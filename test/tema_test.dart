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

  test('colori degli sport: stessi nei due temi, distinti tra loro', () {
    for (final n in [false, true]) {
      neonAttivo = n;
      final colori = [
        for (final s in ['Forza', 'Corsa', 'Nuoto', 'Bici', 'Mobilità'])
          coloreSport(s),
      ];
      expect(colori.toSet().length, 5);
      temaScuroAttivo = !temaScuroAttivo;
      expect([
        for (final s in ['Forza', 'Corsa', 'Nuoto', 'Bici', 'Mobilità'])
          coloreSport(s),
      ], colori);
    }
    neonAttivo = false;
    expect(coloreSport('Forza'), const Color(0xFF8E8E96));
  });
}
