import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/feedback.dart';
import 'package:allenamenti_app/generatore_forza.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generatore_forza_test.dart' show pianoDiProva;

FeedbackSessione fb(
  int giorno,
  int fatica, {
  bool completata = true,
  bool dolore = false,
}) => FeedbackSessione(
  data: DateTime(2026, 10, giorno),
  fatica: fatica,
  completata: completata,
  dolore: dolore,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('esito', () {
    test('facile, giusto o duro rispetto alla fatica prevista', () {
      expect(esito(fb(19, 5), 7), Esito.facile);
      expect(esito(fb(19, 7), 7), Esito.giusto);
      expect(esito(fb(19, 8), 7), Esito.giusto);
      expect(esito(fb(19, 9), 7), Esito.duro);
      // Serie saltate o dolore contano come troppo duro anche con poca fatica.
      expect(esito(fb(19, 5, completata: false), 7), Esito.duro);
      expect(esito(fb(19, 5, dolore: true), 7), Esito.duro);
    });
  });

  group('regola', () {
    test('facile alza il carico, duro lo abbassa, giusto lo lascia', () {
      int dopo(FeedbackSessione f) => regola(
        storico: [f],
        faticaObiettivo: 7,
        regolazione: 0,
        livello: 'intermedio',
      ).regolazione;
      expect(dopo(fb(19, 4)), 1);
      expect(dopo(fb(19, 9)), -1);
      expect(dopo(fb(19, 7)), 0);
    });

    test('il dolore alleggerisce e suggerisce di fermarsi se continua', () {
      final r = regola(
        storico: [fb(19, 6, dolore: true)],
        faticaObiettivo: 7,
        regolazione: 2,
        livello: 'intermedio',
      );
      expect(r.regolazione, 1);
      expect(r.messaggio, contains('medico'));
    });

    test('tre sessioni facili di fila fanno salire di livello', () {
      final r = regola(
        storico: [fb(19, 4), fb(21, 5), fb(23, 4)],
        faticaObiettivo: 7,
        regolazione: 2,
        livello: 'principiante',
      );
      expect(r.livello, 'intermedio');
      expect(r.regolazione, 0); // si riparte dal nuovo livello
    });

    test('tre sessioni dure di fila fanno scendere di livello', () {
      final r = regola(
        storico: [fb(19, 9), fb(21, 10), fb(23, 6, completata: false)],
        faticaObiettivo: 7,
        regolazione: 0,
        livello: 'avanzato',
      );
      expect(r.livello, 'intermedio');
    });

    test('dopo un cambio di livello servono tre feedback nuovi', () {
      final r = regola(
        storico: [fb(19, 4), fb(21, 5), fb(23, 4), fb(26, 4)],
        faticaObiettivo: 7,
        regolazione: 0,
        livello: 'intermedio',
        dalCambio: DateTime(2026, 10, 23),
      );
      expect(r.livello, 'intermedio');
      expect(r.regolazione, 1);
    });

    test('la regolazione resta nei limiti', () {
      final r = regola(
        storico: [fb(19, 2)],
        faticaObiettivo: 7,
        regolazione: regolazioneMax,
        livello: 'avanzato',
      );
      expect(r.regolazione, regolazioneMax);
    });
  });

  group('generatore con regolazione', () {
    late List<Esercizio> esercizi;
    setUpAll(() async => esercizi = await caricaEsercizi());
    final lunedi = DateTime(2026, 10, 19);

    List<WorkoutStep> principali(Attrezzatura a, int regolazione) =>
        generaPianoForza(
              piano: pianoDiProva(1),
              esercizi: esercizi,
              attrezzatura: a,
              obiettivo: 'generale',
              livello: 'intermedio',
              inizio: lunedi,
              da: lunedi,
              regolazione: regolazione,
            ).passi
            .where(
              (s) =>
                  s.id == '$prefissoForza${isoData(lunedi)}' &&
                  s.fase == 'principale',
            )
            .toList();

    double peso(WorkoutStep s) => double.parse(
      RegExp(r'circa (\d+(?:\.\d+)?) kg').firstMatch(s.note)!.group(1)!,
    );

    test('con più pesi disponibili sale il peso, non le ripetizioni', () {
      const manubri = <String, List<double>>{
        'manubri': [2, 4, 6, 8, 10, 12, 14, 16, 18, 20],
        'panca': [],
      };
      final base = principali(
        manubri,
        0,
      ).where((s) => s.note.contains('circa')).toList();
      final su = principali(
        manubri,
        2,
      ).where((s) => s.note.contains('circa')).toList();
      expect(base, isNotEmpty);
      expect(peso(su.first), greaterThan(peso(base.first)));
      expect(su.first.ripetizioni, base.first.ripetizioni);
    });

    test('a corpo libero salgono o scendono le ripetizioni', () {
      int minimo(WorkoutStep s) => int.parse(s.ripetizioni.split('-').first);
      final base = principali(
        {},
        0,
      ).firstWhere((s) => s.ripetizioni.contains('-'));
      final su = principali(
        {},
        1,
      ).firstWhere((s) => s.esercizio == base.esercizio);
      final giu = principali(
        {},
        -2,
      ).firstWhere((s) => s.esercizio == base.esercizio);
      expect(minimo(su), minimo(base) + 2);
      expect(minimo(giu), lessThan(minimo(base)));
      expect(minimo(giu), greaterThanOrEqualTo(3));
    });
  });
}
