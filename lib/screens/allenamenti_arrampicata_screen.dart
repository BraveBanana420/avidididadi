import 'package:flutter/material.dart';

import '../avviso.dart';
import '../allenamento_arrampicata.dart';
import '../app_state.dart';
import '../arrampicata.dart';
import '../models.dart';
import '../pulse.dart';
import '../widgets.dart';
import 'esecuzione_screen.dart';

// La raccolta degli allenamenti di arrampicata: elenco, dettaglio (inizia
// ora, aggiungi al piano) e builder per crearli o cambiarli a mano.

IconData iconaTipoArrampicata(String tipo) => switch (tipo) {
  'trave' => Icons.horizontal_rule,
  'boulder' => Icons.landscape_outlined,
  'circuito' => Icons.loop,
  'campus' => Icons.stairs_outlined,
  'vie' => Icons.terrain,
  _ => Icons.more_horiz,
};

/// Elenco degli allenamenti, come schede da riusare.
class AllenamentiArrampicataScreen extends StatelessWidget {
  final AppState state;
  const AllenamentiArrampicataScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('Allenamenti di arrampicata')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ModificaArrampicataScreen(state: state),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuovo'),
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final lista = [...state.allenamentiArrampicata]
            ..sort(
              (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
            );
          if (lista.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Ancora nessun allenamento', style: t.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  'Crealo con "Nuovo", oppure chiedilo al tuo assistente (per '
                  "esempio mandandogli lo screenshot di un'altra app): nella sua "
                  'risposta condividi il blocco con l\'app e qui trovi '
                  'l\'allenamento, pronto da mettere nel calendario.',
                ),
              ],
            );
          }
          // Raggruppati per categoria.
          final perCategoria = <String, List<AllenamentoArrampicata>>{};
          for (final a in lista) {
            (perCategoria[a.categoria.isEmpty ? 'Altri' : a.categoria] ??= [])
                .add(a);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final e in perCategoria.entries) ...[
                TitoloSezione(e.key),
                for (final a in e.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Scheda(state: state, allenamento: a),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Scheda extends StatelessWidget {
  final AppState state;
  final AllenamentoArrampicata allenamento;
  const _Scheda({required this.state, required this.allenamento});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final a = allenamento;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DettaglioArrampicataScreen(state: state, id: a.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: coloreSport(sportArrampicata),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.nome, style: t.titleMedium),
                    if (a.descrizione.isNotEmpty)
                      Text(
                        a.descrizione,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall,
                      )
                    else
                      Text(
                        a.esercizi.map((e) => e.nome).join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (final tipo in a.tipi)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Tooltip(
                              message: tipiArrampicata[tipo]!,
                              child: Icon(
                                iconaTipoArrampicata(tipo),
                                size: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text('${a.minuti} min', style: t.labelLarge),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un allenamento: esercizi, e i tasti per farlo subito o metterlo nel piano.
class DettaglioArrampicataScreen extends StatelessWidget {
  final AppState state;
  final String id;
  const DettaglioArrampicataScreen({
    super.key,
    required this.state,
    required this.id,
  });

  Future<void> _aggiungi(BuildContext context, AllenamentoArrampicata a) async {
    final oggi = soloData(DateTime.now());
    final data = await showDatePicker(
      context: context,
      initialDate: oggi,
      firstDate: oggi,
      lastDate: oggi.add(const Duration(days: 365)),
      helpText: 'In che giorno?',
    );
    if (data == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await state.programmaArrampicata(a, data);
    messenger.showSnackBar(
      avviso(
        content: Text(
          ok
              ? '${a.nome} è nel calendario: ${dataLunga(data)}.'
              : 'Non è stato possibile: scegli oggi o un giorno dopo.',
        ),
      ),
    );
  }

  Future<void> _elimina(BuildContext context, AllenamentoArrampicata a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Eliminare "${a.nome}"?'),
        content: const Text(
          'Sparisce dalla raccolta. Le sedute già nel calendario restano.',
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
    if (ok != true || !context.mounted) return;
    final navigator = Navigator.of(context);
    await state.eliminaAllenamentoArrampicata(a.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final a = state.allenamentiArrampicata
            .where((x) => x.id == id)
            .firstOrNull;
        if (a == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Allenamento non trovato.')),
          );
        }
        return Scaffold(
          bottomNavigationBar: const MargineBarraSistema(),
          appBar: AppBar(
            title: Text(a.nome),
            actions: [
              IconButton(
                tooltip: 'Modifica',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ModificaArrampicataScreen(state: state, allenamento: a),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Elimina',
                onPressed: () => _elimina(context, a),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (a.categoria.isNotEmpty) PillolaPulse(a.categoria),
                  for (final tipo in a.tipi)
                    Chip(
                      avatar: Icon(iconaTipoArrampicata(tipo), size: 16),
                      label: Text(tipiArrampicata[tipo]!),
                      visualDensity: VisualDensity.compact,
                    ),
                  Chip(
                    avatar: const Icon(Icons.schedule, size: 16),
                    label: Text('${a.minuti} min'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (a.descrizione.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(a.descrizione, style: t.bodyLarge),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PulsantePrincipale(
                      onPressed: () => avviaAllenamento(
                        context,
                        state,
                        sport: sportArrampicata,
                        tipo: a.nome,
                        nome: a.nome,
                        passi: a.passi('libera'),
                        libera: true,
                      ),
                      icona: Icons.play_arrow,
                      testo: 'Inizia ora',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _aggiungi(context, a),
                icon: const Icon(Icons.event_available),
                label: const Text('Aggiungi al piano'),
              ),
              const SizedBox(height: 20),
              Text('Esercizi', style: t.titleMedium),
              const SizedBox(height: 4),
              SuperficiePulse(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    for (final (k, e) in a.esercizi.indexed)
                      RigaPulse(
                        titolo: e.nome,
                        sottotitolo: [
                          e.riassunto,
                          if (e.note.isNotEmpty) e.note,
                        ].where((x) => x.isNotEmpty).join('\n'),
                        linea: k < a.esercizi.length - 1,
                      ),
                  ],
                ),
              ),
              if (a.daSegnare.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.edit_note, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alla fine segna: ${a.daSegnare}',
                        style: t.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Il builder: nome, categoria, tipo, durata, descrizione ed esercizi.
class ModificaArrampicataScreen extends StatefulWidget {
  final AppState state;
  final AllenamentoArrampicata? allenamento; // null: nuovo
  const ModificaArrampicataScreen({
    super.key,
    required this.state,
    this.allenamento,
  });

  @override
  State<ModificaArrampicataScreen> createState() =>
      _ModificaArrampicataScreenState();
}

class _ModificaArrampicataScreenState extends State<ModificaArrampicataScreen> {
  late final a = widget.allenamento;
  late final _nome = TextEditingController(text: a?.nome ?? '');
  late final _categoria = TextEditingController(text: a?.categoria ?? '');
  late final _durata = TextEditingController(
    text: (a?.durataMin ?? 0) > 0 ? '${a!.durataMin}' : '',
  );
  late final _descrizione = TextEditingController(text: a?.descrizione ?? '');
  late final _daSegnare = TextEditingController(text: a?.daSegnare ?? '');
  late Set<String> _tipi = {...?a?.tipi};
  late List<EsercizioArrampicata> _esercizi = [...?a?.esercizi];
  String? _errore;

  @override
  void dispose() {
    for (final c in [_nome, _categoria, _durata, _descrizione, _daSegnare]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salva() async {
    final nome = _nome.text.trim();
    final durata = int.tryParse(_durata.text.trim()) ?? 0;
    if (nome.isEmpty || _esercizi.isEmpty) {
      setState(() => _errore = 'Servono il nome e almeno un esercizio.');
      return;
    }
    if (durata < 0 || durata > 300) {
      setState(() => _errore = 'La durata va da 0 a 300 minuti.');
      return;
    }
    final navigator = Navigator.of(context);
    await widget.state.salvaAllenamentoArrampicata(
      AllenamentoArrampicata(
        id: a?.id ?? nuovoIdArrampicata(DateTime.now()),
        nome: nome.length > 60 ? nome.substring(0, 60) : nome,
        categoria: _categoria.text.trim(),
        tipi: _tipi,
        durataMin: durata,
        descrizione: _descrizione.text.trim(),
        daSegnare: _daSegnare.text.trim(),
        esercizi: _esercizi,
      ),
    );
    navigator.pop();
  }

  Future<void> _esercizio([int? i]) async {
    final e = await showModalBottomSheet<EsercizioArrampicata>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          _FoglioEsercizio(esercizio: i == null ? null : _esercizi[i]),
    );
    if (e == null) return;
    setState(() {
      _esercizi = [..._esercizi];
      if (i == null) {
        _esercizi.add(e);
      } else {
        _esercizi[i] = e;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: Text(a == null ? 'Nuovo allenamento' : 'Modifica'),
        actions: [TextButton(onPressed: _salva, child: const Text('Salva'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nome,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome',
              hintText: 'es. 50-50, 7:3s 40%',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _categoria,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Categoria'),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in categorieArrampicata)
                ActionChip(
                  label: Text(c),
                  onPressed: () => setState(() => _categoria.text = c),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Dove', style: t.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in tipiArrampicata.entries)
                FilterChip(
                  avatar: Icon(iconaTipoArrampicata(e.key), size: 16),
                  label: Text(e.value),
                  selected: _tipi.contains(e.key),
                  onSelected: (v) => setState(
                    () => _tipi = v
                        ? {..._tipi, e.key}
                        : ({..._tipi}..remove(e.key)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _durata,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Durata',
              suffixText: 'min',
              helperText: 'Vuoto = la calcolo dagli esercizi.',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descrizione,
            minLines: 2,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Descrizione'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _daSegnare,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Cosa segnare alla fine',
              hintText: 'es. il grado medio delle due parti',
            ),
          ),
          const SizedBox(height: 20),
          Text('Esercizi', style: t.titleMedium),
          const SizedBox(height: 4),
          for (final (k, e) in _esercizi.indexed)
            Card(
              child: ListTile(
                title: Text(e.nome),
                subtitle: Text(e.riassunto),
                onTap: () => _esercizio(k),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (k > 0)
                      IconButton(
                        tooltip: 'Sposta su',
                        onPressed: () => setState(() {
                          _esercizi = [..._esercizi];
                          final x = _esercizi.removeAt(k);
                          _esercizi.insert(k - 1, x);
                        }),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    IconButton(
                      tooltip: 'Togli',
                      onPressed: () => setState(
                        () => _esercizi = [..._esercizi]..removeAt(k),
                      ),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => _esercizio(),
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi un esercizio'),
          ),
          if (_errore != null) ...[
            const SizedBox(height: 12),
            Text(
              _errore!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          SizedBox(height: spazioBarra(context)),
        ],
      ),
    );
  }
}

/// Un esercizio: serie, ripetizioni, tempi e intensità.
class _FoglioEsercizio extends StatefulWidget {
  final EsercizioArrampicata? esercizio;
  const _FoglioEsercizio({this.esercizio});

  @override
  State<_FoglioEsercizio> createState() => _FoglioEsercizioState();
}

class _FoglioEsercizioState extends State<_FoglioEsercizio> {
  late final e = widget.esercizio;
  late final _nome = TextEditingController(text: e?.nome ?? '');
  late final _serie = TextEditingController(text: '${e?.serie ?? 1}');
  late final _rip = TextEditingController(text: '${e?.ripetizioni ?? 1}');
  late final _lavoro = TextEditingController(
    text: (e?.lavoroS ?? 0) > 0 ? '${e!.lavoroS}' : '',
  );
  late final _pausa = TextEditingController(
    text: (e?.pausaS ?? 0) > 0 ? '${e!.pausaS}' : '',
  );
  late final _recupero = TextEditingController(
    text: (e?.recuperoS ?? 0) > 0 ? '${e!.recuperoS}' : '',
  );
  late final _intensita = TextEditingController(text: e?.intensita ?? '');
  late final _note = TextEditingController(text: e?.note ?? '');
  String? _errore;

  @override
  void dispose() {
    for (final c in [
      _nome,
      _serie,
      _rip,
      _lavoro,
      _pausa,
      _recupero,
      _intensita,
      _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _ok() {
    int? n(TextEditingController c, int min, int max) {
      final t = c.text.trim();
      if (t.isEmpty) return min == 1 ? 1 : 0;
      final v = int.tryParse(t);
      return v == null || v < min || v > max ? null : v;
    }

    final serie = n(_serie, 1, 20);
    final rip = n(_rip, 1, 100);
    final lavoro = n(_lavoro, 0, 3600);
    final pausa = n(_pausa, 0, 3600);
    final recupero = n(_recupero, 0, 3600);
    if (_nome.text.trim().isEmpty ||
        serie == null ||
        rip == null ||
        lavoro == null ||
        pausa == null ||
        recupero == null) {
      setState(
        () => _errore =
            'Controlla: nome, serie 1-20, ripetizioni 1-100, secondi 0-3600.',
      );
      return;
    }
    Navigator.pop(
      context,
      EsercizioArrampicata(
        nome: _nome.text.trim(),
        serie: serie,
        ripetizioni: rip,
        lavoroS: lavoro,
        pausaS: pausa,
        recuperoS: recupero,
        intensita: _intensita.text.trim(),
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget numero(TextEditingController c, String etichetta, {String? unita}) =>
        Expanded(
          child: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: etichetta,
              suffixText: unita,
            ),
          ),
        );
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + spazioInBasso(context)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            TextField(
              controller: _nome,
              autofocus: e == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Esercizio',
                hintText: 'es. Sospensioni, Vie, Blocchi',
              ),
            ),
            Row(
              spacing: 12,
              children: [numero(_serie, 'Serie'), numero(_rip, 'Ripetizioni')],
            ),
            Row(
              spacing: 12,
              children: [
                numero(_lavoro, 'Lavoro', unita: 's'),
                numero(_pausa, 'Pausa', unita: 's'),
                numero(_recupero, 'Tra le serie', unita: 's'),
              ],
            ),
            Text(
              'Lavoro vuoto = finché non hai finito (una via, un blocco): '
              'tocchi "Fatto". Pausa: tra una ripetizione e l\'altra.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextField(
              controller: _intensita,
              decoration: const InputDecoration(
                labelText: 'Intensità o grado',
                hintText: 'es. 40%, 6b+, facile',
              ),
            ),
            TextField(
              controller: _note,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            if (_errore != null)
              Text(
                _errore!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            FilledButton(onPressed: _ok, child: const Text('OK')),
          ],
        ),
      ),
    );
  }
}
