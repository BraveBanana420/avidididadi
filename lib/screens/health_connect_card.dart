import 'package:flutter/material.dart';
import 'package:health/health.dart' show HealthDataType;

import '../avviso.dart';
import '../app_state.dart';
import '../health_connect.dart';
import '../sincronizzazione.dart';
import 'privacy_screen.dart';

/// Stato di Health Connect letto dal telefono.
class _Stato {
  final DisponibilitaHc disponibilita;
  final Map<HealthDataType, bool> permessi;
  final bool storico;
  const _Stato(this.disponibilita, this.permessi, this.storico);
}

/// Sezione "Health Connect" del Profilo: stato, permessi, ultima
/// sincronizzazione, fonti trovate e pulsanti.
class SezioneHealthConnect extends StatefulWidget {
  final AppState state;
  const SezioneHealthConnect({super.key, required this.state});

  @override
  State<SezioneHealthConnect> createState() => _SezioneHealthConnectState();
}

class _SezioneHealthConnectState extends State<SezioneHealthConnect> {
  late Future<_Stato> _stato = _leggi();

  Future<_Stato> _leggi() async {
    final hc = widget.state.hc;
    final d = await hc.disponibilita();
    if (d != DisponibilitaHc.disponibile) return _Stato(d, const {}, false);
    return _Stato(d, await hc.permessi(), await hc.storicoAutorizzato());
  }

  void _aggiorna() => setState(() {
    _stato = _leggi();
  });

  Future<void> _sincronizza() async {
    final messenger = ScaffoldMessenger.of(context);
    final msg = await widget.state.sincronizzaHc(interattiva: true);
    if (!mounted) return;
    _aggiorna();
    messenger.showSnackBar(avviso(content: Text(msg)));
  }

  Future<void> _rivediPermessi(_Stato s) async {
    final hc = widget.state.hc;
    // Se manca qualcosa lo chiede l'app; se è tutto concesso apre Health Connect.
    if (s.permessi.values.any((v) => !v) || !s.storico) {
      await hc.chiediPermessi();
    } else {
      await hc.apriPermessi();
    }
    if (mounted) _aggiorna();
  }

  String _quando(DateTime d) {
    String due(int n) => n.toString().padLeft(2, '0');
    return '${due(d.day)}/${due(d.month)}/${d.year} alle ${due(d.hour)}:${due(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final state = widget.state;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => FutureBuilder<_Stato>(
        future: _stato,
        builder: (context, snap) {
          final s = snap.data;
          final children = <Widget>[
            Row(
              children: [
                Expanded(child: Text('Health Connect', style: t.titleLarge)),
                if (state.sincronizzando)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ];
          if (s == null) {
            children.add(const Text('Controllo Health Connect…'));
          } else if (s.disponibilita != DisponibilitaHc.disponibile) {
            children.addAll([
              Text(switch (s.disponibilita) {
                DisponibilitaHc.daAggiornare =>
                  'Health Connect è installato ma va aggiornato.',
                DisponibilitaHc.nonInstallata =>
                  'Health Connect non è installato. Serve per leggere gli '
                      'allenamenti di Garmin e Freeletics.',
                _ => 'Health Connect è disponibile solo su Android.',
              }),
              if (s.disponibilita != DisponibilitaHc.nonSupportata) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () async {
                    await state.hc.installa();
                    _aggiorna();
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(
                    s.disponibilita == DisponibilitaHc.daAggiornare
                        ? 'Aggiorna Health Connect'
                        : 'Installa Health Connect',
                  ),
                ),
              ],
            ]);
          } else {
            final collegato = s.permessi[HealthDataType.WORKOUT] == true;
            final fonti = fontiDi(state.sessioniHc);
            children.addAll([
              Text(
                collegato
                    ? 'Collegato'
                    : 'Non collegato: manca il permesso per le sessioni.',
              ),
              const SizedBox(height: 8),
              Text('Permessi', style: t.titleSmall),
              for (final e in HealthConnectService.tipi.entries)
                _riga(e.value, s.permessi[e.key] == true, scheme),
              _riga('Dati più vecchi di 30 giorni', s.storico, scheme),
              const SizedBox(height: 8),
              Text(
                state.infoSync.ultima == null
                    ? 'Mai sincronizzato.'
                    : 'Ultima sincronizzazione: ${_quando(state.infoSync.ultima!)}',
              ),
              Text('Sessioni da Health Connect: ${state.sessioniHc.length}'),
              if (fonti.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Fonti trovate', style: t.titleSmall),
                for (final e in fonti.entries)
                  Text('${e.value.$1}: ${e.value.$2} sessioni  (${e.key})'),
              ],
              if (state.infoSync.ignorati.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Tipi di attività ignorati', style: t.titleSmall),
                Text(
                  state.infoSync.ignorati.entries
                      .map((e) => '${e.key} (${e.value})')
                      .join(', '),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: state.sincronizzando ? null : _sincronizza,
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Sincronizza ora'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _rivediPermessi(s),
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Rivedi permessi'),
                  ),
                ],
              ),
            ]);
          }
          children.add(
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
              child: const Text('Privacy e uso dei dati'),
            ),
          );
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _riga(String nome, bool ok, ColorScheme scheme) => Row(
    children: [
      Icon(
        ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
        size: 18,
        color: ok ? scheme.primary : scheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(nome)),
    ],
  );
}

/// Per il trascinamento verso il basso: sincronizza e mostra l'esito.
Future<void> sincronizzaConMessaggio(
  BuildContext context,
  AppState state,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final msg = await state.sincronizzaHc();
  messenger.showSnackBar(avviso(content: Text(msg)));
}
