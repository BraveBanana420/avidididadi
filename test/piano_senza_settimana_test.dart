import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/assistente.dart';
import 'package:allenamenti_app/generatore_endurance.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/screens/crea_piano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il piano vero arrivato sul telefono di chi corre soltanto, verso una 10 km.
const _pianoVero = [
  ('2026-11-07', 'Ritmo gara', 68),
  ('2026-11-09', 'Allunghi', 30),
  ('2026-11-11', 'Ritmo gara', 45),
  ('2026-11-14', 'Lungo', 55),
  ('2026-11-16', 'Lento', 25),
  ('2026-11-18', 'Ripetute', 35),
  ('2026-11-21', 'Allunghi', 15),
  ('2026-11-22', 'Ritmo gara', 65),
];

List<PianoRiga> _righe() => [
  for (final (d, tipo, min) in _pianoVero)
    PianoRiga(
      data: parseData(d)!,
      fascia: 'Mattina',
      sport: 'Corsa',
      tipo: tipo,
      durataMin: min,
      note: notaAssistente,
    ),
];

/// Minuti di una seduta, recuperi compresi.
double _minuti(List<WorkoutStep> passi) {
  var totale = 0.0;
  for (final p in passi) {
    final serie = int.tryParse(p.serie) ?? 1;
    final recupero = (int.tryParse(p.recuperoS) ?? 0) / 60;
    final tratto = p.ripetizioni == '20 s'
        ? 20 / 60
        : (double.tryParse(p.durataMin) ?? 0);
    totale += serie * (tratto + recupero);
  }
  return totale;
}

void main() {
  final oggi = DateTime(2026, 11, 6);

  group('piano arrivato dall\'assistente', () {
    test('lo sport si attiva da solo, una volta sola', () {
      expect(sportDaAttivare(_righe(), {}, oggi), {'Corsa'});
      expect(sportDaAttivare(_righe(), {'Corsa'}, oggi), isEmpty);
    });

    test('le sedute dell\'app o già passate non attivano niente', () {
      final mia = PianoRiga(
        data: oggi,
        fascia: 'Mattina',
        sport: 'Bici',
        durataMin: 60,
      );
      final vecchia = PianoRiga(
        data: oggi.subtract(const Duration(days: 1)),
        fascia: 'Mattina',
        sport: 'Nuoto',
        durataMin: 60,
        note: notaAssistente,
      );
      expect(sportDaAttivare([mia, vecchia], {}, oggi), isEmpty);
    });

    test('ogni seduta ha i passi, con il tipo scelto e la durata giusta', () {
      final p = generaPianoEndurance(
        piano: _righe(),
        storico: const [],
        sport: {'Corsa'},
        inizio: oggi,
        da: oggi,
      );
      expect(p.programma, hasLength(_pianoVero.length));
      for (final (d, tipo, min) in _pianoVero) {
        final data = parseData(d)!;
        final id = p.programma.singleWhere((x) => x.data == data).idWorkout;
        final passi = p.passi.where((w) => w.id == id).toList();
        expect(passi, isNotEmpty, reason: d);
        expect(p.tipi[(data, 'Corsa')], tipo, reason: d);
        expect(_minuti(passi), closeTo(min, 6), reason: '$d: $tipo $min min');
      }
    });
  });

  test(
    'settimane diverse, senza settimana tipo: tutte le sedute hanno passi',
    () {
      // Una sola uscita la prima settimana, tre quella dopo.
      final giorni = [
        DateTime(2026, 11, 12),
        DateTime(2026, 11, 16),
        DateTime(2026, 11, 18),
        DateTime(2026, 11, 21),
      ];
      final p = generaPianoEndurance(
        piano: [
          for (final d in giorni)
            PianoRiga(data: d, fascia: 'Sera', sport: 'Corsa', durataMin: 40),
        ],
        storico: const [],
        sport: {'Corsa'},
        inizio: oggi,
        da: oggi,
      );
      expect(p.programma.map((x) => x.data), giorni);
      for (final r in p.programma) {
        expect(p.passi.where((w) => w.id == r.idWorkout), isNotEmpty);
      }
    },
  );

  group('settimana di partenza', () {
    final mia = [
      Slot(giorno: 1, fascia: 'Sera', sport: 'Corsa', durataMin: 30),
    ];

    test('chi installa ora parte da zero, non con quella di un altro', () {
      expect(settimanaDiPartenza(null, conPiano: false), isEmpty);
    });

    test('quella salvata resta sempre', () {
      expect(settimanaDiPartenza(mia, conPiano: true), mia);
      expect(settimanaDiPartenza([], conPiano: true), isEmpty);
    });

    test('chi aveva già un piano senza settimana salvata non la perde', () {
      expect(settimanaDiPartenza(null, conPiano: true), isNotEmpty);
    });
  });

  group('Prepara le sedute', () {
    Future<void> apri(WidgetTester tester, List<PianoRiga> piano) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      final state = AppState()..piano = piano;
      await tester.pumpWidget(
        MaterialApp(
          home: CreaPianoScreen(state: state, sportIniziale: 'Corsa'),
        ),
      );
      await tester.pump();
    }

    CheckboxListTile riga(WidgetTester tester, String testo) =>
        tester.widget<CheckboxListTile>(
          find.ancestor(
            of: find.textContaining(testo),
            matching: find.byType(CheckboxListTile),
          ),
        );

    testWidgets('sedute in calendario fuori dalla settimana: si può e parte '
        'già scelto', (tester) async {
      final data = soloData(DateTime.now()).add(const Duration(days: 1));
      await apri(tester, [
        PianoRiga(
          data: data,
          fascia: 'Mattina',
          sport: 'Corsa',
          tipo: 'Ritmo gara',
          durataMin: 68,
          note: notaAssistente,
        ),
      ]);
      final corsa = riga(tester, '1 seduta in calendario');
      expect(corsa.onChanged, isNotNull);
      expect(corsa.value, isTrue);
    });

    testWidgets('nessuna seduta: non c\'è niente da preparare', (tester) async {
      await apri(tester, const []);
      final corsa = riga(tester, 'Corsa · nessuna seduta');
      expect(corsa.onChanged, isNull);
    });
  });
}
