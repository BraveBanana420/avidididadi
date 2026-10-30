import 'dart:convert';

import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 10, 30, 7);
  Campione c(int s, double v) => Campione(t0.add(Duration(seconds: s)), v);

  test('ricampiona: al massimo N punti, con la media', () {
    final serie = [for (var i = 0; i < 600; i++) c(i * 10, 100 + i % 10)];
    final r = ricampiona(serie, punti: 60);
    expect(r.length, lessThanOrEqualTo(60));
    expect(r.first.v, closeTo(104.5, 5));
    expect(ricampiona(serie.take(30).toList(), punti: 60).length, 30);
  });

  test('tempo nelle zone, senza contare i buchi', () {
    const z = Zone(fcMax: 200);
    // Z2 da 120, Z4 da 160: 10 minuti in Z2, 5 in Z4, poi un buco di 10 min.
    final fc = [
      for (var s = 0; s <= 600; s += 20) c(s, 130),
      for (var s = 620; s <= 900; s += 20) c(s, 165),
      c(1500, 165),
    ];
    final t = tempoNelleZone(fc, z);
    expect(t[2]!.inSeconds, 620);
    expect(t[4]!.inSeconds, 280);
    expect(t[5], Duration.zero);
  });

  test('passo da velocità e formato', () {
    expect(passoDa(1000 / 330), closeTo(330, 0.01));
    expect(fmtMinSec(330), '5:30');
    expect(passoDa(0.2), 0);
  });

  test('velocità dal GPS dell\'app', () {
    // 0.0001 gradi di latitudine ≈ 11,1 m ogni 4 s ≈ 2,8 m/s.
    final p = Percorso([
      for (var i = 0; i < 40; i++)
        PuntoGps(43.9 + i * 0.0001, 10.9, t0.add(Duration(seconds: i * 4)), 5),
    ]);
    final v = velocitaDaPercorso(p);
    expect(v, isNotEmpty);
    expect(media(v), closeTo(2.78, 0.1));
  });

  test('mappe: satellite e strade portano il percorso al neon', () {
    final orig = Percorso([
      PuntoGps(43.9, 10.9, t0),
      PuntoGps(43.91, 10.91, t0.add(const Duration(minutes: 5))),
    ]);
    final sat = jsonDecode(
      stileSatellite(
        colore: '#FF3B47',
        percorso: orig.geoJson(),
        estremi: orig.geoJsonEstremi(),
      ),
    ) as Map<String, dynamic>;
    expect((sat['layers'] as List).first['type'], 'raster');
    expect([
      for (final l in sat['layers'] as List) l['id'],
    ], containsAllInOrder(['satellite', 'alone', 'luce', 'nucleo', 'estremi']));
    final base = {
      'version': 8,
      'sources': {
        'openmaptiles': {'type': 'vector'},
      },
      'layers': [
        {'id': 'acqua', 'type': 'fill'},
      ],
    };
    final strade = jsonDecode(
      stileStrade(base, colore: '#FF3B47', percorso: orig.geoJson()),
    ) as Map<String, dynamic>;
    expect(
      (strade['sources'] as Map).keys,
      containsAll(['openmaptiles', 'percorso']),
    );
    expect((strade['layers'] as List).first['id'], 'acqua');
    expect((strade['layers'] as List).last['id'], 'estremi');
  });
}
