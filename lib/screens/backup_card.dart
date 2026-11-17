import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../backup.dart';
import '../backup_auto.dart';
import '../models.dart';
import '../l10n/lingua.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(avviso(content: Text(testo)));

  Future<void> _salva() async {
    setState(() => inCorso = true);
    try {
      final dati = await widget.state.creaFileBackup();
      final uri = await FilePicker.saveFile(
        fileName: 'avidididadi_backup_${isoData(soloData(DateTime.now()))}.gz',
        bytes: dati,
        mimeType: 'application/gzip',
        dialogTitle: l10n.salvaBackup,
      );
      if (uri != null && mounted) {
        _messaggio(l10n.backupSalvatoCopialoAnche);
      }
    } catch (e) {
      if (mounted) _messaggio(l10n.backupNonRiuscito(e));
    } finally {
      if (mounted) setState(() => inCorso = false);
    }
  }

  Future<void> _ripristina() async {
    final DatiBackup b;
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);
      if (files.isEmpty) return;
      if ((await files.first.length() ?? 0) > maxByteBackup) {
        throw FormatException(l10n.fileTroppoGrandeEssere);
      }
      b = leggiBackup(await files.first.readAsBytes());
    } on FormatException catch (e) {
      if (mounted) _messaggio(e.message);
      return;
    } catch (e) {
      if (mounted) _messaggio(l10n.impossibileLeggereFile(e));
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ripristinareBackup),
        content: Text(l10n.tuttiDatiAttualiDell(b.riassunto)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.ripristina),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => inCorso = true);
    try {
      await widget.state.ripristinaBackup(b);
      if (mounted) {
        _messaggio(l10n.datiRipristinatiAllaProssima);
      }
    } on FormatException catch (e) {
      if (mounted) _messaggio(e.message);
    } catch (e) {
      if (mounted) _messaggio(l10n.ripristinoNonRiuscito(e));
    } finally {
      if (mounted) setState(() => inCorso = false);
    }
  }

  /// Accende il backup automatico scegliendo la cartella, o lo spegne.
  Future<void> _accendiAutomatico(bool acceso) async {
    final s = widget.state;
    if (!acceso) {
      // Spento apposta: la proposta in Oggi non torna subito.
      await s.rimandaBackup(aLungo: true);
      return;
    }
    final c = await scegliCartellaBackup();
    if (c == null) return;
    await s.impostaBackupAuto(
      s.backupAuto.copyWith(cartella: c.$1, nomeCartella: c.$2, errore: ''),
    );
    await _automaticoOra();
  }

  Future<void> _automaticoOra() async {
    setState(() => inCorso = true);
    await widget.state.backupAutomatico(subito: true);
    if (!mounted) return;
    setState(() => inCorso = false);
    final b = widget.state.backupAuto;
    _messaggio(b.errore.isEmpty ? l10n.backupSalvatoNellaCartella : b.errore);
  }

  Widget _automatico(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final b = widget.state.backupAuto;
    final u = b.ultimo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          type: MaterialType.transparency,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.backupAutomatico),
            subtitle: Text(
              b.attivo
                  ? l10n.inTesto(
                      b.nomeCartella.isEmpty
                          ? l10n.cartellaTelefono
                          : '"${b.nomeCartella}"',
                      u == null ? '' : l10n.ultimo(dataLunga(u)),
                    )
                  : l10n.cartellaScegliTuResta(backupDaTenere),
            ),
            value: b.attivo,
            onChanged: inCorso ? null : _accendiAutomatico,
          ),
        ),
        if (b.attivo) ...[
          SegmentedButton<FrequenzaBackup>(
            segments: [
              ButtonSegment(
                value: FrequenzaBackup.giorno,
                label: Text(l10n.ogniGiorno),
              ),
              ButtonSegment(
                value: FrequenzaBackup.settimana,
                label: Text(l10n.ogniSettimana),
              ),
            ],
            selected: {b.frequenza},
            onSelectionChanged: (v) =>
                widget.state.impostaBackupAuto(b.copyWith(frequenza: v.first)),
          ),
          const SizedBox(height: 8),
          Text(l10n.siFaSoloQuando, style: t.bodySmall),
          if (b.errore.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(b.errore, style: t.bodySmall?.copyWith(color: scheme.error)),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: inCorso ? null : _automaticoOra,
                icon: const Icon(Icons.backup_rounded),
                label: Text(l10n.falloOra),
              ),
              TextButton(
                onPressed: inCorso ? null : () => _accendiAutomatico(true),
                child: Text(l10n.cambiaCartella),
              ),
            ],
          ),
        ],
      ],
    );
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
            Text(l10n.backup, style: t.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.unicoFileSessioniPiano, style: t.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: inCorso ? null : _salva,
                  icon: const Icon(Icons.save_alt_rounded),
                  label: Text(l10n.salvaBackup2),
                ),
                OutlinedButton.icon(
                  onPressed: inCorso ? null : _ripristina,
                  icon: const Icon(Icons.restore_rounded),
                  label: Text(l10n.ripristina),
                ),
              ],
            ),
            const Divider(height: 32),
            ListenableBuilder(
              listenable: widget.state,
              builder: (context, _) => _automatico(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// In Oggi: propone il backup automatico finché è spento (con "Non ora"
/// torna più avanti), e avvisa se l'ultimo non è riuscito.
class PromemoriaBackup extends StatefulWidget {
  final AppState state;
  const PromemoriaBackup({super.key, required this.state});

  @override
  State<PromemoriaBackup> createState() => _PromemoriaBackupState();
}

class _PromemoriaBackupState extends State<PromemoriaBackup> {
  bool inCorso = false;

  Future<void> _accendi() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => inCorso = true);
    final fatto = await widget.state.accendiBackupAuto();
    if (mounted) setState(() => inCorso = false);
    if (!fatto) return;
    final b = widget.state.backupAuto;
    messenger.showSnackBar(
      avviso(
        content: Text(b.errore.isEmpty ? l10n.backupAttivoOraSi : b.errore),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cosa = avvisoBackup(state.backupAuto, DateTime.now());
    // Si propone solo a chi ha già qualcosa da perdere.
    if (cosa == AvvisoBackup.nessuno ||
        (cosa == AvvisoBackup.proponi &&
            state.piano.isEmpty &&
            state.sessioni.isEmpty)) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final errore = cosa == AvvisoBackup.errore;
    final colore = errore ? scheme.onErrorContainer : scheme.onPrimaryContainer;
    return Card(
      color: errore ? scheme.errorContainer : scheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  errore ? Icons.error_outline_rounded : Icons.shield_rounded,
                  color: colore,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errore ? state.backupAuto.errore : l10n.mettiAlSicuroTuoi,
                    style: TextStyle(color: colore),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: inCorso ? null : _accendi,
                  child: Text(
                    errore ? l10n.scegliNuovoCartella : l10n.attivaBackup,
                  ),
                ),
                if (!errore)
                  TextButton(
                    onPressed: inCorso ? null : state.rimandaBackup,
                    child: Text(l10n.nonOra),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
