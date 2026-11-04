import 'dart:math' as math;
import 'dart:ui' show Color;

import 'csv.dart';
import 'models.dart';
import 'obiettivo.dart';
import 'serie_sessione.dart';

// Potenza in bici: zone dall'FTP (come Garmin e intervals.icu), obiettivi in
// watt per le sedute del piano e le serie registrate dall'app con i sensori.

/// Le sette zone di potenza di Coggan, in percentuale dell'FTP (la potenza
/// che si tiene per circa un'ora).
class ZonePotenza {
  final int ftp; // watt
  const ZonePotenza(this.ftp);

  /// Limiti superiori in % dell'FTP: Z1 fino a 55, Z2 fino a 75…; Z7 oltre 150.
  static const quote = [55, 75, 90, 105, 120, 150];
  static const nomi = [
    'Recupero',
    'Fondo',
    'Medio',
    'Soglia',
    'VO2max',
    'Anaerobica',
    'Sprint',
  ];

  /// Zona [n] da 1 a 7: (da, a) in watt; [a] è null per la Z7, senza tetto.
  (int, int?) zona(int n) {
    final da = n == 1 ? 0 : (ftp * quote[n - 2] / 100).round() + 1;
    final a = n == 7 ? null : (ftp * quote[n - 1] / 100).round();
    return (da, a);
  }

  /// Il range in parole: "150-200 W", "fino a 150 W", "oltre 375 W".
  String testo(int n) {
    final (da, a) = zona(n);
    if (n == 1) return 'fino a $a W';
    if (a == null) return 'oltre ${da - 1} W';
    return '$da-$a W';
  }

  /// In quale zona cade una potenza (1-7).
  int zonaDi(int watt) {
    for (var n = 7; n >= 2; n--) {
      if (watt >= zona(n).$1) return n;
    }
    return 1;
  }
}

/// Colori delle sette zone di potenza, come le barre di Garmin.
const coloriZonePotenza = [
  Color(0xFF9A9AA5),
  Color(0xFF2EA8FF),
  Color(0xFF22E07A),
  Color(0xFFFFC233),
  Color(0xFFFF8A3D),
  Color(0xFFFF3B47),
  Color(0xFFB566FF),
];

final _wattScritti = RegExp(
  r'(\d{2,4})\s*(?:-|–|a)\s*(\d{2,4})\s*w\b|(\d{2,4})\s*w\b',
  caseSensitive: false,
);
final _percentuale = RegExp(
  r'(\d{2,3})\s*(?:-|–)\s*(\d{2,3})\s*%|(\d{2,3})\s*%',
);
final _zona = RegExp(r'\b(?:zona\s*|Z)([1-7])\b', caseSensitive: false);

/// I watt da tenere in un passo di bici: watt scritti ("200-220 W"), % dell'FTP
/// ("88-94%", "75% FTP") o zona ("zona 4"). Un recupero senza obiettivo va
/// piano (45-55%). Null se il passo non dice niente.
(int, int)? rangeWatt(
  String intensita,
  ZonePotenza p, {
  bool recupero = false,
}) {
  final w = _wattScritti.firstMatch(intensita);
  if (w != null) {
    if (w[3] != null) {
      final v = int.parse(w[3]!);
      return (v, v);
    }
    final da = int.parse(w[1]!), a = int.parse(w[2]!);
    return da <= a ? (da, a) : (a, da);
  }
  final q = _percentuale.firstMatch(intensita);
  if (q != null) {
    int watt(String x) => (p.ftp * int.parse(x) / 100).round();
    if (q[3] != null) {
      final v = watt(q[3]!);
      return (v, v);
    }
    final da = watt(q[1]!), a = watt(q[2]!);
    return da <= a ? (da, a) : (a, da);
  }
  final z = _zona.firstMatch(intensita);
  if (z != null) {
    final n = int.parse(z[1]!);
    final (da, a) = p.zona(n);
    // Z1 da 45% (non da zero), Z7 fino al 180%: servono a ERG e diagramma.
    return (n == 1 ? (p.ftp * 0.45).round() : da, a ?? (p.ftp * 1.8).round());
  }
  if (recupero) {
    return ((p.ftp * 0.45).round(), (p.ftp * 0.55).round());
  }
  return null;
}

/// I watt che il rullo tiene in ERG: il centro del range, a passi di 5 W,
/// corretto da [scala] (i tasti −5% e +5%).
int wattErg((int, int) range, {double scala = 1}) {
  final centro = (range.$1 + range.$2) / 2 * scala;
  return ((centro / 5).round() * 5).clamp(0, 2000);
}

/// Il range in parole: "181-210 W" o "200 W".
String fmtRange((int, int) r) =>
    r.$1 == r.$2 ? '${r.$1} W' : '${r.$1}-${r.$2} W';

/// "zona 2" in un testo di bici diventa "zona 2 (150-200 W · 125-137 bpm)":
/// i watt per chi ha il rullo o il misuratore, il battito per chi no.
String conWatt(String testo, ZonePotenza? p, Zone z) {
  if (p == null) return conBpm(testo, z);
  return testo
      .replaceAllMapped(RegExp(r'zona ([1-5])(?! \()', caseSensitive: false), (
        m,
      ) {
        final n = int.parse(m[1]!);
        final (da, a) = z.zona(n);
        return '${m[0]} (${p.testo(n)} · $da-$a bpm)';
      })
      // "88-94%" dell'FTP: anche in watt.
      .replaceAllMapped(
        RegExp(r'(\d{2,3})(?:\s*-\s*(\d{2,3}))?\s*%(?:\s*FTP)?(?! \()'),
        (m) {
          int w(String x) => (p.ftp * int.parse(x) / 100).round();
          final da = w(m[1]!);
          return m[2] == null
              ? '${m[0]} ($da W)'
              : '${m[0]} ($da-${w(m[2]!)} W)';
        },
      );
}

/// L'intensità con watt e battito in bici, solo battito negli altri sport.
String intensitaCon(String testo, String sport, ZonePotenza? p, Zone z) =>
    stessoSport(sport, 'Bici') ? conWatt(testo, p, z) : conBpm(testo, z);

/// Margine sui limiti della zona prima di avvisare (una salita breve, un
/// cambio di rapporto).
const marginePotenza = 0.03;

/// Fuori zona di potenza: 1 sopra, -1 sotto (solo dalla zona 3 in su, come
/// per il battito: in un'uscita di fondo andare più piano va bene), 0 dentro.
int versoPotenza(int watt, int obiettivo, ZonePotenza p) {
  final (da, a) = p.zona(obiettivo);
  if (a != null && watt > a * (1 + marginePotenza)) return 1;
  if (obiettivo >= 3 && watt < da * (1 - marginePotenza)) return -1;
  return 0;
}

/// Fuori dal range di watt di un passo: 1 sopra, -1 sotto (solo se il
/// passo chiede almeno il 75% dell'FTP), 0 dentro.
int versoRange(int watt, (int, int) r, ZonePotenza p) {
  if (watt > r.$2 * (1 + marginePotenza)) return 1;
  if (r.$1 > p.ftp * 0.75 && watt < r.$1 * (1 - marginePotenza)) return -1;
  return 0;
}

/// La frase a voce per un range: "260 watt, scendi sotto 230."
String fraseRange(int watt, (int, int) r, int verso) => verso > 0
    ? '$watt watt, scendi sotto ${r.$2}.'
    : '$watt watt, sali sopra ${r.$1}.';

/// La frase a voce: "260 watt, scendi sotto 230." Sopra si dice il tetto,
/// sotto il minimo della zona.
String frasePotenza(int watt, int obiettivo, int verso, ZonePotenza p) {
  final (da, a) = p.zona(obiettivo);
  return verso > 0
      ? '$watt watt, scendi sotto ${a ?? da}.'
      : '$watt watt, sali sopra $da.';
}

/// Media degli ultimi [secondi] campioni, come il "3 s" dei ciclocomputer:
/// il valore istantaneo salta a ogni pedalata.
int? mediaRecente(List<Campione> serie, DateTime ora, {int secondi = 3}) {
  final da = ora.subtract(Duration(seconds: secondi));
  final ultimi = [
    for (final c in serie.reversed.take(secondi + 2))
      if (c.t.isAfter(da)) c.v,
  ];
  if (ultimi.isEmpty) return null;
  return (ultimi.reduce((a, b) => a + b) / ultimi.length).round();
}

/// Tempo passato in ogni zona di potenza (1-7); i buchi oltre il minuto
/// (pause) non contano.
Map<int, Duration> tempoNelleZonePotenza(List<Campione> w, ZonePotenza p) {
  final out = {for (var n = 1; n <= 7; n++) n: Duration.zero};
  final ordinata = [...w]..sort((a, b) => a.t.compareTo(b.t));
  for (var i = 1; i < ordinata.length; i++) {
    final dt = ordinata[i].t.difference(ordinata[i - 1].t);
    if (dt.inSeconds <= 0 || dt.inSeconds > 60) continue;
    final n = p.zonaDi(ordinata[i - 1].v.round());
    out[n] = out[n]! + dt;
  }
  return out;
}

/// Potenza normalizzata: media mobile di 30 secondi, alla quarta, media,
/// radice quarta. Pesa di più i tratti duri, come la fatica vera. Null se
/// l'attività dura meno di un minuto.
int? potenzaNormalizzata(List<Campione> w) {
  final ordinata = [...w]..sort((a, b) => a.t.compareTo(b.t));
  if (ordinata.length < 2 ||
      ordinata.last.t.difference(ordinata.first.t).inSeconds < 60) {
    return null;
  }
  // Un valore al secondo; i secondi senza campione tengono l'ultimo valore.
  final inizio = ordinata.first.t;
  final secondi = ordinata.last.t.difference(inizio).inSeconds + 1;
  final alSecondo = List<double>.filled(secondi, 0);
  var k = 0;
  for (var s = 0; s < secondi; s++) {
    final t = inizio.add(Duration(seconds: s));
    while (k + 1 < ordinata.length && !ordinata[k + 1].t.isAfter(t)) {
      k++;
    }
    alSecondo[s] = ordinata[k].v;
  }
  var somma = 0.0, quarte = 0.0, n = 0;
  for (var s = 0; s < secondi; s++) {
    somma += alSecondo[s];
    if (s >= 30) somma -= alSecondo[s - 30];
    if (s >= 29) {
      quarte += math.pow(somma / 30, 4);
      n++;
    }
  }
  return n == 0 ? null : math.pow(quarte / n, 0.25).round();
}

/// "zona 2" in un passo di bici → "56-75%" (dell'FTP) per intervals.icu, che
/// lo passa a Garmin come obiettivo di potenza; anche watt ("200-220w") e %
/// scritti. Null se non c'è niente.
String? obiettivoPotenzaIcu(String intensita) {
  final w = _wattScritti.firstMatch(intensita);
  if (w != null) {
    return w[3] != null ? '${w[3]}w' : '${w[1]}-${w[2]}w';
  }
  final q = _percentuale.firstMatch(intensita);
  if (q != null) return q[3] != null ? '${q[3]}%' : '${q[1]}-${q[2]}%';
  final m = RegExp(r'zona ([1-5])', caseSensitive: false).firstMatch(intensita);
  if (m == null) return null;
  final n = int.parse(m[1]!);
  final da = n == 1 ? 40 : ZonePotenza.quote[n - 2] + 1;
  return '$da-${ZonePotenza.quote[n - 1]}%';
}

/// L'FTP della bici dal profilo dell'atleta di intervals.icu
/// (sportSettings: quello che comprende "Ride"). Null se non c'è.
int? ftpDaAtletaIcu(Object? atleta) {
  if (atleta is! Map) return null;
  final impostazioni = atleta['sportSettings'];
  if (impostazioni is! List) return null;
  for (final s in impostazioni) {
    if (s is! Map) continue;
    final tipi = s['types'];
    if (tipi is! List || !tipi.contains('Ride')) continue;
    final ftp = s['ftp'];
    if (ftp is num && ftp >= 50 && ftp <= 600) return ftp.round();
  }
  return null;
}

// ---------------------------------------------------------------------
// Serie registrate dall'app (battito, potenza e cadenza dai sensori)

const serieAppHeader = ['tempo_ms', 'fc', 'potenza', 'cadenza'];

/// File con le serie registrate dall'app per quel giorno e sport.
String fileSerieApp(DateTime giorno, String sport) =>
    'serie_app_${isoData(giorno).replaceAll('-', '_')}_'
    '${sport.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}.csv';

/// Le serie dell'app in CSV: una riga al secondo, vuoto dove manca il dato.
String serieAppCsv(SerieSessione s) {
  final righe = <int, List<String>>{};
  void metti(List<Campione> serie, int colonna) {
    for (final c in serie) {
      final r = righe.putIfAbsent(
        c.t.millisecondsSinceEpoch,
        () => ['${c.t.millisecondsSinceEpoch}', '', '', ''],
      );
      r[colonna] = '${c.v.round()}';
    }
  }

  metti(s.fc, 1);
  metti(s.potenza, 2);
  metti(s.cadenza, 3);
  final ordinate = righe.keys.toList()..sort();
  return toCsv([serieAppHeader, for (final k in ordinate) righe[k]!]);
}

SerieSessione serieAppDa(String testo) {
  final t = Tabella.da(testo);
  if (t == null) return const SerieSessione();
  final fc = <Campione>[], w = <Campione>[], cad = <Campione>[];
  for (final r in t.righe) {
    final ms = int.tryParse(t.v(r, 'tempo_ms'));
    if (ms == null) continue;
    final ora = DateTime.fromMillisecondsSinceEpoch(ms);
    void leggi(String colonna, List<Campione> dove, double massimo) {
      final v = double.tryParse(t.v(r, colonna));
      if (v != null && v.isFinite && v >= 0 && v <= massimo) {
        dove.add(Campione(ora, v));
      }
    }

    leggi('fc', fc, 250);
    leggi('potenza', w, 3000);
    leggi('cadenza', cad, 250);
  }
  return SerieSessione(fc: fc, potenza: w, cadenza: cad);
}
