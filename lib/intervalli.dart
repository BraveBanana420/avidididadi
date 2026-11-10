import 'models.dart';

// Gli intervalli di un'attività dell'orologio (da intervals.icu): ogni tratto
// di lavoro o di recupero con metri, tempo e battito. Nel nuoto sono quelli
// segnati col tasto del giro o col "registro allenamento" di Garmin; se
// combaciano con i passi della seduta in programma prendono i loro nomi.

/// Un tratto dell'attività: lavoro o recupero.
class IntervalloFatto {
  final bool recupero;
  final int inizioS; // secondi dall'inizio dell'attività
  final int secondi;
  final double metri; // 0 se non misurati (recuperi a bordo vasca)
  final int fcMedia; // 0 se manca
  final String nome; // dal passo in programma, se combacia
  const IntervalloFatto({
    required this.recupero,
    required this.inizioS,
    required this.secondi,
    this.metri = 0,
    this.fcMedia = 0,
    this.nome = '',
  });

  IntervalloFatto conNome(String n) => IntervalloFatto(
    recupero: recupero,
    inizioS: inizioS,
    secondi: secondi,
    metri: metri,
    fcMedia: fcMedia,
    nome: n,
  );
}

num _n(Object? v) => v is num ? v : 0;

/// Dalla risposta di intervals.icu (`/activity/{id}/intervals`). Gli
/// intervalli senza tempo si saltano.
List<IntervalloFatto> intervalliDaIcu(Object? risposta) {
  final lista = risposta is Map ? risposta['icu_intervals'] : null;
  if (lista is! List) return const [];
  return [
    for (final x in lista)
      if (x is Map && _n(x['elapsed_time'] ?? x['moving_time']) > 0)
        IntervalloFatto(
          recupero: '${x['type']}'.toUpperCase() == 'RECOVERY',
          inizioS: _n(x['start_time']).round(),
          secondi: _n(x['elapsed_time'] ?? x['moving_time']).round(),
          metri: _n(x['distance']).toDouble(),
          fcMedia: _n(x['average_heartrate']).round(),
        ),
  ];
}

/// Per tenerli sul telefono: una riga per intervallo.
String intervalliCsv(List<IntervalloFatto> l) => [
  for (final i in l)
    [
      i.recupero ? 'r' : 'l',
      i.inizioS,
      i.secondi,
      i.metri.round(),
      i.fcMedia,
    ].join(','),
].join('\n');

List<IntervalloFatto> intervalliDaCsv(String testo) => [
  for (final riga in testo.split('\n'))
    if (riga.split(',') case final c when c.length >= 5)
      IntervalloFatto(
        recupero: c[0] == 'r',
        inizioS: int.tryParse(c[1]) ?? 0,
        secondi: int.tryParse(c[2]) ?? 0,
        metri: double.tryParse(c[3]) ?? 0,
        fcMedia: int.tryParse(c[4]) ?? 0,
      ),
];

/// I passi in programma, una voce per ogni ripetizione: (nome, metri).
/// "4 × 50 m Gambe" diventa quattro voci "Gambe 1/4"… da 50 m.
List<(String, double)> ripetizioniDelPiano(List<WorkoutStep> passi) {
  final ordinati = [...passi]..sort((a, b) => a.ordine.compareTo(b.ordine));
  return [
    for (final p in ordinati)
      if ((double.tryParse(p.distanzaM.trim()) ?? 0) > 0)
        for (
          var k = 1, n = (int.tryParse(p.serie.trim()) ?? 1).clamp(1, 100);
          k <= n;
          k++
        )
          (
            n > 1 ? '${p.descrizione} $k/$n' : p.descrizione,
            double.parse(p.distanzaM.trim()),
          ),
  ];
}

/// Dà agli intervalli di lavoro i nomi dei passi in programma, in ordine,
/// finché i metri combaciano (anche un passo fatto in più tratti: 200 m
/// segnati come 2 × 100). Al primo che non torna ci si ferma: meglio nessun
/// nome che un nome sbagliato.
List<IntervalloFatto> conNomiDelPiano(
  List<IntervalloFatto> fatti,
  List<WorkoutStep> passi,
) {
  final previste = ripetizioniDelPiano(passi);
  if (previste.isEmpty) return fatti;
  final out = <IntervalloFatto>[];
  var j = 0; // ripetizione prevista a cui si è arrivati
  var mancano = previste.first.$2; // metri che le restano
  var perso = false;
  for (final f in fatti) {
    if (f.recupero || perso || j >= previste.length || f.metri <= 0) {
      out.add(f);
      continue;
    }
    if (f.metri > mancano + 1) {
      perso = true;
      out.add(f);
      continue;
    }
    out.add(f.conNome(previste[j].$1));
    mancano -= f.metri;
    if (mancano <= 1) {
      j++;
      if (j < previste.length) mancano = previste[j].$2;
    }
  }
  return out;
}

String _minSec(num secondi) {
  final s = secondi.round();
  return '${s ~/ 60}:${two(s % 60)}';
}

/// Il passo di un tratto come lo vuole lo sport: "2:46/100 m" nel nuoto,
/// "24,3 km/h" in bici, "5:42/km" negli altri. Vuoto se mancano i metri.
String passoIntervallo(IntervalloFatto i, String sport) {
  if (i.metri <= 0 || i.secondi <= 0) return '';
  if (stessoSport(sport, 'Nuoto')) {
    return '${_minSec(i.secondi / i.metri * 100)}/100 m';
  }
  if (stessoSport(sport, 'Bici')) {
    final kmh = (i.metri / i.secondi * 3.6).toStringAsFixed(1);
    return '${kmh.replaceAll('.', ',')} km/h';
  }
  return '${_minSec(i.secondi / i.metri * 1000)}/km';
}

/// "200 m · 5:32 · 2:46/100 m · FC 109"; i recuperi "Recupero 0:52".
String rigaIntervallo(IntervalloFatto i, String sport) {
  if (i.recupero) return 'Recupero ${_minSec(i.secondi)}';
  final metri = i.metri >= 1000 && !stessoSport(sport, 'Nuoto')
      ? '${(i.metri / 1000).toStringAsFixed(2).replaceAll('.', ',')} km'
      : '${i.metri.round()} m';
  return [
    if (i.metri > 0) metri,
    _minSec(i.secondi),
    passoIntervallo(i, sport),
    if (i.fcMedia > 0) 'FC ${i.fcMedia}',
  ].where((x) => x.isNotEmpty).join(' · ');
}

/// File in cui restano gli intervalli di un'attività, già letti.
String fileIntervalli(String idSessione) =>
    'intervalli_${idSessione.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}.csv';
