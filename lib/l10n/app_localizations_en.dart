// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tenuto => 'On pace';

  @override
  String get poPiuLento => 'A bit slower';

  @override
  String get moltoPiuLento => 'Much slower';

  @override
  String principaleInvece(Object p0, Object p1) {
    return 'main set $p0 instead of $p1';
  }

  @override
  String passoInvece(Object p0, Object p1) {
    return 'pace $p0 instead of $p1';
  }

  @override
  String intensitaInvece(Object p0, Object p1) {
    return 'intensity $p0 instead of $p1';
  }

  @override
  String totaleMInveceM(Object p0, Object p1) {
    return 'total $p0 m instead of $p1 m';
  }

  @override
  String durataMinInvece(Object p0, Object p1) {
    return 'duration $p0 min instead of $p1';
  }

  @override
  String passoPiuLentoTarget(Object p0, Object p1, Object p2, Object p3) {
    return 'Pace $p0% slower than target (effort $p1, expected $p2): I\'m easing off the $p3.';
  }

  @override
  String faticaSopraAttesaAlleggerisco(Object p0, Object p1, Object p2) {
    return 'Effort $p0, above the expected ($p1): I\'m easing off the $p2.';
  }

  @override
  String faticaLineaAttesaProgressione(Object p0, Object p1) {
    return 'Effort $p0, in line with the expected ($p1): normal progression, one thing at a time.';
  }

  @override
  String faticaSottoAttesaPiccola(Object p0, Object p1) {
    return 'Effort $p0, below the expected ($p1): small progression.';
  }

  @override
  String dueSedutePesantiFila(Object p0) {
    return 'Two hard sessions in a row: recovery week for $p0.';
  }

  @override
  String get claudeImpostazioniPrivacyDisattiva =>
      'In Claude: Settings → Privacy → turn off \"Help improve Claude\".';

  @override
  String get chatgptImpostazioniControlliDati =>
      'In ChatGPT: Settings → Data controls → turn off \"Improve the model for everyone\".';

  @override
  String get geminiDisattivaAttivitaNelle =>
      'In Gemini: turn off \"Gemini Apps Activity\" (or \"Keep activity\") in your Google account.';

  @override
  String get controllaNelleImpostazioniDell =>
      'Check in the app settings whether chats are used to train the model and, if you like, turn it off.';

  @override
  String get nellaRispostaNonC =>
      'The reply has no block for the app. Ask the assistant to write the changes in the <avidididadi> format.';

  @override
  String get codiceNellaRispostaNon =>
      'The code in the reply is not the one for this phone: maybe it comes from an old link. Send the data again and retry.';

  @override
  String get bloccoNonLeggibileChiedi =>
      'The block can\'t be read. Ask the assistant to write it again.';

  @override
  String get dataInizioGiaPassata => 'The start date has already passed.';

  @override
  String get dataMancante => 'missing date';

  @override
  String get primaDellInizioPiano => 'before the start of the plan';

  @override
  String oltreSettimane(Object p0) {
    return 'beyond $p0 weeks';
  }

  @override
  String get sportNonPrevisto => 'sport not allowed';

  @override
  String get durataNonSensata => 'duration doesn\'t make sense';

  @override
  String dueSeduteStessoGiorno(Object p0) {
    return 'two $p0 sessions on the same day';
  }

  @override
  String settimanaMancaGiornoRiposo(Object p0) {
    return 'Week of $p0: a rest day is missing.';
  }

  @override
  String settimanaMinutiTroppiRispetto(Object p0, Object p1, Object p2) {
    return 'Week of $p0: $p1 minutes, too many compared with the previous weeks (at most $p2).';
  }

  @override
  String appNonHaAccettato(Object p0, Object p1) {
    return 'The app did not accept the plan for these reasons:\n$p0\nFix it and send it again in the <avidididadi> block with the code $p1.';
  }

  @override
  String get allenamentoNonHaData => 'A workout has no date.';

  @override
  String allenamentoSportDeveEssere(Object p0) {
    return 'Workout on $p0: the sport must be running, cycling or swimming.';
  }

  @override
  String allenamentoServono140(Object p0) {
    return 'Workout on $p0: it needs 1 to 40 steps.';
  }

  @override
  String allenamento(Object p0) {
    return '$p0 workout';
  }

  @override
  String allenamentoPassoServonoMinuti(Object p0, Object p1) {
    return 'Workout on $p0, step $p1: it needs the minutes (up to 300) or the meters.';
  }

  @override
  String allenamentoPassoRipetizioni1(Object p0, Object p1) {
    return 'Workout on $p0, step $p1: 1 to 30 repetitions and rest up to 1800 seconds.';
  }

  @override
  String allenamentoDuraPiu5(Object p0) {
    return 'Workout on $p0: it lasts more than 5 hours.';
  }

  @override
  String get trave => 'Hangboard';

  @override
  String get circuito => 'Circuit';

  @override
  String get campus => 'Campus';

  @override
  String get potenza => 'Power';

  @override
  String deveEssereNumero0(Object p0, Object p1, Object p2) {
    return '$p0: \"$p1\" must be a number from 0 to $p2.';
  }

  @override
  String mancaNome(Object p0) {
    return '$p0: the name is missing.';
  }

  @override
  String esercizio(Object p0) {
    return 'Exercise $p0';
  }

  @override
  String get allenamentoArrampicataNonHa => 'A climbing workout has no name.';

  @override
  String servono130Esercizi(Object p0) {
    return '\"$p0\": it needs 1 to 30 exercises.';
  }

  @override
  String esercizio2(Object p0, Object p1) {
    return '\"$p0\", exercise $p1';
  }

  @override
  String get recuperoTraSerie => 'Rest between sets';

  @override
  String riposaSerieDopo(Object p0) {
    return 'Rest: the next set is \"$p0\".';
  }

  @override
  String min(Object p0, Object p1) {
    return '$p0:$p1 min';
  }

  @override
  String dataNonValidaServe(Object p0) {
    return 'Invalid date: $p0 (use YYYY-MM-DD).';
  }

  @override
  String get nelBloccoNonCi => 'There are no climbing workouts in the block.';

  @override
  String get backupRovinatoTuoiDati =>
      'The backup is damaged: your data has stayed as it was.';

  @override
  String errore(Object p0) {
    return 'Error: $p0';
  }

  @override
  String get collegaPrimaIntervalsIcu =>
      'Connect intervals.icu first from Profile → Data and connections.';

  @override
  String get giaInviataIntervalsIcu => 'Already sent to intervals.icu.';

  @override
  String get inviataIntervalsIcu => 'Sent to intervals.icu.';

  @override
  String get incollaPrimaChiaveApi => 'Paste the API key first.';

  @override
  String get collegato => 'Connected';

  @override
  String collegatoCome(Object p0) {
    return 'Connected as $p0';
  }

  @override
  String get chiaveNonTrovataCollega =>
      'Key not found: connect intervals.icu again.';

  @override
  String attivitaLetteIntervalsIcu(Object p0) {
    return '$p0 activities read from intervals.icu.';
  }

  @override
  String get calendarioIntervalsIcuGia =>
      'The intervals.icu calendar is already up to date.';

  @override
  String get sedutaMandata => 'session sent';

  @override
  String get seduteMandate => 'sessions sent';

  @override
  String intervalsIcu(Object p0) {
    return '$p0 to intervals.icu.';
  }

  @override
  String seduteTolteDalCalendario(Object p0) {
    return '$p0 sessions removed from the intervals.icu calendar.';
  }

  @override
  String get sincronizzazioneGiaCorso => 'Sync already in progress.';

  @override
  String get healthConnectVaAggiornato =>
      'Health Connect needs an update: open it from the Play Store.';

  @override
  String get healthConnectNonInstallato =>
      'Health Connect is not installed on the phone.';

  @override
  String get healthConnectDisponibileSolo =>
      'Health Connect is only available on Android.';

  @override
  String get healthConnectNonAncora => 'Health Connect is not connected yet.';

  @override
  String get senzaPermessoSessioniAllenamento =>
      'Without permission for workout sessions I can\'t read anything. You can grant it from \"Review permissions\".';

  @override
  String get nessunaNovitaHealthConnect => 'Nothing new from Health Connect.';

  @override
  String sessioniNuove(Object p0) {
    return '$p0 new sessions';
  }

  @override
  String erroreDuranteSincronizzazione(Object p0) {
    return 'Error during sync: $p0';
  }

  @override
  String get feedbackSalvatoContaNel =>
      'Feedback saved: it counts toward your training load.';

  @override
  String get restaUguale => 'stays the same';

  @override
  String prossimaSeduta(Object p0, Object p1, Object p2) {
    return '$p0\n\nNext session ($p1): $p2.';
  }

  @override
  String get feedbackSalvato => 'Feedback saved.';

  @override
  String get fileVuotoONon => 'empty or invalid file.';

  @override
  String formatoNonRiconosciutoServono(Object p0) {
    return 'format not recognized: at least the date and sport columns are needed (found: $p0).';
  }

  @override
  String righeScartateDataO(Object p0) {
    return '$p0 rows skipped (missing date or sport)';
  }

  @override
  String ignorate(Object p0, Object p1) {
    return '$p0 ignored ($p1)';
  }

  @override
  String sessioniNuoveAggiornate(Object p0, Object p1, Object p2) {
    return '$p0 new sessions, $p1 updated$p2.';
  }

  @override
  String gradoPiuDifficile(Object p0, Object p1) {
    return 'Hardest grade: $p0$p1';
  }

  @override
  String get vieChiuse => 'routes sent';

  @override
  String get blocchiChiusi => 'problems sent';

  @override
  String circaMSaliti(Object p0) {
    return 'about $p0 m climbed';
  }

  @override
  String progetto(Object p0) {
    return 'Project: $p0';
  }

  @override
  String get ollamaSulTuoPc => 'Ollama on your PC';

  @override
  String get serveChiaveApiConsole =>
      'You need an API key from console.anthropic.com (pay as you go). A Claude Pro subscription doesn\'t work for external apps.';

  @override
  String get serveChiaveApiPlatform =>
      'You need an API key from platform.openai.com (pay as you go). A ChatGPT Plus subscription doesn\'t work for external apps.';

  @override
  String get serveChiaveApiAistudio =>
      'You need an API key from aistudio.google.com: there\'s a free tier with daily limits.';

  @override
  String get gratisPrivatoModelloGira =>
      'Free and private: the model runs on your PC, on the same Wi-Fi network. No key. On the PC start Ollama with OLLAMA_HOST=0.0.0.0.';

  @override
  String get nelBloccoNonCi2 => 'There are no workouts in the block.';

  @override
  String get nelPianoMancanoData =>
      'The plan is missing the start date or the sessions.';

  @override
  String get nelBloccoNonCi3 => 'There are no valid changes in the block.';

  @override
  String get propostaNonLeggibileChiedi =>
      'The proposal can\'t be read: ask the coach to write it again.';

  @override
  String sportNonPrevisto2(Object p0) {
    return 'sport not allowed ($p0)';
  }

  @override
  String get dataGiaPassata => 'the date has already passed';

  @override
  String durataNonSensataMin(Object p0) {
    return 'duration doesn\'t make sense ($p0 min)';
  }

  @override
  String cGiaSedutaQuel(Object p0) {
    return 'there\'s already a $p0 session that day';
  }

  @override
  String get mancaDurata => 'the duration is missing';

  @override
  String quelGiornoNonC(Object p0) {
    return 'there\'s no $p0 session that day';
  }

  @override
  String get nuovaDataMancanteO => 'new date missing or in the past';

  @override
  String cGiaSedutaGiorno(Object p0) {
    return 'there\'s already a $p0 session on the chosen day';
  }

  @override
  String settimanaPasserebbeMinutiOltre(Object p0, Object p1) {
    return 'the week would go from $p0 to $p1 minutes (over +10%)';
  }

  @override
  String get settimanaResterebbeSenzaGiorno =>
      'the week would be left without a rest day';

  @override
  String nuovaSeduta(Object p0, Object p1) {
    return '$p0: new session, $p1';
  }

  @override
  String tolta(Object p0, Object p1) {
    return '$p0: removed$p1';
  }

  @override
  String get ellittica => 'Elliptical';

  @override
  String get canottaggio => 'Rowing';

  @override
  String get vogatore => 'Rowing machine';

  @override
  String get stepper => 'Stepper';

  @override
  String get scale => 'Stairs';

  @override
  String get sci => 'Skiing';

  @override
  String get scialpinismo => 'Ski touring';

  @override
  String get sciFondo => 'Cross-country skiing';

  @override
  String get pattinaggio => 'Skating';

  @override
  String get kayak => 'Kayak';

  @override
  String get canoa => 'Canoe';

  @override
  String get vela => 'Sailing';

  @override
  String get surf => 'Surfing';

  @override
  String get sup => 'SUP';

  @override
  String get calcio => 'Football';

  @override
  String get basket => 'Basketball';

  @override
  String get pallavolo => 'Volleyball';

  @override
  String get pingPong => 'Table tennis';

  @override
  String get danza => 'Dance';

  @override
  String get artiMarziali => 'Martial arts';

  @override
  String get pugilato => 'Boxing';

  @override
  String get uscitaBici => 'Bike ride';

  @override
  String get nuotoLibero => 'Free swim';

  @override
  String get toccaFattoQuandoHai => 'Tap \"Done\" when you\'ve finished.';

  @override
  String get duePagine => 'Two pages';

  @override
  String get minimappa => 'Mini map';

  @override
  String get tuttoSchermo => 'Full screen';

  @override
  String get annulla => 'Cancel';

  @override
  String creato(Object p0) {
    return 'Created on $p0';
  }

  @override
  String giorniPiano(Object p0) {
    return '$p0 days of plan';
  }

  @override
  String get fotoProfilo => 'profile photo';

  @override
  String get fileTroppoGrandeEssere => 'File too large to be a backup.';

  @override
  String get fileNonBackupAvidididadi =>
      'The file is not an Avidididadi backup.';

  @override
  String get backupCreatoVersionePiu =>
      'Backup created by a newer version of the app: update it.';

  @override
  String get backupVuoto => 'The backup is empty.';

  @override
  String get nonRiescoScrivereNella =>
      'I can\'t write to the folder: choose it again (maybe it was moved or deleted).';

  @override
  String get backupAutomaticoNonRiuscito => 'Automatic backup failed.';

  @override
  String get sensoreBattito => 'Heart rate sensor';

  @override
  String get bastaPaioScarpeSi =>
      'All you need is a pair of shoes. You can start by walking.';

  @override
  String get casaOPalestraAnche =>
      'At home or at the gym, even without equipment.';

  @override
  String get piscinaDelicatoSulleArticolazioni =>
      'In the pool, gentle on the joints.';

  @override
  String get allApertoOSui => 'Outdoors or on the trainer, at an easy pace.';

  @override
  String get stretchingMovimentiLentiPerfetta =>
      'Stretching and slow movements: perfect for starting out or recovering.';

  @override
  String get palestraOFalesiaSegni =>
      'At the gym or at the crag: log routes, problems and grades.';

  @override
  String get maiOQuasiMai => 'Never or almost never';

  @override
  String get siPartePianoSedute =>
      'We start slowly: simple sessions to learn the movements.';

  @override
  String get ogniTanto => 'Now and then';

  @override
  String get qualcheAllenamentoAlMese =>
      'A few workouts a month, but not consistently.';

  @override
  String get regolarmente => 'Regularly';

  @override
  String get miAllenoQuasiOgni =>
      'I\'ve been training almost every week for months.';

  @override
  String get caloStaiFacendoMeno =>
      'Going down: you\'re doing less than usual.';

  @override
  String get equilibratoAumentoSostenibile =>
      'Balanced: a sustainable increase.';

  @override
  String get attenzioneStaiAumentandoFretta =>
      'Careful: you\'re increasing quickly.';

  @override
  String get rischioTroppoCaricoRispetto =>
      'Risk: too much load compared with the last few weeks.';

  @override
  String hMin(Object p0, Object p1) {
    return '$p0 h $p1 min';
  }

  @override
  String get chiudi => 'Close';

  @override
  String get nessunDatoQuestoGrafico => 'No data for this chart.';

  @override
  String settimanaDal(Object p0) {
    return 'Week from $p0';
  }

  @override
  String totale(Object p0) {
    return 'Total: $p0';
  }

  @override
  String tuttoPeriodo(Object p0, Object p1) {
    return '$p0 over the whole period: $p1';
  }

  @override
  String get nessunAllenamento => 'No workout';

  @override
  String ripetizione(Object p0, Object p1) {
    return 'Rep $p0 of $p1';
  }

  @override
  String serie(Object p0, Object p1) {
    return 'Set $p0 of $p1';
  }

  @override
  String get cambiaLatoMeta => 'Switch sides halfway.';

  @override
  String poiRipetizione(Object p0, Object p1) {
    return 'Then rep $p0 of $p1';
  }

  @override
  String poiSerie(Object p0, Object p1) {
    return 'Then set $p0 of $p1';
  }

  @override
  String get continuaPianoSenzaFermarti => 'Keep going easy, without stopping.';

  @override
  String get respiraBeviSorsoAcqua => 'Breathe and take a sip of water.';

  @override
  String get manubri => 'Dumbbells';

  @override
  String get pesoOgniManubrioEs =>
      'The weight of each dumbbell, e.g. 4, 8, 12. If they\'re adjustable write the range, e.g. 2-20.';

  @override
  String get kettlebell => 'Kettlebell';

  @override
  String get pesoOgniKettlebellHai => 'The weight of each kettlebell you have.';

  @override
  String get bilanciere => 'Barbell';

  @override
  String get pesoSolaBarraSolito =>
      'The weight of the bar alone (usually 20 kg).';

  @override
  String get dischi => 'Plates';

  @override
  String get pesoDeiDischiHai =>
      'The weight of the plates you have. They can also be used without a barbell.';

  @override
  String get pallaMedica => 'Medicine ball';

  @override
  String get pesoPalla => 'The weight of the ball.';

  @override
  String get elastici => 'Resistance bands';

  @override
  String get sbarraTrazioni => 'Pull-up bar';

  @override
  String get paralleleDip => 'Dip bars';

  @override
  String get anelliOTrx => 'Rings or TRX';

  @override
  String get panca => 'Bench';

  @override
  String get stepOBox => 'Step or box';

  @override
  String get fitball => 'Swiss ball';

  @override
  String get rulloFoamRoller => 'Foam roller';

  @override
  String get latMachine => 'Lat machine';

  @override
  String get pulleyBasso => 'Low pulley';

  @override
  String get caviRegolabiliCroceAi => 'Adjustable cables (cable crossover)';

  @override
  String get chestPress => 'Chest press';

  @override
  String get pectoralMachine => 'Pec deck';

  @override
  String get shoulderPress => 'Shoulder press';

  @override
  String get rematoreAllaMacchina => 'Machine row';

  @override
  String get multipowerSmithMachine => 'Smith machine';

  @override
  String get legPress => 'Leg press';

  @override
  String get hackSquat => 'Hack squat';

  @override
  String get legExtension => 'Leg extension';

  @override
  String get legCurl => 'Leg curl';

  @override
  String get adduttoriAbduttori => 'Adductor and abductor machine';

  @override
  String get calfMachinePolpacci => 'Calf machine';

  @override
  String get addominali => 'Abs';

  @override
  String get obliqui => 'Obliques';

  @override
  String get adduttori => 'Adductors';

  @override
  String get bicipiti => 'Biceps';

  @override
  String get polpacci => 'Calves';

  @override
  String get petto => 'Chest';

  @override
  String get avambracci => 'Forearms';

  @override
  String get glutei => 'Glutes';

  @override
  String get femorali => 'Hamstrings';

  @override
  String get dorsali => 'Upper back';

  @override
  String get lombari => 'Lower back';

  @override
  String get collo => 'Neck';

  @override
  String get quadricipiti => 'Quadriceps';

  @override
  String get spalle => 'Shoulders';

  @override
  String get trapezio => 'Trapezius';

  @override
  String get tricipiti => 'Triceps';

  @override
  String get spintaOrizzontalePetto => 'Horizontal push (chest)';

  @override
  String get spintaVerticaleSpalle => 'Vertical push (shoulders)';

  @override
  String get trazioneOrizzontaleRematori => 'Horizontal pull (rows)';

  @override
  String get trazioneVerticaleTrazioni => 'Vertical pull (pull-ups)';

  @override
  String get squat => 'Squat';

  @override
  String get affondiStep => 'Lunges and step-ups';

  @override
  String get cernieraAncaStacchiPonti => 'Hip hinge (deadlifts and bridges)';

  @override
  String get core => 'Core';

  @override
  String get spallePostura => 'Shoulders and posture';

  @override
  String get braccia => 'Arms';

  @override
  String get gambeAlleMacchine => 'Leg machines';

  @override
  String get pliometria => 'Plyometrics';

  @override
  String get totalBody => 'Total body';

  @override
  String get rulloAutomassaggio => 'Foam roller (self-massage)';

  @override
  String get n1Esercizio => '1 exercise';

  @override
  String get beneDallaProssimaSessione =>
      'Great! From the next session I\'ll increase the load a little.';

  @override
  String get haiSegnalatoDoloreAlleggerisco =>
      'You reported pain: I\'m easing off the next sessions. If the pain continues, stop and see a doctor.';

  @override
  String get alleggeriscoPoProssimeSessioni =>
      'I\'m easing off the next sessions a little.';

  @override
  String get caricoGiustoSiContinua => 'Load is right: keep it up.';

  @override
  String tiAlleniMeglioQuanto(Object p0) {
    return 'You\'re training better than you thought: moving up to level $p0.';
  }

  @override
  String passoAlLivelloPiu(Object p0) {
    return 'Moving to level $p0, better suited for now.';
  }

  @override
  String haiSegnalatoDoloreAlleggerisco2(Object p0) {
    return 'You reported pain: I\'m easing off the next $p0 sessions. If the pain continues, stop and see a doctor.';
  }

  @override
  String beneSeduteSonoGia(Object p0) {
    return 'Great! Your $p0 sessions are already at the maximum increase.';
  }

  @override
  String beneAumentoPoIntensita(Object p0) {
    return 'Great! I\'m raising the intensity of your next $p0 sessions a little, same time.';
  }

  @override
  String beneAllungoPoProssime(Object p0) {
    return 'Great! I\'m making your next $p0 sessions a little longer.';
  }

  @override
  String rendoPoMenoIntense(Object p0) {
    return 'I\'m making your next $p0 sessions a little less intense.';
  }

  @override
  String accorcioPoProssimeSedute(Object p0) {
    return 'I\'m shortening your next $p0 sessions a little.';
  }

  @override
  String get faticaGiustaSiContinua => 'Effort is right: keep it up.';

  @override
  String get braccio => 'Arm';

  @override
  String get vita => 'Waist';

  @override
  String get fianchi => 'Hips';

  @override
  String get coscia => 'Thigh';

  @override
  String get durata => 'Duration';

  @override
  String get sedutePiuLunghe5 => 'Sessions 5% longer for each step.';

  @override
  String get intensita => 'Intensity';

  @override
  String get stessaDurataPiuSforzo =>
      'Same duration, more effort: shorter recoveries, more fast minutes, a slightly quicker pace.';

  @override
  String get auto => 'Auto';

  @override
  String get primaIntensitaFino2 =>
      'Intensity first (up to 2 steps), then duration.';

  @override
  String min2(Object p0, Object p1) {
    return '$p0 · $p1 min';
  }

  @override
  String get corsaLeggeraAlternataCamminata =>
      'Easy running alternated with walking';

  @override
  String get dopo2MinutiCorsa =>
      'After 2 minutes of running walk for 1 minute. If you\'re out of breath, walk more: that\'s perfectly fine, it\'s how everyone starts.';

  @override
  String lungoMin(Object p0) {
    return 'Long run · $p0 min';
  }

  @override
  String get corsaLungaContinua => 'Continuous long run';

  @override
  String get ritmoFacileCostanteDevi =>
      'Easy, steady pace: you should be able to talk.';

  @override
  String get finaleRitmoGara => 'Finish at race pace';

  @override
  String get finaleProgressione => 'Progressive finish';

  @override
  String get corsaFacile => 'Easy running';

  @override
  String get corsaVeloce => 'Fast running';

  @override
  String get recuperoCorricchiandoZona2 => 'Recover jogging in zone 2.';

  @override
  String get corsaRitmoSostenuto => 'Running at a sustained pace';

  @override
  String get ripetuteVeloci => 'Fast intervals';

  @override
  String get recuperoCorricchiandoPiano => 'Recover jogging slowly.';

  @override
  String get blocchiRitmoGara => 'Blocks at race pace';

  @override
  String get allunghiProgressione => 'Progressive strides';

  @override
  String get velociMaRilassatiNon => 'Fast but relaxed, not all-out.';

  @override
  String lentoMin(Object p0) {
    return 'Easy · $p0 min';
  }

  @override
  String get corsaLenta => 'Easy run';

  @override
  String get stileLiberoFacile => 'Easy freestyle';

  @override
  String get gambeTavolettaBraccioSingolo => 'Kick with board and single-arm';

  @override
  String get n2GambeTavoletta1 =>
      '2 kick with board, 1 right arm only, 1 left arm only.';

  @override
  String get stileLiberoSostenuto => 'Sustained freestyle';

  @override
  String get sostenutoCostante => 'sustained, steady';

  @override
  String get stileLiberoAerobico => 'Aerobic freestyle';

  @override
  String get medioRespirazioneRegolare => 'moderate, regular breathing';

  @override
  String get dorsoFacile => 'Easy backstroke';

  @override
  String intervalliMin(Object p0) {
    return 'Intervals · $p0 min';
  }

  @override
  String get pedalataAgile => 'Easy spin';

  @override
  String get ripetuteSalitaOPianura => 'Intervals uphill or on the flat';

  @override
  String get pedalataSciolta => 'Loose pedaling';

  @override
  String get uscitaLunga => 'Long ride';

  @override
  String uscitaLungaMin(Object p0) {
    return 'Long ride · $p0 min';
  }

  @override
  String get uscitaContinua => 'Continuous ride';

  @override
  String inserisciTratti10Minuti(Object p0) {
    return 'Add $p0 10-minute blocks in zone 3. Eat and drink every 30-45 minutes.';
  }

  @override
  String get mangiaBeviOgni30 => 'Eat and drink every 30-45 minutes.';

  @override
  String uscitaMin(Object p0) {
    return 'Ride · $p0 min';
  }

  @override
  String get pedalataCostante => 'Steady pedaling';

  @override
  String get finalePiuSpinto => 'Harder finish';

  @override
  String get pocheRipetizioniCarichiAlti =>
      'Few reps with heavy loads and long rests.';

  @override
  String get massaMuscolare => 'Muscle mass';

  @override
  String get ripetizioniMediePiuVolume =>
      'Medium reps, more volume to grow muscle.';

  @override
  String get resistenzaMuscolare => 'Muscular endurance';

  @override
  String get tanteRipetizioniRecuperiBrevi =>
      'Many reps and short rests, useful for endurance sports.';

  @override
  String get formaGenerale => 'General fitness';

  @override
  String get equilibrioTraForzaMuscoli =>
      'A balance of strength, muscle and endurance.';

  @override
  String get principiante => 'Beginner';

  @override
  String get tiAlleniPesiPoco =>
      'You\'re new to weights or haven\'t trained in a while.';

  @override
  String get intermedio => 'Intermediate';

  @override
  String get tiAlleniCostanzaAlmeno =>
      'You\'ve trained consistently for at least a few months.';

  @override
  String get avanzato => 'Advanced';

  @override
  String get tiAlleniAnniConosci =>
      'You\'ve trained for years and know the technique well.';

  @override
  String settimana4(Object p0, Object p1) {
    return '$p0 · week $p1 of 4';
  }

  @override
  String get n10Lato => '10 per side';

  @override
  String get n10Lenti => '10 slow';

  @override
  String get settimanaScaricoSerieMeno =>
      'Recovery week: one set fewer, same technique.';

  @override
  String get settimana2RipetizionePiu => 'Week 2: one more rep than last week.';

  @override
  String get settimana3DueRipetizioni =>
      'Week 3: two more reps than the first week.';

  @override
  String gambeLeggereDomaniHai(Object p0) {
    return 'Easy on the legs: tomorrow you have $p0.';
  }

  @override
  String n10Fatica(Object p0) {
    return '$p0/10 effort';
  }

  @override
  String get n30SLato => '30 s per side';

  @override
  String get lungo => 'the Long run';

  @override
  String get fartlek => 'the Fartlek';

  @override
  String get tempoRun => 'the Tempo run';

  @override
  String get partiSolaBarraAggiungi =>
      'Start with the bar alone and add plates until you reach the indicated effort.';

  @override
  String pesoKg(Object p0, Object p1) {
    return 'Weight: $p0 $p1 kg.';
  }

  @override
  String pesoCircaKg(Object p0) {
    return 'Weight: about $p0 kg.';
  }

  @override
  String get movimentiLentiRespiraCalma =>
      'Slow movements, breathe calmly: stretch without ever feeling pain.';

  @override
  String get corsaRitmoTranquilloDevi =>
      'Running at an easy pace: you should be able to talk without getting out of breath. It builds endurance and is the base of everything.';

  @override
  String get corsaPiuLungaSettimana =>
      'The longest run of the week, always at an easy pace. It gets your body used to going the distance.';

  @override
  String get giocoVelocitaAlterniTratti =>
      'Speed play: you alternate fast and easy stretches, without ever stopping. It trains you to change pace.';

  @override
  String get corsaRitmoSostenutoMa =>
      'Running at a sustained but steady pace, \"comfortably hard\": you can talk only with effort, but you hold it for many minutes.';

  @override
  String get trattiBreviVelociPausa =>
      'Short, fast stretches with a break to recover in between. They make you faster.';

  @override
  String get blocchiAlRitmoVuoi =>
      'Blocks at the pace you want to hold on race day, to get used to it.';

  @override
  String get corsaFacileQualcheAccelerazione =>
      'Easy running with a few short accelerations (20 seconds), fast but relaxed. Keeps your legs sharp without tiring them.';

  @override
  String get nuotoCalmoEserciziMigliorare =>
      'Calm swimming with drills to improve your stroke: swimming well takes less effort.';

  @override
  String get serieVascheRitmoSostenuto =>
      'Sets of lengths at a sustained, steady pace with short breaks. Improves the speed you can hold for a long time.';

  @override
  String get pedalataCostanteRitmoFacile =>
      'Steady pedaling at an easy pace: builds endurance.';

  @override
  String get pedalataPiuLungaSettimana =>
      'The longest ride of the week, at an easy pace. Bring water and something to eat.';

  @override
  String get trattiPedalataImpegnativaSalita =>
      'Stretches of hard pedaling (uphill or on the flat) with easy breaks in between.';

  @override
  String get movimentiLentiAllungamentiQuasi =>
      'Slow movements and stretches, almost all timed. They loosen joints and muscles, help you recover and move better. It should never hurt.';

  @override
  String get mobilitaAncheCoscePolpacci =>
      'Mobility for hips, thighs and calves: the parts that work hardest in running and cycling.';

  @override
  String get mobilitaSchienaBustoUtile =>
      'Mobility for the back and torso: useful if you sit a lot.';

  @override
  String get mobilitaSpallePettoBraccia =>
      'Mobility for shoulders, chest and arms: opens up your posture and helps with swimming.';

  @override
  String get eserciziMuscoliCorpoLibero =>
      'Exercises for your muscles, bodyweight or with weights, followed by a few minutes of mobility. They make you stronger and protect against injuries.';

  @override
  String get moltoFacileComeCamminata => 'very easy, like a brisk walk';

  @override
  String get facileRiesciParlare => 'easy: you can talk';

  @override
  String get medioParliMaFatica => 'moderate: you can talk, but with effort';

  @override
  String get impegnativoSoloPocheParole => 'hard: only a few words';

  @override
  String get alMassimoSiRegge => 'all-out: you can hold it only briefly';

  @override
  String get zoneFrequenzaCardiaca => 'Heart rate zones';

  @override
  String get cinqueFasceBattitiAl =>
      'Five ranges of beats per minute, from the easiest (1) to the hardest (5). The app works them out from your data: follow the zone shown and the workout has the right effect.';

  @override
  String get fatica110 => 'Effort (1 to 10)';

  @override
  String get quantoTiSembrataDura =>
      'How hard the session felt: 1 is a stroll, 10 is the maximum. Telling the app after every session helps it adapt the plan.';

  @override
  String get carico => 'Load';

  @override
  String get quantoTiSeiAllenato =>
      'How much you trained, taking duration and effort into account. Watch how it grows: increasing a little at a time keeps you from getting hurt.';

  @override
  String get settimanaScarico => 'Recovery week';

  @override
  String get ogniQuattroSettimanePiu =>
      'Every four weeks a lighter one: your body absorbs the work done and comes back stronger.';

  @override
  String get comeStaiOggiSonno =>
      'How you\'re doing today, from sleep and resting heart rate. If it\'s low, an easy session is better.';

  @override
  String get movimentiLentiSciogliereArticolazioni =>
      'Slow movements to loosen your joints at the end of the session.';

  @override
  String get stoRegistrandoPercorso => 'Recording the route';

  @override
  String get registrazionePercorso => 'Route recording';

  @override
  String get sessioniAllenamento => 'Workout sessions';

  @override
  String get frequenzaCardiaca => 'Heart rate';

  @override
  String get distanza => 'Distance';

  @override
  String get calorieAttive => 'Active calories';

  @override
  String get calorieTotali => 'Total calories';

  @override
  String get passi => 'Steps';

  @override
  String get velocita => 'Speed';

  @override
  String get fcRiposo => 'Resting HR';

  @override
  String get variabilitaCardiacaHrv => 'Heart rate variability (HRV)';

  @override
  String get sonno => 'Sleep';

  @override
  String get immagineNonDisponibileSenza => 'Image not available offline';

  @override
  String previsti(Object p0, Object p1) {
    return '$p0 (planned $p1)';
  }

  @override
  String recupero(Object p0) {
    return 'Rest $p0';
  }

  @override
  String fc(Object p0) {
    return 'HR $p0';
  }

  @override
  String get chiaveApiNonValida =>
      'Invalid API key: copy it again from intervals.icu → Settings → Developer settings.';

  @override
  String get intervalsIcuHaRicevuto =>
      'intervals.icu received too many requests: try again in a few minutes.';

  @override
  String intervalsIcuHaRisposto(Object p0) {
    return 'intervals.icu replied with an error ($p0).';
  }

  @override
  String get nessunaConnessioneInternet => 'No internet connection.';

  @override
  String get intervalsIcuNonRisponde =>
      'intervals.icu is not responding: try again.';

  @override
  String get rispostaIntervalsIcuNon => 'intervals.icu reply can\'t be read.';

  @override
  String get chiaveApiNonValida2 => 'Invalid API key.';

  @override
  String get indirizzoOllamaNonValido =>
      'Invalid Ollama address: write it like http://192.168.1.10:11434';

  @override
  String get proteggereTuoiDatiIndirizzo =>
      'To protect your data, an http address is accepted only on your home network (e.g. http://192.168.1.10:11434). An address on the internet needs https.';

  @override
  String get rispostaVuotaDalModello => 'Empty reply from the model.';

  @override
  String chiaveApiNonValida3(Object p0) {
    return 'Invalid API key: copy it again from the service\'s website, in full.\n($p0)';
  }

  @override
  String get richiestaRifiutataControllaNome =>
      'Request refused: check the model name.';

  @override
  String get chiaveApiNonValida4 => 'Invalid API key or missing permissions.';

  @override
  String get modelloNonTrovatoSu =>
      'Model not found on Ollama: download it with \"ollama pull\".';

  @override
  String get modelloNonTrovatoControlla => 'Model not found: check the name.';

  @override
  String get limiteRichiesteRaggiuntoO =>
      'Request limit reached or credit used up. Try again later.';

  @override
  String get servizioHaProblemaQuesto =>
      'The service has a problem right now. Try again later.';

  @override
  String errore2(Object p0) {
    return 'Error $p0.';
  }

  @override
  String get mancaChiaveApiAggiungila =>
      'The API key is missing: add it above.';

  @override
  String nonRiescoRaggiungereOllama(Object p0, Object p1) {
    return 'I can\'t reach Ollama at $p0. ($p1)';
  }

  @override
  String nessunaConnessioneInternet2(Object p0) {
    return 'No internet connection. ($p0)';
  }

  @override
  String get servizioNonRispondeRiprova =>
      'The service is not responding: try again.';

  @override
  String get rispostaNonLeggibile => 'The reply can\'t be read.';

  @override
  String get indirizzoNonValido => 'Invalid address.';

  @override
  String esempio(Object p0) {
    return ', for example $p0';
  }

  @override
  String chiaveFunzionaMaModello(Object p0, Object p1) {
    return 'The key works, but the model \"$p0\" doesn\'t exist. Tap one in \"Choose from the available models\"$p1.';
  }

  @override
  String get provaConnessione => 'Connection test';

  @override
  String ollamaRispondeMaModello(Object p0, Object p1) {
    return 'Ollama replies, but the model \"$p0\" isn\'t there. Installed: $p1.';
  }

  @override
  String nonRiescoRaggiungereOllama2(Object p0, Object p1) {
    return 'I can\'t reach Ollama at $p0. Is the PC on, on the same network, with Ollama open? ($p1)';
  }

  @override
  String get ollamaNonRispondePc => 'Ollama is not responding: is the PC on?';

  @override
  String get indirizzoNonValidoO =>
      'Invalid address or the reply isn\'t from Ollama.';

  @override
  String get indirizzoNonValidoScrivilo =>
      'Invalid address: write it like http://IP:11434';

  @override
  String get mancaChiaveApiAggiungila2 =>
      'The API key is missing: add it in the settings.';

  @override
  String nonRiescoRaggiungereOllama3(Object p0, Object p1) {
    return 'I can\'t reach Ollama at $p0. Is the PC on, on the same network, with OLLAMA_HOST=0.0.0.0? ($p1)';
  }

  @override
  String get modelloCiStaMettendo => 'The model is taking too long: try again.';

  @override
  String get allenamentoInterrotto => 'Workout interrupted';

  @override
  String appSiEraChiusa(Object p0) {
    return 'The app closed during the workout: $p0. Pick up where you left off? It restarts paused.';
  }

  @override
  String get scarta => 'Discard';

  @override
  String get riprendi => 'Resume';

  @override
  String get rispostaRicevutaTroviCoach =>
      'Reply received: you\'ll find it in Coach.';

  @override
  String get oggi => 'Today';

  @override
  String get progressi => 'Progress';

  @override
  String get coach => 'Coach';

  @override
  String get profilo => 'Profile';

  @override
  String circaMb(Object p0) {
    return 'about $p0 MB';
  }

  @override
  String get downloadNonRiuscitoServe =>
      'Download failed: a connection is needed. Try again later.';

  @override
  String get lunedi => 'Monday';

  @override
  String get martedi => 'Tuesday';

  @override
  String get mercoledi => 'Wednesday';

  @override
  String get giovedi => 'Thursday';

  @override
  String get venerdi => 'Friday';

  @override
  String get sabato => 'Saturday';

  @override
  String get domenica => 'Sunday';

  @override
  String intensita2(Object p0) {
    return 'intensity $p0';
  }

  @override
  String recuperoS(Object p0) {
    return 'rest $p0 s';
  }

  @override
  String get tuaCorsaPiuLunga => 'Your longest run';

  @override
  String get tuaUscitaBiciPiu => 'Your longest bike ride';

  @override
  String get tuaNuotataPiuLunga => 'Your longest swim';

  @override
  String get tuaCamminataPiuLunga => 'Your longest walk';

  @override
  String get primoAllenamentoFatto => 'First workout done!';

  @override
  String haiFattoAllenamenti(Object p0) {
    return 'You\'ve done $p0 workouts!';
  }

  @override
  String record(Object p0) {
    return 'Record: $p0';
  }

  @override
  String settimaneFilaGrande(Object p0) {
    return '$p0 weeks in a row: great!';
  }

  @override
  String settimaneFilaVai(Object p0, Object p1) {
    return '$p0 weeks in a row. Going for $p1?';
  }

  @override
  String get nelFileNonC =>
      'There\'s no route in the file: you need a GPX with a track.';

  @override
  String get destra => 'right';

  @override
  String get sinistra => 'left';

  @override
  String get tieniDestra => 'keep right';

  @override
  String get tieniSinistra => 'keep left';

  @override
  String curvaStretta(Object p0) {
    return 'sharp turn $p0';
  }

  @override
  String get tornaIndietro => 'turn back';

  @override
  String poiSubito(Object p0) {
    return 'then immediately $p0';
  }

  @override
  String get nuovoSulPercorso => 'Back on the route.';

  @override
  String seiFuoriPercorsoDalla(Object p0) {
    return 'You\'re off route, $p0 from the track.';
  }

  @override
  String get staiAndandoNelSenso =>
      'You\'re going the opposite way along the route.';

  @override
  String get arrivoPercorsoCompletato => 'Finish! Route completed.';

  @override
  String tra(Object p0, Object p1, Object p2) {
    return 'In $p0, $p1$p2.';
  }

  @override
  String recuperoPoi(Object p0) {
    return 'Rest · then $p0';
  }

  @override
  String pausa(Object p0) {
    return 'Paused · $p0';
  }

  @override
  String get n5Km => '5 km';

  @override
  String get n10Km => '10 km';

  @override
  String get mezzaMaratona => 'Half marathon';

  @override
  String get maratona => 'Marathon';

  @override
  String get mediofondo => 'Medio fondo';

  @override
  String get granfondo => 'Gran fondo';

  @override
  String get triathlonSprint => 'Sprint triathlon';

  @override
  String get triathlonOlimpico => 'Olympic triathlon';

  @override
  String get triathlon703 => 'Triathlon 70.3';

  @override
  String get base => 'Base';

  @override
  String get sviluppo => 'Build';

  @override
  String get rifinitura => 'Peak';

  @override
  String get scaricoPreGara => 'Pre-race taper';

  @override
  String get settimanaGara => 'Race week';

  @override
  String get senzaObiettivo => 'No goal';

  @override
  String get volumeCrescePianoQuasi =>
      'Volume grows slowly, almost all at low intensity.';

  @override
  String get siAggiungonoSeduteQualita =>
      'Quality sessions are added, the long session gets longer.';

  @override
  String get lavoriAlRitmoGara => 'Work at race pace, steady volume.';

  @override
  String get menoVolumePoIntensita =>
      'Less volume, a bit of intensity to stay sharp.';

  @override
  String get pocheSeduteCorteSi =>
      'Few short sessions: you get to the start fresh.';

  @override
  String get pianoMantenimentoImpostaGara =>
      'Maintenance plan: set a race for a build-up.';

  @override
  String get aerobica => 'Aerobic';

  @override
  String get medio => 'Moderate';

  @override
  String get massimale => 'Maximal';

  @override
  String zBpm(Object p0, Object p1, Object p2) {
    return 'Z$p0 $p1-$p2 bpm';
  }

  @override
  String bpm(Object p0, Object p1, Object p2) {
    return '$p0 ($p1-$p2 bpm)';
  }

  @override
  String get nelFileNonC2 =>
      'There\'s no route in the file: you need a GPX with the activity track.';

  @override
  String get pulse => 'Pulse';

  @override
  String get strade => 'Streets';

  @override
  String get satellite => 'Satellite';

  @override
  String get facile => 'Easy';

  @override
  String get fondo => 'Endurance';

  @override
  String get vo2max => 'VO2max';

  @override
  String get anaerobica => 'Anaerobic';

  @override
  String get sprint => 'Sprint';

  @override
  String finoW(Object p0) {
    return 'up to $p0 W';
  }

  @override
  String oltreW(Object p0) {
    return 'over $p0 W';
  }

  @override
  String cadenzaScendiSotto(Object p0, Object p1) {
    return 'Cadence $p0, go below $p1.';
  }

  @override
  String cadenzaSaliSopra(Object p0, Object p1) {
    return 'Cadence $p0, go above $p1.';
  }

  @override
  String bpm2(Object p0, Object p1) {
    return '$p0-$p1 bpm';
  }

  @override
  String bpm3(Object p0, Object p1, Object p2, Object p3) {
    return '$p0 ($p1 · $p2-$p3 bpm)';
  }

  @override
  String wattScendiSotto(Object p0, Object p1) {
    return '$p0 watts, go below $p1.';
  }

  @override
  String wattSaliSopra(Object p0, Object p1) {
    return '$p0 watts, go above $p1.';
  }

  @override
  String get registraQuestaCorsaAnche =>
      'Record this run with your watch too: it\'s the watch that measures watts.';

  @override
  String get velociMaScioltiPoi => 'Fast but loose, then walk or jog slowly.';

  @override
  String get test20MinutiAl => 'Test: 20 minutes all-out';

  @override
  String get ritmoPiuForteRiesci =>
      'The hardest pace you can hold to the end, steady. Better to start a bit easy and finish strong.';

  @override
  String get corsaLentissima => 'Very easy running';

  @override
  String get energiaBuona => 'Good energy';

  @override
  String get energiaNormale => 'Normal energy';

  @override
  String get energiaBassa => 'Low energy';

  @override
  String get giornataAdattaAncheSeduta =>
      'A good day even for a quality session.';

  @override
  String get allenatiComePrevistoAscoltando =>
      'Train as planned, listening to how you feel.';

  @override
  String get meglioSedutaFacileO =>
      'Better an easy session or a rest day: lower the intensity.';

  @override
  String solitoMsPiuAlta(Object p0) {
    return 'usually $p0 ms · higher is better';
  }

  @override
  String hrvMsSottoTua(Object p0, Object p1) {
    return 'HRV $p0 ms, below your average ($p1 ms)';
  }

  @override
  String hrvMsSopraTua(Object p0) {
    return 'HRV $p0 ms, above your average';
  }

  @override
  String solitoBpmPiuBassa(Object p0) {
    return 'usually $p0 bpm · lower is better';
  }

  @override
  String fcRiposoBpmPiu(Object p0, Object p1) {
    return 'Resting HR $p0 bpm, higher than usual ($p1)';
  }

  @override
  String get bene7H30 => 'good from 7 h 30 up, low under 6 h';

  @override
  String haiDormitoPoco(Object p0) {
    return 'You slept little ($p0)';
  }

  @override
  String haiDormitoBene(Object p0) {
    return 'You slept well ($p0)';
  }

  @override
  String kg(Object p0, Object p1) {
    return '$p0 at $p1 kg';
  }

  @override
  String kg2(Object p0, Object p1) {
    return '$p0 × $p1 kg';
  }

  @override
  String get tempo => 'Time';

  @override
  String get passo => 'Pace';

  @override
  String get battitoMedio => 'Average HR';

  @override
  String get sollevati => 'Lifted';

  @override
  String get calorie => 'Calories';

  @override
  String get classica => 'Classic';

  @override
  String get mappa => 'Map';

  @override
  String get poster => 'Poster';

  @override
  String get kmKm => 'Km by km';

  @override
  String get salita => 'Climb';

  @override
  String get esercizi => 'Exercises';

  @override
  String get muscoli => 'Muscles';

  @override
  String get seduta => 'Session';

  @override
  String get tuaFoto => 'Your photo';

  @override
  String kgPrimaKg(Object p0, Object p1, Object p2) {
    return '$p0 $p1 kg (before $p2 kg)';
  }

  @override
  String get kgSollevatiTutto => 'kg lifted in total';

  @override
  String get arrampicata => 'CLIMBING';

  @override
  String get indoor => 'INDOOR';

  @override
  String get outdoor => 'OUTDOOR';

  @override
  String get gradoPiuAltoOggi => 'today\'s highest grade';

  @override
  String get blocchi => 'Problems';

  @override
  String get saliti => 'Climbed';

  @override
  String get attivita => 'Activity';

  @override
  String get altraAttivita => 'OTHER ACTIVITY';

  @override
  String miaSettimana(Object p0) {
    return 'My week ($p0)';
  }

  @override
  String sedute(Object p0, Object p1) {
    return '$p0/$p1 sessions';
  }

  @override
  String get abbiamoAggiornatoRegole => 'We\'ve updated the rules';

  @override
  String get benvenutoAvidididadi => 'Welcome to Avidididadi';

  @override
  String get terminiInformativaSonoCambiati =>
      'The terms and privacy policy have changed. Read and accept them to continue.';

  @override
  String get primaIniziareEccoBreve =>
      'Before you start, here\'s a short summary of how the app handles your data.';

  @override
  String get datiRestanoSulTelefono => 'Your data stays on your phone';

  @override
  String get nessunAccountNessunServer => 'No account, no server, no ads.';

  @override
  String get healthConnectSoloLettura => 'Health Connect read-only';

  @override
  String get allenamentiBattitoSonnoPercorsi =>
      'Workouts, heart rate, sleep and routes from your apps (e.g. Garmin), only if you allow it.';

  @override
  String get gpsSoloDuranteCorsa => 'GPS only during runs and rides';

  @override
  String get mentreTiAlleniApp =>
      'While you train with the app, with a persistent notification. Never at other times.';

  @override
  String get mappeImmaginiInternet => 'Maps and images from the internet';

  @override
  String get openfreemapEsriSatelliteGithub =>
      'From OpenFreeMap, Esri (satellite) and GitHub: your route is not sent.';

  @override
  String get assistenteFacoltativo => 'Optional assistant';

  @override
  String get inviaRiassuntoDegliAllenamenti =>
      'Sends a summary of your workouts to the service you choose, only if you turn it on.';

  @override
  String get nonConsiglioMedico => 'This is not medical advice';

  @override
  String get pianiConsigliSonoStime =>
      'Plans and advice are estimates: if you have doubts or health problems, ask your doctor.';

  @override
  String get terminiCondizioni => 'Terms and conditions';

  @override
  String get informativaPrivacy => 'Privacy policy';

  @override
  String get hoLettoAccettoTermini =>
      'I have read and accept the Terms and conditions and the Privacy policy';

  @override
  String get entra => 'Enter';

  @override
  String get nonAccettoEsci => 'I don\'t accept, exit';

  @override
  String get usaTuoAssistente => 'Use your assistant';

  @override
  String get parliCoachNellApp =>
      'You talk with the coach in your assistant\'s app, with your subscription (even a free one): no API key.';

  @override
  String get avidididadiPreparaMessaggioTuoi =>
      'Avidididadi prepares a message with your data: you send it to the assistant with Share.';

  @override
  String get parliAssistenteNellaSua =>
      'You talk with the assistant in its app, as much as you like.';

  @override
  String get quandoProponeModificheO =>
      'When it suggests changes or a new plan, share the reply with Avidididadi: you see a preview and you decide.';

  @override
  String get qualeAppUsi => 'Which app do you use?';

  @override
  String get primaIniziare => 'Before you start';

  @override
  String get abbonamentoNormaleChatPossono =>
      'With a regular subscription, chats may be used to train the model, depending on your account settings. Name, photo and GPS routes are never sent.';

  @override
  String get includiEtaSessoAltezza => 'Include age, sex, height and weight';

  @override
  String get vediEsattamenteCosaViene => 'See exactly what is sent';

  @override
  String acconsentoInviareQuestiDati(Object p0) {
    return 'I agree to send this data to $p0 when I tap Share or Copy';
  }

  @override
  String collega(Object p0) {
    return 'Connect $p0';
  }

  @override
  String get privacyUsoDeiDati => 'Privacy and data use';

  @override
  String get assistente => 'the assistant';

  @override
  String manda(Object p0) {
    return 'Send to $p0';
  }

  @override
  String messaggioCopiatoIncollalo(Object p0) {
    return 'Message copied: paste it into $p0.';
  }

  @override
  String appuntiSonoVuotiCopia(Object p0) {
    return 'The clipboard is empty: first copy the reply from $p0.';
  }

  @override
  String scollegare(Object p0) {
    return 'Disconnect $p0?';
  }

  @override
  String get torniAlCoachDentro =>
      'You go back to the coach inside the app (for example Ollama on your PC). Replies from the current conversation will no longer be accepted: if you reconnect, send the data again.';

  @override
  String get scollega => 'Disconnect';

  @override
  String get rispostaNonUsabile => 'Reply can\'t be used';

  @override
  String n1Parla(Object p0) {
    return '1 · Talk with $p0';
  }

  @override
  String get haiFattoAllenamentiNuovi =>
      'Done new workouts? Send the updated data in the same conversation.';

  @override
  String mandaPrimoMessaggioIstruzioni(Object p0) {
    return 'Send the first message: coach instructions and your data. Choose $p0 from the Share menu.';
  }

  @override
  String ultimoInvio(Object p0, Object p1, Object p2) {
    return 'Last sent: $p0, $p1:$p2';
  }

  @override
  String get mandaDatiAggiornati => 'Send updated data';

  @override
  String inizia(Object p0) {
    return 'Start with $p0';
  }

  @override
  String get nuovaConversazione => 'New conversation';

  @override
  String get copiaInvece => 'Copy instead';

  @override
  String get n2PortaQuiModifiche => '2 · Bring the changes here';

  @override
  String quandoProponeCambiarePiano(Object p0) {
    return 'When $p0 suggests changing the plan, tap Share on its reply and choose Avidididadi. Or copy it and tap below.';
  }

  @override
  String get incollaRisposta => 'Paste the reply';

  @override
  String get consiglioIstruzioniVoltaSola => 'Tip: instructions only once';

  @override
  String get incollaIstruzioniCoachProgetto =>
      'Paste the coach instructions into a Claude Project, a custom GPT or a Gemini Gem. Then you only need to send the updated data.';

  @override
  String get istruzioniCopiate => 'Instructions copied.';

  @override
  String get copiaSoloIstruzioni => 'Copy only the instructions';

  @override
  String scollega2(Object p0) {
    return 'Disconnect $p0';
  }

  @override
  String get allenamentiArrampicata => 'Climbing workouts';

  @override
  String get nuovo => 'New';

  @override
  String get ancoraNessunAllenamento => 'No workouts yet';

  @override
  String get crealoNuovoOppureChiedilo =>
      'Create one with \"New\", or ask your assistant (for example by sending it a screenshot from another app): share the block from its reply with the app and you\'ll find the workout here, ready to put in the calendar.';

  @override
  String get altri => 'Others';

  @override
  String get giorno => 'Which day?';

  @override
  String nelCalendario(Object p0, Object p1) {
    return '$p0 is in the calendar: $p1.';
  }

  @override
  String get nonStatoPossibileScegli =>
      'That wasn\'t possible: choose today or a later day.';

  @override
  String eliminare(Object p0) {
    return 'Delete \"$p0\"?';
  }

  @override
  String get sparisceDallaRaccoltaSedute =>
      'It disappears from the collection. Sessions already in the calendar stay.';

  @override
  String get elimina => 'Delete';

  @override
  String get allenamentoNonTrovato => 'Workout not found.';

  @override
  String get modifica => 'Edit';

  @override
  String get iniziaOra => 'Start now';

  @override
  String get aggiungiAlPiano => 'Add to plan';

  @override
  String allaFineSegna(Object p0) {
    return 'At the end, log: $p0';
  }

  @override
  String get servonoNomeAlmenoEsercizio =>
      'You need a name and at least one exercise.';

  @override
  String get durataVa0300 => 'Duration goes from 0 to 300 minutes.';

  @override
  String get nuovoAllenamento => 'New workout';

  @override
  String get salva => 'Save';

  @override
  String get nome => 'Name';

  @override
  String get es50507 => 'e.g. 50-50, 7:3s 40%';

  @override
  String get categoria => 'Category';

  @override
  String get dove => 'Where';

  @override
  String get vuotoCalcoloDagliEsercizi =>
      'Empty = I work it out from the exercises.';

  @override
  String get descrizione => 'Description';

  @override
  String get cosaSegnareAllaFine => 'What to log at the end';

  @override
  String get esGradoMedioDelle => 'e.g. the average grade of the two parts';

  @override
  String get spostaSu => 'Move up';

  @override
  String get togli => 'Remove';

  @override
  String get aggiungiEsercizio => 'Add an exercise';

  @override
  String get controllaNomeSerie1 =>
      'Check: name, sets 1-20, reps 1-100, seconds 0-3600.';

  @override
  String get esercizio3 => 'Exercise';

  @override
  String get esSospensioniVieBlocchi => 'e.g. Hangs, Routes, Problems';

  @override
  String get serie2 => 'Sets';

  @override
  String get ripetizioni => 'Reps';

  @override
  String get lavoro => 'Work';

  @override
  String get pausa2 => 'Pause';

  @override
  String get traSerie => 'Between sets';

  @override
  String get lavoroVuotoFincheNon =>
      'Empty work = until you\'ve finished (a route, a problem): you tap \"Done\". Pause: between one rep and the next.';

  @override
  String get intensitaOGrado => 'Intensity or grade';

  @override
  String get es406bFacile => 'e.g. 40%, 6b+, easy';

  @override
  String get note => 'Notes';

  @override
  String get ok => 'OK';

  @override
  String get attivita2 => 'What activity is it?';

  @override
  String get nomeRestaSullaSessione =>
      'The name stays on the session, in the calendar and in the history.';

  @override
  String get esKayakPadelSci => 'E.g. Kayak, Padel, Skiing';

  @override
  String get registraPercorsoGps => 'Record the GPS route';

  @override
  String get mappaDistanzaVelocitaAnche =>
      'Map, distance and speed, even with the screen off. Off: only time and heart rate.';

  @override
  String get inizia2 => 'Start';

  @override
  String get avanti => 'Next';

  @override
  String get datiCollegamenti => 'Data and connections';

  @override
  String get collegaOrologioOApp =>
      'Connect your watch or the apps you use (Garmin, Freeletics…) through Health Connect: completed workouts arrive by themselves.';

  @override
  String get paroleDellAllenamento => 'Training words';

  @override
  String get concetti => 'Concepts';

  @override
  String get zoneComeTiDevi => 'Zones: how you should feel';

  @override
  String zona(Object p0) {
    return 'Zone $p0';
  }

  @override
  String get tipiSeduta => 'Session types';

  @override
  String prova(Object p0) {
    return ' · test $p0';
  }

  @override
  String avidididadiVersione(Object p0, Object p1, Object p2) {
    return 'Avidididadi · version $p0 ($p1)$p2';
  }

  @override
  String get tuaArrampicata => 'Your climbing';

  @override
  String get palestra => 'Gym';

  @override
  String get falesiaOZona => 'Crag or area';

  @override
  String get facoltativo => 'Optional';

  @override
  String get cosaHaiFatto => 'What you did';

  @override
  String get scegliVieOBoulder =>
      'Choose routes or boulder: the grades use two different scales.';

  @override
  String get gradoPiuDifficileChiuso => 'Hardest grade sent';

  @override
  String nuovoRecordPrimaEra(Object p0) {
    return 'New record! It was $p0 before.';
  }

  @override
  String tuoRecord(Object p0, Object p1, Object p2, Object p3) {
    return 'Your record: $p0 ($p1 $p2 $p3).';
  }

  @override
  String get alPrimoTentativoSenza =>
      'First try, without knowing anything beforehand.';

  @override
  String get alPrimoTentativoSapendo => 'First try, already knowing the moves.';

  @override
  String get chiusaDopoAverlaProvata => 'Sent after trying it several times.';

  @override
  String get comeHaiChiusaFacoltativo => 'How did you send it? (optional)';

  @override
  String get vieChiuse2 => 'Routes sent';

  @override
  String get blocchiChiusi2 => 'Problems sent';

  @override
  String provatSenzaChiuderl(Object p0, Object p1) {
    return 'Tried without sending';
  }

  @override
  String get altezzaMediaDelleVie => 'Average route height (m)';

  @override
  String circaMetriSaliti(Object p0) {
    return 'About $p0 meters climbed.';
  }

  @override
  String get progettoGradoStaiProvando =>
      'Project (the grade you\'re working on)';

  @override
  String get nessuno => 'None';

  @override
  String get meno => 'Less';

  @override
  String get piu => 'More';

  @override
  String get comAndataQuestaSettimana => 'How did this week go?';

  @override
  String get giovediHoPocoTempo =>
      'I\'m short on time on Thursday: what should I move?';

  @override
  String get adattaProssimiGiorniAl => 'Adapt the next few days to my recovery';

  @override
  String get sonoProntoGara => 'Am I ready for the race?';

  @override
  String collegato2(Object p0) {
    return 'Connected to $p0';
  }

  @override
  String get impostazioniAssistente => 'Assistant settings';

  @override
  String get chiedimiDeiTuoiAllenamenti =>
      'Ask me about your workouts: I see the last 4 weeks, the feedback, your recovery and the plan for the next 14 days. If I suggest changing the plan, you decide whether to apply it.';

  @override
  String get stoPensando => 'Thinking…';

  @override
  String get scriviMessaggio => 'Write a message';

  @override
  String get invia => 'Send';

  @override
  String get allenatoreCuiParlareDei =>
      'A coach to talk with about your workouts, who can suggest changes to the plan. Use the model you prefer:';

  @override
  String get facoltativoSenzaAssistenteApp =>
      'It\'s optional: without an assistant the app works as always.';

  @override
  String get configuraAssistente => 'Set up assistant';

  @override
  String get modificheProposteAlPiano => 'Suggested changes to the plan';

  @override
  String get applicateAlPiano => 'Applied to the plan.';

  @override
  String get nonApplicabili => 'Can\'t be applied';

  @override
  String get nienteApplicarePianoCambiato =>
      'Nothing to apply: the plan has changed in the meantime.';

  @override
  String pianoAggiornatoModificheVedi(Object p0) {
    return 'Plan updated: $p0 changes. You can see them in the calendar.';
  }

  @override
  String applicaModifiche(Object p0) {
    return 'Apply $p0 changes';
  }

  @override
  String get nessunModelloDisponibileQuesta =>
      'No model available with this key.';

  @override
  String get consigliato => 'Recommended';

  @override
  String get coachNellaSuaApp =>
      'The coach is in its own app. Disconnect from the Coach page to go back to the service below.';

  @override
  String get usaTuoAbbonamentoClaude =>
      'Use your subscription (Claude, ChatGPT, Gemini…)';

  @override
  String get senzaChiaveApiParli =>
      'No API key: you talk with the coach in your assistant\'s app.';

  @override
  String get coachNellAppQuando => 'Coach in the app (when you disconnect)';

  @override
  String get servizio => 'Service';

  @override
  String get chiaveApi => 'API key';

  @override
  String chiaveSalvata(Object p0) {
    return 'Key saved ••••$p0';
  }

  @override
  String get cifrataSulTelefono => 'Encrypted on the phone.';

  @override
  String get incollaChiaveApi => 'Paste the API key';

  @override
  String get salvaChiave => 'Save key';

  @override
  String get siPagaConsumoSul =>
      'You pay per use on your account: a question usually costs a few cents or less. You can set a spending limit on the service\'s website.';

  @override
  String get indirizzoOllama => 'Ollama address';

  @override
  String get indirizzoPc => 'PC address';

  @override
  String get sulPcInstallaOllama =>
      'On the PC: install Ollama, download a model (ollama pull llama3.1) and start it with OLLAMA_HOST=0.0.0.0 so the phone can reach it. You\'ll find the PC\'s IP address with \"ipconfig\".';

  @override
  String get modello => 'Model';

  @override
  String get nomeModello => 'Model name';

  @override
  String get vuotoPiuAdattoTra => 'Empty = the best fit among those available';

  @override
  String get scegliTraModelliDisponibili => 'Choose from the available models';

  @override
  String get datiInviati => 'Data sent';

  @override
  String get nomeFotoNonVengono => 'Name and photo are never sent.';

  @override
  String get acconsentoInviareQuestiDati2 =>
      'I agree to send this data to my PC with Ollama';

  @override
  String acconsentoInviareQuestiDati3(Object p0) {
    return 'I agree to send this data to $p0 with every message';
  }

  @override
  String nonRaggiungibile(Object p0) {
    return '$p0 can\'t be reached';
  }

  @override
  String verifica(Object p0) {
    return 'Checking $p0…';
  }

  @override
  String get provaConnessione2 => 'Test connection';

  @override
  String collegamento(Object p0) {
    return 'Connecting to $p0…';
  }

  @override
  String get riprova => 'Retry';

  @override
  String nonCollegato(Object p0) {
    return '$p0 not connected';
  }

  @override
  String togliere(Object p0) {
    return 'Remove $p0?';
  }

  @override
  String seduteFutureEsconoDal(Object p0) {
    return 'Future $p0 sessions leave the calendar. The ones already done stay in the history.';
  }

  @override
  String get tueAttivitaSonoAggiornate => 'Your activities are up to date.';

  @override
  String get mieAttivita => 'My activities';

  @override
  String get nelPianoNeiMenu =>
      'In the plan and menus you only see these. From \"+\" you can always do something else too, and everything you do stays in the history.';

  @override
  String quando(Object p0) {
    return '$p0: when?';
  }

  @override
  String get scegliGiorniAllenamentoDecidi =>
      'Choose the days. You decide the workout, or ask the assistant: the app doesn\'t write one by itself.';

  @override
  String get scegliGiorniMettiamoSedute =>
      'Choose the days: we\'ll put the sessions in the calendar.';

  @override
  String get quantoDura => 'How long';

  @override
  String get nonOra => 'Not now';

  @override
  String get mettiNelCalendario => 'Put in the calendar';

  @override
  String get scriviAlmenoPeso => 'Write at least one weight';

  @override
  String get pesiDisponibili => 'Available weights';

  @override
  String get nessunPeso => 'No weights';

  @override
  String letti(Object p0) {
    return 'Read: $p0';
  }

  @override
  String get miaAttrezzatura => 'My equipment';

  @override
  String corpoLiberoSempreIncluso(Object p0, Object p1) {
    return 'Bodyweight is always included. With this equipment you can do $p0 exercises out of $p1.';
  }

  @override
  String get palestra2 => 'At the gym';

  @override
  String get selezionaTutte => 'Select all';

  @override
  String get salvaBackup => 'Save the backup';

  @override
  String get backupSalvatoCopialoAnche =>
      'Backup saved. Copy it off the phone too (Drive, PC) so you don\'t lose it.';

  @override
  String backupNonRiuscito(Object p0) {
    return 'Backup failed: $p0';
  }

  @override
  String impossibileLeggereFile(Object p0) {
    return 'Can\'t read the file: $p0';
  }

  @override
  String get ripristinareBackup => 'Restore the backup?';

  @override
  String tuttiDatiAttualiDell(Object p0) {
    return '$p0.\n\nAll the current data in the app will be replaced. If you\'re not sure, save a backup of now first.';
  }

  @override
  String get ripristina => 'Restore';

  @override
  String get datiRipristinatiAllaProssima =>
      'Data restored. At the next sync Health Connect reads the history again.';

  @override
  String ripristinoNonRiuscito(Object p0) {
    return 'Restore failed: $p0';
  }

  @override
  String get backupSalvatoNellaCartella => 'Backup saved in the folder.';

  @override
  String get backupAutomatico => 'Automatic backup';

  @override
  String get cartellaTelefono => 'a folder on the phone';

  @override
  String ultimo(Object p0) {
    return ' · last $p0';
  }

  @override
  String inTesto(Object p0, Object p1) {
    return 'In $p0$p1';
  }

  @override
  String cartellaScegliTuResta(Object p0) {
    return 'In a folder you choose: it stays even if you uninstall the app. Keeps the last $p0.';
  }

  @override
  String get ogniGiorno => 'Every day';

  @override
  String get ogniSettimana => 'Every week';

  @override
  String get siFaSoloQuando =>
      'It runs by itself when you open the app. So you don\'t lose it with the phone, now and then copy the folder to your PC or Drive.';

  @override
  String get falloOra => 'Do it now';

  @override
  String get cambiaCartella => 'Change folder';

  @override
  String get backup => 'Backup';

  @override
  String get unicoFileSessioniPiano =>
      'A single file with sessions, plan, profile, measurements, feedback, recovery and photo. The assistant key is not included.';

  @override
  String get salvaBackup2 => 'Save backup';

  @override
  String get backupAttivoOraSi =>
      'Backup on: from now on it saves itself every week.';

  @override
  String get mettiAlSicuroTuoi =>
      'Keep your workouts safe: the app saves a copy by itself in a folder you choose. It stays even if you uninstall the app.';

  @override
  String get scegliNuovoCartella => 'Choose the folder again';

  @override
  String get attivaBackup => 'Turn on backup';

  @override
  String get battitoDalSensore => 'Heart rate from sensor';

  @override
  String get fasciaCardioOOrologio =>
      'A chest strap or a watch that broadcasts heart rate via Bluetooth. You see it during the workout; at the end the average and maximum are saved.';

  @override
  String get garminSullOrologioCerca =>
      'Garmin: on the watch look for \"Broadcast heart rate\" (usually in the controls, holding the light button) and turn it on: then tap \"Search\". Some older models only broadcast over ANT+, which the phone can\'t read.\nChest strap: put it on wetting the electrodes a little, it turns on by itself.\nOnce chosen, the sensor reconnects by itself at every workout.';

  @override
  String get sensoriBici => 'Bike sensors';

  @override
  String get rulliSmartTacxWahoo =>
      'Smart trainers (Tacx, Wahoo, Elite…), power meter or speed and cadence sensor, via Bluetooth. At the end the average power and cadence are saved.';

  @override
  String get rulliAccendiliSmettiUsarli =>
      'Trainers: turn them on and stop using them with other apps (Zwift, Tacx), because many connect to only one app at a time.\nSpeed or cadence sensor: it wakes up when you turn the wheel or the pedals.\nThe wheel circumference is only needed for the speed sensor: you\'ll find it written on the tire (e.g. 700×25C = 2105 mm).';

  @override
  String get servePermessoDispositiviNelle =>
      'The \"Nearby devices\" permission is needed.';

  @override
  String get apriImpostazioni => 'Open settings';

  @override
  String get bluetoothSpentoAccendiloRiprova =>
      'Bluetooth is off: turn it on and try again.';

  @override
  String collegato3(Object p0) {
    return 'Connected · $p0';
  }

  @override
  String get collegatoAspettoDati => 'Connected, waiting for data…';

  @override
  String get miCollegoDevEssere => 'Connecting… (it must be on and nearby)';

  @override
  String get nonCollegato2 => 'Not connected';

  @override
  String get dimentica => 'Forget';

  @override
  String get cercoSensoriVicini => 'Looking for nearby sensors…';

  @override
  String get sensoriTrovati => 'Sensors found';

  @override
  String get nessunSensoreTrovato => 'No sensor found.';

  @override
  String get cercaAltroSensore => 'Look for another sensor';

  @override
  String get cercaNuovo => 'Search again';

  @override
  String get comeSiCollega => 'How to connect';

  @override
  String get segnaleForte => 'Strong signal';

  @override
  String get segnaleMedio => 'Medium signal';

  @override
  String get segnaleDebole => 'Weak signal';

  @override
  String adessoKmH(Object p0) {
    return ' Now: $p0 km/h.';
  }

  @override
  String get maiFattaQui => 'Never done from here.';

  @override
  String ultima(Object p0) {
    return 'Last: $p0.';
  }

  @override
  String tienePrecisiWattFalla(Object p0) {
    return '$p0 Keeps the watts accurate: do it about every two weeks and whenever you move the trainer, ideally after 10 minutes of pedaling.';
  }

  @override
  String get chiedoAlRulloIniziare => 'Asking the trainer to start…';

  @override
  String pedalaAcceleraFincheRullo(Object p0) {
    return 'Pedal and speed up until the trainer tells you to stop.$p0';
  }

  @override
  String acceleraFinoSuperareKm(Object p0, Object p1) {
    return 'Speed up until you go over $p0 km/h.$p1';
  }

  @override
  String smettiPedalareAspettaRullo(Object p0) {
    return 'Stop pedaling and wait for the trainer to stop.$p0';
  }

  @override
  String get calibrazioneRiuscita => 'Calibration successful.';

  @override
  String get nonRiuscitaControllaNessun =>
      'It didn\'t work. Check that no other app is using the trainer and try again.';

  @override
  String get calibraRullo => 'Calibrate the trainer';

  @override
  String get iniziaCalibrazione => 'Start calibration';

  @override
  String get circonferenzaRuota => 'Wheel circumference';

  @override
  String get soloSensoreVelocita700 =>
      'Only for the speed sensor. 700×25C: 2105 mm.';

  @override
  String get tuoPianoProntoPrima =>
      'Your plan is ready! The first session is here, in \"Today\". You can change days and duration whenever you like from Profile.';

  @override
  String get tuoPianoProntoOggi =>
      'Your plan is ready! In \"Today\" you\'ll find what to do every day.';

  @override
  String get indietro => 'Back';

  @override
  String get comeTiChiami => 'What\'s your name?';

  @override
  String get cosiAppTiSaluta => 'So the app can greet you by name.';

  @override
  String get tuoNome => 'Your name';

  @override
  String get cosaTiPiacerebbeFare => 'What would you like to do?';

  @override
  String get puoiScegliernePiuUno =>
      'You can choose more than one. With \"Start today\" you begin with 3 sessions of 30 minutes a week (Monday, Wednesday and Friday), suited to beginners, and the first one is today. You can change everything whenever you like.';

  @override
  String get quantoTempoHai => 'How much time do you have?';

  @override
  String get meglioPocoMaCostanza =>
      'Little but often is better: to start, 3 days of 30 minutes are perfect.';

  @override
  String get giorniSettimana => 'Days per week';

  @override
  String get minutiOgniVolta => 'Minutes each time';

  @override
  String giorniNonCSpazio(Object p0, Object p1) {
    return 'With $p0 days there isn\'t room for all the chosen sports: I\'ll use $p1.';
  }

  @override
  String get quantoTiAlleniSolito => 'How often do you usually train?';

  @override
  String get rispondiSinceramentePianoParte =>
      'Answer honestly: the plan starts from your level and grows with you.';

  @override
  String get iniziaOggi => 'Start today';

  @override
  String get primaScelgoGiorniDurata =>
      'First I\'ll choose days, duration and level';

  @override
  String get creaMioPiano => 'Create my plan';

  @override
  String get scegliAlmenoUnoSport => 'Choose at least one sport';

  @override
  String get benvenuto => 'Welcome!';

  @override
  String get tiPreparoPianoAllenamento =>
      'I\'ll prepare a training plan made for you, even if you\'ve never trained. Every day I tell you what to do, step by step, and the plan adapts to how you feel.';

  @override
  String get scegliTuoiSportParti => 'Choose your sports and start right away.';

  @override
  String get iniziamo => 'Let\'s start';

  @override
  String get saltaPreferiscoFareSolo => 'Skip, I\'d rather do it myself';

  @override
  String get haiOrologioSportivo => 'Do you have a sports watch?';

  @override
  String get vaBeneAncheSenza =>
      'It\'s fine without one too: the app works with just the phone.';

  @override
  String get noSoloTelefono => 'No, just the phone';

  @override
  String get nienteOrologioFasciaCardio =>
      'No watch, chest strap or other apps.';

  @override
  String get siOrologioOFascia => 'Yes, a watch or a strap';

  @override
  String get garminPolarSuuntoCoros => 'Garmin, Polar, Suunto, Coros, Wahoo…';

  @override
  String get corsaCamminataBiciRegistra =>
      'The phone records runs, walks and rides with GPS, and guides you by voice step by step.';

  @override
  String get zoneEsempioZona2 =>
      'Follow the zones (for example \"zone 2\") by feel: in zone 2 you can still talk.';

  @override
  String get dopoOgniSedutaRispondi =>
      'After every session answer \"How did it go?\": that\'s how the plan understands your effort and adapts.';

  @override
  String get nuotoSenzaOrologioSegni =>
      'Without a watch, you log swimming by hand after the pool.';

  @override
  String get energiaSonnoRestanoVuoti =>
      'Energy and sleep stay empty: they need data from a watch.';

  @override
  String get dopoCollegaloProfiloDati =>
      'Connect it later from Profile → Data and connections: with Health Connect, or with intervals.icu for Garmin and the others. Activities arrive by themselves, with heart rate and sleep.';

  @override
  String get haiRulloSmartCollegalo =>
      'Do you have a smart trainer? Connect it during the workout: the app sends it the watts for each step.';

  @override
  String get eccoTuaSettimana => 'Here\'s your week';

  @override
  String eccoTuaSettimana2(Object p0) {
    return 'Here\'s your week, $p0';
  }

  @override
  String get ogniGiornoNellaPagina =>
      'Every day, on the \"Today\" page, you\'ll find what to do. You can change days and times whenever you like.';

  @override
  String minuti(Object p0, Object p1) {
    return '$p0 · $p1 minutes';
  }

  @override
  String get cosHaiFatto => 'What did you do?';

  @override
  String get poiScriviDurataTutto =>
      'Then write the duration and everything you remember.';

  @override
  String get ciao => 'Hi!';

  @override
  String ciao2(Object p0) {
    return 'Hi $p0';
  }

  @override
  String get chiudiMese => 'Close the month';

  @override
  String get vediTuttoMese => 'See the whole month';

  @override
  String get prossimi => 'Coming up';

  @override
  String get tuoPiano => 'Your plan';

  @override
  String get cambiaAllenamentiOggi => 'Change today\'s workouts';

  @override
  String cambiaAllenamenti(Object p0) {
    return 'Change the workouts on $p0';
  }

  @override
  String get spostaAggiungiOTogli => 'Move, add or remove: only for that day';

  @override
  String get scriviAttivitaFattaOggi => 'Log an activity done today';

  @override
  String scriviAttivitaFatta(Object p0) {
    return 'Log an activity done $p0';
  }

  @override
  String get quelloNonHaiRegistrato =>
      'For what you didn\'t record: duration, distance, heart rate…';

  @override
  String get miaSettimanaTipo => 'My typical week';

  @override
  String get qualiGiorniTiAlleni => 'Which days you train and for how long';

  @override
  String get allungaCalendario => 'Extend the calendar';

  @override
  String get ripeteSettimanaTipoNei =>
      'Repeats the typical week in the coming months: it decides the days, not the exercises';

  @override
  String get mesePrima => 'Previous month';

  @override
  String get meseDopo => 'Next month';

  @override
  String get fare => 'to do';

  @override
  String get toccaGiornoVederloTienilo =>
      'Tap a day to see it, hold it to change it.';

  @override
  String get buona => 'Good';

  @override
  String get normale => 'Normal';

  @override
  String get bassa => 'Low';

  @override
  String energia(Object p0) {
    return 'Energy $p0';
  }

  @override
  String get tuaSettimana => 'Your week';

  @override
  String settimanaDal2(Object p0, Object p1) {
    return 'Week from $p0 $p1';
  }

  @override
  String fatti(Object p0) {
    return ' of $p0 done';
  }

  @override
  String settimanaCompletataAllenamenti(Object p0) {
    return 'Week completed: $p0 workouts!';
  }

  @override
  String get tornaOggi => 'Back to today';

  @override
  String get oggiSeiPocoRecuperato =>
      'You\'re not well recovered today: instead of the planned session you can do 20 minutes of mobility.';

  @override
  String get vediAllenamento => 'See the workout';

  @override
  String get primaGuardaEsercizi => 'First look at the exercises';

  @override
  String get giornoRiposo => 'Rest day';

  @override
  String get quelGiornoNonRisultano => 'There are no workouts that day.';

  @override
  String get riposoFaParteDell =>
      'Rest is part of training: muscles get stronger while you recover.';

  @override
  String get seTiVa15 => 'If you feel like it: 15 minutes of mobility';

  @override
  String get voglioAllenarmiStesso => 'I want to train anyway';

  @override
  String get nonFatto => 'not done';

  @override
  String fatica10(Object p0) {
    return 'Effort $p0/10';
  }

  @override
  String get comAndata => 'How did it go?';

  @override
  String get rigenerarePiano => 'Regenerate the plan?';

  @override
  String sessioniDalPoiVerranno(Object p0) {
    return 'Sessions from $p0 onward will be replaced. Earlier ones stay as they are.';
  }

  @override
  String get rigenera => 'Regenerate';

  @override
  String get pianoGenerato => 'Plan generated';

  @override
  String get ripeteTuaSettimanaTipo =>
      'Repeats your typical week (which sports, which days, how many minutes) over the months you choose. The exercises for each session are prepared from Profile, with \"Prepare the sessions\".';

  @override
  String durata2(Object p0, Object p1) {
    return 'Duration: $p0 $p1';
  }

  @override
  String parti(Object p0) {
    return 'Start from $p0';
  }

  @override
  String modifica2(Object p0) {
    return 'Edit $p0';
  }

  @override
  String get cambiaSoloQuestoGiorno =>
      'Change only this day: the other weeks stay as they are.';

  @override
  String get nessunaAttivitaProgrammaGiorno =>
      'No activity planned (rest day).';

  @override
  String min3(Object p0, Object p1) {
    return '$p0, $p1 min';
  }

  @override
  String get rimuovi => 'Remove';

  @override
  String get aggiungiAttivita => 'Add activity';

  @override
  String get comAndataVotoAlla =>
      'How did it go? Rating the effort makes the plan more accurate.';

  @override
  String get calendarioVuotoAllungaloSapere =>
      'The calendar is empty: extend it to know what to do every day.';

  @override
  String calendarioFinitoAllungaloProssimi(Object p0) {
    return 'The calendar ended on $p0. Extend it for the coming months.';
  }

  @override
  String traGiorni(Object p0) {
    return 'in $p0 days';
  }

  @override
  String calendarioFinisceVuoiAllungarlo(Object p0, Object p1) {
    return 'The calendar ends $p0 ($p1). Do you want to extend it?';
  }

  @override
  String get allunga => 'Extend';

  @override
  String get piuTardi => 'Later';

  @override
  String scheda(Object p0) {
    return '$p0\'s plan';
  }

  @override
  String scheda2(Object p0) {
    return 'The plan \"$p0\"';
  }

  @override
  String finitaIntantoSeduteSono(Object p0, Object p1) {
    return '$p0 ended on $p1. Meanwhile the sessions are the ones prepared by the app.';
  }

  @override
  String rinnovaGiorni(Object p0) {
    return 'Renew for $p0 days';
  }

  @override
  String get cambiala => 'Change it';

  @override
  String get usaQuellaDellApp => 'Use the app\'s one';

  @override
  String get cosaVuoiFareAdesso => 'What do you want to do now?';

  @override
  String get siAggiungeQuelloC => 'It adds to what\'s planned for today.';

  @override
  String get iniziaAttivitaLibera => 'Start a free activity';

  @override
  String get catalogoEsercizi => 'Exercise catalog';

  @override
  String get toccaEsercizioVedereMuscoli =>
      'Tap an exercise to see the muscles it works.';

  @override
  String get cercaNomeOMuscolo => 'Search by name or muscle';

  @override
  String get tutti => 'All';

  @override
  String get soloMiaAttrezzatura => 'Only with my equipment';

  @override
  String get nessunEsercizioQuestiFiltri => 'No exercises with these filters.';

  @override
  String serve(Object p0) {
    return 'Needs: $p0';
  }

  @override
  String get immaginiIstruzioni => 'Images and instructions';

  @override
  String principali(Object p0) {
    return 'Main: $p0';
  }

  @override
  String secondari(Object p0) {
    return 'Secondary: $p0';
  }

  @override
  String get comeSiEsegue => 'How to do it';

  @override
  String immaginiFreeExerciseDb(Object p0) {
    return 'Images from free-exercise-db ($p0).';
  }

  @override
  String get tueSerie => 'Your sets';

  @override
  String recordKg(Object p0, Object p1) {
    return 'Record: $p0 kg × $p1';
  }

  @override
  String recordRipetizioni(Object p0) {
    return 'Record: $p0 reps';
  }

  @override
  String get condividi => 'Share';

  @override
  String get mappaNonProntaRiprova => 'The map isn\'t ready: try again.';

  @override
  String get immagineNonRiuscitaRiprova => 'Image failed: try again.';

  @override
  String get immagineSiCreaSul =>
      'The image is created on the phone and only goes to the app you choose (WhatsApp, Instagram…).';

  @override
  String get condividiSessione => 'Share the session';

  @override
  String get grafica => 'Design';

  @override
  String get tipoMappa => 'Map type';

  @override
  String get mappaFaVedereDove =>
      'The map shows where you went: careful if you start from home.';

  @override
  String get scegliAltraFoto => 'Choose another photo';

  @override
  String get spostaIngrandisciFotoDue =>
      'Move and zoom the photo with two fingers. It stays on the phone: the location where it was taken doesn\'t go into the image.';

  @override
  String get mostraPercorso => 'Show the route';

  @override
  String get faVedereFormaGiro =>
      'Shows the shape of the loop: careful if you start from home.';

  @override
  String nuovoRecord(Object p0) {
    return 'New record: $p0';
  }

  @override
  String get passoMedio => 'Average pace';

  @override
  String get kmPiuVeloce => 'Fastest km';

  @override
  String get mSalita => 'm of climbing';

  @override
  String get quotaMassima => 'max altitude';

  @override
  String get passoOgni100M => 'PACE PER 100 m';

  @override
  String get n100PiuVeloce => 'Fastest 100';

  @override
  String get gradoPiuAlto => 'highest grade';

  @override
  String gradoPiuAlto2(Object p0) {
    return 'highest grade · $p0';
  }

  @override
  String get primaSedutaQuiSi => 'The first session: it\'s up from here';

  @override
  String gradoPiuAltoDelle(Object p0) {
    return 'The highest grade in the last $p0 sessions';
  }

  @override
  String get progetto2 => 'Project';

  @override
  String get condividiSettimana => 'Share the week';

  @override
  String get settimanaPrima => 'Previous week';

  @override
  String get questaSettimana => 'This week';

  @override
  String get settimanaDopo => 'Next week';

  @override
  String settimana(Object p0) {
    return 'Week $p0';
  }

  @override
  String get nessunaSessioneQuestaSettimana => 'No sessions this week.';

  @override
  String get eserciziSceltiTeTua =>
      'Exercises chosen for you and your equipment, with sets, reps and weights. It always ends with a bit of mobility.';

  @override
  String get corseFaciliSedutaPiu =>
      'Easy runs, one harder session (fartlek, tempo, intervals) and the long run that grows toward the race.';

  @override
  String get tecnicaSerieAlTuo =>
      'Technique and sets at your pace, alternated with harder ones.';

  @override
  String get usciteFaciliIntervalliUscita =>
      'Easy rides, intervals and a long ride.';

  @override
  String get stretchingMovimentiLentiTempo =>
      'Stretching and slow movements, timed: a different part of the body each time. Great for recovery too.';

  @override
  String seduteRestanoNelCalendario(Object p0) {
    return 'The $p0 sessions stay in the calendar, but without prepared exercises. The ones already done don\'t change.';
  }

  @override
  String get sedutePreparateTolte => 'Prepared sessions removed.';

  @override
  String pronteSeduteTroviOggi(Object p0, Object p1) {
    return '$p0 $p1 sessions ready. You\'ll find them in Today.';
  }

  @override
  String get forzaComeVuoi => 'Strength: how you want it';

  @override
  String get obiettivo => 'Goal';

  @override
  String get livello => 'Level';

  @override
  String get nonPreoccupartiSbagliareLivello =>
      'Don\'t worry about getting it wrong: the level adapts to the ratings you give at the end of each session.';

  @override
  String get attrezzatura => 'Equipment';

  @override
  String get soloCorpoLibero => 'Bodyweight only';

  @override
  String comeCrescere(Object p0) {
    return '$p0: how to progress';
  }

  @override
  String get sedutaLungaCosaFare =>
      'Long session, and what to do if it\'s easy';

  @override
  String get sedutaLunga => 'Long session';

  @override
  String get ultimaCorsaOUscita =>
      'The last run or ride of the week lasts longer and grows over time. Off: they all last as long as you chose.';

  @override
  String get preparaSedute => 'Prepare the sessions';

  @override
  String get scegliQualiSportVuoi =>
      'Choose the sports for which you want the app to write step-by-step workouts. It only prepares the ones you tick.';

  @override
  String get qualiSport => 'Which sports?';

  @override
  String get giaPreparato => 'already prepared';

  @override
  String settimana2(Object p0, Object p1) {
    return '$p0 $p1 a week';
  }

  @override
  String calendario(Object p0, Object p1) {
    return '$p0 $p1 in the calendar';
  }

  @override
  String get nessunaSedutaCalendario => 'no sessions in the calendar';

  @override
  String get cambiaGiorniMinutiSettimana =>
      'Change days and minutes (typical week)';

  @override
  String get tuePreferenze => 'Your preferences';

  @override
  String get senzaGaraSeduteCrescono =>
      'Without a race, sessions grow in 4-week blocks, with a lighter one. You can set a race from Profile, under My goal.';

  @override
  String seduteCambianoAvvicinarsiGara(Object p0) {
    return '$p0: sessions change as the race gets closer.';
  }

  @override
  String nessunGiornoNelCalendario(Object p0) {
    return '$p0: no days in the calendar';
  }

  @override
  String get nellaSettimanaTipoMa =>
      'It\'s in the typical week but not in the calendar yet. Open the typical week and tap \"Bring the whole week into the calendar\".';

  @override
  String get calendarioVuoto => 'The calendar is empty';

  @override
  String get primaAllungaCalendarioPoi =>
      'Extend the calendar first: then the sessions fill up.';

  @override
  String seduteSiPreparanoFino(Object p0) {
    return 'Sessions are prepared up to $p0; when you extend the calendar they\'re added by themselves.';
  }

  @override
  String get togliSedutePreparate => 'Remove the prepared sessions';

  @override
  String get aggiornaSedute => 'Update the sessions';

  @override
  String prepara(Object p0) {
    return 'Prepare $p0';
  }

  @override
  String get dataNascita => 'Date of birth';

  @override
  String get altezzaCmTra50 => 'Height in cm, between 50 and 250';

  @override
  String get pesoKgTra20 => 'Weight in kg, between 20 and 300';

  @override
  String get datiPersonali => 'Personal data';

  @override
  String get cognome => 'Surname';

  @override
  String get toccaSceglierla => 'Tap to choose it';

  @override
  String get altezza => 'Height';

  @override
  String get peso => 'Weight';

  @override
  String get pesoNuovoSiRegistra =>
      'A new weight is recorded with today\'s date.';

  @override
  String get ok2 => 'Ok';

  @override
  String mancano(Object p0) {
    return ' $p0 to go.';
  }

  @override
  String get pausa3 => 'Paused.';

  @override
  String get siRiparte => 'Going again.';

  @override
  String chilometri(Object p0) {
    return ', $p0 kilometers';
  }

  @override
  String allenamentoCompletato(Object p0, Object p1) {
    return 'Workout complete. $p0$p1.';
  }

  @override
  String get interrompereAllenamento => 'Stop the workout?';

  @override
  String get puoiTerminarloQuiVedere =>
      'You can finish it here and see the summary, or exit without saving.';

  @override
  String get esci => 'Exit';

  @override
  String get terminaQui => 'Finish here';

  @override
  String get continua => 'Continue';

  @override
  String get questoAllenamentoNonHa => 'This workout has no steps.';

  @override
  String get tempoTotale => 'total time';

  @override
  String get bipVibrazione => 'Beeps and vibration';

  @override
  String get cadenza => 'Cadence';

  @override
  String get poi => 'Next';

  @override
  String get esercizioPrecedente => 'Previous exercise';

  @override
  String get iniziaSubito => 'Start now';

  @override
  String get saltaRecupero => 'Skip rest';

  @override
  String get fatto => 'Done';

  @override
  String get n15SecondiPiu => '15 more seconds';

  @override
  String get salta => 'Skip';

  @override
  String get partiQuandoVuoi => 'Start when you\'re ready';

  @override
  String get preparati => 'Get ready';

  @override
  String esercizi2(Object p0, Object p1) {
    return '$p0 · $p1 exercises';
  }

  @override
  String siParte(Object p0) {
    return 'Starting with: $p0';
  }

  @override
  String indoor2(Object p0) {
    return 'Indoor ($p0)';
  }

  @override
  String get senzaGpsVelocitaKm =>
      'No GPS: speed and km come from the trainer.';

  @override
  String get senzaGpsAllaFine =>
      'No GPS: at the end write the km from the display.';

  @override
  String get seguiPercorso => 'Follow a route';

  @override
  String get facoltativoGpxMappaIndicazioni =>
      'Optional: a GPX with a map and voice directions';

  @override
  String get togliPercorso => 'Remove the route';

  @override
  String get rulloSensori => 'Trainer and sensors';

  @override
  String get sensoriBici2 => 'Bike sensors';

  @override
  String get collegatoOraCalibrarlo => 'Connected · time to calibrate it';

  @override
  String get toccaCollegare => 'Tap to connect';

  @override
  String get battito => 'Heart rate';

  @override
  String get allenamentoCompletato2 => 'Workout complete!';

  @override
  String movimentoTotale(Object p0, Object p1) {
    return 'Moving $p0 · total $p1';
  }

  @override
  String battitoMedioBpmMassimo(Object p0, Object p1) {
    return 'Average heart rate $p0 bpm · max $p1';
  }

  @override
  String potenzaMediaW(Object p0) {
    return 'Average power $p0 W';
  }

  @override
  String cadenzaRpm(Object p0) {
    return 'cadence $p0 rpm';
  }

  @override
  String cadenzaMediaRpm(Object p0) {
    return 'Average cadence $p0 rpm';
  }

  @override
  String circaKcal(Object p0) {
    return 'About $p0 kcal';
  }

  @override
  String km(Object p0) {
    return 'Km $p0';
  }

  @override
  String km2(Object p0) {
    return 'Km from the $p0';
  }

  @override
  String get kmPercorsi => 'Km covered';

  @override
  String get facoltativoSenzaSessioneResta =>
      'Optional: without it, the session has no distance.';

  @override
  String get segnaComeFatto => 'Mark as done';

  @override
  String get seOrologioRegistraStesso =>
      'If your watch records the same workout, its data wins.';

  @override
  String get inserisciDatiMano => 'Enter the data by hand';

  @override
  String segnaleGpsBuonoM(Object p0) {
    return 'Good GPS signal · ±$p0 m';
  }

  @override
  String get cercoSegnaleGpsMeglio => 'Looking for GPS signal… better outdoors';

  @override
  String get gpsNonPermessoTocca => 'GPS not allowed: tap to turn it on';

  @override
  String get posizioneSpentaToccaAccenderla =>
      'Location off: tap to turn it on';

  @override
  String get dati => 'Data';

  @override
  String get ultimoKm => 'Last km';

  @override
  String ultimiKm(Object p0) {
    return 'Last $p0 km';
  }

  @override
  String get velocitaMedia => 'Average speed';

  @override
  String potenzaZ(Object p0) {
    return 'Power · Z$p0';
  }

  @override
  String battitoZ(Object p0) {
    return 'Heart rate · Z$p0';
  }

  @override
  String get miCollego => 'Connecting…';

  @override
  String kmUltimi(Object p0, Object p1, Object p2) {
    return 'Km $p0 · last $p1 in $p2';
  }

  @override
  String mancanoSecondi(Object p0) {
    return '$p0 seconds to go';
  }

  @override
  String get tempoTrascorso => 'Time elapsed';

  @override
  String get pausa4 => 'paused';

  @override
  String get poiPassaSolo => 'then it moves on by itself';

  @override
  String get toccaFattoQuandoHai2 => 'tap Done when you\'ve finished';

  @override
  String guardaMovimento(Object p0) {
    return 'Watch how to do $p0';
  }

  @override
  String get kg3 => 'Kg';

  @override
  String ultimaVolta(Object p0) {
    return 'Last time: $p0';
  }

  @override
  String get aveviFattoTutteRipetizioni =>
      'You did all the reps: try a heavier weight.';

  @override
  String meno2(Object p0) {
    return '$p0: less';
  }

  @override
  String piu2(Object p0) {
    return '$p0: more';
  }

  @override
  String get nessunPeso2 => 'no weight';

  @override
  String get pesiDiversiDallaScheda => 'Weights different from the plan';

  @override
  String get scrittiNellaScheda => 'Written in the plan.';

  @override
  String get aggiornaScheda => 'Update the plan';

  @override
  String get segnaVieBlocchiGradi => 'Log routes, problems and grades';

  @override
  String get moltoLeggera => 'very light';

  @override
  String get moltoDura => 'very hard';

  @override
  String get alMassimo => 'all-out';

  @override
  String get feedbackSalvato2 => 'Feedback saved';

  @override
  String fatica102(Object p0, Object p1) {
    return 'Effort: $p0/10, $p1';
  }

  @override
  String tuoObiettivoFaticaGiusta(Object p0) {
    return 'For your goal the right effort is about $p0/10.';
  }

  @override
  String get comeQuesta => 'like this one';

  @override
  String sedutaFaticaPrevistaCirca(Object p0, Object p1) {
    return 'For a $p0 session the expected effort is about $p1/10.';
  }

  @override
  String get hoCompletatoTutteSerie => 'I completed all the sets';

  @override
  String get hoFattoTuttaSeduta => 'I did the whole session';

  @override
  String passoNellaPartePrincipale(Object p0, Object p1) {
    return 'Pace in the main part (target $p0:$p1/100 m)';
  }

  @override
  String get oppurePassoHaiTenuto => 'Or the pace you held (e.g. 2:45)';

  @override
  String get hoSentitoDoloreO => 'I felt pain or discomfort';

  @override
  String get noteFacoltative => 'Notes (optional)';

  @override
  String grafici(Object p0) {
    return 'Charts · $p0';
  }

  @override
  String get questaAttivitaNonCi =>
      'There\'s no data over time for this activity: it needs heart rate or speed recorded by the watch.';

  @override
  String get altitudine => 'Altitude';

  @override
  String get minima => 'Minimum';

  @override
  String get massima => 'Maximum';

  @override
  String get pendenza => 'Gradient';

  @override
  String get salitaMassima => 'Steepest climb';

  @override
  String get discesaMassima => 'Steepest descent';

  @override
  String get ftpCorsaStimataEta =>
      'Running FTP estimated from age and weight: for an accurate one do the test in Profile → My zones.';

  @override
  String get zoneServeTuoPeso =>
      'For the zones you need your weight (Profile), or the running FTP in Profile → My zones.';

  @override
  String get passiAlMinuto => 'Steps per minute';

  @override
  String get media => 'Average';

  @override
  String get bracciateAlMinuto => 'Strokes per minute';

  @override
  String get alMinuto => 'per minute';

  @override
  String get tempoNelleZone => 'Time in zones';

  @override
  String zoneCalcolateSullaTua(Object p0) {
    return 'Zones calculated on your max HR ($p0 bpm).';
  }

  @override
  String get migliore => 'Best';

  @override
  String tuaFtpCorsaW(Object p0) {
    return 'Your running FTP: $p0 W';
  }

  @override
  String get n95DeiTuoiMigliori =>
      'It\'s 95% of your best 20 minutes. It\'s valid if you ran all-out in those 20 minutes.';

  @override
  String get usalaComeFtpCorsa => 'Use it as running FTP';

  @override
  String get normalizzata => 'Normalized';

  @override
  String get zonePotenzaServeFtp =>
      'Power zones need your FTP: enter it in Profile → Zones, or set it on intervals.icu.';

  @override
  String get tempoNelleZonePotenza => 'Time in power zones';

  @override
  String zoneCalcolateSulTuo(Object p0) {
    return 'Zones calculated on your FTP ($p0 W).';
  }

  @override
  String get intensitaPrevistaTenutaTutta =>
      'Planned and actual intensity across the session';

  @override
  String alle(Object p0, Object p1, Object p2, Object p3, Object p4) {
    return '$p0/$p1/$p2 at $p3:$p4';
  }

  @override
  String get controlloHealthConnect => 'Checking Health Connect…';

  @override
  String get healthConnectInstallatoMa =>
      'Health Connect is installed but needs an update.';

  @override
  String get healthConnectNonInstallato2 =>
      'Health Connect is not installed. It\'s needed to read workouts from Garmin and Freeletics.';

  @override
  String get aggiornaHealthConnect => 'Update Health Connect';

  @override
  String get installaHealthConnect => 'Install Health Connect';

  @override
  String get nonCollegatoMancaPermesso =>
      'Not connected: the permission for sessions is missing.';

  @override
  String get permessi => 'Permissions';

  @override
  String get datiPiuVecchi30 => 'Data older than 30 days';

  @override
  String get maiSincronizzato => 'Never synced.';

  @override
  String ultimaSincronizzazione(Object p0) {
    return 'Last sync: $p0';
  }

  @override
  String sessioniHealthConnect(Object p0) {
    return 'Sessions from Health Connect: $p0';
  }

  @override
  String get fontiTrovate => 'Sources found';

  @override
  String sessioni(Object p0, Object p1, Object p2) {
    return '$p0: $p1 sessions  ($p2)';
  }

  @override
  String get tipiAttivitaIgnorati => 'Activity types ignored';

  @override
  String get sincronizzaOra => 'Sync now';

  @override
  String get rivediPermessi => 'Review permissions';

  @override
  String get salvaModello => 'Save the template';

  @override
  String get modelloSalvatoCompilaloRiga =>
      'Template saved. Fill it in (one row per session) and import it here.';

  @override
  String impossibileSalvareModello(Object p0) {
    return 'Can\'t save the template: $p0';
  }

  @override
  String impossibileAprireSelezioneDei(Object p0) {
    return 'Can\'t open the file picker: $p0';
  }

  @override
  String fileTroppoGrandeMassimo(Object p0) {
    return '$p0: file too large (20 MB max).';
  }

  @override
  String impossibileLeggereFile2(Object p0, Object p1) {
    return '$p0: can\'t read the file ($p1).';
  }

  @override
  String get opzioniAvanzate => 'Advanced options';

  @override
  String get importManualeCsvSenza => 'Manual import from CSV, without sync';

  @override
  String get seNonUsiApp =>
      'If you don\'t use apps connected to Health Connect you can enter sessions by hand: download the template, fill it in with a spreadsheet (one row per session) and import it. The data stays only on the phone.';

  @override
  String get colonneDataAaaaMm =>
      'Columns: data (YYYY-MM-DD), sport (Corsa, Bici, Nuoto, Forza), tipo_sessione, durata_min, distanza_km, fc_media, rpe, fonte, note. At least data and sport are needed. Column names and sports stay in Italian.';

  @override
  String get scaricaModelloCsv => 'Download CSV template';

  @override
  String get importaCsv => 'Import CSV';

  @override
  String get modificaIntervalli => 'Edit the intervals';

  @override
  String get toccaTrattoCambiareNome =>
      'Tap a segment to change its name, meters or time, or to remove it. Hold it and drag it to move it.';

  @override
  String get senzaNome => 'No name';

  @override
  String get aggiungiTratto => 'Add a segment';

  @override
  String get tornaQuelliDellOrologio => 'Back to the watch\'s ones';

  @override
  String get scriviTempoEs5 => 'Write the time, e.g. 5:30 or 45';

  @override
  String get nuovoTratto => 'New segment';

  @override
  String get modificaTratto => 'Edit the segment';

  @override
  String get esDefaticamento => 'E.g. Cool-down';

  @override
  String get metri => 'Meters';

  @override
  String get togliQuestoTratto => 'Remove this segment';

  @override
  String get scollegareIntervalsIcu => 'Disconnect intervals.icu?';

  @override
  String get attivitaTornanoQuelleHealth =>
      'Activities go back to the ones from Health Connect, with fewer details. The key is deleted from the phone.';

  @override
  String get attivitaCompleteGarminPolar =>
      'Complete activities from Garmin, Polar, Suunto, Coros, Wahoo, Zwift: real name, trainer, route, altitude, power.';

  @override
  String get sincronizzazioneCorso => 'Syncing…';

  @override
  String get collegato4 => 'Connected.';

  @override
  String collegatoUltimaSincronizzazioneAttivita(
    Object p0,
    Object p1,
    Object p2,
    Object p3,
  ) {
    return 'Connected · last sync $p0, $p1:$p2 · $p3 activities';
  }

  @override
  String get mandaPianoSeduteIntervals =>
      'Send plan and sessions to intervals.icu';

  @override
  String corsaBiciNuotoDei(Object p0) {
    return 'Running, cycling and swimming for the next $p0 days, step by step: they update by themselves when the plan changes. Sessions recorded with the app are sent by themselves as soon as they\'re finished, with the route if there is one.';
  }

  @override
  String get invioCorso => 'Sending…';

  @override
  String get nonAncoraMandato => 'Not sent yet.';

  @override
  String ultimoInvioSeduteCalendario(
    Object p0,
    Object p1,
    Object p2,
    Object p3,
  ) {
    return 'Last sent $p0, $p1:$p2 · $p3 sessions in the calendar';
  }

  @override
  String get inviaOra => 'Send now';

  @override
  String get averleSullOrologioGarmin => 'To get them on your Garmin watch';

  @override
  String get suIntervalsIcuImpostazioni =>
      'On intervals.icu: Settings → Garmin Connect → turn on \"Upload planned workouts\". Sessions go into the Garmin Connect calendar and from there to the watch. Heart rate: intervals.icu zones; swimming: pace per 100 m.';

  @override
  String get creaAccountGratuitoSu =>
      'Create a free account on intervals.icu (from the browser).';

  @override
  String get liImpostazioniCollegaGarmin =>
      'There, in Settings, connect Garmin Connect (or your watch): activities arrive by themselves.';

  @override
  String get sempreImpostazioniFondoDeveloper =>
      'Still in Settings, at the bottom, \"Developer settings\": create the API key and copy it.';

  @override
  String get incollalaQuiSottoTocca => 'Paste it below and tap Connect.';

  @override
  String get chiaveApiIntervalsIcu => 'intervals.icu API key';

  @override
  String get incollaDagliAppunti => 'Paste from clipboard';

  @override
  String get chiaveRestaCifrataSul =>
      'The key stays encrypted on the phone. It\'s used to read your activities and, only if you turn it on, to send the plan to your calendar.';

  @override
  String get collega2 => 'Connect';

  @override
  String get arrivo => 'Finish';

  @override
  String get percorsoCompletato => 'Route completed';

  @override
  String get cercoPosizione => 'Looking for your location';

  @override
  String get percorsoQuestaParteRaggiungilo =>
      'The route is this way: head to it';

  @override
  String get fuoriPercorsoTornaSulla => 'Off route: get back on the track';

  @override
  String get drittoFinoAllArrivo => 'Straight on to the finish';

  @override
  String percorso(Object p0) {
    return 'Route $p0 away';
  }

  @override
  String fuoriPercorso(Object p0) {
    return 'Off route ($p0)';
  }

  @override
  String arrivoTra(Object p0) {
    return 'Finish in $p0';
  }

  @override
  String get percorsoNonConcessoPuoi =>
      'Route not allowed. You can always allow it from Health Connect.';

  @override
  String get fileTroppoGrandeGpx =>
      'File too large: a workout GPX weighs a few MB at most.';

  @override
  String get giornoDiverso => 'Different day';

  @override
  String fileSessioneUsarloStesso(Object p0, Object p1) {
    return 'The file is from $p0, the session from $p1. Use it anyway?';
  }

  @override
  String get usalo => 'Use it';

  @override
  String percorsoAggiunto(Object p0) {
    return 'Route added: $p0';
  }

  @override
  String get questaSessioneHaPercorso => 'This session has a GPS route';

  @override
  String get healthConnectChiedeTuo =>
      'Health Connect asks for your permission to show it. To avoid granting it every time: Health Connect → Avidididadi → Exercise routes → Always allow.';

  @override
  String get consentiSempre => 'Always allow';

  @override
  String get aggiungiGpx => 'Add GPX';

  @override
  String get appHaRegistratoSessione => 'The app that recorded the session';

  @override
  String get nessunPercorsoGps => 'No GPS route';

  @override
  String nonHaCondivisoPuoi(Object p0) {
    return '$p0 didn\'t share it. You can add it yourself: on connect.garmin.com open the activity, gear → Export to GPX, then load the file here.';
  }

  @override
  String get ritmo => 'Pace';

  @override
  String get scriviQuantiMinutiDurata => 'Write how many minutes it lasted';

  @override
  String get vasca => 'In the pool';

  @override
  String get vasche => 'Lengths';

  @override
  String get lunghezzaVasca => 'Pool length';

  @override
  String get metriTotali => 'Total meters';

  @override
  String get tempoMedio => 'Average time';

  @override
  String get es155 => 'e.g. 1:55';

  @override
  String get stile => 'Stroke';

  @override
  String get modificaSessione => 'Edit the session';

  @override
  String get eliminaSessione => 'Delete the session';

  @override
  String get nomeDellAllenamento => 'Workout name';

  @override
  String get indoorRulliTacx => 'Indoor (trainer, Tacx)';

  @override
  String get indoorTapisRoulant => 'Indoor (treadmill)';

  @override
  String get nienteMappaNeGpx => 'No map or GPX';

  @override
  String inizio(Object p0, Object p1) {
    return 'Start $p0:$p1';
  }

  @override
  String get vieBlocchiGradi => 'Routes, problems and grades';

  @override
  String get eserciziSerieKg => 'Exercises, sets and kg';

  @override
  String get comeAndata => 'How it went';

  @override
  String get battitoMassimo => 'Max heart rate';

  @override
  String get fatica => 'Effort';

  @override
  String get su10 => 'out of 10';

  @override
  String get tuttoQuelloTiRicordi => 'Everything you remember';

  @override
  String get tornaAiDatiOriginali => 'Back to the original data';

  @override
  String get dataGara => 'Race date';

  @override
  String get scriviOreMinutiEs => 'Write hours:minutes, e.g. 1:45';

  @override
  String get scegliDataGara => 'Choose the race date.';

  @override
  String get tempoObiettivoFacoltativo => 'Target time (optional)';

  @override
  String get oreMinutiEs1 => 'hours:minutes, e.g. 1:45';

  @override
  String traSettimane(Object p0) {
    return 'In $p0 weeks';
  }

  @override
  String faseAttuale(Object p0, Object p1) {
    return 'Current phase: $p0. $p1';
  }

  @override
  String get fasiAvanzanoSoleVerso =>
      'Phases move on by themselves toward the race: base, build, peak and taper.';

  @override
  String get rimuoviObiettivo => 'Remove goal';

  @override
  String get controllaValoriFcMax =>
      'Check the values: max HR 120-230, resting HR 30-100, pace m:ss, FTP 50-600 W.';

  @override
  String get n15MinutiFacili3 =>
      '15 easy minutes and 3 strides, then 20 minutes at the hardest you can hold, then 10 very easy minutes. About 50 minutes.';

  @override
  String get telefonoNonMisuraWatt =>
      'The phone doesn\'t measure running watts: record the run with your watch too. Then open the charts of that run: there you\'ll find your FTP and the button to save it.';

  @override
  String testNelCalendarioPrende(Object p0) {
    return 'Test in the calendar: $p0. It replaces that day\'s run.';
  }

  @override
  String get scegliOggiOGiorno => 'Choose today or a later day.';

  @override
  String get mettiloNelCalendario => 'Put it in the calendar';

  @override
  String get zone => 'Zones';

  @override
  String get tueZoneFrequenzaCardiaca => 'Your heart rate zones';

  @override
  String calcolateRiservaCardiacaFc(Object p0, Object p1) {
    return 'Calculated with heart rate reserve (max HR $p0, resting $p1).';
  }

  @override
  String calcolateComePercentualeFc(Object p0) {
    return 'Calculated as a percentage of max HR ($p0). With resting HR they become more accurate.';
  }

  @override
  String get fcMassima => 'Max HR';

  @override
  String vuotoStimaDaiTuoi(Object p0) {
    return 'Empty = estimate from your data: $p0 bpm (the highest of the last year, or from age).';
  }

  @override
  String vuotoQuellaMisurataBpm(Object p0) {
    return 'Empty = the measured one: $p0 bpm.';
  }

  @override
  String get misuralaAppenaSveglioO =>
      'Measure it right after waking up, or leave it empty.';

  @override
  String get passoCriticoNuoto => 'Swimming critical pace';

  @override
  String get mSsEs2 => 'm:ss, e.g. 2:05';

  @override
  String get vuotoStimaDalleSessioni =>
      'Empty = estimate from pool sessions (not available yet).';

  @override
  String vuotoStimaDalleSessioni2(Object p0) {
    return 'Empty = estimate from pool sessions: $p0.';
  }

  @override
  String get tueZonePotenzaBici => 'Your power zones (cycling)';

  @override
  String get partonoDallFtpPotenza =>
      'They start from FTP, the power you can hold for about an hour. Bike sessions give you the watt range to hold.';

  @override
  String get ftp => 'FTP';

  @override
  String vuotoQuelloIntervalsIcu(Object p0) {
    return 'Empty = the one from intervals.icu: $p0 W.';
  }

  @override
  String get seNonSaiPedala =>
      'If you don\'t know it: pedal 20 minutes as hard as you can, FTP is about 95% of the average power.';

  @override
  String get tueZonePotenzaCorsa => 'Your power zones (running)';

  @override
  String get ftpBiciNonVale =>
      'Bike FTP doesn\'t apply to running: running has its own. It\'s used for the charts of runs recorded with a watch that measures watts.';

  @override
  String get ftpCorsa => 'Running FTP';

  @override
  String vuotoStimaEtaPeso(Object p0) {
    return 'Empty = estimate from age and weight: $p0 W. It\'s just a starting point.';
  }

  @override
  String get vuotoStimaEtaPeso2 =>
      'Empty = estimate from age and weight: enter your weight in Profile.';

  @override
  String get faiTestCalcolarla => 'Do the test to calculate it';

  @override
  String get duranteAllenamento => 'During the workout';

  @override
  String get avvisi => 'Alerts';

  @override
  String get voce => 'Voice';

  @override
  String get diceEsercizioIniziaKm =>
      'It says the exercise that\'s starting, the km and whether you\'re out of zone or off pace. It stays quiet during calls.';

  @override
  String get bip => 'Beep';

  @override
  String negliUltimiSecondiRecuperi(Object p0) {
    return 'In the last $p0 seconds of rests and timed exercises, and at every km (5 km on the bike). Uses the media volume.';
  }

  @override
  String get vibrazione => 'Vibration';

  @override
  String get insiemeAiBip => 'Together with the beeps.';

  @override
  String get pausaAutomatica => 'Auto pause';

  @override
  String get corsaBiciCamminataTempo =>
      'Running, cycling and walking: the time stops when you stop and restarts by itself. Never during rests.';

  @override
  String get spenta => 'Off';

  @override
  String get tempoNonSiFerma => 'Time never stops by itself.';

  @override
  String get soloQuandoSeiFermo => 'Only when you\'re stopped';

  @override
  String get alSemaforoOSosta =>
      'At a traffic light or a stop. If you go slowly, even uphill, time keeps running.';

  @override
  String sottoKmH(Object p0) {
    return 'Below $p0 km/h';
  }

  @override
  String get comeCerteAppAttento =>
      'Like some apps: careful, if you go slower than this the time stops.';

  @override
  String get camminataTranquilla45 =>
      'Easy walk 4-5 km/h, slow run 8-10, bike uphill even 6-8.';

  @override
  String get soloMovimento => 'Moving only';

  @override
  String get sosteNonContanoAnche =>
      'Stops don\'t count, even with auto pause off: it\'s the pace at which you moved.';

  @override
  String get soste => 'Including stops';

  @override
  String get distanzaDivisoTuttoTempo =>
      'Distance divided by the whole time, stops included.';

  @override
  String get allaFineRiepilogoMostra =>
      'At the end the summary shows both times anyway: moving and total.';

  @override
  String get corsaCamminataBiciAll =>
      'Outdoor running, walking and cycling: where to put the map that follows your position (and the route, if you\'re following one).';

  @override
  String get scorriLatoTimerDati =>
      'Swipe sideways: timer and data on one, the big map on the other.';

  @override
  String get mappaPiccolaSempreVista =>
      'A small map always in view, above the timer.';

  @override
  String get mappaOccupaTuttoTempo =>
      'The map fills the screen, with time and data on top.';

  @override
  String get fileTroppoGrandeGpx2 =>
      'File too large: a GPX weighs a few MB at most.';

  @override
  String aggiunto(Object p0, Object p1) {
    return 'Added: $p0 · $p1';
  }

  @override
  String mSalita2(Object p0) {
    return '$p0 m of climbing';
  }

  @override
  String get scegliPercorso => 'Choose the route';

  @override
  String get mieiPercorsi => 'My routes';

  @override
  String get nessunPercorso => 'No routes';

  @override
  String get aggiungiFileGpxGara =>
      'Add the GPX file of a race, a famous loop or a friend\'s route. While running, walking or cycling the app shows you where you are on the map and tells you by voice where to turn.';

  @override
  String get doveTrovoGpx => 'Where do I find a GPX?';

  @override
  String get sitoGaraSpessoC =>
      '• Race website: there\'s often \"Download GPX track\".\n• Strava, Komoot, Garmin Connect: open a route or an activity → Export GPX.\n• A friend: they can send you the GPX of their activity.\nThen here: Add GPX and choose the file.';

  @override
  String get ancheSenzaRete => 'Works offline';

  @override
  String get vediPercorso => 'See the route';

  @override
  String get nomePercorso => 'Route name';

  @override
  String get eliminarePercorso => 'Delete the route?';

  @override
  String sparisceDallaRaccoltaDalle(Object p0) {
    return '\"$p0\" disappears from the collection and from the sessions it was assigned to. Workouts already done stay.';
  }

  @override
  String get usaQuestoPercorso => 'Use this route';

  @override
  String get rinomina => 'Rename';

  @override
  String get filePercorsoMancante => 'Route file missing.';

  @override
  String get curve => 'Turns';

  @override
  String get altimetria => 'Elevation profile';

  @override
  String get giroAdAnelloSi => 'Loop: start and finish at the same point.';

  @override
  String get partenzaAlPallinoVerde =>
      'Start at the green dot, finish at the other end.';

  @override
  String get seguirloPrimaPartireCorsa =>
      'To follow it: before starting a run, walk or ride tap \"Follow a route\", or assign it beforehand to a planned session.';

  @override
  String mMinM(Object p0, Object p1) {
    return '$p0 m · min $p1 m';
  }

  @override
  String get percorsoSeguire => 'Route to follow';

  @override
  String get scegli => 'Choose';

  @override
  String get cambia => 'Change';

  @override
  String scaricoMappa(Object p0) {
    return 'Downloading the map… $p0%';
  }

  @override
  String get puoiUsareAppIntanto => 'You can use the app meanwhile.';

  @override
  String get mappaScaricata => 'Map downloaded';

  @override
  String get stradePercorsoSiVedono =>
      'Streets and route are visible even offline (not satellite).';

  @override
  String get mappaSenzaRete => 'Offline map';

  @override
  String scaricaZonaAttornoAl(Object p0) {
    return 'Download the area around the route ($p0), to see it even where the phone has no signal.';
  }

  @override
  String get scarica => 'Download';

  @override
  String ultimoAggiornamento(Object p0) {
    return 'Last updated: $p0';
  }

  @override
  String get breveTuoiDatiRestano =>
      'In short: your data stays on the phone. The app has no server, account or ads, and doesn\'t sell or share your data. It only leaves the phone in the cases described below, almost all chosen by you.';

  @override
  String get datiInserisciTu => 'Data you enter';

  @override
  String get nomeDataNascitaSesso =>
      'Name, date of birth, sex, height, weight and measurements, profile photo, goal and race, typical week, equipment, feedback after workouts (effort, completed, pain), reps and kg of strength sets, climbing routes, problems, grades and workouts, lengths, times and other session data written by hand, hand-written plans and sessions imported from CSV files. They\'re used to prepare the plan and show progress.';

  @override
  String get datiLettiHealthConnect =>
      'Data read from Health Connect (read-only)';

  @override
  String get tuoPermessoAppLegge =>
      'With your permission the app reads workout sessions from Health Connect (type, title, start and end) and, within the time of each session, heart rate, distance, calories, steps and speed. It also reads resting HR, heart rate variability (HRV) and sleep to assess recovery, and history older than 30 days if you allow it. This is the data written by Garmin Connect, Freeletics and the other apps connected to Health Connect. The app doesn\'t write, change or delete anything in Health Connect.';

  @override
  String get percorsiGpsDelleSessioni => 'GPS routes of sessions';

  @override
  String get seAppHaRegistrato =>
      'If the app that recorded a run or a ride also saved the route in Health Connect, Avidididadi reads it only with your permission: for the single session (Health Connect asks you) or for all of them, if you choose \"Always allow\" in the Health Connect settings. You can also add a route yourself by loading a GPX file (for example exported from Garmin Connect). A copy of the route stays in the app to show the map. The routes to follow that you add to \"My routes\" (GPX files of races, loops, friends) stay only on the phone and in the backup; they don\'t go to the assistant.';

  @override
  String get posizioneDuranteAllenamento => 'Location during the workout';

  @override
  String get soloCorsaCamminataBici =>
      'Only for running, walking and cycling (and for another activity if you choose to record the route), and only while workout mode is open, the app uses precise location (GPS and the Google Play location service on the phone) to record route, distance and pace. While recording it shows a persistent notification and keeps going even with the screen off; when you close the workout the GPS turns off. The app doesn\'t use location at any other time and doesn\'t collect it in the background. The route is saved only on the phone: it doesn\'t go to Health Connect, it doesn\'t go to the assistant and it isn\'t sent to anyone, unless you turn on sending to intervals.icu or save it to a GPX file. While you train, a copy of the session in progress (route included) stays on the phone so it can be resumed if the app closes; it\'s deleted when you finish.';

  @override
  String get sensoriBluetoothBattitoBici =>
      'Bluetooth sensors (heart rate and bike)';

  @override
  String get soloSeScegliTu =>
      'Only if you choose to, during workout mode or from the \"My sensors\" page in Profile, the app connects via Bluetooth to a chest strap, a watch that broadcasts heart rate or bike sensors (trainer, power, speed and cadence), to show them while you train. When that page is closed or the workout is over, it disconnects. At the end of the session it saves in the session the average and maximum heart rate, average power and cadence and, for the charts, one value per second of heart rate, power, cadence and speed: all on the phone. The Bluetooth name and address of the sensors (and the wheel circumference) stay on the phone to reconnect next time: you delete them with \"Forget\". The \"Nearby devices\" permission is only used to find the sensor, not to know where you are.';

  @override
  String get mappe => 'Maps';

  @override
  String get disegnareMappaAppScarica =>
      'To draw the map the app downloads the tiles of the area shown: from OpenFreeMap (tiles.openfreemap.org, data © OpenStreetMap) for the Pulse and Streets maps, and from Esri (server.arcgisonline.com) only if you choose the Satellite view. As with any website, those services receive the phone\'s IP address and which tiles are requested, so they can tell which area you\'re looking at. The route, times and other workout data are not sent: the line is drawn on the phone. For routes to follow, the app downloads in advance the tiles of the strip around the track, to see them offline: OpenFreeMap receives those tiles, and therefore the area of the route. They stay in the app\'s memory until you remove the map or the route.';

  @override
  String get intervalsIcuFacoltativo => 'intervals.icu (optional)';

  @override
  String get seColleghiIntervalsIcu =>
      'If you connect intervals.icu with your API key, the app downloads from there your running, cycling and swimming activities (name, times, distance, heart rate, speed, altitude, power, GPS route) and your bike and running FTP, for the power zones. intervals.icu receives them from your watch (Garmin, Polar, Suunto…) because you connected it, under its own privacy terms. The key stays encrypted on the phone. Only if you turn on \"Send plan and sessions to intervals.icu\" does the app write to your intervals.icu calendar the running, cycling and swimming sessions of the next 14 days (date, sport, name, duration, steps with heart rate, power or pace zones): no name, photo, measurements, feedback or strength. Turning it off removes the future sessions sent by the app. With this sending on, every session you record with the app (strength included) goes to your account by itself as soon as it\'s finished; off, only if you tap \"Send to intervals.icu\" on that session. What\'s sent: time, sport, name, duration, distance, average and maximum heart rate and, if there is one, the GPS route. In the same way \"Save GPX\" creates a file with the route where you choose. Downloaded activities stay on the phone and go into the backup; disconnecting removes them.';

  @override
  String get immaginiDegliEsercizi => 'Exercise images';

  @override
  String get fotoDegliEserciziVengono =>
      'Exercise photos are downloaded, when needed, from the public free-exercise-db collection on GitHub. GitHub receives the phone\'s IP address and which image is requested, nothing else.';

  @override
  String get assistenteFacoltativo2 => 'Assistant (optional)';

  @override
  String get soloSeAttiviTu =>
      'Only if you turn it on, the assistant sends a summary of your workouts (sessions of the last 4 weeks, feedback, recovery, heart rate zones and bike FTP, plan for the next 14 days) to the service you choose: Anthropic, OpenAI, Google or Ollama on your PC. Name, photo and GPS routes are never sent; age, sex and weight only if you allow it. Before turning it on you can see exactly what is sent. The API key stays encrypted on the phone. For online services their privacy terms and any costs of your subscription apply.';

  @override
  String get assistenteNellaTuaApp => 'Assistant in your app (optional)';

  @override
  String get seColleghiAppTuo =>
      'If you connect your assistant\'s app (Claude, ChatGPT, Gemini or others), Avidididadi prepares a message with the same summary described above and passes it to that app only when you tap Share or Copy. From then on the data is in the chat of the chosen service and its rules apply: with a regular subscription chats may be used to train the model, depending on your account settings. Replies you share or paste into the app are read only if they contain the code of your link, and changes to the plan are applied only after you confirm. Until you connect it, Avidididadi doesn\'t receive text from other apps; when you disconnect it, the code stops being valid.';

  @override
  String get widgetSullaSchermataHome => 'Home screen widget';

  @override
  String get seAggiungiWidgetSeduta =>
      'If you add the widget, today\'s session and the week are visible on the home screen, so also to anyone who sees the unlocked phone.';

  @override
  String get doveRestanoDati => 'Where the data stays';

  @override
  String get nellaCartellaPrivataDell =>
      'In the app\'s private folder on the phone, which other apps can\'t access. It doesn\'t go into Android\'s automatic backup to Google or the transfer to a new phone: to move it use the app\'s backup.';

  @override
  String get fileBackupCreiContiene =>
      'The backup file you create contains all the app data, including health data, photos and GPS routes (not the API key). You save it where you choose: keep it somewhere safe and don\'t share it. If you turn on automatic backup, the app writes the same file by itself in the folder you chose and keeps the last 5; other apps that read that folder can see it.';

  @override
  String get permessiTelefono => 'Phone permissions';

  @override
  String get healthConnectLetturaDei =>
      'Health Connect (reading the data listed above), precise location (only during running, walking and cycling), nearby devices (only for the heart rate sensor), physical activity (only for steps while running and walking), internet (maps, images, assistant), notifications (only the one for the workout in progress, with time and data, visible even on the lock screen). You can deny each of these permissions: the app keeps working without the part that needs it.';

  @override
  String get comeRevocareOCancellare => 'How to revoke or delete';

  @override
  String get healthConnectImpostazioniHealth =>
      'Health Connect: Health Connect settings → App permissions → Avidididadi, or from Profile with \"Review permissions\". Location, nearby devices and physical activity: Android settings → Apps → Avidididadi → Permissions. Heart rate sensor: \"Forget\" in the heart rate sheet, during the workout. Assistant: turn it off and delete the key on the Coach page. To delete everything: Android settings → Apps → Avidididadi → Storage → Clear data, or uninstall the app. The data in Health Connect stays there, because it belongs to the apps that wrote it.';

  @override
  String get modifiche => 'Changes';

  @override
  String get seQuestaInformativaCambia =>
      'If this policy changes, the app tells you when you open it and asks you to accept it again.';

  @override
  String get cosAvidididadi => 'What Avidididadi is';

  @override
  String get appPersonalePianificareSeguire =>
      'A personal app to plan and follow strength, running, swimming, cycling and mobility workouts, and to see history and progress. By using it you accept these terms and the privacy policy.';

  @override
  String get pianiCarichiZoneFrequenza =>
      'Plans, loads, heart rate zones, recovery assessment and the assistant\'s answers are automatic estimates for information only. They are not a diagnosis or medical advice and don\'t replace a doctor, physiotherapist or coach. Before starting a training program, especially if you have health problems, are pregnant or haven\'t trained in a while, ask a doctor. If you feel pain, dizziness, unusual shortness of breath or chest pain, stop and seek help.';

  @override
  String get allenatiSicurezza => 'Train safely';

  @override
  String get tiAlleniSottoTua =>
      'You train at your own risk: choose loads and paces that suit you, use equipment in good condition and follow the traffic rules. While running, walking or cycling don\'t look at the phone while moving in traffic.';

  @override
  String get precisioneDeiDati => 'Data accuracy';

  @override
  String get gpsDistanzeRitmoPassi =>
      'GPS, distances, pace, steps and data read from Health Connect may contain errors (for example between tall buildings or under trees). Calculations and charts depend on this data and how complete it is.';

  @override
  String get serviziTerzi => 'Third-party services';

  @override
  String get alcuneFunzioniUsanoServizi =>
      'Some features use other parties\' services: Health Connect and the apps that write to it (e.g. Garmin Connect), OpenFreeMap and OpenStreetMap for maps, GitHub for exercise images and, if you turn it on, the artificial intelligence service you choose. These services have their own terms and may change or be unavailable. The API key and the costs of the artificial intelligence service are your responsibility.';

  @override
  String get tuoiDati => 'Your data';

  @override
  String get datiRestanoSulTuo =>
      'The data stays on your phone and you\'re responsible for it: make regular backups and keep the file somewhere safe. If you uninstall the app without a backup the data is lost.';

  @override
  String get nessunaGaranzia => 'No warranty';

  @override
  String get appFornitaCosiCom =>
      'The app is provided as is, with no guarantee that it will work continuously or without errors. To the extent permitted by law, its developer is not liable for damage arising from use of the app, from incorrect data or from data loss.';

  @override
  String get questiTerminiPossonoEssere =>
      'These terms may be updated. If they change, the app tells you when you open it and asks you to accept them again before continuing.';

  @override
  String impossibileCaricareFoto(Object p0) {
    return 'Can\'t load the photo: $p0';
  }

  @override
  String get scegliDallaGalleria => 'Choose from gallery';

  @override
  String get scattaFoto => 'Take a photo';

  @override
  String get rimuoviFoto => 'Remove photo';

  @override
  String get siRegistraDataOggi =>
      'It\'s recorded with today\'s date. Leave empty to delete.';

  @override
  String anni(Object p0, Object p1) {
    return '$p0 ($p1 years)';
  }

  @override
  String get tuoProfilo => 'Your profile';

  @override
  String get inserisciTuoiDati => 'Enter your details';

  @override
  String get modificaTuoiDati => 'Edit your details';

  @override
  String get mioAllenamento => 'My training';

  @override
  String get mioObiettivo => 'My goal';

  @override
  String get nessunaGaraTiAlleni => 'No race: you train to stay fit';

  @override
  String get scegliSportAppScrive =>
      'Choose the sports: the app writes step-by-step workouts';

  @override
  String forza(Object p0) {
    return 'Strength: $p0';
  }

  @override
  String get mieSchede => 'My plans';

  @override
  String get schedePersonalTrainerO =>
      'Plans from your personal trainer or coach';

  @override
  String corso(Object p0) {
    return 'In progress: $p0';
  }

  @override
  String get comeSiFannoImmagini =>
      'How to do them, with images and muscles used';

  @override
  String get mieZone => 'My zones';

  @override
  String get quantoSpingereBattitiAl =>
      'How hard to push: beats per minute and watts on the bike';

  @override
  String get mioCorpo => 'My body';

  @override
  String get toccaMisuraInserirlaVedrai =>
      'Tap a measurement to enter it: you\'ll see how you change over time.';

  @override
  String ultimoAggiornamentoToccaMisura(Object p0) {
    return 'Last updated: $p0. Tap a measurement to update it.';
  }

  @override
  String get impostazioniAiuto => 'Settings and help';

  @override
  String get temaScuro => 'Dark theme';

  @override
  String get fondoGrafiteOppureBianco => 'Graphite or white background';

  @override
  String get versioneNeon => 'Neon version';

  @override
  String get rosaVerdeAcquaAzzurro => 'Pink, teal and blue instead of red';

  @override
  String get mieiSensori => 'My sensors';

  @override
  String get fasciaCardioRulloSensori =>
      'Chest strap, trainer and bike sensors';

  @override
  String get funzioniAvanzate => 'Advanced features';

  @override
  String get zoneWattSensoriBluetooth =>
      'Zones, watts, Bluetooth sensors, trainer and intervals.icu';

  @override
  String get voceBipPausaAutomatica =>
      'Voice, beeps, auto pause and average pace';

  @override
  String get tuoiAllenamentiCrealiFalli =>
      'Your workouts: create them, do them or add them to the plan';

  @override
  String get gpxSeguireMappaIndicazioni =>
      'GPX to follow with a map and voice directions';

  @override
  String get orologioAppBackupDei => 'Watch and apps, data backup';

  @override
  String get giroGuidatoDellApp => 'App tour';

  @override
  String get n10FunzioniPrincipaliAlla => 'The 10 main features, one at a time';

  @override
  String get zoneCaricoFartlekSpiegati =>
      'Zones, load, fartlek… explained simply';

  @override
  String get configurazioneGuidata => 'Guided setup';

  @override
  String get rifaiPianoRispondendoPoche =>
      'Redo the plan by answering a few questions';

  @override
  String get rifareConfigurazione => 'Redo the setup?';

  @override
  String get settimanaTipoPianoOggi =>
      'The typical week and the plan from today onward will be replaced. Workouts already done and measurements stay.';

  @override
  String get inserisciNumeroValido => 'Enter a valid number';

  @override
  String get diagrammaDellAllenamento => 'Workout diagram';

  @override
  String get wattPrevistiTenutiTutta =>
      'Planned and actual watts across the session';

  @override
  String get n1Mese => '1 month';

  @override
  String get n3Mesi => '3 months';

  @override
  String get n6Mesi => '6 months';

  @override
  String get n1Anno => '1 year';

  @override
  String get quiVedraiComeVanno =>
      'Here you\'ll see how your workouts are going. Connect your watch or training apps from Profile (Data and connections), or log the sessions you\'ve done.';

  @override
  String get quantoTiAlleni => 'How much you train';

  @override
  String get alMese => 'per month';

  @override
  String get settimana3 => 'per week';

  @override
  String fatica2(Object p0) {
    return 'Effort $p0';
  }

  @override
  String ore(Object p0) {
    return 'Hours $p0';
  }

  @override
  String get durataFaticaContaAnche =>
      'Duration by effort: it also counts how hard it was.';

  @override
  String get nessunAllenamentoQuestoPeriodo => 'No workouts in this period.';

  @override
  String get toccaColonnaDettagli => 'Tap a column for details.';

  @override
  String get tuoiSport => 'Your sports';

  @override
  String get toccaUnoSportVedere => 'Tap a sport to see all the details.';

  @override
  String get staiRallentando => 'You\'re slowing down';

  @override
  String get staiAndandoBene => 'You\'re doing well';

  @override
  String get staiAccelerando => 'You\'re speeding up';

  @override
  String get troppoTroppoFretta => 'Too much, too fast';

  @override
  String get tiAlleniMenoDelle =>
      'You\'re training less than in the past weeks. That\'s fine if it\'s on purpose (rest, commitments); otherwise get back to it gently.';

  @override
  String get aumentiPocoAllaVolta =>
      'You\'re increasing little by little, as you should: that way you improve without getting hurt.';

  @override
  String get staiFacendoParecchioPiu =>
      'You\'re doing quite a lot more than usual. Listen to how you feel and don\'t add anything else this week.';

  @override
  String get haiAumentatoMoltoPoco =>
      'You\'ve increased a lot in a short time: that\'s how injuries happen. Take a few lighter days.';

  @override
  String get buono => 'Good';

  @override
  String get basso => 'Low';

  @override
  String get tiStoConoscendo => 'Getting to know you';

  @override
  String get dopo3SettimaneAllenamenti =>
      'After 3 weeks of workouts I\'ll tell you whether you\'re increasing the right way.';

  @override
  String get comeCalcolo => 'How I calculate it';

  @override
  String rispettoAllaMediaDelle(Object p0) {
    return 'Compared with the average of the last 4 weeks: $p0 (good between 0.8 and 1.3).';
  }

  @override
  String ultimi7GiorniPunti(Object p0, Object p1) {
    return 'Last 7 days: $p0 points (minutes × effort). $p1';
  }

  @override
  String get settScorsa => 'last wk';

  @override
  String saltati(Object p0) {
    return 'Skipped: $p0';
  }

  @override
  String get comAndata2 => 'How it went';

  @override
  String get tuoiWattTuttaSeduta =>
      'Your watts across the session (average every 10 seconds).';

  @override
  String get barreColorateSonoProgramma =>
      'The colored bars are the plan: the watts to hold block by block. The line is the watts you held (average every 10 seconds); the dashed one is your FTP.';

  @override
  String get barreColorateSonoWatt =>
      'The colored bars are the average watts of each block. The line is the watts you held (average every 10 seconds); the dashed one is your FTP.';

  @override
  String get barraBloccoLargaQuanto =>
      'One bar per block, as wide as it lasted: tall and colored by the watts to hold; the dash is the average watts you held. The line is your FTP.';

  @override
  String get barraBloccoLargaQuanto2 =>
      'One bar per block: as wide as it lasted, tall and colored by the average watts. The line is your FTP.';

  @override
  String get allenamentoNuovo => 'New workout';

  @override
  String allenamentiNuovi(Object p0) {
    return '$p0 new workouts';
  }

  @override
  String min4(Object p0) {
    return ' · $p0 min';
  }

  @override
  String prendePostoSedutaQuel(Object p0) {
    return 'It replaces that day\'s $p0 session.';
  }

  @override
  String get unoGiornoPassatoNon => 'One is on a past day: it isn\'t added.';

  @override
  String sonoGiorniPassatiNon(Object p0) {
    return '$p0 are on past days: they aren\'t added.';
  }

  @override
  String get messoNelCalendario => 'Added to the calendar.';

  @override
  String get nienteMettereDateSono => 'Nothing to add: the dates have passed.';

  @override
  String get allenamentoMessoNelCalendario => 'Workout added to the calendar.';

  @override
  String allenamentiMessiNelCalendario(Object p0) {
    return '$p0 workouts added to the calendar.';
  }

  @override
  String pianoNuovo(Object p0) {
    return 'New plan from $p0';
  }

  @override
  String get applicatoTroviNelCalendario =>
      'Applied: you\'ll find it in the calendar.';

  @override
  String seduteSettimaneSostituisceCalendario(Object p0, Object p1) {
    return '$p0 sessions in $p1 weeks. It replaces the calendar from that day onward.';
  }

  @override
  String settimana5(Object p0, Object p1, Object p2) {
    return 'Week of $p0/$p1: $p2';
  }

  @override
  String get altreSettimane => '…and the other weeks.';

  @override
  String get nonApplicabile => 'Can\'t be applied';

  @override
  String get scriviAlCoachCorreggerlo => 'Ask the coach to fix it.';

  @override
  String copiatoIncollaloCorreggere(Object p0) {
    return 'Copied: paste it into $p0 to fix it.';
  }

  @override
  String copiaProblemi(Object p0) {
    return 'Copy the problems for $p0';
  }

  @override
  String get pianoNonPiuApplicabile =>
      'The plan can\'t be applied anymore: try again.';

  @override
  String pianoApplicatoSeduteNel(Object p0) {
    return 'Plan applied: $p0 sessions in the calendar.';
  }

  @override
  String get applicaPiano => 'Apply the plan';

  @override
  String get allenamentoArrampicata => 'Climbing workout';

  @override
  String allenamentiArrampicata2(Object p0) {
    return '$p0 climbing workouts';
  }

  @override
  String get nellaRaccolta => 'in the collection';

  @override
  String nelCalendario2(Object p0) {
    return 'in the calendar $p0';
  }

  @override
  String get datePassateNonVanno =>
      'Past dates don\'t go into the calendar, but the workout is saved anyway.';

  @override
  String get salvato => 'Saved.';

  @override
  String get salvatoNegliAllenamentiArrampicata =>
      'Saved in climbing workouts.';

  @override
  String salvatiNegliAllenamentiArrampicata(Object p0) {
    return '$p0 saved in climbing workouts.';
  }

  @override
  String get unoNelCalendario => 'One is in the calendar.';

  @override
  String sonoNelCalendario(Object p0) {
    return '$p0 are in the calendar.';
  }

  @override
  String get salvaMettiNelCalendario => 'Save and add to the calendar';

  @override
  String get eserciziSerieRipetizioniKg => 'Exercises, sets, reps and kg';

  @override
  String get passiTempoODistanza =>
      'Steps by time or distance, with zone or pace';

  @override
  String get passiTempoODistanza2 => 'Steps by time or distance, with zone';

  @override
  String get vaschePasso100M => 'Lengths, pace per 100 m and rests';

  @override
  String scheda3(Object p0) {
    return '$p0 plan';
  }

  @override
  String get scriviSchedaTuoPersonal =>
      'Write the plan from your personal trainer or coach: strength, running, cycling or swimming. On the days you choose it replaces the sessions prepared by the app, which won\'t change it by itself.';

  @override
  String get nuovaScheda => 'New plan';

  @override
  String get corso2 => 'In progress';

  @override
  String get finite => 'Finished';

  @override
  String get archiviata => 'Archived';

  @override
  String dalSenzaScadenza(Object p0) {
    return 'From $p0, no end date';
  }

  @override
  String dalAl(Object p0, Object p1) {
    return 'From $p0 to $p1';
  }

  @override
  String get giorno2 => 'Day';

  @override
  String get aggiungiAlmenoEsercizio => 'Add at least one exercise.';

  @override
  String get aggiungiAlmenoPasso => 'Add at least one step.';

  @override
  String get settimanaTipoAggiornata => 'Typical week updated.';

  @override
  String nellaSettimanaTipo(Object p0) {
    return '$p0 in the typical week';
  }

  @override
  String aggiungo(Object p0) {
    return 'Adding: $p0.';
  }

  @override
  String giornoRiposoNonTolgo(Object p0) {
    return '$p0 is a rest day: I won\'t remove anything.';
  }

  @override
  String get fargliPostoTolgoQuesto =>
      'To make room I\'ll remove from this day:';

  @override
  String get oppurePuoiTenerleFare => 'Or you can keep them and do both.';

  @override
  String get tieniEntrambe => 'Keep both';

  @override
  String get aggiungi => 'Add';

  @override
  String get sostituisci => 'Replace';

  @override
  String get eliminareScheda => 'Delete the plan?';

  @override
  String get seduteGiaFatteRestano =>
      'Sessions already done stay. From today the ones prepared by the app come back.';

  @override
  String get uscireSenzaSalvare => 'Exit without saving?';

  @override
  String get resta => 'Stay';

  @override
  String get scheda4 => 'Plan';

  @override
  String get nomeScheda => 'Plan name';

  @override
  String get esSchedaNovembre => 'E.g. November plan';

  @override
  String get fincheNonCambio => 'Until I change it';

  @override
  String get inizio2 => 'Start';

  @override
  String get giorni => 'Days';

  @override
  String get ogniGiornoSchedaBusto =>
      'Each day of the plan (Upper body, Legs…) goes on the days of the week you choose. The ones with strength in the typical week count.';

  @override
  String ogniSedutaSchedaRipetute(Object p0) {
    return 'Each session of the plan (Intervals, Long run…) goes on the days of the week you choose. The ones with $p0 in the typical week count.';
  }

  @override
  String nellaSettimanaTipoNon(Object p0, Object p1) {
    return '$p0: there\'s no $p1 in the typical week.';
  }

  @override
  String get modificaSettimana => 'Edit week';

  @override
  String get aggiungiGiorno => 'Add a day';

  @override
  String get aggiungiSeduta => 'Add a session';

  @override
  String get salvaScheda => 'Save the plan';

  @override
  String get nomeGiorno => 'Day name';

  @override
  String get esBusto => 'E.g. Upper body';

  @override
  String get togliQuestoGiorno => 'Remove this day';

  @override
  String get nessunEsercizio => 'No exercises.';

  @override
  String get nessunPasso => 'No steps.';

  @override
  String get spostaGiu => 'Move down';

  @override
  String get aggiungiEsercizio2 => 'Add exercise';

  @override
  String get aggiungiPasso => 'Add a step';

  @override
  String get serieMeno => 'One set fewer';

  @override
  String get seriePiu => 'One more set';

  @override
  String get es10810 => 'E.g. 10, 8-10, or 30 s for timed exercises';

  @override
  String get recuperoSecondi => 'Rest (seconds)';

  @override
  String get pesoTutteSerie20 =>
      'One weight for all sets (20), or one per set (20 22.5 25). Empty for bodyweight.';

  @override
  String get notePersonalTrainer => 'Personal trainer\'s notes';

  @override
  String get esScendi3Secondi => 'E.g. lower in 3 seconds';

  @override
  String get esercizioNonCatalogo => 'Exercise not in the catalog';

  @override
  String get scegliEsercizio => 'Choose an exercise';

  @override
  String get cercaEsLatPanca => 'Search (e.g. lat, bench, squat)';

  @override
  String get nonCScriviloMano => 'Not there? Write it by hand';

  @override
  String get principale => 'Main set';

  @override
  String get defaticamento => 'Cool-down';

  @override
  String passo2(Object p0) {
    return '$p0 step';
  }

  @override
  String get cosaFare => 'What to do';

  @override
  String get esStileLiberoGambe => 'E.g. Freestyle, kick with board';

  @override
  String get esCorsaFacileRipetute => 'E.g. Easy run, intervals, hills';

  @override
  String get quanteVolte => 'How many times';

  @override
  String get meno3 => 'One fewer';

  @override
  String get piu3 => 'One more';

  @override
  String get tempo2 => 'By time';

  @override
  String get distanza2 => 'By distance';

  @override
  String get minuti2 => 'Minutes';

  @override
  String get es400 => 'E.g. 400';

  @override
  String get es10Oppure1 => 'E.g. 10, or 1.5';

  @override
  String get obiettivoPrincipale => 'Main target';

  @override
  String get libera => 'Free';

  @override
  String get watt => 'Watts';

  @override
  String get es150100 => 'E.g. 1:50/100 m';

  @override
  String get es500Km => 'E.g. 5:00/km';

  @override
  String get es200Oppure190 => 'E.g. 200, or 190-210, or 88-94%';

  @override
  String get obiettivoSecondarioFacoltativo => 'Secondary target (optional)';

  @override
  String get es8590Rpm => 'E.g. 85-90 rpm';

  @override
  String get es170180Ppm => 'E.g. 170-180 spm';

  @override
  String get es40BracciateAl => 'E.g. 40 strokes per minute';

  @override
  String get pausaBordoVascaDopo => 'Rest at the pool wall after each rep';

  @override
  String get traRipetizioneAltraVuoto =>
      'Between one rep and the next; empty if there\'s none';

  @override
  String get scriviMetri => 'Write the meters.';

  @override
  String get scriviMinuti => 'Write the minutes.';

  @override
  String get scriviWattEsempio200 =>
      'Write the watts: for example 200, 190-210 or 88-94%.';

  @override
  String get sensoreCollegatoHoAcceso =>
      'Sensor connected: I turned on the advanced features.';

  @override
  String ricordato(Object p0) {
    return 'Remembered: $p0';
  }

  @override
  String get collegaQuiSensoriBluetooth =>
      'Connect your Bluetooth sensors here: you choose them only once, then they reconnect by themselves at every workout.';

  @override
  String get fasciaCardioOOrologio2 =>
      'Chest strap or watch that broadcasts heart rate';

  @override
  String get rulloSmartPotenzaVelocita =>
      'Smart trainer, power, speed and cadence';

  @override
  String get bluetoothSiUsaSolo =>
      'Bluetooth is used only while this page or the workout is open.';

  @override
  String get togliEsercizio => 'Remove the exercise';

  @override
  String get ripetizioniKg => 'Reps and kg';

  @override
  String get secondi => 'Seconds';

  @override
  String get togliSerie => 'Remove the set';

  @override
  String get eserciziSerie => 'Exercises and sets';

  @override
  String forza2(Object p0) {
    return 'Strength · $p0';
  }

  @override
  String get scriviCosaHaiFatto =>
      'Write what you did: reps and kg for each set (empty kg = bodyweight), or the time for planks and holds. They stay in the exercise history.';

  @override
  String get distanzaTotale => 'total distance';

  @override
  String get passoMedioMinKm => 'average pace (min/km)';

  @override
  String get corsaPiuLunga => 'longest run';

  @override
  String get passoMigliore3Km => 'best pace (≥ 3 km)';

  @override
  String get fcMedia => 'average HR';

  @override
  String get kmSettimana => 'Km per week';

  @override
  String get passoUscitaMinKm => 'Pace per run (min/km)';

  @override
  String get distanzaUscitaKm => 'Distance per run (km)';

  @override
  String get efficienzaAerobicaMetriBattito =>
      'Aerobic efficiency (meters per heartbeat)';

  @override
  String get fcMediaUscitaBpm => 'Average HR per run (bpm)';

  @override
  String get passoMedioMin100 => 'average pace (min/100 m)';

  @override
  String get sessionePiuLunga => 'longest session';

  @override
  String get passoMigliore300M => 'best pace (≥ 300 m)';

  @override
  String get metriSettimana => 'Meters per week';

  @override
  String get passoSessioneMin100 => 'Pace per session (min/100 m)';

  @override
  String get metriSessione => 'Meters per session';

  @override
  String get fcMediaSessioneBpm => 'Average HR per session (bpm)';

  @override
  String get velocitaMediaKmH => 'average speed (km/h)';

  @override
  String get uscitaPiuLunga => 'longest ride';

  @override
  String get velocitaMassimaMedia => 'best average speed';

  @override
  String get velocitaMediaUscitaKm => 'Average speed per ride (km/h)';

  @override
  String get durataMedia => 'average duration';

  @override
  String get sessioniSettimana => 'sessions per week';

  @override
  String get sessioniSettimana2 => 'Sessions per week';

  @override
  String get minutiSettimana => 'Minutes per week';

  @override
  String get durataSessioneMin => 'Duration per session (min)';

  @override
  String get vieBlocchiChiusi => 'routes and problems sent';

  @override
  String get metriSaliti => 'meters climbed';

  @override
  String get viaPiuDifficile => 'hardest route';

  @override
  String get bloccoPiuDifficile => 'hardest problem';

  @override
  String get vieBlocchiChiusiSettimana => 'Routes and problems sent per week';

  @override
  String get gradoPiuDifficileVie => 'Hardest grade: routes';

  @override
  String get gradoPiuDifficileBlocchi => 'Hardest grade: problems';

  @override
  String get tipiSessione => 'Session types';

  @override
  String fcBpm(Object p0) {
    return 'HR $p0 bpm';
  }

  @override
  String settimanaDal3(Object p0, Object p1, Object p2, Object p3) {
    return '$p0 $p1\nWeek from $p2$p3';
  }

  @override
  String get storicoPesoMisure => 'Weight and measurements history';

  @override
  String get storicoMisure => 'Measurements history';

  @override
  String nessunValoreAncoraInserito(Object p0) {
    return 'No $p0 value entered yet.';
  }

  @override
  String get almenoDueValoriComparira =>
      'With at least two values the chart will appear.';

  @override
  String dal(Object p0) {
    return 'From $p0';
  }

  @override
  String invariato(Object p0) {
    return '$p0: unchanged';
  }

  @override
  String get valoriInseriti => 'Values entered';

  @override
  String get barraBasso => 'The bottom bar';

  @override
  String get quattroSezioniOggiProgressi =>
      'Four sections: Today, Progress, Coach and Profile. You can also swipe sideways to move from one to another.';

  @override
  String get sedutaGiorno => 'Today\'s session';

  @override
  String get quiTroviCosaFare =>
      'Here you\'ll find what to do today. Tap the session to see the details and ▶ for the step-by-step guided workout, with timer, beeps and GPS.';

  @override
  String get energia2 => 'Energy';

  @override
  String get comTuoRecuperoOggi =>
      'How well you\'ve recovered today, from sleep, resting heart rate and HRV. Tap it for details: if it\'s low, a light session is better.';

  @override
  String get compariraAltoDestraQuando =>
      'It will appear at the top right when your watch sends sleep and resting heart rate (Profile → Data and connections).';

  @override
  String get cerchioGiornoPienoSe =>
      'One circle per day: filled if done, outlined if still to do. Tap a day to see it above; swipe sideways on the circles for the previous or next week.';

  @override
  String get settimanaTipo => 'The typical week';

  @override
  String get qualiGiorniTiAlleni2 =>
      'Which days you train, which sport and for how long. The whole calendar comes from here: change it when your commitments change.';

  @override
  String get dopoOgniAllenamentoDai =>
      'After each workout rate the effort: the following sessions adapt, easier or harder.';

  @override
  String get quandoAllenamentoFattoNon =>
      'When a workout you\'ve done doesn\'t have a rating yet, \"How did it go?\" appears here in Today. You can also give it by tapping the session you did.';

  @override
  String get caricoAllenamentoGraficiResoconti =>
      'Training load, charts and reports for each sport: tap a sport for details.';

  @override
  String get assistenteChiedigliConsigliSul =>
      'The assistant: ask it for advice on the plan or on how you feel. You connect it from the settings at the top (on your PC or with your app).';

  @override
  String get seduteSchede => 'Sessions and plans';

  @override
  String get preparaSeduteAppScrive =>
      '\"Prepare the sessions\": the app writes the workouts for you. \"My plans\": write the ones from your personal trainer or coach.';

  @override
  String get collegaOrologioHealthConnect =>
      'Connect your watch (Health Connect or intervals.icu) and back up your data. You can always find the tour again down here, in \"App tour\".';

  @override
  String get toccaAvantiContinuare => 'Tap Next to continue.';

  @override
  String get fine => 'Finish';

  @override
  String get vuoiGiroGuidatoDell =>
      'Would you like a tour of the app? Ten steps, one minute.';

  @override
  String get noGrazie => 'No, thanks';

  @override
  String get si => 'Yes';

  @override
  String get ultimoBlocco => 'Last block';

  @override
  String poi2(Object p0) {
    return 'Next: $p0';
  }

  @override
  String get recupero2 => 'of rest';

  @override
  String get fineBlocco => 'at the end of the block';

  @override
  String get collegaRulloOMisuratore =>
      'Connect the trainer or the power meter: you\'ll see power, cadence and speed.';

  @override
  String mediaWMassimoW(Object p0, Object p1) {
    return 'Average $p0 W · Max $p1 W';
  }

  @override
  String blocco(Object p0, Object p1) {
    return 'Block $p0 of $p1';
  }

  @override
  String get siParte2 => 'Starting';

  @override
  String fineTra(Object p0) {
    return 'Ends in $p0';
  }

  @override
  String get rulloErg => 'Trainer in ERG';

  @override
  String get rulloLibero => 'Free trainer';

  @override
  String get senzaObiettivo2 => 'no target';

  @override
  String tieneW(Object p0) {
    return 'holds $p0 W';
  }

  @override
  String get wattLiDecidiTu => 'you decide the watts';

  @override
  String get n5Meno => '5% less';

  @override
  String get n5Piu => '5% more';

  @override
  String get riportareSettimanaNelCalendario =>
      'Bring the week back into the calendar?';

  @override
  String get giorniOggiPoiDiventano =>
      'The days from today onward become the same as the typical week: changes made by hand on those days are replaced. Days already done stay.';

  @override
  String get riporta => 'Bring back';

  @override
  String get settimanaSalvataCalendarioVuoto =>
      'Week saved. The calendar is empty: extend it from Today.';

  @override
  String get settimanaSalvata => 'Week saved.';

  @override
  String calendarioAggiornatoOggiAl(Object p0, Object p1, Object p2) {
    return 'Calendar updated: $p0 $p1 from today to $p2.';
  }

  @override
  String get settimanaTipo2 => 'Typical week';

  @override
  String get scegliCosaFaiQuale =>
      'Choose what you do and on which day. Changes apply to the calendar right away, from today onward; days already done don\'t change.';

  @override
  String get portaTuttaSettimanaNel => 'Bring the whole week into the calendar';

  @override
  String get rifaGiorniOggiPoi =>
      'Redoes the days from today onward to match the typical week. Useful if the calendar no longer matches.';

  @override
  String get aggiungiSessione => 'Add session';

  @override
  String get nessunaSessione => 'No sessions';

  @override
  String get sport => 'Sport';

  @override
  String get fascia => 'Time of day';

  @override
  String get tipoSessioneFacoltativo => 'Session type (optional)';

  @override
  String get durataMinuti => 'Duration (minutes)';

  @override
  String get haiFattoAllenamentoDiverso =>
      'You did a different workout from the planned one: the feedback applies to what you actually did.';

  @override
  String get tuoFeedbackRegolaProssime =>
      'Your feedback adjusts the next sessions.';

  @override
  String get serveCalcolareCaricoAllenamento =>
      'It\'s used to calculate the training load.';

  @override
  String get completata => 'Completed';

  @override
  String get nonCompletata => 'Not completed';

  @override
  String get doloreSegnalato => 'pain reported';

  @override
  String get rispondi => 'Answer';

  @override
  String get hoGiaFattaScrivi => 'I\'ve already done it: enter the data';

  @override
  String get tiGuidoEsercizioEsercizio =>
      'I\'ll guide you exercise by exercise: tap \"Done\" when you finish, I\'ll count the rests and timed parts.';

  @override
  String allenamentoPrevisto(Object p0) {
    return 'Planned workout: $p0';
  }

  @override
  String durataTotaleMin(Object p0) {
    return 'Total duration: $p0 min';
  }

  @override
  String comeTiDeviSentire(Object p0) {
    return 'How you should feel: $p0';
  }

  @override
  String get iniziaAllenamento => 'Start workout';

  @override
  String muscoliSessioneToccaEsercizio(Object p0) {
    return 'Muscles in the session: $p0. Tap an exercise to see its own, the arrow for how to do it.';
  }

  @override
  String cos(Object p0) {
    return 'What it is: $p0';
  }

  @override
  String get sedutaArrampicata => 'Climbing session';

  @override
  String get scegliUnoDeiTuoi =>
      'Choose one of your workouts or ask the assistant. You can also start and log routes and grades at the end.';

  @override
  String get iniziaSeduta => 'Start the session';

  @override
  String get scegliAllenamento => 'Choose a workout';

  @override
  String get questaSedutaNonHa => 'This session has no exercises yet';

  @override
  String get sedutaLibera => 'Free session';

  @override
  String get faiPreparareAllApp =>
      'Let the app prepare strength: it chooses the exercises that suit you and your equipment. It takes a minute.';

  @override
  String faiPreparareAllApp2(Object p0) {
    return 'Let the app prepare the $p0 sessions: each with its own step-by-step directions.';
  }

  @override
  String get tempoHai => 'the time you have';

  @override
  String muovitiRitmoFacileDevi(Object p0) {
    return 'Move for $p0 at an easy pace: you should be able to talk.';
  }

  @override
  String preparaSedute2(Object p0) {
    return 'Prepare the $p0 sessions';
  }

  @override
  String get invioIntervalsIcu => 'Sending to intervals.icu…';

  @override
  String get questaSessioneAppNon =>
      'The app has no GPS route for this session.';

  @override
  String get salvaPercorso => 'Save the route';

  @override
  String get gpxSalvatoPuoiCaricarlo =>
      'GPX saved: you can upload it to Strava or Garmin Connect.';

  @override
  String gpxNonSalvato(Object p0) {
    return 'GPX not saved: $p0';
  }

  @override
  String get eliminareSessione => 'Delete the session?';

  @override
  String get nonTorneraSincronizzazioneNell =>
      ' It won\'t come back with the sync; in the watch app it stays as it is.';

  @override
  String sparisceDalCalendarioDai(Object p0) {
    return 'It disappears from the calendar, Progress and load, together with its \"How did it go?\".$p0';
  }

  @override
  String get sessioneEliminata => 'Session deleted';

  @override
  String get orario => 'Time';

  @override
  String m(Object p0, Object p1) {
    return '$p0 of $p1 m';
  }

  @override
  String get ritmoMedio => 'Average pace';

  @override
  String get calorieAttiveStima => 'Active calories (estimate)';

  @override
  String get calorieTotaliStima => 'Total calories (estimate)';

  @override
  String get potenzaMedia => 'Average power';

  @override
  String get cadenzaMedia => 'Average cadence';

  @override
  String get faticaRpe => 'Effort (RPE)';

  @override
  String fonteCorrettaMano(Object p0) {
    return 'Source: $p0 · corrected by hand';
  }

  @override
  String fonte(Object p0) {
    return 'Source: $p0';
  }

  @override
  String get sulleVie => 'on routes';

  @override
  String get nelBoulder => 'in bouldering';

  @override
  String record2(Object p0, Object p1, Object p2, Object p3, Object p4) {
    return '$p0 record: $p1 ($p2 $p3 $p4)';
  }

  @override
  String get grafici2 => 'Charts';

  @override
  String get inviaIntervalsIcu => 'Send to intervals.icu';

  @override
  String get salvaGpx => 'Save GPX';

  @override
  String get suIntervalsIcu => 'On intervals.icu';

  @override
  String get parteSolaIntervalsIcu =>
      'It goes to intervals.icu by itself as soon as there\'s a connection';

  @override
  String get previstoFatto => 'Planned and done';

  @override
  String fasceColorateSonoIntensita(Object p0) {
    return 'The colored bands are the intensity to hold block by block, the line is what you held: inside the band you were on target, above you went harder, below easier.$p0';
  }

  @override
  String get doveObiettivoEraZona =>
      ' Where the target was a zone we look at heart rate, where it was a pace we look at pace.';

  @override
  String get siGuardaPasso => ' We look at pace.';

  @override
  String get siGuardaBattito => ' We look at heart rate.';

  @override
  String tenere(Object p0) {
    return 'Target $p0';
  }

  @override
  String get fuoriProgramma => 'Off plan';

  @override
  String get intervalliCorrettiMano => 'Intervals (corrected by hand)';

  @override
  String get sensoreBici => 'Bike sensor';

  @override
  String get altitudinePendenza => 'Altitude and gradient';

  @override
  String get altitudinePendenzaPotenza => 'Altitude, gradient and power';

  @override
  String nonCiSonoAverle(Object p0) {
    return '$p0 aren\'t available: to get them connect intervals.icu (Profile → Data and connections).';
  }

  @override
  String chilometriAllOra(Object p0) {
    return '$p0 kilometers per hour';
  }

  @override
  String minutiAlChilometro(Object p0) {
    return '$p0 minutes per kilometer';
  }

  @override
  String alChilometro(Object p0, Object p1) {
    return '$p0 and $p1 per kilometer';
  }

  @override
  String chilometro(Object p0, Object p1) {
    return 'Kilometer $p0. $p1.';
  }

  @override
  String chilometroUltimi(Object p0, Object p1, Object p2, Object p3) {
    return 'Kilometer $p0. Last $p1 in $p2, $p3.';
  }

  @override
  String get piu4 => ' more';

  @override
  String daA(Object p0, Object p1) {
    return 'from $p0 to $p1';
  }

  @override
  String get su102 => ' out of 10';

  @override
  String get giriAlMinuto => 'revolutions per minute';

  @override
  String get recupero3 => 'Rest.';

  @override
  String recupero4(Object p0) {
    return 'Rest, $p0.';
  }

  @override
  String ora(Object p0) {
    return 'Now: $p0';
  }

  @override
  String zonaRallenta(Object p0) {
    return 'Zone $p0, slow down.';
  }

  @override
  String zonaPuoiSpingerePo(Object p0) {
    return 'Zone $p0, you can push a bit harder.';
  }

  @override
  String rallentaPo(Object p0, Object p1) {
    return '$p0 $p1, slow down a bit.';
  }

  @override
  String acceleraPo(Object p0, Object p1) {
    return '$p0 $p1, speed up a bit.';
  }

  @override
  String fatto2(Object p0) {
    return 'Done: $p0';
  }

  @override
  String get ancheRiposoAllenamento => 'Rest is training too';

  @override
  String get alternaRecupero6Volte => 'Alternate with the recovery, 6 times';

  @override
  String get recuperoCorricchiando => 'Recovery jog';

  @override
  String get corsaLentaContinua => 'Continuous easy run';

  @override
  String get restaZona2Tutta => 'Stay in zone 2 the whole time';

  @override
  String get piscinaBase1150M => 'Basic pool (1150 m, 25 m pool)';

  @override
  String get stileScelta => 'Stroke of your choice';

  @override
  String get stileLiberoGambeTavoletta => 'Freestyle, kick with board';

  @override
  String get tavolettaFront => 'Front kickboard';

  @override
  String get dorsoGambeTavoletta => 'Backstroke, kick with board';

  @override
  String get tavolettaDorso => 'Back kickboard';

  @override
  String get stileLiberoBracciaPull => 'Freestyle, arms with pull buoy';

  @override
  String get n25MSoloBraccio =>
      '25 m right arm only, 25 m left arm only, 50 m alternating';

  @override
  String get dorsoDoppioGambeRana => 'Double-arm backstroke, breaststroke kick';

  @override
  String get parolaTolta => 'removed';

  @override
  String get parolaTolte => 'removed';

  @override
  String get parolaSessione => 'session';

  @override
  String get parolaSessioni => 'sessions';

  @override
  String get parolaRulli => 'trainer';

  @override
  String get parolaTapisRoulant => 'treadmill';

  @override
  String get parolaNessuno => 'none';

  @override
  String get parolaGennaio => 'January';

  @override
  String get parolaFebbraio => 'February';

  @override
  String get parolaMarzo => 'March';

  @override
  String get parolaAprile => 'April';

  @override
  String get parolaMaggio => 'May';

  @override
  String get parolaGiugno => 'June';

  @override
  String get parolaLuglio => 'July';

  @override
  String get parolaAgosto => 'August';

  @override
  String get parolaSettembre => 'September';

  @override
  String get parolaOttobre => 'October';

  @override
  String get parolaNovembre => 'November';

  @override
  String get parolaDicembre => 'December';

  @override
  String get parolaChilometro => 'kilometer';

  @override
  String get parolaChilometri => 'kilometers';

  @override
  String get parolaOre => 'hours';

  @override
  String get parolaMinuti => 'minutes';

  @override
  String get parolaFatto => 'done';

  @override
  String get parolaOggi => 'today';

  @override
  String get parolaDomani => 'tomorrow';

  @override
  String get parolaIeri => 'yesterday';

  @override
  String get parolaMese => 'month';

  @override
  String get parolaMesi => 'months';

  @override
  String get parolaSedute => 'sessions';

  @override
  String get parolaVolta => 'time';

  @override
  String get parolaVolte => 'times';

  @override
  String get parolaSeduta => 'session';

  @override
  String get parolaMancano => 'remaining';

  @override
  String get parolaLeggera => 'light';

  @override
  String get parolaModerata => 'moderate';

  @override
  String get parolaImpegnativa => 'hard';

  @override
  String get parolaAllenamento => 'workout';

  @override
  String get parolaAllenamenti => 'workouts';

  @override
  String get parolaPercorsi => 'covered';

  @override
  String get parolaUscite => 'rides';

  @override
  String get parolaPassati => 'elapsed';

  @override
  String get parolaGiorno => 'day';

  @override
  String get parolaGiorni => 'days';

  @override
  String get parolaSecondo => 'second';

  @override
  String get parolaSecondi => 'seconds';

  @override
  String get parolaMinuto => 'minute';

  @override
  String get parolaOra => 'hour';

  @override
  String get parolaMetro => 'meter';

  @override
  String get parolaMetri => 'meters';

  @override
  String get glossarioRecupero => 'Recovery';

  @override
  String get glossarioMobilita => 'Mobility';

  @override
  String get widgetOggi => 'TODAY';

  @override
  String get widgetApri => 'Open the app to see the plan';

  @override
  String get widgetNessuno => 'No workouts this week';

  @override
  String widgetFatti(Object fatti, Object totale) {
    return '$fatti of $totale done this week';
  }

  @override
  String get widgetLettere => 'M,T,W,T,F,S,S';

  @override
  String get notificaCanale => 'Workout in progress';

  @override
  String get notificaAllenamento => 'Workout';

  @override
  String get lingua => 'Language';

  @override
  String get linguaTitolo => 'Choose your language';

  @override
  String get linguaSpiega =>
      'You can change it anytime from Profile. The data you\'ve already entered stays as it is.';

  @override
  String get linguaSotto => 'Italian, English or Greek';

  @override
  String get sostieniProgetto => 'Support the project';

  @override
  String get sostieniSotto =>
      'A donation helps development. It doesn\'t unlock anything: the whole app is free.';

  @override
  String get linkNonAperto => 'I can\'t open the link.';

  @override
  String battitiAlMinuto(Object p0) {
    return '$p0 bpm';
  }

  @override
  String giraVerso(Object p0) {
    return 'turn $p0';
  }

  @override
  String mancanoAncora(Object p0) {
    return '$p0 to go';
  }

  @override
  String recuperoDi(Object p0) {
    return 'rest $p0';
  }

  @override
  String quanteSerie(Object p0) {
    return '$p0 sets';
  }

  @override
  String quanteRipetizioni(Object p0) {
    return '$p0 reps';
  }

  @override
  String quanteAggiornate(Object p0) {
    return '$p0 updated';
  }

  @override
  String quanteRimosse(Object p0) {
    return '$p0 removed';
  }

  @override
  String aggiornato(Object p0) {
    return '$p0 updated';
  }

  @override
  String quantiChili(Object p0) {
    return '$p0 kilos';
  }

  @override
  String unoEAltro(Object p0, Object p1) {
    return '$p0 and $p1';
  }

  @override
  String quantiWatt(Object p0) {
    return '$p0 watts';
  }

  @override
  String quantiMetri(Object p0) {
    return '$p0 meters';
  }

  @override
  String connesso(Object p0) {
    return '$p0 connected';
  }

  @override
  String passoDiTour(Object p0, Object p1) {
    return '$p0 of $p1';
  }

  @override
  String quantiEsercizi(Object p0) {
    return '$p0 exercises';
  }

  @override
  String backupSessioni(Object p0) {
    return '$p0 sessions';
  }

  @override
  String backupMisure(Object p0) {
    return '$p0 measurements';
  }

  @override
  String backupFeedback(Object p0) {
    return '$p0 feedback';
  }

  @override
  String quantiGiorni(Object p0) {
    return '$p0 days';
  }

  @override
  String quanteOre(Object p0) {
    return '$p0 hours';
  }

  @override
  String quantiMinuti(Object p0) {
    return '$p0 minutes';
  }

  @override
  String quanteSedute(Object p0) {
    return '$p0 sessions';
  }

  @override
  String quanteProvate(Object p0, Object p1) {
    return '$p0 tried';
  }

  @override
  String quantiPunti(Object p0) {
    return '$p0 points';
  }

  @override
  String get parolaZona => 'zone';

  @override
  String poiCurva(Object p0) {
    return 'then $p0';
  }

  @override
  String get linguaVoce => 'Voice language';

  @override
  String get linguaVoceComeApp => 'Same as the app';

  @override
  String get linguaVoceComeTelefono => 'Same as the phone';

  @override
  String get linguaVoceSpiega =>
      'Turn-by-turn directions, km, pace and zones. In a language other than the app\'s, exercise names stay in the app\'s language.';

  @override
  String voceNonInstallata(Object p0) {
    return 'The $p0 voice isn\'t installed on the phone: install it from the text-to-speech settings, then try again.';
  }

  @override
  String get installaVoce => 'Install the voice';

  @override
  String get provaVoce => 'Test the voice';

  @override
  String get oppure => ' or ';

  @override
  String get mPerBattito => 'm/beat';

  @override
  String get parolaSettimana => 'week';

  @override
  String get parolaRecupero => 'Rest';

  @override
  String get assistenteTitolo => 'Assistant';

  @override
  String get etichettaRecupero => 'recovery';

  @override
  String get passiDuranteAllenamento => 'Steps during the workout';

  @override
  String get soloCorsaCamminataPassi =>
      'Only for running and walking, and only while workout mode is open, the app reads the phone\'s step counter (\"Physical activity\" permission) to show you steps and steps per minute. In the session it saves the total steps taken with the timer running: it stays on the phone and in the backup. Once the workout is closed the app no longer reads the sensor. Without the permission the workout works anyway, just without steps.';

  @override
  String quantiPassi(Object p0) {
    return '$p0 steps';
  }

  @override
  String get passiDalTelefono => 'Steps from the phone';

  @override
  String get passiDalTelefonoSpiega =>
      'While running and walking the app counts your steps with the phone\'s sensor (\"Physical activity\" permission), even without a watch.';

  @override
  String get permessoPassiNegato =>
      'The \"Physical activity\" permission is not granted: you can allow it in the app settings, under Permissions.';

  @override
  String get traccia => 'Track';
}
