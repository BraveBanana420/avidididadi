import 'package:flutter/material.dart';

import '../app_state.dart';
import '../esercizi.dart';
import '../models.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../scheda.dart';
import '../widgets.dart';

/// Le schede di forza scritte a mano (per esempio dal personal trainer).
class SchedeScreen extends StatelessWidget {
  final AppState state;
  const SchedeScreen({super.key, required this.state});

  void _apri(BuildContext context, SchedaForza? s) => Navigator.of(context)
      .push(
        MaterialPageRoute<void>(
          builder: (_) => SchedaScreen(state: state, scheda: s),
        ),
      );

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
          Widget riga(SchedaForza s, bool linea) => RigaPulse(
            segno: IconaQuadrata(
              Icons.assignment_outlined,
              evidenza: s.valida(oggi),
            ),
            titolo: s.nome.isEmpty ? 'Scheda' : s.nome,
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
                'Scrivi la scheda del tuo personal trainer: esercizi, serie, '
                'ripetizioni e pesi. Nei giorni che scegli prende il posto '
                'della forza preparata dall\'app, che non la cambia da sola.',
                style: t.bodyMedium,
              ),
              const SizedBox(height: 16),
              PulsantePrincipale(
                onPressed: () => _apri(context, null),
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
String descriviValidita(SchedaForza s) {
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
  final SchedaForza? scheda; // null: nuova
  const SchedaScreen({super.key, required this.state, this.scheda});

  @override
  State<SchedaScreen> createState() => _SchedaScreenState();
}

class _SchedaScreenState extends State<SchedaScreen> {
  late SchedaForza s =
      widget.scheda ??
      SchedaForza(
        id: 'sch-${DateTime.now().millisecondsSinceEpoch}',
        nome: '',
        inizio: soloData(DateTime.now()),
        fine: soloData(DateTime.now()).add(const Duration(days: 14)),
        giorni: [
          GiornoScheda(
            nome: 'Giorno A',
            giorni: _giorniForza().take(1).toSet(),
          ),
        ],
      );
  late final _nome = TextEditingController(text: s.nome);
  bool _modificata = false;

  /// I giorni della settimana con la forza nella settimana tipo.
  Set<int> _giorniForza() => {
    for (final x in widget.state.settimana)
      if (stessoSport(x.sport, 'Forza')) x.giorno,
  };

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _cambia(SchedaForza nuova) => setState(() {
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
        const SnackBar(content: Text('Aggiungi almeno un esercizio.')),
      );
      return;
    }
    await widget.state.salvaScheda(s.copyWith(nome: _nome.text.trim()));
    navigator.pop();
  }

  Future<void> _elimina() async {
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminare la scheda?'),
        content: const Text(
          'Le sedute già fatte restano. Da oggi la forza torna quella '
          'preparata dall\'app.',
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
    final forza = _giorniForza();
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
          title: Text(widget.scheda == null ? 'Nuova scheda' : 'Scheda'),
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
              'Ogni giorno della scheda (Busto, Gambe…) va nei giorni della '
              'settimana che scegli. Valgono quelli con la forza nella '
              'settimana tipo.',
              style: t.bodySmall,
            ),
            if (senzaForza.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${senzaForza.map((d) => giorniSettimana[d - 1]).join(', ')}: '
                  'nella settimana tipo non c\'è forza, aggiungila lì.',
                  style: t.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            for (final (i, g) in s.giorni.indexed) ...[
              _GiornoCard(
                state: widget.state,
                giorno: g,
                giorniForza: forza,
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
                    GiornoScheda(
                      nome:
                          'Giorno ${String.fromCharCode(65 + s.giorni.length)}',
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi un giorno'),
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
  final Set<int> giorniForza;
  final Set<int> occupati; // già presi da un altro giorno della scheda
  final ValueChanged<GiornoScheda> cambia;
  final VoidCallback? elimina;
  const _GiornoCard({
    required this.state,
    required this.giorno,
    required this.giorniForza,
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

  Future<void> _aggiungi() async {
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
    final e = await modificaEsercizio(context, g.esercizi[i]);
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
                  // Con la forza nella settimana tipo: bordo pieno.
                  side: widget.giorniForza.contains(d)
                      ? BorderSide(color: scheme.primary)
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
          if (g.esercizi.isEmpty) Text('Nessun esercizio.', style: t.bodySmall),
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
            label: const Text('Aggiungi esercizio'),
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
