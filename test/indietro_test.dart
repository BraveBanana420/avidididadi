import 'package:allenamenti_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('indietro: dalle altre sezioni a Oggi, da Oggi fuori', (t) async {
    // Android chiude l'app quando la prima pagina lascia passare il tasto.
    final uscite = <String>[];
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.pop') uscite.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    var sezione = 3; // Profilo
    await t.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, aggiorna) => IndietroAOggi(
            sezione: sezione,
            tornaAOggi: () => aggiorna(() => sezione = 0),
            child: Scaffold(body: Text('Sezione $sezione')),
          ),
        ),
      ),
    );
    expect(find.text('Sezione 3'), findsOneWidget);

    await t.binding.handlePopRoute();
    await t.pump();
    expect(find.text('Sezione 0'), findsOneWidget);
    expect(uscite, isEmpty);

    await t.binding.handlePopRoute();
    await t.pump();
    expect(uscite, ['SystemNavigator.pop']);
  });

  testWidgets('indietro: una pagina aperta sopra si chiude e basta', (t) async {
    var tornate = 0;
    await t.pumpWidget(
      MaterialApp(
        home: IndietroAOggi(
          sezione: 2,
          tornaAOggi: () => tornate++,
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Dettaglio')),
                  ),
                ),
                child: const Text('Apri'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('Apri'));
    await t.pumpAndSettle();
    expect(find.text('Dettaglio'), findsOneWidget);

    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(find.text('Dettaglio'), findsNothing);
    expect(tornate, 0);
  });
}
