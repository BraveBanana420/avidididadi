import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/screens/battito_sheet.dart';
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

    test('calibrazione: si legge il bit giusto (dati veri del Flux S)', () {
      expect(
        calibrazioneSupportata([0x82, 0x40, 0, 0, 0x0C, 0xA0, 0, 0]),
        isTrue,
      );
      expect(
        calibrazioneSupportata([0x82, 0x40, 0, 0, 0x0C, 0x20, 0, 0]),
        isFalse,
      );
      expect(calibrazioneSupportata([0x82, 0x40]), isFalse);
    });

    test('calibrazione: la risposta del rullo dà le velocità da superare', () {
      final r = rispostaCalibrazione([
        0x80,
        0x13,
        0x01,
        0xB8,
        0x0B,
        0x10,
        0x0E,
      ])!;
      expect(r.riuscito, isTrue);
      expect(r.kmhDa, 30);
      expect(r.kmhA, 36);
      expect(rispostaCalibrazione([0x80, 0x13, 0x04])!.riuscito, isFalse);
      expect(rispostaCalibrazione([0x80, 0x05, 0x01]), isNull);
    });

    test('calibrazione: segue i passi che detta il rullo', () {
      final s = SensoreBici()..faseCalibrazione = FaseCalibrazione.avvio;
      s.leggi(3, [0x80, 0x13, 0x01, 0xB8, 0x0B, 0x10, 0x0E]);
      expect(s.faseCalibrazione, FaseCalibrazione.accelera);
      expect(s.calibraKmhA, 36);
      s.leggi(4, [0x14, 0x04]);
      expect(s.faseCalibrazione, FaseCalibrazione.smetti);
      expect(s.calibrando, isTrue);
      s.leggi(4, [0x14, 0x02]);
      expect(s.faseCalibrazione, FaseCalibrazione.riuscita);
      expect(s.calibrando, isFalse);
    });

    test('calibrazione: rifiuto ed errore del rullo la chiudono', () {
      final rifiuto = SensoreBici()..faseCalibrazione = FaseCalibrazione.avvio;
      rifiuto.leggi(3, [0x80, 0x13, 0x04]);
      expect(rifiuto.faseCalibrazione, FaseCalibrazione.errore);

      final senza = SensoreBici()..faseCalibrazione = FaseCalibrazione.avvio;
      senza.leggi(3, [0x80, 0x00, 0x05]);
      expect(senza.faseCalibrazione, FaseCalibrazione.errore);

      final errore = SensoreBici()..faseCalibrazione = FaseCalibrazione.smetti;
      errore.leggi(4, [0x14, 0x03]);
      expect(errore.faseCalibrazione, FaseCalibrazione.errore);
    });

    test('promemoria: mai fatta o dopo due settimane, non prima', () {
      final oggi = DateTime(2026, 11, 20, 8);
      expect(calibrazioneDaFare(null, oggi), isTrue);
      expect(calibrazioneDaFare(DateTime(2026, 11, 7, 22), oggi), isFalse);
      expect(calibrazioneDaFare(DateTime(2026, 11, 6, 22), oggi), isTrue);
      expect(calibrazioneDaFare(DateTime(2026, 10, 1), oggi), isTrue);
    });

    test('la data dell\'ultima calibrazione si ricorda', () {
      final s = SensoreBici()..faseCalibrazione = FaseCalibrazione.smetti;
      s.leggi(4, [0x14, 0x02, 0x0C, 0x00]);
      expect(s.ultimaCalibrazione, isNotNull);

      final righe = s.altreRighe;
      final dopo = SensoreBici()..altreRighe = righe;
      expect(dopo.ultimaCalibrazione, isNotNull);
      expect(
        calibrazioneDaFare(dopo.ultimaCalibrazione, DateTime.now()),
        isFalse,
      );
    });

    test('il file di prima, con la sola circonferenza, resta leggibile', () {
      final s = SensoreBici()..altreRighe = ['2096'];
      expect(s.circonferenza, 2096);
      expect(s.ultimaCalibrazione, isNull);
    });

    test('il promemoria compare solo col rullo collegato', () {
      final s = SensoreBici()..sapeCalibrare = true;
      expect(s.daCalibrare, isFalse);
      s.comandabile = true;
      s.stato = StatoSensore.collegato;
      expect(s.daCalibrare, isTrue);
      s.ultimaCalibrazione = DateTime.now();
      expect(s.daCalibrare, isFalse);
    });

    test('fuori dalla calibrazione gli stati del rullo non contano', () {
      final s = SensoreBici();
      s.leggi(4, [0x14, 0x02]);
      expect(s.faseCalibrazione, FaseCalibrazione.nessuna);
    });

    test('senza rullo la velocità viene dai giri della ruota', () {
      final s = SensoreBici();
      s.leggi(2, _ruota(100, 0));
      s.leggi(2, _ruota(102, 1024));
      expect(s.velocita, closeTo(2 * circonferenzaDiBase / 1000, 0.01));
    });
  });

  group('foglio dei sensori', () {
    testWidgets('la calibrazione mostra i passi man mano che arrivano', (
      tester,
    ) async {
      sensoreBici.comandabile = true;
      sensoreBici.stato = StatoSensore.collegato;
      sensoreBici.sapeCalibrare = true;
      addTearDown(() {
        sensoreBici.sapeCalibrare = false;
        sensoreBici.faseCalibrazione = FaseCalibrazione.nessuna;
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => mostraSensoreBici(context),
                child: const Text('apri'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      expect(find.text('Inizia la calibrazione'), findsOneWidget);

      // Il rullo risponde con i dati veri del Flux S: da 32 a 37 km/h.
      sensoreBici.faseCalibrazione = FaseCalibrazione.avvio;
      sensoreBici.leggi(3, [0x80, 0x13, 0x01, 0x80, 0x0C, 0x74, 0x0E]);
      await tester.pump();
      expect(find.textContaining('superare 37 km/h'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);

      sensoreBici.leggi(4, [0x14, 0x04]);
      await tester.pump();
      expect(find.textContaining('Smetti di pedalare'), findsOneWidget);

      sensoreBici.leggi(4, [0x14, 0x02]);
      await tester.pump();
      expect(find.text('Calibrazione riuscita.'), findsOneWidget);
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
