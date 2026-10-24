import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/feedback.dart';
import 'package:allenamenti_app/recupero.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final oggi = DateTime(2026, 10, 22);
  DateTime fa(int giorni, [int ora = 7]) =>
      DateTime(oggi.year, oggi.month, oggi.day - giorni, ora);

  group('dati per giorno', () {
    test('FC a riposo minima, HRV media, sonno sommato al risveglio', () {
      final g = giorniRecupero(
        fcRiposo: [(fa(0), 52), (fa(0, 12), 55)],
        hrv: [(fa(0), 40), (fa(0, 3), 50)],
        sonno: [(fa(0), 420), (fa(0, 15), 30)], // notte più pisolino
      );
      expect(g.length, 1);
      expect(g.single.fcRiposo, 52);
      expect(g.single.hrv, 45);
      expect(g.single.sonnoMin, 450);
    });

    test('un giorno riletto sostituisce quello salvato', () {
      final u = unisciRecupero(
        [GiornoRecupero(fa(1), fcRiposo: 50), GiornoRecupero(fa(0), hrv: 30)],
        [GiornoRecupero(fa(0), hrv: 42)],
      );
      expect(u.map((g) => g.hrv), [0, 42]);
    });

    test('salvataggio e lettura', () {
      final g = GiornoRecupero(fa(0), fcRiposo: 51, hrv: 44.5, sonnoMin: 400);
      final t = Tabella.da(
        '${recuperoHeader.join(',')}\n${g.toRow().join(',')}',
      )!;
      final letto = GiornoRecupero.da(t, t.righe.single)!;
      expect((letto.fcRiposo, letto.hrv, letto.sonnoMin), (51, 44.5, 400));
    });

    test('FC a riposo tipica: mediana delle ultime due settimane', () {
      final g = [
        for (var i = 0; i < 20; i++)
          GiornoRecupero(fa(i, 0), fcRiposo: i < 14 ? 50 + i % 3 : 70),
      ];
      expect(fcRiposoTipica(g, oggi), 51);
      expect(fcRiposoTipica([], oggi), 0);
    });
  });

  group('valutazione del recupero', () {
    // Quattro settimane di riferimento: HRV 50 ms, FC a riposo 50 bpm.
    final base = [
      for (var i = 1; i <= 28; i++)
        GiornoRecupero(fa(i, 0), fcRiposo: 50, hrv: 50, sonnoMin: 420),
    ];

    test('HRV bassa, FC alta e poco sonno: recupero basso', () {
      final p = valutaRecupero([
        ...base,
        GiornoRecupero(oggi, fcRiposo: 57, hrv: 40, sonnoMin: 300),
      ], oggi)!;
      expect(p.stato, StatoRecupero.basso);
      expect(p.motivi.length, 3);
    });

    test('valori come al solito: nella norma', () {
      final p = valutaRecupero([
        ...base,
        GiornoRecupero(oggi, fcRiposo: 51, hrv: 49, sonnoMin: 420),
      ], oggi)!;
      expect(p.stato, StatoRecupero.normale);
      expect(p.motivi, isEmpty);
    });

    test('HRV alta e sonno lungo: recupero buono', () {
      final p = valutaRecupero([
        ...base,
        GiornoRecupero(oggi, hrv: 58, sonnoMin: 480),
      ], oggi)!;
      expect(p.stato, StatoRecupero.buono);
    });

    test('senza dati di oggi non si valuta', () {
      expect(valutaRecupero(base, oggi), isNull);
    });
  });

  group('feedback di corsa, nuoto e bici', () {
    FeedbackSessione f(int fatica, {bool dolore = false}) => FeedbackSessione(
      data: oggi,
      sport: 'Corsa',
      fatica: fatica,
      dolore: dolore,
    );

    test('la fatica attesa dipende dal tipo di seduta', () {
      expect(faticaPrevista('Lento'), 4);
      expect(faticaPrevista('Tempo run'), 7);
      expect(faticaPrevista('Ripetute'), 8);
    });

    test('un lento facile allunga, un lento duro accorcia', () {
      expect(regolaEndurance(f(2), 'Lento', 0).regolazione, 1);
      expect(regolaEndurance(f(7), 'Lento', 0).regolazione, -1);
      expect(regolaEndurance(f(7), 'Tempo run', 0).regolazione, 0);
      expect(regolaEndurance(f(5, dolore: true), 'Lento', 0).regolazione, -1);
    });

    test("il messaggio dice se cambia la durata o l'intensità", () {
      expect(
        regolaEndurance(f(2), 'Lento', 0, modo: 'intensita').messaggio,
        contains("l'intensità"),
      );
      expect(
        regolaEndurance(f(2), 'Lento', 0, modo: 'durata').messaggio,
        contains('Allungo'),
      );
      // Auto: i primi due passi sono di intensità, il terzo di durata.
      expect(
        regolaEndurance(f(2), 'Lento', 2, modo: 'auto').messaggio,
        contains('Allungo'),
      );
    });

    test('la regolazione resta tra -3 e +3', () {
      expect(regolaEndurance(f(1), 'Lento', 3).regolazione, 3);
      expect(regolaEndurance(f(10), 'Lento', -3).regolazione, -3);
    });

    test('le righe vecchie senza sport sono di forza', () {
      final t = Tabella.da(
        'data,fatica,completata,dolore,note\n2026-10-20,6,si,no,',
      )!;
      final letto = FeedbackSessione.da(t, t.righe.single)!;
      expect(letto.sport, 'Forza');
      expect(letto.di(DateTime(2026, 10, 20), 'Forza'), true);
      expect(letto.di(DateTime(2026, 10, 20), 'Corsa'), false);
    });
  });
}
