import 'csv.dart';
import 'models.dart';

// Registro della forza: ripetizioni e kg di ogni serie fatta con la modalità
// allenamento. Serve a vedere lo storico di un esercizio e a proporre il peso
// della volta dopo partendo da quello vero, non solo dalle sensazioni.

const serieHeader = ['data', 'esercizio', 'nome', 'serie', 'ripetizioni', 'kg'];

/// Una serie fatta: quante ripetizioni e con quanti kg (0 = corpo libero).
class SerieFatta {
  final DateTime data;
  final String esercizio; // id nel catalogo (vuoto se non c'è)
  final String nome;
  final int serie; // 1, 2, 3…
  final int ripetizioni;
  final double kg;
  const SerieFatta({
    required this.data,
    required this.esercizio,
    required this.nome,
    required this.serie,
    required this.ripetizioni,
    this.kg = 0,
  });

  /// Chiave dell'esercizio: l'id del catalogo, altrimenti il nome.
  String get chiave => esercizio.isEmpty ? nome : esercizio;

  List<String> toRow() => [
    isoData(data),
    esercizio,
    nome,
    '$serie',
    '$ripetizioni',
    kg > 0 ? fmtKg(kg) : '',
  ];

  static SerieFatta? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    final rip = int.tryParse(t.v(r, 'ripetizioni')) ?? 0;
    if (d == null || rip <= 0) return null;
    return SerieFatta(
      data: d,
      esercizio: t.v(r, 'esercizio'),
      nome: t.v(r, 'nome'),
      serie: int.tryParse(t.v(r, 'serie')) ?? 1,
      ripetizioni: rip,
      kg: double.tryParse(t.v(r, 'kg').replaceAll(',', '.')) ?? 0,
    );
  }
}

/// "12.5" → "12,5"; "40.0" → "40".
String fmtKg(double kg) {
  final s = kg == kg.roundToDouble()
      ? kg.round().toString()
      : kg.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  return s.replaceAll('.', ',');
}

/// Ripetizioni previste da "8-10", "12" o "10 per lato"; null se è a tempo.
(int, int)? ripetizioniPreviste(String testo) {
  final t = testo.trim();
  if (RegExp(r'^\d+\s*s\b').hasMatch(t)) return null;
  final m = RegExp(r'^(\d+)(?:\s*[-–]\s*(\d+))?').firstMatch(t);
  if (m == null) return null;
  final lo = int.parse(m.group(1)!);
  final hi = int.tryParse(m.group(2) ?? '') ?? lo;
  return lo <= 0 ? null : (lo, hi < lo ? lo : hi);
}

/// Il peso scritto nelle note del piano ("Peso: circa 12,5 kg."), se c'è.
double? kgDalleNote(String note) {
  final m = RegExp(r'(\d+(?:[.,]\d+)?)\s*kg').firstMatch(note);
  return m == null ? null : double.tryParse(m.group(1)!.replaceAll(',', '.'));
}

/// Le serie dell'ultima volta che hai fatto l'esercizio, prima di [prima].
List<SerieFatta> ultimaVolta(
  List<SerieFatta> tutte,
  String chiave, {
  DateTime? prima,
}) {
  final sue = tutte
      .where(
        (s) =>
            s.chiave == chiave &&
            (prima == null || s.data.isBefore(soloData(prima))),
      )
      .toList();
  if (sue.isEmpty) return const [];
  final ultima = sue.map((s) => s.data).reduce((a, b) => a.isAfter(b) ? a : b);
  return sue.where((s) => s.data == ultima).toList()
    ..sort((a, b) => a.serie.compareTo(b.serie));
}

/// La serie migliore: più kg, a pari kg più ripetizioni.
SerieFatta? recordDi(List<SerieFatta> tutte, String chiave) {
  SerieFatta? r;
  for (final s in tutte.where((s) => s.chiave == chiave)) {
    if (r == null ||
        s.kg > r.kg ||
        (s.kg == r.kg && s.ripetizioni > r.ripetizioni)) {
      r = s;
    }
  }
  return r;
}

/// "3 × 8 a 40 kg", "8, 8, 7 a 40 kg" o "10, 9, 8" a corpo libero.
String fmtSerie(List<SerieFatta> serie) {
  if (serie.isEmpty) return '';
  final rip = serie.map((s) => s.ripetizioni).toList();
  final kg = serie.map((s) => s.kg).toSet();
  final quante = rip.toSet().length == 1
      ? '${rip.length} × ${rip.first}'
      : rip.join(', ');
  if (kg.length == 1) {
    return kg.first > 0 ? '$quante a ${fmtKg(kg.first)} kg' : quante;
  }
  return serie
      .map(
        (s) => s.kg > 0
            ? '${s.ripetizioni} × ${fmtKg(s.kg)} kg'
            : '${s.ripetizioni}',
      )
      .join(', ');
}

/// Vero se l'ultima volta tutte le serie sono arrivate al massimo previsto:
/// è il momento di aumentare il peso.
bool prontoPerAumentare(List<SerieFatta> ultima, int massimo) =>
    ultima.isNotEmpty && ultima.every((s) => s.ripetizioni >= massimo);

/// Valori di partenza per una serie: la serie prima nella stessa seduta, poi
/// la stessa serie dell'ultima volta, poi il previsto dal piano.
(int, double) proposta({
  required int serie,
  required (int, int) previste,
  required List<SerieFatta> ultima,
  (int, double)? precedente,
  double? kgPiano,
  bool kgPerSerie = false,
}) {
  // Pesi diversi serie per serie (piramide della scheda): vale la scheda.
  if (kgPerSerie && kgPiano != null) {
    return (precedente?.$1 ?? previste.$1, kgPiano);
  }
  if (precedente != null) return precedente;
  final stessa =
      ultima.where((s) => s.serie == serie).firstOrNull ?? ultima.lastOrNull;
  if (stessa != null) return (previste.$1, stessa.kg);
  return (previste.$1, kgPiano ?? 0);
}
