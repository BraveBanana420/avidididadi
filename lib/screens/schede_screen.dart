import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../esercizi.dart';
import '../models.dart';
import '../potenza.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../scheda.dart';
import '../widgets.dart';

/// Le schede scritte a mano: forza (per esempio dal personal trainer) e
/// corsa, bici e nuoto (per esempio dall'allenatore o dal gruppo).
class SchedeScreen extends StatelessWidget {
  final AppState state;
  const SchedeScreen({super.key, required this.state});

  void _apri(BuildContext context, Scheda? s, [String sport = 'Forza']) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SchedaScreen(state: state, scheda: s, sport: sport),
        ),
      );

  /// Prima lo sport, poi la scheda.
  Future<void> _nuova(BuildContext context) async {
    final sport = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (sp, testo) in const [
                ('Forza', 'Esercizi, serie, ripetizioni e kg'),
                ('Corsa', 'Passi a tempo o distanza, con zona o passo'),
                ('Bici', 'Passi a tempo o distanza, con zona'),
                ('Nuoto', 'Vasche, passo per 100 m e pause'),
              ])
                if (state.attivitaScelta(sp))
                  ListTile(
                    leading: Icon(iconaSport(sp), color: coloreSport(sp)),
                    title: Text(sp),
                    subtitle: Text(testo),
                    onTap: () => Navigator.pop(c, sp),
                  ),
            ],
          ),
        ),
      ),
    );
    if (sport != null && context.mounted) _apri(context, null, sport);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('Le mie schede')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final oggi = soloData(DateTime.now());
          final inCorso = [
            for (final s in state.schede.reversed)
              if (!s.archiviata && (s.fine == null || !oggi.isAfter(s.fine!)))
                s,
          ];
          final archivio = [
            for (final s in state.schede.reversed)
              if (!inCorso.contains(s)) s,
          ];
          Widget riga(Scheda s, bool linea) => RigaPulse(
            segno: IconaQuadrata(iconaSport(s.sport), evidenza: s.valida(oggi)),
            titolo: s.nome.isEmpty
                ? 'Scheda di ${s.sport.toLowerCase()}'
                : s.nome,
            sottotitolo: [
              descriviValidita(s),
              s.giorni.map((g) => g.nome).join(', '),
            ].where((x) => x.isNotEmpty).join(' · '),
            linea: linea,
            onTap: () => _apri(context, s),
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                'Scrivi la scheda del tuo personal trainer o del tuo '
                'allenatore: forza, corsa, bici o nuoto. Nei giorni che scegli '
                'prende il posto delle sedute preparate dall\'app, che non la '
                'cambia da sola.',
                style: t.bodyMedium,
              ),
              const SizedBox(height: 16),
              PulsantePrincipale(
                onPressed: () => _nuova(context),
                icona: Icons.add,
                testo: 'Nuova scheda',
              ),
              if (inCorso.isNotEmpty) ...[
                const TitoloSezione('In corso'),
                SuperficiePulse(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final (i, s) in inCorso.indexed)
                        riga(s, i < inCorso.length - 1),
                    ],
                  ),
                ),
              ],
              if (archivio.isNotEmpty) ...[
                const TitoloSezione('Finite'),
                SuperficiePulse(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final (i, s) in archivio.indexed)
                        riga(s, i < archivio.length - 1),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// "Dal 2 novembre al 16 novembre", "Dal 2 novembre, senza scadenza".
String descriviValidita(Scheda s) {
  String d(DateTime x) => '${x.day} ${mesiNomi[x.month - 1]}';
  if (s.archiviata) return 'Archiviata';
  return s.fine == null
      ? 'Dal ${d(s.inizio)}, senza scadenza'
      : 'Dal ${d(s.inizio)} al ${d(s.fine!)}';
}

const _iniziali = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
const _durate = [15, 30, 60];

/// Scrittura e modifica di una scheda.
class SchedaScreen extends StatefulWidget {
  final AppState state;
  final Scheda? scheda; // null: nuova
  final String sport; // per una scheda nuova
  const SchedaScreen({
    super.key,
    required this.state,
    this.scheda,
    this.sport = 'Forza',
  });

  @override
  State<SchedaScreen> createState() => _SchedaScreenState();
}

class _SchedaScreenState extends State<SchedaScreen> {
  late Scheda s =
      widget.scheda ??
      Scheda(
        id: 'sch-${DateTime.now().millisecondsSinceEpoch}',
        nome: '',
        sport: widget.sport,
        inizio: soloData(DateTime.now()),
        fine: soloData(DateTime.now()).add(const Duration(days: 14)),
        giorni: [
          GiornoScheda(
            nome: _nomeGiorno(0),
            giorni: _giorniSport().take(1).toSet(),
          ),
        ],
      );
  late final _nome = TextEditingController(text: s.nome);
  bool _modificata = false;

  String get _sport => widget.scheda?.sport ?? widget.sport;
  bool get _forza => stessoSport(_sport, 'Forza');

  String _nomeGiorno(int i) =>
      '${_forza ? 'Giorno' : 'Seduta'} ${String.fromCharCode(65 + i)}';

  /// I giorni della settimana con questo sport nella settimana tipo.
  Set<int> _giorniSport() => {
    for (final x in widget.state.settimana)
      if (stessoSport(x.sport, _sport)) x.giorno,
  };

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _cambia(Scheda nuova) => setState(() {
    s = nuova;
    _modificata = true;
  });

  void _cambiaGiorno(int i, GiornoScheda g) =>
      _cambia(s.copyWith(giorni: [...s.giorni]..[i] = g));

  Future<void> _salva() async {
    final navigator = Navigator.of(context);
    final vuoti = s.giorni.every((g) => g.esercizi.isEmpty);
    if (vuoti) {
      ScaffoldMessenger.of(context).showSnackBar(
        avviso(
          content: Text(
            _forza
                ? 'Aggiungi almeno un esercizio.'
                : 'Aggiungi almeno un passo.',
          ),
        ),
      );
      return;
    }
    await widget.state.salvaScheda(s.copyWith(nome: _nome.text.trim()));
    navigator.pop();
  }

  /// Mette lo sport della scheda nei giorni della settimana tipo che non
  /// lo hanno, dicendo prima cosa si toglie da ciascun giorno.
  Future<void> _modificaSettimana(Set<int> giorni) async {
    final messenger = ScaffoldMessenger.of(context);
    final state = widget.state;
    final prima = [...state.settimana];
    var settimana = prima;
    var cambiati = 0;
    for (final d in giorni.toList()..sort()) {
      final sostituendo = conSportNelGiorno(settimana, d, _sport);
      final scelta = await _conferma(
        d,
        sostituendo.tolti,
        sostituendo.aggiunto,
      );
      if (scelta == null) continue;
      settimana = scelta
          ? sostituendo.settimana
          : conSportNelGiorno(
              settimana,
              d,
              _sport,
              sostituisci: false,
            ).settimana;
      cambiati++;
    }
    if (cambiati == 0) return;
    state.settimana = settimana;
    await state.salvaSettimana(prima: prima);
    if (!mounted) return;
    setState(() {});
    messenger.showSnackBar(avviso(content: Text('Settimana tipo aggiornata.')));
  }

  /// true: sostituisci; false: aggiungi accanto; null: lascia com'è.
  Future<bool?> _conferma(int giorno, List<Slot> tolti, Slot aggiunto) {
    String descrivi(Slot x) => [
      titoloSessione(x.sport, x.tipo),
      x.fascia.toLowerCase(),
      '${x.durataMin} min',
    ].join(' · ');
    final nome = giorniSettimana[giorno - 1];
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('$nome nella settimana tipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aggiungo: ${descrivi(aggiunto)}.'),
            const SizedBox(height: 12),
            if (tolti.isEmpty)
              Text('$nome è un giorno di riposo: non tolgo niente.')
            else ...[
              const Text('Per fargli posto tolgo da questo giorno:'),
              for (final x in tolti) Text('• ${descrivi(x)}'),
              const SizedBox(height: 8),
              const Text('Oppure puoi tenerle e fare tutte e due le cose.'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Annulla'),
          ),
          if (tolti.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Tieni entrambe'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(tolti.isEmpty ? 'Aggiungi' : 'Sostituisci'),
          ),
        ],
      ),
    );
  }

  Future<void> _elimina() async {
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminare la scheda?'),
        content: const Text(
          'Le sedute già fatte restano. Da oggi tornano quelle preparate '
          'dall\'app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.state.eliminaScheda(s.id);
    navigator.pop();
  }

  Future<void> _scegliInizio() async {
    final d = await showDatePicker(
      context: context,
      initialDate: s.inizio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    final durata = s.durataGiorni;
    _cambia(
      s.copyWith(
        inizio: d,
        fine: () => durata == null ? null : d.add(Duration(days: durata - 1)),
      ),
    );
  }

  Future<bool> _confermaUscita() async {
    if (!_modificata) return true;
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Uscire senza salvare?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Esci'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Resta'),
          ),
        ],
      ),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final forza = _giorniSport();
    final durata = s.durataGiorni;
    final senzaForza = {
      for (final g in s.giorni)
        for (final d in g.giorni)
          if (!forza.contains(d)) d,
    };
    return PopScope(
      canPop: !_modificata,
      onPopInvokedWithResult: (fatto, _) async {
        if (fatto) return;
        final navigator = Navigator.of(context);
        if (await _confermaUscita()) navigator.pop();
      },
      child: Scaffold(
        bottomNavigationBar: const MargineBarraSistema(),
        appBar: AppBar(
          title: Text(
            '${widget.scheda == null ? 'Nuova scheda' : 'Scheda'} · $_sport',
          ),
          actions: [
            if (widget.scheda != null)
              IconButton(
                tooltip: 'Elimina',
                onPressed: _elimina,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextField(
              controller: _nome,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => _modificata = true,
              decoration: const InputDecoration(
                labelText: 'Nome della scheda',
                hintText: 'Es. Scheda di novembre',
              ),
            ),
            const TitoloSezione('Quanto dura'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final g in _durate)
                  ChoiceChip(
                    label: Text('$g giorni'),
                    selected: durata == g,
                    onSelected: (_) => _cambia(
                      s.copyWith(
                        fine: () => s.inizio.add(Duration(days: g - 1)),
                      ),
                    ),
                  ),
                ChoiceChip(
                  label: const Text('Finché non la cambio'),
                  selected: durata == null,
                  onSelected: (_) => _cambia(s.copyWith(fine: () => null)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text(descriviValidita(s), style: t.bodyMedium)),
                TextButton.icon(
                  onPressed: _scegliInizio,
                  icon: const Icon(Icons.event_outlined),
                  label: const Text('Inizio'),
                ),
              ],
            ),
            const TitoloSezione('Giorni'),
            Text(
              _forza
                  ? 'Ogni giorno della scheda (Busto, Gambe…) va nei giorni '
                        'della settimana che scegli. Valgono quelli con la '
                        'forza nella settimana tipo.'
                  : 'Ogni seduta della scheda (Ripetute, Lungo…) va nei '
                        'giorni della settimana che scegli. Valgono quelli con '
                        '${_sport.toLowerCase()} nella settimana tipo.',
              style: t.bodySmall,
            ),
            if (senzaForza.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${senzaForza.map((d) => giorniSettimana[d - 1]).join(', ')}: '
                  'nella settimana tipo non c\'è ${_sport.toLowerCase()}.',
                  style: t.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            if (senzaForza.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _modificaSettimana(senzaForza),
                  icon: const Icon(Icons.edit_calendar_outlined),
                  label: const Text('Modifica settimana'),
                ),
              ),
            const SizedBox(height: 8),
            for (final (i, g) in s.giorni.indexed) ...[
              _GiornoCard(
                state: widget.state,
                giorno: g,
                giorniForza: forza,
                sport: _sport,
                occupati: {
                  for (final (j, x) in s.giorni.indexed)
                    if (j != i) ...x.giorni,
                },
                cambia: (nuovo) => _cambiaGiorno(i, nuovo),
                elimina: s.giorni.length > 1
                    ? () => _cambia(
                        s.copyWith(giorni: [...s.giorni]..removeAt(i)),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () => _cambia(
                s.copyWith(
                  giorni: [
                    ...s.giorni,
                    GiornoScheda(nome: _nomeGiorno(s.giorni.length)),
                  ],
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                _forza ? 'Aggiungi un giorno' : 'Aggiungi una seduta',
              ),
            ),
            const SizedBox(height: 24),
            PulsantePrincipale(
              onPressed: _salva,
              icona: Icons.check,
              testo: 'Salva la scheda',
            ),
          ],
        ),
      ),
    );
  }
}

/// Un giorno della scheda: nome, giorni della settimana ed esercizi.
class _GiornoCard extends StatefulWidget {
  final AppState state;
  final GiornoScheda giorno;
  final Set<int> giorniForza; // con questo sport nella settimana tipo
  final String sport;
  final Set<int> occupati; // già presi da un altro giorno della scheda
  final ValueChanged<GiornoScheda> cambia;
  final VoidCallback? elimina;
  const _GiornoCard({
    required this.state,
    required this.giorno,
    required this.giorniForza,
    required this.sport,
    required this.occupati,
    required this.cambia,
    required this.elimina,
  });

  @override
  State<_GiornoCard> createState() => _GiornoCardState();
}

class _GiornoCardState extends State<_GiornoCard> {
  late final _nome = TextEditingController(text: widget.giorno.nome);

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  GiornoScheda get g => widget.giorno;

  @override
  void didUpdateWidget(_GiornoCard prima) {
    super.didUpdateWidget(prima);
    // Tolto un giorno sopra, questa scheda può mostrare un altro giorno.
    if (_nome.text.trim() != g.nome) _nome.text = g.nome;
  }

  bool get _forza => stessoSport(widget.sport, 'Forza');

  Future<void> _aggiungi() async {
    if (!_forza) {
      final nuovo = await modificaPasso(
        context,
        widget.sport,
        EsercizioScheda(
          nome: '',
          serie: 1,
          ripetizioni: '',
          recuperoS: 0,
          fase: g.esercizi.isEmpty ? 'riscaldamento' : 'principale',
          durataMin: '10',
        ),
      );
      if (nuovo == null) return;
      widget.cambia(g.copyWith(esercizi: [...g.esercizi, nuovo]));
      return;
    }
    final scelto = await Navigator.of(context).push<EsercizioScheda>(
      MaterialPageRoute(
        builder: (_) => SceltaEsercizioScreen(state: widget.state),
      ),
    );
    if (scelto == null || !mounted) return;
    final completo = await modificaEsercizio(context, scelto);
    if (completo == null) return;
    widget.cambia(g.copyWith(esercizi: [...g.esercizi, completo]));
  }

  Future<void> _modifica(int i) async {
    final e = _forza
        ? await modificaEsercizio(context, g.esercizi[i])
        : await modificaPasso(context, widget.sport, g.esercizi[i]);
    if (e == null) return;
    widget.cambia(g.copyWith(esercizi: [...g.esercizi]..[i] = e));
  }

  void _sposta(int i, int verso) {
    final l = [...g.esercizi];
    final x = l.removeAt(i);
    l.insert(i + verso, x);
    widget.cambia(g.copyWith(esercizi: l));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nome,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome del giorno',
                    hintText: 'Es. Busto',
                  ),
                  onChanged: (v) => widget.cambia(g.copyWith(nome: v.trim())),
                ),
              ),
              if (widget.elimina != null)
                IconButton(
                  tooltip: 'Togli questo giorno',
                  onPressed: widget.elimina,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  tooltip: giorniSettimana[d - 1],
                  label: Text(_iniziali[d - 1]),
                  showCheckmark: false,
                  // Con lo sport nella settimana tipo: bordo colorato; scelto:
                  // pieno dello stesso colore, un po' più chiaro. Scelto ma
                  // senza lo sport nella settimana: rosso.
                  side: BorderSide(
                    color:
                        g.giorni.contains(d) && !widget.giorniForza.contains(d)
                        ? scheme.error
                        : widget.giorniForza.contains(d)
                        ? scheme.primary
                        : scheme.outlineVariant,
                    width: widget.giorniForza.contains(d) ? 1.5 : 1,
                  ),
                  selectedColor: Color.lerp(
                    g.giorni.contains(d) && !widget.giorniForza.contains(d)
                        ? scheme.error
                        : scheme.primary,
                    Colors.white,
                    0.25,
                  ),
                  labelStyle: g.giorni.contains(d)
                      ? TextStyle(
                          color: widget.giorniForza.contains(d)
                              ? scheme.onPrimary
                              : scheme.onError,
                          fontWeight: FontWeight.w800,
                        )
                      : null,
                  selected: g.giorni.contains(d),
                  onSelected: widget.occupati.contains(d)
                      ? null
                      : (on) => widget.cambia(
                          g.copyWith(
                            giorni: on
                                ? {...g.giorni, d}
                                : ({...g.giorni}..remove(d)),
                          ),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (g.esercizi.isEmpty)
            Text(
              _forza ? 'Nessun esercizio.' : 'Nessun passo.',
              style: t.bodySmall,
            ),
          Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (final (i, e) in g.esercizi.indexed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.nome),
                    subtitle: Text(e.riassunto),
                    onTap: () => _modifica(i),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Altro',
                      onSelected: (v) => switch (v) {
                        'su' => _sposta(i, -1),
                        'giu' => _sposta(i, 1),
                        _ => widget.cambia(
                          g.copyWith(esercizi: [...g.esercizi]..removeAt(i)),
                        ),
                      },
                      itemBuilder: (_) => [
                        if (i > 0)
                          const PopupMenuItem(
                            value: 'su',
                            child: Text('Sposta su'),
                          ),
                        if (i < g.esercizi.length - 1)
                          const PopupMenuItem(
                            value: 'giu',
                            child: Text('Sposta giù'),
                          ),
                        const PopupMenuItem(value: 'via', child: Text('Togli')),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: _aggiungi,
            icon: const Icon(Icons.add),
            label: Text(_forza ? 'Aggiungi esercizio' : 'Aggiungi un passo'),
          ),
        ],
      ),
    );
  }
}

/// I kg scritti come "20", "20 22,5 25" o "20; 22.5; 25", nell'ordine.
List<double> leggiKgSerie(String testo) => [
  for (final x
      in testo.replaceAll(', ', ' ').replaceAll(';', ' ').split(RegExp(r'\s+')))
    if (double.tryParse(x.replaceAll(',', '.')) case final v? when v >= 0) v,
];

/// Serie, ripetizioni, recupero, kg e note di un esercizio della scheda.
Future<EsercizioScheda?> modificaEsercizio(
  BuildContext context,
  EsercizioScheda e,
) {
  final rip = TextEditingController(text: e.ripetizioni);
  final rec = TextEditingController(text: '${e.recuperoS}');
  final kg = TextEditingController(text: e.kg.map(fmtKg).join(' '));
  final note = TextEditingController(text: e.note);
  var serie = e.serie;
  return showModalBottomSheet<EsercizioScheda>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => StatefulBuilder(
      builder: (c, aggiorna) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(c).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(e.nome, style: Theme.of(c).textTheme.titleLarge),
              Row(
                children: [
                  const Expanded(child: Text('Serie')),
                  IconButton.filledTonal(
                    tooltip: 'Una serie in meno',
                    onPressed: serie > 1 ? () => aggiorna(() => serie--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '$serie',
                      textAlign: TextAlign.center,
                      style: Theme.of(c).textTheme.titleLarge,
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Una serie in più',
                    onPressed: serie < 20
                        ? () => aggiorna(() => serie++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              TextField(
                controller: rip,
                decoration: const InputDecoration(
                  labelText: 'Ripetizioni',
                  helperText:
                      'Es. 10, 8-10, oppure 30 s per gli esercizi a tempo',
                ),
              ),
              TextField(
                controller: rec,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Recupero (secondi)',
                ),
              ),
              TextField(
                controller: kg,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Kg',
                  helperText:
                      'Un peso per tutte le serie (20), oppure uno per serie '
                      '(20 22,5 25). Vuoto a corpo libero.',
                  helperMaxLines: 2,
                ),
              ),
              TextField(
                controller: note,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note del personal trainer',
                  hintText: 'Es. scendi in 3 secondi',
                ),
              ),
              PulsantePrincipale(
                onPressed: () => Navigator.pop(
                  c,
                  e.copyWith(
                    serie: serie,
                    ripetizioni: rip.text.trim().isEmpty
                        ? '10'
                        : rip.text.trim(),
                    recuperoS: int.tryParse(rec.text.trim()) ?? 0,
                    kg: leggiKgSerie(kg.text),
                    note: note.text.trim(),
                  ),
                ),
                icona: Icons.check,
                testo: 'Fatto',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Scelta di un esercizio dal catalogo (con l'attrezzatura che hai), oppure
/// scritto a mano se non c'è.
class SceltaEsercizioScreen extends StatefulWidget {
  final AppState state;
  const SceltaEsercizioScreen({super.key, required this.state});

  @override
  State<SceltaEsercizioScreen> createState() => _SceltaEsercizioScreenState();
}

class _SceltaEsercizioScreenState extends State<SceltaEsercizioScreen> {
  String _cerca = '';
  bool _tutti = false;

  Future<void> _aMano() async {
    final navigator = Navigator.of(context);
    final c = TextEditingController(text: _cerca);
    final nome = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Esercizio non in catalogo'),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nome'),
          onSubmitted: (x) => Navigator.pop(d, x),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, c.text),
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
    c.dispose();
    if (nome == null || nome.trim().isEmpty) return;
    navigator.pop(EsercizioScheda(nome: nome.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final lista = cercaEsercizi(
      state.esercizi,
      state.attrezzatura,
      _cerca,
      tutti: _tutti,
    );
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('Scegli un esercizio')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              autofocus: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cerca (es. lat, panca, squat)',
              ),
              onChanged: (v) => setState(() => _cerca = v),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              title: const Text('Solo con la mia attrezzatura'),
              value: !_tutti,
              onChanged: (v) => setState(() => _tutti = !v),
            ),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Non c\'è? Scrivilo a mano'),
                    onTap: _aMano,
                  ),
                  for (final e in lista)
                    ListTile(
                      leading: Icon(iconaSport('Forza')),
                      title: Text(e.nome),
                      subtitle: Text(
                        '${nomiSchemi[e.schema] ?? e.schema} · '
                        '${e.descrizioneAttrezzi}',
                      ),
                      onTap: () => Navigator.pop(
                        context,
                        EsercizioScheda(esercizio: e.id, nome: e.nome),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _fasi = [
  ('riscaldamento', 'Riscaldamento'),
  ('principale', 'Principale'),
  ('defaticamento', 'Defaticamento'),
];

/// Un passo di corsa, bici o nuoto: fase, cosa fare, quante volte, a tempo o
/// a distanza, zona o passo, recupero tra le ripetizioni.
Future<EsercizioScheda?> modificaPasso(
  BuildContext context,
  String sport,
  EsercizioScheda e,
) {
  final nuoto = stessoSport(sport, 'Nuoto');
  final nome = TextEditingController(text: e.nome);
  var aDistanza = e.distanzaM.isNotEmpty || (nuoto && e.durataMin.isEmpty);
  final quanto = TextEditingController(
    text: aDistanza ? e.distanzaM : e.durataMin,
  );
  final zona = RegExp(r'zona ([1-5])').firstMatch(e.intensita);
  var scelta = zona != null
      ? 'zona ${zona.group(1)}'
      : e.intensita.startsWith('passo')
      ? 'passo'
      : intensitaInWatt(e.intensita)
      ? 'watt'
      : '';
  final watt = TextEditingController(text: scelta == 'watt' ? e.intensita : '');
  final secondario = TextEditingController(text: e.obiettivo2);
  final passo = TextEditingController(
    text: e.intensita.startsWith('passo')
        ? e.intensita.substring(5).trim()
        : '',
  );
  final rec = TextEditingController(
    text: e.recuperoS > 0 ? '${e.recuperoS}' : '',
  );
  final note = TextEditingController(text: e.note);
  var fase = e.fase;
  var volte = e.serie;
  return showModalBottomSheet<EsercizioScheda>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => StatefulBuilder(
      builder: (c, aggiorna) {
        final t = Theme.of(c).textTheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(c).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text('Passo di ${sport.toLowerCase()}', style: t.titleLarge),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final (f, testo) in _fasi)
                      ChoiceChip(
                        label: Text(testo),
                        selected: fase == f,
                        onSelected: (_) => aggiorna(() => fase = f),
                      ),
                  ],
                ),
                TextField(
                  controller: nome,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Cosa fare',
                    hintText: nuoto
                        ? 'Es. Stile libero, gambe con tavoletta'
                        : 'Es. Corsa facile, ripetute, salita',
                  ),
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Quante volte')),
                    IconButton.filledTonal(
                      tooltip: 'Una in meno',
                      onPressed: volte > 1
                          ? () => aggiorna(() => volte--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$volte',
                        textAlign: TextAlign.center,
                        style: t.titleLarge,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Una in più',
                      onPressed: volte < 50
                          ? () => aggiorna(() => volte++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('A tempo'),
                      icon: Icon(Icons.timer_outlined),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('A distanza'),
                      icon: Icon(Icons.straighten),
                    ),
                  ],
                  selected: {aDistanza},
                  onSelectionChanged: (v) =>
                      aggiorna(() => aDistanza = v.first),
                ),
                TextField(
                  controller: quanto,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: aDistanza ? 'Metri' : 'Minuti',
                    hintText: aDistanza ? 'Es. 400' : 'Es. 10, oppure 1,5',
                  ),
                ),
                Text('Obiettivo principale', style: t.titleSmall),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: const Text('Libera'),
                      selected: scelta.isEmpty,
                      onSelected: (_) => aggiorna(() => scelta = ''),
                    ),
                    for (var z = 1; z <= 5; z++)
                      ChoiceChip(
                        label: Text('Zona $z'),
                        selected: scelta == 'zona $z',
                        onSelected: (_) => aggiorna(() => scelta = 'zona $z'),
                      ),
                    if (stessoSport(sport, 'Bici'))
                      ChoiceChip(
                        label: const Text('Watt'),
                        selected: scelta == 'watt',
                        onSelected: (_) => aggiorna(() => scelta = 'watt'),
                      ),
                    if (!stessoSport(sport, 'Bici'))
                      ChoiceChip(
                        label: const Text('Passo'),
                        selected: scelta == 'passo',
                        onSelected: (_) => aggiorna(() => scelta = 'passo'),
                      ),
                  ],
                ),
                if (scelta == 'passo')
                  TextField(
                    controller: passo,
                    decoration: InputDecoration(
                      labelText: 'Passo',
                      hintText: nuoto ? 'Es. 1:50/100 m' : 'Es. 5:00/km',
                    ),
                  ),
                if (scelta == 'watt')
                  TextField(
                    controller: watt,
                    decoration: const InputDecoration(
                      labelText: 'Watt',
                      hintText: 'Es. 200, oppure 190-210, oppure 88-94%',
                    ),
                  ),
                TextField(
                  controller: secondario,
                  decoration: InputDecoration(
                    labelText: 'Obiettivo secondario (facoltativo)',
                    hintText: stessoSport(sport, 'Bici')
                        ? 'Es. 85-90 rpm'
                        : stessoSport(sport, 'Corsa')
                        ? 'Es. 170-180 ppm'
                        : 'Es. 40 bracciate al minuto',
                  ),
                ),
                TextField(
                  controller: rec,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Recupero (secondi)',
                    helperText: nuoto
                        ? 'Pausa a bordo vasca dopo ogni ripetizione'
                        : 'Tra una ripetizione e l\'altra; vuoto se non c\'è',
                  ),
                ),
                TextField(
                  controller: note,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
                PulsantePrincipale(
                  onPressed: () {
                    final q = quanto.text.trim().replaceAll(',', '.');
                    if ((double.tryParse(q) ?? 0) <= 0) {
                      ScaffoldMessenger.of(c).showSnackBar(
                        avviso(
                          content: Text(
                            aDistanza ? 'Scrivi i metri.' : 'Scrivi i minuti.',
                          ),
                        ),
                      );
                      return;
                    }
                    final wattScritti = obiettivoWatt(watt.text);
                    if (scelta == 'watt' && wattScritti.isEmpty) {
                      ScaffoldMessenger.of(c).showSnackBar(
                        avviso(
                          content: Text(
                            'Scrivi i watt: per esempio 200, 190-210 o 88-94%.',
                          ),
                        ),
                      );
                      return;
                    }
                    final testo = nome.text.trim();
                    Navigator.pop(
                      c,
                      e.copyWith(
                        nome: testo.isEmpty
                            ? _fasi.firstWhere((x) => x.$1 == fase).$2
                            : testo,
                        fase: fase,
                        serie: volte,
                        durataMin: aDistanza ? '' : q,
                        distanzaM: aDistanza
                            ? '${double.parse(q).round()}'
                            : '',
                        intensita: scelta == 'passo'
                            ? (passo.text.trim().isEmpty
                                  ? ''
                                  : 'passo ${passo.text.trim()}')
                            : scelta == 'watt'
                            ? wattScritti
                            : scelta,
                        obiettivo2: normalizzaSecondario(
                          secondario.text,
                          sport,
                        ),
                        recuperoS: int.tryParse(rec.text.trim()) ?? 0,
                        note: note.text.trim(),
                      ),
                    );
                  },
                  icona: Icons.check,
                  testo: 'Fatto',
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
