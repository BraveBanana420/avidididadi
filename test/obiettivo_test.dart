import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/screens/obiettivo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final oggi = DateTime(2026, 10, 22);
  Obiettivo tra(int settimane, {String gara = 'mezza'}) => Obiettivo(
    sport: 'Corsa',
    gara: gara,
    data: oggi.add(Duration(days: 7 * settimane)),
  );

  group('fasi verso la gara', () {
    test('mezza maratona: base, sviluppo, rifinitura, scarico, gara', () {
      expect(tra(20).fase(oggi), Fase.base);
      expect(tra(12).fase(oggi), Fase.sviluppo);
      expect(tra(5).fase(oggi), Fase.rifinitura);
      expect(tra(2).fase(oggi), Fase.scarico);
      expect(tra(1).fase(oggi), Fase.gara);
      expect(tra(-1).fase(oggi), Fase.libera);
    });

    test('per la maratona lo scarico dura una settimana in più', () {
      expect(tra(3).fase(oggi), Fase.rifinitura);
      expect(tra(3, gara: 'maratona').fase(oggi), Fase.scarico);
    });

    test('il triathlon allena tutti e tre gli sport', () {
      final o = Obiettivo(sport: 'Triathlon', gara: 'olimpico', data: oggi);
      expect(o.sportAllenati, {'Corsa', 'Nuoto', 'Bici'});
      expect(o.nome, 'Triathlon olimpico');
    });
  });

  group('zone di frequenza cardiaca', () {
    test('con la FC a riposo si usa la riserva cardiaca (Karvonen)', () {
      const z = Zone(fcMax: 180, fcRiposo: 50);
      expect(z.zona(2), (128, 140)); // 50 + 60-70% di 130
      expect(z.zona(5), (167, 179));
    });

    test('senza FC a riposo: percentuale della FC massima', () {
      const z = Zone(fcMax: 180);
      expect(z.zona(2), (108, 125));
      expect(z.zonaDi(150), 4); // 83% della FC max
      expect(z.zonaDi(130), 3); // 72%
      expect(z.zonaDi(80), 0);
    });

    test('"zona 2" nei testi diventa anche bpm, una volta sola', () {
      const z = Zone(fcMax: 180, fcRiposo: 50);
      final t = conBpm('Corsa lenta, intensità zona 2', z);
      expect(t, 'Corsa lenta, intensità zona 2 (128-140 bpm)');
      expect(conBpm(t, z), t);
    });
  });

  group('stime dai dati', () {
    Sessione s(
      String sport, {
      int fcMax = 0,
      double km = 0,
      int min = 0,
      int giorniFa = 10,
    }) => Sessione(
      id: '$sport$fcMax$km$giorniFa',
      data: oggi.subtract(Duration(days: giorniFa)),
      sport: sport,
      fcMax: fcMax,
      distanzaKm: km,
      durataMin: min,
    );

    test('FC massima: la più alta dell\'ultimo anno, altrimenti dall\'età', () {
      expect(
        stimaFcMax(
          [s('Corsa', fcMax: 172), s('Bici', fcMax: 166)],
          37,
          oggi,
        ).$1,
        172,
      );
      // Troppo vecchia o troppo bassa per essere credibile: si usa l'età.
      expect(
        stimaFcMax([s('Corsa', fcMax: 185, giorniFa: 400)], 37, oggi).$1,
        182,
      );
      expect(stimaFcMax([], null, oggi).$1, 190);
    });

    test('passo critico: il passo migliore in piscina su almeno 400 m', () {
      final sessioni = [
        s('Nuoto', km: 1.55, min: 48), // 3:06/100
        s('Nuoto', km: 0.5, min: 10), // 2:00/100
        s('Nuoto', km: 0.2, min: 3), // troppo corta
      ];
      expect(stimaPassoCritico(sessioni, oggi), 120);
      expect(fmtPasso100(125), '2:05/100 m');
      expect(stimaPassoCritico([], oggi), isNull);
    });
  });

  testWidgets('icona del triathlon: nuoto, bici e corsa piccoli', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: IconaTriathlon())),
      ),
    );
    for (final i in [Icons.pool, Icons.directions_bike, Icons.directions_run]) {
      expect(find.byIcon(i), findsOneWidget);
    }
    // Sta nello spazio di un'icona normale, senza andare a capo.
    expect(t.getSize(find.byType(IconaTriathlon)).width, lessThan(40));
  });
}
