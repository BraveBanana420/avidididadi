import 'package:allenamenti_app/intervals.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final inizio = DateTime(2026, 10, 30, 7, 9);

  Map<String, dynamic> attivita({
    String type = 'VirtualRide',
    String name = 'Test FTP',
    bool trainer = true,
  }) => {
    'id': 'i98765',
    'start_date_local': '2026-10-30T07:09:00',
    'type': type,
    'name': name,
    'trainer': trainer,
    'distance': 18720.4,
    'moving_time': 2350,
    'elapsed_time': 2400,
    'average_heartrate': 119,
    'max_heartrate': 134,
    'calories': 306,
    'source': 'GARMIN_CONNECT',
  };

  test('un Test FTP sui rulli da Garmin', () {
    final a = attivitaDaIcu(attivita())!;
    final s = a.sessione;
    expect(s.id, 'icu-i98765');
    expect(s.sport, 'Bici');
    expect(s.tipo, 'Test FTP');
    expect(a.alChiuso, isTrue);
    expect(s.durataMin, 40);
    expect(s.distanzaKm, 18.72);
    expect(s.fcMedia, 119);
    expect(s.fonte, 'Garmin (intervals.icu)');
    expect(s.fine, inizio.add(const Duration(seconds: 2400)));
  });

  test('tipi: corsa, nuoto in acque libere, sport ignorati', () {
    expect(sportDaTipoIcu('Run'), ('Corsa', 'Corsa'));
    expect(sportDaTipoIcu('OpenWaterSwim'), ('Nuoto', 'Acque libere'));
    expect(sportDaTipoIcu('WeightTraining'), isNull);
    final corsa = attivitaDaIcu(
      attivita(type: 'Run', name: '', trainer: false),
    )!;
    expect(corsa.sessione.tipo, 'Corsa');
    expect(corsa.alChiuso, isFalse);
    expect(attivitaDaIcu({'id': 'x', 'type': 'Run'}), isNull);
  });

  test('dati nel tempo: si leggono quelli noti, i vuoti si saltano', () {
    final streams = [
      {
        'type': 'time',
        'data': [0, 1, 2, 3, 4, 5],
      },
      {
        'type': 'heartrate',
        'data': [90, 95, null, 110, 112, 115],
      },
      {
        'type': 'velocity_smooth',
        'data': [0, 2.5, 2.8, 3.0, 3.1, 3.0],
      },
      {
        'type': 'altitude',
        'data': [100, 100, 102, 104, 106, 108],
      },
      {
        'type': 'distance',
        'data': [0, 30, 60, 90, 120, 150],
      },
      {
        'type': 'watts',
        'data': [150, 160, 170, 180, 190, 200],
      },
      {
        'type': 'sconosciuto',
        'data': [1, 2, 3],
      },
    ];
    final s = serieDaIcu(streams, inizio);
    expect(s.fc.length, 5);
    expect(s.fc[2].t, inizio.add(const Duration(seconds: 3)));
    expect(s.velocita.last.v, 3.0);
    expect(s.potenza.length, 6);
    // Primo tratto oltre 50 m: da 0 a 60 m, 2 m di salita (3,3%).
    expect(s.pendenza.first.v, closeTo(2 / 60 * 100, 0.01));
    expect(serieDaIcu([], inizio).vuota, isTrue);
  });

  test('pendenza limitata a ±30%', () {
    final t = [for (var i = 0; i < 3; i++) inizio.add(Duration(seconds: i))];
    final p = pendenzaDa(
      [Campione(t[0], 0), Campione(t[1], 100), Campione(t[2], 100)],
      [Campione(t[0], 0), Campione(t[1], 60), Campione(t[2], 200)],
    );
    expect(p.first.v, 30);
    expect(p.last.v, 0);
  });

  test('percorso dalla mappa di intervals.icu', () {
    final p = percorsoDaIcu({
      'latlngs': [
        [43.9, 10.9],
        null,
        [43.91, 10.91],
        [43.92, 10.92],
      ],
    }, inizio);
    expect(p.punti.length, 3);
    expect(p.distanzaKm, greaterThan(2));
    expect(percorsoDaIcu({}, inizio).vuoto, isTrue);
  });

  test('niente doppioni: vince intervals.icu, la forza resta da HC', () {
    final icu = attivitaDaIcu(attivita())!.sessione;
    final hc = [
      Sessione(
        id: 'hc-1',
        data: icu.data,
        sport: 'Bici',
        durataMin: 40,
        inizio: inizio.add(const Duration(minutes: 1)),
        fine: inizio.add(const Duration(minutes: 41)),
      ),
      Sessione(
        id: 'hc-2',
        data: icu.data,
        sport: 'Forza',
        durataMin: 30,
        inizio: inizio,
        fine: inizio.add(const Duration(minutes: 30)),
      ),
      Sessione(
        id: 'hc-3',
        data: icu.data,
        sport: 'Bici',
        durataMin: 60,
        inizio: inizio.add(const Duration(hours: 8)),
        fine: inizio.add(const Duration(hours: 9)),
      ),
    ];
    final restano = senzaDoppioniIcu(hc, [icu]);
    expect(restano.map((s) => s.id), ['hc-2', 'hc-3']);
    expect(senzaDoppioniIcu(hc, const []), hc);
  });
}
