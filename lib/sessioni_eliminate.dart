import 'feedback.dart';
import 'models.dart';

// Sessioni tolte dallo storico dall'utente. Quelle registrate con l'app (o
// importate da CSV) si cancellano davvero; quelle dell'orologio (Health
// Connect, intervals.icu) restano lì e tornerebbero alla sincronizzazione,
// quindi se ne tiene l'id in sessioni_nascoste.csv.

const nascosteHeader = ['id_sessione'];

/// Lo storico dopo aver tolto [s]: anche il suo feedback va via, altrimenti il
/// giorno risulterebbe ancora fatto.
({
  List<Sessione> storico,
  Set<String> nascoste,
  List<FeedbackSessione> feedback,
})
togliSessione(
  Sessione s, {
  required List<Sessione> storico,
  required Set<String> nascoste,
  required List<FeedbackSessione> feedback,
}) {
  final ids = {s.id, for (final p in s.parti) p.id};
  final daStorico = storico.any((x) => ids.contains(x.id));
  return (
    storico: [
      for (final x in storico)
        if (!ids.contains(x.id)) x,
    ],
    nascoste: daStorico ? nascoste : {...nascoste, s.id},
    feedback: [
      for (final f in feedback)
        if (!ids.contains(f.idSessione)) f,
    ],
  );
}

/// Le sessioni da mostrare, senza quelle tolte.
List<Sessione> senzaNascoste(List<Sessione> sessioni, Set<String> nascoste) =>
    nascoste.isEmpty
    ? sessioni
    : [
        for (final s in sessioni)
          if (!nascoste.contains(s.id)) s,
      ];
