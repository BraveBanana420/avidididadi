import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/screens/esecuzione_screen.dart';
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
    await _chiudi(tester);
  });
}
