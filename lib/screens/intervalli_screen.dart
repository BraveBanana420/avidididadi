import 'package:flutter/material.dart';

import '../app_state.dart';
import '../intervalli.dart';
import '../models.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';

/// Gli intervalli di una sessione corretti a mano: il nome di un tratto (una
/// ripetuta che in realtà era il defaticamento), i metri, il tempo, un tratto
/// da togliere o da aggiungere.
class IntervalliScreen extends StatefulWidget {
  final AppState state;
  final Sessione sessione;
  final List<IntervalloFatto> iniziali;
  final List<String> nomi; // i passi in programma, da proporre
  const IntervalliScreen({
    super.key,
    required this.state,
    required this.sessione,
    required this.iniziali,
    this.nomi = const [],
  });

  @override
  State<IntervalliScreen> createState() => _IntervalliScreenState();
}

class _IntervalliScreenState extends State<IntervalliScreen> {
  late final List<IntervalloFatto> _lista = [...widget.iniziali];

  /// Corregge un tratto, o ne scrive uno nuovo ([i] null). Restituisce il
  /// tratto, oppure `false` se va tolto.
  Future<Object?> _foglio(IntervalloFatto? i) => showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _FoglioTratto(tratto: i, nomi: widget.nomi),
  );

  Future<void> _modifica(int n) async {
    final r = await _foglio(_lista[n]);
    if (r == null || !mounted) return;
    setState(() {
      if (r is IntervalloFatto) {
        _lista[n] = r;
      } else {
        _lista.removeAt(n);
      }
    });
  }

  Future<void> _aggiungi() async {
    final r = await _foglio(null);
    if (r is IntervalloFatto && mounted) setState(() => _lista.add(r));
  }

  Future<void> _salva() async {
    final navigator = Navigator.of(context);
    await widget.state.salvaIntervalli(widget.sessione.id, _lista);
    navigator.pop();
  }

  Future<void> _originali() async {
    final navigator = Navigator.of(context);
    await widget.state.salvaIntervalli(widget.sessione.id, null);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sessione;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final modificati = widget.state.intervalliModificati.containsKey(s.id);
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(l10n.modificaIntervalli)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(l10n.toccaTrattoCambiareNome, style: t.bodySmall),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _lista.length,
                // L'indice nuovo arriva già corretto per il tratto tolto.
                onReorderItem: (da, a) =>
                    setState(() => _lista.insert(a, _lista.removeAt(da))),
                itemBuilder: (context, n) {
                  final i = _lista[n];
                  return ListTile(
                    key: ObjectKey(i),
                    dense: i.recupero,
                    leading: Icon(
                      i.recupero
                          ? Icons.pause_circle_outline_rounded
                          : iconaSport(s.sport),
                      color: i.recupero
                          ? scheme.onSurfaceVariant
                          : coloreSport(s.sport),
                    ),
                    title: Text(
                      i.recupero
                          ? rigaIntervallo(i, s.sport)
                          : i.nome.isEmpty
                          ? l10n.senzaNome
                          : i.nome,
                    ),
                    subtitle: i.recupero
                        ? null
                        : Text(rigaIntervallo(i, s.sport)),
                    trailing: const Icon(Icons.edit_rounded, size: 18),
                    onTap: () => _modifica(n),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.aggiungiTratto),
                  onPressed: _aggiungi,
                ),
                if (modificati)
                  TextButton.icon(
                    icon: const Icon(Icons.undo_rounded),
                    label: Text(l10n.tornaQuelliDellOrologio),
                    onPressed: _originali,
                  ),
                PulsantePrincipale(
                  onPressed: _salva,
                  icona: Icons.check_rounded,
                  testo: l10n.salva,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Un tratto da scrivere o correggere.
class _FoglioTratto extends StatefulWidget {
  final IntervalloFatto? tratto; // null: nuovo
  final List<String> nomi;
  const _FoglioTratto({required this.tratto, required this.nomi});

  @override
  State<_FoglioTratto> createState() => _FoglioTrattoState();
}

class _FoglioTrattoState extends State<_FoglioTratto> {
  late final i = widget.tratto;
  late bool _recupero = i?.recupero ?? false;
  late final _nome = TextEditingController(text: i?.nome ?? '');
  late final _metri = TextEditingController(
    text: (i?.metri ?? 0) > 0 ? '${i!.metri.round()}' : '',
  );
  late final _tempo = TextEditingController(
    text: i == null ? '' : '${i!.secondi ~/ 60}:${two(i!.secondi % 60)}',
  );
  String? _errore;

  @override
  void dispose() {
    _nome.dispose();
    _metri.dispose();
    _tempo.dispose();
    super.dispose();
  }

  void _conferma() {
    final secondi = parseSecondi(_tempo.text);
    if (secondi == null) {
      setState(() => _errore = l10n.scriviTempoEs5);
      return;
    }
    Navigator.pop(
      context,
      IntervalloFatto(
        recupero: _recupero,
        inizioS: i?.inizioS ?? 0,
        secondi: secondi,
        metri: _recupero ? 0 : double.tryParse(_metri.text.trim()) ?? 0,
        fcMedia: i?.fcMedia ?? 0,
        nome: _recupero ? '' : _nome.text.trim(),
        wattMedi: i?.wattMedi ?? 0,
        previstoS: i?.previstoS ?? 0,
        fase: i?.fase ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                i == null ? l10n.nuovoTratto : l10n.modificaTratto,
                style: t.titleLarge,
              ),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.play_circle_outline_rounded),
                    label: Text(l10n.lavoro),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.pause_circle_outline_rounded),
                    label: Text(l10n.parolaRecupero),
                  ),
                ],
                selected: {_recupero},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() => _recupero = v.first),
              ),
              if (!_recupero) ...[
                TextField(
                  controller: _nome,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.nome,
                    hintText: l10n.esDefaticamento,
                  ),
                ),
                if (widget.nomi.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final n in widget.nomi)
                        ActionChip(
                          label: Text(n),
                          onPressed: () => setState(() => _nome.text = n),
                        ),
                    ],
                  ),
                TextField(
                  controller: _metri,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.metri,
                    suffixText: 'm',
                  ),
                ),
              ],
              TextField(
                controller: _tempo,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: l10n.tempo,
                  hintText: '5:30',
                  errorText: _errore,
                ),
              ),
              FilledButton(onPressed: _conferma, child: Text(l10n.fatto)),
              if (i != null)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.togliQuestoTratto),
                  onPressed: () => Navigator.pop(context, false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
