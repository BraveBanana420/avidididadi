import 'dart:convert';

import 'allenamento_agente.dart';
import 'arrampicata.dart';
import 'csv.dart';
import 'models.dart';

// Allenamenti di arrampicata costruiti a mano o dall'assistente, nello stile
// come nelle app dedicate: nome, categoria, tipo (vie, boulder, trave…), durata ed
// esercizi con serie, ripetizioni, lavoro e pausa, recupero tra le serie e
// intensità. Si tengono in una raccolta e si mettono nel calendario.

const fileAllenamentiArrampicata = 'allenamenti_arrampicata.csv';

const allenamentiArrampicataHeader = [
  'id',
  'nome',
  'categoria',
  'tipi',
  'durata_min',
  'descrizione',
  'da_segnare',
  'esercizi', // JSON: la lista degli esercizi
];

/// Dove si arrampica: chiave → nome da mostrare.
const tipiArrampicata = {
  'vie': 'Vie',
  'boulder': 'Boulder',
  'trave': 'Trave',
  'circuito': 'Circuito',
  'campus': 'Campus',
  'altro': 'Altro',
};

/// Categorie di allenamento più comuni (si può scriverne un'altra).
const categorieArrampicata = [
  'Capacità aerobica',
  'Potenza aerobica',
  'Resistenza anaerobica',
  'Forza delle dita',
  'Forza massima',
  'Potenza',
  'Tecnica',
  'Riscaldamento',
];

/// Un esercizio: [serie] × [ripetizioni]. Ogni ripetizione dura [lavoroS]
/// secondi (0 = finché non hai finito, es. una via) con [pausaS] secondi tra
/// una e l'altra; [recuperoS] secondi tra le serie.
class EsercizioArrampicata {
  final String nome;
  final int serie;
  final int ripetizioni;
  final int lavoroS;
  final int pausaS;
  final int recuperoS;
  final String
  intensita; // "40%", "6b+", "facile", "metà facile, metà al limite"
  final String note;
  const EsercizioArrampicata({
    required this.nome,
    this.serie = 1,
    this.ripetizioni = 1,
    this.lavoroS = 0,
    this.pausaS = 0,
    this.recuperoS = 0,
    this.intensita = '',
    this.note = '',
  });

  /// "3 × 4 · recupero 10 min", "6 × 7 s / 3 s · 40%".
  String get riassunto => [
    [
      if (serie > 1) '$serie serie',
      if (ripetizioni > 1)
        lavoroS > 0
            ? '$ripetizioni × ${_tempo(lavoroS)}'
                  '${pausaS > 0 ? ' / ${_tempo(pausaS)}' : ''}'
            : '$ripetizioni ripetizioni'
      else if (lavoroS > 0)
        _tempo(lavoroS),
    ].join(' · '),
    if (recuperoS > 0 && serie > 1) 'recupero ${_tempo(recuperoS)}',
    if (intensita.isNotEmpty) intensita,
  ].where((x) => x.isNotEmpty).join(' · ');

  /// Minuti stimati: i tempi scritti; una ripetizione senza tempo conta 3
  /// minuti (una via o un blocco con la discesa).
  double get minuti {
    final rip = lavoroS > 0 ? lavoroS : 180;
    final unaSerie = ripetizioni * rip + (ripetizioni - 1) * pausaS;
    return (serie * unaSerie + (serie - 1) * recuperoS) / 60;
  }

  Map<String, Object> toJson() => {
    'nome': nome,
    if (serie != 1) 'serie': serie,
    if (ripetizioni != 1) 'ripetizioni': ripetizioni,
    if (lavoroS > 0) 'lavoro_s': lavoroS,
    if (pausaS > 0) 'pausa_s': pausaS,
    if (recuperoS > 0) 'recupero_s': recuperoS,
    if (intensita.isNotEmpty) 'intensita': intensita,
    if (note.isNotEmpty) 'note': note,
  };

  /// Da JSON (assistente o file). Lancia [FormatException] se non va.
  static EsercizioArrampicata da(Map<dynamic, dynamic> m, String dove) {
    int n(String k, int base, int max) {
      final v = m[k];
      final x = v is num ? v.round() : int.tryParse('$v'.trim());
      if (v == null || '$v'.trim().isEmpty) return base;
      if (x == null || x < 0 || x > max) {
        throw FormatException('$dove: "$k" deve essere un numero da 0 a $max.');
      }
      return x;
    }

    final nome = _testo(m['nome'], 60);
    if (nome.isEmpty) throw FormatException('$dove: manca il nome.');
    return EsercizioArrampicata(
      nome: nome,
      serie: n('serie', 1, 20).clamp(1, 20),
      ripetizioni: n('ripetizioni', 1, 100).clamp(1, 100),
      lavoroS: n('lavoro_s', 0, 3600),
      pausaS: n('pausa_s', 0, 3600),
      recuperoS: n('recupero_s', 0, 3600),
      intensita: _testo(m['intensita'] ?? m['grado'], 60),
      note: _testo(m['note'], 300),
    );
  }
}

/// Un allenamento della raccolta.
class AllenamentoArrampicata {
  final String id;
  final String nome;
  final String categoria;
  final Set<String> tipi; // chiavi di [tipiArrampicata]
  final int durataMin; // 0 = stima dagli esercizi
  final String descrizione;
  final String daSegnare; // cosa segnare alla fine (es. il grado medio)
  final List<EsercizioArrampicata> esercizi;
  const AllenamentoArrampicata({
    required this.id,
    required this.nome,
    this.categoria = '',
    this.tipi = const {},
    this.durataMin = 0,
    this.descrizione = '',
    this.daSegnare = '',
    required this.esercizi,
  });

  /// I minuti scritti, altrimenti la stima dagli esercizi.
  int get minuti => durataMin > 0
      ? durataMin
      : esercizi.fold(0.0, (t, e) => t + e.minuti).round();

  AllenamentoArrampicata copyWith({
    String? nome,
    String? categoria,
    Set<String>? tipi,
    int? durataMin,
    String? descrizione,
    String? daSegnare,
    List<EsercizioArrampicata>? esercizi,
  }) => AllenamentoArrampicata(
    id: id,
    nome: nome ?? this.nome,
    categoria: categoria ?? this.categoria,
    tipi: tipi ?? this.tipi,
    durataMin: durataMin ?? this.durataMin,
    descrizione: descrizione ?? this.descrizione,
    daSegnare: daSegnare ?? this.daSegnare,
    esercizi: esercizi ?? this.esercizi,
  );

  List<String> toRow() => [
    id,
    nome,
    categoria,
    tipi.join(','),
    durataMin == 0 ? '' : '$durataMin',
    descrizione,
    daSegnare,
    jsonEncode([for (final e in esercizi) e.toJson()]),
  ];

  static AllenamentoArrampicata? daRiga(Tabella t, List<String> r) {
    final id = t.v(r, 'id');
    if (!RegExp(r'^[a-z0-9]+$').hasMatch(id)) return null;
    try {
      final lista = jsonDecode(t.v(r, 'esercizi'));
      if (lista is! List) return null;
      return AllenamentoArrampicata(
        id: id,
        nome: _testo(t.v(r, 'nome'), 60),
        categoria: _testo(t.v(r, 'categoria'), 40),
        tipi: _tipi(t.v(r, 'tipi').split(',')),
        durataMin: (int.tryParse(t.v(r, 'durata_min')) ?? 0).clamp(0, 600),
        descrizione: _testo(t.v(r, 'descrizione'), 2000),
        daSegnare: _testo(t.v(r, 'da_segnare'), 200),
        esercizi: [
          for (final (k, e) in lista.indexed)
            if (e is Map) EsercizioArrampicata.da(e, 'Esercizio ${k + 1}'),
        ],
      );
    } on FormatException {
      return null;
    }
  }

  /// Da JSON (assistente). Lancia [FormatException] con un messaggio
  /// semplice se qualcosa non va.
  static AllenamentoArrampicata da(
    Map<dynamic, dynamic> m, {
    required String id,
  }) {
    final nome = _testo(m['nome'], 60);
    if (nome.isEmpty) {
      throw const FormatException(
        'Un allenamento di arrampicata non ha il nome.',
      );
    }
    final lista = m['esercizi'] ?? m['passi'];
    if (lista is! List || lista.isEmpty || lista.length > 30) {
      throw FormatException('"$nome": servono da 1 a 30 esercizi.');
    }
    final durata = m['durata_min'];
    final d = durata is num ? durata.round() : int.tryParse('${durata ?? ''}');
    final tipi = m['tipi'] ?? m['tipo'];
    return AllenamentoArrampicata(
      id: id,
      nome: nome,
      categoria: _testo(m['categoria'], 40),
      tipi: _tipi(
        tipi is List ? tipi.map((x) => '$x') : '${tipi ?? ''}'.split(','),
      ),
      durataMin: d != null && d >= 5 && d <= 300 ? d : 0,
      descrizione: _testo(m['descrizione'], 2000),
      daSegnare: _testo(m['da_segnare'], 200),
      esercizi: [
        for (final (k, e) in lista.indexed)
          if (e is Map)
            EsercizioArrampicata.da(e, '"$nome", esercizio ${k + 1}'),
      ],
    );
  }

  /// I passi per il player e il calendario: per ogni serie le ripetizioni
  /// (a tempo o a "Fatto") con la pausa tra una e l'altra, poi il recupero
  /// tra le serie.
  List<WorkoutStep> passi(String idWorkout) {
    final out = <WorkoutStep>[];
    void passo(
      String descrizione, {
      int serie = 1,
      String ripetizioni = '',
      String durataMin = '',
      int recuperoS = 0,
      String intensita = '',
      String note = '',
      String fase = 'principale',
    }) => out.add(
      WorkoutStep(
        id: idWorkout,
        sport: sportArrampicata,
        nome: nome,
        durataTot: minuti,
        ordine: out.length + 1,
        fase: fase,
        descrizione: descrizione,
        serie: serie > 1 ? '$serie' : '',
        ripetizioni: ripetizioni,
        distanzaM: '',
        durataMin: durataMin,
        intensita: intensita,
        recuperoS: recuperoS > 0 ? '$recuperoS' : '',
        note: note,
      ),
    );

    for (final e in esercizi) {
      for (var s = 1; s <= e.serie; s++) {
        passo(
          e.serie > 1 ? '${e.nome} · serie $s di ${e.serie}' : e.nome,
          // Nel player le "serie" di un passo sono le ripetizioni.
          serie: e.ripetizioni,
          ripetizioni: e.lavoroS > 0 ? '${e.lavoroS} s' : '',
          recuperoS: e.ripetizioni > 1 ? e.pausaS : 0,
          intensita: e.intensita,
          note: e.note,
        );
        if (s < e.serie && e.recuperoS > 0) {
          passo(
            'Recupero tra le serie',
            durataMin: _minuti(e.recuperoS),
            note: 'Riposa: la serie dopo è "${e.nome}".',
          );
        }
      }
    }
    return out;
  }

  /// L'allenamento nel calendario di quel giorno, al posto della seduta di
  /// arrampicata.
  AllenamentoAgente perIlGiorno(DateTime data, {String fascia = ''}) =>
      AllenamentoAgente(
        data: soloData(data),
        sport: sportArrampicata,
        tipo: nome,
        nome: nome,
        fascia: fascia,
        passi: passi(idAllenamentoAgente(data, sportArrampicata)),
        durataIndicata: minuti > 0 ? minuti : null,
      );
}

String _testo(Object? v, int max) {
  final t = '${v ?? ''}'.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
  return t.length > max ? t.substring(0, max) : t;
}

Set<String> _tipi(Iterable<String> v) => {
  for (final x in v)
    if (tipiArrampicata.containsKey(x.trim().toLowerCase()))
      x.trim().toLowerCase(),
};

String _tempo(int s) => s >= 60 && s % 60 == 0
    ? '${s ~/ 60} min'
    : s >= 60
    ? '${s ~/ 60}:${two(s % 60)} min'
    : '$s s';

/// Secondi in minuti per la colonna "durata_min": "3", "1,5".
String _minuti(int s) => s % 60 == 0
    ? '${s ~/ 60}'
    : (s / 60).toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');

/// Id nuovo per un allenamento della raccolta.
String nuovoIdArrampicata(DateTime ora) =>
    ora.microsecondsSinceEpoch.toRadixString(36);

/// Un allenamento di arrampicata proposto dall'assistente: va nella
/// raccolta e, se ha la data, anche nel calendario quel giorno.
class PropostaArrampicata {
  final AllenamentoArrampicata allenamento;
  final DateTime? data;
  final String fascia;
  const PropostaArrampicata(this.allenamento, {this.data, this.fascia = ''});
}

/// Le proposte nel blocco "arrampicata" dell'assistente.
List<PropostaArrampicata> proposteArrampicata(
  List<dynamic> lista,
  DateTime ora,
) {
  final base = nuovoIdArrampicata(ora);
  final out = <PropostaArrampicata>[];
  for (final (k, x) in lista.indexed) {
    if (x is! Map) continue;
    final testoData = '${x['data'] ?? ''}'.trim();
    final data = testoData.isEmpty ? null : parseData(testoData);
    if (testoData.isNotEmpty && data == null) {
      throw FormatException('Data non valida: $testoData (serve AAAA-MM-GG).');
    }
    out.add(
      PropostaArrampicata(
        AllenamentoArrampicata.da(x, id: '$base$k'),
        data: data,
        fascia: _testo(x['fascia'], 20),
      ),
    );
  }
  if (out.isEmpty) {
    throw const FormatException(
      'Nel blocco non ci sono allenamenti di arrampicata.',
    );
  }
  return out;
}

/// Il formato per l'assistente (aggiunto alle istruzioni). [apri] e
/// [chiudi] sono i segni attorno al JSON.
String formatoArrampicata(String apri, String chiudi) =>
    '''Per gli allenamenti di ARRAMPICATA (anche presi da un'altra app o da una scheda) usa invece:
```
$apri
{"arrampicata": [
  {"nome": "50-50", "categoria": "Capacità aerobica", "tipi": ["vie", "boulder"], "durata_min": 45, "data": "AAAA-MM-GG", "fascia": "Sera",
   "descrizione": "Giri misti: metà via facile, metà al limite a vista.", "da_segnare": "grado medio tra le due parti",
   "esercizi": [
     {"nome": "Vie: metà facile, metà difficile", "serie": 3, "ripetizioni": 4, "recupero_s": 600, "intensita": "facile + a vista", "note": "30 movimenti: 15 facili, poi 15 al limite"}
   ]},
  {"nome": "7:3s 40%", "categoria": "Capacità aerobica", "tipi": ["trave"], "durata_min": 20,
   "esercizi": [
     {"nome": "Sospensioni (repeaters)", "serie": 5, "ripetizioni": 6, "lavoro_s": 7, "pausa_s": 3, "recupero_s": 120, "intensita": "40%"}
   ]}
]}
$chiudi
```
Negli esercizi: "serie" e "ripetizioni"; "lavoro_s" i secondi di ogni ripetizione (lascialo fuori se è una via o un blocco da salire fino in cima); "pausa_s" i secondi tra le ripetizioni; "recupero_s" i secondi tra le serie; "intensita" un grado (6b+, 6B), una % (40%) o a parole. "tipi" tra vie, boulder, trave, circuito, campus, altro. Con "data" l'allenamento va anche nel calendario quel giorno (al posto della seduta di arrampicata); senza data resta nella raccolta degli allenamenti, pronto da usare. Al massimo 30 esercizi. Scrivi descrizioni brevi con parole tue.''';
