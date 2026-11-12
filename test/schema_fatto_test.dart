import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/potenza.dart';
import 'package:allenamenti_app/screens/profilo_allenamento.dart';
import 'package:allenamenti_app/serie_sessione.dart';
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

  test(
    'con i watt previsti: la barra è il range, il trattino i watt tenuti',
    () {
      final barre = barreFatte([
        const IntervalloFatto(
          recupero: false,
          inizioS: 0,
          secondi: 600,
          wattMedi: 124,
          wattPrevisti: (110, 130),
        ),
        const IntervalloFatto(
          recupero: true,
          inizioS: 600,
          secondi: 240,
          wattMedi: 0,
          wattPrevisti: (90, 110),
        ),
      ]);
      expect(barre.first.range, (110, 130));
      expect(barre.first.fatto, 124);
      expect(barre.last.fatto, isNull);
    },
  );

  test('le fasce dei watt previsti finiscono dove inizia il tratto dopo', () {
    final fasce = fasceDaTratti(const [
      IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: 600,
        wattPrevisti: (110, 130),
      ),
      // Dopo una pausa di 30 secondi.
      IntervalloFatto(
        recupero: false,
        inizioS: 630,
        secondi: 480,
        wattPrevisti: (170, 185),
      ),
      IntervalloFatto(recupero: true, inizioS: 1110, secondi: 240),
    ]);
    expect(fasce.length, 2);
    expect((fasce[0].da, fasce[0].a), (0, 630));
    expect((fasce[1].da, fasce[1].a, fasce[1].range), (630, 1110, (170, 185)));
  });

  test('i watt di tutta la seduta, media ogni 10 secondi', () {
    final t0 = DateTime(2026, 11, 12, 18);
    final serie = [
      for (var s = 0; s < 30; s++)
        Campione(t0.add(Duration(seconds: s)), s < 10 ? 100 : 200),
    ];
    final punti = wattMediati(serie, t0);
    expect(punti.map((p) => p.w), [100, 200, 200]);
    expect(punti.first.s, 5);
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

      // Il grafico di tutta la seduta, con le fasce e la linea.
      final t0 = DateTime(2026, 11, 12, 18);
      await tester.pumpWidget(
        MaterialApp(
          theme: tema,
          home: Scaffold(
            body: GraficoPotenzaSeduta(
              serie: [
                for (var s = 0; s < 1200; s++)
                  Campione(t0.add(Duration(seconds: s)), s < 600 ? 120 : 178),
              ],
              fasce: const [
                (da: 0, a: 600, range: (110, 130)),
                (da: 600, a: 1200, range: (170, 185)),
              ],
              inizio: t0,
              zone: const ZonePotenza(200),
            ),
          ),
        ),
      );
      expect(find.text('20:00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
