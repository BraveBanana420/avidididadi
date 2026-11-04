import 'package:allenamenti_app/invio_intervals.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/potenza.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutStep passoBici(
  int ordine,
  String fase,
  String descrizione, {
  String serie = '',
  String minuti = '',
  String intensita = '',
  String recupero = '',
}) => WorkoutStep(
  id: 'w',
  sport: 'Bici',
  nome: 'Intervalli · 60 min',
  durataTot: 60,
  ordine: ordine,
  fase: fase,
  descrizione: descrizione,
  serie: serie,
  ripetizioni: '',
  distanzaM: '',
  durataMin: minuti,
  intensita: intensita,
  recuperoS: recupero,
  note: '',
);

void main() {
  const zp = ZonePotenza(200);
  const fc = Zone(fcMax: 190);
  final t0 = DateTime(2026, 11, 4, 18);

  group('zone di potenza', () {
    test('FTP 200 W: i sette range di Coggan', () {
      expect(
        [for (var n = 1; n <= 7; n++) zp.testo(n)],
        [
          'fino a 110 W',
          '111-150 W',
          '151-180 W',
          '181-210 W',
          '211-240 W',
          '241-300 W',
          'oltre 300 W',
        ],
      );
    });

    test('in che zona cade una potenza', () {
      expect(zp.zonaDi(0), 1);
      expect(zp.zonaDi(110), 1);
      expect(zp.zonaDi(111), 2);
      expect(zp.zonaDi(205), 4);
      expect(zp.zonaDi(900), 7);
    });

    test('in bici la zona del piano mostra watt e battito', () {
      expect(conWatt('zona 2', zp, fc), 'zona 2 (111-150 W · 114-132 bpm)');
      expect(conWatt('zona 1', zp, fc), startsWith('zona 1 (fino a 110 W'));
      // Senza FTP restano i battiti, come prima.
      expect(conWatt('zona 2', null, fc), 'zona 2 (114-132 bpm)');
      // Negli altri sport solo i battiti.
      expect(intensitaCon('zona 2', 'Corsa', zp, fc), 'zona 2 (114-132 bpm)');
    });
  });

  group('avvisi', () {
    test('sopra il tetto avvisa; nel fondo andare piano va bene', () {
      expect(versoPotenza(140, 2, zp), 0);
      expect(versoPotenza(100, 2, zp), 0); // sotto la Z2: va bene lo stesso
      expect(versoPotenza(160, 2, zp), 1);
      expect(versoPotenza(152, 2, zp), 0); // dentro il margine del 3%
      expect(versoPotenza(170, 4, zp), -1);
      expect(versoPotenza(195, 4, zp), 0);
    });

    test('la frase dice il limite da rispettare', () {
      expect(frasePotenza(160, 2, 1, zp), '160 watt, scendi sotto 150.');
      expect(frasePotenza(170, 4, -1, zp), '170 watt, sali sopra 181.');
    });

    test('media degli ultimi 3 secondi', () {
      final serie = [
        Campione(t0, 400),
        Campione(t0.add(const Duration(seconds: 1)), 200),
        Campione(t0.add(const Duration(seconds: 2)), 210),
        Campione(t0.add(const Duration(seconds: 3)), 220),
      ];
      expect(
        mediaRecente(serie, t0.add(const Duration(milliseconds: 3500))),
        210,
      );
      // Sensore muto da più di 3 secondi: niente valore vecchio.
      expect(mediaRecente(serie, t0.add(const Duration(seconds: 10))), isNull);
    });
  });

  group('riepilogo', () {
    // 10 minuti a 150 W e 5 a 250 W, un campione al secondo.
    final serie = [
      for (var s = 0; s < 900; s++)
        Campione(t0.add(Duration(seconds: s)), s < 600 ? 150 : 250),
    ];

    test('tempo nelle zone', () {
      final z = tempoNelleZonePotenza(serie, zp);
      expect(z[2]!.inSeconds, 600);
      expect(z[6]!.inSeconds, 299);
      expect(z[4], Duration.zero);
    });

    test('la normalizzata pesa di più i tratti duri', () {
      final np = potenzaNormalizzata(serie)!;
      expect(media(serie).round(), 183);
      expect(np, greaterThan(190));
      expect(np, lessThan(250));
      // Potenza costante: normalizzata = media.
      final piatta = [
        for (var s = 0; s < 300; s++)
          Campione(t0.add(Duration(seconds: s)), 180),
      ];
      expect(potenzaNormalizzata(piatta), 180);
      expect(potenzaNormalizzata(serie.take(30).toList()), isNull);
    });

    test('le serie dell\'app si salvano e si rileggono', () {
      final s = SerieSessione(
        fc: [
          Campione(t0, 132),
          Campione(t0.add(const Duration(seconds: 1)), 133),
        ],
        potenza: [Campione(t0, 180)],
        cadenza: [Campione(t0, 88.4)],
      );
      final letta = serieAppDa(serieAppCsv(s));
      expect(letta.fc.map((c) => c.v), [132, 133]);
      expect(letta.potenza.single.v, 180);
      expect(letta.potenza.single.t, t0);
      expect(letta.cadenza.single.v, 88);
      expect(
        fileSerieApp(DateTime(2026, 11, 4), 'Bici'),
        'serie_app_2026_11_04_bici.csv',
      );
      expect(
        RegExp(r'^[a-z0-9_]+\.csv$').hasMatch(fileSerieApp(t0, 'Bici')),
        isTrue,
      );
    });

    test('valori impossibili nel file si scartano', () {
      final letta = serieAppDa(
        'tempo_ms,fc,potenza,cadenza\n1,NaN,99999,-5\n2,140,,\nx,1,1,1\n',
      );
      expect(letta.fc.single.v, 140);
      expect(letta.potenza, isEmpty);
      expect(letta.cadenza, isEmpty);
    });
  });

  group('intervals.icu', () {
    test('FTP dal profilo dell\'atleta', () {
      expect(
        ftpDaAtletaIcu({
          'sportSettings': [
            {
              'types': ['Run', 'VirtualRun'],
              'ftp': 300,
            },
            {
              'types': ['Ride', 'VirtualRide', 'GravelRide'],
              'ftp': 235,
            },
          ],
        }),
        235,
      );
      expect(ftpDaAtletaIcu({'sportSettings': []}), isNull);
      expect(
        ftpDaAtletaIcu({
          'sportSettings': [
            {
              'types': ['Ride'],
              'ftp': 0,
            },
          ],
        }),
        isNull,
      );
      expect(ftpDaAtletaIcu('niente'), isNull);
    });

    test('con l\'FTP la bici va su Garmin con gli obiettivi in % FTP', () {
      final passi = [
        passoBici(
          1,
          'riscaldamento',
          'Pedalata agile',
          minuti: '15',
          intensita: 'zona 2',
        ),
        passoBici(
          2,
          'principale',
          'Ripetute in salita o in pianura',
          serie: '4',
          minuti: '6',
          intensita: 'zona 4',
          recupero: '180',
        ),
        passoBici(
          3,
          'defaticamento',
          'Pedalata sciolta',
          minuti: '10',
          intensita: 'zona 1',
        ),
      ];
      expect(
        testoIcu('Bici', passi, potenza: true),
        'Warmup\n'
        '- Pedalata agile 15m 56-75%\n'
        '\n'
        'Principale 4x\n'
        '- Ripetute in salita o in pianura 6m 91-105%\n'
        '- Recupero 180s 40-55%\n'
        '\n'
        'Cooldown\n'
        '- Pedalata sciolta 10m 40-55%',
      );
      // Senza FTP restano le zone di battito.
      expect(testoIcu('Bici', passi), contains('15m Z2 HR'));
      // La corsa non cambia anche con l'FTP.
      expect(
        testoIcu('Corsa', [
          passoBici(
            1,
            'principale',
            'Corsa',
            minuti: '30',
            intensita: 'zona 2',
          ),
        ], potenza: true),
        contains('Z2 HR'),
      );
    });
  });
}
