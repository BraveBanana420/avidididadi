import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_state.dart';
import '../glossario.dart';
import '../l10n/vocabolario.dart';
import '../models.dart';
import '../widgets.dart';
import 'backup_card.dart';
import 'health_connect_card.dart';
import 'intervals_card.dart';
import 'passi_card.dart';
import 'import_csv.dart';
import 'privacy_screen.dart';
import '../l10n/lingua.dart';

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
      appBar: AppBar(title: Text(l10n.datiCollegamenti)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.collegaOrologioOApp, style: t.bodyMedium),
          const SizedBox(height: 12),
          SezioneHealthConnect(state: state),
          const SizedBox(height: 12),
          const SezionePassi(),
          const SizedBox(height: 12),
          // intervals.icu e l'import da file: solo con le funzioni avanzate.
          if (state.profilo.modoAvanzato) ...[
            SezioneIntervals(state: state),
            const SizedBox(height: 12),
          ],
          SezioneBackup(state: state),
          if (state.profilo.modoAvanzato) ...[
            const SizedBox(height: 12),
            ImportCsvAvanzato(state: state),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
            icon: const Icon(Icons.privacy_tip_rounded),
            label: Text(l10n.privacyUsoDeiDati),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TerminiScreen())),
            icon: const Icon(Icons.gavel_rounded),
            label: Text(l10n.terminiCondizioni),
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
      appBar: AppBar(title: Text(l10n.paroleDellAllenamento)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.concetti, style: t.titleLarge),
          for (final e in glossario.entries) voce(e.key, e.value),
          const SizedBox(height: 16),
          Text(l10n.zoneComeTiDevi, style: t.titleLarge),
          Card(
            child: Column(
              children: [
                for (final e in sensazioniZone.entries)
                  ListTile(
                    leading: CircleAvatar(child: Text('${e.key}')),
                    title: Text(l10n.zona(e.key)),
                    subtitle: Text(maiuscola(e.value)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.tipiSeduta, style: t.titleLarge),
          for (final e in spiegazioniSedute.entries)
            voce(maiuscola(mostra(e.key)), e.value),
        ],
      ),
    );
  }
}

/// Commit da cui è stato fatto l'APK (`--dart-define=COMMIT=...`): distingue
/// le prove di staging senza alzare la versione.
const _commit = String.fromEnvironment('COMMIT');

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
          l10n.avidididadiVersione(
            v.version,
            v.buildNumber,
            _commit.isEmpty ? '' : l10n.prova(_commit),
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    },
  );
}
