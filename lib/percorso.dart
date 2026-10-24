import 'dart:convert';
import 'dart:math' as math;

import 'csv.dart';
import 'models.dart';

/// Un punto GPS: posizione, istante e margine di errore in metri (0 = ignoto).
class PuntoGps {
  final double lat;
  final double lon;
  final DateTime t;
  final double precisione;
  const PuntoGps(this.lat, this.lon, this.t, [this.precisione = 0]);
}

const percorsoHeader = ['lat', 'lon', 'tempo_ms', 'precisione_m'];

/// Gli sport all'aperto di cui ha senso il percorso.
bool sportConPercorso(String sport) =>
    stessoSport(sport, 'Corsa') || stessoSport(sport, 'Bici');

String _pulito(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

/// File del percorso registrato dall'app per quel giorno e sport.
String filePercorsoApp(DateTime giorno, String sport) =>
    'percorso_app_${_pulito(isoData(giorno))}_${_pulito(sport)}.csv';

/// File con la copia del percorso letto da Health Connect (uuid della sessione).
String filePercorsoHc(String uuid) => 'percorso_hc_${_pulito(uuid)}.csv';

/// Distanza in metri tra due punti (formula dell'emisenoverso).
double distanzaM(PuntoGps a, PuntoGps b) {
  const r = 6371000.0;
  double rad(double g) => g * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLon = rad(b.lon - a.lon);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) *
          math.cos(rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(h)));
}

class Percorso {
  final List<PuntoGps> punti;
  const Percorso(this.punti);

  bool get vuoto => punti.length < 2;

  double get distanzaKm {
    var m = 0.0;
    for (var i = 1; i < punti.length; i++) {
      m += distanzaM(punti[i - 1], punti[i]);
    }
    return m / 1000;
  }

  Duration get durata =>
      vuoto ? Duration.zero : punti.last.t.difference(punti.first.t);

  /// Angoli sud-ovest e nord-est: (latMin, lonMin, latMax, lonMax).
  (double, double, double, double) get limiti {
    var a = punti.first.lat, b = punti.first.lon;
    var c = a, d = b;
    for (final p in punti) {
      a = math.min(a, p.lat);
      b = math.min(b, p.lon);
      c = math.max(c, p.lat);
      d = math.max(d, p.lon);
    }
    return (a, b, c, d);
  }

  List<List<String>> toRows() => [
    for (final p in punti)
      [
        p.lat.toStringAsFixed(6),
        p.lon.toStringAsFixed(6),
        '${p.t.millisecondsSinceEpoch}',
        p.precisione.toStringAsFixed(1),
      ],
  ];

  String toCsvText() => toCsv([percorsoHeader, ...toRows()]);

  factory Percorso.daCsv(String testo) {
    final righe = parseCsv(testo);
    final punti = <PuntoGps>[];
    for (final r in righe.skip(1)) {
      if (r.length < 3) continue;
      final lat = double.tryParse(r[0]);
      final lon = double.tryParse(r[1]);
      final ms = int.tryParse(r[2]);
      if (lat == null || lon == null || ms == null) continue;
      punti.add(
        PuntoGps(
          lat,
          lon,
          DateTime.fromMillisecondsSinceEpoch(ms),
          r.length > 3 ? double.tryParse(r[3]) ?? 0 : 0,
        ),
      );
    }
    return Percorso(punti);
  }

  /// Dai numeri mandati da Android: lat, lon, millisecondi, ripetuti.
  factory Percorso.daPiatto(List<double> v) => Percorso([
    for (var i = 0; i + 2 < v.length; i += 3)
      PuntoGps(
        v[i],
        v[i + 1],
        DateTime.fromMillisecondsSinceEpoch(v[i + 2].round()),
      ),
  ]);

  /// La linea per la mappa (GeoJSON: longitudine prima della latitudine).
  Map<String, dynamic> geoJson() => {
    'type': 'FeatureCollection',
    'features': [
      if (!vuoto)
        {
          'type': 'Feature',
          'properties': <String, dynamic>{},
          'geometry': {
            'type': 'LineString',
            'coordinates': [
              for (final p in punti) [p.lon, p.lat],
            ],
          },
        },
    ],
  };

  /// Partenza e arrivo, per i due pallini.
  Map<String, dynamic> geoJsonEstremi() => {
    'type': 'FeatureCollection',
    'features': [
      if (!vuoto)
        for (final (p, ruolo) in [(punti.first, 'via'), (punti.last, 'fine')])
          {
            'type': 'Feature',
            'properties': {'ruolo': ruolo},
            'geometry': {
              'type': 'Point',
              'coordinates': [p.lon, p.lat],
            },
          },
    ],
  };
}

/// Filtro dei punti durante la registrazione: scarta quelli poco precisi, il
/// tremolio da fermo e i salti impossibili. Tiene il conto della distanza.
class FiltroGps {
  /// Oltre questo margine di errore il punto non si usa.
  static const precisioneMassima = 25.0;

  /// Velocità oltre la quale un punto è un salto del GPS (m/s).
  final double velocitaMassima;
  final punti = <PuntoGps>[];
  double metri = 0;

  FiltroGps({required this.velocitaMassima});

  factory FiltroGps.per(String sport) =>
      FiltroGps(velocitaMassima: stessoSport(sport, 'Bici') ? 25 : 10);

  /// Aggiunge il punto se è buono; true se è stato tenuto.
  bool aggiungi(PuntoGps p) {
    if (p.precisione <= 0 || p.precisione > precisioneMassima) return false;
    // Il primo punto, o il primo dopo una pausa: non somma distanza.
    if (punti.isEmpty || _ripresa) {
      _ripresa = false;
      punti.add(p);
      return true;
    }
    final u = punti.last;
    final d = distanzaM(u, p);
    // Da fermo il GPS "tremola" di qualche metro: si ignora.
    if (d < math.max(3, math.max(u.precisione, p.precisione) * 0.5)) {
      return false;
    }
    final s = p.t.difference(u.t).inMilliseconds / 1000;
    if (s <= 0 || d / s > velocitaMassima) return false;
    punti.add(p);
    metri += d;
    return true;
  }

  /// Dopo una pausa il primo punto riparte da lì, senza contare il tratto.
  void riprendi() {
    if (punti.isNotEmpty) _ripresa = true;
  }

  bool _ripresa = false;

  Percorso get percorso => Percorso(List.of(punti));
}

/// Ritmo medio (corsa, "5:42 min/km") o velocità (bici, "24.3 km/h").
String ritmoMedio(String sport, double km, Duration t) {
  if (km < 0.05 || t.inSeconds == 0) return '–';
  final min = t.inSeconds / 60;
  final v = stessoSport(sport, 'Bici') ? km / (min / 60) : min / km;
  return '${fmtRitmo(sport, v)} ${unitaRitmo(sport)}';
}

String fmtKm(double km) => '${km.toStringAsFixed(2).replaceAll('.', ',')} km';

/// Fonte dei riquadri della mappa: OpenFreeMap (gratis, senza chiave).
const fonteRiquadri = 'https://tiles.openfreemap.org/planet';

/// Stile della mappa con i colori del tema: strade spente, percorso al neon.
/// Il percorso sta nella sorgente "percorso", partenza e arrivo in "estremi".
String stileMappa({
  required bool scuro,
  required String colore,
  Map<String, dynamic>? percorso,
  Map<String, dynamic>? estremi,
}) {
  final c = scuro
      ? (
          sfondo: '#0B0B0D',
          verde: '#0F1311',
          acqua: '#12151C',
          edifici: '#121216',
          strade: '#1E1E24',
          principali: '#2A2A32',
          nucleo: '#FFE3E5',
        )
      : (
          sfondo: '#F6F6FA',
          verde: '#EEF3F1',
          acqua: '#E4ECF5',
          edifici: '#ECECF2',
          strade: '#E2E2EA',
          principali: '#D6D6E0',
          nucleo: '#FFFFFF',
        );
  final vuota = {'type': 'FeatureCollection', 'features': <dynamic>[]};
  List<dynamic> larghezza(double a, double b) => [
    'interpolate',
    ['exponential', 1.5],
    ['zoom'],
    12,
    a,
    18,
    b,
  ];
  final stile = {
    'version': 8,
    'sources': {
      'omt': {'type': 'vector', 'url': fonteRiquadri},
      'percorso': {'type': 'geojson', 'data': percorso ?? vuota},
      'estremi': {'type': 'geojson', 'data': estremi ?? vuota},
    },
    'layers': [
      {
        'id': 'sfondo',
        'type': 'background',
        'paint': {'background-color': c.sfondo},
      },
      {
        'id': 'verde',
        'type': 'fill',
        'source': 'omt',
        'source-layer': 'park',
        'paint': {'fill-color': c.verde},
      },
      {
        'id': 'bosco',
        'type': 'fill',
        'source': 'omt',
        'source-layer': 'landcover',
        'filter': [
          'in',
          ['get', 'class'],
          [
            'literal',
            ['wood', 'grass', 'farmland'],
          ],
        ],
        'paint': {'fill-color': c.verde},
      },
      {
        'id': 'acqua',
        'type': 'fill',
        'source': 'omt',
        'source-layer': 'water',
        'paint': {'fill-color': c.acqua},
      },
      {
        'id': 'fiumi',
        'type': 'line',
        'source': 'omt',
        'source-layer': 'waterway',
        'paint': {'line-color': c.acqua, 'line-width': 1.5},
      },
      {
        'id': 'edifici',
        'type': 'fill',
        'source': 'omt',
        'source-layer': 'building',
        'minzoom': 14,
        'paint': {'fill-color': c.edifici},
      },
      {
        'id': 'sentieri',
        'type': 'line',
        'source': 'omt',
        'source-layer': 'transportation',
        'filter': [
          'in',
          ['get', 'class'],
          [
            'literal',
            ['path', 'track'],
          ],
        ],
        'paint': {
          'line-color': c.strade,
          'line-width': larghezza(0.6, 2),
          'line-dasharray': [2, 1.5],
        },
      },
      {
        'id': 'strade',
        'type': 'line',
        'source': 'omt',
        'source-layer': 'transportation',
        'filter': [
          'in',
          ['get', 'class'],
          [
            'literal',
            ['minor', 'service', 'tertiary', 'secondary'],
          ],
        ],
        'layout': {'line-cap': 'round', 'line-join': 'round'},
        'paint': {'line-color': c.strade, 'line-width': larghezza(0.8, 9)},
      },
      {
        'id': 'principali',
        'type': 'line',
        'source': 'omt',
        'source-layer': 'transportation',
        'filter': [
          'in',
          ['get', 'class'],
          [
            'literal',
            ['primary', 'trunk', 'motorway'],
          ],
        ],
        'layout': {'line-cap': 'round', 'line-join': 'round'},
        'paint': {'line-color': c.principali, 'line-width': larghezza(1.2, 14)},
      },
      // Il percorso: tre linee sovrapposte fanno il bagliore al neon.
      {
        'id': 'alone',
        'type': 'line',
        'source': 'percorso',
        'layout': {'line-cap': 'round', 'line-join': 'round'},
        'paint': {
          'line-color': colore,
          'line-width': 16,
          'line-blur': 12,
          'line-opacity': scuro ? 0.55 : 0.4,
        },
      },
      {
        'id': 'luce',
        'type': 'line',
        'source': 'percorso',
        'layout': {'line-cap': 'round', 'line-join': 'round'},
        'paint': {'line-color': colore, 'line-width': 5, 'line-blur': 1.5},
      },
      {
        'id': 'nucleo',
        'type': 'line',
        'source': 'percorso',
        'layout': {'line-cap': 'round', 'line-join': 'round'},
        'paint': {
          'line-color': c.nucleo,
          'line-width': 1.6,
          'line-opacity': 0.9,
        },
      },
      {
        'id': 'estremi',
        'type': 'circle',
        'source': 'estremi',
        'paint': {
          'circle-radius': 6,
          'circle-color': [
            'match',
            ['get', 'ruolo'],
            'via',
            '#22E07A',
            colore,
          ],
          'circle-stroke-width': 2,
          'circle-stroke-color': c.nucleo,
        },
      },
    ],
  };
  return jsonEncode(stile);
}

/// Dimensione massima di un file GPX (molte ore di attività).
const maxByteGpx = 20 * 1024 * 1024;

final _inizioPuntoGpx = RegExp(r'<(?:\w+:)?trkpt\b');
final _tempoGpx = RegExp(r'<(?:\w+:)?time>([^<]+)</(?:\w+:)?time>');

double? _attributo(String attr, String nome) {
  final m = RegExp(r'\b' + nome + r'''\s*=\s*["']([-0-9.]+)["']''')
      .firstMatch(attr);
  return m == null ? null : double.tryParse(m[1]!);
}

/// Percorso da un file GPX (es. esportato da Garmin Connect). Lancia
/// [FormatException] se il file non contiene una traccia.
Percorso percorsoDaGpx(String testo) {
  final punti = <PuntoGps>[];
  // Ogni punto va dal suo "<trkpt" al successivo: una sola passata sul testo,
  // anche se il file è malformato (tag non chiusi).
  final inizi = [for (final m in _inizioPuntoGpx.allMatches(testo)) m.start];
  for (var k = 0; k < inizi.length; k++) {
    final fine = k + 1 < inizi.length ? inizi[k + 1] : testo.length;
    final pezzo = testo.substring(inizi[k], fine);
    final chiusa = pezzo.indexOf('>');
    if (chiusa < 0) continue;
    final attr = pezzo.substring(0, chiusa);
    final lat = _attributo(attr, 'lat');
    final lon = _attributo(attr, 'lon');
    if (lat == null || lon == null || lat.abs() > 90 || lon.abs() > 180) {
      continue;
    }
    final ora = attr.endsWith('/')
        ? null
        : _tempoGpx.firstMatch(pezzo.substring(chiusa))?[1];
    // Senza orario: un secondo dopo il punto prima, solo per l'ordine.
    final t =
        (ora == null ? null : DateTime.tryParse(ora.trim())?.toLocal()) ??
        (punti.isEmpty
            ? DateTime.fromMillisecondsSinceEpoch(0)
            : punti.last.t.add(const Duration(seconds: 1)));
    punti.add(PuntoGps(lat, lon, t));
  }
  if (punti.length < 2) {
    throw const FormatException(
      'Nel file non c\'è un percorso: serve un GPX con la traccia dell\'attività.',
    );
  }
  return Percorso(punti);
}

/// Giorno del percorso, se il GPX ha gli orari.
DateTime? giornoDi(Percorso p) =>
    p.vuoto || p.punti.first.t.year < 2000 ? null : soloData(p.punti.first.t);
