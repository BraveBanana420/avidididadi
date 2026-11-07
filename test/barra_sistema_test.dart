import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/attivita_libera.dart';
import 'package:allenamenti_app/screens/calendar_screen.dart';
import 'package:allenamenti_app/screens/crea_piano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Con la barra di navigazione del telefono i pulsanti in basso devono restare visibili.
void main() {
  const barra = 48.0; // altezza della barra di sistema, in punti

  Future<void> conBarra(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.7;
    tester.view.padding = const FakeViewPadding(bottom: barra * 2.7);
    tester.view.viewPadding = const FakeViewPadding(bottom: barra * 2.7);
    addTearDown(tester.view.reset);
  }

  double fondoSchermo(WidgetTester tester) =>
      tester.view.physicalSize.height / tester.view.devicePixelRatio;

  testWidgets('il pulsante di Allunga il calendario resta sopra la barra', (
    tester,
  ) async {
    await conBarra(tester);
    final state = AppState();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => GeneraSheet(state: state),
              ),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
    final pulsante = tester.getRect(
      find.widgetWithText(FilledButton, 'Allunga il calendario'),
    );
    expect(pulsante.bottom, lessThanOrEqualTo(fondoSchermo(tester) - barra));
  });

  /// Apre il foglio del "+" con tutte le attività.
  Future<void> apriAttivita(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => scegliAttivitaLibera(
                context,
                titolo: 'Cosa vuoi fare adesso?',
                sottotitolo: "Si aggiunge a quello che c'è in programma oggi.",
              ),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
  }

  testWidgets('tutte le attività del "+" restano sopra la barra', (
    tester,
  ) async {
    await conBarra(tester);
    await apriAttivita(tester);
    for (final (_, _, nome) in attivitaLibere) {
      final scelta = tester.getRect(find.text(nome));
      expect(scelta.bottom, lessThanOrEqualTo(fondoSchermo(tester) - barra));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('su un telefono piccolo le attività si raggiungono scorrendo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(540, 800);
    tester.view.devicePixelRatio = 1.5;
    tester.view.padding = const FakeViewPadding(bottom: barra * 1.5);
    tester.view.viewPadding = const FakeViewPadding(bottom: barra * 1.5);
    addTearDown(tester.view.reset);
    await apriAttivita(tester);
    final ultima = find.text(attivitaLibere.last.$3);
    await tester.ensureVisible(ultima);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(ultima).bottom,
      lessThanOrEqualTo(fondoSchermo(tester) - barra),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('la pagina Crea piano finisce sopra la barra', (tester) async {
    await conBarra(tester);
    await tester.pumpWidget(
      MaterialApp(home: CreaPianoScreen(state: AppState())),
    );
    await tester.scrollUntilVisible(find.byType(FilledButton), 300);
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    final pulsante = tester.getRect(find.byType(FilledButton));
    expect(pulsante.bottom, lessThanOrEqualTo(fondoSchermo(tester) - barra));
  });
}
