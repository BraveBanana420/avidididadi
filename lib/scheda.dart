import 'csv.dart';
import 'esercizi.dart';
import 'generatore_forza.dart';
import 'models.dart';
import 'registro_forza.dart';

// Scheda di forza scritta a mano, per esempio quella del personal trainer:
// uno o più giorni (Busto, Gambe…) legati ai giorni della settimana, con
// esercizi, serie, ripetizioni, recupero e kg. Finché è attiva prende il posto
// della forza generata dall'app, che non cambia nulla da sola.

/// Un esercizio della scheda.
class EsercizioScheda {
  final String esercizio; // id nel catalogo; vuoto se scritto a mano
  final String nome;
  final int serie;
  final String ripetizioni; // "10", "8-10", "30 s"
  final int recuperoS;
  final List<double> kg; // uno per tutte le serie, oppure uno per serie
  final String note;
  const EsercizioScheda({
    this.esercizio = '',
    required this.nome,
    this.serie = 3,
    this.ripetizioni = '10',
    this.recuperoS = 90,
    this.kg = const [],
    this.note = '',
  });

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
  }) => EsercizioScheda(
    esercizio: esercizio ?? this.esercizio,
    nome: nome ?? this.nome,
    serie: serie ?? this.serie,
    ripetizioni: ripetizioni ?? this.ripetizioni,
    recuperoS: recuperoS ?? this.recuperoS,
    kg: kg ?? this.kg,
    note: note ?? this.note,
  );

  /// "3 × 10 · 90 s · 20 kg" oppure "3 × 10 · 20, 22,5, 25 kg".
  String get riassunto => [
    '$serie × $ripetizioni',
    if (recuperoS > 0) '$recuperoS s',
    if (kg.isNotEmpty) '${kg.map(fmtKg).join(', ')} kg',
  ].join(' · ');
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
class SchedaForza {
  final String id;
  final String nome;
  final DateTime inizio;
  final DateTime? fine;
  final bool archiviata;
  final List<GiornoScheda> giorni;
  const SchedaForza({
    required this.id,
    required this.nome,
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

  SchedaForza copyWith({
    String? nome,
    DateTime? inizio,
    DateTime? Function()? fine,
    bool? archiviata,
    List<GiornoScheda>? giorni,
  }) => SchedaForza(
    id: id,
    nome: nome ?? this.nome,
    inizio: inizio ?? this.inizio,
    fine: fine == null ? this.fine : fine(),
    archiviata: archiviata ?? this.archiviata,
    giorni: giorni ?? this.giorni,
  );

  /// Stessa scheda per altri [giorni] giorni dal giorno dopo la fine.
  SchedaForza rinnovata(int giorniValidita) {
    final da = fine == null
        ? soloData(DateTime.now())
        : fine!.add(const Duration(days: 1));
    return copyWith(
      inizio: da,
      fine: () => da.add(Duration(days: giorniValidita - 1)),
    );
  }
}

/// La scheda che vale in [d] (l'ultima iniziata, se più d'una).
SchedaForza? schedaDel(List<SchedaForza> schede, DateTime d) {
  SchedaForza? s;
  for (final x in schede) {
    if (x.valida(d) && (s == null || x.inizio.isAfter(s.inizio))) s = x;
  }
  return s;
}

// ---------------------------------------------------------------------------
// CSV: una riga per scheda e una per esercizio.

const schedeHeader = ['id', 'nome', 'inizio', 'fine', 'archiviata'];
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
];

String _kgTesto(List<double> kg) => kg.map(fmtKg).join(';');
List<double> _kgDa(String t) => [
  for (final x in t.split(';'))
    if (double.tryParse(x.trim().replaceAll(',', '.')) case final v?)
      if (v >= 0) v,
];

List<List<String>> righeSchede(List<SchedaForza> schede) => [
  for (final s in schede)
    [
      s.id,
      s.nome,
      isoData(s.inizio),
      s.fine == null ? '' : isoData(s.fine!),
      s.archiviata ? 'si' : '',
    ],
];

List<List<String>> righeEserciziSchede(List<SchedaForza> schede) => [
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
        ],
];

List<SchedaForza> schedeDa(Tabella? schede, Tabella? esercizi) {
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
          serie: (int.tryParse(esercizi.v(r, 'serie')) ?? 3).clamp(1, 20),
          ripetizioni: esercizi.v(r, 'ripetizioni').isEmpty
              ? '10'
              : esercizi.v(r, 'ripetizioni'),
          recuperoS: int.tryParse(esercizi.v(r, 'recupero_s')) ?? 90,
          kg: _kgDa(esercizi.v(r, 'kg')),
          note: esercizi.v(r, 'note'),
        ),
      ));
    }
  }
  return [
    for (final r in schede.righe)
      if (parseData(schede.v(r, 'inizio')) case final inizio?)
        SchedaForza(
          id: schede.v(r, 'id'),
          nome: schede.v(r, 'nome'),
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

/// I passi del workout di un giorno della scheda, con lo stesso id dei
/// workout di forza generati: così valgono le stesse regole (un feedback
/// blocca la seduta, da oggi in poi si riscrive).
List<WorkoutStep> passiScheda(GiornoScheda g, DateTime d, int durataMin) {
  final id = '$prefissoForza${isoData(d)}';
  return [
    for (final (i, e) in g.esercizi.indexed)
      WorkoutStep(
        id: id,
        sport: 'Forza',
        nome: g.nome,
        durataTot: durataMin,
        ordine: i + 1,
        fase: 'principale',
        descrizione: e.nome,
        serie: '${e.serie}',
        ripetizioni: e.ripetizioni,
        distanzaM: '',
        durataMin: '',
        intensita: '',
        recuperoS: e.recuperoS > 0 ? '${e.recuperoS}' : '',
        note: e.note,
        esercizio: e.esercizio,
        kg: _kgTesto(e.kg),
      ),
  ];
}

/// Il piano di forza con la scheda al posto delle sedute generate, nei giorni
/// di forza della settimana tipo che la scheda copre.
PianoForza conScheda(
  PianoForza generato,
  List<PianoRiga> piano,
  List<SchedaForza> schede,
) {
  final passi = [...generato.passi];
  final programma = [...generato.programma];
  for (final r in piano) {
    if (!stessoSport(r.sport, 'Forza')) continue;
    final s = schedaDel(schede, r.data);
    final g = s?.giornoPer(r.data);
    if (g == null) continue;
    final id = '$prefissoForza${isoData(r.data)}';
    passi
      ..removeWhere((w) => w.id == id)
      ..addAll(passiScheda(g, r.data, r.durataMin));
    programma
      ..removeWhere((p) => p.data == r.data && stessoSport(p.sport, 'Forza'))
      ..add(ProgrammaRiga(data: r.data, sport: 'Forza', idWorkout: id));
  }
  programma.sort((a, b) => a.data.compareTo(b.data));
  return PianoForza(passi, programma);
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
SchedaForza conPesi(SchedaForza s, Map<String, List<double>> kg) => s.copyWith(
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
