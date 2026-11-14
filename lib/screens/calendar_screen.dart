import 'package:flutter/material.dart';

import '../app_state.dart';
import '../attivita_libera.dart';
import '../carico.dart';
import '../generatore_mobilita.dart';
import '../glossario.dart';
import '../modifica_sessione.dart';
import '../models.dart';
import '../pulse.dart';
import '../recupero.dart';
import '../tema.dart';
import '../widgets.dart';
import '../workout_base.dart';
import 'energia.dart';
import 'esecuzione_screen.dart';
import 'modifica_sessione_screen.dart';
import 'feedback_sheet.dart';
import 'health_connect_card.dart';
import 'schede_screen.dart';
import 'tour.dart';
import 'week_screen.dart';
import 'workout_screen.dart';

class CalendarScreen extends StatefulWidget {
  final AppState state;
  const CalendarScreen({super.key, required this.state});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime mese = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selezionato = soloData(DateTime.now());
  bool meseAperto = false;

  void _vai(int delta) =>
      setState(() => mese = DateTime(mese.year, mese.month + delta));

  void _apriGenera() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => GeneraSheet(state: widget.state),
    );
  }

  /// Quello che non è stato registrato: si sceglie cosa e si scrivono i dati.
  Future<void> _scriviFatta(DateTime giorno) async {
    final state = widget.state;
    final scelta = await scegliAttivitaLibera(
      context,
      titolo: "Cos'hai fatto?",
      sottotitolo: 'Poi scrivi durata e tutto quello che ti ricordi.',
    );
    if (scelta == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ModificaSessioneScreen(
          state: state,
          sessione: sessioneDaScrivere(
            giorno,
            scelta.$1,
            tipo: scelta.$2,
            occupati: {for (final s in state.sessioni) s.id},
          ),
        ),
      ),
    );
  }

  void _apriModifica(DateTime d) {
    _seleziona(d);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => GiornoSheet(state: widget.state, data: d),
    );
  }

  void _seleziona(DateTime d) => setState(() {
    selezionato = d;
    settimanaVista = lunediDi(d);
    mese = DateTime(d.year, d.month);
  });

  /// Il lunedì della settimana mostrata nella striscia: scorrendo cambia solo
  /// questa, il giorno scelto resta finché non se ne tocca un altro.
  DateTime settimanaVista = lunediDi(soloData(DateTime.now()));

  /// Da dove entra la settimana nuova: 1 da destra (successiva), -1 da sinistra.
  int _verso = 0;

  void _cambiaSettimana(int verso) => setState(() {
    _verso = verso;
    settimanaVista = DateTime(
      settimanaVista.year,
      settimanaVista.month,
      settimanaVista.day + 7 * verso,
    );
  });

  /// Icona dello sport: nel suo colore se la sessione è svolta, grigia se in
  /// programma. Lo sport si riconosce dalla forma, lo stato dal colore.
  Widget _icona(String sport, bool svolta, {double size = 14}) => Icon(
    iconaSport(sport),
    size: size,
    color: svolta
        ? coloreSport(sport)
        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
  );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final state = widget.state;
        final piano = <String, List<PianoRiga>>{};
        for (final r in state.piano) {
          (piano[isoData(r.data)] ??= []).add(r);
        }
        final svolte = <String, List<Sessione>>{};
        for (final s in state.sessioni) {
          (svolte[isoData(s.data)] ??= []).add(s);
        }
        final oggi = soloData(DateTime.now());
        // Se uno sport è già stato svolto quel giorno, il programma non serve più.
        List<PianoRiga> previstiDi(DateTime d) => (piano[isoData(d)] ?? [])
            .where(
              (p) =>
                  !stessoSport(p.sport, 'Riposo') &&
                  !(svolte[isoData(d)] ?? []).any(
                    (s) => stessoSport(s.sport, p.sport),
                  ),
            )
            .toList();
        List<Sessione> fattiDi(DateTime d) => svolte[isoData(d)] ?? [];

        // I prossimi giorni con qualcosa in programma, dopo quello scelto.
        final prossimi = <(DateTime, PianoRiga)>[];
        for (var i = 1; i <= 21 && prossimi.length < 4; i++) {
          final d = DateTime(oggi.year, oggi.month, oggi.day + i);
          if (d == selezionato) continue;
          for (final r in previstiDi(d)) {
            if (prossimi.length < 4) prossimi.add((d, r));
          }
        }
        final nome = state.profilo.nome;
        final pronto = state.prontezza;

        return SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Trascinando verso il basso si sincronizza con Health Connect.
              RefreshIndicator(
                onRefresh: () => sincronizzaConMessaggio(context, state),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // In fondo, spazio anche per il pulsante "+".
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    spazioBarra(context) + 76,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dataLunga(oggi),
                                  style: t.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                // Su una riga sola: se il nome è lungo, rimpicciolisce.
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    nome.isEmpty ? 'Ciao!' : 'Ciao $nome',
                                    maxLines: 1,
                                    style: t.headlineMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (pronto != null)
                            KeyedSubtree(
                              key: ChiaviTour.energia,
                              child: _PillolaEnergia(pronto),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!state.primaVolta) const InvitoTour(),
                    PromemoriaPiano(state: state),
                    PromemoriaScheda(state: state),
                    KeyedSubtree(
                      key: ChiaviTour.feedback,
                      child: PromemoriaFeedback(state: state),
                    ),
                    SchedaGiorno(
                      key: ChiaviTour.giorno,
                      state: state,
                      giorno: selezionato,
                      fatti: fattiDi(selezionato),
                      previsti: previstiDi(selezionato),
                      onModifica: () => _apriModifica(selezionato),
                      onOggi: selezionato == oggi
                          ? null
                          : () => _seleziona(oggi),
                    ),
                    Padding(
                      key: ChiaviTour.settimana,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _StripSettimana(
                        state: state,
                        selezionato: selezionato,
                        lunedi: settimanaVista,
                        oggi: oggi,
                        fattiDi: fattiDi,
                        previstiDi: previstiDi,
                        icona: _icona,
                        onTocca: _seleziona,
                        onSettimana: _cambiaSettimana,
                        verso: _verso,
                      ),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            setState(() => meseAperto = !meseAperto),
                        icon: Icon(
                          meseAperto ? Icons.expand_less : Icons.calendar_month,
                        ),
                        label: Text(
                          meseAperto ? 'Chiudi il mese' : 'Vedi tutto il mese',
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      alignment: Alignment.topCenter,
                      child: meseAperto
                          ? _mese(context, oggi, fattiDi, previstiDi)
                          : const SizedBox(width: double.infinity),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (prossimi.isNotEmpty) ...[
                            const TitoloSezione('Prossimi'),
                            for (var i = 0; i < prossimi.length; i++)
                              RigaPulse(
                                segno: PallinoPulse(
                                  coloreSport(prossimi[i].$2.sport),
                                ),
                                titolo: titoloSessione(
                                  prossimi[i].$2.sport,
                                  prossimi[i].$2.tipo,
                                ),
                                sottotitolo: [
                                  maiuscola(quandoGiorno(prossimi[i].$1, oggi)),
                                  if (prossimi[i].$2.durataMin > 0)
                                    '${prossimi[i].$2.durataMin} min',
                                ].join(' · '),
                                linea: i < prossimi.length - 1,
                                onTap: () => apriSessione(
                                  context,
                                  state,
                                  prossimi[i].$2,
                                ),
                              ),
                          ],
                          const TitoloSezione('Il tuo piano'),
                          RigaPulse(
                            segno: const IconaQuadrata(
                              Icons.edit_calendar_outlined,
                            ),
                            titolo: selezionato == oggi
                                ? 'Cambia gli allenamenti di oggi'
                                : 'Cambia gli allenamenti di '
                                      '${quandoGiorno(selezionato, oggi)}',
                            sottotitolo: 'Sposta, aggiungi o togli: solo per quel giorno',
                            onTap: () => _apriModifica(selezionato),
                          ),
                          if (!selezionato.isAfter(oggi))
                            RigaPulse(
                              segno: const IconaQuadrata(Icons.edit_note),
                              titolo: selezionato == oggi
                                  ? 'Scrivi un\'attività fatta oggi'
                                  : 'Scrivi un\'attività fatta '
                                        '${quandoGiorno(selezionato, oggi)}',
                              sottotitolo:
                                  'Per quello che non hai registrato: durata, '
                                  'distanza, battito…',
                              onTap: () => _scriviFatta(selezionato),
                            ),
                          RigaPulse(
                            key: ChiaviTour.settimanaTipo,
                            segno: const IconaQuadrata(
                              Icons.view_week_outlined,
                            ),
                            titolo: 'La mia settimana tipo',
                            sottotitolo:
                                'Quali giorni ti alleni e per quanto tempo',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WeekScreen(state: state),
                              ),
                            ),
                          ),
                          RigaPulse(
                            segno: const IconaQuadrata(Icons.auto_awesome),
                            titolo: 'Allunga il calendario',
                            sottotitolo:
                                'Ripete la settimana tipo nei prossimi mesi: '
                                'decide i giorni, non gli esercizi',
                            linea: false,
                            onTap: _apriGenera,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Attività libera, fuori dal piano: sempre a portata di pollice.
              Positioned(
                right: 20,
                bottom: spazioBarra(context),
                child: PulsanteLibera(state: state),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Il mese intero: si apre solo se serve, per vedere più avanti o indietro.
  Widget _mese(
    BuildContext context,
    DateTime oggi,
    List<Sessione> Function(DateTime) fattiDi,
    List<PianoRiga> Function(DateTime) previstiDi,
  ) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final primo = DateTime(mese.year, mese.month, 1);
    final offset = primo.weekday - 1;
    final giorni = DateTime(mese.year, mese.month + 1, 0).day;
    final righe = ((offset + giorni) / 7).ceil();
    final nomeMese = '${maiuscola(mesiNomi[mese.month - 1])} ${mese.year}';

    Widget cella(int n) {
      if (n < 1 || n > giorni) return const SizedBox(height: 58);
      final d = DateTime(mese.year, mese.month, n);
      final fatti = fattiDi(d);
      final previsti = previstiDi(d);
      final sel = d == selezionato;
      return InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _seleziona(d),
        onLongPress: () => _apriModifica(d),
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cerchio intorno al numero: pieno se selezionato, bordo se oggi.
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: sel ? Pulse.di(context).primario : null,
                  border: d == oggi && !sel
                      ? Border.all(color: scheme.primary, width: 2)
                      : null,
                ),
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontWeight: sel || d == oggi ? FontWeight.bold : null,
                    color: sel ? Pulse.di(context).suPrimario : null,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // Altezza fissa: i numeri restano allineati anche senza icone.
              SizedBox(
                height: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final (sport, svolta) in [
                      for (final s in fatti) (s.sport, true),
                      for (final p in previsti) (p.sport, false),
                    ].take(3))
                      _icona(sport, svolta),
                    if (fatti.length + previsti.length > 3)
                      Text('+', style: t.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SuperficiePulse(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      margine: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Mese prima',
                onPressed: () => _vai(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(child: Text(nomeMese, style: t.titleMedium)),
              ),
              IconButton(
                tooltip: 'Mese dopo',
                onPressed: () => _vai(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Row(
            children: [
              for (final l in const ['L', 'M', 'M', 'G', 'V', 'S', 'D'])
                Expanded(
                  child: Center(child: Text(l, style: t.labelMedium)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var rg = 0; rg < righe; rg++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(child: cella(rg * 7 + c - offset + 1)),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icona('Corsa', true),
              const SizedBox(width: 6),
              const Text('fatto'),
              const SizedBox(width: 16),
              _icona('Corsa', false),
              const SizedBox(width: 6),
              const Text('da fare'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Tocca un giorno per vederlo, tienilo premuto per cambiarlo.',
              style: t.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// "oggi", "domani", "ieri" o "giovedì 29".
String quandoGiorno(DateTime d, DateTime oggi) =>
    switch (soloData(d).difference(oggi).inDays) {
      0 => 'oggi',
      1 => 'domani',
      -1 => 'ieri',
      _ => '${giorniSettimana[d.weekday - 1].toLowerCase()} ${d.day}',
    };

/// Il recupero di oggi in due parole, in alto a destra; un tocco spiega.
class _PillolaEnergia extends StatelessWidget {
  final Prontezza p;
  const _PillolaEnergia(this.p);

  @override
  Widget build(BuildContext context) {
    final parola = switch (p.stato) {
      StatoRecupero.buono => 'Buona',
      StatoRecupero.normale => 'Normale',
      StatoRecupero.basso => 'Bassa',
    };
    final colore = coloreEnergia(p.stato);
    return Semantics(
      label: 'Energia ${parola.toLowerCase()}',
      button: true,
      excludeSemantics: true,
      child: SuperficiePulse(
        raggio: 999,
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        onTap: () => mostraEnergia(context, p),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(painter: FulmineNeon(colore)),
            ),
            const SizedBox(width: 6),
            Text(
              parola,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fulmine a contorno con alone neon: verde (buona), giallo, rosso (bassa).

/// La settimana in una riga di cerchi: pieno e colorato = fatto, bordo = da
/// fare, rosso = oggi. Un tocco su un giorno lo mostra sopra.
class _StripSettimana extends StatelessWidget {
  final AppState state;
  final DateTime selezionato;
  final DateTime lunedi; // della settimana mostrata
  final DateTime oggi;
  final List<Sessione> Function(DateTime) fattiDi;
  final List<PianoRiga> Function(DateTime) previstiDi;
  final Widget Function(String, bool, {double size}) icona;
  final void Function(DateTime) onTocca;
  final void Function(int) onSettimana; // -1 precedente, 1 successiva
  final int verso; // da dove entra la settimana nuova
  const _StripSettimana({
    required this.state,
    required this.selezionato,
    required this.lunedi,
    required this.oggi,
    required this.fattiDi,
    required this.previstiDi,
    required this.icona,
    required this.onTocca,
    required this.onSettimana,
    required this.verso,
  });

  @override
  Widget build(BuildContext context) {
    final c = confrontaSettimana(state.piano, state.sessioni, lunedi, oggi);
    final fatte = c.fatte.length + c.extra.length;
    // Scorrendo sulla settimana si passa alla precedente o alla successiva;
    // fuori dalla settimana lo scorrimento cambia pagina come prima.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() < 150) return;
        onSettimana(v < 0 ? 1 : -1);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        layoutBuilder: (attuale, _) => attuale ?? const SizedBox.shrink(),
        transitionBuilder: (figlio, a) => SlideTransition(
          position: Tween(
            begin: Offset(0.25 * verso, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: a, child: figlio),
        ),
        child: KeyedSubtree(
          key: ValueKey(lunedi),
          child: _contenuto(context, lunedi, c, fatte),
        ),
      ),
    );
  }

  Widget _contenuto(
    BuildContext context,
    DateTime lunedi,
    Confronto c,
    int fatte,
  ) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = Pulse.di(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitoloSezione(
          lunedi == lunediDi(oggi)
              ? 'La tua settimana'
              : 'Settimana dal ${lunedi.day} ${mesiNomi[lunedi.month - 1]}',
          destra: c.previste == 0
              ? null
              : Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$fatte',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: fatte > c.previste
                            ? ' fatti'
                            : ' di ${c.previste} fatti',
                      ),
                    ],
                  ),
                  style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
        ),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              () {
                final d = lunedi.add(Duration(days: i));
                final sel = d == selezionato;
                final fatti = fattiDi(d);
                final previsti = previstiDi(d);
                final fatto = fatti.isNotEmpty;
                final colore = fatto ? coloreSport(fatti.first.sport) : null;
                // Spunta del colore del fondo del tema, su ogni sport.
                final suColore = colore == null
                    ? null
                    : Theme.of(context).colorScheme.surface;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onTocca(d),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          Text(
                            const ['L', 'M', 'M', 'G', 'V', 'S', 'D'][i],
                            style: t.labelMedium?.copyWith(
                              color: d == oggi
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                              fontWeight: d == oggi ? FontWeight.w800 : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Anello esterno sul giorno scelto.
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: sel
                                  ? Border.all(color: scheme.primary, width: 2)
                                  : null,
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colore,
                                border: fatto
                                    ? null
                                    : Border.all(
                                        color: d == oggi
                                            ? scheme.primary
                                            : previsti.isNotEmpty
                                            ? scheme.outline
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                boxShadow: fatto
                                    ? [
                                        BoxShadow(
                                          color: colore!.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: fatto
                                  ? Icon(Icons.check, size: 20, color: suColore)
                                  : Text(
                                      '${d.day}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: d == oggi
                                            ? scheme.primary
                                            : scheme.onSurfaceVariant,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (final (sport, svolta) in [
                                  for (final s in fatti) (s.sport, true),
                                  for (final p in previsti) (p.sport, false),
                                ].take(2))
                                  icona(sport, svolta, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
          ],
        ),
        if (c.previste > 0) ...[
          const SizedBox(height: 10),
          BarraAvanzamento(fatte / c.previste),
          if (fatte >= c.previste)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Settimana completata: $fatte allenamenti!',
                style: t.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: p.anello[1],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Il giorno scelto: la seduta da fare in grande (con un pulsante solo), poi
/// quello che è stato fatto, il riposo o i consigli.
class SchedaGiorno extends StatelessWidget {
  final AppState state;
  final DateTime giorno;
  final List<Sessione> fatti;
  final List<PianoRiga> previsti;
  final VoidCallback onModifica;
  final VoidCallback? onOggi; // torna a oggi, se si guarda un altro giorno
  const SchedaGiorno({
    super.key,
    required this.state,
    required this.giorno,
    required this.fatti,
    required this.previsti,
    required this.onModifica,
    this.onOggi,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final oggi = soloData(DateTime.now());
    final passato = giorno.isBefore(oggi);
    final quando = giorno == oggi
        ? 'Oggi'
        : maiuscola(quandoGiorno(giorno, oggi));
    final pronto = giorno == oggi ? state.prontezza : null;
    final hero = !passato && previsti.isNotEmpty ? previsti.first : null;
    final altri = [
      for (final r in previsti)
        if (r != hero) r,
    ];
    final elenco = <Widget>[
      if (fatti.isEmpty && previsti.isEmpty)
        _Riposo(
          passato: passato,
          onAggiungi: onModifica,
          // Solo oggi: un invito facoltativo, non cambia il piano.
          onMobilita: giorno == oggi
              ? () => _mobilita(context, state, 15)
              : null,
        ),
      for (final s in fatti) _Fatto(state: state, sessione: s),
      for (final r in altri) _DaFare(state: state, riga: r, passato: passato),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onOggi != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
            child: Row(
              children: [
                Expanded(child: Text(quando, style: t.titleLarge)),
                TextButton(
                  onPressed: onOggi,
                  child: const Text('Torna a oggi'),
                ),
              ],
            ),
          ),
        if (hero != null)
          _HeroSeduta(
            state: state,
            riga: hero,
            etichetta: '$quando · ${hero.fascia.toLowerCase()}',
          ),
        if (elenco.isNotEmpty)
          SuperficiePulse(
            margine: EdgeInsets.only(top: hero != null ? 12 : 0),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: elenco,
            ),
          ),
        // Recupero basso: al posto della seduta, mobilità (solo un consiglio).
        if (pronto?.stato == StatoRecupero.basso &&
            fatti.isEmpty &&
            previsti.any((r) => !stessoSport(r.sport, sportMobilita)))
          SuperficiePulse(
            margine: const EdgeInsets.only(top: 12),
            onTap: () => _mobilita(context, state, 20),
            child: Row(
              children: [
                IconaQuadrata(
                  iconaSport(sportMobilita),
                  colore: coloreSport(sportMobilita),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Oggi sei poco recuperato: al posto della seduta prevista '
                    'puoi fare 20 minuti di mobilità.',
                  ),
                ),
                const Icon(Icons.play_arrow),
              ],
            ),
          ),
      ],
    );
  }
}

/// La seduta da fare, in grande e sfumata: un solo pulsante, Inizia.
class _HeroSeduta extends StatelessWidget {
  final AppState state;
  final PianoRiga riga;
  final String etichetta;
  const _HeroSeduta({
    required this.state,
    required this.riga,
    required this.etichetta,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = Pulse.di(context);
    final r = riga;
    final passi = state.passiSeduta(r.data, r.sport, r.tipo);
    final esercizi = passi.length;
    final spiegazione = spiegaSeduta(r.sport, r.tipo);
    final ink = p.suPrimario;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: p.hero,
        borderRadius: BorderRadius.circular(32),
        boxShadow: p.ombraHero,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // L'icona dello sport, grande e trasparente, come decorazione.
            Positioned(
              right: -36,
              top: -30,
              child: Icon(
                iconaSport(r.sport),
                size: 190,
                color: ink.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etichetta.toUpperCase(),
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    r.tipo.isEmpty ? r.sport : r.tipo,
                    style: t.displaySmall?.copyWith(color: ink, height: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      if (r.tipo.isNotEmpty) r.sport,
                      if (r.durataMin > 0) '${r.durataMin} minuti',
                      if (esercizi > 1) '$esercizi esercizi',
                    ].join(' · '),
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (spiegazione != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      spiegazione,
                      style: TextStyle(color: ink, fontSize: 14, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: PulsantePrincipale(
                          testo: passi.isEmpty
                              ? "Vedi l'allenamento"
                              : 'Inizia',
                          icona: passi.isEmpty
                              ? Icons.chevron_right
                              : Icons.play_arrow,
                          gradiente: LinearGradient(colors: [ink, ink]),
                          colore: Colors.white,
                          onPressed: passi.isEmpty
                              ? () => apriSessione(context, state, r)
                              : () => avviaAllenamento(
                                  context,
                                  state,
                                  sport: r.sport,
                                  tipo: r.tipo,
                                  nome: passi.first.nome.isEmpty
                                      ? titoloSessione(r.sport, r.tipo)
                                      : passi.first.nome,
                                  passi: passi,
                                ),
                        ),
                      ),
                      if (passi.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Tooltip(
                          message: 'Prima guarda gli esercizi',
                          child: Material(
                            type: MaterialType.transparency,
                            shape: CircleBorder(
                              side: BorderSide(color: ink, width: 2),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => apriSessione(context, state, r),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: Icon(
                                  Icons.format_list_bulleted,
                                  color: ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seduta di mobilità al volo nella modalità allenamento.
void _mobilita(BuildContext context, AppState state, int minuti) {
  final passi = state.mobilitaAlVolo(minuti);
  if (passi.isEmpty) return;
  avviaAllenamento(
    context,
    state,
    sport: sportMobilita,
    tipo: passi.first.nome.split(' · ').first,
    nome: passi.first.nome,
    passi: passi,
  );
}

class _Riposo extends StatelessWidget {
  final bool passato;
  final VoidCallback onAggiungi;
  final VoidCallback? onMobilita;
  const _Riposo({
    required this.passato,
    required this.onAggiungi,
    this.onMobilita,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconaQuadrata(Icons.bedtime_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passato ? 'Nessun allenamento' : 'Giorno di riposo',
                  style: t.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  passato
                      ? 'Quel giorno non risultano allenamenti.'
                      : 'Il riposo fa parte dell\'allenamento: i muscoli si '
                            'rinforzano mentre recuperi.',
                ),
                if (onMobilita != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: onMobilita,
                    icon: Icon(iconaSport(sportMobilita)),
                    label: const Text('Se ti va: 15 minuti di mobilità'),
                  ),
                if (!passato)
                  TextButton.icon(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: onAggiungi,
                    icon: const Icon(Icons.add),
                    label: const Text('Voglio allenarmi lo stesso'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Un'altra seduta da fare nello stesso giorno (o una passata non fatta).
class _DaFare extends StatelessWidget {
  final AppState state;
  final PianoRiga riga;
  final bool passato;
  const _DaFare({
    required this.state,
    required this.riga,
    required this.passato,
  });

  @override
  Widget build(BuildContext context) {
    final r = riga;
    final passi = state.passiSeduta(r.data, r.sport, r.tipo);
    return RigaPulse(
      segno: IconaQuadrata(iconaSport(r.sport), colore: coloreSport(r.sport)),
      titolo: titoloSessione(r.sport, r.tipo),
      sottotitolo: [
        if (r.durataMin > 0) '${r.durataMin} minuti',
        r.fascia.toLowerCase(),
        if (passato) 'non fatto',
      ].join(' · '),
      linea: false,
      onTap: () => apriSessione(context, state, r),
      fine: !passato && passi.isNotEmpty
          ? IconButton.filledTonal(
              tooltip: 'Inizia',
              onPressed: () => avviaAllenamento(
                context,
                state,
                sport: r.sport,
                tipo: r.tipo,
                nome: passi.first.nome.isEmpty
                    ? titoloSessione(r.sport, r.tipo)
                    : passi.first.nome,
                passi: passi,
              ),
              icon: const Icon(Icons.play_arrow),
            )
          : null,
    );
  }
}

class _Fatto extends StatelessWidget {
  final AppState state;
  final Sessione sessione;
  const _Fatto({required this.state, required this.sessione});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = sessione;
    final c = coloreSport(s.sport);
    final f = state.feedbackDel(s.data, s.sport);
    final dati = [
      if (s.durataMin > 0) '${s.durataMin} min',
      if (s.distanzaKm > 0)
        stessoSport(s.sport, 'Nuoto')
            ? '${(s.distanzaKm * 1000).round()} m'
            : '${fmtNum(s.distanzaKm)} km',
      if (s.fcMedia > 0) '${s.fcMedia} battiti/min',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => apriSvolta(context, state, s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titoloSessione(s.sport, s.tipo),
                        style: t.titleMedium,
                      ),
                      if (dati.isNotEmpty) Text(dati.join(' · ')),
                      if (f != null)
                        Text('Fatica ${f.fatica}/10', style: t.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            if (f == null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      apriFeedback(context, state, s.data, s.sport, s),
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text("Com'è andata?"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GeneraSheet extends StatefulWidget {
  final AppState state;
  final DateTime? inizio; // default: oggi
  const GeneraSheet({super.key, required this.state, this.inizio});

  @override
  State<GeneraSheet> createState() => _GeneraSheetState();
}

class _GeneraSheetState extends State<GeneraSheet> {
  double mesi = 3;
  late DateTime inizio = widget.inizio ?? soloData(DateTime.now());

  Future<void> _scegliData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: inizio,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );
    if (d != null) setState(() => inizio = soloData(d));
  }

  Future<void> _genera() async {
    final messenger = ScaffoldMessenger.of(context);
    final haFuturo = widget.state.piano.any((r) => !r.data.isBefore(inizio));
    if (haFuturo) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Rigenerare il piano?'),
          content: Text(
            'Le sessioni dal ${dataLunga(inizio)} in poi verranno sostituite. Quelle precedenti restano invariate.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Rigenera'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await widget.state.genera(inizio, mesi.round());
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(content: Text('Piano generato')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + spazioInBasso(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allunga il calendario',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Ripete la tua settimana tipo (quali sport, che giorni, quanti '
            'minuti) sui mesi che scegli. Gli esercizi di ogni seduta si '
            'preparano dal Profilo, con "Prepara le sedute".',
          ),
          const SizedBox(height: 12),
          Text(
            'Durata: ${mesi.round()} ${mesi.round() == 1 ? 'mese' : 'mesi'}',
          ),
          Slider(
            value: mesi,
            min: 1,
            max: 12,
            divisions: 11,
            label: '${mesi.round()}',
            onChanged: (v) => setState(() => mesi = v),
          ),
          OutlinedButton.icon(
            onPressed: _scegliData,
            icon: const Icon(Icons.event),
            label: Text('Parti da ${dataLunga(inizio)}'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _genera,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Allunga il calendario'),
          ),
        ],
      ),
    );
  }
}

/// Modifica le sessioni in programma di un solo giorno.
class GiornoSheet extends StatefulWidget {
  final AppState state;
  final DateTime data;
  const GiornoSheet({super.key, required this.state, required this.data});

  @override
  State<GiornoSheet> createState() => _GiornoSheetState();
}

class _GiornoSheetState extends State<GiornoSheet> {
  late final List<PianoRiga> righe = widget.state.piano
      .where((r) => r.data == widget.data)
      .toList();

  Slot _slot(PianoRiga r) => Slot(
    giorno: r.data.weekday,
    fascia: r.fascia,
    sport: r.sport,
    tipo: r.tipo,
    durataMin: r.durataMin,
    note: r.note,
  );

  PianoRiga _riga(Slot s, [PianoRiga? prima]) => PianoRiga(
    data: widget.data,
    fascia: s.fascia,
    sport: s.sport,
    tipo: s.tipo.isEmpty ? tipoPredefinito(widget.data, s.sport) : s.tipo,
    durataMin: s.durataMin,
    // Distanza e intensità restano solo se lo sport non cambia.
    distanzaKm: prima != null && prima.sport == s.sport ? prima.distanzaKm : '',
    intensita: prima != null && prima.sport == s.sport ? prima.intensita : '',
    note: s.note,
  );

  Future<void> _modifica(int i) async {
    final r = righe[i];
    final s = await showDialog<Slot>(
      context: context,
      builder: (_) => SlotDialog(
        slot: _slot(r),
        titolo: dataLunga(widget.data),
        sport: widget.state.sportScelti,
      ),
    );
    if (s != null) setState(() => righe[i] = _riga(s, r));
  }

  Future<void> _aggiungi() async {
    // Proposta: la fascia libera successiva a quelle già usate.
    final usate = righe.map((r) => r.fascia).toSet();
    final fascia = fasce.firstWhere(
      (f) => !usate.contains(f),
      orElse: () => fasce.last,
    );
    final s = await showDialog<Slot>(
      context: context,
      builder: (_) => SlotDialog(
        slot: Slot(
          giorno: widget.data.weekday,
          fascia: fascia,
          sport: widget.state.sportScelti.first,
        ),
        titolo: dataLunga(widget.data),
        sport: widget.state.sportScelti,
      ),
    );
    if (s != null) setState(() => righe.add(_riga(s)));
  }

  Future<void> _salva() async {
    final messenger = ScaffoldMessenger.of(context);
    await widget.state.salvaGiorno(widget.data, righe);
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('${dataLunga(widget.data)} aggiornato')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + spazioInBasso(context)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modifica ${dataLunga(widget.data)}', style: t.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Cambia solo questo giorno: le altre settimane restano come sono.',
            ),
            const SizedBox(height: 12),
            if (righe.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nessuna attività in programma (giorno di riposo).',
                ),
              ),
            for (var i = 0; i < righe.length; i++)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(
                    iconaSport(righe[i].sport),
                    color: coloreSport(righe[i].sport),
                  ),
                  title: Text(titoloSessione(righe[i].sport, righe[i].tipo)),
                  subtitle: Text(
                    righe[i].durataMin > 0
                        ? '${righe[i].fascia}, ${righe[i].durataMin} min'
                        : righe[i].fascia,
                  ),
                  onTap: () => _modifica(i),
                  trailing: IconButton(
                    tooltip: 'Rimuovi',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => righe.removeAt(i)),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _aggiungi,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi attività'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annulla'),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: _salva,
                    child: const Text('Salva'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sessioni degli ultimi giorni senza feedback: un tocco apre il voto rapido.
class PromemoriaFeedback extends StatelessWidget {
  final AppState state;
  const PromemoriaFeedback({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final manca = state.senzaFeedback;
    if (manca.isEmpty) return const SizedBox.shrink();
    final oggi = soloData(DateTime.now());
    String quando(DateTime d) => switch (oggi.difference(d).inDays) {
      0 => 'oggi',
      1 => 'ieri',
      _ => giorniSettimana[d.weekday - 1].toLowerCase(),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Com'è andata? Un voto alla fatica rende il piano più preciso.",
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final s in manca)
                  ActionChip(
                    avatar: Icon(iconaSport(s.sport), size: 18),
                    label: Text('${s.sport} ${quando(s.data)}'),
                    onPressed: () =>
                        apriFeedback(context, state, s.data, s.sport, s),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Avviso quando mancano 7 giorni o meno alla fine del piano.
class PromemoriaPiano extends StatelessWidget {
  final AppState state;
  const PromemoriaPiano({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.pianoInScadenza || state.promemoriaChiuso) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final ultimo = state.ultimoGiornoPiano;
    final oggi = soloData(DateTime.now());
    final String testo;
    if (ultimo == null) {
      testo =
          'Il calendario è vuoto: allungalo per sapere cosa fare ogni giorno.';
    } else if (ultimo.isBefore(oggi)) {
      testo =
          'Il calendario è finito il ${dataLunga(ultimo)}. Allungalo per i '
          'prossimi mesi.';
    } else {
      final giorni = ultimo.difference(oggi).inDays;
      final quando = giorni == 0
          ? 'oggi'
          : giorni == 1
          ? 'domani'
          : 'tra $giorni giorni';
      testo =
          'Il calendario finisce $quando (${dataLunga(ultimo)}). Vuoi '
          'allungarlo?';
    }
    // Si riparte dal giorno dopo l'ultimo programmato, senza toccare quelli esistenti.
    final daQuando = ultimo == null || ultimo.isBefore(oggi)
        ? oggi
        : DateTime(ultimo.year, ultimo.month, ultimo.day + 1);
    return Card(
      color: scheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
        child: Row(
          children: [
            Icon(
              Icons.notifications_active_outlined,
              color: scheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                testo,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => GeneraSheet(state: state, inizio: daQuando),
              ),
              child: const Text('Allunga'),
            ),
            IconButton(
              tooltip: 'Più tardi',
              onPressed: state.chiudiPromemoria,
              icon: Icon(Icons.close, color: scheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quando la scheda scritta a mano è finita: rinnovarla, cambiarla o tornare
/// alla forza preparata dall'app.
class PromemoriaScheda extends StatelessWidget {
  final AppState state;
  const PromemoriaScheda({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state.schedaFinita;
    if (s == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final durata = s.durataGiorni ?? 15;
    final nome = s.nome.isEmpty
        ? 'La scheda di ${s.sport.toLowerCase()}'
        : 'La scheda "${s.nome}"';
    return Card(
      color: scheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$nome è finita il ${dataLunga(s.fine!)}. Intanto le sedute '
              "sono quelle preparate dall'app.",
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
            Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => state.salvaScheda(s.rinnovata(durata)),
                  child: Text('Rinnova per $durata giorni'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SchedaScreen(
                        state: state,
                        scheda: s.rinnovata(durata),
                        sport: s.sport,
                      ),
                    ),
                  ),
                  child: const Text('Cambiala'),
                ),
                TextButton(
                  onPressed: () =>
                      state.salvaScheda(s.copyWith(archiviata: true)),
                  child: const Text("Usa quella dell'app"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Le attività tra cui scegliere, tutte: qui non contano quelle scelte nel
/// Profilo, perché si può sempre fare qualcosa di diverso dal solito.
Future<(String, String, String)?> scegliAttivitaLibera(
  BuildContext context, {
  required String titolo,
  required String sottotitolo,
}) => showModalBottomSheet<(String, String, String)>(
  context: context,
  showDragHandle: true,
  builder: (c) {
    final t = Theme.of(c).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titolo, style: t.titleLarge),
            const SizedBox(height: 4),
            Text(sottotitolo, style: t.bodySmall),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final a in attivitaLibere)
                  _Scelta(
                    sport: a.$1,
                    nome: a.$3,
                    onTap: () => Navigator.pop(c, a),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  },
);

/// Pulsante rotondo "+": parte subito un'attività che si aggiunge al
/// calendario, qualunque cosa ci sia in programma.
class PulsanteLibera extends StatelessWidget {
  final AppState state;
  const PulsanteLibera({super.key, required this.state});

  Future<void> _scegli(BuildContext context) async {
    final scelta = await scegliAttivitaLibera(
      context,
      titolo: 'Cosa vuoi fare adesso?',
      sottotitolo: "Si aggiunge a quello che c'è in programma oggi.",
    );
    if (scelta == null || !context.mounted) return;
    final (sport, tipo, nome) = scelta;
    avviaAllenamento(
      context,
      state,
      sport: sport,
      tipo: tipo,
      nome: nome,
      passi: passiLiberi(sport, nome),
      libera: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pulse.di(context);
    return Tooltip(
      message: 'Attività libera',
      child: Semantics(
        button: true,
        label: 'Inizia un\'attività libera',
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: p.primario,
            boxShadow: p.ombraPrimario,
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _scegli(context),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Icon(Icons.add, size: 32, color: p.suPrimario),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Una scelta della griglia: icona dello sport nel suo colore e nome.
class _Scelta extends StatelessWidget {
  final String sport;
  final String nome;
  final VoidCallback onTap;
  const _Scelta({required this.sport, required this.nome, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final c = coloreSport(sport);
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: c.withValues(alpha: 0.18),
                child: Icon(iconaSport(sport), color: c),
              ),
              const SizedBox(height: 8),
              Text(
                nome,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: t.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
