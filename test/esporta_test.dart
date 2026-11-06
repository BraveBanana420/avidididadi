import 'package:allenamenti_app/esporta.dart';
import 'package:allenamenti_app/intervals.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final inizio = DateTime(2026, 11, 1, 8, 10);
  final camminata = Sessione(
    id: 'app-l-2026-11-01-0810-camminata',
    data: DateTime(2026, 11, 1),
    inizio: inizio,
    fine: inizio.add(const Duration(minutes: 47)),
    sport: 'Camminata',
    durataMin: 45,
    distanzaKm: 4.6,
    fcMedia: 108,
    fcMax: 131,
    fonte: fonteApp,
    note: 'Camminata',
  );

  group('copie delle sedute mandate a intervals.icu', () {
    // Il caso vero: bici sui rulli registrata dall'app, mandata e riscaricata.
    final partenza = DateTime(2026, 11, 6, 7, 12);
    final fine = partenza.add(const Duration(minutes: 45));
    final bici = Sessione(
      id: 'app-l-2026-11-06-0712-bici',
      data: DateTime(2026, 11, 6),
      inizio: partenza,
      fine: fine,
      sport: 'Bici',
      durataMin: 45,
      distanzaKm: 12.44,
      fonte: fonteApp,
    );
    Sessione daIcu(String id, {DateTime? inizio}) => Sessione(
      id: 'icu-$id',
      data: DateTime(2026, 11, 6),
      inizio: inizio ?? partenza,
      fine: (inizio ?? partenza).add(const Duration(minutes: 45)),
      sport: 'Bici',
      durataMin: 45,
      fonte: 'intervals.icu (intervals.icu)',
      origine: 'intervals.icu',
    );

    test('la seduta dell\'app resta sua e si può modificare', () {
      final icu = senzaCopieInviate([daIcu('i1')], {bici.id: 'i1'}, [bici]);
      final unite = combina([bici], icu);
      expect(unite.single.id, bici.id);
      expect(unite.single.fonte, fonteApp);
    });

    test('senza l\'id di là la copia si riconosce dalla partenza', () {
      expect(senzaCopieInviate([daIcu('i1')], {bici.id: ''}, [bici]), isEmpty);
    });

    test('tolta la seduta, la copia non torna', () {
      expect(senzaCopieInviate([daIcu('i1')], {bici.id: 'i1'}, []), isEmpty);
    });

    test('la stessa seduta registrata anche dall\'orologio vince ancora', () {
      final orologio = daIcu('i2', inizio: partenza.add(Duration(minutes: 3)));
      final icu = senzaCopieInviate([daIcu('i1'), orologio], {bici.id: 'i1'}, [
        bici,
      ]);
      expect(combina([bici], icu).single.id, 'icu-i2');
    });

    test('mai inviata: l\'attività di là prende il posto come prima', () {
      expect(
        combina([bici], senzaCopieInviate([daIcu('i1')], {}, [bici])).single.id,
        'icu-i1',
      );
    });
  });

  group('invio delle sedute', () {
    InvioSessione invio(
      Sessione s, {
      bool collegato = true,
      bool inviata = false,
      DateTime? dal,
    }) => invioDi(s, collegato: collegato, inviata: inviata, invioDal: dal);

    test('con l\'invio acceso la seduta parte da sola, senza tasto', () {
      expect(
        invio(camminata, dal: inizio.subtract(const Duration(days: 1))),
        InvioSessione.automatico,
      );
    });

    test('accenderlo non manda le sedute di prima', () {
      expect(
        invio(camminata, dal: inizio.add(const Duration(days: 1))),
        InvioSessione.tasto,
      );
    });

    test('con l\'invio spento resta il tasto', () {
      expect(invio(camminata), InvioSessione.tasto);
    });

    test('già inviata non riparte', () {
      expect(
        invio(camminata, inviata: true, dal: inizio),
        InvioSessione.inviata,
      );
    });

    test('non collegato, o sessione dell\'orologio: niente', () {
      expect(invio(camminata, collegato: false), InvioSessione.nessuno);
      expect(
        invio(camminata.copyWith(fonte: 'Garmin'), dal: inizio),
        InvioSessione.nessuno,
      );
    });

    test('due sedute uguali nello stesso giorno: due attività', () {
      final dopo = Sessione(
        id: camminata.id,
        data: camminata.data,
        inizio: inizio.add(const Duration(hours: 6)),
        sport: camminata.sport,
        durataMin: 45,
        fonte: fonteApp,
      );
      expect(idEsterno(camminata), isNot(idEsterno(dopo)));
      expect(idEsterno(camminata), idEsterno(camminata));
    });
  });

  test('tipo di attività, anche al chiuso', () {
    expect(tipoAttivitaIcu('Corsa'), 'Run');
    expect(tipoAttivitaIcu('Corsa', alChiuso: true), 'VirtualRun');
    expect(tipoAttivitaIcu('Bici', alChiuso: true), 'VirtualRide');
    expect(tipoAttivitaIcu('Camminata'), 'Walk');
    expect(tipoAttivitaIcu('Forza'), 'WeightTraining');
    expect(tipoAttivitaIcu('Mobilità'), 'Workout');
  });

  test('nome: quello scritto a mano, se c\'è', () {
    expect(nomeAttivita(camminata, ''), 'Camminata');
    expect(nomeAttivita(camminata, 'Giro del lago'), 'Giro del lago');
    final lento = Sessione(
      id: 'x',
      data: inizio,
      sport: 'Corsa',
      tipo: 'Lento',
      note: 'Corsa lenta',
    );
    expect(nomeAttivita(lento, ''), 'Corsa · Corsa lenta');
  });

  test('GPX con orari in UTC e caratteri protetti', () {
    final p = Percorso([
      PuntoGps(45.4642, 9.19, inizio, 5),
      PuntoGps(45.4651, 9.1912, inizio.add(const Duration(seconds: 5)), 5),
    ]);
    final gpx = gpxDa(p, nome: 'Lago & colline <3', sport: 'Camminata');
    expect(gpx, contains('<name>Lago &amp; colline &lt;3</name>'));
    expect(gpx, contains('<type>Walk</type>'));
    expect(gpx, contains('<trkpt lat="45.4642000" lon="9.1900000">'));
    expect(gpx, contains('<time>${inizio.toUtc().toIso8601String()}</time>'));
    expect('<trkpt'.allMatches(gpx).length, 2);
    expect(nomeFileGpx(camminata), 'avidididadi_2026-11-01_camminata.gpx');
  });

  test('attività manuale: tempo, km in metri, battito', () {
    final a = attivitaManuale(camminata, nome: 'Camminata');
    expect(a['start_date_local'], '2026-11-01T08:10:00');
    expect(a['type'], 'Walk');
    expect(a['moving_time'], 2700);
    expect(a['elapsed_time'], 2820);
    expect(a['distance'], 4600);
    expect(a['average_heartrate'], 108);
    expect(a['max_heartrate'], 131);
    expect(a['external_id'], idEsterno(camminata));
    expect(a['external_id'], startsWith('avidididadi-${camminata.id}-'));
    expect(a.containsKey('trainer'), isFalse);
    final forza = Sessione(
      id: 'app-2026-11-01-forza',
      data: DateTime(2026, 11, 1),
      sport: 'Forza',
      durataMin: 40,
    );
    final f = attivitaManuale(forza, nome: 'Forza');
    expect(f.containsKey('distance'), isFalse);
    expect(f['start_date_local'], '2026-11-01T12:00:00');
    expect(
      attivitaManuale(camminata, nome: 'x', alChiuso: true)['trainer'],
      isTrue,
    );
  });

  test('id dell\'attività creata, nei due formati di risposta', () {
    expect(idAttivitaCreata({'id': 'i123'}), 'i123');
    expect(
      idAttivitaCreata({
        'icu_athlete_id': 'i9',
        'activities': [
          {'id': 'i456'},
        ],
      }),
      'i456',
    );
    expect(idAttivitaCreata(null), isNull);
  });
}
