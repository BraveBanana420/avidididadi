import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../benvenuto.dart';
import '../models.dart';
import '../pulse.dart';
import '../tema.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';
import '../l10n/vocabolario.dart';

/// Configurazione guidata: scelti gli sport si parte subito ("Inizia oggi"),
/// oppure si risponde a qualche domanda in più e il piano è su misura.
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

  /// Crea il piano con le risposte date. Con [subito] ("Inizia oggi") le
  /// altre domande si saltano: 30 minuti, livello principiante, tre giorni
  /// (o uno per sport) dal lunedì al venerdì, con la prima seduta già oggi.
  Future<void> _crea({bool subito = false}) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    setState(() => inCorso = true);
    await widget.state.configuraDaZero(
      nome: _nome.text,
      sport: [
        for (final s in sportBenvenuto.keys)
          if (sport.contains(s)) s,
      ],
      giorni: subito ? giorniSubito(sport.length) : giorni,
      minuti: subito ? 30 : minuti,
      livello: subito ? 'principiante' : livello,
      daOggi: subito,
      // Con un orologio o una fascia servono zone, sensori e collegamenti.
      avanzata: !subito && orologio == true,
    );
    navigator.pop();
    messenger.showSnackBar(
      avviso(
        content: Text(
          subito ? l10n.tuoPianoProntoPrima : l10n.tuoPianoProntoOggi,
        ),
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
                      tooltip: l10n.indietro,
                      onPressed: inCorso ? null : () => _vai(passo - 1),
                      icon: const Icon(Icons.arrow_back_rounded),
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
                    l10n.comeTiChiami,
                    l10n.cosiAppTiSaluta,
                    TextField(
                      controller: _nome,
                      textCapitalization: TextCapitalization.words,
                      style: t.headlineSmall,
                      decoration: InputDecoration(
                        hintText: l10n.tuoNome,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _vai(2),
                    ),
                  ),
                  _domanda(
                    t,
                    l10n.cosaTiPiacerebbeFare,
                    l10n.puoiScegliernePiuUno,
                    // Riquadri grandi da toccare, due per riga; la mobilità
                    // (l'opzione più dolce) da sola, in fondo.
                    LayoutBuilder(
                      builder: (context, v) => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final e in sportBenvenuto.entries)
                            SizedBox(
                              width: (v.maxWidth - 12) / 2,
                              child: _TesseraSport(
                                sport: e.key,
                                testo: e.value,
                                largo: false,
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
                    l10n.quantoTempoHai,
                    l10n.meglioPocoMaCostanza,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.giorniSettimana, style: t.titleMedium),
                        const SizedBox(height: 8),
                        _Pulsanti(
                          valori: const [2, 3, 4, 5, 6],
                          scelto: giorni,
                          testo: (v) => '$v',
                          onScelta: (v) => setState(() => giorni = v),
                        ),
                        const SizedBox(height: 24),
                        Text(l10n.minutiOgniVolta, style: t.titleMedium),
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
                              l10n.giorniNonCSpazio(giorni, giorni),
                              style: t.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _domanda(
                    t,
                    l10n.quantoTiAlleniSolito,
                    l10n.rispondiSinceramentePianoParte,
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
                    : passo == 2 && sport.isNotEmpty
                    // Scelti gli sport si può partire subito: le altre
                    // domande restano per chi vuole decidere tutto.
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PulsantePrincipale(
                            onPressed: () => _crea(subito: true),
                            icona: Icons.play_arrow_rounded,
                            testo: l10n.iniziaOggi,
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => _vai(3),
                            child: Text(l10n.primaScelgoGiorniDurata),
                          ),
                        ],
                      )
                    : PulsantePrincipale(
                        onPressed: !_puoiAndare
                            ? null
                            : ultimo
                            ? _crea
                            : () => _vai(passo + 1),
                        icona: ultimo
                            ? Icons.auto_awesome_rounded
                            : Icons.arrow_forward_rounded,
                        testo: ultimo
                            ? l10n.creaMioPiano
                            : passo == 2 && sport.isEmpty
                            ? l10n.scegliAlmenoUnoSport
                            : l10n.avanti,
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
                Icons.directions_run_rounded,
                size: 60,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.benvenuto,
            style: t.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.tiPreparoPianoAllenamento,
            style: t.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scegliTuoiSportParti,
            style: t.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PulsantePrincipale(onPressed: () => _vai(1), testo: l10n.iniziamo),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _salta,
            child: Text(l10n.saltaPreferiscoFareSolo),
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
      l10n.haiOrologioSportivo,
      l10n.vaBeneAncheSenza,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Scelta(
            titolo: l10n.noSoloTelefono,
            testo: l10n.nienteOrologioFasciaCardio,
            scelta: orologio == false,
            onTap: () => setState(() => orologio = false),
          ),
          _Scelta(
            titolo: l10n.siOrologioOFascia,
            testo: l10n.garminPolarSuuntoCoros,
            scelta: orologio == true,
            onTap: () => setState(() => orologio = true),
          ),
          const SizedBox(height: 8),
          if (orologio == false) ...[
            punto(Icons.gps_fixed_rounded, l10n.corsaCamminataBiciRegistra),
            punto(Icons.sentiment_satisfied_alt_rounded, l10n.zoneEsempioZona2),
            punto(Icons.rate_review_rounded, l10n.dopoOgniSedutaRispondi),
            punto(Icons.pool_rounded, l10n.nuotoSenzaOrologioSegni),
            punto(Icons.bedtime_rounded, l10n.energiaSonnoRestanoVuoti),
          ] else if (orologio == true) ...[
            punto(Icons.link_rounded, l10n.dopoCollegaloProfiloDati),
            punto(Icons.bolt_rounded, l10n.haiRulloSmartCollegalo),
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
      nome.isEmpty ? l10n.eccoTuaSettimana : l10n.eccoTuaSettimana2(nome),
      l10n.ogniGiornoNellaPagina,
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
                      s == null ? Icons.bedtime_rounded : iconaSport(s.sport),
                      color: s == null ? null : coloreSport(s.sport),
                    ),
                  ),
                  title: Text(giorniSettimana[g - 1]),
                  subtitle: Text(
                    s == null ? 'Riposo' : l10n.minuti(s.sport, s.durataMin),
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
                    scelta ? Icons.check_circle_rounded : Icons.circle_outlined,
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
      scelta ? Icons.check_circle_rounded : Icons.circle_outlined,
      size: 26,
      color: scelta ? scheme.primary : scheme.outline,
    );
    final icona = Icon(iconaSport(sport), size: 34, color: coloreSport(sport));
    final testi = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mostra(sport), style: t.titleMedium),
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
