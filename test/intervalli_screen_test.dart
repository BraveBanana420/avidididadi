import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/screens/intervalli_screen.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Correggere a mano il nome di un tratto, nei quattro temi.
void main() {
  final nuotata = Sessione(
    id: 'icu-i1',
    data: DateTime(2026, 11, 10),
    sport: 'Nuoto',
    tipo: 'Piscina',
    durataMin: 40,
    distanzaKm: 1.2,
  );
  const tratti = [
    IntervalloFatto(
      recupero: false,
      inizioS: 0,
      secondi: 305,
      metri: 200,
      nome: 'Stile libero 3/3',
    ),
    IntervalloFatto(recupero: true, inizioS: 305, secondi: 57),
  ];

  for (final tema in [
    for (final b in Brightness.values)
      for (final neon in [false, true]) creaTema(b, neon: neon),
  ]) {
    testWidgets('il nome sbagliato si cambia con un tocco '
        '(${tema.brightness.name})', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.7;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: tema,
          home: IntervalliScreen(
            state: AppState(),
            sessione: nuotata,
            iniziali: tratti,
            nomi: const ['Stile libero', 'Defaticamento'],
          ),
        ),
      );
      expect(find.text('Stile libero 3/3'), findsOneWidget);
      expect(find.text('Recupero 0:57'), findsOneWidget);
      await tester.tap(find.text('Stile libero 3/3'));
      await tester.pumpAndSettle();
      // I nomi dei passi in programma sono lì da toccare.
      await tester.tap(find.widgetWithText(ActionChip, 'Defaticamento'));
      await tester.tap(find.text('Fatto'));
      await tester.pumpAndSettle();
      expect(find.text('Defaticamento'), findsOneWidget);
      expect(find.text('Stile libero 3/3'), findsNothing);
      // Togliere il recupero.
      await tester.tap(find.text('Recupero 0:57'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Togli questo tratto'));
      await tester.pumpAndSettle();
      expect(find.text('Recupero 0:57'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
