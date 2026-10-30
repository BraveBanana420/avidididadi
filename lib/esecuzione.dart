import 'models.dart';

// Modalità allenamento: i passi di un workout diventano blocchi da eseguire uno
// alla volta. Quelli a tempo hanno un conto alla rovescia e passano da soli;
// quelli a ripetizioni o a distanza finiscono quando si tocca "Fatto".

enum TipoBlocco { lavoro, recupero }

class Blocco {
  final TipoBlocco tipo;
  final String titolo; // nome dell'esercizio (o "Recupero")
  final String dettaglio; // "Serie 2 di 3 · 8-10 ripetizioni"
  final String intensita;
  final String note;
  final String fase; // riscaldamento, principale, mobilità…
  final String esercizio; // id nel catalogo, per la figura dei muscoli
  final int? secondi; // null: si va avanti toccando "Fatto"
  final int passo; // a quale passo del workout appartiene (da 0)
  final int serie; // numero della serie (da 1)
  final String ripetizioni; // previste: "8-10", "45 s"…
  const Blocco({
    required this.tipo,
    required this.titolo,
    this.dettaglio = '',
    this.intensita = '',
    this.note = '',
    this.fase = '',
    this.esercizio = '',
    this.secondi,
    required this.passo,
    this.serie = 1,
    this.ripetizioni = '',
  });

  bool get aTempo => secondi != null;
}

final _secondi = RegExp(r'^(\d+)\s*s\b(.*)$');

/// Secondi di un passo a tempo: "10" minuti, oppure ripetizioni come "45 s" o
/// "30 s per lato" (che vale il doppio). Null se è a ripetizioni o distanza.
int? secondiDi(WorkoutStep s) {
  final min = double.tryParse(s.durataMin.replaceAll(',', '.'));
  if (min != null && min > 0) return (min * 60).round();
  final m = _secondi.firstMatch(s.ripetizioni.trim());
  if (m == null) return null;
  final v = int.parse(m.group(1)!);
  return m.group(2)!.contains('per lato') ? v * 2 : v;
}

String _quantita(WorkoutStep s) {
  if (s.distanzaM.isNotEmpty) return '${s.distanzaM} m';
  final r = s.ripetizioni.trim();
  if (r.isNotEmpty) {
    if (_secondi.hasMatch(r)) return r;
    return RegExp(r'[a-zA-Z]').hasMatch(r) ? r : '$r ripetizioni';
  }
  final min = s.durataMin.trim();
  return min.isEmpty ? '' : '$min min';
}

/// I blocchi da eseguire, nell'ordine dei passi.
List<Blocco> blocchiDa(List<WorkoutStep> passi) {
  final ordinati = [...passi]..sort((a, b) => a.ordine.compareTo(b.ordine));
  final out = <Blocco>[];
  for (var p = 0; p < ordinati.length; p++) {
    final s = ordinati[p];
    final n = (int.tryParse(s.serie.trim()) ?? 1).clamp(1, 50).toInt();
    final rec = int.tryParse(s.recuperoS.trim()) ?? 0;
    final quanti = _quantita(s);
    final perLato = s.ripetizioni.contains('per lato');
    final titolo = s.descrizione.isEmpty ? s.nome : s.descrizione;
    for (var i = 1; i <= n; i++) {
      out.add(
        Blocco(
          tipo: TipoBlocco.lavoro,
          titolo: titolo,
          dettaglio: [
            if (n > 1) 'Serie $i di $n',
            if (quanti.isNotEmpty) quanti,
          ].join(' · '),
          intensita: s.intensita,
          note: [
            if (perLato && secondiDi(s) != null) 'Cambia lato a metà.',
            s.note,
          ].where((x) => x.isNotEmpty).join(' '),
          fase: s.fase,
          esercizio: s.esercizio,
          secondi: secondiDi(s),
          passo: p,
          serie: i,
          ripetizioni: s.ripetizioni,
        ),
      );
      // Recupero tra le serie, e dopo l'ultima se c'è un altro passo.
      final ultimoDelWorkout = i == n && p == ordinati.length - 1;
      if (rec > 0 && !ultimoDelWorkout) {
        out.add(
          Blocco(
            tipo: TipoBlocco.recupero,
            titolo: 'Recupero',
            dettaglio: i < n ? 'Poi serie ${i + 1} di $n' : '',
            note: s.sport == 'Corsa' || s.sport == 'Bici'
                ? 'Continua piano, senza fermarti.'
                : 'Respira e bevi un sorso d\'acqua.',
            fase: s.fase,
            secondi: rec,
            passo: p,
          ),
        );
      }
    }
  }
  return out;
}

/// "4:05" o "1:02:30".
String fmtTimer(Duration d) {
  final s = d.inSeconds.abs();
  String due(int n) => n.toString().padLeft(2, '0');
  return s >= 3600
      ? '${s ~/ 3600}:${due(s % 3600 ~/ 60)}:${due(s % 60)}'
      : '${s ~/ 60}:${due(s % 60)}';
}
