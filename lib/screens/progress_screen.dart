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

/// Periodi del grafico: settimane mostrate; oltre i 3 mesi si raggruppa per mese.
const _periodi = {4: '1 mese', 13: '3 mesi', 26: '6 mesi', 52: '1 anno'};

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
        Text('Progressi', style: t.headlineMedium),
        const SizedBox(height: 16),
        const SuperficiePulse(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              'Qui vedrai come vanno i tuoi allenamenti. Collega l\'orologio o '
              'le app di allenamento dal Profilo (Dati e collegamenti), oppure '
              'segna le sedute fatte.',
            ),
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
      const TitoloSezione('Quanto ti alleni'),
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
                        ? 'Fatica ${perMese ? 'al mese' : 'a settimana'}'
                        : 'Ore ${perMese ? 'al mese' : 'a settimana'}',
                    style: t.titleMedium,
                  ),
                ),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const [
                    ButtonSegment(value: false, label: Text('Tempo')),
                    ButtonSegment(value: true, label: Text('Fatica')),
                  ],
                  selected: {fatica},
                  onSelectionChanged: (v) => setState(() => fatica = v.first),
                ),
              ],
            ),
            if (fatica)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Durata per fatica: conta anche quanto è stata dura.',
                  style: t.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            if (periodo.isEmpty)
              const Text('Nessun allenamento in questo periodo.')
            else ...[
              GraficoBarre(
                valori: valori,
                sport: sportOrdinati,
                etichette: etichette,
                conteggi: conteggi,
                formato: fatica ? (v) => '${v.round()} punti' : fmtOre,
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
                        Icon(Icons.circle, size: 10, color: coloreSport(s)),
                        const SizedBox(width: 4),
                        Text(s),
                      ],
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Tocca una colonna per i dettagli.',
                  style: t.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    ]);

    if (sportOrdinati.isNotEmpty) {
      children.addAll([
        const TitoloSezione('I tuoi sport'),
        Text(
          'Tocca uno sport per vedere tutto il dettaglio.',
          style: t.bodySmall,
        ),
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
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 10),
          Text(sport, style: t.titleMedium),
          Text(
            '${sessioni.length} '
            '${sessioni.length == 1 ? 'allenamento' : 'allenamenti'}',
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

const _titoliCarico = {
  StatoCarico.inCalo: 'Stai rallentando',
  StatoCarico.equilibrato: 'Stai andando bene',
  StatoCarico.attenzione: 'Stai accelerando',
  StatoCarico.rischio: 'Troppo, troppo in fretta',
};

const _frasiCarico = {
  StatoCarico.inCalo:
      'Ti alleni meno delle settimane scorse. Va bene se è voluto (riposo, '
      'impegni); altrimenti riprendi con calma.',
  StatoCarico.equilibrato:
      'Aumenti poco alla volta, come si deve: così migliori senza farti male.',
  StatoCarico.attenzione:
      'Stai facendo parecchio più del solito. Ascolta le sensazioni e non '
      'aggiungere altro questa settimana.',
  StatoCarico.rischio:
      'Hai aumentato molto in poco tempo: è così che arrivano gli infortuni. '
      'Fai qualche giorno più leggero.',
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
          : () => mostraEnergia(context, pronto, nota: glossario['Recupero']),
      child: numero(
        pronto == null
            ? '–'
            : switch (pronto.stato) {
                StatoRecupero.buono => 'Buono',
                StatoRecupero.normale => 'Normale',
                StatoRecupero.basso => 'Basso',
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
          child: Text(valore, style: t.headlineSmall?.copyWith(color: colore)),
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
                'Progressi',
                style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            IconButton(
              tooltip: 'Condividi la settimana',
              onPressed: w.condividi,
              icon: const Icon(Icons.share_outlined),
            ),
          ],
        ),
        Text(
          stato == null ? 'Ti sto conoscendo' : _titoliCarico[stato]!,
          style: t.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          stato == null
              ? 'Dopo 3 settimane di allenamenti ti dirò se stai aumentando '
                    'nel modo giusto.'
              : _frasiCarico[stato]!,
          style: t.bodyMedium?.copyWith(height: 1.4),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => setState(() => dettagli = !dettagli),
          icon: Icon(dettagli ? Icons.expand_less : Icons.expand_more),
          label: const Text('Come lo calcolo'),
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
                      Text(glossario['Carico']!, style: t.bodySmall),
                      const SizedBox(height: 8),
                      Text(
                        'Ultimi 7 giorni: ${ultimi7.round()} punti (minuti × '
                        'fatica). ${rapporto == null ? '' : 'Rispetto alla media '
                                  'delle ultime 4 settimane: '
                                  '${rapporto.toStringAsFixed(2)} (bene tra 0,8 e 1,3).'}',
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
                  Text(
                    previste == 0 || fatte > previste
                        ? '$fatte'
                        : '$fatte/$previste',
                    style: t.headlineSmall,
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
                          'allenamento',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: numero(
                          w.kmSettimana >= 1
                              ? '${w.kmSettimana.round()} km'
                              : '${(w.kmSettimana * 1000).round()} m',
                          'percorsi',
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
                          'sett. scorsa',
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
              'Saltati: ${_giorni(w.questa.saltate.map((r) => (r.data, r.sport)))}',
              style: TextStyle(color: scheme.primary),
            ),
          ),
      ],
    );
  }
}
