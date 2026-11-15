import 'dart:math' as math;

import 'arrampicata.dart';
import 'attivita.dart';
import 'carico.dart';
import 'intervalli.dart';
import 'models.dart';
import 'percorso.dart';
import 'registro_forza.dart';
import 'serie_sessione.dart';
import 'l10n/lingua.dart';

// I dati delle immagini da condividere (WhatsApp, Instagram…): una sessione
// o la settimana. Qui solo numeri e testi; il disegno è in
// screens/condividi_screen.dart.

/// "1 h 25 min", "45 min".
String fmtDurataBreve(int minuti) {
  if (minuti < 60) return '$minuti min';
  final m = minuti % 60;
  return m == 0 ? '${minuti ~/ 60} h' : l10n.hMin(minuti ~/ 60, two(m));
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
/// [passoNuoto] (secondi ai 100 m, scritto a mano o dai tratti corretti)
/// vale più del passo calcolato sulla durata, che comprende le pause.
List<(String, String, String)> numeriSessione(
  Sessione s, {
  double kgTotali = 0,
  int passoNuoto = 0,
}) {
  final r = passoNuoto > 0 && stessoSport(s.sport, 'Nuoto')
      ? passoNuoto / 60
      : ritmo(s);
  final bici = stessoSport(s.sport, 'Bici');
  return [
    if (s.durataMin >= 60)
      (l10n.tempo, '${s.durataMin ~/ 60}:${two(s.durataMin % 60)}', 'h')
    else if (s.durataMin > 0)
      (l10n.tempo, '${s.durataMin}', 'min'),
    if (s.distanzaKm > 0)
      (
        l10n.distanza,
        fmtDistanza(s.sport, s.distanzaKm).split(' ').first,
        fmtDistanza(s.sport, s.distanzaKm).split(' ').last,
      ),
    if (r != null)
      (
        bici ? l10n.velocita : l10n.passo,
        fmtRitmo(s.sport, r),
        unitaRitmo(s.sport),
      ),
    if (s.potenzaMedia > 0) (l10n.potenza, '${s.potenzaMedia}', 'W'),
    if (s.fcMedia > 0) (l10n.battitoMedio, '${s.fcMedia}', 'bpm'),
    if (kgTotali > 0) (l10n.sollevati, fmtNum(kgTotali.roundToDouble()), 'kg'),
    if (s.calorieAttive > 0)
      (l10n.calorie, '${s.calorieAttive.round()}', 'kcal'),
  ];
}

/// Le grafiche da condividere: tre per ogni sport, più la tua foto.
enum GraficaCondivisa {
  classica,
  mappa,
  poster,
  kmPerKm,
  profilo,
  ripetute,
  esercizi,
  muscoli,
  seduta,
  progressi,
  foto,
}

Map<GraficaCondivisa, String> get nomiGrafiche => {
  GraficaCondivisa.classica: l10n.classica,
  GraficaCondivisa.mappa: l10n.mappa,
  GraficaCondivisa.poster: l10n.poster,
  GraficaCondivisa.kmPerKm: l10n.kmKm,
  GraficaCondivisa.profilo: l10n.salita,
  GraficaCondivisa.ripetute: 'Ripetute',
  GraficaCondivisa.esercizi: l10n.esercizi,
  GraficaCondivisa.muscoli: l10n.muscoli,
  GraficaCondivisa.seduta: l10n.seduta,
  GraficaCondivisa.progressi: l10n.progressi,
  GraficaCondivisa.foto: l10n.tuaFoto,
};

/// Cosa c'è nei dati della sessione: senza, la grafica che ne ha bisogno
/// non si propone.
typedef DatiCondivisi = ({
  bool mappa, // percorso GPS all'aperto
  bool giri, // almeno 2 km dal GPS
  bool quota, // altitudine dall'orologio
  bool ripetute, // almeno 2 tratti di nuoto con metri e tempo
  bool esercizi, // esercizi scritti (forza) o blocchi (mobilità)
  bool muscoli, // esercizi del catalogo con i muscoli
  bool arrampicata, // la scheda della seduta di arrampicata
});

/// Le grafiche di uno sport, nell'ordine: le tre sue (la classica al posto
/// di quelle senza dati, una volta sola), poi la tua foto.
List<GraficaCondivisa> grafichePer(String sport, DatiCondivisi d) {
  const g = GraficaCondivisa.values;
  final desiderate = switch (sport.trim().toLowerCase()) {
    'bici' => [g[0], if (d.mappa) GraficaCondivisa.mappa, g[2]],
    'corsa' => [
      if (d.mappa) GraficaCondivisa.mappa,
      if (d.giri) GraficaCondivisa.kmPerKm,
      GraficaCondivisa.poster,
    ],
    'camminata' => [
      if (d.mappa) GraficaCondivisa.mappa,
      if (d.quota) GraficaCondivisa.profilo,
      GraficaCondivisa.poster,
    ],
    'nuoto' => [
      if (d.ripetute) GraficaCondivisa.ripetute,
      GraficaCondivisa.poster,
    ],
    'forza' => [
      if (d.esercizi) GraficaCondivisa.esercizi,
      if (d.muscoli) GraficaCondivisa.muscoli,
      GraficaCondivisa.poster,
    ],
    'mobilità' => [
      if (d.esercizi) GraficaCondivisa.esercizi,
      GraficaCondivisa.poster,
    ],
    'arrampicata' => [
      if (d.arrampicata) GraficaCondivisa.seduta,
      if (d.arrampicata) GraficaCondivisa.progressi,
      GraficaCondivisa.poster,
    ],
    _ => [g[0], if (d.mappa) GraficaCondivisa.mappa, g[2]],
  };
  final tre = [
    if (!desiderate.contains(GraficaCondivisa.classica) &&
        desiderate.length < 3)
      GraficaCondivisa.classica,
    ...desiderate,
  ];
  return [...tre, GraficaCondivisa.foto];
}

/// I tempi di ogni chilometro intero, in secondi, dal percorso GPS. I buchi
/// di più di un minuto tra due punti sono pause: i metri contano, il tempo no.
List<int> tempiPerKm(Percorso p) {
  final out = <int>[];
  var metri = 0.0, secondi = 0.0;
  for (var i = 1; i < p.punti.length; i++) {
    final a = p.punti[i - 1], b = p.punti[i];
    final d = distanzaM(a, b);
    final t = b.t.difference(a.t).inMilliseconds / 1000;
    final tempo = t > 60 ? 0.0 : t;
    if (metri + d >= 1000 && d > 0) {
      // Il chilometro finisce dentro questo tratto: si divide in proporzione.
      final parte = (1000 - metri) / d;
      out.add((secondi + tempo * parte).round());
      metri = d * (1 - parte);
      secondi = tempo * (1 - parte);
    } else {
      metri += d;
      secondi += tempo;
    }
  }
  return out;
}

/// Le righe "km per km": una per chilometro fino a 15, oltre si raggruppano
/// (2 km per riga, poi 3…) con il passo medio. (etichetta, secondi al km).
List<(String, int)> righeKm(List<int> tempi) {
  if (tempi.isEmpty) return const [];
  final passo = (tempi.length / 15).ceil();
  return [
    for (var i = 0; i < tempi.length; i += passo)
      () {
        final pezzo = tempi.sublist(i, math.min(i + passo, tempi.length));
        final media = pezzo.fold(0, (a, b) => a + b) / pezzo.length;
        final etichetta = pezzo.length == 1
            ? '${i + 1}'
            : '${i + 1}-${i + pezzo.length}';
        return (etichetta, media.round());
      }(),
  ];
}

/// I metri di salita dalla quota: si ammorbidisce prima (150 punti), così
/// il rumore del GPS e del barometro non gonfia il totale.
int salitaTotale(List<Campione> quota) {
  final r = ricampiona(quota, punti: 150);
  var su = 0.0;
  for (var i = 1; i < r.length; i++) {
    final d = r[i].v - r[i - 1].v;
    if (d > 0) su += d;
  }
  return su.round();
}

/// Nuoto: il passo ai 100 m di ogni tratto nuotato (secondi), saltando
/// recuperi e tratti senza metri.
List<int> passiRipetute(List<IntervalloFatto> tratti) => [
  for (final i in tratti)
    if (!i.recupero && i.metri >= 25 && i.secondi > 0)
      (i.secondi / i.metri * 100).round(),
];

/// Mobilità registrata con l'app: un esercizio per riga con il tempo fatto,
/// le serie dello stesso esercizio ("Piccione 1/2", "Piccione 2/2") unite.
List<(String, int)> eserciziDaTratti(List<IntervalloFatto> tratti) {
  final tempi = <String, int>{};
  for (final i in tratti) {
    if (i.recupero || i.nome.isEmpty || i.secondi <= 0) continue;
    final nome = i.nome.replaceFirst(RegExp(r' \d+/\d+$'), '');
    tempi[nome] = (tempi[nome] ?? 0) + i.secondi;
  }
  return [for (final e in tempi.entries) (e.key, e.value)];
}

/// Forza: il record battuto oggi, "Squat 60 kg (prima 55 kg)". Null se oggi
/// nessun esercizio supera i kg di tutte le volte prima.
String? recordDelGiorno(List<SerieFatta> tutte, DateTime giorno) {
  final d = soloData(giorno);
  String? migliore;
  var salto = 0.0;
  final oggi = tutte.where((s) => s.data == d && s.kg > 0);
  for (final chiave in {for (final s in oggi) s.chiave}) {
    final mie = oggi.where((s) => s.chiave == chiave);
    final prima = tutte.where(
      (s) => s.chiave == chiave && s.data.isBefore(d) && s.kg > 0,
    );
    if (prima.isEmpty) continue;
    final kgOggi = mie.map((s) => s.kg).reduce(math.max);
    final kgPrima = prima.map((s) => s.kg).reduce(math.max);
    if (kgOggi > kgPrima && kgOggi - kgPrima > salto) {
      salto = kgOggi - kgPrima;
      migliore = l10n.kgPrimaKg(mie.first.nome, fmtKg(kgOggi), fmtKg(kgPrima));
    }
  }
  return migliore;
}

/// Arrampicata: il grado più alto delle ultime sedute della stessa
/// disciplina, fino a quella di oggi compresa. (grado, livello, è oggi).
List<(String, int, bool)> progressiArrampicata(
  List<SedutaArrampicata> tutte,
  SedutaArrampicata oggi, {
  int quante = 8,
}) {
  final mie =
      tutte
          .where(
            (a) =>
                a.disciplina == oggi.disciplina &&
                a.gradoMax.isNotEmpty &&
                !a.data.isAfter(oggi.data),
          )
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));
  final ultime = mie.length > quante ? mie.sublist(mie.length - quante) : mie;
  return [
    for (final a in ultime)
      (
        a.gradoMax,
        livello(a.disciplina, a.gradoMax),
        a.idSessione == oggi.idSessione,
      ),
  ];
}

/// Il poster: la scritta in alto, il numero gigante, cosa vuol dire e i tre
/// numeri sotto. Forza: i kg sollevati; arrampicata: il grado più alto;
/// altra attività: il nome; gli altri la distanza o il tempo.
typedef DatiPoster = ({
  String etichetta,
  String grande,
  String sotto,
  List<(String, String, String)> numeri,
});

DatiPoster posterDi(
  Sessione s, {
  double kgTotali = 0,
  SedutaArrampicata? arrampicata,
  int passoNuoto = 0,
}) {
  final etichetta = titoloSessione(
    s.sport,
    s.tipo,
  ).replaceAll(': ', ' · ').toUpperCase();
  final tempo = s.durataMin >= 60
      ? (
          l10n.tempo,
          '${s.durataMin ~/ 60}:${two(s.durataMin % 60)}',
          l10n.parolaOre,
        )
      : (l10n.tempo, '${s.durataMin}', 'min');
  List<(String, String, String)> senza(String nome) => [
    for (final n in numeriSessione(
      s,
      kgTotali: kgTotali,
      passoNuoto: passoNuoto,
    ))
      if (n.$1 != nome) n,
  ].take(3).toList();
  if (stessoSport(s.sport, 'Forza') && kgTotali > 0) {
    return (
      etichetta: etichetta,
      grande: fmtNum(kgTotali.roundToDouble()),
      sotto: l10n.kgSollevatiTutto,
      numeri: senza(l10n.sollevati),
    );
  }
  if (arrampicata case final a? when a.gradoMax.isNotEmpty) {
    return (
      etichetta: [
        l10n.arrampicata,
        a.ambiente == Ambiente.indoor ? l10n.indoor : l10n.outdoor,
      ].join(' · '),
      grande: a.gradoMax,
      sotto: [
        l10n.gradoPiuAltoOggi,
        if (a.stile.isNotEmpty) a.stile.toLowerCase(),
      ].join(' · '),
      numeri: [
        if (a.chiuse > 0) (a.falesia ? 'Vie' : l10n.blocchi, '${a.chiuse}', ''),
        if (a.metri > 0) (l10n.saliti, '${a.metri}', 'm'),
        if (s.durataMin > 0) tempo,
      ].take(3).toList(),
    );
  }
  if (stessoSport(s.sport, sportAttivitaLibera)) {
    final nome = s.tipo.isEmpty || s.tipo == 'Altra attività'
        ? l10n.attivita
        : s.tipo;
    return (
      etichetta: l10n.altraAttivita,
      grande: nome.toUpperCase(),
      sotto: s.durataMin >= 60 ? '${tempo.$2} ore' : '${s.durataMin} minuti',
      numeri: senza(l10n.tempo),
    );
  }
  final (grande, sotto) = numeroGrande(s);
  return (
    etichetta: etichetta,
    grande: grande,
    sotto: sotto,
    numeri: numeriPoster(s),
  );
}

/// Il numero gigante del poster: la distanza se c'è (metri nel nuoto),
/// altrimenti il tempo. (valore, sotto) es. ("42,2", "km"), ("1:02", "ore").
(String, String) numeroGrande(Sessione s) {
  if (s.distanzaKm > 0) {
    final d = fmtDistanza(s.sport, s.distanzaKm).split(' ');
    return (d.first, d.last);
  }
  if (s.durataMin >= 60) {
    return ('${s.durataMin ~/ 60}:${two(s.durataMin % 60)}', l10n.parolaOre);
  }
  return ('${s.durataMin}', l10n.parolaMinuti);
}

/// I numeri piccoli sotto il poster: quelli della sessione senza quello già
/// in grande, al massimo tre.
List<(String, String, String)> numeriPoster(Sessione s) {
  final grande = s.distanzaKm > 0 ? l10n.distanza : l10n.tempo;
  return [
    for (final n in numeriSessione(s))
      if (n.$1 != grande) n,
  ].take(3).toList();
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
  l10n.miaSettimana(periodoSettimana(r.lunedi)),
  r.previste > 0 ? l10n.sedute(r.fatte, r.previste) : '${r.fatte} sedute',
  fmtDurataBreve(r.minuti),
  if (r.km >= 1) '${fmtNum(r.km.roundToDouble())} km',
].join(' · ');
