import 'dart:math' as math;

import 'package:allenamenti_app/pulse.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:allenamenti_app/widgets.dart';
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

  test('rosso o neon, sia nel chiaro sia nello scuro', () {
    for (final b in Brightness.values) {
      expect(creaTema(b).colorScheme.primary, rossoPulse);
      expect(creaTema(b, neon: true).colorScheme.primary, rosaNeon);
    }
    expect(Pulse.per(scuro: true, neon: false), same(Pulse.scuro));
    expect(Pulse.per(scuro: false, neon: true), same(Pulse.chiaro));
    expect(Pulse.per(scuro: false, neon: false), same(Pulse.chiaroRosso));
    expect(Pulse.per(scuro: true, neon: true), same(Pulse.scuroNeon));
  });

  test('colori degli sport: distinti tra loro e leggibili su ogni fondo', () {
    double contrasto(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
    }

    final primaScuro = temaScuroAttivo;
    addTearDown(() {
      temaScuroAttivo = primaScuro;
      neonAttivo = false;
    });
    const sport = [
      'Forza',
      'Corsa',
      'Nuoto',
      'Bici',
      'Mobilità',
      'Arrampicata',
      'Camminata',
      'Attività libera',
    ];
    for (final n in [false, true]) {
      for (final scuro in [true, false]) {
        neonAttivo = n;
        temaScuroAttivo = scuro;
        final fondo = Color(scuro ? 0xFF0B0B0D : 0xFFF6F6FA);
        final colori = [for (final s in sport) coloreSport(s)];
        expect(colori.toSet().length, sport.length);
        for (final (i, c) in colori.indexed) {
          expect(
            contrasto(c, fondo),
            greaterThanOrEqualTo(3),
            reason: '${sport[i]} neon=$n scuro=$scuro',
          );
        }
      }
    }
    // Sul fondo scuro restano i colori di sempre (tranne la bici, più chiara).
    neonAttivo = false;
    temaScuroAttivo = true;
    expect(coloreSport('Forza'), const Color(0xFF8E8E96));
    expect(coloreSport('Nuoto'), const Color(0xFFFF8A3D));
    neonAttivo = true;
    expect(coloreSport('Arrampicata'), const Color(0xFFFFE600));
  });

  test('camminata: si vede sul fondo chiaro, resta luminosa sullo scuro', () {
    double contrasto(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
    }

    final primaScuro = temaScuroAttivo;
    addTearDown(() {
      temaScuroAttivo = primaScuro;
      neonAttivo = false;
    });
    for (final n in [false, true]) {
      neonAttivo = n;
      temaScuroAttivo = false;
      expect(
        contrasto(coloreSport('Camminata'), const Color(0xFFF6F6FA)),
        greaterThanOrEqualTo(3),
      );
      temaScuroAttivo = true;
      expect(
        contrasto(coloreSport('Camminata'), const Color(0xFF0B0B0D)),
        greaterThanOrEqualTo(3),
      );
      expect(
        coloreSport('Camminata'),
        n ? const Color(0xFFC6FF3D) : const Color(0xFFE0A33A),
      );
    }
  });
}
