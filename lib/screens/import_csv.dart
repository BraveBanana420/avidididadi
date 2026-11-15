import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../csv.dart';
import '../models.dart';

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
        dialogTitle: 'Salva il modello',
      );
      if (uri == null || !mounted) return;
      setState(
        () => messaggi = [
          'Modello salvato. Compilalo (una riga per sessione) e importalo qui.',
        ],
      );
    } catch (e) {
      if (mounted) {
        setState(() => messaggi = ['Impossibile salvare il modello: $e']);
      }
    }
  }

  Future<void> _importa() async {
    final List<PlatformFile> files;
    try {
      files = await FilePicker.pickFiles(type: FileType.any);
    } catch (e) {
      if (mounted) {
        setState(
          () => messaggi = ['Impossibile aprire la selezione dei file: $e'],
        );
      }
      return;
    }
    if (files.isEmpty) return;
    final out = <String>[];
    for (final f in files) {
      try {
        if ((await f.length() ?? 0) > maxByteCsv) {
          out.add('${f.name}: file troppo grande (massimo 20 MB).');
          continue;
        }
        final testo = utf8.decode(await f.readAsBytes(), allowMalformed: true);
        out.add('${f.name}: ${await widget.state.importaSessioniCsv(testo)}');
      } catch (e) {
        out.add('${f.name}: impossibile leggere il file ($e).');
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
        title: const Text('Opzioni avanzate'),
        subtitle: const Text('Import manuale da CSV, senza sincronizzazione'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Se non usi app collegate a Health Connect puoi inserire le sessioni a '
            'mano: scarica il modello, compilalo con un foglio di calcolo (una riga '
            'per sessione) e importalo. I dati restano solo sul telefono.',
          ),
          const SizedBox(height: 8),
          Text(
            'Colonne: data (AAAA-MM-GG), sport (Corsa, Bici, Nuoto, Forza), '
            'tipo_sessione, durata_min, distanza_km, fc_media, rpe, fonte, note. '
            'Servono almeno data e sport.',
            style: t.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _scaricaModello,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Scarica modello CSV'),
              ),
              FilledButton.tonalIcon(
                onPressed: _importa,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Importa CSV'),
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
