import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'backup.dart';
import 'csv.dart';
import 'models.dart';

/// Legge e scrive i CSV nella cartella privata dell'app.
class Storage {
  /// Cartella privata dell'app, dove stanno CSV e foto.
  static Future<String> cartella() async =>
      (await getApplicationDocumentsDirectory()).path;

  static Future<File> _file(String nome) async {
    final d = await getApplicationDocumentsDirectory();
    return File('${d.path}/$nome');
  }

  static Future<List<List<String>>?> _read(String nome) async {
    final f = await _file(nome);
    if (!await f.exists()) return null;
    final rows = parseCsv(await f.readAsString());
    return rows.isEmpty ? <List<String>>[] : rows.sublist(1);
  }

  static Future<Tabella?> readTabella(String nome) async {
    final f = await _file(nome);
    if (!await f.exists()) return null;
    return Tabella.da(await f.readAsString());
  }

  static Future<void> write(
    String nome,
    List<String> header,
    List<List<String>> rows,
  ) async {
    final f = await _file(nome);
    await f.writeAsString(toCsv([header, ...rows]));
  }

  static Future<List<Slot>?> readSettimana() async {
    final rows = await _read('settimana_tipo.csv');
    return rows?.map(Slot.fromRow).toList();
  }

  static Future<void> writeSettimana(List<Slot> s) => write(
    'settimana_tipo.csv',
    settimanaHeader,
    s.map((e) => e.toRow()).toList(),
  );

  static Future<List<PianoRiga>> readPiano() async {
    final rows = await _read('piano.csv') ?? [];
    final out = <PianoRiga>[];
    for (final r in rows) {
      try {
        out.add(PianoRiga.fromRow(r));
      } catch (_) {
        // riga non valida: la salto
      }
    }
    return out;
  }

  /// Contenuto di tutti i CSV da mettere nel backup.
  static Future<Map<String, String>> tuttiCsv() async {
    final d = Directory(await cartella());
    return {
      for (final f in d.listSync().whereType<File>())
        if (fileDaSalvare(f.uri.pathSegments.last))
          f.uri.pathSegments.last: await f.readAsString(),
    };
  }

  /// Sostituisce tutti i CSV con quelli del backup (anche il token di Health
  /// Connect si cancella) e salva la foto. I file non nel backup spariscono.
  /// Restituisce i CSV di prima, per tornare indietro con [rimetti] se i dati
  /// nuovi non si caricano.
  static Future<Map<String, String>> ripristina(DatiBackup b) async =>
      ripristinaIn(Directory(await cartella()), b);

  /// Rimette i CSV di prima del ripristino.
  static Future<void> rimetti(Map<String, String> prima) async =>
      rimettiIn(Directory(await cartella()), prima);

  /// Testo di un file della cartella dell'app (null se non c'è).
  static Future<String?> leggiTesto(String nome) async {
    final f = await _file(nome);
    return await f.exists() ? f.readAsString() : null;
  }

  static Future<void> scriviTesto(String nome, String testo) async =>
      (await _file(nome)).writeAsString(testo);

  /// Toglie un file della cartella dell'app, se c'è.
  static Future<void> cancella(String nome) async {
    final f = await _file(nome);
    if (await f.exists()) await f.delete();
  }

  static Future<void> writePiano(List<PianoRiga> p) =>
      write('piano.csv', pianoHeader, p.map((e) => e.toRow()).toList());
}

/// Copia dei dati di prima dell'ultimo ripristino, nella cartella privata
/// (non è un CSV: non entra nei backup). Serve se qualcosa va storto.
const fileCopiaRipristino = 'ripristino_precedente.gz';

Map<String, String> _csvIn(Directory d) => {
  for (final f in d.listSync().whereType<File>())
    if (f.path.endsWith('.csv')) f.uri.pathSegments.last: f.readAsStringSync(),
};

/// Ripristino in [d] senza rischiare i dati: i file nuovi si scrivono prima
/// in una cartella a parte, i vecchi restano in memoria e in
/// [fileCopiaRipristino]. Se una scrittura fallisce si rimette tutto com'era.
Future<Map<String, String>> ripristinaIn(Directory d, DatiBackup b) async {
  final prima = _csvIn(d);
  await File('${d.path}/$fileCopiaRipristino')
      .writeAsBytes(creaBackup(prima, creato: DateTime.now()), flush: true);
  final nuova = Directory('${d.path}/ripristino_tmp');
  if (await nuova.exists()) await nuova.delete(recursive: true);
  await nuova.create();
  try {
    for (final e in b.csv.entries) {
      await File('${nuova.path}/${e.key}').writeAsString(e.value, flush: true);
    }
    // Pronti tutti: solo adesso si tolgono i vecchi e si spostano i nuovi.
    try {
      for (final nome in prima.keys) {
        await File('${d.path}/$nome').delete();
      }
      for (final nome in b.csv.keys) {
        await File('${nuova.path}/$nome').rename('${d.path}/$nome');
      }
    } catch (_) {
      await rimettiIn(d, prima);
      rethrow;
    }
  } finally {
    if (await nuova.exists()) await nuova.delete(recursive: true);
  }
  if (b.nomeFoto != null && b.foto != null) {
    await File('${d.path}/${b.nomeFoto}').writeAsBytes(b.foto!, flush: true);
  }
  return prima;
}

/// Toglie i CSV di adesso e rimette quelli di [prima].
Future<void> rimettiIn(Directory d, Map<String, String> prima) async {
  for (final f in d.listSync().whereType<File>()) {
    if (f.path.endsWith('.csv')) await f.delete();
  }
  for (final e in prima.entries) {
    await File('${d.path}/${e.key}').writeAsString(e.value, flush: true);
  }
}
