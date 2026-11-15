import 'package:allenamenti_app/screens/colonna_dati.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _grande = Key('grande');
const _compatto = Key('compatto');

/// Uno spazio alto [h]; i numeri grandi sono 4 riquadri da 100 più [extra]
/// righe da 60 (i passi, i sensori della bici).
Future<void> _apri(WidgetTester tester, {required double h, int extra = 0}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: h,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: h),
                child: GrandeSeCiSta(
                  grande: Column(
                    key: _grande,
                    children: [
                      for (var i = 0; i < 4; i++)
                        const SizedBox(
                          width: double.infinity,
                          height: 100,
                          child: ColoredBox(color: Colors.red),
                        ),
                      for (var i = 0; i < extra; i++)
                        const SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ColoredBox(color: Colors.green),
                        ),
                    ],
                  ),
                  compatto: SingleChildScrollView(
                    key: _compatto,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: double.infinity,
                          height: 120,
                          child: ColoredBox(color: Colors.blue),
                        ),
                        for (var i = 0; i < extra; i++)
                          const SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ColoredBox(color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

bool _visibile(WidgetTester tester, Key k) =>
    tester.any(find.byKey(k, skipOffstage: false)) &&
    find.byKey(k).hitTestable().evaluate().isNotEmpty;

void main() {
  testWidgets('con posto: i numeri grandi', (tester) async {
    await _apri(tester, h: 500);
    expect(tester.getSize(find.byType(GrandeSeCiSta)).height, 400);
    expect(_visibile(tester, _grande), isTrue);
    expect(_visibile(tester, _compatto), isFalse);
  });

  testWidgets('arrivano i passi e non ci stanno più: la griglia', (
    tester,
  ) async {
    await _apri(tester, h: 440, extra: 1);
    expect(tester.getSize(find.byType(GrandeSeCiSta)).height, 180);
    expect(_visibile(tester, _grande), isFalse);
    expect(_visibile(tester, _compatto), isTrue);
  });

  testWidgets('anche la griglia non ci sta: scorre, senza uscire', (
    tester,
  ) async {
    await _apri(tester, h: 150, extra: 2);
    expect(tester.getSize(find.byType(GrandeSeCiSta)).height, 150);
    expect(tester.takeException(), isNull);
  });
}
