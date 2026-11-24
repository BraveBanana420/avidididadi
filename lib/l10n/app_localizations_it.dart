// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get tenuto => 'Tenuto';

  @override
  String get poPiuLento => 'Un po\' più lento';

  @override
  String get moltoPiuLento => 'Molto più lento';

  @override
  String principaleInvece(Object p0, Object p1) {
    return 'principale $p0 invece di $p1';
  }

  @override
  String passoInvece(Object p0, Object p1) {
    return 'passo $p0 invece di $p1';
  }

  @override
  String intensitaInvece(Object p0, Object p1) {
    return 'intensità $p0 invece di $p1';
  }

  @override
  String totaleMInveceM(Object p0, Object p1) {
    return 'totale $p0 m invece di $p1 m';
  }

  @override
  String durataMinInvece(Object p0, Object p1) {
    return 'durata $p0 min invece di $p1';
  }

  @override
  String passoPiuLentoTarget(Object p0, Object p1, Object p2, Object p3) {
    return 'Passo più lento del target del $p0% (fatica $p1, attesa $p2): alleggerisco il $p3.';
  }

  @override
  String faticaSopraAttesaAlleggerisco(Object p0, Object p1, Object p2) {
    return 'Fatica $p0, sopra l\'attesa ($p1): alleggerisco il $p2.';
  }

  @override
  String faticaLineaAttesaProgressione(Object p0, Object p1) {
    return 'Fatica $p0, in linea con l\'attesa ($p1): progressione normale, una cosa alla volta.';
  }

  @override
  String faticaSottoAttesaPiccola(Object p0, Object p1) {
    return 'Fatica $p0, sotto l\'attesa ($p1): piccola progressione.';
  }

  @override
  String dueSedutePesantiFila(Object p0) {
    return 'Due sedute pesanti di fila: settimana di scarico per il $p0.';
  }

  @override
  String get claudeImpostazioniPrivacyDisattiva =>
      'In Claude: Impostazioni → Privacy → disattiva \"Aiuta a migliorare Claude\".';

  @override
  String get chatgptImpostazioniControlliDati =>
      'In ChatGPT: Impostazioni → Controlli dati → disattiva \"Migliora il modello per tutti\".';

  @override
  String get geminiDisattivaAttivitaNelle =>
      'In Gemini: disattiva \"Attività nelle app Gemini\" (o \"Mantieni attività\") dal tuo account Google.';

  @override
  String get controllaNelleImpostazioniDell =>
      'Controlla nelle impostazioni dell\'app se le chat servono ad addestrare il modello e, se vuoi, disattivalo.';

  @override
  String get nellaRispostaNonC =>
      'Nella risposta non c\'è il blocco per l\'app. Chiedi all\'assistente di scrivere le modifiche nel formato <avidididadi>.';

  @override
  String get codiceNellaRispostaNon =>
      'Il codice nella risposta non è quello di questo telefono: forse è di un collegamento vecchio. Manda di nuovo i dati e riprova.';

  @override
  String get bloccoNonLeggibileChiedi =>
      'Il blocco non è leggibile. Chiedi all\'assistente di riscriverlo.';

  @override
  String get dataInizioGiaPassata => 'La data di inizio è già passata.';

  @override
  String get dataMancante => 'data mancante';

  @override
  String get primaDellInizioPiano => 'prima dell\'inizio del piano';

  @override
  String oltreSettimane(Object p0) {
    return 'oltre le $p0 settimane';
  }

  @override
  String get sportNonPrevisto => 'sport non previsto';

  @override
  String get durataNonSensata => 'durata non sensata';

  @override
  String dueSeduteStessoGiorno(Object p0) {
    return 'due sedute di $p0 lo stesso giorno';
  }

  @override
  String settimanaMancaGiornoRiposo(Object p0) {
    return 'Settimana del $p0: manca un giorno di riposo.';
  }

  @override
  String settimanaMinutiTroppiRispetto(Object p0, Object p1, Object p2) {
    return 'Settimana del $p0: $p1 minuti, troppi rispetto alle settimane prima (al massimo $p2).';
  }

  @override
  String appNonHaAccettato(Object p0, Object p1) {
    return 'L\'app non ha accettato il piano per questi motivi:\n$p0\nCorreggilo e rimandalo nel blocco <avidididadi> con il codice $p1.';
  }

  @override
  String get allenamentoNonHaData => 'Un allenamento non ha la data.';

  @override
  String allenamentoSportDeveEssere(Object p0) {
    return 'Allenamento del $p0: lo sport deve essere corsa, bici o nuoto.';
  }

  @override
  String allenamentoServono140(Object p0) {
    return 'Allenamento del $p0: servono da 1 a 40 passi.';
  }

  @override
  String allenamento(Object p0) {
    return 'Allenamento di $p0';
  }

  @override
  String allenamentoPassoServonoMinuti(Object p0, Object p1) {
    return 'Allenamento del $p0, passo $p1: servono i minuti (fino a 300) o i metri.';
  }

  @override
  String allenamentoPassoRipetizioni1(Object p0, Object p1) {
    return 'Allenamento del $p0, passo $p1: ripetizioni da 1 a 30 e recupero fino a 1800 secondi.';
  }

  @override
  String allenamentoDuraPiu5(Object p0) {
    return 'Allenamento del $p0: dura più di 5 ore.';
  }

  @override
  String get trave => 'Trave';

  @override
  String get circuito => 'Circuito';

  @override
  String get campus => 'Campus';

  @override
  String get potenza => 'Potenza';

  @override
  String deveEssereNumero0(Object p0, Object p1, Object p2) {
    return '$p0: \"$p1\" deve essere un numero da 0 a $p2.';
  }

  @override
  String mancaNome(Object p0) {
    return '$p0: manca il nome.';
  }

  @override
  String esercizio(Object p0) {
    return 'Esercizio $p0';
  }

  @override
  String get allenamentoArrampicataNonHa =>
      'Un allenamento di arrampicata non ha il nome.';

  @override
  String servono130Esercizi(Object p0) {
    return '\"$p0\": servono da 1 a 30 esercizi.';
  }

  @override
  String esercizio2(Object p0, Object p1) {
    return '\"$p0\", esercizio $p1';
  }

  @override
  String get recuperoTraSerie => 'Recupero tra le serie';

  @override
  String riposaSerieDopo(Object p0) {
    return 'Riposa: la serie dopo è \"$p0\".';
  }

  @override
  String min(Object p0, Object p1) {
    return '$p0:$p1 min';
  }

  @override
  String dataNonValidaServe(Object p0) {
    return 'Data non valida: $p0 (serve AAAA-MM-GG).';
  }

  @override
  String get nelBloccoNonCi =>
      'Nel blocco non ci sono allenamenti di arrampicata.';

  @override
  String get backupRovinatoTuoiDati =>
      'Il backup è rovinato: i tuoi dati sono rimasti quelli di prima.';

  @override
  String errore(Object p0) {
    return 'Errore: $p0';
  }

  @override
  String get collegaPrimaIntervalsIcu =>
      'Collega prima intervals.icu da Profilo → Dati e collegamenti.';

  @override
  String get giaInviataIntervalsIcu => 'Già inviata a intervals.icu.';

  @override
  String get inviataIntervalsIcu => 'Inviata a intervals.icu.';

  @override
  String get incollaPrimaChiaveApi => 'Incolla prima la chiave API.';

  @override
  String get collegato => 'Collegato';

  @override
  String collegatoCome(Object p0) {
    return 'Collegato come $p0';
  }

  @override
  String get chiaveNonTrovataCollega =>
      'Chiave non trovata: collega di nuovo intervals.icu.';

  @override
  String attivitaLetteIntervalsIcu(Object p0) {
    return '$p0 attività lette da intervals.icu.';
  }

  @override
  String get calendarioIntervalsIcuGia =>
      'Il calendario di intervals.icu è già aggiornato.';

  @override
  String get sedutaMandata => 'seduta mandata';

  @override
  String get seduteMandate => 'sedute mandate';

  @override
  String intervalsIcu(Object p0) {
    return '$p0 a intervals.icu.';
  }

  @override
  String seduteTolteDalCalendario(Object p0) {
    return '$p0 sedute tolte dal calendario di intervals.icu.';
  }

  @override
  String get sincronizzazioneGiaCorso => 'Sincronizzazione già in corso.';

  @override
  String get healthConnectVaAggiornato =>
      'Health Connect va aggiornato: aprilo dal Play Store.';

  @override
  String get healthConnectNonInstallato =>
      'Health Connect non è installato sul telefono.';

  @override
  String get healthConnectDisponibileSolo =>
      'Health Connect è disponibile solo su Android.';

  @override
  String get healthConnectNonAncora => 'Health Connect non è ancora collegato.';

  @override
  String get senzaPermessoSessioniAllenamento =>
      'Senza il permesso per le sessioni di allenamento non posso leggere nulla. Puoi darlo da \"Rivedi permessi\".';

  @override
  String get nessunaNovitaHealthConnect => 'Nessuna novità da Health Connect.';

  @override
  String sessioniNuove(Object p0) {
    return '$p0 sessioni nuove';
  }

  @override
  String erroreDuranteSincronizzazione(Object p0) {
    return 'Errore durante la sincronizzazione: $p0';
  }

  @override
  String get feedbackSalvatoContaNel =>
      'Feedback salvato: conta nel carico di allenamento.';

  @override
  String get restaUguale => 'resta uguale';

  @override
  String prossimaSeduta(Object p0, Object p1, Object p2) {
    return '$p0\n\nProssima seduta ($p1): $p2.';
  }

  @override
  String get feedbackSalvato => 'Feedback salvato.';

  @override
  String get fileVuotoONon => 'file vuoto o non valido.';

  @override
  String formatoNonRiconosciutoServono(Object p0) {
    return 'formato non riconosciuto: servono almeno le colonne data e sport (trovate: $p0).';
  }

  @override
  String righeScartateDataO(Object p0) {
    return '$p0 righe scartate (data o sport mancanti)';
  }

  @override
  String ignorate(Object p0, Object p1) {
    return '$p0 ignorate ($p1)';
  }

  @override
  String sessioniNuoveAggiornate(Object p0, Object p1, Object p2) {
    return '$p0 sessioni nuove, $p1 aggiornate$p2.';
  }

  @override
  String gradoPiuDifficile(Object p0, Object p1) {
    return 'Grado più difficile: $p0$p1';
  }

  @override
  String get vieChiuse => 'vie chiuse';

  @override
  String get blocchiChiusi => 'blocchi chiusi';

  @override
  String circaMSaliti(Object p0) {
    return 'circa $p0 m saliti';
  }

  @override
  String progetto(Object p0) {
    return 'Progetto: $p0';
  }

  @override
  String get ollamaSulTuoPc => 'Ollama sul tuo PC';

  @override
  String get serveChiaveApiConsole =>
      'Serve una chiave API da console.anthropic.com (a consumo). L\'abbonamento Claude Pro non vale per le app esterne.';

  @override
  String get serveChiaveApiPlatform =>
      'Serve una chiave API da platform.openai.com (a consumo). L\'abbonamento ChatGPT Plus non vale per le app esterne.';

  @override
  String get serveChiaveApiAistudio =>
      'Serve una chiave API da aistudio.google.com: c\'è un piano gratuito con limiti giornalieri.';

  @override
  String get gratisPrivatoModelloGira =>
      'Gratis e privato: il modello gira sul tuo PC, nella stessa rete Wi-Fi. Nessuna chiave. Sul PC avvia Ollama con OLLAMA_HOST=0.0.0.0.';

  @override
  String get nelBloccoNonCi2 => 'Nel blocco non ci sono allenamenti.';

  @override
  String get nelPianoMancanoData =>
      'Nel piano mancano la data di inizio o le sedute.';

  @override
  String get nelBloccoNonCi3 => 'Nel blocco non ci sono modifiche valide.';

  @override
  String get propostaNonLeggibileChiedi =>
      'La proposta non è leggibile: chiedi al coach di riscriverla.';

  @override
  String sportNonPrevisto2(Object p0) {
    return 'sport non previsto ($p0)';
  }

  @override
  String get dataGiaPassata => 'la data è già passata';

  @override
  String durataNonSensataMin(Object p0) {
    return 'durata non sensata ($p0 min)';
  }

  @override
  String cGiaSedutaQuel(Object p0) {
    return 'c\'è già una seduta di $p0 quel giorno';
  }

  @override
  String get mancaDurata => 'manca la durata';

  @override
  String quelGiornoNonC(Object p0) {
    return 'quel giorno non c\'è una seduta di $p0';
  }

  @override
  String get nuovaDataMancanteO => 'nuova data mancante o passata';

  @override
  String cGiaSedutaGiorno(Object p0) {
    return 'c\'è già una seduta di $p0 il giorno scelto';
  }

  @override
  String settimanaPasserebbeMinutiOltre(Object p0, Object p1) {
    return 'la settimana passerebbe da $p0 a $p1 minuti (oltre +10%)';
  }

  @override
  String get settimanaResterebbeSenzaGiorno =>
      'la settimana resterebbe senza un giorno di riposo';

  @override
  String nuovaSeduta(Object p0, Object p1) {
    return '$p0: nuova seduta, $p1';
  }

  @override
  String tolta(Object p0, Object p1) {
    return '$p0: tolta$p1';
  }

  @override
  String get ellittica => 'Ellittica';

  @override
  String get canottaggio => 'Canottaggio';

  @override
  String get vogatore => 'Vogatore';

  @override
  String get stepper => 'Stepper';

  @override
  String get scale => 'Scale';

  @override
  String get sci => 'Sci';

  @override
  String get scialpinismo => 'Scialpinismo';

  @override
  String get sciFondo => 'Sci di fondo';

  @override
  String get pattinaggio => 'Pattinaggio';

  @override
  String get kayak => 'Kayak';

  @override
  String get canoa => 'Canoa';

  @override
  String get vela => 'Vela';

  @override
  String get surf => 'Surf';

  @override
  String get sup => 'SUP';

  @override
  String get calcio => 'Calcio';

  @override
  String get basket => 'Basket';

  @override
  String get pallavolo => 'Pallavolo';

  @override
  String get pingPong => 'Ping pong';

  @override
  String get danza => 'Danza';

  @override
  String get artiMarziali => 'Arti marziali';

  @override
  String get pugilato => 'Pugilato';

  @override
  String get uscitaBici => 'Uscita in bici';

  @override
  String get nuotoLibero => 'Nuoto libero';

  @override
  String get toccaFattoQuandoHai => 'Tocca \"Fatto\" quando hai finito.';

  @override
  String get duePagine => 'Due pagine';

  @override
  String get minimappa => 'Minimappa';

  @override
  String get tuttoSchermo => 'Tutto schermo';

  @override
  String get annulla => 'Annulla';

  @override
  String creato(Object p0) {
    return 'Creato il $p0';
  }

  @override
  String giorniPiano(Object p0) {
    return '$p0 giorni di piano';
  }

  @override
  String get fotoProfilo => 'foto del profilo';

  @override
  String get fileTroppoGrandeEssere =>
      'File troppo grande per essere un backup.';

  @override
  String get fileNonBackupAvidididadi =>
      'Il file non è un backup di Avidididadi.';

  @override
  String get backupCreatoVersionePiu =>
      'Backup creato da una versione più recente dell\'app: aggiornala.';

  @override
  String get backupVuoto => 'Il backup è vuoto.';

  @override
  String get nonRiescoScrivereNella =>
      'Non riesco a scrivere nella cartella: sceglila di nuovo (forse è stata spostata o cancellata).';

  @override
  String get backupAutomaticoNonRiuscito => 'Backup automatico non riuscito.';

  @override
  String get sensoreBattito => 'Sensore del battito';

  @override
  String get bastaPaioScarpeSi =>
      'Basta un paio di scarpe. Si parte anche camminando.';

  @override
  String get casaOPalestraAnche =>
      'A casa o in palestra, anche senza attrezzi.';

  @override
  String get piscinaDelicatoSulleArticolazioni =>
      'In piscina, delicato sulle articolazioni.';

  @override
  String get allApertoOSui => 'All\'aperto o sui rulli, a ritmo tranquillo.';

  @override
  String get stretchingMovimentiLentiPerfetta =>
      'Stretching e movimenti lenti: perfetta per iniziare o recuperare.';

  @override
  String get palestraOFalesiaSegni =>
      'In palestra o in falesia: segni vie, blocchi e gradi.';

  @override
  String get maiOQuasiMai => 'Mai o quasi mai';

  @override
  String get siPartePianoSedute =>
      'Si parte piano: sedute semplici per imparare i movimenti.';

  @override
  String get ogniTanto => 'Ogni tanto';

  @override
  String get qualcheAllenamentoAlMese =>
      'Qualche allenamento al mese, ma senza costanza.';

  @override
  String get regolarmente => 'Regolarmente';

  @override
  String get miAllenoQuasiOgni => 'Mi alleno quasi ogni settimana da mesi.';

  @override
  String get caloStaiFacendoMeno => 'In calo: stai facendo meno del solito.';

  @override
  String get equilibratoAumentoSostenibile =>
      'Equilibrato: aumento sostenibile.';

  @override
  String get attenzioneStaiAumentandoFretta =>
      'Attenzione: stai aumentando in fretta.';

  @override
  String get rischioTroppoCaricoRispetto =>
      'Rischio: troppo carico rispetto alle ultime settimane.';

  @override
  String hMin(Object p0, Object p1) {
    return '$p0 h $p1 min';
  }

  @override
  String get chiudi => 'Chiudi';

  @override
  String get nessunDatoQuestoGrafico => 'Nessun dato per questo grafico.';

  @override
  String settimanaDal(Object p0) {
    return 'Settimana dal $p0';
  }

  @override
  String totale(Object p0) {
    return 'Totale: $p0';
  }

  @override
  String tuttoPeriodo(Object p0, Object p1) {
    return '$p0 in tutto il periodo: $p1';
  }

  @override
  String get nessunAllenamento => 'Nessun allenamento';

  @override
  String ripetizione(Object p0, Object p1) {
    return 'Ripetizione $p0 di $p1';
  }

  @override
  String serie(Object p0, Object p1) {
    return 'Serie $p0 di $p1';
  }

  @override
  String get latoDestro => 'Lato destro';

  @override
  String get latoSinistro => 'Lato sinistro';

  @override
  String get cambiaLato => 'Cambia lato';

  @override
  String get cambiaLatoVoce => 'Cambia lato.';

  @override
  String secondiPerLato(Object p0) {
    return '$p0 s per lato';
  }

  @override
  String ripetizioniPerLato(Object p0) {
    return '$p0 per lato';
  }

  @override
  String poiRipetizione(Object p0, Object p1) {
    return 'Poi ripetizione $p0 di $p1';
  }

  @override
  String poiSerie(Object p0, Object p1) {
    return 'Poi serie $p0 di $p1';
  }

  @override
  String get continuaPianoSenzaFermarti => 'Continua piano, senza fermarti.';

  @override
  String get respiraBeviSorsoAcqua => 'Respira e bevi un sorso d\'acqua.';

  @override
  String get manubri => 'Manubri';

  @override
  String get pesoOgniManubrioEs =>
      'Il peso di ogni manubrio, es. 4, 8, 12. Se sono regolabili scrivi l\'intervallo, es. 2-20.';

  @override
  String get kettlebell => 'Kettlebell';

  @override
  String get pesoOgniKettlebellHai => 'Il peso di ogni kettlebell che hai.';

  @override
  String get bilanciere => 'Bilanciere';

  @override
  String get pesoSolaBarraSolito =>
      'Il peso della sola barra (di solito 20 kg).';

  @override
  String get dischi => 'Dischi';

  @override
  String get pesoDeiDischiHai =>
      'Il peso dei dischi che hai. Si usano anche senza bilanciere.';

  @override
  String get pallaMedica => 'Palla medica';

  @override
  String get pesoPalla => 'Il peso della palla.';

  @override
  String get elastici => 'Elastici';

  @override
  String get sbarraTrazioni => 'Sbarra per trazioni';

  @override
  String get paralleleDip => 'Parallele per dip';

  @override
  String get anelliOTrx => 'Anelli o TRX';

  @override
  String get panca => 'Panca';

  @override
  String get stepOBox => 'Step o box';

  @override
  String get fitball => 'Fitball';

  @override
  String get rulloFoamRoller => 'Rullo (foam roller)';

  @override
  String get latMachine => 'Lat machine';

  @override
  String get pulleyBasso => 'Pulley basso';

  @override
  String get caviRegolabiliCroceAi => 'Cavi regolabili (croce ai cavi)';

  @override
  String get chestPress => 'Chest press';

  @override
  String get pectoralMachine => 'Pectoral machine';

  @override
  String get shoulderPress => 'Shoulder press';

  @override
  String get rematoreAllaMacchina => 'Rematore alla macchina';

  @override
  String get multipowerSmithMachine => 'Multipower (Smith machine)';

  @override
  String get legPress => 'Leg press';

  @override
  String get hackSquat => 'Hack squat';

  @override
  String get legExtension => 'Leg extension';

  @override
  String get legCurl => 'Leg curl';

  @override
  String get adduttoriAbduttori => 'Adduttori e abduttori';

  @override
  String get calfMachinePolpacci => 'Calf machine (polpacci)';

  @override
  String get addominali => 'Addominali';

  @override
  String get obliqui => 'Obliqui';

  @override
  String get adduttori => 'Adduttori';

  @override
  String get bicipiti => 'Bicipiti';

  @override
  String get polpacci => 'Polpacci';

  @override
  String get petto => 'Petto';

  @override
  String get avambracci => 'Avambracci';

  @override
  String get glutei => 'Glutei';

  @override
  String get femorali => 'Femorali';

  @override
  String get dorsali => 'Dorsali';

  @override
  String get lombari => 'Lombari';

  @override
  String get collo => 'Collo';

  @override
  String get quadricipiti => 'Quadricipiti';

  @override
  String get spalle => 'Spalle';

  @override
  String get trapezio => 'Trapezio';

  @override
  String get tricipiti => 'Tricipiti';

  @override
  String get spintaOrizzontalePetto => 'Spinta orizzontale (petto)';

  @override
  String get spintaVerticaleSpalle => 'Spinta verticale (spalle)';

  @override
  String get trazioneOrizzontaleRematori => 'Trazione orizzontale (rematori)';

  @override
  String get trazioneVerticaleTrazioni => 'Trazione verticale (trazioni)';

  @override
  String get squat => 'Squat';

  @override
  String get affondiStep => 'Affondi e step';

  @override
  String get cernieraAncaStacchiPonti => 'Cerniera d\'anca (stacchi e ponti)';

  @override
  String get core => 'Core';

  @override
  String get spallePostura => 'Spalle e postura';

  @override
  String get braccia => 'Braccia';

  @override
  String get gambeAlleMacchine => 'Gambe alle macchine';

  @override
  String get pliometria => 'Pliometria';

  @override
  String get totalBody => 'Total body';

  @override
  String get rulloAutomassaggio => 'Rullo (automassaggio)';

  @override
  String get n1Esercizio => '1 esercizio';

  @override
  String get beneDallaProssimaSessione =>
      'Bene! Dalla prossima sessione aumento un po\' il carico.';

  @override
  String get haiSegnalatoDoloreAlleggerisco =>
      'Hai segnalato dolore: alleggerisco le prossime sessioni. Se il dolore continua, fermati e chiedi a un medico.';

  @override
  String get alleggeriscoPoProssimeSessioni =>
      'Alleggerisco un po\' le prossime sessioni.';

  @override
  String get caricoGiustoSiContinua => 'Carico giusto: si continua così.';

  @override
  String tiAlleniMeglioQuanto(Object p0) {
    return 'Ti alleni meglio di quanto pensavi: passo al livello $p0.';
  }

  @override
  String passoAlLivelloPiu(Object p0) {
    return 'Passo al livello $p0, più adatto per ora.';
  }

  @override
  String haiSegnalatoDoloreAlleggerisco2(Object p0) {
    return 'Hai segnalato dolore: alleggerisco le prossime sedute di $p0. Se il dolore continua, fermati e chiedi a un medico.';
  }

  @override
  String beneSeduteSonoGia(Object p0) {
    return 'Bene! Le sedute di $p0 sono già al massimo dell\'aumento.';
  }

  @override
  String beneAumentoPoIntensita(Object p0) {
    return 'Bene! Aumento un po\' l\'intensità delle prossime sedute di $p0, a parità di tempo.';
  }

  @override
  String beneAllungoPoProssime(Object p0) {
    return 'Bene! Allungo un po\' le prossime sedute di $p0.';
  }

  @override
  String rendoPoMenoIntense(Object p0) {
    return 'Rendo un po\' meno intense le prossime sedute di $p0.';
  }

  @override
  String accorcioPoProssimeSedute(Object p0) {
    return 'Accorcio un po\' le prossime sedute di $p0.';
  }

  @override
  String get faticaGiustaSiContinua => 'Fatica giusta: si continua così.';

  @override
  String get braccio => 'Braccio';

  @override
  String get vita => 'Vita';

  @override
  String get fianchi => 'Fianchi';

  @override
  String get coscia => 'Coscia';

  @override
  String get durata => 'Durata';

  @override
  String get sedutePiuLunghe5 => 'Sedute più lunghe del 5% per ogni passo.';

  @override
  String get intensita => 'Intensità';

  @override
  String get stessaDurataPiuSforzo =>
      'Stessa durata, più sforzo: recuperi più brevi, più minuti veloci, passo un po\' più svelto.';

  @override
  String get auto => 'Auto';

  @override
  String get primaIntensitaFino2 =>
      'Prima l\'intensità (fino a 2 passi), poi la durata.';

  @override
  String min2(Object p0, Object p1) {
    return '$p0 · $p1 min';
  }

  @override
  String get corsaLeggeraAlternataCamminata =>
      'Corsa leggera alternata a camminata';

  @override
  String get dopo2MinutiCorsa =>
      'Dopo 2 minuti di corsa cammina 1 minuto. Se ti manca il fiato, cammina di più: va benissimo, è così che si comincia.';

  @override
  String lungoMin(Object p0) {
    return 'Lungo · $p0 min';
  }

  @override
  String get corsaLungaContinua => 'Corsa lunga continua';

  @override
  String get ritmoFacileCostanteDevi =>
      'Ritmo facile e costante: devi riuscire a parlare.';

  @override
  String get finaleRitmoGara => 'Finale a ritmo gara';

  @override
  String get finaleProgressione => 'Finale in progressione';

  @override
  String get corsaFacile => 'Corsa facile';

  @override
  String get corsaVeloce => 'Corsa veloce';

  @override
  String get recuperoCorricchiandoZona2 => 'Recupero corricchiando in zona 2.';

  @override
  String get corsaRitmoSostenuto => 'Corsa a ritmo sostenuto';

  @override
  String get ripetuteVeloci => 'Ripetute veloci';

  @override
  String get recuperoCorricchiandoPiano => 'Recupero corricchiando piano.';

  @override
  String get blocchiRitmoGara => 'Blocchi a ritmo gara';

  @override
  String get allunghiProgressione => 'Allunghi in progressione';

  @override
  String get velociMaRilassatiNon => 'Veloci ma rilassati, non a tutta.';

  @override
  String lentoMin(Object p0) {
    return 'Lento · $p0 min';
  }

  @override
  String get corsaLenta => 'Corsa lenta';

  @override
  String get stileLiberoFacile => 'Stile libero facile';

  @override
  String get gambeTavolettaBraccioSingolo =>
      'Gambe con tavoletta e braccio singolo';

  @override
  String get n2GambeTavoletta1 =>
      '2 gambe con tavoletta, 1 solo braccio destro, 1 solo sinistro.';

  @override
  String get stileLiberoSostenuto => 'Stile libero sostenuto';

  @override
  String get sostenutoCostante => 'sostenuto, costante';

  @override
  String get stileLiberoAerobico => 'Stile libero aerobico';

  @override
  String get medioRespirazioneRegolare => 'medio, respirazione regolare';

  @override
  String get dorsoFacile => 'Dorso facile';

  @override
  String intervalliMin(Object p0) {
    return 'Intervalli · $p0 min';
  }

  @override
  String get pedalataAgile => 'Pedalata agile';

  @override
  String get ripetuteSalitaOPianura => 'Ripetute in salita o in pianura';

  @override
  String get pedalataSciolta => 'Pedalata sciolta';

  @override
  String get uscitaLunga => 'Uscita lunga';

  @override
  String uscitaLungaMin(Object p0) {
    return 'Uscita lunga · $p0 min';
  }

  @override
  String get uscitaContinua => 'Uscita continua';

  @override
  String inserisciTratti10Minuti(Object p0) {
    return 'Inserisci $p0 tratti da 10 minuti in zona 3. Mangia e bevi ogni 30-45 minuti.';
  }

  @override
  String get mangiaBeviOgni30 => 'Mangia e bevi ogni 30-45 minuti.';

  @override
  String uscitaMin(Object p0) {
    return 'Uscita · $p0 min';
  }

  @override
  String get pedalataCostante => 'Pedalata costante';

  @override
  String get finalePiuSpinto => 'Finale più spinto';

  @override
  String get pocheRipetizioniCarichiAlti =>
      'Poche ripetizioni con carichi alti e recuperi lunghi.';

  @override
  String get massaMuscolare => 'Massa muscolare';

  @override
  String get ripetizioniMediePiuVolume =>
      'Ripetizioni medie, più volume per far crescere i muscoli.';

  @override
  String get resistenzaMuscolare => 'Resistenza muscolare';

  @override
  String get tanteRipetizioniRecuperiBrevi =>
      'Tante ripetizioni e recuperi brevi, utile per gli sport di resistenza.';

  @override
  String get formaGenerale => 'Forma generale';

  @override
  String get equilibrioTraForzaMuscoli =>
      'Un equilibrio tra forza, muscoli e resistenza.';

  @override
  String get principiante => 'Principiante';

  @override
  String get tiAlleniPesiPoco =>
      'Ti alleni con i pesi da poco o non lo fai da tempo.';

  @override
  String get intermedio => 'Intermedio';

  @override
  String get tiAlleniCostanzaAlmeno =>
      'Ti alleni con costanza da almeno qualche mese.';

  @override
  String get avanzato => 'Avanzato';

  @override
  String get tiAlleniAnniConosci =>
      'Ti alleni da anni e conosci bene la tecnica.';

  @override
  String settimana4(Object p0, Object p1) {
    return '$p0 · settimana $p1 di 4';
  }

  @override
  String get n10Lato => '10 per lato';

  @override
  String get n10Lenti => '10 lenti';

  @override
  String get settimanaScaricoSerieMeno =>
      'Settimana di scarico: una serie in meno, stessa tecnica.';

  @override
  String get settimana2RipetizionePiu =>
      'Settimana 2: una ripetizione in più rispetto alla scorsa.';

  @override
  String get settimana3DueRipetizioni =>
      'Settimana 3: due ripetizioni in più rispetto alla prima.';

  @override
  String gambeLeggereDomaniHai(Object p0) {
    return 'Gambe leggere: domani hai $p0.';
  }

  @override
  String n10Fatica(Object p0) {
    return '$p0/10 di fatica';
  }

  @override
  String get n30SLato => '30 s per lato';

  @override
  String get lungo => 'il Lungo';

  @override
  String get fartlek => 'il Fartlek';

  @override
  String get tempoRun => 'il Tempo run';

  @override
  String get partiSolaBarraAggiungi =>
      'Parti con la sola barra e aggiungi dischi fino alla fatica indicata.';

  @override
  String pesoKg(Object p0, Object p1) {
    return 'Peso: $p0 $p1 kg.';
  }

  @override
  String pesoCircaKg(Object p0) {
    return 'Peso: circa $p0 kg.';
  }

  @override
  String get movimentiLentiRespiraCalma =>
      'Movimenti lenti, respira con calma: allunga senza mai sentire dolore.';

  @override
  String get corsaRitmoTranquilloDevi =>
      'Corsa a ritmo tranquillo: devi riuscire a parlare senza fiatone. Costruisce la resistenza ed è la base di tutto.';

  @override
  String get corsaPiuLungaSettimana =>
      'La corsa più lunga della settimana, sempre a ritmo facile. Abitua il corpo a durare nel tempo.';

  @override
  String get giocoVelocitaAlterniTratti =>
      'Gioco di velocità: alterni tratti veloci e tratti facili, senza mai fermarti. Allena a cambiare ritmo.';

  @override
  String get corsaRitmoSostenutoMa =>
      'Corsa a ritmo sostenuto ma costante, \"comodamente impegnativo\": parli a fatica, ma lo tieni per molti minuti.';

  @override
  String get trattiBreviVelociPausa =>
      'Tratti brevi e veloci con una pausa per recuperare tra uno e l\'altro. Rendono più veloci.';

  @override
  String get blocchiAlRitmoVuoi =>
      'Blocchi al ritmo che vuoi tenere il giorno della gara, per prenderci confidenza.';

  @override
  String get corsaFacileQualcheAccelerazione =>
      'Corsa facile con qualche accelerazione breve (20 secondi), veloce ma rilassata. Tiene le gambe brillanti senza stancare.';

  @override
  String get nuotoCalmoEserciziMigliorare =>
      'Nuoto calmo con esercizi per migliorare il movimento: nuotare bene costa meno fatica.';

  @override
  String get serieVascheRitmoSostenuto =>
      'Serie di vasche a ritmo sostenuto e costante con brevi pause. Migliora la velocità che riesci a tenere a lungo.';

  @override
  String get pedalataCostanteRitmoFacile =>
      'Pedalata costante a ritmo facile: costruisce la resistenza.';

  @override
  String get pedalataPiuLungaSettimana =>
      'La pedalata più lunga della settimana, a ritmo facile. Porta acqua e qualcosa da mangiare.';

  @override
  String get trattiPedalataImpegnativaSalita =>
      'Tratti di pedalata impegnativa (in salita o in pianura) con pause facili in mezzo.';

  @override
  String get movimentiLentiAllungamentiQuasi =>
      'Movimenti lenti e allungamenti, quasi tutti a tempo. Sciolgono articolazioni e muscoli, aiutano a recuperare e a muoversi meglio. Non deve mai fare male.';

  @override
  String get mobilitaAncheCoscePolpacci =>
      'Mobilità per anche, cosce e polpacci: le parti che lavorano di più in corsa e in bici.';

  @override
  String get mobilitaSchienaBustoUtile =>
      'Mobilità per la schiena e il busto: utile se stai molto seduto.';

  @override
  String get mobilitaSpallePettoBraccia =>
      'Mobilità per spalle, petto e braccia: apre la postura e aiuta nel nuoto.';

  @override
  String get eserciziMuscoliCorpoLibero =>
      'Esercizi per i muscoli, a corpo libero o con i pesi, seguiti da qualche minuto di mobilità. Rendono più forti e proteggono da infortuni.';

  @override
  String get moltoFacileComeCamminata =>
      'molto facile, come una camminata veloce';

  @override
  String get facileRiesciParlare => 'facile: riesci a parlare';

  @override
  String get medioParliMaFatica => 'medio: parli, ma a fatica';

  @override
  String get impegnativoSoloPocheParole => 'impegnativo: solo poche parole';

  @override
  String get alMassimoSiRegge => 'al massimo: si regge per poco';

  @override
  String get zoneFrequenzaCardiaca => 'Zone di frequenza cardiaca';

  @override
  String get cinqueFasceBattitiAl =>
      'Cinque fasce di battiti al minuto, dalla più facile (1) alla più dura (5). Le calcola l\'app dai tuoi dati: segui la zona indicata e l\'allenamento ha l\'effetto giusto.';

  @override
  String get fatica110 => 'Fatica (da 1 a 10)';

  @override
  String get quantoTiSembrataDura =>
      'Quanto ti è sembrata dura la seduta: 1 è una passeggiata, 10 è il massimo. Dirlo dopo ogni seduta aiuta l\'app ad adattare il piano.';

  @override
  String get carico => 'Carico';

  @override
  String get quantoTiSeiAllenato =>
      'Quanto ti sei allenato, tenendo conto di durata e fatica. Conta come cresce: aumentare poco alla volta evita di farsi male.';

  @override
  String get settimanaScarico => 'Settimana di scarico';

  @override
  String get ogniQuattroSettimanePiu =>
      'Ogni quattro settimane una più leggera: il corpo assorbe il lavoro fatto e riparte più forte.';

  @override
  String get comeStaiOggiSonno =>
      'Come stai oggi, da sonno e battiti a riposo. Se è basso, meglio una seduta facile.';

  @override
  String get movimentiLentiSciogliereArticolazioni =>
      'Movimenti lenti per sciogliere le articolazioni a fine seduta.';

  @override
  String get stoRegistrandoPercorso => 'Sto registrando il percorso';

  @override
  String get registrazionePercorso => 'Registrazione percorso';

  @override
  String get sessioniAllenamento => 'Sessioni di allenamento';

  @override
  String get frequenzaCardiaca => 'Frequenza cardiaca';

  @override
  String get distanza => 'Distanza';

  @override
  String get calorieAttive => 'Calorie attive';

  @override
  String get calorieTotali => 'Calorie totali';

  @override
  String get passi => 'Passi';

  @override
  String get velocita => 'Velocità';

  @override
  String get fcRiposo => 'FC a riposo';

  @override
  String get variabilitaCardiacaHrv => 'Variabilità cardiaca (HRV)';

  @override
  String get sonno => 'Sonno';

  @override
  String get immagineNonDisponibileSenza =>
      'Immagine non disponibile senza rete';

  @override
  String previsti(Object p0, Object p1) {
    return '$p0 (previsti $p1)';
  }

  @override
  String recupero(Object p0) {
    return 'Recupero $p0';
  }

  @override
  String fc(Object p0) {
    return 'FC $p0';
  }

  @override
  String get chiaveApiNonValida =>
      'Chiave API non valida: ricopiala da intervals.icu → Impostazioni → Developer settings.';

  @override
  String get intervalsIcuHaRicevuto =>
      'intervals.icu ha ricevuto troppe richieste: riprova tra qualche minuto.';

  @override
  String intervalsIcuHaRisposto(Object p0) {
    return 'intervals.icu ha risposto con un errore ($p0).';
  }

  @override
  String get nessunaConnessioneInternet => 'Nessuna connessione a internet.';

  @override
  String get intervalsIcuNonRisponde => 'intervals.icu non risponde: riprova.';

  @override
  String get rispostaIntervalsIcuNon =>
      'Risposta di intervals.icu non leggibile.';

  @override
  String get chiaveApiNonValida2 => 'Chiave API non valida.';

  @override
  String get indirizzoOllamaNonValido =>
      'Indirizzo di Ollama non valido: scrivilo come http://192.168.1.10:11434';

  @override
  String get proteggereTuoiDatiIndirizzo =>
      'Per proteggere i tuoi dati, l\'indirizzo http è accettato solo nella rete di casa (es. http://192.168.1.10:11434). Per un indirizzo su internet serve https.';

  @override
  String get rispostaVuotaDalModello => 'Risposta vuota dal modello.';

  @override
  String chiaveApiNonValida3(Object p0) {
    return 'Chiave API non valida: ricopiala dal sito del servizio, per intero.\n($p0)';
  }

  @override
  String get richiestaRifiutataControllaNome =>
      'Richiesta rifiutata: controlla il nome del modello.';

  @override
  String get chiaveApiNonValida4 => 'Chiave API non valida o senza permessi.';

  @override
  String get modelloNonTrovatoSu =>
      'Modello non trovato su Ollama: scaricalo con \"ollama pull\".';

  @override
  String get modelloNonTrovatoControlla =>
      'Modello non trovato: controlla il nome.';

  @override
  String get limiteRichiesteRaggiuntoO =>
      'Limite di richieste raggiunto o credito esaurito. Riprova più tardi.';

  @override
  String get servizioHaProblemaQuesto =>
      'Il servizio ha un problema in questo momento. Riprova più tardi.';

  @override
  String errore2(Object p0) {
    return 'Errore $p0.';
  }

  @override
  String get mancaChiaveApiAggiungila =>
      'Manca la chiave API: aggiungila qui sopra.';

  @override
  String nonRiescoRaggiungereOllama(Object p0, Object p1) {
    return 'Non riesco a raggiungere Ollama a $p0. ($p1)';
  }

  @override
  String nessunaConnessioneInternet2(Object p0) {
    return 'Nessuna connessione a internet. ($p0)';
  }

  @override
  String get servizioNonRispondeRiprova => 'Il servizio non risponde: riprova.';

  @override
  String get rispostaNonLeggibile => 'Risposta non leggibile.';

  @override
  String get indirizzoNonValido => 'Indirizzo non valido.';

  @override
  String esempio(Object p0) {
    return ', per esempio $p0';
  }

  @override
  String chiaveFunzionaMaModello(Object p0, Object p1) {
    return 'La chiave funziona, ma il modello \"$p0\" non esiste. Toccane uno da \"Scegli tra i modelli disponibili\"$p1.';
  }

  @override
  String get provaConnessione => 'Prova di connessione';

  @override
  String ollamaRispondeMaModello(Object p0, Object p1) {
    return 'Ollama risponde, ma il modello \"$p0\" non c\'è. Installati: $p1.';
  }

  @override
  String nonRiescoRaggiungereOllama2(Object p0, Object p1) {
    return 'Non riesco a raggiungere Ollama a $p0. Il PC è acceso, nella stessa rete, con Ollama aperto? ($p1)';
  }

  @override
  String get ollamaNonRispondePc => 'Ollama non risponde: il PC è acceso?';

  @override
  String get indirizzoNonValidoO =>
      'Indirizzo non valido o risposta non di Ollama.';

  @override
  String get indirizzoNonValidoScrivilo =>
      'Indirizzo non valido: scrivilo come http://IP:11434';

  @override
  String get mancaChiaveApiAggiungila2 =>
      'Manca la chiave API: aggiungila nelle impostazioni.';

  @override
  String nonRiescoRaggiungereOllama3(Object p0, Object p1) {
    return 'Non riesco a raggiungere Ollama a $p0. Il PC è acceso, nella stessa rete, con OLLAMA_HOST=0.0.0.0? ($p1)';
  }

  @override
  String get modelloCiStaMettendo =>
      'Il modello ci sta mettendo troppo: riprova.';

  @override
  String get allenamentoInterrotto => 'Allenamento interrotto';

  @override
  String appSiEraChiusa(Object p0) {
    return 'L\'app si era chiusa durante l\'allenamento: $p0. Riprendi da dove eri? Riparte in pausa.';
  }

  @override
  String get scarta => 'Scarta';

  @override
  String get riprendi => 'Riprendi';

  @override
  String get rispostaRicevutaTroviCoach =>
      'Risposta ricevuta: la trovi in Coach.';

  @override
  String get oggi => 'Oggi';

  @override
  String get progressi => 'Progressi';

  @override
  String get coach => 'Coach';

  @override
  String get profilo => 'Profilo';

  @override
  String circaMb(Object p0) {
    return 'circa $p0 MB';
  }

  @override
  String get downloadNonRiuscitoServe =>
      'Download non riuscito: serve la rete. Riprova più tardi.';

  @override
  String get lunedi => 'Lunedì';

  @override
  String get martedi => 'Martedì';

  @override
  String get mercoledi => 'Mercoledì';

  @override
  String get giovedi => 'Giovedì';

  @override
  String get venerdi => 'Venerdì';

  @override
  String get sabato => 'Sabato';

  @override
  String get domenica => 'Domenica';

  @override
  String intensita2(Object p0) {
    return 'intensità $p0';
  }

  @override
  String recuperoS(Object p0) {
    return 'recupero $p0 s';
  }

  @override
  String get tuaCorsaPiuLunga => 'La tua corsa più lunga';

  @override
  String get tuaUscitaBiciPiu => 'La tua uscita in bici più lunga';

  @override
  String get tuaNuotataPiuLunga => 'La tua nuotata più lunga';

  @override
  String get tuaCamminataPiuLunga => 'La tua camminata più lunga';

  @override
  String get primoAllenamentoFatto => 'Primo allenamento fatto!';

  @override
  String haiFattoAllenamenti(Object p0) {
    return 'Hai fatto $p0 allenamenti!';
  }

  @override
  String record(Object p0) {
    return 'Record: $p0';
  }

  @override
  String settimaneFilaGrande(Object p0) {
    return '$p0 settimane di fila: grande!';
  }

  @override
  String settimaneFilaVai(Object p0, Object p1) {
    return '$p0 settimane di fila. Vai per la $p1?';
  }

  @override
  String get nelFileNonC =>
      'Nel file non c\'è un percorso: serve un GPX con una traccia.';

  @override
  String get destra => 'a destra';

  @override
  String get sinistra => 'a sinistra';

  @override
  String get tieniDestra => 'tieni la destra';

  @override
  String get tieniSinistra => 'tieni la sinistra';

  @override
  String curvaStretta(Object p0) {
    return 'curva stretta $p0';
  }

  @override
  String get tornaIndietro => 'torna indietro';

  @override
  String poiSubito(Object p0) {
    return 'poi subito $p0';
  }

  @override
  String get nuovoSulPercorso => 'Di nuovo sul percorso.';

  @override
  String seiFuoriPercorsoDalla(Object p0) {
    return 'Sei fuori percorso, a $p0 dalla traccia.';
  }

  @override
  String get staiAndandoNelSenso =>
      'Stai andando nel senso contrario al percorso.';

  @override
  String get arrivoPercorsoCompletato => 'Arrivo! Percorso completato.';

  @override
  String tra(Object p0, Object p1, Object p2) {
    return 'Tra $p0, $p1$p2.';
  }

  @override
  String recuperoPoi(Object p0) {
    return 'Recupero · poi $p0';
  }

  @override
  String pausa(Object p0) {
    return 'In pausa · $p0';
  }

  @override
  String get n5Km => '5 km';

  @override
  String get n10Km => '10 km';

  @override
  String get mezzaMaratona => 'Mezza maratona';

  @override
  String get maratona => 'Maratona';

  @override
  String get mediofondo => 'Mediofondo';

  @override
  String get granfondo => 'Granfondo';

  @override
  String get triathlonSprint => 'Triathlon sprint';

  @override
  String get triathlonOlimpico => 'Triathlon olimpico';

  @override
  String get triathlon703 => 'Triathlon 70.3';

  @override
  String get base => 'Base';

  @override
  String get sviluppo => 'Sviluppo';

  @override
  String get rifinitura => 'Rifinitura';

  @override
  String get scaricoPreGara => 'Scarico pre-gara';

  @override
  String get settimanaGara => 'Settimana della gara';

  @override
  String get senzaObiettivo => 'Senza obiettivo';

  @override
  String get volumeCrescePianoQuasi =>
      'Volume che cresce piano, quasi tutto a bassa intensità.';

  @override
  String get siAggiungonoSeduteQualita =>
      'Si aggiungono le sedute di qualità, il lungo si allunga.';

  @override
  String get lavoriAlRitmoGara => 'Lavori al ritmo gara, volume stabile.';

  @override
  String get menoVolumePoIntensita =>
      'Meno volume, un po\' di intensità per restare reattivo.';

  @override
  String get pocheSeduteCorteSi =>
      'Poche sedute corte: si arriva freschi al via.';

  @override
  String get pianoMantenimentoImpostaGara =>
      'Piano di mantenimento: imposta una gara per una preparazione.';

  @override
  String get aerobica => 'Aerobica';

  @override
  String get medio => 'Medio';

  @override
  String get massimale => 'Massimale';

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
      'Nel file non c\'è un percorso: serve un GPX con la traccia dell\'attività.';

  @override
  String get pulse => 'Pulse';

  @override
  String get strade => 'Strade';

  @override
  String get satellite => 'Satellite';

  @override
  String get facile => 'Facile';

  @override
  String get fondo => 'Fondo';

  @override
  String get vo2max => 'VO2max';

  @override
  String get anaerobica => 'Anaerobica';

  @override
  String get sprint => 'Sprint';

  @override
  String finoW(Object p0) {
    return 'fino a $p0 W';
  }

  @override
  String oltreW(Object p0) {
    return 'oltre $p0 W';
  }

  @override
  String cadenzaScendiA(Object p0, Object p1) {
    return 'Cadenza $p0, scendi a $p1.';
  }

  @override
  String cadenzaSaliA(Object p0, Object p1) {
    return 'Cadenza $p0, sali a $p1.';
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
  String wattScendiA(Object p0, Object p1) {
    return '$p0 watt, scendi a $p1.';
  }

  @override
  String wattSaliA(Object p0, Object p1) {
    return '$p0 watt, sali a $p1.';
  }

  @override
  String get registraQuestaCorsaAnche =>
      'Registra questa corsa anche con l\'orologio: è lui a misurare i watt.';

  @override
  String get velociMaScioltiPoi =>
      'Veloci ma sciolti, poi cammina o corri piano.';

  @override
  String get test20MinutiAl => 'Test: 20 minuti al massimo';

  @override
  String get ritmoPiuForteRiesci =>
      'Il ritmo più forte che riesci a tenere fino alla fine, costante. Meglio partire un po\' piano e chiudere in crescendo.';

  @override
  String get corsaLentissima => 'Corsa lentissima';

  @override
  String get energiaBuona => 'Energia buona';

  @override
  String get energiaNormale => 'Energia normale';

  @override
  String get energiaBassa => 'Energia bassa';

  @override
  String get giornataAdattaAncheSeduta =>
      'Giornata adatta anche a una seduta di qualità.';

  @override
  String get allenatiComePrevistoAscoltando =>
      'Allenati come previsto, ascoltando le sensazioni.';

  @override
  String get meglioSedutaFacileO =>
      'Meglio una seduta facile o un giorno di riposo: abbassa l\'intensità.';

  @override
  String solitoMsPiuAlta(Object p0) {
    return 'di solito $p0 ms · più alta è meglio';
  }

  @override
  String hrvMsSottoTua(Object p0, Object p1) {
    return 'HRV $p0 ms, sotto la tua media ($p1 ms)';
  }

  @override
  String hrvMsSopraTua(Object p0) {
    return 'HRV $p0 ms, sopra la tua media';
  }

  @override
  String solitoBpmPiuBassa(Object p0) {
    return 'di solito $p0 bpm · più bassa è meglio';
  }

  @override
  String fcRiposoBpmPiu(Object p0, Object p1) {
    return 'FC a riposo $p0 bpm, più alta del solito ($p1)';
  }

  @override
  String get bene7H30 => 'bene da 7 h 30 in su, poco sotto le 6 h';

  @override
  String haiDormitoPoco(Object p0) {
    return 'Hai dormito poco ($p0)';
  }

  @override
  String haiDormitoBene(Object p0) {
    return 'Hai dormito bene ($p0)';
  }

  @override
  String kg(Object p0, Object p1) {
    return '$p0 a $p1 kg';
  }

  @override
  String kg2(Object p0, Object p1) {
    return '$p0 × $p1 kg';
  }

  @override
  String get tempo => 'Tempo';

  @override
  String get passo => 'Passo';

  @override
  String get battitoMedio => 'Battito medio';

  @override
  String get sollevati => 'Sollevati';

  @override
  String get calorie => 'Calorie';

  @override
  String get classica => 'Classica';

  @override
  String get mappa => 'Mappa';

  @override
  String get poster => 'Poster';

  @override
  String get kmKm => 'Km per km';

  @override
  String get salita => 'Salita';

  @override
  String get esercizi => 'Esercizi';

  @override
  String get muscoli => 'Muscoli';

  @override
  String get seduta => 'Seduta';

  @override
  String get tuaFoto => 'La tua foto';

  @override
  String kgPrimaKg(Object p0, Object p1, Object p2) {
    return '$p0 $p1 kg (prima $p2 kg)';
  }

  @override
  String get kgSollevatiTutto => 'kg sollevati in tutto';

  @override
  String get arrampicata => 'ARRAMPICATA';

  @override
  String get indoor => 'INDOOR';

  @override
  String get outdoor => 'OUTDOOR';

  @override
  String get gradoPiuAltoOggi => 'il grado più alto di oggi';

  @override
  String get blocchi => 'Blocchi';

  @override
  String get saliti => 'Saliti';

  @override
  String get attivita => 'Attività';

  @override
  String get altraAttivita => 'ALTRA ATTIVITÀ';

  @override
  String miaSettimana(Object p0) {
    return 'La mia settimana ($p0)';
  }

  @override
  String sedute(Object p0, Object p1) {
    return '$p0/$p1 sedute';
  }

  @override
  String get abbiamoAggiornatoRegole => 'Abbiamo aggiornato le regole';

  @override
  String get benvenutoAvidididadi => 'Benvenuto in Avidididadi';

  @override
  String get terminiInformativaSonoCambiati =>
      'Termini e informativa sono cambiati. Leggili e accettali per continuare.';

  @override
  String get primaIniziareEccoBreve =>
      'Prima di iniziare, ecco in breve come funziona l\'app con i tuoi dati.';

  @override
  String get datiRestanoSulTelefono => 'I dati restano sul telefono';

  @override
  String get nessunAccountNessunServer =>
      'Nessun account, nessun server, nessuna pubblicità.';

  @override
  String get healthConnectSoloLettura => 'Health Connect solo in lettura';

  @override
  String get allenamentiBattitoSonnoPercorsi =>
      'Allenamenti, battito, sonno e percorsi delle tue app (es. Garmin), solo se lo permetti.';

  @override
  String get gpsSoloDuranteCorsa => 'GPS solo durante corsa e bici';

  @override
  String get mentreTiAlleniApp =>
      'Mentre ti alleni con l\'app, con una notifica fissa. Mai in altri momenti.';

  @override
  String get mappeImmaginiInternet => 'Mappe e immagini da internet';

  @override
  String get openfreemapEsriSatelliteGithub =>
      'Da OpenFreeMap, Esri (satellite) e GitHub: il percorso non viene inviato.';

  @override
  String get assistenteFacoltativo => 'Assistente facoltativo';

  @override
  String get inviaRiassuntoDegliAllenamenti =>
      'Invia un riassunto degli allenamenti al servizio che scegli, solo se lo attivi tu.';

  @override
  String get nonConsiglioMedico => 'Non è un consiglio medico';

  @override
  String get pianiConsigliSonoStime =>
      'Piani e consigli sono stime: in caso di dubbi o problemi di salute, chiedi al medico.';

  @override
  String get terminiCondizioni => 'Termini e condizioni';

  @override
  String get informativaPrivacy => 'Informativa privacy';

  @override
  String get hoLettoAccettoTermini =>
      'Ho letto e accetto i Termini e condizioni e l\'Informativa sulla privacy';

  @override
  String get entra => 'Entra';

  @override
  String get nonAccettoEsci => 'Non accetto, esci';

  @override
  String get usaTuoAssistente => 'Usa il tuo assistente';

  @override
  String get parliCoachNellApp =>
      'Parli con il coach nell\'app del tuo assistente, con il tuo abbonamento (anche gratuito): nessuna chiave API.';

  @override
  String get avidididadiPreparaMessaggioTuoi =>
      'Avidididadi prepara un messaggio con i tuoi dati: lo mandi all\'assistente con Condividi.';

  @override
  String get parliAssistenteNellaSua =>
      'Parli con l\'assistente nella sua app, quanto vuoi.';

  @override
  String get quandoProponeModificheO =>
      'Quando propone modifiche o un piano nuovo, condividi la risposta con Avidididadi: vedi l\'anteprima e decidi tu.';

  @override
  String get qualeAppUsi => 'Quale app usi?';

  @override
  String get primaIniziare => 'Prima di iniziare';

  @override
  String get abbonamentoNormaleChatPossono =>
      'Con un abbonamento normale le chat possono servire ad addestrare il modello, secondo le impostazioni del tuo account. Nome, foto e percorsi GPS non vengono mai inviati.';

  @override
  String get includiEtaSessoAltezza => 'Includi età, sesso, altezza e peso';

  @override
  String get vediEsattamenteCosaViene => 'Vedi esattamente cosa viene inviato';

  @override
  String acconsentoInviareQuestiDati(Object p0) {
    return 'Acconsento a inviare questi dati a $p0 quando tocco Condividi o Copia';
  }

  @override
  String collega(Object p0) {
    return 'Collega $p0';
  }

  @override
  String get privacyUsoDeiDati => 'Privacy e uso dei dati';

  @override
  String get assistente => 'l\'assistente';

  @override
  String manda(Object p0) {
    return 'Manda a $p0';
  }

  @override
  String messaggioCopiatoIncollalo(Object p0) {
    return 'Messaggio copiato: incollalo in $p0.';
  }

  @override
  String appuntiSonoVuotiCopia(Object p0) {
    return 'Gli appunti sono vuoti: copia prima la risposta di $p0.';
  }

  @override
  String scollegare(Object p0) {
    return 'Scollegare $p0?';
  }

  @override
  String get torniAlCoachDentro =>
      'Torni al coach dentro l\'app (per esempio Ollama sul tuo PC). Le risposte della conversazione attuale non verranno più accettate: se ricolleghi, manda di nuovo i dati.';

  @override
  String get scollega => 'Scollega';

  @override
  String get rispostaNonUsabile => 'Risposta non usabile';

  @override
  String n1Parla(Object p0) {
    return '1 · Parla con $p0';
  }

  @override
  String get haiFattoAllenamentiNuovi =>
      'Hai fatto allenamenti nuovi? Manda i dati aggiornati nella stessa conversazione.';

  @override
  String mandaPrimoMessaggioIstruzioni(Object p0) {
    return 'Manda il primo messaggio: istruzioni da coach e i tuoi dati. Scegli $p0 dal menu Condividi.';
  }

  @override
  String ultimoInvio(Object p0, Object p1, Object p2) {
    return 'Ultimo invio: $p0, $p1:$p2';
  }

  @override
  String get mandaDatiAggiornati => 'Manda dati aggiornati';

  @override
  String inizia(Object p0) {
    return 'Inizia con $p0';
  }

  @override
  String get nuovaConversazione => 'Nuova conversazione';

  @override
  String get copiaInvece => 'Copia invece';

  @override
  String get n2PortaQuiModifiche => '2 · Porta qui le modifiche';

  @override
  String quandoProponeCambiarePiano(Object p0) {
    return 'Quando $p0 propone di cambiare il piano, nella sua risposta tocca Condividi e scegli Avidididadi. Oppure copiala e tocca qui sotto.';
  }

  @override
  String get incollaRisposta => 'Incolla la risposta';

  @override
  String get consiglioIstruzioniVoltaSola =>
      'Consiglio: le istruzioni una volta sola';

  @override
  String get incollaIstruzioniCoachProgetto =>
      'Incolla le istruzioni da coach in un Progetto di Claude, in un GPT personalizzato o in un Gem di Gemini. Poi ti basta mandare i dati aggiornati.';

  @override
  String get istruzioniCopiate => 'Istruzioni copiate.';

  @override
  String get copiaSoloIstruzioni => 'Copia solo le istruzioni';

  @override
  String scollega2(Object p0) {
    return 'Scollega $p0';
  }

  @override
  String get allenamentiArrampicata => 'Allenamenti di arrampicata';

  @override
  String get nuovo => 'Nuovo';

  @override
  String get ancoraNessunAllenamento => 'Ancora nessun allenamento';

  @override
  String get crealoNuovoOppureChiedilo =>
      'Crealo con \"Nuovo\", oppure chiedilo al tuo assistente (per esempio mandandogli lo screenshot di un\'altra app): nella sua risposta condividi il blocco con l\'app e qui trovi l\'allenamento, pronto da mettere nel calendario.';

  @override
  String get altri => 'Altri';

  @override
  String get giorno => 'In che giorno?';

  @override
  String nelCalendario(Object p0, Object p1) {
    return '$p0 è nel calendario: $p1.';
  }

  @override
  String get nonStatoPossibileScegli =>
      'Non è stato possibile: scegli oggi o un giorno dopo.';

  @override
  String eliminare(Object p0) {
    return 'Eliminare \"$p0\"?';
  }

  @override
  String get sparisceDallaRaccoltaSedute =>
      'Sparisce dalla raccolta. Le sedute già nel calendario restano.';

  @override
  String get elimina => 'Elimina';

  @override
  String get allenamentoNonTrovato => 'Allenamento non trovato.';

  @override
  String get modifica => 'Modifica';

  @override
  String get iniziaOra => 'Inizia ora';

  @override
  String get aggiungiAlPiano => 'Aggiungi al piano';

  @override
  String allaFineSegna(Object p0) {
    return 'Alla fine segna: $p0';
  }

  @override
  String get servonoNomeAlmenoEsercizio =>
      'Servono il nome e almeno un esercizio.';

  @override
  String get durataVa0300 => 'La durata va da 0 a 300 minuti.';

  @override
  String get nuovoAllenamento => 'Nuovo allenamento';

  @override
  String get salva => 'Salva';

  @override
  String get nome => 'Nome';

  @override
  String get es50507 => 'es. 50-50, 7:3s 40%';

  @override
  String get categoria => 'Categoria';

  @override
  String get dove => 'Dove';

  @override
  String get vuotoCalcoloDagliEsercizi => 'Vuoto = la calcolo dagli esercizi.';

  @override
  String get descrizione => 'Descrizione';

  @override
  String get cosaSegnareAllaFine => 'Cosa segnare alla fine';

  @override
  String get esGradoMedioDelle => 'es. il grado medio delle due parti';

  @override
  String get spostaSu => 'Sposta su';

  @override
  String get togli => 'Togli';

  @override
  String get aggiungiEsercizio => 'Aggiungi un esercizio';

  @override
  String get controllaNomeSerie1 =>
      'Controlla: nome, serie 1-20, ripetizioni 1-100, secondi 0-3600.';

  @override
  String get esercizio3 => 'Esercizio';

  @override
  String get esSospensioniVieBlocchi => 'es. Sospensioni, Vie, Blocchi';

  @override
  String get serie2 => 'Serie';

  @override
  String get ripetizioni => 'Ripetizioni';

  @override
  String get lavoro => 'Lavoro';

  @override
  String get pausa2 => 'Pausa';

  @override
  String get traSerie => 'Tra le serie';

  @override
  String get lavoroVuotoFincheNon =>
      'Lavoro vuoto = finché non hai finito (una via, un blocco): tocchi \"Fatto\". Pausa: tra una ripetizione e l\'altra.';

  @override
  String get intensitaOGrado => 'Intensità o grado';

  @override
  String get es406bFacile => 'es. 40%, 6b+, facile';

  @override
  String get note => 'Note';

  @override
  String get ok => 'OK';

  @override
  String get attivita2 => 'Che attività è?';

  @override
  String get nomeRestaSullaSessione =>
      'Il nome resta sulla sessione, nel calendario e nello storico.';

  @override
  String get esKayakPadelSci => 'Es. Kayak, Padel, Sci';

  @override
  String get registraPercorsoGps => 'Registra il percorso GPS';

  @override
  String get mappaDistanzaVelocitaAnche =>
      'Mappa, distanza e velocità, anche a schermo spento. Spento: solo tempo e battito.';

  @override
  String get inizia2 => 'Inizia';

  @override
  String get avanti => 'Avanti';

  @override
  String get datiCollegamenti => 'Dati e collegamenti';

  @override
  String get collegaOrologioOApp =>
      'Collega l\'orologio o le app che usi (Garmin, Freeletics…) tramite Health Connect: gli allenamenti fatti arrivano da soli.';

  @override
  String get paroleDellAllenamento => 'Le parole dell\'allenamento';

  @override
  String get concetti => 'Concetti';

  @override
  String get zoneComeTiDevi => 'Zone: come ti devi sentire';

  @override
  String zona(Object p0) {
    return 'Zona $p0';
  }

  @override
  String get tipiSeduta => 'Tipi di seduta';

  @override
  String prova(Object p0) {
    return ' · prova $p0';
  }

  @override
  String avidididadiVersione(Object p0, Object p1, Object p2) {
    return 'Avidididadi · versione $p0 ($p1)$p2';
  }

  @override
  String avidididadiVersioneBreve(Object p0) {
    return 'Avidididadi · versione $p0';
  }

  @override
  String get tuaArrampicata => 'La tua arrampicata';

  @override
  String get palestra => 'Palestra';

  @override
  String get falesiaOZona => 'Falesia o zona';

  @override
  String get facoltativo => 'Facoltativo';

  @override
  String get cosaHaiFatto => 'Cosa hai fatto';

  @override
  String get scegliVieOBoulder =>
      'Scegli vie o boulder: i gradi hanno due scale diverse.';

  @override
  String get gradoPiuDifficileChiuso => 'Grado più difficile chiuso';

  @override
  String nuovoRecordPrimaEra(Object p0) {
    return 'Nuovo record! Prima era $p0.';
  }

  @override
  String tuoRecord(Object p0, Object p1, Object p2, Object p3) {
    return 'Il tuo record: $p0 ($p1 $p2 $p3).';
  }

  @override
  String get alPrimoTentativoSenza =>
      'Al primo tentativo, senza sapere niente prima.';

  @override
  String get alPrimoTentativoSapendo =>
      'Al primo tentativo, sapendo già i movimenti.';

  @override
  String get chiusaDopoAverlaProvata => 'Chiusa dopo averla provata più volte.';

  @override
  String get comeHaiChiusaFacoltativo => 'Come l\'hai chiusa? (facoltativo)';

  @override
  String get vieChiuse2 => 'Vie chiuse';

  @override
  String get blocchiChiusi2 => 'Blocchi chiusi';

  @override
  String provatSenzaChiuderl(Object p0, Object p1) {
    return 'Provat$p0 senza chiuderl$p1';
  }

  @override
  String get altezzaMediaDelleVie => 'Altezza media delle vie (m)';

  @override
  String circaMetriSaliti(Object p0) {
    return 'Circa $p0 metri saliti.';
  }

  @override
  String get progettoGradoStaiProvando =>
      'Progetto (il grado che stai provando)';

  @override
  String get nessuno => 'Nessuno';

  @override
  String get meno => 'Meno';

  @override
  String get piu => 'Più';

  @override
  String get comAndataQuestaSettimana => 'Com\'è andata questa settimana?';

  @override
  String get giovediHoPocoTempo => 'Giovedì ho poco tempo: cosa sposto?';

  @override
  String get adattaProssimiGiorniAl =>
      'Adatta i prossimi giorni al mio recupero';

  @override
  String get sonoProntoGara => 'Sono pronto per la gara?';

  @override
  String collegato2(Object p0) {
    return 'Collegato a $p0';
  }

  @override
  String get impostazioniAssistente => 'Impostazioni assistente';

  @override
  String get chiedimiDeiTuoiAllenamenti =>
      'Chiedimi dei tuoi allenamenti: vedo le ultime 4 settimane, i feedback, il recupero e il piano dei prossimi 14 giorni. Se propongo di cambiare il piano, decidi tu se applicare.';

  @override
  String get stoPensando => 'Sto pensando…';

  @override
  String get scriviMessaggio => 'Scrivi un messaggio';

  @override
  String get invia => 'Invia';

  @override
  String get allenatoreCuiParlareDei =>
      'Un allenatore con cui parlare dei tuoi allenamenti, che può proporre modifiche al piano. Usi il modello che preferisci:';

  @override
  String get facoltativoSenzaAssistenteApp =>
      'È facoltativo: senza assistente l\'app funziona come sempre.';

  @override
  String get configuraAssistente => 'Configura assistente';

  @override
  String get modificheProposteAlPiano => 'Modifiche proposte al piano';

  @override
  String get applicateAlPiano => 'Applicate al piano.';

  @override
  String get nonApplicabili => 'Non applicabili';

  @override
  String get nienteApplicarePianoCambiato =>
      'Niente da applicare: il piano è cambiato nel frattempo.';

  @override
  String pianoAggiornatoModificheVedi(Object p0) {
    return 'Piano aggiornato: $p0 modifiche. Le vedi nel calendario.';
  }

  @override
  String applicaModifiche(Object p0) {
    return 'Applica $p0 modifiche';
  }

  @override
  String get nessunModelloDisponibileQuesta =>
      'Nessun modello disponibile con questa chiave.';

  @override
  String get consigliato => 'Consigliato';

  @override
  String get coachNellaSuaApp =>
      'Il coach è nella sua app. Scollega dalla pagina Coach per tornare al servizio qui sotto.';

  @override
  String get usaTuoAbbonamentoClaude =>
      'Usa il tuo abbonamento (Claude, ChatGPT, Gemini…)';

  @override
  String get senzaChiaveApiParli =>
      'Senza chiave API: parli con il coach nell\'app del tuo assistente.';

  @override
  String get coachNellAppQuando => 'Coach nell\'app (quando scolleghi)';

  @override
  String get servizio => 'Servizio';

  @override
  String get chiaveApi => 'Chiave API';

  @override
  String chiaveSalvata(Object p0) {
    return 'Chiave salvata ••••$p0';
  }

  @override
  String get cifrataSulTelefono => 'Cifrata sul telefono.';

  @override
  String get incollaChiaveApi => 'Incolla la chiave API';

  @override
  String get salvaChiave => 'Salva chiave';

  @override
  String get siPagaConsumoSul =>
      'Si paga a consumo sul tuo account: una domanda costa di solito pochi centesimi o meno. Puoi impostare un limite di spesa sul sito del servizio.';

  @override
  String get indirizzoOllama => 'Indirizzo di Ollama';

  @override
  String get indirizzoPc => 'Indirizzo del PC';

  @override
  String get sulPcInstallaOllama =>
      'Sul PC: installa Ollama, scarica un modello (ollama pull llama3.1) e avvialo con OLLAMA_HOST=0.0.0.0 così il telefono lo raggiunge. L\'indirizzo IP del PC lo trovi con \"ipconfig\".';

  @override
  String get modello => 'Modello';

  @override
  String get nomeModello => 'Nome del modello';

  @override
  String get vuotoPiuAdattoTra =>
      'Vuoto = il più adatto tra quelli disponibili';

  @override
  String get scegliTraModelliDisponibili => 'Scegli tra i modelli disponibili';

  @override
  String get datiInviati => 'Dati inviati';

  @override
  String get nomeFotoNonVengono => 'Nome e foto non vengono mai inviati.';

  @override
  String get acconsentoInviareQuestiDati2 =>
      'Acconsento a inviare questi dati al mio PC con Ollama';

  @override
  String acconsentoInviareQuestiDati3(Object p0) {
    return 'Acconsento a inviare questi dati a $p0 a ogni messaggio';
  }

  @override
  String nonRaggiungibile(Object p0) {
    return '$p0 non raggiungibile';
  }

  @override
  String verifica(Object p0) {
    return 'Verifica di $p0…';
  }

  @override
  String get provaConnessione2 => 'Prova connessione';

  @override
  String collegamento(Object p0) {
    return 'Collegamento a $p0…';
  }

  @override
  String get riprova => 'Riprova';

  @override
  String nonCollegato(Object p0) {
    return '$p0 non collegato';
  }

  @override
  String togliere(Object p0) {
    return 'Togliere $p0?';
  }

  @override
  String seduteFutureEsconoDal(Object p0) {
    return 'Le sedute future di $p0 escono dal calendario. Quelle già fatte restano nello storico.';
  }

  @override
  String get tueAttivitaSonoAggiornate => 'Le tue attività sono aggiornate.';

  @override
  String get mieAttivita => 'Le mie attività';

  @override
  String get nelPianoNeiMenu =>
      'Nel piano e nei menu vedi solo queste. Dal \"+\" puoi sempre fare anche altro, e tutto quello che fai resta nello storico.';

  @override
  String quando(Object p0) {
    return '$p0: quando?';
  }

  @override
  String get scegliGiorniAllenamentoDecidi =>
      'Scegli i giorni. L\'allenamento lo decidi tu, o lo chiedi all\'assistente: l\'app non ne scrive da sola.';

  @override
  String get scegliGiorniMettiamoSedute =>
      'Scegli i giorni: mettiamo le sedute nel calendario.';

  @override
  String get quantoDura => 'Quanto dura';

  @override
  String get nonOra => 'Non ora';

  @override
  String get mettiNelCalendario => 'Metti nel calendario';

  @override
  String get scriviAlmenoPeso => 'Scrivi almeno un peso';

  @override
  String get pesiDisponibili => 'Pesi disponibili';

  @override
  String get nessunPeso => 'Nessun peso';

  @override
  String letti(Object p0) {
    return 'Letti: $p0';
  }

  @override
  String get miaAttrezzatura => 'La mia attrezzatura';

  @override
  String corpoLiberoSempreIncluso(Object p0, Object p1) {
    return 'Il corpo libero è sempre incluso. Con questa attrezzatura puoi fare $p0 esercizi su $p1.';
  }

  @override
  String get palestra2 => 'In palestra';

  @override
  String get selezionaTutte => 'Seleziona tutte';

  @override
  String get salvaBackup => 'Salva il backup';

  @override
  String get backupSalvatoCopialoAnche =>
      'Backup salvato. Copialo anche fuori dal telefono (Drive, PC) per non perderlo.';

  @override
  String backupNonRiuscito(Object p0) {
    return 'Backup non riuscito: $p0';
  }

  @override
  String impossibileLeggereFile(Object p0) {
    return 'Impossibile leggere il file: $p0';
  }

  @override
  String get ripristinareBackup => 'Ripristinare il backup?';

  @override
  String tuttiDatiAttualiDell(Object p0) {
    return '$p0.\n\nTutti i dati attuali dell\'app verranno sostituiti. Se non sei sicuro, salva prima un backup di adesso.';
  }

  @override
  String get ripristina => 'Ripristina';

  @override
  String get datiRipristinatiAllaProssima =>
      'Dati ripristinati. Alla prossima sincronizzazione Health Connect rilegge lo storico.';

  @override
  String ripristinoNonRiuscito(Object p0) {
    return 'Ripristino non riuscito: $p0';
  }

  @override
  String get backupSalvatoNellaCartella => 'Backup salvato nella cartella.';

  @override
  String get backupAutomatico => 'Backup automatico';

  @override
  String get cartellaTelefono => 'una cartella del telefono';

  @override
  String ultimo(Object p0) {
    return ' · ultimo $p0';
  }

  @override
  String inTesto(Object p0, Object p1) {
    return 'In $p0$p1';
  }

  @override
  String cartellaScegliTuResta(Object p0) {
    return 'In una cartella che scegli tu: resta anche se disinstalli l\'app. Tiene gli ultimi $p0.';
  }

  @override
  String get ogniGiorno => 'Ogni giorno';

  @override
  String get ogniSettimana => 'Ogni settimana';

  @override
  String get siFaSoloQuando =>
      'Si fa da solo quando apri l\'app. Per non perderlo col telefono, ogni tanto copia la cartella sul PC o su Drive.';

  @override
  String get falloOra => 'Fallo ora';

  @override
  String get cambiaCartella => 'Cambia cartella';

  @override
  String get backup => 'Backup';

  @override
  String get unicoFileSessioniPiano =>
      'Un unico file con sessioni, piano, profilo, misure, feedback, recupero e foto. La chiave dell\'assistente non è inclusa.';

  @override
  String get salvaBackup2 => 'Salva backup';

  @override
  String get backupAttivoOraSi =>
      'Backup attivo: da ora si salva da solo ogni settimana.';

  @override
  String get mettiAlSicuroTuoi =>
      'Metti al sicuro i tuoi allenamenti: l\'app ne salva da sola una copia in una cartella che scegli tu. Resta anche se disinstalli l\'app.';

  @override
  String get scegliNuovoCartella => 'Scegli di nuovo la cartella';

  @override
  String get attivaBackup => 'Attiva il backup';

  @override
  String get battitoDalSensore => 'Battito dal sensore';

  @override
  String get fasciaCardioOOrologio =>
      'Una fascia cardio o un orologio che trasmette il battito via Bluetooth. Lo vedi durante l\'allenamento; alla fine si salvano media e massimo.';

  @override
  String get garminSullOrologioCerca =>
      'Garmin: sull\'orologio cerca \"Trasmetti frequenza cardiaca\" (di solito nei controlli, tenendo premuto il tasto della luce) e attivala: poi tocca \"Cerca\". Alcuni modelli vecchi la trasmettono solo in ANT+, che il telefono non legge.\nFascia cardio: indossala bagnando un po\' gli elettrodi, si accende da sola.\nUna volta scelto, il sensore si ricollega da solo a ogni allenamento.';

  @override
  String get sensoriBici => 'Sensori della bici';

  @override
  String get rulliSmartTacxWahoo =>
      'Rulli smart (Tacx, Wahoo, Elite…), misuratore di potenza o sensore di velocità e cadenza, via Bluetooth. Alla fine si salvano potenza e cadenza medie.';

  @override
  String get rulliAccendiliSmettiUsarli =>
      'Rulli: accendili e smetti di usarli con altre app (Zwift, Tacx), perché molti si collegano a una sola app per volta.\nSensore di velocità o di cadenza: si sveglia girando la ruota o i pedali.\nLa circonferenza della ruota serve solo al sensore di velocità: la trovi scritta sul copertone (es. 700×25C = 2105 mm).';

  @override
  String get servePermessoDispositiviNelle =>
      'Serve il permesso \"Dispositivi nelle vicinanze\".';

  @override
  String get apriImpostazioni => 'Apri le impostazioni';

  @override
  String get bluetoothSpentoAccendiloRiprova =>
      'Il Bluetooth è spento: accendilo e riprova.';

  @override
  String collegato3(Object p0) {
    return 'Collegato · $p0';
  }

  @override
  String get collegatoAspettoDati => 'Collegato, aspetto i dati…';

  @override
  String get miCollegoDevEssere => 'Mi collego… (dev\'essere acceso e vicino)';

  @override
  String get nonCollegato2 => 'Non collegato';

  @override
  String get dimentica => 'Dimentica';

  @override
  String get cercoSensoriVicini => 'Cerco i sensori vicini…';

  @override
  String get sensoriTrovati => 'Sensori trovati';

  @override
  String get nessunSensoreTrovato => 'Nessun sensore trovato.';

  @override
  String get cercaAltroSensore => 'Cerca un altro sensore';

  @override
  String get cercaNuovo => 'Cerca di nuovo';

  @override
  String get comeSiCollega => 'Come si collega';

  @override
  String get segnaleForte => 'Segnale forte';

  @override
  String get segnaleMedio => 'Segnale medio';

  @override
  String get segnaleDebole => 'Segnale debole';

  @override
  String adessoKmH(Object p0) {
    return ' Adesso: $p0 km/h.';
  }

  @override
  String get maiFattaQui => 'Mai fatta da qui.';

  @override
  String ultima(Object p0) {
    return 'Ultima: $p0.';
  }

  @override
  String tienePrecisiWattFalla(Object p0) {
    return '$p0 Tiene precisi i watt: falla ogni due settimane circa e quando sposti il rullo, meglio dopo 10 minuti di pedalata.';
  }

  @override
  String get chiedoAlRulloIniziare => 'Chiedo al rullo di iniziare…';

  @override
  String pedalaAcceleraFincheRullo(Object p0) {
    return 'Pedala e accelera finché il rullo non ti dice di smettere.$p0';
  }

  @override
  String acceleraFinoSuperareKm(Object p0, Object p1) {
    return 'Accelera fino a superare $p0 km/h.$p1';
  }

  @override
  String smettiPedalareAspettaRullo(Object p0) {
    return 'Smetti di pedalare e aspetta che il rullo si fermi.$p0';
  }

  @override
  String get calibrazioneRiuscita => 'Calibrazione riuscita.';

  @override
  String get nonRiuscitaControllaNessun =>
      'Non è riuscita. Controlla che nessun\'altra app usi il rullo e riprova.';

  @override
  String get calibraRullo => 'Calibra il rullo';

  @override
  String get iniziaCalibrazione => 'Inizia la calibrazione';

  @override
  String get circonferenzaRuota => 'Circonferenza della ruota';

  @override
  String get soloSensoreVelocita700 =>
      'Solo per il sensore di velocità. 700×25C: 2105 mm.';

  @override
  String get tuoPianoProntoPrima =>
      'Il tuo piano è pronto! La prima seduta è qui, in \"Oggi\". Giorni e durata li cambi quando vuoi dal Profilo.';

  @override
  String get tuoPianoProntoOggi =>
      'Il tuo piano è pronto! In \"Oggi\" trovi cosa fare ogni giorno.';

  @override
  String get indietro => 'Indietro';

  @override
  String get comeTiChiami => 'Come ti chiami?';

  @override
  String get cosiAppTiSaluta => 'Così l\'app ti saluta per nome.';

  @override
  String get tuoNome => 'Il tuo nome';

  @override
  String get cosaTiPiacerebbeFare => 'Cosa ti piacerebbe fare?';

  @override
  String get puoiScegliernePiuUno =>
      'Puoi sceglierne più di uno. Con \"Inizia oggi\" parti con 3 sedute da 30 minuti a settimana (lunedì, mercoledì e venerdì), adatte a chi comincia, e la prima è già oggi. Potrai cambiare tutto quando vuoi.';

  @override
  String get quantoTempoHai => 'Quanto tempo hai?';

  @override
  String get meglioPocoMaCostanza =>
      'Meglio poco ma con costanza: per iniziare 3 giorni da 30 minuti sono perfetti.';

  @override
  String get giorniSettimana => 'Giorni a settimana';

  @override
  String get minutiOgniVolta => 'Minuti ogni volta';

  @override
  String giorniNonCSpazio(Object p0, Object p1) {
    return 'Con $p0 giorni non c\'è spazio per tutti gli sport scelti: ne userò $p1.';
  }

  @override
  String get quantoTiAlleniSolito => 'Quanto ti alleni di solito?';

  @override
  String get rispondiSinceramentePianoParte =>
      'Rispondi sinceramente: il piano parte dal tuo livello e cresce insieme a te.';

  @override
  String get iniziaOggi => 'Inizia oggi';

  @override
  String get primaScelgoGiorniDurata => 'Prima scelgo giorni, durata e livello';

  @override
  String get creaMioPiano => 'Crea il mio piano';

  @override
  String get scegliAlmenoUnoSport => 'Scegli almeno uno sport';

  @override
  String get benvenuto => 'Benvenuto!';

  @override
  String get tiPreparoPianoAllenamento =>
      'Ti preparo un piano di allenamento su misura, anche se non ti sei mai allenato. Ogni giorno ti dico cosa fare, passo passo, e il piano si adatta a come ti senti.';

  @override
  String get scegliTuoiSportParti => 'Scegli i tuoi sport e parti subito.';

  @override
  String get iniziamo => 'Iniziamo';

  @override
  String get saltaPreferiscoFareSolo => 'Salta, preferisco fare da solo';

  @override
  String get haiOrologioSportivo => 'Hai un orologio sportivo?';

  @override
  String get vaBeneAncheSenza =>
      'Va bene anche senza: l\'app funziona con il solo telefono.';

  @override
  String get noSoloTelefono => 'No, solo il telefono';

  @override
  String get nienteOrologioFasciaCardio =>
      'Niente orologio, fascia cardio o altre app.';

  @override
  String get siOrologioOFascia => 'Sì, un orologio o una fascia';

  @override
  String get garminPolarSuuntoCoros => 'Garmin, Polar, Suunto, Coros, Wahoo…';

  @override
  String get corsaCamminataBiciRegistra =>
      'Corsa, camminata e bici le registra il telefono con il GPS, e ti guida a voce passo passo.';

  @override
  String get zoneEsempioZona2 =>
      'Le zone (per esempio \"zona 2\") seguile a sensazione: in zona 2 riesci ancora a parlare.';

  @override
  String get dopoOgniSedutaRispondi =>
      'Dopo ogni seduta rispondi a \"Com\'è andata?\": è così che il piano capisce la fatica e si adatta.';

  @override
  String get nuotoSenzaOrologioSegni =>
      'Il nuoto, senza orologio, lo segni a mano dopo la vasca.';

  @override
  String get energiaSonnoRestanoVuoti =>
      'Energia e sonno restano vuoti: servono i dati di un orologio.';

  @override
  String get dopoCollegaloProfiloDati =>
      'Dopo collegalo da Profilo → Dati e collegamenti: con Health Connect, o con intervals.icu per Garmin e gli altri. Le attività arrivano da sole, con battito e sonno.';

  @override
  String get haiRulloSmartCollegalo =>
      'Hai un rullo smart? Collegalo durante l\'allenamento: l\'app gli manda i watt di ogni passo.';

  @override
  String get eccoTuaSettimana => 'Ecco la tua settimana';

  @override
  String eccoTuaSettimana2(Object p0) {
    return 'Ecco la tua settimana, $p0';
  }

  @override
  String get ogniGiornoNellaPagina =>
      'Ogni giorno, nella pagina \"Oggi\", trovi cosa fare. Potrai cambiare giorni e orari quando vuoi.';

  @override
  String minuti(Object p0, Object p1) {
    return '$p0 · $p1 minuti';
  }

  @override
  String get cosHaiFatto => 'Cos\'hai fatto?';

  @override
  String get poiScriviDurataTutto =>
      'Poi scrivi durata e tutto quello che ti ricordi.';

  @override
  String get ciao => 'Ciao!';

  @override
  String ciao2(Object p0) {
    return 'Ciao $p0';
  }

  @override
  String get chiudiMese => 'Chiudi il mese';

  @override
  String get vediTuttoMese => 'Vedi tutto il mese';

  @override
  String get prossimi => 'Prossimi';

  @override
  String get tuoPiano => 'Il tuo piano';

  @override
  String get cambiaAllenamentiOggi => 'Cambia gli allenamenti di oggi';

  @override
  String cambiaAllenamenti(Object p0) {
    return 'Cambia gli allenamenti di $p0';
  }

  @override
  String get spostaAggiungiOTogli =>
      'Sposta, aggiungi o togli: solo per quel giorno';

  @override
  String get scriviAttivitaFattaOggi => 'Scrivi un\'attività fatta oggi';

  @override
  String scriviAttivitaFatta(Object p0) {
    return 'Scrivi un\'attività fatta $p0';
  }

  @override
  String get quelloNonHaiRegistrato =>
      'Per quello che non hai registrato: durata, distanza, battito…';

  @override
  String get miaSettimanaTipo => 'La mia settimana tipo';

  @override
  String get qualiGiorniTiAlleni => 'Quali giorni ti alleni e per quanto tempo';

  @override
  String get allungaCalendario => 'Allunga il calendario';

  @override
  String get ripeteSettimanaTipoNei =>
      'Ripete la settimana tipo nei prossimi mesi: decide i giorni, non gli esercizi';

  @override
  String get mesePrima => 'Mese prima';

  @override
  String get meseDopo => 'Mese dopo';

  @override
  String get fare => 'da fare';

  @override
  String get toccaGiornoVederloTienilo =>
      'Tocca un giorno per vederlo, tienilo premuto per cambiarlo.';

  @override
  String get buona => 'Buona';

  @override
  String get normale => 'Normale';

  @override
  String get bassa => 'Bassa';

  @override
  String energia(Object p0) {
    return 'Energia $p0';
  }

  @override
  String get tuaSettimana => 'La tua settimana';

  @override
  String settimanaDal2(Object p0, Object p1) {
    return 'Settimana dal $p0 $p1';
  }

  @override
  String fatti(Object p0) {
    return ' di $p0 fatti';
  }

  @override
  String settimanaCompletataAllenamenti(Object p0) {
    return 'Settimana completata: $p0 allenamenti!';
  }

  @override
  String get tornaOggi => 'Torna a oggi';

  @override
  String get oggiSeiPocoRecuperato =>
      'Oggi sei poco recuperato: al posto della seduta prevista puoi fare 20 minuti di mobilità.';

  @override
  String get vediAllenamento => 'Vedi l\'allenamento';

  @override
  String get primaGuardaEsercizi => 'Prima guarda gli esercizi';

  @override
  String get giornoRiposo => 'Giorno di riposo';

  @override
  String get quelGiornoNonRisultano => 'Quel giorno non risultano allenamenti.';

  @override
  String get riposoFaParteDell =>
      'Il riposo fa parte dell\'allenamento: i muscoli si rinforzano mentre recuperi.';

  @override
  String get seTiVa15 => 'Se ti va: 15 minuti di mobilità';

  @override
  String get voglioAllenarmiStesso => 'Voglio allenarmi lo stesso';

  @override
  String get nonFatto => 'non fatto';

  @override
  String fatica10(Object p0) {
    return 'Fatica $p0/10';
  }

  @override
  String get comAndata => 'Com\'è andata?';

  @override
  String get rigenerarePiano => 'Rigenerare il piano?';

  @override
  String sessioniDalPoiVerranno(Object p0) {
    return 'Le sessioni dal $p0 in poi verranno sostituite. Quelle precedenti restano invariate.';
  }

  @override
  String get rigenera => 'Rigenera';

  @override
  String get pianoGenerato => 'Piano generato';

  @override
  String get ripeteTuaSettimanaTipo =>
      'Ripete la tua settimana tipo (quali sport, che giorni, quanti minuti) sui mesi che scegli. Gli esercizi di ogni seduta si preparano dal Profilo, con \"Prepara le sedute\".';

  @override
  String durata2(Object p0, Object p1) {
    return 'Durata: $p0 $p1';
  }

  @override
  String parti(Object p0) {
    return 'Parti da $p0';
  }

  @override
  String modifica2(Object p0) {
    return 'Modifica $p0';
  }

  @override
  String get cambiaSoloQuestoGiorno =>
      'Cambia solo questo giorno: le altre settimane restano come sono.';

  @override
  String get nessunaAttivitaProgrammaGiorno =>
      'Nessuna attività in programma (giorno di riposo).';

  @override
  String min3(Object p0, Object p1) {
    return '$p0, $p1 min';
  }

  @override
  String get rimuovi => 'Rimuovi';

  @override
  String get aggiungiAttivita => 'Aggiungi attività';

  @override
  String get comAndataVotoAlla =>
      'Com\'è andata? Un voto alla fatica rende il piano più preciso.';

  @override
  String get calendarioVuotoAllungaloSapere =>
      'Il calendario è vuoto: allungalo per sapere cosa fare ogni giorno.';

  @override
  String calendarioFinitoAllungaloProssimi(Object p0) {
    return 'Il calendario è finito il $p0. Allungalo per i prossimi mesi.';
  }

  @override
  String traGiorni(Object p0) {
    return 'tra $p0 giorni';
  }

  @override
  String calendarioFinisceVuoiAllungarlo(Object p0, Object p1) {
    return 'Il calendario finisce $p0 ($p1). Vuoi allungarlo?';
  }

  @override
  String get allunga => 'Allunga';

  @override
  String get piuTardi => 'Più tardi';

  @override
  String scheda(Object p0) {
    return 'La scheda di $p0';
  }

  @override
  String scheda2(Object p0) {
    return 'La scheda \"$p0\"';
  }

  @override
  String finitaIntantoSeduteSono(Object p0, Object p1) {
    return '$p0 è finita il $p1. Intanto le sedute sono quelle preparate dall\'app.';
  }

  @override
  String rinnovaGiorni(Object p0) {
    return 'Rinnova per $p0 giorni';
  }

  @override
  String get cambiala => 'Cambiala';

  @override
  String get usaQuellaDellApp => 'Usa quella dell\'app';

  @override
  String get cosaVuoiFareAdesso => 'Cosa vuoi fare adesso?';

  @override
  String get siAggiungeQuelloC =>
      'Si aggiunge a quello che c\'è in programma oggi.';

  @override
  String get iniziaAttivitaLibera => 'Inizia un\'attività libera';

  @override
  String get catalogoEsercizi => 'Catalogo esercizi';

  @override
  String get toccaEsercizioVedereMuscoli =>
      'Tocca un esercizio per vedere i muscoli che allena.';

  @override
  String get cercaNomeOMuscolo => 'Cerca per nome o muscolo';

  @override
  String get tutti => 'Tutti';

  @override
  String get soloMiaAttrezzatura => 'Solo con la mia attrezzatura';

  @override
  String get nessunEsercizioQuestiFiltri =>
      'Nessun esercizio con questi filtri.';

  @override
  String serve(Object p0) {
    return 'Serve: $p0';
  }

  @override
  String get immaginiIstruzioni => 'Immagini e istruzioni';

  @override
  String principali(Object p0) {
    return 'Principali: $p0';
  }

  @override
  String secondari(Object p0) {
    return 'Secondari: $p0';
  }

  @override
  String get comeSiEsegue => 'Come si esegue';

  @override
  String immaginiFreeExerciseDb(Object p0) {
    return 'Immagini da free-exercise-db ($p0).';
  }

  @override
  String get tueSerie => 'Le tue serie';

  @override
  String recordKg(Object p0, Object p1) {
    return 'Record: $p0 kg × $p1';
  }

  @override
  String recordRipetizioni(Object p0) {
    return 'Record: $p0 ripetizioni';
  }

  @override
  String get condividi => 'Condividi';

  @override
  String get mappaNonProntaRiprova => 'La mappa non è pronta: riprova.';

  @override
  String get immagineNonRiuscitaRiprova => 'Immagine non riuscita: riprova.';

  @override
  String get immagineSiCreaSul =>
      'L\'immagine si crea sul telefono e va solo all\'app che scegli (WhatsApp, Instagram…).';

  @override
  String get condividiSessione => 'Condividi la sessione';

  @override
  String get grafica => 'Grafica';

  @override
  String get tipoMappa => 'Tipo di mappa';

  @override
  String get mappaFaVedereDove =>
      'La mappa fa vedere dove sei passato: occhio se parti da casa.';

  @override
  String get scegliAltraFoto => 'Scegli un\'altra foto';

  @override
  String get spostaIngrandisciFotoDue =>
      'Sposta e ingrandisci la foto con due dita. Resta sul telefono: nell\'immagine non va la posizione in cui è stata scattata.';

  @override
  String get mostraPercorso => 'Mostra il percorso';

  @override
  String get faVedereFormaGiro =>
      'Fa vedere la forma del giro: occhio se parti da casa.';

  @override
  String nuovoRecord(Object p0) {
    return 'Nuovo record: $p0';
  }

  @override
  String get passoMedio => 'Passo medio';

  @override
  String get kmPiuVeloce => 'Km più veloce';

  @override
  String get mSalita => 'm di salita';

  @override
  String get quotaMassima => 'quota massima';

  @override
  String get passoOgni100M => 'PASSO OGNI 100 m';

  @override
  String get n100PiuVeloce => '100 più veloce';

  @override
  String get gradoPiuAlto => 'grado più alto';

  @override
  String gradoPiuAlto2(Object p0) {
    return 'grado più alto · $p0';
  }

  @override
  String get primaSedutaQuiSi => 'La prima seduta: da qui si sale';

  @override
  String gradoPiuAltoDelle(Object p0) {
    return 'Il grado più alto delle ultime $p0 sedute';
  }

  @override
  String get progetto2 => 'Progetto';

  @override
  String get condividiSettimana => 'Condividi la settimana';

  @override
  String get settimanaPrima => 'Settimana prima';

  @override
  String get questaSettimana => 'Questa settimana';

  @override
  String get settimanaDopo => 'Settimana dopo';

  @override
  String settimana(Object p0) {
    return 'Settimana $p0';
  }

  @override
  String get nessunaSessioneQuestaSettimana =>
      'Nessuna sessione in questa settimana.';

  @override
  String get eserciziSceltiTeTua =>
      'Esercizi scelti per te e la tua attrezzatura, con serie, ripetizioni e pesi. Finisce sempre con un po\' di mobilità.';

  @override
  String get corseFaciliSedutaPiu =>
      'Corse facili, una seduta più intensa (fartlek, tempo, ripetute) e il lungo che cresce verso la gara.';

  @override
  String get tecnicaSerieAlTuo =>
      'Tecnica e serie al tuo ritmo, alternate a quelle più intense.';

  @override
  String get usciteFaciliIntervalliUscita =>
      'Uscite facili, intervalli e uscita lunga.';

  @override
  String get stretchingMovimentiLentiTempo =>
      'Stretching e movimenti lenti, a tempo: ogni volta una zona del corpo diversa. Ottima anche per recuperare.';

  @override
  String seduteRestanoNelCalendario(Object p0) {
    return 'Le sedute di $p0 restano nel calendario, ma senza esercizi preparati. Quelle già fatte non cambiano.';
  }

  @override
  String get sedutePreparateTolte => 'Sedute preparate tolte.';

  @override
  String pronteSeduteTroviOggi(Object p0, Object p1) {
    return 'Pronte $p0 sedute di $p1. Le trovi in Oggi.';
  }

  @override
  String get forzaComeVuoi => 'Forza: come la vuoi';

  @override
  String get obiettivo => 'Obiettivo';

  @override
  String get livello => 'Livello';

  @override
  String get nonPreoccupartiSbagliareLivello =>
      'Non preoccuparti di sbagliare: il livello si adatta ai voti che dai a fine seduta.';

  @override
  String get attrezzatura => 'Attrezzatura';

  @override
  String get soloCorpoLibero => 'Solo corpo libero';

  @override
  String comeCrescere(Object p0) {
    return '$p0: come crescere';
  }

  @override
  String get sedutaLungaCosaFare => 'Seduta lunga, e cosa fare se è facile';

  @override
  String get sedutaLunga => 'Seduta lunga';

  @override
  String get ultimaCorsaOUscita =>
      'L\'ultima corsa o uscita in bici della settimana dura di più e cresce col tempo. Spenta, durano tutte quanto hai scelto.';

  @override
  String get preparaSedute => 'Prepara le sedute';

  @override
  String get scegliQualiSportVuoi =>
      'Scegli per quali sport vuoi che l\'app scriva gli allenamenti passo passo. Prepara solo quelli che spunti.';

  @override
  String get qualiSport => 'Per quali sport?';

  @override
  String get giaPreparato => 'già preparato';

  @override
  String settimana2(Object p0, Object p1) {
    return '$p0 $p1 a settimana';
  }

  @override
  String calendario(Object p0, Object p1) {
    return '$p0 $p1 in calendario';
  }

  @override
  String get nessunaSedutaCalendario => 'nessuna seduta in calendario';

  @override
  String get cambiaGiorniMinutiSettimana =>
      'Cambia giorni e minuti (settimana tipo)';

  @override
  String get tuePreferenze => 'Le tue preferenze';

  @override
  String get senzaGaraSeduteCrescono =>
      'Senza una gara le sedute crescono a blocchi di 4 settimane, con una più leggera. Puoi fissare una gara dal Profilo, alla voce Il mio obiettivo.';

  @override
  String seduteCambianoAvvicinarsiGara(Object p0) {
    return '$p0: le sedute cambiano con l\'avvicinarsi della gara.';
  }

  @override
  String nessunGiornoNelCalendario(Object p0) {
    return '$p0: nessun giorno nel calendario';
  }

  @override
  String get nellaSettimanaTipoMa =>
      'È nella settimana tipo ma non ancora nel calendario. Apri la settimana tipo e tocca \"Porta tutta la settimana nel calendario\".';

  @override
  String get calendarioVuoto => 'Il calendario è vuoto';

  @override
  String get primaAllungaCalendarioPoi =>
      'Prima allunga il calendario: poi le sedute si riempiono.';

  @override
  String seduteSiPreparanoFino(Object p0) {
    return 'Le sedute si preparano fino a $p0; quando allunghi il calendario si aggiungono da sole.';
  }

  @override
  String get togliSedutePreparate => 'Togli le sedute preparate';

  @override
  String get aggiornaSedute => 'Aggiorna le sedute';

  @override
  String prepara(Object p0) {
    return 'Prepara $p0';
  }

  @override
  String get dataNascita => 'Data di nascita';

  @override
  String get altezzaCmTra50 => 'Altezza in cm, tra 50 e 250';

  @override
  String get pesoKgTra20 => 'Peso in kg, tra 20 e 300';

  @override
  String get datiPersonali => 'Dati personali';

  @override
  String get cognome => 'Cognome';

  @override
  String get toccaSceglierla => 'Tocca per sceglierla';

  @override
  String get altezza => 'Altezza';

  @override
  String get peso => 'Peso';

  @override
  String get pesoNuovoSiRegistra =>
      'Un peso nuovo si registra con la data di oggi.';

  @override
  String get ok2 => 'Ok';

  @override
  String mancano(Object p0) {
    return ' Mancano $p0.';
  }

  @override
  String get pausa3 => 'In pausa.';

  @override
  String get siRiparte => 'Si riparte.';

  @override
  String chilometri(Object p0) {
    return ', $p0 chilometri';
  }

  @override
  String allenamentoCompletato(Object p0, Object p1) {
    return 'Allenamento completato. $p0$p1.';
  }

  @override
  String get interrompereAllenamento => 'Interrompere l\'allenamento?';

  @override
  String get puoiTerminarloQuiVedere =>
      'Puoi terminarlo qui e vedere il riepilogo, oppure uscire senza salvare.';

  @override
  String get esci => 'Esci';

  @override
  String get terminaQui => 'Termina qui';

  @override
  String get continua => 'Continua';

  @override
  String get questoAllenamentoNonHa => 'Questo allenamento non ha passi.';

  @override
  String get tempoTotale => 'tempo totale';

  @override
  String get bipVibrazione => 'Bip e vibrazione';

  @override
  String get cadenza => 'Cadenza';

  @override
  String get poi => 'Poi';

  @override
  String get esercizioPrecedente => 'Esercizio precedente';

  @override
  String get iniziaSubito => 'Inizia subito';

  @override
  String get saltaRecupero => 'Salta recupero';

  @override
  String get fatto => 'Fatto';

  @override
  String get n15SecondiPiu => '15 secondi in più';

  @override
  String get salta => 'Salta';

  @override
  String get partiQuandoVuoi => 'Parti quando vuoi';

  @override
  String get preparati => 'Preparati';

  @override
  String esercizi2(Object p0, Object p1) {
    return '$p0 · $p1 esercizi';
  }

  @override
  String siParte(Object p0) {
    return 'Si parte con: $p0';
  }

  @override
  String indoor2(Object p0) {
    return 'Indoor ($p0)';
  }

  @override
  String get senzaGpsVelocitaKm =>
      'Senza GPS: velocità e km arrivano dal rullo.';

  @override
  String get senzaGpsAllaFine =>
      'Senza GPS: alla fine scrivi i km del display.';

  @override
  String get seguiPercorso => 'Segui un percorso';

  @override
  String get facoltativoGpxMappaIndicazioni =>
      'Facoltativo: un GPX con mappa e indicazioni a voce';

  @override
  String get togliPercorso => 'Togli il percorso';

  @override
  String get rulloSensori => 'Rullo e sensori';

  @override
  String get sensoriBici2 => 'Sensori bici';

  @override
  String get collegatoOraCalibrarlo => 'Collegato · è ora di calibrarlo';

  @override
  String get toccaCollegare => 'Tocca per collegare';

  @override
  String get battito => 'Battito';

  @override
  String get allenamentoCompletato2 => 'Allenamento completato!';

  @override
  String movimentoTotale(Object p0, Object p1) {
    return 'In movimento $p0 · totale $p1';
  }

  @override
  String battitoMedioBpmMassimo(Object p0, Object p1) {
    return 'Battito medio $p0 bpm · massimo $p1';
  }

  @override
  String potenzaMediaW(Object p0) {
    return 'Potenza media $p0 W';
  }

  @override
  String cadenzaRpm(Object p0) {
    return 'cadenza $p0 rpm';
  }

  @override
  String cadenzaMediaRpm(Object p0) {
    return 'Cadenza media $p0 rpm';
  }

  @override
  String circaKcal(Object p0) {
    return 'Circa $p0 kcal';
  }

  @override
  String km(Object p0) {
    return 'Km $p0';
  }

  @override
  String km2(Object p0) {
    return 'Km del $p0';
  }

  @override
  String get kmPercorsi => 'Km percorsi';

  @override
  String get facoltativoSenzaSessioneResta =>
      'Facoltativo: senza, la sessione resta senza distanza.';

  @override
  String get segnaComeFatto => 'Segna come fatto';

  @override
  String get seOrologioRegistraStesso =>
      'Se l\'orologio registra lo stesso allenamento, vale il suo.';

  @override
  String get inserisciDatiMano => 'Inserisci i dati a mano';

  @override
  String segnaleGpsBuonoM(Object p0) {
    return 'Segnale GPS buono · ±$p0 m';
  }

  @override
  String get cercoSegnaleGpsMeglio =>
      'Cerco il segnale GPS… meglio all\'aperto';

  @override
  String get gpsNonPermessoTocca => 'GPS non permesso: tocca per attivarlo';

  @override
  String get posizioneSpentaToccaAccenderla =>
      'Posizione spenta: tocca per accenderla';

  @override
  String get dati => 'Dati';

  @override
  String get ultimoKm => 'Ultimo km';

  @override
  String ultimiKm(Object p0) {
    return 'Ultimi $p0 km';
  }

  @override
  String get velocitaMedia => 'Velocità media';

  @override
  String potenzaZ(Object p0) {
    return 'Potenza · Z$p0';
  }

  @override
  String battitoZ(Object p0) {
    return 'Battito · Z$p0';
  }

  @override
  String get miCollego => 'Mi collego…';

  @override
  String kmUltimi(Object p0, Object p1, Object p2) {
    return 'Km $p0 · ultimi $p1 in $p2';
  }

  @override
  String mancanoSecondi(Object p0) {
    return 'Mancano $p0 secondi';
  }

  @override
  String get tempoTrascorso => 'Tempo trascorso';

  @override
  String get pausa4 => 'in pausa';

  @override
  String get poiPassaSolo => 'poi passa da solo';

  @override
  String get toccaFattoQuandoHai2 => 'tocca Fatto quando hai finito';

  @override
  String guardaMovimento(Object p0) {
    return 'Guarda il movimento di $p0';
  }

  @override
  String get kg3 => 'Kg';

  @override
  String ultimaVolta(Object p0) {
    return 'Ultima volta: $p0';
  }

  @override
  String get aveviFattoTutteRipetizioni =>
      'Avevi fatto tutte le ripetizioni: prova un peso in più.';

  @override
  String meno2(Object p0) {
    return '$p0: meno';
  }

  @override
  String piu2(Object p0) {
    return '$p0: più';
  }

  @override
  String get nessunPeso2 => 'nessun peso';

  @override
  String get pesiDiversiDallaScheda => 'Pesi diversi dalla scheda';

  @override
  String get scrittiNellaScheda => 'Scritti nella scheda.';

  @override
  String get aggiornaScheda => 'Aggiorna la scheda';

  @override
  String get segnaVieBlocchiGradi => 'Segna vie, blocchi e gradi';

  @override
  String get moltoLeggera => 'molto leggera';

  @override
  String get moltoDura => 'molto dura';

  @override
  String get alMassimo => 'al massimo';

  @override
  String get feedbackSalvato2 => 'Feedback salvato';

  @override
  String fatica102(Object p0, Object p1) {
    return 'Fatica: $p0/10, $p1';
  }

  @override
  String tuoObiettivoFaticaGiusta(Object p0) {
    return 'Per il tuo obiettivo la fatica giusta è circa $p0/10.';
  }

  @override
  String get comeQuesta => 'come questa';

  @override
  String sedutaFaticaPrevistaCirca(Object p0, Object p1) {
    return 'Per una seduta $p0 la fatica prevista è circa $p1/10.';
  }

  @override
  String get hoCompletatoTutteSerie => 'Ho completato tutte le serie';

  @override
  String get hoFattoTuttaSeduta => 'Ho fatto tutta la seduta';

  @override
  String passoNellaPartePrincipale(Object p0, Object p1) {
    return 'Il passo nella parte principale (obiettivo $p0:$p1/100 m)';
  }

  @override
  String get oppurePassoHaiTenuto =>
      'Oppure il passo che hai tenuto (es. 2:45)';

  @override
  String get hoSentitoDoloreO => 'Ho sentito dolore o fastidio';

  @override
  String get noteFacoltative => 'Note (facoltative)';

  @override
  String grafici(Object p0) {
    return 'Grafici · $p0';
  }

  @override
  String get questaAttivitaNonCi =>
      'Per questa attività non ci sono dati nel tempo: servono il battito o la velocità registrati dall\'orologio.';

  @override
  String get altitudine => 'Altitudine';

  @override
  String get minima => 'Minima';

  @override
  String get massima => 'Massima';

  @override
  String get pendenza => 'Pendenza';

  @override
  String get salitaMassima => 'Salita massima';

  @override
  String get discesaMassima => 'Discesa massima';

  @override
  String get ftpCorsaStimataEta =>
      'FTP di corsa stimata da età e peso: per averla precisa fai il test in Profilo → Le mie zone.';

  @override
  String get zoneServeTuoPeso =>
      'Per le zone serve il tuo peso (Profilo), oppure l\'FTP di corsa in Profilo → Le mie zone.';

  @override
  String get passiAlMinuto => 'Passi al minuto';

  @override
  String get media => 'Media';

  @override
  String get bracciateAlMinuto => 'Bracciate al minuto';

  @override
  String get alMinuto => 'al minuto';

  @override
  String get tempoNelleZone => 'Tempo nelle zone';

  @override
  String zoneCalcolateSullaTua(Object p0) {
    return 'Zone calcolate sulla tua FC massima ($p0 bpm).';
  }

  @override
  String get migliore => 'Migliore';

  @override
  String tuaFtpCorsaW(Object p0) {
    return 'La tua FTP di corsa: $p0 W';
  }

  @override
  String get n95DeiTuoiMigliori =>
      'È il 95% dei tuoi migliori 20 minuti. Vale se in quei 20 minuti hai corso al massimo.';

  @override
  String get usalaComeFtpCorsa => 'Usala come FTP di corsa';

  @override
  String get normalizzata => 'Normalizzata';

  @override
  String get zonePotenzaServeFtp =>
      'Per le zone di potenza serve l\'FTP: scrivilo in Profilo → Zone, oppure impostalo su intervals.icu.';

  @override
  String get tempoNelleZonePotenza => 'Tempo nelle zone di potenza';

  @override
  String zoneCalcolateSulTuo(Object p0) {
    return 'Zone calcolate sul tuo FTP ($p0 W).';
  }

  @override
  String get intensitaPrevistaTenutaTutta =>
      'Intensità prevista e tenuta in tutta la seduta';

  @override
  String alle(Object p0, Object p1, Object p2, Object p3, Object p4) {
    return '$p0/$p1/$p2 alle $p3:$p4';
  }

  @override
  String get controlloHealthConnect => 'Controllo Health Connect…';

  @override
  String get healthConnectInstallatoMa =>
      'Health Connect è installato ma va aggiornato.';

  @override
  String get healthConnectNonInstallato2 =>
      'Health Connect non è installato. Serve per leggere gli allenamenti di Garmin e Freeletics.';

  @override
  String get aggiornaHealthConnect => 'Aggiorna Health Connect';

  @override
  String get installaHealthConnect => 'Installa Health Connect';

  @override
  String get nonCollegatoMancaPermesso =>
      'Non collegato: manca il permesso per le sessioni.';

  @override
  String get permessi => 'Permessi';

  @override
  String get datiPiuVecchi30 => 'Dati più vecchi di 30 giorni';

  @override
  String get maiSincronizzato => 'Mai sincronizzato.';

  @override
  String ultimaSincronizzazione(Object p0) {
    return 'Ultima sincronizzazione: $p0';
  }

  @override
  String sessioniHealthConnect(Object p0) {
    return 'Sessioni da Health Connect: $p0';
  }

  @override
  String get fontiTrovate => 'Fonti trovate';

  @override
  String sessioni(Object p0, Object p1, Object p2) {
    return '$p0: $p1 sessioni  ($p2)';
  }

  @override
  String get tipiAttivitaIgnorati => 'Tipi di attività ignorati';

  @override
  String get sincronizzaOra => 'Sincronizza ora';

  @override
  String get rivediPermessi => 'Rivedi permessi';

  @override
  String get salvaModello => 'Salva il modello';

  @override
  String get modelloSalvatoCompilaloRiga =>
      'Modello salvato. Compilalo (una riga per sessione) e importalo qui.';

  @override
  String impossibileSalvareModello(Object p0) {
    return 'Impossibile salvare il modello: $p0';
  }

  @override
  String impossibileAprireSelezioneDei(Object p0) {
    return 'Impossibile aprire la selezione dei file: $p0';
  }

  @override
  String fileTroppoGrandeMassimo(Object p0) {
    return '$p0: file troppo grande (massimo 20 MB).';
  }

  @override
  String impossibileLeggereFile2(Object p0, Object p1) {
    return '$p0: impossibile leggere il file ($p1).';
  }

  @override
  String get opzioniAvanzate => 'Opzioni avanzate';

  @override
  String get importManualeCsvSenza =>
      'Import manuale da CSV, senza sincronizzazione';

  @override
  String get seNonUsiApp =>
      'Se non usi app collegate a Health Connect puoi inserire le sessioni a mano: scarica il modello, compilalo con un foglio di calcolo (una riga per sessione) e importalo. I dati restano solo sul telefono.';

  @override
  String get colonneDataAaaaMm =>
      'Colonne: data (AAAA-MM-GG), sport (Corsa, Bici, Nuoto, Forza), tipo_sessione, durata_min, distanza_km, fc_media, rpe, fonte, note. Servono almeno data e sport.';

  @override
  String get scaricaModelloCsv => 'Scarica modello CSV';

  @override
  String get importaCsv => 'Importa CSV';

  @override
  String get modificaIntervalli => 'Modifica gli intervalli';

  @override
  String get toccaTrattoCambiareNome =>
      'Tocca un tratto per cambiare nome, metri o tempo, o per toglierlo. Tienilo premuto e trascinalo per spostarlo.';

  @override
  String get senzaNome => 'Senza nome';

  @override
  String get aggiungiTratto => 'Aggiungi un tratto';

  @override
  String get tornaQuelliDellOrologio => 'Torna a quelli dell\'orologio';

  @override
  String get scriviTempoEs5 => 'Scrivi il tempo, es. 5:30 o 45';

  @override
  String get nuovoTratto => 'Nuovo tratto';

  @override
  String get modificaTratto => 'Modifica il tratto';

  @override
  String get esDefaticamento => 'Es. Defaticamento';

  @override
  String get metri => 'Metri';

  @override
  String get togliQuestoTratto => 'Togli questo tratto';

  @override
  String get scollegareIntervalsIcu => 'Scollegare intervals.icu?';

  @override
  String get attivitaTornanoQuelleHealth =>
      'Le attività tornano quelle di Health Connect, con meno dettagli. La chiave viene cancellata dal telefono.';

  @override
  String get attivitaCompleteGarminPolar =>
      'Attività complete da Garmin, Polar, Suunto, Coros, Wahoo, Zwift: nome vero, rulli, percorso, altitudine, potenza.';

  @override
  String get sincronizzazioneCorso => 'Sincronizzazione in corso…';

  @override
  String get collegato4 => 'Collegato.';

  @override
  String collegatoUltimaSincronizzazioneAttivita(
    Object p0,
    Object p1,
    Object p2,
    Object p3,
  ) {
    return 'Collegato · ultima sincronizzazione $p0, $p1:$p2 · $p3 attività';
  }

  @override
  String get mandaPianoSeduteIntervals =>
      'Manda piano e sedute a intervals.icu';

  @override
  String corsaBiciNuotoDei(Object p0) {
    return 'Corsa, bici e nuoto dei prossimi $p0 giorni, passo per passo: si aggiornano da soli quando il piano cambia. Le sedute registrate con l\'app partono da sole appena finite, con il percorso se c\'è.';
  }

  @override
  String get invioCorso => 'Invio in corso…';

  @override
  String get nonAncoraMandato => 'Non ancora mandato.';

  @override
  String ultimoInvioSeduteCalendario(
    Object p0,
    Object p1,
    Object p2,
    Object p3,
  ) {
    return 'Ultimo invio $p0, $p1:$p2 · $p3 sedute in calendario';
  }

  @override
  String get inviaOra => 'Invia ora';

  @override
  String get averleSullOrologioGarmin => 'Per averle sull\'orologio Garmin';

  @override
  String get suIntervalsIcuImpostazioni =>
      'Su intervals.icu: Impostazioni → Garmin Connect → attiva \"Upload planned workouts\". Le sedute passano nel calendario di Garmin Connect e da lì all\'orologio. Battito: zone di intervals.icu; nuoto: passo per 100 m.';

  @override
  String get creaAccountGratuitoSu =>
      'Crea un account gratuito su intervals.icu (dal browser).';

  @override
  String get liImpostazioniCollegaGarmin =>
      'Lì, in Impostazioni, collega Garmin Connect (o il tuo orologio): le attività arrivano da sole.';

  @override
  String get sempreImpostazioniFondoDeveloper =>
      'Sempre in Impostazioni, in fondo, \"Developer settings\": crea la chiave API e copiala.';

  @override
  String get incollalaQuiSottoTocca => 'Incollala qui sotto e tocca Collega.';

  @override
  String get chiaveApiIntervalsIcu => 'Chiave API di intervals.icu';

  @override
  String get incollaDagliAppunti => 'Incolla dagli appunti';

  @override
  String get chiaveRestaCifrataSul =>
      'La chiave resta cifrata sul telefono. Serve a leggere le tue attività e, solo se lo accendi, a mandare il piano al tuo calendario.';

  @override
  String get collega2 => 'Collega';

  @override
  String get arrivo => 'Arrivo';

  @override
  String get percorsoCompletato => 'Percorso completato';

  @override
  String get cercoPosizione => 'Cerco la posizione';

  @override
  String get percorsoQuestaParteRaggiungilo =>
      'Il percorso è da questa parte: raggiungilo';

  @override
  String get fuoriPercorsoTornaSulla => 'Fuori percorso: torna sulla traccia';

  @override
  String get drittoFinoAllArrivo => 'Dritto fino all\'arrivo';

  @override
  String percorso(Object p0) {
    return 'Percorso a $p0';
  }

  @override
  String fuoriPercorso(Object p0) {
    return 'Fuori percorso ($p0)';
  }

  @override
  String arrivoTra(Object p0) {
    return 'Arrivo tra $p0';
  }

  @override
  String get percorsoNonConcessoPuoi =>
      'Percorso non concesso. Puoi sempre permetterlo da Health Connect.';

  @override
  String get fileTroppoGrandeGpx =>
      'File troppo grande: un GPX di un allenamento pesa al massimo pochi MB.';

  @override
  String get giornoDiverso => 'Giorno diverso';

  @override
  String fileSessioneUsarloStesso(Object p0, Object p1) {
    return 'Il file è di $p0, la sessione di $p1. Usarlo lo stesso?';
  }

  @override
  String get usalo => 'Usalo';

  @override
  String percorsoAggiunto(Object p0) {
    return 'Percorso aggiunto: $p0';
  }

  @override
  String get questaSessioneHaPercorso => 'Questa sessione ha il percorso GPS';

  @override
  String get healthConnectChiedeTuo =>
      'Health Connect chiede il tuo permesso per mostrarlo. Per non doverlo dare ogni volta: Health Connect → Avidididadi → Percorsi di allenamento → Consenti sempre.';

  @override
  String get consentiSempre => 'Consenti sempre';

  @override
  String get aggiungiGpx => 'Aggiungi GPX';

  @override
  String get appHaRegistratoSessione => 'L\'app che ha registrato la sessione';

  @override
  String get nessunPercorsoGps => 'Nessun percorso GPS';

  @override
  String nonHaCondivisoPuoi(Object p0) {
    return '$p0 non lo ha condiviso. Puoi aggiungerlo tu: su connect.garmin.com apri l\'attività, ingranaggio → Esporta in GPX, poi carica qui il file.';
  }

  @override
  String get ritmo => 'Ritmo';

  @override
  String get scriviQuantiMinutiDurata => 'Scrivi quanti minuti è durata';

  @override
  String get vasca => 'In vasca';

  @override
  String get vasche => 'Vasche';

  @override
  String get lunghezzaVasca => 'Lunghezza vasca';

  @override
  String get metriTotali => 'Metri totali';

  @override
  String get tempoMedio => 'Tempo medio';

  @override
  String get es155 => 'es. 1:55';

  @override
  String get stile => 'Stile';

  @override
  String get modificaSessione => 'Modifica la sessione';

  @override
  String get eliminaSessione => 'Elimina la sessione';

  @override
  String get nomeDellAllenamento => 'Nome dell\'allenamento';

  @override
  String get indoorRulliTacx => 'Indoor (rulli, Tacx)';

  @override
  String get indoorTapisRoulant => 'Indoor (tapis roulant)';

  @override
  String get nienteMappaNeGpx => 'Niente mappa né GPX';

  @override
  String inizio(Object p0, Object p1) {
    return 'Inizio $p0:$p1';
  }

  @override
  String get vieBlocchiGradi => 'Vie, blocchi e gradi';

  @override
  String get eserciziSerieKg => 'Esercizi, serie e kg';

  @override
  String get comeAndata => 'Come è andata';

  @override
  String get battitoMassimo => 'Battito massimo';

  @override
  String get fatica => 'Fatica';

  @override
  String get su10 => 'su 10';

  @override
  String get tuttoQuelloTiRicordi => 'Tutto quello che ti ricordi';

  @override
  String get tornaAiDatiOriginali => 'Torna ai dati originali';

  @override
  String get dataGara => 'Data della gara';

  @override
  String get scriviOreMinutiEs => 'Scrivi ore:minuti, es. 1:45';

  @override
  String get scegliDataGara => 'Scegli la data della gara.';

  @override
  String get tempoObiettivoFacoltativo => 'Tempo obiettivo (facoltativo)';

  @override
  String get oreMinutiEs1 => 'ore:minuti, es. 1:45';

  @override
  String traSettimane(Object p0) {
    return 'Tra $p0 settimane';
  }

  @override
  String faseAttuale(Object p0, Object p1) {
    return 'Fase attuale: $p0. $p1';
  }

  @override
  String get fasiAvanzanoSoleVerso =>
      'Le fasi avanzano da sole verso la gara: base, sviluppo, rifinitura e scarico.';

  @override
  String get rimuoviObiettivo => 'Rimuovi obiettivo';

  @override
  String get controllaValoriFcMax =>
      'Controlla i valori: FC max 120-230, FC riposo 30-100, passo m:ss, FTP 50-600 W.';

  @override
  String get n15MinutiFacili3 =>
      '15 minuti facili e 3 allunghi, poi 20 minuti al massimo che riesci a tenere, poi 10 minuti lentissimi. Circa 50 minuti.';

  @override
  String get telefonoNonMisuraWatt =>
      'Il telefono non misura i watt di corsa: registra la corsa anche con l\'orologio. Poi apri i grafici di quella corsa: lì trovi la tua FTP e il tasto per salvarla.';

  @override
  String testNelCalendarioPrende(Object p0) {
    return 'Test nel calendario: $p0. Prende il posto della corsa di quel giorno.';
  }

  @override
  String get scegliOggiOGiorno => 'Scegli oggi o un giorno dopo.';

  @override
  String get mettiloNelCalendario => 'Mettilo nel calendario';

  @override
  String get zone => 'Zone';

  @override
  String get tueZoneFrequenzaCardiaca => 'Le tue zone di frequenza cardiaca';

  @override
  String calcolateRiservaCardiacaFc(Object p0, Object p1) {
    return 'Calcolate con la riserva cardiaca (FC max $p0, a riposo $p1).';
  }

  @override
  String calcolateComePercentualeFc(Object p0) {
    return 'Calcolate come percentuale della FC max ($p0). Con la FC a riposo diventano più precise.';
  }

  @override
  String get fcMassima => 'FC massima';

  @override
  String vuotoStimaDaiTuoi(Object p0) {
    return 'Vuoto = stima dai tuoi dati: $p0 bpm (la più alta dell\'ultimo anno, o dall\'età).';
  }

  @override
  String vuotoQuellaMisurataBpm(Object p0) {
    return 'Vuoto = quella misurata: $p0 bpm.';
  }

  @override
  String get misuralaAppenaSveglioO =>
      'Misurala appena sveglio, o lascia vuoto.';

  @override
  String get passoCriticoNuoto => 'Passo critico del nuoto';

  @override
  String get mSsEs2 => 'm:ss, es. 2:05';

  @override
  String get vuotoStimaDalleSessioni =>
      'Vuoto = stima dalle sessioni in piscina (non ancora disponibile).';

  @override
  String vuotoStimaDalleSessioni2(Object p0) {
    return 'Vuoto = stima dalle sessioni in piscina: $p0.';
  }

  @override
  String get tueZonePotenzaBici => 'Le tue zone di potenza (bici)';

  @override
  String get partonoDallFtpPotenza =>
      'Partono dall\'FTP, la potenza che riesci a tenere per circa un\'ora. Le sedute di bici ti danno il range di watt da tenere.';

  @override
  String get ftp => 'FTP';

  @override
  String vuotoQuelloIntervalsIcu(Object p0) {
    return 'Vuoto = quello di intervals.icu: $p0 W.';
  }

  @override
  String get seNonSaiPedala =>
      'Se non lo sai: pedala 20 minuti più forte che puoi, l\'FTP è circa il 95% della potenza media.';

  @override
  String get tueZonePotenzaCorsa => 'Le tue zone di potenza (corsa)';

  @override
  String get ftpBiciNonVale =>
      'L\'FTP della bici non vale correndo: la corsa ha la sua. Serve ai grafici delle corse registrate con un orologio che misura i watt.';

  @override
  String get ftpCorsa => 'FTP di corsa';

  @override
  String vuotoStimaEtaPeso(Object p0) {
    return 'Vuoto = stima da età e peso: $p0 W. È solo un punto di partenza.';
  }

  @override
  String get vuotoStimaEtaPeso2 =>
      'Vuoto = stima da età e peso: scrivi il peso nel Profilo.';

  @override
  String get faiTestCalcolarla => 'Fai il test per calcolarla';

  @override
  String get duranteAllenamento => 'Durante l\'allenamento';

  @override
  String get avvisi => 'Avvisi';

  @override
  String get voce => 'Voce';

  @override
  String get diceEsercizioIniziaKm =>
      'Dice l\'esercizio che inizia, i km e se sei fuori zona o fuori passo. Durante le chiamate sta zitta.';

  @override
  String get bip => 'Bip';

  @override
  String negliUltimiSecondiRecuperi(Object p0) {
    return 'Negli ultimi $p0 secondi di recuperi ed esercizi a tempo, e a ogni km (5 km in bici). Usa il volume dei media.';
  }

  @override
  String get vibrazione => 'Vibrazione';

  @override
  String get insiemeAiBip => 'Insieme ai bip.';

  @override
  String get pausaAutomatica => 'Pausa automatica';

  @override
  String get corsaBiciCamminataTempo =>
      'Corsa, bici e camminata: il tempo si ferma quando ti fermi e riparte da solo. Mai durante i recuperi.';

  @override
  String get spenta => 'Spenta';

  @override
  String get tempoNonSiFerma => 'Il tempo non si ferma mai da solo.';

  @override
  String get soloQuandoSeiFermo => 'Solo quando sei fermo';

  @override
  String get alSemaforoOSosta =>
      'Al semaforo o a una sosta. Se vai piano, anche in salita, il tempo continua.';

  @override
  String sottoKmH(Object p0) {
    return 'Sotto i $p0 km/h';
  }

  @override
  String get comeCerteAppAttento =>
      'Come certe app: attento, se vai più piano di così il tempo si ferma.';

  @override
  String get camminataTranquilla45 =>
      'Camminata tranquilla 4-5 km/h, corsa lenta 8-10, bici in salita anche 6-8.';

  @override
  String get soloMovimento => 'Solo in movimento';

  @override
  String get sosteNonContanoAnche =>
      'Le soste non contano, anche con la pausa automatica spenta: è il passo con cui ti sei mosso.';

  @override
  String get soste => 'Con le soste';

  @override
  String get distanzaDivisoTuttoTempo =>
      'Distanza diviso tutto il tempo, soste comprese.';

  @override
  String get allaFineRiepilogoMostra =>
      'Alla fine il riepilogo mostra comunque tutti e due i tempi: in movimento e totale.';

  @override
  String get corsaCamminataBiciAll =>
      'Corsa, camminata e bici all\'aperto: dove sta la mappa che segue la tua posizione (e il percorso, se ne segui uno).';

  @override
  String get scorriLatoTimerDati =>
      'Scorri di lato: in una timer e dati, nell\'altra la mappa grande.';

  @override
  String get mappaPiccolaSempreVista =>
      'Una mappa piccola sempre in vista, sopra il timer.';

  @override
  String get mappaOccupaTuttoTempo =>
      'La mappa occupa tutto, con tempo e dati sopra.';

  @override
  String get fileTroppoGrandeGpx2 =>
      'File troppo grande: un GPX pesa al massimo pochi MB.';

  @override
  String aggiunto(Object p0, Object p1) {
    return 'Aggiunto: $p0 · $p1';
  }

  @override
  String mSalita2(Object p0) {
    return '$p0 m di salita';
  }

  @override
  String get scegliPercorso => 'Scegli il percorso';

  @override
  String get mieiPercorsi => 'I miei percorsi';

  @override
  String get nessunPercorso => 'Nessun percorso';

  @override
  String get aggiungiFileGpxGara =>
      'Aggiungi il file GPX di una gara, di un giro famoso o di un amico. Durante corsa, camminata o bici l\'app ti mostra dove sei sulla mappa e ti dice a voce dove girare.';

  @override
  String get doveTrovoGpx => 'Dove trovo un GPX?';

  @override
  String get sitoGaraSpessoC =>
      '• Sito della gara: spesso c\'è \"Scarica la traccia GPX\".\n• Strava, Komoot, Garmin Connect: apri un percorso o un\'attività → Esporta GPX.\n• Un amico: può mandarti il GPX della sua attività.\nPoi qui: Aggiungi GPX e scegli il file.';

  @override
  String get ancheSenzaRete => 'Anche senza rete';

  @override
  String get vediPercorso => 'Vedi il percorso';

  @override
  String get nomePercorso => 'Nome del percorso';

  @override
  String get eliminarePercorso => 'Eliminare il percorso?';

  @override
  String sparisceDallaRaccoltaDalle(Object p0) {
    return '\"$p0\" sparisce dalla raccolta e dalle sedute a cui era assegnato. Gli allenamenti già fatti restano.';
  }

  @override
  String get usaQuestoPercorso => 'Usa questo percorso';

  @override
  String get rinomina => 'Rinomina';

  @override
  String get filePercorsoMancante => 'File del percorso mancante.';

  @override
  String get curve => 'Curve';

  @override
  String get altimetria => 'Altimetria';

  @override
  String get giroAdAnelloSi =>
      'Giro ad anello: si parte e si arriva nello stesso punto.';

  @override
  String get partenzaAlPallinoVerde =>
      'Partenza al pallino verde, arrivo all\'altro capo.';

  @override
  String get seguirloPrimaPartireCorsa =>
      'Per seguirlo: prima di partire con corsa, camminata o bici tocca \"Segui un percorso\", oppure assegnalo prima a una seduta in programma.';

  @override
  String mMinM(Object p0, Object p1) {
    return '$p0 m · min $p1 m';
  }

  @override
  String get percorsoSeguire => 'Percorso da seguire';

  @override
  String get scegli => 'Scegli';

  @override
  String get cambia => 'Cambia';

  @override
  String scaricoMappa(Object p0) {
    return 'Scarico la mappa… $p0%';
  }

  @override
  String get puoiUsareAppIntanto => 'Puoi usare l\'app intanto.';

  @override
  String get mappaScaricata => 'Mappa scaricata';

  @override
  String get stradePercorsoSiVedono =>
      'Strade e percorso si vedono anche senza rete (non il satellite).';

  @override
  String get mappaSenzaRete => 'Mappa senza rete';

  @override
  String scaricaZonaAttornoAl(Object p0) {
    return 'Scarica la zona attorno al percorso ($p0), per vederla anche dove il telefono non prende.';
  }

  @override
  String get scarica => 'Scarica';

  @override
  String ultimoAggiornamento(Object p0) {
    return 'Ultimo aggiornamento: $p0';
  }

  @override
  String get breveTuoiDatiRestano =>
      'In breve: i tuoi dati restano sul telefono. L\'app non ha server, account né pubblicità e non vende né condivide i tuoi dati. Escono dal telefono solo nei casi descritti qui sotto, quasi tutti scelti da te.';

  @override
  String get datiInserisciTu => 'Dati che inserisci tu';

  @override
  String get nomeDataNascitaSesso =>
      'Nome, data di nascita, sesso, altezza, peso e misure, foto del profilo, obiettivo e gara, settimana tipo, attrezzatura, feedback dopo gli allenamenti (fatica, completata, dolore), ripetizioni e kg delle serie di forza, vie, blocchi, gradi e allenamenti dell\'arrampicata, vasche, tempi e altri dati delle sedute scritti a mano, schede scritte a mano e sessioni importate da file CSV. Servono a preparare il piano e a mostrare i progressi.';

  @override
  String get datiLettiHealthConnect =>
      'Dati letti da Health Connect (solo lettura)';

  @override
  String get tuoPermessoAppLegge =>
      'Con il tuo permesso l\'app legge da Health Connect le sessioni di allenamento (tipo, titolo, inizio e fine) e, nel tempo di ogni sessione, frequenza cardiaca, distanza, calorie, passi e velocità. Legge anche FC a riposo, variabilità cardiaca (HRV) e sonno per valutare il recupero, e lo storico oltre i 30 giorni se lo concedi. Sono i dati scritti da Garmin Connect, Freeletics e dalle altre app collegate a Health Connect. L\'app non scrive, non modifica e non cancella nulla in Health Connect.';

  @override
  String get percorsiGpsDelleSessioni => 'Percorsi GPS delle sessioni';

  @override
  String get seAppHaRegistrato =>
      'Se l\'app che ha registrato una corsa o un\'uscita in bici ha salvato anche il percorso in Health Connect, Avidididadi lo legge solo con il tuo permesso: per la singola sessione (te lo chiede Health Connect) oppure per tutte, se scegli \"Consenti sempre\" nelle impostazioni di Health Connect. Puoi anche aggiungere tu un percorso caricando un file GPX (per esempio esportato da Garmin Connect). Una copia del percorso resta nell\'app per mostrare la mappa. I percorsi da seguire che aggiungi a \"I miei percorsi\" (file GPX di gare, giri, amici) restano solo sul telefono e nel backup; non vanno all\'assistente.';

  @override
  String get posizioneDuranteAllenamento => 'Posizione durante l\'allenamento';

  @override
  String get soloCorsaCamminataBici =>
      'Solo per corsa, camminata e bici (e per un\'altra attività se scegli tu di registrare il percorso), e solo mentre la modalità allenamento è aperta, l\'app usa la posizione precisa (GPS e servizio di posizione di Google Play sul telefono) per registrare percorso, distanza e ritmo. Mentre registra mostra una notifica fissa e continua anche a schermo spento; quando chiudi l\'allenamento il GPS si spegne. L\'app non usa la posizione in nessun altro momento e non la raccoglie in background. Il percorso viene salvato solo sul telefono: non va in Health Connect, non va all\'assistente e non viene inviato a nessuno, a meno che sia tu ad accendere l\'invio a intervals.icu o a salvarlo in un file GPX. Mentre ti alleni, una copia della seduta in corso (percorso compreso) resta sul telefono per riprenderla se l\'app si chiude; si cancella quando finisci.';

  @override
  String get sensoriBluetoothBattitoBici =>
      'Sensori Bluetooth (battito e bici)';

  @override
  String get soloSeScegliTu =>
      'Solo se lo scegli tu, durante la modalità allenamento o dalla pagina \"I miei sensori\" del Profilo, l\'app si collega via Bluetooth a una fascia cardio, a un orologio che trasmette il battito o ai sensori della bici (rulli, potenza, velocità e cadenza), per mostrarteli mentre ti alleni. Chiusa quella pagina o finito l\'allenamento, si scollega. Alla fine della seduta salva nella sessione battito medio e massimo, potenza e cadenza medie e, per i grafici, un valore al secondo di battito, potenza, cadenza e velocità: tutto sul telefono. Nome e indirizzo Bluetooth dei sensori (e la circonferenza della ruota) restano sul telefono per ricollegarsi la volta dopo: li cancelli con \"Dimentica\". Il permesso \"Dispositivi nelle vicinanze\" serve solo a trovare il sensore, non a sapere dove sei.';

  @override
  String get mappe => 'Mappe';

  @override
  String get disegnareMappaAppScarica =>
      'Per disegnare la mappa l\'app scarica i riquadri della zona mostrata: da OpenFreeMap (tiles.openfreemap.org, dati © OpenStreetMap) per le mappe Pulse e Strade, e da Esri (server.arcgisonline.com) solo se scegli la vista Satellite. Come per qualsiasi sito, quei servizi ricevono l\'indirizzo IP del telefono e quali riquadri vengono chiesti, quindi possono capire quale zona stai guardando. Il percorso, i tempi e gli altri dati dell\'allenamento non vengono inviati: la linea viene disegnata sul telefono. Per i percorsi da seguire l\'app scarica in anticipo i riquadri della fascia attorno alla traccia, per vederli senza rete: OpenFreeMap riceve quei riquadri, e quindi la zona del percorso. Restano nella memoria dell\'app finché non togli la mappa o il percorso.';

  @override
  String get intervalsIcuFacoltativo => 'intervals.icu (facoltativo)';

  @override
  String get seColleghiIntervalsIcu =>
      'Se colleghi intervals.icu con la tua chiave API, l\'app scarica da lì le tue attività di corsa, bici e nuoto (nome, orari, distanza, battito, velocità, altitudine, potenza, percorso GPS) e il tuo FTP di bici e corsa, per le zone di potenza. intervals.icu le riceve dal tuo orologio (Garmin, Polar, Suunto…) perché lo hai collegato tu, con le sue condizioni sulla privacy. La chiave resta cifrata sul telefono. Solo se accendi \"Manda piano e sedute a intervals.icu\", l\'app scrive nel tuo calendario di intervals.icu le sedute di corsa, bici e nuoto dei prossimi 14 giorni (data, sport, nome, durata, passi con zone di battito, potenza o passo): niente nome, foto, misure, feedback o forza. Spegnendolo, le sedute future mandate dall\'app vengono tolte. Con questo invio acceso, ogni sessione che registri con l\'app (forza compresa) va da sola sul tuo account appena finita; spento, solo se tocchi \"Invia a intervals.icu\" su quella sessione. Partono orario, sport, nome, durata, distanza, battito medio e massimo e, se c\'è, il percorso GPS. Allo stesso modo \"Salva GPX\" crea un file col percorso dove scegli tu. Le attività scaricate restano sul telefono ed entrano nel backup; scollegando, vengono tolte.';

  @override
  String get immaginiDegliEsercizi => 'Immagini degli esercizi';

  @override
  String get fotoDegliEserciziVengono =>
      'Le foto degli esercizi vengono scaricate, quando servono, dalla raccolta pubblica free-exercise-db su GitHub. GitHub riceve l\'indirizzo IP del telefono e quale immagine viene chiesta, nient\'altro.';

  @override
  String get assistenteFacoltativo2 => 'Assistente (facoltativo)';

  @override
  String get soloSeAttiviTu =>
      'Solo se lo attivi tu, l\'assistente invia un riassunto dei tuoi allenamenti (sessioni delle ultime 4 settimane, feedback, recupero, zone di battito e FTP della bici, piano dei prossimi 14 giorni) al servizio che scegli: Anthropic, OpenAI, Google oppure Ollama sul tuo PC. Nome, foto e percorsi GPS non vengono mai inviati; età, sesso e peso solo se lo permetti. Prima di attivarlo puoi vedere esattamente cosa viene inviato. La chiave API resta cifrata sul telefono. Per i servizi online valgono le loro condizioni sulla privacy e gli eventuali costi del tuo abbonamento.';

  @override
  String get assistenteNellaTuaApp => 'Assistente nella tua app (facoltativo)';

  @override
  String get seColleghiAppTuo =>
      'Se colleghi l\'app del tuo assistente (Claude, ChatGPT, Gemini o altre), Avidididadi prepara un messaggio con lo stesso riassunto descritto sopra e lo passa a quell\'app solo quando tocchi Condividi o Copia. Da quel momento i dati sono nella chat del servizio scelto e valgono le sue regole: con un abbonamento normale le chat possono servire ad addestrare il modello, secondo le impostazioni del tuo account. Le risposte che condividi o incolli nell\'app vengono lette solo se contengono il codice del tuo collegamento, e le modifiche al piano si applicano solo dopo la tua conferma. Finché non lo colleghi, Avidididadi non riceve testo da altre app; quando lo scolleghi, il codice smette di valere.';

  @override
  String get widgetSullaSchermataHome => 'Widget sulla schermata home';

  @override
  String get seAggiungiWidgetSeduta =>
      'Se aggiungi il widget, la seduta di oggi e la settimana sono visibili sulla schermata home, quindi anche a chi vede il telefono sbloccato.';

  @override
  String get doveRestanoDati => 'Dove restano i dati';

  @override
  String get nellaCartellaPrivataDell =>
      'Nella cartella privata dell\'app sul telefono, a cui le altre app non possono accedere. Non finiscono nel backup automatico di Android su Google né nel trasferimento a un nuovo telefono: per spostarli usa il backup dell\'app.';

  @override
  String get fileBackupCreiContiene =>
      'Il file di backup che crei contiene tutti i dati dell\'app, compresi dati sulla salute, foto e percorsi GPS (non la chiave API). Lo salvi dove scegli tu: tienilo in un posto sicuro e non condividerlo. Se accendi il backup automatico, l\'app scrive lo stesso file da sola nella cartella che hai scelto e tiene gli ultimi 5; le altre app che leggono quella cartella possono vederlo.';

  @override
  String get permessiTelefono => 'Permessi del telefono';

  @override
  String get healthConnectLetturaDei =>
      'Health Connect (lettura dei dati elencati sopra), posizione precisa (solo durante corsa, camminata e bici), dispositivi nelle vicinanze (solo per il sensore del battito), attività fisica (solo per i passi in corsa e camminata), internet (mappe, immagini, assistente, aggiornamenti), installazione di app (solo per gli aggiornamenti dell\'app, che confermi ogni volta), notifiche (solo quella dell\'allenamento in corso, con tempo e dati, visibile anche a schermo bloccato). Puoi negare ognuno di questi permessi: l\'app continua a funzionare senza la parte che ne ha bisogno.';

  @override
  String get comeRevocareOCancellare => 'Come revocare o cancellare';

  @override
  String get healthConnectImpostazioniHealth =>
      'Health Connect: Impostazioni di Health Connect → Permessi delle app → Avidididadi, oppure dal Profilo con \"Rivedi permessi\". Posizione, dispositivi nelle vicinanze e attività fisica: Impostazioni di Android → App → Avidididadi → Permessi. Sensore del battito: \"Dimentica\" nel foglio del battito, durante l\'allenamento. Assistente: disattivalo e cancella la chiave nella pagina Coach. Per cancellare tutto: Impostazioni di Android → App → Avidididadi → Memoria → Cancella dati, oppure disinstalla l\'app. I dati in Health Connect restano lì, perché sono delle app che li hanno scritti.';

  @override
  String get modifiche => 'Modifiche';

  @override
  String get seQuestaInformativaCambia =>
      'Se questa informativa cambia, all\'apertura l\'app te lo dice e ti chiede di accettarla di nuovo.';

  @override
  String get cosAvidididadi => 'Cos\'è Avidididadi';

  @override
  String get appPersonalePianificareSeguire =>
      'Un\'app personale per pianificare e seguire allenamenti di forza, corsa, nuoto, bici e mobilità, e per vedere storico e progressi. Usandola accetti questi termini e l\'informativa sulla privacy.';

  @override
  String get pianiCarichiZoneFrequenza =>
      'Piani, carichi, zone di frequenza cardiaca, valutazione del recupero e risposte dell\'assistente sono stime automatiche a scopo informativo. Non sono una diagnosi né un parere medico e non sostituiscono medico, fisioterapista o allenatore. Prima di iniziare un programma di allenamento, soprattutto se hai problemi di salute, sei in gravidanza o non ti alleni da tempo, chiedi a un medico. Se senti dolore, vertigini, fiato corto anomalo o dolore al petto, fermati e cerca assistenza.';

  @override
  String get allenatiSicurezza => 'Allenati in sicurezza';

  @override
  String get tiAlleniSottoTua =>
      'Ti alleni sotto la tua responsabilità: scegli carichi e ritmi adatti a te, usa attrezzatura in buono stato e rispetta il codice della strada. Durante corsa, camminata e bici non guardare il telefono mentre ti muovi nel traffico.';

  @override
  String get precisioneDeiDati => 'Precisione dei dati';

  @override
  String get gpsDistanzeRitmoPassi =>
      'GPS, distanze, ritmo, passi e i dati letti da Health Connect possono contenere errori (per esempio tra palazzi alti o sotto gli alberi). Calcoli e grafici dipendono da questi dati e dalla loro completezza.';

  @override
  String get serviziTerzi => 'Servizi di terzi';

  @override
  String get alcuneFunzioniUsanoServizi =>
      'Alcune funzioni usano servizi di altri: Health Connect e le app che vi scrivono (es. Garmin Connect), OpenFreeMap e OpenStreetMap per le mappe, GitHub per le immagini degli esercizi e gli aggiornamenti dell\'app e, se lo attivi, il servizio di intelligenza artificiale che scegli. Questi servizi hanno condizioni proprie, possono cambiare o non essere disponibili. Chiave API e costi del servizio di intelligenza artificiale sono a tuo carico.';

  @override
  String get tuoiDati => 'I tuoi dati';

  @override
  String get datiRestanoSulTuo =>
      'I dati restano sul tuo telefono e ne sei responsabile tu: fai backup periodici e conserva il file in un posto sicuro. Disinstallando l\'app senza backup i dati vanno persi.';

  @override
  String get nessunaGaranzia => 'Nessuna garanzia';

  @override
  String get appFornitaCosiCom =>
      'L\'app è fornita così com\'è, senza garanzie di funzionamento continuo o privo di errori. Nei limiti consentiti dalla legge, chi l\'ha sviluppata non risponde di danni derivanti dall\'uso dell\'app, da dati non corretti o dalla perdita di dati.';

  @override
  String get questiTerminiPossonoEssere =>
      'Questi termini possono essere aggiornati. Se cambiano, all\'apertura l\'app te lo dice e ti chiede di accettarli di nuovo prima di continuare.';

  @override
  String impossibileCaricareFoto(Object p0) {
    return 'Impossibile caricare la foto: $p0';
  }

  @override
  String get scegliDallaGalleria => 'Scegli dalla galleria';

  @override
  String get scattaFoto => 'Scatta una foto';

  @override
  String get rimuoviFoto => 'Rimuovi foto';

  @override
  String get siRegistraDataOggi =>
      'Si registra con la data di oggi. Lascia vuoto per cancellare.';

  @override
  String anni(Object p0, Object p1) {
    return '$p0 ($p1 anni)';
  }

  @override
  String get tuoProfilo => 'Il tuo profilo';

  @override
  String get inserisciTuoiDati => 'Inserisci i tuoi dati';

  @override
  String get modificaTuoiDati => 'Modifica i tuoi dati';

  @override
  String get mioAllenamento => 'Il mio allenamento';

  @override
  String get mioObiettivo => 'Il mio obiettivo';

  @override
  String get nessunaGaraTiAlleni =>
      'Nessuna gara: ti alleni per stare in forma';

  @override
  String get scegliSportAppScrive =>
      'Scegli gli sport: l\'app scrive gli allenamenti passo passo';

  @override
  String forza(Object p0) {
    return 'Forza: $p0';
  }

  @override
  String get mieSchede => 'Le mie schede';

  @override
  String get schedePersonalTrainerO =>
      'Le schede del personal trainer o dell\'allenatore';

  @override
  String corso(Object p0) {
    return 'In corso: $p0';
  }

  @override
  String get comeSiFannoImmagini =>
      'Come si fanno, con immagini e muscoli usati';

  @override
  String get mieZone => 'Le mie zone';

  @override
  String get quantoSpingereBattitiAl =>
      'Quanto spingere: battiti al minuto e watt in bici';

  @override
  String get mioCorpo => 'Il mio corpo';

  @override
  String get toccaMisuraInserirlaVedrai =>
      'Tocca una misura per inserirla: vedrai come cambi nel tempo.';

  @override
  String ultimoAggiornamentoToccaMisura(Object p0) {
    return 'Ultimo aggiornamento: $p0. Tocca una misura per aggiornarla.';
  }

  @override
  String get impostazioniAiuto => 'Impostazioni e aiuto';

  @override
  String get temaScuro => 'Tema scuro';

  @override
  String get fondoGrafiteOppureBianco => 'Fondo grafite oppure bianco';

  @override
  String get versioneNeon => 'Versione neon';

  @override
  String get rosaVerdeAcquaAzzurro =>
      'Rosa, verde acqua e azzurro al posto del rosso';

  @override
  String get mieiSensori => 'I miei sensori';

  @override
  String get fasciaCardioRulloSensori =>
      'Fascia cardio, rullo e sensori della bici';

  @override
  String get funzioniAvanzate => 'Funzioni avanzate';

  @override
  String get zoneWattSensoriBluetooth =>
      'Zone, watt, sensori Bluetooth, rullo e intervals.icu';

  @override
  String get voceBipPausaAutomatica =>
      'Voce, bip, pausa automatica e passo medio';

  @override
  String get tuoiAllenamentiCrealiFalli =>
      'I tuoi allenamenti: creali, falli o mettili nel piano';

  @override
  String get gpxSeguireMappaIndicazioni =>
      'GPX da seguire con mappa e indicazioni a voce';

  @override
  String get orologioAppBackupDei => 'Orologio e app, backup dei dati';

  @override
  String get giroGuidatoDellApp => 'Giro guidato dell\'app';

  @override
  String get n10FunzioniPrincipaliAlla =>
      'Le 10 funzioni principali, una alla volta';

  @override
  String get zoneCaricoFartlekSpiegati =>
      'Zone, carico, fartlek… spiegati semplici';

  @override
  String get configurazioneGuidata => 'Configurazione guidata';

  @override
  String get rifaiPianoRispondendoPoche =>
      'Rifai il piano rispondendo a poche domande';

  @override
  String get rifareConfigurazione => 'Rifare la configurazione?';

  @override
  String get settimanaTipoPianoOggi =>
      'Settimana tipo e piano da oggi in poi verranno sostituiti. Gli allenamenti già fatti e le misure restano.';

  @override
  String get inserisciNumeroValido => 'Inserisci un numero valido';

  @override
  String get diagrammaDellAllenamento => 'Diagramma dell\'allenamento';

  @override
  String get wattPrevistiTenutiTutta =>
      'Watt previsti e tenuti in tutta la seduta';

  @override
  String get n1Mese => '1 mese';

  @override
  String get n3Mesi => '3 mesi';

  @override
  String get n6Mesi => '6 mesi';

  @override
  String get n1Anno => '1 anno';

  @override
  String get quiVedraiComeVanno =>
      'Qui vedrai come vanno i tuoi allenamenti. Collega l\'orologio o le app di allenamento dal Profilo (Dati e collegamenti), oppure segna le sedute fatte.';

  @override
  String get quantoTiAlleni => 'Quanto ti alleni';

  @override
  String get alMese => 'al mese';

  @override
  String get settimana3 => 'a settimana';

  @override
  String fatica2(Object p0) {
    return 'Fatica $p0';
  }

  @override
  String ore(Object p0) {
    return 'Ore $p0';
  }

  @override
  String get durataFaticaContaAnche =>
      'Durata per fatica: conta anche quanto è stata dura.';

  @override
  String get nessunAllenamentoQuestoPeriodo =>
      'Nessun allenamento in questo periodo.';

  @override
  String get toccaColonnaDettagli => 'Tocca una colonna per i dettagli.';

  @override
  String get tuoiSport => 'I tuoi sport';

  @override
  String get toccaUnoSportVedere =>
      'Tocca uno sport per vedere tutto il dettaglio.';

  @override
  String get staiRallentando => 'Stai rallentando';

  @override
  String get staiAndandoBene => 'Stai andando bene';

  @override
  String get staiAccelerando => 'Stai accelerando';

  @override
  String get troppoTroppoFretta => 'Troppo, troppo in fretta';

  @override
  String get tiAlleniMenoDelle =>
      'Ti alleni meno delle settimane scorse. Va bene se è voluto (riposo, impegni); altrimenti riprendi con calma.';

  @override
  String get aumentiPocoAllaVolta =>
      'Aumenti poco alla volta, come si deve: così migliori senza farti male.';

  @override
  String get staiFacendoParecchioPiu =>
      'Stai facendo parecchio più del solito. Ascolta le sensazioni e non aggiungere altro questa settimana.';

  @override
  String get haiAumentatoMoltoPoco =>
      'Hai aumentato molto in poco tempo: è così che arrivano gli infortuni. Fai qualche giorno più leggero.';

  @override
  String get buono => 'Buono';

  @override
  String get basso => 'Basso';

  @override
  String get tiStoConoscendo => 'Ti sto conoscendo';

  @override
  String get dopo3SettimaneAllenamenti =>
      'Dopo 3 settimane di allenamenti ti dirò se stai aumentando nel modo giusto.';

  @override
  String get comeCalcolo => 'Come lo calcolo';

  @override
  String rispettoAllaMediaDelle(Object p0) {
    return 'Rispetto alla media delle ultime 4 settimane: $p0 (bene tra 0,8 e 1,3).';
  }

  @override
  String ultimi7GiorniPunti(Object p0, Object p1) {
    return 'Ultimi 7 giorni: $p0 punti (minuti × fatica). $p1';
  }

  @override
  String get settScorsa => 'sett. scorsa';

  @override
  String saltati(Object p0) {
    return 'Saltati: $p0';
  }

  @override
  String get comAndata2 => 'Com\'è andata';

  @override
  String get tuoiWattTuttaSeduta =>
      'I tuoi watt in tutta la seduta (media ogni 10 secondi).';

  @override
  String get barreColorateSonoProgramma =>
      'Le barre colorate sono il programma: i watt da tenere blocco per blocco. La linea sono i watt che hai tenuto (media ogni 10 secondi); quella tratteggiata è la tua FTP.';

  @override
  String get barreColorateSonoWatt =>
      'Le barre colorate sono i watt medi di ogni blocco. La linea sono i watt che hai tenuto (media ogni 10 secondi); quella tratteggiata è la tua FTP.';

  @override
  String get barraBloccoLargaQuanto =>
      'Una barra per blocco, larga quanto è durato: alta e colorata secondo i watt da tenere; il trattino sono i watt medi che hai tenuto. La linea è la tua FTP.';

  @override
  String get barraBloccoLargaQuanto2 =>
      'Una barra per blocco: larga quanto è durato, alta e colorata secondo i watt medi. La linea è la tua FTP.';

  @override
  String get allenamentoNuovo => 'Allenamento nuovo';

  @override
  String allenamentiNuovi(Object p0) {
    return '$p0 allenamenti nuovi';
  }

  @override
  String min4(Object p0) {
    return ' · $p0 min';
  }

  @override
  String prendePostoSedutaQuel(Object p0) {
    return 'Prende il posto della seduta di $p0 di quel giorno.';
  }

  @override
  String get unoGiornoPassatoNon => 'Uno è in un giorno passato: non si mette.';

  @override
  String sonoGiorniPassatiNon(Object p0) {
    return '$p0 sono in giorni passati: non si mettono.';
  }

  @override
  String get messoNelCalendario => 'Messo nel calendario.';

  @override
  String get nienteMettereDateSono =>
      'Niente da mettere: le date sono passate.';

  @override
  String get allenamentoMessoNelCalendario =>
      'Allenamento messo nel calendario.';

  @override
  String allenamentiMessiNelCalendario(Object p0) {
    return '$p0 allenamenti messi nel calendario.';
  }

  @override
  String pianoNuovo(Object p0) {
    return 'Piano nuovo da $p0';
  }

  @override
  String get applicatoTroviNelCalendario =>
      'Applicato: lo trovi nel calendario.';

  @override
  String seduteSettimaneSostituisceCalendario(Object p0, Object p1) {
    return '$p0 sedute in $p1 settimane. Sostituisce il calendario da quel giorno in poi.';
  }

  @override
  String settimana5(Object p0, Object p1, Object p2) {
    return 'Settimana del $p0/$p1: $p2';
  }

  @override
  String get altreSettimane => '…e le altre settimane.';

  @override
  String get nonApplicabile => 'Non applicabile';

  @override
  String get scriviAlCoachCorreggerlo => 'Scrivi al coach di correggerlo.';

  @override
  String copiatoIncollaloCorreggere(Object p0) {
    return 'Copiato: incollalo in $p0 per correggere.';
  }

  @override
  String copiaProblemi(Object p0) {
    return 'Copia i problemi per $p0';
  }

  @override
  String get pianoNonPiuApplicabile =>
      'Il piano non è più applicabile: riprova.';

  @override
  String pianoApplicatoSeduteNel(Object p0) {
    return 'Piano applicato: $p0 sedute nel calendario.';
  }

  @override
  String get applicaPiano => 'Applica il piano';

  @override
  String get allenamentoArrampicata => 'Allenamento di arrampicata';

  @override
  String allenamentiArrampicata2(Object p0) {
    return '$p0 allenamenti di arrampicata';
  }

  @override
  String get nellaRaccolta => 'nella raccolta';

  @override
  String nelCalendario2(Object p0) {
    return 'nel calendario $p0';
  }

  @override
  String get datePassateNonVanno =>
      'Le date passate non vanno nel calendario, ma l\'allenamento si salva lo stesso.';

  @override
  String get salvato => 'Salvato.';

  @override
  String get salvatoNegliAllenamentiArrampicata =>
      'Salvato negli allenamenti di arrampicata.';

  @override
  String salvatiNegliAllenamentiArrampicata(Object p0) {
    return '$p0 salvati negli allenamenti di arrampicata.';
  }

  @override
  String get unoNelCalendario => 'Uno è nel calendario.';

  @override
  String sonoNelCalendario(Object p0) {
    return '$p0 sono nel calendario.';
  }

  @override
  String get salvaMettiNelCalendario => 'Salva e metti nel calendario';

  @override
  String get eserciziSerieRipetizioniKg => 'Esercizi, serie, ripetizioni e kg';

  @override
  String get passiTempoODistanza =>
      'Passi a tempo o distanza, con zona o passo';

  @override
  String get passiTempoODistanza2 => 'Passi a tempo o distanza, con zona';

  @override
  String get vaschePasso100M => 'Vasche, passo per 100 m e pause';

  @override
  String scheda3(Object p0) {
    return 'Scheda di $p0';
  }

  @override
  String get scriviSchedaTuoPersonal =>
      'Scrivi la scheda del tuo personal trainer o del tuo allenatore: forza, corsa, bici o nuoto. Nei giorni che scegli prende il posto delle sedute preparate dall\'app, che non la cambia da sola.';

  @override
  String get nuovaScheda => 'Nuova scheda';

  @override
  String get corso2 => 'In corso';

  @override
  String get finite => 'Finite';

  @override
  String get archiviata => 'Archiviata';

  @override
  String dalSenzaScadenza(Object p0) {
    return 'Dal $p0, senza scadenza';
  }

  @override
  String dalAl(Object p0, Object p1) {
    return 'Dal $p0 al $p1';
  }

  @override
  String get giorno2 => 'Giorno';

  @override
  String get aggiungiAlmenoEsercizio => 'Aggiungi almeno un esercizio.';

  @override
  String get aggiungiAlmenoPasso => 'Aggiungi almeno un passo.';

  @override
  String get settimanaTipoAggiornata => 'Settimana tipo aggiornata.';

  @override
  String nellaSettimanaTipo(Object p0) {
    return '$p0 nella settimana tipo';
  }

  @override
  String aggiungo(Object p0) {
    return 'Aggiungo: $p0.';
  }

  @override
  String giornoRiposoNonTolgo(Object p0) {
    return '$p0 è un giorno di riposo: non tolgo niente.';
  }

  @override
  String get fargliPostoTolgoQuesto =>
      'Per fargli posto tolgo da questo giorno:';

  @override
  String get oppurePuoiTenerleFare =>
      'Oppure puoi tenerle e fare tutte e due le cose.';

  @override
  String get tieniEntrambe => 'Tieni entrambe';

  @override
  String get aggiungi => 'Aggiungi';

  @override
  String get sostituisci => 'Sostituisci';

  @override
  String get eliminareScheda => 'Eliminare la scheda?';

  @override
  String get seduteGiaFatteRestano =>
      'Le sedute già fatte restano. Da oggi tornano quelle preparate dall\'app.';

  @override
  String get uscireSenzaSalvare => 'Uscire senza salvare?';

  @override
  String get resta => 'Resta';

  @override
  String get scheda4 => 'Scheda';

  @override
  String get nomeScheda => 'Nome della scheda';

  @override
  String get esSchedaNovembre => 'Es. Scheda di novembre';

  @override
  String get fincheNonCambio => 'Finché non la cambio';

  @override
  String get inizio2 => 'Inizio';

  @override
  String get giorni => 'Giorni';

  @override
  String get ogniGiornoSchedaBusto =>
      'Ogni giorno della scheda (Busto, Gambe…) va nei giorni della settimana che scegli. Valgono quelli con la forza nella settimana tipo.';

  @override
  String ogniSedutaSchedaRipetute(Object p0) {
    return 'Ogni seduta della scheda (Ripetute, Lungo…) va nei giorni della settimana che scegli. Valgono quelli con $p0 nella settimana tipo.';
  }

  @override
  String nellaSettimanaTipoNon(Object p0, Object p1) {
    return '$p0: nella settimana tipo non c\'è $p1.';
  }

  @override
  String get modificaSettimana => 'Modifica settimana';

  @override
  String get aggiungiGiorno => 'Aggiungi un giorno';

  @override
  String get aggiungiSeduta => 'Aggiungi una seduta';

  @override
  String get salvaScheda => 'Salva la scheda';

  @override
  String get nomeGiorno => 'Nome del giorno';

  @override
  String get esBusto => 'Es. Busto';

  @override
  String get togliQuestoGiorno => 'Togli questo giorno';

  @override
  String get nessunEsercizio => 'Nessun esercizio.';

  @override
  String get nessunPasso => 'Nessun passo.';

  @override
  String get spostaGiu => 'Sposta giù';

  @override
  String get aggiungiEsercizio2 => 'Aggiungi esercizio';

  @override
  String get aggiungiPasso => 'Aggiungi un passo';

  @override
  String get serieMeno => 'Una serie in meno';

  @override
  String get seriePiu => 'Una serie in più';

  @override
  String get es10810 => 'Es. 10, 8-10, oppure 30 s per gli esercizi a tempo';

  @override
  String get recuperoSecondi => 'Recupero (secondi)';

  @override
  String get pesoTutteSerie20 =>
      'Un peso per tutte le serie (20), oppure uno per serie (20 22,5 25). Vuoto a corpo libero.';

  @override
  String get notePersonalTrainer => 'Note del personal trainer';

  @override
  String get esScendi3Secondi => 'Es. scendi in 3 secondi';

  @override
  String get esercizioNonCatalogo => 'Esercizio non in catalogo';

  @override
  String get scegliEsercizio => 'Scegli un esercizio';

  @override
  String get cercaEsLatPanca => 'Cerca (es. lat, panca, squat)';

  @override
  String get nonCScriviloMano => 'Non c\'è? Scrivilo a mano';

  @override
  String get principale => 'Principale';

  @override
  String get defaticamento => 'Defaticamento';

  @override
  String passo2(Object p0) {
    return 'Passo di $p0';
  }

  @override
  String get cosaFare => 'Cosa fare';

  @override
  String get esStileLiberoGambe => 'Es. Stile libero, gambe con tavoletta';

  @override
  String get esCorsaFacileRipetute => 'Es. Corsa facile, ripetute, salita';

  @override
  String get quanteVolte => 'Quante volte';

  @override
  String get meno3 => 'Una in meno';

  @override
  String get piu3 => 'Una in più';

  @override
  String get tempo2 => 'A tempo';

  @override
  String get distanza2 => 'A distanza';

  @override
  String get minuti2 => 'Minuti';

  @override
  String get es400 => 'Es. 400';

  @override
  String get es10Oppure1 => 'Es. 10, oppure 1,5';

  @override
  String get obiettivoPrincipale => 'Obiettivo principale';

  @override
  String get libera => 'Libera';

  @override
  String get watt => 'Watt';

  @override
  String get es150100 => 'Es. 1:50/100 m';

  @override
  String get es500Km => 'Es. 5:00/km';

  @override
  String get es200Oppure190 => 'Es. 200, oppure 190-210, oppure 88-94%';

  @override
  String get obiettivoSecondarioFacoltativo =>
      'Obiettivo secondario (facoltativo)';

  @override
  String get es8590Rpm => 'Es. 85-90 rpm';

  @override
  String get es170180Ppm => 'Es. 170-180 ppm';

  @override
  String get es40BracciateAl => 'Es. 40 bracciate al minuto';

  @override
  String get pausaBordoVascaDopo => 'Pausa a bordo vasca dopo ogni ripetizione';

  @override
  String get traRipetizioneAltraVuoto =>
      'Tra una ripetizione e l\'altra; vuoto se non c\'è';

  @override
  String get scriviMetri => 'Scrivi i metri.';

  @override
  String get scriviMinuti => 'Scrivi i minuti.';

  @override
  String get scriviWattEsempio200 =>
      'Scrivi i watt: per esempio 200, 190-210 o 88-94%.';

  @override
  String get sensoreCollegatoHoAcceso =>
      'Sensore collegato: ho acceso le funzioni avanzate.';

  @override
  String ricordato(Object p0) {
    return 'Ricordato: $p0';
  }

  @override
  String get collegaQuiSensoriBluetooth =>
      'Collega qui i sensori Bluetooth: li scegli una volta sola, poi si ricollegano da soli a ogni allenamento.';

  @override
  String get fasciaCardioOOrologio2 =>
      'Fascia cardio o orologio che trasmette il battito';

  @override
  String get rulloSmartPotenzaVelocita =>
      'Rullo smart, potenza, velocità e cadenza';

  @override
  String get bluetoothSiUsaSolo =>
      'Il Bluetooth si usa solo mentre questa pagina o l\'allenamento sono aperti.';

  @override
  String get togliEsercizio => 'Togli l\'esercizio';

  @override
  String get ripetizioniKg => 'Ripetizioni e kg';

  @override
  String get secondi => 'Secondi';

  @override
  String get togliSerie => 'Togli la serie';

  @override
  String get eserciziSerie => 'Esercizi e serie';

  @override
  String forza2(Object p0) {
    return 'Forza · $p0';
  }

  @override
  String get scriviCosaHaiFatto =>
      'Scrivi cosa hai fatto: ripetizioni e kg di ogni serie (kg vuoto = corpo libero), oppure il tempo per plank e tenute. Restano nello storico dell\'esercizio.';

  @override
  String get distanzaTotale => 'distanza totale';

  @override
  String get passoMedioMinKm => 'passo medio (min/km)';

  @override
  String get corsaPiuLunga => 'corsa più lunga';

  @override
  String get passoMigliore3Km => 'passo migliore (≥ 3 km)';

  @override
  String get fcMedia => 'FC media';

  @override
  String get kmSettimana => 'Km a settimana';

  @override
  String get passoUscitaMinKm => 'Passo per uscita (min/km)';

  @override
  String get distanzaUscitaKm => 'Distanza per uscita (km)';

  @override
  String get efficienzaAerobicaMetriBattito =>
      'Efficienza aerobica (metri per battito)';

  @override
  String get fcMediaUscitaBpm => 'FC media per uscita (bpm)';

  @override
  String get passoMedioMin100 => 'passo medio (min/100 m)';

  @override
  String get sessionePiuLunga => 'sessione più lunga';

  @override
  String get passoMigliore300M => 'passo migliore (≥ 300 m)';

  @override
  String get metriSettimana => 'Metri a settimana';

  @override
  String get passoSessioneMin100 => 'Passo per sessione (min/100 m)';

  @override
  String get metriSessione => 'Metri per sessione';

  @override
  String get fcMediaSessioneBpm => 'FC media per sessione (bpm)';

  @override
  String get velocitaMediaKmH => 'velocità media (km/h)';

  @override
  String get uscitaPiuLunga => 'uscita più lunga';

  @override
  String get velocitaMassimaMedia => 'velocità massima media';

  @override
  String get velocitaMediaUscitaKm => 'Velocità media per uscita (km/h)';

  @override
  String get durataMedia => 'durata media';

  @override
  String get sessioniSettimana => 'sessioni a settimana';

  @override
  String get sessioniSettimana2 => 'Sessioni a settimana';

  @override
  String get minutiSettimana => 'Minuti a settimana';

  @override
  String get durataSessioneMin => 'Durata per sessione (min)';

  @override
  String get vieBlocchiChiusi => 'vie e blocchi chiusi';

  @override
  String get metriSaliti => 'metri saliti';

  @override
  String get viaPiuDifficile => 'via più difficile';

  @override
  String get bloccoPiuDifficile => 'blocco più difficile';

  @override
  String get vieBlocchiChiusiSettimana => 'Vie e blocchi chiusi a settimana';

  @override
  String get gradoPiuDifficileVie => 'Grado più difficile: vie';

  @override
  String get gradoPiuDifficileBlocchi => 'Grado più difficile: blocchi';

  @override
  String get tipiSessione => 'Tipi di sessione';

  @override
  String fcBpm(Object p0) {
    return 'FC $p0 bpm';
  }

  @override
  String settimanaDal3(Object p0, Object p1, Object p2, Object p3) {
    return '$p0 $p1\nSettimana dal $p2$p3';
  }

  @override
  String get storicoPesoMisure => 'Storico di peso e misure';

  @override
  String get storicoMisure => 'Storico misure';

  @override
  String nessunValoreAncoraInserito(Object p0) {
    return 'Nessun valore di $p0 ancora inserito.';
  }

  @override
  String get almenoDueValoriComparira =>
      'Con almeno due valori comparirà il grafico.';

  @override
  String dal(Object p0) {
    return 'Dal $p0';
  }

  @override
  String invariato(Object p0) {
    return '$p0: invariato';
  }

  @override
  String get valoriInseriti => 'Valori inseriti';

  @override
  String get barraBasso => 'La barra in basso';

  @override
  String get quattroSezioniOggiProgressi =>
      'Quattro sezioni: Oggi, Progressi, Coach e Profilo. Puoi anche scorrere di lato per passare dall\'una all\'altra.';

  @override
  String get sedutaGiorno => 'La seduta del giorno';

  @override
  String get quiTroviCosaFare =>
      'Qui trovi cosa fare oggi. Tocca la seduta per vedere i dettagli e ▶ per l\'allenamento guidato passo passo, con timer, bip e GPS.';

  @override
  String get energia2 => 'L\'energia';

  @override
  String get comTuoRecuperoOggi =>
      'Com\'è il tuo recupero oggi, da sonno, battito a riposo e HRV. Toccala per i dettagli: se è bassa, meglio una seduta leggera.';

  @override
  String get compariraAltoDestraQuando =>
      'Comparirà in alto a destra quando l\'orologio manda sonno e battito a riposo (Profilo → Dati e collegamenti).';

  @override
  String get cerchioGiornoPienoSe =>
      'Un cerchio per giorno: pieno se fatto, col bordo se da fare. Tocca un giorno per vederlo sopra; scorri di lato sui cerchi per la settimana prima o dopo.';

  @override
  String get settimanaTipo => 'La settimana tipo';

  @override
  String get qualiGiorniTiAlleni2 =>
      'Quali giorni ti alleni, quale sport e per quanto tempo. Da qui nasce tutto il calendario: cambiala quando cambiano i tuoi impegni.';

  @override
  String get dopoOgniAllenamentoDai =>
      'Dopo ogni allenamento dai un voto alla fatica: le sedute dopo si adattano, più facili o più impegnative.';

  @override
  String get quandoAllenamentoFattoNon =>
      'Quando un allenamento fatto non ha ancora un voto, qui in Oggi compare \"Com\'è andata?\". Puoi darlo anche toccando la seduta fatta.';

  @override
  String get caricoAllenamentoGraficiResoconti =>
      'Il carico di allenamento, i grafici e i resoconti di ogni sport: tocca uno sport per i dettagli.';

  @override
  String get assistenteChiedigliConsigliSul =>
      'L\'assistente: chiedigli consigli sul piano o su come ti senti. Lo colleghi dalle impostazioni in alto (sul tuo PC o con la tua app).';

  @override
  String get seduteSchede => 'Sedute e schede';

  @override
  String get preparaSeduteAppScrive =>
      '\"Prepara le sedute\": l\'app scrive gli allenamenti per te. \"Le mie schede\": scrivi quelli del tuo personal trainer o allenatore.';

  @override
  String get collegaOrologioHealthConnect =>
      'Collega l\'orologio (Health Connect o intervals.icu) e fai il backup dei tuoi dati. Il giro lo ritrovi sempre qui sotto, in \"Giro guidato dell\'app\".';

  @override
  String get toccaAvantiContinuare => 'Tocca Avanti per continuare.';

  @override
  String get fine => 'Fine';

  @override
  String get vuoiGiroGuidatoDell =>
      'Vuoi un giro guidato dell\'app? Dieci passi, un minuto.';

  @override
  String get noGrazie => 'No, grazie';

  @override
  String get si => 'Sì';

  @override
  String get ultimoBlocco => 'Ultimo blocco';

  @override
  String poi2(Object p0) {
    return 'Poi: $p0';
  }

  @override
  String get recupero2 => 'di recupero';

  @override
  String get fineBlocco => 'a fine blocco';

  @override
  String get collegaRulloOMisuratore =>
      'Collega il rullo o il misuratore: vedrai potenza, cadenza e velocità.';

  @override
  String mediaWMassimoW(Object p0, Object p1) {
    return 'Media $p0 W · Massimo $p1 W';
  }

  @override
  String blocco(Object p0, Object p1) {
    return 'Blocco $p0 di $p1';
  }

  @override
  String get siParte2 => 'Si parte';

  @override
  String fineTra(Object p0) {
    return 'Fine tra $p0';
  }

  @override
  String get rulloErg => 'Rullo in ERG';

  @override
  String get rulloLibero => 'Rullo libero';

  @override
  String get senzaObiettivo2 => 'senza obiettivo';

  @override
  String tieneW(Object p0) {
    return 'tiene $p0 W';
  }

  @override
  String get wattLiDecidiTu => 'i watt li decidi tu';

  @override
  String get n5Meno => '5% in meno';

  @override
  String get n5Piu => '5% in più';

  @override
  String get riportareSettimanaNelCalendario =>
      'Riportare la settimana nel calendario?';

  @override
  String get giorniOggiPoiDiventano =>
      'I giorni da oggi in poi diventano uguali alla settimana tipo: le modifiche fatte a mano su quei giorni vengono sostituite. I giorni già fatti restano.';

  @override
  String get riporta => 'Riporta';

  @override
  String get settimanaSalvataCalendarioVuoto =>
      'Settimana salvata. Il calendario è vuoto: allungalo da Oggi.';

  @override
  String get settimanaSalvata => 'Settimana salvata.';

  @override
  String calendarioAggiornatoOggiAl(Object p0, Object p1, Object p2) {
    return 'Calendario aggiornato: $p0 $p1 da oggi al $p2.';
  }

  @override
  String get settimanaTipo2 => 'Settimana tipo';

  @override
  String get scegliCosaFaiQuale =>
      'Scegli cosa fai e in quale giorno. I cambi valgono subito nel calendario, da oggi in poi; i giorni già fatti non cambiano.';

  @override
  String get portaTuttaSettimanaNel =>
      'Porta tutta la settimana nel calendario';

  @override
  String get rifaGiorniOggiPoi =>
      'Rifà i giorni da oggi in poi uguali alla settimana tipo. Utile se il calendario non corrisponde più.';

  @override
  String get aggiungiSessione => 'Aggiungi sessione';

  @override
  String get nessunaSessione => 'Nessuna sessione';

  @override
  String get sport => 'Sport';

  @override
  String get fascia => 'Fascia';

  @override
  String get tipoSessioneFacoltativo => 'Tipo di sessione (facoltativo)';

  @override
  String get durataMinuti => 'Durata (minuti)';

  @override
  String get haiFattoAllenamentoDiverso =>
      'Hai fatto un allenamento diverso da quello in programma: il feedback vale per quello che hai fatto davvero.';

  @override
  String get tuoFeedbackRegolaProssime =>
      'Il tuo feedback regola le prossime sessioni.';

  @override
  String get serveCalcolareCaricoAllenamento =>
      'Serve a calcolare il carico di allenamento.';

  @override
  String get completata => 'Completata';

  @override
  String get nonCompletata => 'Non completata';

  @override
  String get doloreSegnalato => 'dolore segnalato';

  @override
  String get rispondi => 'Rispondi';

  @override
  String get hoGiaFattaScrivi => 'L\'ho già fatta: scrivi i dati';

  @override
  String get tiGuidoEsercizioEsercizio =>
      'Ti guido esercizio per esercizio: tocchi \"Fatto\" quando finisci, i recuperi e le parti a tempo li conto io.';

  @override
  String allenamentoPrevisto(Object p0) {
    return 'Allenamento previsto: $p0';
  }

  @override
  String durataTotaleMin(Object p0) {
    return 'Durata totale: $p0 min';
  }

  @override
  String comeTiDeviSentire(Object p0) {
    return 'Come ti devi sentire: $p0';
  }

  @override
  String get iniziaAllenamento => 'Inizia allenamento';

  @override
  String muscoliSessioneToccaEsercizio(Object p0) {
    return 'Muscoli della sessione: $p0. Tocca un esercizio per vedere i suoi, la freccia per come si fa.';
  }

  @override
  String cos(Object p0) {
    return 'Cos\'è: $p0';
  }

  @override
  String get sedutaArrampicata => 'Seduta di arrampicata';

  @override
  String get scegliUnoDeiTuoi =>
      'Scegli uno dei tuoi allenamenti o chiedilo all\'assistente. Puoi anche partire e segnare vie e gradi alla fine.';

  @override
  String get iniziaSeduta => 'Inizia la seduta';

  @override
  String get scegliAllenamento => 'Scegli un allenamento';

  @override
  String get questaSedutaNonHa => 'Questa seduta non ha ancora esercizi';

  @override
  String get sedutaLibera => 'Seduta libera';

  @override
  String get faiPreparareAllApp =>
      'Fai preparare all\'app la forza: sceglie gli esercizi adatti a te e alla tua attrezzatura. Ci vuole un minuto.';

  @override
  String faiPreparareAllApp2(Object p0) {
    return 'Fai preparare all\'app le sedute di $p0: ognuna con le sue indicazioni passo passo.';
  }

  @override
  String get tempoHai => 'il tempo che hai';

  @override
  String muovitiRitmoFacileDevi(Object p0) {
    return 'Muoviti per $p0 a ritmo facile: devi riuscire a parlare.';
  }

  @override
  String preparaSedute2(Object p0) {
    return 'Prepara le sedute di $p0';
  }

  @override
  String get invioIntervalsIcu => 'Invio a intervals.icu…';

  @override
  String get questaSessioneAppNon =>
      'Per questa sessione l\'app non ha un percorso GPS.';

  @override
  String get salvaPercorso => 'Salva il percorso';

  @override
  String get gpxSalvatoPuoiCaricarlo =>
      'GPX salvato: puoi caricarlo su Strava o Garmin Connect.';

  @override
  String gpxNonSalvato(Object p0) {
    return 'GPX non salvato: $p0';
  }

  @override
  String get eliminareSessione => 'Eliminare la sessione?';

  @override
  String get nonTorneraSincronizzazioneNell =>
      ' Non tornerà con la sincronizzazione; nell\'app dell\'orologio resta com\'è.';

  @override
  String sparisceDalCalendarioDai(Object p0) {
    return 'Sparisce dal calendario, dai Progressi e dal carico, insieme al suo \"Com\'è andata?\".$p0';
  }

  @override
  String get sessioneEliminata => 'Sessione eliminata';

  @override
  String get orario => 'Orario';

  @override
  String m(Object p0, Object p1) {
    return '$p0 da $p1 m';
  }

  @override
  String get ritmoMedio => 'Ritmo medio';

  @override
  String get calorieAttiveStima => 'Calorie attive (stima)';

  @override
  String get calorieTotaliStima => 'Calorie totali (stima)';

  @override
  String get potenzaMedia => 'Potenza media';

  @override
  String get cadenzaMedia => 'Cadenza media';

  @override
  String get faticaRpe => 'Fatica (RPE)';

  @override
  String fonteCorrettaMano(Object p0) {
    return 'Fonte: $p0 · corretta a mano';
  }

  @override
  String fonte(Object p0) {
    return 'Fonte: $p0';
  }

  @override
  String get sulleVie => 'sulle vie';

  @override
  String get nelBoulder => 'nel boulder';

  @override
  String record2(Object p0, Object p1, Object p2, Object p3, Object p4) {
    return 'Record $p0: $p1 ($p2 $p3 $p4)';
  }

  @override
  String get grafici2 => 'Grafici';

  @override
  String get inviaIntervalsIcu => 'Invia a intervals.icu';

  @override
  String get salvaGpx => 'Salva GPX';

  @override
  String get suIntervalsIcu => 'Su intervals.icu';

  @override
  String get parteSolaIntervalsIcu =>
      'Parte da sola per intervals.icu appena c\'è rete';

  @override
  String get previstoFatto => 'Previsto e fatto';

  @override
  String fasceColorateSonoIntensita(Object p0) {
    return 'Le fasce colorate sono l\'intensità da tenere blocco per blocco, la linea quella che hai tenuto: dentro la fascia eri nell\'obiettivo, sopra andavi più forte, sotto più piano.$p0';
  }

  @override
  String get doveObiettivoEraZona =>
      ' Dove l\'obiettivo era una zona si guarda il battito, dove era un passo si guarda il passo.';

  @override
  String get siGuardaPasso => ' Si guarda il passo.';

  @override
  String get siGuardaBattito => ' Si guarda il battito.';

  @override
  String tenere(Object p0) {
    return 'Da tenere $p0';
  }

  @override
  String get fuoriProgramma => 'Fuori programma';

  @override
  String get intervalliCorrettiMano => 'Intervalli (corretti a mano)';

  @override
  String get sensoreBici => 'Sensore bici';

  @override
  String get altitudinePendenza => 'Altitudine e pendenza';

  @override
  String get altitudinePendenzaPotenza => 'Altitudine, pendenza e potenza';

  @override
  String nonCiSonoAverle(Object p0) {
    return '$p0 non ci sono: per averle collega intervals.icu (Profilo → Dati e collegamenti).';
  }

  @override
  String chilometriAllOra(Object p0) {
    return '$p0 chilometri all\'ora';
  }

  @override
  String minutiAlChilometro(Object p0) {
    return '$p0 minuti al chilometro';
  }

  @override
  String alChilometro(Object p0, Object p1) {
    return '$p0 e $p1 al chilometro';
  }

  @override
  String chilometro(Object p0, Object p1) {
    return 'Chilometro $p0. $p1.';
  }

  @override
  String chilometroUltimi(Object p0, Object p1, Object p2, Object p3) {
    return 'Chilometro $p0. Ultimi $p1 in $p2, $p3.';
  }

  @override
  String get piu4 => ' più';

  @override
  String daA(Object p0, Object p1) {
    return 'da $p0 a $p1';
  }

  @override
  String get su102 => ' su 10';

  @override
  String get giriAlMinuto => 'giri al minuto';

  @override
  String get recupero3 => 'Recupero.';

  @override
  String recupero4(Object p0) {
    return 'Recupero, $p0.';
  }

  @override
  String ora(Object p0) {
    return 'Ora: $p0';
  }

  @override
  String zonaRallenta(Object p0) {
    return 'Zona $p0, rallenta.';
  }

  @override
  String zonaPuoiSpingerePo(Object p0) {
    return 'Zona $p0, puoi spingere un po\' di più.';
  }

  @override
  String rallentaPo(Object p0, Object p1) {
    return '$p0 $p1, rallenta un po\'.';
  }

  @override
  String acceleraPo(Object p0, Object p1) {
    return '$p0 $p1, accelera un po\'.';
  }

  @override
  String fatto2(Object p0) {
    return 'Fatto: $p0';
  }

  @override
  String get ancheRiposoAllenamento => 'Anche il riposo è allenamento';

  @override
  String get alternaRecupero6Volte => 'Alterna con il recupero, 6 volte';

  @override
  String get recuperoCorricchiando => 'Recupero corricchiando';

  @override
  String get corsaLentaContinua => 'Corsa lenta continua';

  @override
  String get restaZona2Tutta => 'Resta in zona 2 per tutta la durata';

  @override
  String get piscinaBase1150M => 'Piscina Base (1150 m, vasca 25 m)';

  @override
  String get stileScelta => 'Stile a scelta';

  @override
  String get stileLiberoGambeTavoletta => 'Stile libero, gambe con tavoletta';

  @override
  String get tavolettaFront => 'Tavoletta front';

  @override
  String get dorsoGambeTavoletta => 'Dorso, gambe con tavoletta';

  @override
  String get tavolettaDorso => 'Tavoletta dorso';

  @override
  String get stileLiberoBracciaPull => 'Stile libero, braccia con pull buoy';

  @override
  String get n25MSoloBraccio =>
      '25 m solo braccio DX, 25 m solo braccio SX, 50 m alternato';

  @override
  String get dorsoDoppioGambeRana => 'Dorso doppio, gambe rana';

  @override
  String get parolaTolta => 'tolta';

  @override
  String get parolaTolte => 'tolte';

  @override
  String get parolaSessione => 'sessione';

  @override
  String get parolaSessioni => 'sessioni';

  @override
  String get parolaRulli => 'rulli';

  @override
  String get parolaTapisRoulant => 'tapis roulant';

  @override
  String get parolaNessuno => 'nessuno';

  @override
  String get parolaGennaio => 'gennaio';

  @override
  String get parolaFebbraio => 'febbraio';

  @override
  String get parolaMarzo => 'marzo';

  @override
  String get parolaAprile => 'aprile';

  @override
  String get parolaMaggio => 'maggio';

  @override
  String get parolaGiugno => 'giugno';

  @override
  String get parolaLuglio => 'luglio';

  @override
  String get parolaAgosto => 'agosto';

  @override
  String get parolaSettembre => 'settembre';

  @override
  String get parolaOttobre => 'ottobre';

  @override
  String get parolaNovembre => 'novembre';

  @override
  String get parolaDicembre => 'dicembre';

  @override
  String get parolaChilometro => 'chilometro';

  @override
  String get parolaChilometri => 'chilometri';

  @override
  String get parolaOre => 'ore';

  @override
  String get parolaMinuti => 'minuti';

  @override
  String get parolaFatto => 'fatto';

  @override
  String get parolaOggi => 'oggi';

  @override
  String get parolaDomani => 'domani';

  @override
  String get parolaIeri => 'ieri';

  @override
  String get parolaMese => 'mese';

  @override
  String get parolaMesi => 'mesi';

  @override
  String get parolaSedute => 'sedute';

  @override
  String get parolaVolta => 'volta';

  @override
  String get parolaVolte => 'volte';

  @override
  String get parolaSeduta => 'seduta';

  @override
  String get parolaMancano => 'mancano';

  @override
  String get parolaLeggera => 'leggera';

  @override
  String get parolaModerata => 'moderata';

  @override
  String get parolaImpegnativa => 'impegnativa';

  @override
  String get parolaAllenamento => 'allenamento';

  @override
  String get parolaAllenamenti => 'allenamenti';

  @override
  String get parolaPercorsi => 'percorsi';

  @override
  String get parolaUscite => 'uscite';

  @override
  String get parolaPassati => 'passati';

  @override
  String get parolaGiorno => 'giorno';

  @override
  String get parolaGiorni => 'giorni';

  @override
  String get parolaSecondo => 'secondo';

  @override
  String get parolaSecondi => 'secondi';

  @override
  String get parolaMinuto => 'minuto';

  @override
  String get parolaOra => 'ora';

  @override
  String get parolaMetro => 'metro';

  @override
  String get parolaMetri => 'metri';

  @override
  String get glossarioRecupero => 'Recupero';

  @override
  String get glossarioMobilita => 'Mobilità';

  @override
  String get widgetOggi => 'OGGI';

  @override
  String get widgetApri => 'Apri l\'app per vedere il piano';

  @override
  String get widgetNessuno => 'Nessun allenamento questa settimana';

  @override
  String widgetFatti(Object fatti, Object totale) {
    return '$fatti di $totale fatti questa settimana';
  }

  @override
  String get widgetLettere => 'L,M,M,G,V,S,D';

  @override
  String get notificaCanale => 'Allenamento in corso';

  @override
  String get notificaAllenamento => 'Allenamento';

  @override
  String get lingua => 'Lingua';

  @override
  String get linguaTitolo => 'Scegli la lingua';

  @override
  String get linguaSpiega =>
      'Potrai cambiarla quando vuoi dal Profilo. I dati che hai già scritto restano come sono.';

  @override
  String get linguaSotto => 'Italiano, inglese o greco';

  @override
  String get sostieniProgetto => 'Sostieni il progetto';

  @override
  String get sostieniSotto =>
      'Una donazione aiuta lo sviluppo. Non sblocca nulla: l\'app è tutta gratuita.';

  @override
  String get linkNonAperto => 'Non riesco ad aprire il link.';

  @override
  String battitiAlMinuto(Object p0) {
    return '$p0 battiti/min';
  }

  @override
  String giraVerso(Object p0) {
    return 'gira $p0';
  }

  @override
  String mancanoAncora(Object p0) {
    return 'mancano $p0';
  }

  @override
  String recuperoDi(Object p0) {
    return 'recupero $p0';
  }

  @override
  String quanteSerie(Object p0) {
    return '$p0 serie';
  }

  @override
  String quanteRipetizioni(Object p0) {
    return '$p0 ripetizioni';
  }

  @override
  String quanteAggiornate(Object p0) {
    return '$p0 aggiornate';
  }

  @override
  String quanteRimosse(Object p0) {
    return '$p0 rimosse';
  }

  @override
  String aggiornato(Object p0) {
    return '$p0 aggiornato';
  }

  @override
  String quantiChili(Object p0) {
    return '$p0 chili';
  }

  @override
  String unoEAltro(Object p0, Object p1) {
    return '$p0 e $p1';
  }

  @override
  String quantiWatt(Object p0) {
    return '$p0 watt';
  }

  @override
  String quantiMetri(Object p0) {
    return '$p0 metri';
  }

  @override
  String connesso(Object p0) {
    return '$p0 connesso';
  }

  @override
  String passoDiTour(Object p0, Object p1) {
    return '$p0 di $p1';
  }

  @override
  String quantiEsercizi(Object p0) {
    return '$p0 esercizi';
  }

  @override
  String backupSessioni(Object p0) {
    return '$p0 sessioni';
  }

  @override
  String backupMisure(Object p0) {
    return '$p0 misure';
  }

  @override
  String backupFeedback(Object p0) {
    return '$p0 feedback';
  }

  @override
  String quantiGiorni(Object p0) {
    return '$p0 giorni';
  }

  @override
  String quanteOre(Object p0) {
    return '$p0 ore';
  }

  @override
  String quantiMinuti(Object p0) {
    return '$p0 minuti';
  }

  @override
  String quanteSedute(Object p0) {
    return '$p0 sedute';
  }

  @override
  String quanteProvate(Object p0, Object p1) {
    return '$p0 provat$p1';
  }

  @override
  String quantiPunti(Object p0) {
    return '$p0 punti';
  }

  @override
  String get parolaZona => 'zona';

  @override
  String poiCurva(Object p0) {
    return 'poi $p0';
  }

  @override
  String get linguaVoce => 'Lingua della voce';

  @override
  String get linguaVoceComeApp => 'Come l\'app';

  @override
  String get linguaVoceComeTelefono => 'Come il telefono';

  @override
  String get linguaVoceSpiega =>
      'Indicazioni stradali, km, ritmo e zone. In una lingua diversa da quella dell\'app, i nomi degli esercizi restano nella lingua dell\'app.';

  @override
  String voceNonInstallata(Object p0) {
    return 'La voce in $p0 non è installata sul telefono: installala dalle impostazioni della sintesi vocale, poi riprova.';
  }

  @override
  String get installaVoce => 'Installa la voce';

  @override
  String get provaVoce => 'Prova la voce';

  @override
  String get oppure => ' o ';

  @override
  String get mPerBattito => 'm/battito';

  @override
  String get parolaSettimana => 'settimana';

  @override
  String get parolaRecupero => 'Recupero';

  @override
  String get assistenteTitolo => 'Assistente';

  @override
  String get etichettaRecupero => 'recupero';

  @override
  String get passiDuranteAllenamento => 'Passi durante l\'allenamento';

  @override
  String get soloCorsaCamminataPassi =>
      'Solo per corsa e camminata, e solo mentre la modalità allenamento è aperta, l\'app legge il contapassi del telefono (permesso \"Attività fisica\") per mostrarti i passi e i passi al minuto. Nella sessione salva il totale dei passi fatti a cronometro acceso: resta sul telefono e nel backup. Chiuso l\'allenamento l\'app non legge più il sensore. Senza il permesso l\'allenamento funziona lo stesso, solo senza passi.';

  @override
  String quantiPassi(Object p0) {
    return '$p0 passi';
  }

  @override
  String get passiDalTelefono => 'Passi dal telefono';

  @override
  String get passiDalTelefonoSpiega =>
      'In corsa e camminata l\'app conta i passi con il sensore del telefono (permesso \"Attività fisica\"), anche senza orologio.';

  @override
  String get permessoPassiNegato =>
      'Il permesso \"Attività fisica\" non è concesso: puoi darlo dalle impostazioni dell\'app, alla voce Permessi.';

  @override
  String get intervalliFatti => 'Intervalli';

  @override
  String get tsPedalataFacile => 'Pedalata facile';

  @override
  String get tsPedalaSciolto => 'Pedala sciolto. Il test vero comincia dopo.';

  @override
  String tsGradinoRampa(Object p0) {
    return 'Rampa: gradino $p0';
  }

  @override
  String get tsRampaNota =>
      'Ogni minuto un po\' più duro. Vai avanti finché non riesci più a tenere la cadenza: poi tocca Avanti fino al defaticamento.';

  @override
  String get tsRisultatoNeiGrafici =>
      'Il risultato lo trovi nei grafici di questa uscita.';

  @override
  String get tsMinutiSvelti => 'Minuti svelti';

  @override
  String get tsMinutiSveltiNota =>
      'Svelti ma non al massimo: svegliano le gambe.';

  @override
  String get tsVentiSenzaFtp =>
      'Il ritmo più forte che riesci a tenere fino alla fine, costante. Parti un po\' piano e chiudi in crescendo.';

  @override
  String tsVentiConFtp(Object p0) {
    return 'Parti intorno a $p0 W e tienili: se dopo 10 minuti stai bene, alza un po\'. Chiudi in crescendo.';
  }

  @override
  String get tsStileSceltaFacile => 'Stile a scelta, facile';

  @override
  String get tsStileLiberoProgressione => 'Stile libero in progressione';

  @override
  String get tsOgni50Svelto => 'Ogni 50 m un po\' più svelto.';

  @override
  String get tsTest400 => 'Test: 400 m al massimo';

  @override
  String get tsTest400Nota =>
      'Il più veloce che riesci a tenere, costante, senza partire troppo forte. Segnati il tempo.';

  @override
  String get tsTest200 => 'Test: 200 m al massimo';

  @override
  String get tsTest200Nota =>
      'Il più veloce che riesci a tenere. Segnati il tempo, poi scrivi i due tempi in Profilo → Le mie zone.';

  @override
  String get tsMancaFtp =>
      'Non sappiamo ancora il tuo FTP: senza, le sedute vanno a sensazione.';

  @override
  String get tsMancaPasso =>
      'Non sappiamo ancora il tuo passo critico: senza, le sedute vanno a sensazione.';

  @override
  String get tsVecchioFtp =>
      'Il tuo FTP non si aggiorna da più di 8 settimane: nel frattempo potresti essere migliorato.';

  @override
  String get tsVecchioPasso =>
      'Il tuo passo critico non si aggiorna da più di 8 settimane: nel frattempo potresti essere migliorato.';

  @override
  String get tsTroppoFacile =>
      'Gli ultimi intervalli ti sono sembrati facili: forse l\'FTP è più alto.';

  @override
  String get tsTroppoDuro =>
      'Gli ultimi intervalli non sei riuscito a finirli: forse l\'FTP è troppo alto.';

  @override
  String get tsTestFtpBici => 'Test FTP in bici';

  @override
  String get tsRulloSmart => 'Rullo smart';

  @override
  String get tsSuStrada => 'Su strada';

  @override
  String get tsRampaTesto1 =>
      '10 minuti facili, poi una rampa: ogni minuto il rullo chiede qualche watt in più, finché non ce la fai più. Circa 25 minuti in tutto.';

  @override
  String get tsRampaTesto2 =>
      'Il rullo in ERG tiene i watt da solo: non serve sapere quanto spingere. L\'FTP è il 75% del tuo minuto migliore.';

  @override
  String get tsVentiTesto1 =>
      'Riscaldamento con 3 minuti svelti, poi 20 minuti al massimo che riesci a tenere, poi 10 minuti sciolti. Circa 55 minuti.';

  @override
  String get tsVentiTesto2Senza =>
      'Senza un FTP si va a sensazione: parti un po\' piano e chiudi in crescendo. Serve un sensore di potenza.';

  @override
  String tsVentiTesto2Con(Object p0) {
    return 'Si parte intorno al tuo FTP di adesso ($p0 W). Serve un sensore di potenza.';
  }

  @override
  String get tsVentiTesto3 => 'L\'FTP è il 95% della media dei 20 minuti.';

  @override
  String get tsNuotoTesto1 =>
      'Riscaldamento, poi 400 m al massimo che riesci a tenere, 5 minuti di pausa e 200 m al massimo. Circa 1300 m in tutto.';

  @override
  String get tsNuotoTesto2 =>
      'Segnati i due tempi (l\'orologio o il cronometro della piscina): il passo critico è la differenza divisa per 2.';

  @override
  String get tsHoFattoTest => 'Ho fatto il test: scrivi i tempi';

  @override
  String get tsTempiTest => 'I tempi del test';

  @override
  String get tsEs400 => 'm:ss, es. 8:20';

  @override
  String get tsEs200 => 'm:ss, es. 3:55';

  @override
  String get tsCalcola => 'Calcola';

  @override
  String get tsControllaTempi =>
      'Controlla i tempi (m:ss): il 400 deve essere almeno quasi il doppio del 200.';

  @override
  String tsPassoSalvato(Object p0) {
    return 'Passo critico: $p0. Salvato.';
  }

  @override
  String tsTestNelCalendario(Object p0) {
    return 'Test nel calendario: $p0. Prende il posto della seduta di quel giorno.';
  }

  @override
  String get tsSeNonSaiTest => 'Se non lo sai, fai il test qui sotto.';

  @override
  String get tsFaiTestCalcolarlo => 'Fai il test per calcolarlo';

  @override
  String tsUsciteDicono(Object p0) {
    return 'Le tue uscite dicono $p0 W';
  }

  @override
  String tsDalTest(Object p0) {
    return 'Dal test del $p0.';
  }

  @override
  String tsHaiTenuto(Object p0, Object p1, Object p2) {
    return 'Il $p0 hai tenuto $p1 W per 20 minuti: il tuo FTP è almeno $p2 W.';
  }

  @override
  String get tsUsaloComeFtp => 'Usalo come FTP';

  @override
  String tsTuoFtp(Object p0) {
    return 'Il tuo FTP: $p0 W';
  }

  @override
  String tsComeRampa(Object p0) {
    return 'È il 75% del tuo minuto migliore nella rampa ($p0 W).';
  }

  @override
  String tsComeVenti(Object p0) {
    return 'È il 95% dei tuoi 20 minuti del test ($p0 W di media).';
  }

  @override
  String tsComeUscita(Object p0) {
    return 'È il 95% dei tuoi migliori 20 minuti ($p0 W). Senza un test dice solo che sei almeno a questo livello.';
  }

  @override
  String tsAdessoUsi(Object p0) {
    return 'Adesso usi $p0 W.';
  }

  @override
  String tsPropostaPrima(Object p0) {
    return 'Dalle tue uscite il tuo FTP in bici è almeno $p0 W. Lo uso per le zone?';
  }

  @override
  String tsPropostaSalito(Object p0, Object p1) {
    return 'Le tue uscite dicono che il tuo FTP in bici è salito: $p0 W (prima $p1). Lo aggiorno?';
  }

  @override
  String get tsAggiorna => 'Aggiorna';

  @override
  String get tsTestRampaRullo => 'Test FTP a rampa sul rullo';

  @override
  String get tsTestNuotoPiscina => 'Test del passo critico in piscina';

  @override
  String tsPropostaTest(Object p0, Object p1, Object p2) {
    return '$p0 $p1: $p2?';
  }

  @override
  String tsPropostaTestAlPosto(Object p0, Object p1, Object p2, Object p3) {
    return '$p0 $p1: $p2, al posto di $p3?';
  }

  @override
  String get tsMettilo => 'Mettilo';

  @override
  String tsTestNelCalendarioBreve(Object p0) {
    return 'Test nel calendario: $p0.';
  }

  @override
  String get tsNonRiuscito => 'Non sono riuscito a metterlo nel calendario.';

  @override
  String get webhookTitolo => 'Webhook';

  @override
  String get webhookSottotitolo =>
      'Manda i tuoi allenamenti a un indirizzo web tuo (Home Assistant, n8n, Node-RED…)';

  @override
  String get webhookSpiegazione =>
      'A ogni allenamento finito, piano cambiato o record nuovo l\'app manda un messaggio all\'indirizzo che scegli tu, così i dati arrivano nei tuoi pannelli. Nessun server nostro: l\'indirizzo è tuo.';

  @override
  String get webhookAttivo => 'Invia i dati al webhook';

  @override
  String get webhookSpento => 'Spento: non parte niente.';

  @override
  String get webhookAcceso => 'Acceso';

  @override
  String get webhookIndirizzo => 'Indirizzo (URL)';

  @override
  String get webhookUrlNonValido =>
      'Serve un indirizzo completo che inizi con https://';

  @override
  String get webhookChiave => 'Chiave segreta (facoltativa)';

  @override
  String get webhookChiaveAiuto =>
      'Con la chiave ogni messaggio ha una firma: chi lo riceve controlla che arrivi davvero dalla tua app.';

  @override
  String get webhookGenera => 'Genera';

  @override
  String get webhookCopia => 'Copia la chiave';

  @override
  String get webhookChiaveCopiata => 'Chiave copiata';

  @override
  String get webhookMostraChiave => 'Mostra o nascondi la chiave';

  @override
  String get webhookSalva => 'Salva';

  @override
  String get webhookSalvato => 'Webhook salvato';

  @override
  String get webhookPrimaUrl => 'Prima scrivi e salva un indirizzo https://';

  @override
  String get webhookCosaInviare => 'Cosa inviare';

  @override
  String get webhookEventoAllenamento => 'Allenamento completato';

  @override
  String get webhookEventoAllenamentoSotto =>
      'Data, sport, durata, distanza, battito, watt, esercizi, serie e carichi';

  @override
  String get webhookEventoPiano => 'Piano aggiornato';

  @override
  String get webhookEventoPianoSotto =>
      'Le sedute in programma, quando cambiano';

  @override
  String get webhookEventoRecord => 'Nuovo record';

  @override
  String get webhookEventoRecordSotto =>
      'Più kg in un esercizio o la distanza più lunga in uno sport';

  @override
  String get webhookQualiAllenamenti => 'Quali allenamenti';

  @override
  String get webhookSoloApp => 'Solo quelli registrati con l\'app';

  @override
  String get webhookTutti => 'Anche quelli importati';

  @override
  String get webhookTuttiSotto =>
      'Da Health Connect, intervals.icu e CSV, compresi quelli già salvati';

  @override
  String get webhookSceltaTitolo => 'Quali allenamenti inviare?';

  @override
  String webhookSceltaTesto(Object p0) {
    return 'Puoi mandare solo quelli che registri con l\'app, oppure anche quelli che arrivano da Health Connect, intervals.icu e dai CSV. Con la seconda scelta partono anche quelli già salvati (ora sono $p0): possono essere centinaia, e il primo invio può richiedere un po\'. Partono uno alla volta, anche con l\'app chiusa.';
  }

  @override
  String get webhookInviaTest => 'Invia test';

  @override
  String webhookTestOk(Object p0) {
    return 'Test riuscito: risposta HTTP $p0';
  }

  @override
  String webhookTestErrore(Object p0) {
    return 'Test non riuscito: $p0';
  }

  @override
  String webhookCodiceHttp(Object p0) {
    return 'risposta HTTP $p0';
  }

  @override
  String get webhookErroreTimeout => 'nessuna risposta entro 10 secondi';

  @override
  String get webhookErroreRete => 'rete non raggiungibile';

  @override
  String get webhookErroreAltro =>
      'connessione non riuscita (certificato o indirizzo)';

  @override
  String get webhookErroreScaduto => 'messaggio troppo vecchio, scartato';

  @override
  String get webhookStato => 'Stato';

  @override
  String webhookUltimoOk(Object p0, Object p1, Object p2) {
    return 'Ultimo invio riuscito: $p0 alle $p1:$p2';
  }

  @override
  String get webhookMaiInviato => 'Ancora nessun invio riuscito';

  @override
  String webhookUltimoErrore(Object p0, Object p1, Object p2, Object p3) {
    return 'Ultimo errore: $p0 alle $p1:$p2, $p3';
  }

  @override
  String webhookInCoda(Object p0) {
    return 'Messaggi in coda: $p0';
  }

  @override
  String webhookScartati(Object p0) {
    return 'Messaggi scartati: $p0';
  }

  @override
  String get webhookComeFunziona => 'Come funziona';

  @override
  String get webhookComeFunzionaTesto =>
      'Ogni messaggio è una richiesta POST con un JSON. Se non arriva (niente rete, server spento) resta in coda e l\'app ritenta dopo 1, 5 e 15 minuti, poi ogni ora, anche ad app chiusa appena torna la rete: al massimo 10 volte o 7 giorni. Gli errori 4xx (indirizzo o chiave sbagliati) non si ritentano. Formato ed esempi in docs/WEBHOOK.md, nel repository dell\'app su GitHub.';

  @override
  String get webhookFacoltativo => 'Webhook (facoltativo)';

  @override
  String get webhookPrivacy =>
      'Solo se accendi il webhook e scrivi un indirizzo https, l\'app manda a quell\'indirizzo, scelto e gestito da te, i dati degli eventi che spunti: allenamenti fatti (data, orari, sport, nome, durata, distanza, battito, watt, cadenza, passi, calorie, RPE, note, esercizi con serie e kg), sedute in programma e record. Niente nome, foto, misure del corpo o percorsi GPS. Indirizzo e chiave segreta restano cifrati sul telefono e non entrano nel backup. Chi riceve i dati è il servizio che hai scelto tu, con le sue condizioni sulla privacy. Spegnendolo non parte più niente e la coda si svuota.';

  @override
  String get aggiornamentiApp => 'Aggiornamenti dell\'app';

  @override
  String get aggiornamentiAppSotto =>
      'Controlla ogni giorno su GitHub. Tocca per cercare ora';

  @override
  String nuovaVersione(Object p0) {
    return 'È uscita la versione $p0';
  }

  @override
  String get aggiornamentoSpiegazione =>
      'Si installa sopra l\'app che hai: dati e impostazioni restano. Android ti chiederà di confermare.';

  @override
  String get novitaVersione => 'Novità';

  @override
  String get aggiornaApp => 'Aggiorna';

  @override
  String get scaricoAggiornamento => 'Scarico l\'aggiornamento…';

  @override
  String get aggiornamentoPermesso =>
      'Senza il permesso di installare app l\'aggiornamento non può partire. Puoi darlo la prossima volta che tocchi Aggiorna.';

  @override
  String get aggiornamentoRete =>
      'Download non riuscito: controlla la connessione e riprova.';

  @override
  String get aggiornamentoImpronta =>
      'Il file scaricato non è identico a quello pubblicato: non l\'ho installato.';

  @override
  String get aggiornamentoErrore =>
      'Aggiornamento non riuscito. Puoi scaricare l\'APK dalla pagina Releases su GitHub.';

  @override
  String get aggiornamentoAnnullato => 'Aggiornamento annullato.';

  @override
  String haiUltimaVersione(Object p0) {
    return 'Hai già l\'ultima versione ($p0).';
  }

  @override
  String get githubNonRisponde => 'GitHub non risponde: riprova più tardi.';

  @override
  String get aggiornamentiPrivacy =>
      'Una volta al giorno, all\'apertura, l\'app chiede a GitHub (api.github.com) qual è l\'ultima versione pubblicata. Se tocchi Aggiorna, scarica l\'APK da GitHub nella sua memoria temporanea, controlla che sia identico a quello pubblicato, lo passa all\'installatore di Android e lo cancella: sul telefono non restano file. GitHub riceve l\'indirizzo IP del telefono e la versione chiesta, nient\'altro. Puoi spegnere il controllo dal Profilo, alla voce Aggiornamenti dell\'app.';
}
