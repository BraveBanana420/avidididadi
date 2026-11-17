import 'package:allenamenti_app/avviso.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('durataAvviso', () {
    test('un messaggio corto dura poco, uno lungo si riesce a leggere', () {
      expect(
        durataAvviso('Piano generato'),
        const Duration(milliseconds: 2350),
      );
      expect(
        durataAvviso(
          'Settimana salvata. Il calendario è vuoto: allungalo da Oggi.',
        ),
        const Duration(milliseconds: 3500),
      );
      expect(durataAvviso('x' * 500), const Duration(seconds: 5));
    });

    test('con Annulla c\'è il tempo di toccarlo', () {
      expect(
        durataAvviso('Sessione eliminata', conAnnulla: true),
        minimoConAnnulla,
      );
    });
  });

  group('avviso', () {
    /// Apre l'avviso con un pulsante e lascia finire l'animazione di entrata.
    Future<void> apri(WidgetTester t, SnackBar Function() crea) async {
      await t.pumpWidget(
        MaterialApp(
          theme: creaTema(Brightness.dark),
          home: Scaffold(
            body: Builder(
              builder: (c) => Center(
                child: TextButton(
                  onPressed: () => ScaffoldMessenger.of(c).showSnackBar(crea()),
                  child: const Text('apri'),
                ),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('apri'));
      await t.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    }

    for (final (nome, spostamento) in const [
      ('sinistra', Offset(-300, 0)),
      ('destra', Offset(300, 0)),
      ('basso', Offset(0, 100)),
      ('alto', Offset(0, -100)),
    ]) {
      testWidgets('scorrendolo verso $nome si chiude', (t) async {
        await apri(t, () => avviso(content: const Text('Salvato')));
        await t.fling(find.text('Salvato'), spostamento, 1000);
        await t.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
      });

      testWidgets('anche con Annulla si chiude verso $nome, senza annullare', (
        t,
      ) async {
        var annullato = 0;
        await apri(
          t,
          () => avviso(
            content: const Text('Sessione eliminata'),
            annulla: () => annullato++,
          ),
        );
        await t.fling(find.text('Sessione eliminata'), spostamento, 1000);
        await t.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
        expect(annullato, 0);
      });
    }

    testWidgets('con Annulla sparisce da solo', (t) async {
      await apri(
        t,
        () => avviso(content: const Text('Sessione eliminata'), annulla: () {}),
      );
      await t.pump(minimoConAnnulla);
      await t.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Annulla ha il bordo e, toccato due volte, vale una', (
      t,
    ) async {
      var annullato = 0;
      await apri(
        t,
        () => avviso(
          content: const Text('Sessione eliminata'),
          annulla: () => annullato++,
        ),
      );
      final tasto = find.widgetWithText(OutlinedButton, 'Annulla');
      expect(tasto, findsOneWidget);
      await t.tap(tasto);
      await t.pump();
      await t.tap(tasto, warnIfMissed: false);
      await t.pumpAndSettle();
      expect(annullato, 1);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('una durata scelta vale al posto di quella calcolata', (
      t,
    ) async {
      final a = avviso(
        content: const Text('Errore'),
        duration: const Duration(seconds: 8),
      );
      expect(a.duration, const Duration(seconds: 8));
      expect(a.persist, isFalse);
    });
  });
}
