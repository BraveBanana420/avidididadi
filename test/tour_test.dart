import 'package:allenamenti_app/screens/tour.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un'app finta con alcuni dei punti del giro (non tutti: quelli che mancano
/// devono mostrare solo la spiegazione).
Widget appDiProva(List<int> sezioni) => MaterialApp(
  theme: creaTema(Brightness.dark),
  home: Scaffold(
    body: ListView(
      children: [
        SizedBox(key: ChiaviTour.energia, height: 40, width: 80),
        SizedBox(key: ChiaviTour.giorno, height: 200),
        SizedBox(key: ChiaviTour.settimana, height: 100),
        const SizedBox(height: 900),
        SizedBox(key: ChiaviTour.settimanaTipo, height: 60),
        SizedBox(key: ChiaviTour.prepara, height: 120),
        SizedBox(key: ChiaviTour.collegamenti, height: 60),
        Builder(
          builder: (c) =>
              TextButton(onPressed: () => avviaTour(c), child: const Text('?')),
        ),
      ],
    ),
    bottomNavigationBar: SizedBox(
      key: ChiaviTour.barra,
      height: 80,
      child: Row(
        children: [
          for (final k in ChiaviTour.voci)
            Expanded(child: SizedBox(key: k, height: 60)),
        ],
      ),
    ),
  ),
);

/// L'anello pulsa sempre: si va avanti a passi invece di aspettare che si fermi.
Future<void> attendi(WidgetTester t) async {
  for (var k = 0; k < 25; k++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('dieci passi: avanti, tocco nel cerchio, indietro, fine', (
    t,
  ) async {
    final sezioni = <int>[];
    vaiAllaSezione = sezioni.add;
    await t.binding.setSurfaceSize(const Size(400, 800));
    await t.pumpWidget(appDiProva(sezioni));
    await t.scrollUntilVisible(find.text('?'), 300);
    await t.tap(find.text('?'));
    await attendi(t);
    expect(find.text('1 di 10'), findsOneWidget);
    expect(find.text('La barra in basso'), findsOneWidget);
    expect(find.text('Tocca il cerchio per continuare.'), findsOneWidget);

    // Il tocco dentro il cerchio (la barra) passa al passo dopo.
    // Un tocco fuori dal cerchio non fa niente.
    await t.tapAt(const Offset(200, 300));
    await attendi(t);
    expect(find.text('1 di 10'), findsOneWidget);
    await t.tapAt(t.getCenter(find.byKey(ChiaviTour.barra)));
    await attendi(t);

    expect(find.text('2 di 10'), findsOneWidget);

    await t.tap(find.byTooltip('Indietro'));
    await attendi(t);
    expect(find.text('1 di 10'), findsOneWidget);

    for (var n = 2; n <= 10; n++) {
      await t.tap(find.text('Avanti'));
      await attendi(t);
      expect(find.text('$n di 10'), findsOneWidget);
    }
    // Il feedback non c'è: solo la spiegazione, senza cerchio.
    expect(find.text('Dati e collegamenti'), findsOneWidget);
    await t.tap(find.text('Fine'));
    await t.pumpAndSettle();
    expect(find.text('10 di 10'), findsNothing);
    // Ha visitato Oggi, Progressi, Coach e Profilo, e alla fine torna al Profilo.
    expect(sezioni.toSet(), {0, 1, 2, 3});
    expect(sezioni.last, 3);
    expect(tourProposto.value, isTrue);
  });

  testWidgets('dove il tasto non c\'è si spiega dove comparirà', (t) async {
    vaiAllaSezione = (_) {};
    await t.binding.setSurfaceSize(const Size(400, 800));
    await t.pumpWidget(appDiProva([]));
    await t.scrollUntilVisible(find.text('?'), 300);
    await t.tap(find.text('?'));
    await attendi(t);
    for (var n = 2; n <= 6; n++) {
      await t.tap(find.text('Avanti'));
      await attendi(t);
    }
    expect(find.text('Com\'è andata?'), findsOneWidget);
    expect(find.textContaining('Quando un allenamento fatto'), findsOneWidget);
    expect(find.text('Tocca il cerchio per continuare.'), findsNothing);
    await t.tap(find.text('Esci'));
    await t.pumpAndSettle();
    expect(find.text('6 di 10'), findsNothing);
  });
}
