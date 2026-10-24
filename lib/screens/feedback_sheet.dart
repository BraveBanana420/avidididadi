import 'package:flutter/material.dart';

import '../app_state.dart';
import '../feedback.dart';
import '../generatore_forza.dart';
import '../models.dart';
import '../widgets.dart';

/// Apre il feedback rapido di fine sessione per il giorno [data].
Future<void> apriFeedback(
  BuildContext context,
  AppState state,
  DateTime data, [
  String sport = 'Forza',
]) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _FeedbackSheet(
    state: state,
    data: soloData(data),
    sport: normSport(sport),
  ),
);

String _descrizioneFatica(int f) => switch (f) {
  <= 2 => 'molto leggera',
  <= 4 => 'leggera',
  <= 6 => 'moderata',
  <= 8 => 'impegnativa',
  9 => 'molto dura',
  _ => 'al massimo',
};

class _FeedbackSheet extends StatefulWidget {
  final AppState state;
  final DateTime data;
  final String sport;
  const _FeedbackSheet({
    required this.state,
    required this.data,
    required this.sport,
  });

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  late final FeedbackSessione? prima = widget.state.feedbackDel(
    widget.data,
    widget.sport,
  );
  late final bool forza = stessoSport(widget.sport, 'Forza');
  late final String tipo = widget.state.tipoDel(widget.data, widget.sport);
  late final int obiettivo = forza
      ? faticaObiettivo(widget.state.profilo.obiettivo)
      : faticaPrevista(tipo);
  late int fatica = prima?.fatica ?? obiettivo;
  late bool completata = prima?.completata ?? true;
  late bool dolore = prima?.dolore ?? false;
  late final TextEditingController note = TextEditingController(
    text: prima?.note,
  );
  bool inCorso = false;

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => inCorso = true);
    final messaggio = await widget.state.salvaFeedback(
      FeedbackSessione(
        data: widget.data,
        sport: widget.sport,
        fatica: fatica,
        completata: completata,
        dolore: dolore,
        note: note.text.trim(),
      ),
    );
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(messaggio), duration: const Duration(seconds: 6)),
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
            Text('Com\'è andata?', style: t.titleLarge),
            Text('${widget.sport} · ${dataLunga(widget.data)}'),
            const SizedBox(height: 16),
            Text(
              'Fatica: $fatica/10, ${_descrizioneFatica(fatica)}',
              style: t.titleMedium,
            ),
            Slider(
              value: fatica.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$fatica',
              onChanged: (v) => setState(() => fatica = v.round()),
            ),
            Text(
              forza
                  ? 'Per il tuo obiettivo la fatica giusta è circa $obiettivo/10.'
                  : 'Per una seduta ${tipo.isEmpty ? 'come questa' : tipo.toLowerCase()} '
                        'la fatica prevista è circa $obiettivo/10.',
              style: t.bodySmall,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                forza
                    ? 'Ho completato tutte le serie'
                    : 'Ho fatto tutta la seduta',
              ),
              value: completata,
              onChanged: (v) => setState(() => completata = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ho sentito dolore o fastidio'),
              value: dolore,
              onChanged: (v) => setState(() => dolore = v),
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(
                labelText: 'Note (facoltative)',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: inCorso ? null : _salva,
                child: const Text('Salva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
