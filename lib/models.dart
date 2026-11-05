import 'csv.dart';

const giorniSettimana = [
  'Lunedì',
  'Martedì',
  'Mercoledì',
  'Giovedì',
  'Venerdì',
  'Sabato',
  'Domenica',
];
const mesiNomi = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];
const fasce = ['Mattina', 'Pranzo', 'Pomeriggio', 'Sera'];
const sportList = ['Forza', 'Corsa', 'Nuoto', 'Bici', 'Mobilità', 'Riposo'];

const settimanaHeader = [
  'giorno',
  'fascia',
  'sport',
  'tipo_sessione',
  'durata_min',
  'note',
];
const pianoHeader = [
  'data',
  'fascia',
  'sport',
  'tipo_sessione',
  'target_durata_min',
  'target_distanza_km',
  'intensita',
  'note',
];
const sessioniHeader = [
  'id_sessione',
  'data',
  'sport',
  'tipo_sessione',
  'durata_min',
  'distanza_km',
  'fc_media',
  'rpe',
  'fonte',
  'note',
  // Colonne facoltative, riempite dalle sessioni lette da Health Connect.
  'inizio',
  'fine',
  'fc_max',
  'calorie_attive',
  'calorie_totali',
  'passi',
  'origine',
  // Bici: dai sensori collegati all'app o da intervals.icu.
  'potenza_media',
  'cadenza_media',
];
const workoutHeader = [
  'id_workout',
  'sport',
  'nome_workout',
  'durata_totale_min',
  'ordine',
  'fase',
  'descrizione',
  'serie',
  'ripetizioni',
  'distanza_m',
  'durata_min',
  'intensita',
  'recupero_s',
  'note',
  'id_esercizio',
  'kg', // aggiunta: pesi per serie dalla scheda del personal trainer
  'obiettivo_2', // aggiunta: obiettivo secondario, es. "85-90 rpm"
];
const programmaHeader = ['data', 'sport', 'id_workout'];

/// Modello da compilare per importare le sessioni a mano: le colonne base di
/// sessioni.csv e tre righe di esempio. id_sessione si può lasciare vuoto.
String modelloCsvSessioni() => toCsv([
  sessioniHeader.sublist(0, 10),
  [
    '',
    '2026-10-15',
    'Corsa',
    'Fartlek',
    '44',
    '6.71',
    '140',
    '7',
    'Manuale',
    '6 x 2 minuti veloci',
  ],
  [
    '',
    '2026-10-16',
    'Forza',
    'Corpo intero',
    '40',
    '',
    '120',
    '8',
    'Manuale',
    '',
  ],
  [
    '',
    '2026-10-17',
    'Nuoto',
    'Piscina',
    '45',
    '1.15',
    '',
    '6',
    'Manuale',
    'Distanza in km',
  ],
]);

String two(int n) => n.toString().padLeft(2, '0');
String isoData(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';
String dataLunga(DateTime d) =>
    '${giorniSettimana[d.weekday - 1]} ${d.day} ${mesiNomi[d.month - 1]}';
DateTime soloData(DateTime d) => DateTime(d.year, d.month, d.day);
String titoloSessione(String sport, String tipo) =>
    tipo.isEmpty ? sport : '$sport: $tipo';
bool stessoSport(String a, String b) =>
    a.trim().toLowerCase() == b.trim().toLowerCase();
String maiuscola(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Maiuscola iniziale; Freeletics è stato rinominato Forza.
String normSport(String s) {
  final t = s.trim();
  if (t.isEmpty) return t;
  final n = t[0].toUpperCase() + t.substring(1).toLowerCase();
  return switch (n) {
    'Freeletics' => 'Forza',
    'Mobilita' || 'Stretching' || 'Yoga' || 'Pilates' => 'Mobilità',
    _ => n,
  };
}

DateTime? _crea(int y, int m, int d) {
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  return DateTime(y, m, d);
}

/// Accetta 2026-09-30 oppure 30/09/2026.
DateTime? parseData(String s) {
  final t = s.trim();
  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(t);
  if (iso != null) {
    return _crea(int.parse(iso[1]!), int.parse(iso[2]!), int.parse(iso[3]!));
  }
  final ita = RegExp(r'^(\d{1,2})[/.](\d{1,2})[/.](\d{4})').firstMatch(t);
  if (ita != null) {
    return _crea(int.parse(ita[3]!), int.parse(ita[2]!), int.parse(ita[1]!));
  }
  return null;
}

/// Numero da un testo ("5,2" o "5.2"); 0 se non è un numero vero. Anche
/// "NaN" e "Infinity" valgono 0: arrotondarli bloccherebbe l'app.
double numero(String s) {
  final v = double.tryParse(s.trim().replaceAll(',', '.')) ?? 0;
  return v.isFinite ? v : 0;
}

String fmtNum(double v) {
  if (v == 0) return '';
  if (v == v.roundToDouble()) return v.round().toString();
  return v
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Una riga della settimana tipo (giorno 1 = lunedì ... 7 = domenica).
class Slot {
  int giorno;
  String fascia;
  String sport;
  String tipo;
  int durataMin;
  String note;

  Slot({
    required this.giorno,
    required this.fascia,
    required this.sport,
    this.tipo = '',
    this.durataMin = 45,
    this.note = '',
  });

  List<String> toRow() => [
    giorno.toString(),
    fascia,
    sport,
    tipo,
    '$durataMin',
    note,
  ];

  factory Slot.fromRow(List<String> r) {
    String g(int i) => i < r.length ? r[i] : '';
    return Slot(
      giorno: int.tryParse(g(0)) ?? 1,
      fascia: g(1),
      sport: normSport(g(2)),
      tipo: g(3),
      durataMin: int.tryParse(g(4)) ?? 0,
      note: g(5),
    );
  }
}

/// Una sessione del piano generato.
class PianoRiga {
  final DateTime data;
  final String fascia;
  final String sport;
  final String tipo;
  final int durataMin;
  final String distanzaKm;
  final String intensita;
  final String note;

  const PianoRiga({
    required this.data,
    required this.fascia,
    required this.sport,
    this.tipo = '',
    this.durataMin = 0,
    this.distanzaKm = '',
    this.intensita = '',
    this.note = '',
  });

  List<String> toRow() => [
    isoData(data),
    fascia,
    sport,
    tipo,
    '$durataMin',
    distanzaKm,
    intensita,
    note,
  ];

  factory PianoRiga.fromRow(List<String> r) {
    String g(int i) => i < r.length ? r[i] : '';
    return PianoRiga(
      data: soloData(DateTime.parse(g(0))),
      fascia: g(1),
      sport: normSport(g(2)),
      tipo: g(3),
      durataMin: int.tryParse(g(4)) ?? 0,
      distanzaKm: g(5),
      intensita: g(6),
      note: g(7),
    );
  }
}

/// Una sessione svolta (storico).
class Sessione {
  final String id;
  final DateTime data;
  final String sport;
  final String tipo;
  final int durataMin;
  final double distanzaKm;
  final int fcMedia;
  final double rpe;
  final String fonte;
  final String note;
  // Dati in più delle sessioni di Health Connect (vuoti per lo storico CSV).
  final DateTime? inizio;
  final DateTime? fine;
  final int fcMax;
  final double calorieAttive;
  final double calorieTotali;
  final int passi;
  final String origine; // pacchetto dell'app che ha scritto la sessione
  final int potenzaMedia; // watt
  final int cadenzaMedia; // pedalate al minuto
  /// Pezzi da cui è stata ricomposta (es. i blocchi di Freeletics o due
  /// registrazioni dopo un crash). Non si salva: si ricalcola a ogni avvio.
  final List<Sessione> parti;

  const Sessione({
    required this.id,
    required this.data,
    required this.sport,
    this.tipo = '',
    this.durataMin = 0,
    this.distanzaKm = 0,
    this.fcMedia = 0,
    this.rpe = 0,
    this.fonte = '',
    this.note = '',
    this.inizio,
    this.fine,
    this.fcMax = 0,
    this.calorieAttive = 0,
    this.calorieTotali = 0,
    this.passi = 0,
    this.origine = '',
    this.potenzaMedia = 0,
    this.cadenzaMedia = 0,
    this.parti = const [],
  });

  Sessione copyWith({
    String? tipo,
    double? distanzaKm,
    int? fcMedia,
    int? fcMax,
    double? calorieAttive,
    double? calorieTotali,
    int? passi,
    String? fonte,
    String? note,
    String? origine,
  }) => Sessione(
    id: id,
    data: data,
    sport: sport,
    tipo: tipo ?? this.tipo,
    durataMin: durataMin,
    distanzaKm: distanzaKm ?? this.distanzaKm,
    fcMedia: fcMedia ?? this.fcMedia,
    rpe: rpe,
    fonte: fonte ?? this.fonte,
    note: note ?? this.note,
    inizio: inizio,
    fine: fine,
    fcMax: fcMax ?? this.fcMax,
    calorieAttive: calorieAttive ?? this.calorieAttive,
    calorieTotali: calorieTotali ?? this.calorieTotali,
    passi: passi ?? this.passi,
    origine: origine ?? this.origine,
    potenzaMedia: potenzaMedia,
    cadenzaMedia: cadenzaMedia,
    parti: parti,
  );

  List<String> toRow() => [
    id,
    isoData(data),
    sport,
    tipo,
    durataMin == 0 ? '' : '$durataMin',
    fmtNum(distanzaKm),
    fcMedia == 0 ? '' : '$fcMedia',
    fmtNum(rpe),
    fonte,
    note,
    inizio?.toIso8601String() ?? '',
    fine?.toIso8601String() ?? '',
    fcMax == 0 ? '' : '$fcMax',
    fmtNum(calorieAttive),
    fmtNum(calorieTotali),
    passi == 0 ? '' : '$passi',
    origine,
    potenzaMedia == 0 ? '' : '$potenzaMedia',
    cadenzaMedia == 0 ? '' : '$cadenzaMedia',
  ];

  /// Da una riga di CSV (anche importata a mano o da un backup): i numeri
  /// fuori misura si riportano nei limiti di un allenamento vero e i testi
  /// lunghissimi si accorciano, così un file sbagliato non rovina grafici e
  /// carico né gonfia i dati.
  static Sessione? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    final sport = normSport(t.v(r, 'sport'));
    if (d == null || sport.isEmpty) return null;
    double tra(String col, double max) =>
        numero(t.v(r, col)).clamp(0, max).toDouble();
    String corto(String col, int max) {
      final v = t.v(r, col);
      return v.length > max ? v.substring(0, max) : v;
    }

    final durata = tra('durata_min', 2880).round(); // fino a 48 ore
    var id = corto('id_sessione', 100);
    if (id.isEmpty) id = '${isoData(d)}-${sport.toLowerCase()}-$durata';
    return Sessione(
      id: id,
      data: d,
      sport: sport,
      tipo: corto('tipo_sessione', 100),
      durataMin: durata,
      distanzaKm: tra('distanza_km', 1000),
      fcMedia: tra('fc_media', 250).round(),
      rpe: tra('rpe', 10),
      fonte: corto('fonte', 100),
      note: corto('note', 2000),
      inizio: DateTime.tryParse(t.v(r, 'inizio')),
      fine: DateTime.tryParse(t.v(r, 'fine')),
      fcMax: tra('fc_max', 250).round(),
      calorieAttive: tra('calorie_attive', 20000),
      calorieTotali: tra('calorie_totali', 20000),
      passi: tra('passi', 300000).round(),
      origine: corto('origine', 200),
      potenzaMedia: tra('potenza_media', 3000).round(),
      cadenzaMedia: tra('cadenza_media', 250).round(),
    );
  }
}

/// Un passaggio di un workout (riscaldamento, serie principale, ...).
class WorkoutStep {
  final String id;
  final String sport;
  final String nome;
  final int durataTot;
  final int ordine;
  final String fase;
  final String descrizione;
  final String serie;
  final String ripetizioni;
  final String distanzaM;
  final String durataMin;
  final String intensita;
  final String recuperoS;
  final String note;
  final String esercizio; // id nel catalogo esercizi, se c'è
  final String kg; // pesi per serie, es. "20;22,5;25" (vuoto se non detti)
  final String obiettivo2; // obiettivo secondario, es. "85-90 rpm"

  const WorkoutStep({
    required this.id,
    required this.sport,
    required this.nome,
    required this.durataTot,
    required this.ordine,
    required this.fase,
    required this.descrizione,
    required this.serie,
    required this.ripetizioni,
    required this.distanzaM,
    required this.durataMin,
    required this.intensita,
    required this.recuperoS,
    required this.note,
    this.esercizio = '',
    this.kg = '',
    this.obiettivo2 = '',
  });

  List<String> toRow() => [
    id,
    sport,
    nome,
    durataTot == 0 ? '' : '$durataTot',
    '$ordine',
    fase,
    descrizione,
    serie,
    ripetizioni,
    distanzaM,
    durataMin,
    intensita,
    recuperoS,
    note,
    esercizio,
    kg,
    obiettivo2,
  ];

  static WorkoutStep? da(Tabella t, List<String> r) {
    final id = t.v(r, 'id_workout');
    if (id.isEmpty) return null;
    return WorkoutStep(
      id: id,
      sport: normSport(t.v(r, 'sport')),
      nome: t.v(r, 'nome_workout'),
      durataTot: numero(t.v(r, 'durata_totale_min')).round(),
      ordine: numero(t.v(r, 'ordine')).round(),
      fase: t.v(r, 'fase'),
      descrizione: t.v(r, 'descrizione'),
      serie: t.v(r, 'serie'),
      ripetizioni: t.v(r, 'ripetizioni'),
      distanzaM: t.v(r, 'distanza_m'),
      durataMin: t.v(r, 'durata_min'),
      intensita: t.v(r, 'intensita'),
      recuperoS: t.v(r, 'recupero_s'),
      note: t.v(r, 'note'),
      esercizio: t.v(r, 'id_esercizio'),
      kg: t.v(r, 'kg'),
      obiettivo2: t.v(r, 'obiettivo_2'),
    );
  }

  String get riepilogo {
    final p = <String>[];
    final qta = distanzaM.isNotEmpty
        ? '$distanzaM m'
        : ripetizioni.isNotEmpty
        // "8-10" diventa "8-10 rip"; "30 s" o "10 per lato" restano così.
        ? (RegExp(r'[a-zA-Z]').hasMatch(ripetizioni)
              ? ripetizioni
              : '$ripetizioni rip')
        : '';
    if (serie.isNotEmpty && qta.isNotEmpty) {
      p.add('$serie x $qta');
    } else if (serie.isNotEmpty) {
      p.add('$serie serie');
    } else if (qta.isNotEmpty) {
      p.add(qta);
    }
    if (durataMin.isNotEmpty) p.add('$durataMin min');
    if (intensita.isNotEmpty) p.add('intensità $intensita');
    if (obiettivo2.isNotEmpty) p.add('poi $obiettivo2');
    if (recuperoS.isNotEmpty) p.add('recupero $recuperoS s');
    return p.join(', ');
  }
}

/// Quale workout fare in un dato giorno per un dato sport.
class ProgrammaRiga {
  final DateTime data;
  final String sport;
  final String idWorkout;

  const ProgrammaRiga({
    required this.data,
    required this.sport,
    required this.idWorkout,
  });

  String get chiave => '${isoData(data)}|${sport.toLowerCase()}';
  List<String> toRow() => [isoData(data), sport, idWorkout];

  static ProgrammaRiga? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    final id = t.v(r, 'id_workout');
    final sport = normSport(t.v(r, 'sport'));
    if (d == null || id.isEmpty || sport.isEmpty) return null;
    return ProgrammaRiga(data: d, sport: sport, idWorkout: id);
  }
}

/// Ritmo di una sessione: km/h per la bici, min/100 m per il nuoto, min/km altrimenti.
/// Passi al minuto della corsa (cadenza media), dai passi della sessione.
/// Null se mancano i passi o il valore non è credibile.
int? cadenza(Sessione s) {
  if (!siCammina(s.sport)) return null;
  final minuti = s.inizio != null && s.fine != null
      ? s.fine!.difference(s.inizio!).inSeconds / 60
      : s.durataMin.toDouble();
  final double v;
  if (s.passi > 0 && minuti > 0) {
    v = s.passi / minuti;
  } else if (s.cadenzaMedia > 0) {
    // Solo la cadenza dell'orologio (intervals.icu), senza i passi totali.
    final m = s.cadenzaMedia.toDouble();
    v = cadenzaDiUnPiede(m, s.sport) ? m * 2 : m;
  } else {
    return null;
  }
  final c = v.round();
  return c >= 60 && c <= 240 ? c : null;
}

/// Corsa e camminata si misurano in passi al minuto, non in giri.
bool siCammina(String sport) =>
    stessoSport(sport, 'Corsa') || stessoSport(sport, 'Camminata');

/// Garmin e altri orologi salvano la cadenza contando un piede solo (85 invece
/// di 170): nessuno corre sotto i 120 passi al minuto, né cammina sotto i 75.
bool cadenzaDiUnPiede(double v, String sport) =>
    v > 0 && v < (stessoSport(sport, 'Corsa') ? 120 : 75);

double? ritmo(Sessione s) {
  if (s.distanzaKm <= 0 || s.durataMin <= 0) return null;
  final sp = s.sport.toLowerCase();
  if (sp == 'bici') return s.distanzaKm / (s.durataMin / 60);
  if (sp == 'nuoto') return s.durataMin / (s.distanzaKm * 10);
  return s.durataMin / s.distanzaKm;
}

String unitaRitmo(String sport) {
  final sp = sport.toLowerCase();
  if (sp == 'bici') return 'km/h';
  if (sp == 'nuoto') return 'min/100 m';
  return 'min/km';
}

String fmtRitmo(String sport, double v) {
  if (sport.toLowerCase() == 'bici') return v.toStringAsFixed(1);
  var m = v.floor();
  var s = ((v - m) * 60).round();
  if (s == 60) {
    m += 1;
    s = 0;
  }
  return '$m:${two(s)}';
}

const ritocchiHeader = ['id_sessione', 'nome', 'al_chiuso'];

/// Quello che l'orologio non manda e l'utente scrive a mano su una sessione:
/// il nome (es. "Test FTP") e se era al chiuso (rulli, Tacx, tapis roulant).
class RitoccoSessione {
  final String id;
  final String nome;
  final bool alChiuso;
  const RitoccoSessione(this.id, {this.nome = '', this.alChiuso = false});

  List<String> toRow() => [id, nome, alChiuso ? 'si' : ''];

  static RitoccoSessione? da(Tabella t, List<String> r) {
    final id = t.v(r, 'id_sessione');
    if (id.isEmpty) return null;
    return RitoccoSessione(
      id,
      nome: t.v(r, 'nome'),
      alChiuso: t.v(r, 'al_chiuso') == 'si',
    );
  }
}
