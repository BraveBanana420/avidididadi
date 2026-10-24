import 'package:allenamenti_app/pulse.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cambiando tema la pagina aperta resta quella', (t) async {
    final pagine = PageController();
    Widget app(Brightness b) => MaterialApp(
      theme: creaTema(b),
      home: Scaffold(
        body: SfondoPulse(
          child: PageView(
            controller: pagine,
            children: const [Text('Oggi'), Text('Progressi'), Text('Profilo')],
          ),
        ),
      ),
    );
    await t.pumpWidget(app(Brightness.dark));
    pagine.jumpToPage(2);
    await t.pumpAndSettle();
    expect(find.text('Profilo'), findsOneWidget);
    // Il tema chiaro ha due bagliori invece di uno: il contenuto non si ricrea.
    await t.pumpWidget(app(Brightness.light));
    await t.pumpAndSettle();
    expect(find.text('Profilo'), findsOneWidget);
    expect(find.text('Oggi'), findsNothing);
  });
}
