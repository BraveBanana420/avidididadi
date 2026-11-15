import 'package:flutter/material.dart';

import '../app_state.dart';
import '../attivita_libera.dart';

/// Un'attività che non è tra quelle dell'app (kayak, sci, padel…): si
/// scrive il nome, che resta come etichetta della sessione, e si sceglie se
/// registrare il percorso GPS. Restituisce (nome, GPS) oppure null.
Future<(String, bool)?> chiediAltraAttivita(
  BuildContext context,
  AppState state, {
  bool conGps = true,
}) => showModalBottomSheet<(String, bool)>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _FoglioAltraAttivita(
    nomi: nomiAltreAttivita(state.sessioni),
    conGps: conGps,
  ),
);

class _FoglioAltraAttivita extends StatefulWidget {
  final List<String> nomi;
  final bool conGps; // false: seduta scritta a mano, il GPS non serve
  const _FoglioAltraAttivita({required this.nomi, required this.conGps});

  @override
  State<_FoglioAltraAttivita> createState() => _FoglioAltraAttivitaState();
}

class _FoglioAltraAttivitaState extends State<_FoglioAltraAttivita> {
  final _nome = TextEditingController();
  bool _gps = false;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _conferma() {
    final nome = pulisciNomeAttivita(_nome.text);
    Navigator.pop(context, (nome.isEmpty ? tipoAltraAttivita : nome, _gps));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      // Il foglio sale sopra la tastiera.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text('Che attività è?', style: t.titleLarge),
              Text(
                'Il nome resta sulla sessione, nel calendario e nello '
                'storico.',
                style: t.bodySmall,
              ),
              TextField(
                controller: _nome,
                autofocus: widget.nomi.isEmpty,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Es. Kayak, Padel, Sci',
                ),
                onSubmitted: (_) => _conferma(),
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
              if (widget.conGps)
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.route_rounded),
                    title: const Text('Registra il percorso GPS'),
                    subtitle: const Text(
                      'Mappa, distanza e velocità, anche a schermo spento. '
                      'Spento: solo tempo e battito.',
                    ),
                    value: _gps,
                    onChanged: (v) => setState(() => _gps = v),
                  ),
                ),
              FilledButton(
                onPressed: _conferma,
                child: Text(widget.conGps ? 'Inizia' : 'Avanti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
