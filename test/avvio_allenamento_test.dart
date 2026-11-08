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
          'immagini': <String>[],
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
