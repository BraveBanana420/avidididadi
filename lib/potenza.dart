import 'dart:math' as math;
import 'dart:ui' show Color;

import 'csv.dart';
import 'models.dart';
import 'obiettivo.dart';
import 'serie_sessione.dart';
import 'l10n/lingua.dart';

// Potenza in bici: zone dall'FTP (come Garmin e intervals.icu), obiettivi in
// watt per le sedute del piano e le serie registrate dall'app con i sensori.

/// Le sette zone di potenza di Coggan, in percentuale dell'FTP (la potenza
/// che si tiene per circa un'ora).
class ZonePotenza {
  final int ftp; // watt
  final List<int> limiti;
  final List<Color> colori;
  final bool _corsa;
  const ZonePotenza(this.ftp)
    : limiti = quote,
      _corsa = false,
      colori = coloriZonePotenza;

  /// Nomi delle zone nella lingua in uso.
  List<String> get nomiZone => _corsa ? nomiCorsa : nomi;

  /// La corsa ha le sue cinque zone e la sua soglia: gli stessi watt di una
  /// pedalata, correndo, sono tutt'altro sforzo.
  const ZonePotenza.corsa(this.ftp)
    : limiti = quoteCorsa,
      _corsa = true,
      colori = coloriZoneBattito;

  /// Limiti superiori in % dell'FTP: Z1 fino a 55, Z2 fino a 75…; Z7 oltre 150.
  static const quote = [55, 75, 90, 105, 120, 150];
  static const quoteCorsa = [80, 90, 100, 115];
  static List<String> get nomiCorsa => [
    l10n.facile,
    l10n.medio,
    'Soglia',
    'Intervalli',
    'Ripetute',
  ];
  static List<String> get nomi => [
    'Recupero',
    l10n.fondo,
    l10n.medio,
    'Soglia',
    l10n.vo2max,
    l10n.anaerobica,
    l10n.sprint,
  ];

  /// Quante zone ci sono.
  int get numero => limiti.length + 1;

  /// Zona [n] da 1: (da, a) in watt; [a] è null per l'ultima, senza tetto.
  (int, int?) zona(int n) {
    final da = n == 1 ? 0 : (ftp * limiti[n - 2] / 100).round() + 1;
    final a = n == numero ? null : (ftp * limiti[n - 1] / 100).round();
    return (da, a);
  }

  /// Il range in parole: "150-200 W", "fino a 150 W", "oltre 375 W".
  String testo(int n) {
    final (da, a) = zona(n);
    if (n == 1) return l10n.finoW(a!);
    if (a == null) return l10n.oltreW(da - 1);
    return '$da-$a W';
  }

  /// In quale zona cade una potenza.
  int zonaDi(int watt) {
    for (var n = numero; n >= 2; n--) {
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

/// Colori delle cinque zone di battito.
const coloriZoneBattito = [
  Color(0xFF9A9AA5),
  Color(0xFF2EA8FF),
  Color(0xFF22E07A),
  Color(0xFFFFC233),
  Color(0xFFFF3B47),
];

final _wattScritti = RegExp(
  r'(\d{2,4})\s*(?:-|–|a)\s*(\d{2,4})\s*w\b|(\d{2,4})\s*w\b',
  caseSensitive: false,
);
final _percentuale = RegExp(
  r'(\d{2,3})\s*(?:-|–)\s*(\d{2,3})\s*%|(\d{2,3})\s*%',
);
final _zona = RegExp(r'\b(?:zona\s*|Z)([1-7])\b', caseSensitive: false);

/// I watt scritti in un passo ("200 W", "190-210 W"): valgono anche senza FTP.
(int, int)? rangeWattScritti(String intensita) {
  final w = _wattScritti.firstMatch(intensita);
  if (w == null) return null;
  if (w[3] != null) {
    final v = int.parse(w[3]!);
    return (v, v);
  }
  final da = int.parse(w[1]!), a = int.parse(w[2]!);
  return da <= a ? (da, a) : (a, da);
}

/// Quello che si scrive nel campo dei watt: "200" diventa "200 W", "190-210"
/// "190-210 W"; le % dell'FTP restano così. Vuoto se non vuol dire niente.
String obiettivoWatt(String testo) {
  final t = testo.trim().replaceAll('–', '-').replaceAll(RegExp(r'\s+'), ' ');
  if (RegExp(
    r'^\d{2,3}( ?- ?\d{2,3})? ?%( ?FTP)?$',
    caseSensitive: false,
  ).hasMatch(t)) {
    return t;
  }
  final n = RegExp(
    r'^(\d{2,4})( ?- ?(\d{2,4}))? ?(w|watt)?$',
    caseSensitive: false,
  ).firstMatch(t);
  if (n == null) return '';
  return n[3] == null ? '${n[1]} W' : '${n[1]}-${n[3]} W';
}

/// Vero se l'intensità è in watt o in % dell'FTP (non una zona o un passo).
bool intensitaInWatt(String intensita) =>
    _wattScritti.hasMatch(intensita) || _percentuale.hasMatch(intensita);

/// L'obiettivo secondario: i soli numeri prendono l'unità dello sport ("85-90"
/// in bici è "85-90 rpm", nella corsa "170-180 ppm"); il resto resta com'è.
String normalizzaSecondario(String testo, String sport) {
  final t = testo.trim().replaceAll('–', '-').replaceAll(RegExp(r'\s+'), ' ');
  final n = RegExp(r'^(\d{2,3})( ?- ?(\d{2,3}))?$').firstMatch(t);
  if (n == null) return t;
  final unita = stessoSport(sport, 'Bici')
      ? ' rpm'
      : stessoSport(sport, 'Corsa')
      ? ' ppm'
      : '';
  return '${n[1]}${n[3] == null ? '' : '-${n[3]}'}$unita';
}

/// La cadenza chiesta dall'obiettivo secondario ("85-90 rpm", "90 rpm").
(int, int)? rangeCadenza(String obiettivo2) {
  final m = RegExp(
    r'(\d{2,3})(?: ?- ?(\d{2,3}))? ?rpm\b',
    caseSensitive: false,
  ).firstMatch(obiettivo2);
  if (m == null) return null;
  final da = int.parse(m[1]!);
  final a = m[2] == null ? da : int.parse(m[2]!);
  return da <= a ? (da, a) : (a, da);
}

/// Margine sulla cadenza prima di avvisare: i giri oscillano sempre un po'.
const margineCadenza = 2;

/// Fuori cadenza: 1 troppo agile, -1 troppo duro, 0 dentro (o ruota libera).
int versoCadenza(int rpm, (int, int) r) => rpm <= 0
    ? 0
    : rpm > r.$2 + margineCadenza
    ? 1
    : rpm < r.$1 - margineCadenza
    ? -1
    : 0;

String fraseCadenza(int rpm, (int, int) r, int verso) => verso > 0
    ? l10nVoce.cadenzaScendiA(rpm, r.$2)
    : l10nVoce.cadenzaSaliA(rpm, r.$1);

/// La cadenza per intervals.icu e Garmin: "85-90rpm". Vuoto se non c'è.
String obiettivo2Icu(String obiettivo2) {
  final r = rangeCadenza(obiettivo2);
  if (r == null) return '';
  return r.$1 == r.$2 ? '${r.$1}rpm' : '${r.$1}-${r.$2}rpm';
}

/// I watt da tenere in un passo di bici: watt scritti ("200-220 W"), % dell'FTP
/// ("88-94%", "75% FTP") o zona ("zona 4"). Un recupero senza obiettivo va
/// piano (45-55%). Null se il passo non dice niente.
(int, int)? rangeWatt(
  String intensita,
  ZonePotenza p, {
  bool recupero = false,
}) {
  if (rangeWattScritti(intensita) case final w?) return w;
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
/// La zona di battito (1-5) che corrisponde a una quota dell'FTP: serve
/// quando i watt non arrivano (all'aperto senza misuratore). È una stima: il
/// battito sale in ritardo e cambia con caldo e stanchezza.
int zonaBattitoDaQuota(double percento) => percento <= 55
    ? 1
    : percento <= 75
    ? 2
    : percento <= 90
    ? 3
    : percento <= 105
    ? 4
    : 5;

/// La zona di battito di un passo di bici: quella scritta ("zona 2"),
/// altrimenti quella che corrisponde alla % dell'FTP o ai watt (questi solo
/// se si conosce l'FTP). Null se il passo non dice l'intensità.
int? zonaBattitoDi(String intensita, ZonePotenza? p) {
  // Le zone di potenza 6 e 7 non hanno un battito loro: è il massimo.
  if (_zona.firstMatch(intensita) case final z?) {
    return int.parse(z[1]!).clamp(1, 5);
  }
  double? quota;
  if (rangeWattScritti(intensita) case (final da, final a)) {
    if (p == null || p.ftp <= 0) return null;
    quota = (da + a) / 2 / p.ftp * 100;
  } else if (_percentuale.firstMatch(intensita) case final q?) {
    quota = q[3] != null
        ? double.parse(q[3]!)
        : (int.parse(q[1]!) + int.parse(q[2]!)) / 2;
  }
  return quota == null ? null : zonaBattitoDaQuota(quota);
}

/// Con il battito al posto dei watt non si avvisa "spingi di più" prima di
/// questo tempo dall'inizio del passo: il cuore ci mette un po' a salire.
const ritardoBattito = Duration(seconds: 90);

String fmtRange((int, int) r) =>
    r.$1 == r.$2 ? '${r.$1} W' : '${r.$1}-${r.$2} W';

/// "zona 2" in un testo di bici diventa "zona 2 (150-200 W · 125-137 bpm)":
/// i watt per chi ha il rullo o il misuratore, il battito per chi no. Anche
/// le % dell'FTP e i watt scritti mostrano il battito che gli corrisponde.
String conWatt(String testo, ZonePotenza? p, Zone z) {
  String bpm(double quota) {
    final (da, a) = z.zona(zonaBattitoDaQuota(quota));
    return l10n.bpm2(da, a);
  }

  var t = testo;
  // "200-220 W": anche il battito (serve l'FTP per sapere quanto è duro).
  if (p != null && p.ftp > 0) {
    t = t.replaceAllMapped(
      RegExp('(?:${_wattScritti.pattern})(?! \\()', caseSensitive: false),
      (m) {
        // Dentro una parentesi è già una spiegazione ("zona 2 (150-200 W…").
        final prima = m.input.substring(0, m.start);
        if (prima.lastIndexOf('(') > prima.lastIndexOf(')')) return m[0]!;
        final (da, a) = rangeWattScritti(m[0]!)!;
        return '${m[0]} (${bpm((da + a) / 2 / p.ftp * 100)})';
      },
    );
  }
  t = p == null
      ? conBpm(t, z)
      : t.replaceAllMapped(
          RegExp(r'zona ([1-5])(?! \()', caseSensitive: false),
          (m) {
            final n = int.parse(m[1]!);
            final (da, a) = z.zona(n);
            return l10n.bpm3(m[0]!, p.testo(n), da, a);
          },
        );
  // "88-94%" dell'FTP: in watt (se c'è l'FTP) e in battito.
  return t.replaceAllMapped(
    RegExp(r'(\d{2,3})(?:\s*-\s*(\d{2,3}))?\s*%(?:\s*FTP)?(?! \()'),
    (m) {
      final da = int.parse(m[1]!);
      final a = int.parse(m[2] ?? m[1]!);
      final battito = bpm((da + a) / 2);
      if (p == null) return '${m[0]} ($battito)';
      int w(int x) => (p.ftp * x / 100).round();
      final watt = m[2] == null ? '${w(da)} W' : '${w(da)}-${w(a)} W';
      return '${m[0]} ($watt · $battito)';
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

/// La frase a voce per un range: "260 watt, scendi a 230." Si dice il
/// bordo più vicino della fascia: andare "sotto" o "sopra" la farebbe scavalcare.
String fraseRange(int watt, (int, int) r, int verso) => verso > 0
    ? l10nVoce.wattScendiA(watt, r.$2)
    : l10nVoce.wattSaliA(watt, r.$1);

/// La frase a voce: "260 watt, scendi a 230." Sopra si dice il tetto,
/// sotto il minimo della zona.
String frasePotenza(int watt, int obiettivo, int verso, ZonePotenza p) {
  final (da, a) = p.zona(obiettivo);
  return verso > 0
      ? l10nVoce.wattScendiA(watt, a ?? da)
      : l10nVoce.wattSaliA(watt, da);
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
  final out = {for (var n = 1; n <= p.numero; n++) n: Duration.zero};
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

/// Una prima stima dell'FTP di corsa, se non c'è di meglio: watt per chilo di
/// un runner amatoriale, che calano piano dopo i 35 anni. Serve a leggere i
/// grafici finché non si fa il test. Null senza il peso.
int? stimaFtpCorsa({double? pesoKg, int? eta, String sesso = ''}) {
  if (pesoKg == null || pesoKg < 30 || pesoKg > 200) return null;
  final base = switch (sesso) {
    'Uomo' => 3.7,
    'Donna' => 3.2,
    _ => 3.45,
  };
  final anni = (eta ?? 35) - 35;
  final calo = anni <= 0 ? 1.0 : math.max(0.6, 1 - anni * 0.007);
  return (pesoKg * base * calo).round();
}

/// La potenza media migliore su [durata]: un valore al secondo, tenendo
/// l'ultimo nei buchi brevi e contando zero nelle soste. Null se l'attività
/// è più corta.
int? migliorePotenza(List<Campione> serie, Duration durata) {
  final ordinata = [...serie]..sort((a, b) => a.t.compareTo(b.t));
  final finestra = durata.inSeconds;
  if (ordinata.length < 2 || finestra <= 0) return null;
  final inizio = ordinata.first.t;
  final secondi = ordinata.last.t.difference(inizio).inSeconds + 1;
  if (secondi < finestra) return null;
  final alSecondo = List<double>.filled(secondi, 0);
  for (var i = 0; i < ordinata.length; i++) {
    final da = ordinata[i].t.difference(inizio).inSeconds;
    final a = i + 1 < ordinata.length
        ? ordinata[i + 1].t.difference(inizio).inSeconds
        : secondi;
    final fine = math.min(a, da + 5);
    for (var s = da; s < fine && s < secondi; s++) {
      alSecondo[s] = ordinata[i].v;
    }
  }
  var somma = 0.0;
  var migliore = 0.0;
  for (var s = 0; s < secondi; s++) {
    somma += alSecondo[s];
    if (s >= finestra) somma -= alSecondo[s - finestra];
    if (s >= finestra - 1 && somma > migliore) migliore = somma;
  }
  return (migliore / finestra).round();
}

/// La soglia da una corsa: il 95% dei migliori 20 minuti. Null se non ci sono
/// 20 minuti di potenza.
int? sogliaDaVenti(List<Campione> serie) {
  final m = migliorePotenza(serie, const Duration(minutes: 20));
  return m == null || m <= 0 ? null : (m * 0.95).round();
}

/// Il test per l'FTP di corsa: riscaldamento, 20 minuti al massimo costante,
/// defaticamento. La potenza la misura l'orologio, non il telefono.
List<WorkoutStep> passiTestFtpCorsa(String id) {
  WorkoutStep passo(
    int ordine,
    String fase,
    String descrizione, {
    String serie = '',
    String ripetizioni = '',
    String minuti = '',
    String intensita = '',
    String recupero = '',
    String note = '',
  }) => WorkoutStep(
    id: id,
    sport: 'Corsa',
    nome: nomeTestFtpCorsa,
    durataTot: 50,
    ordine: ordine,
    fase: fase,
    descrizione: descrizione,
    serie: serie,
    ripetizioni: ripetizioni,
    distanzaM: '',
    durataMin: minuti,
    intensita: intensita,
    recuperoS: recupero,
    note: note,
  );
  return [
    passo(
      1,
      'riscaldamento',
      l10n.corsaFacile,
      minuti: '15',
      intensita: 'zona 2',
      note: l10n.registraQuestaCorsaAnche,
    ),
    passo(
      2,
      'riscaldamento',
      'Allunghi',
      serie: '3',
      ripetizioni: '20 s',
      recupero: '60',
      note: l10n.velociMaScioltiPoi,
    ),
    passo(
      3,
      'principale',
      l10n.test20MinutiAl,
      minuti: '20',
      note: l10n.ritmoPiuForteRiesci,
    ),
    passo(
      4,
      'defaticamento',
      l10n.corsaLentissima,
      minuti: '10',
      intensita: 'zona 1',
    ),
  ];
}

const nomeTestFtpCorsa = 'Test FTP di corsa';

/// L'FTP dal profilo dell'atleta di intervals.icu (sportSettings: quello che
/// comprende [tipo], "Ride" o "Run"). Null se non c'è.
int? ftpDaAtletaIcu(Object? atleta, {String tipo = 'Ride'}) {
  if (atleta is! Map) return null;
  final impostazioni = atleta['sportSettings'];
  if (impostazioni is! List) return null;
  for (final s in impostazioni) {
    if (s is! Map) continue;
    final tipi = s['types'];
    if (tipi is! List || !tipi.contains(tipo)) continue;
    final ftp = s['ftp'];
    if (ftp is num && ftp >= 50 && ftp <= 600) return ftp.round();
  }
  return null;
}

// ---------------------------------------------------------------------
// Serie registrate dall'app (battito, potenza, cadenza e velocità dai sensori)

const serieAppHeader = ['tempo_ms', 'fc', 'potenza', 'cadenza', 'velocita'];

/// File con le serie registrate dall'app per quel giorno e sport.
String fileSerieApp(DateTime giorno, String sport) =>
    'serie_app_${isoData(giorno).replaceAll('-', '_')}_'
    '${sport.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}.csv';

/// Le serie dell'app in CSV: una riga al secondo, vuoto dove manca il dato.
String serieAppCsv(SerieSessione s) {
  final righe = <int, List<String>>{};
  void metti(List<Campione> serie, int colonna, {int decimali = 0}) {
    for (final c in serie) {
      final r = righe.putIfAbsent(
        c.t.millisecondsSinceEpoch,
        () => ['${c.t.millisecondsSinceEpoch}', '', '', '', ''],
      );
      r[colonna] = c.v.toStringAsFixed(decimali);
    }
  }

  metti(s.fc, 1);
  metti(s.potenza, 2);
  metti(s.cadenza, 3);
  // In m/s: senza decimali 36 e 37 km/h sarebbero lo stesso numero.
  metti(s.velocita, 4, decimali: 2);
  final ordinate = righe.keys.toList()..sort();
  return toCsv([serieAppHeader, for (final k in ordinate) righe[k]!]);
}

SerieSessione serieAppDa(String testo) {
  final t = Tabella.da(testo);
  if (t == null) return const SerieSessione();
  final fc = <Campione>[], w = <Campione>[], cad = <Campione>[];
  final vel = <Campione>[];
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
    leggi('velocita', vel, 40);
  }
  return SerieSessione(fc: fc, potenza: w, cadenza: cad, velocita: vel);
}
