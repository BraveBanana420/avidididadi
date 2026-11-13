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

    test('"Inizia oggi": lunedì, mercoledì e venerdì, weekend libero', () {
      final s = settimanaDa(
        sport: ['Forza', 'Corsa'],
        giorni: 3,
        minuti: 30,
        feriali: true,
      );
      expect(
        [for (final x in s) (x.giorno, x.sport)],
        [(1, 'Corsa'), (3, 'Forza'), (5, 'Corsa')],
      );
    });

    test('"Inizia oggi" con 4 o 5 sport: ancora niente weekend', () {
      for (final n in [4, 5]) {
        final s = settimanaDa(
          sport: ['Corsa', 'Forza', 'Nuoto', 'Bici', 'Mobilità'],
          giorni: n,
          minuti: 30,
          feriali: true,
        );
        expect(s.length, n);
        expect(s.every((x) => x.giorno <= 5), true);
      }
    });

    group('"Inizia oggi": la prima seduta è oggi', () {
      // Lunedì 16, mercoledì 18 e venerdì 20 novembre 2026, poi lunedì 23.
      PianoRiga riga(int giorno, String sport) => PianoRiga(
        data: DateTime(2026, 11, giorno),
        fascia: 'Mattina',
        sport: sport,
        durataMin: 30,
      );
      final piano = [
        riga(16, 'Corsa'),
        riga(18, 'Forza'),
        riga(20, 'Corsa'),
        riga(23, 'Corsa'),
      ];
      List<int> giorni(DateTime oggi) => [
        for (final r in conPrimaSedutaOggi(piano, oggi)) r.data.day,
      ];

      test('oggi è già un giorno di allenamento: niente cambia', () {
        expect(giorni(DateTime(2026, 11, 18)), [16, 18, 20, 23]);
      });

      test('di martedì: la seduta di mercoledì passa a oggi', () {
        final p = conPrimaSedutaOggi(piano, DateTime(2026, 11, 17));
        expect([for (final r in p) r.data.day], [16, 17, 20, 23]);
        expect(p[1].sport, 'Forza');
        expect(p[1].durataMin, 30);
      });

      test('di sabato: la seduta di lunedì passa a oggi, il resto resta', () {
        expect(giorni(DateTime(2026, 11, 21)), [16, 18, 20, 21]);
      });

      test('piano finito: niente da anticipare', () {
        expect(giorni(DateTime(2026, 11, 25)), [16, 18, 20, 23]);
      });
    });

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
