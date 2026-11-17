import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../csv.dart';
import '../models.dart';
import '../l10n/lingua.dart';

/// Opzione avanzata, chiusa di default: import manuale delle sessioni da CSV per
/// chi non usa app collegate a Health Connect e vuole tenere tutto in locale.
class ImportCsvAvanzato extends StatefulWidget {
  final AppState state;
  const ImportCsvAvanzato({super.key, required this.state});

  @override
  State<ImportCsvAvanzato> createState() => _ImportCsvAvanzatoState();
}

class _ImportCsvAvanzatoState extends State<ImportCsvAvanzato> {
  List<String> messaggi = [];

  Future<void> _scaricaModello() async {
    try {
      final uri = await FilePicker.saveFile(
        fileName: 'modello_sessioni.csv',
        bytes: utf8.encode(modelloCsvSessioni()),
        mimeType: 'text/csv',
        dialogTitle: l10n.salvaModello,
      );
      if (uri == null || !mounted) return;
      setState(() => messaggi = [l10n.modelloSalvatoCompilaloRiga]);
    } catch (e) {
      if (mounted) {
        setState(() => messaggi = [l10n.impossibileSalvareModello(e)]);
      }
    }
  }

  Future<void> _importa() async {
    final List<PlatformFile> files;
    try {
      files = await FilePicker.pickFiles(type: FileType.any);
    } catch (e) {
      if (mounted) {
        setState(() => messaggi = [l10n.impossibileAprireSelezioneDei(e)]);
      }
      return;
    }
    if (files.isEmpty) return;
    final out = <String>[];
    for (final f in files) {
      try {
        if ((await f.length() ?? 0) > maxByteCsv) {
          out.add(l10n.fileTroppoGrandeMassimo(f.name));
          continue;
        }
        final testo = utf8.decode(await f.readAsBytes(), allowMalformed: true);
        out.add('${f.name}: ${await widget.state.importaSessioniCsv(testo)}');
      } catch (e) {
        out.add(l10n.impossibileLeggereFile2(f.name, e));
      }
    }
    if (mounted) setState(() => messaggi = out);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.tune_rounded),
        title: Text(l10n.opzioniAvanzate),
        subtitle: Text(l10n.importManualeCsvSenza),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.seNonUsiApp),
          const SizedBox(height: 8),
          Text(l10n.colonneDataAaaaMm, style: t.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _scaricaModello,
                icon: const Icon(Icons.download_rounded),
                label: Text(l10n.scaricaModelloCsv),
              ),
              FilledButton.tonalIcon(
                onPressed: _importa,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(l10n.importaCsv),
              ),
            ],
          ),
          for (final m in messaggi)
            Padding(padding: const EdgeInsets.only(top: 8), child: Text(m)),
        ],
      ),
    );
  }
}
