import 'dart:math' as math;

import 'adattamento.dart';
import 'assistente.dart';
import 'carico.dart';
import 'models.dart';
import 'obiettivo.dart';

/// Piani di corsa, nuoto e bici sulle sessioni della settimana tipo, verso la
/// gara obiettivo (se c'è), con blocchi di 4 settimane e zone personali.

const sportEndurance = ['Corsa', 'Nuoto', 'Bici'];

/// Prefisso degli id dei workout generati per uno sport (es. "corsa_2026-10-23").
String prefissoEndurance(String sport) => '${sport.toLowerCase()}_';

bool idEndurance(String id) =>
    sportEndurance.any((s) => id.startsWith(prefissoEndurance(s)));

/// Tetto del lungo di corsa (minuti) in base alla gara.
const _tettoLungo = {
  '5k': 70,
  '10k': 90,
  'mezza': 120,
  'maratona': 180,
  'sprint': 75,
  'olimpico': 90,
  '703': 120,
  'ironman': 180,
};

class PianoEndurance {
  final List<WorkoutStep> passi;
  final List<ProgrammaRiga> programma;

  /// Tipo di seduta deciso per (giorno, sport), da mostrare nel calendario.
  final Map<(DateTime, String), String> tipi;
  const PianoEndurance(this.passi, this.programma, this.tipi);
}

/// Una seduta da generare: giorno, sport, ruolo nella settimana e durata.
class _Seduta {
  final DateTime data;
  final String sport;
  final String ruolo; // lento, qualita, lungo (corsa); tecnica, soglia (nuoto); z2, intervalli, lungo (bici)
  final int durata;
  final String tipo; // scelto dall'assistente, se la seduta è fissa
  final bool fissa; // tipo e durata decisi dall'assistente: non si toccano
  const _Seduta(
    this.data,
    this.sport,
    this.ruolo,
    this.durata, {
    this.tipo = '',
    this.fissa = false,
  });
}

const _tipiQualita = {
  'Fartlek',
  'Tempo run',
  'Ripetute',
  'Ritmo gara',
  'Allunghi',
};

/// Come cresce il carico quando i feedback dicono che è facile (o cala quando
/// è duro): sedute più lunghe, più intense a parità di tempo, o prima
/// l'intensità e poi la durata.
const progressioneAuto = 'auto';

const modiProgressione = {
  'durata': ('Durata', 'Sedute più lunghe del 5% per ogni passo.'),
  'intensita': (
    'Intensità',
    'Stessa durata, più sforzo: recuperi più brevi, più minuti veloci, '
        'passo un po\' più svelto.',
  ),
  progressioneAuto: (
    'Auto',
    'Prima l\'intensità (fino a 2 passi), poi la durata.',
  ),
};

/// Divide i passi di regolazione [r] in (passi di durata, passi di intensità).
(int, int) dividiProgressione(int r, String modo) => switch (modo) {
  'durata' => (r, 0),
  'intensita' => (0, r),
  _ => (r - r.clamp(-2, 2).toInt(), r.clamp(-2, 2).toInt()),
};

/// Gli sport con sedute future decise dall'assistente che l'app non prepara
/// ancora: senza passi quelle sedute non potrebbero partire.
Set<String> sportDaAttivare(
  List<PianoRiga> piano,
  Set<String> attivi,
  DateTime oggi,
) => {
  for (final r in piano)
    if (!r.data.isBefore(oggi) &&
        rigaDaAssistente(r) &&
        sportEndurance.contains(normSport(r.sport)) &&
        !attivi.contains(normSport(r.sport)))
      normSport(r.sport),
};

/// Ruolo di una seduta dal suo tipo (per quelle decise dall'assistente).
String _ruoloDi(String sport, String tipo) {
  final t = tipo.toLowerCase();
  if (tipoLungo(t)) return 'lungo';
  return switch (sport) {
    'Corsa' =>
      t.isEmpty || t.contains('lento') || t.contains('recupero')
          ? 'lento'
          : 'qualita',
    'Nuoto' => t.contains('soglia') ? 'soglia' : 'tecnica',
    _ => t.contains('intervalli') ? 'intervalli' : 'z2',
  };
}

PianoEndurance generaPianoEndurance({
  required List<PianoRiga> piano,
  required List<Sessione> storico,
  required Set<String> sport,
  required DateTime inizio,
  required DateTime da,
  Obiettivo? obiettivo,
  int?
  passoCritico, // passo di riferimento in piscina (s/100 m), dai dati reali
  Map<String, int> regolazione = const {}, // per sport, dai feedback (vecchio)
  // Esiti dei feedback per sport: se ci sono, la progressione viene da qui.
  Map<String, List<(DateTime, EsitoSeduta)>> esiti = const {},
  Map<String, String> progressione =
      const {}, // per sport: durata, intensità, auto
  bool principiante = false, // si parte da zero: prima solo corse facili
}) {
  final passi = <WorkoutStep>[];
  final programma = <ProgrammaRiga>[];
  final tipi = <(DateTime, String), String>{};

  for (final sp in sport) {
    // Una seduta per giorno e sport, raggruppate per settimana.
    final perSettimana = <DateTime, List<PianoRiga>>{};
    final visti = <DateTime>{};
    for (final r in piano.toList()..sort((a, b) => a.data.compareTo(b.data))) {
      if (!stessoSport(r.sport, sp) ||
          r.data.isBefore(da) ||
          !visti.add(r.data)) {
        continue;
      }
      (perSettimana[lunediDi(r.data)] ??= []).add(r);
    }
    // Il riferimento è preso all'inizio del blocco in corso, così rigenerando
    // il piano durante il blocco le durate non salgono da sole.
    final lunInizio = lunediDi(inizio);
    final bloccoDa = math.max(
      0,
      lunediDi(da).difference(lunInizio).inDays ~/ 28,
    );
    final inizioBlocco = lunInizio.add(Duration(days: 28 * bloccoDa));
    final base = _base(storico, sp, inizioBlocco);
    // Il lungo però segue quello fatto davvero: se nelle ultime 4 settimane
    // la seduta più lunga ha superato il riferimento del blocco, si riparte
    // da lì (anche oltre il tetto della gara, perché l'hai già fatto).
    final lungoFatto = _base(storico, sp, da).lungoMin;
    // Con dei feedback la progressione viene solo dall'adattamento (contano
    // quelli del blocco in corso: la base riparte dai dati recenti).
    final esitiSp = esiti[sp] ?? const [];
    final ad = esitiSp.isEmpty
        ? null
        : adatta([
            for (final e in esitiSp)
              if (!e.$1.isBefore(inizioBlocco)) e,
          ], modo: progressione[sp] ?? progressioneAuto);
    // Volume delle due settimane prima, per il tetto del +10%.
    var prima1 = _volumeFatto(storico, sp, lunediDi(da));
    var prima2 = _volumeFatto(
      storico,
      sp,
      lunediDi(da).subtract(const Duration(days: 7)),
    );
    for (final e in perSettimana.entries) {
      final settimane = math.max(0, e.key.difference(lunInizio).inDays ~/ 7);
      final sb = settimane % 4; // 0-2 progressione, 3 scarico
      final fase = faseDel(obiettivo, e.key);
      final (passiDurata, passiIntensita) = dividiProgressione(
        regolazione[sp] ?? 0,
        progressione[sp] ?? progressioneAuto,
      );
      var fattore = _fattore(sb, fase, passiDurata);
      // Nelle settimane di scarico l'intensità non sale.
      var scarico = sb == 3 || fase == Fase.scarico || fase == Fase.gara;
      var intensita = scarico ? math.min(0, passiIntensita) : passiIntensita;
      if (ad != null) {
        final settimanaScarico =
            ad.scaricoFino != null && !e.key.isAfter(ad.scaricoFino!);
        final f = fase == Fase.scarico
            ? 0.7
            : fase == Fase.gara
            ? 0.5
            : settimanaScarico
            ? 0.75
            : 1.0;
        fattore = (f * ad.volume).clamp(0.4, 1.5).toDouble();
        scarico = f < 1;
        intensita = scarico ? math.min(0, ad.intensita) : ad.intensita;
      }
      List<(_Seduta, (String, List<WorkoutStep>))> costruisci(double fat) => [
        for (final s in _ruoli(
          e.value,
          sp,
          settimane,
          fat,
          base,
          obiettivo,
          principiante,
          lungoFatto,
        ))
          (
            s,
            switch (sp) {
              'Corsa' => _corsa(
                s,
                fase,
                sb,
                settimane,
                obiettivo,
                s.fissa ? 0 : intensita,
                principiante,
              ),
              'Nuoto' => _nuoto(
                s,
                fase,
                sb,
                base,
                fat,
                passoCritico,
                s.fissa ? 0 : intensita,
              ),
              _ => _bici(s, s.fissa ? 0 : intensita),
            },
          ),
      ];
      var settimana = costruisci(fattore);
      // Tetto: al massimo +10% sulla più impegnativa delle due settimane
      // prima (così dopo uno scarico si torna al livello di prima).
      final riferimento = math.max(prima1, prima2);
      // Le serie arrotondano i metri: si riduce finché si sta nel limite.
      for (var prova = 0; prova < 6 && riferimento > 0; prova++) {
        final volume = _volumeSettimana(sp, settimana.map((x) => x.$2.$2));
        if (volume <= riferimento * 1.1) break;
        fattore *= riferimento * 1.1 / volume * 0.97;
        settimana = costruisci(fattore);
      }
      prima2 = prima1;
      prima1 = _volumeSettimana(sp, settimana.map((x) => x.$2.$2));
      for (final (s, w) in settimana) {
        passi.addAll(w.$2);
        programma.add(
          ProgrammaRiga(data: s.data, sport: sp, idWorkout: w.$2.first.id),
        );
        tipi[(s.data, sp)] = w.$1;
      }
    }
  }
  return PianoEndurance(passi, programma, tipi);
}

/// Volume di una seduta: metri nel nuoto, minuti negli altri sport.
double _volumeSeduta(String sport, List<WorkoutStep> passi) {
  if (sport != 'Nuoto') {
    return passi.isEmpty ? 0 : passi.first.durataTot.toDouble();
  }
  return passi.fold(0.0, (t, p) {
    final m = double.tryParse(p.distanzaM) ?? 0;
    final n = int.tryParse(p.serie) ?? 1;
    return t + m * math.max(1, n);
  });
}

double _volumeSettimana(String sport, Iterable<List<WorkoutStep>> sedute) =>
    sedute.fold(0.0, (t, p) => t + _volumeSeduta(sport, p));

/// Volume fatto nella settimana prima di [lunedi] (metri nel nuoto, minuti
/// negli altri sport).
double _volumeFatto(List<Sessione> storico, String sport, DateTime lunedi) {
  final da = lunedi.subtract(const Duration(days: 7));
  return storico
      .where(
        (s) =>
            stessoSport(s.sport, sport) &&
            !s.data.isBefore(da) &&
            s.data.isBefore(lunedi),
      )
      .fold(
        0.0,
        (t, s) => t + (sport == 'Nuoto' ? s.distanzaKm * 1000 : s.durataMin),
      );
}

/// Riferimenti dai dati recenti (ultime 4 settimane): durata della seduta più
/// lunga (corsa, bici) e distanza media in piscina in metri (nuoto).
({int lungoMin, int metri}) _base(
  List<Sessione> storico,
  String sport,
  DateTime da,
) {
  final recenti = storico.where(
    (s) =>
        stessoSport(s.sport, sport) &&
        s.data.isBefore(da) &&
        da.difference(s.data).inDays <= 28,
  );
  final lungo = recenti.fold(0, (m, s) => math.max(m, s.durataMin));
  final conDistanza = recenti.where((s) => s.distanzaKm > 0).toList();
  final metri = conDistanza.isEmpty
      ? 0
      : (conDistanza.fold(0.0, (t, s) => t + s.distanzaKm) /
                conDistanza.length *
                1000)
            .round();
  return (lungoMin: lungo, metri: metri);
}

/// Moltiplicatore del volume: +10% a settimana nel blocco, scarico al 75%,
/// fasi finali più corte, e ±5% per ogni passo deciso dai feedback.
double _fattore(int sb, Fase fase, int regolazione) {
  var f = sb == 3 ? 0.75 : 1 + 0.1 * sb;
  if (fase == Fase.scarico) f = 0.7;
  if (fase == Fase.gara) f = 0.5;
  return (f * (1 + 0.05 * regolazione)).clamp(0.4, 1.5).toDouble();
}

int _arrotonda5(double v) => math.max(15, (v / 5).round() * 5);

/// Ruolo di ogni seduta della settimana e sua durata.
List<_Seduta> _ruoli(
  List<PianoRiga> righe,
  String sport,
  int settimane,
  double fattore,
  ({int lungoMin, int metri}) base,
  Obiettivo? obiettivo,
  bool principiante,
  int lungoFatto,
) {
  final n = righe.length;
  // L'ultima della settimana è il lungo (la corsa anche se è l'unica); la
  // qualità è l'ultima ad almeno due giorni dal lungo; le altre sono facili.
  // Con una sola seduta di nuoto o bici, qualità a settimane alterne.
  final lungo = sport == 'Nuoto' || (sport == 'Bici' && n < 2) ? -1 : n - 1;
  var qualita = -1;
  if (n == 1 && lungo < 0) {
    if (settimane.isOdd) qualita = 0;
  } else {
    for (var i = n - 1; i >= 0; i--) {
      if (i != lungo &&
          righe[n - 1].data.difference(righe[i].data).inDays >= 2) {
        qualita = i;
        break;
      }
    }
    // Nuoto senza lungo: la qualità può essere anche l'ultima seduta.
    if (lungo < 0 && qualita < 0) qualita = n - 1;
  }
  // Chi parte da zero fa solo sedute facili nel primo mese.
  if (principiante && settimane < 4) qualita = -1;
  return [
    for (var i = 0; i < n; i++)
      () {
        final r = righe[i];
        final slot = r.durataMin > 0 ? r.durataMin : 45;
        if (rigaDaAssistente(r)) {
          return _Seduta(
            r.data,
            sport,
            _ruoloDi(sport, r.tipo),
            slot,
            tipo: r.tipo,
            fissa: true,
          );
        }
        final facile = _arrotonda5(slot * math.min(fattore, 1.0));
        if (sport == 'Nuoto') {
          return _Seduta(
            r.data,
            sport,
            i == qualita ? 'soglia' : 'tecnica',
            facile,
          );
        }
        if (i == lungo) {
          final tetto = math.max(
            sport == 'Corsa' ? (_tettoLungo[obiettivo?.gara] ?? 90) : 240,
            lungoFatto,
          );
          final partenza = math.max(math.max(slot, base.lungoMin), lungoFatto);
          return _Seduta(
            r.data,
            sport,
            'lungo',
            _arrotonda5(math.min(partenza * fattore, tetto.toDouble())),
          );
        }
        if (i == qualita) {
          return _Seduta(
            r.data,
            sport,
            sport == 'Corsa' ? 'qualita' : 'intervalli',
            facile,
          );
        }
        return _Seduta(
          r.data,
          sport,
          sport == 'Corsa' ? 'lento' : 'z2',
          facile,
        );
      }(),
  ];
}

WorkoutStep _passo(
  _Seduta s,
  String nome,
  int ordine,
  String fase,
  String descrizione, {
  String serie = '',
  String rip = '',
  String metri = '',
  String minuti = '',
  String intensita = '',
  String recupero = '',
  String note = '',
}) => WorkoutStep(
  id: '${prefissoEndurance(s.sport)}${isoData(s.data)}',
  sport: s.sport,
  nome: nome,
  durataTot: s.durata,
  ordine: ordine,
  fase: fase,
  descrizione: descrizione,
  serie: serie,
  ripetizioni: rip,
  distanzaM: metri,
  durataMin: minuti,
  intensita: intensita,
  recuperoS: recupero,
  note: note,
);

/// Corsa: lento, lungo e qualità che cambia con la fase.
(String, List<WorkoutStep>) _corsa(
  _Seduta s,
  Fase fase,
  int sb,
  int settimane,
  Obiettivo? o,
  int k, // passi di intensità, da -3 a +3
  bool principiante,
) {
  final d = s.durata;
  // Primo mese di chi parte da zero: corsa e camminata alternate.
  if (principiante && settimane < 4 && s.ruolo != 'qualita') {
    final tipo = s.ruolo == 'lungo' ? 'Lungo' : 'Lento';
    return (
      tipo,
      [
        _passo(
          s,
          '$tipo · $d min',
          1,
          'principale',
          'Corsa leggera alternata a camminata',
          serie: '${math.max(3, d ~/ 3)}',
          minuti: '2',
          intensita: 'zona 2',
          recupero: '60',
          note:
              'Dopo 2 minuti di corsa cammina 1 minuto. Se ti manca il fiato, '
              'cammina di più: va benissimo, è così che si comincia.',
        ),
      ],
    );
  }
  // Minuti finali più svelti a parità di durata (al massimo un terzo).
  final progressivo = k > 0 ? math.min(5 * k, d ~/ 3) : 0;
  const piuFacile = 'Ancora più tranquillo del solito: resta in zona 1-2.';
  final ritmoGara = o?.gara == '5k' || o?.gara == '10k' ? 'zona 4' : 'zona 3';
  switch (s.ruolo) {
    case 'lungo':
      final finale =
          (fase == Fase.sviluppo || fase == Fase.rifinitura) &&
          {'mezza', 'maratona', '703', 'ironman'}.contains(o?.gara);
      final nome = 'Lungo · $d min';
      final minFinale = finale ? 20 + progressivo : progressivo;
      return (
        'Lungo',
        [
          _passo(
            s,
            nome,
            1,
            'principale',
            'Corsa lunga continua',
            minuti: '${d - minFinale}',
            intensita: 'zona 2',
            note: k < 0
                ? piuFacile
                : 'Ritmo facile e costante: devi riuscire a parlare.',
          ),
          if (minFinale > 0)
            _passo(
              s,
              nome,
              2,
              'principale',
              finale ? 'Finale a ritmo gara' : 'Finale in progressione',
              minuti: '$minFinale',
              intensita: finale ? ritmoGara : 'zona 3',
            ),
        ],
      );
    case 'qualita':
      final tipo = s.fissa && _tipiQualita.contains(s.tipo)
          ? s.tipo
          : principiante && sb != 3 && fase != Fase.scarico && fase != Fase.gara
          ? 'Fartlek' // la qualità più dolce
          : switch (fase) {
              Fase.scarico || Fase.gara => 'Allunghi',
              _ when sb == 3 => 'Allunghi',
              Fase.base => settimane.isEven ? 'Fartlek' : 'Tempo run',
              Fase.sviluppo => settimane.isEven ? 'Ripetute' : 'Tempo run',
              Fase.rifinitura => 'Ritmo gara',
              Fase.libera => settimane.isEven ? 'Fartlek' : 'Tempo run',
            };
      // Una seduta breve (scelta dall'assistente) resta breve.
      final margine = d < 30 ? 5 : 10;
      final nucleo = math.max(10, d - 2 * margine);
      final nome = '$tipo · $d min';
      final riscaldamento = _passo(
        s,
        nome,
        1,
        'riscaldamento',
        'Corsa facile',
        minuti: '$margine',
        intensita: 'zona 2',
      );
      final defaticamento = _passo(
        s,
        nome,
        9,
        'defaticamento',
        'Corsa facile',
        minuti: '$margine',
        intensita: 'zona 1',
      );
      // Più intensità = recuperi più corti e più minuti veloci nello stesso tempo.
      final recFartlek = (120 - 30 * k).clamp(60, 180).toInt();
      final recRipetute = (120 - 20 * k).clamp(60, 180).toInt();
      final recGara = (180 - 30 * k).clamp(90, 270).toInt();
      final centrale = switch (tipo) {
        'Fartlek' => [
          _passo(
            s,
            nome,
            2,
            'principale',
            'Corsa veloce',
            serie: '${(nucleo * 60 / (120 + recFartlek)).floor().clamp(3, 16)}',
            minuti: '2',
            intensita: 'zona 4',
            recupero: '$recFartlek',
            note: 'Recupero corricchiando in zona 2.',
          ),
        ],
        'Tempo run' => [
          _passo(
            s,
            nome,
            2,
            'principale',
            'Corsa a ritmo sostenuto',
            minuti:
                '${(math.min(nucleo, 30) + 5 * k).clamp(10, math.max(10, nucleo))}',
            intensita: 'zona 3',
          ),
        ],
        'Ripetute' => [
          _passo(
            s,
            nome,
            2,
            'principale',
            'Ripetute veloci',
            serie:
                '${(nucleo * 60 / (180 + recRipetute)).floor().clamp(4, 10)}',
            minuti: '3',
            intensita: 'zona 5',
            recupero: '$recRipetute',
            note: 'Recupero corricchiando piano.',
          ),
        ],
        'Ritmo gara' => [
          _passo(
            s,
            nome,
            2,
            'principale',
            'Blocchi a ritmo gara',
            serie: '2',
            minuti: '${math.max(8, (nucleo * 60 - recGara) ~/ 120)}',
            intensita: ritmoGara,
            recupero: '$recGara',
          ),
        ],
        _ => [
          _passo(
            s,
            nome,
            2,
            'principale',
            'Corsa facile',
            // Gli allunghi durano circa 8 minuti, recuperi compresi.
            minuti: '${math.max(5, d - 8)}',
            intensita: 'zona 2',
          ),
          _passo(
            s,
            nome,
            3,
            'principale',
            'Allunghi in progressione',
            serie: '${(6 + k).clamp(4, 10)}',
            rip: '20 s',
            recupero: '60',
            note: 'Veloci ma rilassati, non a tutta.',
          ),
        ],
      };
      return (
        tipo,
        [
          if (tipo != 'Allunghi') riscaldamento,
          ...centrale,
          if (tipo != 'Allunghi') defaticamento,
        ],
      );
    default:
      return (
        'Lento',
        [
          _passo(
            s,
            'Lento · $d min',
            1,
            'principale',
            'Corsa lenta',
            minuti: '${d - progressivo}',
            intensita: 'zona 2',
            note: k < 0 ? piuFacile : '',
          ),
          if (progressivo > 0)
            _passo(
              s,
              'Lento · $d min',
              2,
              'principale',
              'Finale in progressione',
              minuti: '$progressivo',
              intensita: 'zona 3',
            ),
        ],
      );
  }
}

/// Nuoto: tecnica e aerobico, oppure soglia, al passo critico personale.
(String, List<WorkoutStep>) _nuoto(
  _Seduta s,
  Fase fase,
  int sb,
  ({int lungoMin, int metri}) base,
  double fattore,
  int? pc,
  int k, // passi di intensità: passo più svelto e recuperi più brevi
) {
  // Metri totali: dai dati recenti (o dalla durata), con la progressione.
  final partenza = base.metri > 0 && !s.fissa
      ? base.metri
      : (s.durata * 60 / ((pc ?? 150) + 25) * 100 * 0.7);
  final f = s.fissa ? 1.0 : fattore;
  final totale = math.max(600, ((partenza * f) / 50).round() * 50);
  final principale = math.max(200, totale - 200 - 200 - 200);
  String passo({required bool soglia}) => pc == null
      ? ''
      : 'passo ${fmtPasso100(targetNuoto(pc, soglia: soglia, k: k))}';
  final soglia = s.fissa
      ? s.ruolo == 'soglia'
      : s.ruolo == 'soglia' && sb != 3 && fase != Fase.scarico;
  final tipo = soglia ? 'Soglia' : 'Tecnica';
  final nome = '$tipo · $totale m';
  return (
    tipo,
    [
      _passo(
        s,
        nome,
        1,
        'riscaldamento',
        'Stile libero facile',
        metri: '200',
        recupero: '30',
      ),
      _passo(
        s,
        nome,
        2,
        'tecnica',
        'Gambe con tavoletta e braccio singolo',
        serie: '4',
        metri: '50',
        recupero: '20',
        note: '2 gambe con tavoletta, 1 solo braccio destro, 1 solo sinistro.',
      ),
      if (soglia)
        _passo(
          s,
          nome,
          3,
          'principale',
          'Stile libero sostenuto',
          serie: '${principale ~/ 100}',
          metri: '100',
          intensita: pc == null ? 'sostenuto, costante' : passo(soglia: true),
          recupero: '${(15 - 3 * k).clamp(5, 30)}',
        )
      else
        _passo(
          s,
          nome,
          3,
          'principale',
          'Stile libero aerobico',
          serie: '${principale ~/ 200}',
          metri: '200',
          intensita: pc == null
              ? 'medio, respirazione regolare'
              : passo(soglia: false),
          recupero: '${(30 - 5 * k).clamp(10, 45)}',
        ),
      _passo(s, nome, 4, 'defaticamento', 'Dorso facile', metri: '200'),
    ],
  );
}

/// Bici: Z2, intervalli in zona 4, uscita lunga nel fine settimana.
(String, List<WorkoutStep>) _bici(_Seduta s, int k) {
  final d = s.durata;
  final progressivo = k > 0 ? math.min(5 * k, d ~/ 3) : 0;
  switch (s.ruolo) {
    case 'intervalli':
      final nome = 'Intervalli · $d min';
      final rec = (180 - 30 * k).clamp(90, 270).toInt();
      final serie = ((d - 25) * 60 / (360 + rec)).floor().clamp(2, 8);
      return (
        'Intervalli',
        [
          _passo(
            s,
            nome,
            1,
            'riscaldamento',
            'Pedalata agile',
            minuti: '15',
            intensita: 'zona 2',
          ),
          _passo(
            s,
            nome,
            2,
            'principale',
            'Ripetute in salita o in pianura',
            serie: '$serie',
            minuti: '6',
            intensita: 'zona 4',
            recupero: '$rec',
          ),
          _passo(
            s,
            nome,
            3,
            'defaticamento',
            'Pedalata sciolta',
            minuti: '10',
            intensita: 'zona 1',
          ),
        ],
      );
    case 'lungo':
      return (
        'Uscita lunga',
        [
          _passo(
            s,
            'Uscita lunga · $d min',
            1,
            'principale',
            'Uscita continua',
            minuti: '$d',
            intensita: 'zona 2',
            note: k > 0
                ? 'Inserisci ${k + 1} tratti da 10 minuti in zona 3. '
                      'Mangia e bevi ogni 30-45 minuti.'
                : 'Mangia e bevi ogni 30-45 minuti.',
          ),
        ],
      );
    default:
      return (
        'Uscita',
        [
          _passo(
            s,
            'Uscita · $d min',
            1,
            'principale',
            'Pedalata costante',
            minuti: '${d - progressivo}',
            intensita: 'zona 2',
          ),
          if (progressivo > 0)
            _passo(
              s,
              'Uscita · $d min',
              2,
              'principale',
              'Finale più spinto',
              minuti: '$progressivo',
              intensita: 'zona 3',
            ),
        ],
      );
  }
}
