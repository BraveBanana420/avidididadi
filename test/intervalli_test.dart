import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gli intervalli di una nuotata vera (Garmin con "registro allenamento",
/// letta da intervals.icu): 200 + 4 × 50 + 4 × 200 = 1200 m.
void main() {
  Map<String, Object?> tratto(
    String tipo,
    int da,
    int a, [
    double? metri,
    int fc = 0,
  ]) => {
    'type': tipo,
    'start_time': da,
    'end_time': a,
    'elapsed_time': a - da,
    'moving_time': a - da,
    'distance': metri,
    'average_heartrate': fc,
  };

  final risposta = {
    'id': 'i208265343',
    'icu_intervals': [
      tratto('WORK', 0, 332, 200, 109),
      tratto('WORK', 332, 465, 50, 119),
      tratto('RECOVERY', 465, 517, null, 117),
      tratto('WORK', 517, 632, 50, 122),
      tratto('RECOVERY', 632, 648, null, 137),
      tratto('WORK', 648, 737, 50, 127),
      tratto('RECOVERY', 737, 758, null, 123),
      tratto('WORK', 758, 843, 50, 148),
      tratto('RECOVERY', 843, 909, null, 121),
      tratto('WORK', 909, 1203, 200, 117),
      tratto('RECOVERY', 1203, 1291, null, 123),
      tratto('WORK', 1291, 1596, 200, 144),
      tratto('RECOVERY', 1596, 1656, null, 133),
      tratto('WORK', 1656, 1961, 200, 148),
      tratto('RECOVERY', 1961, 2018, null, 138),
      tratto('WORK', 2018, 2363, 200, 136),
      tratto('RECOVERY', 2363, 2375, null, 139),
    ],
  };

  WorkoutStep passo(int ordine, String nome, int metri, {int serie = 1}) =>
      WorkoutStep(
        id: 'nuoto_2026-11-10',
        sport: 'Nuoto',
        nome: 'Tecnica',
        durataTot: 40,
        ordine: ordine,
        fase: 'principale',
        descrizione: nome,
        serie: '$serie',
        ripetizioni: '',
        distanzaM: '$metri',
        durataMin: '',
        intensita: '',
        recuperoS: '20',
        note: '',
      );

  final piano = [
    passo(1, 'Riscaldamento', 200),
    passo(2, 'Gambe con tavoletta', 50, serie: 4),
    passo(3, 'Stile libero', 200, serie: 3),
    passo(4, 'Defaticamento', 200),
  ];

  test('da intervals.icu: lavoro e recuperi, con metri, tempo e battito', () {
    final l = intervalliDaIcu(risposta);
    expect(l.length, 17);
    final lavoro = l.where((i) => !i.recupero).toList();
    expect(lavoro.length, 9);
    expect(lavoro.fold(0.0, (t, i) => t + i.metri), 1200);
    expect(
      rigaIntervallo(l.first, 'Nuoto'),
      '200 m · 5:32 · 2:46/100 m · FC 109',
    );
    expect(rigaIntervallo(l[2], 'Nuoto'), 'Recupero 0:52');
    expect(intervalliDaIcu({'icu_intervals': null}), isEmpty);
    expect(intervalliDaIcu('errore'), isEmpty);
  });

  test('i metri combaciano col programma: ogni tratto prende il suo nome', () {
    final l = conNomiDelPiano(intervalliDaIcu(risposta), piano);
    expect(l.where((i) => !i.recupero).map((i) => i.nome), [
      'Riscaldamento',
      'Gambe con tavoletta 1/4',
      'Gambe con tavoletta 2/4',
      'Gambe con tavoletta 3/4',
      'Gambe con tavoletta 4/4',
      'Stile libero 1/3',
      'Stile libero 2/3',
      'Stile libero 3/3',
      'Defaticamento',
    ]);
    expect(l.where((i) => i.recupero).every((i) => i.nome.isEmpty), isTrue);
  });

  test('un passo fatto in due tratti resta lo stesso passo', () {
    final spezzato = [
      const IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: 160,
        metri: 100,
      ),
      const IntervalloFatto(
        recupero: false,
        inizioS: 160,
        secondi: 170,
        metri: 100,
      ),
      const IntervalloFatto(
        recupero: false,
        inizioS: 330,
        secondi: 80,
        metri: 50,
      ),
    ];
    expect(conNomiDelPiano(spezzato, piano).map((i) => i.nome), [
      'Riscaldamento',
      'Riscaldamento',
      'Gambe con tavoletta 1/4',
    ]);
  });

  test('se non combacia ci si ferma: niente nomi sbagliati', () {
    final altro = [
      const IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: 330,
        metri: 200,
      ),
      const IntervalloFatto(
        recupero: false,
        inizioS: 330,
        secondi: 700,
        metri: 400,
      ),
      const IntervalloFatto(
        recupero: false,
        inizioS: 1030,
        secondi: 80,
        metri: 50,
      ),
    ];
    expect(conNomiDelPiano(altro, piano).map((i) => i.nome), [
      'Riscaldamento',
      '',
      '',
    ]);
    // Senza programma restano come sono.
    expect(
      conNomiDelPiano(altro, const []).every((i) => i.nome.isEmpty),
      isTrue,
    );
  });

  test('salvati e riletti restano uguali', () {
    final l = intervalliDaIcu(risposta);
    final r = intervalliDaCsv(intervalliCsv(l));
    expect(r.length, l.length);
    expect(
      r.map((i) => rigaIntervallo(i, 'Nuoto')),
      l.map((i) => rigaIntervallo(i, 'Nuoto')),
    );
    expect(fileIntervalli('icu-i208265343'), 'intervalli_icu_i208265343.csv');
  });

  test('corsa e bici: passo al km e velocità', () {
    const km = IntervalloFatto(
      recupero: false,
      inizioS: 0,
      secondi: 300,
      metri: 1000,
      fcMedia: 150,
    );
    expect(rigaIntervallo(km, 'Corsa'), '1,00 km · 5:00 · 5:00/km · FC 150');
    expect(passoIntervallo(km, 'Bici'), '12,0 km/h');
  });

  test('tornando nell\'app si risincronizza, ma non a ogni cambio di app', () {
    final ora = DateTime(2026, 11, 10, 14);
    expect(daRisincronizzare(null, ora), isFalse); // avvio ancora in corso
    expect(
      daRisincronizzare(ora.subtract(const Duration(minutes: 2)), ora),
      isFalse,
    );
    expect(
      daRisincronizzare(ora.subtract(const Duration(minutes: 40)), ora),
      isTrue,
    );
  });
}
