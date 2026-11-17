import 'dart:typed_data';

import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/avvisi.dart';
import 'package:allenamenti_app/battito.dart';
import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/immagini.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/pulse.dart';
import 'package:allenamenti_app/screens/esecuzione_screen.dart';
import 'package:allenamenti_app/sensori_bici.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _notaLibera = 'Tocca "Fatto" quando hai finito.';

WorkoutStep _passo(
  String sport, {
  String durata = '10',
  String note = '',
  String esercizio = '',
}) => WorkoutStep(
  id: 'prova',
  sport: sport,
  nome: 'Prova',
  durataTot: 10,
  ordine: 1,
  fase: 'principale',
  descrizione: 'Primo blocco',
  serie: '',
  ripetizioni: '',
  distanzaM: '',
  durataMin: durata,
  intensita: '',
  recuperoS: '',
  note: note,
  esercizio: esercizio,
);

Future<void> _apri(
  WidgetTester tester,
  String sport,
  String tipo, {
  bool libera = false,
  WorkoutStep? passo,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: EsecuzioneScreen(
        state: AppState(),
        sport: sport,
        tipo: tipo,
        nome: 'Prova',
        libera: libera,
        passi: [passo ?? _passo(sport)],
      ),
    ),
  );
  await tester.pump();
}

/// Il cronometro della schermata è vero, il tempo dei test no: più dei
/// 5 secondi del conto alla rovescia bisogna aspettarli davvero.
Future<void> _aspettaOltreIlConto(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(seconds: 6)));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

Future<void> _chiudi(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('bici al chiuso: niente timer, parte solo col tasto Inizia', (
    tester,
  ) async {
    await _apri(tester, 'Bici', 'Rulli');
    expect(find.text('Parti quando vuoi'), findsOneWidget);
    expect(find.text('Rullo e sensori'), findsOneWidget);
    expect(find.text('Battito'), findsOneWidget);
    expect(find.byTooltip('Pausa'), findsNothing);

    // Il tempo passa, ma la schermata resta quella.
    await _aspettaOltreIlConto(tester);
    expect(find.text('Parti quando vuoi'), findsOneWidget);

    await tester.tap(find.text('Inizia'));
    await tester.pump();
    expect(find.text('Parti quando vuoi'), findsNothing);
    expect(find.byTooltip('Pausa'), findsOneWidget);
    await _chiudi(tester);
  });

  testWidgets('camminata al chiuso: aspetta il tasto, senza riga del rullo', (
    tester,
  ) async {
    await _apri(tester, 'Camminata', 'Tapis roulant');
    await _aspettaOltreIlConto(tester);
    expect(find.text('Parti quando vuoi'), findsOneWidget);
    expect(find.text('Rullo e sensori'), findsNothing);
    expect(find.text('Battito'), findsOneWidget);
    await _chiudi(tester);
  });

  testWidgets('camminata: i passi del telefono si contano dal via', (
    tester,
  ) async {
    // Il contapassi del telefono: passi dall'accensione e ultimo passo (ms).
    var totale = 48210.0;
    var ms = 0.0;
    const canale = MethodChannel('avidididadi/avvio');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(canale, (
      call,
    ) async {
      if (call.method == 'passiAvvia') return true;
      if (call.method == 'passiLetti') {
        return Float64List.fromList([totale, ms]);
      }
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        canale,
        null,
      ),
    );
    await _apri(tester, 'Camminata', 'Tapis roulant');
    await tester.pump(const Duration(seconds: 2));
    // Prima del via si cammina verso il tapis roulant: non conta.
    totale += 35;
    ms += 20000;
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('PASSI'), findsNothing);

    await tester.tap(find.text('Inizia'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('PASSI'), findsOneWidget);
    expect(find.text('PASSI AL MINUTO'), findsOneWidget);
    expect(find.text('0', findRichText: true), findsOneWidget);

    for (var k = 0; k < 4; k++) {
      totale += 11;
      ms += 6000;
      await tester.pump(const Duration(seconds: 2));
    }
    expect(find.text('44', findRichText: true), findsOneWidget);
    expect(find.text('110', findRichText: true), findsOneWidget);

    // In pausa i passi non entrano nel conto.
    await tester.tap(find.byTooltip('Pausa'));
    await tester.pump(const Duration(seconds: 2));
    totale += 60;
    ms += 40000;
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('44', findRichText: true), findsOneWidget);
    await _chiudi(tester);
  });

  testWidgets('forza: resta il conto alla rovescia, poi parte da sola', (
    tester,
  ) async {
    await _apri(tester, 'Forza', '');
    expect(find.text('Preparati'), findsOneWidget);
    expect(find.text('Inizia subito'), findsOneWidget);

    await _aspettaOltreIlConto(tester);
    expect(find.text('Preparati'), findsNothing);
    expect(find.text('Inizia subito'), findsNothing);
    expect(find.byType(AnelloPulse), findsOneWidget);
    await _chiudi(tester);
  });

  testWidgets('bici all\'aperto: watt e cadenza solo se arrivano davvero', (
    tester,
  ) async {
    // Due pagine: nei test la mappa vera non si può aprire.
    addTearDown(() {
      sensoreBici.stato = StatoSensore.spento;
      sensoreBici.azzera();
    });
    await _apri(tester, 'Bici', 'Intervalli');
    await tester.tap(find.text('Inizia'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('POTENZA'), findsNothing);
    expect(find.text('CADENZA'), findsNothing);

    // Sensore collegato, ma ancora nessun dato: resta tutto nascosto.
    sensoreBici.stato = StatoSensore.collegato;
    sensoreBici.notifyListeners();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('POTENZA'), findsNothing);

    // Misuratore di potenza senza cadenza: 200 W.
    sensoreBici.leggi(1, [0x00, 0x00, 0xC8, 0x00]);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('POTENZA'), findsOneWidget);
    expect(find.text('CADENZA'), findsNothing);
    await _chiudi(tester);
  });

  testWidgets('bici all\'aperto libera: numeri grandi finché ci stanno', (
    tester,
  ) async {
    final prima = vistaMappa.value;
    vistaMappa.value = VistaMappa.pagine;
    addTearDown(() {
      vistaMappa.value = prima;
      sensoreBici.stato = StatoSensore.spento;
      sensoreBici.azzera();
    });
    await _apri(
      tester,
      'Bici',
      '',
      libera: true,
      passo: _passo('Bici', durata: '', note: _notaLibera),
    );
    final inizia = find.textContaining('Inizia');
    if (inizia.evaluate().isNotEmpty) await tester.tap(inizia.first);
    await tester.pump(const Duration(milliseconds: 300));
    // Lo schermo del Samsung S24 (360 × 780), quello su cui si prova.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    await tester.pump();

    // Senza sensori: un dato per riga, uno sotto l'altro. Le due versioni
    // (numeri grandi e griglia) ci sono entrambe: conta quella che si vede.
    Offset dove(String testo) =>
        tester.getTopLeft(find.text(testo).hitTestable());
    expect(dove('VELOCITÀ').dx, dove('DISTANZA').dx);
    expect(dove('VELOCITÀ').dy, greaterThan(dove('DISTANZA').dy));
    expect(find.text('POTENZA'), findsNothing);

    // Arrivano watt e cadenza: compaiono e non ci stanno più tutti grandi:
    // si torna da soli alla griglia a due.
    sensoreBici.stato = StatoSensore.collegato;
    sensoreBici.leggi(1, [0x00, 0x00, 0xC8, 0x00]);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('POTENZA').hitTestable(), findsOneWidget);
    // Stessa riga (le caselle possono differire di poco in altezza).
    expect(dove('VELOCITÀ').dy, closeTo(dove('DISTANZA').dy, 3));
    expect(dove('VELOCITÀ').dx, greaterThan(dove('DISTANZA').dx));
    await _chiudi(tester);
  });

  testWidgets('camminata libera: con i passi i numeri passano alla griglia', (
    tester,
  ) async {
    final prima = vistaMappa.value;
    vistaMappa.value = VistaMappa.pagine;
    addTearDown(() => vistaMappa.value = prima);
    const canale = MethodChannel('avidididadi/avvio');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(canale, (
      call,
    ) async {
      if (call.method == 'passiAvvia') return true;
      if (call.method == 'passiLetti') return Float64List.fromList([1000, 0]);
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        canale,
        null,
      ),
    );
    // GPS già permesso: il contapassi parte dopo la sua richiesta.
    for (final c in const [
      'flutter.baseflow.com/geolocator_android',
      'flutter.baseflow.com/geolocator',
    ]) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        MethodChannel(c),
        (chiamata) async => switch (chiamata.method) {
          'isLocationServiceEnabled' => true,
          'checkPermission' || 'requestPermission' => 3,
          _ => null,
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          MethodChannel(c),
          null,
        ),
      );
    }
    await _apri(
      tester,
      'Camminata',
      '',
      libera: true,
      passo: _passo('Camminata', durata: '', note: _notaLibera),
    );
    final inizia = find.textContaining('Inizia');
    if (inizia.evaluate().isNotEmpty) await tester.tap(inizia.first);
    await tester.pump(const Duration(seconds: 2));
    // Lo schermo del Samsung S24 (360 × 780).
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    await tester.pump();

    // I passi si vedono e distanza e passo stanno sulla stessa riga: la
    // griglia, invece dei numeri grandi che farebbero scorrere la pagina.
    Offset dove(String testo) =>
        tester.getTopLeft(find.text(testo).hitTestable());
    expect(find.text('PASSI').hitTestable(), findsOneWidget);
    expect(dove('PASSO').dy, closeTo(dove('DISTANZA').dy, 3));
    await _chiudi(tester);
  });

  testWidgets('forza libera: il cerchio resta, il testo doppio no', (
    tester,
  ) async {
    await _apri(
      tester,
      'Forza',
      '',
      libera: true,
      passo: _passo('Forza', durata: '', note: _notaLibera),
    );
    await tester.tap(find.text('Inizia subito'));
    await tester.pump();

    expect(find.byType(AnelloPulse), findsOneWidget);
    expect(find.text('tocca Fatto quando hai finito'), findsOneWidget);
    expect(find.text(_notaLibera), findsNothing);
    await _chiudi(tester);
  });

  testWidgets('senza sensori il movimento riempie lo spazio sotto, in grande', (
    tester,
  ) async {
    final state = AppState()
      ..esercizi = [
        Esercizio.da({
          'id': 'Pushups',
          'nome': 'Piegamenti',
          'nome_en': 'Pushups',
          'tipo': 'forza',
          'schema': 'spinta',
          'livello': 'principiante',
          'attrezzi': <List<String>>[],
          'muscoli': ['chest'],
          'muscoli_secondari': <String>[],
          'istruzioni': <String>[],
          // Le due foto della libreria: senza animazione sono loro il movimento.
          'immagini': ['Pushups/0.jpg', 'Pushups/1.jpg'],
        }),
      ];
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: EsecuzioneScreen(
          state: state,
          sport: 'Forza',
          tipo: '',
          nome: 'Prova',
          passi: [_passo('Forza', durata: '', esercizio: 'Pushups')],
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Inizia subito'));
    await tester.pump();

    final figura = find.bySemanticsLabel('Guarda il movimento di Piegamenti');
    expect(figura, findsOneWidget);
    // Molto più larga della miniatura accanto al nome (112).
    expect(tester.getSize(figura).width, greaterThan(250));
    // Sotto il cerchio del tempo, non accanto al nome.
    expect(
      tester.getTopLeft(figura).dy,
      greaterThan(tester.getBottomLeft(find.byType(AnelloPulse)).dy),
    );
    expect(find.textContaining('BATTITO'), findsNothing);

    // Fascia collegata ma ancora muta: niente riquadro vuoto, figura grande.
    addTearDown(() {
      sensoreBattito.stato = StatoSensore.spento;
      sensoreBattito.azzera();
    });
    sensoreBattito.stato = StatoSensore.collegato;
    sensoreBattito.notifyListeners();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('BATTITO'), findsNothing);
    expect(tester.getSize(figura).width, greaterThan(250));

    // Arriva il battito: riquadro e figura piccola accanto al nome.
    sensoreBattito.leggi(0, [0x00, 66]);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('BATTITO'), findsOneWidget);
    expect(find.textContaining('66', findRichText: true), findsOneWidget);
    expect(tester.getSize(find.byType(AnimazioneEsercizio)).width, 112);
    expect(tester.takeException(), isNull);
    await _chiudi(tester);
  });

  testWidgets('a fine seduta i dati a mano si inseriscono dal riepilogo', (
    tester,
  ) async {
    await _apri(
      tester,
      'Nuoto',
      'Piscina',
      libera: true,
      passo: _passo('Nuoto', durata: '', note: _notaLibera),
    );
    await tester.tap(find.text('Inizia subito'));
    await tester.pump();
    await tester.tap(find.text('Fatto'));
    await tester.pump();
    expect(find.text('Inserisci i dati a mano'), findsOneWidget);
    await _chiudi(tester);
  });

  for (final libera in [true, false]) {
    testWidgets(
      'bici all\'aperto ${libera ? 'libera: niente doppioni' : 'programmata: il testo resta'}',
      (tester) async {
        await _apri(
          tester,
          'Bici',
          'Intervalli',
          libera: libera,
          passo: _passo('Bici', durata: '', note: _notaLibera),
        );
        await tester.tap(find.text('Inizia'));
        await tester.pump();

        expect(find.text('tocca Fatto quando hai finito'), findsOneWidget);
        expect(find.text(_notaLibera), libera ? findsNothing : findsOneWidget);
        await _chiudi(tester);
      },
    );
  }

  for (final vista in [VistaMappa.minimappa, VistaMappa.pagine]) {
    testWidgets(
      'bici all\'aperto (${vista.name}): barra piatta, sempre in vista',
      (tester) async {
        final prima = vistaMappa.value;
        vistaMappa.value = vista;
        addTearDown(() => vistaMappa.value = prima);
        await _apri(tester, 'Bici', 'Intervalli');
        await tester.tap(find.text('Inizia'));
        await tester.pump();

        expect(find.byType(AnelloPulse), findsNothing);
        expect(find.byType(BarraAvanzamento), findsOneWidget);
        // Tutta dentro lo schermo, anche con la mappa: senza scorrere.
        expect(
          tester.getBottomRight(find.byType(BarraAvanzamento)).dy,
          lessThan(tester.view.physicalSize.height / 2.625),
        );
        await _chiudi(tester);
      },
    );
  }
}
