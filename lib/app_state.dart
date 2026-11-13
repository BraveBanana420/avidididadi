import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart' show HealthDataType;

import 'adattamento.dart';
import 'arrampicata.dart';
import 'attivita_libera.dart';
import 'agente_esterno.dart';
import 'allenamento_agente.dart';
import 'allenamento_arrampicata.dart';
import 'assistente.dart';
import 'backup.dart';
import 'backup_auto.dart';
import 'benvenuto.dart';
import 'condivisione.dart';
import 'csv.dart';
import 'esercizi.dart';
import 'esporta.dart';
import 'feedback.dart';
import 'generator.dart';
import 'generatore_endurance.dart';
import 'generatore_forza.dart';
import 'generatore_mobilita.dart';
import 'health_connect.dart';
import 'intervalli.dart';
import 'intervals.dart';
import 'invio_intervals.dart';
import 'llm.dart';
import 'attivita.dart';
import 'modifica_sessione.dart';
import 'models.dart';
import 'navigazione.dart';
import 'obiettivo.dart';
import 'percorso.dart';
import 'potenza.dart';
import 'profilo.dart';
import 'recupero.dart';
import 'registro_forza.dart';
import 'scheda.dart';
import 'sessioni_eliminate.dart';
import 'serie_sessione.dart';
import 'sincronizzazione.dart';
import 'storage.dart';
import 'workout_base.dart';

/// Sport ignorati dall'app (non mostrati né importati).
const sportEsclusi = {'Altro'};

/// La settimana con cui si parte. Chi installa l'app parte da zero e la sceglie
/// nel benvenuto. Solo chi aveva già un piano e non ha mai salvato la settimana
/// tiene quella che usava prima, altrimenti la perderebbe aggiornando.
List<Slot> settimanaDiPartenza(List<Slot>? salvata, {required bool conPiano}) =>
    salvata ?? (conPiano ? _settimanaDiPrima() : []);

List<Slot> _settimanaDiPrima() => [
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

  /// Passi degli allenamenti scritti dall'assistente (allenamenti_agente.csv):
  /// valgono al posto di quelli preparati dall'app in quel giorno.
  List<WorkoutStep> allenamentiAgente = [];

  /// La raccolta degli allenamenti di arrampicata (allenamenti_arrampicata.csv).
  List<AllenamentoArrampicata> allenamentiArrampicata = [];
  List<ProgrammaRiga> programma = [];
  Profilo profilo = Profilo();
  List<Misura> misure = []; // in ordine di data
  String cartella = ''; // cartella privata dell'app (per la foto)
  List<Esercizio> esercizi = []; // catalogo, dagli asset dell'app
  Attrezzatura attrezzatura = {};
  List<FeedbackSessione> feedback = []; // in ordine di data
  List<SerieFatta> serieFatte = []; // ripetizioni e kg della forza

  /// Intervalli corretti a mano, per id della sessione.
  Map<String, List<IntervalloFatto>> intervalliModificati = {};
  List<SedutaArrampicata> arrampicate = []; // vie, blocchi e gradi
  List<SedutaNuoto> nuotate = []; // vasche e tempi scritti a mano
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
    await Storage.pulisciTemporanei();
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
    settimana = settimanaDiPartenza(
      await Storage.readSettimana(),
      conPiano: piano.isNotEmpty,
    );

    // Una riga illeggibile si salta: non deve impedire di aprire l'app.
    Sessione? riga(Tabella t, List<String> r) {
      try {
        return Sessione.da(t, r);
      } catch (e) {
        debugPrint('Sessione scartata: $e');
        return null;
      }
    }

    List<Sessione> leggiSessioni(Tabella? t) => t == null
        ? []
        : t.righe
              .map((r) => riga(t, r))
              .whereType<Sessione>()
              .where((s) => !sportEsclusi.contains(s.sport))
              .toList();
    storicoCsv = leggiSessioni(await Storage.readTabella('sessioni.csv'));
    sessioniModificate = {
      for (final s in leggiSessioni(await Storage.readTabella(_fileModificate)))
        s.id: s,
    };
    sessioniHc = leggiSessioni(
      await Storage.readTabella('health_connect_sessioni.csv'),
    ).map(riparaFonte).toList();
    infoSync = InfoSync.da(await Storage.readTabella('health_connect.csv'));
    await _caricaIntervals();
    backupAuto = await leggiImpostazioniBackup();
    final tInviate = await Storage.readTabella('sessioni_inviate.csv');
    inviate = {
      if (tInviate != null)
        for (final r in tInviate.righe)
          if (tInviate.v(r, 'id_sessione') case final id when id.isNotEmpty)
            id: tInviate.v(r, 'id_intervals'),
    };
    await _caricaPercorsi();
    final tNascoste = await Storage.readTabella('sessioni_nascoste.csv');
    nascoste = {
      if (tNascoste != null)
        for (final r in tNascoste.righe)
          if (tNascoste.v(r, 'id_sessione') case final id when id.isNotEmpty)
            id,
    };
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

    final tAllArr = await Storage.readTabella(fileAllenamentiArrampicata);
    allenamentiArrampicata = [
      if (tAllArr != null)
        for (final r in tAllArr.righe)
          ?AllenamentoArrampicata.daRiga(tAllArr, r),
    ];

    final ta = await Storage.readTabella(fileAllenamentiAgente);
    // Quelli di più di due mesi fa non servono più.
    final daTenere = soloData(DateTime.now())
        .subtract(const Duration(days: 60));
    allenamentiAgente = [
      if (ta != null)
        for (final r in ta.righe)
          if (WorkoutStep.da(ta, r) case final w?)
            if (!(_dataAgente(w.id)?.isBefore(daTenere) ?? true)) w,
    ];

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
    final tInt = await Storage.readTabella('intervalli_modificati.csv');
    intervalliModificati = tInt == null ? {} : intervalliModificatiDa(tInt);
    final tNuoto = await Storage.readTabella('nuoto.csv');
    nuotate = tNuoto == null
        ? []
        : tNuoto.righe
              .map((r) => SedutaNuoto.da(tNuoto, r))
              .whereType<SedutaNuoto>()
              .toList();
    final tArr = await Storage.readTabella('arrampicata.csv');
    arrampicate = tArr == null
        ? []
        : (tArr.righe
              .map((r) => SedutaArrampicata.da(tArr, r))
              .whereType<SedutaArrampicata>()
              .toList()
            ..sort((a, b) => a.data.compareTo(b.data)));
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

    // Aveva già l'app quando non si sceglievano: valgono quelle dei suoi dati.
    if (profilo.attivita.isEmpty) {
      final trovate = attivitaDaiDati(
        settimana: settimana,
        piano: piano,
        sessioni: sessioni,
        generati: profilo.sportGenerati,
        forza: profilo.obiettivo.isNotEmpty,
        arrampicata:
            arrampicate.isNotEmpty || allenamentiArrampicata.isNotEmpty,
      );
      if (trovate.isNotEmpty) {
        profilo.attivita = trovate;
        await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
      }
    }

    // Le sedute future seguono sempre i feedback e i dati più recenti.
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Le attività di chi usa l'app (nessuna scelta fatta: tutte).
  Set<String> get attivitaScelte =>
      profilo.attivita.isEmpty ? attivitaDaScegliere.toSet() : profilo.attivita;

  bool attivitaScelta(String sport) =>
      attivitaScelte.contains(normSport(sport));

  /// Gli sport dei menu del piano.
  List<String> get sportScelti => sportDeiMenu(profilo.attivita);

  /// Cambia le attività scelte. Le sedute future di quelle tolte escono dal
  /// calendario e dalla settimana tipo; quello che è stato fatto resta.
  Future<void> impostaAttivita(Set<String> nuove) async {
    final tolte = attivitaScelte.difference(nuove);
    profilo.attivita = nuove;
    if (tolte.isNotEmpty) {
      final oggi = soloData(DateTime.now());
      piano = senzaSedute(
        piano,
        tolte,
        oggi,
        (r) => sessioni.any(
          (s) => s.data == r.data && stessoSport(s.sport, r.sport),
        ),
      );
      await Storage.writePiano(piano);
      settimana = [
        for (final s in settimana)
          if (!tolte.contains(normSport(s.sport))) s,
      ];
      await Storage.writeSettimana(settimana);
      profilo.sportGenerati = profilo.sportGenerati.difference(tolte);
      if (profilo.sportGenerati.isEmpty) profilo.inizioEndurance = null;
      if (tolte.contains('Forza') && profilo.obiettivo.isNotEmpty) {
        await disattivaForza();
      }
    }
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    _ricombina();
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Mette un'attività nel calendario nei giorni della settimana scelti (1 =
  /// lunedì), fino alla fine del piano, e ne prepara i passi se l'app li sa
  /// scrivere. L'arrampicata no: l'allenamento lo sceglie chi arrampica.
  Future<void> aggiungiAlCalendario(
    String sport,
    Set<int> giorni,
    int minuti,
  ) async {
    if (giorni.isEmpty) return;
    final oggi = soloData(DateTime.now());
    final minimo = oggi.add(const Duration(days: 90));
    final u = ultimoGiornoPiano;
    final slot = [
      for (final g in giorni)
        Slot(giorno: g, fascia: 'Mattina', sport: sport, durataMin: minuti),
    ];
    piano = conSeduteNuove(
      piano,
      slot,
      oggi,
      u != null && u.isAfter(minimo) ? u : minimo,
    );
    await Storage.writePiano(piano);
    // La settimana tipo è facoltativa: non nasce da sola per un solo sport.
    if (settimana.isNotEmpty) {
      settimana = [
        ...settimana,
        for (final s in slot)
          if (!settimana.any(
            (x) => x.giorno == s.giorno && stessoSport(x.sport, sport),
          ))
            s,
      ];
      await Storage.writeSettimana(settimana);
    }
    _ricombina();
    if (stessoSport(sport, 'Forza')) {
      await creaPianoForza(
        profilo.obiettivo.isEmpty ? 'generale' : profilo.obiettivo,
        profilo.livello.isEmpty ? 'intermedio' : profilo.livello,
      );
    } else if (sportEndurance.contains(sport) || sport == sportMobilita) {
      await creaPianoEndurance({...profilo.sportGenerati, sport});
    }
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
    final id = idAllenamentoAgente(d, sport);
    final suMisura = allenamentiAgente.where((w) => w.id == id).toList();
    if (suMisura.isNotEmpty) {
      return suMisura..sort((a, b) => a.ordine.compareTo(b.ordine));
    }
    final prog = programma
        .where((p) => p.data == d && stessoSport(p.sport, sport))
        .toList();
    final idApp = prog.isEmpty
        ? workoutPredefinito(d, sport, tipo)
        : prog.first.idWorkout;
    if (idApp == null) {
      return stessoSport(sport, 'Arrampicata')
          ? passiLiberi('Arrampicata', titoloSessione('Arrampicata', tipo))
          : const [];
    }
    var passi = workout.where((w) => w.id == idApp).toList();
    if (passi.isEmpty) {
      passi = workoutBase.where((w) => w.id == idApp).toList();
    }
    return passi..sort((a, b) => a.ordine.compareTo(b.ordine));
  }

  /// Registra un allenamento fatto con la modalità allenamento, per chi non ha
  /// un orologio collegato. Una seduta dello stesso giorno e sport la sostituisce.
  Future<void> registraSvolta(Sessione s) async {
    final prima = storicoCsv.where((x) => x.id == s.id).firstOrNull;
    // Un'altra seduta con lo stesso id: per intervals.icu è un'attività nuova.
    if (prima != null &&
        prima.inizio != s.inizio &&
        inviate.containsKey(s.id)) {
      inviate = {...inviate}..remove(s.id);
      await _salvaInviate();
    }
    // Una nuotata nuova con lo stesso id non eredita le vasche di prima.
    if (prima != null && prima.inizio != s.inizio && nuotoDi(s.id) != null) {
      nuotate = nuotate.where((x) => x.idSessione != s.id).toList();
      await _salvaNuotate();
    }
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

  /// Salva battito, potenza e cadenza registrati dai sensori durante
  /// l'allenamento, per i grafici.
  Future<void> salvaSerieApp(DateTime giorno, String sport, SerieSessione s) =>
      Storage.scriviTesto(fileSerieApp(giorno, sport), serieAppCsv(s));

  /// Le serie registrate dall'app per una sessione (vuote se non ci sono).
  Future<SerieSessione> serieApp(Sessione s) async {
    final t = await Storage.leggiTesto(fileSerieApp(s.data, s.sport));
    return t == null ? const SerieSessione() : serieAppDa(t);
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
  /// Con [daOggi] ("Inizia oggi") i giorni sono dal lunedì al venerdì e la
  /// prima seduta è anticipata a oggi.
  Future<int> configuraDaZero({
    required String nome,
    required List<String> sport,
    required int giorni,
    required int minuti,
    required String livello,
    bool daOggi = false,
  }) async {
    final oggi = soloData(DateTime.now());
    if (nome.trim().isNotEmpty) profilo.nome = nome.trim();
    profilo.benvenuto = true;
    profilo.attivita = sport.toSet();
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
    settimana = settimanaDa(
      sport: sport,
      giorni: giorni,
      minuti: minuti,
      feriali: daOggi,
    );
    await Storage.writeSettimana(settimana);
    await genera(oggi, 3);
    if (daOggi) {
      piano = conPrimaSedutaOggi(piano, oggi);
      await Storage.writePiano(piano);
    }
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
          // L'allenamento dell'assistente tiene il suo nome.
          if (_haAllenamentoAgente(r.data, r.sport)) return r;
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
  /// Backup automatico in una cartella scelta dall'utente (spento all'inizio).
  ImpostazioniBackup backupAuto = const ImpostazioniBackup();

  Future<void> impostaBackupAuto(ImpostazioniBackup b) async {
    backupAuto = b;
    await salvaImpostazioniBackup(b);
    notifyListeners();
  }

  /// Accende il backup automatico: fa scegliere la cartella e scrive subito
  /// il primo. Falso se la scelta è stata annullata.
  Future<bool> accendiBackupAuto() async {
    final c = await scegliCartellaBackup();
    if (c == null) return false;
    await impostaBackupAuto(
      backupAuto.copyWith(cartella: c.$1, nomeCartella: c.$2, errore: ''),
    );
    await backupAutomatico(subito: true);
    return true;
  }

  /// "Non ora" alla proposta del backup: torna più avanti.
  /// Con [aLungo] (spento apposta dal Profilo) aspetta subito il tempo lungo.
  Future<void> rimandaBackup({bool aLungo = false}) => impostaBackupAuto(
    ImpostazioniBackup(
      frequenza: backupAuto.frequenza,
      rimandato: DateTime.now(),
      rimandi: aLungo ? 2 : backupAuto.rimandi + 1,
    ),
  );

  /// All'apertura: scrive il backup se è ora. Con [subito], comunque.
  Future<void> backupAutomatico({bool subito = false}) async {
    if (!backupAuto.attivo) return;
    if (!subito && !backupDovuto(backupAuto, DateTime.now())) return;
    await impostaBackupAuto(
      await scriviBackupAuto(backupAuto, await creaFileBackup()),
    );
  }

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
  /// Ripristina il backup. Se i dati nuovi non si caricano (backup rovinato)
  /// torna ai dati di prima e lancia [FormatException].
  Future<void> ripristinaBackup(DatiBackup b) async {
    final fotoPrima = fileFoto;
    final prima = await Storage.ripristina(b);
    try {
      await load();
    } catch (e) {
      debugPrint('Ripristino: dati non caricabili ($e), torno a prima');
      await Storage.rimetti(prima);
      await load();
      throw const FormatException(
        'Il backup è rovinato: i tuoi dati sono rimasti quelli di prima.',
      );
    }
    if (fotoPrima != null &&
        b.nomeFoto != profilo.foto &&
        await fotoPrima.exists()) {
      await fotoPrima.delete();
    }
    chat = [];
    promemoriaChiuso = false;
    fcRiposoMisurata = 0;
    notifyListeners();
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
    ftp: zonePotenza?.ftp,
    passoCritico: passoCritico,
    sessioni: sessioni,
    piano: piano,
    feedback: feedback,
    recupero: recupero,
    sportGenerati: profilo.sportGenerati,
    attivita: profilo.attivita,
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
      final r = leggiProposta(risposta);
      final p = r.proposta;
      chat = [
        ...chat,
        MessaggioChat(
          false,
          r.testo,
          proposta: p?.modifiche,
          piano: p?.piano,
          allenamenti: p?.allenamenti,
          arrampicata: p?.arrampicata,
          motivo: p?.motivo ?? '',
          errore: r.errore,
        ),
      ];
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

  /// Mette nel calendario gli allenamenti dell'assistente (da oggi in poi),
  /// al posto della seduta dello stesso sport in quel giorno. Restituisce
  /// quanti ne ha messi.
  Future<int> applicaAllenamentiAgente(
    List<AllenamentoAgente> lista, {
    MessaggioChat? da,
  }) async {
    final oggi = soloData(DateTime.now());
    final validi = lista.where((a) => !a.data.isBefore(oggi)).toList();
    if (validi.isEmpty) return 0;
    for (final a in validi) {
      final id = idAllenamentoAgente(a.data, a.sport);
      allenamentiAgente = [
        ...allenamentiAgente.where((w) => w.id != id),
        ...a.passi,
      ];
      piano = pianoCon(piano, a);
    }
    await _attivitaDalPiano();
    await Storage.write(
      fileAllenamentiAgente,
      workoutHeader,
      allenamentiAgente.map((w) => w.toRow()).toList(),
    );
    await Storage.writePiano(piano);
    _ricombina();
    await _aggiornaEndurance();
    _segnaApplicata(da);
    notifyListeners();
    // Subito anche nel calendario di intervals.icu (e da lì a Garmin).
    if (invioIntervals) await inviaPianoIntervals();
    return validi.length;
  }

  // ---------------------------------------------------------------------
  // Allenamenti di arrampicata

  Future<void> _salvaArrampicata() => Storage.write(
    fileAllenamentiArrampicata,
    allenamentiArrampicataHeader,
    allenamentiArrampicata.map((a) => a.toRow()).toList(),
  );

  /// Aggiunge un allenamento alla raccolta, o lo aggiorna se c'è già.
  Future<void> salvaAllenamentoArrampicata(AllenamentoArrampicata a) async {
    final i = allenamentiArrampicata.indexWhere((x) => x.id == a.id);
    allenamentiArrampicata = [...allenamentiArrampicata];
    if (i >= 0) {
      allenamentiArrampicata[i] = a;
    } else {
      allenamentiArrampicata.add(a);
    }
    await _salvaArrampicata();
    notifyListeners();
  }

  Future<void> eliminaAllenamentoArrampicata(String id) async {
    allenamentiArrampicata = [
      for (final a in allenamentiArrampicata)
        if (a.id != id) a,
    ];
    await _salvaArrampicata();
    notifyListeners();
  }

  /// Mette l'allenamento nel calendario quel giorno, al posto della seduta
  /// di arrampicata (o in più). False se il giorno è passato.
  Future<bool> programmaArrampicata(
    AllenamentoArrampicata a,
    DateTime data, {
    String fascia = '',
  }) async =>
      await applicaAllenamentiAgente([a.perIlGiorno(data, fascia: fascia)]) > 0;

  /// Le proposte dell'assistente: tutte nella raccolta (uno con lo stesso
  /// nome si aggiorna), quelle con la data anche nel calendario.
  /// Restituisce (salvati, nel calendario).
  Future<(int, int)> applicaProposteArrampicata(
    List<PropostaArrampicata> proposte, {
    MessaggioChat? da,
  }) async {
    final lista = [...allenamentiArrampicata];
    final perIlCalendario = <AllenamentoAgente>[];
    for (final p in proposte) {
      final i = lista.indexWhere(
        (x) => x.nome.toLowerCase() == p.allenamento.nome.toLowerCase(),
      );
      final a = i >= 0
          ? AllenamentoArrampicata(
              id: lista[i].id,
              nome: p.allenamento.nome,
              categoria: p.allenamento.categoria,
              tipi: p.allenamento.tipi,
              durataMin: p.allenamento.durataMin,
              descrizione: p.allenamento.descrizione,
              daSegnare: p.allenamento.daSegnare,
              esercizi: p.allenamento.esercizi,
            )
          : p.allenamento;
      if (i >= 0) {
        lista[i] = a;
      } else {
        lista.add(a);
      }
      if (p.data case final d?) {
        perIlCalendario.add(a.perIlGiorno(d, fascia: p.fascia));
      }
    }
    allenamentiArrampicata = lista;
    await _salvaArrampicata();
    final messi = perIlCalendario.isEmpty
        ? 0
        : await applicaAllenamentiAgente(perIlCalendario, da: da);
    _segnaApplicata(da);
    notifyListeners();
    return (proposte.length, messi);
  }

  /// Proposta applicata: nel messaggio della chat del coach, oppure nella
  /// risposta dell'assistente esterno.
  void _segnaApplicata(MessaggioChat? da) {
    if (da != null) {
      da.applicata = true;
    } else {
      rispostaApplicata = true;
    }
  }

  bool _haAllenamentoAgente(DateTime d, String sport) {
    final id = idAllenamentoAgente(d, sport);
    return allenamentiAgente.any((w) => w.id == id);
  }

  /// La data nell'id "agente-AAAA-MM-GG-sport".
  static DateTime? _dataAgente(String id) =>
      id.length >= 17 ? parseData(id.substring(7, 17)) : null;

  /// Controlli sul piano nuovo dell'agente, sul piano e le sessioni di adesso.
  EsitoPiano valutaPianoDa(PianoAgente p) => valutaPianoAgente(
    piano: piano,
    sessioni: sessioni,
    proposta: p,
    oggi: DateTime.now(),
  );

  /// Un piano accettato con uno sport non ancora scelto: lo si è voluto, quindi
  /// quello sport ora si vede anche nei menu.
  Future<void> _attivitaDalPiano() async {
    if (profilo.attivita.isEmpty) return;
    final oggi = soloData(DateTime.now());
    final nel = attivitaDaiDati(
      settimana: const [],
      piano: piano.where((r) => !r.data.isBefore(oggi)).toList(),
      sessioni: const [],
      generati: const {},
      forza: false,
      arrampicata: false,
    );
    if (nel.difference(profilo.attivita).isEmpty) return;
    profilo.attivita = {...profilo.attivita, ...nel};
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
  }

  /// Le sedute decise dall'assistente devono poter partire: attiva la
  /// preparazione dei loro sport, così l'app ne scrive i passi.
  Future<void> _attivaSportDelPiano() async {
    await _attivitaDalPiano();
    final oggi = soloData(DateTime.now());
    final nuovi = sportDaAttivare(piano, profilo.sportGenerati, oggi);
    if (nuovi.isEmpty) return;
    if (profilo.inizioEndurance == null || profilo.sportGenerati.isEmpty) {
      profilo.inizioEndurance = oggi;
    }
    profilo.sportGenerati = {...profilo.sportGenerati, ...nuovi};
    await Storage.write('profilo.csv', profiloHeader, profilo.toRows());
  }

  /// Sostituisce il calendario dalla data del piano nuovo (ricontrollato).
  Future<int> applicaPianoAgente(PianoAgente p, {MessaggioChat? da}) async {
    final esito = valutaPianoDa(p);
    if (!esito.applicabile) return 0;
    piano = esito.piano;
    await Storage.writePiano(piano);
    _ricombina();
    await _attivaSportDelPiano();
    await _aggiornaForza();
    await _aggiornaEndurance();
    _segnaApplicata(da);
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
    await _attivaSportDelPiano();
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

  /// Zone di potenza della bici: dall'FTP scritto a mano o da quello di
  /// intervals.icu. Null se non si conosce l'FTP.
  ZonePotenza? get zonePotenza {
    final ftp = profilo.ftpManuale > 0 ? profilo.ftpManuale : ftpIcu;
    return ftp > 0 ? ZonePotenza(ftp) : null;
  }

  /// La stima dell'FTP di corsa da peso, età e sesso (null senza il peso).
  int? get stimaFtpDiCorsa => stimaFtpCorsa(
    pesoKg: ultimaMisura('peso_kg')?.$1,
    eta: profilo.eta,
    sesso: profilo.sesso,
  );

  /// Vero se l'FTP di corsa è solo la stima: nessun numero scritto o arrivato.
  bool get ftpCorsaStimata => profilo.ftpCorsaManuale <= 0 && ftpCorsaIcu <= 0;

  /// Zone di potenza della corsa: FTP scritto, di intervals.icu o la stima.
  ZonePotenza? get zonePotenzaCorsa {
    final ftp = profilo.ftpCorsaManuale > 0
        ? profilo.ftpCorsaManuale
        : ftpCorsaIcu > 0
        ? ftpCorsaIcu
        : stimaFtpDiCorsa;
    return ftp == null ? null : ZonePotenza.corsa(ftp);
  }

  /// Le zone di potenza di uno sport: solo bici e corsa ne hanno.
  ZonePotenza? zonePotenzaDi(String sport) => stessoSport(sport, 'Bici')
      ? zonePotenza
      : stessoSport(sport, 'Corsa')
      ? zonePotenzaCorsa
      : null;

  /// Scrive l'FTP di corsa, per esempio dal risultato del test.
  Future<void> impostaFtpCorsa(int watt) async {
    profilo.ftpCorsaManuale = watt;
    await salvaProfilo();
    notifyListeners();
  }

  /// Mette il test dell'FTP di corsa nel calendario di quel giorno.
  Future<bool> programmaTestFtpCorsa(DateTime data) async =>
      await applicaAllenamentiAgente([
        AllenamentoAgente(
          data: soloData(data),
          sport: 'Corsa',
          tipo: 'Test FTP',
          nome: nomeTestFtpCorsa,
          fascia: '',
          passi: passiTestFtpCorsa(idAllenamentoAgente(data, 'Corsa')),
          durataIndicata: 50,
        ),
      ], da: MessaggioChat(false, '')) >
      0;

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
      lungo: tipoLungo(r.tipo) || passi.any((p) => tipoLungo(p.nome)),
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
    // Le tolte si filtrano dopo aver unito i doppioni: così non spunta al loro
    // posto la copia della stessa attività arrivata da un'altra fonte.
    final copie = senzaCopieInviate(sessioniIcu, inviate, storicoCsv);
    final hc = senzaDoppioniIcu(sessioniHc, copie);
    final icu = icuSenzaDoppioniHc(copie, hc);
    sessioni = [
      for (final s in senzaNascoste(
        combina(storicoCsv, conTipoDalPiano([...hc, ...icu], piano)),
        nascoste,
      ).where((s) => !sportEsclusi.contains(s.sport)))
        _conCorrezioni(s),
    ];
  }

  /// Quello che è scritto a mano vince su quello che arriva dall'orologio.
  Sessione _conCorrezioni(Sessione s) {
    final o = sessioniModificate[s.id];
    final c = o == null
        ? s
        : sessioneModificata(
            s,
            inizio: o.inizio ?? s.inizio ?? s.data,
            durataMin: o.durataMin,
            distanzaKm: o.distanzaKm,
            fcMedia: o.fcMedia,
            fcMax: o.fcMax,
            calorie: o.calorieAttive,
            rpe: o.rpe,
            note: o.note,
          );
    final nome = ritocchi[s.id]?.nome ?? '';
    return nome.isEmpty ? c : c.copyWith(tipo: nome);
  }

  static const _fileModificate = 'sessioni_modificate.csv';

  /// Sessioni dell'orologio corrette a mano, per id: non si perdono quando
  /// l'orologio manda di nuovo i suoi dati.
  Map<String, Sessione> sessioniModificate = {};

  Future<void> _salvaModificate() => Storage.write(
    _fileModificate,
    sessioniHeader,
    sessioniModificate.values.map((x) => x.toRow()).toList(),
  );

  /// Toglie le correzioni: tornano i dati arrivati dall'orologio.
  Future<void> annullaCorrezioni(String id) async {
    sessioniModificate = {...sessioniModificate}..remove(id);
    await _salvaModificate();
    _ricombina();
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Nome e "al chiuso" scritti a mano sulle sessioni, per id.
  Map<String, RitoccoSessione> ritocchi = {};

  /// Sessioni dell'orologio tolte dallo storico (id): non tornano più.
  Set<String> nascoste = {};

  /// Toglie una sessione dallo storico, con il suo feedback. Restituisce la
  /// funzione che la rimette com'era (per "Annulla").
  Future<Future<void> Function()> eliminaSessione(Sessione s) async {
    final prima = (storico: storicoCsv, nascoste: nascoste, feedback: feedback);
    final dopo = togliSessione(
      s,
      storico: storicoCsv,
      nascoste: nascoste,
      feedback: feedback,
    );
    await _salvaStorico(dopo.storico, dopo.nascoste, dopo.feedback);
    return () => _salvaStorico(prima.storico, prima.nascoste, prima.feedback);
  }

  Future<void> _salvaStorico(
    List<Sessione> storico,
    Set<String> tolte,
    List<FeedbackSessione> fb,
  ) async {
    storicoCsv = storico;
    nascoste = tolte;
    feedback = fb;
    await Storage.write(
      'sessioni.csv',
      sessioniHeader,
      storicoCsv.map((x) => x.toRow()).toList(),
    );
    await Storage.write('sessioni_nascoste.csv', nascosteHeader, [
      for (final id in nascoste) [id],
    ]);
    await Storage.write(
      'feedback.csv',
      feedbackHeader,
      feedback.map((x) => x.toRow()).toList(),
    );
    _ricombina();
    await _aggiornaForza();
    await _aggiornaEndurance();
    notifyListeners();
  }

  bool alChiuso(Sessione s) =>
      ritocchi[s.id]?.alChiuso ?? icuAlChiuso.contains(s.id);

  // ---------------------------------------------------------------------
  // intervals.icu (attività complete da Garmin, Polar, Suunto…)

  List<Sessione> sessioniIcu = [];
  Set<String> icuAlChiuso = {}; // rulli e tapis roulant, da intervals.icu
  bool intervalsCollegato = false;

  /// Sessioni registrate dall'app già mandate a intervals.icu (id → id là).
  Map<String, String> inviate = {};

  /// Il percorso registrato dall'app per questa sessione, se c'è e se è suo:
  /// il file è uno per giorno e sport, quindi l'orario deve combaciare.
  Future<Percorso?> percorsoApp(Sessione s) async {
    final t = await Storage.leggiTesto(filePercorsoApp(s.data, s.sport));
    if (t == null) return null;
    final p = Percorso.daCsv(t);
    if (p.vuoto) return null;
    final a = s.inizio, b = s.fine;
    if (a != null && b != null) {
      const margine = Duration(minutes: 5);
      final primo = p.punti.first.t;
      if (primo.isBefore(a.subtract(margine)) ||
          primo.isAfter(b.add(margine))) {
        return null;
      }
    }
    return p;
  }

  /// GPX della sessione registrata dall'app, da salvare o condividere.
  Future<String?> gpxSessione(Sessione s) async {
    if (alChiuso(s)) return null;
    final p = await percorsoApp(s);
    if (p == null) return null;
    return gpxDa(
      p,
      nome: nomeAttivita(s, ritocchi[s.id]?.nome ?? ''),
      sport: s.sport,
    );
  }

  /// Manda a intervals.icu una sessione registrata dall'app: col percorso
  /// come GPX (c'è la mappa), senza come attività con tempo, km e battito.
  Future<String> inviaSessioneIntervals(Sessione s) async {
    final chiave = await ChiaveIntervals.leggi();
    if (chiave == null) {
      return 'Collega prima intervals.icu da Profilo → Dati e collegamenti.';
    }
    if (inviate.containsKey(s.id)) return 'Già inviata a intervals.icu.';
    final nome = nomeAttivita(s, ritocchi[s.id]?.nome ?? '');
    try {
      final client = ClientIntervals(chiave);
      final gpx = await gpxSessione(s);
      final id = gpx != null
          ? await client.caricaGpx(
              gpx,
              nomeFile: nomeFileGpx(s),
              nome: nome,
              idEsterno: idEsterno(s),
            )
          : await client.creaAttivita(
              attivitaManuale(s, nome: nome, alChiuso: alChiuso(s)),
            );
      inviate = {...inviate, s.id: id ?? ''};
      await _salvaInviate();
      notifyListeners();
      return 'Inviata a intervals.icu.';
    } on ErroreIntervals catch (e) {
      return e.messaggio;
    }
  }

  Future<void> _salvaInviate() =>
      Storage.write('sessioni_inviate.csv', inviateHeader, [
        for (final e in inviate.entries) [e.key, e.value],
      ]);

  /// Come arriva a intervals.icu questa sessione.
  InvioSessione invioSessione(Sessione s) => invioDi(
    s,
    collegato: intervalsCollegato,
    inviata: inviate.containsKey(s.id),
    invioDal: invioIntervals ? invioDal : null,
  );

  bool _inviandoSedute = false;

  /// Manda da sole le sedute registrate dall'app con l'invio acceso. Parte da
  /// [sessioni]: così quelle già arrivate dall'orologio non si mandano due
  /// volte. Senza rete si ferma e riprova alla prossima apertura.
  Future<void> inviaSeduteFatte() async {
    if (_inviandoSedute) return;
    _inviandoSedute = true;
    try {
      final daMandare = sessioni
          .where((s) => invioSessione(s) == InvioSessione.automatico)
          .toList();
      for (final s in daMandare) {
        await inviaSessioneIntervals(s);
        if (!inviate.containsKey(s.id)) break;
      }
    } finally {
      _inviandoSedute = false;
    }
  }

  /// A fine allenamento: prima legge le attività (se l'orologio ha registrato
  /// la stessa seduta non serve mandarla), poi manda quella dell'app.
  Future<void> inviaDopoAllenamento() async {
    if (invioIntervals) await sincronizzaIntervals();
  }

  DateTime? ultimaIntervals;
  String? erroreIntervals;
  bool sincronizzandoIntervals = false;

  /// Invio del piano (corsa, bici, nuoto) al calendario di intervals.icu.
  bool invioIntervals = false;
  DateTime? ultimoInvio;

  /// Quando è stato acceso l'invio: da lì in poi le sedute partono da sole.
  DateTime? invioDal;

  /// FTP della bici letto da intervals.icu (0 = non arrivato).
  int ftpIcu = 0;

  /// FTP della corsa letto da intervals.icu (0 = non arrivato).
  int ftpCorsaIcu = 0;
  List<EventoInviato> inviatiIcu = [];
  String? erroreInvio;
  bool inviando = false;
  static const _fileInviati = 'intervals_inviati.csv';

  /// Le regole con cui sono state lette le attività di intervals.icu.
  int _regoleIcu = 0;

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
    ftpIcu = int.tryParse(m['ftp'] ?? '') ?? 0;
    ftpCorsaIcu = int.tryParse(m['ftp_corsa'] ?? '') ?? 0;
    _regoleIcu = int.tryParse(m['regole'] ?? '') ?? 0;
    invioDal = DateTime.tryParse(m['invio_dal'] ?? '');
    // Acceso con una versione di prima: le sedute già fatte restano a mano.
    if (invioIntervals && invioDal == null) {
      invioDal = DateTime.now();
      await _salvaIntervals();
    }
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
        ['ftp', ftpIcu == 0 ? '' : '$ftpIcu'],
        ['ftp_corsa', ftpCorsaIcu == 0 ? '' : '$ftpCorsaIcu'],
        ['invio_dal', invioDal?.toIso8601String() ?? ''],
        ['regole', '$_regoleIcu'],
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
      final da = ultimaIntervals == null || _regoleIcu != versioneRegoleIcu
          ? oggi.subtract(const Duration(days: 90))
          : soloData(ultimaIntervals!).subtract(const Duration(days: 3));
      final nuove = await ClientIntervals(chiave).attivita(da, oggi);
      try {
        // L'FTP serve alle zone di potenza; se non arriva si tiene il vecchio.
        final soglie = await ClientIntervals(chiave).soglie();
        ftpIcu = soglie.bici ?? ftpIcu;
        ftpCorsaIcu = soglie.corsa ?? ftpCorsaIcu;
      } on ErroreIntervals {
        // Le attività sono arrivate: va bene lo stesso.
      }
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
      _regoleIcu = versioneRegoleIcu;
      erroreIntervals = null;
      await _salvaIntervals();
      _ricombina();
      await _aggiornaEndurance();
      final letto = '${nuove.length} attività lette da intervals.icu.';
      if (!invioIntervals) return letto;
      sincronizzandoIntervals = false;
      await inviaSeduteFatte();
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
          potenza: zonePotenza != null,
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
    invioDal = attivo ? DateTime.now() : null;
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
    invioDal = null;
    ultimoInvio = null;
    await ChiaveIntervals.elimina();
    intervalsCollegato = false;
    ultimaIntervals = null;
    erroreIntervals = null;
    sessioniIcu = [];
    icuAlChiuso = {};
    ftpIcu = 0;
    ftpCorsaIcu = 0;
    await _salvaIntervals();
    _ricombina();
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Tutte le serie di una sessione per i grafici: da intervals.icu se c'è,
  /// altrimenti da Health Connect, con i sensori collegati all'app e la
  /// velocità dal GPS se manca.
  Future<SerieSessione> serieDi(Sessione s) async {
    // Da intervals.icu: tutti i dati dell'orologio (anche quota e potenza).
    final icu = await serieIcu(s);
    if (icu != null && !icu.vuota) return icu;
    var serie = const SerieSessione();
    if (s.inizio != null && s.fine != null && s.origine.isNotEmpty) {
      // Con Freeletics il battito arriva dall'orologio: niente filtro sull'app.
      serie = await hc.serie(
        s.inizio!,
        s.fine!,
        origine: daFreeletics(s) ? '' : s.origine,
        conPassi: siCammina(s.sport),
      );
    }
    // Battito, potenza, cadenza e velocità dai sensori collegati all'app
    // (rulli, misuratore di potenza, fascia cardio).
    final app = await serieApp(s);
    if (!app.vuota) {
      serie = SerieSessione(
        fc: serie.fc.isEmpty ? app.fc : serie.fc,
        velocita: serie.velocita.isEmpty ? app.velocita : serie.velocita,
        potenza: app.potenza,
        // Quella di Health Connect resta, se i sensori non ne hanno una.
        cadenza: app.cadenza.isEmpty ? serie.cadenza : app.cadenza,
      );
    }
    if (serie.velocita.isEmpty && sportConPercorso(s.sport, s.tipo)) {
      final r = await percorsoDi(s);
      if (r.stato == StatoPercorso.dati && r.percorso != null) {
        serie = SerieSessione(
          fc: serie.fc,
          velocita: velocitaDaPercorso(r.percorso!),
          potenza: serie.potenza,
          cadenza: serie.cadenza,
        );
      }
    }
    return serie;
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

  /// Gli intervalli di un'attività (lavoro e recuperi): la copia sul telefono
  /// (anche i blocchi delle sedute registrate con l'app), altrimenti per
  /// quelle di intervals.icu dalla rete. Vuoti se non ci sono.
  Future<List<IntervalloFatto>> intervalliDi(Sessione s) async {
    // Corsa e bici dall'orologio: i giri veri, dal file originale.
    if (s.id.startsWith(prefissoIcu) && !stessoSport(s.sport, 'Nuoto')) {
      final giri = await _giriDi(s);
      if (giri.isNotEmpty) return giri;
    }
    final file = fileIntervalli(s.id);
    final t = await Storage.leggiTesto(file);
    if (t != null) return intervalliDaCsv(t);
    if (!s.id.startsWith(prefissoIcu)) return const [];
    final chiave = await ChiaveIntervals.leggi();
    if (chiave == null) return const [];
    try {
      final l = await ClientIntervals(chiave)
          .intervalli(s.id.substring(prefissoIcu.length));
      // Appena finita l'attività possono non esserci ancora: si riprova.
      if (l.isNotEmpty) await Storage.scriviTesto(file, intervalliCsv(l));
      return l;
    } on ErroreIntervals {
      return const [];
    }
  }

  /// I giri dell'orologio di un'attività di intervals.icu: la copia già
  /// letta, altrimenti dal file originale (una volta sola: se non ha giri si
  /// segna e non si riscarica).
  Future<List<IntervalloFatto>> _giriDi(Sessione s) async {
    final file = fileGiri(s.id);
    final t = await Storage.leggiTesto(file);
    if (t != null) return intervalliDaCsv(t);
    final chiave = await ChiaveIntervals.leggi();
    if (chiave == null) return const [];
    try {
      final giri = await ClientIntervals(chiave)
          .giriOrologio(s.id.substring(prefissoIcu.length));
      await Storage.scriviTesto(file, intervalliCsv(giri));
      return giri;
    } on ErroreIntervals {
      return const []; // senza rete: si riprova la prossima volta
    }
  }

  /// I blocchi di una seduta registrata con l'app, com'è andata davvero.
  Future<void> salvaIntervalliApp(
    String idSessione,
    List<IntervalloFatto> intervalli,
  ) async {
    if (intervalli.isEmpty) return;
    await Storage.scriviTesto(
      fileIntervalli(idSessione),
      intervalliCsv(intervalli),
    );
  }

  /// Salva gli intervalli corretti a mano di una sessione; con [nuovi] null
  /// si torna a quelli dell'orologio.
  Future<void> salvaIntervalli(
    String idSessione,
    List<IntervalloFatto>? nuovi,
  ) async {
    intervalliModificati = {...intervalliModificati}..remove(idSessione);
    if (nuovi != null) intervalliModificati[idSessione] = nuovi;
    await Storage.write(
      'intervalli_modificati.csv',
      intervalliModificatiHeader,
      [
        for (final e in intervalliModificati.entries)
          ...righeIntervalli(e.key, e.value),
      ],
    );
    notifyListeners();
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

  /// Tutte le serie di un giorno scritte a mano: sostituiscono quelle che
  /// c'erano, così un esercizio tolto sparisce davvero.
  Future<void> scriviSerieDel(DateTime giorno, List<SerieFatta> nuove) async {
    final d = soloData(giorno);
    serieFatte = [...serieFatte.where((s) => s.data != d), ...nuove];
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

  /// Vasche e tempi scritti a mano per una nuotata, se ci sono.
  SedutaNuoto? nuotoDi(String idSessione) =>
      nuotate.where((n) => n.idSessione == idSessione).firstOrNull;

  Future<void> _salvaNuotate() => Storage.write(
    'nuoto.csv',
    nuotoHeader,
    nuotate.map((x) => x.toRow()).toList(),
  );

  /// Salva i dati scritti a mano su una seduta: registrata con l'app, arrivata
  /// dall'orologio o nuova, di un giorno passato.
  Future<void> modificaSessione(Sessione s, {SedutaNuoto? nuoto}) async {
    final dellApp = storicoCsv.any((x) => x.id == s.id);
    if (!dellApp && sessioni.any((x) => x.id == s.id)) {
      sessioniModificate = {...sessioniModificate, s.id: s};
      await _salvaModificate();
    } else {
      storicoCsv = dellApp
          ? [for (final x in storicoCsv) x.id == s.id ? s : x]
          : [...storicoCsv, s];
      await Storage.write(
        'sessioni.csv',
        sessioniHeader,
        storicoCsv.map((x) => x.toRow()).toList(),
      );
    }
    if (nuoto != null) {
      nuotate = [
        ...nuotate.where((x) => x.idSessione != s.id),
        if (!nuoto.vuota) nuoto,
      ];
      await _salvaNuotate();
    }
    _ricombina();
    await _aggiornaEndurance();
    notifyListeners();
  }

  /// Salva (o sostituisce) la scheda dell'arrampicata di una seduta.
  Future<void> salvaArrampicata(SedutaArrampicata a) async {
    arrampicate = [...arrampicate.where((x) => x.idSessione != a.idSessione), a]
      ..sort((x, y) => x.data.compareTo(y.data));
    await Storage.write(
      'arrampicata.csv',
      arrampicataHeader,
      arrampicate.map((x) => x.toRow()).toList(),
    );
    notifyListeners();
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

  // ---------------------------------------------------------------------
  // Percorsi da seguire ("I miei percorsi")

  List<PercorsoSalvato> percorsiSalvati = [];

  /// Percorso assegnato a una seduta in programma: chiaveSeduta → id.
  Map<String, String> percorsiPiano = {};

  Future<void> _caricaPercorsi() async {
    final t = await Storage.readTabella('percorsi_salvati.csv');
    percorsiSalvati = [
      if (t != null)
        for (final r in t.righe) ?PercorsoSalvato.da(t, r),
    ];
    final ids = {for (final p in percorsiSalvati) p.id};
    final tp = await Storage.readTabella('percorsi_piano.csv');
    // Le sedute passate da più di un mese non servono più.
    final limite = soloData(DateTime.now()).subtract(const Duration(days: 30));
    percorsiPiano = {
      if (tp != null)
        for (final r in tp.righe)
          if (DateTime.tryParse(tp.v(r, 'data')) case final d?
              when !d.isBefore(limite) && ids.contains(tp.v(r, 'id_percorso')))
            chiaveSeduta(d, tp.v(r, 'sport')): tp.v(r, 'id_percorso'),
    };
  }

  Future<void> _salvaPercorsi() => Storage.write(
    'percorsi_salvati.csv',
    PercorsoSalvato.header,
    percorsiSalvati.map((p) => p.toRow()).toList(),
  );

  Future<void> _salvaPercorsiPiano() =>
      Storage.write('percorsi_piano.csv', percorsiPianoHeader, [
        for (final e in percorsiPiano.entries) [...e.key.split('|'), e.value],
      ]);

  /// Aggiunge una traccia alla raccolta (semplificata: la forma resta entro
  /// pochi metri, il file pesa molto meno).
  Future<PercorsoSalvato> aggiungiPercorso(Traccia t) async {
    final leggera = Traccia(t.nome, semplifica(t.punti, tolleranzaTraccia));
    final p = PercorsoSalvato(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      nome: t.nome,
      km: t.metri / 1000,
      dislivello: t.dislivello,
      aggiunto: soloData(DateTime.now()),
    );
    await Storage.scriviTesto(p.file, leggera.toCsvText());
    percorsiSalvati = [p, ...percorsiSalvati];
    await _salvaPercorsi();
    notifyListeners();
    return p;
  }

  Future<void> rinominaPercorso(String id, String nome) async {
    final pulito = nome.trim();
    if (pulito.isEmpty) return;
    percorsiSalvati = [
      for (final p in percorsiSalvati)
        p.id == id ? p.copyWith(nome: pulito) : p,
    ];
    await _salvaPercorsi();
    notifyListeners();
  }

  /// Toglie il percorso dalla raccolta e dalle sedute a cui era assegnato.
  Future<void> eliminaPercorso(String id) async {
    percorsiSalvati = percorsiSalvati.where((p) => p.id != id).toList();
    percorsiPiano = Map.of(percorsiPiano)..removeWhere((_, v) => v == id);
    await Storage.cancella(fileTraccia(id));
    await _salvaPercorsi();
    await _salvaPercorsiPiano();
    notifyListeners();
  }

  PercorsoSalvato? percorsoSalvato(String id) {
    for (final p in percorsiSalvati) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// I punti del percorso salvato (null se il file manca o è vuoto).
  Future<Traccia?> tracciaDi(PercorsoSalvato p) async {
    final testo = await Storage.leggiTesto(p.file);
    if (testo == null) return null;
    final t = Traccia.daCsv(p.nome, testo);
    return t.vuota ? null : t;
  }

  /// Il percorso da seguire nella seduta di quel giorno e sport, se c'è.
  PercorsoSalvato? percorsoDellaSeduta(DateTime giorno, String sport) {
    final id = percorsiPiano[chiaveSeduta(soloData(giorno), sport)];
    return id == null ? null : percorsoSalvato(id);
  }

  /// Assegna (o toglie, con null) il percorso a una seduta in programma.
  Future<void> assegnaPercorso(
    DateTime giorno,
    String sport,
    String? id,
  ) async {
    final chiave = chiaveSeduta(soloData(giorno), sport);
    percorsiPiano = Map.of(percorsiPiano);
    if (id == null) {
      percorsiPiano.remove(chiave);
    } else {
      percorsiPiano[chiave] = id;
    }
    await _salvaPercorsiPiano();
    notifyListeners();
  }
}
