import 'dart:io';

import 'package:allenamenti_app/animazioni_esercizi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('senza animazione l\'esercizio usa le foto (anche il push-up)', () {
    expect(animazioneDi('Pushups'), isNull);
    expect(animazioneDi('Incline_Push-Up'), isNull);
  });

  test('una riga della mappa diventa il percorso dell\'asset', () {
    for (final MapEntry(:key, :value) in animazioniEsercizi.entries) {
      expect(animazioneDi(key), '$cartellaAnimazioni$value');
    }
  });

  test('la cartella delle animazioni esiste anche vuota', () {
    // pubspec la registra: se mancasse, la compilazione si fermerebbe.
    expect(Directory(cartellaAnimazioni).existsSync(), isTrue);
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
