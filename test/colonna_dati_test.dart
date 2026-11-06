import 'package:allenamenti_app/screens/colonna_dati.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _mappa = Key('mappa');
const _testo = Key('testo');

/// Una colonna alta [h] con pezzi di altezza nota.
Future<void> _apri(
  WidgetTester tester, {
  double h = 700,
  double numeri = 160,
  double testo = 60,
  bool conMappa = true,
}) async {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 400,
            height: h,
            child: ColonnaDati(
              sopra: const SizedBox(height: 20),
              mappa: conMappa
                  ? const ColoredBox(key: _mappa, color: Colors.red)
                  : null,
              numeri: SingleChildScrollView(child: SizedBox(height: numeri)),
              testo: ListView(
                key: _testo,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [SizedBox(height: testo)],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

double _altezza(WidgetTester tester, Key k) =>
    tester.getSize(find.byKey(k)).height;

void main() {
  testWidgets('la mappa prende tutto lo spazio che resta', (tester) async {
    await _apri(tester);
    expect(_altezza(tester, _mappa), 700 - 20 - 160 - 60);
    expect(tester.takeException(), isNull);
  });

  testWidgets('senza watt e cadenza la mappa si allarga, senza vuoti', (
    tester,
  ) async {
    await _apri(tester, numeri: 160);
    final senza = _altezza(tester, _mappa);
    await _apri(tester, numeri: 260);
    final con = _altezza(tester, _mappa);
    expect(senza - con, 100);
    expect(tester.getBottomLeft(find.byKey(_testo)).dy, 700);
  });

  testWidgets('un testo lungo scorre e non si mangia la mappa', (tester) async {
    await _apri(tester, testo: 2000);
    expect(_altezza(tester, _testo), 700 * 0.3);
    expect(_altezza(tester, _mappa), greaterThan(altezzaMinimaMappa));
    expect(tester.takeException(), isNull);
  });

  testWidgets('schermo piccolo e tanti dati: niente esce dallo schermo', (
    tester,
  ) async {
    await _apri(tester, h: 400, numeri: 600, testo: 300);
    expect(tester.takeException(), isNull);
    expect(tester.getBottomLeft(find.byKey(_testo)).dy, lessThanOrEqualTo(400));
  });

  testWidgets('senza mappa il testo prende il resto', (tester) async {
    await _apri(tester, conMappa: false);
    expect(_altezza(tester, _testo), 700 - 20 - 160);
    expect(tester.takeException(), isNull);
  });
}
