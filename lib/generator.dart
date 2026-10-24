import 'models.dart';
import 'workout_base.dart';

/// Replica la settimana tipo da [inizio] per [mesi] mesi.
List<PianoRiga> generaPiano(List<Slot> settimana, DateTime inizio, int mesi) {
  final fine = DateTime(inizio.year, inizio.month + mesi, inizio.day);
  final out = <PianoRiga>[];
  for (
    var d = inizio;
    d.isBefore(fine);
    d = DateTime(d.year, d.month, d.day + 1)
  ) {
    final delGiorno = settimana.where((s) => s.giorno == d.weekday).toList()
      ..sort(
        (a, b) => fasce.indexOf(a.fascia).compareTo(fasce.indexOf(b.fascia)),
      );
    for (final s in delGiorno) {
      out.add(
        PianoRiga(
          data: d,
          fascia: s.fascia,
          sport: s.sport,
          tipo: s.tipo.isEmpty ? tipoPredefinito(d, s.sport) : s.tipo,
          durataMin: s.durataMin,
          note: s.note,
        ),
      );
    }
  }
  return out;
}

String _chiaveSlot(Slot s) =>
    '${s.fascia}|${normSport(s.sport)}|${s.tipo}|${s.durataMin}|${s.note}';

/// Giorni della settimana (1 = lunedì) in cui la settimana tipo è cambiata.
Set<int> giorniCambiati(List<Slot> prima, List<Slot> dopo) {
  List<String> di(List<Slot> l, int g) => [
    for (final s in l)
      if (s.giorno == g) _chiaveSlot(s),
  ]..sort();
  return {
    for (var g = 1; g <= 7; g++)
      if (di(prima, g).join(';') != di(dopo, g).join(';')) g,
  };
}

/// Porta nel calendario i cambi della settimana tipo, da [da] a [fine]
/// compresi, solo nei giorni della settimana cambiati. I giorni per cui
/// [daTenere] è vero (già svolti, decisi dall'assistente…) restano come sono.
List<PianoRiga> applicaSettimana({
  required List<PianoRiga> piano,
  required List<Slot> prima,
  required List<Slot> dopo,
  required DateTime da,
  required DateTime fine,
  bool Function(DateTime)? daTenere,
}) {
  final cambiati = giorniCambiati(prima, dopo);
  if (cambiati.isEmpty) return piano;
  bool tocca(DateTime d) =>
      cambiati.contains(d.weekday) &&
      !d.isBefore(da) &&
      !d.isAfter(fine) &&
      !(daTenere?.call(d) ?? false);
  final giorni = <DateTime>{
    for (
      var d = soloData(da);
      !d.isAfter(fine);
      d = DateTime(d.year, d.month, d.day + 1)
    )
      if (tocca(d)) d,
  };
  final nuove = [for (final d in giorni) ..._delGiorno(dopo, d)];
  return [
    for (final r in piano)
      if (!giorni.contains(r.data)) r,
    ...nuove,
  ]..sort((a, b) {
    final c = a.data.compareTo(b.data);
    return c != 0
        ? c
        : fasce.indexOf(a.fascia).compareTo(fasce.indexOf(b.fascia));
  });
}

List<PianoRiga> _delGiorno(List<Slot> settimana, DateTime d) => [
  for (final s
      in settimana.where((s) => s.giorno == d.weekday).toList()..sort(
        (a, b) => fasce.indexOf(a.fascia).compareTo(fasce.indexOf(b.fascia)),
      ))
    PianoRiga(
      data: d,
      fascia: s.fascia,
      sport: s.sport,
      tipo: s.tipo.isEmpty ? tipoPredefinito(d, s.sport) : s.tipo,
      durataMin: s.durataMin,
      note: s.note,
    ),
];
