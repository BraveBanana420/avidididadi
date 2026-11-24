import 'dart:convert';
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

  test('lo squat a corpo libero ha la sua animazione', () {
    expect(
      animazioneDi('Bodyweight_Squat'),
      '${cartellaAnimazioni}bodyweight_squat.webp',
    );
  });

  test('ogni animazione rispetta il suo limite di peso', () {
    // 300 KB a corpo libero, 400 KB con attrezzi o macchine (più dettagli).
    final esercizi = (jsonDecode(
      File('assets/esercizi.json').readAsStringSync(),
    ) as List).cast<Map<String, dynamic>>();
    for (final MapEntry(:key, :value) in animazioniEsercizi.entries) {
      final e = esercizi.firstWhere((x) => x['id'] == key);
      final conAttrezzi = (e['attrezzi'] as List).isNotEmpty;
      final byte = File('$cartellaAnimazioni$value').lengthSync();
      expect(
        byte,
        lessThanOrEqualTo((conAttrezzi ? 400 : 300) * 1024),
        reason: value,
      );
    }
  });

  test('ogni animazione è di un esercizio del catalogo', () {
    final ids = (jsonDecode(
      File('assets/esercizi.json').readAsStringSync(),
    ) as List).map((e) => e['id']).toSet();
    for (final id in animazioniEsercizi.keys) {
      expect(ids, contains(id));
    }
  });

  test('ogni animazione ha il video originale e la sua fonte', () {
    final fonti = File('docs/animazioni/FONTI.md').readAsStringSync();
    for (final file in animazioniEsercizi.values) {
      final nome = file.replaceAll('.webp', '');
      expect(
        File('docs/animazioni/originali/$nome.mp4').existsSync(),
        isTrue,
        reason: file,
      );
      expect(fonti, contains('`$file`'), reason: file);
    }
  });

  test('pubspec registra la cartella delle animazioni', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('- $cartellaAnimazioni'),
    );
  });

  test('le richieste approvate sono complete e di esercizi del catalogo', () {
    // agents/animazione.mjs prende vista, partenza, posa e movimento solo da
    // qui: una voce sbagliata fermerebbe chi fa l'animazione.
    final esercizi = (jsonDecode(
      File('assets/esercizi.json').readAsStringSync(),
    ) as List).cast<Map<String, dynamic>>();
    final ids = esercizi.map((e) => e['id']).toSet();
    final richieste =
        (jsonDecode(File('docs/animazioni/richieste.json').readAsStringSync())
                as Map<String, dynamic>)['esercizi']
            as Map<String, dynamic>;
    for (final MapEntry(:key, :value) in richieste.entries) {
      final r = value as Map<String, dynamic>;
      expect(ids, contains(key));
      expect(['tre_quarti', 'lato', 'fronte'], contains(r['vista']));
      expect(['avatar', 'genera'], contains(r['partenza']), reason: key);
      expect(r['movimento'], matches(RegExp(r'\bhe\b')), reason: key);
      expect(
        r['approvata'],
        matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
        reason: key,
      );
      if (r['partenza'] == 'genera') {
        expect(r['posa'], startsWith('He '), reason: key);
      } else {
        // L'avatar è a corpo libero: con un attrezzo l'immagine va generata.
        final e = esercizi.firstWhere((x) => x['id'] == key);
        expect(e['attrezzi'], isEmpty, reason: key);
      }
    }
    // Ogni animazione nell'app si può rifare con la stessa ricetta.
    for (final id in animazioniEsercizi.keys) {
      expect(richieste.keys, contains(id));
    }
  });
}
