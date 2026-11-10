import 'csv.dart';
import 'esecuzione.dart';
import 'models.dart';
import 'serie_sessione.dart';

// Gli intervalli di un'attività: ogni tratto di lavoro o di recupero con
// metri, tempo, battito e watt. Dall'orologio (intervals.icu) sono i giri
// segnati col tasto o dall'allenamento sull'orologio, e se combaciano con i
// passi della seduta in programma prendono i loro nomi; dalle sedute
// registrate con l'app sono i blocchi del player, già con nome e sezione.

/// Un tratto dell'attività: lavoro o recupero.
class IntervalloFatto {
  final bool recupero;
  final int inizioS; // secondi dall'inizio dell'attività
  final int secondi;
  final double metri; // 0 se non misurati (recuperi a bordo vasca)
  final int fcMedia; // 0 se manca
  final String nome; // dal passo in programma, se combacia
  final int wattMedi; // 0 se mancano
  final int previstoS; // durata prevista dal passo; 0 se non si sa
  final String fase; // sezione della seduta, se già nota (sedute dell'app)
  const IntervalloFatto({
    required this.recupero,
    required this.inizioS,
    required this.secondi,
    this.metri = 0,
    this.fcMedia = 0,
    this.nome = '',
    this.wattMedi = 0,
    this.previstoS = 0,
    this.fase = '',
  });

  IntervalloFatto copia({
    bool? recupero,
    int? secondi,
    double? metri,
    String? nome,
    int? previstoS,
  }) => IntervalloFatto(
    recupero: recupero ?? this.recupero,
    inizioS: inizioS,
    secondi: secondi ?? this.secondi,
    metri: metri ?? this.metri,
    fcMedia: fcMedia,
    nome: nome ?? this.nome,
    wattMedi: wattMedi,
    previstoS: previstoS ?? this.previstoS,
    fase: fase,
  );

  IntervalloFatto conNome(String n) => copia(nome: n);
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
          wattMedi: _n(x['average_watts']).round(),
        ),
  ];
}

/// Per tenerli sul telefono: una riga per intervallo. Le colonne nuove stanno
/// in fondo (le righe vecchie ne hanno 5) e il nome è l'ultima, perché può
/// contenere virgole.
String intervalliCsv(List<IntervalloFatto> l) => [
  for (final i in l)
    [
      i.recupero ? 'r' : 'l',
      i.inizioS,
      i.secondi,
      i.metri.round(),
      i.fcMedia,
      i.wattMedi,
      i.previstoS,
      i.fase.replaceAll(RegExp(r'[,\n\r]'), ' '),
      i.nome.replaceAll(RegExp(r'[\n\r]'), ' '),
    ].join(','),
].join('\n');

List<IntervalloFatto> intervalliDaCsv(String testo) => [
  for (final riga in testo.split('\n'))
    if (riga.trimRight().split(',') case final c when c.length >= 5)
      IntervalloFatto(
        recupero: c[0] == 'r',
        inizioS: int.tryParse(c[1]) ?? 0,
        secondi: int.tryParse(c[2]) ?? 0,
        metri: double.tryParse(c[3]) ?? 0,
        fcMedia: int.tryParse(c[4]) ?? 0,
        wattMedi: c.length > 5 ? int.tryParse(c[5]) ?? 0 : 0,
        previstoS: c.length > 6 ? int.tryParse(c[6]) ?? 0 : 0,
        fase: c.length > 7 ? c[7] : '',
        nome: c.length > 8 ? c.sublist(8).join(',') : '',
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

/// Il tempo fatto e, se si è staccato di più di 10 secondi da quello
/// previsto (un blocco da 8 minuti chiuso dopo 2), anche quello:
/// "2:00 (previsti 8:00)".
String _tempoConPrevisto(IntervalloFatto i) =>
    i.previstoS > 0 && (i.secondi - i.previstoS).abs() > 10
    ? '${_minSec(i.secondi)} (previsti ${_minSec(i.previstoS)})'
    : _minSec(i.secondi);

/// "200 m · 5:32 · 2:46/100 m · FC 109"; i recuperi "Recupero 0:52". In bici
/// anche i watt medi: "· 210 W".
String rigaIntervallo(IntervalloFatto i, String sport) {
  if (i.recupero) return 'Recupero ${_tempoConPrevisto(i)}';
  final metri = i.metri >= 1000 && !stessoSport(sport, 'Nuoto')
      ? '${(i.metri / 1000).toStringAsFixed(2).replaceAll('.', ',')} km'
      : '${i.metri.round()} m';
  return [
    if (i.metri > 0) metri,
    _tempoConPrevisto(i),
    passoIntervallo(i, sport),
    if (i.wattMedi > 0) '${i.wattMedi} W',
    if (i.fcMedia > 0) 'FC ${i.fcMedia}',
  ].where((x) => x.isNotEmpty).join(' · ');
}

/// File in cui restano gli intervalli di un'attività, già letti.
String fileIntervalli(String idSessione) =>
    'intervalli_${idSessione.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}.csv';

// Intervalli corretti a mano: il nome sbagliato (una ripetuta al posto del
// defaticamento), un tratto in più o in meno. Valgono al posto di quelli
// letti dall'orologio, finché non si torna agli originali.

const intervalliModificatiHeader = [
  'sessione',
  'ordine',
  'recupero',
  'secondi',
  'metri',
  'fc',
  'nome',
  'watt',
  'previsto',
  'fase',
];

/// Le righe di una sessione per intervalli_modificati.csv.
List<List<String>> righeIntervalli(
  String idSessione,
  List<IntervalloFatto> l,
) => [
  for (final (n, i) in l.indexed)
    [
      idSessione,
      '${n + 1}',
      i.recupero ? '1' : '0',
      '${i.secondi}',
      '${i.metri.round()}',
      '${i.fcMedia}',
      i.nome,
      '${i.wattMedi}',
      '${i.previstoS}',
      i.fase,
    ],
];

/// Dal CSV: per ogni sessione i suoi intervalli, in ordine.
Map<String, List<IntervalloFatto>> intervalliModificatiDa(Tabella t) {
  final righe = <String, List<(int, IntervalloFatto)>>{};
  for (final r in t.righe) {
    final id = t.v(r, 'sessione');
    final secondi = int.tryParse(t.v(r, 'secondi')) ?? 0;
    if (id.isEmpty || secondi <= 0) continue;
    (righe[id] ??= []).add((
      int.tryParse(t.v(r, 'ordine')) ?? 0,
      IntervalloFatto(
        recupero: t.v(r, 'recupero') == '1',
        inizioS: 0,
        secondi: secondi,
        metri: double.tryParse(t.v(r, 'metri')) ?? 0,
        fcMedia: int.tryParse(t.v(r, 'fc')) ?? 0,
        nome: t.v(r, 'nome'),
        wattMedi: int.tryParse(t.v(r, 'watt')) ?? 0,
        previstoS: int.tryParse(t.v(r, 'previsto')) ?? 0,
        fase: t.v(r, 'fase'),
      ),
    ));
  }
  return {
    for (final e in righe.entries)
      e.key: [
        for (final x in e.value..sort((a, b) => a.$1.compareTo(b.$1))) x.$2,
      ],
  };
}

/// I nomi dei passi in programma, senza doppioni: da proporre quando si
/// corregge il nome di un tratto.
List<String> nomiDeiPassi(List<WorkoutStep> passi) {
  final ordinati = [...passi]..sort((a, b) => a.ordine.compareTo(b.ordine));
  final visti = <String>{};
  return [
    for (final p in ordinati)
      if (p.descrizione.trim().isNotEmpty && visti.add(p.descrizione.trim()))
        p.descrizione.trim(),
  ];
}

/// "Gambe 2/4" → "Gambe": il nome del passo senza il numero di ripetizione.
String _nomeDelPasso(String nome) =>
    nome.trim().replaceFirst(RegExp(r'\s+\d+/\d+$'), '');

/// La sezione della seduta prevista (riscaldamento, principale…) di ogni
/// tratto, dal nome del passo che porta: così il riepilogo si divide come
/// l'allenamento in programma. Si cerca prima il nome completo della
/// ripetizione ("Stile libero 1/2"), poi quello del passo (i nomi scritti a
/// mano), andando avanti nell'ordine: con due passi dallo stesso nome vale
/// quello che viene dopo. I recuperi stanno nella sezione del tratto prima; i
/// tratti senza nome (fuori programma) restano senza: ''.
List<String> fasiDegliIntervalli(
  List<IntervalloFatto> intervalli,
  List<WorkoutStep> passi,
) {
  final ordinati = [...passi]..sort((a, b) => a.ordine.compareTo(b.ordine));
  // Una voce per ripetizione, come in ripetizioniDelPiano: (completo, passo, fase).
  final voci = [
    for (final p in ordinati)
      for (
        var k = 1, n = (int.tryParse(p.serie.trim()) ?? 1).clamp(1, 100);
        k <= n;
        k++
      )
        (
          n > 1 ? '${p.descrizione.trim()} $k/$n' : p.descrizione.trim(),
          p.descrizione.trim(),
          p.fase.trim(),
        ),
  ];
  var da = 0; // voce a cui si è arrivati
  var ultima = '';
  int? cerca(bool Function((String, String, String)) uguale, int inizio) {
    for (var k = inizio; k < voci.length; k++) {
      if (uguale(voci[k])) return k;
    }
    return null;
  }

  String fase(IntervalloFatto i) {
    final nome = i.nome.trim();
    final passo = _nomeDelPasso(nome);
    bool completo((String, String, String) v) => v.$1 == nome;
    bool delPasso((String, String, String) v) => v.$2 == passo;
    final k =
        cerca(completo, da) ??
        cerca(delPasso, da) ??
        cerca(completo, 0) ??
        cerca(delPasso, 0);
    if (k == null) return '';
    da = k;
    return voci[k].$3;
  }

  return [
    for (final i in intervalli)
      if (i.fase.isNotEmpty)
        ultima = i.fase
      else if (i.recupero)
        ultima
      else
        ultima = i.nome.trim().isEmpty ? '' : fase(i),
  ];
}

/// Un tratto previsto della seduta, per l'abbinamento a tempo.
typedef _Tratto = ({
  String nome,
  bool recupero,
  int secondi, // 0 se si misura a metri
  double metri, // 0 se si misura a tempo
  bool facoltativo, // il recupero dopo l'ultima ripetizione
});

/// Corsa, bici, camminata: i tratti previsti, uno per ripetizione e uno per
/// ogni recupero, come i blocchi del player ("6 × 3 min, rec 2 min").
List<_Tratto> _trattiDelPiano(List<WorkoutStep> passi) {
  final ordinati = [...passi]..sort((a, b) => a.ordine.compareTo(b.ordine));
  final out = <_Tratto>[];
  for (final p in ordinati) {
    final min = double.tryParse(p.durataMin.replaceAll(',', '.')) ?? 0;
    final secondi = (min * 60).round();
    final metri = double.tryParse(p.distanzaM.trim()) ?? 0;
    if (secondi <= 0 && metri <= 0) continue;
    final n = (int.tryParse(p.serie.trim()) ?? 1).clamp(1, 100);
    final rec = int.tryParse(p.recuperoS.trim()) ?? 0;
    for (var k = 1; k <= n; k++) {
      out.add((
        nome: n > 1 ? '${p.descrizione.trim()} $k/$n' : p.descrizione.trim(),
        recupero: false,
        secondi: metri > 0 ? 0 : secondi,
        metri: metri,
        facoltativo: false,
      ));
      // Come nel player: anche dopo l'ultima ripetizione, se c'è un altro
      // passo; quello però può mancare (si riparte subito).
      if (rec > 0 && !(k == n && p == ordinati.last)) {
        out.add((
          nome: '',
          recupero: true,
          secondi: rec,
          metri: 0,
          facoltativo: k == n,
        ));
      }
    }
  }
  return out;
}

/// Un giro fatto corrisponde al tratto previsto: stessa durata (entro 15
/// secondi o il 10%) o stessa distanza (entro 20 metri o il 5%).
bool _combacia(IntervalloFatto f, _Tratto t) {
  if (t.metri > 0) {
    final tolleranza = t.metri * 0.05 < 20 ? 20 : t.metri * 0.05;
    return (f.metri - t.metri).abs() <= tolleranza;
  }
  final tolleranza = t.secondi * 0.1 < 15 ? 15 : t.secondi * 0.1;
  return (f.secondi - t.secondi).abs() <= tolleranza;
}

/// Corsa, bici e camminata dall'orologio (allenamento ricostruito sul Garmin:
/// un giro per passo): ogni giro prende il nome del tratto previsto, in
/// ordine, finché durata o distanza combaciano. Un recupero dopo l'ultima
/// ripetizione si può saltare. Al primo che non torna ci si ferma: meglio
/// nessun nome che un nome sbagliato.
List<IntervalloFatto> conNomiATempo(
  List<IntervalloFatto> fatti,
  List<WorkoutStep> passi,
) {
  final previsti = _trattiDelPiano(passi);
  if (previsti.isEmpty) return fatti;
  final out = <IntervalloFatto>[];
  var j = 0;
  var perso = false;
  for (final f in fatti) {
    if (!perso && j < previsti.length && !_combacia(f, previsti[j])) {
      // Il recupero dopo l'ultima ripetizione può non esserci.
      if (previsti[j].facoltativo &&
          j + 1 < previsti.length &&
          _combacia(f, previsti[j + 1])) {
        j++;
      } else {
        perso = true;
      }
    }
    if (perso || j >= previsti.length) {
      out.add(f);
      continue;
    }
    final t = previsti[j];
    out.add(
      f.copia(
        recupero: t.recupero,
        nome: t.nome,
        previstoS: t.secondi > 0 ? t.secondi : null,
      ),
    );
    j++;
  }
  return out;
}

/// I nomi dei passi in programma, come li si abbina nello sport: a metri nel
/// nuoto (anche un passo in più tratti), a tempo o distanza negli altri.
List<IntervalloFatto> abbinaAlPiano(
  String sport,
  List<IntervalloFatto> fatti,
  List<WorkoutStep> passi,
) => stessoSport(sport, 'Nuoto')
    ? conNomiDelPiano(fatti, passi)
    : conNomiATempo(fatti, passi);

/// Un blocco del player com'è andato: quando è iniziato e finito, quanto è
/// durato davvero (senza le pause) e i metri fatti.
typedef TrattoApp = ({
  int blocco,
  DateTime inizio,
  DateTime fine,
  int secondi,
  double metri,
});

/// La media dei valori tra [da] e [a]; 0 se non ce ne sono.
int _mediaTra(List<Campione> serie, DateTime da, DateTime a) {
  var somma = 0.0;
  var n = 0;
  for (final c in serie) {
    if (c.t.isBefore(da) || !c.t.isBefore(a)) continue;
    somma += c.v;
    n++;
  }
  return n == 0 ? 0 : (somma / n).round();
}

/// Sedute registrate con l'app: ogni blocco fatto diventa un tratto, con il
/// nome, la sezione e il tempo previsto del passo, e battito e watt medi
/// presi dalle serie al secondo. Così nel riepilogo si vede anche un blocco
/// da 8 minuti chiuso dopo 2.
List<IntervalloFatto> intervalliDaTratti(
  List<Blocco> blocchi,
  List<TrattoApp> tratti, {
  List<Campione> fc = const [],
  List<Campione> potenza = const [],
}) {
  if (tratti.isEmpty) return const [];
  final partenza = tratti.first.inizio;
  // Quante ripetizioni ha ogni passo, per "Ripetuta 2/6".
  final ripetizioni = <int, int>{};
  for (final b in blocchi) {
    if (b.tipo == TipoBlocco.lavoro) {
      ripetizioni[b.passo] = (ripetizioni[b.passo] ?? 0) + 1;
    }
  }
  return [
    for (final t in tratti)
      if (t.blocco >= 0 && t.blocco < blocchi.length && t.secondi > 0)
        () {
          final b = blocchi[t.blocco];
          final recupero = b.tipo == TipoBlocco.recupero;
          final n = ripetizioni[b.passo] ?? 1;
          return IntervalloFatto(
            recupero: recupero,
            inizioS: t.inizio.difference(partenza).inSeconds,
            secondi: t.secondi,
            metri: t.metri,
            fcMedia: _mediaTra(fc, t.inizio, t.fine),
            wattMedi: _mediaTra(potenza, t.inizio, t.fine),
            previstoS: b.secondi ?? 0,
            fase: b.fase,
            nome: recupero
                ? ''
                : n > 1
                ? '${b.titolo} ${b.serie}/$n'
                : b.titolo,
          );
        }(),
  ];
}
