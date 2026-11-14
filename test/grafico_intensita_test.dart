import 'package:allenamenti_app/intensita.dart';
import 'package:allenamenti_app/screens/grafico_intensita.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fasce = <FasciaIntensita>[
    (da: 0, a: 600, giu: 2.0, su: 3.0, passo: false),
    (da: 600, a: 900, giu: 4.1, su: 4.6, passo: true),
  ];
  final punti = [
    for (var s = 7.5; s < 900; s += 15) (s: s, livello: s < 600 ? 2.4 : 4.3),
  ];

  for (final scuro in [true, false]) {
    for (final neon in [true, false]) {
      testWidgets('previsto e fatto: ${scuro ? 'scuro' : 'chiaro'} '
          '${neon ? 'neon' : 'rosso'}', (t) async {
        await t.pumpWidget(
          MaterialApp(
            theme: creaTema(
              scuro ? Brightness.dark : Brightness.light,
              neon: neon,
            ),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: GraficoIntensitaSeduta(
                  punti: punti,
                  fasce: fasce,
                  colore: Colors.red,
                ),
              ),
            ),
          ),
        );
        expect(find.text('0:00'), findsOneWidget);
        expect(find.text('15:00'), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('senza punti né fasce non si rompe', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GraficoIntensitaSeduta(
            punti: [],
            fasce: [],
            colore: Colors.red,
          ),
        ),
      ),
    );
    expect(t.takeException(), isNull);
  });
}
