import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart' show HealthDataType;

import 'adattamento.dart';
import 'agente_esterno.dart';
import 'assistente.dart';
import 'backup.dart';
import 'benvenuto.dart';
import 'condivisione.dart';
import 'csv.dart';
import 'esercizi.dart';
import 'feedback.dart';
import 'generator.dart';
import 'generatore_endurance.dart';
import 'generatore_forza.dart';
import 'generatore_mobilita.dart';
import 'health_connect.dart';
import 'intervals.dart';
import 'invio_intervals.dart';
import 'llm.dart';
import 'models.dart';
import 'obiettivo.dart';
import 'percorso.dart';
import 'profilo.dart';
import 'recupero.dart';
import 'registro_forza.dart';
import 'scheda.dart';
import 'serie_sessione.dart';
import 'sincronizzazione.dart';
import 'storage.dart';
import 'workout_base.dart';

/// Sport ignorati dall'app (non mostrati né importati).
const sportEsclusi = {'Altro'};

List<Slot> settimanaIniziale() => [
  Slot(giorno: 1, fascia: 'Mattina', sport: 'Forza', durataMin: 45),
  Slot(giorno: 2, fascia: 'Mattina', sport: 'Bici', durataMin: 60),
  Slot(giorno: 2, fascia: 'Pranzo', sport: 'Nuoto', durataMin: 60),
  Slot(giorno: 3, fascia: 'Mattina', sport: 'Forza', durataMin: 45),
  Slot(giorno: 4, fascia: 'Mattina', sport: 'Corsa', durataMin: 60),
  Slot(giorno: 5, fascia: 'Mattina', sport: 'Forza', durataMin: 45),
  Slot(giorno: 6, fascia: 'Mattina', sport: 'Corsa', durataMin: 60),
];

class AppState extends ChangeNotifier {
  List<Slot> settimana = [];
  List<PianoRiga> piano = [];

  /// Sessioni mostrate: storico CSV più Health Connect, senza doppioni.
  List<Sessione> sessioni = [];
  List<Sessione> storicoCsv = []; // importato dai CSV (sessioni.csv)
  List<Sessione> sessioniHc = []; // lette da Health Connect
  InfoSync infoSync = InfoSync();
  final hc = HealthConnectService();
  bool sincronizzando = false;
  List<WorkoutStep> workout = [];
  List<ProgrammaRiga> programma = [];
  Profilo profilo = Profilo();
  List<Misura> misure = []; // in ordine di data
  String cartella = ''; // cartella privata dell'app (per la foto)
  List<Esercizio> esercizi = []; // catalogo, dagli asset dell'app
  Attrezzatura attrezzatura = {};
  List<FeedbackSessione> feedback = []; // in ordine di data
  List<SerieFatta> serieFatte = []; // ripetizioni e kg della forza
  List<Scheda> schede = []; // schede scritte a mano (personal trainer)
  List<GiornoRecupero> recupero = []; // FC a riposo, HRV e sonno, per giorno
  ConfigAssistente assistente = ConfigAssistente();
  List<MessaggioChat> chat = []; // solo in memoria: si azzera alla chiusura
  bool assistenteInAttesa = false;
  StatoConnessione connessione = StatoConnessione.daVerificare;
  String? erroreConnessione;

  /// Promemoria "piano in scadenza" chiuso: torna alla prossima apertura dell'app.
  bool promemoriaChiuso = false;

  /// Ultimo giorno con qualcosa in programma, o null se il piano è vuoto.
  DateTime? get ultimoGiornoPiano => piano.isEmpty
      ? null
      : piano.map((r) => r.data).reduce((a, b) => a.isAfter(b) ? a : b);

  /// Vero se mancano 7 giorni o meno alla fine del piano (o se non c'è un piano).
  bool get pianoInScadenza {
    final u = ultimoGiornoPiano;
    if (u == null) return true;
    return u.difference(soloData(DateTime.now())).inDays <= 7;
  }

  void chiudiPromemoria() {
    promemoriaChiuso = true;
    notifyListeners();
  }

  Future<void> load() async {
    settimana = await Storage.readSettimana() ?? settimanaIniziale();
    piano = [
      for (final r in await Storage.readPiano())
        r.tipo.isNotEmpty || tipoPredefinito(r.data, r.sport).isEmpty
            ? r
            : PianoRiga(
                data: r.data,
                fascia: r.fascia,
                sport: r.sport,
                tipo: tipoPredefinito(r.data, r.sport),
                durataMin: r.durataMin,
                distanzaKm: r.distanzaKm,
                intensita: r.intensita,
                note: r.note,
              ),
    ];

    List<Sessione> leggiSessioni(Tabella? t) => t == null
        ? []
        : t.righe
              .map((r) => Sessione.da(t, r))
              .whereType<Sessione>()
              .where((s) => !sportEsclusi.contains(s.sport))
              .toList();
    storicoCsv = leggiSessioni(await Storage.readTabella('sessioni.csv'));
    sessioniHc = leggiSessioni(
      await Storage.readTabella('health_connect_sessioni.csv'),
    ).map(riparaFonte).toList();
    infoSync = InfoSync.da(await Storage.readTabella('health_connect.csv'));
    await _caricaIntervals();
    final tRitocchi = await Storage.readTabella('ritocchi_sessioni.csv');
    ritocchi = {
      if (tRitocchi != null)
        for (final r in tRitocchi.righe) ?RitoccoSessione.da(tRitocchi, r),
    }.fold({}, (m, r) => m..[r.id] = r);
    _ricombina();

    final tw = await Storage.readTabella('workout.csv');
    workout = tw == null
        ? []
        : tw.righe
              .map((r) => WorkoutStep.da(tw, r))
              .whereType<WorkoutStep>()
              .toList();

    final tp = await Storage.readTabella('programma.csv');
    programma = tp == null
        ? []
        : tp.righe
              .map((r) => ProgrammaRiga.da(tp, r))
              .whereType<ProgrammaRiga>()
              .toList();

    cartella = await Storage.cartella();
    esercizi = await caricaEsercizi();
    final tf = await Storage.readTabella('feedback.csv');
    feedback = tf == null
        ? []
        : (tf.righe
              .map((r) => FeedbackSessione.da(tf, r))
              .whereType<FeedbackSessione>()
              .toList()
            ..sort((a, b) => a.data.compareTo(b.data)));
    final tSerie = await Storage.readTabella('serie.csv');
    serieFatte = tSerie == null
        ? []
        : tSerie.righe
              .map((r) => SerieFatta.da(tSerie, r))
              .whereType<SerieFatta>()
              .toList();
    final tr = await Storage.readTabella('recupero.csv');
    recupero = tr == null
        ? []
        : (tr.righe
              .map((r) => GiornoRecupero.da(tr, r))
              .whereType<GiornoRecupero>()
              .toList()
            ..sort((a, b) => a.data.compareTo(b.data)));
    fcRiposoMisurata = fcRiposoTipica(recupero, soloData(DateTime.now()));
    attrezzatura = attrezzaturaDa(
      await Storage.readTabella('attrezzatura.csv'),
    );
    schede = schedeDa(
      await Storage.readTabella('schede.csv'),
      await Storage.readTabella('schede_esercizi.csv'),
    );
    profilo = Profilo.da(await Storage.readTabella('profilo.csv'));
    assistente = ConfigAssistente.da(
      await Storage.readTabella('assistente.csv'),
    );
    final tm = await Storage.readTabella('misure.csv');
    misure = tm == null
        ? []
        : (tm.righe.map((r) => Misura.da(tm, r)).whereType<Misura>().toList()
            ..sort((a, b) => a.data.compareTo(b.data)));

    // Le sedute future seguono sempre i feedback e i dati più recenti.
    await _aggiornaEndurance();
    notifyListeners();
  }

  Future<void> salvaAttrezzatura() async {
    await Storage.write(
      'attrezzatura.csv',
      attrezzaturaHeader,
      attrezzaturaRighe(attrezzatura),
    );
    await _aggiornaForza(); // il piano di forza usa l'attrezzatura nuova
    notifyListeners();
  }

  Future<void> salvaProfilo() async {
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    await _aggiornaEndurance(); // gara e zone cambiano le sedute
    notifyListeners();
  }

  File? get fileFoto => profilo.foto.isEmpty || cartella.isEmpty
      ? null
      : File('$cartella/${profilo.foto}');

  /// Copia la foto scelta nella cartella dell'app. Il nome cambia a ogni foto,
  /// così l'immagine si aggiorna subito senza restare in cache.
  Future<void> impostaFoto(String origine) async {
    final nome = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(origine).copy('$cartella/$nome');
    await _eliminaFoto();
    profilo.foto = nome;
    await salvaProfilo();
  }

  Future<void> rimuoviFoto() async {
    await _eliminaFoto();
    profilo.foto = '';
    await salvaProfilo();
  }

  Future<void> _eliminaFoto() async {
    final f = fileFoto;
    if (f != null && await f.exists()) await f.delete();
  }

  /// Ultimo valore registrato di un campo (peso o misura), con la sua data.
  (double, DateTime)? ultimaMisura(String campo) {
    for (final m in misure.reversed) {
      final v = m.valori[campo];
      if (v != null && v > 0) return (v, m.data);
    }
    return null;
  }

  /// Registra un valore con la data di oggi; 0 cancella quello di oggi.
  Future<void> salvaMisura(String campo, double valore) async {
    final oggi = soloData(DateTime.now());
    final i = misure.indexWhere((m) => m.data == oggi);
    if (i >= 0) {
      if (valore > 0) {
        misure[i].valori[campo] = valore;
      } else {
        misure[i].valori.remove(campo);
      }
    } else if (valore > 0) {
      misure.add(Misura(oggi, {campo: valore}));
    }
    misure
      ..removeWhere((m) => m.valori.isEmpty)
      ..sort((a, b) => a.data.compareTo(b.data));
    await Storage.write(
      'misure.csv',
      misureHeader,
      misure.map((m) => m.toRow()).toList(),
    );
    notifyListeners();
  }

  /// Salva la settimana tipo e porta subito i cambi nel calendario, da oggi
  /// alla sua fine: solo nei giorni della settimana cambiati, lasciando come
  /// sono i giorni già svolti e quelli decisi dall'assistente. Restituisce
  /// quanti giorni del calendario sono cambiati.
  Future<int> salvaSettimana({List<Slot>? prima}) async {
    await Storage.writeSettimana(settimana);
    final fine = ultimoGiornoPiano;
    final oggi = soloData(DateTime.now());
    if (prima == null || fine == null || fine.isBefore(oggi)) {
      notifyListeners();
      return 0;
    }
    final nuovo = applicaSettimana(
      piano: piano,
      prima: prima,
      dopo: settimana,
      da: oggi,
      fine: fine,
      daTenere: (d) =>
          sessioni.any((s) => s.data == d) ||
          piano.any((r) => r.data == d && rigaDaAssistente(r)),
    );
    final cambiati = {
      for (final r in [...piano, ...nuovo])
        if (!piano.contains(r) || !nuovo.contains(r)) r.data,
    }.length;
    piano = nuovo;
    await Storage.writePiano(piano);
    _ricombina();
    await _aggiornaForza();
    await _aggiornaEndurance();
    notifyListeners();
    return cambiati;
  }

  /// Sostituisce le sessioni dalla data [inizio] in poi; le precedenti restano.
  Future<void> genera(DateTime inizio, int mesi) async {
    final ini = soloData(inizio);
    final passate = piano.where((r) => r.data.isBefore(ini));
    piano = [...passate, ...generaPiano(settimana, ini, mesi)];
    await Storage.writePiano(piano);
    _ricombina(); // il tipo delle corse svolte può venire dal piano
    await _aggiornaForza();
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Sostituisce le sessioni in programma di un solo giorno; gli altri restano invariati.
  Future<void> salvaGiorno(DateTime giorno, List<PianoRiga> righe) async {
    final d = soloData(giorno);
    piano = [...piano.where((r) => r.data != d), ...righe]
      ..sort((a, b) {
        final c = a.data.compareTo(b.data);
        return c != 0
            ? c
            : fasce.indexOf(a.fascia).compareTo(fasce.indexOf(b.fascia));
      });
    await Storage.writePiano(piano);
    _ricombina(); // il tipo delle corse svolte può venire dal piano
    await _aggiornaForza();
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Crea il piano di forza con obiettivo e livello scelti, da oggi in poi.
  /// Restituisce quante sessioni sono state preparate.
  Future<int> creaPianoForza(String obiettivo, String livello) async {
    final oggi = soloData(DateTime.now());
    // Cambiando obiettivo o livello si riparte con un blocco nuovo.
    if (profilo.inizioForza == null ||
        profilo.obiettivo != obiettivo ||
        profilo.livello != livello) {
      profilo.inizioForza = oggi;
      profilo.regolazione = 0;
      // Il giorno prima: così conta anche un feedback dato oggi stesso.
      profilo.cambioLivello = DateTime(oggi.year, oggi.month, oggi.day - 1);
    }
    profilo.obiettivo = obiettivo;
    profilo.livello = livello;
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    final n = await _aggiornaForza();
    notifyListeners();
    return n;
  }

  /// Spegne il piano di forza: le sedute future preparate spariscono, quelle
  /// passate (e quelle con un feedback) restano.
  Future<void> disattivaForza() async {
    final oggi = soloData(DateTime.now());
    final valutate = {
      for (final f in feedback)
        if (stessoSport(f.sport, 'Forza')) f.data,
    };
    bool futura(DateTime d) => !d.isBefore(oggi) && !valutate.contains(d);
    DateTime dataDi(String id) =>
        parseData(id.substring(prefissoForza.length)) ?? oggi;
    profilo
      ..obiettivo = ''
      ..inizioForza = null;
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    workout = [
      for (final w in workout)
        if (!w.id.startsWith(prefissoForza) || !futura(dataDi(w.id))) w,
    ];
    programma = [
      for (final p in programma)
        if (!p.idWorkout.startsWith(prefissoForza) || !futura(p.data)) p,
    ];
    await Storage.write(
      'workout.csv',
      workoutHeader,
      workout.map((w) => w.toRow()).toList(),
    );
    await Storage.write(
      'programma.csv',
      programmaHeader,
      programma.map((p) => p.toRow()).toList(),
    );
    notifyListeners();
  }

  /// Prepara le sedute solo per gli sport scelti (e toglie quelle degli sport
  /// non più scelti). Restituisce quante sedute ci sono da oggi in poi.
  Future<int> preparaSedute({
    required Set<String> sport,
    required String obiettivoForza,
    required String livelloForza,
    required Map<String, String> progressione,
  }) async {
    var n = 0;
    if (sport.contains('Forza')) {
      n += await creaPianoForza(obiettivoForza, livelloForza);
    } else if (profilo.obiettivo.isNotEmpty) {
      await disattivaForza();
    }
    profilo.progressione = {...profilo.progressione, ...progressione};
    final resistenza = {
      for (final s in sport)
        if (sportEndurance.contains(s) || s == sportMobilita) s,
    };
    if (resistenza.isNotEmpty || profilo.sportGenerati.isNotEmpty) {
      n += await creaPianoEndurance(resistenza);
    }
    notifyListeners();
    return n;
  }

  /// Rigenera i workout di forza da oggi in poi (quelli passati restano),
  /// se un piano di forza è stato creato.
  Future<int> _aggiornaForza() async {
    final inizio = profilo.inizioForza;
    final generatore = profilo.obiettivo.isNotEmpty && inizio != null;
    if (!generatore && schede.isEmpty) return 0;
    final oggi = soloData(DateTime.now());
    // La scheda scritta a mano, dove vale, prende il posto di quella generata.
    final nuovo = conScheda(
      generatore
          ? generaPianoForza(
              piano: piano,
              esercizi: esercizi,
              attrezzatura: attrezzatura,
              obiettivo: profilo.obiettivo,
              livello: profilo.livello,
              inizio: inizio,
              da: oggi,
              regolazione: profilo.regolazione,
            )
          : const PianoForza([], []),
      piano.where((r) => !r.data.isBefore(oggi)).toList(),
      schede,
    );
    final coperti = {
      for (final p in nuovo.programma) p.data,
      // Anche quelli fatti prima dall'app (scheda tolta o finita).
      for (final p in programma)
        if (stessoSport(p.sport, 'Forza') &&
            p.idWorkout.startsWith(prefissoForza))
          p.data,
    };
    // Le sessioni con un feedback non si riscrivono: resta quello che è stato fatto.
    // Senza piano generato si toccano solo i giorni della scheda.
    final valutate = {
      for (final f in feedback)
        if (stessoSport(f.sport, 'Forza')) f.data,
    };
    bool daRifare(DateTime d) =>
        !d.isBefore(oggi) &&
        !valutate.contains(d) &&
        (generatore || coperti.contains(d));
    DateTime? dataDi(String id) =>
        parseData(id.substring(prefissoForza.length));
    workout = [
      for (final w in workout)
        if (!w.id.startsWith(prefissoForza) || !daRifare(dataDi(w.id) ?? oggi))
          w,
      for (final w in nuovo.passi)
        if (daRifare(dataDi(w.id) ?? oggi)) w,
    ];
    // Da oggi in poi la forza segue il piano generato, anche al posto di workout importati.
    programma = [
      for (final p in programma)
        if (!(stessoSport(p.sport, 'Forza') && daRifare(p.data))) p,
      for (final p in nuovo.programma)
        if (daRifare(p.data)) p,
    ]..sort((a, b) => a.data.compareTo(b.data));
    await Storage.write(
      'workout.csv',
      workoutHeader,
      workout.map((w) => w.toRow()).toList(),
    );
    await Storage.write(
      'programma.csv',
      programmaHeader,
      programma.map((p) => p.toRow()).toList(),
    );
    return nuovo.programma.length;
  }

  /// Sceglie quali sport tra corsa, nuoto e bici generare e prepara le sedute
  /// da oggi in poi. Restituisce quante sedute sono state preparate.
  Future<int> creaPianoEndurance(Set<String> scelti) async {
    final oggi = soloData(DateTime.now());
    final tolti = profilo.sportGenerati.difference(scelti);
    if (profilo.inizioEndurance == null || profilo.sportGenerati.isEmpty) {
      profilo.inizioEndurance = oggi;
    }
    profilo.sportGenerati = scelti;
    if (scelti.isEmpty) profilo.inizioEndurance = null;
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    if (tolti.isNotEmpty) {
      // Gli sport tolti tornano ai tipi di seduta predefiniti.
      piano = [
        for (final r in piano)
          r.data.isBefore(oggi) || !tolti.contains(normSport(r.sport))
              ? r
              : _conTipo(r, tipoPredefinito(r.data, r.sport)),
      ];
      await Storage.writePiano(piano);
    }
    final n = await _aggiornaEndurance();
    notifyListeners();
    return n;
  }

  /// I passi dell'allenamento previsto per una seduta: quello generato o
  /// importato in programma, altrimenti il workout fisso predefinito.
  List<WorkoutStep> passiSeduta(DateTime data, String sport, String tipo) {
    final d = soloData(data);
    final prog = programma
        .where((p) => p.data == d && stessoSport(p.sport, sport))
        .toList();
    final id = prog.isEmpty
        ? workoutPredefinito(d, sport, tipo)
        : prog.first.idWorkout;
    if (id == null) return const [];
    var passi = workout.where((w) => w.id == id).toList();
    if (passi.isEmpty) passi = workoutBase.where((w) => w.id == id).toList();
    return passi..sort((a, b) => a.ordine.compareTo(b.ordine));
  }

  /// Registra un allenamento fatto con la modalità allenamento, per chi non ha
  /// un orologio collegato. Una seduta dello stesso giorno e sport la sostituisce.
  Future<void> registraSvolta(Sessione s) async {
    storicoCsv = [...storicoCsv.where((x) => x.id != s.id), s];
    await Storage.write(
      'sessioni.csv',
      sessioniHeader,
      storicoCsv.map((x) => x.toRow()).toList(),
    );
    _ricombina();
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Salva il percorso GPS registrato dall'app durante l'allenamento.
  Future<void> salvaPercorsoApp(DateTime giorno, String sport, Percorso p) =>
      Storage.scriviTesto(filePercorsoApp(giorno, sport), p.toCsvText());

  /// Uuid di Health Connect della sessione e dei pezzi da cui è composta.
  List<String> _uuidHc(Sessione s) => [
    for (final x in [s, ...s.parti])
      if (x.id.startsWith('hc-')) x.id.substring(3),
  ];

  /// Percorso GPS di una sessione svolta: la copia già salvata, poi quello
  /// registrato dall'app quel giorno, poi Health Connect (es. Garmin).
  Future<RispostaPercorso> percorsoDi(Sessione s) async {
    if (s.id.startsWith(prefissoIcu)) return _percorsoIcu(s);
    final uuid = _uuidHc(s);
    for (final u in uuid) {
      final t = await Storage.leggiTesto(filePercorsoHc(u));
      if (t != null) return RispostaPercorso.dati(Percorso.daCsv(t));
    }
    final app = await Storage.leggiTesto(filePercorsoApp(s.data, s.sport));
    if (app != null) return RispostaPercorso.dati(Percorso.daCsv(app));
    var consenso = false;
    for (final u in uuid) {
      final r = await hc.percorso(u);
      if (r.stato == StatoPercorso.dati && !r.percorso!.vuoto) {
        await Storage.scriviTesto(filePercorsoHc(u), r.percorso!.toCsvText());
        return r;
      }
      if (r.stato == StatoPercorso.consenso) consenso = true;
    }
    return RispostaPercorso(
      consenso ? StatoPercorso.consenso : StatoPercorso.nessuno,
    );
  }

  Future<RispostaPercorso> _percorsoIcu(Sessione s) async {
    final file = filePercorsoHc(s.id); // es. percorso_hc_icu_i123.csv
    final t = await Storage.leggiTesto(file);
    if (t != null) return RispostaPercorso.dati(Percorso.daCsv(t));
    final chiave = await ChiaveIntervals.leggi();
    if (chiave == null || s.inizio == null || alChiuso(s)) {
      return const RispostaPercorso(StatoPercorso.nessuno);
    }
    try {
      final p = await ClientIntervals(chiave)
          .percorso(s.id.substring(prefissoIcu.length), s.inizio!);
      if (p.vuoto) return const RispostaPercorso(StatoPercorso.nessuno);
      await Storage.scriviTesto(file, p.toCsvText());
      return RispostaPercorso.dati(p);
    } on ErroreIntervals {
      return const RispostaPercorso(StatoPercorso.errore);
    }
  }

  /// Chiede a Health Connect il permesso di vedere il percorso della sessione.
  Future<Percorso?> chiediPercorso(Sessione s) async {
    for (final u in _uuidHc(s)) {
      final p = await hc.chiediPercorso(u);
      if (p != null && !p.vuoto) {
        await Storage.scriviTesto(filePercorsoHc(u), p.toCsvText());
        return p;
      }
    }
    return null;
  }

  /// Percorso aggiunto a mano (file GPX) a una sessione svolta.
  Future<void> salvaPercorsoGpx(Sessione s, Percorso p) {
    final uuid = _uuidHc(s);
    return Storage.scriviTesto(
      uuid.isEmpty
          ? filePercorsoApp(s.data, s.sport)
          : filePercorsoHc(uuid.first),
      p.toCsvText(),
    );
  }

  /// Prima apertura: nessun dato e nessuna configurazione guidata fatta.
  bool get primaVolta =>
      !profilo.benvenuto &&
      profilo.nome.isEmpty &&
      sessioni.isEmpty &&
      piano.isEmpty;

  /// Termini e informativa accettati, nella versione [versione].
  Future<void> accettaTermini(String versione) async {
    profilo.terminiAccettati = versione;
    await salvaProfilo();
  }

  /// Salta la configurazione guidata (non la ripropone più).
  Future<void> saltaBenvenuto() async {
    profilo.benvenuto = true;
    await salvaProfilo();
  }

  /// Configurazione guidata: settimana tipo, piano di 3 mesi e sedute pronte
  /// per gli sport scelti. Restituisce quante sedute ci sono da oggi.
  Future<int> configuraDaZero({
    required String nome,
    required List<String> sport,
    required int giorni,
    required int minuti,
    required String livello,
  }) async {
    final oggi = soloData(DateTime.now());
    if (nome.trim().isNotEmpty) profilo.nome = nome.trim();
    profilo.benvenuto = true;
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    settimana = settimanaDa(sport: sport, giorni: giorni, minuti: minuti);
    await Storage.writeSettimana(settimana);
    await genera(oggi, 3);
    if (sport.contains('Forza')) await creaPianoForza('generale', livello);
    final resistenza = {
      for (final s in sport)
        if (sportEndurance.contains(s) || s == sportMobilita) s,
    };
    if (resistenza.isNotEmpty || profilo.sportGenerati.isNotEmpty) {
      await creaPianoEndurance(resistenza);
    }
    notifyListeners();
    return piano.where((r) => !r.data.isBefore(oggi)).length;
  }

  /// Come cresce il carico di uno sport: durata, intensità o automatico.
  Future<void> impostaProgressione(String sport, String modo) async {
    profilo.progressione[sport] = modo;
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    await _aggiornaEndurance();
    notifyListeners();
  }

  PianoRiga _conTipo(PianoRiga r, String tipo) => PianoRiga(
    data: r.data,
    fascia: r.fascia,
    sport: r.sport,
    tipo: tipo,
    durataMin: r.durataMin,
    distanzaKm: r.distanzaKm,
    intensita: r.intensita,
    note: r.note,
  );

  /// Rigenera le sedute preparate di corsa, nuoto, bici e mobilità.
  Future<int> _aggiornaEndurance() async =>
      await _aggiornaResistenza() + await _aggiornaMobilita();

  /// Sport preparati che non sono di resistenza (oggi solo la mobilità).
  bool _mobilitaScelta() => profilo.sportGenerati.contains(sportMobilita);

  /// Rigenera le sedute di mobilità da oggi in poi (se scelta), oppure toglie
  /// quelle future preparate. I giorni già fatti restano.
  Future<int> _aggiornaMobilita() async {
    final oggi = soloData(DateTime.now());
    final presenti =
        workout.any((w) => w.id.startsWith(prefissoMobilita)) ||
        programma.any((p) => p.idWorkout.startsWith(prefissoMobilita));
    if (!_mobilitaScelta() && !presenti) return 0;
    final nuovo = _mobilitaScelta()
        ? generaPianoMobilita(
            piano: piano,
            esercizi: esercizi,
            attrezzatura: attrezzatura,
            da: oggi,
          )
        : const PianoMobilita([], [], {});
    bool fatta(DateTime d) =>
        sessioni.any((s) => s.data == d && stessoSport(s.sport, sportMobilita));
    bool daRifare(DateTime d) => !d.isBefore(oggi) && !fatta(d);
    DateTime dataDi(String id) =>
        parseData(id.substring(prefissoMobilita.length)) ?? oggi;
    workout = [
      for (final w in workout)
        if (!w.id.startsWith(prefissoMobilita) || !daRifare(dataDi(w.id))) w,
      for (final w in nuovo.passi)
        if (daRifare(dataDi(w.id))) w,
    ];
    programma = [
      for (final p in programma)
        if (!(stessoSport(p.sport, sportMobilita) && daRifare(p.data))) p,
      for (final p in nuovo.programma)
        if (daRifare(p.data)) p,
    ]..sort((a, b) => a.data.compareTo(b.data));
    var cambiato = false;
    piano = [
      for (final r in piano)
        () {
          final t = nuovo.tipi[r.data];
          if (!stessoSport(r.sport, sportMobilita) ||
              t == null ||
              t == r.tipo ||
              !daRifare(r.data)) {
            return r;
          }
          cambiato = true;
          return _conTipo(r, t);
        }(),
    ];
    if (cambiato) await Storage.writePiano(piano);
    await Storage.write(
      'workout.csv',
      workoutHeader,
      workout.map((w) => w.toRow()).toList(),
    );
    await Storage.write(
      'programma.csv',
      programmaHeader,
      programma.map((p) => p.toRow()).toList(),
    );
    return nuovo.programma.length;
  }

  /// Seduta di mobilità al volo (per un giorno di riposo o di recupero basso),
  /// senza cambiare il piano.
  List<WorkoutStep> mobilitaAlVolo(int minuti) {
    final oggi = soloData(DateTime.now());
    final corsaBici = sessioni.any(
      (s) =>
          oggi.difference(s.data).inDays <= 1 &&
          (stessoSport(s.sport, 'Corsa') || stessoSport(s.sport, 'Bici')),
    );
    return sedutaMobilita(
      esercizi: esercizi,
      attrezzatura: attrezzatura,
      data: oggi,
      minuti: minuti,
      focus: corsaBici
          ? 'Anche e gambe'
          : focusMobilita.keys.toList()[oggi.day % 3],
      rotazione: oggi.day,
    );
  }

  /// Rigenera le sedute di corsa, nuoto e bici scelte da oggi in poi; i giorni
  /// in cui lo sport è già stato svolto restano come sono.
  Future<int> _aggiornaResistenza() async {
    final inizio = profilo.inizioEndurance;
    final scelti = profilo.sportGenerati.intersection(sportEndurance.toSet());
    final oggi = soloData(DateTime.now());
    final conSchede = schede.any((x) => !stessoSport(x.sport, 'Forza'));
    if (inizio == null &&
        !conSchede &&
        !workout.any((w) => idEndurance(w.id)) &&
        !programma.any((p) => idEndurance(p.idWorkout))) {
      return 0;
    }
    final generato = scelti.isEmpty || inizio == null
        ? const PianoEndurance([], [], {})
        : generaPianoEndurance(
            piano: piano,
            storico: sessioni,
            sport: scelti,
            inizio: inizio,
            da: oggi,
            obiettivo: profilo.obiettivoGara,
            passoCritico: passoNuoto,
            esiti: esitiEndurance,
            regolazione: profilo.regolazioneEndurance,
            progressione: profilo.progressione,
            principiante: profilo.livello == 'principiante',
          );
    // Le schede scritte a mano, dove valgono, al posto delle sedute preparate.
    var nuovo = generato;
    final futuro = piano.where((r) => !r.data.isBefore(oggi)).toList();
    for (final sport in sportEndurance) {
      final r = applicaSchede(
        nuovo.passi,
        nuovo.programma,
        futuro,
        schede,
        sport,
      );
      nuovo = PianoEndurance(r.passi, r.programma, {
        ...nuovo.tipi,
        for (final MapEntry(key: d, value: t) in r.tipi.entries)
          (d, normSport(sport)): t,
      });
    }
    bool svolta(DateTime d, String sport) =>
        sessioni.any((s) => s.data == d && stessoSport(s.sport, sport)) ||
        feedback.any((f) => f.di(d, sport));
    bool daRifare(DateTime d, String sport) =>
        !d.isBefore(oggi) && !svolta(d, sport);
    DateTime dataDi(String id) =>
        parseData(id.substring(id.indexOf('_') + 1)) ?? oggi;
    // Scelto per le sedute preparate, oppure coperto da una scheda.
    final coperti = {
      for (final p in nuovo.programma) (p.data, normSport(p.sport)),
    };
    bool scelto(String sport) => scelti.any((x) => stessoSport(x, sport));
    workout = [
      for (final w in workout)
        if (!idEndurance(w.id) || !daRifare(dataDi(w.id), w.sport)) w,
      for (final w in nuovo.passi)
        if (daRifare(dataDi(w.id), w.sport)) w,
    ];
    programma = [
      for (final p in programma)
        if (!((idEndurance(p.idWorkout) ||
                scelto(p.sport) ||
                coperti.contains((p.data, normSport(p.sport)))) &&
            daRifare(p.data, p.sport)))
          p,
      for (final p in nuovo.programma)
        if (daRifare(p.data, p.sport)) p,
    ]..sort((a, b) => a.data.compareTo(b.data));
    // Il tipo di seduta deciso dal generatore si vede anche nel calendario.
    var cambiato = false;
    piano = [
      for (final r in piano)
        () {
          final t = nuovo.tipi[(r.data, normSport(r.sport))];
          if (t == null || t == r.tipo || !daRifare(r.data, r.sport)) return r;
          cambiato = true;
          return _conTipo(r, t);
        }(),
    ];
    if (cambiato) await Storage.writePiano(piano);
    await Storage.write(
      'workout.csv',
      workoutHeader,
      workout.map((w) => w.toRow()).toList(),
    );
    await Storage.write(
      'programma.csv',
      programmaHeader,
      programma.map((p) => p.toRow()).toList(),
    );
    return nuovo.programma.length;
  }

  /// File di backup con tutti i dati e la foto.
  Future<Uint8List> creaFileBackup() async {
    final f = fileFoto;
    final foto = f != null && await f.exists() ? await f.readAsBytes() : null;
    return creaBackup(
      await Storage.tuttiCsv(),
      nomeFoto: foto == null ? null : profilo.foto,
      foto: foto,
      creato: DateTime.now(),
    );
  }

  /// Sostituisce tutti i dati con quelli del backup e li ricarica.
  Future<void> ripristinaBackup(DatiBackup b) async {
    final fotoPrima = fileFoto;
    await Storage.ripristina(b);
    if (fotoPrima != null &&
        b.nomeFoto != profilo.foto &&
        await fotoPrima.exists()) {
      await fotoPrima.delete();
    }
    chat = [];
    promemoriaChiuso = false;
    fcRiposoMisurata = 0;
    await load();
  }

  Future<void> salvaAssistente() async {
    await Storage.write(
      'assistente.csv',
      configAssistenteHeader,
      assistente.toRows(),
    );
    notifyListeners();
  }

  /// Età, sesso, altezza e peso per l'assistente, solo se l'utente lo permette.
  String? get _datiPersonali {
    if (!assistente.datiPersonali) return null;
    final peso = ultimaMisura('peso_kg');
    return [
      if (profilo.sesso.isNotEmpty) profilo.sesso.toLowerCase(),
      if (profilo.eta != null) '${profilo.eta} anni',
      if (profilo.altezzaCm > 0) '${fmtNum(profilo.altezzaCm)} cm',
      if (peso != null) '${fmtNum(peso.$1)} kg',
      if (profilo.livello.isNotEmpty) 'livello forza ${profilo.livello}',
    ].join(', ');
  }

  /// Il riassunto che viene inviato all'assistente, uguale all'anteprima.
  String get contestoAssistente => contestoAllenamento(
    oggi: DateTime.now(),
    personali: _datiPersonali,
    gara: profilo.obiettivoGara,
    zone: zone,
    passoCritico: passoCritico,
    sessioni: sessioni,
    piano: piano,
    feedback: feedback,
    recupero: recupero,
    sportGenerati: profilo.sportGenerati,
  );

  /// Verifica che il servizio scelto risponda e aggiorna lo stato mostrato.
  Future<void> verificaAssistente() async {
    if (connessione == StatoConnessione.inVerifica) return;
    connessione = StatoConnessione.inVerifica;
    notifyListeners();
    try {
      final nuovo = await verificaConnessione(
        assistente,
        await ChiaviAssistente.leggi(assistente.fornitore),
      );
      // Il modello predefinito non c'era più: si tiene quello consigliato.
      if (nuovo != null) await salvaAssistente();
      _connesso(null);
    } on ErroreLlm catch (e) {
      _connesso(e.messaggio);
    } catch (e) {
      _connesso('Errore: $e');
    }
  }

  void _connesso(String? errore) {
    connessione = errore == null
        ? StatoConnessione.connesso
        : StatoConnessione.errore;
    erroreConnessione = errore;
    notifyListeners();
  }

  /// Dopo un cambio di servizio, indirizzo o modello lo stato va riverificato.
  void connessioneDaVerificare() {
    connessione = StatoConnessione.daVerificare;
    erroreConnessione = null;
    notifyListeners();
  }

  void nuovaChat() {
    chat = [];
    notifyListeners();
  }

  /// Invia un messaggio all'assistente. Restituisce l'errore, se c'è.
  Future<String?> chiediAllAssistente(String testo) async {
    if (assistenteInAttesa || testo.trim().isEmpty) return null;
    chat = [...chat, MessaggioChat(true, testo.trim())];
    assistenteInAttesa = true;
    notifyListeners();
    try {
      // Solo gli ultimi messaggi, per contenere costi e lunghezza.
      final storia = chat.length > 12 ? chat.sublist(chat.length - 12) : chat;
      final risposta = await chiediAssistente(
        assistente,
        await ChiaviAssistente.leggi(assistente.fornitore),
        istruzioniAssistente(contestoAssistente),
        storia,
      );
      final (testoRisposta, proposta) = estraiProposta(risposta);
      chat = [...chat, MessaggioChat(false, testoRisposta, proposta: proposta)];
      connessione = StatoConnessione.connesso;
      erroreConnessione = null;
      return null;
    } on ErroreLlm catch (e) {
      chat = chat.sublist(0, chat.length - 1); // si può riprovare
      connessione = StatoConnessione.errore;
      erroreConnessione = e.messaggio;
      return e.messaggio;
    } catch (e) {
      chat = chat.sublist(0, chat.length - 1);
      return 'Errore: $e';
    } finally {
      assistenteInAttesa = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------
  // Assistente nell'app dell'utente (senza chiave API)

  /// Ultima risposta dell'agente portata nell'app (non si salva).
  RispostaAgente? rispostaAgente;
  MessaggioChat? propostaAgente; // le modifiche, come nella chat interna
  String? erroreAgente;
  bool rispostaApplicata = false;

  /// Collega l'app dell'assistente: nuovo codice e ricezione delle risposte
  /// condivise accesa.
  Future<void> collegaAgente(String app) async {
    assistente
      ..esterno = true
      ..appEsterna = app
      ..codiceEsterno = nuovoCodiceAgente()
      ..ultimoInvioEsterno = null;
    rispostaAgente = null;
    propostaAgente = null;
    erroreAgente = null;
    await salvaAssistente();
    await Condivisione.ricevi(true);
  }

  /// Scollega: il codice non vale più e l'app smette di ricevere testo.
  Future<void> scollegaAgente() async {
    assistente
      ..esterno = false
      ..codiceEsterno = ''
      ..ultimoInvioEsterno = null;
    rispostaAgente = null;
    propostaAgente = null;
    erroreAgente = null;
    await salvaAssistente();
    await Condivisione.ricevi(false);
  }

  /// Messaggio da mandare all'agente: completo la prima volta, poi solo i dati.
  Future<String> messaggioAgente({required bool completo}) async {
    final c = assistente;
    final oggi = DateTime.now();
    final testo = completo
        ? messaggioInizialeAgente(
            codice: c.codiceEsterno,
            contesto: contestoAssistente,
            oggi: oggi,
          )
        : datiAgente(
            codice: c.codiceEsterno,
            contesto: contestoAssistente,
            oggi: oggi,
          );
    c.ultimoInvioEsterno = oggi;
    await salvaAssistente();
    return testo;
  }

  /// Risposta dell'agente incollata o condivisa: si legge e si mostra
  /// l'anteprima. Non si applica niente senza conferma.
  void riceviDaAgente(String testo) {
    if (!assistente.esterno) return;
    try {
      rispostaAgente = leggiRispostaAgente(testo, assistente.codiceEsterno);
      final m = rispostaAgente!.modifiche;
      propostaAgente = m == null ? null : MessaggioChat(false, '', proposta: m);
      erroreAgente = null;
    } on FormatException catch (e) {
      rispostaAgente = null;
      propostaAgente = null;
      erroreAgente = e.message;
    }
    rispostaApplicata = false;
    notifyListeners();
  }

  /// Controlli sul piano nuovo dell'agente, sul piano e le sessioni di adesso.
  EsitoPiano valutaPianoDa(PianoAgente p) => valutaPianoAgente(
    piano: piano,
    sessioni: sessioni,
    proposta: p,
    oggi: DateTime.now(),
  );

  /// Sostituisce il calendario dalla data del piano nuovo (ricontrollato).
  Future<int> applicaPianoAgente(PianoAgente p) async {
    final esito = valutaPianoDa(p);
    if (!esito.applicabile) return 0;
    piano = esito.piano;
    await Storage.writePiano(piano);
    _ricombina();
    await _aggiornaForza();
    await _aggiornaEndurance();
    rispostaApplicata = true;
    notifyListeners();
    return esito.sedute.length;
  }

  /// Applica le modifiche approvate (ricontrollate sul piano di adesso) e
  /// riprepara le sedute. Restituisce quante sono state applicate.
  Future<int> applicaProposta(MessaggioChat m) async {
    final proposta = m.proposta;
    if (proposta == null || m.applicata) return 0;
    final esito = valutaProposta(piano, proposta, DateTime.now());
    if (esito.accettate.isEmpty) return 0;
    piano = esito.piano;
    await Storage.writePiano(piano);
    _ricombina();
    await _aggiornaForza();
    await _aggiornaEndurance();
    m.applicata = true;
    notifyListeners();
    return esito.accettate.length;
  }

  /// FC a riposo misurata (da Health Connect, vedi recupero); 0 = sconosciuta.
  int fcRiposoMisurata = 0;

  /// Zone di frequenza cardiaca personali: correzioni manuali o stime dai dati.
  Zone get zone {
    final (stimata, _) = stimaFcMax(sessioni, profilo.eta, DateTime.now());
    return Zone(
      fcMax: profilo.fcMaxManuale > 0 ? profilo.fcMaxManuale : stimata,
      fcRiposo: profilo.fcRiposoManuale > 0
          ? profilo.fcRiposoManuale
          : fcRiposoMisurata,
      fcMaxStimata: profilo.fcMaxManuale == 0,
    );
  }

  /// Passo critico del nuoto in secondi per 100 m (null se non stimabile).
  int? get passoCritico => profilo.passoCriticoManuale > 0
      ? profilo.passoCriticoManuale
      : passoNuoto ?? stimaPassoCritico(sessioni, DateTime.now());

  // ---------------------------------------------------------------------
  // Adattamento ai feedback (corsa, nuoto, bici)

  /// Gli step della seduta di [sport] di quel giorno, anche passata.
  List<WorkoutStep> passiDel(DateTime d, String sport) =>
      passiSeduta(soloData(d), sport, tipoDel(d, sport));

  PianoRiga? _previsto(DateTime d, String sport) => piano
      .where((r) => r.data == soloData(d) && stessoSport(r.sport, sport))
      .firstOrNull;

  /// L'attività davvero svolta a cui si riferisce il feedback.
  Sessione? attivitaDi(FeedbackSessione f) {
    if (f.idSessione.isNotEmpty) {
      for (final s in sessioni) {
        if (s.id == f.idSessione || s.parti.any((p) => p.id == f.idSessione)) {
          return s;
        }
      }
    }
    return sessioni
        .where((s) => s.data == f.data && stessoSport(s.sport, f.sport))
        .firstOrNull;
  }

  /// Il feedback di un'attività: quello legato a lei, o del suo giorno.
  FeedbackSessione? feedbackDi(Sessione s) =>
      feedback
          .where(
            (f) =>
                f.idSessione == s.id ||
                s.parti.any((p) => p.id == f.idSessione),
          )
          .firstOrNull ??
      feedbackDel(s.data, s.sport);

  /// La seduta in programma rispetto a quello che è stato fatto quel giorno.
  StatoSeduta statoDel(PianoRiga r) {
    final passi = passiDel(r.data, r.sport);
    return statoSeduta(
      previsto: r,
      fatte: sessioni,
      metriPrevisti: stessoSport(r.sport, 'Nuoto') ? metriDi(passi).round() : 0,
    );
  }

  /// Passo target della nuotata in programma quel giorno (s/100 m).
  int? passoTargetDel(DateTime d) => passoTargetDi(passiDel(d, 'Nuoto'));

  /// Com'è andata davvero: fatica attesa per l'attività svolta, scarto dal
  /// passo target (solo se è stata fatta la seduta in programma) ed esito.
  ({EsitoSeduta esito, int atteso, double? scarto, StatoSeduta stato})
  valutaFeedback(FeedbackSessione f) {
    final attivita = attivitaDi(f);
    final previsto = _previsto(f.data, f.sport);
    final stato = previsto == null
        ? StatoSeduta.sostituita
        : attivita == null
        ? StatoSeduta
              .svolta // feedback senza attività: fatta a mano
        : statoDel(previsto);
    final atteso = faticaAttesa(
      attivita: attivita,
      previsto: previsto,
      stato: stato,
    );
    final target = stato == StatoSeduta.svolta && stessoSport(f.sport, 'Nuoto')
        ? passoTargetDel(f.data)
        : null;
    final scarto = scartoPasso(f, target);
    return (
      esito: valutaSeduta(f: f, atteso: atteso, scarto: scarto),
      atteso: atteso,
      scarto: scarto,
      stato: stato,
    );
  }

  /// Esiti dei feedback per sport, in ordine di data.
  Map<String, List<(DateTime, EsitoSeduta)>> get esitiEndurance {
    final out = <String, List<(DateTime, EsitoSeduta)>>{};
    for (final f in feedback) {
      final sp = normSport(f.sport);
      if (!sportEndurance.contains(sp)) continue;
      (out[sp] ??= []).add((f.data, valutaFeedback(f).esito));
    }
    return out;
  }

  /// Passo di riferimento in piscina (s/100 m): mediana del passo della parte
  /// principale nelle ultime 3 nuotate (dal feedback o stimato), oppure quello
  /// scritto a mano nel profilo.
  int? get passoNuoto {
    if (profilo.passoCriticoManuale > 0) return profilo.passoCriticoManuale;
    final oggi = soloData(DateTime.now());
    final nuotate =
        sessioni
            .where(
              (s) => stessoSport(s.sport, 'Nuoto') && !s.data.isAfter(oggi),
            )
            .toList()
          ..sort((a, b) => b.data.compareTo(a.data));
    final valori = <int>[];
    for (final s in nuotate) {
      final previsto = _previsto(s.data, 'Nuoto');
      final passi = passiDel(s.data, 'Nuoto');
      final svolta =
          previsto != null && statoDel(previsto) == StatoSeduta.svolta;
      final v = passoEseguito(
        s: s,
        f: feedbackDi(s),
        target: svolta ? passoTargetDi(passi) : null,
        recuperoS: svolta ? recuperoPrevisto(passi) : 0,
      );
      if (v != null) valori.add(v);
      if (valori.length == 3) break;
    }
    return passoRiferimento(valori);
  }

  void _ricombina() {
    sessioni = [
      for (final s in combina(
        storicoCsv,
        conTipoDalPiano([
          ...senzaDoppioniIcu(sessioniHc, sessioniIcu),
          ...sessioniIcu,
        ], piano),
      ).where((s) => !sportEsclusi.contains(s.sport)))
        // Il nome scritto a mano vince su quello dell'orologio.
        (ritocchi[s.id]?.nome ?? '').isEmpty
            ? s
            : s.copyWith(tipo: ritocchi[s.id]!.nome),
    ];
  }

  /// Nome e "al chiuso" scritti a mano sulle sessioni, per id.
  Map<String, RitoccoSessione> ritocchi = {};

  bool alChiuso(Sessione s) =>
      ritocchi[s.id]?.alChiuso ?? icuAlChiuso.contains(s.id);

  // ---------------------------------------------------------------------
  // intervals.icu (attività complete da Garmin, Polar, Suunto…)

  List<Sessione> sessioniIcu = [];
  Set<String> icuAlChiuso = {}; // rulli e tapis roulant, da intervals.icu
  bool intervalsCollegato = false;
  DateTime? ultimaIntervals;
  String? erroreIntervals;
  bool sincronizzandoIntervals = false;

  /// Invio del piano (corsa, bici, nuoto) al calendario di intervals.icu.
  bool invioIntervals = false;
  List<EventoInviato> inviatiIcu = [];
  DateTime? ultimoInvio;
  String? erroreInvio;
  bool inviando = false;
  static const _fileInviati = 'intervals_inviati.csv';

  static const _fileIcu = 'intervals_sessioni.csv';
  static const _infoIcu = 'intervals.csv';
  static const _icuHeader = [...sessioniHeader, 'al_chiuso'];

  Future<void> _caricaIntervals() async {
    final t = await Storage.readTabella(_fileIcu);
    sessioniIcu = [];
    icuAlChiuso = {};
    if (t != null) {
      for (final r in t.righe) {
        final s = Sessione.da(t, r);
        if (s == null) continue;
        sessioniIcu.add(s);
        if (t.v(r, 'al_chiuso') == 'si') icuAlChiuso.add(s.id);
      }
    }
    final info = await Storage.readTabella(_infoIcu);
    final m = {
      if (info != null)
        for (final r in info.righe) info.v(r, 'chiave'): info.v(r, 'valore'),
    };
    intervalsCollegato = m['collegato'] == 'si';
    ultimaIntervals = DateTime.tryParse(m['ultima'] ?? '');
    invioIntervals = m['invio'] == 'si';
    ultimoInvio = DateTime.tryParse(m['ultimo_invio'] ?? '');
    final ti = await Storage.readTabella(_fileInviati);
    inviatiIcu = ti == null
        ? []
        : ti.righe
              .map((r) => EventoInviato.da(ti, r))
              .whereType<EventoInviato>()
              .toList();
  }

  Future<void> _salvaInviati() => Storage.write(
    _fileInviati,
    inviatiHeader,
    inviatiIcu.map((x) => x.toRow()).toList(),
  );

  Future<void> _salvaIntervals() async {
    await Storage.write(_fileIcu, _icuHeader, [
      for (final s in sessioniIcu)
        [...s.toRow(), icuAlChiuso.contains(s.id) ? 'si' : ''],
    ]);
    await Storage.write(
      _infoIcu,
      const ['chiave', 'valore'],
      [
        ['collegato', intervalsCollegato ? 'si' : ''],
        ['ultima', ultimaIntervals?.toIso8601String() ?? ''],
        ['invio', invioIntervals ? 'si' : ''],
        ['ultimo_invio', ultimoInvio?.toIso8601String() ?? ''],
      ],
    );
  }

  /// Prova la chiave, la salva cifrata e scarica gli ultimi 90 giorni.
  Future<String> collegaIntervals(String chiave) async {
    final k = chiave.trim();
    if (k.isEmpty) return 'Incolla prima la chiave API.';
    try {
      final nome = await ClientIntervals(k).verifica();
      await ChiaveIntervals.salva(k);
      intervalsCollegato = true;
      ultimaIntervals = null;
      final esito = await sincronizzaIntervals();
      return '${nome.isEmpty ? 'Collegato' : 'Collegato come $nome'}. $esito';
    } on ErroreIntervals catch (e) {
      return e.messaggio;
    }
  }

  /// Scarica le attività nuove o cambiate (dall'ultima volta, con 3 giorni
  /// di margine; la prima volta gli ultimi 90 giorni).
  Future<String> sincronizzaIntervals() async {
    if (!intervalsCollegato || sincronizzandoIntervals) return '';
    final chiave = await ChiaveIntervals.leggi();
    if (chiave == null) {
      erroreIntervals = 'Chiave non trovata: collega di nuovo intervals.icu.';
      notifyListeners();
      return erroreIntervals!;
    }
    sincronizzandoIntervals = true;
    notifyListeners();
    try {
      final oggi = soloData(DateTime.now());
      final da = ultimaIntervals == null
          ? oggi.subtract(const Duration(days: 90))
          : soloData(ultimaIntervals!).subtract(const Duration(days: 3));
      final nuove = await ClientIntervals(chiave).attivita(da, oggi);
      final perId = {
        for (final s in sessioniIcu)
          if (s.data.isBefore(da)) s.id: s,
      };
      final chiuse = {
        for (final id in icuAlChiuso)
          if (perId.containsKey(id)) id,
      };
      for (final a in nuove) {
        perId[a.sessione.id] = a.sessione;
        if (a.alChiuso) chiuse.add(a.sessione.id);
      }
      sessioniIcu = perId.values.toList()
        ..sort((a, b) => a.data.compareTo(b.data));
      icuAlChiuso = chiuse;
      ultimaIntervals = DateTime.now();
      erroreIntervals = null;
      await _salvaIntervals();
      _ricombina();
      await _aggiornaEndurance();
      final letto = '${nuove.length} attività lette da intervals.icu.';
      if (!invioIntervals) return letto;
      sincronizzandoIntervals = false;
      return '$letto ${await inviaPianoIntervals()}';
    } on ErroreIntervals catch (e) {
      erroreIntervals = e.messaggio;
      return e.messaggio;
    } finally {
      sincronizzandoIntervals = false;
      notifyListeners();
    }
  }

  /// Le sedute di corsa, bici e nuoto dei prossimi [giorniInvio] giorni, con
  /// i passi dell'allenamento. Quelle di oggi già fatte non si mandano.
  List<SedutaDaInviare> seduteDaInviare() {
    final oggi = soloData(DateTime.now());
    final fine = oggi.add(const Duration(days: giorniInvio));
    final out = <SedutaDaInviare>[];
    final contati = <String, int>{};
    for (final r in piano) {
      if (r.data.isBefore(oggi) || !r.data.isBefore(fine)) continue;
      if (tipoEventoIcu(r.sport, r.tipo) == null) continue;
      if (r.data == oggi &&
          sessioni.any(
            (x) => x.data == oggi && stessoSport(x.sport, r.sport),
          )) {
        continue;
      }
      final chiave = '${isoData(r.data)}-${r.sport}';
      final indice = contati[chiave] ?? 0;
      contati[chiave] = indice + 1;
      out.add(
        SedutaDaInviare(
          data: r.data,
          sport: r.sport,
          tipo: r.tipo,
          durataMin: r.durataMin,
          indice: indice,
          // I passi dettagliati valgono per la prima seduta del giorno.
          passi: indice == 0 ? passiSeduta(r.data, r.sport, r.tipo) : const [],
        ),
      );
    }
    return out;
  }

  /// Manda a intervals.icu le sedute nuove o cambiate e toglie quelle non più
  /// in programma. Restituisce il messaggio per l'utente.
  Future<String> inviaPianoIntervals() async {
    if (!intervalsCollegato || inviando) return '';
    final chiave = await ChiaveIntervals.leggi();
    if (chiave == null) {
      return 'Chiave non trovata: collega di nuovo intervals.icu.';
    }
    inviando = true;
    notifyListeners();
    try {
      final oggi = soloData(DateTime.now());
      final (:nuovi, :daCancellare) = pianoInvio(
        seduteDaInviare(),
        inviatiIcu,
        oggi,
      );
      final client = ClientIntervals(chiave);
      await client.cancellaEventi(daCancellare);
      final creati = await client.creaEventi(nuovi);
      final perId = {
        for (final x in inviatiIcu)
          if (!daCancellare.contains(x.id)) x.externalId: x,
      };
      for (final e in nuovi) {
        final ext = e['external_id']! as String;
        final id = creati[ext];
        if (id == null) continue;
        perId[ext] = EventoInviato(
          ext,
          id,
          parseData((e['start_date_local']! as String).substring(0, 10))!,
          firmaDi(e),
        );
      }
      // Si dimenticano i giorni passati: restano nel calendario così come sono.
      inviatiIcu = perId.values.where((x) => !x.data.isBefore(oggi)).toList()
        ..sort((a, b) => a.data.compareTo(b.data));
      ultimoInvio = DateTime.now();
      erroreInvio = null;
      await _salvaInviati();
      await _salvaIntervals();
      if (nuovi.isEmpty && daCancellare.isEmpty) {
        return 'Il calendario di intervals.icu è già aggiornato.';
      }
      final tolte = daCancellare.length - nuovi.length;
      final fatto = [
        if (nuovi.isNotEmpty)
          '${nuovi.length} ${nuovi.length == 1 ? 'seduta mandata' : 'sedute mandate'}',
        if (tolte > 0) '$tolte ${tolte == 1 ? 'tolta' : 'tolte'}',
      ].join(', ');
      return '${maiuscola(fatto)} a intervals.icu.';
    } on ErroreIntervals catch (e) {
      erroreInvio = e.messaggio;
      return e.messaggio;
    } finally {
      inviando = false;
      notifyListeners();
    }
  }

  /// Accende o spegne l'invio. Spegnendolo, le sedute future mandate
  /// dall'app spariscono dal calendario di intervals.icu.
  Future<String> impostaInvioIntervals(bool attivo) async {
    invioIntervals = attivo;
    await _salvaIntervals();
    notifyListeners();
    if (attivo) return inviaPianoIntervals();
    final chiave = await ChiaveIntervals.leggi();
    if (chiave == null || inviatiIcu.isEmpty) return '';
    try {
      await ClientIntervals(chiave)
          .cancellaEventi([for (final x in inviatiIcu) x.id]);
      final n = inviatiIcu.length;
      inviatiIcu = [];
      await _salvaInviati();
      notifyListeners();
      return '$n sedute tolte dal calendario di intervals.icu.';
    } on ErroreIntervals catch (e) {
      return e.messaggio;
    }
  }

  /// Toglie chiave e attività di intervals.icu: tornano quelle di Health
  /// Connect.
  Future<void> scollegaIntervals() async {
    if (inviatiIcu.isNotEmpty) await impostaInvioIntervals(false);
    invioIntervals = false;
    ultimoInvio = null;
    await ChiaveIntervals.elimina();
    intervalsCollegato = false;
    ultimaIntervals = null;
    erroreIntervals = null;
    sessioniIcu = [];
    icuAlChiuso = {};
    await _salvaIntervals();
    _ricombina();
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Battito, velocità, altitudine e potenza di un'attività di intervals.icu.
  Future<SerieSessione?> serieIcu(Sessione s) async {
    final chiave = await ChiaveIntervals.leggi();
    if (chiave == null || !s.id.startsWith(prefissoIcu) || s.inizio == null) {
      return null;
    }
    try {
      return await ClientIntervals(chiave)
          .serie(s.id.substring(prefissoIcu.length), s.inizio!);
    } on ErroreIntervals {
      return null;
    }
  }

  Future<void> ritoccaSessione(RitoccoSessione r) async {
    ritocchi = {...ritocchi, r.id: r};
    if (r.nome.isEmpty && !r.alChiuso) ritocchi.remove(r.id);
    await Storage.write(
      'ritocchi_sessioni.csv',
      ritocchiHeader,
      ritocchi.values.map((x) => x.toRow()).toList(),
    );
    _ricombina();
    notifyListeners();
  }

  /// Legge da Health Connect le sessioni nuove o cambiate dall'ultima volta
  /// (tutto lo storico disponibile la prima volta). Con [interattiva] chiede i
  /// permessi che mancano; altrimenti, senza permessi, non fa nulla.
  /// Restituisce il messaggio da mostrare.
  Future<String> sincronizzaHc({bool interattiva = false}) async {
    if (sincronizzando) return 'Sincronizzazione già in corso.';
    sincronizzando = true;
    notifyListeners();
    try {
      final disp = await hc.disponibilita();
      if (disp != DisponibilitaHc.disponibile) {
        return switch (disp) {
          DisponibilitaHc.daAggiornare =>
            'Health Connect va aggiornato: aprilo dal Play Store.',
          DisponibilitaHc.nonInstallata =>
            'Health Connect non è installato sul telefono.',
          _ => 'Health Connect è disponibile solo su Android.',
        };
      }
      if ((await hc.permessi())[HealthDataType.WORKOUT] != true) {
        if (!interattiva) return 'Health Connect non è ancora collegato.';
        await hc.chiediPermessi();
        if ((await hc.permessi())[HealthDataType.WORKOUT] != true) {
          return 'Senza il permesso per le sessioni di allenamento non posso '
              'leggere nulla. Puoi darlo da "Rivedi permessi".';
        }
      }

      var aggiornati = <RecordHc>[];
      var cancellati = <String>{};
      var token = infoSync.token;
      // Rilettura completa la prima volta o quando cambiano le regole di abbinamento.
      final regoleNuove = infoSync.regole != versioneRegole;
      var rilettura = token == null || regoleNuove;
      if (!rilettura) {
        final m = await hc.modifiche(token);
        if (m.scaduto) {
          rilettura = true;
        } else {
          (aggiornati, cancellati, token) = (
            m.aggiornati,
            m.cancellati,
            m.token,
          );
        }
      }
      if (rilettura) {
        // Il token si chiede prima di leggere, per non perdere modifiche nel mezzo.
        final nuovo = await hc.tokenModifiche();
        final adesso = DateTime.now();
        // Prima volta: tutto lo storico; token scaduto: l'ultimo mese.
        final tutto = infoSync.token == null || regoleNuove;
        final da = tutto
            ? DateTime(2000)
            : adesso.subtract(const Duration(days: 31));
        aggiornati = await hc.sessioni(da, adesso);
        token = nuovo;
        if (tutto) infoSync.ignorati = {};
      }

      final prima = {for (final s in sessioniHc) s.id};
      final titoli = await hc.titoli([
        for (final r in aggiornati)
          if (mappaAttivita(r.tipo, pacchetto: r.pacchetto) != null) r.uuid,
      ]);
      aggiornati = [
        for (final r in aggiornati)
          titoli[r.uuid] == null ? r : r.conTitolo(titoli[r.uuid]!),
      ];
      final nuove = <Sessione>[];
      for (final r in aggiornati) {
        if (mappaAttivita(r.tipo, pacchetto: r.pacchetto) == null) {
          infoSync.ignorati[r.tipo] = (infoSync.ignorati[r.tipo] ?? 0) + 1;
          cancellati.add(
            r.uuid,
          ); // un record cambiato in un tipo non seguito esce
          continue;
        }
        final s = sessioneDa(r, await hc.metricheDi(r));
        if (s != null) nuove.add(s);
      }
      sessioniHc = applicaModifiche(
        sessioniHc,
        aggiornate: nuove,
        cancellati: cancellati,
      );
      infoSync
        ..token = token
        ..regole = versioneRegole
        ..ultima = DateTime.now();
      await Storage.write(
        'health_connect_sessioni.csv',
        sessioniHeader,
        sessioniHc.map((s) => s.toRow()).toList(),
      );
      await Storage.write(
        'health_connect.csv',
        infoSyncHeader,
        infoSync.toRows(),
      );
      _ricombina();
      await _sincronizzaRecupero();

      final aggiunte = nuove.where((s) => !prima.contains(s.id)).length;
      final cambiate = nuove.length - aggiunte;
      final tolte = cancellati.where((u) => prima.contains('hc-$u')).length;
      if (aggiunte + cambiate + tolte == 0) {
        return 'Nessuna novità da Health Connect.';
      }
      return [
        if (aggiunte > 0) '$aggiunte sessioni nuove',
        if (cambiate > 0) '$cambiate aggiornate',
        if (tolte > 0) '$tolte rimosse',
      ].join(', ');
    } catch (e) {
      debugPrint('Health Connect: errore $e');
      return 'Errore durante la sincronizzazione: $e';
    } finally {
      sincronizzando = false;
      notifyListeners();
    }
  }

  /// Rilegge FC a riposo, HRV e sonno delle ultime 5 settimane. Un errore qui
  /// non deve fermare la sincronizzazione delle sessioni.
  Future<void> _sincronizzaRecupero() async {
    try {
      final adesso = DateTime.now();
      final nuovi = await hc.recupero(
        soloData(adesso.subtract(const Duration(days: 35))),
        adesso,
      );
      if (nuovi.isEmpty) return;
      recupero = unisciRecupero(recupero, nuovi);
      fcRiposoMisurata = fcRiposoTipica(recupero, soloData(adesso));
      await Storage.write(
        'recupero.csv',
        recuperoHeader,
        recupero.map((g) => g.toRow()).toList(),
      );
    } catch (e) {
      debugPrint('Health Connect: recupero non letto ($e)');
    }
  }

  /// Valutazione del recupero di oggi (null senza dati di oggi).
  Prontezza? get prontezza =>
      valutaRecupero(recupero, soloData(DateTime.now()));

  FeedbackSessione? feedbackDel(DateTime giorno, [String sport = 'Forza']) {
    for (final f in feedback) {
      if (f.di(giorno, sport)) return f;
    }
    return null;
  }

  /// Sessioni svolte negli ultimi 3 giorni senza feedback, dalla più recente.
  List<Sessione> get senzaFeedback {
    final oggi = soloData(DateTime.now());
    final visti = <String>{};
    return [
      for (final s in sessioni.reversed)
        if (!s.data.isAfter(oggi) &&
            oggi.difference(s.data).inDays < 3 &&
            feedbackDel(s.data, s.sport) == null &&
            visti.add('${isoData(s.data)}|${normSport(s.sport)}'))
          s,
    ]..sort((a, b) => b.data.compareTo(a.data));
  }

  /// Tipo della seduta di [sport] in programma quel giorno (o di quella svolta).
  String tipoDel(DateTime giorno, String sport) {
    for (final r in piano) {
      if (r.data == soloData(giorno) && stessoSport(r.sport, sport)) {
        return r.tipo;
      }
    }
    for (final s in sessioni) {
      if (s.data == soloData(giorno) && stessoSport(s.sport, sport)) {
        return s.tipo;
      }
    }
    return '';
  }

  /// Salva le serie di forza fatte in un giorno: sostituiscono quelle dello
  /// stesso giorno e degli stessi esercizi (se la seduta si ripete).
  Future<void> salvaSerie(DateTime giorno, List<SerieFatta> nuove) async {
    if (nuove.isEmpty) return;
    final d = soloData(giorno);
    final chiavi = nuove.map((s) => s.chiave).toSet();
    serieFatte = [
      ...serieFatte.where((s) => s.data != d || !chiavi.contains(s.chiave)),
      ...nuove,
    ];
    await Storage.write(
      'serie.csv',
      serieHeader,
      serieFatte.map((s) => s.toRow()).toList(),
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Schede scritte a mano

  /// La scheda che vale oggi, se c'è.
  Scheda? get schedaAttiva => schedaDel(schede, DateTime.now());

  /// Le schede che valgono oggi, una per sport.
  List<Scheda> get schedeAttive => [
    for (final sport in const ['Forza', ...sportEndurance])
      ?schedaDel(schede, DateTime.now(), sport),
  ];

  /// Una scheda appena finita, se oggi non ne vale un'altra dello stesso
  /// sport: si chiede cosa fare.
  Scheda? get schedaFinita {
    final oggi = soloData(DateTime.now());
    Scheda? f;
    for (final s in schede) {
      if (s.finita(oggi) &&
          schedaDel(schede, oggi, s.sport) == null &&
          (f == null || s.fine!.isAfter(f.fine!))) {
        f = s;
      }
    }
    return f;
  }

  Future<void> _salvaSchede() async {
    await Storage.write('schede.csv', schedeHeader, righeSchede(schede));
    await Storage.write(
      'schede_esercizi.csv',
      schedeEserciziHeader,
      righeEserciziSchede(schede),
    );
  }

  /// Salva una scheda nuova o modificata e rifà le sedute di forza da oggi.
  Future<void> salvaScheda(Scheda s) async {
    schede = [...schede.where((x) => x.id != s.id), s]
      ..sort((a, b) => a.inizio.compareTo(b.inizio));
    await _salvaSchede();
    await _aggiornaForza();
    await _aggiornaEndurance(); // le schede di corsa, bici e nuoto
    notifyListeners();
  }

  Future<void> eliminaScheda(String id) async {
    schede = schede.where((x) => x.id != id).toList();
    await _salvaSchede();
    await _aggiornaForza();
    await _aggiornaEndurance(); // le schede di corsa, bici e nuoto
    notifyListeners();
  }

  /// Scrive nella scheda i kg nuovi (per nome dell'esercizio).
  Future<void> aggiornaPesiScheda(
    String id,
    Map<String, List<double>> kg,
  ) async {
    final s = schede.where((x) => x.id == id).firstOrNull;
    if (s == null || kg.isEmpty) return;
    await salvaScheda(conPesi(s, kg));
  }

  /// Le serie di forza di un giorno, raggruppate per esercizio in ordine.
  Map<String, List<SerieFatta>> serieDel(DateTime giorno) {
    final d = soloData(giorno);
    final out = <String, List<SerieFatta>>{};
    for (final s in serieFatte.where((s) => s.data == d)) {
      (out[s.nome] ??= []).add(s);
    }
    for (final l in out.values) {
      l.sort((a, b) => a.serie.compareTo(b.serie));
    }
    return out;
  }

  /// Salva il feedback di una sessione e riprepara quelle future: per la forza
  /// regola carichi e livello, per corsa, nuoto e bici la durata delle sedute.
  /// Restituisce il messaggio per l'utente.
  Future<String> salvaFeedback(FeedbackSessione f) async {
    feedback = [...feedback.where((x) => !x.di(f.data, f.sport)), f]
      ..sort((a, b) => a.data.compareTo(b.data));
    await Storage.write(
      'feedback.csv',
      feedbackHeader,
      feedback.map((x) => x.toRow()).toList(),
    );
    final sport = normSport(f.sport);
    if (!stessoSport(sport, 'Forza')) {
      if (!profilo.sportGenerati.contains(sport) || sport == sportMobilita) {
        notifyListeners();
        return 'Feedback salvato: conta nel carico di allenamento.';
      }
      // La prossima seduta di questo sport, prima e dopo il ricalcolo.
      final oggi = soloData(DateTime.now());
      final prossima =
          piano
              .where(
                (r) =>
                    stessoSport(r.sport, sport) &&
                    !r.data.isBefore(oggi) &&
                    r.data != f.data &&
                    !sessioni.any(
                      (s) => s.data == r.data && stessoSport(s.sport, sport),
                    ),
              )
              .toList()
            ..sort((a, b) => a.data.compareTo(b.data));
      final quando = prossima.firstOrNull?.data;
      final prima = quando == null ? <WorkoutStep>[] : passiDel(quando, sport);
      final v = valutaFeedback(f);
      final esiti = esitiEndurance[sport] ?? const [];
      final scarico =
          adatta(
            esiti,
            modo: profilo.progressione[sport] ?? progressioneAuto,
          ).scaricoFino ==
          f.data.add(const Duration(days: 7));
      await _aggiornaEndurance();
      notifyListeners();
      final frase = fraseEsito(
        esito: v.esito,
        fatica: f.fatica,
        atteso: v.atteso,
        scarto: v.scarto,
        scarico: scarico,
        sport: sport,
      );
      if (quando == null) return frase;
      final cambi = cambiSeduta(prima, passiDel(quando, sport));
      final giorno =
          '${giorniSettimana[quando.weekday - 1].toLowerCase()} '
          '${quando.day}/${quando.month}';
      return '$frase\n\nProssima seduta ($giorno): '
          '${cambi.isEmpty ? 'resta uguale' : cambi.join(', ')}.';
    }
    if (profilo.obiettivo.isEmpty) {
      notifyListeners();
      return 'Feedback salvato.';
    }
    final r = regola(
      storico: feedback
          .where(
            (x) => stessoSport(x.sport, 'Forza') && !x.data.isAfter(f.data),
          )
          .toList(),
      faticaObiettivo: faticaObiettivo(profilo.obiettivo),
      regolazione: profilo.regolazione,
      livello: profilo.livello,
      dalCambio: profilo.cambioLivello,
    );
    if (r.livello != profilo.livello) profilo.cambioLivello = f.data;
    profilo.regolazione = r.regolazione;
    profilo.livello = r.livello;
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    await _aggiornaForza();
    notifyListeners();
    return r.messaggio;
  }

  /// Import manuale delle sessioni da CSV, per chi non usa app collegate a
  /// Health Connect (vedi [modelloCsvSessioni]).
  Future<String> importaSessioniCsv(String testo) async {
    final t = Tabella.da(testo);
    if (t == null || t.righe.isEmpty) return 'file vuoto o non valido.';
    if (t.ha(['data', 'sport'])) return _importaSessioni(t);
    return 'formato non riconosciuto: servono almeno le colonne data e sport '
        '(trovate: ${t.idx.keys.join(', ')}).';
  }

  Future<String> _importaSessioni(Tabella t) async {
    var nuove = 0, aggiornate = 0, scartate = 0, ignorate = 0;
    final mappa = {for (final s in storicoCsv) s.id: s};
    for (final r in t.righe) {
      final s = Sessione.da(t, r);
      if (s == null) {
        scartate++;
        continue;
      }
      if (sportEsclusi.contains(s.sport)) {
        ignorate++;
        continue;
      }
      if (mappa.containsKey(s.id)) {
        aggiornate++;
      } else {
        nuove++;
      }
      mappa[s.id] = s;
    }
    storicoCsv = mappa.values.toList()
      ..sort((a, b) => a.data.compareTo(b.data));
    await Storage.write(
      'sessioni.csv',
      sessioniHeader,
      storicoCsv.map((s) => s.toRow()).toList(),
    );
    _ricombina();
    notifyListeners();
    final extra = [
      if (scartate > 0) '$scartate righe scartate (data o sport mancanti)',
      if (ignorate > 0) '$ignorate ignorate (${sportEsclusi.join(', ')})',
    ].map((e) => ', $e').join();
    return '$nuove sessioni nuove, $aggiornate aggiornate$extra.';
  }
}
