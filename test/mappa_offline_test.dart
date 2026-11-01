import 'dart:math' as math;

import 'package:allenamenti_app/mappa_offline.dart';
import 'package:allenamenti_app/navigazione.dart';
import 'package:flutter_test/flutter_test.dart';

const _m = 111195.0;
PuntoTraccia _p(double x, double y) =>
    PuntoTraccia(45 + y / _m, 9 + x / (_m * math.cos(45 * math.pi / 180)));

/// Una linea dritta verso est lunga [km], un punto ogni 50 m.
Traccia _dritta(double km) =>
    Traccia('Dritta', [for (var x = 0.0; x <= km * 1000; x += 50) _p(x, 0)]);

void main() {
  test('una zona ogni 5 km, con 1 km di margine attorno', () {
    final zone = zoneDaScaricare(_dritta(12));
    expect(zone, hasLength(3)); // 0-5, 5-10, 10-12
    final (a, b, c, d) = zone.first;
    expect((c - a) * _m, closeTo(2000, 5)); // 1 km sopra e sotto
    final larga = (d - b) * _m * math.cos(45 * math.pi / 180);
    expect(
      larga,
      closeTo(5000 + 2000, 60),
    ); // si chiude al primo punto oltre i 5 km
    // Le zone si toccano: nessun buco lungo la traccia.
    expect(zone[1].$2, lessThan(zone[0].$4));
  });

  test('una traccia corta è una zona sola', () {
    expect(zoneDaScaricare(_dritta(1)), hasLength(1));
    expect(zoneDaScaricare(Traccia('Vuota', const [])), isEmpty);
  });

  test('i riquadri: niente doppioni dove le zone si sovrappongono', () {
    final zone = zoneDaScaricare(_dritta(20));
    final tutti = riquadriDi(zone);
    final soloUltimo = riquadriDi(zone, min: 14, max: 14);
    // Al livello 14 un riquadro è largo circa 1,7 km qui: 22 km × 2 km.
    expect(soloUltimo.length, inInclusiveRange(14, 30));
    // I livelli più larghi aggiungono poco.
    expect(tutti.length, lessThan(soloUltimo.length * 2));
    expect(tutti.every((r) => r.$1 >= 10 && r.$1 <= 14), isTrue);
  });

  test('peso stimato: una granfondo di 100 km resta sui MB, non sui GB', () {
    final giro = Traccia('Anello', [
      for (var a = 0; a <= 360; a += 2)
        _p(
          16000 * math.cos(a * math.pi / 180),
          16000 * math.sin(a * math.pi / 180),
        ),
    ]);
    expect(giro.metri, closeTo(100000, 1000));
    final mb = int.parse(RegExp(r'\d+').firstMatch(pesoStimato(giro))![0]!);
    expect(mb, inInclusiveRange(2, 20));
    expect(pesoStimato(_dritta(0.5)), 'circa 1 MB');
  });
}
