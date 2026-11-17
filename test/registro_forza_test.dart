import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/registro_forza.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lun = DateTime(2026, 10, 26);
  final gio = DateTime(2026, 10, 29);

  SerieFatta s(
    DateTime d,
    int n,
    int rip,
    double kg, [
    String id = 'Rematore',
  ]) => SerieFatta(
    data: d,
    esercizio: id,
    nome: 'Rematore con manubrio',
    serie: n,
    ripetizioni: rip,
    kg: kg,
  );

  test('ripetizioni previste e peso dalle note del piano', () {
    expect(ripetizioniPreviste('8-10'), (8, 10));
    expect(ripetizioniPreviste('12'), (12, 12));
    expect(ripetizioniPreviste('10 per lato'), (10, 10));
    expect(ripetizioniPreviste('45 s'), isNull);
    expect(ripetizioniPreviste('max'), isNull);
    expect(kgDalleNote('Peso: circa 12,5 kg. Settimana 2: …'), 12.5);
    expect(kgDalleNote('Parti con la sola barra'), isNull);
  });

  test('si salva e si rilegge dal CSV, anche a corpo libero', () {
    final righe = [s(lun, 1, 8, 22.5), s(lun, 2, 10, 0, 'Pushups')];
    final csv = toCsv([serieHeader, ...righe.map((x) => x.toRow())]);
    final t = Tabella.da(csv)!;
    final lette = t.righe.map((r) => SerieFatta.da(t, r)).toList();
    expect(lette[0]!.kg, 22.5);
    expect(lette[0]!.data, lun);
    expect(lette[1]!.kg, 0);
    expect(lette[1]!.ripetizioni, 10);
  });

  test('ultima volta, record e testo delle serie', () {
    final tutte = [
      s(lun, 1, 10, 20),
      s(lun, 2, 10, 20),
      s(lun, 3, 10, 20),
      s(gio, 1, 8, 22.5),
      s(gio, 2, 8, 22.5),
      s(gio, 3, 7, 22.5),
    ];
    final ultima = ultimaVolta(tutte, 'Rematore');
    expect(ultima.map((x) => x.ripetizioni), [8, 8, 7]);
    expect(fmtSerie(ultima), '8, 8, 7 a 22,5 kg');
    expect(
      fmtSerie(ultimaVolta(tutte, 'Rematore', prima: gio)),
      '3 × 10 a 20 kg',
    );
    expect(recordDi(tutte, 'Rematore')!.kg, 22.5);
    expect(recordDi(tutte, 'Rematore')!.ripetizioni, 8);
    expect(ultimaVolta(tutte, 'Squat'), isEmpty);
    // A lunedì tutte le 10 ripetizioni: pronto ad aumentare; giovedì no.
    expect(
      prontoPerAumentare(ultimaVolta(tutte, 'Rematore', prima: gio), 10),
      isTrue,
    );
    expect(prontoPerAumentare(ultima, 10), isFalse);
  });

  test('proposta: seduta in corso, poi ultima volta, poi piano', () {
    final ultima = [s(lun, 1, 10, 20), s(lun, 2, 9, 20)];
    expect(
      proposta(
        serie: 2,
        previste: (8, 10),
        ultima: ultima,
        precedente: (9, 22),
      ),
      (9, 22.0),
    );
    expect(proposta(serie: 2, previste: (8, 10), ultima: ultima), (8, 20.0));
    expect(proposta(serie: 4, previste: (8, 10), ultima: ultima), (8, 20.0));
    expect(
      proposta(serie: 1, previste: (8, 10), ultima: const [], kgPiano: 12.5),
      (8, 12.5),
    );
  });

  test('i blocchi sanno quale serie sono', () {
    final b = blocchiDa([
      const WorkoutStep(
        id: 'w',
        sport: 'Forza',
        nome: 'Forza A',
        durataTot: 0,
        ordine: 1,
        fase: 'principale',
        descrizione: 'Rematore',
        serie: '3',
        ripetizioni: '8-10',
        distanzaM: '',
        durataMin: '',
        intensita: '',
        recuperoS: '90',
        note: '',
      ),
    ]);
    final lavoro = b.where((x) => x.tipo == TipoBlocco.lavoro).toList();
    expect(lavoro.map((x) => x.serie), [1, 2, 3]);
    expect(lavoro.first.ripetizioni, '8-10');
  });

  group('serie scritte a mano', () {
    final giorno = DateTime(2026, 11, 8, 18, 30);

    test('numerate da 1, senza le serie vuote', () {
      final serie = serieDaEsercizi(giorno, [
        (
          esercizio: 'panca_piana',
          nome: 'Panca piana',
          aTempo: false,
          serie: [(10, 60.0), (0, 60.0), (8, 62.5)],
        ),
        (
          esercizio: '',
          nome: 'Trazioni',
          aTempo: false,
          serie: [(6, 0.0), (5, -3.0)],
        ),
      ]);
      expect(
        serie.map(
          (s) => '${s.nome} ${s.serie}: ${s.ripetizioni}x${fmtKg(s.kg)}',
        ),
        [
          'Panca piana 1: 10x60',
          'Panca piana 2: 8x62,5',
          'Trazioni 1: 6x0',
          'Trazioni 2: 5x0',
        ],
      );
      expect(serie.every((s) => s.data == DateTime(2026, 11, 8)), isTrue);
    });

    test('andata e ritorno: gli esercizi si riaprono come erano', () {
      final serie = serieDaEsercizi(giorno, [
        (
          esercizio: 'squat',
          nome: 'Squat',
          aTempo: false,
          serie: [(5, 100.0), (5, 100.0)],
        ),
        (
          esercizio: '',
          nome: 'Plank laterale',
          aTempo: false,
          serie: [(3, 0.0)],
        ),
      ]);
      final e = eserciziDaSerie(serie.reversed.toList());
      expect(e.map((x) => x.nome).toSet(), {'Squat', 'Plank laterale'});
      expect(e.firstWhere((x) => x.nome == 'Squat').serie, [
        (5, 100.0),
        (5, 100.0),
      ]);
    });
  });

  group('serie a tempo', () {
    final giorno = DateTime(2026, 11, 8);

    test('il tempo si scrive come viene', () {
      expect(parseSecondi('45'), 45);
      expect(parseSecondi('45 s'), 45);
      expect(parseSecondi('1:30'), 90);
      expect(parseSecondi("1'05"), 65);
      expect(parseSecondi(''), isNull);
      expect(parseSecondi('0'), isNull);
      expect(parseSecondi('tanto'), isNull);
      expect(fmtSecondi(45), '45 s');
      expect(fmtSecondi(90), '1:30');
    });

    test('plank: secondi al posto di ripetizioni e kg', () {
      final serie = serieDaEsercizi(giorno, [
        (
          esercizio: '',
          nome: 'Plank',
          aTempo: true,
          serie: [(60, 10.0), (45, 0.0), (0, 0.0)],
        ),
      ]);
      expect(serie.length, 2);
      expect(
        serie.every((s) => s.aTempo && s.ripetizioni == 0 && s.kg == 0),
        isTrue,
      );
      expect(fmtSerie(serie), '1:00, 45 s');
      expect(recordDi(serie, 'Plank')!.secondi, 60);
      final e = eserciziDaSerie(serie).single;
      expect(e.aTempo, isTrue);
      expect(e.serie, [(60, 0.0), (45, 0.0)]);
    });

    test('nel CSV: colonna in fondo, le righe vecchie restano buone', () {
      final plank = SerieFatta(
        data: giorno,
        esercizio: '',
        nome: 'Plank',
        serie: 1,
        ripetizioni: 0,
        secondi: 45,
      );
      expect(serieHeader.last, 'secondi');
      final t = Tabella({for (final (i, c) in serieHeader.indexed) c: i}, []);
      final letta = SerieFatta.da(t, plank.toRow())!;
      expect(letta.secondi, 45);
      expect(fmtSerie([letta, letta]), '2 × 45 s');
      // Riga di prima, senza la colonna dei secondi.
      final vecchia = SerieFatta.da(
        Tabella({
          for (final (i, c) in serieHeader.sublist(0, 6).indexed) c: i,
        }, []),
        ['2026-11-01', 'squat', 'Squat', '1', '5', '100'],
      )!;
      expect(vecchia.aTempo, isFalse);
      expect(vecchia.kg, 100);
    });
  });
}
