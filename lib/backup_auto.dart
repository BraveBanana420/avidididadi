import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';

// Backup automatico: lo stesso file del backup a mano, scritto da solo in una
// cartella scelta una volta (fuori dall'app: resta anche disinstallandola).
// Le scelte stanno in backup_auto.txt, che non entra nel backup: la cartella
// vale solo su questo telefono.

const _canale = MethodChannel('avidididadi/avvio');

/// Quanti backup automatici tenere: i più vecchi si cancellano.
const backupDaTenere = 5;

enum FrequenzaBackup { giorno, settimana }

class ImpostazioniBackup {
  final String cartella; // uri della cartella; vuoto = spento
  final String nomeCartella;
  final FrequenzaBackup frequenza;
  final DateTime? ultimo;
  final String errore;

  /// Quando si è detto "Non ora" alla proposta in Oggi, e quante volte.
  final DateTime? rimandato;
  final int rimandi;

  const ImpostazioniBackup({
    this.cartella = '',
    this.nomeCartella = '',
    this.frequenza = FrequenzaBackup.settimana,
    this.ultimo,
    this.errore = '',
    this.rimandato,
    this.rimandi = 0,
  });

  bool get attivo => cartella.isNotEmpty;

  ImpostazioniBackup copyWith({
    String? cartella,
    String? nomeCartella,
    FrequenzaBackup? frequenza,
    DateTime? ultimo,
    String? errore,
    DateTime? rimandato,
    int? rimandi,
  }) => ImpostazioniBackup(
    cartella: cartella ?? this.cartella,
    nomeCartella: nomeCartella ?? this.nomeCartella,
    frequenza: frequenza ?? this.frequenza,
    ultimo: ultimo ?? this.ultimo,
    errore: errore ?? this.errore,
    rimandato: rimandato ?? this.rimandato,
    rimandi: rimandi ?? this.rimandi,
  );

  String toText() =>
      'cartella=$cartella\n'
      'nome=$nomeCartella\n'
      'frequenza=${frequenza.name}\n'
      'ultimo=${ultimo?.toIso8601String() ?? ''}\n'
      'errore=$errore\n'
      'rimandato=${rimandato?.toIso8601String() ?? ''}\n'
      'rimandi=$rimandi\n';

  static ImpostazioniBackup da(String testo) {
    final v = <String, String>{};
    for (final riga in testo.split('\n')) {
      final i = riga.indexOf('=');
      if (i > 0) v[riga.substring(0, i).trim()] = riga.substring(i + 1).trim();
    }
    return ImpostazioniBackup(
      cartella: v['cartella'] ?? '',
      nomeCartella: v['nome'] ?? '',
      frequenza: v['frequenza'] == 'giorno'
          ? FrequenzaBackup.giorno
          : FrequenzaBackup.settimana,
      ultimo: DateTime.tryParse(v['ultimo'] ?? ''),
      errore: v['errore'] ?? '',
      rimandato: DateTime.tryParse(v['rimandato'] ?? ''),
      rimandi: int.tryParse(v['rimandi'] ?? '') ?? 0,
    );
  }
}

/// Cosa dire in Oggi sul backup automatico.
enum AvvisoBackup { nessuno, proponi, errore }

/// Spento: si propone subito, poi dopo ogni "Non ora" si aspetta (14 giorni
/// la prima volta, 30 le successive: un promemoria, non un assillo).
/// Acceso: si avvisa solo se l'ultimo backup non è riuscito.
AvvisoBackup avvisoBackup(ImpostazioniBackup b, DateTime ora) {
  if (b.attivo) {
    return b.errore.isEmpty ? AvvisoBackup.nessuno : AvvisoBackup.errore;
  }
  final r = b.rimandato;
  if (r == null) return AvvisoBackup.proponi;
  final attesa = Duration(days: b.rimandi <= 1 ? 14 : 30);
  return ora.difference(r) >= attesa
      ? AvvisoBackup.proponi
      : AvvisoBackup.nessuno;
}

/// È ora di un backup? Un po' di margine: aprendo l'app ogni mattina
/// alla stessa ora, "ogni giorno" non deve saltare un giorno.
bool backupDovuto(ImpostazioniBackup b, DateTime ora) {
  if (!b.attivo) return false;
  final u = b.ultimo;
  if (u == null) return true;
  final ogni = b.frequenza == FrequenzaBackup.giorno
      ? const Duration(hours: 20)
      : const Duration(days: 6, hours: 20);
  return ora.difference(u) >= ogni;
}

/// "avidididadi_backup_2026-11-01.gz": come quello a mano.
String nomeBackup(DateTime giorno) =>
    'avidididadi_backup_${isoData(soloData(giorno))}.gz';

final _nomeBackup = RegExp(r'^avidididadi_backup_\d{4}-\d{2}-\d{2}\.gz$');

/// I file da cancellare (id): solo i backup dell'app, oltre i [tieni] più
/// recenti. Gli altri file della cartella non si toccano.
List<String> backupDaCancellare(
  List<(String, String)> file, {
  int tieni = backupDaTenere,
}) {
  final nostri = [
    for (final (id, nome) in file)
      if (_nomeBackup.hasMatch(nome)) (id, nome),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final (id, _) in nostri.skip(tieni)) id];
}

Future<File> _file() async =>
    File('${(await getApplicationDocumentsDirectory()).path}/backup_auto.txt');

Future<ImpostazioniBackup> leggiImpostazioniBackup() async {
  try {
    final f = await _file();
    if (!await f.exists()) return const ImpostazioniBackup();
    return ImpostazioniBackup.da(await f.readAsString());
  } catch (_) {
    return const ImpostazioniBackup();
  }
}

Future<void> salvaImpostazioniBackup(ImpostazioniBackup b) async {
  try {
    await (await _file()).writeAsString(b.toText());
  } catch (_) {}
}

/// Fa scegliere la cartella: (uri, nome) o null se si annulla.
Future<(String, String)?> scegliCartellaBackup() async {
  try {
    final r = await _canale.invokeMethod<List<Object?>>('scegliCartella');
    if (r == null || r.isEmpty) return null;
    return ('${r[0]}', r.length > 1 ? '${r[1]}' : '');
  } catch (_) {
    return null;
  }
}

/// Scrive il backup nella cartella e toglie i più vecchi. Restituisce le
/// impostazioni aggiornate (con l'orario, o con l'errore).
Future<ImpostazioniBackup> scriviBackupAuto(
  ImpostazioniBackup b,
  Uint8List dati, {
  DateTime? ora,
}) async {
  final adesso = ora ?? DateTime.now();
  try {
    final ok = await _canale.invokeMethod<bool>('scriviInCartella', {
      'cartella': b.cartella,
      'nome': nomeBackup(adesso),
      'dati': dati,
    });
    if (ok != true) {
      return b.copyWith(
        errore:
            'Non riesco a scrivere nella cartella: sceglila di nuovo '
            '(forse è stata spostata o cancellata).',
      );
    }
    final elenco =
        await _canale.invokeMethod<List<Object?>>(
          'fileInCartella',
          b.cartella,
        ) ??
        const [];
    final file = [
      for (var k = 0; k + 1 < elenco.length; k += 2)
        ('${elenco[k]}', '${elenco[k + 1]}'),
    ];
    for (final id in backupDaCancellare(file)) {
      await _canale.invokeMethod('cancellaInCartella', {
        'cartella': b.cartella,
        'id': id,
      });
    }
    return b.copyWith(ultimo: adesso, errore: '');
  } catch (e) {
    debugPrint('Backup automatico: $e');
    return b.copyWith(errore: 'Backup automatico non riuscito.');
  }
}
