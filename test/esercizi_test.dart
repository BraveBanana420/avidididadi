import 'package:allenamenti_app/esercizi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conteggio degli esercizi: singolare e plurale', () {
    expect(quantiEsercizi(1), '1 esercizio');
    expect(quantiEsercizi(6), '6 esercizi');
    expect(quantiEsercizi(0), '0 esercizi');
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  group('leggiPesi', () {
    test('lista con virgole e spazi', () {
      expect(leggiPesi('8, 12, 16'), [8, 12, 16]);
      expect(leggiPesi('16 8 12'), [8, 12, 16]);
      expect(leggiPesi('8;12'), [8, 12]);
    });

    test('lista con virgole senza spazi', () {
      expect(leggiPesi('8,12,16'), [8, 12, 16]);
    });

    test('decimali con virgola o punto', () {
      expect(leggiPesi('2,5'), [2.5]);
      expect(leggiPesi('1.25, 2,5, 5'), [1.25, 2.5, 5]);
    });

    test('intervallo dei manubri regolabili a passi di 2 kg', () {
      expect(leggiPesi('2-10'), [2, 4, 6, 8, 10]);
      expect(leggiPesi('3-8'), [3, 5, 7, 8]);
    });

    test('testo senza numeri', () {
      expect(leggiPesi(''), isEmpty);
      expect(leggiPesi('niente'), isEmpty);
    });
  });

  group('catalogo', () {
    late List<Esercizio> esercizi;
    setUpAll(() async => esercizi = await caricaEsercizi());

    test('si carica ed è coerente con attrezzi, schemi e muscoli', () {
      expect(esercizi.length, greaterThan(100));
      final chiavi = attrezzi.map((a) => a.chiave).toSet();
      for (final e in esercizi) {
        expect(nomiSchemi, contains(e.schema), reason: e.id);
        expect(e.istruzioni, isNotEmpty, reason: e.id);
        expect(e.immagini, isNotEmpty, reason: e.id);
        for (final g in e.attrezzi) {
          expect(chiavi, containsAll(g), reason: e.id);
        }
        for (final m in [...e.muscoli, ...e.muscoliSecondari]) {
          expect(nomiMuscoli, contains(m), reason: e.id);
        }
      }
      expect(esercizi.map((e) => e.id).toSet().length, esercizi.length);
    });

    test('fattibilità in base all\'attrezzatura', () {
      Esercizio trova(String id) => esercizi.firstWhere((e) => e.id == id);
      expect(trova('Pushups').fattibile({}), isTrue);
      expect(
        trova('Dumbbell_Bench_Press').fattibile({
          'manubri': [10],
        }),
        isFalse,
      );
      expect(
        trova('Dumbbell_Bench_Press').fattibile({
          'manubri': [10],
          'panca': [],
        }),
        isTrue,
      );
      // Goblet squat: basta uno tra kettlebell, manubri o dischi.
      expect(
        trova('Goblet_Squat').fattibile({
          'dischi': [10],
        }),
        isTrue,
      );
      expect(trova('Goblet_Squat').fattibile({'elastici': []}), isFalse);
    });
  });
}
