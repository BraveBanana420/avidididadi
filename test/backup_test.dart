import 'dart:convert';
import 'dart:io';

import 'package:allenamenti_app/backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final creato = DateTime(2026, 10, 23, 9, 30);
  final csv = {
    'sessioni.csv': 'id,data,sport\n1,2026-10-20,Corsa\n2,2026-10-21,Bici\n',
    'piano.csv': 'data,fascia,sport\n2026-10-24,Mattina,Corsa\n',
    'health_connect.csv': 'chiave,valore\ntoken,abc\n',
  };

  test('backup e lettura: CSV e foto tornano uguali, il token no', () {
    final b = leggiBackup(
      creaBackup(
        csv,
        nomeFoto: 'foto_123.jpg',
        foto: [1, 2, 3],
        creato: creato,
      ),
    );
    expect(b.csv.keys.toSet(), {'sessioni.csv', 'piano.csv'});
    expect(b.csv['sessioni.csv'], csv['sessioni.csv']);
    expect(b.foto, [1, 2, 3]);
    expect(b.nomeFoto, 'foto_123.jpg');
    expect(b.creato, creato);
    expect(b.riassunto, contains('2 sessioni'));
    expect(b.riassunto, contains('foto del profilo'));
  });

  test('un file qualsiasi non è un backup', () {
    expect(() => leggiBackup(utf8.encode('ciao')), throwsFormatException);
    expect(
      () => leggiBackup(gzip.encode(utf8.encode('{"formato":"altro"}'))),
      throwsFormatException,
    );
  });

  test('nomi di file pericolosi vengono ignorati', () {
    final j = {
      'formato': 'avidididadi-backup',
      'versione': 1,
      'creato': creato.toIso8601String(),
      'file': {
        '../../altro.csv': 'x',
        'sessioni.csv': 'id\n',
        'script.sh': 'x',
      },
      'foto': {
        'nome': '../foto.jpg',
        'dati': base64Encode([1]),
      },
    };
    final b = leggiBackup(gzip.encode(utf8.encode(jsonEncode(j))));
    expect(b.csv.keys, ['sessioni.csv']);
    expect(b.foto, isNull);
  });

  test('backup di una versione più recente: si chiede di aggiornare', () {
    final j = {'formato': 'avidididadi-backup', 'versione': 99, 'file': {}};
    expect(
      () => leggiBackup(gzip.encode(utf8.encode(jsonEncode(j)))),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'messaggio',
          contains('aggiornala'),
        ),
      ),
    );
  });
}
