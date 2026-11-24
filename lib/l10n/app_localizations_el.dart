// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get tenuto => 'Στον ρυθμό';

  @override
  String get poPiuLento => 'Λίγο πιο αργά';

  @override
  String get moltoPiuLento => 'Πολύ πιο αργά';

  @override
  String principaleInvece(Object p0, Object p1) {
    return 'κύριο μέρος $p0 αντί για $p1';
  }

  @override
  String passoInvece(Object p0, Object p1) {
    return 'ρυθμός $p0 αντί για $p1';
  }

  @override
  String intensitaInvece(Object p0, Object p1) {
    return 'ένταση $p0 αντί για $p1';
  }

  @override
  String totaleMInveceM(Object p0, Object p1) {
    return 'σύνολο $p0 μ. αντί για $p1 μ.';
  }

  @override
  String durataMinInvece(Object p0, Object p1) {
    return 'διάρκεια $p0 λεπ. αντί για $p1';
  }

  @override
  String passoPiuLentoTarget(Object p0, Object p1, Object p2, Object p3) {
    return 'Ρυθμός $p0% πιο αργός από τον στόχο (κόπωση $p1, αναμενόμενη $p2): χαλαρώνω το $p3.';
  }

  @override
  String faticaSopraAttesaAlleggerisco(Object p0, Object p1, Object p2) {
    return 'Κόπωση $p0, πάνω από την αναμενόμενη ($p1): χαλαρώνω το $p2.';
  }

  @override
  String faticaLineaAttesaProgressione(Object p0, Object p1) {
    return 'Κόπωση $p0, όσο η αναμενόμενη ($p1): κανονική πρόοδος, ένα πράγμα τη φορά.';
  }

  @override
  String faticaSottoAttesaPiccola(Object p0, Object p1) {
    return 'Κόπωση $p0, κάτω από την αναμενόμενη ($p1): μικρή πρόοδος.';
  }

  @override
  String dueSedutePesantiFila(Object p0) {
    return 'Δύο δύσκολες προπονήσεις στη σειρά: εβδομάδα αποκατάστασης για $p0.';
  }

  @override
  String get claudeImpostazioniPrivacyDisattiva =>
      'Στο Claude: Ρυθμίσεις → Απόρρητο → απενεργοποίησε το «Help improve Claude».';

  @override
  String get chatgptImpostazioniControlliDati =>
      'Στο ChatGPT: Ρυθμίσεις → Έλεγχοι δεδομένων → απενεργοποίησε το «Βελτίωση του μοντέλου για όλους».';

  @override
  String get geminiDisattivaAttivitaNelle =>
      'Στο Gemini: απενεργοποίησε τη «Δραστηριότητα εφαρμογών Gemini» (ή «Διατήρηση δραστηριότητας») στον λογαριασμό Google.';

  @override
  String get controllaNelleImpostazioniDell =>
      'Έλεγξε στις ρυθμίσεις της εφαρμογής αν οι συνομιλίες χρησιμοποιούνται για την εκπαίδευση του μοντέλου και, αν θέλεις, απενεργοποίησέ το.';

  @override
  String get nellaRispostaNonC =>
      'Η απάντηση δεν έχει μπλοκ για την εφαρμογή. Ζήτα από τον βοηθό να γράψει τις αλλαγές στη μορφή <avidididadi>.';

  @override
  String get codiceNellaRispostaNon =>
      'Ο κωδικός στην απάντηση δεν είναι αυτού του κινητού: ίσως προέρχεται από παλιό σύνδεσμο. Στείλε ξανά τα δεδομένα και δοκίμασε πάλι.';

  @override
  String get bloccoNonLeggibileChiedi =>
      'Το μπλοκ δεν διαβάζεται. Ζήτα από τον βοηθό να το γράψει ξανά.';

  @override
  String get dataInizioGiaPassata => 'Η ημερομηνία έναρξης έχει ήδη περάσει.';

  @override
  String get dataMancante => 'λείπει η ημερομηνία';

  @override
  String get primaDellInizioPiano => 'πριν από την έναρξη του προγράμματος';

  @override
  String oltreSettimane(Object p0) {
    return 'πέρα από τις $p0 εβδομάδες';
  }

  @override
  String get sportNonPrevisto => 'μη επιτρεπτό άθλημα';

  @override
  String get durataNonSensata => 'η διάρκεια δεν βγάζει νόημα';

  @override
  String dueSeduteStessoGiorno(Object p0) {
    return 'δύο προπονήσεις $p0 την ίδια μέρα';
  }

  @override
  String settimanaMancaGiornoRiposo(Object p0) {
    return 'Εβδομάδα $p0: λείπει μια μέρα ξεκούρασης.';
  }

  @override
  String settimanaMinutiTroppiRispetto(Object p0, Object p1, Object p2) {
    return 'Εβδομάδα $p0: $p1 λεπτά, πάρα πολλά σε σχέση με τις προηγούμενες εβδομάδες (το πολύ $p2).';
  }

  @override
  String appNonHaAccettato(Object p0, Object p1) {
    return 'Η εφαρμογή δεν δέχτηκε το πρόγραμμα για τους εξής λόγους:\n$p0\nΔιόρθωσέ το και στείλ\' το ξανά στο μπλοκ <avidididadi> με τον κωδικό $p1.';
  }

  @override
  String get allenamentoNonHaData => 'Μια προπόνηση δεν έχει ημερομηνία.';

  @override
  String allenamentoSportDeveEssere(Object p0) {
    return 'Προπόνηση $p0: το άθλημα πρέπει να είναι τρέξιμο, ποδήλατο ή κολύμβηση.';
  }

  @override
  String allenamentoServono140(Object p0) {
    return 'Προπόνηση $p0: χρειάζεται από 1 έως 40 βήματα.';
  }

  @override
  String allenamento(Object p0) {
    return 'Προπόνηση $p0';
  }

  @override
  String allenamentoPassoServonoMinuti(Object p0, Object p1) {
    return 'Προπόνηση $p0, βήμα $p1: χρειάζονται τα λεπτά (έως 300) ή τα μέτρα.';
  }

  @override
  String allenamentoPassoRipetizioni1(Object p0, Object p1) {
    return 'Προπόνηση $p0, βήμα $p1: από 1 έως 30 επαναλήψεις και διάλειμμα έως 1800 δευτερόλεπτα.';
  }

  @override
  String allenamentoDuraPiu5(Object p0) {
    return 'Προπόνηση $p0: διαρκεί πάνω από 5 ώρες.';
  }

  @override
  String get trave => 'Hangboard';

  @override
  String get circuito => 'Κύκλωμα';

  @override
  String get campus => 'Campus';

  @override
  String get potenza => 'Ισχύς';

  @override
  String deveEssereNumero0(Object p0, Object p1, Object p2) {
    return '$p0: το «$p1» πρέπει να είναι αριθμός από 0 έως $p2.';
  }

  @override
  String mancaNome(Object p0) {
    return '$p0: λείπει το όνομα.';
  }

  @override
  String esercizio(Object p0) {
    return 'Άσκηση $p0';
  }

  @override
  String get allenamentoArrampicataNonHa =>
      'Μια προπόνηση αναρρίχησης δεν έχει όνομα.';

  @override
  String servono130Esercizi(Object p0) {
    return '«$p0»: χρειάζεται από 1 έως 30 ασκήσεις.';
  }

  @override
  String esercizio2(Object p0, Object p1) {
    return '«$p0», άσκηση $p1';
  }

  @override
  String get recuperoTraSerie => 'Διάλειμμα ανάμεσα στα σετ';

  @override
  String riposaSerieDopo(Object p0) {
    return 'Ξεκουράσου: το επόμενο σετ είναι «$p0».';
  }

  @override
  String min(Object p0, Object p1) {
    return '$p0:$p1 λεπ.';
  }

  @override
  String dataNonValidaServe(Object p0) {
    return 'Μη έγκυρη ημερομηνία: $p0 (γράψε ΕΕΕΕ-ΜΜ-ΗΗ).';
  }

  @override
  String get nelBloccoNonCi =>
      'Στο μπλοκ δεν υπάρχουν προπονήσεις αναρρίχησης.';

  @override
  String get backupRovinatoTuoiDati =>
      'Το αντίγραφο ασφαλείας είναι κατεστραμμένο: τα δεδομένα σου έμειναν όπως ήταν.';

  @override
  String errore(Object p0) {
    return 'Σφάλμα: $p0';
  }

  @override
  String get collegaPrimaIntervalsIcu =>
      'Σύνδεσε πρώτα το intervals.icu από Προφίλ → Δεδομένα και συνδέσεις.';

  @override
  String get giaInviataIntervalsIcu => 'Έχει ήδη σταλεί στο intervals.icu.';

  @override
  String get inviataIntervalsIcu => 'Στάλθηκε στο intervals.icu.';

  @override
  String get incollaPrimaChiaveApi => 'Επικόλλησε πρώτα το κλειδί API.';

  @override
  String get collegato => 'Συνδεδεμένο';

  @override
  String collegatoCome(Object p0) {
    return 'Συνδεδεμένο ως $p0';
  }

  @override
  String get chiaveNonTrovataCollega =>
      'Το κλειδί δεν βρέθηκε: σύνδεσε ξανά το intervals.icu.';

  @override
  String attivitaLetteIntervalsIcu(Object p0) {
    return '$p0 δραστηριότητες διαβάστηκαν από το intervals.icu.';
  }

  @override
  String get calendarioIntervalsIcuGia =>
      'Το ημερολόγιο του intervals.icu είναι ήδη ενημερωμένο.';

  @override
  String get sedutaMandata => 'προπόνηση στάλθηκε';

  @override
  String get seduteMandate => 'προπονήσεις στάλθηκαν';

  @override
  String intervalsIcu(Object p0) {
    return '$p0 στο intervals.icu.';
  }

  @override
  String seduteTolteDalCalendario(Object p0) {
    return '$p0 προπονήσεις αφαιρέθηκαν από το ημερολόγιο του intervals.icu.';
  }

  @override
  String get sincronizzazioneGiaCorso => 'Ο συγχρονισμός είναι ήδη σε εξέλιξη.';

  @override
  String get healthConnectVaAggiornato =>
      'Το Health Connect χρειάζεται ενημέρωση: άνοιξέ το από το Play Store.';

  @override
  String get healthConnectNonInstallato =>
      'Το Health Connect δεν είναι εγκατεστημένο στο κινητό.';

  @override
  String get healthConnectDisponibileSolo =>
      'Το Health Connect υπάρχει μόνο σε Android.';

  @override
  String get healthConnectNonAncora =>
      'Το Health Connect δεν έχει συνδεθεί ακόμα.';

  @override
  String get senzaPermessoSessioniAllenamento =>
      'Χωρίς άδεια για τις προπονήσεις δεν μπορώ να διαβάσω τίποτα. Μπορείς να τη δώσεις από το «Έλεγχος αδειών».';

  @override
  String get nessunaNovitaHealthConnect =>
      'Τίποτα καινούργιο από το Health Connect.';

  @override
  String sessioniNuove(Object p0) {
    return '$p0 νέες προπονήσεις';
  }

  @override
  String erroreDuranteSincronizzazione(Object p0) {
    return 'Σφάλμα κατά τον συγχρονισμό: $p0';
  }

  @override
  String get feedbackSalvatoContaNel =>
      'Η αξιολόγηση αποθηκεύτηκε: μετράει στο προπονητικό φορτίο.';

  @override
  String get restaUguale => 'μένει ίδιο';

  @override
  String prossimaSeduta(Object p0, Object p1, Object p2) {
    return '$p0\n\nΕπόμενη προπόνηση ($p1): $p2.';
  }

  @override
  String get feedbackSalvato => 'Η αξιολόγηση αποθηκεύτηκε.';

  @override
  String get fileVuotoONon => 'κενό ή μη έγκυρο αρχείο.';

  @override
  String formatoNonRiconosciutoServono(Object p0) {
    return 'η μορφή δεν αναγνωρίστηκε: χρειάζονται τουλάχιστον οι στήλες ημερομηνίας και αθλήματος (βρέθηκαν: $p0).';
  }

  @override
  String righeScartateDataO(Object p0) {
    return '$p0 γραμμές παραλείφθηκαν (λείπει ημερομηνία ή άθλημα)';
  }

  @override
  String ignorate(Object p0, Object p1) {
    return '$p0 αγνοήθηκαν ($p1)';
  }

  @override
  String sessioniNuoveAggiornate(Object p0, Object p1, Object p2) {
    return '$p0 νέες προπονήσεις, $p1 ενημερώθηκαν$p2.';
  }

  @override
  String gradoPiuDifficile(Object p0, Object p1) {
    return 'Δυσκολότερος βαθμός: $p0$p1';
  }

  @override
  String get vieChiuse => 'διαδρομές ολοκληρώθηκαν';

  @override
  String get blocchiChiusi => 'boulder ολοκληρώθηκαν';

  @override
  String circaMSaliti(Object p0) {
    return 'περίπου $p0 μ. ανάβαση';
  }

  @override
  String progetto(Object p0) {
    return 'Project: $p0';
  }

  @override
  String get ollamaSulTuoPc => 'Ollama στον υπολογιστή σου';

  @override
  String get serveChiaveApiConsole =>
      'Χρειάζεσαι κλειδί API από το console.anthropic.com (πληρώνεις όσο χρησιμοποιείς). Η συνδρομή Claude Pro δεν λειτουργεί για εξωτερικές εφαρμογές.';

  @override
  String get serveChiaveApiPlatform =>
      'Χρειάζεσαι κλειδί API από το platform.openai.com (πληρώνεις όσο χρησιμοποιείς). Η συνδρομή ChatGPT Plus δεν λειτουργεί για εξωτερικές εφαρμογές.';

  @override
  String get serveChiaveApiAistudio =>
      'Χρειάζεσαι κλειδί API από το aistudio.google.com: υπάρχει δωρεάν επίπεδο με ημερήσια όρια.';

  @override
  String get gratisPrivatoModelloGira =>
      'Δωρεάν και ιδιωτικό: το μοντέλο τρέχει στον υπολογιστή σου, στο ίδιο δίκτυο Wi-Fi. Χωρίς κλειδί. Στον υπολογιστή ξεκίνα το Ollama με OLLAMA_HOST=0.0.0.0.';

  @override
  String get nelBloccoNonCi2 => 'Στο μπλοκ δεν υπάρχουν προπονήσεις.';

  @override
  String get nelPianoMancanoData =>
      'Στο πρόγραμμα λείπουν η ημερομηνία έναρξης ή οι προπονήσεις.';

  @override
  String get nelBloccoNonCi3 => 'Στο μπλοκ δεν υπάρχουν έγκυρες αλλαγές.';

  @override
  String get propostaNonLeggibileChiedi =>
      'Η πρόταση δεν διαβάζεται: ζήτα από τον προπονητή να τη γράψει ξανά.';

  @override
  String sportNonPrevisto2(Object p0) {
    return 'μη επιτρεπτό άθλημα ($p0)';
  }

  @override
  String get dataGiaPassata => 'η ημερομηνία έχει ήδη περάσει';

  @override
  String durataNonSensataMin(Object p0) {
    return 'η διάρκεια δεν βγάζει νόημα ($p0 λεπ.)';
  }

  @override
  String cGiaSedutaQuel(Object p0) {
    return 'υπάρχει ήδη προπόνηση $p0 εκείνη τη μέρα';
  }

  @override
  String get mancaDurata => 'λείπει η διάρκεια';

  @override
  String quelGiornoNonC(Object p0) {
    return 'εκείνη τη μέρα δεν υπάρχει προπόνηση $p0';
  }

  @override
  String get nuovaDataMancanteO => 'η νέα ημερομηνία λείπει ή έχει περάσει';

  @override
  String cGiaSedutaGiorno(Object p0) {
    return 'υπάρχει ήδη προπόνηση $p0 τη μέρα που διάλεξες';
  }

  @override
  String settimanaPasserebbeMinutiOltre(Object p0, Object p1) {
    return 'η εβδομάδα θα πήγαινε από $p0 σε $p1 λεπτά (πάνω από +10%)';
  }

  @override
  String get settimanaResterebbeSenzaGiorno =>
      'η εβδομάδα θα έμενε χωρίς μέρα ξεκούρασης';

  @override
  String nuovaSeduta(Object p0, Object p1) {
    return '$p0: νέα προπόνηση, $p1';
  }

  @override
  String tolta(Object p0, Object p1) {
    return '$p0: αφαιρέθηκε$p1';
  }

  @override
  String get ellittica => 'Ελλειπτικό';

  @override
  String get canottaggio => 'Κωπηλασία';

  @override
  String get vogatore => 'Κωπηλατική μηχανή';

  @override
  String get stepper => 'Stepper';

  @override
  String get scale => 'Σκάλες';

  @override
  String get sci => 'Σκι';

  @override
  String get scialpinismo => 'Ορειβατικό σκι';

  @override
  String get sciFondo => 'Σκι αντοχής';

  @override
  String get pattinaggio => 'Πατινάζ';

  @override
  String get kayak => 'Καγιάκ';

  @override
  String get canoa => 'Κανό';

  @override
  String get vela => 'Ιστιοπλοΐα';

  @override
  String get surf => 'Σέρφινγκ';

  @override
  String get sup => 'SUP';

  @override
  String get calcio => 'Ποδόσφαιρο';

  @override
  String get basket => 'Μπάσκετ';

  @override
  String get pallavolo => 'Βόλεϊ';

  @override
  String get pingPong => 'Πινγκ πονγκ';

  @override
  String get danza => 'Χορός';

  @override
  String get artiMarziali => 'Πολεμικές τέχνες';

  @override
  String get pugilato => 'Πυγμαχία';

  @override
  String get uscitaBici => 'Βόλτα με ποδήλατο';

  @override
  String get nuotoLibero => 'Ελεύθερη κολύμβηση';

  @override
  String get toccaFattoQuandoHai => 'Πάτα «Έγινε» όταν τελειώσεις.';

  @override
  String get duePagine => 'Δύο σελίδες';

  @override
  String get minimappa => 'Μικρός χάρτης';

  @override
  String get tuttoSchermo => 'Πλήρης οθόνη';

  @override
  String get annulla => 'Άκυρο';

  @override
  String creato(Object p0) {
    return 'Δημιουργήθηκε στις $p0';
  }

  @override
  String giorniPiano(Object p0) {
    return '$p0 μέρες προγράμματος';
  }

  @override
  String get fotoProfilo => 'φωτογραφία προφίλ';

  @override
  String get fileTroppoGrandeEssere =>
      'Το αρχείο είναι πολύ μεγάλο για να είναι αντίγραφο ασφαλείας.';

  @override
  String get fileNonBackupAvidididadi =>
      'Το αρχείο δεν είναι αντίγραφο ασφαλείας του Avidididadi.';

  @override
  String get backupCreatoVersionePiu =>
      'Το αντίγραφο ασφαλείας δημιουργήθηκε από νεότερη έκδοση της εφαρμογής: ενημέρωσέ την.';

  @override
  String get backupVuoto => 'Το αντίγραφο ασφαλείας είναι κενό.';

  @override
  String get nonRiescoScrivereNella =>
      'Δεν μπορώ να γράψω στον φάκελο: διάλεξέ τον ξανά (ίσως μετακινήθηκε ή διαγράφηκε).';

  @override
  String get backupAutomaticoNonRiuscito =>
      'Το αυτόματο αντίγραφο ασφαλείας απέτυχε.';

  @override
  String get sensoreBattito => 'Αισθητήρας παλμών';

  @override
  String get bastaPaioScarpeSi =>
      'Αρκεί ένα ζευγάρι παπούτσια. Μπορείς να ξεκινήσεις με περπάτημα.';

  @override
  String get casaOPalestraAnche =>
      'Στο σπίτι ή στο γυμναστήριο, ακόμα και χωρίς εξοπλισμό.';

  @override
  String get piscinaDelicatoSulleArticolazioni =>
      'Στην πισίνα, ήπιο για τις αρθρώσεις.';

  @override
  String get allApertoOSui =>
      'Σε εξωτερικό χώρο ή στο προπονητήριο, με χαλαρό ρυθμό.';

  @override
  String get stretchingMovimentiLentiPerfetta =>
      'Διατάσεις και αργές κινήσεις: ιδανικό για αρχή ή για αποκατάσταση.';

  @override
  String get palestraOFalesiaSegni =>
      'Στο γυμναστήριο ή στον βράχο: κατέγραψε διαδρομές, boulder και βαθμούς.';

  @override
  String get maiOQuasiMai => 'Ποτέ ή σχεδόν ποτέ';

  @override
  String get siPartePianoSedute =>
      'Ξεκινάμε σιγά: απλές προπονήσεις για να μάθεις τις κινήσεις.';

  @override
  String get ogniTanto => 'Πού και πού';

  @override
  String get qualcheAllenamentoAlMese =>
      'Λίγες προπονήσεις τον μήνα, αλλά όχι σταθερά.';

  @override
  String get regolarmente => 'Τακτικά';

  @override
  String get miAllenoQuasiOgni =>
      'Προπονούμαι σχεδόν κάθε εβδομάδα εδώ και μήνες.';

  @override
  String get caloStaiFacendoMeno => 'Πτώση: κάνεις λιγότερα από ό,τι συνήθως.';

  @override
  String get equilibratoAumentoSostenibile =>
      'Ισορροπημένο: μια αύξηση που αντέχεται.';

  @override
  String get attenzioneStaiAumentandoFretta => 'Προσοχή: αυξάνεις γρήγορα.';

  @override
  String get rischioTroppoCaricoRispetto =>
      'Κίνδυνος: πολύ φορτίο σε σχέση με τις τελευταίες εβδομάδες.';

  @override
  String hMin(Object p0, Object p1) {
    return '$p0 ώ. $p1 λεπ.';
  }

  @override
  String get chiudi => 'Κλείσιμο';

  @override
  String get nessunDatoQuestoGrafico =>
      'Δεν υπάρχουν δεδομένα για αυτό το γράφημα.';

  @override
  String settimanaDal(Object p0) {
    return 'Εβδομάδα από $p0';
  }

  @override
  String totale(Object p0) {
    return 'Σύνολο: $p0';
  }

  @override
  String tuttoPeriodo(Object p0, Object p1) {
    return '$p0 σε όλη την περίοδο: $p1';
  }

  @override
  String get nessunAllenamento => 'Καμία προπόνηση';

  @override
  String ripetizione(Object p0, Object p1) {
    return 'Επανάληψη $p0 από $p1';
  }

  @override
  String serie(Object p0, Object p1) {
    return 'Σετ $p0 από $p1';
  }

  @override
  String get latoDestro => 'Δεξιά πλευρά';

  @override
  String get latoSinistro => 'Αριστερή πλευρά';

  @override
  String get cambiaLato => 'Αλλαγή πλευράς';

  @override
  String get cambiaLatoVoce => 'Άλλαξε πλευρά.';

  @override
  String secondiPerLato(Object p0) {
    return '$p0 δευτ. ανά πλευρά';
  }

  @override
  String ripetizioniPerLato(Object p0) {
    return '$p0 ανά πλευρά';
  }

  @override
  String poiRipetizione(Object p0, Object p1) {
    return 'Μετά επανάληψη $p0 από $p1';
  }

  @override
  String poiSerie(Object p0, Object p1) {
    return 'Μετά σετ $p0 από $p1';
  }

  @override
  String get continuaPianoSenzaFermarti =>
      'Συνέχισε χαλαρά, χωρίς να σταματήσεις.';

  @override
  String get respiraBeviSorsoAcqua => 'Πάρε ανάσα και πιες μια γουλιά νερό.';

  @override
  String get manubri => 'Αλτήρες';

  @override
  String get pesoOgniManubrioEs =>
      'Το βάρος κάθε αλτήρα, π.χ. 4, 8, 12. Αν είναι ρυθμιζόμενοι, γράψε το εύρος, π.χ. 2-20.';

  @override
  String get kettlebell => 'Kettlebell';

  @override
  String get pesoOgniKettlebellHai => 'Το βάρος κάθε kettlebell που έχεις.';

  @override
  String get bilanciere => 'Μπάρα';

  @override
  String get pesoSolaBarraSolito =>
      'Το βάρος της μπάρας χωρίς δίσκους (συνήθως 20 kg).';

  @override
  String get dischi => 'Δίσκοι';

  @override
  String get pesoDeiDischiHai =>
      'Το βάρος των δίσκων που έχεις. Χρησιμοποιούνται και χωρίς μπάρα.';

  @override
  String get pallaMedica => 'Μπάλα medicine';

  @override
  String get pesoPalla => 'Το βάρος της μπάλας.';

  @override
  String get elastici => 'Λάστιχα αντίστασης';

  @override
  String get sbarraTrazioni => 'Μονόζυγο';

  @override
  String get paralleleDip => 'Δίζυγο για dips';

  @override
  String get anelliOTrx => 'Κρίκοι ή TRX';

  @override
  String get panca => 'Πάγκος';

  @override
  String get stepOBox => 'Step ή κουτί';

  @override
  String get fitball => 'Μπάλα γυμναστικής';

  @override
  String get rulloFoamRoller => 'Foam roller';

  @override
  String get latMachine => 'Τροχαλία πλάτης';

  @override
  String get pulleyBasso => 'Χαμηλή τροχαλία';

  @override
  String get caviRegolabiliCroceAi => 'Ρυθμιζόμενα καλώδια (cable crossover)';

  @override
  String get chestPress => 'Μηχάνημα πιέσεων στήθους';

  @override
  String get pectoralMachine => 'Πεταλούδα (pec deck)';

  @override
  String get shoulderPress => 'Μηχάνημα πιέσεων ώμων';

  @override
  String get rematoreAllaMacchina => 'Κωπηλατική στο μηχάνημα';

  @override
  String get multipowerSmithMachine => 'Smith machine';

  @override
  String get legPress => 'Πρέσα ποδιών';

  @override
  String get hackSquat => 'Hack squat';

  @override
  String get legExtension => 'Εκτάσεις ποδιών';

  @override
  String get legCurl => 'Κάμψεις ποδιών';

  @override
  String get adduttoriAbduttori => 'Μηχάνημα προσαγωγών και απαγωγών';

  @override
  String get calfMachinePolpacci => 'Μηχάνημα γαστροκνημίων';

  @override
  String get addominali => 'Κοιλιακοί';

  @override
  String get obliqui => 'Πλάγιοι κοιλιακοί';

  @override
  String get adduttori => 'Προσαγωγοί';

  @override
  String get bicipiti => 'Δικέφαλοι';

  @override
  String get polpacci => 'Γάμπες';

  @override
  String get petto => 'Στήθος';

  @override
  String get avambracci => 'Πήχεις';

  @override
  String get glutei => 'Γλουτοί';

  @override
  String get femorali => 'Οπίσθιοι μηριαίοι';

  @override
  String get dorsali => 'Άνω πλάτη';

  @override
  String get lombari => 'Μέση';

  @override
  String get collo => 'Αυχένας';

  @override
  String get quadricipiti => 'Τετρακέφαλοι';

  @override
  String get spalle => 'Ώμοι';

  @override
  String get trapezio => 'Τραπεζοειδής';

  @override
  String get tricipiti => 'Τρικέφαλοι';

  @override
  String get spintaOrizzontalePetto => 'Οριζόντια ώθηση (στήθος)';

  @override
  String get spintaVerticaleSpalle => 'Κάθετη ώθηση (ώμοι)';

  @override
  String get trazioneOrizzontaleRematori => 'Οριζόντια έλξη (κωπηλατικές)';

  @override
  String get trazioneVerticaleTrazioni => 'Κάθετη έλξη (έλξεις)';

  @override
  String get squat => 'Καθίσματα (squat)';

  @override
  String get affondiStep => 'Προβολές και ανεβάσματα';

  @override
  String get cernieraAncaStacchiPonti => 'Κάμψη ισχίου (άρσεις και γέφυρες)';

  @override
  String get core => 'Κορμός';

  @override
  String get spallePostura => 'Ώμοι και στάση σώματος';

  @override
  String get braccia => 'Χέρια';

  @override
  String get gambeAlleMacchine => 'Πόδια στα μηχανήματα';

  @override
  String get pliometria => 'Πλειομετρικά';

  @override
  String get totalBody => 'Όλο το σώμα';

  @override
  String get rulloAutomassaggio => 'Foam roller (αυτομασάζ)';

  @override
  String get n1Esercizio => '1 άσκηση';

  @override
  String get beneDallaProssimaSessione =>
      'Μπράβο! Από την επόμενη προπόνηση ανεβάζω λίγο το φορτίο.';

  @override
  String get haiSegnalatoDoloreAlleggerisco =>
      'Ανέφερες πόνο: ελαφραίνω τις επόμενες προπονήσεις. Αν ο πόνος συνεχίζεται, σταμάτα και δες έναν γιατρό.';

  @override
  String get alleggeriscoPoProssimeSessioni =>
      'Ελαφραίνω λίγο τις επόμενες προπονήσεις.';

  @override
  String get caricoGiustoSiContinua =>
      'Το φορτίο είναι σωστό: συνεχίζουμε έτσι.';

  @override
  String tiAlleniMeglioQuanto(Object p0) {
    return 'Προπονείσαι καλύτερα απ\' ό,τι νόμιζες: ανεβαίνεις στο επίπεδο $p0.';
  }

  @override
  String passoAlLivelloPiu(Object p0) {
    return 'Περνάω στο επίπεδο $p0, πιο κατάλληλο για τώρα.';
  }

  @override
  String haiSegnalatoDoloreAlleggerisco2(Object p0) {
    return 'Ανέφερες πόνο: ελαφραίνω τις επόμενες προπονήσεις $p0. Αν ο πόνος συνεχίζεται, σταμάτα και δες έναν γιατρό.';
  }

  @override
  String beneSeduteSonoGia(Object p0) {
    return 'Μπράβο! Οι προπονήσεις $p0 είναι ήδη στη μέγιστη αύξηση.';
  }

  @override
  String beneAumentoPoIntensita(Object p0) {
    return 'Μπράβο! Ανεβάζω λίγο την ένταση στις επόμενες προπονήσεις $p0, με τον ίδιο χρόνο.';
  }

  @override
  String beneAllungoPoProssime(Object p0) {
    return 'Μπράβο! Κάνω λίγο πιο μεγάλες τις επόμενες προπονήσεις $p0.';
  }

  @override
  String rendoPoMenoIntense(Object p0) {
    return 'Κάνω λίγο πιο ήπιες τις επόμενες προπονήσεις $p0.';
  }

  @override
  String accorcioPoProssimeSedute(Object p0) {
    return 'Κάνω λίγο πιο σύντομες τις επόμενες προπονήσεις $p0.';
  }

  @override
  String get faticaGiustaSiContinua =>
      'Η κόπωση είναι σωστή: συνεχίζουμε έτσι.';

  @override
  String get braccio => 'Μπράτσο';

  @override
  String get vita => 'Μέση';

  @override
  String get fianchi => 'Γοφοί';

  @override
  String get coscia => 'Μηρός';

  @override
  String get durata => 'Διάρκεια';

  @override
  String get sedutePiuLunghe5 => 'Προπονήσεις 5% πιο μεγάλες σε κάθε βήμα.';

  @override
  String get intensita => 'Ένταση';

  @override
  String get stessaDurataPiuSforzo =>
      'Ίδια διάρκεια, περισσότερη προσπάθεια: πιο σύντομα διαλείμματα, περισσότερα γρήγορα λεπτά, λίγο πιο γρήγορος ρυθμός.';

  @override
  String get auto => 'Αυτόματα';

  @override
  String get primaIntensitaFino2 =>
      'Πρώτα η ένταση (έως 2 βήματα), μετά η διάρκεια.';

  @override
  String min2(Object p0, Object p1) {
    return '$p0 · $p1 λεπ.';
  }

  @override
  String get corsaLeggeraAlternataCamminata =>
      'Ελαφρύ τρέξιμο εναλλάξ με περπάτημα';

  @override
  String get dopo2MinutiCorsa =>
      'Μετά από 2 λεπτά τρέξιμο, περπάτα για 1 λεπτό. Αν λαχανιάζεις, περπάτα περισσότερο: είναι απολύτως φυσιολογικό, έτσι ξεκινούν όλοι.';

  @override
  String lungoMin(Object p0) {
    return 'Μεγάλη απόσταση · $p0 λεπ.';
  }

  @override
  String get corsaLungaContinua => 'Συνεχές μεγάλο τρέξιμο';

  @override
  String get ritmoFacileCostanteDevi =>
      'Χαλαρός, σταθερός ρυθμός: πρέπει να μπορείς να μιλάς.';

  @override
  String get finaleRitmoGara => 'Τέλος σε ρυθμό αγώνα';

  @override
  String get finaleProgressione => 'Τέλος με προοδευτική αύξηση';

  @override
  String get corsaFacile => 'Χαλαρό τρέξιμο';

  @override
  String get corsaVeloce => 'Γρήγορο τρέξιμο';

  @override
  String get recuperoCorricchiandoZona2 =>
      'Αποκατάσταση με ελαφρύ τρέξιμο σε ζώνη 2.';

  @override
  String get corsaRitmoSostenuto => 'Τρέξιμο σε έντονο ρυθμό';

  @override
  String get ripetuteVeloci => 'Γρήγορα διαλειμματικά';

  @override
  String get recuperoCorricchiandoPiano =>
      'Αποκατάσταση με πολύ ελαφρύ τρέξιμο.';

  @override
  String get blocchiRitmoGara => 'Τμήματα σε ρυθμό αγώνα';

  @override
  String get allunghiProgressione => 'Προοδευτικές επιταχύνσεις';

  @override
  String get velociMaRilassatiNon => 'Γρήγορα αλλά χαλαρά, όχι στο μέγιστο.';

  @override
  String lentoMin(Object p0) {
    return 'Χαλαρό · $p0 λεπ.';
  }

  @override
  String get corsaLenta => 'Χαλαρό τρέξιμο';

  @override
  String get stileLiberoFacile => 'Χαλαρό ελεύθερο';

  @override
  String get gambeTavolettaBraccioSingolo => 'Πόδια με σανίδα και ένα χέρι';

  @override
  String get n2GambeTavoletta1 =>
      '2 πόδια με σανίδα, 1 μόνο δεξί χέρι, 1 μόνο αριστερό χέρι.';

  @override
  String get stileLiberoSostenuto => 'Έντονο ελεύθερο';

  @override
  String get sostenutoCostante => 'έντονα, σταθερά';

  @override
  String get stileLiberoAerobico => 'Αερόβιο ελεύθερο';

  @override
  String get medioRespirazioneRegolare => 'μέτρια, σταθερή αναπνοή';

  @override
  String get dorsoFacile => 'Χαλαρό ύπτιο';

  @override
  String intervalliMin(Object p0) {
    return 'Διαλειμματικά · $p0 λεπ.';
  }

  @override
  String get pedalataAgile => 'Ελαφριά ποδηλασία';

  @override
  String get ripetuteSalitaOPianura => 'Επαναλήψεις σε ανηφόρα ή σε ευθεία';

  @override
  String get pedalataSciolta => 'Χαλαρή ποδηλασία';

  @override
  String get uscitaLunga => 'Μεγάλη διαδρομή';

  @override
  String uscitaLungaMin(Object p0) {
    return 'Μεγάλη διαδρομή · $p0 λεπ.';
  }

  @override
  String get uscitaContinua => 'Συνεχής διαδρομή';

  @override
  String inserisciTratti10Minuti(Object p0) {
    return 'Βάλε $p0 τμήματα των 10 λεπτών σε ζώνη 3. Τρώγε και πίνε κάθε 30-45 λεπτά.';
  }

  @override
  String get mangiaBeviOgni30 => 'Τρώγε και πίνε κάθε 30-45 λεπτά.';

  @override
  String uscitaMin(Object p0) {
    return 'Διαδρομή · $p0 λεπ.';
  }

  @override
  String get pedalataCostante => 'Σταθερή ποδηλασία';

  @override
  String get finalePiuSpinto => 'Πιο έντονο τέλος';

  @override
  String get pocheRipetizioniCarichiAlti =>
      'Λίγες επαναλήψεις με μεγάλα βάρη και μεγάλα διαλείμματα.';

  @override
  String get massaMuscolare => 'Μυϊκή μάζα';

  @override
  String get ripetizioniMediePiuVolume =>
      'Μέτριες επαναλήψεις, περισσότερος όγκος για να μεγαλώσουν οι μύες.';

  @override
  String get resistenzaMuscolare => 'Μυϊκή αντοχή';

  @override
  String get tanteRipetizioniRecuperiBrevi =>
      'Πολλές επαναλήψεις και σύντομα διαλείμματα, χρήσιμο για αθλήματα αντοχής.';

  @override
  String get formaGenerale => 'Γενική φυσική κατάσταση';

  @override
  String get equilibrioTraForzaMuscoli =>
      'Ισορροπία ανάμεσα σε δύναμη, μύες και αντοχή.';

  @override
  String get principiante => 'Αρχάριος';

  @override
  String get tiAlleniPesiPoco =>
      'Είσαι καινούργιος στα βάρη ή δεν έχεις προπονηθεί εδώ και καιρό.';

  @override
  String get intermedio => 'Μέσος';

  @override
  String get tiAlleniCostanzaAlmeno =>
      'Προπονείσαι σταθερά εδώ και τουλάχιστον λίγους μήνες.';

  @override
  String get avanzato => 'Προχωρημένος';

  @override
  String get tiAlleniAnniConosci =>
      'Προπονείσαι χρόνια και ξέρεις καλά την τεχνική.';

  @override
  String settimana4(Object p0, Object p1) {
    return '$p0 · εβδομάδα $p1 από 4';
  }

  @override
  String get n10Lato => '10 ανά πλευρά';

  @override
  String get n10Lenti => '10 αργές';

  @override
  String get settimanaScaricoSerieMeno =>
      'Εβδομάδα αποκατάστασης: ένα σετ λιγότερο, ίδια τεχνική.';

  @override
  String get settimana2RipetizionePiu =>
      'Εβδομάδα 2: μία επανάληψη περισσότερη από την προηγούμενη εβδομάδα.';

  @override
  String get settimana3DueRipetizioni =>
      'Εβδομάδα 3: δύο επαναλήψεις περισσότερες από την πρώτη εβδομάδα.';

  @override
  String gambeLeggereDomaniHai(Object p0) {
    return 'Ελαφριά για τα πόδια: αύριο έχεις $p0.';
  }

  @override
  String n10Fatica(Object p0) {
    return '$p0/10 κόπωση';
  }

  @override
  String get n30SLato => '30 δευτ. ανά πλευρά';

  @override
  String get lungo => 'η Μεγάλη απόσταση';

  @override
  String get fartlek => 'το Fartlek';

  @override
  String get tempoRun => 'το Tempo run';

  @override
  String get partiSolaBarraAggiungi =>
      'Ξεκίνα μόνο με τη μπάρα και πρόσθεσε δίσκους μέχρι να φτάσεις την κόπωση που λέει.';

  @override
  String pesoKg(Object p0, Object p1) {
    return 'Βάρος: $p0 $p1 kg.';
  }

  @override
  String pesoCircaKg(Object p0) {
    return 'Βάρος: περίπου $p0 kg.';
  }

  @override
  String get movimentiLentiRespiraCalma =>
      'Αργές κινήσεις, ανάπνεε ήρεμα: τέντωσε χωρίς ποτέ να πονάς.';

  @override
  String get corsaRitmoTranquilloDevi =>
      'Τρέξιμο σε ήρεμο ρυθμό: πρέπει να μπορείς να μιλάς χωρίς να λαχανιάζεις. Χτίζει αντοχή και είναι η βάση για όλα.';

  @override
  String get corsaPiuLungaSettimana =>
      'Το πιο μεγάλο τρέξιμο της εβδομάδας, πάντα σε χαλαρό ρυθμό. Συνηθίζει το σώμα στις αποστάσεις.';

  @override
  String get giocoVelocitaAlterniTratti =>
      'Παιχνίδι ταχύτητας: εναλλάσσεις γρήγορα και χαλαρά κομμάτια, χωρίς να σταματάς ποτέ. Σε μαθαίνει να αλλάζεις ρυθμό.';

  @override
  String get corsaRitmoSostenutoMa =>
      'Τρέξιμο σε έντονο αλλά σταθερό ρυθμό, «άνετα δύσκολο»: μιλάς μόνο με κόπο, αλλά τον κρατάς για πολλά λεπτά.';

  @override
  String get trattiBreviVelociPausa =>
      'Σύντομα, γρήγορα κομμάτια με διάλειμμα ανάμεσα για αποκατάσταση. Σε κάνουν πιο γρήγορο.';

  @override
  String get blocchiAlRitmoVuoi =>
      'Τμήματα στον ρυθμό που θέλεις να κρατήσεις τη μέρα του αγώνα, για να τον συνηθίσεις.';

  @override
  String get corsaFacileQualcheAccelerazione =>
      'Χαλαρό τρέξιμο με μερικές σύντομες επιταχύνσεις (20 δευτερόλεπτα), γρήγορες αλλά χαλαρές. Κρατά τα πόδια ζωηρά χωρίς να τα κουράζει.';

  @override
  String get nuotoCalmoEserciziMigliorare =>
      'Ήρεμη κολύμβηση με ασκήσεις για καλύτερη τεχνική: όταν κολυμπάς σωστά, κουράζεσαι λιγότερο.';

  @override
  String get serieVascheRitmoSostenuto =>
      'Σετ από μήκη σε έντονο, σταθερό ρυθμό με σύντομα διαλείμματα. Βελτιώνει την ταχύτητα που κρατάς για πολλή ώρα.';

  @override
  String get pedalataCostanteRitmoFacile =>
      'Σταθερή ποδηλασία σε χαλαρό ρυθμό: χτίζει αντοχή.';

  @override
  String get pedalataPiuLungaSettimana =>
      'Η πιο μεγάλη διαδρομή της εβδομάδας, σε χαλαρό ρυθμό. Πάρε μαζί νερό και κάτι να φας.';

  @override
  String get trattiPedalataImpegnativaSalita =>
      'Κομμάτια δύσκολης ποδηλασίας (σε ανηφόρα ή σε ευθεία) με χαλαρά διαλείμματα ανάμεσα.';

  @override
  String get movimentiLentiAllungamentiQuasi =>
      'Αργές κινήσεις και διατάσεις, σχεδόν όλες με χρόνο. Χαλαρώνουν αρθρώσεις και μύες, βοηθούν την αποκατάσταση και σε κάνουν να κινείσαι καλύτερα. Δεν πρέπει ποτέ να πονάει.';

  @override
  String get mobilitaAncheCoscePolpacci =>
      'Κινητικότητα για ισχία, μηρούς και γάμπες: τα σημεία που δουλεύουν πιο πολύ στο τρέξιμο και στο ποδήλατο.';

  @override
  String get mobilitaSchienaBustoUtile =>
      'Κινητικότητα για πλάτη και κορμό: χρήσιμη αν κάθεσαι πολύ.';

  @override
  String get mobilitaSpallePettoBraccia =>
      'Κινητικότητα για ώμους, στήθος και χέρια: ανοίγει τη στάση του σώματος και βοηθά στην κολύμβηση.';

  @override
  String get eserciziMuscoliCorpoLibero =>
      'Ασκήσεις για τους μύες, με το βάρος του σώματος ή με βάρη, και μετά λίγα λεπτά κινητικότητας. Σε κάνουν πιο δυνατό και προστατεύουν από τραυματισμούς.';

  @override
  String get moltoFacileComeCamminata => 'πολύ εύκολα, σαν γρήγορο περπάτημα';

  @override
  String get facileRiesciParlare => 'εύκολα: μπορείς να μιλάς';

  @override
  String get medioParliMaFatica => 'μέτρια: μιλάς, αλλά με κόπο';

  @override
  String get impegnativoSoloPocheParole => 'δύσκολα: μόνο λίγες λέξεις';

  @override
  String get alMassimoSiRegge => 'στο μέγιστο: αντέχεται μόνο για λίγο';

  @override
  String get zoneFrequenzaCardiaca => 'Ζώνες καρδιακών παλμών';

  @override
  String get cinqueFasceBattitiAl =>
      'Πέντε εύρη παλμών το λεπτό, από το πιο εύκολο (1) ως το πιο δύσκολο (5). Η εφαρμογή τα υπολογίζει από τα δεδομένα σου: ακολούθησε τη ζώνη που δείχνει και η προπόνηση έχει το σωστό αποτέλεσμα.';

  @override
  String get fatica110 => 'Κόπωση (1 έως 10)';

  @override
  String get quantoTiSembrataDura =>
      'Πόσο δύσκολη σου φάνηκε η προπόνηση: 1 είναι βόλτα, 10 είναι το μέγιστο. Αν το λες στην εφαρμογή μετά από κάθε προπόνηση, προσαρμόζει το πρόγραμμα.';

  @override
  String get carico => 'Φορτίο';

  @override
  String get quantoTiSeiAllenato =>
      'Πόσο προπονήθηκες, με βάση τη διάρκεια και την κόπωση. Δες πώς αυξάνεται: αν ανεβαίνεις λίγο λίγο, δεν τραυματίζεσαι.';

  @override
  String get settimanaScarico => 'Εβδομάδα αποκατάστασης';

  @override
  String get ogniQuattroSettimanePiu =>
      'Κάθε τέσσερις εβδομάδες μία πιο ελαφριά: το σώμα αφομοιώνει τη δουλειά που έγινε και επιστρέφει πιο δυνατό.';

  @override
  String get comeStaiOggiSonno =>
      'Πώς είσαι σήμερα, από τον ύπνο και τους παλμούς ηρεμίας. Αν είναι χαμηλό, καλύτερα μια χαλαρή προπόνηση.';

  @override
  String get movimentiLentiSciogliereArticolazioni =>
      'Αργές κινήσεις για να χαλαρώσουν οι αρθρώσεις στο τέλος της προπόνησης.';

  @override
  String get stoRegistrandoPercorso => 'Καταγράφω τη διαδρομή';

  @override
  String get registrazionePercorso => 'Καταγραφή διαδρομής';

  @override
  String get sessioniAllenamento => 'Προπονήσεις';

  @override
  String get frequenzaCardiaca => 'Καρδιακοί παλμοί';

  @override
  String get distanza => 'Απόσταση';

  @override
  String get calorieAttive => 'Ενεργές θερμίδες';

  @override
  String get calorieTotali => 'Συνολικές θερμίδες';

  @override
  String get passi => 'Βήματα';

  @override
  String get velocita => 'Ταχύτητα';

  @override
  String get fcRiposo => 'Παλμοί ηρεμίας';

  @override
  String get variabilitaCardiacaHrv => 'Μεταβλητότητα καρδιακού ρυθμού (HRV)';

  @override
  String get sonno => 'Ύπνος';

  @override
  String get immagineNonDisponibileSenza =>
      'Η εικόνα δεν είναι διαθέσιμη χωρίς σύνδεση';

  @override
  String previsti(Object p0, Object p1) {
    return '$p0 (προγραμματισμένα $p1)';
  }

  @override
  String recupero(Object p0) {
    return 'Διάλειμμα $p0';
  }

  @override
  String fc(Object p0) {
    return 'Παλμοί $p0';
  }

  @override
  String get chiaveApiNonValida =>
      'Μη έγκυρο κλειδί API: αντέγραψέ το ξανά από intervals.icu → Settings → Developer settings.';

  @override
  String get intervalsIcuHaRicevuto =>
      'Το intervals.icu δέχτηκε πάρα πολλά αιτήματα: δοκίμασε ξανά σε λίγα λεπτά.';

  @override
  String intervalsIcuHaRisposto(Object p0) {
    return 'Το intervals.icu απάντησε με σφάλμα ($p0).';
  }

  @override
  String get nessunaConnessioneInternet => 'Δεν υπάρχει σύνδεση στο internet.';

  @override
  String get intervalsIcuNonRisponde =>
      'Το intervals.icu δεν απαντά: δοκίμασε ξανά.';

  @override
  String get rispostaIntervalsIcuNon =>
      'Η απάντηση του intervals.icu δεν διαβάζεται.';

  @override
  String get chiaveApiNonValida2 => 'Μη έγκυρο κλειδί API.';

  @override
  String get indirizzoOllamaNonValido =>
      'Μη έγκυρη διεύθυνση Ollama: γράψ\' τη έτσι: http://192.168.1.10:11434';

  @override
  String get proteggereTuoiDatiIndirizzo =>
      'Για να προστατευτούν τα δεδομένα σου, μια διεύθυνση http γίνεται δεκτή μόνο στο οικιακό δίκτυο (π.χ. http://192.168.1.10:11434). Μια διεύθυνση στο internet θέλει https.';

  @override
  String get rispostaVuotaDalModello => 'Κενή απάντηση από το μοντέλο.';

  @override
  String chiaveApiNonValida3(Object p0) {
    return 'Μη έγκυρο κλειδί API: αντέγραψέ το ξανά ολόκληρο από τον ιστότοπο της υπηρεσίας.\n($p0)';
  }

  @override
  String get richiestaRifiutataControllaNome =>
      'Το αίτημα απορρίφθηκε: έλεγξε το όνομα του μοντέλου.';

  @override
  String get chiaveApiNonValida4 => 'Μη έγκυρο κλειδί API ή λείπουν άδειες.';

  @override
  String get modelloNonTrovatoSu =>
      'Το μοντέλο δεν βρέθηκε στο Ollama: κατέβασέ το με «ollama pull».';

  @override
  String get modelloNonTrovatoControlla =>
      'Το μοντέλο δεν βρέθηκε: έλεγξε το όνομα.';

  @override
  String get limiteRichiesteRaggiuntoO =>
      'Έφτασες το όριο αιτημάτων ή τελείωσε η πίστωση. Δοκίμασε ξανά αργότερα.';

  @override
  String get servizioHaProblemaQuesto =>
      'Η υπηρεσία έχει πρόβλημα αυτή τη στιγμή. Δοκίμασε ξανά αργότερα.';

  @override
  String errore2(Object p0) {
    return 'Σφάλμα $p0.';
  }

  @override
  String get mancaChiaveApiAggiungila =>
      'Λείπει το κλειδί API: πρόσθεσέ το παραπάνω.';

  @override
  String nonRiescoRaggiungereOllama(Object p0, Object p1) {
    return 'Δεν μπορώ να φτάσω το Ollama στο $p0. ($p1)';
  }

  @override
  String nessunaConnessioneInternet2(Object p0) {
    return 'Δεν υπάρχει σύνδεση στο internet. ($p0)';
  }

  @override
  String get servizioNonRispondeRiprova =>
      'Η υπηρεσία δεν απαντά: δοκίμασε ξανά.';

  @override
  String get rispostaNonLeggibile => 'Η απάντηση δεν διαβάζεται.';

  @override
  String get indirizzoNonValido => 'Μη έγκυρη διεύθυνση.';

  @override
  String esempio(Object p0) {
    return ', για παράδειγμα $p0';
  }

  @override
  String chiaveFunzionaMaModello(Object p0, Object p1) {
    return 'Το κλειδί λειτουργεί, αλλά το μοντέλο «$p0» δεν υπάρχει. Πάτα ένα από το «Διάλεξε από τα διαθέσιμα μοντέλα»$p1.';
  }

  @override
  String get provaConnessione => 'Δοκιμή σύνδεσης';

  @override
  String ollamaRispondeMaModello(Object p0, Object p1) {
    return 'Το Ollama απαντά, αλλά το μοντέλο «$p0» δεν υπάρχει. Εγκατεστημένα: $p1.';
  }

  @override
  String nonRiescoRaggiungereOllama2(Object p0, Object p1) {
    return 'Δεν μπορώ να φτάσω το Ollama στο $p0. Είναι ανοιχτός ο υπολογιστής, στο ίδιο δίκτυο, με ανοιχτό το Ollama; ($p1)';
  }

  @override
  String get ollamaNonRispondePc =>
      'Το Ollama δεν απαντά: είναι ανοιχτός ο υπολογιστής;';

  @override
  String get indirizzoNonValidoO =>
      'Μη έγκυρη διεύθυνση ή η απάντηση δεν είναι από το Ollama.';

  @override
  String get indirizzoNonValidoScrivilo =>
      'Μη έγκυρη διεύθυνση: γράψ\' τη έτσι: http://IP:11434';

  @override
  String get mancaChiaveApiAggiungila2 =>
      'Λείπει το κλειδί API: πρόσθεσέ το στις ρυθμίσεις.';

  @override
  String nonRiescoRaggiungereOllama3(Object p0, Object p1) {
    return 'Δεν μπορώ να φτάσω το Ollama στο $p0. Είναι ανοιχτός ο υπολογιστής, στο ίδιο δίκτυο, με OLLAMA_HOST=0.0.0.0; ($p1)';
  }

  @override
  String get modelloCiStaMettendo => 'Το μοντέλο αργεί πολύ: δοκίμασε ξανά.';

  @override
  String get allenamentoInterrotto => 'Η προπόνηση διακόπηκε';

  @override
  String appSiEraChiusa(Object p0) {
    return 'Η εφαρμογή έκλεισε κατά την προπόνηση: $p0. Να συνεχίσεις από εκεί που έμεινες; Ξεκινά σε παύση.';
  }

  @override
  String get scarta => 'Απόρριψη';

  @override
  String get riprendi => 'Συνέχεια';

  @override
  String get rispostaRicevutaTroviCoach =>
      'Η απάντηση ήρθε: θα τη βρεις στον Προπονητή.';

  @override
  String get oggi => 'Σήμερα';

  @override
  String get progressi => 'Πρόοδος';

  @override
  String get coach => 'Προπονητής';

  @override
  String get profilo => 'Προφίλ';

  @override
  String circaMb(Object p0) {
    return 'περίπου $p0 MB';
  }

  @override
  String get downloadNonRiuscitoServe =>
      'Η λήψη απέτυχε: χρειάζεται σύνδεση. Δοκίμασε ξανά αργότερα.';

  @override
  String get lunedi => 'Δευτέρα';

  @override
  String get martedi => 'Τρίτη';

  @override
  String get mercoledi => 'Τετάρτη';

  @override
  String get giovedi => 'Πέμπτη';

  @override
  String get venerdi => 'Παρασκευή';

  @override
  String get sabato => 'Σάββατο';

  @override
  String get domenica => 'Κυριακή';

  @override
  String intensita2(Object p0) {
    return 'ένταση $p0';
  }

  @override
  String recuperoS(Object p0) {
    return 'διάλειμμα $p0 δευτ.';
  }

  @override
  String get tuaCorsaPiuLunga => 'Το πιο μεγάλο σου τρέξιμο';

  @override
  String get tuaUscitaBiciPiu => 'Η πιο μεγάλη σου βόλτα με ποδήλατο';

  @override
  String get tuaNuotataPiuLunga => 'Η πιο μεγάλη σου κολύμβηση';

  @override
  String get tuaCamminataPiuLunga => 'Το πιο μεγάλο σου περπάτημα';

  @override
  String get primoAllenamentoFatto => 'Η πρώτη προπόνηση έγινε!';

  @override
  String haiFattoAllenamenti(Object p0) {
    return 'Έκανες $p0 προπονήσεις!';
  }

  @override
  String record(Object p0) {
    return 'Ρεκόρ: $p0';
  }

  @override
  String settimaneFilaGrande(Object p0) {
    return '$p0 εβδομάδες στη σειρά: μπράβο!';
  }

  @override
  String settimaneFilaVai(Object p0, Object p1) {
    return '$p0 εβδομάδες στη σειρά. Πάμε για $p1;';
  }

  @override
  String get nelFileNonC =>
      'Στο αρχείο δεν υπάρχει διαδρομή: χρειάζεσαι ένα GPX με ίχνος.';

  @override
  String get destra => 'δεξιά';

  @override
  String get sinistra => 'αριστερά';

  @override
  String get tieniDestra => 'κράτα δεξιά';

  @override
  String get tieniSinistra => 'κράτα αριστερά';

  @override
  String curvaStretta(Object p0) {
    return 'κλειστή στροφή $p0';
  }

  @override
  String get tornaIndietro => 'γύρνα πίσω';

  @override
  String poiSubito(Object p0) {
    return 'και αμέσως μετά $p0';
  }

  @override
  String get nuovoSulPercorso => 'Ξανά στη διαδρομή.';

  @override
  String seiFuoriPercorsoDalla(Object p0) {
    return 'Είσαι εκτός διαδρομής, $p0 μακριά από την πορεία.';
  }

  @override
  String get staiAndandoNelSenso =>
      'Πηγαίνεις αντίθετα από την κατεύθυνση της διαδρομής.';

  @override
  String get arrivoPercorsoCompletato =>
      'Τερματισμός! Η διαδρομή ολοκληρώθηκε.';

  @override
  String tra(Object p0, Object p1, Object p2) {
    return 'Σε $p0, $p1$p2.';
  }

  @override
  String recuperoPoi(Object p0) {
    return 'Διάλειμμα · μετά $p0';
  }

  @override
  String pausa(Object p0) {
    return 'Παύση · $p0';
  }

  @override
  String get n5Km => '5 χλμ.';

  @override
  String get n10Km => '10 χλμ.';

  @override
  String get mezzaMaratona => 'Ημιμαραθώνιος';

  @override
  String get maratona => 'Μαραθώνιος';

  @override
  String get mediofondo => 'Medio fondo';

  @override
  String get granfondo => 'Gran fondo';

  @override
  String get triathlonSprint => 'Τρίαθλο sprint';

  @override
  String get triathlonOlimpico => 'Ολυμπιακό τρίαθλο';

  @override
  String get triathlon703 => 'Τρίαθλο 70.3';

  @override
  String get base => 'Βάση';

  @override
  String get sviluppo => 'Ανάπτυξη';

  @override
  String get rifinitura => 'Κορύφωση';

  @override
  String get scaricoPreGara => 'Αποφόρτιση πριν τον αγώνα';

  @override
  String get settimanaGara => 'Εβδομάδα αγώνα';

  @override
  String get senzaObiettivo => 'Χωρίς στόχο';

  @override
  String get volumeCrescePianoQuasi =>
      'Ο όγκος αυξάνεται αργά, σχεδόν όλος σε χαμηλή ένταση.';

  @override
  String get siAggiungonoSeduteQualita =>
      'Προστίθενται προπονήσεις ποιότητας, η μεγάλη προπόνηση μεγαλώνει.';

  @override
  String get lavoriAlRitmoGara => 'Δουλειά σε ρυθμό αγώνα, σταθερός όγκος.';

  @override
  String get menoVolumePoIntensita =>
      'Λιγότερος όγκος, λίγη ένταση για να μείνεις σε φόρμα.';

  @override
  String get pocheSeduteCorteSi =>
      'Λίγες σύντομες προπονήσεις: φτάνεις ξεκούραστος στην αφετηρία.';

  @override
  String get pianoMantenimentoImpostaGara =>
      'Πρόγραμμα διατήρησης: όρισε έναν αγώνα για προετοιμασία.';

  @override
  String get aerobica => 'Αερόβια';

  @override
  String get medio => 'Μέτρια';

  @override
  String get massimale => 'Μέγιστη';

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
      'Στο αρχείο δεν υπάρχει διαδρομή: χρειάζεσαι ένα GPX με το ίχνος της δραστηριότητας.';

  @override
  String get pulse => 'Pulse';

  @override
  String get strade => 'Δρόμοι';

  @override
  String get satellite => 'Δορυφόρος';

  @override
  String get facile => 'Εύκολη';

  @override
  String get fondo => 'Αντοχή';

  @override
  String get vo2max => 'VO2max';

  @override
  String get anaerobica => 'Αναερόβια';

  @override
  String get sprint => 'Σπριντ';

  @override
  String finoW(Object p0) {
    return 'έως $p0 W';
  }

  @override
  String oltreW(Object p0) {
    return 'πάνω από $p0 W';
  }

  @override
  String cadenzaScendiA(Object p0, Object p1) {
    return 'Συχνότητα $p0, κατέβα στις $p1.';
  }

  @override
  String cadenzaSaliA(Object p0, Object p1) {
    return 'Συχνότητα $p0, ανέβα στις $p1.';
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
    return '$p0 βατ, κατέβα στα $p1.';
  }

  @override
  String wattSaliA(Object p0, Object p1) {
    return '$p0 βατ, ανέβα στα $p1.';
  }

  @override
  String get registraQuestaCorsaAnche =>
      'Κατέγραψε αυτό το τρέξιμο και με το ρολόι σου: το ρολόι μετράει τα watt.';

  @override
  String get velociMaScioltiPoi =>
      'Γρήγορα αλλά χαλαρά, μετά περπάτα ή τρέξε πολύ αργά.';

  @override
  String get test20MinutiAl => 'Τεστ: 20 λεπτά στο μέγιστο';

  @override
  String get ritmoPiuForteRiesci =>
      'Ο πιο δυνατός ρυθμός που μπορείς να κρατήσεις ως το τέλος, σταθερά. Καλύτερα να ξεκινήσεις λίγο χαλαρά και να τελειώσεις δυνατά.';

  @override
  String get corsaLentissima => 'Πολύ χαλαρό τρέξιμο';

  @override
  String get energiaBuona => 'Καλή ενέργεια';

  @override
  String get energiaNormale => 'Κανονική ενέργεια';

  @override
  String get energiaBassa => 'Χαμηλή ενέργεια';

  @override
  String get giornataAdattaAncheSeduta =>
      'Καλή μέρα ακόμα και για προπόνηση ποιότητας.';

  @override
  String get allenatiComePrevistoAscoltando =>
      'Προπονήσου όπως προβλέπεται, ακούγοντας πώς νιώθεις.';

  @override
  String get meglioSedutaFacileO =>
      'Καλύτερα μια χαλαρή προπόνηση ή μέρα ξεκούρασης: χαμήλωσε την ένταση.';

  @override
  String solitoMsPiuAlta(Object p0) {
    return 'συνήθως $p0 ms · όσο πιο ψηλά τόσο καλύτερα';
  }

  @override
  String hrvMsSottoTua(Object p0, Object p1) {
    return 'HRV $p0 ms, κάτω από τον μέσο όρο σου ($p1 ms)';
  }

  @override
  String hrvMsSopraTua(Object p0) {
    return 'HRV $p0 ms, πάνω από τον μέσο όρο σου';
  }

  @override
  String solitoBpmPiuBassa(Object p0) {
    return 'συνήθως $p0 bpm · όσο πιο χαμηλά τόσο καλύτερα';
  }

  @override
  String fcRiposoBpmPiu(Object p0, Object p1) {
    return 'Παλμοί ηρεμίας $p0 bpm, πιο ψηλά από ό,τι συνήθως ($p1)';
  }

  @override
  String get bene7H30 => 'καλός από 7 ώ. 30 και πάνω, λίγος κάτω από 6 ώ.';

  @override
  String haiDormitoPoco(Object p0) {
    return 'Κοιμήθηκες λίγο ($p0)';
  }

  @override
  String haiDormitoBene(Object p0) {
    return 'Κοιμήθηκες καλά ($p0)';
  }

  @override
  String kg(Object p0, Object p1) {
    return '$p0 με $p1 kg';
  }

  @override
  String kg2(Object p0, Object p1) {
    return '$p0 × $p1 kg';
  }

  @override
  String get tempo => 'Χρόνος';

  @override
  String get passo => 'Ρυθμός';

  @override
  String get battitoMedio => 'Μέσοι παλμοί';

  @override
  String get sollevati => 'Σηκώθηκαν';

  @override
  String get calorie => 'Θερμίδες';

  @override
  String get classica => 'Κλασική';

  @override
  String get mappa => 'Χάρτης';

  @override
  String get poster => 'Αφίσα';

  @override
  String get kmKm => 'Χιλιόμετρο προς χιλιόμετρο';

  @override
  String get salita => 'Ανάβαση';

  @override
  String get esercizi => 'Ασκήσεις';

  @override
  String get muscoli => 'Μύες';

  @override
  String get seduta => 'Προπόνηση';

  @override
  String get tuaFoto => 'Η φωτογραφία σου';

  @override
  String kgPrimaKg(Object p0, Object p1, Object p2) {
    return '$p0 $p1 kg (πριν $p2 kg)';
  }

  @override
  String get kgSollevatiTutto => 'kg σηκώθηκαν συνολικά';

  @override
  String get arrampicata => 'ΑΝΑΡΡΙΧΗΣΗ';

  @override
  String get indoor => 'ΕΣΩΤΕΡΙΚΗ';

  @override
  String get outdoor => 'ΕΞΩΤΕΡΙΚΗ';

  @override
  String get gradoPiuAltoOggi => 'ο πιο ψηλός βαθμός σήμερα';

  @override
  String get blocchi => 'Boulder';

  @override
  String get saliti => 'Ανάβαση';

  @override
  String get attivita => 'Δραστηριότητα';

  @override
  String get altraAttivita => 'ΑΛΛΗ ΔΡΑΣΤΗΡΙΟΤΗΤΑ';

  @override
  String miaSettimana(Object p0) {
    return 'Η εβδομάδα μου ($p0)';
  }

  @override
  String sedute(Object p0, Object p1) {
    return '$p0/$p1 προπονήσεις';
  }

  @override
  String get abbiamoAggiornatoRegole => 'Ενημερώσαμε τους κανόνες';

  @override
  String get benvenutoAvidididadi => 'Καλώς ήρθες στο Avidididadi';

  @override
  String get terminiInformativaSonoCambiati =>
      'Οι όροι και η πολιτική απορρήτου άλλαξαν. Διάβασέ τους και αποδέξου τους για να συνεχίσεις.';

  @override
  String get primaIniziareEccoBreve =>
      'Πριν ξεκινήσεις, μια σύντομη περίληψη για το πώς η εφαρμογή χειρίζεται τα δεδομένα σου.';

  @override
  String get datiRestanoSulTelefono => 'Τα δεδομένα σου μένουν στο κινητό';

  @override
  String get nessunAccountNessunServer =>
      'Χωρίς λογαριασμό, χωρίς διακομιστή, χωρίς διαφημίσεις.';

  @override
  String get healthConnectSoloLettura => 'Health Connect μόνο για ανάγνωση';

  @override
  String get allenamentiBattitoSonnoPercorsi =>
      'Προπονήσεις, παλμοί, ύπνος και διαδρομές από τις εφαρμογές σου (π.χ. Garmin), μόνο αν το επιτρέψεις.';

  @override
  String get gpsSoloDuranteCorsa => 'GPS μόνο κατά το τρέξιμο και το ποδήλατο';

  @override
  String get mentreTiAlleniApp =>
      'Ενώ προπονείσαι με την εφαρμογή, με μόνιμη ειδοποίηση. Ποτέ άλλη στιγμή.';

  @override
  String get mappeImmaginiInternet => 'Χάρτες και εικόνες από το internet';

  @override
  String get openfreemapEsriSatelliteGithub =>
      'Από OpenFreeMap, Esri (δορυφόρος) και GitHub: η διαδρομή σου δεν αποστέλλεται.';

  @override
  String get assistenteFacoltativo => 'Προαιρετικός βοηθός';

  @override
  String get inviaRiassuntoDegliAllenamenti =>
      'Στέλνει μια περίληψη των προπονήσεών σου στην υπηρεσία που διαλέγεις, μόνο αν τον ενεργοποιήσεις.';

  @override
  String get nonConsiglioMedico => 'Δεν είναι ιατρική συμβουλή';

  @override
  String get pianiConsigliSonoStime =>
      'Τα προγράμματα και οι συμβουλές είναι εκτιμήσεις: αν έχεις αμφιβολίες ή προβλήματα υγείας, ρώτα τον γιατρό σου.';

  @override
  String get terminiCondizioni => 'Όροι και προϋποθέσεις';

  @override
  String get informativaPrivacy => 'Πολιτική απορρήτου';

  @override
  String get hoLettoAccettoTermini =>
      'Διάβασα και αποδέχομαι τους Όρους και προϋποθέσεις και την Πολιτική απορρήτου';

  @override
  String get entra => 'Είσοδος';

  @override
  String get nonAccettoEsci => 'Δεν αποδέχομαι, έξοδος';

  @override
  String get usaTuoAssistente => 'Χρησιμοποίησε τον βοηθό σου';

  @override
  String get parliCoachNellApp =>
      'Μιλάς με τον προπονητή στην εφαρμογή του βοηθού σου, με τη συνδρομή σου (ακόμα και δωρεάν): χωρίς κλειδί API.';

  @override
  String get avidididadiPreparaMessaggioTuoi =>
      'Το Avidididadi ετοιμάζει ένα μήνυμα με τα δεδομένα σου: το στέλνεις στον βοηθό με την Κοινοποίηση.';

  @override
  String get parliAssistenteNellaSua =>
      'Μιλάς με τον βοηθό στην εφαρμογή του, όσο θέλεις.';

  @override
  String get quandoProponeModificheO =>
      'Όταν προτείνει αλλαγές ή νέο πρόγραμμα, κοινοποίησε την απάντηση στο Avidididadi: βλέπεις μια προεπισκόπηση και αποφασίζεις εσύ.';

  @override
  String get qualeAppUsi => 'Ποια εφαρμογή χρησιμοποιείς;';

  @override
  String get primaIniziare => 'Πριν ξεκινήσεις';

  @override
  String get abbonamentoNormaleChatPossono =>
      'Με κανονική συνδρομή, οι συνομιλίες μπορεί να χρησιμοποιηθούν για την εκπαίδευση του μοντέλου, ανάλογα με τις ρυθμίσεις του λογαριασμού σου. Όνομα, φωτογραφία και διαδρομές GPS δεν αποστέλλονται ποτέ.';

  @override
  String get includiEtaSessoAltezza =>
      'Συμπερίληψη ηλικίας, φύλου, ύψους και βάρους';

  @override
  String get vediEsattamenteCosaViene => 'Δες ακριβώς τι αποστέλλεται';

  @override
  String acconsentoInviareQuestiDati(Object p0) {
    return 'Συμφωνώ να στέλνονται αυτά τα δεδομένα στο $p0 όταν πατάω Κοινοποίηση ή Αντιγραφή';
  }

  @override
  String collega(Object p0) {
    return 'Σύνδεση $p0';
  }

  @override
  String get privacyUsoDeiDati => 'Απόρρητο και χρήση δεδομένων';

  @override
  String get assistente => 'τον βοηθό';

  @override
  String manda(Object p0) {
    return 'Αποστολή στο $p0';
  }

  @override
  String messaggioCopiatoIncollalo(Object p0) {
    return 'Το μήνυμα αντιγράφηκε: επικόλλησέ το στο $p0.';
  }

  @override
  String appuntiSonoVuotiCopia(Object p0) {
    return 'Το πρόχειρο είναι κενό: αντέγραψε πρώτα την απάντηση από το $p0.';
  }

  @override
  String scollegare(Object p0) {
    return 'Αποσύνδεση από $p0;';
  }

  @override
  String get torniAlCoachDentro =>
      'Επιστρέφεις στον προπονητή μέσα στην εφαρμογή (για παράδειγμα Ollama στον υπολογιστή σου). Οι απαντήσεις από την τρέχουσα συνομιλία δεν θα γίνονται πια δεκτές: αν συνδεθείς ξανά, στείλε ξανά τα δεδομένα.';

  @override
  String get scollega => 'Αποσύνδεση';

  @override
  String get rispostaNonUsabile => 'Η απάντηση δεν μπορεί να χρησιμοποιηθεί';

  @override
  String n1Parla(Object p0) {
    return '1 · Μίλα με το $p0';
  }

  @override
  String get haiFattoAllenamentiNuovi =>
      'Έκανες νέες προπονήσεις; Στείλε τα ενημερωμένα δεδομένα στην ίδια συνομιλία.';

  @override
  String mandaPrimoMessaggioIstruzioni(Object p0) {
    return 'Στείλε το πρώτο μήνυμα: οδηγίες για τον προπονητή και τα δεδομένα σου. Διάλεξε $p0 από το μενού Κοινοποίησης.';
  }

  @override
  String ultimoInvio(Object p0, Object p1, Object p2) {
    return 'Τελευταία αποστολή: $p0, $p1:$p2';
  }

  @override
  String get mandaDatiAggiornati => 'Στείλε τα ενημερωμένα δεδομένα';

  @override
  String inizia(Object p0) {
    return 'Ξεκίνα με το $p0';
  }

  @override
  String get nuovaConversazione => 'Νέα συνομιλία';

  @override
  String get copiaInvece => 'Αντιγραφή αντί γι\' αυτό';

  @override
  String get n2PortaQuiModifiche => '2 · Φέρε τις αλλαγές εδώ';

  @override
  String quandoProponeCambiarePiano(Object p0) {
    return 'Όταν το $p0 προτείνει αλλαγή του προγράμματος, πάτα Κοινοποίηση στην απάντησή του και διάλεξε Avidididadi. Ή αντέγραψέ την και πάτα παρακάτω.';
  }

  @override
  String get incollaRisposta => 'Επικόλληση απάντησης';

  @override
  String get consiglioIstruzioniVoltaSola =>
      'Συμβουλή: οι οδηγίες μόνο μία φορά';

  @override
  String get incollaIstruzioniCoachProgetto =>
      'Επικόλλησε τις οδηγίες του προπονητή σε ένα Claude Project, ένα custom GPT ή ένα Gemini Gem. Μετά αρκεί να στέλνεις τα ενημερωμένα δεδομένα.';

  @override
  String get istruzioniCopiate => 'Οι οδηγίες αντιγράφηκαν.';

  @override
  String get copiaSoloIstruzioni => 'Αντιγραφή μόνο των οδηγιών';

  @override
  String scollega2(Object p0) {
    return 'Αποσύνδεση από $p0';
  }

  @override
  String get allenamentiArrampicata => 'Προπονήσεις αναρρίχησης';

  @override
  String get nuovo => 'Νέα';

  @override
  String get ancoraNessunAllenamento => 'Καμία προπόνηση ακόμα';

  @override
  String get crealoNuovoOppureChiedilo =>
      'Δημιούργησε μία με το «Νέα», ή ζήτα τη από τον βοηθό σου (για παράδειγμα στέλνοντάς του ένα στιγμιότυπο από άλλη εφαρμογή): κοινοποίησε το μπλοκ της απάντησής του στην εφαρμογή και θα βρεις την προπόνηση εδώ, έτοιμη να μπει στο ημερολόγιο.';

  @override
  String get altri => 'Άλλες';

  @override
  String get giorno => 'Ποια μέρα;';

  @override
  String nelCalendario(Object p0, Object p1) {
    return 'Το $p0 είναι στο ημερολόγιο: $p1.';
  }

  @override
  String get nonStatoPossibileScegli =>
      'Δεν ήταν δυνατό: διάλεξε σήμερα ή κάποια επόμενη μέρα.';

  @override
  String eliminare(Object p0) {
    return 'Διαγραφή του «$p0»;';
  }

  @override
  String get sparisceDallaRaccoltaSedute =>
      'Εξαφανίζεται από τη συλλογή. Οι προπονήσεις που είναι ήδη στο ημερολόγιο μένουν.';

  @override
  String get elimina => 'Διαγραφή';

  @override
  String get allenamentoNonTrovato => 'Η προπόνηση δεν βρέθηκε.';

  @override
  String get modifica => 'Επεξεργασία';

  @override
  String get iniziaOra => 'Ξεκίνα τώρα';

  @override
  String get aggiungiAlPiano => 'Προσθήκη στο πρόγραμμα';

  @override
  String allaFineSegna(Object p0) {
    return 'Στο τέλος, κατέγραψε: $p0';
  }

  @override
  String get servonoNomeAlmenoEsercizio =>
      'Χρειάζεσαι όνομα και τουλάχιστον μία άσκηση.';

  @override
  String get durataVa0300 => 'Η διάρκεια είναι από 0 έως 300 λεπτά.';

  @override
  String get nuovoAllenamento => 'Νέα προπόνηση';

  @override
  String get salva => 'Αποθήκευση';

  @override
  String get nome => 'Όνομα';

  @override
  String get es50507 => 'π.χ. 50-50, 7:3s 40%';

  @override
  String get categoria => 'Κατηγορία';

  @override
  String get dove => 'Πού';

  @override
  String get vuotoCalcoloDagliEsercizi =>
      'Κενό = το υπολογίζω από τις ασκήσεις.';

  @override
  String get descrizione => 'Περιγραφή';

  @override
  String get cosaSegnareAllaFine => 'Τι να καταγράψεις στο τέλος';

  @override
  String get esGradoMedioDelle => 'π.χ. ο μέσος βαθμός των δύο μερών';

  @override
  String get spostaSu => 'Μετακίνηση πάνω';

  @override
  String get togli => 'Αφαίρεση';

  @override
  String get aggiungiEsercizio => 'Προσθήκη άσκησης';

  @override
  String get controllaNomeSerie1 =>
      'Έλεγξε: όνομα, σετ 1-20, επαναλήψεις 1-100, δευτερόλεπτα 0-3600.';

  @override
  String get esercizio3 => 'Άσκηση';

  @override
  String get esSospensioniVieBlocchi => 'π.χ. Κρεμάσματα, Διαδρομές, Boulder';

  @override
  String get serie2 => 'Σετ';

  @override
  String get ripetizioni => 'Επαναλήψεις';

  @override
  String get lavoro => 'Δουλειά';

  @override
  String get pausa2 => 'Παύση';

  @override
  String get traSerie => 'Ανάμεσα στα σετ';

  @override
  String get lavoroVuotoFincheNon =>
      'Κενή δουλειά = μέχρι να τελειώσεις (μια διαδρομή, ένα boulder): πατάς «Έγινε». Παύση: ανάμεσα σε μια επανάληψη και την επόμενη.';

  @override
  String get intensitaOGrado => 'Ένταση ή βαθμός';

  @override
  String get es406bFacile => 'π.χ. 40%, 6b+, εύκολα';

  @override
  String get note => 'Σημειώσεις';

  @override
  String get ok => 'OK';

  @override
  String get attivita2 => 'Τι δραστηριότητα είναι;';

  @override
  String get nomeRestaSullaSessione =>
      'Το όνομα μένει στην προπόνηση, στο ημερολόγιο και στο ιστορικό.';

  @override
  String get esKayakPadelSci => 'Π.χ. Καγιάκ, Padel, Σκι';

  @override
  String get registraPercorsoGps => 'Καταγραφή διαδρομής GPS';

  @override
  String get mappaDistanzaVelocitaAnche =>
      'Χάρτης, απόσταση και ταχύτητα, ακόμα και με σβηστή οθόνη. Κλειστό: μόνο χρόνος και παλμοί.';

  @override
  String get inizia2 => 'Έναρξη';

  @override
  String get avanti => 'Επόμενο';

  @override
  String get datiCollegamenti => 'Δεδομένα και συνδέσεις';

  @override
  String get collegaOrologioOApp =>
      'Σύνδεσε το ρολόι ή τις εφαρμογές που χρησιμοποιείς (Garmin, Freeletics…) μέσω Health Connect: οι προπονήσεις που κάνεις έρχονται μόνες τους.';

  @override
  String get paroleDellAllenamento => 'Λέξεις της προπόνησης';

  @override
  String get concetti => 'Έννοιες';

  @override
  String get zoneComeTiDevi => 'Ζώνες: πώς πρέπει να νιώθεις';

  @override
  String zona(Object p0) {
    return 'Ζώνη $p0';
  }

  @override
  String get tipiSeduta => 'Είδη προπόνησης';

  @override
  String prova(Object p0) {
    return ' · δοκιμή $p0';
  }

  @override
  String avidididadiVersione(Object p0, Object p1, Object p2) {
    return 'Avidididadi · έκδοση $p0 ($p1)$p2';
  }

  @override
  String avidididadiVersioneBreve(Object p0) {
    return 'Avidididadi · έκδοση $p0';
  }

  @override
  String get tuaArrampicata => 'Η αναρρίχησή σου';

  @override
  String get palestra => 'Γυμναστήριο';

  @override
  String get falesiaOZona => 'Βράχος ή περιοχή';

  @override
  String get facoltativo => 'Προαιρετικό';

  @override
  String get cosaHaiFatto => 'Τι έκανες';

  @override
  String get scegliVieOBoulder =>
      'Διάλεξε διαδρομές ή boulder: οι βαθμοί έχουν δύο διαφορετικές κλίμακες.';

  @override
  String get gradoPiuDifficileChiuso => 'Ο δυσκολότερος βαθμός που ολοκλήρωσες';

  @override
  String nuovoRecordPrimaEra(Object p0) {
    return 'Νέο ρεκόρ! Πριν ήταν $p0.';
  }

  @override
  String tuoRecord(Object p0, Object p1, Object p2, Object p3) {
    return 'Το ρεκόρ σου: $p0 ($p1 $p2 $p3).';
  }

  @override
  String get alPrimoTentativoSenza =>
      'Με την πρώτη προσπάθεια, χωρίς να ξέρεις τίποτα από πριν.';

  @override
  String get alPrimoTentativoSapendo =>
      'Με την πρώτη προσπάθεια, ξέροντας ήδη τις κινήσεις.';

  @override
  String get chiusaDopoAverlaProvata =>
      'Ολοκληρώθηκε αφού τη δοκίμασες πολλές φορές.';

  @override
  String get comeHaiChiusaFacoltativo => 'Πώς την ολοκλήρωσες; (προαιρετικό)';

  @override
  String get vieChiuse2 => 'Διαδρομές που ολοκληρώθηκαν';

  @override
  String get blocchiChiusi2 => 'Boulder που ολοκληρώθηκαν';

  @override
  String provatSenzaChiuderl(Object p0, Object p1) {
    return 'Δοκιμάστηκαν χωρίς ολοκλήρωση';
  }

  @override
  String get altezzaMediaDelleVie => 'Μέσο ύψος διαδρομών (μ.)';

  @override
  String circaMetriSaliti(Object p0) {
    return 'Περίπου $p0 μέτρα ανάβαση.';
  }

  @override
  String get progettoGradoStaiProvando => 'Project (ο βαθμός που δουλεύεις)';

  @override
  String get nessuno => 'Κανένα';

  @override
  String get meno => 'Λιγότερο';

  @override
  String get piu => 'Περισσότερο';

  @override
  String get comAndataQuestaSettimana => 'Πώς πήγε αυτή η εβδομάδα;';

  @override
  String get giovediHoPocoTempo =>
      'Την Πέμπτη έχω λίγο χρόνο: τι να μετακινήσω;';

  @override
  String get adattaProssimiGiorniAl =>
      'Προσάρμοσε τις επόμενες μέρες στην αποκατάστασή μου';

  @override
  String get sonoProntoGara => 'Είμαι έτοιμος για τον αγώνα;';

  @override
  String collegato2(Object p0) {
    return 'Συνδεδεμένο με $p0';
  }

  @override
  String get impostazioniAssistente => 'Ρυθμίσεις βοηθού';

  @override
  String get chiedimiDeiTuoiAllenamenti =>
      'Ρώτα με για τις προπονήσεις σου: βλέπω τις τελευταίες 4 εβδομάδες, τις αξιολογήσεις, την αποκατάστασή σου και το πρόγραμμα των επόμενων 14 ημερών. Αν προτείνω αλλαγή του προγράμματος, αποφασίζεις εσύ αν θα την εφαρμόσεις.';

  @override
  String get stoPensando => 'Σκέφτομαι…';

  @override
  String get scriviMessaggio => 'Γράψε ένα μήνυμα';

  @override
  String get invia => 'Αποστολή';

  @override
  String get allenatoreCuiParlareDei =>
      'Ένας προπονητής για να μιλάς για τις προπονήσεις σου, που μπορεί να προτείνει αλλαγές στο πρόγραμμα. Χρησιμοποίησε το μοντέλο που προτιμάς:';

  @override
  String get facoltativoSenzaAssistenteApp =>
      'Είναι προαιρετικό: χωρίς βοηθό η εφαρμογή λειτουργεί όπως πάντα.';

  @override
  String get configuraAssistente => 'Ρύθμιση βοηθού';

  @override
  String get modificheProposteAlPiano => 'Προτεινόμενες αλλαγές στο πρόγραμμα';

  @override
  String get applicateAlPiano => 'Εφαρμόστηκαν στο πρόγραμμα.';

  @override
  String get nonApplicabili => 'Δεν μπορούν να εφαρμοστούν';

  @override
  String get nienteApplicarePianoCambiato =>
      'Τίποτα για εφαρμογή: το πρόγραμμα άλλαξε στο μεταξύ.';

  @override
  String pianoAggiornatoModificheVedi(Object p0) {
    return 'Το πρόγραμμα ενημερώθηκε: $p0 αλλαγές. Μπορείς να τις δεις στο ημερολόγιο.';
  }

  @override
  String applicaModifiche(Object p0) {
    return 'Εφαρμογή $p0 αλλαγών';
  }

  @override
  String get nessunModelloDisponibileQuesta =>
      'Κανένα διαθέσιμο μοντέλο με αυτό το κλειδί.';

  @override
  String get consigliato => 'Προτείνεται';

  @override
  String get coachNellaSuaApp =>
      'Ο προπονητής είναι στη δική του εφαρμογή. Αποσυνδέσου από τη σελίδα Προπονητής για να επιστρέψεις στην παρακάτω υπηρεσία.';

  @override
  String get usaTuoAbbonamentoClaude =>
      'Χρησιμοποίησε τη συνδρομή σου (Claude, ChatGPT, Gemini…)';

  @override
  String get senzaChiaveApiParli =>
      'Χωρίς κλειδί API: μιλάς με τον προπονητή στην εφαρμογή του βοηθού σου.';

  @override
  String get coachNellAppQuando =>
      'Προπονητής στην εφαρμογή (όταν αποσυνδεθείς)';

  @override
  String get servizio => 'Υπηρεσία';

  @override
  String get chiaveApi => 'Κλειδί API';

  @override
  String chiaveSalvata(Object p0) {
    return 'Το κλειδί αποθηκεύτηκε ••••$p0';
  }

  @override
  String get cifrataSulTelefono => 'Κρυπτογραφημένο στο κινητό.';

  @override
  String get incollaChiaveApi => 'Επικόλλησε το κλειδί API';

  @override
  String get salvaChiave => 'Αποθήκευση κλειδιού';

  @override
  String get siPagaConsumoSul =>
      'Πληρώνεις όσο χρησιμοποιείς, στον λογαριασμό σου: μια ερώτηση συνήθως κοστίζει λίγα λεπτά του ευρώ ή λιγότερο. Μπορείς να βάλεις όριο εξόδων στον ιστότοπο της υπηρεσίας.';

  @override
  String get indirizzoOllama => 'Διεύθυνση Ollama';

  @override
  String get indirizzoPc => 'Διεύθυνση υπολογιστή';

  @override
  String get sulPcInstallaOllama =>
      'Στον υπολογιστή: εγκατάστησε το Ollama, κατέβασε ένα μοντέλο (ollama pull llama3.1) και ξεκίνα το με OLLAMA_HOST=0.0.0.0 ώστε να το φτάνει το κινητό. Τη διεύθυνση IP του υπολογιστή τη βρίσκεις με «ipconfig».';

  @override
  String get modello => 'Μοντέλο';

  @override
  String get nomeModello => 'Όνομα μοντέλου';

  @override
  String get vuotoPiuAdattoTra => 'Κενό = το πιο κατάλληλο από τα διαθέσιμα';

  @override
  String get scegliTraModelliDisponibili => 'Διάλεξε από τα διαθέσιμα μοντέλα';

  @override
  String get datiInviati => 'Δεδομένα που αποστέλλονται';

  @override
  String get nomeFotoNonVengono =>
      'Όνομα και φωτογραφία δεν αποστέλλονται ποτέ.';

  @override
  String get acconsentoInviareQuestiDati2 =>
      'Συμφωνώ να στέλνονται αυτά τα δεδομένα στον υπολογιστή μου με το Ollama';

  @override
  String acconsentoInviareQuestiDati3(Object p0) {
    return 'Συμφωνώ να στέλνονται αυτά τα δεδομένα στο $p0 με κάθε μήνυμα';
  }

  @override
  String nonRaggiungibile(Object p0) {
    return 'Το $p0 δεν είναι προσβάσιμο';
  }

  @override
  String verifica(Object p0) {
    return 'Έλεγχος $p0…';
  }

  @override
  String get provaConnessione2 => 'Δοκιμή σύνδεσης';

  @override
  String collegamento(Object p0) {
    return 'Σύνδεση με $p0…';
  }

  @override
  String get riprova => 'Ξανά';

  @override
  String nonCollegato(Object p0) {
    return '$p0 δεν είναι συνδεδεμένο';
  }

  @override
  String togliere(Object p0) {
    return 'Αφαίρεση: $p0;';
  }

  @override
  String seduteFutureEsconoDal(Object p0) {
    return 'Οι μελλοντικές προπονήσεις $p0 βγαίνουν από το ημερολόγιο. Όσες έχουν ήδη γίνει μένουν στο ιστορικό.';
  }

  @override
  String get tueAttivitaSonoAggiornate => 'Οι δραστηριότητές σου ενημερώθηκαν.';

  @override
  String get mieAttivita => 'Οι δραστηριότητές μου';

  @override
  String get nelPianoNeiMenu =>
      'Στο πρόγραμμα και στα μενού βλέπεις μόνο αυτές. Από το «+» μπορείς πάντα να κάνεις και κάτι άλλο, και ό,τι κάνεις μένει στο ιστορικό.';

  @override
  String quando(Object p0) {
    return '$p0: πότε;';
  }

  @override
  String get scegliGiorniAllenamentoDecidi =>
      'Διάλεξε τις μέρες. Την προπόνηση την αποφασίζεις εσύ ή τη ζητάς από τον βοηθό: η εφαρμογή δεν γράφει μόνη της.';

  @override
  String get scegliGiorniMettiamoSedute =>
      'Διάλεξε τις μέρες: βάζουμε τις προπονήσεις στο ημερολόγιο.';

  @override
  String get quantoDura => 'Πόσο διαρκεί';

  @override
  String get nonOra => 'Όχι τώρα';

  @override
  String get mettiNelCalendario => 'Βάλε στο ημερολόγιο';

  @override
  String get scriviAlmenoPeso => 'Γράψε τουλάχιστον ένα βάρος';

  @override
  String get pesiDisponibili => 'Διαθέσιμα βάρη';

  @override
  String get nessunPeso => 'Κανένα βάρος';

  @override
  String letti(Object p0) {
    return 'Διαβάστηκαν: $p0';
  }

  @override
  String get miaAttrezzatura => 'Ο εξοπλισμός μου';

  @override
  String corpoLiberoSempreIncluso(Object p0, Object p1) {
    return 'Το βάρος σώματος περιλαμβάνεται πάντα. Με αυτόν τον εξοπλισμό μπορείς να κάνεις $p0 ασκήσεις από $p1.';
  }

  @override
  String get palestra2 => 'Στο γυμναστήριο';

  @override
  String get selezionaTutte => 'Επιλογή όλων';

  @override
  String get salvaBackup => 'Αποθήκευσε το αντίγραφο ασφαλείας';

  @override
  String get backupSalvatoCopialoAnche =>
      'Το αντίγραφο ασφαλείας αποθηκεύτηκε. Αντέγραψέ το και έξω από το κινητό (Drive, υπολογιστής) για να μην το χάσεις.';

  @override
  String backupNonRiuscito(Object p0) {
    return 'Το αντίγραφο ασφαλείας απέτυχε: $p0';
  }

  @override
  String impossibileLeggereFile(Object p0) {
    return 'Δεν διαβάζεται το αρχείο: $p0';
  }

  @override
  String get ripristinareBackup => 'Επαναφορά του αντιγράφου ασφαλείας;';

  @override
  String tuttiDatiAttualiDell(Object p0) {
    return '$p0.\n\nΌλα τα τωρινά δεδομένα της εφαρμογής θα αντικατασταθούν. Αν δεν είσαι σίγουρος, αποθήκευσε πρώτα ένα αντίγραφο ασφαλείας του τώρα.';
  }

  @override
  String get ripristina => 'Επαναφορά';

  @override
  String get datiRipristinatiAllaProssima =>
      'Τα δεδομένα επανήλθαν. Στον επόμενο συγχρονισμό το Health Connect διαβάζει ξανά το ιστορικό.';

  @override
  String ripristinoNonRiuscito(Object p0) {
    return 'Η επαναφορά απέτυχε: $p0';
  }

  @override
  String get backupSalvatoNellaCartella =>
      'Το αντίγραφο ασφαλείας αποθηκεύτηκε στον φάκελο.';

  @override
  String get backupAutomatico => 'Αυτόματο αντίγραφο ασφαλείας';

  @override
  String get cartellaTelefono => 'έναν φάκελο στο κινητό';

  @override
  String ultimo(Object p0) {
    return ' · τελευταίο $p0';
  }

  @override
  String inTesto(Object p0, Object p1) {
    return 'Σε $p0$p1';
  }

  @override
  String cartellaScegliTuResta(Object p0) {
    return 'Σε έναν φάκελο που διαλέγεις: μένει ακόμα κι αν απεγκαταστήσεις την εφαρμογή. Κρατά τα τελευταία $p0.';
  }

  @override
  String get ogniGiorno => 'Κάθε μέρα';

  @override
  String get ogniSettimana => 'Κάθε εβδομάδα';

  @override
  String get siFaSoloQuando =>
      'Γίνεται μόνο του όταν ανοίγεις την εφαρμογή. Για να μην το χάσεις μαζί με το κινητό, πού και πού αντέγραψε τον φάκελο στον υπολογιστή ή στο Drive.';

  @override
  String get falloOra => 'Κάν\' το τώρα';

  @override
  String get cambiaCartella => 'Αλλαγή φακέλου';

  @override
  String get backup => 'Αντίγραφο ασφαλείας';

  @override
  String get unicoFileSessioniPiano =>
      'Ένα μόνο αρχείο με προπονήσεις, πρόγραμμα, προφίλ, μετρήσεις, αξιολογήσεις, αποκατάσταση και φωτογραφία. Το κλειδί του βοηθού δεν περιλαμβάνεται.';

  @override
  String get salvaBackup2 => 'Αποθήκευση αντιγράφου';

  @override
  String get backupAttivoOraSi =>
      'Το αντίγραφο ασφαλείας ενεργοποιήθηκε: από τώρα αποθηκεύεται μόνο του κάθε εβδομάδα.';

  @override
  String get mettiAlSicuroTuoi =>
      'Κράτα ασφαλείς τις προπονήσεις σου: η εφαρμογή αποθηκεύει μόνη της ένα αντίγραφο σε φάκελο που διαλέγεις. Μένει ακόμα κι αν απεγκαταστήσεις την εφαρμογή.';

  @override
  String get scegliNuovoCartella => 'Διάλεξε ξανά τον φάκελο';

  @override
  String get attivaBackup => 'Ενεργοποίηση αντιγράφου ασφαλείας';

  @override
  String get battitoDalSensore => 'Παλμοί από αισθητήρα';

  @override
  String get fasciaCardioOOrologio =>
      'Ζώνη καρδιακών παλμών ή ρολόι που μεταδίδει τους παλμούς μέσω Bluetooth. Τους βλέπεις κατά την προπόνηση· στο τέλος αποθηκεύονται ο μέσος όρος και ο μέγιστος.';

  @override
  String get garminSullOrologioCerca =>
      'Garmin: στο ρολόι ψάξε τη «Μετάδοση καρδιακών παλμών» (συνήθως στα χειριστήρια, κρατώντας πατημένο το κουμπί φωτισμού) και ενεργοποίησέ τη· μετά πάτα «Αναζήτηση». Μερικά παλιά μοντέλα μεταδίδουν μόνο μέσω ANT+, που το κινητό δεν διαβάζει.\nΖώνη: φόρεσέ τη βρέχοντας λίγο τα ηλεκτρόδια, ανοίγει μόνη της.\nΜόλις τον διαλέξεις, ο αισθητήρας συνδέεται ξανά μόνος του σε κάθε προπόνηση.';

  @override
  String get sensoriBici => 'Αισθητήρες ποδηλάτου';

  @override
  String get rulliSmartTacxWahoo =>
      'Έξυπνα προπονητήρια (Tacx, Wahoo, Elite…), μετρητής ισχύος ή αισθητήρας ταχύτητας και ρυθμού πεταλιού, μέσω Bluetooth. Στο τέλος αποθηκεύονται η μέση ισχύς και ο ρυθμός πεταλιού.';

  @override
  String get rulliAccendiliSmettiUsarli =>
      'Προπονητήρια: άναψέ τα και σταμάτα να τα χρησιμοποιείς με άλλες εφαρμογές (Zwift, Tacx), γιατί πολλά συνδέονται μόνο με μία εφαρμογή τη φορά.\nΑισθητήρας ταχύτητας ή ρυθμού: ξυπνά όταν γυρίζεις τον τροχό ή τα πετάλια.\nΗ περίμετρος του τροχού χρειάζεται μόνο για τον αισθητήρα ταχύτητας: τη βρίσκεις γραμμένη στο λάστιχο (π.χ. 700×25C = 2105 mm).';

  @override
  String get servePermessoDispositiviNelle =>
      'Χρειάζεται η άδεια «Συσκευές κοντά».';

  @override
  String get apriImpostazioni => 'Άνοιγμα ρυθμίσεων';

  @override
  String get bluetoothSpentoAccendiloRiprova =>
      'Το Bluetooth είναι κλειστό: άνοιξέ το και δοκίμασε ξανά.';

  @override
  String collegato3(Object p0) {
    return 'Συνδεδεμένο · $p0';
  }

  @override
  String get collegatoAspettoDati => 'Συνδεδεμένο, περιμένω δεδομένα…';

  @override
  String get miCollegoDevEssere =>
      'Συνδέομαι… (πρέπει να είναι ανοιχτό και κοντά)';

  @override
  String get nonCollegato2 => 'Δεν είναι συνδεδεμένο';

  @override
  String get dimentica => 'Διαγραφή';

  @override
  String get cercoSensoriVicini => 'Ψάχνω αισθητήρες κοντά…';

  @override
  String get sensoriTrovati => 'Αισθητήρες που βρέθηκαν';

  @override
  String get nessunSensoreTrovato => 'Δεν βρέθηκε κανένας αισθητήρας.';

  @override
  String get cercaAltroSensore => 'Αναζήτηση άλλου αισθητήρα';

  @override
  String get cercaNuovo => 'Νέα αναζήτηση';

  @override
  String get comeSiCollega => 'Πώς συνδέεται';

  @override
  String get segnaleForte => 'Δυνατό σήμα';

  @override
  String get segnaleMedio => 'Μέτριο σήμα';

  @override
  String get segnaleDebole => 'Αδύναμο σήμα';

  @override
  String adessoKmH(Object p0) {
    return ' Τώρα: $p0 χλμ./ώ.';
  }

  @override
  String get maiFattaQui => 'Δεν έγινε ποτέ από εδώ.';

  @override
  String ultima(Object p0) {
    return 'Τελευταία: $p0.';
  }

  @override
  String tienePrecisiWattFalla(Object p0) {
    return '$p0 Κρατά ακριβή τα watt: κάν\' τη περίπου κάθε δύο εβδομάδες και κάθε φορά που μετακινείς το προπονητήριο, ιδανικά μετά από 10 λεπτά ποδηλασίας.';
  }

  @override
  String get chiedoAlRulloIniziare => 'Ζητάω από το προπονητήριο να ξεκινήσει…';

  @override
  String pedalaAcceleraFincheRullo(Object p0) {
    return 'Κάνε πετάλι και επιτάχυνε μέχρι να σου πει το προπονητήριο να σταματήσεις.$p0';
  }

  @override
  String acceleraFinoSuperareKm(Object p0, Object p1) {
    return 'Επιτάχυνε μέχρι να περάσεις τα $p0 χλμ./ώ.$p1';
  }

  @override
  String smettiPedalareAspettaRullo(Object p0) {
    return 'Σταμάτα το πετάλι και περίμενε να σταματήσει το προπονητήριο.$p0';
  }

  @override
  String get calibrazioneRiuscita => 'Η βαθμονόμηση πέτυχε.';

  @override
  String get nonRiuscitaControllaNessun =>
      'Δεν πέτυχε. Έλεγξε ότι καμία άλλη εφαρμογή δεν χρησιμοποιεί το προπονητήριο και δοκίμασε ξανά.';

  @override
  String get calibraRullo => 'Βαθμονόμηση προπονητηρίου';

  @override
  String get iniziaCalibrazione => 'Έναρξη βαθμονόμησης';

  @override
  String get circonferenzaRuota => 'Περίμετρος τροχού';

  @override
  String get soloSensoreVelocita700 =>
      'Μόνο για τον αισθητήρα ταχύτητας. 700×25C: 2105 mm.';

  @override
  String get tuoPianoProntoPrima =>
      'Το πρόγραμμά σου είναι έτοιμο! Η πρώτη προπόνηση είναι εδώ, στο «Σήμερα». Μπορείς να αλλάξεις μέρες και διάρκεια όποτε θέλεις από το Προφίλ.';

  @override
  String get tuoPianoProntoOggi =>
      'Το πρόγραμμά σου είναι έτοιμο! Στο «Σήμερα» θα βρίσκεις τι να κάνεις κάθε μέρα.';

  @override
  String get indietro => 'Πίσω';

  @override
  String get comeTiChiami => 'Πώς σε λένε;';

  @override
  String get cosiAppTiSaluta => 'Για να σε χαιρετά η εφαρμογή με το όνομά σου.';

  @override
  String get tuoNome => 'Το όνομά σου';

  @override
  String get cosaTiPiacerebbeFare => 'Τι θα ήθελες να κάνεις;';

  @override
  String get puoiScegliernePiuUno =>
      'Μπορείς να διαλέξεις περισσότερα από ένα. Με το «Ξεκίνα σήμερα» αρχίζεις με 3 προπονήσεις των 30 λεπτών την εβδομάδα (Δευτέρα, Τετάρτη και Παρασκευή), κατάλληλες για αρχάριους, και η πρώτη είναι σήμερα. Μπορείς να αλλάξεις τα πάντα όποτε θέλεις.';

  @override
  String get quantoTempoHai => 'Πόσο χρόνο έχεις;';

  @override
  String get meglioPocoMaCostanza =>
      'Καλύτερα λίγο αλλά συχνά: για αρχή, 3 μέρες των 30 λεπτών είναι ιδανικές.';

  @override
  String get giorniSettimana => 'Μέρες την εβδομάδα';

  @override
  String get minutiOgniVolta => 'Λεπτά κάθε φορά';

  @override
  String giorniNonCSpazio(Object p0, Object p1) {
    return 'Με $p0 μέρες δεν χωράνε όλα τα αθλήματα που διάλεξες: θα χρησιμοποιήσω $p1.';
  }

  @override
  String get quantoTiAlleniSolito => 'Πόσο συχνά προπονείσαι συνήθως;';

  @override
  String get rispondiSinceramentePianoParte =>
      'Απάντησε ειλικρινά: το πρόγραμμα ξεκινά από το επίπεδό σου και μεγαλώνει μαζί σου.';

  @override
  String get iniziaOggi => 'Ξεκίνα σήμερα';

  @override
  String get primaScelgoGiorniDurata =>
      'Πρώτα διαλέγω μέρες, διάρκεια και επίπεδο';

  @override
  String get creaMioPiano => 'Δημιούργησε το πρόγραμμά μου';

  @override
  String get scegliAlmenoUnoSport => 'Διάλεξε τουλάχιστον ένα άθλημα';

  @override
  String get benvenuto => 'Καλώς ήρθες!';

  @override
  String get tiPreparoPianoAllenamento =>
      'Σου ετοιμάζω ένα πρόγραμμα προπόνησης φτιαγμένο για σένα, ακόμα κι αν δεν έχεις προπονηθεί ποτέ. Κάθε μέρα σου λέω τι να κάνεις, βήμα βήμα, και το πρόγραμμα προσαρμόζεται στο πώς νιώθεις.';

  @override
  String get scegliTuoiSportParti =>
      'Διάλεξε τα αθλήματά σου και ξεκίνα αμέσως.';

  @override
  String get iniziamo => 'Ας ξεκινήσουμε';

  @override
  String get saltaPreferiscoFareSolo =>
      'Παράλειψη, προτιμώ να το κάνω μόνος μου';

  @override
  String get haiOrologioSportivo => 'Έχεις αθλητικό ρολόι;';

  @override
  String get vaBeneAncheSenza =>
      'Είναι εντάξει και χωρίς: η εφαρμογή δουλεύει μόνο με το κινητό.';

  @override
  String get noSoloTelefono => 'Όχι, μόνο το κινητό';

  @override
  String get nienteOrologioFasciaCardio =>
      'Χωρίς ρολόι, ζώνη παλμών ή άλλες εφαρμογές.';

  @override
  String get siOrologioOFascia => 'Ναι, ρολόι ή ζώνη';

  @override
  String get garminPolarSuuntoCoros => 'Garmin, Polar, Suunto, Coros, Wahoo…';

  @override
  String get corsaCamminataBiciRegistra =>
      'Το κινητό καταγράφει τρέξιμο, περπάτημα και ποδήλατο με GPS, και σε καθοδηγεί με φωνή βήμα βήμα.';

  @override
  String get zoneEsempioZona2 =>
      'Ακολούθησε τις ζώνες (για παράδειγμα «ζώνη 2») με την αίσθηση: στη ζώνη 2 μπορείς ακόμα να μιλάς.';

  @override
  String get dopoOgniSedutaRispondi =>
      'Μετά από κάθε προπόνηση απάντησε στο «Πώς πήγε;»: έτσι το πρόγραμμα καταλαβαίνει την κόπωσή σου και προσαρμόζεται.';

  @override
  String get nuotoSenzaOrologioSegni =>
      'Χωρίς ρολόι, την κολύμβηση την καταγράφεις με το χέρι μετά την πισίνα.';

  @override
  String get energiaSonnoRestanoVuoti =>
      'Ενέργεια και ύπνος μένουν κενά: χρειάζονται δεδομένα από ρολόι.';

  @override
  String get dopoCollegaloProfiloDati =>
      'Σύνδεσέ το αργότερα από Προφίλ → Δεδομένα και συνδέσεις: με το Health Connect, ή με το intervals.icu για Garmin και τα άλλα. Οι δραστηριότητες έρχονται μόνες τους, με παλμούς και ύπνο.';

  @override
  String get haiRulloSmartCollegalo =>
      'Έχεις έξυπνο προπονητήριο; Σύνδεσέ το κατά την προπόνηση: η εφαρμογή του στέλνει τα watt για κάθε βήμα.';

  @override
  String get eccoTuaSettimana => 'Αυτή είναι η εβδομάδα σου';

  @override
  String eccoTuaSettimana2(Object p0) {
    return 'Αυτή είναι η εβδομάδα σου, $p0';
  }

  @override
  String get ogniGiornoNellaPagina =>
      'Κάθε μέρα, στη σελίδα «Σήμερα», θα βρίσκεις τι να κάνεις. Μπορείς να αλλάξεις μέρες και χρόνους όποτε θέλεις.';

  @override
  String minuti(Object p0, Object p1) {
    return '$p0 · $p1 λεπτά';
  }

  @override
  String get cosHaiFatto => 'Τι έκανες;';

  @override
  String get poiScriviDurataTutto => 'Μετά γράψε τη διάρκεια και ό,τι θυμάσαι.';

  @override
  String get ciao => 'Γεια!';

  @override
  String ciao2(Object p0) {
    return 'Γεια σου $p0';
  }

  @override
  String get chiudiMese => 'Κλείσιμο μήνα';

  @override
  String get vediTuttoMese => 'Δες όλο τον μήνα';

  @override
  String get prossimi => 'Επόμενες';

  @override
  String get tuoPiano => 'Το πρόγραμμά σου';

  @override
  String get cambiaAllenamentiOggi => 'Άλλαξε τις σημερινές προπονήσεις';

  @override
  String cambiaAllenamenti(Object p0) {
    return 'Άλλαξε τις προπονήσεις της $p0';
  }

  @override
  String get spostaAggiungiOTogli =>
      'Μετακίνησε, πρόσθεσε ή αφαίρεσε: μόνο για εκείνη τη μέρα';

  @override
  String get scriviAttivitaFattaOggi =>
      'Κατέγραψε μια δραστηριότητα που έκανες σήμερα';

  @override
  String scriviAttivitaFatta(Object p0) {
    return 'Κατέγραψε μια δραστηριότητα που έκανες $p0';
  }

  @override
  String get quelloNonHaiRegistrato =>
      'Για ό,τι δεν κατέγραψες: διάρκεια, απόσταση, παλμοί…';

  @override
  String get miaSettimanaTipo => 'Η τυπική μου εβδομάδα';

  @override
  String get qualiGiorniTiAlleni => 'Ποιες μέρες προπονείσαι και για πόσο';

  @override
  String get allungaCalendario => 'Επέκταση ημερολογίου';

  @override
  String get ripeteSettimanaTipoNei =>
      'Επαναλαμβάνει την τυπική εβδομάδα τους επόμενους μήνες: αποφασίζει τις μέρες, όχι τις ασκήσεις';

  @override
  String get mesePrima => 'Προηγούμενος μήνας';

  @override
  String get meseDopo => 'Επόμενος μήνας';

  @override
  String get fare => 'να γίνει';

  @override
  String get toccaGiornoVederloTienilo =>
      'Πάτα μια μέρα για να τη δεις, κράτα την πατημένη για να την αλλάξεις.';

  @override
  String get buona => 'Καλή';

  @override
  String get normale => 'Κανονική';

  @override
  String get bassa => 'Χαμηλή';

  @override
  String energia(Object p0) {
    return 'Ενέργεια $p0';
  }

  @override
  String get tuaSettimana => 'Η εβδομάδα σου';

  @override
  String settimanaDal2(Object p0, Object p1) {
    return 'Εβδομάδα από $p0 $p1';
  }

  @override
  String fatti(Object p0) {
    return ' από $p0 έγιναν';
  }

  @override
  String settimanaCompletataAllenamenti(Object p0) {
    return 'Η εβδομάδα ολοκληρώθηκε: $p0 προπονήσεις!';
  }

  @override
  String get tornaOggi => 'Πίσω στο σήμερα';

  @override
  String get oggiSeiPocoRecuperato =>
      'Σήμερα δεν έχεις αποκατασταθεί καλά: αντί για την προγραμματισμένη προπόνηση μπορείς να κάνεις 20 λεπτά κινητικότητας.';

  @override
  String get vediAllenamento => 'Δες την προπόνηση';

  @override
  String get primaGuardaEsercizi => 'Δες πρώτα τις ασκήσεις';

  @override
  String get giornoRiposo => 'Μέρα ξεκούρασης';

  @override
  String get quelGiornoNonRisultano =>
      'Εκείνη τη μέρα δεν υπάρχουν προπονήσεις.';

  @override
  String get riposoFaParteDell =>
      'Η ξεκούραση είναι μέρος της προπόνησης: οι μύες δυναμώνουν όσο αποκαθίστασαι.';

  @override
  String get seTiVa15 => 'Αν έχεις όρεξη: 15 λεπτά κινητικότητας';

  @override
  String get voglioAllenarmiStesso => 'Θέλω να προπονηθώ ούτως ή άλλως';

  @override
  String get nonFatto => 'δεν έγινε';

  @override
  String fatica10(Object p0) {
    return 'Κόπωση $p0/10';
  }

  @override
  String get comAndata => 'Πώς πήγε;';

  @override
  String get rigenerarePiano => 'Νέα δημιουργία προγράμματος;';

  @override
  String sessioniDalPoiVerranno(Object p0) {
    return 'Οι προπονήσεις από $p0 και μετά θα αντικατασταθούν. Οι προηγούμενες μένουν όπως είναι.';
  }

  @override
  String get rigenera => 'Νέα δημιουργία';

  @override
  String get pianoGenerato => 'Το πρόγραμμα δημιουργήθηκε';

  @override
  String get ripeteTuaSettimanaTipo =>
      'Επαναλαμβάνει την τυπική σου εβδομάδα (ποια αθλήματα, ποιες μέρες, πόσα λεπτά) για τους μήνες που διαλέγεις. Οι ασκήσεις κάθε προπόνησης ετοιμάζονται από το Προφίλ, με το «Ετοίμασε τις προπονήσεις».';

  @override
  String durata2(Object p0, Object p1) {
    return 'Διάρκεια: $p0 $p1';
  }

  @override
  String parti(Object p0) {
    return 'Ξεκίνα από $p0';
  }

  @override
  String modifica2(Object p0) {
    return 'Επεξεργασία: $p0';
  }

  @override
  String get cambiaSoloQuestoGiorno =>
      'Αλλάζει μόνο αυτή τη μέρα: οι άλλες εβδομάδες μένουν όπως είναι.';

  @override
  String get nessunaAttivitaProgrammaGiorno =>
      'Καμία προγραμματισμένη δραστηριότητα (μέρα ξεκούρασης).';

  @override
  String min3(Object p0, Object p1) {
    return '$p0, $p1 λεπ.';
  }

  @override
  String get rimuovi => 'Αφαίρεση';

  @override
  String get aggiungiAttivita => 'Προσθήκη δραστηριότητας';

  @override
  String get comAndataVotoAlla =>
      'Πώς πήγε; Αν βαθμολογήσεις την κόπωση, το πρόγραμμα γίνεται πιο ακριβές.';

  @override
  String get calendarioVuotoAllungaloSapere =>
      'Το ημερολόγιο είναι κενό: επέκτεινέ το για να ξέρεις τι να κάνεις κάθε μέρα.';

  @override
  String calendarioFinitoAllungaloProssimi(Object p0) {
    return 'Το ημερολόγιο τελείωσε στις $p0. Επέκτεινέ το για τους επόμενους μήνες.';
  }

  @override
  String traGiorni(Object p0) {
    return 'σε $p0 μέρες';
  }

  @override
  String calendarioFinisceVuoiAllungarlo(Object p0, Object p1) {
    return 'Το ημερολόγιο τελειώνει $p0 ($p1). Θέλεις να το επεκτείνεις;';
  }

  @override
  String get allunga => 'Επέκταση';

  @override
  String get piuTardi => 'Αργότερα';

  @override
  String scheda(Object p0) {
    return 'Το πρόγραμμα του/της $p0';
  }

  @override
  String scheda2(Object p0) {
    return 'Το πρόγραμμα «$p0»';
  }

  @override
  String finitaIntantoSeduteSono(Object p0, Object p1) {
    return '$p0 τελείωσε στις $p1. Στο μεταξύ οι προπονήσεις είναι αυτές που ετοιμάζει η εφαρμογή.';
  }

  @override
  String rinnovaGiorni(Object p0) {
    return 'Ανανέωση για $p0 μέρες';
  }

  @override
  String get cambiala => 'Άλλαξέ το';

  @override
  String get usaQuellaDellApp => 'Χρησιμοποίησε της εφαρμογής';

  @override
  String get cosaVuoiFareAdesso => 'Τι θέλεις να κάνεις τώρα;';

  @override
  String get siAggiungeQuelloC =>
      'Προστίθεται σε ό,τι έχει προγραμματιστεί για σήμερα.';

  @override
  String get iniziaAttivitaLibera => 'Ξεκίνα μια ελεύθερη δραστηριότητα';

  @override
  String get catalogoEsercizi => 'Κατάλογος ασκήσεων';

  @override
  String get toccaEsercizioVedereMuscoli =>
      'Πάτα μια άσκηση για να δεις τους μύες που δουλεύει.';

  @override
  String get cercaNomeOMuscolo => 'Αναζήτηση με όνομα ή μυ';

  @override
  String get tutti => 'Όλα';

  @override
  String get soloMiaAttrezzatura => 'Μόνο με τον εξοπλισμό μου';

  @override
  String get nessunEsercizioQuestiFiltri => 'Καμία άσκηση με αυτά τα φίλτρα.';

  @override
  String serve(Object p0) {
    return 'Χρειάζεται: $p0';
  }

  @override
  String get immaginiIstruzioni => 'Εικόνες και οδηγίες';

  @override
  String principali(Object p0) {
    return 'Κύριοι: $p0';
  }

  @override
  String secondari(Object p0) {
    return 'Δευτερεύοντες: $p0';
  }

  @override
  String get comeSiEsegue => 'Πώς γίνεται';

  @override
  String immaginiFreeExerciseDb(Object p0) {
    return 'Εικόνες από το free-exercise-db ($p0).';
  }

  @override
  String get tueSerie => 'Τα σετ σου';

  @override
  String recordKg(Object p0, Object p1) {
    return 'Ρεκόρ: $p0 kg × $p1';
  }

  @override
  String recordRipetizioni(Object p0) {
    return 'Ρεκόρ: $p0 επαναλήψεις';
  }

  @override
  String get condividi => 'Κοινοποίηση';

  @override
  String get mappaNonProntaRiprova =>
      'Ο χάρτης δεν είναι έτοιμος: δοκίμασε ξανά.';

  @override
  String get immagineNonRiuscitaRiprova => 'Η εικόνα απέτυχε: δοκίμασε ξανά.';

  @override
  String get immagineSiCreaSul =>
      'Η εικόνα δημιουργείται στο κινητό και πηγαίνει μόνο στην εφαρμογή που διαλέγεις (WhatsApp, Instagram…).';

  @override
  String get condividiSessione => 'Κοινοποίηση προπόνησης';

  @override
  String get grafica => 'Σχέδιο';

  @override
  String get tipoMappa => 'Τύπος χάρτη';

  @override
  String get mappaFaVedereDove =>
      'Ο χάρτης δείχνει πού πήγες: πρόσεχε αν ξεκινάς από το σπίτι.';

  @override
  String get scegliAltraFoto => 'Διάλεξε άλλη φωτογραφία';

  @override
  String get spostaIngrandisciFotoDue =>
      'Μετακίνησε και μεγέθυνε τη φωτογραφία με δύο δάχτυλα. Μένει στο κινητό: το μέρος όπου τραβήχτηκε δεν μπαίνει στην εικόνα.';

  @override
  String get mostraPercorso => 'Εμφάνιση διαδρομής';

  @override
  String get faVedereFormaGiro =>
      'Δείχνει το σχήμα της διαδρομής: πρόσεχε αν ξεκινάς από το σπίτι.';

  @override
  String nuovoRecord(Object p0) {
    return 'Νέο ρεκόρ: $p0';
  }

  @override
  String get passoMedio => 'Μέσος ρυθμός';

  @override
  String get kmPiuVeloce => 'Πιο γρήγορο χλμ.';

  @override
  String get mSalita => 'μ. ανάβασης';

  @override
  String get quotaMassima => 'μέγιστο υψόμετρο';

  @override
  String get passoOgni100M => 'ΡΥΘΜΟΣ ΑΝΑ 100 μ.';

  @override
  String get n100PiuVeloce => 'Πιο γρήγορα 100';

  @override
  String get gradoPiuAlto => 'ο πιο ψηλός βαθμός';

  @override
  String gradoPiuAlto2(Object p0) {
    return 'ο πιο ψηλός βαθμός · $p0';
  }

  @override
  String get primaSedutaQuiSi => 'Η πρώτη προπόνηση: από εδώ και πάνω';

  @override
  String gradoPiuAltoDelle(Object p0) {
    return 'Ο πιο ψηλός βαθμός στις τελευταίες $p0 προπονήσεις';
  }

  @override
  String get progetto2 => 'Project';

  @override
  String get condividiSettimana => 'Κοινοποίηση εβδομάδας';

  @override
  String get settimanaPrima => 'Προηγούμενη εβδομάδα';

  @override
  String get questaSettimana => 'Αυτή η εβδομάδα';

  @override
  String get settimanaDopo => 'Επόμενη εβδομάδα';

  @override
  String settimana(Object p0) {
    return 'Εβδομάδα $p0';
  }

  @override
  String get nessunaSessioneQuestaSettimana =>
      'Καμία προπόνηση αυτή την εβδομάδα.';

  @override
  String get eserciziSceltiTeTua =>
      'Ασκήσεις διαλεγμένες για σένα και τον εξοπλισμό σου, με σετ, επαναλήψεις και βάρη. Τελειώνει πάντα με λίγη κινητικότητα.';

  @override
  String get corseFaciliSedutaPiu =>
      'Χαλαρά τρεξίματα, μία πιο δύσκολη προπόνηση (fartlek, tempo, διαλειμματικά) και η μεγάλη απόσταση που μεγαλώνει προς τον αγώνα.';

  @override
  String get tecnicaSerieAlTuo =>
      'Τεχνική και σετ στον ρυθμό σου, εναλλάξ με πιο δύσκολα.';

  @override
  String get usciteFaciliIntervalliUscita =>
      'Χαλαρές διαδρομές, διαλειμματικά και μία μεγάλη διαδρομή.';

  @override
  String get stretchingMovimentiLentiTempo =>
      'Διατάσεις και αργές κινήσεις, με χρόνο: κάθε φορά ένα διαφορετικό μέρος του σώματος. Ιδανικό και για αποκατάσταση.';

  @override
  String seduteRestanoNelCalendario(Object p0) {
    return 'Οι προπονήσεις $p0 μένουν στο ημερολόγιο, αλλά χωρίς έτοιμες ασκήσεις. Όσες έχουν ήδη γίνει δεν αλλάζουν.';
  }

  @override
  String get sedutePreparateTolte => 'Οι έτοιμες προπονήσεις αφαιρέθηκαν.';

  @override
  String pronteSeduteTroviOggi(Object p0, Object p1) {
    return '$p0 προπονήσεις $p1 έτοιμες. Θα τις βρεις στο Σήμερα.';
  }

  @override
  String get forzaComeVuoi => 'Δύναμη: όπως τη θέλεις';

  @override
  String get obiettivo => 'Στόχος';

  @override
  String get livello => 'Επίπεδο';

  @override
  String get nonPreoccupartiSbagliareLivello =>
      'Μην ανησυχείς αν κάνεις λάθος: το επίπεδο προσαρμόζεται στις βαθμολογίες που δίνεις στο τέλος κάθε προπόνησης.';

  @override
  String get attrezzatura => 'Εξοπλισμός';

  @override
  String get soloCorpoLibero => 'Μόνο βάρος σώματος';

  @override
  String comeCrescere(Object p0) {
    return '$p0: πώς να προοδεύσεις';
  }

  @override
  String get sedutaLungaCosaFare =>
      'Μεγάλη προπόνηση, και τι να κάνεις αν είναι εύκολη';

  @override
  String get sedutaLunga => 'Μεγάλη προπόνηση';

  @override
  String get ultimaCorsaOUscita =>
      'Το τελευταίο τρέξιμο ή η τελευταία διαδρομή της εβδομάδας διαρκεί περισσότερο και μεγαλώνει με τον καιρό. Κλειστό: όλες διαρκούν όσο διάλεξες.';

  @override
  String get preparaSedute => 'Ετοίμασε τις προπονήσεις';

  @override
  String get scegliQualiSportVuoi =>
      'Διάλεξε για ποια αθλήματα θέλεις η εφαρμογή να γράφει προπονήσεις βήμα βήμα. Ετοιμάζει μόνο όσα τσεκάρεις.';

  @override
  String get qualiSport => 'Ποια αθλήματα;';

  @override
  String get giaPreparato => 'ήδη έτοιμο';

  @override
  String settimana2(Object p0, Object p1) {
    return '$p0 $p1 την εβδομάδα';
  }

  @override
  String calendario(Object p0, Object p1) {
    return '$p0 $p1 στο ημερολόγιο';
  }

  @override
  String get nessunaSedutaCalendario => 'καμία προπόνηση στο ημερολόγιο';

  @override
  String get cambiaGiorniMinutiSettimana =>
      'Άλλαξε μέρες και λεπτά (τυπική εβδομάδα)';

  @override
  String get tuePreferenze => 'Οι προτιμήσεις σου';

  @override
  String get senzaGaraSeduteCrescono =>
      'Χωρίς αγώνα, οι προπονήσεις μεγαλώνουν σε κύκλους 4 εβδομάδων, με μία πιο ελαφριά. Μπορείς να ορίσεις αγώνα από το Προφίλ, στο Ο στόχος μου.';

  @override
  String seduteCambianoAvvicinarsiGara(Object p0) {
    return '$p0: οι προπονήσεις αλλάζουν καθώς πλησιάζει ο αγώνας.';
  }

  @override
  String nessunGiornoNelCalendario(Object p0) {
    return '$p0: καμία μέρα στο ημερολόγιο';
  }

  @override
  String get nellaSettimanaTipoMa =>
      'Είναι στην τυπική εβδομάδα αλλά όχι ακόμα στο ημερολόγιο. Άνοιξε την τυπική εβδομάδα και πάτα «Φέρε όλη την εβδομάδα στο ημερολόγιο».';

  @override
  String get calendarioVuoto => 'Το ημερολόγιο είναι κενό';

  @override
  String get primaAllungaCalendarioPoi =>
      'Επέκτεινε πρώτα το ημερολόγιο: μετά γεμίζουν οι προπονήσεις.';

  @override
  String seduteSiPreparanoFino(Object p0) {
    return 'Οι προπονήσεις ετοιμάζονται έως $p0· όταν επεκτείνεις το ημερολόγιο προστίθενται μόνες τους.';
  }

  @override
  String get togliSedutePreparate => 'Αφαίρεσε τις έτοιμες προπονήσεις';

  @override
  String get aggiornaSedute => 'Ενημέρωσε τις προπονήσεις';

  @override
  String prepara(Object p0) {
    return 'Ετοίμασε: $p0';
  }

  @override
  String get dataNascita => 'Ημερομηνία γέννησης';

  @override
  String get altezzaCmTra50 => 'Ύψος σε cm, από 50 έως 250';

  @override
  String get pesoKgTra20 => 'Βάρος σε kg, από 20 έως 300';

  @override
  String get datiPersonali => 'Προσωπικά στοιχεία';

  @override
  String get cognome => 'Επώνυμο';

  @override
  String get toccaSceglierla => 'Πάτα για να τη διαλέξεις';

  @override
  String get altezza => 'Ύψος';

  @override
  String get peso => 'Βάρος';

  @override
  String get pesoNuovoSiRegistra =>
      'Ένα νέο βάρος καταγράφεται με τη σημερινή ημερομηνία.';

  @override
  String get ok2 => 'Εντάξει';

  @override
  String mancano(Object p0) {
    return ' Απομένουν $p0.';
  }

  @override
  String get pausa3 => 'Σε παύση.';

  @override
  String get siRiparte => 'Συνεχίζουμε.';

  @override
  String chilometri(Object p0) {
    return ', $p0 χιλιόμετρα';
  }

  @override
  String allenamentoCompletato(Object p0, Object p1) {
    return 'Η προπόνηση ολοκληρώθηκε. $p0$p1.';
  }

  @override
  String get interrompereAllenamento => 'Διακοπή της προπόνησης;';

  @override
  String get puoiTerminarloQuiVedere =>
      'Μπορείς να την τελειώσεις εδώ και να δεις την περίληψη, ή να βγεις χωρίς αποθήκευση.';

  @override
  String get esci => 'Έξοδος';

  @override
  String get terminaQui => 'Τέλος εδώ';

  @override
  String get continua => 'Συνέχεια';

  @override
  String get questoAllenamentoNonHa => 'Αυτή η προπόνηση δεν έχει βήματα.';

  @override
  String get tempoTotale => 'συνολικός χρόνος';

  @override
  String get bipVibrazione => 'Ήχοι και δόνηση';

  @override
  String get cadenza => 'Ρυθμός πεταλιού';

  @override
  String get poi => 'Μετά';

  @override
  String get esercizioPrecedente => 'Προηγούμενη άσκηση';

  @override
  String get iniziaSubito => 'Ξεκίνα τώρα';

  @override
  String get saltaRecupero => 'Παράλειψη διαλείμματος';

  @override
  String get fatto => 'Έγινε';

  @override
  String get n15SecondiPiu => '15 δευτερόλεπτα ακόμα';

  @override
  String get salta => 'Παράλειψη';

  @override
  String get partiQuandoVuoi => 'Ξεκίνα όταν είσαι έτοιμος';

  @override
  String get preparati => 'Ετοιμάσου';

  @override
  String esercizi2(Object p0, Object p1) {
    return '$p0 · $p1 ασκήσεις';
  }

  @override
  String siParte(Object p0) {
    return 'Ξεκινάμε με: $p0';
  }

  @override
  String indoor2(Object p0) {
    return 'Εσωτερικός χώρος ($p0)';
  }

  @override
  String get senzaGpsVelocitaKm =>
      'Χωρίς GPS: ταχύτητα και χιλιόμετρα έρχονται από το προπονητήριο.';

  @override
  String get senzaGpsAllaFine =>
      'Χωρίς GPS: στο τέλος γράψε τα χιλιόμετρα από την οθόνη.';

  @override
  String get seguiPercorso => 'Ακολούθησε μια διαδρομή';

  @override
  String get facoltativoGpxMappaIndicazioni =>
      'Προαιρετικό: ένα GPX με χάρτη και φωνητικές οδηγίες';

  @override
  String get togliPercorso => 'Αφαίρεση διαδρομής';

  @override
  String get rulloSensori => 'Προπονητήριο και αισθητήρες';

  @override
  String get sensoriBici2 => 'Αισθητήρες ποδηλάτου';

  @override
  String get collegatoOraCalibrarlo => 'Συνδεδεμένο · ώρα για βαθμονόμηση';

  @override
  String get toccaCollegare => 'Πάτα για σύνδεση';

  @override
  String get battito => 'Παλμοί';

  @override
  String get allenamentoCompletato2 => 'Η προπόνηση ολοκληρώθηκε!';

  @override
  String movimentoTotale(Object p0, Object p1) {
    return 'Σε κίνηση $p0 · σύνολο $p1';
  }

  @override
  String battitoMedioBpmMassimo(Object p0, Object p1) {
    return 'Μέσοι παλμοί $p0 bpm · μέγιστοι $p1';
  }

  @override
  String potenzaMediaW(Object p0) {
    return 'Μέση ισχύς $p0 W';
  }

  @override
  String cadenzaRpm(Object p0) {
    return 'ρυθμός πεταλιού $p0 rpm';
  }

  @override
  String cadenzaMediaRpm(Object p0) {
    return 'Μέσος ρυθμός πεταλιού $p0 rpm';
  }

  @override
  String circaKcal(Object p0) {
    return 'Περίπου $p0 kcal';
  }

  @override
  String km(Object p0) {
    return 'Χλμ. $p0';
  }

  @override
  String km2(Object p0) {
    return 'Χλμ. από το $p0';
  }

  @override
  String get kmPercorsi => 'Χιλιόμετρα που διανύθηκαν';

  @override
  String get facoltativoSenzaSessioneResta =>
      'Προαιρετικό: χωρίς αυτό, η προπόνηση δεν έχει απόσταση.';

  @override
  String get segnaComeFatto => 'Σημείωσε ως ολοκληρωμένο';

  @override
  String get seOrologioRegistraStesso =>
      'Αν το ρολόι σου καταγράφει την ίδια προπόνηση, κερδίζουν τα δικά του δεδομένα.';

  @override
  String get inserisciDatiMano => 'Βάλε τα δεδομένα με το χέρι';

  @override
  String segnaleGpsBuonoM(Object p0) {
    return 'Καλό σήμα GPS · ±$p0 μ.';
  }

  @override
  String get cercoSegnaleGpsMeglio =>
      'Ψάχνω σήμα GPS… καλύτερα σε ανοιχτό χώρο';

  @override
  String get gpsNonPermessoTocca =>
      'Το GPS δεν επιτρέπεται: πάτα για να το ενεργοποιήσεις';

  @override
  String get posizioneSpentaToccaAccenderla =>
      'Η τοποθεσία είναι κλειστή: πάτα για να την ανοίξεις';

  @override
  String get dati => 'Δεδομένα';

  @override
  String get ultimoKm => 'Τελευταίο χλμ.';

  @override
  String ultimiKm(Object p0) {
    return 'Τελευταία $p0 χλμ.';
  }

  @override
  String get velocitaMedia => 'Μέση ταχύτητα';

  @override
  String potenzaZ(Object p0) {
    return 'Ισχύς · Z$p0';
  }

  @override
  String battitoZ(Object p0) {
    return 'Παλμοί · Z$p0';
  }

  @override
  String get miCollego => 'Συνδέομαι…';

  @override
  String kmUltimi(Object p0, Object p1, Object p2) {
    return 'Χλμ. $p0 · τελευταία $p1 σε $p2';
  }

  @override
  String mancanoSecondi(Object p0) {
    return 'Μένουν $p0 δευτερόλεπτα';
  }

  @override
  String get tempoTrascorso => 'Χρόνος που πέρασε';

  @override
  String get pausa4 => 'σε παύση';

  @override
  String get poiPassaSolo => 'μετά προχωρά μόνο του';

  @override
  String get toccaFattoQuandoHai2 => 'πάτα Έγινε όταν τελειώσεις';

  @override
  String guardaMovimento(Object p0) {
    return 'Δες πώς γίνεται: $p0';
  }

  @override
  String get kg3 => 'Kg';

  @override
  String ultimaVolta(Object p0) {
    return 'Την τελευταία φορά: $p0';
  }

  @override
  String get aveviFattoTutteRipetizioni =>
      'Έκανες όλες τις επαναλήψεις: δοκίμασε πιο βαρύ βάρος.';

  @override
  String meno2(Object p0) {
    return '$p0: λιγότερο';
  }

  @override
  String piu2(Object p0) {
    return '$p0: περισσότερο';
  }

  @override
  String get nessunPeso2 => 'χωρίς βάρος';

  @override
  String get pesiDiversiDallaScheda => 'Βάρη διαφορετικά από το πρόγραμμα';

  @override
  String get scrittiNellaScheda => 'Γράφτηκαν στο πρόγραμμα.';

  @override
  String get aggiornaScheda => 'Ενημέρωσε το πρόγραμμα';

  @override
  String get segnaVieBlocchiGradi => 'Κατέγραψε διαδρομές, boulder και βαθμούς';

  @override
  String get moltoLeggera => 'πολύ ελαφριά';

  @override
  String get moltoDura => 'πολύ δύσκολη';

  @override
  String get alMassimo => 'στο μέγιστο';

  @override
  String get feedbackSalvato2 => 'Η αξιολόγηση αποθηκεύτηκε';

  @override
  String fatica102(Object p0, Object p1) {
    return 'Κόπωση: $p0/10, $p1';
  }

  @override
  String tuoObiettivoFaticaGiusta(Object p0) {
    return 'Για τον στόχο σου η σωστή κόπωση είναι περίπου $p0/10.';
  }

  @override
  String get comeQuesta => 'σαν αυτή';

  @override
  String sedutaFaticaPrevistaCirca(Object p0, Object p1) {
    return 'Για μια προπόνηση $p0 η αναμενόμενη κόπωση είναι περίπου $p1/10.';
  }

  @override
  String get hoCompletatoTutteSerie => 'Ολοκλήρωσα όλα τα σετ';

  @override
  String get hoFattoTuttaSeduta => 'Έκανα όλη την προπόνηση';

  @override
  String passoNellaPartePrincipale(Object p0, Object p1) {
    return 'Ρυθμός στο κύριο μέρος (στόχος $p0:$p1/100 μ.)';
  }

  @override
  String get oppurePassoHaiTenuto => 'Ή ο ρυθμός που κράτησες (π.χ. 2:45)';

  @override
  String get hoSentitoDoloreO => 'Ένιωσα πόνο ή ενόχληση';

  @override
  String get noteFacoltative => 'Σημειώσεις (προαιρετικά)';

  @override
  String grafici(Object p0) {
    return 'Γραφήματα · $p0';
  }

  @override
  String get questaAttivitaNonCi =>
      'Γι\' αυτή τη δραστηριότητα δεν υπάρχουν δεδομένα στον χρόνο: χρειάζονται παλμοί ή ταχύτητα από το ρολόι.';

  @override
  String get altitudine => 'Υψόμετρο';

  @override
  String get minima => 'Ελάχιστο';

  @override
  String get massima => 'Μέγιστο';

  @override
  String get pendenza => 'Κλίση';

  @override
  String get salitaMassima => 'Μέγιστη ανηφόρα';

  @override
  String get discesaMassima => 'Μέγιστη κατηφόρα';

  @override
  String get ftpCorsaStimataEta =>
      'FTP τρεξίματος υπολογισμένο από ηλικία και βάρος: για ακριβές, κάνε το τεστ στο Προφίλ → Οι ζώνες μου.';

  @override
  String get zoneServeTuoPeso =>
      'Για τις ζώνες χρειάζεται το βάρος σου (Προφίλ), ή το FTP τρεξίματος στο Προφίλ → Οι ζώνες μου.';

  @override
  String get passiAlMinuto => 'Βήματα το λεπτό';

  @override
  String get media => 'Μέσος όρος';

  @override
  String get bracciateAlMinuto => 'Χεριές το λεπτό';

  @override
  String get alMinuto => 'το λεπτό';

  @override
  String get tempoNelleZone => 'Χρόνος στις ζώνες';

  @override
  String zoneCalcolateSullaTua(Object p0) {
    return 'Ζώνες υπολογισμένες στους μέγιστους παλμούς σου ($p0 bpm).';
  }

  @override
  String get migliore => 'Καλύτερο';

  @override
  String tuaFtpCorsaW(Object p0) {
    return 'Το FTP τρεξίματός σου: $p0 W';
  }

  @override
  String get n95DeiTuoiMigliori =>
      'Είναι το 95% των καλύτερων 20 λεπτών σου. Ισχύει αν έτρεξες στο μέγιστο σε αυτά τα 20 λεπτά.';

  @override
  String get usalaComeFtpCorsa => 'Χρησιμοποίησέ το ως FTP τρεξίματος';

  @override
  String get normalizzata => 'Κανονικοποιημένη';

  @override
  String get zonePotenzaServeFtp =>
      'Για τις ζώνες ισχύος χρειάζεται το FTP σου: βάλ\' το στο Προφίλ → Ζώνες, ή όρισέ το στο intervals.icu.';

  @override
  String get tempoNelleZonePotenza => 'Χρόνος στις ζώνες ισχύος';

  @override
  String zoneCalcolateSulTuo(Object p0) {
    return 'Ζώνες υπολογισμένες στο FTP σου ($p0 W).';
  }

  @override
  String get intensitaPrevistaTenutaTutta =>
      'Προγραμματισμένη και πραγματική ένταση σε όλη την προπόνηση';

  @override
  String alle(Object p0, Object p1, Object p2, Object p3, Object p4) {
    return '$p0/$p1/$p2 στις $p3:$p4';
  }

  @override
  String get controlloHealthConnect => 'Έλεγχος Health Connect…';

  @override
  String get healthConnectInstallatoMa =>
      'Το Health Connect είναι εγκατεστημένο αλλά χρειάζεται ενημέρωση.';

  @override
  String get healthConnectNonInstallato2 =>
      'Το Health Connect δεν είναι εγκατεστημένο. Χρειάζεται για να διαβάζονται προπονήσεις από Garmin και Freeletics.';

  @override
  String get aggiornaHealthConnect => 'Ενημέρωση Health Connect';

  @override
  String get installaHealthConnect => 'Εγκατάσταση Health Connect';

  @override
  String get nonCollegatoMancaPermesso =>
      'Δεν είναι συνδεδεμένο: λείπει η άδεια για τις προπονήσεις.';

  @override
  String get permessi => 'Άδειες';

  @override
  String get datiPiuVecchi30 => 'Δεδομένα παλαιότερα από 30 μέρες';

  @override
  String get maiSincronizzato => 'Δεν έχει συγχρονιστεί ποτέ.';

  @override
  String ultimaSincronizzazione(Object p0) {
    return 'Τελευταίος συγχρονισμός: $p0';
  }

  @override
  String sessioniHealthConnect(Object p0) {
    return 'Προπονήσεις από Health Connect: $p0';
  }

  @override
  String get fontiTrovate => 'Πηγές που βρέθηκαν';

  @override
  String sessioni(Object p0, Object p1, Object p2) {
    return '$p0: $p1 προπονήσεις  ($p2)';
  }

  @override
  String get tipiAttivitaIgnorati => 'Είδη δραστηριότητας που αγνοήθηκαν';

  @override
  String get sincronizzaOra => 'Συγχρονισμός τώρα';

  @override
  String get rivediPermessi => 'Έλεγχος αδειών';

  @override
  String get salvaModello => 'Αποθήκευσε το πρότυπο';

  @override
  String get modelloSalvatoCompilaloRiga =>
      'Το πρότυπο αποθηκεύτηκε. Συμπλήρωσέ το (μία γραμμή ανά προπόνηση) και εισήγαγέ το εδώ.';

  @override
  String impossibileSalvareModello(Object p0) {
    return 'Δεν αποθηκεύεται το πρότυπο: $p0';
  }

  @override
  String impossibileAprireSelezioneDei(Object p0) {
    return 'Δεν ανοίγει η επιλογή αρχείων: $p0';
  }

  @override
  String fileTroppoGrandeMassimo(Object p0) {
    return '$p0: πολύ μεγάλο αρχείο (έως 20 MB).';
  }

  @override
  String impossibileLeggereFile2(Object p0, Object p1) {
    return '$p0: δεν διαβάζεται το αρχείο ($p1).';
  }

  @override
  String get opzioniAvanzate => 'Προχωρημένες επιλογές';

  @override
  String get importManualeCsvSenza =>
      'Χειροκίνητη εισαγωγή από CSV, χωρίς συγχρονισμό';

  @override
  String get seNonUsiApp =>
      'Αν δεν χρησιμοποιείς εφαρμογές συνδεδεμένες με το Health Connect, μπορείς να βάζεις τις προπονήσεις με το χέρι: κατέβασε το πρότυπο, συμπλήρωσέ το με ένα λογιστικό φύλλο (μία γραμμή ανά προπόνηση) και εισήγαγέ το. Τα δεδομένα μένουν μόνο στο κινητό.';

  @override
  String get colonneDataAaaaMm =>
      'Στήλες: data (ΕΕΕΕ-ΜΜ-ΗΗ), sport (Corsa, Bici, Nuoto, Forza), tipo_sessione, durata_min, distanza_km, fc_media, rpe, fonte, note. Χρειάζονται τουλάχιστον data και sport. Τα ονόματα των στηλών και τα αθλήματα μένουν στα ιταλικά.';

  @override
  String get scaricaModelloCsv => 'Λήψη προτύπου CSV';

  @override
  String get importaCsv => 'Εισαγωγή CSV';

  @override
  String get modificaIntervalli => 'Επεξεργασία διαστημάτων';

  @override
  String get toccaTrattoCambiareNome =>
      'Πάτα ένα τμήμα για να αλλάξεις όνομα, μέτρα ή χρόνο, ή για να το αφαιρέσεις. Κράτα το πατημένο και σύρ\' το για να το μετακινήσεις.';

  @override
  String get senzaNome => 'Χωρίς όνομα';

  @override
  String get aggiungiTratto => 'Προσθήκη τμήματος';

  @override
  String get tornaQuelliDellOrologio => 'Πίσω σε αυτά του ρολογιού';

  @override
  String get scriviTempoEs5 => 'Γράψε τον χρόνο, π.χ. 5:30 ή 45';

  @override
  String get nuovoTratto => 'Νέο τμήμα';

  @override
  String get modificaTratto => 'Επεξεργασία τμήματος';

  @override
  String get esDefaticamento => 'Π.χ. Αποθεραπεία';

  @override
  String get metri => 'Μέτρα';

  @override
  String get togliQuestoTratto => 'Αφαίρεση αυτού του τμήματος';

  @override
  String get scollegareIntervalsIcu => 'Αποσύνδεση από το intervals.icu;';

  @override
  String get attivitaTornanoQuelleHealth =>
      'Οι δραστηριότητες επιστρέφουν σε αυτές του Health Connect, με λιγότερες λεπτομέρειες. Το κλειδί διαγράφεται από το κινητό.';

  @override
  String get attivitaCompleteGarminPolar =>
      'Πλήρεις δραστηριότητες από Garmin, Polar, Suunto, Coros, Wahoo, Zwift: πραγματικό όνομα, προπονητήριο, διαδρομή, υψόμετρο, ισχύς.';

  @override
  String get sincronizzazioneCorso => 'Συγχρονισμός…';

  @override
  String get collegato4 => 'Συνδεδεμένο.';

  @override
  String collegatoUltimaSincronizzazioneAttivita(
    Object p0,
    Object p1,
    Object p2,
    Object p3,
  ) {
    return 'Συνδεδεμένο · τελευταίος συγχρονισμός $p0, $p1:$p2 · $p3 δραστηριότητες';
  }

  @override
  String get mandaPianoSeduteIntervals =>
      'Στείλε πρόγραμμα και προπονήσεις στο intervals.icu';

  @override
  String corsaBiciNuotoDei(Object p0) {
    return 'Τρέξιμο, ποδήλατο και κολύμβηση των επόμενων $p0 ημερών, βήμα βήμα: ενημερώνονται μόνα τους όταν αλλάζει το πρόγραμμα. Οι προπονήσεις που καταγράφεις με την εφαρμογή στέλνονται μόνες τους μόλις τελειώσουν, με τη διαδρομή αν υπάρχει.';
  }

  @override
  String get invioCorso => 'Αποστολή…';

  @override
  String get nonAncoraMandato => 'Δεν έχει σταλεί ακόμα.';

  @override
  String ultimoInvioSeduteCalendario(
    Object p0,
    Object p1,
    Object p2,
    Object p3,
  ) {
    return 'Τελευταία αποστολή $p0, $p1:$p2 · $p3 προπονήσεις στο ημερολόγιο';
  }

  @override
  String get inviaOra => 'Αποστολή τώρα';

  @override
  String get averleSullOrologioGarmin => 'Για να τις έχεις στο ρολόι Garmin';

  @override
  String get suIntervalsIcuImpostazioni =>
      'Στο intervals.icu: Settings → Garmin Connect → ενεργοποίησε το «Upload planned workouts». Οι προπονήσεις μπαίνουν στο ημερολόγιο του Garmin Connect και από εκεί στο ρολόι. Παλμοί: ζώνες του intervals.icu· κολύμβηση: ρυθμός ανά 100 μ.';

  @override
  String get creaAccountGratuitoSu =>
      'Δημιούργησε δωρεάν λογαριασμό στο intervals.icu (από τον browser).';

  @override
  String get liImpostazioniCollegaGarmin =>
      'Εκεί, στα Settings, σύνδεσε το Garmin Connect (ή το ρολόι σου): οι δραστηριότητες έρχονται μόνες τους.';

  @override
  String get sempreImpostazioniFondoDeveloper =>
      'Πάλι στα Settings, στο τέλος, «Developer settings»: δημιούργησε το κλειδί API και αντέγραψέ το.';

  @override
  String get incollalaQuiSottoTocca =>
      'Επικόλλησέ το παρακάτω και πάτα Σύνδεση.';

  @override
  String get chiaveApiIntervalsIcu => 'Κλειδί API του intervals.icu';

  @override
  String get incollaDagliAppunti => 'Επικόλληση από το πρόχειρο';

  @override
  String get chiaveRestaCifrataSul =>
      'Το κλειδί μένει κρυπτογραφημένο στο κινητό. Χρησιμοποιείται για να διαβάζονται οι δραστηριότητές σου και, μόνο αν το ενεργοποιήσεις, για να στέλνεται το πρόγραμμα στο ημερολόγιό σου.';

  @override
  String get collega2 => 'Σύνδεση';

  @override
  String get arrivo => 'Τερματισμός';

  @override
  String get percorsoCompletato => 'Η διαδρομή ολοκληρώθηκε';

  @override
  String get cercoPosizione => 'Ψάχνω την τοποθεσία σου';

  @override
  String get percorsoQuestaParteRaggiungilo =>
      'Η διαδρομή είναι από εδώ: πήγαινε προς αυτήν';

  @override
  String get fuoriPercorsoTornaSulla =>
      'Εκτός διαδρομής: γύρνα πίσω στη γραμμή';

  @override
  String get drittoFinoAllArrivo => 'Ευθεία μέχρι τον τερματισμό';

  @override
  String percorso(Object p0) {
    return 'Διαδρομή σε $p0';
  }

  @override
  String fuoriPercorso(Object p0) {
    return 'Εκτός διαδρομής ($p0)';
  }

  @override
  String arrivoTra(Object p0) {
    return 'Τερματισμός σε $p0';
  }

  @override
  String get percorsoNonConcessoPuoi =>
      'Η διαδρομή δεν επιτρέπεται. Μπορείς πάντα να την επιτρέψεις από το Health Connect.';

  @override
  String get fileTroppoGrandeGpx =>
      'Πολύ μεγάλο αρχείο: ένα GPX προπόνησης είναι το πολύ λίγα MB.';

  @override
  String get giornoDiverso => 'Διαφορετική μέρα';

  @override
  String fileSessioneUsarloStesso(Object p0, Object p1) {
    return 'Το αρχείο είναι της $p0, η προπόνηση της $p1. Να χρησιμοποιηθεί ούτως ή άλλως;';
  }

  @override
  String get usalo => 'Χρησιμοποίησέ το';

  @override
  String percorsoAggiunto(Object p0) {
    return 'Η διαδρομή προστέθηκε: $p0';
  }

  @override
  String get questaSessioneHaPercorso => 'Αυτή η προπόνηση έχει διαδρομή GPS';

  @override
  String get healthConnectChiedeTuo =>
      'Το Health Connect ζητά την άδειά σου για να τη δείξει. Για να μην τη δίνεις κάθε φορά: Health Connect → Avidididadi → Διαδρομές άσκησης → Να επιτρέπεται πάντα.';

  @override
  String get consentiSempre => 'Να επιτρέπεται πάντα';

  @override
  String get aggiungiGpx => 'Προσθήκη GPX';

  @override
  String get appHaRegistratoSessione =>
      'Η εφαρμογή που κατέγραψε την προπόνηση';

  @override
  String get nessunPercorsoGps => 'Χωρίς διαδρομή GPS';

  @override
  String nonHaCondivisoPuoi(Object p0) {
    return 'Το $p0 δεν την κοινοποίησε. Μπορείς να την προσθέσεις εσύ: στο connect.garmin.com άνοιξε τη δραστηριότητα, γρανάζι → Εξαγωγή σε GPX, και μετά φόρτωσε το αρχείο εδώ.';
  }

  @override
  String get ritmo => 'Ρυθμός';

  @override
  String get scriviQuantiMinutiDurata => 'Γράψε πόσα λεπτά κράτησε';

  @override
  String get vasca => 'Στην πισίνα';

  @override
  String get vasche => 'Μήκη';

  @override
  String get lunghezzaVasca => 'Μήκος πισίνας';

  @override
  String get metriTotali => 'Συνολικά μέτρα';

  @override
  String get tempoMedio => 'Μέσος χρόνος';

  @override
  String get es155 => 'π.χ. 1:55';

  @override
  String get stile => 'Στυλ';

  @override
  String get modificaSessione => 'Επεξεργασία προπόνησης';

  @override
  String get eliminaSessione => 'Διαγραφή προπόνησης';

  @override
  String get nomeDellAllenamento => 'Όνομα προπόνησης';

  @override
  String get indoorRulliTacx => 'Εσωτερικός χώρος (προπονητήριο, Tacx)';

  @override
  String get indoorTapisRoulant => 'Εσωτερικός χώρος (διάδρομος)';

  @override
  String get nienteMappaNeGpx => 'Χωρίς χάρτη ή GPX';

  @override
  String inizio(Object p0, Object p1) {
    return 'Έναρξη $p0:$p1';
  }

  @override
  String get vieBlocchiGradi => 'Διαδρομές, boulder και βαθμοί';

  @override
  String get eserciziSerieKg => 'Ασκήσεις, σετ και kg';

  @override
  String get comeAndata => 'Πώς πήγε';

  @override
  String get battitoMassimo => 'Μέγιστοι παλμοί';

  @override
  String get fatica => 'Κόπωση';

  @override
  String get su10 => 'στα 10';

  @override
  String get tuttoQuelloTiRicordi => 'Ό,τι θυμάσαι';

  @override
  String get tornaAiDatiOriginali => 'Πίσω στα αρχικά δεδομένα';

  @override
  String get dataGara => 'Ημερομηνία αγώνα';

  @override
  String get scriviOreMinutiEs => 'Γράψε ώρες:λεπτά, π.χ. 1:45';

  @override
  String get scegliDataGara => 'Διάλεξε την ημερομηνία του αγώνα.';

  @override
  String get tempoObiettivoFacoltativo => 'Χρόνος-στόχος (προαιρετικό)';

  @override
  String get oreMinutiEs1 => 'ώρες:λεπτά, π.χ. 1:45';

  @override
  String traSettimane(Object p0) {
    return 'Σε $p0 εβδομάδες';
  }

  @override
  String faseAttuale(Object p0, Object p1) {
    return 'Τρέχουσα φάση: $p0. $p1';
  }

  @override
  String get fasiAvanzanoSoleVerso =>
      'Οι φάσεις προχωρούν μόνες τους προς τον αγώνα: βάση, ανάπτυξη, κορύφωση και αποφόρτιση.';

  @override
  String get rimuoviObiettivo => 'Αφαίρεση στόχου';

  @override
  String get controllaValoriFcMax =>
      'Έλεγξε τις τιμές: μέγιστοι παλμοί 120-230, παλμοί ηρεμίας 30-100, ρυθμός λ:δδ, FTP 50-600 W.';

  @override
  String get n15MinutiFacili3 =>
      '15 χαλαρά λεπτά και 3 επιταχύνσεις, μετά 20 λεπτά όσο πιο δυνατά αντέχεις, μετά 10 πολύ χαλαρά λεπτά. Περίπου 50 λεπτά.';

  @override
  String get telefonoNonMisuraWatt =>
      'Το κινητό δεν μετράει watt στο τρέξιμο: κατέγραψε το τρέξιμο και με το ρολόι σου. Μετά άνοιξε τα γραφήματα εκείνου του τρεξίματος: εκεί θα βρεις το FTP σου και το κουμπί για να το αποθηκεύσεις.';

  @override
  String testNelCalendarioPrende(Object p0) {
    return 'Το τεστ στο ημερολόγιο: $p0. Παίρνει τη θέση του τρεξίματος εκείνης της μέρας.';
  }

  @override
  String get scegliOggiOGiorno => 'Διάλεξε σήμερα ή κάποια επόμενη μέρα.';

  @override
  String get mettiloNelCalendario => 'Βάλ\' το στο ημερολόγιο';

  @override
  String get zone => 'Ζώνες';

  @override
  String get tueZoneFrequenzaCardiaca => 'Οι ζώνες καρδιακών παλμών σου';

  @override
  String calcolateRiservaCardiacaFc(Object p0, Object p1) {
    return 'Υπολογίζονται με την καρδιακή εφεδρεία (μέγιστοι παλμοί $p0, ηρεμίας $p1).';
  }

  @override
  String calcolateComePercentualeFc(Object p0) {
    return 'Υπολογίζονται ως ποσοστό των μέγιστων παλμών ($p0). Με τους παλμούς ηρεμίας γίνονται πιο ακριβείς.';
  }

  @override
  String get fcMassima => 'Μέγιστοι παλμοί';

  @override
  String vuotoStimaDaiTuoi(Object p0) {
    return 'Κενό = εκτίμηση από τα δεδομένα σου: $p0 bpm (οι πιο ψηλοί του τελευταίου έτους, ή από την ηλικία).';
  }

  @override
  String vuotoQuellaMisurataBpm(Object p0) {
    return 'Κενό = οι μετρημένοι: $p0 bpm.';
  }

  @override
  String get misuralaAppenaSveglioO =>
      'Μέτρησέ τους μόλις ξυπνήσεις, ή άφησέ το κενό.';

  @override
  String get passoCriticoNuoto => 'Κρίσιμος ρυθμός κολύμβησης';

  @override
  String get mSsEs2 => 'λ:δδ, π.χ. 2:05';

  @override
  String get vuotoStimaDalleSessioni =>
      'Κενό = εκτίμηση από τις προπονήσεις στην πισίνα (δεν υπάρχει ακόμα).';

  @override
  String vuotoStimaDalleSessioni2(Object p0) {
    return 'Κενό = εκτίμηση από τις προπονήσεις στην πισίνα: $p0.';
  }

  @override
  String get tueZonePotenzaBici => 'Οι ζώνες ισχύος σου (ποδήλατο)';

  @override
  String get partonoDallFtpPotenza =>
      'Ξεκινούν από το FTP, την ισχύ που αντέχεις για περίπου μία ώρα. Οι προπονήσεις ποδηλάτου σου δίνουν το εύρος watt που πρέπει να κρατήσεις.';

  @override
  String get ftp => 'FTP';

  @override
  String vuotoQuelloIntervalsIcu(Object p0) {
    return 'Κενό = αυτό του intervals.icu: $p0 W.';
  }

  @override
  String get seNonSaiPedala =>
      'Αν δεν το ξέρεις: κάνε πετάλι 20 λεπτά όσο πιο δυνατά μπορείς· το FTP είναι περίπου το 95% της μέσης ισχύος.';

  @override
  String get tueZonePotenzaCorsa => 'Οι ζώνες ισχύος σου (τρέξιμο)';

  @override
  String get ftpBiciNonVale =>
      'Το FTP του ποδηλάτου δεν ισχύει για το τρέξιμο: το τρέξιμο έχει το δικό του. Χρησιμοποιείται στα γραφήματα των τρεξιμάτων που καταγράφονται με ρολόι που μετράει watt.';

  @override
  String get ftpCorsa => 'FTP τρεξίματος';

  @override
  String vuotoStimaEtaPeso(Object p0) {
    return 'Κενό = εκτίμηση από ηλικία και βάρος: $p0 W. Είναι μόνο ένα σημείο εκκίνησης.';
  }

  @override
  String get vuotoStimaEtaPeso2 =>
      'Κενό = εκτίμηση από ηλικία και βάρος: βάλε το βάρος σου στο Προφίλ.';

  @override
  String get faiTestCalcolarla => 'Κάνε το τεστ για να το υπολογίσεις';

  @override
  String get duranteAllenamento => 'Κατά την προπόνηση';

  @override
  String get avvisi => 'Ειδοποιήσεις';

  @override
  String get voce => 'Φωνή';

  @override
  String get diceEsercizioIniziaKm =>
      'Λέει την άσκηση που ξεκινά, τα χιλιόμετρα και αν είσαι εκτός ζώνης ή εκτός ρυθμού. Σωπαίνει στις κλήσεις.';

  @override
  String get bip => 'Ήχος';

  @override
  String negliUltimiSecondiRecuperi(Object p0) {
    return 'Στα τελευταία $p0 δευτερόλεπτα των διαλειμμάτων και των ασκήσεων με χρόνο, και σε κάθε χιλιόμετρο (5 χλμ. στο ποδήλατο). Χρησιμοποιεί την ένταση πολυμέσων.';
  }

  @override
  String get vibrazione => 'Δόνηση';

  @override
  String get insiemeAiBip => 'Μαζί με τους ήχους.';

  @override
  String get pausaAutomatica => 'Αυτόματη παύση';

  @override
  String get corsaBiciCamminataTempo =>
      'Τρέξιμο, ποδήλατο και περπάτημα: ο χρόνος σταματά όταν σταματάς και ξεκινά ξανά μόνος του. Ποτέ στα διαλείμματα.';

  @override
  String get spenta => 'Κλειστή';

  @override
  String get tempoNonSiFerma => 'Ο χρόνος δεν σταματά ποτέ μόνος του.';

  @override
  String get soloQuandoSeiFermo => 'Μόνο όταν είσαι σταματημένος';

  @override
  String get alSemaforoOSosta =>
      'Σε φανάρι ή σε στάση. Αν πηγαίνεις αργά, ακόμα και σε ανηφόρα, ο χρόνος συνεχίζει.';

  @override
  String sottoKmH(Object p0) {
    return 'Κάτω από $p0 χλμ./ώ.';
  }

  @override
  String get comeCerteAppAttento =>
      'Όπως κάποιες εφαρμογές: πρόσεχε, αν πας πιο αργά από αυτό ο χρόνος σταματά.';

  @override
  String get camminataTranquilla45 =>
      'Χαλαρό περπάτημα 4-5 χλμ./ώ., αργό τρέξιμο 8-10, ποδήλατο σε ανηφόρα ακόμα και 6-8.';

  @override
  String get soloMovimento => 'Μόνο σε κίνηση';

  @override
  String get sosteNonContanoAnche =>
      'Οι στάσεις δεν μετράνε, ακόμα και με κλειστή την αυτόματη παύση: είναι ο ρυθμός με τον οποίο κινήθηκες.';

  @override
  String get soste => 'Με τις στάσεις';

  @override
  String get distanzaDivisoTuttoTempo =>
      'Απόσταση διά όλο τον χρόνο, μαζί με τις στάσεις.';

  @override
  String get allaFineRiepilogoMostra =>
      'Στο τέλος η περίληψη δείχνει έτσι κι αλλιώς και τους δύο χρόνους: σε κίνηση και συνολικό.';

  @override
  String get corsaCamminataBiciAll =>
      'Τρέξιμο, περπάτημα και ποδήλατο σε εξωτερικό χώρο: πού να μπει ο χάρτης που ακολουθεί τη θέση σου (και τη διαδρομή, αν ακολουθείς μία).';

  @override
  String get scorriLatoTimerDati =>
      'Σύρε στο πλάι: χρονόμετρο και δεδομένα στη μία, ο μεγάλος χάρτης στην άλλη.';

  @override
  String get mappaPiccolaSempreVista =>
      'Ένας μικρός χάρτης πάντα ορατός, πάνω από το χρονόμετρο.';

  @override
  String get mappaOccupaTuttoTempo =>
      'Ο χάρτης γεμίζει την οθόνη, με χρόνο και δεδομένα από πάνω.';

  @override
  String get fileTroppoGrandeGpx2 =>
      'Πολύ μεγάλο αρχείο: ένα GPX είναι το πολύ λίγα MB.';

  @override
  String aggiunto(Object p0, Object p1) {
    return 'Προστέθηκε: $p0 · $p1';
  }

  @override
  String mSalita2(Object p0) {
    return '$p0 μ. ανάβασης';
  }

  @override
  String get scegliPercorso => 'Διάλεξε τη διαδρομή';

  @override
  String get mieiPercorsi => 'Οι διαδρομές μου';

  @override
  String get nessunPercorso => 'Καμία διαδρομή';

  @override
  String get aggiungiFileGpxGara =>
      'Πρόσθεσε το αρχείο GPX ενός αγώνα, μιας γνωστής διαδρομής ή μιας διαδρομής ενός φίλου. Ενώ τρέχεις, περπατάς ή κάνεις ποδήλατο, η εφαρμογή σου δείχνει πού είσαι στον χάρτη και σου λέει με φωνή πού να στρίψεις.';

  @override
  String get doveTrovoGpx => 'Πού βρίσκω ένα GPX;';

  @override
  String get sitoGaraSpessoC =>
      '• Ιστότοπος του αγώνα: συχνά υπάρχει «Λήψη ίχνους GPX».\n• Strava, Komoot, Garmin Connect: άνοιξε μια διαδρομή ή μια δραστηριότητα → Εξαγωγή GPX.\n• Ένας φίλος: μπορεί να σου στείλει το GPX της δραστηριότητάς του.\nΜετά εδώ: Προσθήκη GPX και διάλεξε το αρχείο.';

  @override
  String get ancheSenzaRete => 'Λειτουργεί και χωρίς σύνδεση';

  @override
  String get vediPercorso => 'Δες τη διαδρομή';

  @override
  String get nomePercorso => 'Όνομα διαδρομής';

  @override
  String get eliminarePercorso => 'Διαγραφή της διαδρομής;';

  @override
  String sparisceDallaRaccoltaDalle(Object p0) {
    return 'Το «$p0» εξαφανίζεται από τη συλλογή και από τις προπονήσεις στις οποίες είχε ανατεθεί. Οι προπονήσεις που έχουν ήδη γίνει μένουν.';
  }

  @override
  String get usaQuestoPercorso => 'Χρησιμοποίησε αυτή τη διαδρομή';

  @override
  String get rinomina => 'Μετονομασία';

  @override
  String get filePercorsoMancante => 'Λείπει το αρχείο της διαδρομής.';

  @override
  String get curve => 'Στροφές';

  @override
  String get altimetria => 'Υψομετρικό προφίλ';

  @override
  String get giroAdAnelloSi =>
      'Κυκλική διαδρομή: εκκίνηση και τερματισμός στο ίδιο σημείο.';

  @override
  String get partenzaAlPallinoVerde =>
      'Εκκίνηση στην πράσινη κουκκίδα, τερματισμός στην άλλη άκρη.';

  @override
  String get seguirloPrimaPartireCorsa =>
      'Για να την ακολουθήσεις: πριν ξεκινήσεις τρέξιμο, περπάτημα ή ποδήλατο πάτα «Ακολούθησε μια διαδρομή», ή ανάθεσέ τη από πριν σε μια προγραμματισμένη προπόνηση.';

  @override
  String mMinM(Object p0, Object p1) {
    return '$p0 μ. · ελάχ. $p1 μ.';
  }

  @override
  String get percorsoSeguire => 'Διαδρομή που θα ακολουθήσεις';

  @override
  String get scegli => 'Επιλογή';

  @override
  String get cambia => 'Αλλαγή';

  @override
  String scaricoMappa(Object p0) {
    return 'Λήψη χάρτη… $p0%';
  }

  @override
  String get puoiUsareAppIntanto =>
      'Μπορείς να χρησιμοποιείς την εφαρμογή στο μεταξύ.';

  @override
  String get mappaScaricata => 'Ο χάρτης κατέβηκε';

  @override
  String get stradePercorsoSiVedono =>
      'Δρόμοι και διαδρομή φαίνονται και χωρίς σύνδεση (όχι ο δορυφόρος).';

  @override
  String get mappaSenzaRete => 'Χάρτης χωρίς σύνδεση';

  @override
  String scaricaZonaAttornoAl(Object p0) {
    return 'Κατέβασε την περιοχή γύρω από τη διαδρομή ($p0), για να τη βλέπεις ακόμα και όπου το κινητό δεν έχει σήμα.';
  }

  @override
  String get scarica => 'Λήψη';

  @override
  String ultimoAggiornamento(Object p0) {
    return 'Τελευταία ενημέρωση: $p0';
  }

  @override
  String get breveTuoiDatiRestano =>
      'Με λίγα λόγια: τα δεδομένα σου μένουν στο κινητό. Η εφαρμογή δεν έχει διακομιστή, λογαριασμό ή διαφημίσεις, και δεν πουλά ούτε μοιράζεται τα δεδομένα σου. Βγαίνουν από το κινητό μόνο στις περιπτώσεις που περιγράφονται παρακάτω, σχεδόν όλες επιλεγμένες από σένα.';

  @override
  String get datiInserisciTu => 'Δεδομένα που βάζεις εσύ';

  @override
  String get nomeDataNascitaSesso =>
      'Όνομα, ημερομηνία γέννησης, φύλο, ύψος, βάρος και μετρήσεις, φωτογραφία προφίλ, στόχος και αγώνας, τυπική εβδομάδα, εξοπλισμός, αξιολογήσεις μετά τις προπονήσεις (κόπωση, ολοκλήρωση, πόνος), επαναλήψεις και kg των σετ δύναμης, διαδρομές αναρρίχησης, boulder, βαθμοί και προπονήσεις, μήκη, χρόνοι και άλλα δεδομένα προπονήσεων γραμμένα με το χέρι, προγράμματα γραμμένα με το χέρι και προπονήσεις που εισάγονται από αρχεία CSV. Χρησιμοποιούνται για να ετοιμαστεί το πρόγραμμα και να φαίνεται η πρόοδος.';

  @override
  String get datiLettiHealthConnect =>
      'Δεδομένα που διαβάζονται από το Health Connect (μόνο ανάγνωση)';

  @override
  String get tuoPermessoAppLegge =>
      'Με την άδειά σου η εφαρμογή διαβάζει από το Health Connect τις προπονήσεις (είδος, τίτλος, έναρξη και λήξη) και, μέσα στον χρόνο κάθε προπόνησης, καρδιακούς παλμούς, απόσταση, θερμίδες, βήματα και ταχύτητα. Διαβάζει επίσης τους παλμούς ηρεμίας, τη μεταβλητότητα καρδιακού ρυθμού (HRV) και τον ύπνο για να εκτιμήσει την αποκατάσταση, και το ιστορικό παλαιότερο από 30 μέρες αν το επιτρέψεις. Είναι τα δεδομένα που γράφουν το Garmin Connect, το Freeletics και οι άλλες εφαρμογές που είναι συνδεδεμένες με το Health Connect. Η εφαρμογή δεν γράφει, δεν αλλάζει και δεν διαγράφει τίποτα στο Health Connect.';

  @override
  String get percorsiGpsDelleSessioni => 'Διαδρομές GPS των προπονήσεων';

  @override
  String get seAppHaRegistrato =>
      'Αν η εφαρμογή που κατέγραψε ένα τρέξιμο ή μια διαδρομή με ποδήλατο αποθήκευσε και τη διαδρομή στο Health Connect, το Avidididadi τη διαβάζει μόνο με την άδειά σου: για τη μεμονωμένη προπόνηση (σε ρωτά το Health Connect) ή για όλες, αν διαλέξεις «Να επιτρέπεται πάντα» στις ρυθμίσεις του Health Connect. Μπορείς επίσης να προσθέσεις μόνος σου μια διαδρομή φορτώνοντας ένα αρχείο GPX (για παράδειγμα εξαγμένο από το Garmin Connect). Ένα αντίγραφο της διαδρομής μένει στην εφαρμογή για να φαίνεται ο χάρτης. Οι διαδρομές για να ακολουθήσεις που προσθέτεις στις «Οι διαδρομές μου» (αρχεία GPX αγώνων, διαδρομών, φίλων) μένουν μόνο στο κινητό και στο αντίγραφο ασφαλείας· δεν πηγαίνουν στον βοηθό.';

  @override
  String get posizioneDuranteAllenamento => 'Τοποθεσία κατά την προπόνηση';

  @override
  String get soloCorsaCamminataBici =>
      'Μόνο για τρέξιμο, περπάτημα και ποδήλατο (και για άλλη δραστηριότητα αν διαλέξεις να καταγράψεις τη διαδρομή), και μόνο όσο είναι ανοιχτή η λειτουργία προπόνησης, η εφαρμογή χρησιμοποιεί την ακριβή τοποθεσία (GPS και την υπηρεσία τοποθεσίας Google Play στο κινητό) για να καταγράψει διαδρομή, απόσταση και ρυθμό. Κατά την καταγραφή δείχνει μόνιμη ειδοποίηση και συνεχίζει ακόμα και με σβηστή οθόνη· όταν κλείνεις την προπόνηση το GPS σβήνει. Η εφαρμογή δεν χρησιμοποιεί την τοποθεσία καμία άλλη στιγμή και δεν τη συλλέγει στο παρασκήνιο. Η διαδρομή αποθηκεύεται μόνο στο κινητό: δεν πηγαίνει στο Health Connect, δεν πηγαίνει στον βοηθό και δεν στέλνεται σε κανέναν, εκτός αν ενεργοποιήσεις την αποστολή στο intervals.icu ή την αποθηκεύσεις σε αρχείο GPX. Όσο προπονείσαι, ένα αντίγραφο της τρέχουσας προπόνησης (μαζί με τη διαδρομή) μένει στο κινητό για να μπορεί να συνεχιστεί αν κλείσει η εφαρμογή· διαγράφεται όταν τελειώσεις.';

  @override
  String get sensoriBluetoothBattitoBici =>
      'Αισθητήρες Bluetooth (παλμοί και ποδήλατο)';

  @override
  String get soloSeScegliTu =>
      'Μόνο αν το διαλέξεις, κατά τη λειτουργία προπόνησης ή από τη σελίδα «Οι αισθητήρες μου» στο Προφίλ, η εφαρμογή συνδέεται μέσω Bluetooth σε ζώνη παλμών, σε ρολόι που μεταδίδει παλμούς ή σε αισθητήρες ποδηλάτου (προπονητήριο, ισχύς, ταχύτητα και ρυθμός πεταλιού), για να τα δείχνει όσο προπονείσαι. Όταν κλείνει εκείνη η σελίδα ή τελειώνει η προπόνηση, αποσυνδέεται. Στο τέλος της προπόνησης αποθηκεύει σε αυτήν τους μέσους και μέγιστους παλμούς, τη μέση ισχύ και τον μέσο ρυθμό πεταλιού και, για τα γραφήματα, μία τιμή ανά δευτερόλεπτο για παλμούς, ισχύ, ρυθμό πεταλιού και ταχύτητα: όλα στο κινητό. Το όνομα και η διεύθυνση Bluetooth των αισθητήρων (και η περίμετρος του τροχού) μένουν στο κινητό για να ξανασυνδεθούν την επόμενη φορά: τα διαγράφεις με το «Διαγραφή». Η άδεια «Συσκευές κοντά» χρησιμοποιείται μόνο για να βρεθεί ο αισθητήρας, όχι για να ξέρει η εφαρμογή πού είσαι.';

  @override
  String get mappe => 'Χάρτες';

  @override
  String get disegnareMappaAppScarica =>
      'Για να σχεδιάσει τον χάρτη η εφαρμογή κατεβάζει τα πλακίδια της περιοχής που φαίνεται: από το OpenFreeMap (tiles.openfreemap.org, δεδομένα © OpenStreetMap) για τους χάρτες Pulse και Δρόμοι, και από την Esri (server.arcgisonline.com) μόνο αν διαλέξεις την προβολή Δορυφόρος. Όπως σε κάθε ιστότοπο, αυτές οι υπηρεσίες λαμβάνουν τη διεύθυνση IP του κινητού και ποια πλακίδια ζητούνται, οπότε μπορούν να καταλάβουν ποια περιοχή κοιτάς. Η διαδρομή, οι χρόνοι και τα άλλα δεδομένα της προπόνησης δεν στέλνονται: η γραμμή σχεδιάζεται στο κινητό. Για τις διαδρομές που ακολουθείς, η εφαρμογή κατεβάζει από πριν τα πλακίδια της λωρίδας γύρω από το ίχνος, για να τα βλέπεις χωρίς σύνδεση: το OpenFreeMap λαμβάνει αυτά τα πλακίδια, άρα και την περιοχή της διαδρομής. Μένουν στη μνήμη της εφαρμογής μέχρι να αφαιρέσεις τον χάρτη ή τη διαδρομή.';

  @override
  String get intervalsIcuFacoltativo => 'intervals.icu (προαιρετικό)';

  @override
  String get seColleghiIntervalsIcu =>
      'Αν συνδέσεις το intervals.icu με το κλειδί API σου, η εφαρμογή κατεβάζει από εκεί τις δραστηριότητες τρεξίματος, ποδηλάτου και κολύμβησης (όνομα, χρόνοι, απόσταση, παλμοί, ταχύτητα, υψόμετρο, ισχύς, διαδρομή GPS) και το FTP ποδηλάτου και τρεξίματος, για τις ζώνες ισχύος. Το intervals.icu τα λαμβάνει από το ρολόι σου (Garmin, Polar, Suunto…) επειδή το συνέδεσες, με τους δικούς του όρους απορρήτου. Το κλειδί μένει κρυπτογραφημένο στο κινητό. Μόνο αν ενεργοποιήσεις το «Στείλε πρόγραμμα και προπονήσεις στο intervals.icu» η εφαρμογή γράφει στο ημερολόγιό σου στο intervals.icu τις προπονήσεις τρεξίματος, ποδηλάτου και κολύμβησης των επόμενων 14 ημερών (ημερομηνία, άθλημα, όνομα, διάρκεια, βήματα με ζώνες παλμών, ισχύος ή ρυθμού): χωρίς όνομα, φωτογραφία, μετρήσεις, αξιολογήσεις ή δύναμη. Αν το απενεργοποιήσεις, αφαιρούνται οι μελλοντικές προπονήσεις που έστειλε η εφαρμογή. Με αυτή την αποστολή ενεργή, κάθε προπόνηση που καταγράφεις με την εφαρμογή (και η δύναμη) πηγαίνει μόνη της στον λογαριασμό σου μόλις τελειώσει· αν είναι κλειστή, μόνο αν πατήσεις «Αποστολή στο intervals.icu» σε εκείνη την προπόνηση. Τι στέλνεται: ώρα, άθλημα, όνομα, διάρκεια, απόσταση, μέσοι και μέγιστοι παλμοί και, αν υπάρχει, η διαδρομή GPS. Με τον ίδιο τρόπο το «Αποθήκευση GPX» δημιουργεί ένα αρχείο με τη διαδρομή όπου διαλέξεις. Οι δραστηριότητες που κατεβαίνουν μένουν στο κινητό και μπαίνουν στο αντίγραφο ασφαλείας· με την αποσύνδεση αφαιρούνται.';

  @override
  String get immaginiDegliEsercizi => 'Εικόνες των ασκήσεων';

  @override
  String get fotoDegliEserciziVengono =>
      'Οι φωτογραφίες των ασκήσεων κατεβαίνουν, όταν χρειάζονται, από τη δημόσια συλλογή free-exercise-db στο GitHub. Το GitHub λαμβάνει τη διεύθυνση IP του κινητού και ποια εικόνα ζητείται, τίποτα άλλο.';

  @override
  String get assistenteFacoltativo2 => 'Βοηθός (προαιρετικό)';

  @override
  String get soloSeAttiviTu =>
      'Μόνο αν τον ενεργοποιήσεις, ο βοηθός στέλνει μια περίληψη των προπονήσεών σου (προπονήσεις των τελευταίων 4 εβδομάδων, αξιολογήσεις, αποκατάσταση, ζώνες παλμών και FTP ποδηλάτου, πρόγραμμα των επόμενων 14 ημερών) στην υπηρεσία που διαλέγεις: Anthropic, OpenAI, Google ή Ollama στον υπολογιστή σου. Όνομα, φωτογραφία και διαδρομές GPS δεν στέλνονται ποτέ· ηλικία, φύλο και βάρος μόνο αν το επιτρέψεις. Πριν τον ενεργοποιήσεις μπορείς να δεις ακριβώς τι στέλνεται. Το κλειδί API μένει κρυπτογραφημένο στο κινητό. Για τις υπηρεσίες στο internet ισχύουν οι δικοί τους όροι απορρήτου και τυχόν κόστη της συνδρομής σου.';

  @override
  String get assistenteNellaTuaApp => 'Βοηθός στην εφαρμογή σου (προαιρετικό)';

  @override
  String get seColleghiAppTuo =>
      'Αν συνδέσεις την εφαρμογή του βοηθού σου (Claude, ChatGPT, Gemini ή άλλες), το Avidididadi ετοιμάζει ένα μήνυμα με την ίδια περίληψη που περιγράφεται παραπάνω και το δίνει σε εκείνη την εφαρμογή μόνο όταν πατάς Κοινοποίηση ή Αντιγραφή. Από εκεί και πέρα τα δεδομένα είναι στη συνομιλία της υπηρεσίας που διάλεξες και ισχύουν οι κανόνες της: με κανονική συνδρομή οι συνομιλίες μπορεί να χρησιμοποιηθούν για την εκπαίδευση του μοντέλου, ανάλογα με τις ρυθμίσεις του λογαριασμού σου. Οι απαντήσεις που κοινοποιείς ή επικολλάς στην εφαρμογή διαβάζονται μόνο αν περιέχουν τον κωδικό της σύνδεσής σου, και οι αλλαγές στο πρόγραμμα εφαρμόζονται μόνο αφού επιβεβαιώσεις. Μέχρι να τη συνδέσεις, το Avidididadi δεν δέχεται κείμενο από άλλες εφαρμογές· όταν την αποσυνδέσεις, ο κωδικός παύει να ισχύει.';

  @override
  String get widgetSullaSchermataHome => 'Widget στην αρχική οθόνη';

  @override
  String get seAggiungiWidgetSeduta =>
      'Αν προσθέσεις το widget, η σημερινή προπόνηση και η εβδομάδα φαίνονται στην αρχική οθόνη, άρα και σε όποιον βλέπει το κινητό ξεκλείδωτο.';

  @override
  String get doveRestanoDati => 'Πού μένουν τα δεδομένα';

  @override
  String get nellaCartellaPrivataDell =>
      'Στον ιδιωτικό φάκελο της εφαρμογής στο κινητό, στον οποίο οι άλλες εφαρμογές δεν έχουν πρόσβαση. Δεν μπαίνουν στο αυτόματο αντίγραφο ασφαλείας του Android στο Google ούτε στη μεταφορά σε νέο κινητό: για να τα μεταφέρεις χρησιμοποίησε το αντίγραφο ασφαλείας της εφαρμογής.';

  @override
  String get fileBackupCreiContiene =>
      'Το αρχείο αντιγράφου ασφαλείας που δημιουργείς περιέχει όλα τα δεδομένα της εφαρμογής, μαζί με τα δεδομένα υγείας, τις φωτογραφίες και τις διαδρομές GPS (όχι το κλειδί API). Το αποθηκεύεις όπου διαλέξεις: κράτα το σε ασφαλές μέρος και μην το μοιράζεσαι. Αν ενεργοποιήσεις το αυτόματο αντίγραφο ασφαλείας, η εφαρμογή γράφει μόνη της το ίδιο αρχείο στον φάκελο που διάλεξες και κρατά τα 5 τελευταία· άλλες εφαρμογές που διαβάζουν εκείνον τον φάκελο μπορούν να το δουν.';

  @override
  String get permessiTelefono => 'Άδειες του κινητού';

  @override
  String get healthConnectLetturaDei =>
      'Health Connect (ανάγνωση των δεδομένων που αναφέρονται παραπάνω), ακριβής τοποθεσία (μόνο κατά το τρέξιμο, το περπάτημα και το ποδήλατο), συσκευές κοντά (μόνο για τον αισθητήρα παλμών), σωματική δραστηριότητα (μόνο για τα βήματα σε τρέξιμο και περπάτημα), internet (χάρτες, εικόνες, βοηθός, ενημερώσεις), εγκατάσταση εφαρμογών (μόνο για τις ενημερώσεις της εφαρμογής, που επιβεβαιώνεις κάθε φορά), ειδοποιήσεις (μόνο αυτή της τρέχουσας προπόνησης, με χρόνο και δεδομένα, ορατή και στην οθόνη κλειδώματος). Μπορείς να αρνηθείς καθεμία από αυτές τις άδειες: η εφαρμογή συνεχίζει να λειτουργεί χωρίς το μέρος που τη χρειάζεται.';

  @override
  String get comeRevocareOCancellare => 'Πώς να ανακαλέσεις ή να διαγράψεις';

  @override
  String get healthConnectImpostazioniHealth =>
      'Health Connect: ρυθμίσεις του Health Connect → Άδειες εφαρμογών → Avidididadi, ή από το Προφίλ με το «Έλεγχος αδειών». Τοποθεσία, συσκευές κοντά και σωματική δραστηριότητα: ρυθμίσεις Android → Εφαρμογές → Avidididadi → Άδειες. Αισθητήρας παλμών: «Διαγραφή» στο φύλλο των παλμών, κατά την προπόνηση. Βοηθός: απενεργοποίησέ τον και διάγραψε το κλειδί στη σελίδα Προπονητής. Για να διαγράψεις τα πάντα: ρυθμίσεις Android → Εφαρμογές → Avidididadi → Αποθηκευτικός χώρος → Διαγραφή δεδομένων, ή απεγκατάστησε την εφαρμογή. Τα δεδομένα στο Health Connect μένουν εκεί, γιατί ανήκουν στις εφαρμογές που τα έγραψαν.';

  @override
  String get modifiche => 'Αλλαγές';

  @override
  String get seQuestaInformativaCambia =>
      'Αν αλλάξει αυτή η πολιτική, η εφαρμογή σου το λέει όταν την ανοίγεις και σου ζητά να την αποδεχτείς ξανά.';

  @override
  String get cosAvidididadi => 'Τι είναι το Avidididadi';

  @override
  String get appPersonalePianificareSeguire =>
      'Μια προσωπική εφαρμογή για να σχεδιάζεις και να ακολουθείς προπονήσεις δύναμης, τρεξίματος, κολύμβησης, ποδηλάτου και κινητικότητας, και να βλέπεις ιστορικό και πρόοδο. Χρησιμοποιώντας την αποδέχεσαι αυτούς τους όρους και την πολιτική απορρήτου.';

  @override
  String get pianiCarichiZoneFrequenza =>
      'Προγράμματα, φορτία, ζώνες παλμών, εκτίμηση αποκατάστασης και οι απαντήσεις του βοηθού είναι αυτόματες εκτιμήσεις μόνο για ενημέρωση. Δεν είναι διάγνωση ή ιατρική συμβουλή και δεν αντικαθιστούν γιατρό, φυσικοθεραπευτή ή προπονητή. Πριν ξεκινήσεις ένα πρόγραμμα προπόνησης, ειδικά αν έχεις προβλήματα υγείας, είσαι έγκυος ή δεν έχεις προπονηθεί εδώ και καιρό, ρώτα έναν γιατρό. Αν νιώσεις πόνο, ζαλάδα, ασυνήθιστη δύσπνοια ή πόνο στο στήθος, σταμάτα και ζήτα βοήθεια.';

  @override
  String get allenatiSicurezza => 'Προπονήσου με ασφάλεια';

  @override
  String get tiAlleniSottoTua =>
      'Προπονείσαι με δική σου ευθύνη: διάλεξε φορτία και ρυθμούς που σου ταιριάζουν, χρησιμοποίησε εξοπλισμό σε καλή κατάσταση και τήρησε τον κώδικα οδικής κυκλοφορίας. Όταν τρέχεις, περπατάς ή κάνεις ποδήλατο μην κοιτάς το κινητό ενώ κινείσαι μέσα στην κίνηση.';

  @override
  String get precisioneDeiDati => 'Ακρίβεια των δεδομένων';

  @override
  String get gpsDistanzeRitmoPassi =>
      'Το GPS, οι αποστάσεις, ο ρυθμός, τα βήματα και τα δεδομένα από το Health Connect μπορεί να έχουν λάθη (για παράδειγμα ανάμεσα σε ψηλά κτίρια ή κάτω από δέντρα). Οι υπολογισμοί και τα γραφήματα εξαρτώνται από αυτά τα δεδομένα και από το πόσο πλήρη είναι.';

  @override
  String get serviziTerzi => 'Υπηρεσίες τρίτων';

  @override
  String get alcuneFunzioniUsanoServizi =>
      'Κάποιες λειτουργίες χρησιμοποιούν υπηρεσίες άλλων: το Health Connect και τις εφαρμογές που γράφουν σε αυτό (π.χ. Garmin Connect), το OpenFreeMap και το OpenStreetMap για τους χάρτες, το GitHub για τις εικόνες των ασκήσεων και τις ενημερώσεις της εφαρμογής και, αν το ενεργοποιήσεις, την υπηρεσία τεχνητής νοημοσύνης που διαλέγεις. Αυτές οι υπηρεσίες έχουν τους δικούς τους όρους και μπορεί να αλλάξουν ή να μην είναι διαθέσιμες. Το κλειδί API και τα κόστη της υπηρεσίας τεχνητής νοημοσύνης είναι δική σου ευθύνη.';

  @override
  String get tuoiDati => 'Τα δεδομένα σου';

  @override
  String get datiRestanoSulTuo =>
      'Τα δεδομένα μένουν στο κινητό σου και είσαι υπεύθυνος γι\' αυτά: κάνε τακτικά αντίγραφα ασφαλείας και κράτα το αρχείο σε ασφαλές μέρος. Αν απεγκαταστήσεις την εφαρμογή χωρίς αντίγραφο ασφαλείας, τα δεδομένα χάνονται.';

  @override
  String get nessunaGaranzia => 'Χωρίς εγγύηση';

  @override
  String get appFornitaCosiCom =>
      'Η εφαρμογή παρέχεται ως έχει, χωρίς εγγύηση ότι θα λειτουργεί συνεχώς ή χωρίς λάθη. Στον βαθμό που επιτρέπει ο νόμος, ο δημιουργός της δεν ευθύνεται για ζημιές από τη χρήση της εφαρμογής, από λανθασμένα δεδομένα ή από απώλεια δεδομένων.';

  @override
  String get questiTerminiPossonoEssere =>
      'Αυτοί οι όροι μπορεί να ενημερωθούν. Αν αλλάξουν, η εφαρμογή σου το λέει όταν την ανοίγεις και σου ζητά να τους αποδεχτείς ξανά πριν συνεχίσεις.';

  @override
  String impossibileCaricareFoto(Object p0) {
    return 'Δεν φορτώνεται η φωτογραφία: $p0';
  }

  @override
  String get scegliDallaGalleria => 'Επιλογή από τη συλλογή';

  @override
  String get scattaFoto => 'Λήψη φωτογραφίας';

  @override
  String get rimuoviFoto => 'Αφαίρεση φωτογραφίας';

  @override
  String get siRegistraDataOggi =>
      'Καταγράφεται με τη σημερινή ημερομηνία. Άφησέ το κενό για διαγραφή.';

  @override
  String anni(Object p0, Object p1) {
    return '$p0 ($p1 ετών)';
  }

  @override
  String get tuoProfilo => 'Το προφίλ σου';

  @override
  String get inserisciTuoiDati => 'Βάλε τα στοιχεία σου';

  @override
  String get modificaTuoiDati => 'Επεξεργασία στοιχείων';

  @override
  String get mioAllenamento => 'Η προπόνησή μου';

  @override
  String get mioObiettivo => 'Ο στόχος μου';

  @override
  String get nessunaGaraTiAlleni =>
      'Χωρίς αγώνα: προπονείσαι για να είσαι σε φόρμα';

  @override
  String get scegliSportAppScrive =>
      'Διάλεξε τα αθλήματα: η εφαρμογή γράφει προπονήσεις βήμα βήμα';

  @override
  String forza(Object p0) {
    return 'Δύναμη: $p0';
  }

  @override
  String get mieSchede => 'Τα προγράμματά μου';

  @override
  String get schedePersonalTrainerO =>
      'Προγράμματα από τον personal trainer ή τον προπονητή σου';

  @override
  String corso(Object p0) {
    return 'Σε εξέλιξη: $p0';
  }

  @override
  String get comeSiFannoImmagini =>
      'Πώς γίνονται, με εικόνες και τους μύες που δουλεύουν';

  @override
  String get mieZone => 'Οι ζώνες μου';

  @override
  String get quantoSpingereBattitiAl =>
      'Πόσο να πιέσεις: παλμοί το λεπτό και watt στο ποδήλατο';

  @override
  String get mioCorpo => 'Το σώμα μου';

  @override
  String get toccaMisuraInserirlaVedrai =>
      'Πάτα μια μέτρηση για να τη βάλεις: θα βλέπεις πώς αλλάζεις με τον καιρό.';

  @override
  String ultimoAggiornamentoToccaMisura(Object p0) {
    return 'Τελευταία ενημέρωση: $p0. Πάτα μια μέτρηση για να την ενημερώσεις.';
  }

  @override
  String get impostazioniAiuto => 'Ρυθμίσεις και βοήθεια';

  @override
  String get temaScuro => 'Σκούρο θέμα';

  @override
  String get fondoGrafiteOppureBianco => 'Φόντο γραφίτη ή λευκό';

  @override
  String get versioneNeon => 'Έκδοση νέον';

  @override
  String get rosaVerdeAcquaAzzurro =>
      'Ροζ, τιρκουάζ και γαλάζιο αντί για κόκκινο';

  @override
  String get mieiSensori => 'Οι αισθητήρες μου';

  @override
  String get fasciaCardioRulloSensori =>
      'Ζώνη παλμών, προπονητήριο και αισθητήρες ποδηλάτου';

  @override
  String get funzioniAvanzate => 'Προχωρημένες λειτουργίες';

  @override
  String get zoneWattSensoriBluetooth =>
      'Ζώνες, watt, αισθητήρες Bluetooth, προπονητήριο και intervals.icu';

  @override
  String get voceBipPausaAutomatica =>
      'Φωνή, ήχοι, αυτόματη παύση και μέσος ρυθμός';

  @override
  String get tuoiAllenamentiCrealiFalli =>
      'Οι προπονήσεις σου: δημιούργησέ τες, κάν\' τες ή πρόσθεσέ τες στο πρόγραμμα';

  @override
  String get gpxSeguireMappaIndicazioni =>
      'GPX για να ακολουθείς με χάρτη και φωνητικές οδηγίες';

  @override
  String get orologioAppBackupDei =>
      'Ρολόι και εφαρμογές, αντίγραφο ασφαλείας δεδομένων';

  @override
  String get giroGuidatoDellApp => 'Ξενάγηση στην εφαρμογή';

  @override
  String get n10FunzioniPrincipaliAlla => 'Οι 10 βασικές λειτουργίες, μία μία';

  @override
  String get zoneCaricoFartlekSpiegati =>
      'Ζώνες, φορτίο, fartlek… με απλά λόγια';

  @override
  String get configurazioneGuidata => 'Καθοδηγούμενη ρύθμιση';

  @override
  String get rifaiPianoRispondendoPoche =>
      'Ξαναφτιάξε το πρόγραμμα απαντώντας σε λίγες ερωτήσεις';

  @override
  String get rifareConfigurazione => 'Νέα ρύθμιση;';

  @override
  String get settimanaTipoPianoOggi =>
      'Η τυπική εβδομάδα και το πρόγραμμα από σήμερα και μετά θα αντικατασταθούν. Οι προπονήσεις που έγιναν και οι μετρήσεις μένουν.';

  @override
  String get inserisciNumeroValido => 'Βάλε έναν έγκυρο αριθμό';

  @override
  String get diagrammaDellAllenamento => 'Διάγραμμα της προπόνησης';

  @override
  String get wattPrevistiTenutiTutta =>
      'Προγραμματισμένα και πραγματικά watt σε όλη την προπόνηση';

  @override
  String get n1Mese => '1 μήνας';

  @override
  String get n3Mesi => '3 μήνες';

  @override
  String get n6Mesi => '6 μήνες';

  @override
  String get n1Anno => '1 έτος';

  @override
  String get quiVedraiComeVanno =>
      'Εδώ θα βλέπεις πώς πάνε οι προπονήσεις σου. Σύνδεσε το ρολόι ή τις εφαρμογές προπόνησης από το Προφίλ (Δεδομένα και συνδέσεις), ή κατέγραψε τις προπονήσεις που έκανες.';

  @override
  String get quantoTiAlleni => 'Πόσο προπονείσαι';

  @override
  String get alMese => 'τον μήνα';

  @override
  String get settimana3 => 'την εβδομάδα';

  @override
  String fatica2(Object p0) {
    return 'Κόπωση $p0';
  }

  @override
  String ore(Object p0) {
    return 'Ώρες $p0';
  }

  @override
  String get durataFaticaContaAnche =>
      'Διάρκεια επί κόπωση: μετράει και πόσο δύσκολο ήταν.';

  @override
  String get nessunAllenamentoQuestoPeriodo =>
      'Καμία προπόνηση σε αυτή την περίοδο.';

  @override
  String get toccaColonnaDettagli => 'Πάτα μια στήλη για λεπτομέρειες.';

  @override
  String get tuoiSport => 'Τα αθλήματά σου';

  @override
  String get toccaUnoSportVedere =>
      'Πάτα ένα άθλημα για να δεις όλες τις λεπτομέρειες.';

  @override
  String get staiRallentando => 'Επιβραδύνεις';

  @override
  String get staiAndandoBene => 'Πας καλά';

  @override
  String get staiAccelerando => 'Επιταχύνεις';

  @override
  String get troppoTroppoFretta => 'Πολλά, πολύ γρήγορα';

  @override
  String get tiAlleniMenoDelle =>
      'Προπονείσαι λιγότερο από τις προηγούμενες εβδομάδες. Είναι εντάξει αν είναι σκόπιμο (ξεκούραση, υποχρεώσεις)· αλλιώς ξαναξεκίνα σιγά σιγά.';

  @override
  String get aumentiPocoAllaVolta =>
      'Αυξάνεις λίγο λίγο, όπως πρέπει: έτσι βελτιώνεσαι χωρίς να τραυματιστείς.';

  @override
  String get staiFacendoParecchioPiu =>
      'Κάνεις αρκετά περισσότερα από ό,τι συνήθως. Άκου πώς νιώθεις και μην προσθέσεις τίποτα άλλο αυτή την εβδομάδα.';

  @override
  String get haiAumentatoMoltoPoco =>
      'Αύξησες πολύ σε λίγο χρόνο: έτσι γίνονται οι τραυματισμοί. Κάνε λίγες πιο ελαφριές μέρες.';

  @override
  String get buono => 'Καλό';

  @override
  String get basso => 'Χαμηλό';

  @override
  String get tiStoConoscendo => 'Σε γνωρίζω ακόμα';

  @override
  String get dopo3SettimaneAllenamenti =>
      'Μετά από 3 εβδομάδες προπονήσεων θα σου πω αν αυξάνεις με τον σωστό τρόπο.';

  @override
  String get comeCalcolo => 'Πώς το υπολογίζω';

  @override
  String rispettoAllaMediaDelle(Object p0) {
    return 'Σε σχέση με τον μέσο όρο των τελευταίων 4 εβδομάδων: $p0 (καλό από 0,8 έως 1,3).';
  }

  @override
  String ultimi7GiorniPunti(Object p0, Object p1) {
    return 'Τελευταίες 7 μέρες: $p0 πόντοι (λεπτά × κόπωση). $p1';
  }

  @override
  String get settScorsa => 'προηγ. εβδ.';

  @override
  String saltati(Object p0) {
    return 'Παραλείφθηκαν: $p0';
  }

  @override
  String get comAndata2 => 'Πώς πήγε';

  @override
  String get tuoiWattTuttaSeduta =>
      'Τα watt σου σε όλη την προπόνηση (μέσος όρος ανά 10 δευτερόλεπτα).';

  @override
  String get barreColorateSonoProgramma =>
      'Οι χρωματιστές μπάρες είναι το πρόγραμμα: τα watt που πρέπει να κρατήσεις τμήμα προς τμήμα. Η γραμμή είναι τα watt που κράτησες (μέσος όρος ανά 10 δευτερόλεπτα)· η διακεκομμένη είναι το FTP σου.';

  @override
  String get barreColorateSonoWatt =>
      'Οι χρωματιστές μπάρες είναι τα μέσα watt κάθε τμήματος. Η γραμμή είναι τα watt που κράτησες (μέσος όρος ανά 10 δευτερόλεπτα)· η διακεκομμένη είναι το FTP σου.';

  @override
  String get barraBloccoLargaQuanto =>
      'Μία μπάρα ανά τμήμα, τόσο φαρδιά όσο κράτησε: ύψος και χρώμα από τα watt που πρέπει να κρατήσεις· η παύλα είναι τα μέσα watt που κράτησες. Η γραμμή είναι το FTP σου.';

  @override
  String get barraBloccoLargaQuanto2 =>
      'Μία μπάρα ανά τμήμα: τόσο φαρδιά όσο κράτησε, ύψος και χρώμα από τα μέσα watt. Η γραμμή είναι το FTP σου.';

  @override
  String get allenamentoNuovo => 'Νέα προπόνηση';

  @override
  String allenamentiNuovi(Object p0) {
    return '$p0 νέες προπονήσεις';
  }

  @override
  String min4(Object p0) {
    return ' · $p0 λεπ.';
  }

  @override
  String prendePostoSedutaQuel(Object p0) {
    return 'Παίρνει τη θέση της προπόνησης $p0 εκείνης της μέρας.';
  }

  @override
  String get unoGiornoPassatoNon =>
      'Μία είναι σε μέρα που πέρασε: δεν προστίθεται.';

  @override
  String sonoGiorniPassatiNon(Object p0) {
    return '$p0 είναι σε μέρες που πέρασαν: δεν προστίθενται.';
  }

  @override
  String get messoNelCalendario => 'Μπήκε στο ημερολόγιο.';

  @override
  String get nienteMettereDateSono =>
      'Τίποτα για προσθήκη: οι ημερομηνίες πέρασαν.';

  @override
  String get allenamentoMessoNelCalendario =>
      'Η προπόνηση μπήκε στο ημερολόγιο.';

  @override
  String allenamentiMessiNelCalendario(Object p0) {
    return '$p0 προπονήσεις μπήκαν στο ημερολόγιο.';
  }

  @override
  String pianoNuovo(Object p0) {
    return 'Νέο πρόγραμμα από $p0';
  }

  @override
  String get applicatoTroviNelCalendario =>
      'Εφαρμόστηκε: θα το βρεις στο ημερολόγιο.';

  @override
  String seduteSettimaneSostituisceCalendario(Object p0, Object p1) {
    return '$p0 προπονήσεις σε $p1 εβδομάδες. Αντικαθιστά το ημερολόγιο από εκείνη τη μέρα και μετά.';
  }

  @override
  String settimana5(Object p0, Object p1, Object p2) {
    return 'Εβδομάδα $p0/$p1: $p2';
  }

  @override
  String get altreSettimane => '…και οι άλλες εβδομάδες.';

  @override
  String get nonApplicabile => 'Δεν μπορεί να εφαρμοστεί';

  @override
  String get scriviAlCoachCorreggerlo =>
      'Ζήτα από τον προπονητή να το διορθώσει.';

  @override
  String copiatoIncollaloCorreggere(Object p0) {
    return 'Αντιγράφηκε: επικόλλησέ το στο $p0 για να το διορθώσει.';
  }

  @override
  String copiaProblemi(Object p0) {
    return 'Αντιγραφή των προβλημάτων για το $p0';
  }

  @override
  String get pianoNonPiuApplicabile =>
      'Το πρόγραμμα δεν μπορεί πια να εφαρμοστεί: δοκίμασε ξανά.';

  @override
  String pianoApplicatoSeduteNel(Object p0) {
    return 'Το πρόγραμμα εφαρμόστηκε: $p0 προπονήσεις στο ημερολόγιο.';
  }

  @override
  String get applicaPiano => 'Εφαρμογή προγράμματος';

  @override
  String get allenamentoArrampicata => 'Προπόνηση αναρρίχησης';

  @override
  String allenamentiArrampicata2(Object p0) {
    return '$p0 προπονήσεις αναρρίχησης';
  }

  @override
  String get nellaRaccolta => 'στη συλλογή';

  @override
  String nelCalendario2(Object p0) {
    return 'στο ημερολόγιο $p0';
  }

  @override
  String get datePassateNonVanno =>
      'Οι ημερομηνίες που πέρασαν δεν μπαίνουν στο ημερολόγιο, αλλά η προπόνηση αποθηκεύεται έτσι κι αλλιώς.';

  @override
  String get salvato => 'Αποθηκεύτηκε.';

  @override
  String get salvatoNegliAllenamentiArrampicata =>
      'Αποθηκεύτηκε στις προπονήσεις αναρρίχησης.';

  @override
  String salvatiNegliAllenamentiArrampicata(Object p0) {
    return '$p0 αποθηκεύτηκαν στις προπονήσεις αναρρίχησης.';
  }

  @override
  String get unoNelCalendario => 'Μία είναι στο ημερολόγιο.';

  @override
  String sonoNelCalendario(Object p0) {
    return '$p0 είναι στο ημερολόγιο.';
  }

  @override
  String get salvaMettiNelCalendario =>
      'Αποθήκευση και προσθήκη στο ημερολόγιο';

  @override
  String get eserciziSerieRipetizioniKg => 'Ασκήσεις, σετ, επαναλήψεις και kg';

  @override
  String get passiTempoODistanza =>
      'Βήματα με χρόνο ή απόσταση, με ζώνη ή ρυθμό';

  @override
  String get passiTempoODistanza2 => 'Βήματα με χρόνο ή απόσταση, με ζώνη';

  @override
  String get vaschePasso100M => 'Μήκη, ρυθμός ανά 100 μ. και διαλείμματα';

  @override
  String scheda3(Object p0) {
    return 'Πρόγραμμα $p0';
  }

  @override
  String get scriviSchedaTuoPersonal =>
      'Γράψε το πρόγραμμα του personal trainer ή του προπονητή σου: δύναμη, τρέξιμο, ποδήλατο ή κολύμβηση. Τις μέρες που διαλέγεις αντικαθιστά τις προπονήσεις που ετοιμάζει η εφαρμογή, η οποία δεν θα το αλλάξει μόνη της.';

  @override
  String get nuovaScheda => 'Νέο πρόγραμμα';

  @override
  String get corso2 => 'Σε εξέλιξη';

  @override
  String get finite => 'Ολοκληρωμένα';

  @override
  String get archiviata => 'Αρχειοθετημένο';

  @override
  String dalSenzaScadenza(Object p0) {
    return 'Από $p0, χωρίς λήξη';
  }

  @override
  String dalAl(Object p0, Object p1) {
    return 'Από $p0 έως $p1';
  }

  @override
  String get giorno2 => 'Μέρα';

  @override
  String get aggiungiAlmenoEsercizio => 'Πρόσθεσε τουλάχιστον μία άσκηση.';

  @override
  String get aggiungiAlmenoPasso => 'Πρόσθεσε τουλάχιστον ένα βήμα.';

  @override
  String get settimanaTipoAggiornata => 'Η τυπική εβδομάδα ενημερώθηκε.';

  @override
  String nellaSettimanaTipo(Object p0) {
    return '$p0 στην τυπική εβδομάδα';
  }

  @override
  String aggiungo(Object p0) {
    return 'Προσθέτω: $p0.';
  }

  @override
  String giornoRiposoNonTolgo(Object p0) {
    return 'Η $p0 είναι μέρα ξεκούρασης: δεν αφαιρώ τίποτα.';
  }

  @override
  String get fargliPostoTolgoQuesto =>
      'Για να κάνω χώρο αφαιρώ από αυτή τη μέρα:';

  @override
  String get oppurePuoiTenerleFare =>
      'Ή μπορείς να τις κρατήσεις και να κάνεις και τα δύο.';

  @override
  String get tieniEntrambe => 'Κράτα και τα δύο';

  @override
  String get aggiungi => 'Προσθήκη';

  @override
  String get sostituisci => 'Αντικατάσταση';

  @override
  String get eliminareScheda => 'Διαγραφή του προγράμματος;';

  @override
  String get seduteGiaFatteRestano =>
      'Οι προπονήσεις που έγιναν μένουν. Από σήμερα επιστρέφουν αυτές που ετοιμάζει η εφαρμογή.';

  @override
  String get uscireSenzaSalvare => 'Έξοδος χωρίς αποθήκευση;';

  @override
  String get resta => 'Μείνε';

  @override
  String get scheda4 => 'Πρόγραμμα';

  @override
  String get nomeScheda => 'Όνομα προγράμματος';

  @override
  String get esSchedaNovembre => 'Π.χ. Πρόγραμμα Νοεμβρίου';

  @override
  String get fincheNonCambio => 'Μέχρι να το αλλάξω';

  @override
  String get inizio2 => 'Έναρξη';

  @override
  String get giorni => 'Μέρες';

  @override
  String get ogniGiornoSchedaBusto =>
      'Κάθε μέρα του προγράμματος (Πάνω μέρος, Πόδια…) μπαίνει στις μέρες της εβδομάδας που διαλέγεις. Μετράνε αυτές με δύναμη στην τυπική εβδομάδα.';

  @override
  String ogniSedutaSchedaRipetute(Object p0) {
    return 'Κάθε προπόνηση του προγράμματος (Διαλειμματικά, Μεγάλη απόσταση…) μπαίνει στις μέρες της εβδομάδας που διαλέγεις. Μετράνε αυτές με $p0 στην τυπική εβδομάδα.';
  }

  @override
  String nellaSettimanaTipoNon(Object p0, Object p1) {
    return '$p0: δεν υπάρχει $p1 στην τυπική εβδομάδα.';
  }

  @override
  String get modificaSettimana => 'Επεξεργασία εβδομάδας';

  @override
  String get aggiungiGiorno => 'Προσθήκη μέρας';

  @override
  String get aggiungiSeduta => 'Προσθήκη προπόνησης';

  @override
  String get salvaScheda => 'Αποθήκευση προγράμματος';

  @override
  String get nomeGiorno => 'Όνομα μέρας';

  @override
  String get esBusto => 'Π.χ. Πάνω μέρος';

  @override
  String get togliQuestoGiorno => 'Αφαίρεση αυτής της μέρας';

  @override
  String get nessunEsercizio => 'Καμία άσκηση.';

  @override
  String get nessunPasso => 'Κανένα βήμα.';

  @override
  String get spostaGiu => 'Μετακίνηση κάτω';

  @override
  String get aggiungiEsercizio2 => 'Προσθήκη άσκησης';

  @override
  String get aggiungiPasso => 'Προσθήκη βήματος';

  @override
  String get serieMeno => 'Ένα σετ λιγότερο';

  @override
  String get seriePiu => 'Ένα σετ περισσότερο';

  @override
  String get es10810 => 'Π.χ. 10, 8-10, ή 30 s για ασκήσεις με χρόνο';

  @override
  String get recuperoSecondi => 'Διάλειμμα (δευτερόλεπτα)';

  @override
  String get pesoTutteSerie20 =>
      'Ένα βάρος για όλα τα σετ (20), ή ένα για κάθε σετ (20 22.5 25). Κενό για βάρος σώματος.';

  @override
  String get notePersonalTrainer => 'Σημειώσεις του personal trainer';

  @override
  String get esScendi3Secondi => 'Π.χ. κατέβα σε 3 δευτερόλεπτα';

  @override
  String get esercizioNonCatalogo => 'Άσκηση εκτός καταλόγου';

  @override
  String get scegliEsercizio => 'Διάλεξε μια άσκηση';

  @override
  String get cercaEsLatPanca => 'Αναζήτηση (π.χ. τροχαλία, πάγκος, squat)';

  @override
  String get nonCScriviloMano => 'Δεν υπάρχει; Γράψ\' το με το χέρι';

  @override
  String get principale => 'Κύριο μέρος';

  @override
  String get defaticamento => 'Αποθεραπεία';

  @override
  String passo2(Object p0) {
    return 'Βήμα $p0';
  }

  @override
  String get cosaFare => 'Τι να κάνεις';

  @override
  String get esStileLiberoGambe => 'Π.χ. Ελεύθερο, πόδια με σανίδα';

  @override
  String get esCorsaFacileRipetute =>
      'Π.χ. Χαλαρό τρέξιμο, διαλειμματικά, ανηφόρες';

  @override
  String get quanteVolte => 'Πόσες φορές';

  @override
  String get meno3 => 'Μία λιγότερη';

  @override
  String get piu3 => 'Μία περισσότερη';

  @override
  String get tempo2 => 'Με χρόνο';

  @override
  String get distanza2 => 'Με απόσταση';

  @override
  String get minuti2 => 'Λεπτά';

  @override
  String get es400 => 'Π.χ. 400';

  @override
  String get es10Oppure1 => 'Π.χ. 10, ή 1.5';

  @override
  String get obiettivoPrincipale => 'Κύριος στόχος';

  @override
  String get libera => 'Ελεύθερο';

  @override
  String get watt => 'Watt';

  @override
  String get es150100 => 'Π.χ. 1:50/100 m';

  @override
  String get es500Km => 'Π.χ. 5:00/km';

  @override
  String get es200Oppure190 => 'Π.χ. 200, ή 190-210, ή 88-94%';

  @override
  String get obiettivoSecondarioFacoltativo =>
      'Δευτερεύων στόχος (προαιρετικό)';

  @override
  String get es8590Rpm => 'Π.χ. 85-90 rpm';

  @override
  String get es170180Ppm => 'Π.χ. 170-180 βήματα το λεπτό';

  @override
  String get es40BracciateAl => 'Π.χ. 40 χεριές το λεπτό';

  @override
  String get pausaBordoVascaDopo =>
      'Διάλειμμα στο τοίχωμα της πισίνας μετά από κάθε επανάληψη';

  @override
  String get traRipetizioneAltraVuoto =>
      'Ανάμεσα σε μια επανάληψη και την επόμενη· κενό αν δεν υπάρχει';

  @override
  String get scriviMetri => 'Γράψε τα μέτρα.';

  @override
  String get scriviMinuti => 'Γράψε τα λεπτά.';

  @override
  String get scriviWattEsempio200 =>
      'Γράψε τα watt: για παράδειγμα 200, 190-210 ή 88-94%.';

  @override
  String get sensoreCollegatoHoAcceso =>
      'Ο αισθητήρας συνδέθηκε: ενεργοποίησα τις προχωρημένες λειτουργίες.';

  @override
  String ricordato(Object p0) {
    return 'Αποθηκεύτηκε: $p0';
  }

  @override
  String get collegaQuiSensoriBluetooth =>
      'Σύνδεσε εδώ τους αισθητήρες Bluetooth: τους διαλέγεις μόνο μία φορά, μετά ξανασυνδέονται μόνοι τους σε κάθε προπόνηση.';

  @override
  String get fasciaCardioOOrologio2 =>
      'Ζώνη παλμών ή ρολόι που μεταδίδει τους παλμούς';

  @override
  String get rulloSmartPotenzaVelocita =>
      'Έξυπνο προπονητήριο, ισχύς, ταχύτητα και ρυθμός πεταλιού';

  @override
  String get bluetoothSiUsaSolo =>
      'Το Bluetooth χρησιμοποιείται μόνο όσο είναι ανοιχτή αυτή η σελίδα ή η προπόνηση.';

  @override
  String get togliEsercizio => 'Αφαίρεση άσκησης';

  @override
  String get ripetizioniKg => 'Επαναλήψεις και kg';

  @override
  String get secondi => 'Δευτερόλεπτα';

  @override
  String get togliSerie => 'Αφαίρεση σετ';

  @override
  String get eserciziSerie => 'Ασκήσεις και σετ';

  @override
  String forza2(Object p0) {
    return 'Δύναμη · $p0';
  }

  @override
  String get scriviCosaHaiFatto =>
      'Γράψε τι έκανες: επαναλήψεις και kg για κάθε σετ (κενά kg = βάρος σώματος), ή τον χρόνο για σανίδες και κρατήματα. Μένουν στο ιστορικό της άσκησης.';

  @override
  String get distanzaTotale => 'συνολική απόσταση';

  @override
  String get passoMedioMinKm => 'μέσος ρυθμός (λεπ./χλμ.)';

  @override
  String get corsaPiuLunga => 'πιο μεγάλο τρέξιμο';

  @override
  String get passoMigliore3Km => 'καλύτερος ρυθμός (≥ 3 χλμ.)';

  @override
  String get fcMedia => 'μέσοι παλμοί';

  @override
  String get kmSettimana => 'Χλμ. την εβδομάδα';

  @override
  String get passoUscitaMinKm => 'Ρυθμός ανά τρέξιμο (λεπ./χλμ.)';

  @override
  String get distanzaUscitaKm => 'Απόσταση ανά τρέξιμο (χλμ.)';

  @override
  String get efficienzaAerobicaMetriBattito =>
      'Αερόβια απόδοση (μέτρα ανά παλμό)';

  @override
  String get fcMediaUscitaBpm => 'Μέσοι παλμοί ανά τρέξιμο (bpm)';

  @override
  String get passoMedioMin100 => 'μέσος ρυθμός (λεπ./100 μ.)';

  @override
  String get sessionePiuLunga => 'πιο μεγάλη προπόνηση';

  @override
  String get passoMigliore300M => 'καλύτερος ρυθμός (≥ 300 μ.)';

  @override
  String get metriSettimana => 'Μέτρα την εβδομάδα';

  @override
  String get passoSessioneMin100 => 'Ρυθμός ανά προπόνηση (λεπ./100 μ.)';

  @override
  String get metriSessione => 'Μέτρα ανά προπόνηση';

  @override
  String get fcMediaSessioneBpm => 'Μέσοι παλμοί ανά προπόνηση (bpm)';

  @override
  String get velocitaMediaKmH => 'μέση ταχύτητα (χλμ./ώ.)';

  @override
  String get uscitaPiuLunga => 'πιο μεγάλη διαδρομή';

  @override
  String get velocitaMassimaMedia => 'καλύτερη μέση ταχύτητα';

  @override
  String get velocitaMediaUscitaKm => 'Μέση ταχύτητα ανά διαδρομή (χλμ./ώ.)';

  @override
  String get durataMedia => 'μέση διάρκεια';

  @override
  String get sessioniSettimana => 'προπονήσεις την εβδομάδα';

  @override
  String get sessioniSettimana2 => 'Προπονήσεις την εβδομάδα';

  @override
  String get minutiSettimana => 'Λεπτά την εβδομάδα';

  @override
  String get durataSessioneMin => 'Διάρκεια ανά προπόνηση (λεπ.)';

  @override
  String get vieBlocchiChiusi => 'διαδρομές και boulder που ολοκληρώθηκαν';

  @override
  String get metriSaliti => 'μέτρα ανάβασης';

  @override
  String get viaPiuDifficile => 'δυσκολότερη διαδρομή';

  @override
  String get bloccoPiuDifficile => 'δυσκολότερο boulder';

  @override
  String get vieBlocchiChiusiSettimana => 'Διαδρομές και boulder την εβδομάδα';

  @override
  String get gradoPiuDifficileVie => 'Δυσκολότερος βαθμός: διαδρομές';

  @override
  String get gradoPiuDifficileBlocchi => 'Δυσκολότερος βαθμός: boulder';

  @override
  String get tipiSessione => 'Είδη προπόνησης';

  @override
  String fcBpm(Object p0) {
    return 'Παλμοί $p0 bpm';
  }

  @override
  String settimanaDal3(Object p0, Object p1, Object p2, Object p3) {
    return '$p0 $p1\nΕβδομάδα από $p2$p3';
  }

  @override
  String get storicoPesoMisure => 'Ιστορικό βάρους και μετρήσεων';

  @override
  String get storicoMisure => 'Ιστορικό μετρήσεων';

  @override
  String nessunValoreAncoraInserito(Object p0) {
    return 'Δεν έχει μπει ακόμα καμία τιμή για $p0.';
  }

  @override
  String get almenoDueValoriComparira =>
      'Με τουλάχιστον δύο τιμές θα εμφανιστεί το γράφημα.';

  @override
  String dal(Object p0) {
    return 'Από $p0';
  }

  @override
  String invariato(Object p0) {
    return '$p0: χωρίς αλλαγή';
  }

  @override
  String get valoriInseriti => 'Τιμές που μπήκαν';

  @override
  String get barraBasso => 'Η κάτω μπάρα';

  @override
  String get quattroSezioniOggiProgressi =>
      'Τέσσερις ενότητες: Σήμερα, Πρόοδος, Προπονητής και Προφίλ. Μπορείς επίσης να σύρεις στο πλάι για να πας από τη μία στην άλλη.';

  @override
  String get sedutaGiorno => 'Η σημερινή προπόνηση';

  @override
  String get quiTroviCosaFare =>
      'Εδώ βρίσκεις τι να κάνεις σήμερα. Πάτα την προπόνηση για να δεις τις λεπτομέρειες και το ▶ για την καθοδηγούμενη προπόνηση βήμα βήμα, με χρονόμετρο, ήχους και GPS.';

  @override
  String get energia2 => 'Ενέργεια';

  @override
  String get comTuoRecuperoOggi =>
      'Πόσο έχεις αποκατασταθεί σήμερα, από τον ύπνο, τους παλμούς ηρεμίας και το HRV. Πάτα για λεπτομέρειες: αν είναι χαμηλή, καλύτερα μια ελαφριά προπόνηση.';

  @override
  String get compariraAltoDestraQuando =>
      'Θα εμφανιστεί πάνω δεξιά όταν το ρολόι σου στέλνει ύπνο και παλμούς ηρεμίας (Προφίλ → Δεδομένα και συνδέσεις).';

  @override
  String get cerchioGiornoPienoSe =>
      'Ένας κύκλος για κάθε μέρα: γεμάτος αν έγινε, περίγραμμα αν μένει να γίνει. Πάτα μια μέρα για να τη δεις πάνω· σύρε στο πλάι στους κύκλους για την προηγούμενη ή την επόμενη εβδομάδα.';

  @override
  String get settimanaTipo => 'Η τυπική εβδομάδα';

  @override
  String get qualiGiorniTiAlleni2 =>
      'Ποιες μέρες προπονείσαι, ποιο άθλημα και για πόσο. Όλο το ημερολόγιο βγαίνει από εδώ: άλλαξέ τη όταν αλλάζουν οι υποχρεώσεις σου.';

  @override
  String get dopoOgniAllenamentoDai =>
      'Μετά από κάθε προπόνηση βαθμολόγησε την κόπωση: οι επόμενες προπονήσεις προσαρμόζονται, πιο εύκολες ή πιο δύσκολες.';

  @override
  String get quandoAllenamentoFattoNon =>
      'Όταν μια προπόνηση που έκανες δεν έχει ακόμα βαθμολογία, εμφανίζεται εδώ στο Σήμερα το «Πώς πήγε;». Μπορείς επίσης να τη δώσεις πατώντας την προπόνηση που έκανες.';

  @override
  String get caricoAllenamentoGraficiResoconti =>
      'Προπονητικό φορτίο, γραφήματα και αναφορές για κάθε άθλημα: πάτα ένα άθλημα για λεπτομέρειες.';

  @override
  String get assistenteChiedigliConsigliSul =>
      'Ο βοηθός: ζήτα του συμβουλές για το πρόγραμμα ή για το πώς νιώθεις. Τον συνδέεις από τις ρυθμίσεις πάνω (στον υπολογιστή σου ή με την εφαρμογή σου).';

  @override
  String get seduteSchede => 'Προπονήσεις και προγράμματα';

  @override
  String get preparaSeduteAppScrive =>
      '«Ετοίμασε τις προπονήσεις»: η εφαρμογή γράφει τις προπονήσεις για σένα. «Τα προγράμματά μου»: γράψε αυτά του personal trainer ή του προπονητή σου.';

  @override
  String get collegaOrologioHealthConnect =>
      'Σύνδεσε το ρολόι σου (Health Connect ή intervals.icu) και κράτα αντίγραφο ασφαλείας των δεδομένων σου. Την ξενάγηση τη βρίσκεις πάντα εδώ κάτω, στο «Ξενάγηση στην εφαρμογή».';

  @override
  String get toccaAvantiContinuare => 'Πάτα Επόμενο για να συνεχίσεις.';

  @override
  String get fine => 'Τέλος';

  @override
  String get vuoiGiroGuidatoDell =>
      'Θέλεις μια ξενάγηση στην εφαρμογή; Δέκα βήματα, ένα λεπτό.';

  @override
  String get noGrazie => 'Όχι, ευχαριστώ';

  @override
  String get si => 'Ναι';

  @override
  String get ultimoBlocco => 'Τελευταίο τμήμα';

  @override
  String poi2(Object p0) {
    return 'Μετά: $p0';
  }

  @override
  String get recupero2 => 'διαλείμματος';

  @override
  String get fineBlocco => 'στο τέλος του τμήματος';

  @override
  String get collegaRulloOMisuratore =>
      'Σύνδεσε το προπονητήριο ή τον μετρητή ισχύος: θα βλέπεις ισχύ, ρυθμό πεταλιού και ταχύτητα.';

  @override
  String mediaWMassimoW(Object p0, Object p1) {
    return 'Μέση $p0 W · Μέγιστη $p1 W';
  }

  @override
  String blocco(Object p0, Object p1) {
    return 'Τμήμα $p0 από $p1';
  }

  @override
  String get siParte2 => 'Ξεκινάμε';

  @override
  String fineTra(Object p0) {
    return 'Τελειώνει σε $p0';
  }

  @override
  String get rulloErg => 'Προπονητήριο σε ERG';

  @override
  String get rulloLibero => 'Ελεύθερο προπονητήριο';

  @override
  String get senzaObiettivo2 => 'χωρίς στόχο';

  @override
  String tieneW(Object p0) {
    return 'κρατά $p0 W';
  }

  @override
  String get wattLiDecidiTu => 'τα watt τα αποφασίζεις εσύ';

  @override
  String get n5Meno => '5% λιγότερο';

  @override
  String get n5Piu => '5% περισσότερο';

  @override
  String get riportareSettimanaNelCalendario =>
      'Να ξαναμπεί η εβδομάδα στο ημερολόγιο;';

  @override
  String get giorniOggiPoiDiventano =>
      'Οι μέρες από σήμερα και μετά γίνονται ίδιες με την τυπική εβδομάδα: οι αλλαγές που έκανες με το χέρι εκείνες τις μέρες αντικαθίστανται. Οι μέρες που έγιναν μένουν.';

  @override
  String get riporta => 'Επαναφορά';

  @override
  String get settimanaSalvataCalendarioVuoto =>
      'Η εβδομάδα αποθηκεύτηκε. Το ημερολόγιο είναι κενό: επέκτεινέ το από το Σήμερα.';

  @override
  String get settimanaSalvata => 'Η εβδομάδα αποθηκεύτηκε.';

  @override
  String calendarioAggiornatoOggiAl(Object p0, Object p1, Object p2) {
    return 'Το ημερολόγιο ενημερώθηκε: $p0 $p1 από σήμερα έως $p2.';
  }

  @override
  String get settimanaTipo2 => 'Τυπική εβδομάδα';

  @override
  String get scegliCosaFaiQuale =>
      'Διάλεξε τι κάνεις και ποια μέρα. Οι αλλαγές εφαρμόζονται αμέσως στο ημερολόγιο, από σήμερα και μετά· οι μέρες που έγιναν δεν αλλάζουν.';

  @override
  String get portaTuttaSettimanaNel => 'Φέρε όλη την εβδομάδα στο ημερολόγιο';

  @override
  String get rifaGiorniOggiPoi =>
      'Ξαναφτιάχνει τις μέρες από σήμερα και μετά ώστε να ταιριάζουν με την τυπική εβδομάδα. Χρήσιμο αν το ημερολόγιο δεν ταιριάζει πια.';

  @override
  String get aggiungiSessione => 'Προσθήκη προπόνησης';

  @override
  String get nessunaSessione => 'Καμία προπόνηση';

  @override
  String get sport => 'Άθλημα';

  @override
  String get fascia => 'Ώρα της μέρας';

  @override
  String get tipoSessioneFacoltativo => 'Είδος προπόνησης (προαιρετικό)';

  @override
  String get durataMinuti => 'Διάρκεια (λεπτά)';

  @override
  String get haiFattoAllenamentoDiverso =>
      'Έκανες διαφορετική προπόνηση από την προγραμματισμένη: η αξιολόγηση αφορά αυτό που έκανες πραγματικά.';

  @override
  String get tuoFeedbackRegolaProssime =>
      'Η αξιολόγησή σου ρυθμίζει τις επόμενες προπονήσεις.';

  @override
  String get serveCalcolareCaricoAllenamento =>
      'Χρησιμεύει για τον υπολογισμό του προπονητικού φορτίου.';

  @override
  String get completata => 'Ολοκληρώθηκε';

  @override
  String get nonCompletata => 'Δεν ολοκληρώθηκε';

  @override
  String get doloreSegnalato => 'αναφέρθηκε πόνος';

  @override
  String get rispondi => 'Απάντησε';

  @override
  String get hoGiaFattaScrivi => 'Την έχω ήδη κάνει: βάλε τα δεδομένα';

  @override
  String get tiGuidoEsercizioEsercizio =>
      'Σε καθοδηγώ άσκηση προς άσκηση: πάτα «Έγινε» όταν τελειώνεις, μετράω εγώ τα διαλείμματα και τα κομμάτια με χρόνο.';

  @override
  String allenamentoPrevisto(Object p0) {
    return 'Προγραμματισμένη προπόνηση: $p0';
  }

  @override
  String durataTotaleMin(Object p0) {
    return 'Συνολική διάρκεια: $p0 λεπ.';
  }

  @override
  String comeTiDeviSentire(Object p0) {
    return 'Πώς πρέπει να νιώθεις: $p0';
  }

  @override
  String get iniziaAllenamento => 'Έναρξη προπόνησης';

  @override
  String muscoliSessioneToccaEsercizio(Object p0) {
    return 'Μύες της προπόνησης: $p0. Πάτα μια άσκηση για να δεις τους δικούς της, το βελάκι για το πώς γίνεται.';
  }

  @override
  String cos(Object p0) {
    return 'Τι είναι: $p0';
  }

  @override
  String get sedutaArrampicata => 'Προπόνηση αναρρίχησης';

  @override
  String get scegliUnoDeiTuoi =>
      'Διάλεξε μία από τις προπονήσεις σου ή ρώτα τον βοηθό. Μπορείς επίσης να ξεκινήσεις και να καταγράψεις διαδρομές και βαθμούς στο τέλος.';

  @override
  String get iniziaSeduta => 'Ξεκίνα την προπόνηση';

  @override
  String get scegliAllenamento => 'Διάλεξε μια προπόνηση';

  @override
  String get questaSedutaNonHa => 'Αυτή η προπόνηση δεν έχει ακόμα ασκήσεις';

  @override
  String get sedutaLibera => 'Ελεύθερη προπόνηση';

  @override
  String get faiPreparareAllApp =>
      'Άφησε την εφαρμογή να ετοιμάσει τη δύναμη: διαλέγει τις ασκήσεις που ταιριάζουν σε σένα και στον εξοπλισμό σου. Θέλει ένα λεπτό.';

  @override
  String faiPreparareAllApp2(Object p0) {
    return 'Άφησε την εφαρμογή να ετοιμάσει τις προπονήσεις $p0: καθεμία με τις δικές της οδηγίες βήμα βήμα.';
  }

  @override
  String get tempoHai => 'τον χρόνο που έχεις';

  @override
  String muovitiRitmoFacileDevi(Object p0) {
    return 'Κινήσου για $p0 σε χαλαρό ρυθμό: πρέπει να μπορείς να μιλάς.';
  }

  @override
  String preparaSedute2(Object p0) {
    return 'Ετοίμασε τις προπονήσεις $p0';
  }

  @override
  String get invioIntervalsIcu => 'Αποστολή στο intervals.icu…';

  @override
  String get questaSessioneAppNon =>
      'Η εφαρμογή δεν έχει διαδρομή GPS για αυτή την προπόνηση.';

  @override
  String get salvaPercorso => 'Αποθήκευση διαδρομής';

  @override
  String get gpxSalvatoPuoiCaricarlo =>
      'Το GPX αποθηκεύτηκε: μπορείς να το ανεβάσεις στο Strava ή στο Garmin Connect.';

  @override
  String gpxNonSalvato(Object p0) {
    return 'Το GPX δεν αποθηκεύτηκε: $p0';
  }

  @override
  String get eliminareSessione => 'Διαγραφή της προπόνησης;';

  @override
  String get nonTorneraSincronizzazioneNell =>
      ' Δεν θα επιστρέψει με τον συγχρονισμό· στην εφαρμογή του ρολογιού μένει όπως είναι.';

  @override
  String sparisceDalCalendarioDai(Object p0) {
    return 'Εξαφανίζεται από το ημερολόγιο, την Πρόοδο και το φορτίο, μαζί με το «Πώς πήγε;».$p0';
  }

  @override
  String get sessioneEliminata => 'Η προπόνηση διαγράφηκε';

  @override
  String get orario => 'Ώρα';

  @override
  String m(Object p0, Object p1) {
    return '$p0 από $p1 μ.';
  }

  @override
  String get ritmoMedio => 'Μέσος ρυθμός';

  @override
  String get calorieAttiveStima => 'Ενεργές θερμίδες (εκτίμηση)';

  @override
  String get calorieTotaliStima => 'Συνολικές θερμίδες (εκτίμηση)';

  @override
  String get potenzaMedia => 'Μέση ισχύς';

  @override
  String get cadenzaMedia => 'Μέσος ρυθμός πεταλιού';

  @override
  String get faticaRpe => 'Κόπωση (RPE)';

  @override
  String fonteCorrettaMano(Object p0) {
    return 'Πηγή: $p0 · διορθώθηκε με το χέρι';
  }

  @override
  String fonte(Object p0) {
    return 'Πηγή: $p0';
  }

  @override
  String get sulleVie => 'σε διαδρομές';

  @override
  String get nelBoulder => 'στο boulder';

  @override
  String record2(Object p0, Object p1, Object p2, Object p3, Object p4) {
    return 'Ρεκόρ $p0: $p1 ($p2 $p3 $p4)';
  }

  @override
  String get grafici2 => 'Γραφήματα';

  @override
  String get inviaIntervalsIcu => 'Αποστολή στο intervals.icu';

  @override
  String get salvaGpx => 'Αποθήκευση GPX';

  @override
  String get suIntervalsIcu => 'Στο intervals.icu';

  @override
  String get parteSolaIntervalsIcu =>
      'Φεύγει μόνη της για το intervals.icu μόλις υπάρξει σύνδεση';

  @override
  String get previstoFatto => 'Προγραμματισμένο και πραγματικό';

  @override
  String fasceColorateSonoIntensita(Object p0) {
    return 'Οι χρωματιστές ζώνες είναι η ένταση που πρέπει να κρατήσεις τμήμα προς τμήμα, η γραμμή είναι αυτό που κράτησες: μέσα στη ζώνη ήσουν στον στόχο, από πάνω πήγες πιο δυνατά, από κάτω πιο χαλαρά.$p0';
  }

  @override
  String get doveObiettivoEraZona =>
      ' Όπου ο στόχος ήταν ζώνη κοιτάμε τους παλμούς, όπου ήταν ρυθμός κοιτάμε τον ρυθμό.';

  @override
  String get siGuardaPasso => ' Κοιτάμε τον ρυθμό.';

  @override
  String get siGuardaBattito => ' Κοιτάμε τους παλμούς.';

  @override
  String tenere(Object p0) {
    return 'Στόχος $p0';
  }

  @override
  String get fuoriProgramma => 'Εκτός προγράμματος';

  @override
  String get intervalliCorrettiMano => 'Διαστήματα (διορθωμένα με το χέρι)';

  @override
  String get sensoreBici => 'Αισθητήρας ποδηλάτου';

  @override
  String get altitudinePendenza => 'Υψόμετρο και κλίση';

  @override
  String get altitudinePendenzaPotenza => 'Υψόμετρο, κλίση και ισχύς';

  @override
  String nonCiSonoAverle(Object p0) {
    return 'Δεν υπάρχουν $p0: για να τα έχεις σύνδεσε το intervals.icu (Προφίλ → Δεδομένα και συνδέσεις).';
  }

  @override
  String chilometriAllOra(Object p0) {
    return '$p0 χιλιόμετρα την ώρα';
  }

  @override
  String minutiAlChilometro(Object p0) {
    return '$p0 λεπτά ανά χιλιόμετρο';
  }

  @override
  String alChilometro(Object p0, Object p1) {
    return '$p0 και $p1 ανά χιλιόμετρο';
  }

  @override
  String chilometro(Object p0, Object p1) {
    return 'Χιλιόμετρο $p0. $p1.';
  }

  @override
  String chilometroUltimi(Object p0, Object p1, Object p2, Object p3) {
    return 'Χιλιόμετρο $p0. Τα τελευταία $p1 σε $p2, $p3.';
  }

  @override
  String get piu4 => ' συν';

  @override
  String daA(Object p0, Object p1) {
    return 'από $p0 έως $p1';
  }

  @override
  String get su102 => ' στα 10';

  @override
  String get giriAlMinuto => 'στροφές το λεπτό';

  @override
  String get recupero3 => 'Αποκατάσταση.';

  @override
  String recupero4(Object p0) {
    return 'Αποκατάσταση, $p0.';
  }

  @override
  String ora(Object p0) {
    return 'Τώρα: $p0';
  }

  @override
  String zonaRallenta(Object p0) {
    return 'Ζώνη $p0, χαλάρωσε.';
  }

  @override
  String zonaPuoiSpingerePo(Object p0) {
    return 'Ζώνη $p0, μπορείς να πιέσεις λίγο περισσότερο.';
  }

  @override
  String rallentaPo(Object p0, Object p1) {
    return '$p0 $p1, χαλάρωσε λίγο.';
  }

  @override
  String acceleraPo(Object p0, Object p1) {
    return '$p0 $p1, επιτάχυνε λίγο.';
  }

  @override
  String fatto2(Object p0) {
    return 'Έγινε: $p0';
  }

  @override
  String get ancheRiposoAllenamento => 'Και η ξεκούραση είναι προπόνηση';

  @override
  String get alternaRecupero6Volte => 'Εναλλάξ με την αποκατάσταση, 6 φορές';

  @override
  String get recuperoCorricchiando => 'Αποκατάσταση με ελαφρύ τρέξιμο';

  @override
  String get corsaLentaContinua => 'Συνεχές χαλαρό τρέξιμο';

  @override
  String get restaZona2Tutta => 'Μείνε σε ζώνη 2 όλη την ώρα';

  @override
  String get piscinaBase1150M => 'Βασική πισίνα (1150 μ., πισίνα 25 μ.)';

  @override
  String get stileScelta => 'Στυλ της επιλογής σου';

  @override
  String get stileLiberoGambeTavoletta => 'Ελεύθερο, πόδια με σανίδα';

  @override
  String get tavolettaFront => 'Σανίδα μπροστά';

  @override
  String get dorsoGambeTavoletta => 'Ύπτιο, πόδια με σανίδα';

  @override
  String get tavolettaDorso => 'Σανίδα για ύπτιο';

  @override
  String get stileLiberoBracciaPull => 'Ελεύθερο, χέρια με pull buoy';

  @override
  String get n25MSoloBraccio =>
      '25 μ. μόνο δεξί χέρι, 25 μ. μόνο αριστερό χέρι, 50 μ. εναλλάξ';

  @override
  String get dorsoDoppioGambeRana => 'Ύπτιο με δύο χέρια μαζί, πόδια προσθίου';

  @override
  String get parolaTolta => 'αφαιρέθηκε';

  @override
  String get parolaTolte => 'αφαιρέθηκαν';

  @override
  String get parolaSessione => 'προπόνηση';

  @override
  String get parolaSessioni => 'προπονήσεις';

  @override
  String get parolaRulli => 'προπονητήριο';

  @override
  String get parolaTapisRoulant => 'διάδρομος';

  @override
  String get parolaNessuno => 'κανένα';

  @override
  String get parolaGennaio => 'Ιανουαρίου';

  @override
  String get parolaFebbraio => 'Φεβρουαρίου';

  @override
  String get parolaMarzo => 'Μαρτίου';

  @override
  String get parolaAprile => 'Απριλίου';

  @override
  String get parolaMaggio => 'Μαΐου';

  @override
  String get parolaGiugno => 'Ιουνίου';

  @override
  String get parolaLuglio => 'Ιουλίου';

  @override
  String get parolaAgosto => 'Αυγούστου';

  @override
  String get parolaSettembre => 'Σεπτεμβρίου';

  @override
  String get parolaOttobre => 'Οκτωβρίου';

  @override
  String get parolaNovembre => 'Νοεμβρίου';

  @override
  String get parolaDicembre => 'Δεκεμβρίου';

  @override
  String get parolaChilometro => 'χιλιόμετρο';

  @override
  String get parolaChilometri => 'χιλιόμετρα';

  @override
  String get parolaOre => 'ώρες';

  @override
  String get parolaMinuti => 'λεπτά';

  @override
  String get parolaFatto => 'έγινε';

  @override
  String get parolaOggi => 'σήμερα';

  @override
  String get parolaDomani => 'αύριο';

  @override
  String get parolaIeri => 'χθες';

  @override
  String get parolaMese => 'μήνας';

  @override
  String get parolaMesi => 'μήνες';

  @override
  String get parolaSedute => 'προπονήσεις';

  @override
  String get parolaVolta => 'φορά';

  @override
  String get parolaVolte => 'φορές';

  @override
  String get parolaSeduta => 'προπόνηση';

  @override
  String get parolaMancano => 'μένουν';

  @override
  String get parolaLeggera => 'ελαφριά';

  @override
  String get parolaModerata => 'μέτρια';

  @override
  String get parolaImpegnativa => 'δύσκολη';

  @override
  String get parolaAllenamento => 'προπόνηση';

  @override
  String get parolaAllenamenti => 'προπονήσεις';

  @override
  String get parolaPercorsi => 'διανύθηκαν';

  @override
  String get parolaUscite => 'διαδρομές';

  @override
  String get parolaPassati => 'πέρασαν';

  @override
  String get parolaGiorno => 'μέρα';

  @override
  String get parolaGiorni => 'μέρες';

  @override
  String get parolaSecondo => 'δευτερόλεπτο';

  @override
  String get parolaSecondi => 'δευτερόλεπτα';

  @override
  String get parolaMinuto => 'λεπτό';

  @override
  String get parolaOra => 'ώρα';

  @override
  String get parolaMetro => 'μέτρο';

  @override
  String get parolaMetri => 'μέτρα';

  @override
  String get glossarioRecupero => 'Αποκατάσταση';

  @override
  String get glossarioMobilita => 'Κινητικότητα';

  @override
  String get widgetOggi => 'ΣΗΜΕΡΑ';

  @override
  String get widgetApri => 'Άνοιξε την εφαρμογή για να δεις το πρόγραμμα';

  @override
  String get widgetNessuno => 'Καμία προπόνηση αυτή την εβδομάδα';

  @override
  String widgetFatti(Object fatti, Object totale) {
    return '$fatti από $totale έγιναν αυτή την εβδομάδα';
  }

  @override
  String get widgetLettere => 'Δ,Τ,Τ,Π,Π,Σ,Κ';

  @override
  String get notificaCanale => 'Προπόνηση σε εξέλιξη';

  @override
  String get notificaAllenamento => 'Προπόνηση';

  @override
  String get lingua => 'Γλώσσα';

  @override
  String get linguaTitolo => 'Διάλεξε τη γλώσσα σου';

  @override
  String get linguaSpiega =>
      'Μπορείς να την αλλάξεις όποτε θέλεις από το Προφίλ. Τα δεδομένα που έχεις ήδη βάλει μένουν όπως είναι.';

  @override
  String get linguaSotto => 'Ιταλικά, αγγλικά ή ελληνικά';

  @override
  String get sostieniProgetto => 'Στήριξε το έργο';

  @override
  String get sostieniSotto =>
      'Μια δωρεά βοηθά την ανάπτυξη. Δεν ξεκλειδώνει τίποτα: όλη η εφαρμογή είναι δωρεάν.';

  @override
  String get linkNonAperto => 'Δεν μπορώ να ανοίξω τον σύνδεσμο.';

  @override
  String battitiAlMinuto(Object p0) {
    return '$p0 bpm';
  }

  @override
  String giraVerso(Object p0) {
    return 'στρίψε $p0';
  }

  @override
  String mancanoAncora(Object p0) {
    return 'μένουν $p0';
  }

  @override
  String recuperoDi(Object p0) {
    return 'διάλειμμα $p0';
  }

  @override
  String quanteSerie(Object p0) {
    return '$p0 σετ';
  }

  @override
  String quanteRipetizioni(Object p0) {
    return '$p0 επαναλήψεις';
  }

  @override
  String quanteAggiornate(Object p0) {
    return '$p0 ενημερώθηκαν';
  }

  @override
  String quanteRimosse(Object p0) {
    return '$p0 αφαιρέθηκαν';
  }

  @override
  String aggiornato(Object p0) {
    return '$p0 ενημερώθηκε';
  }

  @override
  String quantiChili(Object p0) {
    return '$p0 κιλά';
  }

  @override
  String unoEAltro(Object p0, Object p1) {
    return '$p0 και $p1';
  }

  @override
  String quantiWatt(Object p0) {
    return '$p0 βατ';
  }

  @override
  String quantiMetri(Object p0) {
    return '$p0 μέτρα';
  }

  @override
  String connesso(Object p0) {
    return '$p0 συνδέθηκε';
  }

  @override
  String passoDiTour(Object p0, Object p1) {
    return '$p0 από $p1';
  }

  @override
  String quantiEsercizi(Object p0) {
    return '$p0 ασκήσεις';
  }

  @override
  String backupSessioni(Object p0) {
    return '$p0 προπονήσεις';
  }

  @override
  String backupMisure(Object p0) {
    return '$p0 μετρήσεις';
  }

  @override
  String backupFeedback(Object p0) {
    return '$p0 αξιολογήσεις';
  }

  @override
  String quantiGiorni(Object p0) {
    return '$p0 μέρες';
  }

  @override
  String quanteOre(Object p0) {
    return '$p0 ώρες';
  }

  @override
  String quantiMinuti(Object p0) {
    return '$p0 λεπτά';
  }

  @override
  String quanteSedute(Object p0) {
    return '$p0 προπονήσεις';
  }

  @override
  String quanteProvate(Object p0, Object p1) {
    return '$p0 δοκιμάστηκαν';
  }

  @override
  String quantiPunti(Object p0) {
    return '$p0 πόντοι';
  }

  @override
  String get parolaZona => 'ζώνη';

  @override
  String poiCurva(Object p0) {
    return 'μετά $p0';
  }

  @override
  String get linguaVoce => 'Γλώσσα φωνής';

  @override
  String get linguaVoceComeApp => 'Όπως η εφαρμογή';

  @override
  String get linguaVoceComeTelefono => 'Όπως το κινητό';

  @override
  String get linguaVoceSpiega =>
      'Οδηγίες διαδρομής, χιλιόμετρα, ρυθμός και ζώνες. Σε γλώσσα διαφορετική από της εφαρμογής, τα ονόματα των ασκήσεων μένουν στη γλώσσα της εφαρμογής.';

  @override
  String voceNonInstallata(Object p0) {
    return 'Η φωνή $p0 δεν είναι εγκατεστημένη στο κινητό: εγκατάστησέ τη από τις ρυθμίσεις μετατροπής κειμένου σε ομιλία και δοκίμασε ξανά.';
  }

  @override
  String get installaVoce => 'Εγκατάσταση φωνής';

  @override
  String get provaVoce => 'Δοκιμή φωνής';

  @override
  String get oppure => ' ή ';

  @override
  String get mPerBattito => 'm/παλμό';

  @override
  String get parolaSettimana => 'εβδομάδα';

  @override
  String get parolaRecupero => 'Διάλειμμα';

  @override
  String get assistenteTitolo => 'Βοηθός';

  @override
  String get etichettaRecupero => 'ανάκαμψη';

  @override
  String get passiDuranteAllenamento => 'Βήματα κατά την προπόνηση';

  @override
  String get soloCorsaCamminataPassi =>
      'Μόνο για τρέξιμο και περπάτημα, και μόνο όσο είναι ανοιχτή η λειτουργία προπόνησης, η εφαρμογή διαβάζει τον μετρητή βημάτων του κινητού (άδεια «Σωματική δραστηριότητα») για να σου δείχνει τα βήματα και τα βήματα το λεπτό. Στην προπόνηση αποθηκεύει το σύνολο των βημάτων με το χρονόμετρο σε λειτουργία: μένει στο κινητό και στο αντίγραφο ασφαλείας. Όταν κλείσει η προπόνηση, η εφαρμογή δεν διαβάζει πια τον αισθητήρα. Χωρίς την άδεια η προπόνηση λειτουργεί κανονικά, απλώς χωρίς βήματα.';

  @override
  String quantiPassi(Object p0) {
    return '$p0 βήματα';
  }

  @override
  String get passiDalTelefono => 'Βήματα από το κινητό';

  @override
  String get passiDalTelefonoSpiega =>
      'Στο τρέξιμο και στο περπάτημα η εφαρμογή μετράει τα βήματα με τον αισθητήρα του κινητού (άδεια «Σωματική δραστηριότητα»), ακόμα και χωρίς ρολόι.';

  @override
  String get permessoPassiNegato =>
      'Η άδεια «Σωματική δραστηριότητα» δεν έχει δοθεί: μπορείς να τη δώσεις από τις ρυθμίσεις της εφαρμογής, στις Άδειες.';

  @override
  String get intervalliFatti => 'Διαστήματα';

  @override
  String get tsPedalataFacile => 'Εύκολο πετάλι';

  @override
  String get tsPedalaSciolto =>
      'Κάνε χαλαρό πετάλι. Το κανονικό τεστ ξεκινά μετά.';

  @override
  String tsGradinoRampa(Object p0) {
    return 'Ράμπα: σκαλί $p0';
  }

  @override
  String get tsRampaNota =>
      'Κάθε λεπτό λίγο πιο δύσκολα. Συνέχισε μέχρι να μην μπορείς να κρατήσεις τον ρυθμό πεταλιού· μετά πάτα Επόμενο μέχρι την αποθεραπεία.';

  @override
  String get tsRisultatoNeiGrafici =>
      'Το αποτέλεσμα θα το βρεις στα γραφήματα αυτής της διαδρομής.';

  @override
  String get tsMinutiSvelti => 'Γρήγορα λεπτά';

  @override
  String get tsMinutiSveltiNota =>
      'Γρήγορα αλλά όχι στο μέγιστο: ξυπνούν τα πόδια.';

  @override
  String get tsVentiSenzaFtp =>
      'Η πιο δυνατή προσπάθεια που μπορείς να κρατήσεις ως το τέλος, σταθερά. Ξεκίνα λίγο χαλαρά και τελείωσε δυνατά.';

  @override
  String tsVentiConFtp(Object p0) {
    return 'Ξεκίνα γύρω στα $p0 W και κράτα τα: αν μετά από 10 λεπτά νιώθεις καλά, ανέβασε λίγο. Τελείωσε δυνατά.';
  }

  @override
  String get tsStileSceltaFacile => 'Ελεύθερη επιλογή στυλ, χαλαρά';

  @override
  String get tsStileLiberoProgressione => 'Ελεύθερο με προοδευτική αύξηση';

  @override
  String get tsOgni50Svelto => 'Κάθε 50 μ. λίγο πιο γρήγορα.';

  @override
  String get tsTest400 => 'Τεστ: 400 μ. στο μέγιστο';

  @override
  String get tsTest400Nota =>
      'Όσο πιο γρήγορα μπορείς να κρατήσεις, σταθερά, χωρίς να ξεκινήσεις πολύ δυνατά. Σημείωσε τον χρόνο.';

  @override
  String get tsTest200 => 'Τεστ: 200 μ. στο μέγιστο';

  @override
  String get tsTest200Nota =>
      'Όσο πιο γρήγορα μπορείς να κρατήσεις. Σημείωσε τον χρόνο και μετά γράψε τους δύο χρόνους στο Προφίλ → Οι ζώνες μου.';

  @override
  String get tsMancaFtp =>
      'Δεν ξέρουμε ακόμα το FTP σου: χωρίς αυτό, οι προπονήσεις γίνονται με την αίσθηση.';

  @override
  String get tsMancaPasso =>
      'Δεν ξέρουμε ακόμα τον κρίσιμο ρυθμό σου: χωρίς αυτόν, οι προπονήσεις γίνονται με την αίσθηση.';

  @override
  String get tsVecchioFtp =>
      'Το FTP σου δεν έχει ενημερωθεί πάνω από 8 εβδομάδες: μπορεί να έχεις βελτιωθεί στο μεταξύ.';

  @override
  String get tsVecchioPasso =>
      'Ο κρίσιμος ρυθμός σου δεν έχει ενημερωθεί πάνω από 8 εβδομάδες: μπορεί να έχεις βελτιωθεί στο μεταξύ.';

  @override
  String get tsTroppoFacile =>
      'Τα τελευταία διαλειμματικά σου φάνηκαν εύκολα: ίσως το FTP είναι υψηλότερο.';

  @override
  String get tsTroppoDuro =>
      'Δεν κατάφερες να τελειώσεις τα τελευταία διαλειμματικά: ίσως το FTP είναι πολύ υψηλό.';

  @override
  String get tsTestFtpBici => 'Τεστ FTP ποδηλάτου';

  @override
  String get tsRulloSmart => 'Έξυπνο προπονητήριο';

  @override
  String get tsSuStrada => 'Στον δρόμο';

  @override
  String get tsRampaTesto1 =>
      '10 εύκολα λεπτά και μετά μια ράμπα: κάθε λεπτό το προπονητήριο ζητά λίγα watt παραπάνω, μέχρι να μην μπορείς άλλο. Περίπου 25 λεπτά συνολικά.';

  @override
  String get tsRampaTesto2 =>
      'Σε ERG το προπονητήριο κρατά μόνο του τα watt: δεν χρειάζεται να ξέρεις πόσο να πιέσεις. Το FTP είναι το 75% του καλύτερου λεπτού σου.';

  @override
  String get tsVentiTesto1 =>
      'Ζέσταμα με 3 γρήγορα λεπτά, μετά 20 λεπτά όσο πιο δυνατά μπορείς να κρατήσεις και μετά 10 χαλαρά λεπτά. Περίπου 55 λεπτά.';

  @override
  String get tsVentiTesto2Senza =>
      'Χωρίς FTP πας με την αίσθηση: ξεκίνα λίγο χαλαρά και τελείωσε δυνατά. Χρειάζεται μετρητής ισχύος.';

  @override
  String tsVentiTesto2Con(Object p0) {
    return 'Ξεκινάς γύρω από το τωρινό σου FTP ($p0 W). Χρειάζεται μετρητής ισχύος.';
  }

  @override
  String get tsVentiTesto3 =>
      'Το FTP είναι το 95% του μέσου όρου των 20 λεπτών.';

  @override
  String get tsNuotoTesto1 =>
      'Ζέσταμα, μετά 400 μ. όσο πιο γρήγορα μπορείς, 5 λεπτά διάλειμμα και 200 μ. στο μέγιστο. Περίπου 1300 μ. συνολικά.';

  @override
  String get tsNuotoTesto2 =>
      'Σημείωσε τους δύο χρόνους (ρολόι ή χρονόμετρο της πισίνας): ο κρίσιμος ρυθμός είναι η διαφορά διά 2.';

  @override
  String get tsHoFattoTest => 'Έκανα το τεστ: γράψε τους χρόνους';

  @override
  String get tsTempiTest => 'Οι χρόνοι του τεστ';

  @override
  String get tsEs400 => 'λ:δδ, π.χ. 8:20';

  @override
  String get tsEs200 => 'λ:δδ, π.χ. 3:55';

  @override
  String get tsCalcola => 'Υπολογισμός';

  @override
  String get tsControllaTempi =>
      'Έλεγξε τους χρόνους (λ:δδ): το 400 πρέπει να είναι τουλάχιστον σχεδόν διπλάσιο από το 200.';

  @override
  String tsPassoSalvato(Object p0) {
    return 'Κρίσιμος ρυθμός: $p0. Αποθηκεύτηκε.';
  }

  @override
  String tsTestNelCalendario(Object p0) {
    return 'Τεστ στο ημερολόγιο: $p0. Παίρνει τη θέση της προπόνησης εκείνης της μέρας.';
  }

  @override
  String get tsSeNonSaiTest => 'Αν δεν το ξέρεις, κάνε το τεστ παρακάτω.';

  @override
  String get tsFaiTestCalcolarlo => 'Κάνε το τεστ για να το υπολογίσεις';

  @override
  String tsUsciteDicono(Object p0) {
    return 'Οι διαδρομές σου λένε $p0 W';
  }

  @override
  String tsDalTest(Object p0) {
    return 'Από το τεστ της $p0.';
  }

  @override
  String tsHaiTenuto(Object p0, Object p1, Object p2) {
    return 'Στις $p0 κράτησες $p1 W για 20 λεπτά: το FTP σου είναι τουλάχιστον $p2 W.';
  }

  @override
  String get tsUsaloComeFtp => 'Χρησιμοποίησέ το ως FTP';

  @override
  String tsTuoFtp(Object p0) {
    return 'Το FTP σου: $p0 W';
  }

  @override
  String tsComeRampa(Object p0) {
    return 'Είναι το 75% του καλύτερου λεπτού σου στη ράμπα ($p0 W).';
  }

  @override
  String tsComeVenti(Object p0) {
    return 'Είναι το 95% των 20 λεπτών του τεστ ($p0 W μέσος όρος).';
  }

  @override
  String tsComeUscita(Object p0) {
    return 'Είναι το 95% των καλύτερων 20 λεπτών σου ($p0 W). Χωρίς τεστ δείχνει μόνο ότι είσαι τουλάχιστον σε αυτό το επίπεδο.';
  }

  @override
  String tsAdessoUsi(Object p0) {
    return 'Τώρα χρησιμοποιείς $p0 W.';
  }

  @override
  String tsPropostaPrima(Object p0) {
    return 'Από τις διαδρομές σου το FTP ποδηλάτου είναι τουλάχιστον $p0 W. Να το χρησιμοποιήσω για τις ζώνες;';
  }

  @override
  String tsPropostaSalito(Object p0, Object p1) {
    return 'Οι διαδρομές σου λένε ότι το FTP ποδηλάτου ανέβηκε: $p0 W (πριν $p1). Να το ενημερώσω;';
  }

  @override
  String get tsAggiorna => 'Ενημέρωση';

  @override
  String get tsTestRampaRullo => 'Τεστ FTP ράμπας στο προπονητήριο';

  @override
  String get tsTestNuotoPiscina => 'Τεστ κρίσιμου ρυθμού στην πισίνα';

  @override
  String tsPropostaTest(Object p0, Object p1, Object p2) {
    return '$p0 $p1: $p2;';
  }

  @override
  String tsPropostaTestAlPosto(Object p0, Object p1, Object p2, Object p3) {
    return '$p0 $p1: $p2, στη θέση του $p3;';
  }

  @override
  String get tsMettilo => 'Πρόσθεσέ το';

  @override
  String tsTestNelCalendarioBreve(Object p0) {
    return 'Τεστ στο ημερολόγιο: $p0.';
  }

  @override
  String get tsNonRiuscito => 'Δεν κατάφερα να το προσθέσω στο ημερολόγιο.';

  @override
  String get webhookTitolo => 'Webhook';

  @override
  String get webhookSottotitolo =>
      'Στείλε τις προπονήσεις σου σε μια δική σου διεύθυνση web (Home Assistant, n8n, Node-RED…)';

  @override
  String get webhookSpiegazione =>
      'Κάθε φορά που τελειώνεις μια προπόνηση, αλλάζει το πρόγραμμά σου ή κάνεις νέο ρεκόρ, η εφαρμογή στέλνει ένα μήνυμα στη διεύθυνση που επιλέγεις, ώστε τα δεδομένα να φτάνουν στους δικούς σου πίνακες. Κανένας δικός μας διακομιστής: η διεύθυνση είναι δική σου.';

  @override
  String get webhookAttivo => 'Αποστολή δεδομένων στο webhook';

  @override
  String get webhookSpento => 'Ανενεργό: δεν στέλνεται τίποτα.';

  @override
  String get webhookAcceso => 'Ενεργό';

  @override
  String get webhookIndirizzo => 'Διεύθυνση (URL)';

  @override
  String get webhookUrlNonValido =>
      'Γράψε μια πλήρη διεύθυνση που ξεκινά με https://';

  @override
  String get webhookChiave => 'Μυστικό κλειδί (προαιρετικό)';

  @override
  String get webhookChiaveAiuto =>
      'Με το κλειδί κάθε μήνυμα έχει υπογραφή: όποιος το λαμβάνει ελέγχει ότι έρχεται πράγματι από την εφαρμογή σου.';

  @override
  String get webhookGenera => 'Δημιουργία';

  @override
  String get webhookCopia => 'Αντιγραφή κλειδιού';

  @override
  String get webhookChiaveCopiata => 'Το κλειδί αντιγράφηκε';

  @override
  String get webhookMostraChiave => 'Εμφάνιση ή απόκρυψη του κλειδιού';

  @override
  String get webhookSalva => 'Αποθήκευση';

  @override
  String get webhookSalvato => 'Το webhook αποθηκεύτηκε';

  @override
  String get webhookPrimaUrl =>
      'Πρώτα γράψε και αποθήκευσε μια διεύθυνση https://';

  @override
  String get webhookCosaInviare => 'Τι να στέλνεται';

  @override
  String get webhookEventoAllenamento => 'Ολοκληρωμένη προπόνηση';

  @override
  String get webhookEventoAllenamentoSotto =>
      'Ημερομηνία, άθλημα, διάρκεια, απόσταση, παλμοί, watt, ασκήσεις, σετ και βάρη';

  @override
  String get webhookEventoPiano => 'Ενημερωμένο πρόγραμμα';

  @override
  String get webhookEventoPianoSotto =>
      'Οι προγραμματισμένες προπονήσεις, όταν αλλάζουν';

  @override
  String get webhookEventoRecord => 'Νέο ρεκόρ';

  @override
  String get webhookEventoRecordSotto =>
      'Περισσότερα κιλά σε μια άσκηση ή η μεγαλύτερη απόσταση σε ένα άθλημα';

  @override
  String get webhookQualiAllenamenti => 'Ποιες προπονήσεις';

  @override
  String get webhookSoloApp => 'Μόνο όσες καταγράφονται με την εφαρμογή';

  @override
  String get webhookTutti => 'Και οι εισαγόμενες';

  @override
  String get webhookTuttiSotto =>
      'Από Health Connect, intervals.icu και CSV, μαζί με όσες είναι ήδη αποθηκευμένες';

  @override
  String get webhookSceltaTitolo => 'Ποιες προπονήσεις να στέλνονται;';

  @override
  String webhookSceltaTesto(Object p0) {
    return 'Μπορείς να στέλνεις μόνο όσες καταγράφεις με την εφαρμογή ή και όσες έρχονται από Health Connect, intervals.icu και αρχεία CSV. Με τη δεύτερη επιλογή στέλνονται και όσες είναι ήδη αποθηκευμένες (τώρα είναι $p0): μπορεί να είναι εκατοντάδες και η πρώτη αποστολή μπορεί να πάρει λίγη ώρα. Φεύγουν μία μία, ακόμη και με την εφαρμογή κλειστή.';
  }

  @override
  String get webhookInviaTest => 'Δοκιμαστική αποστολή';

  @override
  String webhookTestOk(Object p0) {
    return 'Η δοκιμή πέτυχε: απάντηση HTTP $p0';
  }

  @override
  String webhookTestErrore(Object p0) {
    return 'Η δοκιμή απέτυχε: $p0';
  }

  @override
  String webhookCodiceHttp(Object p0) {
    return 'απάντηση HTTP $p0';
  }

  @override
  String get webhookErroreTimeout => 'καμία απάντηση μέσα σε 10 δευτερόλεπτα';

  @override
  String get webhookErroreRete => 'το δίκτυο δεν είναι διαθέσιμο';

  @override
  String get webhookErroreAltro =>
      'η σύνδεση απέτυχε (πιστοποιητικό ή διεύθυνση)';

  @override
  String get webhookErroreScaduto => 'πολύ παλιό μήνυμα, απορρίφθηκε';

  @override
  String get webhookStato => 'Κατάσταση';

  @override
  String webhookUltimoOk(Object p0, Object p1, Object p2) {
    return 'Τελευταία επιτυχής αποστολή: $p0 στις $p1:$p2';
  }

  @override
  String get webhookMaiInviato => 'Καμία επιτυχής αποστολή ακόμη';

  @override
  String webhookUltimoErrore(Object p0, Object p1, Object p2, Object p3) {
    return 'Τελευταίο σφάλμα: $p0 στις $p1:$p2, $p3';
  }

  @override
  String webhookInCoda(Object p0) {
    return 'Μηνύματα σε αναμονή: $p0';
  }

  @override
  String webhookScartati(Object p0) {
    return 'Μηνύματα που απορρίφθηκαν: $p0';
  }

  @override
  String get webhookComeFunziona => 'Πώς λειτουργεί';

  @override
  String get webhookComeFunzionaTesto =>
      'Κάθε μήνυμα είναι ένα αίτημα POST με JSON. Αν δεν φτάσει (χωρίς δίκτυο, διακομιστής κλειστός) μένει σε ουρά και η εφαρμογή ξαναδοκιμάζει μετά από 1, 5 και 15 λεπτά, μετά κάθε ώρα, ακόμη και με την εφαρμογή κλειστή μόλις επιστρέψει το δίκτυο: το πολύ 10 φορές ή 7 ημέρες. Τα σφάλματα 4xx (λάθος διεύθυνση ή κλειδί) δεν ξαναδοκιμάζονται. Μορφή και παραδείγματα στο docs/WEBHOOK.md, στο αποθετήριο της εφαρμογής στο GitHub.';

  @override
  String get webhookFacoltativo => 'Webhook (προαιρετικό)';

  @override
  String get webhookPrivacy =>
      'Μόνο αν ενεργοποιήσεις το webhook και γράψεις μια διεύθυνση https, η εφαρμογή στέλνει σε αυτή τη διεύθυνση, που επιλέγεις και διαχειρίζεσαι εσύ, τα δεδομένα των γεγονότων που τσεκάρεις: ολοκληρωμένες προπονήσεις (ημερομηνία, ώρες, άθλημα, όνομα, διάρκεια, απόσταση, παλμοί, watt, ρυθμός πεταλιάς, βήματα, θερμίδες, RPE, σημειώσεις, ασκήσεις με σετ και κιλά), προγραμματισμένες προπονήσεις και ρεκόρ. Όχι όνομα, φωτογραφία, σωματικές μετρήσεις ή διαδρομές GPS. Η διεύθυνση και το μυστικό κλειδί μένουν κρυπτογραφημένα στο τηλέφωνο και δεν μπαίνουν στο αντίγραφο ασφαλείας. Τα δεδομένα τα λαμβάνει η υπηρεσία που επέλεξες εσύ, με τους δικούς της όρους απορρήτου. Αν το απενεργοποιήσεις, δεν στέλνεται πια τίποτα και η ουρά αδειάζει.';

  @override
  String get aggiornamentiApp => 'Ενημερώσεις εφαρμογής';

  @override
  String get aggiornamentiAppSotto =>
      'Έλεγχος στο GitHub μία φορά τη μέρα. Πάτα για έλεγχο τώρα';

  @override
  String nuovaVersione(Object p0) {
    return 'Κυκλοφόρησε η έκδοση $p0';
  }

  @override
  String get aggiornamentoSpiegazione =>
      'Εγκαθίσταται πάνω από την εφαρμογή που έχεις: τα δεδομένα και οι ρυθμίσεις μένουν. Το Android θα σου ζητήσει επιβεβαίωση.';

  @override
  String get novitaVersione => 'Τι νέο υπάρχει';

  @override
  String get aggiornaApp => 'Ενημέρωση';

  @override
  String get scaricoAggiornamento => 'Λήψη της ενημέρωσης…';

  @override
  String get aggiornamentoPermesso =>
      'Χωρίς την άδεια εγκατάστασης εφαρμογών η ενημέρωση δεν μπορεί να ξεκινήσει. Μπορείς να τη δώσεις την επόμενη φορά που θα πατήσεις Ενημέρωση.';

  @override
  String get aggiornamentoRete =>
      'Η λήψη απέτυχε: έλεγξε τη σύνδεση και δοκίμασε ξανά.';

  @override
  String get aggiornamentoImpronta =>
      'Το αρχείο που κατέβηκε δεν ταιριάζει με αυτό που δημοσιεύτηκε: δεν εγκαταστάθηκε.';

  @override
  String get aggiornamentoErrore =>
      'Η ενημέρωση απέτυχε. Μπορείς να κατεβάσεις το APK από τη σελίδα Releases στο GitHub.';

  @override
  String get aggiornamentoAnnullato => 'Η ενημέρωση ακυρώθηκε.';

  @override
  String haiUltimaVersione(Object p0) {
    return 'Έχεις ήδη την τελευταία έκδοση ($p0).';
  }

  @override
  String get githubNonRisponde => 'Το GitHub δεν απαντά: δοκίμασε αργότερα.';

  @override
  String get aggiornamentiPrivacy =>
      'Μία φορά τη μέρα, όταν ανοίγει, η εφαρμογή ρωτά το GitHub (api.github.com) ποια είναι η τελευταία έκδοση που δημοσιεύτηκε. Αν πατήσεις Ενημέρωση, κατεβάζει το APK από το GitHub στην προσωρινή της μνήμη, ελέγχει ότι είναι ίδιο με αυτό που δημοσιεύτηκε, το δίνει στο πρόγραμμα εγκατάστασης του Android και το διαγράφει: στο τηλέφωνο δεν μένουν αρχεία. Το GitHub λαμβάνει τη διεύθυνση IP του τηλεφώνου και την έκδοση που ζητήθηκε, τίποτα άλλο. Μπορείς να απενεργοποιήσεις τον έλεγχο από το Προφίλ, στο Ενημερώσεις εφαρμογής.';
}
