import 'esecuzione.dart';
import 'models.dart';

// Allenamenti preparati dall'assistente (per esempio Claude) passo per passo:
// riscaldamento, ripetute con watt o % dell'FTP, recuperi, defaticamento.
// Vanno nel calendario in quel giorno al posto della seduta preparata
// dall'app, e il rullo smart li segue in ERG.

/// Il file con i passi degli allenamenti dell'assistente.
const fileAllenamentiAgente = 'allenamenti_agente.csv';

/// Sport per cui l'assistente può scrivere i passi.
const sportAllenamentiAgente = {'Corsa', 'Bici', 'Nuoto'};

/// Id del workout dell'assistente per quel giorno e sport.
String idAllenamentoAgente(DateTime data, String sport) =>
    'agente-${isoData(data)}-${normSport(sport).toLowerCase()}';

/// Un allenamento proposto dall'assistente, già nel formato dell'app.
class AllenamentoAgente {
  final DateTime data;
  final String sport;
  final String tipo; // es. Intervalli, Uscita lunga
  final String nome; // es. "VO2max 5×4"
  final String fascia;
  final List<WorkoutStep> passi;
  const AllenamentoAgente({
    required this.data,
    required this.sport,
    required this.tipo,
    required this.nome,
    required this.fascia,
    required this.passi,
  });

  /// Minuti in tutto: lavoro e recuperi di ogni ripetizione.
  int get durataMin => durataPassi(passi);
}

/// Minuti totali dei blocchi a tempo, recuperi compresi, come li fa il
/// player (quelli a distanza non si sanno).
int durataPassi(List<WorkoutStep> passi) =>
    (blocchiDa(passi).fold(0, (t, b) => t + (b.secondi ?? 0)) / 60).round();

String _testo(Object? v, int max) {
  final t = '${v ?? ''}'.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t.length > max ? t.substring(0, max) : t;
}

double? _numero(Object? v) {
  final n = v is num
      ? v.toDouble()
      : double.tryParse('$v'.replaceAll(',', '.'));
  return n == null || !n.isFinite ? null : n;
}

String _cifra(double v) =>
    v == v.roundToDouble() ? '${v.round()}' : fmtNum(v).replaceAll('.', ',');

const _fasi = {'riscaldamento', 'principale', 'defaticamento'};

/// Legge un allenamento dal JSON dell'assistente. Lancia [FormatException]
/// con un messaggio semplice se qualcosa non va.
AllenamentoAgente allenamentoDa(Map<String, dynamic> m) {
  final data = parseData('${m['data'] ?? ''}');
  if (data == null) {
    throw const FormatException('Un allenamento non ha la data.');
  }
  final sport = normSport('${m['sport'] ?? ''}');
  if (!sportAllenamentiAgente.contains(sport)) {
    throw FormatException(
      'Allenamento del ${isoData(data)}: lo sport deve essere corsa, bici '
      'o nuoto.',
    );
  }
  final lista = m['passi'];
  if (lista is! List || lista.isEmpty || lista.length > 40) {
    throw FormatException(
      'Allenamento del ${isoData(data)}: servono da 1 a 40 passi.',
    );
  }
  final nome = _testo(m['nome'], 60).isEmpty
      ? 'Allenamento di ${sport.toLowerCase()}'
      : _testo(m['nome'], 60);
  final id = idAllenamentoAgente(data, sport);
  final passi = <WorkoutStep>[];
  for (final (k, x) in lista.indexed) {
    if (x is! Map) continue;
    final minuti = _numero(x['minuti']);
    final metri = _numero(x['metri']);
    final okMinuti = minuti != null && minuti > 0 && minuti <= 300;
    final okMetri = metri != null && metri > 0 && metri <= 100000;
    if (!okMinuti && !okMetri) {
      throw FormatException(
        'Allenamento del ${isoData(data)}, passo ${k + 1}: servono i minuti '
        '(fino a 300) o i metri.',
      );
    }
    final ripeti = (_numero(x['ripeti']) ?? 1).round();
    final recupero = (_numero(x['recupero_s']) ?? 0).round();
    if (ripeti < 1 || ripeti > 30 || recupero < 0 || recupero > 1800) {
      throw FormatException(
        'Allenamento del ${isoData(data)}, passo ${k + 1}: ripetizioni da 1 '
        'a 30 e recupero fino a 1800 secondi.',
      );
    }
    final fase = _testo(x['fase'], 20).toLowerCase();
    passi.add(
      WorkoutStep(
        id: id,
        sport: sport,
        nome: nome,
        durataTot: 0,
        ordine: k + 1,
        fase: _fasi.contains(fase) ? fase : 'principale',
        descrizione: _testo(x['nome'], 60).isEmpty
            ? maiuscola(fase.isEmpty ? 'principale' : fase)
            : _testo(x['nome'], 60),
        serie: ripeti > 1 ? '$ripeti' : '',
        ripetizioni: '',
        distanzaM: okMinuti ? '' : '${metri!.round()}',
        durataMin: okMinuti ? _cifra(minuti) : '',
        intensita: _testo(x['intensita'] ?? x['potenza'], 60),
        recuperoS: recupero > 0 ? '$recupero' : '',
        note: _testo(x['note'], 200),
      ),
    );
  }
  final durata = durataPassi(passi);
  if (durata > 300) {
    throw FormatException(
      'Allenamento del ${isoData(data)}: dura più di 5 ore.',
    );
  }
  final conTotale = [
    for (final s in passi)
      WorkoutStep(
        id: s.id,
        sport: s.sport,
        nome: s.nome,
        durataTot: durata,
        ordine: s.ordine,
        fase: s.fase,
        descrizione: s.descrizione,
        serie: s.serie,
        ripetizioni: s.ripetizioni,
        distanzaM: s.distanzaM,
        durataMin: s.durataMin,
        intensita: s.intensita,
        recuperoS: s.recuperoS,
        note: s.note,
      ),
  ];
  return AllenamentoAgente(
    data: data,
    sport: sport,
    tipo: _testo(m['tipo'], 30).isEmpty ? nome : _testo(m['tipo'], 30),
    nome: nome,
    fascia: _testo(m['fascia'], 20),
    passi: conTotale,
  );
}

/// Il piano con la seduta dell'allenamento: al posto di quella dello stesso
/// sport in quel giorno (tenendo l'orario), oppure aggiunta.
List<PianoRiga> pianoCon(List<PianoRiga> piano, AllenamentoAgente a) {
  final prima = piano
      .where((r) => r.data == a.data && stessoSport(r.sport, a.sport))
      .firstOrNull;
  final riga = PianoRiga(
    data: a.data,
    fascia: a.fascia.isNotEmpty ? a.fascia : prima?.fascia ?? 'Sera',
    sport: a.sport,
    tipo: a.tipo,
    durataMin: a.durataMin,
    note: prima?.note ?? '',
  );
  final out = <PianoRiga>[];
  var messa = false;
  for (final r in piano) {
    if (r.data == a.data && stessoSport(r.sport, a.sport)) {
      if (!messa) out.add(riga);
      messa = true;
    } else {
      out.add(r);
    }
  }
  if (!messa) out.add(riga);
  return out..sort((x, y) => x.data.compareTo(y.data));
}
