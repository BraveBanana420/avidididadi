import 'dart:math' as math;

import 'csv.dart';
import 'attivita.dart';
import 'models.dart';

/// Logica della sincronizzazione con Health Connect, senza dipendere dal plugin:
/// abbinamento dei tipi, metriche nella finestra della sessione e doppioni.

const pacchettoGarmin = 'com.garmin.android.apps.connectmobile';

/// Versione delle regole di abbinamento: quando cambia, la sincronizzazione
/// rilegge tutto lo storico, così le sessioni prima ignorate vengono recuperate.
/// 2: "OTHER" di Garmin come Forza e titoli delle sessioni.
/// 3: nuovo tentativo di lettura dei titoli.
const versioneRegole = 5; // 5: camminata e attività libere

bool _daFreeletics(String pacchetto) =>
    pacchetto.toLowerCase().contains('freeletics');

bool daFreeletics(Sessione s) => _daFreeletics(s.origine);

const _titoliGenerici = {
  'riscaldamento',
  'intervallo',
  'intervalli',
  'defaticamento',
  'warm up',
  'warm-up',
  'warmup',
  'cool down',
  'cooldown',
  'recupero',
  'pausa',
  'hiit',
};

/// Nome dell'allenamento Freeletics dai titoli dei blocchi, senza quelli
/// generici (riscaldamento, intervallo, defaticamento). Null se non ce ne sono.
String? nomeFreeletics(Iterable<String> titoli) {
  final nomi = <String>[];
  for (final t in titoli.map((x) => x.trim())) {
    if (t.isEmpty || _titoliGenerici.contains(t.toLowerCase())) continue;
    if (!nomi.contains(t)) nomi.add(t);
  }
  return nomi.isEmpty ? null : nomi.join(' · ');
}

/// Nome leggibile dell'app di origine.
String nomeFonte(String pacchetto, String nome) {
  final p = pacchetto.toLowerCase();
  if (p == pacchettoGarmin || p.contains('garmin')) return 'Garmin';
  if (_daFreeletics(p)) return 'Freeletics';
  return nome.isNotEmpty ? nome : pacchetto;
}

/// Tipo di attività di Health Connect -> (sport, tipo di sessione) dell'app.
/// Quello che non è uno sport noto diventa un'attività libera.
(String, String)? mappaAttivita(String tipoHc, {String pacchetto = ''}) {
  final m = switch (tipoHc) {
    'RUNNING' => ('Corsa', 'Corsa'),
    'RUNNING_TREADMILL' => ('Corsa', 'Tapis roulant'),
    'BIKING' => ('Bici', 'Uscita'),
    'BIKING_STATIONARY' => ('Bici', 'Cyclette'),
    'SWIMMING_POOL' => ('Nuoto', 'Piscina'),
    'SWIMMING_OPEN_WATER' => ('Nuoto', 'Acque libere'),
    'SWIMMING' => ('Nuoto', ''),
    'STRENGTH_TRAINING' || 'WEIGHTLIFTING' => ('Forza', 'Pesi'),
    'HIGH_INTENSITY_INTERVAL_TRAINING' => ('Forza', 'HIIT'),
    'CALISTHENICS' => ('Forza', 'Corpo libero'),
    'YOGA' => ('Mobilità', 'Yoga'),
    'PILATES' => ('Mobilità', 'Pilates'),
    'FLEXIBILITY' || 'STRETCHING' => ('Mobilità', 'Stretching'),
    'ROCK_CLIMBING' || 'CLIMBING' => ('Arrampicata', 'Arrampicata'),
    _ => null,
  };
  if (m != null) return m;
  // Freeletics fa solo forza, anche quando scrive un tipo generico.
  if (_daFreeletics(pacchetto)) return ('Forza', '');
  // Il "Cardio indoor" di Garmin arriva come OTHER: sono gli allenamenti di forza.
  if (tipoHc == 'OTHER' && pacchetto.toLowerCase().contains('garmin')) {
    return ('Forza', 'Cardio');
  }
  return attivitaDaNome(tipoHc);
}

/// Tipo di corsa ricavato dal titolo scritto dall'app (es. "Milano - Fartlek FC").
String tipoDaTitolo(String sport, String tipo, String titolo) {
  if (sport != 'Corsa') return tipo;
  final t = titolo.toLowerCase();
  if (t.contains('fartlek')) return 'Fartlek';
  if (t.contains('tempo')) return 'Tempo run';
  if (t.contains('lungo')) return 'Lungo';
  if (t.contains('lento')) return 'Lento';
  return tipo;
}

/// Una sessione di Health Connect, già semplificata.
class RecordHc {
  final String uuid;
  final String tipo; // nome del tipo di attività di Health Connect
  final String pacchetto;
  final String nomeFonte;
  final DateTime inizio;
  final DateTime fine;
  final double? distanzaM; // totali della sessione, se l'app li ha scritti
  final double? calorie;
  final int? passi;
  final String titolo; // nome dato dall'app, es. "Milano - Fartlek FC"
  const RecordHc({
    required this.uuid,
    required this.tipo,
    required this.pacchetto,
    required this.nomeFonte,
    required this.inizio,
    required this.fine,
    this.distanzaM,
    this.calorie,
    this.passi,
    this.titolo = '',
  });

  RecordHc conTitolo(String t) => RecordHc(
    uuid: uuid,
    tipo: tipo,
    pacchetto: pacchetto,
    nomeFonte: nomeFonte,
    inizio: inizio,
    fine: fine,
    distanzaM: distanzaM,
    calorie: calorie,
    passi: passi,
    titolo: t,
  );
}

/// Un valore di una metrica in un intervallo (uguale a [da] per i campioni istantanei).
class CampioneHc {
  final DateTime da;
  final DateTime a;
  final double valore;
  const CampioneHc(this.da, this.a, this.valore);
}

/// Le metriche lette nella finestra di una sessione, da qualunque app.
class MetricheHc {
  final List<CampioneHc> fc;
  final List<CampioneHc> distanza; // metri
  final List<CampioneHc> calorieAttive;
  final List<CampioneHc> calorieTotali;
  final List<CampioneHc> passi;
  const MetricheHc({
    this.fc = const [],
    this.distanza = const [],
    this.calorieAttive = const [],
    this.calorieTotali = const [],
    this.passi = const [],
  });
}

/// Quota di un campione che cade nella finestra [da, a]: un intervallo a metà
/// conta per metà, un campione istantaneo conta se è dentro.
double _quota(CampioneHc c, DateTime da, DateTime a) {
  final durata = c.a.difference(c.da).inMilliseconds;
  if (durata <= 0) return !c.da.isBefore(da) && !c.da.isAfter(a) ? 1 : 0;
  final inizio = c.da.isAfter(da) ? c.da : da;
  final fine = c.a.isBefore(a) ? c.a : a;
  final dentro = fine.difference(inizio).inMilliseconds;
  return dentro <= 0 ? 0 : dentro / durata;
}

double _somma(List<CampioneHc> c, DateTime da, DateTime a) =>
    c.fold(0.0, (t, x) => t + x.valore * _quota(x, da, a));

/// Converte un record in una sessione dell'app, con le metriche aggregate nella
/// sua finestra. Null se il tipo di attività non interessa.
Sessione? sessioneDa(RecordHc r, MetricheHc m) {
  final sport = mappaAttivita(r.tipo, pacchetto: r.pacchetto);
  if (sport == null) return null;
  final fc = [
    for (final c in m.fc)
      if (_quota(c, r.inizio, r.fine) > 0) c.valore,
  ];
  final metri = (r.distanzaM ?? 0) > 0
      ? r.distanzaM!
      : _somma(m.distanza, r.inizio, r.fine);
  final totali = (r.calorie ?? 0) > 0
      ? r.calorie!
      : _somma(m.calorieTotali, r.inizio, r.fine);
  final passi = (r.passi ?? 0) > 0
      ? r.passi!
      : _somma(m.passi, r.inizio, r.fine).round();
  return Sessione(
    id: 'hc-${r.uuid}',
    data: soloData(r.inizio),
    sport: sport.$1,
    tipo: tipoDaTitolo(sport.$1, sport.$2, r.titolo),
    note: r.titolo,
    durataMin: (r.fine.difference(r.inizio).inSeconds / 60).round(),
    distanzaKm: (metri / 10).round() / 100,
    fcMedia: fc.isEmpty ? 0 : (fc.reduce((a, b) => a + b) / fc.length).round(),
    fcMax: fc.isEmpty ? 0 : fc.reduce(math.max).round(),
    calorieAttive: _somma(m.calorieAttive, r.inizio, r.fine).roundToDouble(),
    calorieTotali: totali.roundToDouble(),
    passi: passi,
    fonte: r.nomeFonte,
    origine: r.pacchetto,
    inizio: r.inizio,
    fine: r.fine,
  );
}

/// Applica alle sessioni di Health Connect già salvate quelle nuove o modificate
/// (sostituite per id) e toglie quelle cancellate ([cancellati]: uuid dei record).
List<Sessione> applicaModifiche(
  List<Sessione> salvate, {
  List<Sessione> aggiornate = const [],
  Set<String> cancellati = const {},
}) {
  final perId = {for (final s in salvate) s.id: s};
  for (final uuid in cancellati) {
    perId.remove('hc-$uuid');
  }
  for (final s in aggiornate) {
    perId[s.id] = s;
  }
  return _inOrdine(perId.values);
}

List<Sessione> _inOrdine(Iterable<Sessione> s) =>
    s.toList()
      ..sort((a, b) => (a.inizio ?? a.data).compareTo(b.inizio ?? b.data));

/// Registrazioni dello stesso sport separate da meno di così sono un unico
/// allenamento (blocchi di Freeletics, ripartenza dopo un crash dell'orologio).
const margineUnione = Duration(minutes: 10);

/// Si sovrappongono almeno per metà della più breve: è la stessa cosa registrata
/// due volte (doppione), non due pezzi in sequenza.
bool _sovrapposte(Sessione a, Sessione b) {
  final ia = a.inizio, fa = a.fine, ib = b.inizio, fb = b.fine;
  if (ia == null || fa == null || ib == null || fb == null) return false;
  final inizio = ia.isAfter(ib) ? ia : ib;
  final fine = fa.isBefore(fb) ? fa : fb;
  final comune = fine.difference(inizio).inSeconds;
  final piuBreve = math.min(
    fa.difference(ia).inSeconds,
    fb.difference(ib).inSeconds,
  );
  return piuBreve > 0 && comune >= piuBreve / 2;
}

int _datiPresenti(Sessione s) => [
  s.distanzaKm,
  s.fcMedia,
  s.fcMax,
  s.calorieAttive,
  s.calorieTotali,
  s.passi,
].where((v) => v > 0).length;

/// Di due doppioni resta il più completo, con i dati mancanti presi dall'altro.
Sessione _piuCompleta(Sessione a, Sessione b) {
  final x = _datiPresenti(b) > _datiPresenti(a) ? b : a;
  final y = identical(x, a) ? b : a;
  T o<T extends num>(T mio, T suo) => mio > 0 ? mio : suo;
  return x.copyWith(
    distanzaKm: o(x.distanzaKm, y.distanzaKm),
    fcMedia: o(x.fcMedia, y.fcMedia),
    fcMax: o(x.fcMax, y.fcMax),
    calorieAttive: o(x.calorieAttive, y.calorieAttive),
    calorieTotali: o(x.calorieTotali, y.calorieTotali),
    passi: o(x.passi, y.passi),
  );
}

List<Sessione> _senzaDoppioni(List<Sessione> s) {
  final out = <Sessione>[];
  for (final x in s) {
    final i = out.indexWhere((o) => _sovrapposte(o, x));
    if (i < 0) {
      out.add(x);
    } else {
      out[i] = _piuCompleta(out[i], x);
    }
  }
  return out;
}

/// Un gruppo di registrazioni dello stesso allenamento diventa una sessione:
/// - i pezzi in sequenza si sommano (durata, distanza, calorie);
/// - i doppioni sovrapposti contano una volta sola;
/// - se c'è Freeletics, i pezzi sono i suoi blocchi (nome e tipo), mentre FC e
///   calorie vengono dall'orologio. La fonte mostrata è solo quella dei pezzi.
Sessione _unisciGruppo(List<Sessione> g) {
  if (g.length == 1) {
    final s = g.first;
    final nome = _daFreeletics(s.origine) ? nomeFreeletics([s.note]) : null;
    return nome == null ? s : s.copyWith(tipo: nome);
  }
  final freeletics = g.where((s) => _daFreeletics(s.origine)).toList();
  final parti = _senzaDoppioni(freeletics.isNotEmpty ? freeletics : g);
  final orologio = freeletics.isNotEmpty
      ? _senzaDoppioni(g.where((s) => !_daFreeletics(s.origine)).toList())
      : <Sessione>[];
  final metriche = orologio.isNotEmpty ? orologio : parti;

  final conFc = metriche.where((s) => s.fcMedia > 0 && s.durataMin > 0);
  final minutiFc = conFc.fold(0, (t, s) => t + s.durataMin);
  final tipi = <String, int>{};
  for (final s in parti.where((s) => s.tipo.isNotEmpty)) {
    tipi[s.tipo] = (tipi[s.tipo] ?? 0) + s.durataMin;
  }
  final primo = parti.first;
  return Sessione(
    id: primo.id,
    data: primo.data,
    sport: primo.sport,
    // Freeletics: il nome dei blocchi veri (es. "5/10 PANDORA"), non "HIIT".
    tipo:
        (freeletics.isEmpty
            ? null
            : nomeFreeletics(parti.map((s) => s.note))) ??
        (tipi.isEmpty
            ? primo.tipo
            : (tipi.entries.toList()..sort((a, b) => b.value - a.value))
                  .first
                  .key),
    durataMin: parti.fold(0, (t, s) => t + s.durataMin),
    distanzaKm:
        (parti.fold(0.0, (t, s) => t + s.distanzaKm) * 100).round() / 100,
    fcMedia: minutiFc == 0
        ? 0
        : (conFc.fold(0, (t, s) => t + s.fcMedia * s.durataMin) / minutiFc)
              .round(),
    fcMax: g.fold(0, (t, s) => math.max(t, s.fcMax)),
    calorieAttive: metriche.fold(0.0, (t, s) => t + s.calorieAttive),
    calorieTotali: metriche.fold(0.0, (t, s) => t + s.calorieTotali),
    passi: metriche.fold(0, (t, s) => t + s.passi),
    rpe: primo.rpe,
    fonte: primo.fonte,
    origine: primo.origine,
    note: primo.note,
    inizio: parti.map((s) => s.inizio!).reduce((a, b) => a.isBefore(b) ? a : b),
    fine: parti.map((s) => s.fine!).reduce((a, b) => a.isAfter(b) ? a : b),
    parti: parti.length > 1 ? parti : const [],
  );
}

/// Sessioni di Health Connect con le registrazioni dello stesso allenamento
/// (stesso sport, sovrapposte o a meno di [margineUnione]) riunite in una.
List<Sessione> raggruppa(List<Sessione> hc) {
  final gruppi = <List<Sessione>>[];
  for (final s in _inOrdine(hc)) {
    final i = s.inizio == null
        ? -1
        : gruppi.lastIndexWhere((g) {
            if (!stessoSport(g.first.sport, s.sport)) return false;
            final fine = g
                .map((x) => x.fine)
                .whereType<DateTime>()
                .fold<DateTime?>(
                  null,
                  (a, b) => a == null || b.isAfter(a) ? b : a,
                );
            return fine != null && !s.inizio!.isAfter(fine.add(margineUnione));
          });
    if (i < 0) {
      gruppi.add([s]);
    } else {
      gruppi[i].add(s);
    }
  }
  return [for (final g in gruppi) _unisciGruppo(g)];
}

/// Sessioni da mostrare: lo storico importato da CSV più quelle di Health Connect.
/// Una sessione del CSV che arriva anche da Health Connect (stesso giorno, stesso
/// sport, durata entro 3 minuti) viene sostituita da quella di Health Connect.
/// Fonte delle sedute registrate dalla modalità allenamento dell'app.
const fonteApp = 'Avidididadi';

List<Sessione> combina(List<Sessione> storico, List<Sessione> hc) {
  final unite = raggruppa(hc);
  // Una seduta segnata dall'app lascia il posto a quella dell'orologio dello
  // stesso giorno e sport, che ha più dati (battiti, distanza).
  bool doppione(Sessione s) => unite.any(
    (h) =>
        h.data == s.data &&
        stessoSport(h.sport, s.sport) &&
        (s.fonte == fonteApp
            ? _stessoMomento(s, h)
            : (h.durataMin - s.durataMin).abs() <= 3),
  );
  return _inOrdine([...storico.where((s) => !doppione(s)), ...unite]);
}

/// Una seduta dell'app con l'orario è lo stesso allenamento dell'orologio
/// solo se gli orari si sovrappongono (5 minuti di margine): una camminata la
/// sera resta anche se la mattina l'orologio ha registrato un'altra uscita.
/// Senza orario (sedute vecchie) basta lo stesso giorno.
bool _stessoMomento(Sessione app, Sessione orologio) {
  final a = app.inizio, b = app.fine, c = orologio.inizio, d = orologio.fine;
  if (a == null || b == null || c == null || d == null) return true;
  const margine = Duration(minutes: 5);
  return a.isBefore(d.add(margine)) && c.isBefore(b.add(margine));
}

const infoSyncHeader = ['chiave', 'valore'];

/// Stato della sincronizzazione, salvato in health_connect.csv.
class InfoSync {
  DateTime? ultima;
  String? token; // per leggere solo le modifiche dalla volta precedente
  int regole = 0; // versioneRegole con cui sono state lette le sessioni
  Map<String, int> ignorati =
      {}; // tipi di attività non seguiti -> quante sessioni

  List<List<String>> toRows() => [
    ['ultima', ultima?.toIso8601String() ?? ''],
    ['token', token ?? ''],
    ['regole', '$regole'],
    ['ignorati', ignorati.entries.map((e) => '${e.key}=${e.value}').join(';')],
  ];

  static InfoSync da(Tabella? t) {
    final i = InfoSync();
    if (t == null) return i;
    final m = {for (final r in t.righe) t.v(r, 'chiave'): t.v(r, 'valore')};
    i.ultima = DateTime.tryParse(m['ultima'] ?? '');
    i.token = (m['token'] ?? '').isEmpty ? null : m['token'];
    i.regole = int.tryParse(m['regole'] ?? '') ?? 0;
    for (final p in (m['ignorati'] ?? '').split(';')) {
      final kv = p.split('=');
      if (kv.length == 2) i.ignorati[kv[0]] = int.tryParse(kv[1]) ?? 0;
    }
    return i;
  }
}

/// App di origine delle sessioni di Health Connect: pacchetto -> (nome, quante).
Map<String, (String, int)> fontiDi(List<Sessione> hc) {
  final out = <String, (String, int)>{};
  for (final s in hc) {
    final p = out[s.origine];
    out[s.origine] = (s.fonte, (p?.$2 ?? 0) + 1);
  }
  return out;
}

/// Sessioni salvate prima della correzione del pacchetto di origine (finito in
/// fonte, con origine vuota): rimette il pacchetto in origine e il nome in fonte.
Sessione riparaFonte(Sessione s) => s.origine.isEmpty && s.fonte.contains('.')
    ? s.copyWith(origine: s.fonte, fonte: nomeFonte(s.fonte, ''))
    : s;

/// Garmin non scrive il nome dell'allenamento in Health Connect: per una corsa
/// svolta con il tipo generico si usa il tipo previsto dal piano quel giorno
/// (es. Fartlek il giovedì, Lungo il sabato). Un titolo dell'app vince sempre.
List<Sessione> conTipoDalPiano(List<Sessione> hc, List<PianoRiga> piano) => [
  for (final s in hc)
    () {
      if (s.sport != 'Corsa' || s.tipo != 'Corsa') return s;
      for (final p in piano) {
        if (p.data == s.data &&
            stessoSport(p.sport, s.sport) &&
            p.tipo.isNotEmpty) {
          return s.copyWith(tipo: p.tipo);
        }
      }
      return s;
    }(),
];

/// Stessa attività vista da due fonti: stesso giorno e orari che si
/// sovrappongono (con 2 minuti di margine).
bool _stessaUscita(Sessione a, Sessione b) {
  if (a.data != b.data) return false;
  final a1 = a.inizio, a2 = a.fine, b1 = b.inizio, b2 = b.fine;
  if (a1 == null || a2 == null || b1 == null || b2 == null) {
    return (a.durataMin - b.durataMin).abs() <= 5;
  }
  const m = Duration(minutes: 2);
  return a1.isBefore(b2.add(m)) && b1.isBefore(a2.add(m));
}

/// Forza e mobilità hanno più dettagli su Health Connect (i blocchi di
/// Freeletics); gli altri su intervals.icu.
bool _meglioDaHc(String sport) => sport == 'Forza' || sport == 'Mobilità';

/// Le sessioni di Health Connect senza quelle che intervals.icu ha già, più
/// complete. Un'attività libera è la stessa anche con un altro nome di sport.
List<Sessione> senzaDoppioniIcu(List<Sessione> hc, List<Sessione> icu) {
  if (icu.isEmpty) return hc;
  bool coperta(Sessione h) => icu.any(
    (i) =>
        (stessoSport(i.sport, h.sport) || h.sport == sportAttivitaLibera) &&
        _stessaUscita(h, i),
  );
  return [
    for (final h in hc)
      if (_meglioDaHc(h.sport) || !coperta(h)) h,
  ];
}

/// Le sessioni di intervals.icu senza quelle che restano da Health Connect:
/// forza e mobilità, e le libere che là hanno un nome di sport.
List<Sessione> icuSenzaDoppioniHc(List<Sessione> icu, List<Sessione> hc) {
  if (hc.isEmpty) return icu;
  bool coperta(Sessione i) => hc.any(
    (h) =>
        (stessoSport(i.sport, h.sport) && _meglioDaHc(h.sport) ||
            i.sport == sportAttivitaLibera) &&
        _stessaUscita(h, i),
  );
  return [
    for (final i in icu)
      if (!coperta(i)) i,
  ];
}

/// Tornando nell'app si risincronizza solo se l'avvio ha già finito
/// ([ultima] non null) e sono passati almeno 5 minuti: passare da un'app
/// all'altra non deve far ripartire tutto ogni volta.
bool daRisincronizzare(DateTime? ultima, DateTime ora) =>
    ultima != null && ora.difference(ultima) >= const Duration(minutes: 5);
