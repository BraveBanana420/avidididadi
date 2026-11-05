import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/screens/esecuzione_screen.dart';
import 'package:allenamenti_app/screens/vista_bici.dart';
import 'package:allenamenti_app/sensore_ble.dart';
import 'package:allenamenti_app/sensori_bici.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Indoor Bike Data" di un rullo: 36 km/h, 90 rpm, 200 W.
const _datiRullo = [0x44, 0x00, 0x10, 0x0E, 0xB4, 0x00, 0xC8, 0x00];

/// "CSC Measurement": solo i giri della ruota.
List<int> _ruota(int giri, int tempo) => [
  0x01,
  giri & 0xFF,
  (giri >> 8) & 0xFF,
  0,
  0,
  tempo & 0xFF,
  (tempo >> 8) & 0xFF,
];

WorkoutStep _passo() => WorkoutStep(
  id: 'prova',
  sport: 'Bici',
  nome: 'Prova',
  durataTot: 10,
  ordine: 1,
  fase: 'principale',
  descrizione: 'Watt fissi',
  serie: '',
  ripetizioni: '',
  distanzaM: '',
  durataMin: '10',
  intensita: '120 W',
  recuperoS: '',
  note: '',
);

Future<void> _apri(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: EsecuzioneScreen(
        state: AppState(),
        sport: 'Bici',
        // Il tipo non dice "rulli": è il caso della prova vera.
        tipo: 'Intervalli',
        nome: 'Prova',
        passi: [_passo()],
      ),
    ),
  );
  await tester.pump();
}

Future<void> _chiudi(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void _togliRullo() {
  sensoreBici.comandabile = false;
  sensoreBici.stato = StatoSensore.spento;
}

void main() {
  tearDown(_togliRullo);

  group('sensore', () {
    test('il rullo conta solo se è collegato adesso', () {
      final s = SensoreBici();
      expect(s.rulloInUso, isFalse);
      s.leggi(0, _datiRullo);
      expect(s.comandabile, isTrue);
      expect(s.rulloInUso, isFalse);
      s.stato = StatoSensore.collegato;
      expect(s.rulloInUso, isTrue);
      expect(s.velocita, closeTo(10, 0.01));
    });

    test('staccato non resta "rullo": la prossima uscita è su strada', () {
      final s = SensoreBici()..stato = StatoSensore.collegato;
      s.leggi(0, _datiRullo);
      s.azzera();
      expect(s.rulloInUso, isFalse);
    });

    test('la velocità del rullo non viene sovrascritta dai giri', () {
      final s = SensoreBici();
      s.leggi(0, _datiRullo);
      s.leggi(2, _ruota(100, 0));
      s.leggi(2, _ruota(100, 1024));
      expect(s.velocita, closeTo(10, 0.01));
    });

    test('senza rullo la velocità viene dai giri della ruota', () {
      final s = SensoreBici();
      s.leggi(2, _ruota(100, 0));
      s.leggi(2, _ruota(102, 1024));
      expect(s.velocita, closeTo(2 * circonferenzaDiBase / 1000, 0.01));
    });
  });

  group('schermata', () {
    testWidgets('col rullo collegato prima del via si passa al chiuso', (
      tester,
    ) async {
      await _apri(tester);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );

      sensoreBici.comandabile = true;
      sensoreBici.stato = StatoSensore.collegato;
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );

      await tester.tap(find.text('Inizia'));
      await tester.pump();
      expect(find.byType(VistaBici), findsOneWidget);
      expect(find.text('Mappa'), findsNothing);
      await _chiudi(tester);
    });

    testWidgets('col rullo collegato dopo il via si passa al chiuso', (
      tester,
    ) async {
      await _apri(tester);
      await tester.tap(find.text('Inizia'));
      await tester.pump();
      expect(find.byType(VistaBici), findsNothing);

      sensoreBici.comandabile = true;
      sensoreBici.stato = StatoSensore.collegato;
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.byType(VistaBici), findsOneWidget);
      await _chiudi(tester);
    });

    testWidgets('spento a mano, l\'interruttore comanda', (tester) async {
      await _apri(tester);
      sensoreBici.comandabile = true;
      sensoreBici.stato = StatoSensore.collegato;
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      await _chiudi(tester);
    });

    testWidgets('senza rullo resta la schermata all\'aperto', (tester) async {
      await _apri(tester);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Inizia'));
      await tester.pump();
      expect(find.byType(VistaBici), findsNothing);
      await _chiudi(tester);
    });
  });
}
