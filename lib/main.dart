import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'avviso.dart';
import 'app_state.dart';
import 'condivisione.dart';
import 'health_connect.dart';
import 'in_corso.dart';
import 'models.dart';
import 'pulse.dart';
import 'sincronizzazione.dart';
import 'screens/esecuzione_screen.dart';
import 'widget_home.dart';
import 'screens/assistente_screen.dart';
import 'screens/accettazione_screen.dart';
import 'screens/benvenuto_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/tour.dart';
import 'tema.dart';
import 'l10n/lingua.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await caricaTema();
  await caricaTour();
  runApp(const AllenamentiApp());
}

class AllenamentiApp extends StatelessWidget {
  const AllenamentiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([tema, neon]),
      builder: (context, _) => MaterialApp(
        title: 'Avidididadi',
        debugShowCheckedModeBanner: false,
        theme: creaTema(Brightness.light, neon: neon.value),
        darkTheme: creaTema(Brightness.dark, neon: neon.value),
        themeMode: tema.value,
        // Tutta l'app in italiano: calendari in GG/MM/AAAA e settimana da lunedì.
        locale: const Locale('it'),
        supportedLocales: const [Locale('it')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        // I colori degli sport seguono il tema in uso.
        builder: (context, child) {
          temaScuroAttivo = Theme.of(context).brightness == Brightness.dark;
          neonAttivo = neon.value;
          return child!;
        },
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final state = AppState();

  /// Ultima sincronizzazione (avvio o ritorno nell'app); null finché l'avvio
  /// non ha finito.
  DateTime? _sincronizzataIl;

  /// Tornando nell'app dopo un allenamento con l'orologio le sessioni nuove
  /// arrivano da sole, senza doverla chiudere e riaprire.
  @override
  void didChangeAppLifecycleState(AppLifecycleState stato) {
    if (stato != AppLifecycleState.resumed) return;
    final ora = DateTime.now();
    if (!daRisincronizzare(_sincronizzataIl, ora)) return;
    _sincronizzataIl = ora;
    () async {
      await state.sincronizzaHc();
      await state.sincronizzaIntervals();
    }();
  }

  final pagine = PageController();
  int tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Il giro guidato passa da una sezione all'altra.
    vaiAllaSezione = (i) {
      if (!mounted) return;
      pagine.jumpToPage(i);
      setState(() => tab = i);
    };
    _avvia();
  }

  Future<void> _avvia() async {
    // Health Connect può aprire l'app per mostrare l'informativa sulla privacy.
    HealthConnectService.quandoChiedePrivacy(
      _apriPrivacy,
      avviaDaWidget: _avviaOggi,
      testoCondiviso: _daAgente,
    );
    final azione = await HealthConnectService.azioneAvvio();
    if (HealthConnectService.azioniPrivacy.contains(azione)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _apriPrivacy());
    }
    await state.load();
    // Prima di usare l'app si accettano termini e informativa (di nuovo se
    // sono cambiati).
    if (state.profilo.terminiAccettati != versioneTermini && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => AccettazioneScreen(state: state),
        ),
      );
    }
    // Il widget della schermata home segue piano, sedute fatte e tema.
    state.addListener(_aggiornaWidget);
    tema.addListener(_aggiornaWidget);
    neon.addListener(_aggiornaWidget);
    _aggiornaWidget();
    if (azione == azioneAvviaWidget) _avviaOggi();
    // Avidididadi nel menu Condividi solo con l'assistente esterno collegato
    // (anche dopo un ripristino del backup).
    await Condivisione.ricevi(state.assistente.esterno);
    // Aperta condividendo la risposta dell'assistente collegato.
    final condiviso = await Condivisione.testoAllAvvio();
    if (condiviso != null) _daAgente(condiviso);
    // Un allenamento interrotto (app chiusa da Android o bloccata).
    final interrotto = await leggiInCorso();
    if (interrotto != null && mounted) await _proponiRipresa(interrotto);
    // Prima apertura: domande semplici e il piano è pronto.
    if (state.primaVolta && mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => BenvenutoScreen(state: state)));
    }
    // All'apertura sincronizza solo se Health Connect è già collegato:
    // nessuna richiesta di permessi senza che l'utente lo chieda.
    await state.sincronizzaHc();
    await state.sincronizzaIntervals();
    _sincronizzataIl = DateTime.now();
    // Dopo la sincronizzazione, così il backup ha anche le sessioni nuove.
    await state.backupAutomatico();
  }

  /// Chiede se riprendere la seduta rimasta a metà.
  Future<void> _proponiRipresa(AllenamentoInCorso r) async {
    final riprendi = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.restore_rounded),
        title: Text(l10n.allenamentoInterrotto),
        content: Text(l10n.appSiEraChiusa(r.riassunto)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.scarta),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.riprendi),
          ),
        ],
      ),
    );
    if (riprendi == true && mounted) {
      riprendiAllenamento(context, state, r);
    } else {
      await cancellaInCorso();
    }
  }

  Timer? _attesaWidget;

  /// Aggiorna il widget poco dopo l'ultimo cambiamento (non a ogni notifica).
  void _aggiornaWidget() {
    _attesaWidget?.cancel();
    _attesaWidget = Timer(
      const Duration(seconds: 1),
      () => aggiornaWidgetHome(state),
    );
  }

  /// Dal pulsante ▶ del widget: la prima seduta di oggi con esercizi parte
  /// subito nella modalità allenamento.
  void _avviaOggi() {
    if (!mounted) return;
    final oggi = soloData(DateTime.now());
    for (final r in state.piano.where((r) => r.data == oggi)) {
      final fatta = state.sessioni.any(
        (s) => s.data == oggi && stessoSport(s.sport, r.sport),
      );
      final passi = state.passiSeduta(r.data, r.sport, r.tipo);
      if (fatta || passi.isEmpty) continue;
      avviaAllenamento(
        context,
        state,
        sport: r.sport,
        tipo: r.tipo,
        nome: passi.first.nome.isEmpty
            ? titoloSessione(r.sport, r.tipo)
            : passi.first.nome,
        passi: passi,
      );
      return;
    }
  }

  /// Risposta dell'assistente condivisa con l'app: anteprima nella pagina Coach.
  void _daAgente(String testo) {
    if (!mounted || !state.assistente.esterno) return;
    state.riceviDaAgente(testo);
    pagine.jumpToPage(2);
    setState(() => tab = 2);
    // Se è aperta un'altra pagina (es. un allenamento) non si chiude: avviso.
    if (Navigator.of(context).canPop()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(avviso(content: Text(l10n.rispostaRicevutaTroviCoach)));
    }
  }

  void _apriPrivacy() {
    if (!mounted) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PrivacyScreen()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _attesaWidget?.cancel();
    state.removeListener(_aggiornaWidget);
    tema.removeListener(_aggiornaWidget);
    neon.removeListener(_aggiornaWidget);
    pagine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // La barra fluttua sopra le schede; dietro, il fondo con i bagliori.
      extendBody: true,
      backgroundColor: Colors.transparent,
      // Si cambia sezione scorrendo di lato o dalla barra in basso.
      body: SfondoPulse(
        child: PageView(
          controller: pagine,
          onPageChanged: (i) => setState(() => tab = i),
          children: [
            _TieniViva(child: CalendarScreen(state: state)),
            _TieniViva(child: ProgressScreen(state: state)),
            _TieniViva(child: AssistenteScreen(state: state)),
            _TieniViva(child: ProfileScreen(state: state)),
          ],
        ),
      ),
      bottomNavigationBar: BarraPulse(
        key: ChiaviTour.barra,
        chiavi: ChiaviTour.voci,
        attiva: tab,
        voci: [
          VoceBarra(Icons.today_rounded, l10n.oggi),
          VoceBarra(Icons.insights_rounded, l10n.progressi),
          VoceBarra(Icons.forum_rounded, l10n.coach),
          VoceBarra(Icons.person_outline_rounded, l10n.profilo),
        ],
        onTocca: (i) {
          // Animazione solo verso la sezione accanto, altrimenti salto diretto.
          if ((i - tab).abs() == 1) {
            pagine.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            pagine.jumpToPage(i);
          }
          setState(() => tab = i);
        },
      ),
    );
  }
}

/// Mantiene lo stato di una sezione (periodo, mese, scroll) quando esce dallo schermo.
class _TieniViva extends StatefulWidget {
  final Widget child;
  const _TieniViva({required this.child});

  @override
  State<_TieniViva> createState() => _TieniVivaState();
}

class _TieniVivaState extends State<_TieniViva>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
