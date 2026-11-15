import 'package:allenamenti_app/pulse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il contenuto che entra con dissolvenza: numeri che cambiano ed esercizi.
void main() {
  Widget app(String testo, {bool ferme = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: ferme),
      child: Center(
        child: EntrataMorbida(key: ValueKey(testo), child: Text(testo)),
      ),
    ),
  );

  double opacita(WidgetTester tester) => tester
      .widget<Opacity>(
        find.ancestor(of: find.byType(Text), matching: find.byType(Opacity)),
      )
      .opacity;

  testWidgets('entra da trasparente e riparte quando cambia il valore', (
    tester,
  ) async {
    await tester.pumpWidget(app('3'));
    expect(opacita(tester), 0);
    await tester.pumpAndSettle();
    expect(opacita(tester), 1);

    // Numero nuovo: quello vecchio non resta sullo schermo.
    await tester.pumpWidget(app('4'));
    expect(find.text('3'), findsNothing);
    expect(opacita(tester), 0);
    await tester.pump(const Duration(milliseconds: 140));
    expect(opacita(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(opacita(tester), 1);
  });

  testWidgets('con le animazioni spente nel telefono compare subito', (
    tester,
  ) async {
    await tester.pumpWidget(app('3', ferme: true));
    expect(opacita(tester), 1);
    await tester.pumpWidget(app('4', ferme: true));
    expect(opacita(tester), 1);
  });
}
