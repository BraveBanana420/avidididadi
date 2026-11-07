import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../arrampicata.dart';
import '../attivita.dart';
import '../benvenuto.dart';
import '../models.dart';
import '../pulse.dart';
import '../widgets.dart';

/// Le attività che si vogliono vedere nel piano e nei menu. Quelle tolte escono
/// dal calendario; quelle aggiunte ci entrano nei giorni scelti.
class AttivitaScreen extends StatefulWidget {
  final AppState state;
  const AttivitaScreen({super.key, required this.state});

  @override
  State<AttivitaScreen> createState() => _AttivitaScreenState();
}

class _AttivitaScreenState extends State<AttivitaScreen> {
  late final Set<String> prima = {...widget.state.attivitaScelte};
  late final Set<String> scelte = {...prima};
  bool inCorso = false;

  Future<bool> _confermaTolte(Set<String> tolte) async {
    final nomi = tolte.join(' e ');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Togliere $nomi?'),
        content: Text(
          'Le sedute future di ${nomi.toLowerCase()} escono dal calendario. '
          'Quelle già fatte restano nello storico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Togli'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _salva() async {
    final state = widget.state;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final tolte = prima.difference(scelte);
    final aggiunte = [
      for (final a in attivitaDaScegliere)
        if (scelte.contains(a) && !prima.contains(a)) a,
    ];
    if (tolte.isNotEmpty && !await _confermaTolte(tolte)) return;
    if (!mounted) return;
    setState(() => inCorso = true);
    await state.impostaAttivita({...scelte});
    for (final a in aggiunte) {
      if (!mounted) return;
      final q = await showDialog<(Set<int>, int)>(
        context: context,
        builder: (_) => QuandoDialog(sport: a),
      );
      if (q != null) await state.aggiungiAlCalendario(a, q.$1, q.$2);
    }
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      avviso(content: Text('Le tue attività sono aggiornate.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        child: PulsantePrincipale(
          testo: 'Salva',
          icona: Icons.check,
          onPressed: scelte.isEmpty || inCorso ? null : _salva,
        ),
      ),
      appBar: AppBar(title: const Text('Le mie attività')),
      body: Material(
        type: MaterialType.transparency,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Nel piano e nei menu vedi solo queste. Dal "+" puoi sempre '
                'fare anche altro, e tutto quello che fai resta nello storico.',
                style: t.bodyMedium,
              ),
            ),
            for (final a in attivitaDaScegliere)
              CheckboxListTile(
                value: scelte.contains(a),
                secondary: Icon(iconaSport(a), color: coloreSport(a)),
                title: Text(a),
                subtitle: Text(sportBenvenuto[a] ?? ''),
                onChanged: (si) => setState(
                  () => si == true ? scelte.add(a) : scelte.remove(a),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// In quali giorni va messa nel calendario un'attività appena aggiunta.
/// Restituisce i giorni della settimana (1 = lunedì) e i minuti.
class QuandoDialog extends StatefulWidget {
  final String sport;
  const QuandoDialog({super.key, required this.sport});

  @override
  State<QuandoDialog> createState() => _QuandoDialogState();
}

class _QuandoDialogState extends State<QuandoDialog> {
  final giorni = <int>{};
  final minuti = TextEditingController(text: '45');

  @override
  void dispose() {
    minuti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final m = int.tryParse(minuti.text.trim()) ?? 0;
    return AlertDialog(
      title: Text('${widget.sport}: quando?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              stessoSport(widget.sport, sportArrampicata)
                  ? 'Scegli i giorni. L\'allenamento lo decidi tu, o lo chiedi '
                        'all\'assistente: l\'app non ne scrive da sola.'
                  : 'Scegli i giorni: mettiamo le sedute nel calendario.',
              style: t.bodyMedium,
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var g = 1; g <= 7; g++)
                  FilterChip(
                    label: Text(giorniSettimana[g - 1].substring(0, 3)),
                    selected: giorni.contains(g),
                    onSelected: (si) =>
                        setState(() => si ? giorni.add(g) : giorni.remove(g)),
                  ),
              ],
            ),
            TextField(
              controller: minuti,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quanto dura',
                suffixText: 'min',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Non ora'),
        ),
        FilledButton(
          onPressed: giorni.isEmpty || m <= 0
              ? null
              : () => Navigator.pop(context, (giorni, m.clamp(1, 600))),
          child: const Text('Metti nel calendario'),
        ),
      ],
    );
  }
}
