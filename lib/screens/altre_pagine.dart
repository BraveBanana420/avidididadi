import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_state.dart';
import '../glossario.dart';
import '../models.dart';
import '../widgets.dart';
import 'backup_card.dart';
import 'health_connect_card.dart';
import 'import_csv.dart';
import 'privacy_screen.dart';

/// Collegamenti e dati: Health Connect, backup e import. La parte tecnica,
/// tenuta fuori dal Profilo.
class DatiCollegamentiScreen extends StatelessWidget {
  final AppState state;
  const DatiCollegamentiScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('Dati e collegamenti')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Collega l\'orologio o le app che usi (Garmin, Freeletics…) tramite '
            'Health Connect: gli allenamenti fatti arrivano da soli.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 12),
          SezioneHealthConnect(state: state),
          const SizedBox(height: 12),
          SezioneBackup(state: state),
          const SizedBox(height: 12),
          ImportCsvAvanzato(state: state),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Privacy e uso dei dati'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TerminiScreen())),
            icon: const Icon(Icons.gavel_outlined),
            label: const Text('Termini e condizioni'),
          ),
          const _Versione(),
        ],
      ),
    );
  }
}

/// Le parole dell'allenamento, spiegate semplici.
class GlossarioScreen extends StatelessWidget {
  const GlossarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget voce(String titolo, String testo) => Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        title: Text(titolo),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        children: [Text(testo)],
      ),
    );
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text("Le parole dell'allenamento")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Concetti', style: t.titleLarge),
          for (final e in glossario.entries) voce(e.key, e.value),
          const SizedBox(height: 16),
          Text('Zone: come ti devi sentire', style: t.titleLarge),
          Card(
            child: Column(
              children: [
                for (final e in sensazioniZone.entries)
                  ListTile(
                    leading: CircleAvatar(child: Text('${e.key}')),
                    title: Text('Zona ${e.key}'),
                    subtitle: Text(maiuscola(e.value)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Tipi di seduta', style: t.titleLarge),
          for (final e in spiegazioniSedute.entries)
            voce(maiuscola(e.key), e.value),
        ],
      ),
    );
  }
}

/// Nome e versione dell'app, sotto informativa e termini.
class _Versione extends StatelessWidget {
  const _Versione();

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
    future: PackageInfo.fromPlatform(),
    builder: (context, snap) {
      final v = snap.data;
      if (v == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Avidididadi · versione ${v.version} (${v.buildNumber})',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    },
  );
}
