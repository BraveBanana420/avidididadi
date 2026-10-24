import 'package:allenamenti_app/generatore_endurance.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lunedi = DateTime(2026, 10, 26);

  /// Otto settimane: nuoto e bici il martedì, corsa giovedì e sabato.
  List<PianoRiga> piano({int settimane = 8}) => [
    for (var w = 0; w < settimane; w++)
      for (final (giorno, sport) in [
        (1, 'Nuoto'),
        (1, 'Bici'),
        (3, 'Corsa'),
        (5, 'Corsa'),
      ])
        PianoRiga(
          data: lunedi.add(Duration(days: 7 * w + giorno)),
          fascia: 'Mattina',
          sport: sport,
          durataMin: 60,
        ),
  ];

  PianoEndurance genera(
    Set<String> sport, {
    Obiettivo? obiettivo,
    int? passoCritico,
    DateTime? da,
  }) => generaPianoEndurance(
    piano: piano(),
    storico: const [],
    sport: sport,
    inizio: lunedi,
    da: da ?? lunedi,
    obiettivo: obiettivo,
    passoCritico: passoCritico,
  );

  String tipo(PianoEndurance p, int settimana, int giorno, String sport) =>
      p.tipi[(lunedi.add(Duration(days: 7 * settimana + giorno)), sport)]!;

  int durata(PianoEndurance p, int settimana, int giorno, String sport) {
    final id =
        '${prefissoEndurance(sport)}'
        '${isoData(lunedi.add(Duration(days: 7 * settimana + giorno)))}';
    return p.passi.firstWhere((w) => w.id == id).durataTot;
  }

  group('corsa', () {
    test('giovedì qualità, sabato lungo; una seduta per giorno', () {
      final p = genera({'Corsa'});
      expect(p.programma.length, 16);
      expect(p.programma.every((r) => r.idWorkout.startsWith('corsa_')), true);
      expect(tipo(p, 0, 3, 'Corsa'), 'Fartlek');
      expect(tipo(p, 1, 3, 'Corsa'), 'Tempo run');
      expect(tipo(p, 0, 5, 'Corsa'), 'Lungo');
    });

    test('il lungo cresce nel blocco e cala nella settimana di scarico', () {
      final p = genera({'Corsa'});
      expect(
        [for (var w = 0; w < 5; w++) durata(p, w, 5, 'Corsa')],
        [60, 65, 70, 45, 60],
      );
      // Nella settimana di scarico niente qualità vera: solo allunghi.
      expect(tipo(p, 3, 3, 'Corsa'), 'Allunghi');
    });

    test('verso la gara: ritmo gara in rifinitura, poi scarico più corto', () {
      final mezza = Obiettivo(
        sport: 'Corsa',
        gara: 'mezza',
        data: lunedi.add(const Duration(days: 7 * 7 + 6)),
      );
      final p = genera({'Corsa'}, obiettivo: mezza);
      final fasi = [
        for (var w = 0; w < 8; w++)
          faseDel(mezza, lunedi.add(Duration(days: 7 * w))),
      ];
      expect(fasi, containsAll([Fase.rifinitura, Fase.scarico, Fase.gara]));
      for (var w = 0; w < 8; w++) {
        if (w % 4 == 3) continue; // settimana di scarico del blocco
        final atteso = switch (fasi[w]) {
          Fase.rifinitura => 'Ritmo gara',
          Fase.scarico || Fase.gara => 'Allunghi',
          _ => null,
        };
        if (atteso != null) expect(tipo(p, w, 3, 'Corsa'), atteso);
      }
      final ultima = fasi.lastIndexOf(Fase.gara);
      expect(
        durata(p, ultima, 5, 'Corsa'),
        lessThan(durata(p, fasi.indexOf(Fase.rifinitura), 5, 'Corsa')),
      );
    });

    test('le sedute prima di "da" non si generano', () {
      final p = genera({'Corsa'}, da: lunedi.add(const Duration(days: 14)));
      expect(p.programma.length, 12);
      expect(
        p.programma.every(
          (r) => !r.data.isBefore(lunedi.add(const Duration(days: 14))),
        ),
        true,
      );
    });
  });

  group('nuoto e bici', () {
    test('nuoto al passo critico, soglia a settimane alterne', () {
      final p = genera({'Nuoto'}, passoCritico: 120);
      expect(tipo(p, 0, 1, 'Nuoto'), 'Tecnica');
      expect(tipo(p, 1, 1, 'Nuoto'), 'Soglia');
      final soglia = p.passi.where(
        (w) =>
            w.id == 'nuoto_${isoData(lunedi.add(const Duration(days: 8)))}' &&
            w.fase == 'principale',
      );
      expect(soglia.single.intensita, 'passo 2:00/100 m');
    });

    test('una sola uscita in bici: Z2 e intervalli alternati', () {
      final p = genera({'Bici'});
      expect(tipo(p, 0, 1, 'Bici'), 'Uscita');
      expect(tipo(p, 1, 1, 'Bici'), 'Intervalli');
      expect(p.tipi.keys.every((k) => k.$2 == 'Bici'), true);
    });

    test('solo gli sport scelti', () {
      final p = genera({'Nuoto', 'Bici'});
      expect(p.programma.map((r) => r.sport).toSet(), {'Nuoto', 'Bici'});
      expect(idEndurance('bici_2026-10-27'), true);
      expect(idEndurance('forza_2026-10-27'), false);
    });
  });

  group('progressione: durata o intensità', () {
    PianoEndurance conRegolazione(String modo, int r) => generaPianoEndurance(
      piano: piano(),
      storico: const [],
      sport: {'Corsa', 'Bici'},
      inizio: lunedi,
      da: lunedi,
      regolazione: {'Corsa': r, 'Bici': r},
      progressione: {'Corsa': modo, 'Bici': modo},
    );

    WorkoutStep principale(PianoEndurance p, int giorno, String sport) =>
        p.passi.firstWhere(
          (w) =>
              w.id ==
                  '${prefissoEndurance(sport)}'
                      '${isoData(lunedi.add(Duration(days: giorno)))}' &&
              w.fase == 'principale',
        );

    test('i passi si dividono secondo il modo scelto', () {
      expect(dividiProgressione(3, 'durata'), (3, 0));
      expect(dividiProgressione(3, 'intensita'), (0, 3));
      expect(dividiProgressione(3, 'auto'), (1, 2));
      expect(dividiProgressione(-1, 'auto'), (0, -1));
    });

    test('intensità: stessa durata, recuperi più brevi e più ripetizioni', () {
      final base = conRegolazione('intensita', 0);
      final dura = conRegolazione('intensita', 2);
      // Giovedì della prima settimana: Fartlek di 60 minuti.
      expect(durata(dura, 0, 3, 'Corsa'), durata(base, 0, 3, 'Corsa'));
      final f0 = principale(base, 3, 'Corsa'),
          f2 = principale(dura, 3, 'Corsa');
      expect(int.parse(f2.recuperoS), lessThan(int.parse(f0.recuperoS)));
      expect(int.parse(f2.serie), greaterThan(int.parse(f0.serie)));
      // Bici: intervalli (settimana dispari) con recuperi più corti.
      final b0 = principale(base, 8, 'Bici'), b2 = principale(dura, 8, 'Bici');
      expect(int.parse(b2.recuperoS), lessThan(int.parse(b0.recuperoS)));
      // Il lungo resta di 60 minuti ma finisce in progressione.
      expect(durata(dura, 0, 5, 'Corsa'), 60);
      expect(
        dura.passi.any(
          (w) =>
              w.id == 'corsa_${isoData(lunedi.add(const Duration(days: 5)))}' &&
              w.descrizione == 'Finale in progressione',
        ),
        true,
      );
    });

    test('durata: sedute più lunghe, stessa intensità', () {
      final base = conRegolazione('durata', 0);
      final lunga = conRegolazione('durata', 2);
      expect(
        durata(lunga, 0, 5, 'Corsa'),
        greaterThan(durata(base, 0, 5, 'Corsa')),
      );
      expect(
        principale(lunga, 3, 'Corsa').recuperoS,
        principale(base, 3, 'Corsa').recuperoS,
      );
    });

    test("nella settimana di scarico l'intensità non sale", () {
      final base = conRegolazione('intensita', 0);
      final dura = conRegolazione('intensita', 3);
      // Quarta settimana: allunghi, uguali con o senza regolazione.
      expect(
        principale(dura, 21 + 3, 'Corsa').serie,
        principale(base, 21 + 3, 'Corsa').serie,
      );
    });
  });
}
