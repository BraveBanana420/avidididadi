import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:allenamenti_app/potenza.dart';
import 'package:allenamenti_app/riepilogo_condiviso.dart';
import 'package:allenamenti_app/screens/condividi_screen.dart';
import 'package:allenamenti_app/screens/profilo_allenamento.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lunedi = DateTime(2026, 11, 2);
  final oggi = DateTime(2026, 11, 5); // giovedì
  final corsa = Sessione(
    id: 'a',
    data: DateTime(2026, 11, 2),
    sport: 'Corsa',
    tipo: 'Lento',
    durataMin: 52,
    distanzaKm: 10.24,
    fcMedia: 142,
    calorieAttive: 610,
  );
  final bici = Sessione(
    id: 'b',
    data: DateTime(2026, 11, 4),
    sport: 'Bici',
    tipo: 'Intervalli',
    durataMin: 75,
    distanzaKm: 0,
    potenzaMedia: 198,
  );
  final nuoto = Sessione(
    id: 'c',
    data: DateTime(2026, 11, 4),
    sport: 'Nuoto',
    durataMin: 40,
    distanzaKm: 1.5,
  );
  final piano = [
    for (final (g, sport) in [
      (0, 'Corsa'),
      (2, 'Bici'),
      (4, 'Corsa'),
      (6, 'Forza'),
    ])
      PianoRiga(
        data: lunedi.add(Duration(days: g)),
        fascia: 'Sera',
        sport: sport,
        durataMin: 45,
      ),
  ];

  group('testi e numeri', () {
    test('durate e distanze come si dicono', () {
      expect(fmtDurataBreve(45), '45 min');
      expect(fmtDurataBreve(60), '1 h');
      expect(fmtDurataBreve(85), '1 h 25 min');
      expect(fmtDistanza('Corsa', 10.24), '10,24 km');
      expect(fmtDistanza('Bici', 42.37), '42,37 km');
      expect(fmtDistanza('Bici', 120.44), '120,4 km');
      expect(fmtDistanza('Corsa', 10.0), '10 km');
      expect(fmtDistanza('Nuoto', 1.5), '1500 m');
    });

    test('la sessione: tempo, distanza, passo, battito, calorie', () {
      expect(testoSessione(corsa), 'Corsa: Lento · 10,24 km in 52 min');
      final n = numeriSessione(corsa);
      expect(n.map((x) => x.$1), [
        'Tempo',
        'Distanza',
        'Passo',
        'Battito medio',
        'Calorie',
      ]);
      expect(n[2].$2, '5:05');
      expect(numeriSessione(bici).first, ('Tempo', '1:15', 'h'));
      expect(numeriSessione(bici)[1], ('Potenza', '198', 'W'));
    });

    test('la settimana: sedute fatte, tempo, km senza il nuoto', () {
      final r = riepilogoSettimana(piano, [corsa, bici, nuoto], lunedi, oggi);
      // Corsa e bici previste e fatte, il nuoto in più.
      expect(r.fatte, 3);
      expect(r.previste, 4);
      expect(r.minuti, 167);
      expect(r.km, closeTo(10.24, 0.001));
      expect(r.perSport.map((x) => x.sport), ['Bici', 'Corsa', 'Nuoto']);
      expect(r.perGiorno[0], ['Corsa']);
      expect(r.perGiorno[2], ['Bici', 'Nuoto']);
      expect(r.perGiorno[6], isEmpty);
      expect(periodoSettimana(lunedi), '2 – 8 novembre');
      expect(
        periodoSettimana(DateTime(2026, 10, 26)),
        '26 ottobre – 1 novembre',
      );
      expect(
        testoSettimana(r),
        'La mia settimana (2 – 8 novembre) · 3/4 sedute · 2 h 47 min · 10 km',
      );
    });
  });

  test('il numero grande del poster: distanza, altrimenti tempo', () {
    expect(numeroGrande(corsa), ('10,24', 'km'));
    expect(numeroGrande(nuoto), ('1500', 'm'));
    expect(numeroGrande(bici), ('1:15', 'ore'));
    expect(
      numeroGrande(
        Sessione(id: 'm', data: oggi, sport: 'Mobilità', durataMin: 25),
      ),
      ('25', 'minuti'),
    );
    // Sotto, gli altri numeri senza quello già in grande.
    expect(numeriPoster(corsa).map((n) => n.$1), [
      'Tempo',
      'Passo',
      'Battito medio',
    ]);
    expect(numeriPoster(bici).map((n) => n.$1), ['Potenza']);
  });

  group('immagini', () {
    Future<void> disegna(WidgetTester t, Widget w, ThemeData tema) async {
      await t.pumpWidget(
        MaterialApp(
          theme: tema,
          home: Scaffold(
            body: Center(child: SizedBox(width: 360, height: 450, child: w)),
          ),
        ),
      );
    }

    final temi = {
      'scuro rosso': creaTema(Brightness.dark),
      'chiaro rosso': creaTema(Brightness.light),
      'scuro neon': creaTema(Brightness.dark, neon: true),
      'chiaro neon': creaTema(Brightness.light, neon: true),
    };

    for (final MapEntry(key: nome, value: tema) in temi.entries) {
      testWidgets('sessione con percorso e settimana: $nome', (t) async {
        final giro = Percorso([
          for (var i = 0; i < 40; i++)
            PuntoGps(
              45.46 + 0.01 * (i < 20 ? i : 40 - i) / 20,
              9.19 + 0.01 * (i % 20) / 20,
              DateTime(2026, 11, 2, 18).add(Duration(seconds: 30 * i)),
            ),
        ]);
        await disegna(
          t,
          ImmagineSessione(sessione: corsa, percorso: giro),
          tema,
        );
        expect(find.text('Corsa: Lento'), findsOneWidget);
        expect(find.text('#avidididadi'), findsOneWidget);
        expect(find.text('Allenato con Avidididadi'), findsNothing);
        expect(t.takeException(), isNull);

        await disegna(
          t,
          ImmagineSessione(
            sessione: Sessione(
              id: 'f',
              data: oggi,
              sport: 'Forza',
              durataMin: 50,
            ),
            kgTotali: 4520,
            esercizi: const [
              ('Squat', '3×10 · 60 kg'),
              ('Panca piana', '3×8 · 50 kg'),
            ],
          ),
          tema,
        );
        expect(find.text('Sollevati'), findsOneWidget);
        expect(t.takeException(), isNull);

        await disegna(
          t,
          ImmagineSettimana(
            riepilogo: riepilogoSettimana(
              piano,
              [corsa, bici, nuoto],
              lunedi,
              oggi,
            ),
          ),
          tema,
        );
        expect(find.text('3/4'), findsOneWidget);
        expect(t.takeException(), isNull);

        // Il poster di una seduta indoor, con il grafico dei blocchi.
        await disegna(
          t,
          ImmaginePoster(
            sessione: bici,
            indoor: true,
            grafico: ProfiloAllenamento(
              barre: const [
                BarraAllenamento(600, (110, 130), '', 124),
                BarraAllenamento(480, (170, 185), '', 179),
              ],
              zone: const ZonePotenza(200),
              altezza: 96,
            ),
          ),
          tema,
        );
        expect(find.text('1:15'), findsOneWidget);
        expect(find.text('Indoor'), findsOneWidget);
        expect(t.takeException(), isNull);

        // La mappa: qui al posto della mappa vera un riquadro.
        await disegna(
          t,
          ImmagineMappa(
            sessione: corsa,
            mappa: const ColoredBox(color: Colors.grey),
            crediti: '© OpenStreetMap',
          ),
          tema,
        );
        expect(find.text('Corsa: Lento'), findsOneWidget);
        expect(find.text('#avidididadi'), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }
  });
}
