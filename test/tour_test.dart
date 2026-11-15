import 'package:allenamenti_app/screens/tour.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un'app finta con alcuni dei punti del giro (non tutti: quelli che mancano
/// devono mostrare solo la spiegazione).
Widget appDiProva(
  List<int> sezioni, {
  double altezzaGiorno = 200,
  bool tastoInAlto = false,
}) => MaterialApp(
  theme: creaTema(Brightness.dark),
  home: Scaffold(
    body: ListView(
      children: [
        // Il tasto in cima: la lista resta all'inizio, come Oggi nell'app.
        if (tastoInAlto)
          Builder(
            builder: (c) => TextButton(
              onPressed: () => avviaTour(c),
              child: const Text('?'),
            ),
          ),
        SizedBox(key: ChiaviTour.energia, height: 40, width: 80),
        SizedBox(key: ChiaviTour.giorno, height: altezzaGiorno),
        SizedBox(key: ChiaviTour.settimana, height: 100),
        const SizedBox(height: 900),
        SizedBox(key: ChiaviTour.settimanaTipo, height: 60),
        SizedBox(key: ChiaviTour.prepara, height: 120),
        SizedBox(key: ChiaviTour.collegamenti, height: 60),
        if (!tastoInAlto)
          Builder(
            builder: (c) => TextButton(
              onPressed: () => avviaTour(c),
              child: const Text('?'),
            ),
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
    expect(find.text('Tocca Avanti per continuare.'), findsOneWidget);

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
    await t.tap(find.text('Esci'));
    await t.pumpAndSettle();
    expect(find.text('6 di 10'), findsNothing);
  });

  testWidgets('Avanti ed Esci restano sopra la barra di Android', (t) async {
    vaiAllaSezione = (_) {};
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 3;
    t.view.padding = const FakeViewPadding(top: 84, bottom: 144);
    t.view.viewPadding = const FakeViewPadding(top: 84, bottom: 144);
    addTearDown(t.view.reset);
    // La seduta del giorno alta come nell'app vera (con il pulsante "Com'è
    // andata?"): il centro sta in alto, ma sotto non c'è posto.
    await t.pumpWidget(appDiProva([], altezzaGiorno: 470, tastoInAlto: true));
    await t.tap(find.text('?'));
    await attendi(t);
    const fondoSicuro = 780 - 144 / 3;
    for (var n = 1; n <= 10; n++) {
      expect(find.text('$n di 10'), findsOneWidget);
      expect(t.getBottomLeft(find.text('Esci')).dy, lessThan(fondoSicuro));
      final avanti = n == 10 ? 'Fine' : 'Avanti';
      expect(t.getBottomLeft(find.text(avanti)).dy, lessThan(fondoSicuro));
      await t.tap(find.text(avanti));
      await attendi(t);
    }
  });

  group('la scheda resta dentro lo schermo', () {
    const schermo = Size(360, 780);
    const margini = EdgeInsets.only(top: 28, bottom: 48);

    test('seduta alta nella metà su: dentro i margini di sistema', () {
      const buco = Rect.fromLTRB(16, 150, 344, 560);
      final p = posizioneSchedaTour(
        schermo: schermo,
        buco: buco,
        margini: margini,
      );
      expect(p.alto, greaterThanOrEqualTo(margini.top));
      expect(p.basso, greaterThanOrEqualTo(margini.bottom));
      expect(schermo.height - p.alto - p.basso, greaterThan(0));
    });

    test('con spazio sotto il buco si mette sotto', () {
      const buco = Rect.fromLTRB(16, 80, 344, 200);
      final p = posizioneSchedaTour(
        schermo: schermo,
        buco: buco,
        margini: margini,
      );
      expect(p.sotto, isTrue);
      expect(p.alto, 220);
      expect(p.basso, 64);
    });

    test('la barra in basso: la scheda va sopra', () {
      const buco = Rect.fromLTRB(16, 680, 344, 740);
      final p = posizioneSchedaTour(
        schermo: schermo,
        buco: buco,
        margini: margini,
      );
      expect(p.sotto, isFalse);
      expect(p.basso, 780 - 680 + 20);
    });

    test('buco grande quanto lo schermo: in basso, dentro i margini', () {
      const buco = Rect.fromLTRB(0, 60, 360, 740);
      final p = posizioneSchedaTour(
        schermo: schermo,
        buco: buco,
        margini: margini,
      );
      expect(p.alto, 44);
      expect(p.basso, 64);
    });
  });
}
