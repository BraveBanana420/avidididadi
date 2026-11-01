import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../adattamento.dart';
import '../app_state.dart';
import '../esercizi.dart';
import '../esporta.dart';
import '../figura.dart';
import '../generatore_endurance.dart';
import '../generatore_forza.dart';
import '../glossario.dart';
import '../models.dart';
import '../obiettivo.dart';
import '../percorso.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../sincronizzazione.dart';
import '../tema.dart';
import '../widgets.dart';
import 'catalogo_screen.dart';
import 'crea_piano_screen.dart';
import 'esecuzione_screen.dart';
import 'feedback_sheet.dart';
import 'grafici_screen.dart';
import 'mappa_percorso.dart';

void apriSessione(BuildContext context, AppState state, PianoRiga r) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => WorkoutScreen(
        state: state,
        data: r.data,
        sport: r.sport,
        tipo: r.tipo,
        fascia: r.fascia,
        durataMin: r.durataMin,
      ),
    ),
  );
}

void apriSvolta(BuildContext context, AppState state, Sessione s) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => WorkoutScreen(
        state: state,
        data: s.data,
        sport: s.sport,
        tipo: s.tipo,
        fascia: '',
        durataMin: s.durataMin,
      ),
    ),
  );
}

/// Una sessione del calendario: i dati di quella svolta e l'allenamento previsto.
class WorkoutScreen extends StatefulWidget {
  final AppState state;
  final DateTime data;
  final String sport;
  final String tipo;
  final String fascia;
  final int durataMin;

  const WorkoutScreen({
    super.key,
    required this.state,
    required this.data,
    required this.sport,
    required this.tipo,
    required this.fascia,
    required this.durataMin,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  /// Passo selezionato (ordine): la figura mostra i muscoli del suo esercizio.
  int? selezionato;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) => _costruisci(context),
  );

  Widget _costruisci(BuildContext context) {
    final state = widget.state;
    final data = widget.data;
    final sport = widget.sport;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final steps = state.passiSeduta(data, sport, widget.tipo);
    final id = steps.isEmpty ? null : steps.first.id;
    final svolte = state.sessioni
        .where((s) => s.data == data && stessoSport(s.sport, sport))
        .toList();
    final perId = {for (final e in state.esercizi) e.id: e};
    // La figura dei muscoli c'è solo se la parte principale ha esercizi noti
    // (forza sì, mobilità no).
    final conFigura = steps.any(
      (s) => s.fase == 'principale' && perId[s.esercizio] != null,
    );

    final riga = <String>[
      if (widget.fascia.isNotEmpty) widget.fascia,
      if (widget.durataMin > 0 && svolte.isEmpty) '${widget.durataMin} min',
    ].join(', ');

    final tipo = widget.tipo.isNotEmpty
        ? widget.tipo
        : state.tipoDel(data, sport);
    final spiegazione = spiegaSeduta(sport, tipo);
    final children = <Widget>[
      Text(dataLunga(data), style: t.titleMedium),
      if (riga.isNotEmpty) Text(riga),
      const SizedBox(height: 12),
    ];

    // Prima quello che hai fatto: percorso e dati della sessione svolta
    // (storico CSV, Garmin, Health Connect).
    for (final s in svolte) {
      // Il percorso GPS (registrato dall'app o letto da Health Connect).
      // Al chiuso (rulli, Tacx, tapis roulant) non c'è un percorso.
      if (sportConPercorso(s.sport, s.tipo) && !state.alChiuso(s)) {
        children.add(
          AnteprimaPercorso(key: ValueKey(s.id), state: state, sessione: s),
        );
      }
      children.add(_DatiSessione(state: state, sessione: s));
      children.add(const SizedBox(height: 12));
    }
    // Fatto un allenamento diverso da quello in programma: lo si dice.
    final previsto = state.piano
        .where((r) => r.data == data && stessoSport(r.sport, sport))
        .firstOrNull;
    if (svolte.isNotEmpty &&
        previsto != null &&
        state.statoDel(previsto) == StatoSeduta.sostituita) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hai fatto un allenamento diverso da quello in programma: '
                  'il feedback vale per quello che hai fatto davvero.',
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Feedback rapido, da oggi indietro: sedute generate dall'app o svolte.
    final generata =
        id != null && (id.startsWith(prefissoForza) || idEndurance(id));
    if ((generata || svolte.isNotEmpty) &&
        !data.isAfter(soloData(DateTime.now()))) {
      final f = state.feedbackDel(data, sport);
      children.add(
        Card(
          child: ListTile(
            leading: Icon(
              f == null
                  ? Icons.rate_review_outlined
                  : Icons.check_circle_outline,
            ),
            title: Text(f == null ? "Com'è andata?" : 'Fatica ${f.fatica}/10'),
            subtitle: Text(
              f == null
                  ? (generata
                        ? 'Il tuo feedback regola le prossime sessioni.'
                        : 'Serve a calcolare il carico di allenamento.')
                  : [
                      f.completata ? 'Completata' : 'Non completata',
                      if (f.dolore) 'dolore segnalato',
                    ].join(' · '),
            ),
            trailing: Text(f == null ? 'Rispondi' : 'Modifica'),
            onTap: () =>
                apriFeedback(context, state, data, sport, svolte.firstOrNull),
          ),
        ),
      );
      children.add(const SizedBox(height: 12));
    }

    // Cos'è questa seduta, in parole semplici: chiusa, si apre col tocco.
    if (spiegazione != null) {
      children.add(
        _Spiegazione(titolo: tipo.isEmpty ? sport : tipo, testo: spiegazione),
      );
      children.add(const SizedBox(height: 12));
    }

    if (steps.isEmpty) {
      if (svolte.isEmpty) {
        children.add(
          _SenzaEsercizi(
            state: state,
            sport: sport,
            durataMin: widget.durataMin,
          ),
        );
      }
    } else if (svolte.isEmpty) {
      // Il previsto si vede solo finché l'attività non è stata fatta.
      final nome = steps.first.nome;
      final tot = steps.first.durataTot;
      // Modalità allenamento: un esercizio alla volta, con il cronometro.
      if (svolte.isEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Ti guido esercizio per esercizio: tocchi "Fatto" quando finisci, '
              'i recuperi e le parti a tempo li conto io.',
              style: t.bodySmall,
            ),
          ),
        );
      }
      children.add(
        Text(
          svolte.isEmpty
              ? (nome.isEmpty ? 'Allenamento' : nome)
              : 'Allenamento previsto: ${nome.isEmpty ? 'allenamento' : nome}',
          style: t.titleLarge,
        ),
      );
      if (tot > 0) children.add(Text('Durata totale: $tot min'));
      String? faseCorrente;
      for (var k = 0; k < steps.length; k++) {
        final s = steps[k];
        final ultimo = k == steps.length - 1;
        if (s.fase != faseCorrente) {
          faseCorrente = s.fase;
          if (s.fase.isNotEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8),
                child: Text(
                  s.fase.toUpperCase(),
                  style: t.labelMedium?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }
        }
        final esercizio = perId[s.esercizio];
        final scelto = selezionato == s.ordine;
        final testo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.descrizione.isNotEmpty)
              Text(s.descrizione, style: t.titleSmall),
            // "zona 2" diventa anche bpm, con le zone personali.
            if (s.riepilogo.isNotEmpty) Text(conBpm(s.riepilogo, state.zone)),
            // ...e come la si riconosce, anche senza orologio.
            if (sensazioneDi(s.riepilogo) != null)
              Text(
                'Come ti devi sentire: ${sensazioneDi(s.riepilogo)}',
                style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            if (s.note.isNotEmpty) Text(s.note, style: t.bodySmall),
          ],
        );
        // Il percorso: un punto per passo, uniti da una linea. Pieno e nel
        // colore del tema per la parte principale, vuoto per il resto.
        final principale = s.fase == 'principale';
        final segno = Column(
          children: [
            const SizedBox(height: 4),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: principale ? Pulse.di(context).primario : null,
                border: principale
                    ? null
                    : Border.all(
                        width: 3,
                        color: s.fase == 'mobilità'
                            ? coloreSport('Mobilità')
                            : scheme.outline,
                      ),
              ),
            ),
            if (!ultimo)
              Expanded(
                child: Container(width: 2, color: scheme.outlineVariant),
              ),
          ],
        );
        Widget riga(Widget contenuto) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              segno,
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: contenuto,
                ),
              ),
            ],
          ),
        );
        children.add(
          Container(
            decoration: BoxDecoration(
              color: scelto ? scheme.secondaryContainer : null,
              borderRadius: BorderRadius.circular(16),
            ),
            // Con la figura in alto il tocco seleziona (e colora i muscoli) e
            // la freccia apre il dettaglio; senza figura il tocco apre subito
            // il dettaglio.
            child: esercizio == null
                ? riga(testo)
                : () {
                    void dettaglio() => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            EsercizioScreen(state: state, esercizio: esercizio),
                      ),
                    );
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: conFigura
                          ? () => setState(
                              () => selezionato = scelto ? null : s.ordine,
                            )
                          : dettaglio,
                      child: riga(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: testo),
                            IconButton(
                              tooltip: 'Immagini e istruzioni',
                              icon: const Icon(Icons.chevron_right),
                              onPressed: dettaglio,
                            ),
                          ],
                        ),
                      ),
                    );
                  }(),
          ),
        );
      }
    }

    // Una sola figura, fissa in alto: muscoli della sessione o dell'esercizio scelto.
    final allenati = {
      for (final s in steps)
        if (s.fase == 'principale') ...?perId[s.esercizio]?.muscoli,
    };
    Esercizio? scelto;
    for (final s in steps) {
      if (s.ordine == selezionato) scelto = perId[s.esercizio];
    }
    final evidenziati = scelto?.muscoli.toSet() ?? allenati;

    final inizia = steps.isNotEmpty && svolte.isEmpty;
    return Scaffold(
      bottomNavigationBar: !inizia
          ? const MargineBarraSistema()
          : Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: PulsantePrincipale(
                testo: 'Inizia allenamento',
                icona: Icons.play_arrow,
                onPressed: () => avviaAllenamento(
                  context,
                  state,
                  sport: sport,
                  tipo: tipo,
                  nome: steps.first.nome.isEmpty
                      ? titoloSessione(sport, tipo)
                      : steps.first.nome,
                  passi: steps,
                ),
              ),
            ),
      appBar: AppBar(title: Text(titoloSessione(sport, widget.tipo))),
      body: Column(
        children: [
          if (allenati.isNotEmpty)
            FiguraMuscoliFissa(
              sesso: state.profilo.sesso,
              evidenziati: evidenziati,
              didascalia: scelto == null
                  ? 'Muscoli della sessione: ${_nomi(allenati)}. '
                        'Tocca un esercizio per vedere i suoi, la freccia per '
                        'come si fa.'
                  : '${scelto.nome}: ${_nomi(evidenziati)}',
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Riquadro "Cos'è": spiega il tipo di seduta a chi non lo conosce.
class _Spiegazione extends StatefulWidget {
  final String titolo;
  final String testo;
  const _Spiegazione({required this.titolo, required this.testo});

  @override
  State<_Spiegazione> createState() => _SpiegazioneState();
}

class _SpiegazioneState extends State<_Spiegazione> {
  bool aperta = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => aperta = !aperta),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cos'è: ${widget.titolo}", style: t.titleSmall),
                      if (aperta) ...[
                        const SizedBox(height: 2),
                        Text(widget.testo),
                      ],
                    ],
                  ),
                ),
              ),
              Icon(aperta ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seduta in programma senza esercizi: si spiega perché e cosa fare.
class _SenzaEsercizi extends StatelessWidget {
  final AppState state;
  final String sport;
  final int durataMin;
  const _SenzaEsercizi({
    required this.state,
    required this.sport,
    required this.durataMin,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final forza = stessoSport(sport, 'Forza');
    final daCreare = forza
        ? state.profilo.obiettivo.isEmpty
        : !state.profilo.sportGenerati.contains(normSport(sport));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              daCreare
                  ? 'Questa seduta non ha ancora esercizi'
                  : 'Seduta libera',
              style: t.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              daCreare
                  ? (forza
                        ? 'Fai preparare all\'app la forza: sceglie gli '
                              'esercizi adatti a te e alla tua attrezzatura. '
                              'Ci vuole un minuto.'
                        : 'Fai preparare all\'app le sedute di '
                              '${sport.toLowerCase()}: ognuna con le sue '
                              'indicazioni passo passo.')
                  : 'Muoviti per ${durataMin > 0 ? '$durataMin minuti' : 'il tempo che hai'} '
                        'a ritmo facile: devi riuscire a parlare.',
            ),
            if (daCreare) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CreaPianoScreen(state: state, sportIniziale: sport),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: Text('Prepara le sedute di ${sport.toLowerCase()}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _nomi(Set<String> muscoli) =>
    muscoli.map((m) => nomiMuscoli[m] ?? m).join(', ');

/// Tutti i dati di una sessione svolta.
class _DatiSessione extends StatelessWidget {
  final AppState state;
  final Sessione sessione;
  const _DatiSessione({required this.state, required this.sessione});

  Future<void> _inviaIntervals(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Invio a intervals.icu…')),
    );
    final esito = await state.inviaSessioneIntervals(sessione);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(esito)));
  }

  /// Il percorso in un file GPX, per Strava, Garmin Connect o altre app.
  Future<void> _salvaGpx(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final gpx = await state.gpxSessione(sessione);
    if (gpx == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Per questa sessione l'app non ha un percorso GPS."),
        ),
      );
      return;
    }
    try {
      final uri = await FilePicker.saveFile(
        fileName: nomeFileGpx(sessione),
        bytes: utf8.encode(gpx),
        mimeType: 'application/gpx+xml',
        dialogTitle: 'Salva il percorso',
      );
      if (uri != null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'GPX salvato: puoi caricarlo su Strava o Garmin Connect.',
            ),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('GPX non salvato: $e')));
    }
  }

  /// Nome e "al chiuso", che l'orologio non manda.
  Future<void> _ritocca(BuildContext context) async {
    final s = sessione;
    final prima = state.ritocchi[s.id];
    final nome = TextEditingController(text: prima?.nome ?? '');
    var chiuso = prima?.alChiuso ?? false;
    final scelta = await showDialog<String>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, aggiorna) => AlertDialog(
          title: const Text('Modifica la sessione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              TextField(
                controller: nome,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nome dell\'allenamento',
                  hintText: stessoSport(s.sport, 'Bici')
                      ? 'es. Test FTP'
                      : 'es. Ripetute in pista',
                  helperText: 'Vuoto = quello dell\'orologio',
                ),
              ),
              if (sportConPercorso(s.sport, s.tipo))
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    stessoSport(s.sport, 'Bici')
                        ? 'Al chiuso (rulli, Tacx)'
                        : 'Al chiuso (tapis roulant)',
                  ),
                  subtitle: const Text('Niente mappa né GPX'),
                  value: chiuso,
                  onChanged: (v) => aggiorna(() => chiuso = v),
                ),
            ],
          ),
          actions: [
            // Una riga sola: il cestino a sinistra, lontano da "Salva" e nel
            // colore degli errori, così non si tocca per sbaglio.
            Row(
              children: [
                IconButton(
                  tooltip: 'Elimina la sessione',
                  color: Theme.of(c).colorScheme.error,
                  onPressed: () => Navigator.pop(c, 'elimina'),
                  icon: const Icon(Icons.delete_outline),
                ),
                // Con il testo grande si rimpiccioliscono invece di andare a capo.
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Annulla'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => Navigator.pop(c, 'salva'),
                            child: const Text('Salva'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    final testo = nome.text.trim();
    nome.dispose();
    if (scelta == 'salva') {
      await state.ritoccaSessione(
        RitoccoSessione(s.id, nome: testo, alChiuso: chiuso),
      );
    } else if (scelta == 'elimina' && context.mounted) {
      await _elimina(context);
    }
  }

  /// Toglie la sessione dallo storico, dopo aver chiesto conferma.
  Future<void> _elimina(BuildContext context) async {
    final s = sessione;
    // Quelle dell'app si cancellano; quelle dell'orologio si nascondono.
    final orologio = !state.storicoCsv.any((x) => x.id == s.id);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: Icon(Icons.delete_outline, color: Theme.of(c).colorScheme.error),
        title: const Text('Eliminare la sessione?'),
        content: Text(
          'Sparisce dal calendario, dai Progressi e dal carico, insieme al '
          'suo "Com\'è andata?".'
          '${orologio ? ' Non tornerà con la sincronizzazione; nell\'app '
                    'dell\'orologio resta com\'è.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(c).colorScheme.error,
              foregroundColor: Theme.of(c).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final ripristina = await state.eliminaSessione(s);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Sessione eliminata'),
        action: SnackBarAction(label: 'Annulla', onPressed: ripristina),
      ),
    );
  }

  String _ora(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

  @override
  Widget build(BuildContext context) {
    final s = sessione;
    final t = Theme.of(context).textTheme;
    final nuoto = s.sport.toLowerCase() == 'nuoto';
    final r = ritmo(s);
    final dati = <(String, String)>[
      if (s.inizio != null && s.fine != null)
        ('Orario', '${_ora(s.inizio!)} – ${_ora(s.fine!)}'),
      if (s.durataMin > 0) ('Durata', '${s.durataMin} min'),
      if (s.distanzaKm > 0)
        (
          'Distanza',
          nuoto
              ? '${(s.distanzaKm * 1000).round()} m'
              : '${fmtNum(s.distanzaKm)} km',
        ),
      if (r != null)
        (
          s.sport.toLowerCase() == 'bici' ? 'Velocità media' : 'Ritmo medio',
          '${fmtRitmo(s.sport, r)} ${unitaRitmo(s.sport)}',
        ),
      if (s.fcMedia > 0) ('FC media', '${s.fcMedia} bpm'),
      if (s.fcMax > 0) ('FC massima', '${s.fcMax} bpm'),
      // Quelle delle sessioni dell'app sono calcolate, non misurate.
      if (s.calorieAttive > 0)
        (
          s.fonte == fonteApp ? 'Calorie attive (stima)' : 'Calorie attive',
          '${s.calorieAttive.round()} kcal',
        ),
      if (s.calorieTotali > 0)
        (
          s.fonte == fonteApp ? 'Calorie totali (stima)' : 'Calorie totali',
          '${s.calorieTotali.round()} kcal',
        ),
      if (s.passi > 0) ('Passi', '${s.passi}'),
      if (s.potenzaMedia > 0) ('Potenza media', '${s.potenzaMedia} W'),
      if (s.cadenzaMedia > 0) ('Cadenza media', '${s.cadenzaMedia} rpm'),
      if (cadenza(s) case final c?) ('Passi al minuto', '$c ppm'),
      if (s.rpe > 0) ('Fatica (RPE)', '${fmtNum(s.rpe)}/10'),
    ];
    final c = coloreSport(s.sport);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconaSport(s.sport), color: c),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titoloSessione(s.sport, s.tipo),
                    style: t.titleMedium,
                  ),
                ),
                if (state.alChiuso(s))
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Chip(
                      label: Text('Al chiuso'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                IconButton(
                  tooltip: 'Modifica nome e luogo',
                  onPressed: () => _ritocca(context),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
            if (s.fonte.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('Fonte: ${s.fonte}', style: t.bodySmall),
              ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, vincoli) => Wrap(
                runSpacing: 12,
                children: [
                  for (final (nome, valore) in dati)
                    SizedBox(
                      width: vincoli.maxWidth / 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nome, style: t.labelSmall),
                          Text(valore, style: t.titleMedium),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // I pezzi da cui è stata ricomposta (blocchi Freeletics, ripartenze):
            // visibili solo qui, nel calendario la sessione è una sola.
            if (s.parti.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                daFreeletics(s) ? 'Blocchi' : 'Intervalli',
                style: t.titleSmall,
              ),
              const SizedBox(height: 4),
              for (final p in s.parti)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    // Freeletics: il nome del blocco (es. "25x Leg Wipers").
                    '• ${[if (daFreeletics(p) && p.note.isNotEmpty) p.note else if (p.inizio != null && p.fine != null) '${_ora(p.inizio!)}–${_ora(p.fine!)}', '${p.durataMin} min', if (!daFreeletics(p) && p.tipo.isNotEmpty) p.tipo, if (p.distanzaKm > 0) nuoto ? '${(p.distanzaKm * 1000).round()} m' : '${fmtNum(p.distanzaKm)} km', if (p.fcMedia > 0) 'FC ${p.fcMedia}'].join(' · ')}',
                  ),
                ),
            ],
            // Forza: ripetizioni e kg segnati nella modalità allenamento.
            if (stessoSport(s.sport, 'Forza') &&
                state.serieDel(s.data).isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Serie', style: t.titleSmall),
              const SizedBox(height: 4),
              for (final MapEntry(key: nome, value: serie)
                  in state.serieDel(s.data).entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text('• $nome: ${fmtSerie(serie)}'),
                ),
            ],
            if (s.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(s.note, style: t.bodySmall),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Battito, zone e passo nel tempo: in una pagina a parte.
                if (s.inizio != null && s.fine != null)
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            GraficiScreen(state: state, sessione: s),
                      ),
                    ),
                    icon: const Icon(Icons.show_chart),
                    label: const Text('Grafici'),
                  ),
                // Solo quelle registrate dall'app: quelle dell'orologio
                // sono già su Garmin Connect, intervals.icu e simili.
                if (s.fonte == fonteApp && state.intervalsCollegato)
                  OutlinedButton.icon(
                    onPressed: state.inviate.containsKey(s.id)
                        ? null
                        : () => _inviaIntervals(context),
                    icon: Icon(
                      state.inviate.containsKey(s.id)
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_upload_outlined,
                    ),
                    label: Text(
                      state.inviate.containsKey(s.id)
                          ? 'Su intervals.icu'
                          : 'Invia a intervals.icu',
                    ),
                  ),
                if (s.fonte == fonteApp &&
                    sportConPercorso(s.sport, s.tipo) &&
                    !state.alChiuso(s))
                  OutlinedButton.icon(
                    onPressed: () => _salvaGpx(context),
                    icon: const Icon(Icons.route_outlined),
                    label: const Text('Salva GPX'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
