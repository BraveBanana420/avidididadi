import 'package:allenamenti_app/benvenuto.dart';
import 'package:allenamenti_app/generatore_endurance.dart';
import 'package:allenamenti_app/glossario.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('settimana dalla configurazione guidata', () {
    test('3 giorni con corsa e forza: la corsa cade il sabato', () {
      final s = settimanaDa(sport: ['Forza', 'Corsa'], giorni: 3, minuti: 30);
      expect(
        [for (final x in s) (x.giorno, x.sport)],
        [(1, 'Corsa'), (3, 'Forza'), (6, 'Corsa')],
      );
      expect(s.every((x) => x.durataMin == 30), true);
    });

    test('più sport che giorni: ne entrano quanti sono i giorni', () {
      final s = settimanaDa(
        sport: ['Corsa', 'Forza', 'Nuoto', 'Bici'],
        giorni: 2,
        minuti: 45,
      );
      expect(s.map((x) => x.giorno), [2, 6]);
      expect(s.map((x) => x.sport).toSet().length, 2);
    });

    test('"Inizia oggi": oggi è sempre un giorno di allenamento', () {
      for (var giorni = 1; giorni <= 6; giorni++) {
        for (var oggi = 1; oggi <= 7; oggi++) {
          final s = settimanaDa(
            sport: ['Corsa', 'Forza'],
            giorni: giorni,
            minuti: 30,
            oggi: oggi,
          );
          expect(s.length, giorni);
          expect(s.map((x) => x.giorno).toSet().length, giorni);
          expect(s.any((x) => x.giorno == oggi), true, reason: '$giorni/$oggi');
        }
      }
    });

    test('"Inizia oggi" di venerdì: lunedì, mercoledì e venerdì', () {
      final s = settimanaDa(
        sport: ['Corsa', 'Forza'],
        giorni: 3,
        minuti: 30,
        oggi: 5,
      );
      expect(s.map((x) => x.giorno), [1, 3, 5]);
    });

    test(
      '"Inizia oggi" in un giorno già previsto: la settimana non cambia',
      () {
        final s = settimanaDa(
          sport: ['Forza', 'Corsa'],
          giorni: 3,
          minuti: 30,
          oggi: 3,
        );
        expect(
          [for (final x in s) (x.giorno, x.sport)],
          [(1, 'Corsa'), (3, 'Forza'), (6, 'Corsa')],
        );
      },
    );

    test('"Inizia oggi": tre giorni, o uno per sport se sono di più', () {
      expect(giorniSubito(1), 3);
      expect(giorniSubito(4), 4);
      expect(giorniSubito(9), 6);
    });

    test('nessuno sport, nessun giorno', () {
      expect(settimanaDa(sport: [], giorni: 3, minuti: 30), isEmpty);
    });
  });

  test(
    'chi parte da zero: primo mese di corsa e camminata, niente qualità',
    () {
      final lunedi = DateTime(2026, 10, 26);
      final piano = [
        for (var w = 0; w < 6; w++)
          for (final g in [0, 5])
            PianoRiga(
              data: lunedi.add(Duration(days: 7 * w + g)),
              fascia: 'Mattina',
              sport: 'Corsa',
              durataMin: 30,
            ),
      ];
      final p = generaPianoEndurance(
        piano: piano,
        storico: const [],
        sport: {'Corsa'},
        inizio: lunedi,
        da: lunedi,
        principiante: true,
      );
      String tipo(int w, int g) =>
          p.tipi[(lunedi.add(Duration(days: 7 * w + g)), 'Corsa')]!;
      expect([for (var w = 0; w < 4; w++) tipo(w, 0)], everyElement('Lento'));
      expect(
        p.passi
            .firstWhere((x) => x.id == 'corsa_${isoData(lunedi)}')
            .descrizione,
        contains('camminata'),
      );
      // Dal secondo mese arriva la qualità, ma solo la più dolce.
      expect(tipo(4, 0), 'Fartlek');
    },
  );

  test('ogni tipo di seduta generato ha una spiegazione', () {
    for (final t in [
      'Lento',
      'Lungo',
      'Fartlek',
      'Tempo run',
      'Ripetute',
      'Ritmo gara',
      'Allunghi',
      'Tecnica',
      'Soglia',
      'Uscita',
      'Uscita lunga',
      'Intervalli',
    ]) {
      expect(spiegaSeduta('Corsa', t), isNotNull, reason: t);
    }
    expect(spiegaSeduta('Forza', ''), isNotNull);
    expect(sensazioneDi('intensità zona 2'), 'facile: riesci a parlare');
    expect(sensazioneDi('recupero 60 s'), isNull);
  });
}
