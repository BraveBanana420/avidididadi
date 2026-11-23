import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Versione -> punti di una sezione "## x.y.z" del changelog.
Map<String, List<String>> sezioni(String file) {
  final out = <String, List<String>>{};
  List<String>? attuale;
  for (final r in File(file).readAsLinesSync()) {
    if (r.startsWith('## ')) {
      attuale = out[r.substring(3).trim()] = [];
    } else if (r.startsWith('- ')) {
      attuale?.add(r);
    }
  }
  return out;
}

void main() {
  // Le novità vanno nelle note della release e nell'avviso dell'app, nella
  // lingua di chi la usa: le traduzioni seguono l'italiano punto per punto.
  final it = sezioni('CHANGELOG.md');

  for (final lingua in ['en', 'el']) {
    test('CHANGELOG.$lingua.md ha le stesse versioni e gli stessi punti', () {
      final altro = sezioni('CHANGELOG.$lingua.md');
      expect(altro.keys.toList(), it.keys.toList());
      for (final v in it.keys) {
        expect(altro[v], hasLength(it[v]!.length), reason: 'versione $v');
      }
    });
  }

  test('la versione di pubblicazione ha le sue novità', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final versione = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(it.keys, contains(versione));
  });
}
