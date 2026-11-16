import 'dart:math' as math;

import 'carico.dart';
import 'csv.dart';
import 'l10n/lingua.dart';
import 'models.dart';
import 'potenza.dart';
import 'serie_sessione.dart';

// Test delle soglie: FTP in bici (rampa sul rullo o 20 minuti), passo critico
// nel nuoto. Più la stima dell'FTP dalle uscite e quando proporre un test.

/// Tipo delle sedute di test nel calendario (corsa e bici).
const tipoTestFtp = 'Test FTP';

/// Tipo del test del nuoto nel calendario.
const tipoTestNuoto = 'Test';

const nomeTestFtpBiciRampa = 'Test FTP in bici (rampa)';
const nomeTestFtpBiciVenti = 'Test FTP in bici (20 minuti)';
const nomeTestNuoto = 'Test del passo critico';

/// Vero se il tipo (o il nome) di una seduta dice che è un test.
bool eTest(String testo) =>
    RegExp(r'\btest\b|\bftp\b', caseSensitive: false).hasMatch(testo);

/// Il test di bici scritto in un testo: "rampa", "venti" o vuoto se non è un
/// test.
String testBiciDa(String testo) {
  if (!eTest(testo)) return '';
  return testo.toLowerCase().contains('rampa') ? 'rampa' : 'venti';
}

WorkoutStep _passo(
  String id,
  String sport,
  String nome,
  int durataTot,
  int ordine,
  String fase,
  String descrizione, {
  String serie = '',
  String ripetizioni = '',
  String metri = '',
  String minuti = '',
  String intensita = '',
  String recupero = '',
  String note = '',
  String obiettivo2 = '',
}) => WorkoutStep(
  id: id,
  sport: sport,
  nome: nome,
  durataTot: durataTot,
  ordine: ordine,
  fase: fase,
  descrizione: descrizione,
  serie: serie,
  ripetizioni: ripetizioni,
  distanzaM: metri,
  durataMin: minuti,
  intensita: intensita,
  recuperoS: recupero,
  note: note,
  obiettivo2: obiettivo2,
);

int _a5(num w) => (w / 5).round() * 5;

/// Il test a rampa: 1 minuto per gradino, ogni minuto un po' più duro, finché
/// non ce la fai più. Il rullo in ERG tiene i watt da solo, quindi non serve
/// sapere quanto spingere. Con l'FTP i gradini partono dalla metà e salgono
/// del 6%; senza, da 100 W e di 20 W.
List<WorkoutStep> passiTestRampa(String id, {int? ftp}) {
  final f = ftp != null && ftp >= 50 ? ftp : null;
  final partenza = f == null ? 100 : math.max(50, _a5(f * 0.5));
  final gradino = f == null ? 20 : _a5(f * 0.06).clamp(10, 25).toInt();
  final cima = f == null ? 500 : (f * 1.6).round();
  final gradini = ((cima - partenza) / gradino).ceil().clamp(10, 30).toInt();
  final durata = 10 + gradini + 10;
  WorkoutStep p(
    int ordine,
    String fase,
    String descrizione, {
    String minuti = '',
    String intensita = '',
    String note = '',
  }) => _passo(
    id,
    'Bici',
    nomeTestFtpBiciRampa,
    durata,
    ordine,
    fase,
    descrizione,
    minuti: minuti,
    intensita: intensita,
    note: note,
    obiettivo2: '85-95 rpm',
  );
  final riscaldaW = f == null ? 90 : _a5(f * 0.45);
  return [
    p(
      1,
      'riscaldamento',
      l10n.tsPedalataFacile,
      minuti: '10',
      intensita: '$riscaldaW W',
      note: l10n.tsPedalaSciolto,
    ),
    for (var i = 0; i < gradini; i++)
      p(
        2 + i,
        'principale',
        l10n.tsGradinoRampa(i + 1),
        minuti: '1',
        intensita: '${partenza + i * gradino} W',
        note: i == 0 ? l10n.tsRampaNota : '',
      ),
    p(
      2 + gradini,
      'defaticamento',
      l10n.pedalataSciolta,
      minuti: '10',
      intensita: '$riscaldaW W',
      note: l10n.tsRisultatoNeiGrafici,
    ),
  ];
}

/// Il test dei 20 minuti, su strada o sul rullo senza ERG: riscaldamento con
/// 3 minuti svelti, poi 20 minuti al massimo costante. Con l'FTP suggerisce
/// i watt da cui partire; senza, si va a sensazione.
List<WorkoutStep> passiTestVenti(String id, {int? ftp, String sport = 'Bici'}) {
  final f = ftp != null && ftp >= 50 ? ftp : null;
  const durata = 15 + 5 + 5 + 20 + 10;
  WorkoutStep p(
    int ordine,
    String fase,
    String descrizione, {
    String serie = '',
    String minuti = '',
    String intensita = '',
    String recupero = '',
    String note = '',
  }) => _passo(
    id,
    sport,
    nomeTestFtpBiciVenti,
    durata,
    ordine,
    fase,
    descrizione,
    serie: serie,
    minuti: minuti,
    intensita: intensita,
    recupero: recupero,
    note: note,
  );
  return [
    p(
      1,
      'riscaldamento',
      l10n.tsPedalataFacile,
      minuti: '15',
      intensita: 'zona 2',
    ),
    p(
      2,
      'riscaldamento',
      l10n.tsMinutiSvelti,
      serie: '3',
      minuti: '1',
      intensita: 'zona 5',
      recupero: '60',
      note: l10n.tsMinutiSveltiNota,
    ),
    p(
      3,
      'riscaldamento',
      l10n.tsPedalataFacile,
      minuti: '5',
      intensita: 'zona 1',
    ),
    p(
      4,
      'principale',
      l10n.test20MinutiAl,
      minuti: '20',
      note: f == null
          ? l10n.tsVentiSenzaFtp
          : l10n.tsVentiConFtp(_a5(f * 1.02)),
    ),
    p(
      5,
      'defaticamento',
      l10n.pedalataSciolta,
      minuti: '10',
      intensita: 'zona 1',
      note: l10n.tsRisultatoNeiGrafici,
    ),
  ];
}

/// Il test del passo critico in piscina: 400 m e 200 m al massimo, con una
/// pausa lunga in mezzo. I due tempi danno il passo che si tiene a lungo.
List<WorkoutStep> passiTestNuoto(String id) {
  const durata = 40;
  WorkoutStep p(
    int ordine,
    String fase,
    String descrizione, {
    String serie = '',
    String metri = '',
    String intensita = '',
    String recupero = '',
    String note = '',
  }) => _passo(
    id,
    'Nuoto',
    nomeTestNuoto,
    durata,
    ordine,
    fase,
    descrizione,
    serie: serie,
    metri: metri,
    intensita: intensita,
    recupero: recupero,
    note: note,
  );
  return [
    p(1, 'riscaldamento', l10n.tsStileSceltaFacile, metri: '300'),
    p(
      2,
      'riscaldamento',
      l10n.tsStileLiberoProgressione,
      serie: '4',
      metri: '50',
      recupero: '20',
      note: l10n.tsOgni50Svelto,
    ),
    p(
      3,
      'principale',
      l10n.tsTest400,
      metri: '400',
      recupero: '300',
      note: l10n.tsTest400Nota,
    ),
    p(4, 'principale', l10n.tsTest200, metri: '200', note: l10n.tsTest200Nota),
    p(5, 'defaticamento', l10n.dorsoFacile, metri: '200'),
  ];
}

/// Il passo critico (secondi per 100 m) dai tempi del test: la differenza tra
/// 400 e 200 m, divisa per 2. Null se i tempi non tornano.
int? passoCriticoDaTest(int secondi400, int secondi200) {
  if (secondi200 < 100 || secondi400 <= secondi200) return null;
  // Il 400 non può essere molto più svelto di due 200.
  if (secondi400 < secondi200 * 1.9) return null;
  final pc = ((secondi400 - secondi200) / 2).round();
  return pc >= 50 && pc <= 300 ? pc : null;
}

// ---------------------------------------------------------------------
// Potenze migliori delle uscite (potenze_migliori.csv)

const potenzeMiglioriHeader = ['id_sessione', 'data', 'w20', 'w1', 'test'];
const filePotenzeMigliori = 'potenze_migliori.csv';

/// I migliori 20 minuti e il miglior minuto di un'uscita in bici. [test] è
/// "rampa", "venti" o vuoto per un'uscita normale.
class PotenzaMigliore {
  final String idSessione;
  final DateTime data;
  final int w20; // 0 se l'uscita è più corta di 20 minuti
  final int w1;
  final String test;
  const PotenzaMigliore({
    required this.idSessione,
    required this.data,
    required this.w20,
    required this.w1,
    this.test = '',
  });

  /// L'FTP che dice questa uscita: dalla rampa il 75% del miglior minuto,
  /// altrimenti il 95% dei migliori 20 minuti. Null se non dice niente.
  int? get ftp {
    if (test == 'rampa') return w1 > 0 ? (w1 * 0.75).round() : null;
    return w20 > 0 ? (w20 * 0.95).round() : null;
  }

  List<String> toRow() => [
    idSessione,
    isoData(data),
    w20 > 0 ? '$w20' : '',
    w1 > 0 ? '$w1' : '',
    test,
  ];

  static PotenzaMigliore? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    final id = t.v(r, 'id_sessione');
    if (d == null || id.isEmpty) return null;
    return PotenzaMigliore(
      idSessione: id,
      data: d,
      w20: int.tryParse(t.v(r, 'w20')) ?? 0,
      w1: int.tryParse(t.v(r, 'w1')) ?? 0,
      test: t.v(r, 'test'),
    );
  }
}

/// Le potenze migliori di un'uscita dalla sua serie. Null senza potenza.
PotenzaMigliore? potenzaMiglioreDa(
  String idSessione,
  DateTime data,
  List<Campione> potenza, {
  String test = '',
}) {
  if (potenza.length < 60) return null;
  final w1 = migliorePotenza(potenza, const Duration(minutes: 1)) ?? 0;
  final w20 = migliorePotenza(potenza, const Duration(minutes: 20)) ?? 0;
  if (w1 <= 0) return null;
  return PotenzaMigliore(
    idSessione: idSessione,
    data: soloData(data),
    w20: w20,
    w1: w1,
    test: test,
  );
}

/// Quanti giorni guarda indietro la stima dell'FTP.
const giorniStimaFtp = 42;

/// La stima dell'FTP dalle uscite recenti: la più alta delle ultime 6
/// settimane. Un'uscita normale può solo alzarla (se non si è spinto al
/// massimo dice meno del vero), quindi questa stima non scende mai da sola.
PotenzaMigliore? miglioreRecente(List<PotenzaMigliore> potenze, DateTime oggi) {
  final da = soloData(oggi).subtract(const Duration(days: giorniStimaFtp));
  PotenzaMigliore? migliore;
  for (final p in potenze) {
    if (p.data.isBefore(da) || p.data.isAfter(oggi)) continue;
    final f = p.ftp;
    if (f == null) continue;
    if (migliore == null || f > migliore.ftp!) migliore = p;
  }
  return migliore;
}

/// L'FTP da proporre al posto di [attuale]: solo se la stima è più alta di
/// almeno il 3% (sotto è rumore). Null se non c'è niente da proporre.
int? ftpDaProporre(List<PotenzaMigliore> potenze, int? attuale, DateTime oggi) {
  final f = miglioreRecente(potenze, oggi)?.ftp;
  if (f == null || f < 50 || f > 600) return null;
  if (attuale == null || attuale <= 0) return f;
  return f >= attuale * 1.03 ? f : null;
}

// ---------------------------------------------------------------------
// Quando proporre un test

/// Perché l'app propone un test.
enum MotivoTest { manca, vecchio, troppoFacile, troppoDuro }

/// Tra un test e l'altro almeno 4 settimane; vecchio dopo 8.
const giorniMinTraTest = 28;
const giorniTestVecchio = 56;

/// Il motivo per proporre un test dell'FTP in bici, o null se non serve.
/// [ultimaProva] è l'ultima volta che l'FTP è stato confermato (test, FTP
/// scritto o accettato, uscita vicina alla soglia); [ultimoTest] l'ultimo test.
/// [intervalli] sono gli ultimi feedback delle sedute dure di bici, dal più
/// recente: (fatica 1-10, completata).
MotivoTest? motivoTestBici({
  required int? ftp,
  required bool potenzaMisurata,
  required DateTime? ultimaProva,
  required DateTime? ultimoTest,
  required List<(int, bool)> intervalli,
  required DateTime oggi,
  DateTime? rimandatoFino,
}) {
  if (!potenzaMisurata) return null; // senza watt il test non si legge
  final o = soloData(oggi);
  if (rimandatoFino != null && o.isBefore(rimandatoFino)) return null;
  if (ultimoTest != null &&
      o.difference(ultimoTest).inDays < giorniMinTraTest) {
    return null;
  }
  if (ftp == null || ftp <= 0) return MotivoTest.manca;
  final ultime = intervalli.take(3).toList();
  if (ultime.length == 3 && ultime.every((x) => x.$1 <= 3 && x.$2)) {
    return MotivoTest.troppoFacile;
  }
  if (ultime.where((x) => !x.$2).length >= 2) return MotivoTest.troppoDuro;
  if (ultimaProva == null ||
      o.difference(ultimaProva).inDays > giorniTestVecchio) {
    return MotivoTest.vecchio;
  }
  return null;
}

/// Il motivo per proporre il test del nuoto: costa poco, quindi ogni 8
/// settimane (o subito se il passo critico non c'è).
MotivoTest? motivoTestNuoto({
  required DateTime? ultimoTest,
  required bool passoScritto,
  required DateTime oggi,
  DateTime? rimandatoFino,
}) {
  final o = soloData(oggi);
  if (rimandatoFino != null && o.isBefore(rimandatoFino)) return null;
  if (ultimoTest != null) {
    final giorni = o.difference(ultimoTest).inDays;
    return giorni > giorniTestVecchio ? MotivoTest.vecchio : null;
  }
  return passoScritto ? MotivoTest.vecchio : MotivoTest.manca;
}

/// Una frase semplice per il motivo.
String spiegaMotivo(MotivoTest m, String sport) {
  final nuoto = stessoSport(sport, 'Nuoto');
  return switch (m) {
    MotivoTest.manca => nuoto ? l10n.tsMancaPasso : l10n.tsMancaFtp,
    MotivoTest.vecchio => nuoto ? l10n.tsVecchioPasso : l10n.tsVecchioFtp,
    MotivoTest.troppoFacile => l10n.tsTroppoFacile,
    MotivoTest.troppoDuro => l10n.tsTroppoDuro,
  };
}

/// Vero se la settimana di [lunedi] viene dopo una settimana leggera del
/// piano (ogni 4 settimane dall'inizio la quarta è di scarico).
bool dopoScarico(DateTime inizio, DateTime lunedi) {
  final settimane = lunedi.difference(lunediDi(inizio)).inDays ~/ 7;
  return settimane > 0 && settimane % 4 == 0;
}

/// La seduta del piano che il test può sostituire: la prossima seduta dura
/// dello sport nei prossimi 21 giorni (da domani), meglio se nella settimana
/// dopo lo scarico; altrimenti la prossima seduta dello sport. Null se non
/// c'è niente in calendario.
PianoRiga? sedutaPerTest(
  List<PianoRiga> piano,
  String sport,
  DateTime oggi, {
  DateTime? inizio,
}) {
  final da = soloData(oggi);
  final a = da.add(const Duration(days: 21));
  final candidate = [
    for (final r in piano)
      if (stessoSport(r.sport, sport) &&
          r.data.isAfter(da) &&
          !r.data.isAfter(a) &&
          !eTest(r.tipo))
        r,
  ]..sort((x, y) => x.data.compareTo(y.data));
  if (candidate.isEmpty) return null;
  final dure = candidate.where((r) => _dura(r.tipo, sport)).toList();
  if (inizio != null) {
    final dopo = dure.where((r) => dopoScarico(inizio, lunediDi(r.data)));
    if (dopo.isNotEmpty) return dopo.first;
  }
  if (dure.isNotEmpty) return dure.first;
  // Mai al posto del lungo: è la seduta più importante della settimana.
  return candidate
      .where((r) => !r.tipo.toLowerCase().contains('lung'))
      .firstOrNull;
}

bool _dura(String tipo, String sport) {
  final t = tipo.toLowerCase();
  if (stessoSport(sport, 'Nuoto')) return t.contains('soglia');
  if (stessoSport(sport, 'Bici')) return t.contains('intervall');
  return const ['fartlek', 'tempo', 'ripetute', 'ritmo'].any(t.contains);
}
