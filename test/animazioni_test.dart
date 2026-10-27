import 'dart:io';

import 'package:allenamenti_app/animazioni_esercizi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('il push-up ha il WebP, gli altri esercizi no', () {
    expect(animazioneDi('Pushups'), 'assets/exercises/animated/push_up.webp');
    expect(animazioneDi('Incline_Push-Up'), isNull);
  });

  test('ogni animazione della mappa esiste ed è un WebP animato', () {
    for (final file in animazioniEsercizi.values) {
      final f = File('$cartellaAnimazioni$file');
      expect(f.existsSync(), isTrue, reason: file);
      final dati = f.readAsBytesSync();
      expect(String.fromCharCodes(dati.sublist(8, 12)), 'WEBP');
      // Il blocco ANIM c'è solo nei WebP animati.
      expect(String.fromCharCodes(dati).contains('ANIM'), isTrue, reason: file);
    }
  });

  test('pubspec registra la cartella delle animazioni', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('- $cartellaAnimazioni'),
    );
  });
}
