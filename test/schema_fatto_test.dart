import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/potenza.dart';
import 'package:allenamenti_app/screens/profilo_allenamento.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo schema della seduta com'è andata, nel riepilogo della bici.
void main() {
  IntervalloFatto tratto(int secondi, int watt, {bool recupero = false}) =>
      IntervalloFatto(
        recupero: recupero,
        inizioS: 0,
        secondi: secondi,
        wattMedi: watt,
      );

  test('una barra per tratto, con i tempi e i watt fatti davvero', () {
    // Sweet spot 3 × 8: la prima intera, le altre chiuse dopo 2 minuti.
    final barre = barreFatte([
      tratto(600, 130),
      tratto(480, 178),
      tratto(240, 100, recupero: true),
      tratto(120, 176),
      tratto(120, 175),
      tratto(0, 0), // senza tempo: non si disegna
    ]);
    expect(barre.map((b) => b.secondi), [600, 480, 240, 120, 120]);
    expect(barre[1].range, (178, 178));
    // Zone con FTP 200: riscaldamento in Z2 (azzurro), sweet spot in Z3.
    const zp = ZonePotenza(200);
    expect(zp.zonaDi(barre.first.range!.$1), 2);
    expect(zp.zonaDi(barre[1].range!.$1), 3);
  });

  test('un blocco solo si disegna; senza watt niente schema', () {
    expect(barreFatte([tratto(2700, 139)]).single.range, (139, 139));
    expect(barreFatte([tratto(2700, 0), tratto(300, 0)]), isEmpty);
    expect(barreFatte(const []), isEmpty);
    // Un tratto senza watt tra gli altri resta, in grigio.
    expect(barreFatte([tratto(600, 150), tratto(60, 0)]).last.range, isNull);
  });

  for (final tema in [
    for (final b in Brightness.values)
      for (final neon in [false, true]) creaTema(b, neon: neon),
  ]) {
    testWidgets('lo schema si disegna (${tema.brightness.name})', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: tema,
          home: Scaffold(
            body: ProfiloAllenamento(
              barre: barreFatte([tratto(600, 130), tratto(480, 178)]),
              zone: const ZonePotenza(200),
              altezza: 56,
            ),
          ),
        ),
      );
      expect(find.byType(ProfiloAllenamento), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
