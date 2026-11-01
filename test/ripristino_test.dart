import 'dart:io';

import 'package:allenamenti_app/backup.dart';
import 'package:allenamenti_app/storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory d;
  setUp(() async => d = await Directory.systemTemp.createTemp('ripristino'));
  tearDown(() async => d.delete(recursive: true));

  Future<void> scrivi(String nome, String testo) =>
      File('${d.path}/$nome').writeAsString(testo);
  String leggi(String nome) => File('${d.path}/$nome').readAsStringSync();
  List<String> csv() => [
    for (final f in d.listSync().whereType<File>())
      if (f.path.endsWith('.csv')) f.uri.pathSegments.last,
  ]..sort();

  final backup = DatiBackup(DateTime(2026, 10, 23), const {
    'sessioni.csv': 'id,data,sport\nnuova,2026-10-24,Corsa\n',
    'piano.csv': 'data,fascia,sport\n2026-11-02,Mattina,Bici\n',
  });

  test('i dati del backup prendono il posto di quelli di adesso', () async {
    await scrivi('sessioni.csv', 'id,data,sport\nvecchia,2026-10-01,Nuoto\n');
    await scrivi('misure.csv', 'data,peso_kg\n2026-10-01,74\n');
    await scrivi('foto_1.jpg', 'foto');
    final prima = await ripristinaIn(d, backup);
    expect(csv(), ['piano.csv', 'sessioni.csv']);
    expect(leggi('sessioni.csv'), contains('nuova'));
    // Quelli di prima: in memoria e nella copia di sicurezza.
    expect(prima.keys, unorderedEquals(['sessioni.csv', 'misure.csv']));
    final copia = leggiBackup(
      File('${d.path}/$fileCopiaRipristino').readAsBytesSync(),
    );
    expect(copia.csv['misure.csv'], contains('74'));
    // La cartella di appoggio non resta.
    expect(Directory('${d.path}/ripristino_tmp').existsSync(), isFalse);
    // Altri file (la foto) non si toccano.
    expect(leggi('foto_1.jpg'), 'foto');
  });

  test('tornare indietro rimette i dati di prima', () async {
    await scrivi('sessioni.csv', 'id,data,sport\nvecchia,2026-10-01,Nuoto\n');
    final prima = await ripristinaIn(d, backup);
    await rimettiIn(d, prima);
    expect(csv(), ['sessioni.csv']);
    expect(leggi('sessioni.csv'), contains('vecchia'));
  });

  group('scrittura sicura', () {
    test('sostituisce il file e non lascia temporanei', () async {
      final f = File('${d.path}/sessioni.csv');
      await scriviSicuro(f, 'prima\n');
      await scriviSicuro(f, 'dopo\n');
      expect(f.readAsStringSync(), 'dopo\n');
      expect(d.listSync().where((e) => e.path.endsWith('.tmp')), isEmpty);
    });

    test('due scritture insieme: il file resta intero', () async {
      final f = File('${d.path}/sessioni.csv');
      final a = 'a' * 200000, b = 'b' * 200000;
      await Future.wait([scriviSicuro(f, a), scriviSicuro(f, b)]);
      expect(f.readAsStringSync(), anyOf(a, b));
    });

    test('se la scrittura fallisce resta il file di prima', () async {
      final f = File('${d.path}/sessioni.csv');
      await scriviSicuro(f, 'buono\n');
      // Guasto simulato: la cartella di destinazione non esiste.
      final altrove = File('${d.path}/manca/sessioni.csv');
      await expectLater(
        scriviSicuro(altrove, 'x'),
        throwsA(isA<FileSystemException>()),
      );
      expect(f.readAsStringSync(), 'buono\n');
    });
  });

  test('se lo spostamento fallisce si torna ai dati di prima', () async {
    await scrivi('sessioni.csv', 'id,data,sport\nvecchia,2026-10-01,Nuoto\n');
    // Una cartella con il nome di un file del backup: non si può sostituire.
    await Directory('${d.path}/piano.csv').create();
    await expectLater(
      ripristinaIn(d, backup),
      throwsA(isA<FileSystemException>()),
    );
    expect(leggi('sessioni.csv'), contains('vecchia'));
    expect(Directory('${d.path}/ripristino_tmp').existsSync(), isFalse);
  });
}
