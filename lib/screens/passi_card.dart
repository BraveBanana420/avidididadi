import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../avvisi.dart';
import '../contapassi.dart';
import '../l10n/lingua.dart';

/// Passi dal telefono in corsa e camminata: l'interruttore per accenderli o
/// spegnerli. Il permesso "Attività fisica" si chiede solo al primo
/// allenamento; dopo, solo da qui.
class SezionePassi extends StatelessWidget {
  const SezionePassi({super.key});

  Future<void> _cambia(BuildContext context, bool acceso) async {
    if (!acceso) {
      await salvaAvvisi(passi: false);
      return;
    }
    final ok = await SensorePassi.chiediPermesso();
    await salvaAvvisi(passi: ok, passiChiesto: true);
    if (ok || !context.mounted) return;
    // Negato (anche per sempre): si concede dalle impostazioni dell'app.
    final apri = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.directions_walk_rounded),
        title: Text(l10n.passiDalTelefono),
        content: Text(l10n.permessoPassiNegato),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.chiudi),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.apriImpostazioni),
          ),
        ],
      ),
    );
    if (apri == true) await Geolocator.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: ValueListenableBuilder<bool>(
          valueListenable: passiAttivi,
          builder: (context, acceso, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.passiDalTelefono, style: t.titleMedium),
                  ),
                  Switch(value: acceso, onChanged: (v) => _cambia(context, v)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(l10n.passiDalTelefonoSpiega, style: t.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
