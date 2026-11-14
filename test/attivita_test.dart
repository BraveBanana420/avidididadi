import 'dart:io';

import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/attivita.dart';
import 'package:allenamenti_app/attivita_libera.dart';
import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/intervals.dart';
import 'package:allenamenti_app/modifica_sessione.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/profilo.dart';
import 'package:allenamenti_app/screens/attivita_screen.dart';
import 'package:allenamenti_app/screens/workout_screen.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:allenamenti_app/voce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Sessione _sessione(
  String id,
  String sport, {
  int ora = 8,
  int minuti = 45,
  String fonte = 'Garmin',
  String tipo = '',
}) {
  final inizio = DateTime(2026, 11, 2, ora);
  return Sessione(
    id: id,
    data: DateTime(2026, 11, 2),
    sport: sport,
    tipo: tipo,
    durataMin: minuti,
    fonte: fonte,
    inizio: inizio,
    fine: inizio.add(Duration(minutes: minuti)),
  );
}

void main() {
  group('nomi delle attività', () {
    test('"walking" di intervals.icu è una camminata', () {
      expect(sportDaTipoIcu('walking'), ('Camminata', 'Camminata'));
      expect(sportDaTipoIcu('Walking')!.$1, 'Camminata');
      expect(sportDaTipoIcu('Walk')!.$1, 'Camminata');
      expect(sportDaTipoIcu('Hike'), ('Camminata', 'Escursione'));
    });

    test('la stessa attività, comunque scritta', () {
      for (final n in ['RockClimbing', 'ROCK_CLIMBING', 'rock climbing']) {
        expect(attivitaDaNome(n)!.$1, 'Arrampicata', reason: n);
      }
      expect(sportDaTipoIcu('WeightTraining'), ('Forza', 'Pesi'));
      expect(sportDaTipoIcu('Yoga'), ('Mobilità', 'Yoga'));
    });

    test('i tipi già noti non cambiano', () {
      expect(sportDaTipoIcu('Run'), ('Corsa', 'Corsa'));
      expect(sportDaTipoIcu('VirtualRide'), ('Bici', 'Rulli'));
      expect(sportDaTipoIcu('OpenWaterSwim'), ('Nuoto', 'Acque libere'));
    });

    test('il resto è un\'attività libera col suo nome, in italiano', () {
      expect(sportDaTipoIcu('Elliptical'), (sportAttivitaLibera, 'Ellittica'));
      expect(mappaAttivita('TENNIS'), (sportAttivitaLibera, 'Tennis'));
      expect(mappaAttivita('OTHER', pacchetto: 'com.altra.app'), (
        sportAttivitaLibera,
        'Allenamento',
      ));
      expect(attivitaDaNome('StandUpFoo'), (
        sportAttivitaLibera,
        'Stand up foo',
      ));
      expect(attivitaDaNome(''), isNull);
    });

    test('Health Connect: camminata tradotta, il Garmin OTHER resta forza', () {
      expect(mappaAttivita('WALKING')!.$1, 'Camminata');
      expect(mappaAttivita('OTHER', pacchetto: pacchettoGarmin)!.$1, 'Forza');
    });
  });

  group('stessa attività da due fonti', () {
    test('camminata: resta quella di intervals.icu', () {
      final hc = _sessione('hc', 'Camminata');
      final icu = _sessione('icu', 'Camminata');
      expect(senzaDoppioniIcu([hc], [icu]), isEmpty);
    });

    test('forza: resta quella di Health Connect, coi blocchi', () {
      final hc = _sessione('hc', 'Forza');
      final icu = _sessione('icu', 'Forza');
      expect(senzaDoppioniIcu([hc], [icu]), [hc]);
      expect(icuSenzaDoppioniHc([icu], [hc]), isEmpty);
    });

    test('una libera è la stessa di uno sport noto alla stessa ora', () {
      final garmin = _sessione('hc', 'Forza');
      final libera = _sessione('icu', sportAttivitaLibera);
      expect(icuSenzaDoppioniHc([libera], [garmin]), isEmpty);
      final hcLibera = _sessione('hc2', sportAttivitaLibera);
      final corsa = _sessione('icu2', 'Corsa');
      expect(senzaDoppioniIcu([hcLibera], [corsa]), isEmpty);
    });

    test('orari diversi: sono due attività', () {
      final mattina = _sessione('hc', 'Camminata');
      final sera = _sessione('icu', 'Camminata', ora: 18);
      expect(senzaDoppioniIcu([mattina], [sera]), [mattina]);
      final libera = _sessione('icu2', sportAttivitaLibera, ora: 18);
      expect(icuSenzaDoppioniHc([libera], [mattina]), [libera]);
    });
  });

  group('attività scelte', () {
    test('chi aveva già l\'app le trova dai suoi dati', () {
      final a = attivitaDaiDati(
        settimana: [Slot(giorno: 1, fascia: 'Mattina', sport: 'Corsa')],
        piano: const [],
        sessioni: [_sessione('s', 'Yoga'), _sessione('c', 'Camminata')],
        generati: const {'Bici'},
        forza: true,
        arrampicata: true,
      );
      expect(a, {'Corsa', 'Mobilità', 'Bici', 'Forza', 'Arrampicata'});
    });

    test('nuova installazione: nessuna, e nei menu ci sono tutte', () {
      expect(
        attivitaDaiDati(
          settimana: const [],
          piano: const [],
          sessioni: const [],
          generati: const {},
          forza: false,
          arrampicata: false,
        ),
        isEmpty,
      );
      expect(sportDeiMenu(const {}), sportList);
    });

    test('nei menu solo quelle scelte, e il riposo', () {
      expect(sportDeiMenu({'Nuoto', 'Corsa', 'Bici'}), [
        'Corsa',
        'Nuoto',
        'Bici',
        'Riposo',
      ]);
    });

    test('dal "+" ci sono sempre tutte', () {
      final nel = attivitaLibere.map((a) => a.$1).toSet();
      expect(nel, containsAll(attivitaDaScegliere));
      expect(nel, contains(sportCamminata));
    });

    test('si salvano nel profilo; le righe vecchie restano leggibili', () {
      final p = Profilo()..attivita = {'Corsa', 'Arrampicata'};
      final righe = p.toRows();
      final t = Tabella({'chiave': 0, 'valore': 1}, righe);
      expect(Profilo.da(t).attivita, {'Corsa', 'Arrampicata'});
      final vecchia = Tabella(
        {'chiave': 0, 'valore': 1},
        [
          ['nome', 'x'],
        ],
      );
      expect(Profilo.da(vecchia).attivita, isEmpty);
    });
  });

  group('calendario', () {
    final oggi = DateTime(2026, 11, 2); // lunedì
    PianoRiga riga(DateTime d, String sport) => PianoRiga(
      data: d,
      fascia: 'Mattina',
      sport: sport,
      tipo: '',
      durataMin: 45,
    );

    test('togliere uno sport: restano passato e sedute fatte', () {
      final ieri = oggi.subtract(const Duration(days: 1));
      final domani = oggi.add(const Duration(days: 1));
      final piano = [
        riga(ieri, 'Nuoto'),
        riga(oggi, 'Nuoto'),
        riga(domani, 'Nuoto'),
        riga(domani, 'Corsa'),
      ];
      final fuori = senzaSedute(piano, {'Nuoto'}, oggi, (r) => r.data == oggi);
      expect(fuori.map((r) => (r.data, r.sport)), [
        (ieri, 'Nuoto'),
        (oggi, 'Nuoto'),
        (domani, 'Corsa'),
      ]);
    });

    test('aggiungere uno sport: nei giorni scelti, fino alla fine', () {
      final fine = oggi.add(const Duration(days: 14));
      final nuovo = conSeduteNuove(
        [riga(oggi, 'Corsa')],
        [
          Slot(giorno: 1, fascia: 'Mattina', sport: 'Arrampicata'),
          Slot(giorno: 4, fascia: 'Sera', sport: 'Arrampicata', durataMin: 90),
        ],
        oggi,
        fine,
      );
      final arr = nuovo.where((r) => r.sport == 'Arrampicata').toList();
      // Lunedì 2, 9, 16 e giovedì 5, 12.
      expect(arr.map((r) => r.data.day), [2, 5, 9, 12, 16]);
      expect(arr[1].durataMin, 90);
      expect(nuovo.where((r) => r.sport == 'Corsa'), hasLength(1));
    });

    test('un giorno che ha già quello sport non si raddoppia', () {
      final nuovo = conSeduteNuove(
        [riga(oggi, 'Corsa')],
        [Slot(giorno: 1, fascia: 'Sera', sport: 'Corsa')],
        oggi,
        oggi,
      );
      expect(nuovo, hasLength(1));
    });
  });

  group('sedute passate scritte a mano', () {
    test('la seduta nuova non prende il posto di un\'altra', () {
      final d = DateTime(2026, 10, 20);
      final a = sessioneDaScrivere(d, 'Nuoto', tipo: 'Piscina', durataMin: 40);
      expect(a.data, d);
      expect(a.durataMin, 40);
      expect(a.fonte, fonteApp);
      final b = sessioneDaScrivere(d, 'Nuoto', occupati: {a.id});
      expect(b.id, isNot(a.id));
      expect(b.data, d);
    });
  });

  group('la voce e i gradi', () {
    test('6a è "6 A", non "sesta"', () {
      expect(gradiParlati('Via 6a'), 'Via 6 A');
      expect(gradiParlati('Boulder 7B+ a vista'), 'Boulder 7 B più a vista');
      expect(gradiParlati('6a-6c'), 'da 6 A a 6 C');
      expect(gradiParlati('6a+-7a'), 'da 6 A più a 7 A');
    });

    test('non tocca il resto', () {
      for (final t in [
        'Serie 3a',
        '3 x 10',
        '5:30/km',
        'Z2',
        '8-10 ripetizioni',
        'bici 10b',
      ]) {
        expect(gradiParlati(t), t);
      }
    });

    test('vale nel nome e nel dettaglio del blocco', () {
      const b = Blocco(
        tipo: TipoBlocco.lavoro,
        titolo: 'Via 6a',
        dettaglio: 'Serie 1 di 3 · grado 6b+',
        intensita: '',
        obiettivo2: '',
        note: '',
        fase: 'principale',
        esercizio: '',
        secondi: null,
        passo: 0,
        serie: 1,
        ripetizioni: '',
      );
      final frase = fraseBlocco(b);
      expect(frase, contains('Via 6 A'));
      expect(frase, contains('grado 6 B più'));
    });
  });

  group('con i dati salvati', () {
    late Directory cartella;
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      cartella = Directory.systemTemp.createTempSync('attivita_test');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => cartella.path,
          );
    });
    tearDown(() => cartella.deleteSync(recursive: true));

    test('la correzione di una seduta dell\'orologio non si perde', () async {
      final state = AppState();
      final garmin = _sessione('hc-1', 'Corsa');
      state.sessioniHc = [garmin];
      state.sessioni = [garmin];
      await state.modificaSessione(
        sessioneModificata(
          garmin,
          inizio: garmin.inizio!,
          durataMin: 50,
          distanzaKm: 8,
          fcMedia: 140,
          fcMax: 160,
          calorie: 500,
          rpe: 6,
          note: 'corretta',
        ),
      );
      expect(state.sessioni.single.durataMin, 50);
      expect(state.sessioni.single.fonte, 'Garmin');
      expect(state.storicoCsv, isEmpty);

      // L'orologio manda di nuovo i suoi dati: la correzione resta.
      await state.load();
      state.sessioniHc = [garmin];
      await state.annullaCorrezioni('nessuna');
      expect(state.sessioni.single.durataMin, 50);

      await state.annullaCorrezioni('hc-1');
      expect(state.sessioni.single.durataMin, 45);
    });

    test('una seduta nuova di un giorno passato entra nello storico', () async {
      final state = AppState();
      final nuova = sessioneDaScrivere(DateTime(2026, 10, 20), 'Nuoto');
      await state.modificaSessione(
        sessioneModificata(
          nuova,
          inizio: nuova.inizio!,
          durataMin: 40,
          distanzaKm: 1.5,
          fcMedia: 0,
          fcMax: 0,
          calorie: 0,
          rpe: 0,
          note: '',
        ),
      );
      expect(state.storicoCsv.single.durataMin, 40);
      expect(state.sessioniModificate, isEmpty);
    });

    test('togliere un\'attività: storico intatto, calendario pulito', () async {
      final state = AppState();
      final oggi = soloData(DateTime.now());
      final domani = oggi.add(const Duration(days: 1));
      state.profilo.attivita = {'Corsa', 'Nuoto'};
      state.piano = [
        PianoRiga(
          data: domani,
          fascia: 'Mattina',
          sport: 'Nuoto',
          tipo: '',
          durataMin: 30,
        ),
        PianoRiga(
          data: domani,
          fascia: 'Sera',
          sport: 'Corsa',
          tipo: '',
          durataMin: 30,
        ),
      ];
      state.settimana = [Slot(giorno: 1, fascia: 'Mattina', sport: 'Nuoto')];
      state.storicoCsv = [_sessione('app', 'Nuoto', fonte: fonteApp)];
      await state.impostaAttivita({'Corsa'});
      expect(state.piano.single.sport, 'Corsa');
      expect(state.settimana, isEmpty);
      expect(state.sessioni.single.sport, 'Nuoto');
      expect(state.attivitaScelta('Nuoto'), isFalse);
      expect(state.sportScelti, ['Corsa', 'Riposo']);
    });

    test('aggiungere l\'arrampicata: sedute sì, generatore no', () async {
      final state = AppState();
      final oggi = soloData(DateTime.now());
      state.profilo.attivita = {'Corsa'};
      await state.impostaAttivita({'Corsa', 'Arrampicata'});
      await state.aggiungiAlCalendario('Arrampicata', {oggi.weekday}, 90);
      final righe = state.piano.where((r) => r.sport == 'Arrampicata');
      expect(righe.first.data, oggi);
      expect(righe.first.durataMin, 90);
      expect(righe.length, greaterThan(10));
      expect(state.profilo.sportGenerati, isEmpty);
      // La settimana tipo non c'era: non nasce da sola.
      expect(state.settimana, isEmpty);
    });
  });

  group('schermate', () {
    Future<void> grande(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Widget seduta(AppState state, String tipo) => MaterialApp(
      home: WorkoutScreen(
        state: state,
        data: DateTime(2026, 11, 2),
        sport: 'Nuoto',
        tipo: tipo,
        fascia: '',
        durataMin: 45,
      ),
    );

    AppState conPiano() => AppState()
      ..piano = [
        PianoRiga(
          data: DateTime(2026, 11, 2),
          fascia: 'Mattina',
          sport: 'Nuoto',
          tipo: 'Piscina',
          durataMin: 45,
        ),
      ];

    testWidgets('a seduta fatta si vede ancora l\'allenamento previsto', (
      tester,
    ) async {
      await grande(tester);
      final state = conPiano()
        ..sessioni = [_sessione('hc', 'Nuoto', tipo: 'Vasca')];
      await tester.pumpWidget(seduta(state, 'Vasca'));
      expect(find.textContaining('Allenamento previsto'), findsOneWidget);
      expect(find.text('Inizia allenamento'), findsNothing);
      // Anche se viene dall'orologio, i dati si correggono.
      expect(find.byTooltip('Modifica la sessione'), findsOneWidget);
      expect(find.text("L'ho già fatta: scrivi i dati"), findsNothing);
    });

    testWidgets('attività fuori programma: niente allenamento previsto', (
      tester,
    ) async {
      await grande(tester);
      final state = AppState()
        ..sessioni = [_sessione('hc', 'Nuoto', tipo: 'Piscina')];
      await tester.pumpWidget(seduta(state, 'Piscina'));
      expect(find.textContaining('Allenamento previsto'), findsNothing);
    });

    testWidgets('seduta passata non fatta: si possono scrivere i dati', (
      tester,
    ) async {
      await grande(tester);
      await tester.pumpWidget(seduta(conPiano(), 'Piscina'));
      expect(find.text("L'ho già fatta: scrivi i dati"), findsOneWidget);
    });

    testWidgets('scegliere i giorni di un\'attività aggiunta', (tester) async {
      (Set<int>, int)? risposta;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (c) => TextButton(
              onPressed: () async => risposta = await showDialog(
                context: c,
                builder: (_) => const QuandoDialog(sport: 'Arrampicata'),
              ),
              child: const Text('apri'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      final conferma = find.widgetWithText(
        FilledButton,
        'Metti nel calendario',
      );
      expect(tester.widget<FilledButton>(conferma).onPressed, isNull);
      await tester.tap(find.text('Mar'));
      await tester.pump();
      await tester.tap(conferma);
      await tester.pumpAndSettle();
      expect(risposta!.$1, {2});
      expect(risposta!.$2, 45);
    });
  });
}
