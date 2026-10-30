import 'package:flutter/material.dart';

import '../app_state.dart';
import '../esercizi.dart';
import '../models.dart';
import '../widgets.dart';

/// Scelta dell'attrezzatura disponibile, con i pesi per gli attrezzi che li hanno.
class AttrezzaturaScreen extends StatelessWidget {
  final AppState state;
  const AttrezzaturaScreen({super.key, required this.state});

  Future<List<double>?> _chiediPesi(
    BuildContext context,
    Attrezzo a,
    List<double> attuali,
  ) {
    final c = TextEditingController(text: attuali.map(fmtNum).join(', '));
    String? errore;
    return showDialog<List<double>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, aggiorna) {
          void salva() {
            final pesi = leggiPesi(c.text);
            if (pesi.isEmpty) {
              aggiorna(() => errore = 'Scrivi almeno un peso');
              return;
            }
            Navigator.pop(ctx, pesi);
          }

          final letti = leggiPesi(c.text);
          return AlertDialog(
            title: Text(a.nome),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: c,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Pesi disponibili',
                    suffixText: 'kg',
                    helperText: a.aiutoPeso,
                    helperMaxLines: 3,
                    errorText: errore,
                  ),
                  onChanged: (_) => aggiorna(() => errore = null),
                  onSubmitted: (_) => salva(),
                ),
                const SizedBox(height: 12),
                // Come sono stati letti i pesi, per accorgersi subito di un errore.
                Text(
                  letti.isEmpty ? 'Nessun peso' : 'Letti: ${scriviPesi(letti)}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              FilledButton(onPressed: salva, child: const Text('Salva')),
            ],
          );
        },
      ),
    );
  }

  /// In palestra di solito ci sono tutte: si selezionano con un tocco.
  Future<void> _tutteLeMacchine(BuildContext context) async {
    for (final a in attrezzi.where((a) => a.palestra)) {
      state.attrezzatura[a.chiave] ??= [];
    }
    await state.salvaAttrezzatura();
  }

  Future<void> _cambia(BuildContext context, Attrezzo a, bool attivo) async {
    if (!attivo) {
      state.attrezzatura.remove(a.chiave);
    } else if (a.conPeso) {
      final pesi = await _chiediPesi(context, a, const []);
      if (pesi == null) return; // annullato: resta non selezionato
      state.attrezzatura[a.chiave] = pesi;
    } else {
      state.attrezzatura[a.chiave] = [];
    }
    await state.salvaAttrezzatura();
  }

  Future<void> _modificaPesi(BuildContext context, Attrezzo a) async {
    final pesi = await _chiediPesi(
      context,
      a,
      state.attrezzatura[a.chiave] ?? [],
    );
    if (pesi == null) return;
    state.attrezzatura[a.chiave] = pesi;
    await state.salvaAttrezzatura();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('La mia attrezzatura')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final fattibili = state.esercizi.where(
            (e) => e.fattibile(state.attrezzatura),
          );
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Il corpo libero è sempre incluso. Con questa attrezzatura puoi fare '
                  '${fattibili.length} esercizi su ${state.esercizi.length}.',
                ),
              ),
              for (final a in attrezzi) ...[
                if (a.palestra && a == attrezzi.firstWhere((x) => x.palestra))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'In palestra',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _tutteLeMacchine(context),
                          child: const Text('Seleziona tutte'),
                        ),
                      ],
                    ),
                  ),
                CheckboxListTile(
                  value: state.attrezzatura.containsKey(a.chiave),
                  onChanged: (v) => _cambia(context, a, v ?? false),
                  secondary: Icon(a.icona),
                  title: Text(a.nome),
                  subtitle:
                      a.conPeso && state.attrezzatura.containsKey(a.chiave)
                      ? InkWell(
                          onTap: () => _modificaPesi(context, a),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  scriviPesi(state.attrezzatura[a.chiave]!),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit_outlined, size: 16),
                            ],
                          ),
                        )
                      : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
