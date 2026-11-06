import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/modifica_sessione.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/screens/modifica_sessione_screen.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Tabella _tab(List<String> colonne, List<String> riga) =>
    Tabella({for (final (i, c) in colonne.indexed) c: i}, [riga]);

void main() {
  final partenza = DateTime(2026, 11, 6, 18, 30);
  // Fatta partire e fermata subito: i dati veri si scrivono dopo.
  final fermata = Sessione(
    id: 'app-2026-11-06-nuoto-1830',
    data: DateTime(2026, 11, 6),
    sport: 'Nuoto',
    tipo: 'Piscina',
    durataMin: 1,
    fonte: fonteApp,
    note: 'Nuoto libero',
    inizio: partenza,
    fine: partenza.add(const Duration(minutes: 1)),
    calorieAttive: 8,
    calorieTotali: 10,
  );

  Sessione modificata({int durata = 45, double km = 1.025, double kcal = 8}) =>
      sessioneModificata(
        fermata,
        inizio: partenza,
        durataMin: durata,
        distanzaKm: km,
        fcMedia: 128,
        fcMax: 150,
        calorie: kcal,
        rpe: 6,
        note: '10x100',
      );

  group('sessione scritta a mano', () {
    test('i dati nuovi ci sono, id e giorno restano', () {
      final s = modificata();
      expect(s.id, fermata.id);
      expect(s.data, fermata.data);
      expect(s.durataMin, 45);
      expect(s.distanzaKm, 1.025);
      expect(s.fcMedia, 128);
      expect(s.rpe, 6);
      expect(s.note, '10x100');
      expect(s.fine, partenza.add(const Duration(minutes: 45)));
    });

    test('un dato tolto sparisce, non torna quello di prima', () {
      final s = sessioneModificata(
        fermata,
        inizio: partenza,
        durataMin: 45,
        distanzaKm: 0,
        fcMedia: 0,
        fcMax: 0,
        calorie: 0,
        rpe: 0,
        note: '',
      );
      expect(s.distanzaKm, 0);
      expect(s.calorieAttive, 0);
      expect(s.note, '');
    });

    test('le calorie scritte valgono anche per il totale', () {
      expect(modificata(kcal: 400).calorieTotali, 400);
      expect(modificata().calorieTotali, 10);
    });

    test('il ritmo delle statistiche segue i dati scritti', () {
      // 45 minuti per 1025 m: 4,39 minuti ogni 100 m.
      expect(ritmo(modificata()), closeTo(45 / 10.25, 0.001));
    });

    test('i metri in piscina si salvano esatti', () {
      final riga = modificata().toRow();
      final t = _tab(sessioniHeader, riga);
      expect(Sessione.da(t, riga)!.distanzaKm, 1.025);
    });
  });

  group('dati del nuoto', () {
    test('tempo medio scritto in vari modi', () {
      expect(secondiDa('1:55'), 115);
      expect(secondiDa('1.55'), 115);
      expect(secondiDa('115'), 115);
      expect(secondiDa(''), 0);
      expect(secondiDa('1:75'), 0);
      expect(secondiDa('ciao'), 0);
      expect(tempoScritto(115), '1:55');
      expect(tempoScritto(0), '');
    });

    test('si salvano e si rileggono', () {
      final n = SedutaNuoto(
        idSessione: fermata.id,
        data: fermata.data,
        vasche: 41,
        lunghezzaM: 25,
        passo100S: 115,
        stile: 'Stile libero',
      );
      final riga = n.toRow();
      final letta = SedutaNuoto.da(_tab(nuotoHeader, riga), riga)!;
      expect(letta.vasche, 41);
      expect(letta.lunghezzaM, 25);
      expect(letta.passo100S, 115);
      expect(letta.stile, 'Stile libero');
    });

    test('valori impossibili restano nei limiti', () {
      final riga = [fermata.id, '2026-11-06', '99999', '-3', 'x', ''];
      final letta = SedutaNuoto.da(_tab(nuotoHeader, riga), riga)!;
      expect(letta.vasche, 2000);
      expect(letta.lunghezzaM, 25);
      expect(letta.passo100S, 0);
    });

    test('numeri scritti a mano', () {
      expect(numeroScritto('12,5', 100), 12.5);
      expect(numeroScritto('', 100), 0);
      expect(numeroScritto('abc', 100), 0);
      expect(numeroScritto('-4', 100), 0);
      expect(numeroScritto('900', 100), 100);
    });
  });

  group('schermata', () {
    Future<void> apri(WidgetTester tester, Sessione s) async {
      tester.view.physicalSize = const Size(1080, 3400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: ModificaSessioneScreen(state: AppState(), sessione: s),
        ),
      );
    }

    Finder campo(String etichetta) => find.widgetWithText(TextField, etichetta);

    testWidgets('nuoto: vasche per lunghezza scrivono i metri', (tester) async {
      await apri(tester, fermata);
      await tester.enterText(campo('Vasche'), '41');
      await tester.pump();
      expect(
        tester.widget<TextField>(campo('Metri totali')).controller!.text,
        '1025',
      );
      await tester.tap(find.text('50 m'));
      await tester.pump();
      expect(
        tester.widget<TextField>(campo('Metri totali')).controller!.text,
        '2050',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('senza durata non si salva', (tester) async {
      await apri(tester, fermata);
      await tester.enterText(campo('Durata'), '');
      await tester.tap(find.text('Salva'));
      await tester.pump();
      expect(find.text('Scrivi quanti minuti è durata'), findsOneWidget);
    });
  });
}
