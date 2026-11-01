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
    expect(a['external_id'], 'avidididadi-${camminata.id}');
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
