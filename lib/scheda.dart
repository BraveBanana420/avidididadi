import 'csv.dart';
import 'esercizi.dart';
import 'generatore_endurance.dart';
import 'generatore_forza.dart';
import 'models.dart';
import 'registro_forza.dart';

// Scheda scritta a mano, per esempio quella del personal trainer o
// dell'allenatore: uno o più giorni (Busto, Gambe, Ripetute…) legati ai giorni
// della settimana. Per la forza esercizi con serie, ripetizioni, recupero e kg;
// per corsa, bici e nuoto passi a tempo o a distanza, con zona o passo.
// Finché è attiva prende il posto delle sedute preparate dall'app per quello
// sport, che non cambia nulla da sola.

/// Un esercizio (forza) o un passo (corsa, bici, nuoto) della scheda.
class EsercizioScheda {
  final String esercizio; // id nel catalogo; vuoto se scritto a mano
  final String nome;
  final int serie; // forza: serie; resistenza: quante volte si ripete
  final String ripetizioni; // "10", "8-10", "30 s"
  final int recuperoS;
  final List<double> kg; // uno per tutte le serie, oppure uno per serie
  final String note;
  // Corsa, bici e nuoto
  final String fase; // riscaldamento, principale, defaticamento
  final String durataMin; // "10", "1,5"
  final String distanzaM; // "400"
  final String intensita; // "zona 2", "passo 5:00/km", "passo 1:50/100 m"
  const EsercizioScheda({
    this.esercizio = '',
    required this.nome,
    this.serie = 3,
    this.ripetizioni = '10',
    this.recuperoS = 90,
    this.kg = const [],
    this.note = '',
    this.fase = 'principale',
    this.durataMin = '',
    this.distanzaM = '',
    this.intensita = '',
  });

  /// Un passo a tempo o a distanza (corsa, bici, nuoto).
  bool get diResistenza => durataMin.isNotEmpty || distanzaM.isNotEmpty;

  /// I kg della serie [n] (da 1): l'ultimo valore vale per le serie dopo.
  double? kgSerie(int n) =>
      kg.isEmpty ? null : kg[(n - 1).clamp(0, kg.length - 1)];

  EsercizioScheda copyWith({
    String? esercizio,
    String? nome,
    int? serie,
    String? ripetizioni,
    int? recuperoS,
    List<double>? kg,
    String? note,
    String? fase,
    String? durataMin,
    String? distanzaM,
    String? intensita,
  }) => EsercizioScheda(
    esercizio: esercizio ?? this.esercizio,
    nome: nome ?? this.nome,
    serie: serie ?? this.serie,
    ripetizioni: ripetizioni ?? this.ripetizioni,
    recuperoS: recuperoS ?? this.recuperoS,
    kg: kg ?? this.kg,
    note: note ?? this.note,
    fase: fase ?? this.fase,
    durataMin: durataMin ?? this.durataMin,
    distanzaM: distanzaM ?? this.distanzaM,
    intensita: intensita ?? this.intensita,
  );

  /// Forza: "3 × 10 · 90 s · 20 kg" oppure "3 × 10 · 20, 22,5, 25 kg".
  /// Resistenza: "6 × 400 m · zona 4 · recupero 90 s".
  String get riassunto {
    if (diResistenza) {
      final quanto = distanzaM.isNotEmpty
          ? '$distanzaM m'
          : '${durataMin.replaceAll('.', ',')} min';
      return [
        serie > 1 ? '$serie × $quanto' : quanto,
        if (intensita.isNotEmpty) intensita,
        if (recuperoS > 0) 'recupero $recuperoS s',
      ].join(' · ');
    }
    return [
      '$serie × $ripetizioni',
      if (recuperoS > 0) '$recuperoS s',
      if (kg.isNotEmpty) '${kg.map(fmtKg).join(', ')} kg',
    ].join(' · ');
  }
}

/// Un giorno della scheda (Busto, Gambe…) e i giorni della settimana in cui
/// si fa (1 = lunedì).
class GiornoScheda {
  final String nome;
  final Set<int> giorni;
  final List<EsercizioScheda> esercizi;
  const GiornoScheda({
    required this.nome,
    this.giorni = const {},
    this.esercizi = const [],
  });

  GiornoScheda copyWith({
    String? nome,
    Set<int>? giorni,
    List<EsercizioScheda>? esercizi,
  }) => GiornoScheda(
    nome: nome ?? this.nome,
    giorni: giorni ?? this.giorni,
    esercizi: esercizi ?? this.esercizi,
  );
}

/// La scheda: valida da [inizio] a [fine] compresa (null: finché non cambia).
class Scheda {
  final String id;
  final String nome;
  final String sport; // Forza, Corsa, Bici o Nuoto
  final DateTime inizio;
  final DateTime? fine;
  final bool archiviata;
  final List<GiornoScheda> giorni;
  const Scheda({
    required this.id,
    required this.nome,
    this.sport = 'Forza',
    required this.inizio,
    this.fine,
    this.archiviata = false,
    this.giorni = const [],
  });

  bool valida(DateTime d) {
    final g = soloData(d);
    return !archiviata &&
        !g.isBefore(inizio) &&
        (fine == null || !g.isAfter(fine!));
  }

  /// Il giorno della scheda da fare in [d], se c'è.
  GiornoScheda? giornoPer(DateTime d) {
    if (!valida(d)) return null;
    for (final g in giorni) {
      if (g.giorni.contains(d.weekday) && g.esercizi.isNotEmpty) return g;
    }
    return null;
  }

  /// Finita ma non ancora rinnovata né archiviata: da chiedere cosa fare.
  bool finita(DateTime oggi) =>
      !archiviata && fine != null && soloData(oggi).isAfter(fine!);

  /// Giorni di validità (null se non scade).
  int? get durataGiorni =>
      fine == null ? null : fine!.difference(inizio).inDays + 1;

  Scheda copyWith({
    String? nome,
    DateTime? inizio,
    DateTime? Function()? fine,
    bool? archiviata,
    List<GiornoScheda>? giorni,
  }) => Scheda(
    id: id,
    nome: nome ?? this.nome,
    sport: sport,
    inizio: inizio ?? this.inizio,
    fine: fine == null ? this.fine : fine(),
    archiviata: archiviata ?? this.archiviata,
    giorni: giorni ?? this.giorni,
  );

  /// Stessa scheda per altri [giorni] giorni dal giorno dopo la fine.
  Scheda rinnovata(int giorniValidita) {
    final da = fine == null
        ? soloData(DateTime.now())
        : fine!.add(const Duration(days: 1));
    return copyWith(
      inizio: da,
      fine: () => da.add(Duration(days: giorniValidita - 1)),
    );
  }
}

/// La scheda di [sport] che vale in [d] (l'ultima iniziata, se più d'una).
Scheda? schedaDel(List<Scheda> schede, DateTime d, [String sport = 'Forza']) {
  Scheda? s;
  for (final x in schede) {
    if (stessoSport(x.sport, sport) &&
        x.valida(d) &&
        (s == null || x.inizio.isAfter(s.inizio))) {
      s = x;
    }
  }
  return s;
}

// ---------------------------------------------------------------------------
// CSV: una riga per scheda e una per esercizio.

const schedeHeader = ['id', 'nome', 'inizio', 'fine', 'archiviata', 'sport'];
const schedeEserciziHeader = [
  'scheda',
  'giorno',
  'giorni_settimana',
  'ordine',
  'esercizio',
  'nome',
  'serie',
  'ripetizioni',
  'recupero_s',
  'kg',
  'note',
  // Colonne per corsa, bici e nuoto.
  'fase',
  'durata_min',
  'distanza_m',
  'intensita',
];

String _kgTesto(List<double> kg) => kg.map(fmtKg).join(';');
List<double> _kgDa(String t) => [
  for (final x in t.split(';'))
    if (double.tryParse(x.trim().replaceAll(',', '.')) case final v?)
      if (v >= 0) v,
];

List<List<String>> righeSchede(List<Scheda> schede) => [
  for (final s in schede)
    [
      s.id,
      s.nome,
      isoData(s.inizio),
      s.fine == null ? '' : isoData(s.fine!),
      s.archiviata ? 'si' : '',
      s.sport,
    ],
];

List<List<String>> righeEserciziSchede(List<Scheda> schede) => [
  for (final s in schede)
    for (final g in s.giorni)
      // Un giorno senza esercizi resta con una riga vuota, per non perderlo.
      for (final (i, e)
          in (g.esercizi.isEmpty
                  ? [const EsercizioScheda(nome: '')]
                  : g.esercizi)
              .indexed)
        [
          s.id,
          g.nome,
          (g.giorni.toList()..sort()).join(';'),
          '${i + 1}',
          e.esercizio,
          e.nome,
          e.nome.isEmpty ? '' : '${e.serie}',
          e.nome.isEmpty ? '' : e.ripetizioni,
          e.nome.isEmpty ? '' : '${e.recuperoS}',
          _kgTesto(e.kg),
          e.note,
          e.nome.isEmpty ? '' : e.fase,
          e.durataMin,
          e.distanzaM,
          e.intensita,
        ],
];

List<Scheda> schedeDa(Tabella? schede, Tabella? esercizi) {
  if (schede == null) return [];
  // scheda -> giorno -> (giorni della settimana, esercizi in ordine)
  final giorni =
      <String, Map<String, (Set<int>, List<(int, EsercizioScheda)>)>>{};
  if (esercizi != null) {
    for (final r in esercizi.righe) {
      final id = esercizi.v(r, 'scheda');
      final nomeGiorno = esercizi.v(r, 'giorno');
      if (id.isEmpty || nomeGiorno.isEmpty) continue;
      final g = (giorni[id] ??= {})[nomeGiorno] ??= (
        {
          for (final x in esercizi.v(r, 'giorni_settimana').split(';'))
            if (int.tryParse(x) case final n? when n >= 1 && n <= 7) n,
        },
        [],
      );
      final nome = esercizi.v(r, 'nome');
      if (nome.isEmpty) continue;
      g.$2.add((
        int.tryParse(esercizi.v(r, 'ordine')) ?? 0,
        EsercizioScheda(
          esercizio: esercizi.v(r, 'esercizio'),
          nome: nome,
          serie: (int.tryParse(esercizi.v(r, 'serie')) ?? 3).clamp(1, 50),
          ripetizioni: esercizi.v(r, 'ripetizioni').isEmpty
              ? '10'
              : esercizi.v(r, 'ripetizioni'),
          recuperoS: int.tryParse(esercizi.v(r, 'recupero_s')) ?? 90,
          kg: _kgDa(esercizi.v(r, 'kg')),
          note: esercizi.v(r, 'note'),
          fase: esercizi.v(r, 'fase').isEmpty
              ? 'principale'
              : esercizi.v(r, 'fase'),
          durataMin: esercizi.v(r, 'durata_min'),
          distanzaM: esercizi.v(r, 'distanza_m'),
          intensita: esercizi.v(r, 'intensita'),
        ),
      ));
    }
  }
  return [
    for (final r in schede.righe)
      if (parseData(schede.v(r, 'inizio')) case final inizio?)
        Scheda(
          id: schede.v(r, 'id'),
          nome: schede.v(r, 'nome'),
          sport: schede.v(r, 'sport').isEmpty
              ? 'Forza'
              : normSport(schede.v(r, 'sport')),
          inizio: inizio,
          fine: parseData(schede.v(r, 'fine')),
          archiviata: schede.v(r, 'archiviata') == 'si',
          giorni: [
            for (final MapEntry(key: nome, value: (sett, es))
                in (giorni[schede.v(r, 'id')] ?? const {}).entries)
              GiornoScheda(
                nome: nome,
                giorni: sett,
                esercizi: [
                  for (final (_, e) in es..sort((a, b) => a.$1.compareTo(b.$1)))
                    e,
                ],
              ),
          ],
        ),
  ];
}

// ---------------------------------------------------------------------------
// Dalla scheda al piano

/// Id del workout di un giorno: lo stesso dei workout generati, così valgono
/// le stesse regole (una seduta fatta non si tocca, da oggi in poi si
/// riscrive).
String idSeduta(String sport, DateTime d) => stessoSport(sport, 'Forza')
    ? '$prefissoForza${isoData(d)}'
    : '${prefissoEndurance(normSport(sport))}${isoData(d)}';

/// I passi del workout di un giorno della scheda.
List<WorkoutStep> passiScheda(
  GiornoScheda g,
  DateTime d,
  int durataMin, {
  String sport = 'Forza',
}) {
  final id = idSeduta(sport, d);
  final forza = stessoSport(sport, 'Forza');
  return [
    for (final (i, e) in g.esercizi.indexed)
      WorkoutStep(
        id: id,
        sport: normSport(sport),
        nome: g.nome,
        durataTot: durataMin,
        ordine: i + 1,
        fase: forza ? 'principale' : e.fase,
        descrizione: e.nome,
        serie: forza || e.serie > 1 ? '${e.serie}' : '',
        ripetizioni: forza ? e.ripetizioni : '',
        distanzaM: forza ? '' : e.distanzaM,
        durataMin: forza ? '' : e.durataMin,
        intensita: forza ? '' : e.intensita,
        recuperoS: e.recuperoS > 0 ? '${e.recuperoS}' : '',
        note: e.note,
        esercizio: forza ? e.esercizio : '',
        kg: forza ? _kgTesto(e.kg) : '',
      ),
  ];
}

/// Passi e programma con le schede di [sport] al posto delle sedute
/// preparate dall'app, nei giorni della settimana tipo che coprono. Restituisce
/// anche il nome del giorno della scheda, da mostrare nel calendario.
({
  List<WorkoutStep> passi,
  List<ProgrammaRiga> programma,
  Map<DateTime, String> tipi,
})
applicaSchede(
  List<WorkoutStep> generati,
  List<ProgrammaRiga> programmati,
  List<PianoRiga> piano,
  List<Scheda> schede,
  String sport,
) {
  final passi = [...generati];
  final programma = [...programmati];
  final tipi = <DateTime, String>{};
  for (final r in piano) {
    if (!stessoSport(r.sport, sport)) continue;
    final g = schedaDel(schede, r.data, sport)?.giornoPer(r.data);
    if (g == null) continue;
    final id = idSeduta(sport, r.data);
    passi
      ..removeWhere((w) => w.id == id)
      ..addAll(passiScheda(g, r.data, r.durataMin, sport: sport));
    programma
      ..removeWhere((p) => p.data == r.data && stessoSport(p.sport, sport))
      ..add(
        ProgrammaRiga(data: r.data, sport: normSport(sport), idWorkout: id),
      );
    tipi[r.data] = g.nome;
  }
  programma.sort((a, b) => a.data.compareTo(b.data));
  return (passi: passi, programma: programma, tipi: tipi);
}

/// Il piano di forza con la scheda al posto delle sedute generate, nei giorni
/// di forza della settimana tipo che la scheda copre.
PianoForza conScheda(
  PianoForza generato,
  List<PianoRiga> piano,
  List<Scheda> schede,
) {
  final r = applicaSchede(
    generato.passi,
    generato.programma,
    piano,
    schede,
    'Forza',
  );
  return PianoForza(r.passi, r.programma);
}

/// I kg segnati che non corrispondono alla scheda: (esercizio, prima, dopo).
/// Si guarda la serie più pesante fatta.
List<(String, List<double>, List<double>)> pesiCambiati(
  GiornoScheda g,
  List<SerieFatta> fatte,
) {
  final out = <(String, List<double>, List<double>)>[];
  for (final e in g.esercizi) {
    final sue = fatte.where((s) => s.nome == e.nome && s.kg > 0).toList()
      ..sort((a, b) => a.serie.compareTo(b.serie));
    if (sue.isEmpty) continue;
    final nuovi = [for (final s in sue) s.kg];
    // Se tutte le serie hanno lo stesso peso, basta un valore.
    final compatti = nuovi.toSet().length == 1 ? [nuovi.first] : nuovi;
    final prima = e.kg.toSet().length == 1 ? [e.kg.first] : e.kg;
    if (prima.length == compatti.length &&
        [for (var i = 0; i < prima.length; i++) prima[i] == compatti[i]]
            .every((x) => x)) {
      continue;
    }
    out.add((e.nome, e.kg, compatti));
  }
  return out;
}

/// La scheda con i kg nuovi per gli esercizi indicati (per nome).
Scheda conPesi(Scheda s, Map<String, List<double>> kg) => s.copyWith(
  giorni: [
    for (final g in s.giorni)
      g.copyWith(
        esercizi: [
          for (final e in g.esercizi)
            kg[e.nome] == null ? e : e.copyWith(kg: kg[e.nome]),
        ],
      ),
  ],
);

/// Gli esercizi del catalogo fattibili con l'attrezzatura, cercati per nome.
List<Esercizio> cercaEsercizi(
  List<Esercizio> catalogo,
  Attrezzatura attrezzatura,
  String testo, {
  bool tutti = false,
}) {
  final t = testo.trim().toLowerCase();
  return [
    for (final e in catalogo)
      if (e.tipo == 'forza' &&
          (tutti || e.fattibile(attrezzatura)) &&
          (t.isEmpty ||
              e.nome.toLowerCase().contains(t) ||
              e.nomeEn.toLowerCase().contains(t)))
        e,
  ]..sort((a, b) => a.nome.compareTo(b.nome));
}

// ---------------------------------------------------------------------------
// Settimana tipo

/// La settimana tipo con [sport] anche nel giorno [giorno] (1 = lunedì).
/// Con [sostituisci] toglie quello che c'era in quel giorno, e lo restituisce
/// in [tolti] per dirlo prima di confermare. Durata e fascia vengono da un
/// altro giorno dello stesso sport, o da quello che si toglie.
({List<Slot> settimana, List<Slot> tolti, Slot aggiunto}) conSportNelGiorno(
  List<Slot> settimana,
  int giorno,
  String sport, {
  bool sostituisci = true,
}) {
  final nelGiorno = settimana.where((x) => x.giorno == giorno).toList();
  final simile = settimana
      .where((x) => stessoSport(x.sport, sport) && x.giorno != giorno)
      .firstOrNull;
  final aggiunto = Slot(
    giorno: giorno,
    fascia: nelGiorno.firstOrNull?.fascia ?? simile?.fascia ?? 'Mattina',
    sport: normSport(sport),
    durataMin: simile?.durataMin ?? nelGiorno.firstOrNull?.durataMin ?? 45,
  );
  final tolti = sostituisci ? nelGiorno : <Slot>[];
  return (
    settimana: [
      for (final x in settimana)
        if (!tolti.contains(x)) x,
      aggiunto,
    ]..sort((a, b) => a.giorno.compareTo(b.giorno)),
    tolti: tolti,
    aggiunto: aggiunto,
  );
}
