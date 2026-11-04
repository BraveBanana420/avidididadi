import 'package:flutter/material.dart';

import '../app_state.dart';
import '../benvenuto.dart';
import '../models.dart';
import '../pulse.dart';
import '../tema.dart';
import '../widgets.dart';

/// Configurazione guidata: cinque domande semplici e il piano è pronto.
/// Pensata per chi non si è mai allenato e non ha mai usato un'app così.
class BenvenutoScreen extends StatefulWidget {
  final AppState state;
  const BenvenutoScreen({super.key, required this.state});

  @override
  State<BenvenutoScreen> createState() => _BenvenutoScreenState();
}

class _BenvenutoScreenState extends State<BenvenutoScreen> {
  static const _passi = 7;
  final _pagine = PageController();
  late final _nome = TextEditingController(text: widget.state.profilo.nome);
  int passo = 0;
  final sport = <String>{};
  int giorni = 3;
  int minuti = 30;
  String livello = 'principiante';
  bool? orologio; // ha un orologio o una fascia? null = non ancora detto
  bool inCorso = false;

  @override
  void dispose() {
    _pagine.dispose();
    _nome.dispose();
    super.dispose();
  }

  bool get _puoiAndare => switch (passo) {
    2 => sport.isNotEmpty,
    _ => true,
  };

  void _vai(int p) {
    FocusScope.of(context).unfocus();
    setState(() => passo = p);
    _pagine.animateToPage(
      p,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _salta() async {
    final navigator = Navigator.of(context);
    await widget.state.saltaBenvenuto();
    navigator.pop();
  }

  Future<void> _crea() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => inCorso = true);
    await widget.state.configuraDaZero(
      nome: _nome.text,
      sport: [
        for (final s in sportBenvenuto.keys)
          if (sport.contains(s)) s,
      ],
      giorni: giorni,
      minuti: minuti,
      livello: livello,
    );
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Il tuo piano è pronto! In "Oggi" trovi cosa fare ogni giorno.',
        ),
        duration: Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ultimo = passo == _passi - 1;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      body: SafeArea(
        child: Column(
          children: [
            if (passo > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Indietro',
                      onPressed: inCorso ? null : () => _vai(passo - 1),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: passo / (_passi - 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // La chiave tiene la stessa PageView quando compare la barra in alto.
            Expanded(
              key: const ValueKey('domande'),
              child: PageView(
                controller: _pagine,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _inizio(t),
                  _domanda(
                    t,
                    'Come ti chiami?',
                    'Così l\'app ti saluta per nome.',
                    TextField(
                      controller: _nome,
                      textCapitalization: TextCapitalization.words,
                      style: t.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: 'Il tuo nome',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _vai(2),
                    ),
                  ),
                  _domanda(
                    t,
                    'Cosa ti piacerebbe fare?',
                    'Puoi sceglierne più di uno. Potrai cambiare idea quando vuoi.',
                    // Riquadri grandi da toccare, due per riga; la mobilità
                    // (l'opzione più dolce) da sola, in fondo.
                    LayoutBuilder(
                      builder: (context, v) => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final e in sportBenvenuto.entries)
                            SizedBox(
                              width: e.key == 'Mobilità'
                                  ? v.maxWidth
                                  : (v.maxWidth - 12) / 2,
                              child: _TesseraSport(
                                sport: e.key,
                                testo: e.value,
                                largo: e.key == 'Mobilità',
                                scelta: sport.contains(e.key),
                                onTap: () => setState(
                                  () => sport.contains(e.key)
                                      ? sport.remove(e.key)
                                      : sport.add(e.key),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _domanda(
                    t,
                    'Quanto tempo hai?',
                    'Meglio poco ma con costanza: per iniziare 3 giorni da 30 '
                        'minuti sono perfetti.',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giorni a settimana', style: t.titleMedium),
                        const SizedBox(height: 8),
                        _Pulsanti(
                          valori: const [2, 3, 4, 5, 6],
                          scelto: giorni,
                          testo: (v) => '$v',
                          onScelta: (v) => setState(() => giorni = v),
                        ),
                        const SizedBox(height: 24),
                        Text('Minuti ogni volta', style: t.titleMedium),
                        const SizedBox(height: 8),
                        _Pulsanti(
                          valori: const [20, 30, 45, 60],
                          scelto: minuti,
                          testo: (v) => '$v',
                          onScelta: (v) => setState(() => minuti = v),
                        ),
                        if (sport.length > giorni)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              'Con $giorni giorni non c\'è spazio per tutti '
                              'gli sport scelti: ne userò $giorni.',
                              style: t.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _domanda(
                    t,
                    'Quanto ti alleni di solito?',
                    'Rispondi sinceramente: il piano parte dal tuo livello e '
                        'cresce insieme a te.',
                    Column(
                      children: [
                        for (final e in livelliBenvenuto.entries)
                          _Scelta(
                            titolo: e.value.$1,
                            testo: e.value.$2,
                            scelta: livello == e.key,
                            onTap: () => setState(() => livello = e.key),
                          ),
                      ],
                    ),
                  ),
                  _orologio(t),
                  _riepilogo(t),
                ],
              ),
            ),
            if (passo > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: inCorso
                    ? const SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : PulsantePrincipale(
                        onPressed: !_puoiAndare
                            ? null
                            : ultimo
                            ? _crea
                            : () => _vai(passo + 1),
                        icona: ultimo
                            ? Icons.auto_awesome
                            : Icons.arrow_forward,
                        testo: ultimo
                            ? 'Crea il mio piano'
                            : passo == 2 && sport.isEmpty
                            ? 'Scegli almeno uno sport'
                            : 'Avanti',
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inizio(TextTheme t) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: AnelloPulse(
              valore: 1,
              dimensione: 130,
              spessore: 10,
              child: Icon(
                Icons.directions_run,
                size: 60,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Benvenuto!',
            style: t.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Ti preparo un piano di allenamento su misura, anche se non ti sei '
            'mai allenato. Ogni giorno ti dico cosa fare, passo passo, e il '
            'piano si adatta a come ti senti.',
            style: t.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Bastano 5 domande.',
            style: t.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PulsantePrincipale(onPressed: () => _vai(1), testo: 'Iniziamo'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _salta,
            child: const Text('Salta, preferisco fare da solo'),
          ),
        ],
      ),
    );
  }

  /// Con o senza orologio: cosa cambia, così chi ha solo il telefono sa
  /// cosa aspettarsi e come far adattare il piano.
  Widget _orologio(TextTheme t) {
    final scheme = Theme.of(context).colorScheme;
    Widget punto(IconData icona, String testo) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icona, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(testo, style: t.bodyMedium)),
        ],
      ),
    );
    return _domanda(
      t,
      'Hai un orologio sportivo?',
      'Va bene anche senza: l\'app funziona con il solo telefono.',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Scelta(
            titolo: 'No, solo il telefono',
            testo: 'Niente orologio, fascia cardio o altre app.',
            scelta: orologio == false,
            onTap: () => setState(() => orologio = false),
          ),
          _Scelta(
            titolo: 'Sì, un orologio o una fascia',
            testo: 'Garmin, Polar, Suunto, Coros, Wahoo…',
            scelta: orologio == true,
            onTap: () => setState(() => orologio = true),
          ),
          const SizedBox(height: 8),
          if (orologio == false) ...[
            punto(
              Icons.gps_fixed,
              'Corsa, camminata e bici le registra il telefono con il GPS, e '
              'ti guida a voce passo passo.',
            ),
            punto(
              Icons.sentiment_satisfied_alt,
              'Le zone (per esempio "zona 2") seguile a sensazione: in zona 2 '
              'riesci ancora a parlare.',
            ),
            punto(
              Icons.rate_review_outlined,
              'Dopo ogni seduta rispondi a "Com\'è andata?": è così che il '
              'piano capisce la fatica e si adatta.',
            ),
            punto(
              Icons.pool,
              'Il nuoto, senza orologio, lo segni a mano dopo la vasca.',
            ),
            punto(
              Icons.bedtime_outlined,
              'Energia e sonno restano vuoti: servono i dati di un orologio.',
            ),
          ] else if (orologio == true) ...[
            punto(
              Icons.link,
              'Dopo collegalo da Profilo → Dati e collegamenti: con Health '
              'Connect, o con intervals.icu per Garmin e gli altri. Le '
              'attività arrivano da sole, con battito e sonno.',
            ),
            punto(
              Icons.bolt,
              'Hai un rullo smart? Collegalo durante l\'allenamento: l\'app '
              'gli manda i watt di ogni passo.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _domanda(TextTheme t, String titolo, String aiuto, Widget contenuto) =>
      ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: [
          Text(titolo, style: t.headlineSmall),
          const SizedBox(height: 6),
          Text(aiuto, style: t.bodyMedium),
          const SizedBox(height: 24),
          contenuto,
        ],
      );

  Widget _riepilogo(TextTheme t) {
    final scelti = [
      for (final s in sportBenvenuto.keys)
        if (sport.contains(s)) s,
    ];
    final settimana = settimanaDa(
      sport: scelti,
      giorni: giorni,
      minuti: minuti,
    );
    final nome = _nome.text.trim();
    return _domanda(
      t,
      nome.isEmpty ? 'Ecco la tua settimana' : 'Ecco la tua settimana, $nome',
      'Ogni giorno, nella pagina "Oggi", trovi cosa fare. Potrai cambiare '
      'giorni e orari quando vuoi.',
      Card(
        child: Column(
          children: [
            for (var g = 1; g <= 7; g++)
              () {
                final s = settimana.where((x) => x.giorno == g).firstOrNull;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s == null
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : coloreSport(s.sport).withValues(alpha: 0.18),
                    child: Icon(
                      s == null ? Icons.bedtime_outlined : iconaSport(s.sport),
                      color: s == null ? null : coloreSport(s.sport),
                    ),
                  ),
                  title: Text(giorniSettimana[g - 1]),
                  subtitle: Text(
                    s == null ? 'Riposo' : '${s.sport} · ${s.durataMin} minuti',
                  ),
                );
              }(),
          ],
        ),
      ),
    );
  }
}

/// Riquadro grande da toccare per scegliere (sport o livello).
class _Scelta extends StatelessWidget {
  final String titolo;
  final String testo;
  final bool scelta;
  final VoidCallback onTap;
  const _Scelta({
    required this.titolo,
    required this.testo,
    required this.scelta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = Pulse.di(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: p.superficie,
          border: Border.all(
            color: scelta ? scheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: scelta ? p.ombraPrimario : p.ombraSuperficie,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titolo, style: t.titleMedium),
                        Text(
                          testo,
                          style: t.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    scelta ? Icons.check_circle : Icons.circle_outlined,
                    color: scelta ? scheme.primary : scheme.outline,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila di pulsanti grandi e tondi per scegliere un numero.
class _Pulsanti extends StatelessWidget {
  final List<int> valori;
  final int scelto;
  final String Function(int) testo;
  final void Function(int) onScelta;
  const _Pulsanti({
    required this.valori,
    required this.scelto,
    required this.testo,
    required this.onScelta,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final v in valori)
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => onScelta(v),
            child: Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: v == scelto
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
              ),
              child: Text(
                testo(v),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: v == scelto ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Riquadro di uno sport nella scelta iniziale: grande, con icona e frase;
/// scelto, si illumina con il colore del tema.
class _TesseraSport extends StatelessWidget {
  final String sport;
  final String testo;
  final bool largo;
  final bool scelta;
  final VoidCallback onTap;
  const _TesseraSport({
    required this.sport,
    required this.testo,
    required this.largo,
    required this.scelta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = Pulse.di(context);
    final segno = Icon(
      scelta ? Icons.check_circle : Icons.circle_outlined,
      size: 26,
      color: scelta ? scheme.primary : scheme.outline,
    );
    final icona = Icon(iconaSport(sport), size: 34, color: coloreSport(sport));
    final testi = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sport, style: t.titleMedium),
        Text(
          testo,
          style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
    return Semantics(
      selected: scelta,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: scelta
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.secondaryContainer,
                    scheme.surfaceContainerLow,
                  ],
                )
              : p.superficie,
          border: Border.all(
            color: scelta ? scheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: scelta ? p.ombraPrimario : p.ombraSuperficie,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: largo
                  ? Row(
                      children: [
                        icona,
                        const SizedBox(width: 14),
                        Expanded(child: testi),
                        segno,
                      ],
                    )
                  : SizedBox(
                      height: 128,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [icona, segno],
                          ),
                          testi,
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
