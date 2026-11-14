import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../avviso.dart';
import '../adattamento.dart';
import '../app_state.dart';
import '../arrampicata.dart';
import '../attivita.dart';
import '../dati_live.dart';
import '../esercizi.dart';
import '../esporta.dart';
import '../figura.dart';
import '../generatore_endurance.dart';
import '../generatore_forza.dart';
import '../glossario.dart';
import '../intensita.dart';
import '../intervalli.dart';
import '../intervals.dart';
import '../modifica_sessione.dart';
import '../attivita_libera.dart';
import '../models.dart';
import '../potenza.dart';
import '../percorso.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../serie_sessione.dart';
import '../sincronizzazione.dart';
import '../tema.dart';
import '../widgets.dart';
import 'arrampicata_sheet.dart';
import 'catalogo_screen.dart';
import 'condividi_screen.dart';
import 'crea_piano_screen.dart';
import 'esecuzione_screen.dart';
import 'feedback_sheet.dart';
import 'allenamenti_arrampicata_screen.dart';
import 'grafici_screen.dart';
import 'grafico_intensita.dart';
import 'intervalli_screen.dart';
import 'modifica_sessione_screen.dart';
import 'mappa_percorso.dart';
import 'percorsi_screen.dart';
import 'riepilogo_bici.dart';

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
    final svolte = state.sessioni
        .where((s) => s.data == data && stessoSport(s.sport, sport))
        .toList();
    final previsto = state.piano
        .where((r) => r.data == data && stessoSport(r.sport, sport))
        .firstOrNull;
    // A seduta fatta il tipo qui è quello svolto: i passi previsti vengono dal
    // calendario.
    final steps = state.passiSeduta(
      data,
      sport,
      svolte.isNotEmpty && previsto != null ? previsto.tipo : widget.tipo,
    );
    final id = steps.isEmpty ? null : steps.first.id;
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
      // Altra attività (es. kayak) registrata con l'app: il percorso, se si
      // è scelto il GPS (senza, la mappa non compare).
      final liberaApp =
          stessoSport(s.sport, sportAttivitaLibera) && s.fonte == fonteApp;
      if ((sportConPercorso(s.sport, s.tipo) || liberaApp) &&
          !state.alChiuso(s)) {
        children.add(
          AnteprimaPercorso(key: ValueKey(s.id), state: state, sessione: s),
        );
      }
      children.add(_DatiSessione(state: state, sessione: s));
      children.add(const SizedBox(height: 12));
    }
    // Da fare, all'aperto: si può scegliere prima il percorso da seguire.
    if (svolte.isEmpty &&
        sportConPercorso(sport, tipo) &&
        !tipoAlChiuso(tipo) &&
        !data.isBefore(soloData(DateTime.now()))) {
      children
        ..add(PercorsoDellaSeduta(state: state, giorno: data, sport: sport))
        ..add(const SizedBox(height: 12));
    }

    // Fatto un allenamento diverso da quello in programma: lo si dice.
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
            // Come per il nome e gli intervalli: la matita vuol dire modifica.
            trailing: f == null
                ? const Text('Rispondi')
                : const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    semanticLabel: 'Modifica',
                  ),
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

    // Non registrata: i dati si possono scrivere anche giorni dopo.
    if (svolte.isEmpty &&
        !stessoSport(sport, 'Riposo') &&
        !data.isAfter(soloData(DateTime.now()))) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ModificaSessioneScreen(
                  state: state,
                  sessione: sessioneDaScrivere(
                    data,
                    sport,
                    tipo: tipo,
                    durataMin: widget.durataMin,
                    occupati: {for (final s in state.sessioni) s.id},
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.edit_note),
            label: const Text("L'ho già fatta: scrivi i dati"),
          ),
        ),
      );
    }

    if (steps.isEmpty) {
      if (svolte.isEmpty) {
        children.add(
          _SenzaEsercizi(
            state: state,
            sport: sport,
            giorno: data,
            durataMin: widget.durataMin,
          ),
        );
      }
    } else if (svolte.isEmpty || previsto != null) {
      // A seduta fatta resta da vedere cosa era in programma, per confrontarlo.
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
          if (s.fase.isNotEmpty) children.add(_TitoloFase(s.fase));
        }
        final esercizio = perId[s.esercizio];
        final scelto = selezionato == s.ordine;
        final testo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.descrizione.isNotEmpty)
              Text(s.descrizione, style: t.titleSmall),
            // "zona 2" diventa anche bpm, con le zone personali.
            if (s.riepilogo.isNotEmpty)
              Text(
                intensitaCon(
                  s.riepilogo,
                  s.sport,
                  state.zonePotenza,
                  state.zone,
                ),
              ),
            // ...e come la si riconosce, anche senza orologio.
            if (sensazioneDi(s.riepilogo) != null)
              Text(
                'Come ti devi sentire: ${sensazioneDi(s.riepilogo)}',
                style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            if (s.note.isNotEmpty) Text(s.note, style: t.bodySmall),
          ],
        );
        final segno = _SegnoFase(fase: s.fase, ultimo: ultimo);
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
  final DateTime giorno;
  final int durataMin;
  const _SenzaEsercizi({
    required this.state,
    required this.sport,
    required this.giorno,
    required this.durataMin,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final forza = stessoSport(sport, 'Forza');
    final arrampicata = stessoSport(sport, sportArrampicata);
    final daCreare = forza
        ? state.profilo.obiettivo.isEmpty
        : !arrampicata &&
              !state.profilo.sportGenerati.contains(normSport(sport));
    if (arrampicata) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text('Seduta di arrampicata', style: t.titleMedium),
              const Text(
                'Scegli uno dei tuoi allenamenti o chiedilo all\'assistente. '
                'Puoi anche partire e segnare vie e gradi alla fine.',
              ),
              if (giorno == soloData(DateTime.now()))
                FilledButton.icon(
                  onPressed: () => avviaAllenamento(
                    context,
                    state,
                    sport: sport,
                    tipo: sportArrampicata,
                    nome: sportArrampicata,
                    passi: passiLiberi(sport, sportArrampicata),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Inizia la seduta'),
                ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AllenamentiArrampicataScreen(state: state),
                  ),
                ),
                icon: const Icon(Icons.terrain),
                label: const Text('Scegli un allenamento'),
              ),
            ],
          ),
        ),
      );
    }
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
    messenger.showSnackBar(avviso(content: Text('Invio a intervals.icu…')));
    final esito = await state.inviaSessioneIntervals(sessione);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(avviso(content: Text(esito)));
  }

  /// Il percorso in un file GPX, per Strava, Garmin Connect o altre app.
  Future<void> _salvaGpx(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final gpx = await state.gpxSessione(sessione);
    if (gpx == null) {
      messenger.showSnackBar(
        avviso(
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
          avviso(
            content: Text(
              'GPX salvato: puoi caricarlo su Strava o Garmin Connect.',
            ),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(avviso(content: Text('GPX non salvato: $e')));
    }
  }

  /// Nome, luogo e dati: tutto in una pagina sola, dalla matita.
  Future<void> _modifica(BuildContext context) async {
    final scelta = await Navigator.of(context).push(
      MaterialPageRoute<String>(
        builder: (_) => ModificaSessioneScreen(
          state: state,
          sessione: sessione,
          completa: true,
        ),
      ),
    );
    if (scelta == 'elimina' && context.mounted) await _elimina(context);
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
      avviso(content: const Text('Sessione eliminata'), annulla: ripristina),
    );
  }

  String _ora(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

  @override
  Widget build(BuildContext context) {
    final s = sessione;
    final t = Theme.of(context).textTheme;
    final nuoto = s.sport.toLowerCase() == 'nuoto';
    final r = ritmo(s);
    final vasca = nuoto ? state.nuotoDi(s.id) : null;
    // Tratti corretti a mano: il passo è quello delle sole vasche nuotate,
    // senza le pause spostate dove andavano.
    final aMano = nuoto ? state.intervalliModificati[s.id] : null;
    final passoTratti = aMano == null ? null : passoNuotatoDaTratti(aMano);
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
      if (vasca != null && vasca.vasche > 0)
        ('Vasche', '${vasca.vasche} da ${vasca.lunghezzaM} m'),
      if (vasca != null && vasca.stile.isNotEmpty) ('Stile', vasca.stile),
      // Il tempo medio scritto a mano vale più del calcolo: la durata comprende
      // anche le pause a bordo vasca.
      if (vasca != null && vasca.passo100S > 0)
        ('Tempo medio', '${tempoScritto(vasca.passo100S)} /100 m')
      else if (passoTratti != null)
        ('Tempo medio', '${fmtMinSec(passoTratti.toDouble())} /100 m')
      else if (r != null)
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
      // Corsa e camminata hanno i passi al minuto, qui sotto.
      if (s.cadenzaMedia > 0 && !siCammina(s.sport))
        (
          'Cadenza media',
          '${s.cadenzaMedia} ${stessoSport(s.sport, 'Bici') ? 'rpm' : 'al minuto'}',
        ),
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
                    nomeSessione(s.sport, s.tipo),
                    style: t.titleMedium,
                  ),
                ),
                // Corsa, bici e camminata: dove è stata fatta.
                if (state.alChiuso(s) || sportConPercorso(s.sport, s.tipo))
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Chip(
                      label: Text(state.alChiuso(s) ? 'Indoor' : 'Outdoor'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                IconButton(
                  tooltip: 'Modifica la sessione',
                  onPressed: () => _modifica(context),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
            if (s.fonte.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  state.sessioniModificate.containsKey(s.id)
                      ? 'Fonte: ${s.fonte} · corretta a mano'
                      : 'Fonte: ${s.fonte}',
                  style: t.bodySmall,
                ),
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
            // I tratti della seduta: dall'orologio (giri, con i nomi dei passi
            // in programma se combaciano) o dai blocchi registrati con l'app.
            if (s.id.startsWith(prefissoIcu) || s.id.startsWith('app-'))
              _Intervalli(
                key: ValueKey('int-${s.id}'),
                state: state,
                sessione: s,
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
            // Arrampicata: vie, blocchi e gradi, da segnare anche dopo.
            if (stessoSport(s.sport, sportArrampicata)) ...[
              const SizedBox(height: 16),
              Text('Arrampicata', style: t.titleSmall),
              const SizedBox(height: 4),
              if (arrampicataDi(state.arrampicate, s.id, s.data)
                  case final a?) ...[
                for (final r in a.riassunto)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• $r'),
                  ),
                if (recordArrampicata(state.arrampicate, a.disciplina) case (
                  final g,
                  final quando,
                ))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Record ${a.falesia ? 'sulle vie' : 'nel boulder'}: '
                      '$g (${quando.day} ${mesiNomi[quando.month - 1]} ${quando.year})',
                      style: t.bodySmall,
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => apriArrampicata(
                  context,
                  state,
                  idSessione: s.id,
                  data: s.data,
                ),
                icon: const Icon(Icons.terrain),
                label: Text(
                  arrampicataDi(state.arrampicate, s.id, s.data) == null
                      ? 'Segna vie, blocchi e gradi'
                      : 'Modifica',
                ),
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
              crossAxisAlignment: WrapCrossAlignment.center,
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
                // Un'immagine della sessione per WhatsApp, Instagram…
                IconButton.outlined(
                  tooltip: 'Condividi',
                  onPressed: () => apriCondividiSessione(context, state, s),
                  icon: const Icon(Icons.share_outlined),
                ),
                // Solo quelle registrate dall'app: quelle dell'orologio
                // sono già su Garmin Connect, intervals.icu e simili.
                // Il tasto resta solo dove l'invio non pensa da solo.
                if (state.invioSessione(s) == InvioSessione.tasto)
                  OutlinedButton.icon(
                    onPressed: () => _inviaIntervals(context),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Invia a intervals.icu'),
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
            if (switch (state.invioSessione(s)) {
                  InvioSessione.inviata => (
                    Icons.cloud_done_outlined,
                    'Su intervals.icu',
                  ),
                  InvioSessione.automatico => (
                    Icons.cloud_queue,
                    'Parte da sola per intervals.icu appena c\'è rete',
                  ),
                  _ => null,
                }
                case (final icona, final testo)) ...[
              const SizedBox(height: 12),
              Row(
                spacing: 8,
                children: [
                  Icon(
                    icona,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  Expanded(
                    child: Text(
                      testo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Gli intervalli di una nuotata: lavoro e recuperi, come sull'orologio.
class _Intervalli extends StatefulWidget {
  final AppState state;
  final Sessione sessione;
  const _Intervalli({super.key, required this.state, required this.sessione});

  @override
  State<_Intervalli> createState() => _IntervalliState();
}

class _IntervalliState extends State<_Intervalli> {
  late final Future<List<IntervalloFatto>> _intervalli = widget.state
      .intervalliDi(widget.sessione);

  /// Battito e passo di tutta la corsa: si leggono solo se c'è qualcosa da
  /// confrontare, e una volta sola.
  Future<SerieSessione>? _serieCorsa;

  /// Corsa strutturata: previsto e fatto in un grafico solo, in zone, anche
  /// se l'obiettivo dei blocchi passa dal battito al passo. Null se nessun
  /// blocco ha un obiettivo da disegnare.
  Widget? _schemaCorsa(List<IntervalloFatto> lista, List<WorkoutStep> passi) {
    final s = widget.sessione;
    final inizio = s.inizio;
    if (!stessoSport(s.sport, 'Corsa') || inizio == null) return null;
    final state = widget.state;
    final soglia = sogliaCorsa(state.sessioni, s.data);
    final fasce = fasceIntensita(lista, passi, soglia: soglia);
    if (fasce.isEmpty) return null;
    return FutureBuilder<SerieSessione>(
      future: _serieCorsa ??= state.serieDi(s),
      builder: (context, snap) {
        final serie = snap.data;
        if (serie == null) return const SizedBox.shrink();
        final punti = lineaIntensita(
          serie,
          inizio,
          fasce,
          state.zone,
          soglia: soglia,
        );
        // Senza battito né passo non c'è niente da confrontare.
        if (punti.length < 6) return const SizedBox.shrink();
        final t = Theme.of(context).textTheme;
        final scheme = Theme.of(context).colorScheme;
        final aPasso = fasce.any((f) => f.passo);
        final aZone = fasce.any((f) => !f.passo);
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text('Previsto e fatto', style: t.titleSmall),
              GraficoIntensitaSeduta(
                punti: punti,
                fasce: fasce,
                colore: coloreSport(s.sport),
              ),
              Text(
                'Le fasce colorate sono l\'intensità da tenere blocco per '
                'blocco, la linea quella che hai tenuto: dentro la fascia '
                'eri nell\'obiettivo, sopra andavi più forte, sotto più '
                'piano.'
                '${aPasso && aZone
                    ? ' Dove l\'obiettivo era una zona si guarda il '
                          'battito, dove era un passo si guarda il passo.'
                    : aPasso
                    ? ' Si guarda il passo.'
                    : ' Si guarda il battito.'}',
                style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }

  List<WorkoutStep> get _passi {
    final s = widget.sessione;
    final previsto = widget.state.piano
        .where((r) => r.data == s.data && stessoSport(r.sport, s.sport))
        .firstOrNull;
    return widget.state.passiSeduta(s.data, s.sport, previsto?.tipo ?? s.tipo);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sessione;
    final state = widget.state;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<IntervalloFatto>>(
      future: _intervalli,
      builder: (context, snap) {
        final letti = snap.data ?? const <IntervalloFatto>[];
        final aMano = state.intervalliModificati[s.id];
        // Bici con i watt: lo schema della seduta com'è andata, con le barre
        // colorate per zona come durante l'allenamento, e sotto i watt di
        // tutta la seduta sulle fasce da tenere. C'è anche quando i tratti
        // non si elencano (un blocco solo).
        final diagramma = stessoSport(s.sport, 'Bici')
            ? RiepilogoBici(state: state, sessione: s, tratti: letti)
            : null;
        // Un tratto solo non dice niente di più dei totali.
        if (aMano == null && letti.where((i) => !i.recupero).length < 2) {
          return diagramma ?? const SizedBox.shrink();
        }
        final passi = _passi;
        final nuoto = stessoSport(s.sport, 'Nuoto');
        // Corsa e bici: un lungo, un lento o un'uscita continua sono un passo
        // solo, e i giri dell'orologio non dicono niente di più dei totali.
        // I tratti si mostrano solo se la seduta ha una struttura.
        // Quelli registrati con l'app sono i blocchi veri del player: si
        // vedono sempre, anche se la seduta in calendario è cambiata.
        final dallApp = letti.any((i) => i.fase.isNotEmpty);
        if (aMano == null && !nuoto && !dallApp && !sedutaStrutturata(passi)) {
          return diagramma ?? const SizedBox.shrink();
        }
        // Quelli corretti a mano valgono al posto di quelli dell'orologio.
        // Quelli registrati con l'app hanno già nome e sezione.
        final abbinati = dallApp ? letti : abbinaAlPiano(s.sport, letti, passi);
        // I chilometri in più a fine seduta: una riga sola.
        final lista =
            aMano ?? (nuoto ? abbinati : conFuoriProgrammaUniti(abbinati));
        // Corsa e bici dall'orologio: i giri di 1 km non dicono niente di
        // più dei totali; si mostrano solo se combaciano con la seduta.
        if (aMano == null &&
            !dallApp &&
            !stessoSport(s.sport, 'Nuoto') &&
            !lista.any((i) => i.nome.isNotEmpty)) {
          return diagramma ?? const SizedBox.shrink();
        }
        // Abbinati alla seduta prevista: le sue sezioni e i suoi pallini.
        final fasi = fasiDegliIntervalli(lista, passi);
        final conSezioni = fasi.any((f) => f.isNotEmpty);
        Widget voce(IntervalloFatto i) => i.recupero
            ? Text(
                rigaIntervallo(i, s.sport),
                style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (i.nome.isNotEmpty)
                    Text(
                      i.nome,
                      style: conSezioni ? t.titleSmall : t.labelMedium,
                    ),
                  Text(rigaIntervallo(i, s.sport)),
                  if (i.wattPrevisti case final r?)
                    Text(
                      'Da tenere ${fmtRange(r)}',
                      style: t.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              );
        // Un titolo a ogni cambio di sezione, poi la riga sulla linea.
        final conLinea = <Widget>[];
        String? sezione;
        for (var k = 0; k < lista.length; k++) {
          final i = lista[k];
          if (!i.recupero && fasi[k] != sezione) {
            sezione = fasi[k];
            conLinea.add(
              _TitoloFase(sezione.isEmpty ? 'Fuori programma' : sezione),
            );
          }
          conLinea.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SegnoFase(
                    fase: fasi[k],
                    ultimo: k == lista.length - 1,
                    punto: !i.recupero,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i.recupero ? 10 : 12),
                      child: voce(i),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?diagramma,
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    aMano == null
                        ? 'Intervalli'
                        : 'Intervalli (corretti a mano)',
                    style: t.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Modifica gli intervalli',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => IntervalliScreen(
                        state: state,
                        sessione: s,
                        iniziali: lista,
                        nomi: nomiDeiPassi(passi),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!conSezioni)
              for (final i in lista)
                Padding(
                  padding: EdgeInsets.only(
                    top: 3,
                    bottom: 3,
                    left: i.recupero ? 16 : 0,
                  ),
                  child: voce(i),
                )
            else
              ...conLinea,
            ?_schemaCorsa(lista, passi),
          ],
        );
      },
    );
  }
}

/// Il titolo di una sezione della seduta ("RISCALDAMENTO"): uguale nella
/// seduta prevista e negli intervalli fatti.
class _TitoloFase extends StatelessWidget {
  final String testo;
  const _TitoloFase(this.testo);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(
      testo.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

/// Il percorso della seduta: un punto per passo, uniti da una linea. Pieno e
/// nel colore del tema per la parte principale, vuoto per il resto. Senza
/// [punto] solo la linea (i recuperi tra un tratto e l'altro).
class _SegnoFase extends StatelessWidget {
  final String fase;
  final bool ultimo;
  final bool punto;
  const _SegnoFase({
    required this.fase,
    required this.ultimo,
    this.punto = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final principale = fase == 'principale';
    return SizedBox(
      width: 14,
      child: Column(
        children: [
          if (punto) ...[
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
                        color: fase == 'mobilità'
                            ? coloreSport('Mobilità')
                            : scheme.outline,
                      ),
              ),
            ),
          ],
          if (!ultimo)
            Expanded(child: Container(width: 2, color: scheme.outlineVariant)),
        ],
      ),
    );
  }
}
