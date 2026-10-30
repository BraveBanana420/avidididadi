import 'package:allenamenti_app/invio_intervals.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutStep passo(
  int ordine,
  String fase,
  String descrizione, {
  String sport = 'Corsa',
  String serie = '',
  String rip = '',
  String metri = '',
  String minuti = '',
  String intensita = '',
  String recupero = '',
}) => WorkoutStep(
  id: 'w',
  sport: sport,
  nome: 'Ripetute',
  durataTot: 50,
  ordine: ordine,
  fase: fase,
  descrizione: descrizione,
  serie: serie,
  ripetizioni: rip,
  distanzaM: metri,
  durataMin: minuti,
  intensita: intensita,
  recuperoS: recupero,
  note: '',
);

void main() {
  final lun = DateTime(2026, 11, 2);
  final oggi = DateTime(2026, 10, 30);

  test(
    'corsa a ripetute: riscaldamento, blocco 5x con recupero, defaticamento',
    () {
      final testo = testoIcu('Corsa', [
        passo(
          1,
          'riscaldamento',
          'Corsa facile',
          minuti: '15',
          intensita: 'zona 2',
        ),
        passo(
          2,
          'principale',
          'Ripetute da 3 minuti',
          serie: '5',
          minuti: '3',
          intensita: 'zona 4',
          recupero: '120',
        ),
        passo(
          3,
          'defaticamento',
          'Corsa lenta',
          minuti: '10',
          intensita: 'zona 1',
        ),
      ]);
      expect(
        testo,
        'Warmup\n'
        '- Corsa facile 15m Z2 HR\n'
        '\n'
        'Principale 5x\n'
        '- Ripetute 3m Z4 HR\n'
        '- Recupero 120s Z1 HR\n'
        '\n'
        'Cooldown\n'
        '- Corsa lenta 10m Z1 HR',
      );
    },
  );

  test('nuoto: metri, passo per 100 m e pause a bordo vasca', () {
    final testo = testoIcu('Nuoto', [
      passo(
        1,
        'riscaldamento',
        'Stile libero facile',
        sport: 'Nuoto',
        metri: '200',
        recupero: '30',
      ),
      passo(
        2,
        'principale',
        'Stile libero sostenuto',
        sport: 'Nuoto',
        serie: '8',
        metri: '100',
        intensita: 'passo 1:56/100 m',
        recupero: '15',
      ),
    ]);
    expect(
      testo,
      contains('- Stile libero facile 200mtr\n- 30s intensity=rest'),
    );
    expect(
      testo,
      contains(
        'Principale 8x\n- Stile libero sostenuto 100mtr 1:56/100m Pace\n'
        '- 15s intensity=rest',
      ),
    );
  });

  test('quantità: minuti, secondi, km e tasto lap', () {
    expect(quantitaIcu(passo(1, '', '', minuti: '1,5')), '1m30');
    expect(quantitaIcu(passo(1, '', '', minuti: '0.5')), '30s');
    expect(quantitaIcu(passo(1, '', '', metri: '2500')), '2.5km');
    expect(quantitaIcu(passo(1, '', '', metri: '400')), '400mtr');
    expect(quantitaIcu(passo(1, '', '', rip: '20 s')), '20s');
    expect(quantitaIcu(passo(1, '', '', rip: '6')), 'Press lap');
    expect(obiettivoIcu('medio, respirazione regolare'), '');
  });

  test('evento: tipo, nome, data ed external_id; la forza non si manda', () {
    final s = SedutaDaInviare(
      data: lun,
      sport: 'Bici',
      tipo: 'Rulli',
      durataMin: 60,
      passi: const [],
    );
    final e = s.evento()!;
    expect(e['type'], 'VirtualRide');
    expect(e['name'], 'Bici: Rulli');
    expect(e['start_date_local'], '2026-11-02T00:00:00');
    expect(e['external_id'], 'avd-2026-11-02-bici');
    expect(e['description'], '- 60m');
    expect(e['moving_time'], 3600);
    expect(
      SedutaDaInviare(
        data: lun,
        sport: 'Corsa',
        tipo: 'Lungo',
        durataMin: 40,
        passi: const [],
        indice: 1,
      ).externalId,
      'avd-2026-11-02-corsa-2',
    );
    expect(
      SedutaDaInviare(
        data: lun,
        sport: 'Forza',
        tipo: 'A',
        durataMin: 45,
        passi: const [],
      ).evento(),
      isNull,
    );
  });

  test('cosa mandare: nuove, cambiate, tolte; il passato resta', () {
    SedutaDaInviare corsa(int min) => SedutaDaInviare(
      data: lun,
      sport: 'Corsa',
      tipo: 'Lungo',
      durataMin: min,
      passi: const [],
    );
    final firma = firmaDi(corsa(60).evento()!);
    final inviati = [
      EventoInviato('avd-2026-11-02-corsa', 11, lun, firma),
      EventoInviato('avd-2026-11-03-nuoto', 12, DateTime(2026, 11, 3), 'x'),
      EventoInviato('avd-2026-10-28-bici', 13, DateTime(2026, 10, 28), 'y'),
    ];
    // Uguale: niente da fare; il nuoto non c'è più e si toglie.
    var p = pianoInvio([corsa(60)], inviati, oggi);
    expect(p.nuovi, isEmpty);
    expect(p.daCancellare, [12]);
    // Cambiata la durata: si cancella la vecchia e si manda la nuova.
    p = pianoInvio([corsa(75)], inviati, oggi);
    expect(p.nuovi.single['moving_time'], 75 * 60);
    expect(p.daCancellare, [11, 12]);
    // Prima volta: tutto nuovo.
    p = pianoInvio([corsa(60)], const [], oggi);
    expect(p.nuovi.length, 1);
  });
}
