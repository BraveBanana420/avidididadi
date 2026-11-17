import 'package:allenamenti_app/assi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le tacche tonde si scrivono senza decimali', () {
    expect(numeroAsse(6), '6');
    expect(numeroAsse(0), '0');
    expect(numeroAsse(0.5), '0.5');
    expect(numeroAsse(1.5), '1.5');
  });

  test('la potenza della corsa di Milano: 0, 200, 400, 600 W', () {
    final s = scalaTonda(126, 585);
    expect(tacche(s), [600, 400, 200, 0]);
  });

  test('il battito: tacche ogni 20 o 25, mai 86-128-171', () {
    final s = scalaTonda(92, 168);
    expect(s.lo, lessThanOrEqualTo(92));
    expect(s.hi, greaterThanOrEqualTo(168));
    expect(tacche(s), [175, 150, 125, 100, 75]);
  });

  test('la pendenza passa dallo zero, scritto senza il meno', () {
    final t = tacche(scalaTonda(-7.4, 6.8));
    expect(t, [10, 5, 0, -5, -10]);
    expect(t[2].toStringAsFixed(0), '0');
  });

  test('il passo usa tempi tondi (i valori sono secondi col meno)', () {
    // Da 3:24 a 7:40 al km.
    final s = scalaTonda(-460, -204, passi: passiTempo);
    expect(s.passo, 120);
    expect(tacche(s), [-120, -240, -360, -480]);
  });

  test('numeri piccoli e linea piatta', () {
    expect(tacche(scalaTonda(61.5, 63.5)), [63.5, 63, 62.5, 62, 61.5]);
    final piatta = scalaTonda(70, 70);
    expect(piatta.lo, lessThan(70));
    expect(piatta.hi, greaterThan(70));
    expect(tacche(scalaTonda(0, 5.6)).first, 6);
  });

  test('percentile: pochi picchi non spostano il limite', () {
    final passi = <double>[
      for (var i = 0; i < 95; i++) -360,
      -900,
      -900,
      -880,
      -870,
      -860,
    ];
    expect(percentile(passi, 0.05), -360);
    expect(percentile(const [], 0.5), 0);
  });
}
