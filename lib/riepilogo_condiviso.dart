import 'carico.dart';
import 'models.dart';

// I dati delle immagini da condividere (WhatsApp, Instagram…): una sessione
// o la settimana. Qui solo numeri e testi; il disegno è in
// screens/condividi_screen.dart.

/// "1 h 25 min", "45 min".
String fmtDurataBreve(int minuti) {
  if (minuti < 60) return '$minuti min';
  final m = minuti % 60;
  return m == 0 ? '${minuti ~/ 60} h' : '${minuti ~/ 60} h ${two(m)} min';
}

/// La distanza come si dice nello sport: metri nel nuoto, km negli altri.
String fmtDistanza(String sport, double km) => stessoSport(sport, 'Nuoto')
    ? '${(km * 1000).round()} m'
    : '${_virgola(km, km < 100 ? 2 : 1)} km';

/// "10,24", "42,4", "8": decimali con la virgola, senza zeri in fondo.
String _virgola(double v, int decimali) => v
    .toStringAsFixed(decimali)
    .replaceFirst(RegExp(r'\.?0+$'), '')
    .replaceAll('.', ',');

/// I numeri grandi dell'immagine di una sessione: (etichetta, valore, unità).
List<(String, String, String)> numeriSessione(
  Sessione s, {
  double kgTotali = 0,
}) {
  final r = ritmo(s);
  final bici = stessoSport(s.sport, 'Bici');
  return [
    if (s.durataMin >= 60)
      ('Tempo', '${s.durataMin ~/ 60}:${two(s.durataMin % 60)}', 'h')
    else if (s.durataMin > 0)
      ('Tempo', '${s.durataMin}', 'min'),
    if (s.distanzaKm > 0)
      (
        'Distanza',
        fmtDistanza(s.sport, s.distanzaKm).split(' ').first,
        fmtDistanza(s.sport, s.distanzaKm).split(' ').last,
      ),
    if (r != null)
      (bici ? 'Velocità' : 'Passo', fmtRitmo(s.sport, r), unitaRitmo(s.sport)),
    if (s.potenzaMedia > 0) ('Potenza', '${s.potenzaMedia}', 'W'),
    if (s.fcMedia > 0) ('Battito medio', '${s.fcMedia}', 'bpm'),
    if (kgTotali > 0) ('Sollevati', fmtNum(kgTotali.roundToDouble()), 'kg'),
    if (s.calorieAttive > 0) ('Calorie', '${s.calorieAttive.round()}', 'kcal'),
  ];
}

/// Il testo che accompagna l'immagine: "Corsa · 10,2 km in 52 min".
String testoSessione(Sessione s) => [
  titoloSessione(s.sport, s.tipo),
  [
    if (s.distanzaKm > 0) fmtDistanza(s.sport, s.distanzaKm),
    if (s.durataMin > 0) fmtDurataBreve(s.durataMin),
  ].join(' in '),
].where((x) => x.isNotEmpty).join(' · ');

/// Sport fatti in una settimana: quante sedute, minuti e km.
class SportSettimana {
  final String sport;
  final int sedute;
  final int minuti;
  final double km;
  const SportSettimana(this.sport, this.sedute, this.minuti, this.km);
}

/// La settimana da condividere: sedute fatte su previste, tempo, km, gli
/// sport e cosa si è fatto ogni giorno.
class RiepilogoSettimana {
  final DateTime lunedi;
  final int fatte;
  final int previste;
  final int minuti;
  final double km; // senza il nuoto, che si conta in metri
  final List<SportSettimana> perSport; // dal più fatto
  final List<List<String>> perGiorno; // 7 giorni, gli sport fatti
  const RiepilogoSettimana({
    required this.lunedi,
    required this.fatte,
    required this.previste,
    required this.minuti,
    required this.km,
    required this.perSport,
    required this.perGiorno,
  });

  bool get vuota => perSport.isEmpty;
}

RiepilogoSettimana riepilogoSettimana(
  List<PianoRiga> piano,
  List<Sessione> sessioni,
  DateTime lunedi,
  DateTime oggi,
) {
  final c = confrontaSettimana(piano, sessioni, lunedi, oggi);
  final fine = lunedi.add(const Duration(days: 7));
  final svolte = sessioni
      .where((s) => !s.data.isBefore(lunedi) && s.data.isBefore(fine))
      .toList();
  final perSport = <String, SportSettimana>{};
  for (final s in svolte) {
    final p = perSport[s.sport];
    perSport[s.sport] = SportSettimana(
      s.sport,
      (p?.sedute ?? 0) + 1,
      (p?.minuti ?? 0) + s.durataMin,
      (p?.km ?? 0) + s.distanzaKm,
    );
  }
  final ordinati = perSport.values.toList()
    ..sort((a, b) => b.minuti.compareTo(a.minuti));
  return RiepilogoSettimana(
    lunedi: lunedi,
    fatte: c.fatte.length + c.extra.length,
    previste: c.previste,
    minuti: svolte.fold(0, (t, s) => t + s.durataMin),
    km: svolte
        .where((s) => !stessoSport(s.sport, 'Nuoto'))
        .fold(0.0, (t, s) => t + s.distanzaKm),
    perSport: ordinati,
    perGiorno: [
      for (var g = 0; g < 7; g++)
        [
          for (final s in svolte)
            if (soloData(s.data) == lunedi.add(Duration(days: g))) s.sport,
        ],
    ],
  );
}

/// "3 – 9 novembre", "27 ottobre – 2 novembre".
String periodoSettimana(DateTime lunedi) {
  final domenica = lunedi.add(const Duration(days: 6));
  return lunedi.month == domenica.month
      ? '${lunedi.day} – ${domenica.day} ${mesiNomi[domenica.month - 1]}'
      : '${lunedi.day} ${mesiNomi[lunedi.month - 1]} – '
            '${domenica.day} ${mesiNomi[domenica.month - 1]}';
}

/// Il testo che accompagna l'immagine della settimana.
String testoSettimana(RiepilogoSettimana r) => [
  'La mia settimana (${periodoSettimana(r.lunedi)})',
  r.previste > 0 ? '${r.fatte}/${r.previste} sedute' : '${r.fatte} sedute',
  fmtDurataBreve(r.minuti),
  if (r.km >= 1) '${fmtNum(r.km.roundToDouble())} km',
].join(' · ');
