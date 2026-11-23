import 'models.dart';
import 'l10n/lingua.dart';

// Modalità allenamento: i passi di un workout diventano blocchi da eseguire uno
// alla volta. Quelli a tempo hanno un conto alla rovescia e passano da soli;
// quelli a ripetizioni o a distanza finiscono quando si tocca "Fatto".

enum TipoBlocco { lavoro, recupero }

class Blocco {
  final TipoBlocco tipo;
  final String titolo; // nome dell'esercizio (o "Recupero")
  final String dettaglio; // "Serie 2 di 3 · 8-10 ripetizioni"
  final String intensita;
  final String obiettivo2; // obiettivo secondario, es. "85-90 rpm"
  final String note;
  final String fase; // riscaldamento, principale, mobilità…
  final String esercizio; // id nel catalogo, per la figura dei muscoli
  final int? secondi; // null: si va avanti toccando "Fatto"
  final int passo; // a quale passo del workout appartiene (da 0)
  final int serie; // numero della serie (da 1)
  final String ripetizioni; // previste: "8-10", "45 s"…
  final double? kg; // dalla scheda del personal trainer, se c'è
  final bool kgPerSerie; // la scheda dà pesi diversi per serie

  /// Metri previsti del blocco ("4 × 50 m" → 50), null se non è a distanza.
  final double? metri;

  /// Il lato degli esercizi a tempo "per lato", divisi in due blocchi:
  /// [latoDestro] o [latoSinistro]; 0 se si fa con tutti e due insieme.
  /// In un recupero, [latoSinistro] è la pausa per girarsi ([cambioLato]).
  final int lato;
  const Blocco({
    required this.tipo,
    required this.titolo,
    this.dettaglio = '',
    this.intensita = '',
    this.obiettivo2 = '',
    this.note = '',
    this.fase = '',
    this.esercizio = '',
    this.secondi,
    required this.passo,
    this.serie = 1,
    this.ripetizioni = '',
    this.kg,
    this.kgPerSerie = false,
    this.metri,
    this.lato = 0,
  });

  bool get aTempo => secondi != null;

  /// La pausa breve tra lato destro e lato sinistro.
  bool get cambioLato => tipo == TipoBlocco.recupero && lato != 0;
}

/// Il titolo di un recupero: "Cambia lato" tra i due lati, se no "Recupero".
String titoloRecupero(Blocco b) =>
    b.cambioLato ? l10n.cambiaLato : l10n.parolaRecupero;

const latoDestro = 1;
const latoSinistro = 2;

/// Secondi per girarsi dall'altro lato, tra i due blocchi di "per lato".
const pausaCambioLato = 5;

// "45 s", e in greco "45 δευτ.": i generatori scrivono nella lingua dell'app.
final _secondi = RegExp(r'^(\d+)\s*(?:s\b|δευτ\.?)(.*)$');

/// "per lato" nelle tre lingue in cui i generatori lo scrivono.
final _perLato = RegExp(r'per lato|per side|ανά πλευρά');

/// Vero se le ripetizioni previste valgono per ogni lato ("10 per lato").
bool perLato(String ripetizioni) => _perLato.hasMatch(ripetizioni);

/// Secondi di un passo a tempo: "10" minuti, oppure ripetizioni come "45 s" o
/// "30 s per lato" (che vale il doppio). Null se è a ripetizioni o distanza.
int? secondiDi(WorkoutStep s) {
  final lato = _secondiPerLato(s);
  if (lato != null) return lato * 2;
  final min = double.tryParse(s.durataMin.replaceAll(',', '.'));
  if (min != null && min > 0) return (min * 60).round();
  final m = _secondi.firstMatch(s.ripetizioni.trim());
  return m == null ? null : int.parse(m.group(1)!);
}

/// I secondi di ogni lato di "30 s per lato"; null se non è a tempo per lato.
int? _secondiPerLato(WorkoutStep s) {
  final min = double.tryParse(s.durataMin.replaceAll(',', '.'));
  if (min != null && min > 0) return null;
  final m = _secondi.firstMatch(s.ripetizioni.trim());
  if (m == null || !perLato(m.group(2)!)) return null;
  return int.parse(m.group(1)!);
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

/// I kg della serie [n] da "20;22,5;25": l'ultimo vale per le serie dopo.
double? kgDellaSerie(String kg, int n) {
  final v = [
    for (final x in kg.split(';'))
      ?double.tryParse(x.trim().replaceAll(',', '.')),
  ];
  return v.isEmpty ? null : v[(n - 1).clamp(0, v.length - 1)];
}

double? _metriPrevisti(String testo) {
  final m = double.tryParse(testo.trim().replaceAll(',', '.'));
  return m != null && m > 0 ? m : null;
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
    final titolo = s.descrizione.isEmpty ? s.nome : s.descrizione;
    // "30 s per lato": due blocchi da 30 s, prima a destra e poi a sinistra,
    // ognuno con il suo conto alla rovescia e la voce che dice il lato, con
    // in mezzo qualche secondo per girarsi.
    final perLatoS = _secondiPerLato(s);
    for (var i = 1; i <= n; i++) {
      Blocco lavoro({int lato = 0}) => Blocco(
        tipo: TipoBlocco.lavoro,
        titolo: titolo,
        dettaglio: [
          // Nell'arrampicata le "serie" di un passo sono le ripetizioni.
          if (n > 1)
            s.sport == 'Arrampicata'
                ? l10n.ripetizione(i, n)
                : l10n.serie(i, n),
          if (lato == latoDestro) l10n.latoDestro,
          if (lato == latoSinistro) l10n.latoSinistro,
          if (lato != 0) '$perLatoS s' else if (quanti.isNotEmpty) quanti,
        ].join(' · '),
        intensita: s.intensita,
        obiettivo2: s.obiettivo2,
        // Il consiglio del passo una volta sola, sul primo lato.
        note: lato == latoSinistro ? '' : s.note,
        fase: s.fase,
        esercizio: s.esercizio,
        secondi: lato != 0 ? perLatoS : secondiDi(s),
        passo: p,
        serie: i,
        ripetizioni: s.ripetizioni,
        kg: kgDellaSerie(s.kg, i),
        kgPerSerie: s.kg.split(';').toSet().length > 1,
        metri: _metriPrevisti(s.distanzaM),
        lato: lato,
      );
      if (perLatoS != null) {
        out
          ..add(lavoro(lato: latoDestro))
          ..add(
            Blocco(
              tipo: TipoBlocco.recupero,
              titolo: 'Cambia lato',
              fase: s.fase,
              secondi: pausaCambioLato,
              passo: p,
              serie: i,
              lato: latoSinistro,
            ),
          )
          ..add(lavoro(lato: latoSinistro));
      } else {
        out.add(lavoro());
      }
      // Recupero tra le serie, e dopo l'ultima se c'è un altro passo.
      final ultimoDelWorkout = i == n && p == ordinati.length - 1;
      if (rec > 0 && !ultimoDelWorkout) {
        out.add(
          Blocco(
            tipo: TipoBlocco.recupero,
            titolo: 'Recupero',
            dettaglio: i < n
                ? s.sport == 'Arrampicata'
                      ? l10n.poiRipetizione(i + 1, n)
                      : l10n.poiSerie(i + 1, n)
                : '',
            note: s.sport == 'Corsa' || s.sport == 'Bici'
                ? l10n.continuaPianoSenzaFermarti
                : l10n.respiraBeviSorsoAcqua,
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

/// Il dettaglio da mostrare durante il blocco: "Serie 2 di 5" resta, "10 min"
/// no, perché nei blocchi a tempo lo dice già il timer.
String dettaglioBreve(Blocco b) => b.dettaglio
    .split(' · ')
    .where(
      (x) =>
          x.isNotEmpty &&
          !(b.aTempo &&
              RegExp(r'^\d+([.,]\d+)?\s*(min\b|s\b|δευτ|λεπ)').hasMatch(x)),
    )
    .join(' · ');

/// "4:05" o "1:02:30".
String fmtTimer(Duration d) {
  final s = d.inSeconds.abs();
  String due(int n) => n.toString().padLeft(2, '0');
  return s >= 3600
      ? '${s ~/ 3600}:${due(s % 3600 ~/ 60)}:${due(s % 60)}'
      : '${s ~/ 60}:${due(s % 60)}';
}
