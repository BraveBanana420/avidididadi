import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('el'),
    Locale('en'),
    Locale('it'),
  ];

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'Tenuto'**
  String get tenuto;

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'Un po\' più lento'**
  String get poPiuLento;

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'Molto più lento'**
  String get moltoPiuLento;

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'principale {p0} invece di {p1}'**
  String principaleInvece(Object p0, Object p1);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'passo {p0} invece di {p1}'**
  String passoInvece(Object p0, Object p1);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'intensità {p0} invece di {p1}'**
  String intensitaInvece(Object p0, Object p1);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'totale {p0} m invece di {p1} m'**
  String totaleMInveceM(Object p0, Object p1);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'durata {p0} min invece di {p1}'**
  String durataMinInvece(Object p0, Object p1);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'Passo più lento del target del {p0}% (fatica {p1}, attesa {p2}): alleggerisco il {p3}.'**
  String passoPiuLentoTarget(Object p0, Object p1, Object p2, Object p3);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica {p0}, sopra l\'attesa ({p1}): alleggerisco il {p2}.'**
  String faticaSopraAttesaAlleggerisco(Object p0, Object p1, Object p2);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica {p0}, in linea con l\'attesa ({p1}): progressione normale, una cosa alla volta.'**
  String faticaLineaAttesaProgressione(Object p0, Object p1);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica {p0}, sotto l\'attesa ({p1}): piccola progressione.'**
  String faticaSottoAttesaPiccola(Object p0, Object p1);

  /// adattamento.dart
  ///
  /// In it, this message translates to:
  /// **'Due sedute pesanti di fila: settimana di scarico per il {p0}.'**
  String dueSedutePesantiFila(Object p0);

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'In Claude: Impostazioni → Privacy → disattiva \"Aiuta a migliorare Claude\".'**
  String get claudeImpostazioniPrivacyDisattiva;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'In ChatGPT: Impostazioni → Controlli dati → disattiva \"Migliora il modello per tutti\".'**
  String get chatgptImpostazioniControlliDati;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'In Gemini: disattiva \"Attività nelle app Gemini\" (o \"Mantieni attività\") dal tuo account Google.'**
  String get geminiDisattivaAttivitaNelle;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'Controlla nelle impostazioni dell\'app se le chat servono ad addestrare il modello e, se vuoi, disattivalo.'**
  String get controllaNelleImpostazioniDell;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'Nella risposta non c\'è il blocco per l\'app. Chiedi all\'assistente di scrivere le modifiche nel formato <avidididadi>.'**
  String get nellaRispostaNonC;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'Il codice nella risposta non è quello di questo telefono: forse è di un collegamento vecchio. Manda di nuovo i dati e riprova.'**
  String get codiceNellaRispostaNon;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'Il blocco non è leggibile. Chiedi all\'assistente di riscriverlo.'**
  String get bloccoNonLeggibileChiedi;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'La data di inizio è già passata.'**
  String get dataInizioGiaPassata;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'data mancante'**
  String get dataMancante;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'prima dell\'inizio del piano'**
  String get primaDellInizioPiano;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'oltre le {p0} settimane'**
  String oltreSettimane(Object p0);

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'sport non previsto'**
  String get sportNonPrevisto;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'durata non sensata'**
  String get durataNonSensata;

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'due sedute di {p0} lo stesso giorno'**
  String dueSeduteStessoGiorno(Object p0);

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana del {p0}: manca un giorno di riposo.'**
  String settimanaMancaGiornoRiposo(Object p0);

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana del {p0}: {p1} minuti, troppi rispetto alle settimane prima (al massimo {p2}).'**
  String settimanaMinutiTroppiRispetto(Object p0, Object p1, Object p2);

  /// agente_esterno.dart
  ///
  /// In it, this message translates to:
  /// **'L\'app non ha accettato il piano per questi motivi:\n{p0}\nCorreggilo e rimandalo nel blocco <avidididadi> con il codice {p1}.'**
  String appNonHaAccettato(Object p0, Object p1);

  /// allenamento_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Un allenamento non ha la data.'**
  String get allenamentoNonHaData;

  /// allenamento_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento del {p0}: lo sport deve essere corsa, bici o nuoto.'**
  String allenamentoSportDeveEssere(Object p0);

  /// allenamento_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento del {p0}: servono da 1 a 40 passi.'**
  String allenamentoServono140(Object p0);

  /// allenamento_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento di {p0}'**
  String allenamento(Object p0);

  /// allenamento_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento del {p0}, passo {p1}: servono i minuti (fino a 300) o i metri.'**
  String allenamentoPassoServonoMinuti(Object p0, Object p1);

  /// allenamento_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento del {p0}, passo {p1}: ripetizioni da 1 a 30 e recupero fino a 1800 secondi.'**
  String allenamentoPassoRipetizioni1(Object p0, Object p1);

  /// allenamento_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento del {p0}: dura più di 5 ore.'**
  String allenamentoDuraPiu5(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Trave'**
  String get trave;

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Circuito'**
  String get circuito;

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Campus'**
  String get campus;

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Potenza'**
  String get potenza;

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: \"{p1}\" deve essere un numero da 0 a {p2}.'**
  String deveEssereNumero0(Object p0, Object p1, Object p2);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: manca il nome.'**
  String mancaNome(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizio {p0}'**
  String esercizio(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Un allenamento di arrampicata non ha il nome.'**
  String get allenamentoArrampicataNonHa;

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'\"{p0}\": servono da 1 a 30 esercizi.'**
  String servono130Esercizi(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'\"{p0}\", esercizio {p1}'**
  String esercizio2(Object p0, Object p1);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero tra le serie'**
  String get recuperoTraSerie;

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Riposa: la serie dopo è \"{p0}\".'**
  String riposaSerieDopo(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}:{p1} min'**
  String min(Object p0, Object p1);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Data non valida: {p0} (serve AAAA-MM-GG).'**
  String dataNonValidaServe(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Nel blocco non ci sono allenamenti di arrampicata.'**
  String get nelBloccoNonCi;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Il backup è rovinato: i tuoi dati sono rimasti quelli di prima.'**
  String get backupRovinatoTuoiDati;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Errore: {p0}'**
  String errore(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Collega prima intervals.icu da Profilo → Dati e collegamenti.'**
  String get collegaPrimaIntervalsIcu;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Già inviata a intervals.icu.'**
  String get giaInviataIntervalsIcu;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Inviata a intervals.icu.'**
  String get inviataIntervalsIcu;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Incolla prima la chiave API.'**
  String get incollaPrimaChiaveApi;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Collegato'**
  String get collegato;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Collegato come {p0}'**
  String collegatoCome(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave non trovata: collega di nuovo intervals.icu.'**
  String get chiaveNonTrovataCollega;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} attività lette da intervals.icu.'**
  String attivitaLetteIntervalsIcu(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Il calendario di intervals.icu è già aggiornato.'**
  String get calendarioIntervalsIcuGia;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'seduta mandata'**
  String get sedutaMandata;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'sedute mandate'**
  String get seduteMandate;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} a intervals.icu.'**
  String intervalsIcu(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} sedute tolte dal calendario di intervals.icu.'**
  String seduteTolteDalCalendario(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione già in corso.'**
  String get sincronizzazioneGiaCorso;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect va aggiornato: aprilo dal Play Store.'**
  String get healthConnectVaAggiornato;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect non è installato sul telefono.'**
  String get healthConnectNonInstallato;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect è disponibile solo su Android.'**
  String get healthConnectDisponibileSolo;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect non è ancora collegato.'**
  String get healthConnectNonAncora;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Senza il permesso per le sessioni di allenamento non posso leggere nulla. Puoi darlo da \"Rivedi permessi\".'**
  String get senzaPermessoSessioniAllenamento;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuna novità da Health Connect.'**
  String get nessunaNovitaHealthConnect;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} sessioni nuove'**
  String sessioniNuove(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Errore durante la sincronizzazione: {p0}'**
  String erroreDuranteSincronizzazione(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Feedback salvato: conta nel carico di allenamento.'**
  String get feedbackSalvatoContaNel;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'resta uguale'**
  String get restaUguale;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}\n\nProssima seduta ({p1}): {p2}.'**
  String prossimaSeduta(Object p0, Object p1, Object p2);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'Feedback salvato.'**
  String get feedbackSalvato;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'file vuoto o non valido.'**
  String get fileVuotoONon;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'formato non riconosciuto: servono almeno le colonne data e sport (trovate: {p0}).'**
  String formatoNonRiconosciutoServono(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} righe scartate (data o sport mancanti)'**
  String righeScartateDataO(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} ignorate ({p1})'**
  String ignorate(Object p0, Object p1);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} sessioni nuove, {p1} aggiornate{p2}.'**
  String sessioniNuoveAggiornate(Object p0, Object p1, Object p2);

  /// arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Grado più difficile: {p0}{p1}'**
  String gradoPiuDifficile(Object p0, Object p1);

  /// arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'vie chiuse'**
  String get vieChiuse;

  /// arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'blocchi chiusi'**
  String get blocchiChiusi;

  /// arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'circa {p0} m saliti'**
  String circaMSaliti(Object p0);

  /// arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'Progetto: {p0}'**
  String progetto(Object p0);

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'Ollama sul tuo PC'**
  String get ollamaSulTuoPc;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'Serve una chiave API da console.anthropic.com (a consumo). L\'abbonamento Claude Pro non vale per le app esterne.'**
  String get serveChiaveApiConsole;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'Serve una chiave API da platform.openai.com (a consumo). L\'abbonamento ChatGPT Plus non vale per le app esterne.'**
  String get serveChiaveApiPlatform;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'Serve una chiave API da aistudio.google.com: c\'è un piano gratuito con limiti giornalieri.'**
  String get serveChiaveApiAistudio;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'Gratis e privato: il modello gira sul tuo PC, nella stessa rete Wi-Fi. Nessuna chiave. Sul PC avvia Ollama con OLLAMA_HOST=0.0.0.0.'**
  String get gratisPrivatoModelloGira;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'Nel blocco non ci sono allenamenti.'**
  String get nelBloccoNonCi2;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'Nel piano mancano la data di inizio o le sedute.'**
  String get nelPianoMancanoData;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'Nel blocco non ci sono modifiche valide.'**
  String get nelBloccoNonCi3;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'La proposta non è leggibile: chiedi al coach di riscriverla.'**
  String get propostaNonLeggibileChiedi;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'sport non previsto ({p0})'**
  String sportNonPrevisto2(Object p0);

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'la data è già passata'**
  String get dataGiaPassata;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'durata non sensata ({p0} min)'**
  String durataNonSensataMin(Object p0);

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'c\'è già una seduta di {p0} quel giorno'**
  String cGiaSedutaQuel(Object p0);

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'manca la durata'**
  String get mancaDurata;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'quel giorno non c\'è una seduta di {p0}'**
  String quelGiornoNonC(Object p0);

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'nuova data mancante o passata'**
  String get nuovaDataMancanteO;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'c\'è già una seduta di {p0} il giorno scelto'**
  String cGiaSedutaGiorno(Object p0);

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'la settimana passerebbe da {p0} a {p1} minuti (oltre +10%)'**
  String settimanaPasserebbeMinutiOltre(Object p0, Object p1);

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'la settimana resterebbe senza un giorno di riposo'**
  String get settimanaResterebbeSenzaGiorno;

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: nuova seduta, {p1}'**
  String nuovaSeduta(Object p0, Object p1);

  /// assistente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: tolta{p1}'**
  String tolta(Object p0, Object p1);

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Ellittica'**
  String get ellittica;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Canottaggio'**
  String get canottaggio;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Vogatore'**
  String get vogatore;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Stepper'**
  String get stepper;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Scale'**
  String get scale;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Sci'**
  String get sci;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Scialpinismo'**
  String get scialpinismo;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Sci di fondo'**
  String get sciFondo;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Pattinaggio'**
  String get pattinaggio;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Kayak'**
  String get kayak;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Canoa'**
  String get canoa;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Vela'**
  String get vela;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Surf'**
  String get surf;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'SUP'**
  String get sup;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Calcio'**
  String get calcio;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Basket'**
  String get basket;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Pallavolo'**
  String get pallavolo;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Ping pong'**
  String get pingPong;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Danza'**
  String get danza;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Arti marziali'**
  String get artiMarziali;

  /// attivita.dart
  ///
  /// In it, this message translates to:
  /// **'Pugilato'**
  String get pugilato;

  /// attivita_libera.dart
  ///
  /// In it, this message translates to:
  /// **'Uscita in bici'**
  String get uscitaBici;

  /// attivita_libera.dart
  ///
  /// In it, this message translates to:
  /// **'Nuoto libero'**
  String get nuotoLibero;

  /// attivita_libera.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca \"Fatto\" quando hai finito.'**
  String get toccaFattoQuandoHai;

  /// avvisi.dart
  ///
  /// In it, this message translates to:
  /// **'Due pagine'**
  String get duePagine;

  /// avvisi.dart
  ///
  /// In it, this message translates to:
  /// **'Minimappa'**
  String get minimappa;

  /// avvisi.dart
  ///
  /// In it, this message translates to:
  /// **'Tutto schermo'**
  String get tuttoSchermo;

  /// avviso.dart
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get annulla;

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'Creato il {p0}'**
  String creato(Object p0);

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} giorni di piano'**
  String giorniPiano(Object p0);

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'foto del profilo'**
  String get fotoProfilo;

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'File troppo grande per essere un backup.'**
  String get fileTroppoGrandeEssere;

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'Il file non è un backup di Avidididadi.'**
  String get fileNonBackupAvidididadi;

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'Backup creato da una versione più recente dell\'app: aggiornala.'**
  String get backupCreatoVersionePiu;

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'Il backup è vuoto.'**
  String get backupVuoto;

  /// backup_auto.dart
  ///
  /// In it, this message translates to:
  /// **'Non riesco a scrivere nella cartella: sceglila di nuovo (forse è stata spostata o cancellata).'**
  String get nonRiescoScrivereNella;

  /// backup_auto.dart
  ///
  /// In it, this message translates to:
  /// **'Backup automatico non riuscito.'**
  String get backupAutomaticoNonRiuscito;

  /// battito.dart
  ///
  /// In it, this message translates to:
  /// **'Sensore del battito'**
  String get sensoreBattito;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'Basta un paio di scarpe. Si parte anche camminando.'**
  String get bastaPaioScarpeSi;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'A casa o in palestra, anche senza attrezzi.'**
  String get casaOPalestraAnche;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'In piscina, delicato sulle articolazioni.'**
  String get piscinaDelicatoSulleArticolazioni;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'All\'aperto o sui rulli, a ritmo tranquillo.'**
  String get allApertoOSui;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'Stretching e movimenti lenti: perfetta per iniziare o recuperare.'**
  String get stretchingMovimentiLentiPerfetta;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'In palestra o in falesia: segni vie, blocchi e gradi.'**
  String get palestraOFalesiaSegni;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'Mai o quasi mai'**
  String get maiOQuasiMai;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'Si parte piano: sedute semplici per imparare i movimenti.'**
  String get siPartePianoSedute;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni tanto'**
  String get ogniTanto;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'Qualche allenamento al mese, ma senza costanza.'**
  String get qualcheAllenamentoAlMese;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'Regolarmente'**
  String get regolarmente;

  /// benvenuto.dart
  ///
  /// In it, this message translates to:
  /// **'Mi alleno quasi ogni settimana da mesi.'**
  String get miAllenoQuasiOgni;

  /// carico.dart
  ///
  /// In it, this message translates to:
  /// **'In calo: stai facendo meno del solito.'**
  String get caloStaiFacendoMeno;

  /// carico.dart
  ///
  /// In it, this message translates to:
  /// **'Equilibrato: aumento sostenibile.'**
  String get equilibratoAumentoSostenibile;

  /// carico.dart
  ///
  /// In it, this message translates to:
  /// **'Attenzione: stai aumentando in fretta.'**
  String get attenzioneStaiAumentandoFretta;

  /// carico.dart
  ///
  /// In it, this message translates to:
  /// **'Rischio: troppo carico rispetto alle ultime settimane.'**
  String get rischioTroppoCaricoRispetto;

  /// charts.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} h {p1} min'**
  String hMin(Object p0, Object p1);

  /// charts.dart
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get chiudi;

  /// charts.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun dato per questo grafico.'**
  String get nessunDatoQuestoGrafico;

  /// charts.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana dal {p0}'**
  String settimanaDal(Object p0);

  /// charts.dart
  ///
  /// In it, this message translates to:
  /// **'Totale: {p0}'**
  String totale(Object p0);

  /// charts.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} in tutto il periodo: {p1}'**
  String tuttoPeriodo(Object p0, Object p1);

  /// charts.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento'**
  String get nessunAllenamento;

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Ripetizione {p0} di {p1}'**
  String ripetizione(Object p0, Object p1);

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Serie {p0} di {p1}'**
  String serie(Object p0, Object p1);

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Lato destro'**
  String get latoDestro;

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Lato sinistro'**
  String get latoSinistro;

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Cambia lato'**
  String get cambiaLato;

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'Cambia lato.'**
  String get cambiaLatoVoce;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} s per lato'**
  String secondiPerLato(Object p0);

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} per lato'**
  String ripetizioniPerLato(Object p0);

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Poi ripetizione {p0} di {p1}'**
  String poiRipetizione(Object p0, Object p1);

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Poi serie {p0} di {p1}'**
  String poiSerie(Object p0, Object p1);

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Continua piano, senza fermarti.'**
  String get continuaPianoSenzaFermarti;

  /// esecuzione.dart
  ///
  /// In it, this message translates to:
  /// **'Respira e bevi un sorso d\'acqua.'**
  String get respiraBeviSorsoAcqua;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Manubri'**
  String get manubri;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Il peso di ogni manubrio, es. 4, 8, 12. Se sono regolabili scrivi l\'intervallo, es. 2-20.'**
  String get pesoOgniManubrioEs;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Kettlebell'**
  String get kettlebell;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Il peso di ogni kettlebell che hai.'**
  String get pesoOgniKettlebellHai;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Bilanciere'**
  String get bilanciere;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Il peso della sola barra (di solito 20 kg).'**
  String get pesoSolaBarraSolito;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Dischi'**
  String get dischi;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Il peso dei dischi che hai. Si usano anche senza bilanciere.'**
  String get pesoDeiDischiHai;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Palla medica'**
  String get pallaMedica;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Il peso della palla.'**
  String get pesoPalla;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Elastici'**
  String get elastici;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Sbarra per trazioni'**
  String get sbarraTrazioni;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Parallele per dip'**
  String get paralleleDip;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Anelli o TRX'**
  String get anelliOTrx;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Panca'**
  String get panca;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Step o box'**
  String get stepOBox;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Fitball'**
  String get fitball;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Rullo (foam roller)'**
  String get rulloFoamRoller;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Lat machine'**
  String get latMachine;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Pulley basso'**
  String get pulleyBasso;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Cavi regolabili (croce ai cavi)'**
  String get caviRegolabiliCroceAi;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Chest press'**
  String get chestPress;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Pectoral machine'**
  String get pectoralMachine;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Shoulder press'**
  String get shoulderPress;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Rematore alla macchina'**
  String get rematoreAllaMacchina;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Multipower (Smith machine)'**
  String get multipowerSmithMachine;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Leg press'**
  String get legPress;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Hack squat'**
  String get hackSquat;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Leg extension'**
  String get legExtension;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Leg curl'**
  String get legCurl;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Adduttori e abduttori'**
  String get adduttoriAbduttori;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Calf machine (polpacci)'**
  String get calfMachinePolpacci;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Addominali'**
  String get addominali;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Obliqui'**
  String get obliqui;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Adduttori'**
  String get adduttori;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Bicipiti'**
  String get bicipiti;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Polpacci'**
  String get polpacci;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Petto'**
  String get petto;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Avambracci'**
  String get avambracci;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Glutei'**
  String get glutei;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Femorali'**
  String get femorali;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Dorsali'**
  String get dorsali;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Lombari'**
  String get lombari;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Collo'**
  String get collo;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Quadricipiti'**
  String get quadricipiti;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Spalle'**
  String get spalle;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Trapezio'**
  String get trapezio;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Tricipiti'**
  String get tricipiti;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Spinta orizzontale (petto)'**
  String get spintaOrizzontalePetto;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Spinta verticale (spalle)'**
  String get spintaVerticaleSpalle;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Trazione orizzontale (rematori)'**
  String get trazioneOrizzontaleRematori;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Trazione verticale (trazioni)'**
  String get trazioneVerticaleTrazioni;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Squat'**
  String get squat;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Affondi e step'**
  String get affondiStep;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Cerniera d\'anca (stacchi e ponti)'**
  String get cernieraAncaStacchiPonti;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Core'**
  String get core;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Spalle e postura'**
  String get spallePostura;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Braccia'**
  String get braccia;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Gambe alle macchine'**
  String get gambeAlleMacchine;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Pliometria'**
  String get pliometria;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Total body'**
  String get totalBody;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'Rullo (automassaggio)'**
  String get rulloAutomassaggio;

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'1 esercizio'**
  String get n1Esercizio;

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Bene! Dalla prossima sessione aumento un po\' il carico.'**
  String get beneDallaProssimaSessione;

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Hai segnalato dolore: alleggerisco le prossime sessioni. Se il dolore continua, fermati e chiedi a un medico.'**
  String get haiSegnalatoDoloreAlleggerisco;

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Alleggerisco un po\' le prossime sessioni.'**
  String get alleggeriscoPoProssimeSessioni;

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Carico giusto: si continua così.'**
  String get caricoGiustoSiContinua;

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Ti alleni meglio di quanto pensavi: passo al livello {p0}.'**
  String tiAlleniMeglioQuanto(Object p0);

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Passo al livello {p0}, più adatto per ora.'**
  String passoAlLivelloPiu(Object p0);

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Hai segnalato dolore: alleggerisco le prossime sedute di {p0}. Se il dolore continua, fermati e chiedi a un medico.'**
  String haiSegnalatoDoloreAlleggerisco2(Object p0);

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Bene! Le sedute di {p0} sono già al massimo dell\'aumento.'**
  String beneSeduteSonoGia(Object p0);

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Bene! Aumento un po\' l\'intensità delle prossime sedute di {p0}, a parità di tempo.'**
  String beneAumentoPoIntensita(Object p0);

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Bene! Allungo un po\' le prossime sedute di {p0}.'**
  String beneAllungoPoProssime(Object p0);

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Rendo un po\' meno intense le prossime sedute di {p0}.'**
  String rendoPoMenoIntense(Object p0);

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Accorcio un po\' le prossime sedute di {p0}.'**
  String accorcioPoProssimeSedute(Object p0);

  /// feedback.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica giusta: si continua così.'**
  String get faticaGiustaSiContinua;

  /// figura.dart
  ///
  /// In it, this message translates to:
  /// **'Braccio'**
  String get braccio;

  /// figura.dart
  ///
  /// In it, this message translates to:
  /// **'Vita'**
  String get vita;

  /// figura.dart
  ///
  /// In it, this message translates to:
  /// **'Fianchi'**
  String get fianchi;

  /// figura.dart
  ///
  /// In it, this message translates to:
  /// **'Coscia'**
  String get coscia;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Durata'**
  String get durata;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Sedute più lunghe del 5% per ogni passo.'**
  String get sedutePiuLunghe5;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Intensità'**
  String get intensita;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Stessa durata, più sforzo: recuperi più brevi, più minuti veloci, passo un po\' più svelto.'**
  String get stessaDurataPiuSforzo;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Auto'**
  String get auto;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Prima l\'intensità (fino a 2 passi), poi la durata.'**
  String get primaIntensitaFino2;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} · {p1} min'**
  String min2(Object p0, Object p1);

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa leggera alternata a camminata'**
  String get corsaLeggeraAlternataCamminata;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Dopo 2 minuti di corsa cammina 1 minuto. Se ti manca il fiato, cammina di più: va benissimo, è così che si comincia.'**
  String get dopo2MinutiCorsa;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Lungo · {p0} min'**
  String lungoMin(Object p0);

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa lunga continua'**
  String get corsaLungaContinua;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Ritmo facile e costante: devi riuscire a parlare.'**
  String get ritmoFacileCostanteDevi;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Finale a ritmo gara'**
  String get finaleRitmoGara;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Finale in progressione'**
  String get finaleProgressione;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa facile'**
  String get corsaFacile;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa veloce'**
  String get corsaVeloce;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero corricchiando in zona 2.'**
  String get recuperoCorricchiandoZona2;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa a ritmo sostenuto'**
  String get corsaRitmoSostenuto;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Ripetute veloci'**
  String get ripetuteVeloci;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero corricchiando piano.'**
  String get recuperoCorricchiandoPiano;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Blocchi a ritmo gara'**
  String get blocchiRitmoGara;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Allunghi in progressione'**
  String get allunghiProgressione;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Veloci ma rilassati, non a tutta.'**
  String get velociMaRilassatiNon;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Lento · {p0} min'**
  String lentoMin(Object p0);

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa lenta'**
  String get corsaLenta;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Stile libero facile'**
  String get stileLiberoFacile;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Gambe con tavoletta e braccio singolo'**
  String get gambeTavolettaBraccioSingolo;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'2 gambe con tavoletta, 1 solo braccio destro, 1 solo sinistro.'**
  String get n2GambeTavoletta1;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Stile libero sostenuto'**
  String get stileLiberoSostenuto;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'sostenuto, costante'**
  String get sostenutoCostante;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Stile libero aerobico'**
  String get stileLiberoAerobico;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'medio, respirazione regolare'**
  String get medioRespirazioneRegolare;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Dorso facile'**
  String get dorsoFacile;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Intervalli · {p0} min'**
  String intervalliMin(Object p0);

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Pedalata agile'**
  String get pedalataAgile;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Ripetute in salita o in pianura'**
  String get ripetuteSalitaOPianura;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Pedalata sciolta'**
  String get pedalataSciolta;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Uscita lunga'**
  String get uscitaLunga;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Uscita lunga · {p0} min'**
  String uscitaLungaMin(Object p0);

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Uscita continua'**
  String get uscitaContinua;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Inserisci {p0} tratti da 10 minuti in zona 3. Mangia e bevi ogni 30-45 minuti.'**
  String inserisciTratti10Minuti(Object p0);

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Mangia e bevi ogni 30-45 minuti.'**
  String get mangiaBeviOgni30;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Uscita · {p0} min'**
  String uscitaMin(Object p0);

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Pedalata costante'**
  String get pedalataCostante;

  /// generatore_endurance.dart
  ///
  /// In it, this message translates to:
  /// **'Finale più spinto'**
  String get finalePiuSpinto;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Poche ripetizioni con carichi alti e recuperi lunghi.'**
  String get pocheRipetizioniCarichiAlti;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Massa muscolare'**
  String get massaMuscolare;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni medie, più volume per far crescere i muscoli.'**
  String get ripetizioniMediePiuVolume;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Resistenza muscolare'**
  String get resistenzaMuscolare;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Tante ripetizioni e recuperi brevi, utile per gli sport di resistenza.'**
  String get tanteRipetizioniRecuperiBrevi;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Forma generale'**
  String get formaGenerale;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Un equilibrio tra forza, muscoli e resistenza.'**
  String get equilibrioTraForzaMuscoli;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Principiante'**
  String get principiante;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Ti alleni con i pesi da poco o non lo fai da tempo.'**
  String get tiAlleniPesiPoco;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Intermedio'**
  String get intermedio;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Ti alleni con costanza da almeno qualche mese.'**
  String get tiAlleniCostanzaAlmeno;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Avanzato'**
  String get avanzato;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Ti alleni da anni e conosci bene la tecnica.'**
  String get tiAlleniAnniConosci;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} · settimana {p1} di 4'**
  String settimana4(Object p0, Object p1);

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'10 per lato'**
  String get n10Lato;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'10 lenti'**
  String get n10Lenti;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana di scarico: una serie in meno, stessa tecnica.'**
  String get settimanaScaricoSerieMeno;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana 2: una ripetizione in più rispetto alla scorsa.'**
  String get settimana2RipetizionePiu;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana 3: due ripetizioni in più rispetto alla prima.'**
  String get settimana3DueRipetizioni;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Gambe leggere: domani hai {p0}.'**
  String gambeLeggereDomaniHai(Object p0);

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}/10 di fatica'**
  String n10Fatica(Object p0);

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'30 s per lato'**
  String get n30SLato;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'il Lungo'**
  String get lungo;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'il Fartlek'**
  String get fartlek;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'il Tempo run'**
  String get tempoRun;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Parti con la sola barra e aggiungi dischi fino alla fatica indicata.'**
  String get partiSolaBarraAggiungi;

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Peso: {p0} {p1} kg.'**
  String pesoKg(Object p0, Object p1);

  /// generatore_forza.dart
  ///
  /// In it, this message translates to:
  /// **'Peso: circa {p0} kg.'**
  String pesoCircaKg(Object p0);

  /// generatore_mobilita.dart
  ///
  /// In it, this message translates to:
  /// **'Movimenti lenti, respira con calma: allunga senza mai sentire dolore.'**
  String get movimentiLentiRespiraCalma;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa a ritmo tranquillo: devi riuscire a parlare senza fiatone. Costruisce la resistenza ed è la base di tutto.'**
  String get corsaRitmoTranquilloDevi;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'La corsa più lunga della settimana, sempre a ritmo facile. Abitua il corpo a durare nel tempo.'**
  String get corsaPiuLungaSettimana;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Gioco di velocità: alterni tratti veloci e tratti facili, senza mai fermarti. Allena a cambiare ritmo.'**
  String get giocoVelocitaAlterniTratti;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa a ritmo sostenuto ma costante, \"comodamente impegnativo\": parli a fatica, ma lo tieni per molti minuti.'**
  String get corsaRitmoSostenutoMa;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Tratti brevi e veloci con una pausa per recuperare tra uno e l\'altro. Rendono più veloci.'**
  String get trattiBreviVelociPausa;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Blocchi al ritmo che vuoi tenere il giorno della gara, per prenderci confidenza.'**
  String get blocchiAlRitmoVuoi;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa facile con qualche accelerazione breve (20 secondi), veloce ma rilassata. Tiene le gambe brillanti senza stancare.'**
  String get corsaFacileQualcheAccelerazione;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Nuoto calmo con esercizi per migliorare il movimento: nuotare bene costa meno fatica.'**
  String get nuotoCalmoEserciziMigliorare;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Serie di vasche a ritmo sostenuto e costante con brevi pause. Migliora la velocità che riesci a tenere a lungo.'**
  String get serieVascheRitmoSostenuto;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Pedalata costante a ritmo facile: costruisce la resistenza.'**
  String get pedalataCostanteRitmoFacile;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'La pedalata più lunga della settimana, a ritmo facile. Porta acqua e qualcosa da mangiare.'**
  String get pedalataPiuLungaSettimana;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Tratti di pedalata impegnativa (in salita o in pianura) con pause facili in mezzo.'**
  String get trattiPedalataImpegnativaSalita;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Movimenti lenti e allungamenti, quasi tutti a tempo. Sciolgono articolazioni e muscoli, aiutano a recuperare e a muoversi meglio. Non deve mai fare male.'**
  String get movimentiLentiAllungamentiQuasi;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Mobilità per anche, cosce e polpacci: le parti che lavorano di più in corsa e in bici.'**
  String get mobilitaAncheCoscePolpacci;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Mobilità per la schiena e il busto: utile se stai molto seduto.'**
  String get mobilitaSchienaBustoUtile;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Mobilità per spalle, petto e braccia: apre la postura e aiuta nel nuoto.'**
  String get mobilitaSpallePettoBraccia;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizi per i muscoli, a corpo libero o con i pesi, seguiti da qualche minuto di mobilità. Rendono più forti e proteggono da infortuni.'**
  String get eserciziMuscoliCorpoLibero;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'molto facile, come una camminata veloce'**
  String get moltoFacileComeCamminata;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'facile: riesci a parlare'**
  String get facileRiesciParlare;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'medio: parli, ma a fatica'**
  String get medioParliMaFatica;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'impegnativo: solo poche parole'**
  String get impegnativoSoloPocheParole;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'al massimo: si regge per poco'**
  String get alMassimoSiRegge;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Zone di frequenza cardiaca'**
  String get zoneFrequenzaCardiaca;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Cinque fasce di battiti al minuto, dalla più facile (1) alla più dura (5). Le calcola l\'app dai tuoi dati: segui la zona indicata e l\'allenamento ha l\'effetto giusto.'**
  String get cinqueFasceBattitiAl;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica (da 1 a 10)'**
  String get fatica110;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Quanto ti è sembrata dura la seduta: 1 è una passeggiata, 10 è il massimo. Dirlo dopo ogni seduta aiuta l\'app ad adattare il piano.'**
  String get quantoTiSembrataDura;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Carico'**
  String get carico;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Quanto ti sei allenato, tenendo conto di durata e fatica. Conta come cresce: aumentare poco alla volta evita di farsi male.'**
  String get quantoTiSeiAllenato;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana di scarico'**
  String get settimanaScarico;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni quattro settimane una più leggera: il corpo assorbe il lavoro fatto e riparte più forte.'**
  String get ogniQuattroSettimanePiu;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Come stai oggi, da sonno e battiti a riposo. Se è basso, meglio una seduta facile.'**
  String get comeStaiOggiSonno;

  /// glossario.dart
  ///
  /// In it, this message translates to:
  /// **'Movimenti lenti per sciogliere le articolazioni a fine seduta.'**
  String get movimentiLentiSciogliereArticolazioni;

  /// gps.dart
  ///
  /// In it, this message translates to:
  /// **'Sto registrando il percorso'**
  String get stoRegistrandoPercorso;

  /// gps.dart
  ///
  /// In it, this message translates to:
  /// **'Registrazione percorso'**
  String get registrazionePercorso;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Sessioni di allenamento'**
  String get sessioniAllenamento;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Frequenza cardiaca'**
  String get frequenzaCardiaca;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Distanza'**
  String get distanza;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Calorie attive'**
  String get calorieAttive;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Calorie totali'**
  String get calorieTotali;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Passi'**
  String get passi;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Velocità'**
  String get velocita;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'FC a riposo'**
  String get fcRiposo;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Variabilità cardiaca (HRV)'**
  String get variabilitaCardiacaHrv;

  /// health_connect.dart
  ///
  /// In it, this message translates to:
  /// **'Sonno'**
  String get sonno;

  /// immagini.dart
  ///
  /// In it, this message translates to:
  /// **'Immagine non disponibile senza rete'**
  String get immagineNonDisponibileSenza;

  /// intervalli.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} (previsti {p1})'**
  String previsti(Object p0, Object p1);

  /// intervalli.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero {p0}'**
  String recupero(Object p0);

  /// intervalli.dart
  ///
  /// In it, this message translates to:
  /// **'FC {p0}'**
  String fc(Object p0);

  /// intervals.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave API non valida: ricopiala da intervals.icu → Impostazioni → Developer settings.'**
  String get chiaveApiNonValida;

  /// intervals.dart
  ///
  /// In it, this message translates to:
  /// **'intervals.icu ha ricevuto troppe richieste: riprova tra qualche minuto.'**
  String get intervalsIcuHaRicevuto;

  /// intervals.dart
  ///
  /// In it, this message translates to:
  /// **'intervals.icu ha risposto con un errore ({p0}).'**
  String intervalsIcuHaRisposto(Object p0);

  /// intervals.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuna connessione a internet.'**
  String get nessunaConnessioneInternet;

  /// intervals.dart
  ///
  /// In it, this message translates to:
  /// **'intervals.icu non risponde: riprova.'**
  String get intervalsIcuNonRisponde;

  /// intervals.dart
  ///
  /// In it, this message translates to:
  /// **'Risposta di intervals.icu non leggibile.'**
  String get rispostaIntervalsIcuNon;

  /// intervals.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave API non valida.'**
  String get chiaveApiNonValida2;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Indirizzo di Ollama non valido: scrivilo come http://192.168.1.10:11434'**
  String get indirizzoOllamaNonValido;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Per proteggere i tuoi dati, l\'indirizzo http è accettato solo nella rete di casa (es. http://192.168.1.10:11434). Per un indirizzo su internet serve https.'**
  String get proteggereTuoiDatiIndirizzo;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Risposta vuota dal modello.'**
  String get rispostaVuotaDalModello;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave API non valida: ricopiala dal sito del servizio, per intero.\n({p0})'**
  String chiaveApiNonValida3(Object p0);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Richiesta rifiutata: controlla il nome del modello.'**
  String get richiestaRifiutataControllaNome;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave API non valida o senza permessi.'**
  String get chiaveApiNonValida4;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Modello non trovato su Ollama: scaricalo con \"ollama pull\".'**
  String get modelloNonTrovatoSu;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Modello non trovato: controlla il nome.'**
  String get modelloNonTrovatoControlla;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Limite di richieste raggiunto o credito esaurito. Riprova più tardi.'**
  String get limiteRichiesteRaggiuntoO;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Il servizio ha un problema in questo momento. Riprova più tardi.'**
  String get servizioHaProblemaQuesto;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Errore {p0}.'**
  String errore2(Object p0);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Manca la chiave API: aggiungila qui sopra.'**
  String get mancaChiaveApiAggiungila;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Non riesco a raggiungere Ollama a {p0}. ({p1})'**
  String nonRiescoRaggiungereOllama(Object p0, Object p1);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuna connessione a internet. ({p0})'**
  String nessunaConnessioneInternet2(Object p0);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Il servizio non risponde: riprova.'**
  String get servizioNonRispondeRiprova;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Risposta non leggibile.'**
  String get rispostaNonLeggibile;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Indirizzo non valido.'**
  String get indirizzoNonValido;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **', per esempio {p0}'**
  String esempio(Object p0);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'La chiave funziona, ma il modello \"{p0}\" non esiste. Toccane uno da \"Scegli tra i modelli disponibili\"{p1}.'**
  String chiaveFunzionaMaModello(Object p0, Object p1);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Prova di connessione'**
  String get provaConnessione;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Ollama risponde, ma il modello \"{p0}\" non c\'è. Installati: {p1}.'**
  String ollamaRispondeMaModello(Object p0, Object p1);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Non riesco a raggiungere Ollama a {p0}. Il PC è acceso, nella stessa rete, con Ollama aperto? ({p1})'**
  String nonRiescoRaggiungereOllama2(Object p0, Object p1);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Ollama non risponde: il PC è acceso?'**
  String get ollamaNonRispondePc;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Indirizzo non valido o risposta non di Ollama.'**
  String get indirizzoNonValidoO;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Indirizzo non valido: scrivilo come http://IP:11434'**
  String get indirizzoNonValidoScrivilo;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Manca la chiave API: aggiungila nelle impostazioni.'**
  String get mancaChiaveApiAggiungila2;

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Non riesco a raggiungere Ollama a {p0}. Il PC è acceso, nella stessa rete, con OLLAMA_HOST=0.0.0.0? ({p1})'**
  String nonRiescoRaggiungereOllama3(Object p0, Object p1);

  /// llm.dart
  ///
  /// In it, this message translates to:
  /// **'Il modello ci sta mettendo troppo: riprova.'**
  String get modelloCiStaMettendo;

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento interrotto'**
  String get allenamentoInterrotto;

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'L\'app si era chiusa durante l\'allenamento: {p0}. Riprendi da dove eri? Riparte in pausa.'**
  String appSiEraChiusa(Object p0);

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'Scarta'**
  String get scarta;

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'Riprendi'**
  String get riprendi;

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'Risposta ricevuta: la trovi in Coach.'**
  String get rispostaRicevutaTroviCoach;

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get oggi;

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'Progressi'**
  String get progressi;

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'Coach'**
  String get coach;

  /// main.dart
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profilo;

  /// mappa_offline.dart
  ///
  /// In it, this message translates to:
  /// **'circa {p0} MB'**
  String circaMb(Object p0);

  /// mappa_offline.dart
  ///
  /// In it, this message translates to:
  /// **'Download non riuscito: serve la rete. Riprova più tardi.'**
  String get downloadNonRiuscitoServe;

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'Lunedì'**
  String get lunedi;

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'Martedì'**
  String get martedi;

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'Mercoledì'**
  String get mercoledi;

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'Giovedì'**
  String get giovedi;

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'Venerdì'**
  String get venerdi;

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'Sabato'**
  String get sabato;

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'Domenica'**
  String get domenica;

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'intensità {p0}'**
  String intensita2(Object p0);

  /// models.dart
  ///
  /// In it, this message translates to:
  /// **'recupero {p0} s'**
  String recuperoS(Object p0);

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'La tua corsa più lunga'**
  String get tuaCorsaPiuLunga;

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'La tua uscita in bici più lunga'**
  String get tuaUscitaBiciPiu;

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'La tua nuotata più lunga'**
  String get tuaNuotataPiuLunga;

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'La tua camminata più lunga'**
  String get tuaCamminataPiuLunga;

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'Primo allenamento fatto!'**
  String get primoAllenamentoFatto;

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'Hai fatto {p0} allenamenti!'**
  String haiFattoAllenamenti(Object p0);

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'Record: {p0}'**
  String record(Object p0);

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} settimane di fila: grande!'**
  String settimaneFilaGrande(Object p0);

  /// motivazione.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} settimane di fila. Vai per la {p1}?'**
  String settimaneFilaVai(Object p0, Object p1);

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'Nel file non c\'è un percorso: serve un GPX con una traccia.'**
  String get nelFileNonC;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'a destra'**
  String get destra;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'a sinistra'**
  String get sinistra;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'tieni la destra'**
  String get tieniDestra;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'tieni la sinistra'**
  String get tieniSinistra;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'curva stretta {p0}'**
  String curvaStretta(Object p0);

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'torna indietro'**
  String get tornaIndietro;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'poi subito {p0}'**
  String poiSubito(Object p0);

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'Di nuovo sul percorso.'**
  String get nuovoSulPercorso;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'Sei fuori percorso, a {p0} dalla traccia.'**
  String seiFuoriPercorsoDalla(Object p0);

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'Stai andando nel senso contrario al percorso.'**
  String get staiAndandoNelSenso;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'Arrivo! Percorso completato.'**
  String get arrivoPercorsoCompletato;

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'Tra {p0}, {p1}{p2}.'**
  String tra(Object p0, Object p1, Object p2);

  /// notifica_allenamento.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero · poi {p0}'**
  String recuperoPoi(Object p0);

  /// notifica_allenamento.dart
  ///
  /// In it, this message translates to:
  /// **'In pausa · {p0}'**
  String pausa(Object p0);

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'5 km'**
  String get n5Km;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'10 km'**
  String get n10Km;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Mezza maratona'**
  String get mezzaMaratona;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Maratona'**
  String get maratona;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Mediofondo'**
  String get mediofondo;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Granfondo'**
  String get granfondo;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Triathlon sprint'**
  String get triathlonSprint;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Triathlon olimpico'**
  String get triathlonOlimpico;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Triathlon 70.3'**
  String get triathlon703;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Base'**
  String get base;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Sviluppo'**
  String get sviluppo;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Rifinitura'**
  String get rifinitura;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Scarico pre-gara'**
  String get scaricoPreGara;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana della gara'**
  String get settimanaGara;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Senza obiettivo'**
  String get senzaObiettivo;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Volume che cresce piano, quasi tutto a bassa intensità.'**
  String get volumeCrescePianoQuasi;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Si aggiungono le sedute di qualità, il lungo si allunga.'**
  String get siAggiungonoSeduteQualita;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Lavori al ritmo gara, volume stabile.'**
  String get lavoriAlRitmoGara;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Meno volume, un po\' di intensità per restare reattivo.'**
  String get menoVolumePoIntensita;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Poche sedute corte: si arriva freschi al via.'**
  String get pocheSeduteCorteSi;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Piano di mantenimento: imposta una gara per una preparazione.'**
  String get pianoMantenimentoImpostaGara;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Aerobica'**
  String get aerobica;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Medio'**
  String get medio;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Massimale'**
  String get massimale;

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'Z{p0} {p1}-{p2} bpm'**
  String zBpm(Object p0, Object p1, Object p2);

  /// obiettivo.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} ({p1}-{p2} bpm)'**
  String bpm(Object p0, Object p1, Object p2);

  /// percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Nel file non c\'è un percorso: serve un GPX con la traccia dell\'attività.'**
  String get nelFileNonC2;

  /// percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Pulse'**
  String get pulse;

  /// percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Strade'**
  String get strade;

  /// percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Satellite'**
  String get satellite;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Facile'**
  String get facile;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Fondo'**
  String get fondo;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'VO2max'**
  String get vo2max;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Anaerobica'**
  String get anaerobica;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Sprint'**
  String get sprint;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'fino a {p0} W'**
  String finoW(Object p0);

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'oltre {p0} W'**
  String oltreW(Object p0);

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Cadenza {p0}, scendi a {p1}.'**
  String cadenzaScendiA(Object p0, Object p1);

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Cadenza {p0}, sali a {p1}.'**
  String cadenzaSaliA(Object p0, Object p1);

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}-{p1} bpm'**
  String bpm2(Object p0, Object p1);

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} ({p1} · {p2}-{p3} bpm)'**
  String bpm3(Object p0, Object p1, Object p2, Object p3);

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} watt, scendi a {p1}.'**
  String wattScendiA(Object p0, Object p1);

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} watt, sali a {p1}.'**
  String wattSaliA(Object p0, Object p1);

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Registra questa corsa anche con l\'orologio: è lui a misurare i watt.'**
  String get registraQuestaCorsaAnche;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Veloci ma sciolti, poi cammina o corri piano.'**
  String get velociMaScioltiPoi;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Test: 20 minuti al massimo'**
  String get test20MinutiAl;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Il ritmo più forte che riesci a tenere fino alla fine, costante. Meglio partire un po\' piano e chiudere in crescendo.'**
  String get ritmoPiuForteRiesci;

  /// potenza.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa lentissima'**
  String get corsaLentissima;

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'Energia buona'**
  String get energiaBuona;

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'Energia normale'**
  String get energiaNormale;

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'Energia bassa'**
  String get energiaBassa;

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'Giornata adatta anche a una seduta di qualità.'**
  String get giornataAdattaAncheSeduta;

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'Allenati come previsto, ascoltando le sensazioni.'**
  String get allenatiComePrevistoAscoltando;

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'Meglio una seduta facile o un giorno di riposo: abbassa l\'intensità.'**
  String get meglioSedutaFacileO;

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'di solito {p0} ms · più alta è meglio'**
  String solitoMsPiuAlta(Object p0);

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'HRV {p0} ms, sotto la tua media ({p1} ms)'**
  String hrvMsSottoTua(Object p0, Object p1);

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'HRV {p0} ms, sopra la tua media'**
  String hrvMsSopraTua(Object p0);

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'di solito {p0} bpm · più bassa è meglio'**
  String solitoBpmPiuBassa(Object p0);

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'FC a riposo {p0} bpm, più alta del solito ({p1})'**
  String fcRiposoBpmPiu(Object p0, Object p1);

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'bene da 7 h 30 in su, poco sotto le 6 h'**
  String get bene7H30;

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'Hai dormito poco ({p0})'**
  String haiDormitoPoco(Object p0);

  /// recupero.dart
  ///
  /// In it, this message translates to:
  /// **'Hai dormito bene ({p0})'**
  String haiDormitoBene(Object p0);

  /// registro_forza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} a {p1} kg'**
  String kg(Object p0, Object p1);

  /// registro_forza.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} × {p1} kg'**
  String kg2(Object p0, Object p1);

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Tempo'**
  String get tempo;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Passo'**
  String get passo;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Battito medio'**
  String get battitoMedio;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Sollevati'**
  String get sollevati;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Calorie'**
  String get calorie;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Classica'**
  String get classica;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Mappa'**
  String get mappa;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Poster'**
  String get poster;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Km per km'**
  String get kmKm;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Salita'**
  String get salita;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizi'**
  String get esercizi;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Muscoli'**
  String get muscoli;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Seduta'**
  String get seduta;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'La tua foto'**
  String get tuaFoto;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} {p1} kg (prima {p2} kg)'**
  String kgPrimaKg(Object p0, Object p1, Object p2);

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'kg sollevati in tutto'**
  String get kgSollevatiTutto;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'ARRAMPICATA'**
  String get arrampicata;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'INDOOR'**
  String get indoor;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'OUTDOOR'**
  String get outdoor;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'il grado più alto di oggi'**
  String get gradoPiuAltoOggi;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Blocchi'**
  String get blocchi;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Saliti'**
  String get saliti;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'Attività'**
  String get attivita;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'ALTRA ATTIVITÀ'**
  String get altraAttivita;

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'La mia settimana ({p0})'**
  String miaSettimana(Object p0);

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}/{p1} sedute'**
  String sedute(Object p0, Object p1);

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Abbiamo aggiornato le regole'**
  String get abbiamoAggiornatoRegole;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Benvenuto in Avidididadi'**
  String get benvenutoAvidididadi;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Termini e informativa sono cambiati. Leggili e accettali per continuare.'**
  String get terminiInformativaSonoCambiati;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prima di iniziare, ecco in breve come funziona l\'app con i tuoi dati.'**
  String get primaIniziareEccoBreve;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I dati restano sul telefono'**
  String get datiRestanoSulTelefono;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun account, nessun server, nessuna pubblicità.'**
  String get nessunAccountNessunServer;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect solo in lettura'**
  String get healthConnectSoloLettura;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamenti, battito, sonno e percorsi delle tue app (es. Garmin), solo se lo permetti.'**
  String get allenamentiBattitoSonnoPercorsi;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'GPS solo durante corsa e bici'**
  String get gpsSoloDuranteCorsa;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mentre ti alleni con l\'app, con una notifica fissa. Mai in altri momenti.'**
  String get mentreTiAlleniApp;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mappe e immagini da internet'**
  String get mappeImmaginiInternet;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Da OpenFreeMap, Esri (satellite) e GitHub: il percorso non viene inviato.'**
  String get openfreemapEsriSatelliteGithub;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Assistente facoltativo'**
  String get assistenteFacoltativo;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Invia un riassunto degli allenamenti al servizio che scegli, solo se lo attivi tu.'**
  String get inviaRiassuntoDegliAllenamenti;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non è un consiglio medico'**
  String get nonConsiglioMedico;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Piani e consigli sono stime: in caso di dubbi o problemi di salute, chiedi al medico.'**
  String get pianiConsigliSonoStime;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Termini e condizioni'**
  String get terminiCondizioni;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Informativa privacy'**
  String get informativaPrivacy;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ho letto e accetto i Termini e condizioni e l\'Informativa sulla privacy'**
  String get hoLettoAccettoTermini;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Entra'**
  String get entra;

  /// screens/accettazione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non accetto, esci'**
  String get nonAccettoEsci;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Usa il tuo assistente'**
  String get usaTuoAssistente;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Parli con il coach nell\'app del tuo assistente, con il tuo abbonamento (anche gratuito): nessuna chiave API.'**
  String get parliCoachNellApp;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Avidididadi prepara un messaggio con i tuoi dati: lo mandi all\'assistente con Condividi.'**
  String get avidididadiPreparaMessaggioTuoi;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Parli con l\'assistente nella sua app, quanto vuoi.'**
  String get parliAssistenteNellaSua;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quando propone modifiche o un piano nuovo, condividi la risposta con Avidididadi: vedi l\'anteprima e decidi tu.'**
  String get quandoProponeModificheO;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quale app usi?'**
  String get qualeAppUsi;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prima di iniziare'**
  String get primaIniziare;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Con un abbonamento normale le chat possono servire ad addestrare il modello, secondo le impostazioni del tuo account. Nome, foto e percorsi GPS non vengono mai inviati.'**
  String get abbonamentoNormaleChatPossono;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Includi età, sesso, altezza e peso'**
  String get includiEtaSessoAltezza;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vedi esattamente cosa viene inviato'**
  String get vediEsattamenteCosaViene;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Acconsento a inviare questi dati a {p0} quando tocco Condividi o Copia'**
  String acconsentoInviareQuestiDati(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Collega {p0}'**
  String collega(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Privacy e uso dei dati'**
  String get privacyUsoDeiDati;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'l\'assistente'**
  String get assistente;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Manda a {p0}'**
  String manda(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Messaggio copiato: incollalo in {p0}.'**
  String messaggioCopiatoIncollalo(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Gli appunti sono vuoti: copia prima la risposta di {p0}.'**
  String appuntiSonoVuotiCopia(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scollegare {p0}?'**
  String scollegare(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Torni al coach dentro l\'app (per esempio Ollama sul tuo PC). Le risposte della conversazione attuale non verranno più accettate: se ricolleghi, manda di nuovo i dati.'**
  String get torniAlCoachDentro;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scollega'**
  String get scollega;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Risposta non usabile'**
  String get rispostaNonUsabile;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'1 · Parla con {p0}'**
  String n1Parla(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Hai fatto allenamenti nuovi? Manda i dati aggiornati nella stessa conversazione.'**
  String get haiFattoAllenamentiNuovi;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Manda il primo messaggio: istruzioni da coach e i tuoi dati. Scegli {p0} dal menu Condividi.'**
  String mandaPrimoMessaggioIstruzioni(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimo invio: {p0}, {p1}:{p2}'**
  String ultimoInvio(Object p0, Object p1, Object p2);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Manda dati aggiornati'**
  String get mandaDatiAggiornati;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia con {p0}'**
  String inizia(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nuova conversazione'**
  String get nuovaConversazione;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Copia invece'**
  String get copiaInvece;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'2 · Porta qui le modifiche'**
  String get n2PortaQuiModifiche;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quando {p0} propone di cambiare il piano, nella sua risposta tocca Condividi e scegli Avidididadi. Oppure copiala e tocca qui sotto.'**
  String quandoProponeCambiarePiano(Object p0);

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Incolla la risposta'**
  String get incollaRisposta;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Consiglio: le istruzioni una volta sola'**
  String get consiglioIstruzioniVoltaSola;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Incolla le istruzioni da coach in un Progetto di Claude, in un GPT personalizzato o in un Gem di Gemini. Poi ti basta mandare i dati aggiornati.'**
  String get incollaIstruzioniCoachProgetto;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Istruzioni copiate.'**
  String get istruzioniCopiate;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Copia solo le istruzioni'**
  String get copiaSoloIstruzioni;

  /// screens/agente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scollega {p0}'**
  String scollega2(Object p0);

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamenti di arrampicata'**
  String get allenamentiArrampicata;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nuovo'**
  String get nuovo;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ancora nessun allenamento'**
  String get ancoraNessunAllenamento;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Crealo con \"Nuovo\", oppure chiedilo al tuo assistente (per esempio mandandogli lo screenshot di un\'altra app): nella sua risposta condividi il blocco con l\'app e qui trovi l\'allenamento, pronto da mettere nel calendario.'**
  String get crealoNuovoOppureChiedilo;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Altri'**
  String get altri;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'In che giorno?'**
  String get giorno;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} è nel calendario: {p1}.'**
  String nelCalendario(Object p0, Object p1);

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile: scegli oggi o un giorno dopo.'**
  String get nonStatoPossibileScegli;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Eliminare \"{p0}\"?'**
  String eliminare(Object p0);

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sparisce dalla raccolta. Le sedute già nel calendario restano.'**
  String get sparisceDallaRaccoltaSedute;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get elimina;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento non trovato.'**
  String get allenamentoNonTrovato;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get modifica;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia ora'**
  String get iniziaOra;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi al piano'**
  String get aggiungiAlPiano;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Alla fine segna: {p0}'**
  String allaFineSegna(Object p0);

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Servono il nome e almeno un esercizio.'**
  String get servonoNomeAlmenoEsercizio;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La durata va da 0 a 300 minuti.'**
  String get durataVa0300;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nuovo allenamento'**
  String get nuovoAllenamento;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get salva;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get nome;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'es. 50-50, 7:3s 40%'**
  String get es50507;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get categoria;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dove'**
  String get dove;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = la calcolo dagli esercizi.'**
  String get vuotoCalcoloDagliEsercizi;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get descrizione;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cosa segnare alla fine'**
  String get cosaSegnareAllaFine;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'es. il grado medio delle due parti'**
  String get esGradoMedioDelle;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sposta su'**
  String get spostaSu;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Togli'**
  String get togli;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un esercizio'**
  String get aggiungiEsercizio;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Controlla: nome, serie 1-20, ripetizioni 1-100, secondi 0-3600.'**
  String get controllaNomeSerie1;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizio'**
  String get esercizio3;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'es. Sospensioni, Vie, Blocchi'**
  String get esSospensioniVieBlocchi;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Serie'**
  String get serie2;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni'**
  String get ripetizioni;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Lavoro'**
  String get lavoro;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Pausa'**
  String get pausa2;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tra le serie'**
  String get traSerie;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Lavoro vuoto = finché non hai finito (una via, un blocco): tocchi \"Fatto\". Pausa: tra una ripetizione e l\'altra.'**
  String get lavoroVuotoFincheNon;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Intensità o grado'**
  String get intensitaOGrado;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'es. 40%, 6b+, facile'**
  String get es406bFacile;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get note;

  /// screens/allenamenti_arrampicata_screen.dart
  ///
  /// In it, this message translates to:
  /// **'OK'**
  String get ok;

  /// screens/altra_attivita_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Che attività è?'**
  String get attivita2;

  /// screens/altra_attivita_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Il nome resta sulla sessione, nel calendario e nello storico.'**
  String get nomeRestaSullaSessione;

  /// screens/altra_attivita_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Es. Kayak, Padel, Sci'**
  String get esKayakPadelSci;

  /// screens/altra_attivita_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Registra il percorso GPS'**
  String get registraPercorsoGps;

  /// screens/altra_attivita_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Mappa, distanza e velocità, anche a schermo spento. Spento: solo tempo e battito.'**
  String get mappaDistanzaVelocitaAnche;

  /// screens/altra_attivita_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get inizia2;

  /// screens/altra_attivita_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get avanti;

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Dati e collegamenti'**
  String get datiCollegamenti;

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Collega l\'orologio o le app che usi (Garmin, Freeletics…) tramite Health Connect: gli allenamenti fatti arrivano da soli.'**
  String get collegaOrologioOApp;

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Le parole dell\'allenamento'**
  String get paroleDellAllenamento;

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Concetti'**
  String get concetti;

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Zone: come ti devi sentire'**
  String get zoneComeTiDevi;

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Zona {p0}'**
  String zona(Object p0);

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Tipi di seduta'**
  String get tipiSeduta;

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **' · prova {p0}'**
  String prova(Object p0);

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Avidididadi · versione {p0} ({p1}){p2}'**
  String avidididadiVersione(Object p0, Object p1, Object p2);

  /// screens/altre_pagine.dart
  ///
  /// In it, this message translates to:
  /// **'Avidididadi · versione {p0}'**
  String avidididadiVersioneBreve(Object p0);

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'La tua arrampicata'**
  String get tuaArrampicata;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Palestra'**
  String get palestra;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Falesia o zona'**
  String get falesiaOZona;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Facoltativo'**
  String get facoltativo;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Cosa hai fatto'**
  String get cosaHaiFatto;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli vie o boulder: i gradi hanno due scale diverse.'**
  String get scegliVieOBoulder;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Grado più difficile chiuso'**
  String get gradoPiuDifficileChiuso;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Nuovo record! Prima era {p0}.'**
  String nuovoRecordPrimaEra(Object p0);

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo record: {p0} ({p1} {p2} {p3}).'**
  String tuoRecord(Object p0, Object p1, Object p2, Object p3);

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Al primo tentativo, senza sapere niente prima.'**
  String get alPrimoTentativoSenza;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Al primo tentativo, sapendo già i movimenti.'**
  String get alPrimoTentativoSapendo;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Chiusa dopo averla provata più volte.'**
  String get chiusaDopoAverlaProvata;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Come l\'hai chiusa? (facoltativo)'**
  String get comeHaiChiusaFacoltativo;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Vie chiuse'**
  String get vieChiuse2;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Blocchi chiusi'**
  String get blocchiChiusi2;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Provat{p0} senza chiuderl{p1}'**
  String provatSenzaChiuderl(Object p0, Object p1);

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Altezza media delle vie (m)'**
  String get altezzaMediaDelleVie;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Circa {p0} metri saliti.'**
  String circaMetriSaliti(Object p0);

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Progetto (il grado che stai provando)'**
  String get progettoGradoStaiProvando;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuno'**
  String get nessuno;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Meno'**
  String get meno;

  /// screens/arrampicata_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Più'**
  String get piu;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Com\'è andata questa settimana?'**
  String get comAndataQuestaSettimana;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Giovedì ho poco tempo: cosa sposto?'**
  String get giovediHoPocoTempo;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Adatta i prossimi giorni al mio recupero'**
  String get adattaProssimiGiorniAl;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sono pronto per la gara?'**
  String get sonoProntoGara;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Collegato a {p0}'**
  String collegato2(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Impostazioni assistente'**
  String get impostazioniAssistente;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Chiedimi dei tuoi allenamenti: vedo le ultime 4 settimane, i feedback, il recupero e il piano dei prossimi 14 giorni. Se propongo di cambiare il piano, decidi tu se applicare.'**
  String get chiedimiDeiTuoiAllenamenti;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sto pensando…'**
  String get stoPensando;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi un messaggio'**
  String get scriviMessaggio;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Invia'**
  String get invia;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Un allenatore con cui parlare dei tuoi allenamenti, che può proporre modifiche al piano. Usi il modello che preferisci:'**
  String get allenatoreCuiParlareDei;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'È facoltativo: senza assistente l\'app funziona come sempre.'**
  String get facoltativoSenzaAssistenteApp;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Configura assistente'**
  String get configuraAssistente;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifiche proposte al piano'**
  String get modificheProposteAlPiano;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Applicate al piano.'**
  String get applicateAlPiano;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non applicabili'**
  String get nonApplicabili;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Niente da applicare: il piano è cambiato nel frattempo.'**
  String get nienteApplicarePianoCambiato;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Piano aggiornato: {p0} modifiche. Le vedi nel calendario.'**
  String pianoAggiornatoModificheVedi(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Applica {p0} modifiche'**
  String applicaModifiche(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun modello disponibile con questa chiave.'**
  String get nessunModelloDisponibileQuesta;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Consigliato'**
  String get consigliato;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il coach è nella sua app. Scollega dalla pagina Coach per tornare al servizio qui sotto.'**
  String get coachNellaSuaApp;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Usa il tuo abbonamento (Claude, ChatGPT, Gemini…)'**
  String get usaTuoAbbonamentoClaude;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Senza chiave API: parli con il coach nell\'app del tuo assistente.'**
  String get senzaChiaveApiParli;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Coach nell\'app (quando scolleghi)'**
  String get coachNellAppQuando;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Servizio'**
  String get servizio;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave API'**
  String get chiaveApi;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave salvata ••••{p0}'**
  String chiaveSalvata(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cifrata sul telefono.'**
  String get cifrataSulTelefono;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Incolla la chiave API'**
  String get incollaChiaveApi;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salva chiave'**
  String get salvaChiave;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Si paga a consumo sul tuo account: una domanda costa di solito pochi centesimi o meno. Puoi impostare un limite di spesa sul sito del servizio.'**
  String get siPagaConsumoSul;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Indirizzo di Ollama'**
  String get indirizzoOllama;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Indirizzo del PC'**
  String get indirizzoPc;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sul PC: installa Ollama, scarica un modello (ollama pull llama3.1) e avvialo con OLLAMA_HOST=0.0.0.0 così il telefono lo raggiunge. L\'indirizzo IP del PC lo trovi con \"ipconfig\".'**
  String get sulPcInstallaOllama;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modello'**
  String get modello;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nome del modello'**
  String get nomeModello;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = il più adatto tra quelli disponibili'**
  String get vuotoPiuAdattoTra;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli tra i modelli disponibili'**
  String get scegliTraModelliDisponibili;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dati inviati'**
  String get datiInviati;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nome e foto non vengono mai inviati.'**
  String get nomeFotoNonVengono;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Acconsento a inviare questi dati al mio PC con Ollama'**
  String get acconsentoInviareQuestiDati2;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Acconsento a inviare questi dati a {p0} a ogni messaggio'**
  String acconsentoInviareQuestiDati3(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} non raggiungibile'**
  String nonRaggiungibile(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Verifica di {p0}…'**
  String verifica(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prova connessione'**
  String get provaConnessione2;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Collegamento a {p0}…'**
  String collegamento(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get riprova;

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} non collegato'**
  String nonCollegato(Object p0);

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Togliere {p0}?'**
  String togliere(Object p0);

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le sedute future di {p0} escono dal calendario. Quelle già fatte restano nello storico.'**
  String seduteFutureEsconoDal(Object p0);

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le tue attività sono aggiornate.'**
  String get tueAttivitaSonoAggiornate;

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le mie attività'**
  String get mieAttivita;

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nel piano e nei menu vedi solo queste. Dal \"+\" puoi sempre fare anche altro, e tutto quello che fai resta nello storico.'**
  String get nelPianoNeiMenu;

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: quando?'**
  String quando(Object p0);

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli i giorni. L\'allenamento lo decidi tu, o lo chiedi all\'assistente: l\'app non ne scrive da sola.'**
  String get scegliGiorniAllenamentoDecidi;

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli i giorni: mettiamo le sedute nel calendario.'**
  String get scegliGiorniMettiamoSedute;

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quanto dura'**
  String get quantoDura;

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non ora'**
  String get nonOra;

  /// screens/attivita_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Metti nel calendario'**
  String get mettiNelCalendario;

  /// screens/attrezzatura_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi almeno un peso'**
  String get scriviAlmenoPeso;

  /// screens/attrezzatura_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Pesi disponibili'**
  String get pesiDisponibili;

  /// screens/attrezzatura_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun peso'**
  String get nessunPeso;

  /// screens/attrezzatura_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Letti: {p0}'**
  String letti(Object p0);

  /// screens/attrezzatura_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La mia attrezzatura'**
  String get miaAttrezzatura;

  /// screens/attrezzatura_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il corpo libero è sempre incluso. Con questa attrezzatura puoi fare {p0} esercizi su {p1}.'**
  String corpoLiberoSempreIncluso(Object p0, Object p1);

  /// screens/attrezzatura_screen.dart
  ///
  /// In it, this message translates to:
  /// **'In palestra'**
  String get palestra2;

  /// screens/attrezzatura_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Seleziona tutte'**
  String get selezionaTutte;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Salva il backup'**
  String get salvaBackup;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Backup salvato. Copialo anche fuori dal telefono (Drive, PC) per non perderlo.'**
  String get backupSalvatoCopialoAnche;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Backup non riuscito: {p0}'**
  String backupNonRiuscito(Object p0);

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Impossibile leggere il file: {p0}'**
  String impossibileLeggereFile(Object p0);

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Ripristinare il backup?'**
  String get ripristinareBackup;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}.\n\nTutti i dati attuali dell\'app verranno sostituiti. Se non sei sicuro, salva prima un backup di adesso.'**
  String tuttiDatiAttualiDell(Object p0);

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Ripristina'**
  String get ripristina;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Dati ripristinati. Alla prossima sincronizzazione Health Connect rilegge lo storico.'**
  String get datiRipristinatiAllaProssima;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Ripristino non riuscito: {p0}'**
  String ripristinoNonRiuscito(Object p0);

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Backup salvato nella cartella.'**
  String get backupSalvatoNellaCartella;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Backup automatico'**
  String get backupAutomatico;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'una cartella del telefono'**
  String get cartellaTelefono;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **' · ultimo {p0}'**
  String ultimo(Object p0);

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'In {p0}{p1}'**
  String inTesto(Object p0, Object p1);

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'In una cartella che scegli tu: resta anche se disinstalli l\'app. Tiene gli ultimi {p0}.'**
  String cartellaScegliTuResta(Object p0);

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni giorno'**
  String get ogniGiorno;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni settimana'**
  String get ogniSettimana;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Si fa da solo quando apri l\'app. Per non perderlo col telefono, ogni tanto copia la cartella sul PC o su Drive.'**
  String get siFaSoloQuando;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Fallo ora'**
  String get falloOra;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Cambia cartella'**
  String get cambiaCartella;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Backup'**
  String get backup;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Un unico file con sessioni, piano, profilo, misure, feedback, recupero e foto. La chiave dell\'assistente non è inclusa.'**
  String get unicoFileSessioniPiano;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Salva backup'**
  String get salvaBackup2;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Backup attivo: da ora si salva da solo ogni settimana.'**
  String get backupAttivoOraSi;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Metti al sicuro i tuoi allenamenti: l\'app ne salva da sola una copia in una cartella che scegli tu. Resta anche se disinstalli l\'app.'**
  String get mettiAlSicuroTuoi;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli di nuovo la cartella'**
  String get scegliNuovoCartella;

  /// screens/backup_card.dart
  ///
  /// In it, this message translates to:
  /// **'Attiva il backup'**
  String get attivaBackup;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Battito dal sensore'**
  String get battitoDalSensore;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Una fascia cardio o un orologio che trasmette il battito via Bluetooth. Lo vedi durante l\'allenamento; alla fine si salvano media e massimo.'**
  String get fasciaCardioOOrologio;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Garmin: sull\'orologio cerca \"Trasmetti frequenza cardiaca\" (di solito nei controlli, tenendo premuto il tasto della luce) e attivala: poi tocca \"Cerca\". Alcuni modelli vecchi la trasmettono solo in ANT+, che il telefono non legge.\nFascia cardio: indossala bagnando un po\' gli elettrodi, si accende da sola.\nUna volta scelto, il sensore si ricollega da solo a ogni allenamento.'**
  String get garminSullOrologioCerca;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Sensori della bici'**
  String get sensoriBici;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Rulli smart (Tacx, Wahoo, Elite…), misuratore di potenza o sensore di velocità e cadenza, via Bluetooth. Alla fine si salvano potenza e cadenza medie.'**
  String get rulliSmartTacxWahoo;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Rulli: accendili e smetti di usarli con altre app (Zwift, Tacx), perché molti si collegano a una sola app per volta.\nSensore di velocità o di cadenza: si sveglia girando la ruota o i pedali.\nLa circonferenza della ruota serve solo al sensore di velocità: la trovi scritta sul copertone (es. 700×25C = 2105 mm).'**
  String get rulliAccendiliSmettiUsarli;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Serve il permesso \"Dispositivi nelle vicinanze\".'**
  String get servePermessoDispositiviNelle;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Apri le impostazioni'**
  String get apriImpostazioni;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Il Bluetooth è spento: accendilo e riprova.'**
  String get bluetoothSpentoAccendiloRiprova;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Collegato · {p0}'**
  String collegato3(Object p0);

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Collegato, aspetto i dati…'**
  String get collegatoAspettoDati;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Mi collego… (dev\'essere acceso e vicino)'**
  String get miCollegoDevEssere;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Non collegato'**
  String get nonCollegato2;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Dimentica'**
  String get dimentica;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Cerco i sensori vicini…'**
  String get cercoSensoriVicini;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Sensori trovati'**
  String get sensoriTrovati;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun sensore trovato.'**
  String get nessunSensoreTrovato;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Cerca un altro sensore'**
  String get cercaAltroSensore;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Cerca di nuovo'**
  String get cercaNuovo;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Come si collega'**
  String get comeSiCollega;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Segnale forte'**
  String get segnaleForte;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Segnale medio'**
  String get segnaleMedio;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Segnale debole'**
  String get segnaleDebole;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **' Adesso: {p0} km/h.'**
  String adessoKmH(Object p0);

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Mai fatta da qui.'**
  String get maiFattaQui;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Ultima: {p0}.'**
  String ultima(Object p0);

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} Tiene precisi i watt: falla ogni due settimane circa e quando sposti il rullo, meglio dopo 10 minuti di pedalata.'**
  String tienePrecisiWattFalla(Object p0);

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Chiedo al rullo di iniziare…'**
  String get chiedoAlRulloIniziare;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Pedala e accelera finché il rullo non ti dice di smettere.{p0}'**
  String pedalaAcceleraFincheRullo(Object p0);

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Accelera fino a superare {p0} km/h.{p1}'**
  String acceleraFinoSuperareKm(Object p0, Object p1);

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Smetti di pedalare e aspetta che il rullo si fermi.{p0}'**
  String smettiPedalareAspettaRullo(Object p0);

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Calibrazione riuscita.'**
  String get calibrazioneRiuscita;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Non è riuscita. Controlla che nessun\'altra app usi il rullo e riprova.'**
  String get nonRiuscitaControllaNessun;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Calibra il rullo'**
  String get calibraRullo;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia la calibrazione'**
  String get iniziaCalibrazione;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Circonferenza della ruota'**
  String get circonferenzaRuota;

  /// screens/battito_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Solo per il sensore di velocità. 700×25C: 2105 mm.'**
  String get soloSensoreVelocita700;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo piano è pronto! La prima seduta è qui, in \"Oggi\". Giorni e durata li cambi quando vuoi dal Profilo.'**
  String get tuoPianoProntoPrima;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo piano è pronto! In \"Oggi\" trovi cosa fare ogni giorno.'**
  String get tuoPianoProntoOggi;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get indietro;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come ti chiami?'**
  String get comeTiChiami;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Così l\'app ti saluta per nome.'**
  String get cosiAppTiSaluta;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo nome'**
  String get tuoNome;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cosa ti piacerebbe fare?'**
  String get cosaTiPiacerebbeFare;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Puoi sceglierne più di uno. Con \"Inizia oggi\" parti con 3 sedute da 30 minuti a settimana (lunedì, mercoledì e venerdì), adatte a chi comincia, e la prima è già oggi. Potrai cambiare tutto quando vuoi.'**
  String get puoiScegliernePiuUno;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quanto tempo hai?'**
  String get quantoTempoHai;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Meglio poco ma con costanza: per iniziare 3 giorni da 30 minuti sono perfetti.'**
  String get meglioPocoMaCostanza;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Giorni a settimana'**
  String get giorniSettimana;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Minuti ogni volta'**
  String get minutiOgniVolta;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Con {p0} giorni non c\'è spazio per tutti gli sport scelti: ne userò {p1}.'**
  String giorniNonCSpazio(Object p0, Object p1);

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quanto ti alleni di solito?'**
  String get quantoTiAlleniSolito;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rispondi sinceramente: il piano parte dal tuo livello e cresce insieme a te.'**
  String get rispondiSinceramentePianoParte;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia oggi'**
  String get iniziaOggi;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prima scelgo giorni, durata e livello'**
  String get primaScelgoGiorniDurata;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Crea il mio piano'**
  String get creaMioPiano;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli almeno uno sport'**
  String get scegliAlmenoUnoSport;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Benvenuto!'**
  String get benvenuto;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ti preparo un piano di allenamento su misura, anche se non ti sei mai allenato. Ogni giorno ti dico cosa fare, passo passo, e il piano si adatta a come ti senti.'**
  String get tiPreparoPianoAllenamento;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli i tuoi sport e parti subito.'**
  String get scegliTuoiSportParti;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Iniziamo'**
  String get iniziamo;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salta, preferisco fare da solo'**
  String get saltaPreferiscoFareSolo;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Hai un orologio sportivo?'**
  String get haiOrologioSportivo;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Va bene anche senza: l\'app funziona con il solo telefono.'**
  String get vaBeneAncheSenza;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'No, solo il telefono'**
  String get noSoloTelefono;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Niente orologio, fascia cardio o altre app.'**
  String get nienteOrologioFasciaCardio;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sì, un orologio o una fascia'**
  String get siOrologioOFascia;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Garmin, Polar, Suunto, Coros, Wahoo…'**
  String get garminPolarSuuntoCoros;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa, camminata e bici le registra il telefono con il GPS, e ti guida a voce passo passo.'**
  String get corsaCamminataBiciRegistra;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le zone (per esempio \"zona 2\") seguile a sensazione: in zona 2 riesci ancora a parlare.'**
  String get zoneEsempioZona2;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dopo ogni seduta rispondi a \"Com\'è andata?\": è così che il piano capisce la fatica e si adatta.'**
  String get dopoOgniSedutaRispondi;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il nuoto, senza orologio, lo segni a mano dopo la vasca.'**
  String get nuotoSenzaOrologioSegni;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Energia e sonno restano vuoti: servono i dati di un orologio.'**
  String get energiaSonnoRestanoVuoti;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dopo collegalo da Profilo → Dati e collegamenti: con Health Connect, o con intervals.icu per Garmin e gli altri. Le attività arrivano da sole, con battito e sonno.'**
  String get dopoCollegaloProfiloDati;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Hai un rullo smart? Collegalo durante l\'allenamento: l\'app gli manda i watt di ogni passo.'**
  String get haiRulloSmartCollegalo;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ecco la tua settimana'**
  String get eccoTuaSettimana;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ecco la tua settimana, {p0}'**
  String eccoTuaSettimana2(Object p0);

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni giorno, nella pagina \"Oggi\", trovi cosa fare. Potrai cambiare giorni e orari quando vuoi.'**
  String get ogniGiornoNellaPagina;

  /// screens/benvenuto_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} · {p1} minuti'**
  String minuti(Object p0, Object p1);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cos\'hai fatto?'**
  String get cosHaiFatto;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Poi scrivi durata e tutto quello che ti ricordi.'**
  String get poiScriviDurataTutto;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ciao!'**
  String get ciao;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ciao {p0}'**
  String ciao2(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Chiudi il mese'**
  String get chiudiMese;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vedi tutto il mese'**
  String get vediTuttoMese;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prossimi'**
  String get prossimi;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo piano'**
  String get tuoPiano;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cambia gli allenamenti di oggi'**
  String get cambiaAllenamentiOggi;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cambia gli allenamenti di {p0}'**
  String cambiaAllenamenti(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sposta, aggiungi o togli: solo per quel giorno'**
  String get spostaAggiungiOTogli;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi un\'attività fatta oggi'**
  String get scriviAttivitaFattaOggi;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi un\'attività fatta {p0}'**
  String scriviAttivitaFatta(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per quello che non hai registrato: durata, distanza, battito…'**
  String get quelloNonHaiRegistrato;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La mia settimana tipo'**
  String get miaSettimanaTipo;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quali giorni ti alleni e per quanto tempo'**
  String get qualiGiorniTiAlleni;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allunga il calendario'**
  String get allungaCalendario;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ripete la settimana tipo nei prossimi mesi: decide i giorni, non gli esercizi'**
  String get ripeteSettimanaTipoNei;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mese prima'**
  String get mesePrima;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mese dopo'**
  String get meseDopo;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'da fare'**
  String get fare;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca un giorno per vederlo, tienilo premuto per cambiarlo.'**
  String get toccaGiornoVederloTienilo;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Buona'**
  String get buona;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Normale'**
  String get normale;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Bassa'**
  String get bassa;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Energia {p0}'**
  String energia(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La tua settimana'**
  String get tuaSettimana;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana dal {p0} {p1}'**
  String settimanaDal2(Object p0, Object p1);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **' di {p0} fatti'**
  String fatti(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana completata: {p0} allenamenti!'**
  String settimanaCompletataAllenamenti(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Torna a oggi'**
  String get tornaOggi;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Oggi sei poco recuperato: al posto della seduta prevista puoi fare 20 minuti di mobilità.'**
  String get oggiSeiPocoRecuperato;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vedi l\'allenamento'**
  String get vediAllenamento;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prima guarda gli esercizi'**
  String get primaGuardaEsercizi;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Giorno di riposo'**
  String get giornoRiposo;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quel giorno non risultano allenamenti.'**
  String get quelGiornoNonRisultano;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il riposo fa parte dell\'allenamento: i muscoli si rinforzano mentre recuperi.'**
  String get riposoFaParteDell;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se ti va: 15 minuti di mobilità'**
  String get seTiVa15;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Voglio allenarmi lo stesso'**
  String get voglioAllenarmiStesso;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'non fatto'**
  String get nonFatto;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica {p0}/10'**
  String fatica10(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Com\'è andata?'**
  String get comAndata;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rigenerare il piano?'**
  String get rigenerarePiano;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le sessioni dal {p0} in poi verranno sostituite. Quelle precedenti restano invariate.'**
  String sessioniDalPoiVerranno(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rigenera'**
  String get rigenera;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Piano generato'**
  String get pianoGenerato;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ripete la tua settimana tipo (quali sport, che giorni, quanti minuti) sui mesi che scegli. Gli esercizi di ogni seduta si preparano dal Profilo, con \"Prepara le sedute\".'**
  String get ripeteTuaSettimanaTipo;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Durata: {p0} {p1}'**
  String durata2(Object p0, Object p1);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Parti da {p0}'**
  String parti(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifica {p0}'**
  String modifica2(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cambia solo questo giorno: le altre settimane restano come sono.'**
  String get cambiaSoloQuestoGiorno;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuna attività in programma (giorno di riposo).'**
  String get nessunaAttivitaProgrammaGiorno;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}, {p1} min'**
  String min3(Object p0, Object p1);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rimuovi'**
  String get rimuovi;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi attività'**
  String get aggiungiAttivita;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Com\'è andata? Un voto alla fatica rende il piano più preciso.'**
  String get comAndataVotoAlla;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il calendario è vuoto: allungalo per sapere cosa fare ogni giorno.'**
  String get calendarioVuotoAllungaloSapere;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il calendario è finito il {p0}. Allungalo per i prossimi mesi.'**
  String calendarioFinitoAllungaloProssimi(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'tra {p0} giorni'**
  String traGiorni(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il calendario finisce {p0} ({p1}). Vuoi allungarlo?'**
  String calendarioFinisceVuoiAllungarlo(Object p0, Object p1);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allunga'**
  String get allunga;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Più tardi'**
  String get piuTardi;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La scheda di {p0}'**
  String scheda(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La scheda \"{p0}\"'**
  String scheda2(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} è finita il {p1}. Intanto le sedute sono quelle preparate dall\'app.'**
  String finitaIntantoSeduteSono(Object p0, Object p1);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rinnova per {p0} giorni'**
  String rinnovaGiorni(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cambiala'**
  String get cambiala;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Usa quella dell\'app'**
  String get usaQuellaDellApp;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cosa vuoi fare adesso?'**
  String get cosaVuoiFareAdesso;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Si aggiunge a quello che c\'è in programma oggi.'**
  String get siAggiungeQuelloC;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia un\'attività libera'**
  String get iniziaAttivitaLibera;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Catalogo esercizi'**
  String get catalogoEsercizi;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca un esercizio per vedere i muscoli che allena.'**
  String get toccaEsercizioVedereMuscoli;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cerca per nome o muscolo'**
  String get cercaNomeOMuscolo;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get tutti;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo con la mia attrezzatura'**
  String get soloMiaAttrezzatura;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun esercizio con questi filtri.'**
  String get nessunEsercizioQuestiFiltri;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Serve: {p0}'**
  String serve(Object p0);

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Immagini e istruzioni'**
  String get immaginiIstruzioni;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Principali: {p0}'**
  String principali(Object p0);

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Secondari: {p0}'**
  String secondari(Object p0);

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come si esegue'**
  String get comeSiEsegue;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Immagini da free-exercise-db ({p0}).'**
  String immaginiFreeExerciseDb(Object p0);

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Animazione creata con l\'intelligenza artificiale per Avidididadi.'**
  String get animazioneFattaConIa;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Immagine creata con l\'intelligenza artificiale per Avidididadi.'**
  String get immagineFattaConIa;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le tue serie'**
  String get tueSerie;

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Record: {p0} kg × {p1}'**
  String recordKg(Object p0, Object p1);

  /// screens/catalogo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Record: {p0} ripetizioni'**
  String recordRipetizioni(Object p0);

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get condividi;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La mappa non è pronta: riprova.'**
  String get mappaNonProntaRiprova;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Immagine non riuscita: riprova.'**
  String get immagineNonRiuscitaRiprova;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'L\'immagine si crea sul telefono e va solo all\'app che scegli (WhatsApp, Instagram…).'**
  String get immagineSiCreaSul;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Condividi la sessione'**
  String get condividiSessione;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Grafica'**
  String get grafica;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tipo di mappa'**
  String get tipoMappa;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La mappa fa vedere dove sei passato: occhio se parti da casa.'**
  String get mappaFaVedereDove;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli un\'altra foto'**
  String get scegliAltraFoto;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sposta e ingrandisci la foto con due dita. Resta sul telefono: nell\'immagine non va la posizione in cui è stata scattata.'**
  String get spostaIngrandisciFotoDue;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mostra il percorso'**
  String get mostraPercorso;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fa vedere la forma del giro: occhio se parti da casa.'**
  String get faVedereFormaGiro;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nuovo record: {p0}'**
  String nuovoRecord(Object p0);

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passo medio'**
  String get passoMedio;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Km più veloce'**
  String get kmPiuVeloce;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'m di salita'**
  String get mSalita;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'quota massima'**
  String get quotaMassima;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'PASSO OGNI 100 m'**
  String get passoOgni100M;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'100 più veloce'**
  String get n100PiuVeloce;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'grado più alto'**
  String get gradoPiuAlto;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'grado più alto · {p0}'**
  String gradoPiuAlto2(Object p0);

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La prima seduta: da qui si sale'**
  String get primaSedutaQuiSi;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il grado più alto delle ultime {p0} sedute'**
  String gradoPiuAltoDelle(Object p0);

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Progetto'**
  String get progetto2;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Condividi la settimana'**
  String get condividiSettimana;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana prima'**
  String get settimanaPrima;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Questa settimana'**
  String get questaSettimana;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana dopo'**
  String get settimanaDopo;

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana {p0}'**
  String settimana(Object p0);

  /// screens/condividi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuna sessione in questa settimana.'**
  String get nessunaSessioneQuestaSettimana;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizi scelti per te e la tua attrezzatura, con serie, ripetizioni e pesi. Finisce sempre con un po\' di mobilità.'**
  String get eserciziSceltiTeTua;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Corse facili, una seduta più intensa (fartlek, tempo, ripetute) e il lungo che cresce verso la gara.'**
  String get corseFaciliSedutaPiu;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tecnica e serie al tuo ritmo, alternate a quelle più intense.'**
  String get tecnicaSerieAlTuo;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Uscite facili, intervalli e uscita lunga.'**
  String get usciteFaciliIntervalliUscita;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Stretching e movimenti lenti, a tempo: ogni volta una zona del corpo diversa. Ottima anche per recuperare.'**
  String get stretchingMovimentiLentiTempo;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le sedute di {p0} restano nel calendario, ma senza esercizi preparati. Quelle già fatte non cambiano.'**
  String seduteRestanoNelCalendario(Object p0);

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sedute preparate tolte.'**
  String get sedutePreparateTolte;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Pronte {p0} sedute di {p1}. Le trovi in Oggi.'**
  String pronteSeduteTroviOggi(Object p0, Object p1);

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Forza: come la vuoi'**
  String get forzaComeVuoi;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Obiettivo'**
  String get obiettivo;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Livello'**
  String get livello;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non preoccuparti di sbagliare: il livello si adatta ai voti che dai a fine seduta.'**
  String get nonPreoccupartiSbagliareLivello;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Attrezzatura'**
  String get attrezzatura;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo corpo libero'**
  String get soloCorpoLibero;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: come crescere'**
  String comeCrescere(Object p0);

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Seduta lunga, e cosa fare se è facile'**
  String get sedutaLungaCosaFare;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Seduta lunga'**
  String get sedutaLunga;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'L\'ultima corsa o uscita in bici della settimana dura di più e cresce col tempo. Spenta, durano tutte quanto hai scelto.'**
  String get ultimaCorsaOUscita;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prepara le sedute'**
  String get preparaSedute;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli per quali sport vuoi che l\'app scriva gli allenamenti passo passo. Prepara solo quelli che spunti.'**
  String get scegliQualiSportVuoi;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per quali sport?'**
  String get qualiSport;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'già preparato'**
  String get giaPreparato;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} {p1} a settimana'**
  String settimana2(Object p0, Object p1);

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} {p1} in calendario'**
  String calendario(Object p0, Object p1);

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'nessuna seduta in calendario'**
  String get nessunaSedutaCalendario;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cambia giorni e minuti (settimana tipo)'**
  String get cambiaGiorniMinutiSettimana;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le tue preferenze'**
  String get tuePreferenze;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Senza una gara le sedute crescono a blocchi di 4 settimane, con una più leggera. Puoi fissare una gara dal Profilo, alla voce Il mio obiettivo.'**
  String get senzaGaraSeduteCrescono;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: le sedute cambiano con l\'avvicinarsi della gara.'**
  String seduteCambianoAvvicinarsiGara(Object p0);

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: nessun giorno nel calendario'**
  String nessunGiornoNelCalendario(Object p0);

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'È nella settimana tipo ma non ancora nel calendario. Apri la settimana tipo e tocca \"Porta tutta la settimana nel calendario\".'**
  String get nellaSettimanaTipoMa;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il calendario è vuoto'**
  String get calendarioVuoto;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prima allunga il calendario: poi le sedute si riempiono.'**
  String get primaAllungaCalendarioPoi;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le sedute si preparano fino a {p0}; quando allunghi il calendario si aggiungono da sole.'**
  String seduteSiPreparanoFino(Object p0);

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Togli le sedute preparate'**
  String get togliSedutePreparate;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiorna le sedute'**
  String get aggiornaSedute;

  /// screens/crea_piano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prepara {p0}'**
  String prepara(Object p0);

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Data di nascita'**
  String get dataNascita;

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Altezza in cm, tra 50 e 250'**
  String get altezzaCmTra50;

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Peso in kg, tra 20 e 300'**
  String get pesoKgTra20;

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dati personali'**
  String get datiPersonali;

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cognome'**
  String get cognome;

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca per sceglierla'**
  String get toccaSceglierla;

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Altezza'**
  String get altezza;

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Peso'**
  String get peso;

  /// screens/dati_personali_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Un peso nuovo si registra con la data di oggi.'**
  String get pesoNuovoSiRegistra;

  /// screens/energia.dart
  ///
  /// In it, this message translates to:
  /// **'Ok'**
  String get ok2;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **' Mancano {p0}.'**
  String mancano(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'In pausa.'**
  String get pausa3;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Si riparte.'**
  String get siRiparte;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **', {p0} chilometri'**
  String chilometri(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento completato. {p0}{p1}.'**
  String allenamentoCompletato(Object p0, Object p1);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Interrompere l\'allenamento?'**
  String get interrompereAllenamento;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Puoi terminarlo qui e vedere il riepilogo, oppure uscire senza salvare.'**
  String get puoiTerminarloQuiVedere;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get esci;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Termina qui'**
  String get terminaQui;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get continua;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Questo allenamento non ha passi.'**
  String get questoAllenamentoNonHa;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'tempo totale'**
  String get tempoTotale;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Bip e vibrazione'**
  String get bipVibrazione;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cadenza'**
  String get cadenza;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Poi'**
  String get poi;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizio precedente'**
  String get esercizioPrecedente;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia subito'**
  String get iniziaSubito;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salta recupero'**
  String get saltaRecupero;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get fatto;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'15 secondi in più'**
  String get n15SecondiPiu;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get salta;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Parti quando vuoi'**
  String get partiQuandoVuoi;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Preparati'**
  String get preparati;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} · {p1} esercizi'**
  String esercizi2(Object p0, Object p1);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Si parte con: {p0}'**
  String siParte(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Indoor ({p0})'**
  String indoor2(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Senza GPS: velocità e km arrivano dal rullo.'**
  String get senzaGpsVelocitaKm;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Senza GPS: alla fine scrivi i km del display.'**
  String get senzaGpsAllaFine;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Segui un percorso'**
  String get seguiPercorso;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Facoltativo: un GPX con mappa e indicazioni a voce'**
  String get facoltativoGpxMappaIndicazioni;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Togli il percorso'**
  String get togliPercorso;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rullo e sensori'**
  String get rulloSensori;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sensori bici'**
  String get sensoriBici2;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Collegato · è ora di calibrarlo'**
  String get collegatoOraCalibrarlo;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca per collegare'**
  String get toccaCollegare;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Battito'**
  String get battito;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento completato!'**
  String get allenamentoCompletato2;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'In movimento {p0} · totale {p1}'**
  String movimentoTotale(Object p0, Object p1);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Battito medio {p0} bpm · massimo {p1}'**
  String battitoMedioBpmMassimo(Object p0, Object p1);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Potenza media {p0} W'**
  String potenzaMediaW(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'cadenza {p0} rpm'**
  String cadenzaRpm(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cadenza media {p0} rpm'**
  String cadenzaMediaRpm(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Circa {p0} kcal'**
  String circaKcal(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Km {p0}'**
  String km(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Km del {p0}'**
  String km2(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Km percorsi'**
  String get kmPercorsi;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Facoltativo: senza, la sessione resta senza distanza.'**
  String get facoltativoSenzaSessioneResta;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Segna come fatto'**
  String get segnaComeFatto;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se l\'orologio registra lo stesso allenamento, vale il suo.'**
  String get seOrologioRegistraStesso;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inserisci i dati a mano'**
  String get inserisciDatiMano;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Segnale GPS buono · ±{p0} m'**
  String segnaleGpsBuonoM(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cerco il segnale GPS… meglio all\'aperto'**
  String get cercoSegnaleGpsMeglio;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'GPS non permesso: tocca per attivarlo'**
  String get gpsNonPermessoTocca;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Posizione spenta: tocca per accenderla'**
  String get posizioneSpentaToccaAccenderla;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dati'**
  String get dati;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimo km'**
  String get ultimoKm;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimi {p0} km'**
  String ultimiKm(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Velocità media'**
  String get velocitaMedia;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Potenza · Z{p0}'**
  String potenzaZ(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Battito · Z{p0}'**
  String battitoZ(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mi collego…'**
  String get miCollego;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Km {p0} · ultimi {p1} in {p2}'**
  String kmUltimi(Object p0, Object p1, Object p2);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mancano {p0} secondi'**
  String mancanoSecondi(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tempo trascorso'**
  String get tempoTrascorso;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'in pausa'**
  String get pausa4;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'poi passa da solo'**
  String get poiPassaSolo;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'tocca Fatto quando hai finito'**
  String get toccaFattoQuandoHai2;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Guarda il movimento di {p0}'**
  String guardaMovimento(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Kg'**
  String get kg3;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultima volta: {p0}'**
  String ultimaVolta(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Avevi fatto tutte le ripetizioni: prova un peso in più.'**
  String get aveviFattoTutteRipetizioni;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: meno'**
  String meno2(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: più'**
  String piu2(Object p0);

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'nessun peso'**
  String get nessunPeso2;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Pesi diversi dalla scheda'**
  String get pesiDiversiDallaScheda;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scritti nella scheda.'**
  String get scrittiNellaScheda;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiorna la scheda'**
  String get aggiornaScheda;

  /// screens/esecuzione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Segna vie, blocchi e gradi'**
  String get segnaVieBlocchiGradi;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'molto leggera'**
  String get moltoLeggera;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'molto dura'**
  String get moltoDura;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'al massimo'**
  String get alMassimo;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Feedback salvato'**
  String get feedbackSalvato2;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica: {p0}/10, {p1}'**
  String fatica102(Object p0, Object p1);

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Per il tuo obiettivo la fatica giusta è circa {p0}/10.'**
  String tuoObiettivoFaticaGiusta(Object p0);

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'come questa'**
  String get comeQuesta;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Per una seduta {p0} la fatica prevista è circa {p1}/10.'**
  String sedutaFaticaPrevistaCirca(Object p0, Object p1);

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Ho completato tutte le serie'**
  String get hoCompletatoTutteSerie;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Ho fatto tutta la seduta'**
  String get hoFattoTuttaSeduta;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Il passo nella parte principale (obiettivo {p0}:{p1}/100 m)'**
  String passoNellaPartePrincipale(Object p0, Object p1);

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Oppure il passo che hai tenuto (es. 2:45)'**
  String get oppurePassoHaiTenuto;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Ho sentito dolore o fastidio'**
  String get hoSentitoDoloreO;

  /// screens/feedback_sheet.dart
  ///
  /// In it, this message translates to:
  /// **'Note (facoltative)'**
  String get noteFacoltative;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Grafici · {p0}'**
  String grafici(Object p0);

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per questa attività non ci sono dati nel tempo: servono il battito o la velocità registrati dall\'orologio.'**
  String get questaAttivitaNonCi;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Altitudine'**
  String get altitudine;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Minima'**
  String get minima;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Massima'**
  String get massima;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Pendenza'**
  String get pendenza;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salita massima'**
  String get salitaMassima;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Discesa massima'**
  String get discesaMassima;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'FTP di corsa stimata da età e peso: per averla precisa fai il test in Profilo → Le mie zone.'**
  String get ftpCorsaStimataEta;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per le zone serve il tuo peso (Profilo), oppure l\'FTP di corsa in Profilo → Le mie zone.'**
  String get zoneServeTuoPeso;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passi al minuto'**
  String get passiAlMinuto;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Media'**
  String get media;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Bracciate al minuto'**
  String get bracciateAlMinuto;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'al minuto'**
  String get alMinuto;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tempo nelle zone'**
  String get tempoNelleZone;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Zone calcolate sulla tua FC massima ({p0} bpm).'**
  String zoneCalcolateSullaTua(Object p0);

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Migliore'**
  String get migliore;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La tua FTP di corsa: {p0} W'**
  String tuaFtpCorsaW(Object p0);

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'È il 95% dei tuoi migliori 20 minuti. Vale se in quei 20 minuti hai corso al massimo.'**
  String get n95DeiTuoiMigliori;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Usala come FTP di corsa'**
  String get usalaComeFtpCorsa;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Normalizzata'**
  String get normalizzata;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per le zone di potenza serve l\'FTP: scrivilo in Profilo → Zone, oppure impostalo su intervals.icu.'**
  String get zonePotenzaServeFtp;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tempo nelle zone di potenza'**
  String get tempoNelleZonePotenza;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Zone calcolate sul tuo FTP ({p0} W).'**
  String zoneCalcolateSulTuo(Object p0);

  /// screens/grafico_intensita.dart
  ///
  /// In it, this message translates to:
  /// **'Intensità prevista e tenuta in tutta la seduta'**
  String get intensitaPrevistaTenutaTutta;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}/{p1}/{p2} alle {p3}:{p4}'**
  String alle(Object p0, Object p1, Object p2, Object p3, Object p4);

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Controllo Health Connect…'**
  String get controlloHealthConnect;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect è installato ma va aggiornato.'**
  String get healthConnectInstallatoMa;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect non è installato. Serve per leggere gli allenamenti di Garmin e Freeletics.'**
  String get healthConnectNonInstallato2;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiorna Health Connect'**
  String get aggiornaHealthConnect;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Installa Health Connect'**
  String get installaHealthConnect;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Non collegato: manca il permesso per le sessioni.'**
  String get nonCollegatoMancaPermesso;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Permessi'**
  String get permessi;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Dati più vecchi di 30 giorni'**
  String get datiPiuVecchi30;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Mai sincronizzato.'**
  String get maiSincronizzato;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Ultima sincronizzazione: {p0}'**
  String ultimaSincronizzazione(Object p0);

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Sessioni da Health Connect: {p0}'**
  String sessioniHealthConnect(Object p0);

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Fonti trovate'**
  String get fontiTrovate;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: {p1} sessioni  ({p2})'**
  String sessioni(Object p0, Object p1, Object p2);

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Tipi di attività ignorati'**
  String get tipiAttivitaIgnorati;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Sincronizza ora'**
  String get sincronizzaOra;

  /// screens/health_connect_card.dart
  ///
  /// In it, this message translates to:
  /// **'Rivedi permessi'**
  String get rivediPermessi;

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Salva il modello'**
  String get salvaModello;

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Modello salvato. Compilalo (una riga per sessione) e importalo qui.'**
  String get modelloSalvatoCompilaloRiga;

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare il modello: {p0}'**
  String impossibileSalvareModello(Object p0);

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire la selezione dei file: {p0}'**
  String impossibileAprireSelezioneDei(Object p0);

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: file troppo grande (massimo 20 MB).'**
  String fileTroppoGrandeMassimo(Object p0);

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: impossibile leggere il file ({p1}).'**
  String impossibileLeggereFile2(Object p0, Object p1);

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Opzioni avanzate'**
  String get opzioniAvanzate;

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Import manuale da CSV, senza sincronizzazione'**
  String get importManualeCsvSenza;

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Se non usi app collegate a Health Connect puoi inserire le sessioni a mano: scarica il modello, compilalo con un foglio di calcolo (una riga per sessione) e importalo. I dati restano solo sul telefono.'**
  String get seNonUsiApp;

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Colonne: data (AAAA-MM-GG), sport (Corsa, Bici, Nuoto, Forza), tipo_sessione, durata_min, distanza_km, fc_media, rpe, fonte, note. Servono almeno data e sport.'**
  String get colonneDataAaaaMm;

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Scarica modello CSV'**
  String get scaricaModelloCsv;

  /// screens/import_csv.dart
  ///
  /// In it, this message translates to:
  /// **'Importa CSV'**
  String get importaCsv;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifica gli intervalli'**
  String get modificaIntervalli;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca un tratto per cambiare nome, metri o tempo, o per toglierlo. Tienilo premuto e trascinalo per spostarlo.'**
  String get toccaTrattoCambiareNome;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Senza nome'**
  String get senzaNome;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un tratto'**
  String get aggiungiTratto;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Torna a quelli dell\'orologio'**
  String get tornaQuelliDellOrologio;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi il tempo, es. 5:30 o 45'**
  String get scriviTempoEs5;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nuovo tratto'**
  String get nuovoTratto;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifica il tratto'**
  String get modificaTratto;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. Defaticamento'**
  String get esDefaticamento;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Metri'**
  String get metri;

  /// screens/intervalli_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Togli questo tratto'**
  String get togliQuestoTratto;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Scollegare intervals.icu?'**
  String get scollegareIntervalsIcu;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Le attività tornano quelle di Health Connect, con meno dettagli. La chiave viene cancellata dal telefono.'**
  String get attivitaTornanoQuelleHealth;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Attività complete da Garmin, Polar, Suunto, Coros, Wahoo, Zwift: nome vero, rulli, percorso, altitudine, potenza.'**
  String get attivitaCompleteGarminPolar;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione in corso…'**
  String get sincronizzazioneCorso;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Collegato.'**
  String get collegato4;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Collegato · ultima sincronizzazione {p0}, {p1}:{p2} · {p3} attività'**
  String collegatoUltimaSincronizzazioneAttivita(
    Object p0,
    Object p1,
    Object p2,
    Object p3,
  );

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Manda piano e sedute a intervals.icu'**
  String get mandaPianoSeduteIntervals;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa, bici e nuoto dei prossimi {p0} giorni, passo per passo: si aggiornano da soli quando il piano cambia. Le sedute registrate con l\'app partono da sole appena finite, con il percorso se c\'è.'**
  String corsaBiciNuotoDei(Object p0);

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Invio in corso…'**
  String get invioCorso;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Non ancora mandato.'**
  String get nonAncoraMandato;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimo invio {p0}, {p1}:{p2} · {p3} sedute in calendario'**
  String ultimoInvioSeduteCalendario(
    Object p0,
    Object p1,
    Object p2,
    Object p3,
  );

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Invia ora'**
  String get inviaOra;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Per averle sull\'orologio Garmin'**
  String get averleSullOrologioGarmin;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Su intervals.icu: Impostazioni → Garmin Connect → attiva \"Upload planned workouts\". Le sedute passano nel calendario di Garmin Connect e da lì all\'orologio. Battito: zone di intervals.icu; nuoto: passo per 100 m.'**
  String get suIntervalsIcuImpostazioni;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Crea un account gratuito su intervals.icu (dal browser).'**
  String get creaAccountGratuitoSu;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Lì, in Impostazioni, collega Garmin Connect (o il tuo orologio): le attività arrivano da sole.'**
  String get liImpostazioniCollegaGarmin;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Sempre in Impostazioni, in fondo, \"Developer settings\": crea la chiave API e copiala.'**
  String get sempreImpostazioniFondoDeveloper;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Incollala qui sotto e tocca Collega.'**
  String get incollalaQuiSottoTocca;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave API di intervals.icu'**
  String get chiaveApiIntervalsIcu;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Incolla dagli appunti'**
  String get incollaDagliAppunti;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'La chiave resta cifrata sul telefono. Serve a leggere le tue attività e, solo se lo accendi, a mandare il piano al tuo calendario.'**
  String get chiaveRestaCifrataSul;

  /// screens/intervals_card.dart
  ///
  /// In it, this message translates to:
  /// **'Collega'**
  String get collega2;

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Arrivo'**
  String get arrivo;

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Percorso completato'**
  String get percorsoCompletato;

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Cerco la posizione'**
  String get cercoPosizione;

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Il percorso è da questa parte: raggiungilo'**
  String get percorsoQuestaParteRaggiungilo;

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Fuori percorso: torna sulla traccia'**
  String get fuoriPercorsoTornaSulla;

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Dritto fino all\'arrivo'**
  String get drittoFinoAllArrivo;

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Percorso a {p0}'**
  String percorso(Object p0);

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Fuori percorso ({p0})'**
  String fuoriPercorso(Object p0);

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'Arrivo tra {p0}'**
  String arrivoTra(Object p0);

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Percorso non concesso. Puoi sempre permetterlo da Health Connect.'**
  String get percorsoNonConcessoPuoi;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'File troppo grande: un GPX di un allenamento pesa al massimo pochi MB.'**
  String get fileTroppoGrandeGpx;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Giorno diverso'**
  String get giornoDiverso;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Il file è di {p0}, la sessione di {p1}. Usarlo lo stesso?'**
  String fileSessioneUsarloStesso(Object p0, Object p1);

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Usalo'**
  String get usalo;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Percorso aggiunto: {p0}'**
  String percorsoAggiunto(Object p0);

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Questa sessione ha il percorso GPS'**
  String get questaSessioneHaPercorso;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect chiede il tuo permesso per mostrarlo. Per non doverlo dare ogni volta: Health Connect → Avidididadi → Percorsi di allenamento → Consenti sempre.'**
  String get healthConnectChiedeTuo;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Consenti sempre'**
  String get consentiSempre;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi GPX'**
  String get aggiungiGpx;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'L\'app che ha registrato la sessione'**
  String get appHaRegistratoSessione;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun percorso GPS'**
  String get nessunPercorsoGps;

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} non lo ha condiviso. Puoi aggiungerlo tu: su connect.garmin.com apri l\'attività, ingranaggio → Esporta in GPX, poi carica qui il file.'**
  String nonHaCondivisoPuoi(Object p0);

  /// screens/mappa_percorso.dart
  ///
  /// In it, this message translates to:
  /// **'Ritmo'**
  String get ritmo;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi quanti minuti è durata'**
  String get scriviQuantiMinutiDurata;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'In vasca'**
  String get vasca;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vasche'**
  String get vasche;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Lunghezza vasca'**
  String get lunghezzaVasca;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Metri totali'**
  String get metriTotali;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tempo medio'**
  String get tempoMedio;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'es. 1:55'**
  String get es155;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Stile'**
  String get stile;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifica la sessione'**
  String get modificaSessione;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Elimina la sessione'**
  String get eliminaSessione;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nome dell\'allenamento'**
  String get nomeDellAllenamento;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Indoor (rulli, Tacx)'**
  String get indoorRulliTacx;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Indoor (tapis roulant)'**
  String get indoorTapisRoulant;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Niente mappa né GPX'**
  String get nienteMappaNeGpx;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizio {p0}:{p1}'**
  String inizio(Object p0, Object p1);

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vie, blocchi e gradi'**
  String get vieBlocchiGradi;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizi, serie e kg'**
  String get eserciziSerieKg;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come è andata'**
  String get comeAndata;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Battito massimo'**
  String get battitoMassimo;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica'**
  String get fatica;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'su 10'**
  String get su10;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tutto quello che ti ricordi'**
  String get tuttoQuelloTiRicordi;

  /// screens/modifica_sessione_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Torna ai dati originali'**
  String get tornaAiDatiOriginali;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Data della gara'**
  String get dataGara;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi ore:minuti, es. 1:45'**
  String get scriviOreMinutiEs;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli la data della gara.'**
  String get scegliDataGara;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tempo obiettivo (facoltativo)'**
  String get tempoObiettivoFacoltativo;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'ore:minuti, es. 1:45'**
  String get oreMinutiEs1;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tra {p0} settimane'**
  String traSettimane(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fase attuale: {p0}. {p1}'**
  String faseAttuale(Object p0, Object p1);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le fasi avanzano da sole verso la gara: base, sviluppo, rifinitura e scarico.'**
  String get fasiAvanzanoSoleVerso;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rimuovi obiettivo'**
  String get rimuoviObiettivo;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Controlla i valori: FC max 120-230, FC riposo 30-100, passo m:ss, FTP 50-600 W.'**
  String get controllaValoriFcMax;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'15 minuti facili e 3 allunghi, poi 20 minuti al massimo che riesci a tenere, poi 10 minuti lentissimi. Circa 50 minuti.'**
  String get n15MinutiFacili3;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il telefono non misura i watt di corsa: registra la corsa anche con l\'orologio. Poi apri i grafici di quella corsa: lì trovi la tua FTP e il tasto per salvarla.'**
  String get telefonoNonMisuraWatt;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Test nel calendario: {p0}. Prende il posto della corsa di quel giorno.'**
  String testNelCalendarioPrende(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli oggi o un giorno dopo.'**
  String get scegliOggiOGiorno;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mettilo nel calendario'**
  String get mettiloNelCalendario;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Zone'**
  String get zone;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le tue zone di frequenza cardiaca'**
  String get tueZoneFrequenzaCardiaca;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Calcolate con la riserva cardiaca (FC max {p0}, a riposo {p1}).'**
  String calcolateRiservaCardiacaFc(Object p0, Object p1);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Calcolate come percentuale della FC max ({p0}). Con la FC a riposo diventano più precise.'**
  String calcolateComePercentualeFc(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'FC massima'**
  String get fcMassima;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = stima dai tuoi dati: {p0} bpm (la più alta dell\'ultimo anno, o dall\'età).'**
  String vuotoStimaDaiTuoi(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = quella misurata: {p0} bpm.'**
  String vuotoQuellaMisurataBpm(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Misurala appena sveglio, o lascia vuoto.'**
  String get misuralaAppenaSveglioO;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passo critico del nuoto'**
  String get passoCriticoNuoto;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'m:ss, es. 2:05'**
  String get mSsEs2;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = stima dalle sessioni in piscina (non ancora disponibile).'**
  String get vuotoStimaDalleSessioni;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = stima dalle sessioni in piscina: {p0}.'**
  String vuotoStimaDalleSessioni2(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le tue zone di potenza (bici)'**
  String get tueZonePotenzaBici;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Partono dall\'FTP, la potenza che riesci a tenere per circa un\'ora. Le sedute di bici ti danno il range di watt da tenere.'**
  String get partonoDallFtpPotenza;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'FTP'**
  String get ftp;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = quello di intervals.icu: {p0} W.'**
  String vuotoQuelloIntervalsIcu(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se non lo sai: pedala 20 minuti più forte che puoi, l\'FTP è circa il 95% della potenza media.'**
  String get seNonSaiPedala;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le tue zone di potenza (corsa)'**
  String get tueZonePotenzaCorsa;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'L\'FTP della bici non vale correndo: la corsa ha la sua. Serve ai grafici delle corse registrate con un orologio che misura i watt.'**
  String get ftpBiciNonVale;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'FTP di corsa'**
  String get ftpCorsa;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = stima da età e peso: {p0} W. È solo un punto di partenza.'**
  String vuotoStimaEtaPeso(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoto = stima da età e peso: scrivi il peso nel Profilo.'**
  String get vuotoStimaEtaPeso2;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fai il test per calcolarla'**
  String get faiTestCalcolarla;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Durante l\'allenamento'**
  String get duranteAllenamento;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Avvisi'**
  String get avvisi;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Voce'**
  String get voce;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dice l\'esercizio che inizia, i km e se sei fuori zona o fuori passo. Durante le chiamate sta zitta.'**
  String get diceEsercizioIniziaKm;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Bip'**
  String get bip;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Negli ultimi {p0} secondi di recuperi ed esercizi a tempo, e a ogni km (5 km in bici). Usa il volume dei media.'**
  String negliUltimiSecondiRecuperi(Object p0);

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vibrazione'**
  String get vibrazione;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Insieme ai bip.'**
  String get insiemeAiBip;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Pausa automatica'**
  String get pausaAutomatica;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa, bici e camminata: il tempo si ferma quando ti fermi e riparte da solo. Mai durante i recuperi.'**
  String get corsaBiciCamminataTempo;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Spenta'**
  String get spenta;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il tempo non si ferma mai da solo.'**
  String get tempoNonSiFerma;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo quando sei fermo'**
  String get soloQuandoSeiFermo;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Al semaforo o a una sosta. Se vai piano, anche in salita, il tempo continua.'**
  String get alSemaforoOSosta;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sotto i {p0} km/h'**
  String sottoKmH(Object p0);

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come certe app: attento, se vai più piano di così il tempo si ferma.'**
  String get comeCerteAppAttento;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Camminata tranquilla 4-5 km/h, corsa lenta 8-10, bici in salita anche 6-8.'**
  String get camminataTranquilla45;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo in movimento'**
  String get soloMovimento;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le soste non contano, anche con la pausa automatica spenta: è il passo con cui ti sei mosso.'**
  String get sosteNonContanoAnche;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Con le soste'**
  String get soste;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Distanza diviso tutto il tempo, soste comprese.'**
  String get distanzaDivisoTuttoTempo;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Alla fine il riepilogo mostra comunque tutti e due i tempi: in movimento e totale.'**
  String get allaFineRiepilogoMostra;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa, camminata e bici all\'aperto: dove sta la mappa che segue la tua posizione (e il percorso, se ne segui uno).'**
  String get corsaCamminataBiciAll;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scorri di lato: in una timer e dati, nell\'altra la mappa grande.'**
  String get scorriLatoTimerDati;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Una mappa piccola sempre in vista, sopra il timer.'**
  String get mappaPiccolaSempreVista;

  /// screens/opzioni_allenamento_screen.dart
  ///
  /// In it, this message translates to:
  /// **'La mappa occupa tutto, con tempo e dati sopra.'**
  String get mappaOccupaTuttoTempo;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'File troppo grande: un GPX pesa al massimo pochi MB.'**
  String get fileTroppoGrandeGpx2;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiunto: {p0} · {p1}'**
  String aggiunto(Object p0, Object p1);

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} m di salita'**
  String mSalita2(Object p0);

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli il percorso'**
  String get scegliPercorso;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I miei percorsi'**
  String get mieiPercorsi;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun percorso'**
  String get nessunPercorso;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi il file GPX di una gara, di un giro famoso o di un amico. Durante corsa, camminata o bici l\'app ti mostra dove sei sulla mappa e ti dice a voce dove girare.'**
  String get aggiungiFileGpxGara;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dove trovo un GPX?'**
  String get doveTrovoGpx;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'• Sito della gara: spesso c\'è \"Scarica la traccia GPX\".\n• Strava, Komoot, Garmin Connect: apri un percorso o un\'attività → Esporta GPX.\n• Un amico: può mandarti il GPX della sua attività.\nPoi qui: Aggiungi GPX e scegli il file.'**
  String get sitoGaraSpessoC;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Anche senza rete'**
  String get ancheSenzaRete;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vedi il percorso'**
  String get vediPercorso;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nome del percorso'**
  String get nomePercorso;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Eliminare il percorso?'**
  String get eliminarePercorso;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'\"{p0}\" sparisce dalla raccolta e dalle sedute a cui era assegnato. Gli allenamenti già fatti restano.'**
  String sparisceDallaRaccoltaDalle(Object p0);

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Usa questo percorso'**
  String get usaQuestoPercorso;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get rinomina;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'File del percorso mancante.'**
  String get filePercorsoMancante;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Curve'**
  String get curve;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Altimetria'**
  String get altimetria;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Giro ad anello: si parte e si arriva nello stesso punto.'**
  String get giroAdAnelloSi;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Partenza al pallino verde, arrivo all\'altro capo.'**
  String get partenzaAlPallinoVerde;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per seguirlo: prima di partire con corsa, camminata o bici tocca \"Segui un percorso\", oppure assegnalo prima a una seduta in programma.'**
  String get seguirloPrimaPartireCorsa;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} m · min {p1} m'**
  String mMinM(Object p0, Object p1);

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Percorso da seguire'**
  String get percorsoSeguire;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli'**
  String get scegli;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cambia'**
  String get cambia;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scarico la mappa… {p0}%'**
  String scaricoMappa(Object p0);

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Puoi usare l\'app intanto.'**
  String get puoiUsareAppIntanto;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mappa scaricata'**
  String get mappaScaricata;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Strade e percorso si vedono anche senza rete (non il satellite).'**
  String get stradePercorsoSiVedono;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mappa senza rete'**
  String get mappaSenzaRete;

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scarica la zona attorno al percorso ({p0}), per vederla anche dove il telefono non prende.'**
  String scaricaZonaAttornoAl(Object p0);

  /// screens/percorsi_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scarica'**
  String get scarica;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimo aggiornamento: {p0}'**
  String ultimoAggiornamento(Object p0);

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'In breve: i tuoi dati restano sul telefono. L\'app non ha server, account né pubblicità e non vende né condivide i tuoi dati. Escono dal telefono solo nei casi descritti qui sotto, quasi tutti scelti da te.'**
  String get breveTuoiDatiRestano;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dati che inserisci tu'**
  String get datiInserisciTu;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nome, data di nascita, sesso, altezza, peso e misure, foto del profilo, obiettivo e gara, settimana tipo, attrezzatura, feedback dopo gli allenamenti (fatica, completata, dolore), ripetizioni e kg delle serie di forza, vie, blocchi, gradi e allenamenti dell\'arrampicata, vasche, tempi e altri dati delle sedute scritti a mano, schede scritte a mano e sessioni importate da file CSV. Servono a preparare il piano e a mostrare i progressi.'**
  String get nomeDataNascitaSesso;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dati letti da Health Connect (solo lettura)'**
  String get datiLettiHealthConnect;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Con il tuo permesso l\'app legge da Health Connect le sessioni di allenamento (tipo, titolo, inizio e fine) e, nel tempo di ogni sessione, frequenza cardiaca, distanza, calorie, passi e velocità. Legge anche FC a riposo, variabilità cardiaca (HRV) e sonno per valutare il recupero, e lo storico oltre i 30 giorni se lo concedi. Sono i dati scritti da Garmin Connect, Freeletics e dalle altre app collegate a Health Connect. L\'app non scrive, non modifica e non cancella nulla in Health Connect.'**
  String get tuoPermessoAppLegge;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Percorsi GPS delle sessioni'**
  String get percorsiGpsDelleSessioni;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se l\'app che ha registrato una corsa o un\'uscita in bici ha salvato anche il percorso in Health Connect, Avidididadi lo legge solo con il tuo permesso: per la singola sessione (te lo chiede Health Connect) oppure per tutte, se scegli \"Consenti sempre\" nelle impostazioni di Health Connect. Puoi anche aggiungere tu un percorso caricando un file GPX (per esempio esportato da Garmin Connect). Una copia del percorso resta nell\'app per mostrare la mappa. I percorsi da seguire che aggiungi a \"I miei percorsi\" (file GPX di gare, giri, amici) restano solo sul telefono e nel backup; non vanno all\'assistente.'**
  String get seAppHaRegistrato;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Posizione durante l\'allenamento'**
  String get posizioneDuranteAllenamento;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo per corsa, camminata e bici (e per un\'altra attività se scegli tu di registrare il percorso), e solo mentre la modalità allenamento è aperta, l\'app usa la posizione precisa (GPS e servizio di posizione di Google Play sul telefono) per registrare percorso, distanza e ritmo. Mentre registra mostra una notifica fissa e continua anche a schermo spento; quando chiudi l\'allenamento il GPS si spegne. L\'app non usa la posizione in nessun altro momento e non la raccoglie in background. Il percorso viene salvato solo sul telefono: non va in Health Connect, non va all\'assistente e non viene inviato a nessuno, a meno che sia tu ad accendere l\'invio a intervals.icu o a salvarlo in un file GPX. Mentre ti alleni, una copia della seduta in corso (percorso compreso) resta sul telefono per riprenderla se l\'app si chiude; si cancella quando finisci.'**
  String get soloCorsaCamminataBici;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sensori Bluetooth (battito e bici)'**
  String get sensoriBluetoothBattitoBici;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo se lo scegli tu, durante la modalità allenamento o dalla pagina \"I miei sensori\" del Profilo, l\'app si collega via Bluetooth a una fascia cardio, a un orologio che trasmette il battito o ai sensori della bici (rulli, potenza, velocità e cadenza), per mostrarteli mentre ti alleni. Chiusa quella pagina o finito l\'allenamento, si scollega. Alla fine della seduta salva nella sessione battito medio e massimo, potenza e cadenza medie e, per i grafici, un valore al secondo di battito, potenza, cadenza e velocità: tutto sul telefono. Nome e indirizzo Bluetooth dei sensori (e la circonferenza della ruota) restano sul telefono per ricollegarsi la volta dopo: li cancelli con \"Dimentica\". Il permesso \"Dispositivi nelle vicinanze\" serve solo a trovare il sensore, non a sapere dove sei.'**
  String get soloSeScegliTu;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mappe'**
  String get mappe;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per disegnare la mappa l\'app scarica i riquadri della zona mostrata: da OpenFreeMap (tiles.openfreemap.org, dati © OpenStreetMap) per le mappe Pulse e Strade, e da Esri (server.arcgisonline.com) solo se scegli la vista Satellite. Come per qualsiasi sito, quei servizi ricevono l\'indirizzo IP del telefono e quali riquadri vengono chiesti, quindi possono capire quale zona stai guardando. Il percorso, i tempi e gli altri dati dell\'allenamento non vengono inviati: la linea viene disegnata sul telefono. Per i percorsi da seguire l\'app scarica in anticipo i riquadri della fascia attorno alla traccia, per vederli senza rete: OpenFreeMap riceve quei riquadri, e quindi la zona del percorso. Restano nella memoria dell\'app finché non togli la mappa o il percorso.'**
  String get disegnareMappaAppScarica;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'intervals.icu (facoltativo)'**
  String get intervalsIcuFacoltativo;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se colleghi intervals.icu con la tua chiave API, l\'app scarica da lì le tue attività di corsa, bici e nuoto (nome, orari, distanza, battito, velocità, altitudine, potenza, percorso GPS) e il tuo FTP di bici e corsa, per le zone di potenza. intervals.icu le riceve dal tuo orologio (Garmin, Polar, Suunto…) perché lo hai collegato tu, con le sue condizioni sulla privacy. La chiave resta cifrata sul telefono. Solo se accendi \"Manda piano e sedute a intervals.icu\", l\'app scrive nel tuo calendario di intervals.icu le sedute di corsa, bici e nuoto dei prossimi 14 giorni (data, sport, nome, durata, passi con zone di battito, potenza o passo): niente nome, foto, misure, feedback o forza. Spegnendolo, le sedute future mandate dall\'app vengono tolte. Con questo invio acceso, ogni sessione che registri con l\'app (forza compresa) va da sola sul tuo account appena finita; spento, solo se tocchi \"Invia a intervals.icu\" su quella sessione. Partono orario, sport, nome, durata, distanza, battito medio e massimo e, se c\'è, il percorso GPS. Allo stesso modo \"Salva GPX\" crea un file col percorso dove scegli tu. Le attività scaricate restano sul telefono ed entrano nel backup; scollegando, vengono tolte.'**
  String get seColleghiIntervalsIcu;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Immagini degli esercizi'**
  String get immaginiDegliEsercizi;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le foto degli esercizi vengono scaricate, quando servono, dalla raccolta pubblica free-exercise-db su GitHub. GitHub riceve l\'indirizzo IP del telefono e quale immagine viene chiesta, nient\'altro.'**
  String get fotoDegliEserciziVengono;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Assistente (facoltativo)'**
  String get assistenteFacoltativo2;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo se lo attivi tu, l\'assistente invia un riassunto dei tuoi allenamenti (sessioni delle ultime 4 settimane, feedback, recupero, zone di battito e FTP della bici, piano dei prossimi 14 giorni, serie di forza delle ultime 6 settimane, attrezzatura e schede di forza) al servizio che scegli: Anthropic, OpenAI, Google oppure Ollama sul tuo PC. Nome, foto e percorsi GPS non vengono mai inviati; età, sesso e peso solo se lo permetti. Prima di attivarlo puoi vedere esattamente cosa viene inviato. La chiave API resta cifrata sul telefono. Per i servizi online valgono le loro condizioni sulla privacy e gli eventuali costi del tuo abbonamento.'**
  String get soloSeAttiviTu;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Assistente nella tua app (facoltativo)'**
  String get assistenteNellaTuaApp;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se colleghi l\'app del tuo assistente (Claude, ChatGPT, Gemini o altre), Avidididadi prepara un messaggio con lo stesso riassunto descritto sopra e lo passa a quell\'app solo quando tocchi Condividi o Copia. Da quel momento i dati sono nella chat del servizio scelto e valgono le sue regole: con un abbonamento normale le chat possono servire ad addestrare il modello, secondo le impostazioni del tuo account. Le risposte che condividi o incolli nell\'app vengono lette solo se contengono il codice del tuo collegamento, e le modifiche al piano si applicano solo dopo la tua conferma. Finché non lo colleghi, Avidididadi non riceve testo da altre app; quando lo scolleghi, il codice smette di valere.'**
  String get seColleghiAppTuo;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Widget sulla schermata home'**
  String get widgetSullaSchermataHome;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se aggiungi il widget, la seduta di oggi e la settimana sono visibili sulla schermata home, quindi anche a chi vede il telefono sbloccato.'**
  String get seAggiungiWidgetSeduta;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dove restano i dati'**
  String get doveRestanoDati;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nella cartella privata dell\'app sul telefono, a cui le altre app non possono accedere. Non finiscono nel backup automatico di Android su Google né nel trasferimento a un nuovo telefono: per spostarli usa il backup dell\'app.'**
  String get nellaCartellaPrivataDell;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il file di backup che crei contiene tutti i dati dell\'app, compresi dati sulla salute, foto e percorsi GPS (non la chiave API). Lo salvi dove scegli tu: tienilo in un posto sicuro e non condividerlo. Se accendi il backup automatico, l\'app scrive lo stesso file da sola nella cartella che hai scelto e tiene gli ultimi 5; le altre app che leggono quella cartella possono vederlo.'**
  String get fileBackupCreiContiene;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Permessi del telefono'**
  String get permessiTelefono;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect (lettura dei dati elencati sopra), posizione precisa (solo durante corsa, camminata e bici), dispositivi nelle vicinanze (solo per il sensore del battito), attività fisica (solo per i passi in corsa e camminata), internet (mappe, immagini, assistente, aggiornamenti), installazione di app (solo per gli aggiornamenti dell\'app, che confermi ogni volta), notifiche (solo quella dell\'allenamento in corso, con tempo e dati, visibile anche a schermo bloccato). Puoi negare ognuno di questi permessi: l\'app continua a funzionare senza la parte che ne ha bisogno.'**
  String get healthConnectLetturaDei;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come revocare o cancellare'**
  String get comeRevocareOCancellare;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Health Connect: Impostazioni di Health Connect → Permessi delle app → Avidididadi, oppure dal Profilo con \"Rivedi permessi\". Posizione, dispositivi nelle vicinanze e attività fisica: Impostazioni di Android → App → Avidididadi → Permessi. Sensore del battito: \"Dimentica\" nel foglio del battito, durante l\'allenamento. Assistente: disattivalo e cancella la chiave nella pagina Coach. Per cancellare tutto: Impostazioni di Android → App → Avidididadi → Memoria → Cancella dati, oppure disinstalla l\'app. I dati in Health Connect restano lì, perché sono delle app che li hanno scritti.'**
  String get healthConnectImpostazioniHealth;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifiche'**
  String get modifiche;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se questa informativa cambia, all\'apertura l\'app te lo dice e ti chiede di accettarla di nuovo.'**
  String get seQuestaInformativaCambia;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cos\'è Avidididadi'**
  String get cosAvidididadi;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Un\'app personale per pianificare e seguire allenamenti di forza, corsa, nuoto, bici e mobilità, e per vedere storico e progressi. Usandola accetti questi termini e l\'informativa sulla privacy.'**
  String get appPersonalePianificareSeguire;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Piani, carichi, zone di frequenza cardiaca, valutazione del recupero e risposte dell\'assistente sono stime automatiche a scopo informativo. Non sono una diagnosi né un parere medico e non sostituiscono medico, fisioterapista o allenatore. Prima di iniziare un programma di allenamento, soprattutto se hai problemi di salute, sei in gravidanza o non ti alleni da tempo, chiedi a un medico. Se senti dolore, vertigini, fiato corto anomalo o dolore al petto, fermati e cerca assistenza.'**
  String get pianiCarichiZoneFrequenza;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allenati in sicurezza'**
  String get allenatiSicurezza;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ti alleni sotto la tua responsabilità: scegli carichi e ritmi adatti a te, usa attrezzatura in buono stato e rispetta il codice della strada. Durante corsa, camminata e bici non guardare il telefono mentre ti muovi nel traffico.'**
  String get tiAlleniSottoTua;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Precisione dei dati'**
  String get precisioneDeiDati;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'GPS, distanze, ritmo, passi e i dati letti da Health Connect possono contenere errori (per esempio tra palazzi alti o sotto gli alberi). Calcoli e grafici dipendono da questi dati e dalla loro completezza.'**
  String get gpsDistanzeRitmoPassi;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Servizi di terzi'**
  String get serviziTerzi;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Alcune funzioni usano servizi di altri: Health Connect e le app che vi scrivono (es. Garmin Connect), OpenFreeMap e OpenStreetMap per le mappe, GitHub per le immagini degli esercizi e gli aggiornamenti dell\'app e, se lo attivi, il servizio di intelligenza artificiale che scegli. Questi servizi hanno condizioni proprie, possono cambiare o non essere disponibili. Chiave API e costi del servizio di intelligenza artificiale sono a tuo carico.'**
  String get alcuneFunzioniUsanoServizi;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I tuoi dati'**
  String get tuoiDati;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I dati restano sul tuo telefono e ne sei responsabile tu: fai backup periodici e conserva il file in un posto sicuro. Disinstallando l\'app senza backup i dati vanno persi.'**
  String get datiRestanoSulTuo;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuna garanzia'**
  String get nessunaGaranzia;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'L\'app è fornita così com\'è, senza garanzie di funzionamento continuo o privo di errori. Nei limiti consentiti dalla legge, chi l\'ha sviluppata non risponde di danni derivanti dall\'uso dell\'app, da dati non corretti o dalla perdita di dati.'**
  String get appFornitaCosiCom;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Questi termini possono essere aggiornati. Se cambiano, all\'apertura l\'app te lo dice e ti chiede di accettarli di nuovo prima di continuare.'**
  String get questiTerminiPossonoEssere;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare la foto: {p0}'**
  String impossibileCaricareFoto(Object p0);

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli dalla galleria'**
  String get scegliDallaGalleria;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scatta una foto'**
  String get scattaFoto;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rimuovi foto'**
  String get rimuoviFoto;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Si registra con la data di oggi. Lascia vuoto per cancellare.'**
  String get siRegistraDataOggi;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} ({p1} anni)'**
  String anni(Object p0, Object p1);

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo profilo'**
  String get tuoProfilo;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inserisci i tuoi dati'**
  String get inserisciTuoiDati;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifica i tuoi dati'**
  String get modificaTuoiDati;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il mio allenamento'**
  String get mioAllenamento;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il mio obiettivo'**
  String get mioObiettivo;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuna gara: ti alleni per stare in forma'**
  String get nessunaGaraTiAlleni;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli gli sport: l\'app scrive gli allenamenti passo passo'**
  String get scegliSportAppScrive;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Forza: {p0}'**
  String forza(Object p0);

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le mie schede'**
  String get mieSchede;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le schede del personal trainer o dell\'allenatore'**
  String get schedePersonalTrainerO;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'In corso: {p0}'**
  String corso(Object p0);

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come si fanno, con immagini e muscoli usati'**
  String get comeSiFannoImmagini;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le mie zone'**
  String get mieZone;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quanto spingere: battiti al minuto e watt in bici'**
  String get quantoSpingereBattitiAl;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il mio corpo'**
  String get mioCorpo;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca una misura per inserirla: vedrai come cambi nel tempo.'**
  String get toccaMisuraInserirlaVedrai;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimo aggiornamento: {p0}. Tocca una misura per aggiornarla.'**
  String ultimoAggiornamentoToccaMisura(Object p0);

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Impostazioni e aiuto'**
  String get impostazioniAiuto;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tema scuro'**
  String get temaScuro;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fondo grafite oppure bianco'**
  String get fondoGrafiteOppureBianco;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Versione neon'**
  String get versioneNeon;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rosa, verde acqua e azzurro al posto del rosso'**
  String get rosaVerdeAcquaAzzurro;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I miei sensori'**
  String get mieiSensori;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fascia cardio, rullo e sensori della bici'**
  String get fasciaCardioRulloSensori;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Funzioni avanzate'**
  String get funzioniAvanzate;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Zone, watt, sensori Bluetooth, rullo e intervals.icu'**
  String get zoneWattSensoriBluetooth;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Voce, bip, pausa automatica e passo medio'**
  String get voceBipPausaAutomatica;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I tuoi allenamenti: creali, falli o mettili nel piano'**
  String get tuoiAllenamentiCrealiFalli;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'GPX da seguire con mappa e indicazioni a voce'**
  String get gpxSeguireMappaIndicazioni;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Orologio e app, backup dei dati'**
  String get orologioAppBackupDei;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Giro guidato dell\'app'**
  String get giroGuidatoDellApp;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le 10 funzioni principali, una alla volta'**
  String get n10FunzioniPrincipaliAlla;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Zone, carico, fartlek… spiegati semplici'**
  String get zoneCaricoFartlekSpiegati;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Configurazione guidata'**
  String get configurazioneGuidata;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rifai il piano rispondendo a poche domande'**
  String get rifaiPianoRispondendoPoche;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rifare la configurazione?'**
  String get rifareConfigurazione;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana tipo e piano da oggi in poi verranno sostituiti. Gli allenamenti già fatti e le misure restano.'**
  String get settimanaTipoPianoOggi;

  /// screens/profile_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inserisci un numero valido'**
  String get inserisciNumeroValido;

  /// screens/profilo_allenamento.dart
  ///
  /// In it, this message translates to:
  /// **'Diagramma dell\'allenamento'**
  String get diagrammaDellAllenamento;

  /// screens/profilo_allenamento.dart
  ///
  /// In it, this message translates to:
  /// **'Watt previsti e tenuti in tutta la seduta'**
  String get wattPrevistiTenutiTutta;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'1 mese'**
  String get n1Mese;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'3 mesi'**
  String get n3Mesi;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'6 mesi'**
  String get n6Mesi;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'1 anno'**
  String get n1Anno;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Qui vedrai come vanno i tuoi allenamenti. Collega l\'orologio o le app di allenamento dal Profilo (Dati e collegamenti), oppure segna le sedute fatte.'**
  String get quiVedraiComeVanno;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quanto ti alleni'**
  String get quantoTiAlleni;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'al mese'**
  String get alMese;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'a settimana'**
  String get settimana3;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica {p0}'**
  String fatica2(Object p0);

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ore {p0}'**
  String ore(Object p0);

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Durata per fatica: conta anche quanto è stata dura.'**
  String get durataFaticaContaAnche;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento in questo periodo.'**
  String get nessunAllenamentoQuestoPeriodo;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca una colonna per i dettagli.'**
  String get toccaColonnaDettagli;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I tuoi sport'**
  String get tuoiSport;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca uno sport per vedere tutto il dettaglio.'**
  String get toccaUnoSportVedere;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Stai rallentando'**
  String get staiRallentando;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Stai andando bene'**
  String get staiAndandoBene;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Stai accelerando'**
  String get staiAccelerando;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Troppo, troppo in fretta'**
  String get troppoTroppoFretta;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ti alleni meno delle settimane scorse. Va bene se è voluto (riposo, impegni); altrimenti riprendi con calma.'**
  String get tiAlleniMenoDelle;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aumenti poco alla volta, come si deve: così migliori senza farti male.'**
  String get aumentiPocoAllaVolta;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Stai facendo parecchio più del solito. Ascolta le sensazioni e non aggiungere altro questa settimana.'**
  String get staiFacendoParecchioPiu;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Hai aumentato molto in poco tempo: è così che arrivano gli infortuni. Fai qualche giorno più leggero.'**
  String get haiAumentatoMoltoPoco;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Buono'**
  String get buono;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Basso'**
  String get basso;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ti sto conoscendo'**
  String get tiStoConoscendo;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dopo 3 settimane di allenamenti ti dirò se stai aumentando nel modo giusto.'**
  String get dopo3SettimaneAllenamenti;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come lo calcolo'**
  String get comeCalcolo;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rispetto alla media delle ultime 4 settimane: {p0} (bene tra 0,8 e 1,3).'**
  String rispettoAllaMediaDelle(Object p0);

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimi 7 giorni: {p0} punti (minuti × fatica). {p1}'**
  String ultimi7GiorniPunti(Object p0, Object p1);

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'sett. scorsa'**
  String get settScorsa;

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Saltati: {p0}'**
  String saltati(Object p0);

  /// screens/riepilogo_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Com\'è andata'**
  String get comAndata2;

  /// screens/riepilogo_bici.dart
  ///
  /// In it, this message translates to:
  /// **'I tuoi watt in tutta la seduta (media ogni 10 secondi).'**
  String get tuoiWattTuttaSeduta;

  /// screens/riepilogo_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Le barre colorate sono il programma: i watt da tenere blocco per blocco. La linea sono i watt che hai tenuto (media ogni 10 secondi); quella tratteggiata è la tua FTP.'**
  String get barreColorateSonoProgramma;

  /// screens/riepilogo_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Le barre colorate sono i watt medi di ogni blocco. La linea sono i watt che hai tenuto (media ogni 10 secondi); quella tratteggiata è la tua FTP.'**
  String get barreColorateSonoWatt;

  /// screens/riepilogo_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Una barra per blocco, larga quanto è durato: alta e colorata secondo i watt da tenere; il trattino sono i watt medi che hai tenuto. La linea è la tua FTP.'**
  String get barraBloccoLargaQuanto;

  /// screens/riepilogo_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Una barra per blocco: larga quanto è durato, alta e colorata secondo i watt medi. La linea è la tua FTP.'**
  String get barraBloccoLargaQuanto2;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento nuovo'**
  String get allenamentoNuovo;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} allenamenti nuovi'**
  String allenamentiNuovi(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **' · {p0} min'**
  String min4(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Prende il posto della seduta di {p0} di quel giorno.'**
  String prendePostoSedutaQuel(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Uno è in un giorno passato: non si mette.'**
  String get unoGiornoPassatoNon;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} sono in giorni passati: non si mettono.'**
  String sonoGiorniPassatiNon(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Messo nel calendario.'**
  String get messoNelCalendario;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Niente da mettere: le date sono passate.'**
  String get nienteMettereDateSono;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento messo nel calendario.'**
  String get allenamentoMessoNelCalendario;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} allenamenti messi nel calendario.'**
  String allenamentiMessiNelCalendario(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Piano nuovo da {p0}'**
  String pianoNuovo(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Applicato: lo trovi nel calendario.'**
  String get applicatoTroviNelCalendario;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} sedute in {p1} settimane. Sostituisce il calendario da quel giorno in poi.'**
  String seduteSettimaneSostituisceCalendario(Object p0, Object p1);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana del {p0}/{p1}: {p2}'**
  String settimana5(Object p0, Object p1, Object p2);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'…e le altre settimane.'**
  String get altreSettimane;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Non applicabile'**
  String get nonApplicabile;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi al coach di correggerlo.'**
  String get scriviAlCoachCorreggerlo;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Copiato: incollalo in {p0} per correggere.'**
  String copiatoIncollaloCorreggere(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Copia i problemi per {p0}'**
  String copiaProblemi(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Il piano non è più applicabile: riprova.'**
  String get pianoNonPiuApplicabile;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Piano applicato: {p0} sedute nel calendario.'**
  String pianoApplicatoSeduteNel(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Applica il piano'**
  String get applicaPiano;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento di arrampicata'**
  String get allenamentoArrampicata;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} allenamenti di arrampicata'**
  String allenamentiArrampicata2(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'nella raccolta'**
  String get nellaRaccolta;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'nel calendario {p0}'**
  String nelCalendario2(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Le date passate non vanno nel calendario, ma l\'allenamento si salva lo stesso.'**
  String get datePassateNonVanno;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Salvato.'**
  String get salvato;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Salvato negli allenamenti di arrampicata.'**
  String get salvatoNegliAllenamentiArrampicata;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} salvati negli allenamenti di arrampicata.'**
  String salvatiNegliAllenamentiArrampicata(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Uno è nel calendario.'**
  String get unoNelCalendario;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} sono nel calendario.'**
  String sonoNelCalendario(Object p0);

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Salva e metti nel calendario'**
  String get salvaMettiNelCalendario;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizi, serie, ripetizioni e kg'**
  String get eserciziSerieRipetizioniKg;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passi a tempo o distanza, con zona o passo'**
  String get passiTempoODistanza;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passi a tempo o distanza, con zona'**
  String get passiTempoODistanza2;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vasche, passo per 100 m e pause'**
  String get vaschePasso100M;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scheda di {p0}'**
  String scheda3(Object p0);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi la scheda del tuo personal trainer o del tuo allenatore: forza, corsa, bici o nuoto. Nei giorni che scegli prende il posto delle sedute preparate dall\'app, che non la cambia da sola.'**
  String get scriviSchedaTuoPersonal;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nuova scheda'**
  String get nuovaScheda;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'In corso'**
  String get corso2;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Finite'**
  String get finite;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Archiviata'**
  String get archiviata;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dal {p0}, senza scadenza'**
  String dalSenzaScadenza(Object p0);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dal {p0} al {p1}'**
  String dalAl(Object p0, Object p1);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Giorno'**
  String get giorno2;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi almeno un esercizio.'**
  String get aggiungiAlmenoEsercizio;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi almeno un passo.'**
  String get aggiungiAlmenoPasso;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana tipo aggiornata.'**
  String get settimanaTipoAggiornata;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} nella settimana tipo'**
  String nellaSettimanaTipo(Object p0);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungo: {p0}.'**
  String aggiungo(Object p0);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} è un giorno di riposo: non tolgo niente.'**
  String giornoRiposoNonTolgo(Object p0);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per fargli posto tolgo da questo giorno:'**
  String get fargliPostoTolgoQuesto;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Oppure puoi tenerle e fare tutte e due le cose.'**
  String get oppurePuoiTenerleFare;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tieni entrambe'**
  String get tieniEntrambe;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get aggiungi;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sostituisci'**
  String get sostituisci;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Eliminare la scheda?'**
  String get eliminareScheda;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le sedute già fatte restano. Da oggi tornano quelle preparate dall\'app.'**
  String get seduteGiaFatteRestano;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Uscire senza salvare?'**
  String get uscireSenzaSalvare;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Resta'**
  String get resta;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scheda'**
  String get scheda4;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nome della scheda'**
  String get nomeScheda;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. Scheda di novembre'**
  String get esSchedaNovembre;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Finché non la cambio'**
  String get fincheNonCambio;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizio'**
  String get inizio2;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Giorni'**
  String get giorni;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni giorno della scheda (Busto, Gambe…) va nei giorni della settimana che scegli. Valgono quelli con la forza nella settimana tipo.'**
  String get ogniGiornoSchedaBusto;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni seduta della scheda (Ripetute, Lungo…) va nei giorni della settimana che scegli. Valgono quelli con {p0} nella settimana tipo.'**
  String ogniSedutaSchedaRipetute(Object p0);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: nella settimana tipo non c\'è {p1}.'**
  String nellaSettimanaTipoNon(Object p0, Object p1);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Modifica settimana'**
  String get modificaSettimana;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un giorno'**
  String get aggiungiGiorno;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi una seduta'**
  String get aggiungiSeduta;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salva la scheda'**
  String get salvaScheda;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nome del giorno'**
  String get nomeGiorno;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. Busto'**
  String get esBusto;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Togli questo giorno'**
  String get togliQuestoGiorno;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun esercizio.'**
  String get nessunEsercizio;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun passo.'**
  String get nessunPasso;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sposta giù'**
  String get spostaGiu;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi esercizio'**
  String get aggiungiEsercizio2;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un passo'**
  String get aggiungiPasso;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Una serie in meno'**
  String get serieMeno;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Una serie in più'**
  String get seriePiu;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 10, 8-10, oppure 30 s per gli esercizi a tempo'**
  String get es10810;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero (secondi)'**
  String get recuperoSecondi;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Un peso per tutte le serie (20), oppure uno per serie (20 22,5 25). Vuoto a corpo libero.'**
  String get pesoTutteSerie20;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Note del personal trainer'**
  String get notePersonalTrainer;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. scendi in 3 secondi'**
  String get esScendi3Secondi;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizio non in catalogo'**
  String get esercizioNonCatalogo;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli un esercizio'**
  String get scegliEsercizio;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cerca (es. lat, panca, squat)'**
  String get cercaEsLatPanca;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non c\'è? Scrivilo a mano'**
  String get nonCScriviloMano;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Principale'**
  String get principale;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Defaticamento'**
  String get defaticamento;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passo di {p0}'**
  String passo2(Object p0);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cosa fare'**
  String get cosaFare;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. Stile libero, gambe con tavoletta'**
  String get esStileLiberoGambe;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. Corsa facile, ripetute, salita'**
  String get esCorsaFacileRipetute;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quante volte'**
  String get quanteVolte;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Una in meno'**
  String get meno3;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Una in più'**
  String get piu3;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'A tempo'**
  String get tempo2;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'A distanza'**
  String get distanza2;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Minuti'**
  String get minuti2;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 400'**
  String get es400;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 10, oppure 1,5'**
  String get es10Oppure1;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Obiettivo principale'**
  String get obiettivoPrincipale;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Libera'**
  String get libera;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Watt'**
  String get watt;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 1:50/100 m'**
  String get es150100;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 5:00/km'**
  String get es500Km;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 200, oppure 190-210, oppure 88-94%'**
  String get es200Oppure190;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Obiettivo secondario (facoltativo)'**
  String get obiettivoSecondarioFacoltativo;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 85-90 rpm'**
  String get es8590Rpm;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 170-180 ppm'**
  String get es170180Ppm;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Es. 40 bracciate al minuto'**
  String get es40BracciateAl;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Pausa a bordo vasca dopo ogni ripetizione'**
  String get pausaBordoVascaDopo;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tra una ripetizione e l\'altra; vuoto se non c\'è'**
  String get traRipetizioneAltraVuoto;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi i metri.'**
  String get scriviMetri;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi i minuti.'**
  String get scriviMinuti;

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi i watt: per esempio 200, 190-210 o 88-94%.'**
  String get scriviWattEsempio200;

  /// screens/sensori_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sensore collegato: ho acceso le funzioni avanzate.'**
  String get sensoreCollegatoHoAcceso;

  /// screens/sensori_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ricordato: {p0}'**
  String ricordato(Object p0);

  /// screens/sensori_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Collega qui i sensori Bluetooth: li scegli una volta sola, poi si ricollegano da soli a ogni allenamento.'**
  String get collegaQuiSensoriBluetooth;

  /// screens/sensori_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fascia cardio o orologio che trasmette il battito'**
  String get fasciaCardioOOrologio2;

  /// screens/sensori_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rullo smart, potenza, velocità e cadenza'**
  String get rulloSmartPotenzaVelocita;

  /// screens/sensori_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il Bluetooth si usa solo mentre questa pagina o l\'allenamento sono aperti.'**
  String get bluetoothSiUsaSolo;

  /// screens/serie_a_mano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Togli l\'esercizio'**
  String get togliEsercizio;

  /// screens/serie_a_mano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni e kg'**
  String get ripetizioniKg;

  /// screens/serie_a_mano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Secondi'**
  String get secondi;

  /// screens/serie_a_mano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Togli la serie'**
  String get togliSerie;

  /// screens/serie_a_mano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Esercizi e serie'**
  String get eserciziSerie;

  /// screens/serie_a_mano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Forza · {p0}'**
  String forza2(Object p0);

  /// screens/serie_a_mano_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scrivi cosa hai fatto: ripetizioni e kg di ogni serie (kg vuoto = corpo libero), oppure il tempo per plank e tenute. Restano nello storico dell\'esercizio.'**
  String get scriviCosaHaiFatto;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'distanza totale'**
  String get distanzaTotale;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'passo medio (min/km)'**
  String get passoMedioMinKm;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'corsa più lunga'**
  String get corsaPiuLunga;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'passo migliore (≥ 3 km)'**
  String get passoMigliore3Km;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'FC media'**
  String get fcMedia;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Km a settimana'**
  String get kmSettimana;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passo per uscita (min/km)'**
  String get passoUscitaMinKm;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Distanza per uscita (km)'**
  String get distanzaUscitaKm;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Efficienza aerobica (metri per battito)'**
  String get efficienzaAerobicaMetriBattito;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'FC media per uscita (bpm)'**
  String get fcMediaUscitaBpm;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'passo medio (min/100 m)'**
  String get passoMedioMin100;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'sessione più lunga'**
  String get sessionePiuLunga;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'passo migliore (≥ 300 m)'**
  String get passoMigliore300M;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Metri a settimana'**
  String get metriSettimana;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passo per sessione (min/100 m)'**
  String get passoSessioneMin100;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Metri per sessione'**
  String get metriSessione;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'FC media per sessione (bpm)'**
  String get fcMediaSessioneBpm;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'velocità media (km/h)'**
  String get velocitaMediaKmH;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'uscita più lunga'**
  String get uscitaPiuLunga;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'velocità massima media'**
  String get velocitaMassimaMedia;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Velocità media per uscita (km/h)'**
  String get velocitaMediaUscitaKm;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'durata media'**
  String get durataMedia;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'sessioni a settimana'**
  String get sessioniSettimana;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sessioni a settimana'**
  String get sessioniSettimana2;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Minuti a settimana'**
  String get minutiSettimana;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Durata per sessione (min)'**
  String get durataSessioneMin;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'vie e blocchi chiusi'**
  String get vieBlocchiChiusi;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'metri saliti'**
  String get metriSaliti;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'via più difficile'**
  String get viaPiuDifficile;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'blocco più difficile'**
  String get bloccoPiuDifficile;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Vie e blocchi chiusi a settimana'**
  String get vieBlocchiChiusiSettimana;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Grado più difficile: vie'**
  String get gradoPiuDifficileVie;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Grado più difficile: blocchi'**
  String get gradoPiuDifficileBlocchi;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tipi di sessione'**
  String get tipiSessione;

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'FC {p0} bpm'**
  String fcBpm(Object p0);

  /// screens/sport_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} {p1}\nSettimana dal {p2}{p3}'**
  String settimanaDal3(Object p0, Object p1, Object p2, Object p3);

  /// screens/storico_misure_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Storico di peso e misure'**
  String get storicoPesoMisure;

  /// screens/storico_misure_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Storico misure'**
  String get storicoMisure;

  /// screens/storico_misure_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessun valore di {p0} ancora inserito.'**
  String nessunValoreAncoraInserito(Object p0);

  /// screens/storico_misure_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Con almeno due valori comparirà il grafico.'**
  String get almenoDueValoriComparira;

  /// screens/storico_misure_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dal {p0}'**
  String dal(Object p0);

  /// screens/storico_misure_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: invariato'**
  String invariato(Object p0);

  /// screens/storico_misure_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Valori inseriti'**
  String get valoriInseriti;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'La barra in basso'**
  String get barraBasso;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Quattro sezioni: Oggi, Progressi, Coach e Profilo. Puoi anche scorrere di lato per passare dall\'una all\'altra.'**
  String get quattroSezioniOggiProgressi;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'La seduta del giorno'**
  String get sedutaGiorno;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Qui trovi cosa fare oggi. Tocca la seduta per vedere i dettagli e ▶ per l\'allenamento guidato passo passo, con timer, bip e GPS.'**
  String get quiTroviCosaFare;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'L\'energia'**
  String get energia2;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Com\'è il tuo recupero oggi, da sonno, battito a riposo e HRV. Toccala per i dettagli: se è bassa, meglio una seduta leggera.'**
  String get comTuoRecuperoOggi;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Comparirà in alto a destra quando l\'orologio manda sonno e battito a riposo (Profilo → Dati e collegamenti).'**
  String get compariraAltoDestraQuando;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Un cerchio per giorno: pieno se fatto, col bordo se da fare. Tocca un giorno per vederlo sopra; scorri di lato sui cerchi per la settimana prima o dopo.'**
  String get cerchioGiornoPienoSe;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'La settimana tipo'**
  String get settimanaTipo;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Quali giorni ti alleni, quale sport e per quanto tempo. Da qui nasce tutto il calendario: cambiala quando cambiano i tuoi impegni.'**
  String get qualiGiorniTiAlleni2;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Dopo ogni allenamento dai un voto alla fatica: le sedute dopo si adattano, più facili o più impegnative.'**
  String get dopoOgniAllenamentoDai;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Quando un allenamento fatto non ha ancora un voto, qui in Oggi compare \"Com\'è andata?\". Puoi darlo anche toccando la seduta fatta.'**
  String get quandoAllenamentoFattoNon;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Il carico di allenamento, i grafici e i resoconti di ogni sport: tocca uno sport per i dettagli.'**
  String get caricoAllenamentoGraficiResoconti;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'L\'assistente: chiedigli consigli sul piano o su come ti senti. Lo colleghi dalle impostazioni in alto (sul tuo PC o con la tua app).'**
  String get assistenteChiedigliConsigliSul;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Sedute e schede'**
  String get seduteSchede;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'\"Prepara le sedute\": l\'app scrive gli allenamenti per te. \"Le mie schede\": scrivi quelli del tuo personal trainer o allenatore.'**
  String get preparaSeduteAppScrive;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Collega l\'orologio (Health Connect o intervals.icu) e fai il backup dei tuoi dati. Il giro lo ritrovi sempre qui sotto, in \"Giro guidato dell\'app\".'**
  String get collegaOrologioHealthConnect;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Tocca Avanti per continuare.'**
  String get toccaAvantiContinuare;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Fine'**
  String get fine;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Vuoi un giro guidato dell\'app? Dieci passi, un minuto.'**
  String get vuoiGiroGuidatoDell;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'No, grazie'**
  String get noGrazie;

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'Sì'**
  String get si;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimo blocco'**
  String get ultimoBlocco;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Poi: {p0}'**
  String poi2(Object p0);

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'di recupero'**
  String get recupero2;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'a fine blocco'**
  String get fineBlocco;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Collega il rullo o il misuratore: vedrai potenza, cadenza e velocità.'**
  String get collegaRulloOMisuratore;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Media {p0} W · Massimo {p1} W'**
  String mediaWMassimoW(Object p0, Object p1);

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Blocco {p0} di {p1}'**
  String blocco(Object p0, Object p1);

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Si parte'**
  String get siParte2;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Fine tra {p0}'**
  String fineTra(Object p0);

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Rullo in ERG'**
  String get rulloErg;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Rullo libero'**
  String get rulloLibero;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'senza obiettivo'**
  String get senzaObiettivo2;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'tiene {p0} W'**
  String tieneW(Object p0);

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'i watt li decidi tu'**
  String get wattLiDecidiTu;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'5% in meno'**
  String get n5Meno;

  /// screens/vista_bici.dart
  ///
  /// In it, this message translates to:
  /// **'5% in più'**
  String get n5Piu;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Riportare la settimana nel calendario?'**
  String get riportareSettimanaNelCalendario;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I giorni da oggi in poi diventano uguali alla settimana tipo: le modifiche fatte a mano su quei giorni vengono sostituite. I giorni già fatti restano.'**
  String get giorniOggiPoiDiventano;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Riporta'**
  String get riporta;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana salvata. Il calendario è vuoto: allungalo da Oggi.'**
  String get settimanaSalvataCalendarioVuoto;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana salvata.'**
  String get settimanaSalvata;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Calendario aggiornato: {p0} {p1} da oggi al {p2}.'**
  String calendarioAggiornatoOggiAl(Object p0, Object p1, Object p2);

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Settimana tipo'**
  String get settimanaTipo2;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli cosa fai e in quale giorno. I cambi valgono subito nel calendario, da oggi in poi; i giorni già fatti non cambiano.'**
  String get scegliCosaFaiQuale;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Porta tutta la settimana nel calendario'**
  String get portaTuttaSettimanaNel;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rifà i giorni da oggi in poi uguali alla settimana tipo. Utile se il calendario non corrisponde più.'**
  String get rifaGiorniOggiPoi;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiungi sessione'**
  String get aggiungiSessione;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nessuna sessione'**
  String get nessunaSessione;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sport'**
  String get sport;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fascia'**
  String get fascia;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Tipo di sessione (facoltativo)'**
  String get tipoSessioneFacoltativo;

  /// screens/week_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Durata (minuti)'**
  String get durataMinuti;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Hai fatto un allenamento diverso da quello in programma: il feedback vale per quello che hai fatto davvero.'**
  String get haiFattoAllenamentoDiverso;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo feedback regola le prossime sessioni.'**
  String get tuoFeedbackRegolaProssime;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Serve a calcolare il carico di allenamento.'**
  String get serveCalcolareCaricoAllenamento;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Completata'**
  String get completata;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non completata'**
  String get nonCompletata;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'dolore segnalato'**
  String get doloreSegnalato;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rispondi'**
  String get rispondi;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'L\'ho già fatta: scrivi i dati'**
  String get hoGiaFattaScrivi;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ti guido esercizio per esercizio: tocchi \"Fatto\" quando finisci, i recuperi e le parti a tempo li conto io.'**
  String get tiGuidoEsercizioEsercizio;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento previsto: {p0}'**
  String allenamentoPrevisto(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Durata totale: {p0} min'**
  String durataTotaleMin(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come ti devi sentire: {p0}'**
  String comeTiDeviSentire(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia allenamento'**
  String get iniziaAllenamento;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Muscoli della sessione: {p0}. Tocca un esercizio per vedere i suoi, la freccia per come si fa.'**
  String muscoliSessioneToccaEsercizio(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cos\'è: {p0}'**
  String cos(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Seduta di arrampicata'**
  String get sedutaArrampicata;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli uno dei tuoi allenamenti o chiedilo all\'assistente. Puoi anche partire e segnare vie e gradi alla fine.'**
  String get scegliUnoDeiTuoi;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Inizia la seduta'**
  String get iniziaSeduta;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Scegli un allenamento'**
  String get scegliAllenamento;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Questa seduta non ha ancora esercizi'**
  String get questaSedutaNonHa;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Seduta libera'**
  String get sedutaLibera;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fai preparare all\'app la forza: sceglie gli esercizi adatti a te e alla tua attrezzatura. Ci vuole un minuto.'**
  String get faiPreparareAllApp;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fai preparare all\'app le sedute di {p0}: ognuna con le sue indicazioni passo passo.'**
  String faiPreparareAllApp2(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'il tempo che hai'**
  String get tempoHai;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Muoviti per {p0} a ritmo facile: devi riuscire a parlare.'**
  String muovitiRitmoFacileDevi(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prepara le sedute di {p0}'**
  String preparaSedute2(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Invio a intervals.icu…'**
  String get invioIntervalsIcu;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Per questa sessione l\'app non ha un percorso GPS.'**
  String get questaSessioneAppNon;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salva il percorso'**
  String get salvaPercorso;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'GPX salvato: puoi caricarlo su Strava o Garmin Connect.'**
  String get gpxSalvatoPuoiCaricarlo;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'GPX non salvato: {p0}'**
  String gpxNonSalvato(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Eliminare la sessione?'**
  String get eliminareSessione;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **' Non tornerà con la sincronizzazione; nell\'app dell\'orologio resta com\'è.'**
  String get nonTorneraSincronizzazioneNell;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sparisce dal calendario, dai Progressi e dal carico, insieme al suo \"Com\'è andata?\".{p0}'**
  String sparisceDalCalendarioDai(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Sessione eliminata'**
  String get sessioneEliminata;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Orario'**
  String get orario;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} da {p1} m'**
  String m(Object p0, Object p1);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ritmo medio'**
  String get ritmoMedio;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Calorie attive (stima)'**
  String get calorieAttiveStima;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Calorie totali (stima)'**
  String get calorieTotaliStima;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Potenza media'**
  String get potenzaMedia;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cadenza media'**
  String get cadenzaMedia;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fatica (RPE)'**
  String get faticaRpe;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fonte: {p0} · corretta a mano'**
  String fonteCorrettaMano(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fonte: {p0}'**
  String fonte(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'sulle vie'**
  String get sulleVie;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'nel boulder'**
  String get nelBoulder;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Record {p0}: {p1} ({p2} {p3} {p4})'**
  String record2(Object p0, Object p1, Object p2, Object p3, Object p4);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Grafici'**
  String get grafici2;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Invia a intervals.icu'**
  String get inviaIntervalsIcu;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salva GPX'**
  String get salvaGpx;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Su intervals.icu'**
  String get suIntervalsIcu;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Parte da sola per intervals.icu appena c\'è rete'**
  String get parteSolaIntervalsIcu;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Previsto e fatto'**
  String get previstoFatto;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le fasce colorate sono l\'intensità da tenere blocco per blocco, la linea quella che hai tenuto: dentro la fascia eri nell\'obiettivo, sopra andavi più forte, sotto più piano.{p0}'**
  String fasceColorateSonoIntensita(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **' Dove l\'obiettivo era una zona si guarda il battito, dove era un passo si guarda il passo.'**
  String get doveObiettivoEraZona;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **' Si guarda il passo.'**
  String get siGuardaPasso;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **' Si guarda il battito.'**
  String get siGuardaBattito;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Da tenere {p0}'**
  String tenere(Object p0);

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fuori programma'**
  String get fuoriProgramma;

  /// screens/workout_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Intervalli (corretti a mano)'**
  String get intervalliCorrettiMano;

  /// sensori_bici.dart
  ///
  /// In it, this message translates to:
  /// **'Sensore bici'**
  String get sensoreBici;

  /// serie_sessione.dart
  ///
  /// In it, this message translates to:
  /// **'Altitudine e pendenza'**
  String get altitudinePendenza;

  /// serie_sessione.dart
  ///
  /// In it, this message translates to:
  /// **'Altitudine, pendenza e potenza'**
  String get altitudinePendenzaPotenza;

  /// serie_sessione.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} non ci sono: per averle collega intervals.icu (Profilo → Dati e collegamenti).'**
  String nonCiSonoAverle(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} chilometri all\'ora'**
  String chilometriAllOra(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} minuti al chilometro'**
  String minutiAlChilometro(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} e {p1} al chilometro'**
  String alChilometro(Object p0, Object p1);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'Chilometro {p0}. {p1}.'**
  String chilometro(Object p0, Object p1);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'Chilometro {p0}. Ultimi {p1} in {p2}, {p3}.'**
  String chilometroUltimi(Object p0, Object p1, Object p2, Object p3);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **' più'**
  String get piu4;

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'da {p0} a {p1}'**
  String daA(Object p0, Object p1);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **' su 10'**
  String get su102;

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'giri al minuto'**
  String get giriAlMinuto;

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero.'**
  String get recupero3;

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero, {p0}.'**
  String recupero4(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'Ora: {p0}'**
  String ora(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'Zona {p0}, rallenta.'**
  String zonaRallenta(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'Zona {p0}, puoi spingere un po\' di più.'**
  String zonaPuoiSpingerePo(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} {p1}, rallenta un po\'.'**
  String rallentaPo(Object p0, Object p1);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} {p1}, accelera un po\'.'**
  String acceleraPo(Object p0, Object p1);

  /// widget_home.dart
  ///
  /// In it, this message translates to:
  /// **'Fatto: {p0}'**
  String fatto2(Object p0);

  /// widget_home.dart
  ///
  /// In it, this message translates to:
  /// **'Anche il riposo è allenamento'**
  String get ancheRiposoAllenamento;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Alterna con il recupero, 6 volte'**
  String get alternaRecupero6Volte;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Recupero corricchiando'**
  String get recuperoCorricchiando;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Corsa lenta continua'**
  String get corsaLentaContinua;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Resta in zona 2 per tutta la durata'**
  String get restaZona2Tutta;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Piscina Base (1150 m, vasca 25 m)'**
  String get piscinaBase1150M;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Stile a scelta'**
  String get stileScelta;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Stile libero, gambe con tavoletta'**
  String get stileLiberoGambeTavoletta;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Tavoletta front'**
  String get tavolettaFront;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Dorso, gambe con tavoletta'**
  String get dorsoGambeTavoletta;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Tavoletta dorso'**
  String get tavolettaDorso;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Stile libero, braccia con pull buoy'**
  String get stileLiberoBracciaPull;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'25 m solo braccio DX, 25 m solo braccio SX, 50 m alternato'**
  String get n25MSoloBraccio;

  /// workout_base.dart
  ///
  /// In it, this message translates to:
  /// **'Dorso doppio, gambe rana'**
  String get dorsoDoppioGambeRana;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'tolta'**
  String get parolaTolta;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'tolte'**
  String get parolaTolte;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'sessione'**
  String get parolaSessione;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'sessioni'**
  String get parolaSessioni;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'rulli'**
  String get parolaRulli;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'tapis roulant'**
  String get parolaTapisRoulant;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'nessuno'**
  String get parolaNessuno;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'gennaio'**
  String get parolaGennaio;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'febbraio'**
  String get parolaFebbraio;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'marzo'**
  String get parolaMarzo;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'aprile'**
  String get parolaAprile;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'maggio'**
  String get parolaMaggio;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'giugno'**
  String get parolaGiugno;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'luglio'**
  String get parolaLuglio;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'agosto'**
  String get parolaAgosto;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'settembre'**
  String get parolaSettembre;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'ottobre'**
  String get parolaOttobre;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'novembre'**
  String get parolaNovembre;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'dicembre'**
  String get parolaDicembre;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'chilometro'**
  String get parolaChilometro;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'chilometri'**
  String get parolaChilometri;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'ore'**
  String get parolaOre;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'minuti'**
  String get parolaMinuti;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'fatto'**
  String get parolaFatto;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'oggi'**
  String get parolaOggi;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'domani'**
  String get parolaDomani;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'ieri'**
  String get parolaIeri;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'mese'**
  String get parolaMese;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'mesi'**
  String get parolaMesi;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'sedute'**
  String get parolaSedute;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'volta'**
  String get parolaVolta;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'volte'**
  String get parolaVolte;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'seduta'**
  String get parolaSeduta;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'mancano'**
  String get parolaMancano;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'leggera'**
  String get parolaLeggera;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'moderata'**
  String get parolaModerata;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'impegnativa'**
  String get parolaImpegnativa;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'allenamento'**
  String get parolaAllenamento;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'allenamenti'**
  String get parolaAllenamenti;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'percorsi'**
  String get parolaPercorsi;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'uscite'**
  String get parolaUscite;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'passati'**
  String get parolaPassati;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'giorno'**
  String get parolaGiorno;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'giorni'**
  String get parolaGiorni;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'secondo'**
  String get parolaSecondo;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'secondi'**
  String get parolaSecondi;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'minuto'**
  String get parolaMinuto;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'ora'**
  String get parolaOra;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'metro'**
  String get parolaMetro;

  /// parola singola
  ///
  /// In it, this message translates to:
  /// **'metri'**
  String get parolaMetri;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Recupero'**
  String get glossarioRecupero;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Mobilità'**
  String get glossarioMobilita;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'OGGI'**
  String get widgetOggi;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Apri l\'app per vedere il piano'**
  String get widgetApri;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento questa settimana'**
  String get widgetNessuno;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'{fatti} di {totale} fatti questa settimana'**
  String widgetFatti(Object fatti, Object totale);

  /// iniziali dei giorni da lunedì, separate da virgole
  ///
  /// In it, this message translates to:
  /// **'L,M,M,G,V,S,D'**
  String get widgetLettere;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Allenamento in corso'**
  String get notificaCanale;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Allenamento'**
  String get notificaAllenamento;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get lingua;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Scegli la lingua'**
  String get linguaTitolo;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Potrai cambiarla quando vuoi dal Profilo. I dati che hai già scritto restano come sono.'**
  String get linguaSpiega;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Italiano, inglese o greco'**
  String get linguaSotto;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Sostieni il progetto'**
  String get sostieniProgetto;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Una donazione aiuta lo sviluppo. Non sblocca nulla: l\'app è tutta gratuita.'**
  String get sostieniSotto;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Non riesco ad aprire il link.'**
  String get linkNonAperto;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'{p0} battiti/min'**
  String battitiAlMinuto(Object p0);

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'gira {p0}'**
  String giraVerso(Object p0);

  /// screens/mappa_live.dart
  ///
  /// In it, this message translates to:
  /// **'mancano {p0}'**
  String mancanoAncora(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'recupero {p0}'**
  String recuperoDi(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} serie'**
  String quanteSerie(Object p0);

  /// allenamento_arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} ripetizioni'**
  String quanteRipetizioni(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} aggiornate'**
  String quanteAggiornate(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} rimosse'**
  String quanteRimosse(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} aggiornato'**
  String aggiornato(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} chili'**
  String quantiChili(Object p0);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} e {p1}'**
  String unoEAltro(Object p0, Object p1);

  /// voce.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} watt'**
  String quantiWatt(Object p0);

  /// navigazione.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} metri'**
  String quantiMetri(Object p0);

  /// screens/assistente_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} connesso'**
  String connesso(Object p0);

  /// screens/tour.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} di {p1}'**
  String passoDiTour(Object p0, Object p1);

  /// esercizi.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} esercizi'**
  String quantiEsercizi(Object p0);

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} sessioni'**
  String backupSessioni(Object p0);

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} misure'**
  String backupMisure(Object p0);

  /// backup.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} feedback'**
  String backupFeedback(Object p0);

  /// screens/schede_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} giorni'**
  String quantiGiorni(Object p0);

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} ore'**
  String quanteOre(Object p0);

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} minuti'**
  String quantiMinuti(Object p0);

  /// riepilogo_condiviso.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} sedute'**
  String quanteSedute(Object p0);

  /// arrampicata.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} provat{p1}'**
  String quanteProvate(Object p0, Object p1);

  /// screens/progress_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} punti'**
  String quantiPunti(Object p0);

  /// detto dalla voce: zona di battito
  ///
  /// In it, this message translates to:
  /// **'zona'**
  String get parolaZona;

  /// curva subito dopo un'altra, a voce
  ///
  /// In it, this message translates to:
  /// **'poi {p0}'**
  String poiCurva(Object p0);

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Lingua della voce'**
  String get linguaVoce;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Come l\'app'**
  String get linguaVoceComeApp;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Come il telefono'**
  String get linguaVoceComeTelefono;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Indicazioni stradali, km, ritmo e zone. In una lingua diversa da quella dell\'app, i nomi degli esercizi restano nella lingua dell\'app.'**
  String get linguaVoceSpiega;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'La voce in {p0} non è installata sul telefono: installala dalle impostazioni della sintesi vocale, poi riprova.'**
  String voceNonInstallata(Object p0);

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Installa la voce'**
  String get installaVoce;

  /// aggiunta a mano
  ///
  /// In it, this message translates to:
  /// **'Prova la voce'**
  String get provaVoce;

  /// tra due attrezzi alternativi, con gli spazi
  ///
  /// In it, this message translates to:
  /// **' o '**
  String get oppure;

  /// unità dell'efficienza aerobica
  ///
  /// In it, this message translates to:
  /// **'m/battito'**
  String get mPerBattito;

  /// sotto il numero nell'anello di Progressi
  ///
  /// In it, this message translates to:
  /// **'settimana'**
  String get parolaSettimana;

  /// la pausa tra due esercizi o ripetizioni
  ///
  /// In it, this message translates to:
  /// **'Recupero'**
  String get parolaRecupero;

  /// titolo della pagina
  ///
  /// In it, this message translates to:
  /// **'Assistente'**
  String get assistenteTitolo;

  /// sotto lo stato del recupero, in Progressi
  ///
  /// In it, this message translates to:
  /// **'recupero'**
  String get etichettaRecupero;

  /// titolo nell'informativa
  ///
  /// In it, this message translates to:
  /// **'Passi durante l\'allenamento'**
  String get passiDuranteAllenamento;

  /// testo nell'informativa
  ///
  /// In it, this message translates to:
  /// **'Solo per corsa e camminata, e solo mentre la modalità allenamento è aperta, l\'app legge il contapassi del telefono (permesso \"Attività fisica\") per mostrarti i passi e i passi al minuto. Nella sessione salva il totale dei passi fatti a cronometro acceso: resta sul telefono e nel backup. Chiuso l\'allenamento l\'app non legge più il sensore. Senza il permesso l\'allenamento funziona lo stesso, solo senza passi.'**
  String get soloCorsaCamminataPassi;

  /// passi fatti, nel riepilogo e nella notifica
  ///
  /// In it, this message translates to:
  /// **'{p0} passi'**
  String quantiPassi(Object p0);

  /// interruttore in Dati e collegamenti
  ///
  /// In it, this message translates to:
  /// **'Passi dal telefono'**
  String get passiDalTelefono;

  /// sotto l'interruttore dei passi
  ///
  /// In it, this message translates to:
  /// **'In corsa e camminata l\'app conta i passi con il sensore del telefono (permesso \"Attività fisica\"), anche senza orologio.'**
  String get passiDalTelefonoSpiega;

  /// quando il permesso dei passi è negato
  ///
  /// In it, this message translates to:
  /// **'Il permesso \"Attività fisica\" non è concesso: puoi darlo dalle impostazioni dell\'app, alla voce Permessi.'**
  String get permessoPassiNegato;

  /// workout_screen.dart: titolo degli intervalli registrati di una sessione
  ///
  /// In it, this message translates to:
  /// **'Intervalli'**
  String get intervalliFatti;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Pedalata facile'**
  String get tsPedalataFacile;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Pedala sciolto. Il test vero comincia dopo.'**
  String get tsPedalaSciolto;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Rampa: gradino {p0}'**
  String tsGradinoRampa(Object p0);

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni minuto un po\' più duro. Vai avanti finché non riesci più a tenere la cadenza: poi tocca Avanti fino al defaticamento.'**
  String get tsRampaNota;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Il risultato lo trovi nei grafici di questa uscita.'**
  String get tsRisultatoNeiGrafici;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Minuti svelti'**
  String get tsMinutiSvelti;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Svelti ma non al massimo: svegliano le gambe.'**
  String get tsMinutiSveltiNota;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Il ritmo più forte che riesci a tenere fino alla fine, costante. Parti un po\' piano e chiudi in crescendo.'**
  String get tsVentiSenzaFtp;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Parti intorno a {p0} W e tienili: se dopo 10 minuti stai bene, alza un po\'. Chiudi in crescendo.'**
  String tsVentiConFtp(Object p0);

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Stile a scelta, facile'**
  String get tsStileSceltaFacile;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Stile libero in progressione'**
  String get tsStileLiberoProgressione;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni 50 m un po\' più svelto.'**
  String get tsOgni50Svelto;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Test: 400 m al massimo'**
  String get tsTest400;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Il più veloce che riesci a tenere, costante, senza partire troppo forte. Segnati il tempo.'**
  String get tsTest400Nota;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Test: 200 m al massimo'**
  String get tsTest200;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Il più veloce che riesci a tenere. Segnati il tempo, poi scrivi i due tempi in Profilo → Le mie zone.'**
  String get tsTest200Nota;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Non sappiamo ancora il tuo FTP: senza, le sedute vanno a sensazione.'**
  String get tsMancaFtp;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Non sappiamo ancora il tuo passo critico: senza, le sedute vanno a sensazione.'**
  String get tsMancaPasso;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo FTP non si aggiorna da più di 8 settimane: nel frattempo potresti essere migliorato.'**
  String get tsVecchioFtp;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo passo critico non si aggiorna da più di 8 settimane: nel frattempo potresti essere migliorato.'**
  String get tsVecchioPasso;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Gli ultimi intervalli ti sono sembrati facili: forse l\'FTP è più alto.'**
  String get tsTroppoFacile;

  /// test_soglia.dart
  ///
  /// In it, this message translates to:
  /// **'Gli ultimi intervalli non sei riuscito a finirli: forse l\'FTP è troppo alto.'**
  String get tsTroppoDuro;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Test FTP in bici'**
  String get tsTestFtpBici;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Rullo smart'**
  String get tsRulloSmart;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Su strada'**
  String get tsSuStrada;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'10 minuti facili, poi una rampa: ogni minuto il rullo chiede qualche watt in più, finché non ce la fai più. Circa 25 minuti in tutto.'**
  String get tsRampaTesto1;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il rullo in ERG tiene i watt da solo: non serve sapere quanto spingere. L\'FTP è il 75% del tuo minuto migliore.'**
  String get tsRampaTesto2;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Riscaldamento con 3 minuti svelti, poi 20 minuti al massimo che riesci a tenere, poi 10 minuti sciolti. Circa 55 minuti.'**
  String get tsVentiTesto1;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Senza un FTP si va a sensazione: parti un po\' piano e chiudi in crescendo. Serve un sensore di potenza.'**
  String get tsVentiTesto2Senza;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Si parte intorno al tuo FTP di adesso ({p0} W). Serve un sensore di potenza.'**
  String tsVentiTesto2Con(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'L\'FTP è il 95% della media dei 20 minuti.'**
  String get tsVentiTesto3;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Riscaldamento, poi 400 m al massimo che riesci a tenere, 5 minuti di pausa e 200 m al massimo. Circa 1300 m in tutto.'**
  String get tsNuotoTesto1;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Segnati i due tempi (l\'orologio o il cronometro della piscina): il passo critico è la differenza divisa per 2.'**
  String get tsNuotoTesto2;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ho fatto il test: scrivi i tempi'**
  String get tsHoFattoTest;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'I tempi del test'**
  String get tsTempiTest;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'m:ss, es. 8:20'**
  String get tsEs400;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'m:ss, es. 3:55'**
  String get tsEs200;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Calcola'**
  String get tsCalcola;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Controlla i tempi (m:ss): il 400 deve essere almeno quasi il doppio del 200.'**
  String get tsControllaTempi;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Passo critico: {p0}. Salvato.'**
  String tsPassoSalvato(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Test nel calendario: {p0}. Prende il posto della seduta di quel giorno.'**
  String tsTestNelCalendario(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Se non lo sai, fai il test qui sotto.'**
  String get tsSeNonSaiTest;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Fai il test per calcolarlo'**
  String get tsFaiTestCalcolarlo;

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le tue uscite dicono {p0} W'**
  String tsUsciteDicono(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dal test del {p0}.'**
  String tsDalTest(Object p0);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il {p0} hai tenuto {p1} W per 20 minuti: il tuo FTP è almeno {p2} W.'**
  String tsHaiTenuto(Object p0, Object p1, Object p2);

  /// screens/obiettivo_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Usalo come FTP'**
  String get tsUsaloComeFtp;

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Il tuo FTP: {p0} W'**
  String tsTuoFtp(Object p0);

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'È il 75% del tuo minuto migliore nella rampa ({p0} W).'**
  String tsComeRampa(Object p0);

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'È il 95% dei tuoi 20 minuti del test ({p0} W di media).'**
  String tsComeVenti(Object p0);

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'È il 95% dei tuoi migliori 20 minuti ({p0} W). Senza un test dice solo che sei almeno a questo livello.'**
  String tsComeUscita(Object p0);

  /// screens/grafici_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Adesso usi {p0} W.'**
  String tsAdessoUsi(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Dalle tue uscite il tuo FTP in bici è almeno {p0} W. Lo uso per le zone?'**
  String tsPropostaPrima(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le tue uscite dicono che il tuo FTP in bici è salito: {p0} W (prima {p1}). Lo aggiorno?'**
  String tsPropostaSalito(Object p0, Object p1);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get tsAggiorna;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Test FTP a rampa sul rullo'**
  String get tsTestRampaRullo;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Test del passo critico in piscina'**
  String get tsTestNuotoPiscina;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} {p1}: {p2}?'**
  String tsPropostaTest(Object p0, Object p1, Object p2);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} {p1}: {p2}, al posto di {p3}?'**
  String tsPropostaTestAlPosto(Object p0, Object p1, Object p2, Object p3);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mettilo'**
  String get tsMettilo;

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Test nel calendario: {p0}.'**
  String tsTestNelCalendarioBreve(Object p0);

  /// screens/calendar_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Non sono riuscito a metterlo nel calendario.'**
  String get tsNonRiuscito;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Webhook'**
  String get webhookTitolo;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Manda i tuoi allenamenti a un indirizzo web tuo (Home Assistant, n8n, Node-RED…)'**
  String get webhookSottotitolo;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'A ogni allenamento finito, piano cambiato o record nuovo l\'app manda un messaggio all\'indirizzo che scegli tu, così i dati arrivano nei tuoi pannelli. Nessun server nostro: l\'indirizzo è tuo.'**
  String get webhookSpiegazione;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Invia i dati al webhook'**
  String get webhookAttivo;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Spento: non parte niente.'**
  String get webhookSpento;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Acceso'**
  String get webhookAcceso;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Indirizzo (URL)'**
  String get webhookIndirizzo;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Serve un indirizzo completo che inizi con https://'**
  String get webhookUrlNonValido;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave segreta (facoltativa)'**
  String get webhookChiave;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Con la chiave ogni messaggio ha una firma: chi lo riceve controlla che arrivi davvero dalla tua app.'**
  String get webhookChiaveAiuto;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Genera'**
  String get webhookGenera;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Copia la chiave'**
  String get webhookCopia;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Chiave copiata'**
  String get webhookChiaveCopiata;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Mostra o nascondi la chiave'**
  String get webhookMostraChiave;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get webhookSalva;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Webhook salvato'**
  String get webhookSalvato;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Prima scrivi e salva un indirizzo https://'**
  String get webhookPrimaUrl;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Cosa inviare'**
  String get webhookCosaInviare;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Allenamento completato'**
  String get webhookEventoAllenamento;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Data, sport, durata, distanza, battito, watt, esercizi, serie e carichi'**
  String get webhookEventoAllenamentoSotto;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Piano aggiornato'**
  String get webhookEventoPiano;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Le sedute in programma, quando cambiano'**
  String get webhookEventoPianoSotto;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Nuovo record'**
  String get webhookEventoRecord;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Più kg in un esercizio o la distanza più lunga in uno sport'**
  String get webhookEventoRecordSotto;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quali allenamenti'**
  String get webhookQualiAllenamenti;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo quelli registrati con l\'app'**
  String get webhookSoloApp;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Anche quelli importati'**
  String get webhookTutti;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Da Health Connect, intervals.icu e CSV, compresi quelli già salvati'**
  String get webhookTuttiSotto;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Quali allenamenti inviare?'**
  String get webhookSceltaTitolo;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Puoi mandare solo quelli che registri con l\'app, oppure anche quelli che arrivano da Health Connect, intervals.icu e dai CSV. Con la seconda scelta partono anche quelli già salvati (ora sono {p0}): possono essere centinaia, e il primo invio può richiedere un po\'. Partono uno alla volta, anche con l\'app chiusa.'**
  String webhookSceltaTesto(Object p0);

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Invia test'**
  String get webhookInviaTest;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Test riuscito: risposta HTTP {p0}'**
  String webhookTestOk(Object p0);

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Test non riuscito: {p0}'**
  String webhookTestErrore(Object p0);

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'risposta HTTP {p0}'**
  String webhookCodiceHttp(Object p0);

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'nessuna risposta entro 10 secondi'**
  String get webhookErroreTimeout;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'rete non raggiungibile'**
  String get webhookErroreRete;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'connessione non riuscita (certificato o indirizzo)'**
  String get webhookErroreAltro;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'messaggio troppo vecchio, scartato'**
  String get webhookErroreScaduto;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Stato'**
  String get webhookStato;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimo invio riuscito: {p0} alle {p1}:{p2}'**
  String webhookUltimoOk(Object p0, Object p1, Object p2);

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ancora nessun invio riuscito'**
  String get webhookMaiInviato;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ultimo errore: {p0} alle {p1}:{p2}, {p3}'**
  String webhookUltimoErrore(Object p0, Object p1, Object p2, Object p3);

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Messaggi in coda: {p0}'**
  String webhookInCoda(Object p0);

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Messaggi scartati: {p0}'**
  String webhookScartati(Object p0);

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Come funziona'**
  String get webhookComeFunziona;

  /// screens/webhook_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Ogni messaggio è una richiesta POST con un JSON. Se non arriva (niente rete, server spento) resta in coda e l\'app ritenta dopo 1, 5 e 15 minuti, poi ogni ora, anche ad app chiusa appena torna la rete: al massimo 10 volte o 7 giorni. Gli errori 4xx (indirizzo o chiave sbagliati) non si ritentano. Formato ed esempi in docs/WEBHOOK.md, nel repository dell\'app su GitHub.'**
  String get webhookComeFunzionaTesto;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Webhook (facoltativo)'**
  String get webhookFacoltativo;

  /// screens/privacy_screen.dart
  ///
  /// In it, this message translates to:
  /// **'Solo se accendi il webhook e scrivi un indirizzo https, l\'app manda a quell\'indirizzo, scelto e gestito da te, i dati degli eventi che spunti: allenamenti fatti (data, orari, sport, nome, durata, distanza, battito, watt, cadenza, passi, calorie, RPE, note, esercizi con serie e kg), sedute in programma e record. Niente nome, foto, misure del corpo o percorsi GPS. Indirizzo e chiave segreta restano cifrati sul telefono e non entrano nel backup. Chi riceve i dati è il servizio che hai scelto tu, con le sue condizioni sulla privacy. Spegnendolo non parte più niente e la coda si svuota.'**
  String get webhookPrivacy;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiornamenti dell\'app'**
  String get aggiornamentiApp;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Controlla ogni giorno su GitHub. Tocca per cercare ora'**
  String get aggiornamentiAppSotto;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'È uscita la versione {p0}'**
  String nuovaVersione(Object p0);

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Si installa sopra l\'app che hai: dati e impostazioni restano. Android ti chiederà di confermare.'**
  String get aggiornamentoSpiegazione;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Novità'**
  String get novitaVersione;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get aggiornaApp;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Scarico l\'aggiornamento…'**
  String get scaricoAggiornamento;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Senza il permesso di installare app l\'aggiornamento non può partire. Puoi darlo la prossima volta che tocchi Aggiorna.'**
  String get aggiornamentoPermesso;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Download non riuscito: controlla la connessione e riprova.'**
  String get aggiornamentoRete;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Il file scaricato non è identico a quello pubblicato: non l\'ho installato.'**
  String get aggiornamentoImpronta;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiornamento non riuscito. Puoi scaricare l\'APK dalla pagina Releases su GitHub.'**
  String get aggiornamentoErrore;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Aggiornamento annullato.'**
  String get aggiornamentoAnnullato;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Hai già l\'ultima versione ({p0}).'**
  String haiUltimaVersione(Object p0);

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'GitHub non risponde: riprova più tardi.'**
  String get githubNonRisponde;

  /// aggiornamento.dart
  ///
  /// In it, this message translates to:
  /// **'Una volta al giorno, all\'apertura, l\'app chiede a GitHub (api.github.com) qual è l\'ultima versione pubblicata. Se tocchi Aggiorna, scarica l\'APK da GitHub nella sua memoria temporanea, controlla che sia identico a quello pubblicato, lo passa all\'installatore di Android e lo cancella: sul telefono non restano file. GitHub riceve l\'indirizzo IP del telefono e la versione chiesta, nient\'altro. Puoi spegnere il controllo dal Profilo, alla voce Aggiornamenti dell\'app.'**
  String get aggiornamentiPrivacy;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Più cambi insieme'**
  String get piuCambiInsieme;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Questa risposta cambia più cose: qui sotto le vedi una per una. Si applicano tutte insieme, in quest\'ordine: piano nuovo, modifiche, allenamenti, scheda di forza.'**
  String get piuCambiSpiegazione;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Applica tutto'**
  String get applicaTutto;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Tutto applicato: lo trovi nel calendario.'**
  String get tuttoApplicato;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Il piano nuovo ha dei problemi (li vedi qui sotto): chiedi di correggerlo prima di applicare tutto.'**
  String get pianoDaCorreggerePrima;

  /// screens/schede_proposte.dart
  ///
  /// In it, this message translates to:
  /// **'Fatto: {p0}.'**
  String fattoRiassunto(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'piano nuovo con {p0} sedute'**
  String partePiano(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} modifiche al piano'**
  String parteModifiche(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} allenamenti nel calendario'**
  String parteAllenamenti(Object p0);

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'{p0} allenamenti di arrampicata'**
  String parteArrampicata(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: l\'esercizio \"{p1}\" non c\'è nell\'app. Usa un id della lista degli esercizi, oppure solo \"nome\" per un esercizio scritto a mano.'**
  String forzaEsercizioSconosciuto(Object p0, Object p1);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: un esercizio non ha né id né nome.'**
  String forzaEsercizioSenzaNome(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: le serie devono essere da 1 a 10 e il recupero da 0 a 600 secondi.'**
  String forzaSerieNonValide(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Giorno {p0}'**
  String forzaGiornoN(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: servono i giorni della settimana (1 = lunedì) e da 1 a 20 esercizi.'**
  String forzaGiornoNonValido(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Scheda di forza graduale'**
  String get schedaForzaGraduale;

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Nella scheda di forza servono da 1 a {p0} fasi, ognuna con settimane, giorni ed esercizi.'**
  String forzaServonoFasi(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Fase {p0}'**
  String forzaFaseN(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: la data d\'inizio non è valida (serve AAAA-MM-GG).'**
  String forzaInizioNonValido(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: comincia prima di oggi.'**
  String forzaIniziaPrimaDiOggi(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: comincia prima che finisca la fase precedente.'**
  String forzaFasiSovrapposte(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: le settimane devono essere da 1 a {p1}.'**
  String forzaSettimaneNonValide(Object p0, Object p1);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: servono da 1 a 7 giorni di allenamento.'**
  String forzaGiorniNonValidi(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'{p0}: {p1} è in due giorni della scheda.'**
  String forzaGiornoDoppio(Object p0, Object p1);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'La scheda dura più di {p0} settimane.'**
  String forzaTroppoLunga(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'dal {p0} al {p1}'**
  String forzaDalAl(Object p0, Object p1);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Le schede di forza in corso finiscono il giorno prima: {p0}.'**
  String forzaAccorciate(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Prende il posto di: {p0}.'**
  String forzaTolte(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Nella settimana tipo la forza non c\'è di {p0}: la aggiungo accanto a quello che c\'è già.'**
  String forzaAggiungeGiorni(Object p0);

  /// forza_agente.dart
  ///
  /// In it, this message translates to:
  /// **'Scheda salvata: le sedute di forza seguono i suoi esercizi.'**
  String get forzaSchedaSalvata;

  /// app_state.dart
  ///
  /// In it, this message translates to:
  /// **'la scheda di forza \"{p0}\"'**
  String parteForza(Object p0);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['el', 'en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
