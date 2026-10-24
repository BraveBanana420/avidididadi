import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../backup.dart';
import '../models.dart';

/// Backup e ripristino di tutti i dati dell'app in un unico file.
class SezioneBackup extends StatefulWidget {
  final AppState state;
  const SezioneBackup({super.key, required this.state});

  @override
  State<SezioneBackup> createState() => _SezioneBackupState();
}

class _SezioneBackupState extends State<SezioneBackup> {
  bool inCorso = false;

  void _messaggio(String testo) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(testo)));

  Future<void> _salva() async {
    setState(() => inCorso = true);
    try {
      final dati = await widget.state.creaFileBackup();
      final uri = await FilePicker.saveFile(
        fileName: 'avidididadi_backup_${isoData(soloData(DateTime.now()))}.gz',
        bytes: dati,
        mimeType: 'application/gzip',
        dialogTitle: 'Salva il backup',
      );
      if (uri != null && mounted) {
        _messaggio(
          'Backup salvato. Copialo anche fuori dal telefono '
          '(Drive, PC) per non perderlo.',
        );
      }
    } catch (e) {
      if (mounted) _messaggio('Backup non riuscito: $e');
    } finally {
      if (mounted) setState(() => inCorso = false);
    }
  }

  Future<void> _ripristina() async {
    final DatiBackup b;
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);
      if (files.isEmpty) return;
      b = leggiBackup(await files.first.readAsBytes());
    } on FormatException catch (e) {
      if (mounted) _messaggio(e.message);
      return;
    } catch (e) {
      if (mounted) _messaggio('Impossibile leggere il file: $e');
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ripristinare il backup?'),
        content: Text(
          '${b.riassunto}.\n\nTutti i dati attuali dell\'app verranno '
          'sostituiti. Se non sei sicuro, salva prima un backup di adesso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ripristina'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => inCorso = true);
    try {
      await widget.state.ripristinaBackup(b);
      if (mounted) {
        _messaggio(
          'Dati ripristinati. Alla prossima sincronizzazione Health Connect '
          'rilegge lo storico.',
        );
      }
    } catch (e) {
      if (mounted) _messaggio('Ripristino non riuscito: $e');
    } finally {
      if (mounted) setState(() => inCorso = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backup', style: t.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Un unico file con sessioni, piano, profilo, misure, feedback, '
              'recupero e foto. La chiave dell\'assistente non è inclusa.',
              style: t.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: inCorso ? null : _salva,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Salva backup'),
                ),
                OutlinedButton.icon(
                  onPressed: inCorso ? null : _ripristina,
                  icon: const Icon(Icons.restore),
                  label: const Text('Ripristina'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
