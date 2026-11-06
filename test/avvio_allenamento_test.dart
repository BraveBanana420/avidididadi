import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/avvisi.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/pulse.dart';
import 'package:allenamenti_app/screens/esecuzione_screen.dart';
import 'package:allenamenti_app/sensore_ble.dart';
import 'package:allenamenti_app/sensori_bici.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutStep _passo(String sport) => WorkoutStep(
  id: 'prova',
  sport: sport,
  nome: 'Prova',
  durataTot: 10,
  ordine: 1,
  fase: 'principale',
  descrizione: 'Primo blocco',
  serie: '',
  ripetizioni: '',
  distanzaM: '',
  durataMin: '10',
  intensita: '',
  recuperoS: '',
  note: '',
);

Future<void> _apri(WidgetTester tester, String sport, String tipo) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: EsecuzioneScreen(
        state: AppState(),
        sport: sport,
        tipo: tipo,
        nome: 'Prova',
        passi: [_passo(sport)],
      ),
    ),
  );
  await tester.pump();
}

/// Il cronometro della schermata è vero, il tempo dei test no: più dei
/// 5 secondi del conto alla rovescia bisogna aspettarli davvero.
Future<void> _aspettaOltreIlConto(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(seconds: 6)));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

Future<void> _chiudi(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('bici al chiuso: niente timer, parte solo col tasto Inizia', (
    tester,
  ) async {
    await _apri(tester, 'Bici', 'Rulli');
    expect(find.text('Parti quando vuoi'), findsOneWidget);
    expect(find.text('Rullo e sensori'), findsOneWidget);
    expect(find.text('Battito'), findsOneWidget);
    expect(find.byTooltip('Pausa'), findsNothing);

    // Il tempo passa, ma la schermata resta quella.
    await _aspettaOltreIlConto(tester);
    expect(find.text('Parti quando vuoi'), findsOneWidget);

    await tester.tap(find.text('Inizia'));
    await tester.pump();
    expect(find.text('Parti quando vuoi'), findsNothing);
    expect(find.byTooltip('Pausa'), findsOneWidget);
    await _chiudi(tester);
  });

  testWidgets('camminata al chiuso: aspetta il tasto, senza riga del rullo', (
    tester,
  ) async {
    await _apri(tester, 'Camminata', 'Tapis roulant');
    await _aspettaOltreIlConto(tester);
    expect(find.text('Parti quando vuoi'), findsOneWidget);
    expect(find.text('Rullo e sensori'), findsNothing);
    expect(find.text('Battito'), findsOneWidget);
    await _chiudi(tester);
  });

  testWidgets('forza: resta il conto alla rovescia, poi parte da sola', (
    tester,
  ) async {
    await _apri(tester, 'Forza', '');
    expect(find.text('Preparati'), findsOneWidget);
    expect(find.text('Inizia subito'), findsOneWidget);

    await _aspettaOltreIlConto(tester);
    expect(find.text('Preparati'), findsNothing);
    expect(find.text('Inizia subito'), findsNothing);
    expect(find.byType(AnelloPulse), findsOneWidget);
    await _chiudi(tester);
  });

  testWidgets('bici all\'aperto: watt e cadenza solo se arrivano davvero', (
    tester,
  ) async {
    // Due pagine: nei test la mappa vera non si può aprire.
    addTearDown(() {
      sensoreBici.stato = StatoSensore.spento;
      sensoreBici.azzera();
    });
    await _apri(tester, 'Bici', 'Intervalli');
    await tester.tap(find.text('Inizia'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('POTENZA'), findsNothing);
    expect(find.text('CADENZA'), findsNothing);

    // Sensore collegato, ma ancora nessun dato: resta tutto nascosto.
    sensoreBici.stato = StatoSensore.collegato;
    sensoreBici.notifyListeners();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('POTENZA'), findsNothing);

    // Misuratore di potenza senza cadenza: 200 W.
    sensoreBici.leggi(1, [0x00, 0x00, 0xC8, 0x00]);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('POTENZA'), findsOneWidget);
    expect(find.text('CADENZA'), findsNothing);
    await _chiudi(tester);
  });

  for (final vista in [VistaMappa.minimappa, VistaMappa.pagine]) {
    testWidgets(
      'bici all\'aperto (${vista.name}): barra piatta, sempre in vista',
      (tester) async {
        final prima = vistaMappa.value;
        vistaMappa.value = vista;
        addTearDown(() => vistaMappa.value = prima);
        await _apri(tester, 'Bici', 'Intervalli');
        await tester.tap(find.text('Inizia'));
        await tester.pump();

        expect(find.byType(AnelloPulse), findsNothing);
        expect(find.byType(BarraAvanzamento), findsOneWidget);
        // Tutta dentro lo schermo, anche con la mappa: senza scorrere.
        expect(
          tester.getBottomRight(find.byType(BarraAvanzamento)).dy,
          lessThan(tester.view.physicalSize.height / 2.625),
        );
        await _chiudi(tester);
      },
    );
  }
}
