import 'dart:math' as math;

import 'esercizi.dart';
import 'generatore_mobilita.dart';
import 'models.dart';
import 'l10n/lingua.dart';

/// Obiettivi del piano di forza, con una spiegazione breve per la scelta.
Map<String, (String, String)> get obiettivi => {
  'forza': ('Forza', l10n.pocheRipetizioniCarichiAlti),
  'ipertrofia': (l10n.massaMuscolare, l10n.ripetizioniMediePiuVolume),
  'resistenza': (l10n.resistenzaMuscolare, l10n.tanteRipetizioniRecuperiBrevi),
  'generale': (l10n.formaGenerale, l10n.equilibrioTraForzaMuscoli),
};

Map<String, (String, String)> get livelli => {
  'principiante': (l10n.principiante, l10n.tiAlleniPesiPoco),
  'intermedio': (l10n.intermedio, l10n.tiAlleniCostanzaAlmeno),
  'avanzato': (l10n.avanzato, l10n.tiAlleniAnniConosci),
};

/// Serie, ripetizioni, recupero e fatica per ogni obiettivo.
class _Parametri {
  final int serie;
  final (int, int) rip; // con sovraccarico
  final (int, int) ripCorpoLibero;
  final int secondi; // esercizi a tenuta (plank)
  final int recupero; // secondi tra le serie
  final int rpe;
  const _Parametri(
    this.serie,
    this.rip,
    this.ripCorpoLibero,
    this.secondi,
    this.recupero,
    this.rpe,
  );
}

const _parametri = {
  'forza': _Parametri(4, (5, 6), (6, 10), 30, 120, 8),
  'ipertrofia': _Parametri(3, (8, 12), (10, 15), 40, 75, 8),
  'resistenza': _Parametri(3, (15, 20), (15, 25), 50, 45, 7),
  'generale': _Parametri(3, (10, 12), (10, 15), 40, 60, 7),
};

/// Esercizi a tenuta: si misurano in secondi.
const _aTenuta = {'Plank', 'Side_Bridge'};

const _gambe = {'squat', 'affondo', 'cerniera', 'polpacci', 'pliometria'};

/// Sequenza di schemi di movimento per tipo di sessione, in ordine di priorità.
const _sessioni = {
  'Corpo intero A': [
    'squat',
    'cerniera',
    'spinta_orizzontale',
    'trazione_orizzontale',
    'core',
    'spalle',
    'braccia',
    'affondo',
    'polpacci',
  ],
  'Corpo intero B': [
    'affondo',
    'cerniera',
    'spinta_verticale',
    'trazione_verticale',
    'core',
    'braccia',
    'spalle',
    'squat',
    'polpacci',
  ],
  'Corpo intero C': [
    'squat',
    'cerniera',
    'spinta_orizzontale',
    'trazione_verticale',
    'core',
    'total_body',
    'spalle',
    'affondo',
    'braccia',
  ],
  'Parte alta': [
    'spinta_orizzontale',
    'trazione_orizzontale',
    'spinta_verticale',
    'trazione_verticale',
    'spalle',
    'braccia',
    'core',
  ],
  'Parte bassa': [
    'squat',
    'cerniera',
    'affondo',
    'polpacci',
    'core',
    'pliometria',
  ],
};

/// Se per uno schema non c'è nessun esercizio fattibile, si prova il suo simile.
const _alternative = {
  'trazione_verticale': 'trazione_orizzontale',
  'trazione_orizzontale': 'trazione_verticale',
  'spinta_verticale': 'spinta_orizzontale',
  'squat': 'affondo',
  'affondo': 'squat',
};

/// Corse impegnative: il giorno prima la forza tiene leggere le gambe.
const _corseImpegnative = {'lungo', 'fartlek', 'tempo run'};

const _riscaldamento = ['Arm_Circles', 'Hip_Circles_prone', 'Bodyweight_Squat'];

const _livelliAmmessi = {
  'principiante': {'principiante'},
  'intermedio': {'principiante', 'intermedio'},
  'avanzato': {'principiante', 'intermedio', 'avanzato'},
};

const _conPeso = [
  'manubri',
  'kettlebell',
  'dischi',
  'palla_medica',
  'bilanciere',
];

class PianoForza {
  final List<WorkoutStep> passi;
  final List<ProgrammaRiga> programma;
  const PianoForza(this.passi, this.programma);
}

DateTime _lunedi(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));

/// Prefisso degli id dei workout generati, per riconoscerli e sostituirli.
const prefissoForza = 'forza_';

/// Crea i workout di forza per le sessioni Forza del [piano] dal giorno [da] in poi.
/// I blocchi di 4 settimane si contano da [inizio].
PianoForza generaPianoForza({
  required List<PianoRiga> piano,
  required List<Esercizio> esercizi,
  required Attrezzatura attrezzatura,
  required String obiettivo,
  required String livello,
  required DateTime inizio,
  required DateTime da,
  int regolazione =
      0, // passi di carico decisi dai feedback (vedi feedback.dart)
}) {
  final par = _parametri[obiettivo] ?? _parametri['generale']!;
  final ammessi = _livelliAmmessi[livello] ?? _livelliAmmessi['intermedio']!;
  final perId = {for (final e in esercizi) e.id: e};
  bool usabile(Esercizio e) =>
      e.fattibile(attrezzatura) && ammessi.contains(e.livello);

  // Una sessione di forza per giorno (la prima, se ce n'è più di una).
  final giorni = <DateTime, PianoRiga>{};
  for (final r in piano) {
    if (stessoSport(r.sport, 'Forza') && !r.data.isBefore(da)) {
      giorni.putIfAbsent(r.data, () => r);
    }
  }
  final date = giorni.keys.toList()..sort();
  final corsePerData = <DateTime, String>{
    for (final r in piano)
      if (stessoSport(r.sport, 'Corsa')) r.data: r.tipo.toLowerCase(),
  };
  // Quante sessioni di forza ci sono in ogni settimana del piano (per scegliere lo schema).
  final contaSettimana = <DateTime, List<DateTime>>{};
  for (final d in {
    for (final r in piano)
      if (stessoSport(r.sport, 'Forza')) r.data,
  }.toList()..sort()) {
    (contaSettimana[_lunedi(d)] ??= []).add(d);
  }

  final passi = <WorkoutStep>[];
  final programma = <ProgrammaRiga>[];
  for (final data in date) {
    final riga = giorni[data]!;
    final durata = riga.durataMin > 0 ? riga.durataMin : 45;
    final settimana = contaSettimana[_lunedi(data)]!;
    final k = settimana.indexOf(data);
    final nomeSessione = settimana.length >= 4
        ? (k.isEven ? 'Parte alta' : 'Parte bassa')
        : ['Corpo intero A', 'Corpo intero B', 'Corpo intero C'][k % 3];
    final settimane = _lunedi(data).difference(_lunedi(inizio)).inDays ~/ 7;
    final int blocco = math.max(0, settimane) ~/ 4;
    final int sb = math.max(0, settimane) % 4; // 0-2 progressione, 3 scarico
    final domani = corsePerData[DateTime(data.year, data.month, data.day + 1)];
    final gambeLeggere = domani != null && _corseImpegnative.contains(domani);

    final id = '$prefissoForza${isoData(data)}';
    final nome = l10n.settimana4(nomeSessione, sb + 1);
    var ordine = 0;
    WorkoutStep passo(
      String fase,
      Esercizio e, {
      String serie = '',
      String rip = '',
      String intensita = '',
      String recupero = '',
      String note = '',
    }) => WorkoutStep(
      id: id,
      sport: 'Forza',
      nome: nome,
      durataTot: durata,
      ordine: ++ordine,
      fase: fase,
      descrizione: e.nome,
      serie: serie,
      ripetizioni: rip,
      distanzaM: '',
      durataMin: '',
      intensita: intensita,
      recuperoS: recupero,
      note: note,
      esercizio: e.id,
    );

    // Riscaldamento: 5 minuti di movimenti leggeri.
    final riscaldamento = <Esercizio>[];
    for (final rid in _riscaldamento) {
      final e = perId[rid];
      if (e == null) continue;
      riscaldamento.add(e);
      passi.add(
        passo(
          'riscaldamento',
          e,
          rip: e.tipo == 'mobilita' ? l10n.n10Lato : l10n.n10Lenti,
        ),
      );
    }

    // Parte principale: esercizi in ordine di priorità finché c'è tempo.
    final minMobilita = (durata * 0.2).round().clamp(6, 12).toInt();
    final budget = (durata - 5 - minMobilita) * 60;
    var usato = 0;
    final scelti = <Esercizio>[];
    final schemi = [
      for (final s in _sessioni[nomeSessione]!)
        if (!(gambeLeggere && s == 'pliometria')) s,
      if (!gambeLeggere &&
          (obiettivo == 'resistenza' || obiettivo == 'generale') &&
          !_sessioni[nomeSessione]!.contains('pliometria'))
        'pliometria',
    ];
    for (final schema in schemi) {
      final e = _scegli(
        esercizi,
        schema,
        usabile,
        [...riscaldamento, ...scelti],
        obiettivo,
        blocco + _sessioni.keys.toList().indexOf(nomeSessione),
      );
      if (e == null) continue;
      var serie =
          par.serie +
          (livello == 'principiante'
              ? -1
              : livello == 'avanzato'
              ? 1
              : 0);
      if (sb == 3) serie--; // settimana di scarico
      if (gambeLeggere && _gambe.contains(schema)) serie--;
      serie = math.max(2, serie);
      final tenuta = _aTenuta.contains(e.id);
      // I feedback spostano il peso se ce n'è più d'uno, altrimenti ripetizioni e secondi.
      final pesiEs = _pesiDisponibili(e, attrezzatura);
      final suPeso = pesiEs.length > 1;
      final int secondi = math.max(
        15,
        par.secondi + 10 * (sb < 2 ? sb : 2) + 5 * regolazione,
      );
      // Su un lato solo la serie si fa due volte: destra e sinistra.
      final int lavoro = (tenuta ? secondi : 45) * (e.lati ? 2 : 1);
      final int tempo = serie * (lavoro + par.recupero) + 60;
      if (scelti.length >= 3 && usato + tempo > budget + 120) break;
      usato += tempo;
      scelti.add(e);

      final extra = sb == 3 ? 0 : sb; // +1 ripetizione a settimana nel blocco
      final (lo, hi) = e.corpoLibero ? par.ripCorpoLibero : par.rip;
      final daFeedback = suPeso ? 0 : 2 * regolazione;
      final minimo = math.max(3, lo + extra + daFeedback);
      final massimo = math.max(minimo + 2, hi + extra + daFeedback);
      final rip = switch ((tenuta, e.lati)) {
        (true, true) => l10n.secondiPerLato(secondi),
        (true, false) => '$secondi s',
        (false, true) => l10n.ripetizioniPerLato('$minimo-$massimo'),
        (false, false) => '$minimo-$massimo',
      };
      final peso = _pesoSuggerito(
        e,
        attrezzatura,
        livello,
        suPeso ? regolazione : 0,
      );
      final note = [
        if (peso.isNotEmpty) peso,
        if (sb == 3) l10n.settimanaScaricoSerieMeno,
        if (sb == 1) l10n.settimana2RipetizionePiu,
        if (sb == 2) l10n.settimana3DueRipetizioni,
        if (gambeLeggere && _gambe.contains(schema))
          l10n.gambeLeggereDomaniHai(_nomeCorsa(domani)),
      ].join(' ');
      passi.add(
        passo(
          'principale',
          e,
          serie: '$serie',
          rip: rip,
          intensita: l10n.n10Fatica(par.rpe),
          recupero: '${par.recupero}',
          note: note,
        ),
      );
    }

    // Mobilità finale sui muscoli allenati (e su anche e polpacci, per la corsa).
    final allenati = {
      for (final e in scelti) ...{...e.muscoli, ...e.muscoliSecondari},
    };
    for (final e in _mobilita(
      esercizi,
      attrezzatura,
      allenati,
      blocco + k,
      math.max(3, minMobilita ~/ 2),
    )) {
      passi.add(passo('mobilità', e, rip: durataMobilita(e)));
    }

    programma.add(ProgrammaRiga(data: data, sport: 'Forza', idWorkout: id));
  }
  return PianoForza(passi, programma);
}

String _nomeCorsa(String? tipo) => switch (tipo) {
  'lungo' => l10n.lungo,
  'fartlek' => l10n.fartlek,
  _ => l10n.tempoRun,
};

/// Sceglie un esercizio per lo schema, ruotando tra le opzioni a ogni blocco.
Esercizio? _scegli(
  List<Esercizio> esercizi,
  String schema,
  bool Function(Esercizio) usabile,
  List<Esercizio> giaScelti,
  String obiettivo,
  int rotazione,
) {
  for (final s in [
    schema,
    if (_alternative[schema] != null) _alternative[schema]!,
  ]) {
    final opzioni = esercizi
        .where(
          (e) =>
              e.tipo == 'forza' &&
              e.schema == s &&
              usabile(e) &&
              !giaScelti.contains(e),
        )
        .toList();
    if (opzioni.isEmpty) continue;
    // Se c'è l'attrezzatura si preferisce il sovraccarico, tranne per la resistenza.
    if (obiettivo != 'resistenza') {
      final caricati = opzioni.where((e) => !e.corpoLibero).toList();
      if (caricati.isNotEmpty) return caricati[rotazione % caricati.length];
    }
    return opzioni[rotazione % opzioni.length];
  }
  return null;
}

/// Esercizi di mobilità più utili per i muscoli allenati, a rotazione.
List<Esercizio> _mobilita(
  List<Esercizio> esercizi,
  Attrezzatura a,
  Set<String> allenati,
  int rotazione,
  int quanti,
) {
  final opzioni = esercizi
      .where((e) => e.tipo == 'mobilita' && e.fattibile(a))
      .toList();
  if (opzioni.isEmpty) return [];
  final n = opzioni.length;
  int punteggio(Esercizio e) {
    final m = {...e.muscoli, ...e.muscoliSecondari};
    // Anche, femorali e polpacci contano di più: servono alla corsa.
    final corsa = m.intersection({
      'quadriceps',
      'hamstring',
      'calves',
      'gluteal',
    }).length;
    return 2 * m.intersection(allenati).length + corsa;
  }

  final ordinati = [for (var i = 0; i < n; i++) opzioni[(i + rotazione) % n]]
    ..sort((x, y) => punteggio(y).compareTo(punteggio(x)));
  return ordinati.take(quanti).toList();
}

/// Frase con il peso di partenza indicativo tra quelli disponibili;
/// poi i feedback lo correggeranno.
/// Fatica prevista (da 1 a 10) per l'obiettivo, con cui si confrontano i feedback.
int faticaObiettivo(String obiettivo) =>
    (_parametri[obiettivo] ?? _parametri['generale']!).rpe;

/// Pesi disponibili per l'esercizio (vuoto se è a corpo libero o col bilanciere).
List<double> _pesiDisponibili(Esercizio e, Attrezzatura a) {
  final chiave = _attrezzoConPeso(e, a);
  return chiave.isEmpty || chiave == 'bilanciere'
      ? const []
      : a[chiave] ?? const [];
}

String _attrezzoConPeso(Esercizio e, Attrezzatura a) {
  if (e.corpoLibero) return '';
  final gruppo = e.attrezzi.firstWhere(
    (g) => g.every(a.containsKey),
    orElse: () => const [],
  );
  return _conPeso.firstWhere(gruppo.contains, orElse: () => '');
}

String _pesoSuggerito(Esercizio e, Attrezzatura a, String livello, int passi) {
  if (e.corpoLibero) return '';
  final gruppo = e.attrezzi.firstWhere(
    (g) => g.every(a.containsKey),
    orElse: () => const [],
  );
  final chiave = _conPeso.firstWhere(gruppo.contains, orElse: () => '');
  if (chiave.isEmpty) return '';
  if (chiave == 'bilanciere') {
    return l10n.partiSolaBarraAggiungi;
  }
  final pesi = a[chiave] ?? const [];
  if (pesi.isEmpty) return '';
  if (pesi.length == 1) {
    return l10n.pesoKg(
      attrezzoDa(chiave)!.nome.toLowerCase(),
      fmtNum(pesi.first),
    );
  }
  final quota =
      switch (livello) {
        'principiante' => 0.2,
        'avanzato' => 0.7,
        _ => 0.45,
      } +
      (_gambe.contains(e.schema) ? 0.2 : 0);
  final base = ((pesi.length - 1) * math.min(quota, 1.0)).round();
  final p = pesi[(base + passi).clamp(0, pesi.length - 1)];
  return l10n.pesoCircaKg(fmtNum(p));
}
