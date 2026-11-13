import 'package:flutter/material.dart';

import '../app_state.dart';
import '../motivazione.dart';

/// In Oggi, sotto la settimana: settimane di fila, traguardi e record.
/// Righe piatte, con un'icona diversa per tipo; niente se non c'è nulla.
class Motivazione extends StatelessWidget {
  final AppState state;
  const Motivazione({super.key, required this.state});

  static const _icone = {
    TipoSpinta.fila: Icons.local_fire_department_outlined,
    TipoSpinta.traguardo: Icons.flag_outlined,
    TipoSpinta.record: Icons.emoji_events_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final righe = spinte(
      sessioni: state.sessioni,
      serie: state.serieFatte,
      oggi: DateTime.now(),
    );
    if (righe.isEmpty) return const SizedBox.shrink();
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Column(
        children: [
          for (final r in righe)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(_icone[r.tipo], size: 22, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r.testo,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
