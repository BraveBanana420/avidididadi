import 'package:allenamenti_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scalaTesto', () {
    test('un testo che ci sta non cambia', () {
      expect(scalaTesto(200, 300), 1);
      expect(scalaTesto(300, 300), 1);
    });

    test('un testo troppo largo si stringe quanto serve', () {
      expect(scalaTesto(400, 320), closeTo(0.796, 0.001));
    });

    test('non scende sotto il minimo, per restare leggibile', () {
      expect(scalaTesto(1000, 100), 0.7);
    });
  });

  group('TestoUnaRiga', () {
    const nome = 'Corsa lunga progressiva con cambi';
    final riga = find.byType(Text);

    Future<Text> mostra(
      WidgetTester tester,
      double larghezza, {
      String testo = nome,
      double scalaTelefono = 1,
    }) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scalaTelefono)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: larghezza,
                child: TestoUnaRiga(
                  testo,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      );
      return tester.widget<Text>(riga);
    }

    testWidgets('sul telefono largo tiene la dimensione piena', (tester) async {
      final t = await mostra(tester, 800);
      expect(t.style?.fontSize, 20);
    });

    testWidgets('su schermi stretti si rimpicciolisce e sta su una riga', (
      tester,
    ) async {
      final t = await mostra(tester, 500);
      expect(t.style!.fontSize!, lessThan(20));
      expect(t.style!.fontSize!, greaterThanOrEqualTo(14));
      expect(t.maxLines, 1);
      expect(tester.getSize(riga).height, closeTo(t.style!.fontSize!, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('segue anche il testo ingrandito nelle impostazioni', (
      tester,
    ) async {
      final normale = await mostra(tester, 800);
      final grande = await mostra(tester, 800, scalaTelefono: 1.3);
      expect(grande.style!.fontSize!, lessThan(normale.style!.fontSize!));
    });

    testWidgets('un nome lunghissimo si ferma al minimo, senza errori', (
      tester,
    ) async {
      final t = await mostra(tester, 100);
      expect(t.style?.fontSize, 14);
      expect(t.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });
  });
}
