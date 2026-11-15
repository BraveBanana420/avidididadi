import 'package:flutter/material.dart';

import '../app_state.dart';
import '../carico.dart';
import '../charts.dart';
import '../glossario.dart';
import '../models.dart';
import '../pulse.dart';
import '../recupero.dart';
import '../widgets.dart';
import 'condividi_screen.dart';
import 'energia.dart';
import 'health_connect_card.dart';
import 'sport_screen.dart';
import '../l10n/lingua.dart';
import '../l10n/vocabolario.dart';

/// Periodi del grafico: settimane mostrate; oltre i 3 mesi si raggruppa per mese.
Map<int, String> get _periodi => {
  4: l10n.n1Mese,
  13: l10n.n3Mesi,
  26: l10n.n6Mesi,
  52: l10n.n1Anno,
};

class ProgressScreen extends StatefulWidget {
  final AppState state;
  const ProgressScreen({super.key, required this.state});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int settimane = 13;
  bool fatica = false; // grafico: tempo oppure fatica (carico)

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) => SafeArea(
        bottom: false,
        // Trascinando verso il basso si sincronizza con Health Connect.
        child: RefreshIndicator(
          onRefresh: () => sincronizzaConMessaggio(context, widget.state),
          child: GruppoGrafici(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 16, 20, spazioBarra(context)),
              children: _contenuto(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _contenuto(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = widget.state;
    final tutte = state.sessioni;
    final children = <Widget>[];
    if (tutte.isEmpty) {
      children.addAll([
        Text(l10n.progressi, style: t.headlineMedium),
        const SizedBox(height: 16),
        SuperficiePulse(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Text(l10n.quiVedraiComeVanno),
          ),
        ),
      ]);
      return children;
    }

    final oggi = soloData(DateTime.now());
    final lunOggi = lunediDi(oggi);
    final zone = state.zone;
    int? rpeDi(Sessione s) => state.feedbackDel(s.data, s.sport)?.fatica;
    final perGiorno = caricoPerGiorno(tutte, zone, rpeDi: rpeDi);

    children.add(
      _Riassunto(
        questa: confrontaSettimana(state.piano, tutte, lunOggi, oggi),
        scorsa: confrontaSettimana(
          state.piano,
          tutte,
          lunOggi.subtract(const Duration(days: 7)),
          oggi,
        ),
        kmSettimana: tutte
            .where((s) => !s.data.isBefore(lunOggi) && !s.data.isAfter(oggi))
            .fold(0.0, (a, s) => a + s.distanzaKm),
        perGiorno: perGiorno,
        oggi: oggi,
        pronto: state.prontezza,
        condividi: () => apriCondividiSettimana(context, state),
      ),
    );

    // Grafico: settimane o mesi del periodo scelto.
    final inizi = [
      for (var i = settimane - 1; i >= 0; i--)
        DateTime(lunOggi.year, lunOggi.month, lunOggi.day - 7 * i),
    ];
    final fine = lunOggi.add(const Duration(days: 7));
    final periodo = tutte
        .where((s) => !s.data.isBefore(inizi.first) && s.data.isBefore(fine))
        .toList();
    final perMese = settimane > 13;
    final chiavi = perMese
        ? [
            for (var i = (settimane / 4.35).round() - 1; i >= 0; i--)
              DateTime(oggi.year, oggi.month - i),
          ]
        : inizi;
    DateTime chiaveDi(DateTime d) =>
        perMese ? DateTime(d.year, d.month) : lunediDi(d);
    final indice = {for (var i = 0; i < chiavi.length; i++) chiavi[i]: i};
    final valori = List.generate(chiavi.length, (_) => <String, double>{});
    final conteggi = List.generate(chiavi.length, (_) => <String, int>{});
    final perSport = <String, List<Sessione>>{};
    for (final s in periodo) {
      (perSport[s.sport] ??= []).add(s);
      final i = indice[chiaveDi(s.data)];
      if (i == null) continue;
      final v = fatica ? carico(s, zone, rpe: rpeDi(s)) : s.durataMin / 60;
      valori[i][s.sport] = (valori[i][s.sport] ?? 0) + v;
      conteggi[i][s.sport] = (conteggi[i][s.sport] ?? 0) + 1;
    }
    final sportOrdinati = perSport.keys.toList()
      ..sort((a, b) => perSport[b]!.length.compareTo(perSport[a]!.length));
    final etichette = [
      for (final d in chiavi)
        perMese ? mesiNomi[d.month - 1].substring(0, 3) : '${d.day}/${d.month}',
    ];

    children.addAll([
      TitoloSezione(l10n.quantoTiAlleni),
      SizedBox(
        width: double.infinity,
        child: SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            for (final e in _periodi.entries)
              ButtonSegment(value: e.key, label: Text(e.value)),
          ],
          selected: {settimane},
          onSelectionChanged: (v) => setState(() => settimane = v.first),
        ),
      ),
      const SizedBox(height: 12),
      SuperficiePulse(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    fatica
                        ? l10n.fatica2(perMese ? l10n.alMese : l10n.settimana3)
                        : l10n.ore(perMese ? l10n.alMese : l10n.settimana3),
                    style: t.titleMedium,
                  ),
                ),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    ButtonSegment(value: false, label: Text(l10n.tempo)),
                    ButtonSegment(value: true, label: Text(l10n.fatica)),
                  ],
                  selected: {fatica},
                  onSelectionChanged: (v) => setState(() => fatica = v.first),
                ),
              ],
            ),
            if (fatica)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l10n.durataFaticaContaAnche, style: t.bodySmall),
              ),
            const SizedBox(height: 12),
            if (periodo.isEmpty)
              Text(l10n.nessunAllenamentoQuestoPeriodo)
            else ...[
              GraficoBarre(
                valori: valori,
                sport: sportOrdinati,
                etichette: etichette,
                conteggi: conteggi,
                formato: fatica ? (v) => l10n.quantiPunti(v.round()) : fmtOre,
                formatoAsse: fatica ? (v) => '${v.round()}' : null,
                titoloColonna: perMese
                    ? (i) =>
                          '${maiuscola(mesiNomi[chiavi[i].month - 1])} '
                          '${chiavi[i].year}'
                    : null,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  for (final s in sportOrdinati)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle_rounded,
                          size: 10,
                          color: coloreSport(s),
                        ),
                        const SizedBox(width: 4),
                        Text(s),
                      ],
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l10n.toccaColonnaDettagli, style: t.bodySmall),
              ),
            ],
          ],
        ),
      ),
    ]);

    if (sportOrdinati.isNotEmpty) {
      children.addAll([
        TitoloSezione(l10n.tuoiSport),
        Text(l10n.toccaUnoSportVedere, style: t.bodySmall),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, v) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in sportOrdinati)
                SizedBox(
                  width: (v.maxWidth - 8) / 2,
                  child: _TesseraSport(
                    sport: s,
                    sessioni: perSport[s]!,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SportScreen(
                          sport: s,
                          sessioni: perSport[s]!,
                          inizi: inizi,
                          arrampicate: widget.state.arrampicate,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]);
    }
    return children;
  }
}

class _TesseraSport extends StatelessWidget {
  final String sport;
  final List<Sessione> sessioni;
  final VoidCallback onTap;
  const _TesseraSport({
    required this.sport,
    required this.sessioni,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = coloreSport(sport);
    final ore = sessioni.fold<double>(0, (a, x) => a + x.durataMin / 60);
    final km = sessioni.fold<double>(0, (a, x) => a + x.distanzaKm);
    return SuperficiePulse(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: c.withValues(alpha: 0.18),
                child: Icon(iconaSport(sport), color: c),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: 10),
          Text(mostra(sport), style: t.titleMedium),
          Text(
            '${sessioni.length} ${sessioni.length == 1 ? l10n.parolaAllenamento : l10n.parolaAllenamenti}',
          ),
          Text(
            [
              fmtOre(ore),
              if (km > 0)
                stessoSport(sport, 'Nuoto')
                    ? '${(km * 1000).round()} m'
                    : '${km.round()} km',
            ].join(' · '),
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}

Map<StatoCarico, String> get _titoliCarico => {
  StatoCarico.inCalo: l10n.staiRallentando,
  StatoCarico.equilibrato: l10n.staiAndandoBene,
  StatoCarico.attenzione: l10n.staiAccelerando,
  StatoCarico.rischio: l10n.troppoTroppoFretta,
};

Map<StatoCarico, String> get _frasiCarico => {
  StatoCarico.inCalo: l10n.tiAlleniMenoDelle,
  StatoCarico.equilibrato: l10n.aumentiPocoAllaVolta,
  StatoCarico.attenzione: l10n.staiFacendoParecchioPiu,
  StatoCarico.rischio: l10n.haiAumentatoMoltoPoco,
};

/// "2 h 38" (o "45 min"): compatto, per stare accanto ai km.
String _oreBrevi(int minuti) => minuti < 60
    ? '$minuti min'
    : '${minuti ~/ 60} h ${(minuti % 60).toString().padLeft(2, '0')}';

/// In alto: com'è andata, in parole semplici; l'anello della settimana e
/// quattro numeri. I calcoli si aprono solo se interessano.
class _Riassunto extends StatefulWidget {
  final Confronto questa;
  final Confronto scorsa;
  final double kmSettimana;
  final Map<DateTime, double> perGiorno;
  final DateTime oggi;
  final Prontezza? pronto;
  final VoidCallback condividi; // l'immagine della settimana
  const _Riassunto({
    required this.questa,
    required this.scorsa,
    required this.kmSettimana,
    required this.perGiorno,
    required this.oggi,
    required this.pronto,
    required this.condividi,
  });

  @override
  State<_Riassunto> createState() => _RiassuntoState();
}

class _RiassuntoState extends State<_Riassunto> {
  bool dettagli = false;

  String _giorni(Iterable<(DateTime, String)> v) => v
      .map((e) => '${giorniSettimana[e.$1.weekday - 1].toLowerCase()} ${e.$2}')
      .join(', ');

  Widget _recupero(
    BuildContext context,
    Prontezza? pronto,
    Widget Function(String, String, {Color? colore}) numero,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: pronto == null
          ? null
          : () => mostraEnergia(
              context,
              pronto,
              nota: glossario[l10n.glossarioRecupero],
            ),
      child: numero(
        pronto == null
            ? '–'
            : switch (pronto.stato) {
                StatoRecupero.buono => l10n.buono,
                StatoRecupero.normale => l10n.normale,
                StatoRecupero.basso => l10n.basso,
              },
        'recupero',
        colore: pronto?.stato == StatoRecupero.basso
            ? scheme.primary
            : pronto?.stato == StatoRecupero.buono
            ? scheme.tertiary
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final w = widget;
    final rapporto = rapportoAcutoCronico(w.perGiorno, w.oggi);
    final stato = rapporto == null ? null : statoCarico(rapporto);
    final ultimi7 = w.perGiorno.entries
        .where(
          (e) => w.oggi.difference(e.key).inDays < 7 && !e.key.isAfter(w.oggi),
        )
        .fold(0.0, (a, e) => a + e.value);
    final fatte = w.questa.fatte.length + w.questa.extra.length;
    final previste = w.questa.previste;
    final pronto = w.pronto;
    Widget numero(String valore, String etichetta, {Color? colore}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: EntrataMorbida(
            key: ValueKey(valore),
            child: Text(
              valore,
              style: t.headlineSmall?.cifreFisse.copyWith(color: colore),
            ),
          ),
        ),
        Text(
          etichetta,
          style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.progressi,
                style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            IconButton(
              tooltip: l10n.condividiSettimana,
              onPressed: w.condividi,
              icon: const Icon(Icons.share_rounded),
            ),
          ],
        ),
        Text(
          stato == null ? l10n.tiStoConoscendo : _titoliCarico[stato]!,
          style: t.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          stato == null ? l10n.dopo3SettimaneAllenamenti : _frasiCarico[stato]!,
          style: t.bodyMedium?.copyWith(height: 1.4),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => setState(() => dettagli = !dettagli),
          icon: Icon(
            dettagli ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          ),
          label: Text(l10n.comeCalcolo),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topLeft,
          child: !dettagli
              ? const SizedBox(width: double.infinity)
              : SuperficiePulse(
                  margine: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(glossario[l10n.carico]!, style: t.bodySmall),
                      const SizedBox(height: 8),
                      Text(
                        l10n.ultimi7GiorniPunti(
                          ultimi7.round(),
                          rapporto == null
                              ? ''
                              : l10n.rispettoAllaMediaDelle(
                                  rapporto.toStringAsFixed(2),
                                ),
                        ),
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            AnelloPulse(
              valore: previste == 0 ? 0 : fatte / previste,
              dimensione: 120,
              spessore: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EntrataMorbida(
                    key: ValueKey((fatte, previste)),
                    child: Text(
                      previste == 0 || fatte > previste
                          ? '$fatte'
                          : '$fatte/$previste',
                      style: t.headlineSmall?.cifreFisse,
                    ),
                  ),
                  Text(
                    'settimana',
                    style: t.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: numero(
                          _oreBrevi(w.questa.minutiFatti),
                          l10n.parolaAllenamento,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: numero(
                          w.kmSettimana >= 1
                              ? '${w.kmSettimana.round()} km'
                              : '${(w.kmSettimana * 1000).round()} m',
                          l10n.parolaPercorsi,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: numero(
                          '${w.scorsa.fatte.length + w.scorsa.extra.length}',
                          l10n.settScorsa,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _recupero(context, pronto, numero)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (w.questa.saltate.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.saltati(
                _giorni(w.questa.saltate.map((r) => (r.data, r.sport))),
              ),
              style: TextStyle(color: scheme.primary),
            ),
          ),
      ],
    );
  }
}
