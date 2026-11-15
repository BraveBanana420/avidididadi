import 'dart:math' as math;

import 'csv.dart';
import 'models.dart';
import 'percorso.dart';
import 'l10n/lingua.dart';

// Seguire un percorso già fatto da qualcuno (un GPX di una gara, un giro
// famoso): dove sei sulla traccia, quanto manca, la prossima curva e se sei
// uscito dalla strada. Non è un navigatore: la traccia non ha i nomi delle vie,
// solo la sua forma, e le curve si ricavano da lì.

/// Un punto della traccia da seguire, con la quota se il GPX ce l'ha.
class PuntoTraccia {
  final double lat;
  final double lon;
  final double? quota;
  const PuntoTraccia(this.lat, this.lon, [this.quota]);
}

const tracciaHeader = ['lat', 'lon', 'quota_m'];

double _rad(double g) => g * math.pi / 180;

double _distanza(PuntoTraccia a, PuntoTraccia b) =>
    distanzaGradi(a.lat, a.lon, b.lat, b.lon);

/// Direzione da [a] a [b] in gradi: 0 nord, 90 est.
double direzione(double lat1, double lon1, double lat2, double lon2) {
  final y = math.sin(_rad(lon2 - lon1)) * math.cos(_rad(lat2));
  final x =
      math.cos(_rad(lat1)) * math.sin(_rad(lat2)) -
      math.sin(_rad(lat1)) * math.cos(_rad(lat2)) * math.cos(_rad(lon2 - lon1));
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// Differenza tra due direzioni, da -180 a 180 (positiva = verso destra).
double differenzaAngolo(double da, double a) {
  final d = (a - da) % 360;
  return d > 180 ? d - 360 : d;
}

/// La traccia da seguire: punti, distanze progressive e dislivello.
class Traccia {
  final String nome;
  final List<PuntoTraccia> punti;

  /// Metri dalla partenza a ogni punto.
  final List<double> progressivi;

  Traccia(this.nome, this.punti) : progressivi = _progressivi(punti);

  static List<double> _progressivi(List<PuntoTraccia> p) {
    final m = <double>[0];
    for (var i = 1; i < p.length; i++) {
      m.add(m.last + _distanza(p[i - 1], p[i]));
    }
    return m;
  }

  bool get vuota => punti.length < 2;
  double get metri => progressivi.isEmpty ? 0 : progressivi.last;

  /// Partenza e arrivo vicini: un giro ad anello.
  bool get anello => !vuota && _distanza(punti.first, punti.last) < 150;

  /// Metri di salita, ignorando le oscillazioni sotto i 5 m (il GPS e i
  /// barometri ballano).
  int get dislivello {
    var su = 0.0;
    double? base;
    for (final p in punti) {
      final q = p.quota;
      if (q == null) continue;
      if (base == null || q < base) {
        base = q;
      } else if (q - base >= 5) {
        su += q - base;
        base = q;
      }
    }
    return su.round();
  }

  /// Il punto a [m] metri dalla partenza (interpolato tra due punti).
  PuntoTraccia puntoA(double m) {
    if (m <= 0) return punti.first;
    if (m >= metri) return punti.last;
    final i = _segmento(m);
    final a = punti[i], b = punti[i + 1];
    final lungo = progressivi[i + 1] - progressivi[i];
    final f = lungo <= 0 ? 0.0 : (m - progressivi[i]) / lungo;
    return PuntoTraccia(
      a.lat + (b.lat - a.lat) * f,
      a.lon + (b.lon - a.lon) * f,
    );
  }

  /// Indice del tratto che contiene i [m] metri (ricerca binaria).
  int _segmento(double m) {
    var lo = 0, hi = punti.length - 2;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (progressivi[mid] <= m) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  /// Direzione della strada a [m] metri (guardando 20 m avanti).
  double direzioneA(double m) {
    final a = puntoA(math.max(0, math.min(m, metri - 20)));
    final b = puntoA(math.min(metri, math.max(m, 0) + 20));
    return direzione(a.lat, a.lon, b.lat, b.lon);
  }

  /// Quota a [m] metri, se il GPX ce l'ha.
  double? quotaA(double m) {
    if (m <= 0) return punti.first.quota;
    if (m >= metri) return punti.last.quota;
    final i = _segmento(m);
    final a = punti[i].quota, b = punti[i + 1].quota;
    if (a == null || b == null) return a ?? b;
    final lungo = progressivi[i + 1] - progressivi[i];
    return lungo <= 0 ? a : a + (b - a) * (m - progressivi[i]) / lungo;
  }

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

  /// Per la mappa: la stessa forma di un percorso registrato.
  Percorso get comePercorso =>
      Percorso([for (final p in punti) PuntoGps(p.lat, p.lon, DateTime(0))]);

  String toCsvText() => toCsv([
    tracciaHeader,
    for (final p in punti)
      [
        p.lat.toStringAsFixed(6),
        p.lon.toStringAsFixed(6),
        p.quota?.toStringAsFixed(1) ?? '',
      ],
  ]);

  factory Traccia.daCsv(String nome, String testo) {
    final punti = <PuntoTraccia>[];
    for (final r in parseCsv(testo).skip(1)) {
      if (r.length < 2) continue;
      final lat = double.tryParse(r[0]);
      final lon = double.tryParse(r[1]);
      if (lat == null || lon == null) continue;
      punti.add(
        PuntoTraccia(lat, lon, r.length > 2 ? double.tryParse(r[2]) : null),
      );
    }
    return Traccia(nome, punti);
  }
}

String _testoXml(String s) => s
    .replaceAll(RegExp(r'<!\[CDATA\[|\]\]>'), '')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&#39;', "'")
    .replaceAll('&amp;', '&')
    .trim();

final _nomeGpx = RegExp(
  r'<(?:\w+:)?name>([^<]*(?:<!\[CDATA\[.*?\]\]>)?[^<]*)<',
);
final _quotaGpx = RegExp(r'<(?:\w+:)?ele>([^<]+)</(?:\w+:)?ele>');

double? _attributoGpx(String attr, String nome) {
  final m = RegExp(r'\b' + nome + r'''\s*=\s*["']([-0-9.eE+]+)["']''')
      .firstMatch(attr);
  return m == null ? null : double.tryParse(m[1]!);
}

/// La traccia di un file GPX: i punti della traccia (trkpt) o, se non ci
/// sono, quelli del percorso pianificato (rtept, es. da Komoot o Strava).
/// Il nome è quello del file GPX, altrimenti [nomeFile]. Lancia
/// [FormatException] se non c'è una traccia.
Traccia tracciaDaGpx(String testo, {String nomeFile = 'Percorso'}) {
  var tag = 'trkpt';
  var inizi = [
    for (final m in RegExp(r'<(?:\w+:)?trkpt\b').allMatches(testo)) m.start,
  ];
  if (inizi.length < 2) {
    tag = 'rtept';
    inizi = [
      for (final m in RegExp(r'<(?:\w+:)?rtept\b').allMatches(testo)) m.start,
    ];
  }
  final punti = <PuntoTraccia>[];
  for (var k = 0; k < inizi.length; k++) {
    var fine = k + 1 < inizi.length ? inizi[k + 1] : testo.length;
    final chiude = testo.indexOf(RegExp('</(?:\\w+:)?$tag>'), inizi[k]);
    if (chiude >= 0 && chiude < fine) fine = chiude;
    final pezzo = testo.substring(inizi[k], fine);
    final chiusa = pezzo.indexOf('>');
    if (chiusa < 0) continue;
    final attr = pezzo.substring(0, chiusa);
    final lat = _attributoGpx(attr, 'lat');
    final lon = _attributoGpx(attr, 'lon');
    if (lat == null || lon == null || lat.abs() > 90 || lon.abs() > 180) {
      continue;
    }
    final q = attr.endsWith('/')
        ? null
        : double.tryParse(
            _quotaGpx.firstMatch(pezzo.substring(chiusa))?[1]?.trim() ?? '',
          );
    punti.add(PuntoTraccia(lat, lon, q));
  }
  if (punti.length < 2) {
    throw FormatException(l10n.nelFileNonC);
  }
  // Il nome della traccia, o quello generale del file, prima dei punti.
  final prima = testo.substring(0, inizi.first);
  final nomi = [for (final m in _nomeGpx.allMatches(prima)) _testoXml(m[1]!)]
      .where((n) => n.isNotEmpty)
      .toList();
  final nome = nomi.isEmpty ? nomeFile : nomi.last;
  return Traccia(nome.length > 60 ? nome.substring(0, 60) : nome, punti);
}

/// Toglie i punti superflui (Douglas-Peucker): la forma resta entro
/// [tolleranza] metri. Un GPX registrato ha un punto al secondo, quasi tutti
/// in linea: si tiene molto meno e i calcoli vanno più veloci.
List<PuntoTraccia> semplifica(List<PuntoTraccia> p, double tolleranza) {
  if (p.length < 3) return List.of(p);
  final tieni = List<bool>.filled(p.length, false);
  tieni[0] = tieni[p.length - 1] = true;
  final pila = <(int, int)>[(0, p.length - 1)];
  while (pila.isNotEmpty) {
    final (a, b) = pila.removeLast();
    var max = 0.0;
    var indice = -1;
    for (var i = a + 1; i < b; i++) {
      final d = _distanzaDalTratto(p[i], p[a], p[b]).$1;
      if (d > max) {
        max = d;
        indice = i;
      }
    }
    if (indice >= 0 && max > tolleranza) {
      tieni[indice] = true;
      pila
        ..add((a, indice))
        ..add((indice, b));
    }
  }
  return [
    for (var i = 0; i < p.length; i++)
      if (tieni[i]) p[i],
  ];
}

/// Distanza in metri di [p] dal tratto [a]-[b] e frazione del tratto (0-1)
/// del punto più vicino. Piano locale: per pochi km l'errore è trascurabile.
(double, double) _distanzaDalTratto(
  PuntoTraccia p,
  PuntoTraccia a,
  PuntoTraccia b,
) {
  const r = 6371000.0;
  final k = math.cos(_rad(p.lat));
  double x(PuntoTraccia q) => _rad(q.lon - p.lon) * k * r;
  double y(PuntoTraccia q) => _rad(q.lat - p.lat) * r;
  final ax = x(a), ay = y(a), bx = x(b), by = y(b);
  final dx = bx - ax, dy = by - ay;
  final l2 = dx * dx + dy * dy;
  final f = l2 == 0 ? 0.0 : ((-ax * dx - ay * dy) / l2).clamp(0.0, 1.0);
  final cx = ax + f * dx, cy = ay + f * dy;
  return (math.sqrt(cx * cx + cy * cy), f);
}

enum TipoCurva { leggera, normale, stretta, inversione }

/// Una curva della traccia: dove (metri dalla partenza) e di quanto gira
/// (gradi, positivi a destra).
class Curva {
  final double metri;
  final double angolo;
  const Curva(this.metri, this.angolo);

  bool get destra => angolo > 0;

  TipoCurva get tipo {
    final a = angolo.abs();
    if (a >= 165) return TipoCurva.inversione;
    if (a >= 125) return TipoCurva.stretta;
    if (a >= 75) return TipoCurva.normale;
    return TipoCurva.leggera;
  }

  /// "gira a destra", "tornante a sinistra", "torna indietro".
  String get frase {
    final lato = destra ? l10n.destra : l10n.sinistra;
    return switch (tipo) {
      TipoCurva.leggera => destra ? l10n.tieniDestra : l10n.tieniSinistra,
      TipoCurva.normale => 'gira $lato',
      TipoCurva.stretta => l10n.curvaStretta(lato),
      TipoCurva.inversione => l10n.tornaIndietro,
    };
  }

  /// La stessa curva detta subito dopo un'altra: "poi subito a sinistra",
  /// "poi tieni la destra".
  String get fraseDopo => tipo == TipoCurva.normale
      ? l10n.poiSubito(destra ? l10n.destra : l10n.sinistra)
      : 'poi $frase';
}

/// Curve sotto questo angolo non si annunciano: sono la strada che piega.
const angoloMinimoCurva = 45.0;

/// Le curve della traccia. Per ogni vertice si confronta la direzione dei 30
/// metri prima con quella dei 30 dopo: un incrocio gira tutto in pochi metri,
/// una strada che piega dolcemente no (e non si annuncia).
List<Curva> curveDi(Traccia t) {
  if (t.vuota) return const [];
  const braccio = 30.0;
  final candidate = <Curva>[];
  for (var i = 1; i < t.punti.length - 1; i++) {
    final m = t.progressivi[i];
    if (m < braccio / 2 || m > t.metri - braccio / 2) continue;
    final prima = t.puntoA(m - braccio);
    final dopo = t.puntoA(m + braccio);
    final p = t.punti[i];
    final angolo = differenzaAngolo(
      direzione(prima.lat, prima.lon, p.lat, p.lon),
      direzione(p.lat, p.lon, dopo.lat, dopo.lon),
    );
    if (angolo.abs() >= angoloMinimoCurva / 2) {
      candidate.add(Curva(m, angolo));
    }
  }
  // Più vertici della stessa curva (entro il braccio): si tiene il più netto.
  final curve = <Curva>[];
  for (final c in candidate) {
    if (curve.isNotEmpty && c.metri - curve.last.metri < braccio) {
      final u = curve.last;
      // Stesso verso: è la stessa curva. Verso opposto: una "esse", si
      // tengono tutte e due.
      if ((u.angolo > 0) == (c.angolo > 0)) {
        if (c.angolo.abs() > u.angolo.abs()) curve.last = c;
        continue;
      }
    }
    curve.add(c);
  }
  return [
    for (final c in curve)
      if (c.angolo.abs() >= angoloMinimoCurva) c,
  ];
}

/// Quello che la guida ha da dire: alla voce, con bip e vibrazione.
enum TipoAvvisoGuida { curva, fuori, rientro, contrario, arrivo }

class AvvisoGuida {
  final TipoAvvisoGuida tipo;
  final String frase;

  /// Il preavviso di una curva ("Tra 250 metri…"): può aspettare che finisca
  /// un'altra frase. Tutto il resto va detto subito.
  final bool preavviso;
  const AvvisoGuida(this.tipo, this.frase, {this.preavviso = false});

  /// Da dire interrompendo le altre frasi (km, ritmo): a 30 km/h cinque
  /// secondi di ritardo sono 40 metri, e la curva è passata.
  bool get urgente => !preavviso;
  @override
  String toString() => frase;
}

/// "250 metri", "1,2 chilometri".
String parlaMetri(double m) {
  if (m < 1000) return '${m.round()} metri';
  final km = (m / 100).round() / 10;
  final testo = km == km.roundToDouble()
      ? '${km.round()}'
      : km.toStringAsFixed(1).replaceAll('.', ',');
  return '$testo ${km == 1 ? l10n.parolaChilometro : l10n.parolaChilometri}';
}

/// "250 m", "1,2 km" per lo schermo.
String fmtMetri(double m) {
  if (m < 1000) return '${(m / 10).round() * 10} m';
  return '${(m / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

/// Segue la posizione sulla traccia. A ogni punto GPS ([aggiorna]) dice dove
/// sei, quanto manca, la prossima curva, e cosa annunciare.
class Guida {
  final Traccia traccia;
  final List<Curva> curve;
  final bool bici;

  /// Metri percorsi sulla traccia (null finché non ci si è sopra).
  double? progresso;

  /// Distanza dalla traccia, in metri (null prima del primo punto).
  double? distanza;

  /// Fuori percorso da abbastanza tempo da dirlo.
  bool fuori = false;

  bool arrivato = false;

  Guida(this.traccia, {required this.bici}) : curve = curveDi(traccia);

  /// Sotto questa distanza si è sulla traccia (il GPS sbaglia di qualche metro
  /// e chi l'ha registrata pure).
  double get sogliaSopra => bici ? 40 : 35;

  /// Distanze degli annunci di una curva: il preavviso e "adesso". Più si va
  /// veloci, prima si avvisa: il preavviso circa 25 secondi prima (in bici),
  /// "adesso" circa 7 secondi prima, il tempo di dirlo e di frenare.
  double preavvisoA(double? mps) {
    final v = mps ?? 0;
    return bici ? (v * 25).clamp(250, 500).toDouble() : 100;
  }

  double adessoA(double? mps) {
    final v = mps ?? 0;
    return bici ? math.max(60, v * 7) : math.max(25, v * 6);
  }

  double get preavviso => preavvisoA(null);
  double get adesso => adessoA(null);

  /// Velocità dell'ultimo punto (m/s), per le distanze degli annunci.
  double? _velocita;

  static const _attesaFuori = Duration(seconds: 10);
  static const _attesaRientro = Duration(seconds: 3);
  static const _attesaContrario = Duration(seconds: 15);

  DateTime? _lontanoDa;
  DateTime? _vicinoDa;
  DateTime? _contrarioDa;
  DateTime? _ultimoContrario;
  PuntoTraccia? _ultimaPosizione;
  double? _direzioneMoto;

  /// Per ogni curva: 1 preavviso dato, 2 annuncio "adesso" dato.
  final _annunci = <int, int>{};

  double? get metriMancanti =>
      progresso == null ? null : math.max(0, traccia.metri - progresso!);

  /// La prossima curva davanti, e quanti metri mancano.
  (Curva, double)? get prossimaCurva {
    final p = progresso;
    if (p == null) return null;
    for (final c in curve) {
      if (c.metri > p) return (c, c.metri - p);
    }
    return null;
  }

  /// La direzione della traccia dove sei (per girare la mappa da fermi).
  double? get direzioneTraccia =>
      progresso == null ? null : traccia.direzioneA(progresso!);

  /// Il punto della traccia dove si è: (metri dalla partenza, distanza).
  /// Prima si cerca poco dopo [ultimo], il tratto più vicino (tornare indietro
  /// costa un po'): così un anello, una traccia che si incrocia o un andata e
  /// ritorno sulla stessa strada non confondono. Se lì non c'è niente (si è
  /// tagliato o si riparte da un altro punto), il tratto vicino più vicino a
  /// dove si era.
  (double, double) _aggancia(PuntoTraccia pos, double? ultimo) {
    final t = traccia;
    (double, double)? vicino, lontano;
    var punteggioVicino = double.infinity;
    var costoLontano = double.infinity;
    var piuVicino = double.infinity;
    var metriVicino = 0.0;
    final base = ultimo ?? 0;
    for (var i = 0; i < t.punti.length - 1; i++) {
      final (d, f) = _distanzaDalTratto(pos, t.punti[i], t.punti[i + 1]);
      final m =
          t.progressivi[i] + f * (t.progressivi[i + 1] - t.progressivi[i]);
      if (d < piuVicino) {
        piuVicino = d;
        metriVicino = m;
      }
      if (d > sogliaSopra) continue;
      final avanti = m - base;
      if (ultimo != null && avanti >= -50 && avanti <= 300) {
        final punteggio = d + (avanti >= 0 ? avanti * 0.05 : -avanti * 0.5);
        if (punteggio < punteggioVicino) {
          punteggioVicino = punteggio;
          vicino = (m, d);
        }
      }
      final costo = avanti >= 0 ? avanti : -avanti * 3;
      if (costo < costoLontano) {
        costoLontano = costo;
        lontano = (m, d);
      }
    }
    // Nessun tratto vicino: conta solo la distanza dal più vicino.
    return vicino ?? lontano ?? (metriVicino, piuVicino);
  }

  /// Nuova posizione. Restituisce gli avvisi da dare adesso (anche nessuno).
  /// [velocita] in m/s, se si sa: in bici sposta gli annunci delle curve.
  List<AvvisoGuida> aggiorna(
    double lat,
    double lon,
    DateTime ora, {
    double? velocita,
  }) {
    if (traccia.vuota) return const [];
    _velocita = velocita;
    final pos = PuntoTraccia(lat, lon);
    final avvisi = <AvvisoGuida>[];
    _aggiornaMoto(pos);

    final (m, d) = _aggancia(pos, progresso);
    distanza = d;
    final sopra = d <= sogliaSopra;
    // Lontani dalla traccia conta solo la distanza: il progresso parte (o
    // riparte) quando ci si sale.
    if (sopra) progresso = m;

    if (sopra) {
      _lontanoDa = null;
      _vicinoDa ??= ora;
      if (fuori && ora.difference(_vicinoDa!) >= _attesaRientro) {
        fuori = false;
        avvisi.add(AvvisoGuida(TipoAvvisoGuida.rientro, l10n.nuovoSulPercorso));
      }
    } else {
      _vicinoDa = null;
      _lontanoDa ??= ora;
      if (!fuori &&
          progresso != null &&
          ora.difference(_lontanoDa!) >= _attesaFuori) {
        fuori = true;
        avvisi.add(
          AvvisoGuida(
            TipoAvvisoGuida.fuori,
            l10n.seiFuoriPercorsoDalla(parlaMetri(_arrotonda(d))),
          ),
        );
      }
    }

    if (!sopra || fuori || progresso == null) return avvisi;
    final p = progresso!;

    // Verso sbagliato: ci si muove contro la direzione della traccia.
    if (_direzioneMoto != null) {
      final diff = differenzaAngolo(
        traccia.direzioneA(p),
        _direzioneMoto!,
      ).abs();
      if (diff > 135) {
        _contrarioDa ??= ora;
        final ripetibile =
            _ultimoContrario == null ||
            ora.difference(_ultimoContrario!) > const Duration(minutes: 2);
        if (ora.difference(_contrarioDa!) >= _attesaContrario && ripetibile) {
          _ultimoContrario = ora;
          avvisi.add(
            AvvisoGuida(TipoAvvisoGuida.contrario, l10n.staiAndandoNelSenso),
          );
        }
      } else {
        _contrarioDa = null;
      }
    }

    // Arrivo: negli ultimi metri, dopo aver fatto quasi tutta la traccia.
    if (!arrivato && traccia.metri - p < 30 && p > traccia.metri * 0.8) {
      arrivato = true;
      avvisi.add(
        AvvisoGuida(TipoAvvisoGuida.arrivo, l10n.arrivoPercorsoCompletato),
      );
      return avvisi;
    }

    final curva = _avvisoCurva(p);
    if (curva != null) avvisi.add(curva);
    return avvisi;
  }

  double _arrotonda(double m) =>
      m < 1000 ? (m / 10).round() * 10.0 : (m / 100).round() * 100.0;

  AvvisoGuida? _avvisoCurva(double p) {
    final preavviso = preavvisoA(_velocita);
    final adesso = adessoA(_velocita);
    // Due curve più vicine di così (circa 8 secondi) si dicono insieme.
    final legate = math.max(80, adesso * 1.2);
    for (var i = 0; i < curve.length; i++) {
      final c = curve[i];
      final manca = c.metri - p;
      if (manca <= 0) continue;
      if (manca > preavviso) return null;
      final fatto = _annunci[i] ?? 0;
      final dopo = i + 1 < curve.length && curve[i + 1].metri - c.metri < legate
          ? ', ${curve[i + 1].fraseDopo}'
          : '';
      if (manca <= adesso) {
        if (fatto >= 2) return null;
        _annunci[i] = 2;
        // La curva subito dopo è già detta qui.
        if (dopo.isNotEmpty) _annunci[i + 1] = 2;
        return AvvisoGuida(
          TipoAvvisoGuida.curva,
          '${_maiuscola(c.frase)}$dopo.',
        );
      }
      if (fatto >= 1) return null;
      _annunci[i] = 1;
      if (dopo.isNotEmpty) _annunci[i + 1] = math.max(_annunci[i + 1] ?? 0, 1);
      final passo = bici ? 50.0 : 10.0;
      final tra = (manca / passo).round() * passo;
      return AvvisoGuida(
        TipoAvvisoGuida.curva,
        l10n.tra(parlaMetri(tra), c.frase, dopo),
        preavviso: true,
      );
    }
    return null;
  }

  /// La direzione in cui ci si muove, dagli ultimi 15 metri.
  void _aggiornaMoto(PuntoTraccia pos) {
    final u = _ultimaPosizione;
    if (u == null) {
      _ultimaPosizione = pos;
      return;
    }
    if (_distanza(u, pos) >= 15) {
      _direzioneMoto = direzione(u.lat, u.lon, pos.lat, pos.lon);
      _ultimaPosizione = pos;
    }
  }

  /// Dopo un'interruzione dell'app: si riparte dai metri salvati.
  void riprendiDa(double metri) {
    progresso = metri;
    for (var i = 0; i < curve.length; i++) {
      if (curve[i].metri <= metri) _annunci[i] = 2;
    }
  }
}

String _maiuscola(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Un percorso della raccolta "I miei percorsi" (percorsi_salvati.csv); i punti
/// stanno in `traccia_<id>.csv`.
class PercorsoSalvato {
  final String id;
  final String nome;
  final double km;
  final int dislivello;
  final DateTime aggiunto;

  const PercorsoSalvato({
    required this.id,
    required this.nome,
    required this.km,
    required this.dislivello,
    required this.aggiunto,
  });

  static const header = ['id', 'nome', 'km', 'dislivello_m', 'aggiunto'];

  String get file => fileTraccia(id);

  List<String> toRow() => [
    id,
    nome,
    km.toStringAsFixed(2),
    '$dislivello',
    isoData(aggiunto),
  ];

  /// L'id finisce nel nome di un file: solo lettere minuscole e cifre.
  static PercorsoSalvato? da(Tabella t, List<String> r) {
    final id = t.v(r, 'id');
    if (!RegExp(r'^[a-z0-9]+$').hasMatch(id)) return null;
    return PercorsoSalvato(
      id: id,
      nome: t.v(r, 'nome'),
      km: double.tryParse(t.v(r, 'km')) ?? 0,
      dislivello: int.tryParse(t.v(r, 'dislivello_m')) ?? 0,
      aggiunto: DateTime.tryParse(t.v(r, 'aggiunto')) ?? DateTime(2000),
    );
  }

  PercorsoSalvato copyWith({String? nome}) => PercorsoSalvato(
    id: id,
    nome: nome ?? this.nome,
    km: km,
    dislivello: dislivello,
    aggiunto: aggiunto,
  );
}

String fileTraccia(String id) => 'traccia_$id.csv';

/// Tolleranza della traccia salvata: la forma resta entro 3 metri.
const tolleranzaTraccia = 3.0;

/// Percorso assegnato a una seduta in programma (percorsi_piano.csv).
const percorsiPianoHeader = ['data', 'sport', 'id_percorso'];

/// Chiave della seduta in programma: giorno e sport.
String chiaveSeduta(DateTime giorno, String sport) =>
    '${isoData(giorno)}|${normSport(sport)}';
