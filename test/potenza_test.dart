import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/invio_intervals.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/potenza.dart';
import 'package:allenamenti_app/screens/profilo_allenamento.dart';
import 'package:allenamenti_app/sensori_bici.dart';
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

    test('watt e % scritti a mano vanno così come sono', () {
      expect(obiettivoPotenzaIcu('200-220 W'), '200-220w');
      expect(obiettivoPotenzaIcu('110-115%'), '110-115%');
      expect(obiettivoPotenzaIcu('niente'), isNull);
    });
  });

  group('ERG', () {
    test('i watt di un passo: watt, % dell\'FTP, zona, recupero', () {
      expect(rangeWatt('200-220 W', zp), (200, 220));
      expect(rangeWatt('250w', zp), (250, 250));
      expect(rangeWatt('105-110%', zp), (210, 220));
      expect(rangeWatt('75% FTP', zp), (150, 150));
      expect(rangeWatt('zona 4', zp), (181, 210));
      expect(rangeWatt('Z2', zp), (111, 150));
      expect(rangeWatt('zona 1', zp), (90, 110));
      expect(rangeWatt('', zp, recupero: true), (90, 110));
      expect(rangeWatt('Pedalata libera', zp), isNull);
    });

    test('il rullo tiene il centro del range, a passi di 5 W', () {
      expect(wattErg((181, 210)), 195);
      expect(wattErg((181, 210), scala: 0.95), 185);
      expect(wattErg((200, 200), scala: 1.05), 210);
    });

    test('fuori dal range: avviso sopra; sotto solo nei passi duri', () {
      expect(versoRange(230, (181, 210), zp), 1);
      expect(versoRange(170, (181, 210), zp), -1);
      expect(versoRange(80, (111, 150), zp), 0);
      expect(fraseRange(230, (181, 210), 1), '230 watt, scendi sotto 210.');
    });

    test('le % del piano mostrano anche i watt', () {
      expect(conWatt('88-94%', zp, fc), '88-94% (176-188 W)');
      expect(conWatt('Ripetute al 105% FTP', zp, fc), contains('(210 W)'));
    });

    test('comandi per il rullo (FTMS)', () {
      expect(comandoWatt(195), [0x05, 195, 0]);
      expect(comandoWatt(300), [0x05, 0x2C, 0x01]);
      expect(comandoWatt(-10), [0x05, 0, 0]);
      expect(esitoComando([0x80, 0x05, 0x01], 0x05), isTrue);
      expect(esitoComando([0x80, 0x00, 0x05], 0x00), isFalse); // rifiutato
      expect(esitoComando([0x80, 0x07, 0x01], 0x05), isNull);
      expect(esitoComando([0x01], 0x05), isNull);
    });

    test('diagramma: una barra per blocco, recuperi compresi', () {
      final blocchi = blocchiDa([
        passoBici(
          1,
          'riscaldamento',
          'Agile',
          minuti: '10',
          intensita: 'zona 2',
        ),
        passoBici(
          2,
          'principale',
          'Ripetute',
          serie: '3',
          minuti: '4',
          intensita: '105-110%',
          recupero: '120',
        ),
      ]);
      final barre = barreDa(blocchi, zp);
      expect(barre.map((b) => b.secondi), [600, 240, 120, 240, 120, 240]);
      expect(barre.first.range, (111, 150));
      expect(barre[1].range, (210, 220));
      expect(barre[2].range, (90, 110)); // recupero facile
    });
  });

  group('obiettivo secondario', () {
    test('quello che si scrive nel builder', () {
      expect(obiettivoWatt('200'), '200 W');
      expect(obiettivoWatt('190 - 210'), '190-210 W');
      expect(obiettivoWatt('200w'), '200 W');
      expect(obiettivoWatt('88-94%'), '88-94%');
      expect(obiettivoWatt('tanto'), '');
      expect(normalizzaSecondario('85-90', 'Bici'), '85-90 rpm');
      expect(normalizzaSecondario('85–90 rpm', 'Bici'), '85-90 rpm');
      expect(normalizzaSecondario('175', 'Corsa'), '175 ppm');
      expect(normalizzaSecondario('140-150 bpm', 'Bici'), '140-150 bpm');
      expect(normalizzaSecondario('', 'Bici'), '');
    });

    test('i watt scritti non hanno bisogno dell\'FTP', () {
      expect(rangeWattScritti('200 W'), (200, 200));
      expect(rangeWattScritti('190-210 W'), (190, 210));
      expect(rangeWattScritti('zona 2'), isNull);
      expect(rangeWattScritti('88-94%'), isNull);
      expect(intensitaInWatt('200 W'), isTrue);
      expect(intensitaInWatt('88-94%'), isTrue);
      expect(intensitaInWatt('zona 2'), isFalse);
    });

    test('cadenza: dentro, fuori e ruota libera', () {
      const r = (85, 90);
      expect(rangeCadenza('85-90 rpm'), r);
      expect(rangeCadenza('90 rpm'), (90, 90));
      expect(rangeCadenza('140-150 bpm'), isNull);
      expect(versoCadenza(88, r), 0);
      expect(versoCadenza(83, r), 0); // dentro il margine
      expect(versoCadenza(80, r), -1);
      expect(versoCadenza(95, r), 1);
      expect(versoCadenza(0, r), 0);
      expect(fraseCadenza(80, r, -1), 'Cadenza 80, sali sopra 85.');
    });

    test('200 W e 85-90 rpm arrivano a intervals.icu, anche senza FTP', () {
      final p = WorkoutStep(
        id: 'w',
        sport: 'Bici',
        nome: 'Prova',
        durataTot: 10,
        ordine: 1,
        fase: 'principale',
        descrizione: 'Costante',
        serie: '',
        ripetizioni: '',
        distanzaM: '',
        durataMin: '10',
        intensita: '200 W',
        recuperoS: '',
        note: '',
        obiettivo2: '85-90 rpm',
      );
      expect(testoIcu('Bici', [p]), contains('10m 200w 85-90rpm'));
      // Un secondario che non è una cadenza non si manda.
      expect(obiettivo2Icu('140-150 bpm'), '');
      // E nel CSV resta.
      expect(
        WorkoutStep.da(
          Tabella({for (final (k, c) in workoutHeader.indexed) c: k}, const []),
          p.toRow(),
        )!.obiettivo2,
        '85-90 rpm',
      );
    });

    test('righe vecchie senza la colonna nuova: restano leggibili', () {
      final vecchia = [...workoutHeader]..remove('obiettivo_2');
      final t = Tabella.da(
        toCsv([
          vecchia,
          [
            for (final c in vecchia)
              c == 'id_workout' ? 'w' : (c == 'ordine' ? '1' : ''),
          ],
        ]),
      )!;
      expect(WorkoutStep.da(t, t.righe.single)!.obiettivo2, '');
    });
  });

  group('FTP di corsa', () {
    test('cinque zone sue, separate da quelle della bici', () {
      const c = ZonePotenza.corsa(300);
      expect(c.numero, 5);
      expect(
        [for (var n = 1; n <= 5; n++) c.testo(n)],
        ['fino a 240 W', '241-270 W', '271-300 W', '301-345 W', 'oltre 345 W'],
      );
      expect(c.zonaDi(250), 2);
      expect(c.zonaDi(500), 5);
      expect(c.colori, hasLength(5));
      expect(const ZonePotenza(214).numero, 7);
    });

    test('tempo nelle zone: conta le zone della corsa', () {
      final z = tempoNelleZonePotenza([
        for (var s = 0; s < 61; s++)
          Campione(t0.add(Duration(seconds: s)), 280),
      ], const ZonePotenza.corsa(300));
      expect(z.keys, [1, 2, 3, 4, 5]);
      expect(z[3]!.inSeconds, 60);
    });

    test('la stima: peso, età e sesso; senza peso niente', () {
      expect(stimaFtpCorsa(pesoKg: 70, eta: 30, sesso: 'Uomo'), 259);
      expect(stimaFtpCorsa(pesoKg: 60, eta: 30, sesso: 'Donna'), 192);
      // Con gli anni cala, ma poco.
      expect(stimaFtpCorsa(pesoKg: 70, eta: 55, sesso: 'Uomo'), 223);
      expect(stimaFtpCorsa(pesoKg: 70), 242);
      expect(stimaFtpCorsa(eta: 30, sesso: 'Uomo'), isNull);
      expect(stimaFtpCorsa(pesoKg: 5), isNull);
    });

    test('la soglia dal test: 95% dei migliori 20 minuti', () {
      // 10 minuti facili a 200 W, 20 a 300 W, 10 a 200 W.
      final prova = [
        for (var s = 0; s < 2400; s++)
          Campione(
            t0.add(Duration(seconds: s)),
            s >= 600 && s < 1800 ? 300 : 200,
          ),
      ];
      expect(migliorePotenza(prova, const Duration(minutes: 20)), 300);
      expect(sogliaDaVenti(prova), 285);
    });

    test('corsa troppo corta o una sosta lunga', () {
      final corta = [
        for (var s = 0; s < 600; s++)
          Campione(t0.add(Duration(seconds: s)), 300),
      ];
      expect(sogliaDaVenti(corta), isNull);
      // 10 minuti, 10 fermi senza dati, altri 10: la sosta abbassa la media.
      final conSosta = [
        ...corta,
        for (var s = 1200; s < 1800; s++)
          Campione(t0.add(Duration(seconds: s)), 300),
      ];
      expect(
        migliorePotenza(conSosta, const Duration(minutes: 20)),
        lessThan(160),
      );
    });

    test('il test ha i 20 minuti al massimo, nel player', () {
      final b = blocchiDa(passiTestFtpCorsa('w'));
      expect(b.where((x) => x.secondi == 1200), hasLength(1));
      expect(b.first.secondi, 900);
      expect(b.last.secondi, 600);
    });

    test('da intervals.icu: l\'FTP giusto per ogni sport', () {
      final atleta = {
        'sportSettings': [
          {
            'types': ['Run', 'VirtualRun'],
            'ftp': 280,
          },
          {
            'types': ['Ride'],
            'ftp': 214,
          },
        ],
      };
      expect(ftpDaAtletaIcu(atleta), 214);
      expect(ftpDaAtletaIcu(atleta, tipo: 'Run'), 280);
    });
  });
}
