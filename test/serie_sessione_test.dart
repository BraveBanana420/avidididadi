import 'dart:convert';

import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:allenamenti_app/potenza.dart';
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

  group('passi al minuto', () {
    final t0 = DateTime(2026, 11, 5, 8);
    List<Campione> serie(List<double> v) => [
      for (final (k, x) in v.indexed) Campione(t0.add(Duration(seconds: k)), x),
    ];

    test('Garmin conta un piede: nella corsa 85 sono 170 passi', () {
      final p = passiAlMinuto(serie([84, 85, 86, 0, 85]), 'Corsa');
      expect(p.map((c) => c.v), [168, 170, 172, 170]); // lo 0 non conta
    });

    test('se sono già passi al minuto non si raddoppiano', () {
      expect(passiAlMinuto(serie([168, 172, 170]), 'Corsa').map((c) => c.v), [
        168,
        172,
        170,
      ]);
      expect(
        passiAlMinuto(serie([105, 110, 108]), 'Camminata').map((c) => c.v),
        [105, 110, 108],
      );
    });

    test('nella camminata 55 sono 110 passi', () {
      expect(passiAlMinuto(serie([54, 55, 56]), 'Camminata').map((c) => c.v), [
        108,
        110,
        112,
      ]);
    });

    test('un tratto strano non cambia la scala della seduta', () {
      // Un momento lento di chi conta già i due piedi: resta com'è.
      expect(
        passiAlMinuto(
          serie([170, 172, 100, 171, 169]),
          'Corsa',
        ).map((c) => c.v),
        [170, 172, 100, 171, 169],
      );
    });

    test('dalla media delle attività di intervals.icu', () {
      Sessione s(String sport, int cad) => Sessione(
        id: 'x',
        data: t0,
        sport: sport,
        durataMin: 40,
        cadenzaMedia: cad,
      );
      expect(cadenza(s('Corsa', 85)), 170);
      expect(cadenza(s('Corsa', 172)), 172);
      expect(cadenza(s('Camminata', 55)), 110);
      expect(cadenza(s('Bici', 88)), isNull); // in bici restano i giri
    });

    test('dai conteggi di Health Connect, a pezzi', () {
      final pezzi = [
        for (var m = 0; m < 4; m++)
          (
            t0.add(Duration(minutes: m)),
            t0.add(Duration(minutes: m + 1)),
            170.0,
          ),
      ];
      final p = passiDaConteggi(pezzi);
      expect(p, hasLength(4));
      expect(p.first.v, 170);
      // Un solo totale della seduta non fa un grafico.
      expect(
        passiDaConteggi([(t0, t0.add(const Duration(minutes: 50)), 8000)]),
        isEmpty,
      );
      expect(passiDaConteggi(pezzi.take(2).toList()), isEmpty);
    });
  });

  group('velocità dai sensori', () {
    final t0 = DateTime(2026, 11, 6, 7);
    Campione c(int s, double v) => Campione(t0.add(Duration(seconds: s)), v);

    test('si salva e si rilegge con i decimali', () {
      final letta = serieAppDa(
        serieAppCsv(
          SerieSessione(
            potenza: [c(0, 150)],
            velocita: [c(0, 9.72), c(1, 10.28)],
          ),
        ),
      );
      expect(letta.velocita.map((x) => x.v), [9.72, 10.28]);
      expect(letta.potenza.single.v, 150);
    });

    test('i file di prima, senza velocità, restano leggibili', () {
      final ms = t0.millisecondsSinceEpoch;
      final letta = serieAppDa('tempo_ms,fc,potenza,cadenza\n$ms,120,150,85\n');
      expect(letta.velocita, isEmpty);
      expect(letta.fc.single.v, 120);
      expect(letta.potenza.single.v, 150);
      expect(letta.cadenza.single.v, 85);
    });

    test('valori impossibili si scartano', () {
      final ms = t0.millisecondsSinceEpoch;
      final letta = serieAppDa(
        'tempo_ms,fc,potenza,cadenza,velocita\n$ms,,,,99\n',
      );
      expect(letta.velocita, isEmpty);
    });
  });

  group('nota sui dati mancanti', () {
    String? nota({
      bool conPercorso = true,
      bool alChiuso = false,
      bool intervals = false,
      bool altitudine = false,
      bool potenza = false,
    }) => notaDatiMancanti(
      conPercorso: conPercorso,
      alChiuso: alChiuso,
      intervalsCollegato: intervals,
      conAltitudine: altitudine,
      conPotenza: potenza,
    );

    test('all\'aperto senza intervals.icu si spiega come averli', () {
      expect(nota(), startsWith('Altitudine, pendenza e potenza'));
      expect(nota(potenza: true), startsWith('Altitudine e pendenza'));
    });

    test('non compare al chiuso, con intervals.icu o nella forza', () {
      expect(nota(alChiuso: true), isNull);
      expect(nota(intervals: true), isNull);
      expect(nota(conPercorso: false), isNull);
      expect(nota(altitudine: true), isNull);
    });
  });
}
