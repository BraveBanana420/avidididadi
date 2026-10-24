import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter_test/flutter_test.dart';

const freeletics = 'com.freeletics.lite';

DateTime ora(int h, int m) => DateTime(2026, 10, 15, h, m);

RecordHc record(
  String uuid,
  String tipo, {
  String pacchetto = pacchettoGarmin,
  DateTime? inizio,
  DateTime? fine,
  double? distanzaM,
  double? calorie,
}) => RecordHc(
  uuid: uuid,
  tipo: tipo,
  pacchetto: pacchetto,
  nomeFonte: nomeFonte(pacchetto, ''),
  inizio: inizio ?? ora(7, 0),
  fine: fine ?? ora(7, 45),
  distanzaM: distanzaM,
  calorie: calorie,
);

Sessione sessione(RecordHc r, [MetricheHc m = const MetricheHc()]) =>
    sessioneDa(r, m)!;

void main() {
  group('tipi di attività', () {
    test('corsa, bici, nuoto e forza diventano gli sport dell\'app', () {
      expect(mappaAttivita('RUNNING'), ('Corsa', 'Corsa'));
      expect(mappaAttivita('RUNNING_TREADMILL'), ('Corsa', 'Tapis roulant'));
      expect(mappaAttivita('BIKING'), ('Bici', 'Uscita'));
      expect(mappaAttivita('BIKING_STATIONARY'), ('Bici', 'Cyclette'));
      expect(mappaAttivita('SWIMMING_POOL'), ('Nuoto', 'Piscina'));
      expect(mappaAttivita('SWIMMING_OPEN_WATER'), ('Nuoto', 'Acque libere'));
      expect(mappaAttivita('STRENGTH_TRAINING')!.$1, 'Forza');
      expect(mappaAttivita('WEIGHTLIFTING')!.$1, 'Forza');
      expect(mappaAttivita('HIGH_INTENSITY_INTERVAL_TRAINING'), (
        'Forza',
        'HIIT',
      ));
      expect(mappaAttivita('CALISTHENICS')!.$1, 'Forza');
    });

    test('camminata, escursionismo e altro sono ignorati', () {
      expect(mappaAttivita('WALKING'), isNull);
      expect(mappaAttivita('HIKING'), isNull);
      expect(mappaAttivita('OTHER'), isNull);
      expect(sessioneDa(record('w', 'WALKING'), const MetricheHc()), isNull);
    });

    test(
      'il Cardio indoor di Garmin (OTHER) è forza, OTHER di altre app no',
      () {
        expect(mappaAttivita('OTHER', pacchetto: pacchettoGarmin), (
          'Forza',
          'Cardio',
        ));
        expect(mappaAttivita('OTHER', pacchetto: 'com.altra.app'), isNull);
      },
    );

    test('il titolo Garmin dà il nome e il tipo della corsa', () {
      Sessione con(String titolo) =>
          sessione(record('t', 'RUNNING').conTitolo(titolo));
      expect(con('Pistoia - Fartlek FC').tipo, 'Fartlek');
      expect(con('Pistoia - Tempo Run FC').tipo, 'Tempo run');
      expect(con('Artemisio - Lento 7km').tipo, 'Lento');
      expect(con('Brescia Corsa').tipo, 'Corsa');
      expect(con('Pistoia - Fartlek FC').note, 'Pistoia - Fartlek FC');
      // Per gli altri sport il tipo resta quello dell'attività.
      expect(
        sessione(record('n', 'SWIMMING_POOL').conTitolo('Piscina Base')).tipo,
        'Piscina',
      );
    });

    test('senza titolo la corsa prende il tipo previsto dal piano', () {
      final corsa = sessione(record('c', 'RUNNING'));
      final piano = [
        PianoRiga(
          data: DateTime(2026, 10, 15),
          fascia: 'Mattina',
          sport: 'Corsa',
          tipo: 'Fartlek',
        ),
      ];
      expect(conTipoDalPiano([corsa], piano).single.tipo, 'Fartlek');
      // Il titolo scritto dall'app vince sul piano.
      final conTitolo = sessione(
        record('t', 'RUNNING').conTitolo('Pistoia - Tempo Run'),
      );
      expect(conTipoDalPiano([conTitolo], piano).single.tipo, 'Tempo run');
      // Nessun programma quel giorno: resta Corsa.
      expect(conTipoDalPiano([corsa], []).single.tipo, 'Corsa');
    });

    test('Freeletics è forza anche con un tipo generico', () {
      expect(mappaAttivita('OTHER', pacchetto: freeletics)!.$1, 'Forza');
    });

    test('nomi leggibili delle fonti', () {
      expect(nomeFonte(pacchettoGarmin, ''), 'Garmin');
      expect(nomeFonte(freeletics, ''), 'Freeletics');
      expect(nomeFonte('com.altra.app', 'Altra app'), 'Altra app');
    });
  });

  group('metriche nella finestra della sessione', () {
    final r = record('c1', 'RUNNING');

    test('FC media e massima solo dai campioni dentro la sessione', () {
      final s = sessione(
        r,
        MetricheHc(
          fc: [
            CampioneHc(ora(6, 50), ora(6, 50), 180), // prima: esclusa
            CampioneHc(ora(7, 5), ora(7, 5), 130),
            CampioneHc(ora(7, 20), ora(7, 20), 150),
            CampioneHc(ora(7, 40), ora(7, 40), 170),
            CampioneHc(ora(8, 0), ora(8, 0), 190), // dopo: esclusa
          ],
        ),
      );
      expect(s.fcMedia, 150);
      expect(s.fcMax, 170);
    });

    test(
      'distanza e calorie a intervalli contano solo per la parte dentro',
      () {
        final s = sessione(
          r,
          MetricheHc(
            // 1 km a cavallo dell'inizio (metà dentro) + 5 km dentro.
            distanza: [
              CampioneHc(ora(6, 55), ora(7, 5), 1000),
              CampioneHc(ora(7, 5), ora(7, 45), 5000),
            ],
            calorieAttive: [CampioneHc(ora(7, 0), ora(7, 45), 450)],
            passi: [CampioneHc(ora(7, 0), ora(7, 45), 6000)],
          ),
        );
        expect(s.distanzaKm, 5.5);
        expect(s.calorieAttive, 450);
        expect(s.passi, 6000);
      },
    );

    test('i totali scritti dall\'app hanno la precedenza', () {
      final s = sessione(
        record('c2', 'RUNNING', distanzaM: 7020, calorie: 520),
        MetricheHc(distanza: [CampioneHc(ora(7, 0), ora(7, 45), 6000)]),
      );
      expect(s.distanzaKm, 7.02);
      expect(s.calorieTotali, 520);
    });

    test('id, giorno, durata, fonte e orari', () {
      final s = sessione(r);
      expect(s.id, 'hc-c1');
      expect(s.data, DateTime(2026, 10, 15));
      expect(s.durataMin, 45);
      expect(s.fonte, 'Garmin');
      expect(s.origine, pacchettoGarmin);
      expect(s.inizio, ora(7, 0));
      expect(s.fine, ora(7, 45));
    });
  });

  group('doppioni e modifiche', () {
    final corsa = sessione(record('c1', 'RUNNING'));

    test('sincronizzare due volte lo stesso record non crea doppioni', () {
      var hc = applicaModifiche([], aggiornate: [corsa]);
      hc = applicaModifiche(hc, aggiornate: [corsa]);
      expect(hc.length, 1);
    });

    test('un record modificato sostituisce quello salvato', () {
      final modificata = sessione(record('c1', 'RUNNING', distanzaM: 8000));
      final hc = applicaModifiche([corsa], aggiornate: [modificata]);
      expect(hc.single.distanzaKm, 8);
    });

    test('un record cancellato in Health Connect esce', () {
      final altra = sessione(record('c2', 'BIKING'));
      final hc = applicaModifiche([corsa, altra], cancellati: {'c1'});
      expect(hc.map((s) => s.id), ['hc-c2']);
    });

    test(
      'la sessione del CSV che arriva anche da Health Connect è sostituita',
      () {
        final csv = Sessione(
          id: '20261015-corsa-1',
          data: DateTime(2026, 10, 15),
          sport: 'Corsa',
          durataMin: 44, // entro 3 minuti
          fonte: 'Garmin',
        );
        expect(combina([csv], [corsa]).map((s) => s.id), ['hc-c1']);
      },
    );

    test('il CSV resta se sport, giorno o durata non coincidono', () {
      final diversa = Sessione(
        id: '20261015-corsa-2',
        data: DateTime(2026, 10, 15),
        sport: 'Corsa',
        durataMin: 20,
      );
      final altroGiorno = Sessione(
        id: '20261014-corsa-1',
        data: DateTime(2026, 10, 14),
        sport: 'Corsa',
        durataMin: 45,
      );
      expect(combina([diversa, altroGiorno], [corsa]).length, 3);
    });

    test(
      "la seduta segnata dall'app lascia il posto a quella dell'orologio",
      () {
        final dallApp = Sessione(
          id: 'app-2026-10-15-corsa',
          data: DateTime(2026, 10, 15),
          sport: 'Corsa',
          durataMin: 30, // durata diversa dal Garmin: conta lo stesso
          fonte: fonteApp,
        );
        expect(combina([dallApp], [corsa]).map((s) => s.id), ['hc-c1']);
      },
    );

    test(
      'Freeletics e Garmin sullo stesso allenamento diventano una sessione',
      () {
        final daFreeletics = sessione(
          record('f1', 'CALISTHENICS', pacchetto: freeletics, fine: ora(7, 30)),
          const MetricheHc(),
        );
        final dalGarmin = sessione(
          record(
            'g1',
            'HIGH_INTENSITY_INTERVAL_TRAINING',
            inizio: ora(7, 2),
            fine: ora(7, 33),
          ),
          MetricheHc(
            fc: [CampioneHc(ora(7, 10), ora(7, 10), 128)],
            calorieAttive: [CampioneHc(ora(7, 2), ora(7, 33), 310)],
          ),
        );
        final unite = combina([], [dalGarmin, daFreeletics]);
        expect(unite.length, 1);
        final s = unite.single;
        expect(s.id, 'hc-f1'); // la sessione resta quella di Freeletics
        expect(s.tipo, 'Corpo libero'); // nome e tipo da Freeletics
        expect(s.fcMedia, 128); // FC e calorie dall'orologio
        expect(s.calorieAttive, 310);
        expect(s.fonte, 'Freeletics'); // solo i dati, senza "+ Garmin"
      },
    );

    test('non unisce allenamenti distanti o di sport diversi', () {
      final mattina = sessione(
        record('a', 'STRENGTH_TRAINING', fine: ora(7, 30)),
      );
      final sera = sessione(
        record(
          'b',
          'STRENGTH_TRAINING',
          pacchetto: freeletics,
          inizio: ora(18, 0),
          fine: ora(18, 30),
        ),
      );
      final corsaSubitoDopo = sessione(
        record('d', 'RUNNING', inizio: ora(7, 32), fine: ora(8, 0)),
      );
      expect(raggruppa([mattina, sera]).length, 2);
      expect(raggruppa([mattina, corsaSubitoDopo]).length, 2);
    });

    // Casi reali letti dal telefono.

    test(
      'i blocchi di Freeletics e il Cardio Garmin diventano una sessione',
      () {
        Sessione blocco(String id, int h1, int m1, int h2, int m2, int fc) =>
            sessione(
              record(
                id,
                'HIGH_INTENSITY_INTERVAL_TRAINING',
                pacchetto: freeletics,
                inizio: ora(h1, m1),
                fine: ora(h2, m2),
              ),
              MetricheHc(
                fc: [
                  CampioneHc(ora(h1, m1 + 1), ora(h1, m1 + 1), fc.toDouble()),
                ],
              ),
            );
        final blocchi = [
          blocco('f1', 7, 15, 7, 23, 102),
          blocco('f2', 7, 23, 7, 38, 112),
          blocco('f3', 7, 39, 7, 54, 113),
          blocco('f4', 7, 55, 7, 56, 100),
          blocco('f5', 7, 56, 8, 2, 90),
        ];
        final cardio = sessione(
          record('g', 'OTHER', inizio: ora(7, 21), fine: ora(8, 2)),
          MetricheHc(
            fc: [CampioneHc(ora(7, 30), ora(7, 30), 109)],
            calorieAttive: [CampioneHc(ora(7, 21), ora(8, 2), 300)],
          ),
        );
        final unite = raggruppa([...blocchi, cardio]);
        expect(unite.length, 1);
        final s = unite.single;
        expect(s.id, 'hc-f1');
        expect(s.tipo, 'HIIT');
        expect(s.fonte, 'Freeletics');
        expect(s.durataMin, 8 + 15 + 15 + 1 + 6); // somma dei blocchi
        expect(s.fcMedia, 109); // dall'orologio, su tutta la sessione
        expect(s.calorieAttive, 300);
        expect(s.inizio, ora(7, 15));
        expect(s.fine, ora(8, 2));
        expect(
          s.parti.length,
          5,
        ); // gli intervalli, visibili aprendo la sessione
      },
    );

    test('la stessa uscita scritta due volte da Garmin conta una volta', () {
      final conDistanza = sessione(
        record(
          'b1',
          'BIKING',
          distanzaM: 7640,
          inizio: ora(7, 40),
          fine: ora(7, 59),
        ),
      );
      final senza = sessione(
        record('b2', 'BIKING', inizio: ora(7, 41), fine: ora(7, 59)),
      );
      final s = raggruppa([conDistanza, senza]).single;
      expect(s.distanzaKm, 7.64);
      expect(s.durataMin, 19);
      expect(s.parti, isEmpty); // un doppione non è un intervallo
    });

    test('due registrazioni in piscina dopo un crash diventano una sola', () {
      final prima = sessione(
        record(
          'n1',
          'SWIMMING_POOL',
          distanzaM: 425,
          inizio: ora(13, 0),
          fine: ora(13, 23),
        ),
      );
      final dopo = sessione(
        record(
          'n2',
          'SWIMMING_POOL',
          distanzaM: 500,
          inizio: ora(13, 27),
          fine: ora(13, 43),
        ),
      );
      final s = raggruppa([prima, dopo]).single;
      expect(s.distanzaKm, 0.93);
      expect(s.durataMin, 23 + 16);
      expect(s.parti.length, 2);
    });
  });

  group('salvataggio', () {
    test('ripara le sessioni salvate con il pacchetto nella fonte', () {
      final vecchia = Sessione(
        id: 'hc-x',
        data: DateTime(2026, 10, 15),
        sport: 'Corsa',
        fonte: pacchettoGarmin,
      );
      final r = riparaFonte(vecchia);
      expect(r.origine, pacchettoGarmin);
      expect(r.fonte, 'Garmin');
      // Le sessioni già giuste non cambiano.
      expect(riparaFonte(r).fonte, 'Garmin');
    });

    test('le colonne nuove di sessioni.csv si salvano e si rileggono', () {
      final s = sessione(
        record('c1', 'RUNNING', distanzaM: 7000, calorie: 500),
        MetricheHc(fc: [CampioneHc(ora(7, 10), ora(7, 10), 140)]),
      );
      final t = Tabella.da(toCsv([sessioniHeader, s.toRow()]))!;
      final letta = Sessione.da(t, t.righe.single)!;
      expect(letta.inizio, s.inizio);
      expect(letta.fine, s.fine);
      expect(letta.fcMax, 140);
      expect(letta.calorieTotali, 500);
      expect(letta.origine, pacchettoGarmin);
    });

    test('le righe vecchie senza le colonne nuove restano valide', () {
      final t = Tabella.da(
        'id_sessione,data,sport,tipo_sessione,durata_min,distanza_km,fc_media,rpe,fonte,note\n'
        '20261015-corsa-1,2026-10-15,Corsa,Fartlek,44,6.71,140,,Garmin,\n',
      )!;
      final s = Sessione.da(t, t.righe.single)!;
      expect(s.inizio, isNull);
      expect(s.fcMax, 0);
      expect(s.origine, '');
      expect(s.distanzaKm, 6.71);
    });

    test('stato della sincronizzazione', () {
      final i = InfoSync()
        ..ultima = DateTime(2026, 10, 18, 9, 30)
        ..token = 'abc'
        ..ignorati = {'WALKING': 3, 'OTHER': 1};
      final letto = InfoSync.da(
        Tabella.da(toCsv([infoSyncHeader, ...i.toRows()])),
      );
      expect(letto.ultima, i.ultima);
      expect(letto.token, 'abc');
      expect(letto.ignorati, {'WALKING': 3, 'OTHER': 1});
    });
  });
}
