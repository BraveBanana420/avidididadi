import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/registro_forza.dart';
import 'package:allenamenti_app/screens/altra_attivita_sheet.dart';
import 'package:allenamenti_app/screens/serie_a_mano_screen.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Altra attività col suo nome e GPS facoltativo; forza scritta a mano.
void main() {
  /// I quattro temi: fondo scuro o chiaro, accento rosso o neon.
  final temi = [
    for (final b in Brightness.values)
      for (final neon in [false, true]) creaTema(b, neon: neon),
  ];

  for (final tema in temi) {
    testWidgets(
      'altra attività: nome scritto e GPS scelto (${tema.brightness.name})',
      (tester) async {
        (String, bool)? scelta;
        await tester.pumpWidget(
          MaterialApp(
            theme: tema,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async =>
                      scelta = await chiediAltraAttivita(context, AppState()),
                  child: const Text('apri'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('apri'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '  kayak ');
        await tester.tap(find.text('Registra il percorso GPS'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Inizia'));
        await tester.pumpAndSettle();
        expect(scelta, ('Kayak', true));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('forza: gli esercizi del giorno si riaprono e si allungano '
        '(${tema.brightness.name})', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.7;
      addTearDown(tester.view.reset);
      final giorno = DateTime(2026, 11, 8);
      final state = AppState()
        ..serieFatte = serieDaEsercizi(giorno, [
          (esercizio: '', nome: 'Panca piana', serie: [(10, 60.0), (8, 62.5)]),
        ]);
      await tester.pumpWidget(
        MaterialApp(
          theme: tema,
          home: SerieAManoScreen(state: state, giorno: giorno),
        ),
      );
      expect(find.text('Panca piana'), findsOneWidget);
      expect(find.text('62,5'), findsOneWidget);
      await tester.tap(find.text('Serie'));
      await tester.pump();
      // La nuova serie copia l'ultima.
      expect(find.text('62,5'), findsNWidgets(2));
      expect(find.text('3ª'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
