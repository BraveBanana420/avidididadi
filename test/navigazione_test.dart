import 'dart:math' as math;

import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/navigazione.dart';
import 'package:allenamenti_app/screens/mappa_live.dart';
import 'package:allenamenti_app/screens/percorsi_screen.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Punti a x metri verso est e y verso nord da un punto vicino a Milano.
const _m = 111195.0;
PuntoTraccia _p(double x, double y, [double? q]) =>
    PuntoTraccia(45 + y / _m, 9 + x / (_m * math.cos(45 * math.pi / 180)), q);

/// Una linea spezzata da [vertici] (in metri), con un punto ogni [passo].
List<PuntoTraccia> _linea(List<(double, double)> vertici, {double passo = 5}) {
  final out = <PuntoTraccia>[];
  for (var i = 0; i < vertici.length - 1; i++) {
    final (ax, ay) = vertici[i];
    final (bx, by) = vertici[i + 1];
    final lungo = math.sqrt(math.pow(bx - ax, 2) + math.pow(by - ay, 2));
    final n = (lungo / passo).round();
    for (var k = 0; k < n; k++) {
      out.add(_p(ax + (bx - ax) * k / n, ay + (by - ay) * k / n));
    }
  }
  final (x, y) = vertici.last;
  return out..add(_p(x, y));
}

/// 500 m a nord, a destra 500 m a est, a sinistra 300 m a nord.
Traccia _elle() =>
    Traccia('Elle', _linea([(0, 0), (0, 500), (500, 500), (500, 800)]));

/// Cammina lungo [punti] un secondo per punto e raccoglie gli avvisi.
List<AvvisoGuida> _cammina(
  Guida g,
  List<PuntoTraccia> punti, {
  DateTime? da,
  void Function(int i)? dopo,
}) {
  final avvisi = <AvvisoGuida>[];
  var t = da ?? DateTime(2026, 11, 1, 9);
  for (var i = 0; i < punti.length; i++) {
    avvisi.addAll(g.aggiorna(punti[i].lat, punti[i].lon, t));
    dopo?.call(i);
    t = t.add(const Duration(seconds: 1));
  }
  return avvisi;
}

void main() {
  group('GPX', () {
    test('traccia con nome, quota e prefissi', () {
      const gpx = '''<?xml version="1.0"?>
<gpx xmlns="http://www.topografix.com/GPX/1/1">
  <metadata><name>File generico</name></metadata>
  <trk><name>Giro del lago &amp; colline</name><trkseg>
    <trkpt lat="45.80" lon="9.08"><ele>200.5</ele><time>2026-05-01T08:00:00Z</time></trkpt>
    <trkpt lat='45.81' lon='9.09'><ele>210</ele></trkpt>
    <gpx:trkpt lat="45.82" lon="9.10"/>
  </trkseg></trk>
</gpx>''';
      final t = tracciaDaGpx(gpx);
      expect(t.nome, 'Giro del lago & colline');
      expect(t.punti, hasLength(3));
      expect(t.punti[0].quota, 200.5);
      expect(t.punti[1].quota, 210);
      expect(t.punti[2].quota, isNull);
      expect(t.metri, closeTo(2 * 1360, 30));
    });

    test('percorso pianificato (rtept), senza nome: quello del file', () {
      const gpx = '''<gpx><rte>
        <rtept lat="45.0" lon="9.0"></rtept>
        <rtept lat="45.001" lon="9.0"></rtept>
      </rte></gpx>''';
      final t = tracciaDaGpx(gpx, nomeFile: 'Granfondo');
      expect(t.nome, 'Granfondo');
      expect(t.punti, hasLength(2));
      expect(t.metri, closeTo(111, 1));
    });

    test('senza punti: errore chiaro', () {
      expect(
        () => tracciaDaGpx('<gpx><wpt lat="45" lon="9"/></gpx>'),
        throwsFormatException,
      );
    });
  });

  test('dislivello: le oscillazioni sotto i 5 m non contano', () {
    final t = Traccia('Salita', [
      _p(0, 0, 100),
      _p(0, 100, 102), // rumore
      _p(0, 200, 101),
      _p(0, 300, 110),
      _p(0, 400, 105),
      _p(0, 500, 120),
    ]);
    expect(t.dislivello, 10 + 15);
    expect(t.quotaA(450), closeTo(112.5, 0.1));
  });

  test(
    'semplifica: una linea dritta resta coi due capi, la L con l\'angolo',
    () {
      expect(semplifica(_linea([(0, 0), (0, 500)]), 3), hasLength(2));
      final l = semplifica(_elle().punti, 3);
      expect(l, hasLength(4));
    },
  );

  test('salvata e riletta dal CSV', () {
    final t = Traccia('X', [_p(0, 0, 100), _p(0, 100)]);
    final r = Traccia.daCsv('X', t.toCsvText());
    expect(r.punti, hasLength(2));
    expect(r.punti.first.quota, 100);
    expect(r.punti.last.quota, isNull);
    expect(r.metri, closeTo(100, 0.5));
  });

  group('curve', () {
    test('la L: destra a 500 m, sinistra a 1000 m', () {
      final c = curveDi(_elle());
      expect(c, hasLength(2));
      expect(c[0].metri, closeTo(500, 10));
      expect(c[0].destra, isTrue);
      expect(c[0].tipo, TipoCurva.normale);
      expect(c[0].frase, 'gira a destra');
      expect(c[1].metri, closeTo(1000, 10));
      expect(c[1].frase, 'gira a sinistra');
    });

    test('una strada che piega dolcemente non è una curva da annunciare', () {
      // Arco di 90° con raggio 200 m (oltre 300 m di curva).
      final arco = [
        for (var a = 0; a <= 90; a += 2)
          _p(
            200 - 200 * math.cos(a * math.pi / 180),
            200 * math.sin(a * math.pi / 180),
          ),
      ];
      expect(curveDi(Traccia('Arco', arco)), isEmpty);
    });

    test('andata e ritorno: torna indietro', () {
      final c = curveDi(Traccia('AR', _linea([(0, 0), (0, 300), (0, 0)])));
      expect(c, hasLength(1));
      expect(c.single.tipo, TipoCurva.inversione);
      expect(c.single.frase, 'torna indietro');
    });

    test('tornante e curva leggera', () {
      final c = curveDi(
        Traccia(
          'T',
          _linea([(0, 0), (0, 300), (60, 200), (60, 400), (-200, 600)]),
        ),
      );
      expect(c.map((x) => x.tipo), [
        TipoCurva.stretta,
        TipoCurva.stretta,
        TipoCurva.leggera,
      ]);
      expect(c.last.frase, 'tieni la sinistra');
    });
  });

  group('guida', () {
    test('a piedi: preavviso a 100 m, poi "gira" vicino alla curva', () {
      final t = _elle();
      final g = Guida(t, bici: false);
      final metriAvvisi = <double>[];
      final avvisi = <AvvisoGuida>[];
      var tempo = DateTime(2026, 11, 1, 9);
      for (final p in t.punti.take(110)) {
        final a = g.aggiorna(p.lat, p.lon, tempo);
        if (a.isNotEmpty) metriAvvisi.add(g.progresso!);
        avvisi.addAll(a);
        tempo = tempo.add(const Duration(seconds: 1));
      }
      expect(avvisi.map((a) => a.frase), [
        'Tra 100 metri, gira a destra.',
        'Gira a destra.',
      ]);
      expect(metriAvvisi[0], closeTo(400, 6));
      expect(metriAvvisi[1], closeTo(475, 6));
      expect(g.prossimaCurva!.$1.destra, isFalse);
      expect(g.prossimaCurva!.$2, closeTo(455, 6));
      expect(g.metriMancanti, closeTo(1300 - 545, 6));
    });

    test('in bici il preavviso arriva a 250 m', () {
      final t = _elle();
      final g = Guida(t, bici: true);
      final avvisi = _cammina(g, t.punti.take(60).toList());
      expect(avvisi.single.frase, 'Tra 250 metri, gira a destra.');
    });

    test('in discesa veloce (50 km/h) gli avvisi arrivano prima', () {
      final t = _elle();
      final g = Guida(t, bici: true);
      const v = 50 / 3.6;
      final avvisi = <(double, AvvisoGuida)>[];
      var tempo = DateTime(2026, 11, 1, 9);
      for (final p in t.punti.take(100)) {
        for (final a in g.aggiorna(p.lat, p.lon, tempo, velocita: v)) {
          avvisi.add((g.progresso!, a));
        }
        tempo = tempo.add(const Duration(seconds: 1));
      }
      expect(avvisi.map((x) => x.$2.frase), [
        'Tra 350 metri, gira a destra.',
        'Gira a destra.',
      ]);
      // "Gira" circa 7 secondi prima: a 50 km/h quasi 100 metri.
      expect(500 - avvisi[1].$1, closeTo(97, 6));
      expect(avvisi[0].$2.urgente, isFalse);
      expect(avvisi[1].$2.urgente, isTrue);
    });

    test('a piedi la velocità non cambia quasi niente', () {
      final g = Guida(_elle(), bici: false);
      expect(g.preavvisoA(3), 100);
      expect(g.adessoA(3), 25);
      expect(g.adessoA(5.5), closeTo(33, 0.1)); // uno sprint
    });

    test('la seconda curva detta insieme suona naturale', () {
      expect(const Curva(0, 90).fraseDopo, 'poi subito a destra');
      expect(const Curva(0, -55).fraseDopo, 'poi tieni la sinistra');
      expect(const Curva(0, 140).fraseDopo, 'poi curva stretta a destra');
      expect(const Curva(0, 175).fraseDopo, 'poi torna indietro');
    });

    test('due curve vicine si dicono insieme', () {
      final t = Traccia(
        'Esse',
        _linea([(0, 0), (0, 300), (50, 300), (50, 600)]),
      );
      final avvisi = _cammina(Guida(t, bici: false), t.punti);
      expect(avvisi.map((a) => a.frase), [
        'Tra 100 metri, gira a destra, poi subito a sinistra.',
        'Gira a destra, poi subito a sinistra.',
        'Arrivo! Percorso completato.',
      ]);
    });

    test('fuori percorso dopo 10 s, di nuovo sopra dopo 3 s', () {
      final t = _elle();
      final g = Guida(t, bici: false);
      // 200 m sulla traccia, poi 100 m verso ovest e ritorno.
      final strada = [
        ..._linea([(0, 0), (0, 200)]),
        for (var x = -5.0; x >= -100; x -= 5) _p(x, 200),
        for (var x = -100.0; x <= 0; x += 5) _p(x, 200),
        ..._linea([(0, 205), (0, 260)]),
      ];
      final avvisi = _cammina(g, strada);
      final frasi = avvisi.map((a) => a.frase).toList();
      expect(frasi[0], startsWith('Sei fuori percorso, a '));
      expect(frasi[1], 'Di nuovo sul percorso.');
      expect(g.fuori, isFalse);
      expect(g.progresso, closeTo(260, 6));
    });

    test('lontani dalla traccia all\'inizio: solo la distanza', () {
      final g = Guida(_elle(), bici: false);
      final avvisi = _cammina(g, [for (var i = 0; i < 20; i++) _p(-300, 0)]);
      expect(avvisi, isEmpty);
      expect(g.progresso, isNull);
      expect(g.distanza, closeTo(300, 2));
    });

    test('andata e ritorno sulla stessa strada: il progresso va avanti', () {
      final t = Traccia('AR', _linea([(0, 0), (0, 400), (0, 0)]));
      final g = Guida(t, bici: false);
      final avvisi = _cammina(g, t.punti.take(140).toList());
      expect(g.progresso, closeTo(695, 6));
      expect(avvisi.map((a) => a.frase), [
        'Tra 100 metri, torna indietro.',
        'Torna indietro.',
      ]);
    });

    test('anello: si parte dall\'inizio e si arriva alla fine', () {
      final t = Traccia(
        'Anello',
        _linea([(0, 0), (0, 300), (300, 300), (300, 0), (0, 0)]),
      );
      expect(t.anello, isTrue);
      final g = Guida(t, bici: true);
      final avvisi = _cammina(g, t.punti);
      expect(avvisi.last.tipo, TipoAvvisoGuida.arrivo);
      expect(g.arrivato, isTrue);
      expect(
        avvisi.where((a) => a.tipo == TipoAvvisoGuida.curva),
        hasLength(6), // preavviso e "adesso" per 3 curve
      );
    });

    test('senso contrario: avvisa dopo 15 s, non ripete subito', () {
      final t = Traccia('Dritta', _linea([(0, 0), (0, 1000)]));
      final g = Guida(t, bici: false);
      final indietro = [for (var y = 800.0; y >= 500; y -= 3) _p(0, y)];
      final avvisi = _cammina(g, indietro);
      expect(avvisi.map((a) => a.tipo), [TipoAvvisoGuida.contrario]);
    });

    test('dopo un\'interruzione non ripete le curve già fatte', () {
      final t = _elle();
      // Il preavviso era già stato dato prima dell'interruzione, a 400 m.
      final g = Guida(t, bici: false)..riprendiDa(505);
      final avvisi = _cammina(g, _linea([(5, 500), (60, 500)]));
      expect(avvisi, isEmpty);
      expect(g.progresso, closeTo(560, 3));
    });
  });

  test('metri a voce e sullo schermo', () {
    expect(parlaMetri(250), '250 metri');
    expect(parlaMetri(1000), '1 chilometro');
    expect(parlaMetri(1240), '1,2 chilometri');
    expect(parlaMetri(3000), '3 chilometri');
    expect(fmtMetri(247), '250 m');
    expect(fmtMetri(12340), '12,3 km');
  });

  test('percorso salvato: riga CSV', () {
    final p = PercorsoSalvato(
      id: 'p1730450000',
      nome: 'Giro, con virgola',
      km: 42.195,
      dislivello: 320,
      aggiunto: DateTime(2026, 11, 1),
    );
    final t = Tabella.da(toCsv([PercorsoSalvato.header, p.toRow()]))!;
    final r = PercorsoSalvato.da(t, t.righe.single)!;
    expect(r.nome, 'Giro, con virgola');
    expect(r.km, closeTo(42.2, 0.01));
    expect(r.dislivello, 320);
    expect(r.file, 'traccia_p1730450000.csv');
    // Un id che uscirebbe dalla cartella non si accetta.
    expect(
      PercorsoSalvato.da(t, ['../x', 'a', '1', '0', '2026-01-01']),
      isNull,
    );
  });

  testWidgets('sagoma e altimetria si disegnano nei 4 temi', (t) async {
    final tr = Traccia('Salita', [
      for (var i = 0; i <= 40; i++) _p(i * 20.0, i * i * 1.0, 100.0 + i * 3),
    ]);
    for (final b in Brightness.values) {
      for (final neon in [false, true]) {
        await t.pumpWidget(
          MaterialApp(
            theme: creaTema(b, neon: neon),
            home: Scaffold(
              body: Column(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: SagomaTraccia(traccia: tr),
                  ),
                  SizedBox(
                    width: 300,
                    height: 120,
                    child: ProfiloAltimetrico(traccia: tr, metri: 500),
                  ),
                ],
              ),
            ),
          ),
        );
        expect(t.takeException(), isNull);
      }
    }
  });

  group('banner della guida e notifica', () {
    Guida camminata(List<PuntoTraccia> strada) {
      final g = Guida(_elle(), bici: false);
      _cammina(g, strada);
      return g;
    }

    test('le righe della notifica', () {
      expect(testoGuida(null), isNull);
      final lontano = camminata([_p(-300, 0)]);
      expect(testoGuida(lontano), 'Percorso a 300 m');
      final sopra = camminata(_linea([(0, 0), (0, 300)]));
      expect(testoGuida(sopra), '200 m: gira a destra');
      final fuori = camminata([
        ..._linea([(0, 0), (0, 200)]),
        for (var i = 0; i < 12; i++) _p(-90, 200),
      ]);
      expect(testoGuida(fuori), 'Fuori percorso (90 m)');
    });

    testWidgets('si disegna nei 4 temi, in tutti gli stati', (t) async {
      final stati = [
        camminata([_p(-300, 0)]),
        camminata(_linea([(0, 0), (0, 300)])),
        camminata([
          ..._linea([(0, 0), (0, 200)]),
          for (var i = 0; i < 12; i++) _p(-90, 200),
        ]),
        camminata(_elle().punti),
      ];
      expect(stati.last.arrivato, isTrue);
      for (final b in Brightness.values) {
        for (final neon in [false, true]) {
          await t.pumpWidget(
            MaterialApp(
              theme: creaTema(b, neon: neon),
              home: Scaffold(
                body: SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      for (final g in stati) ...[
                        BannerGuida(guida: g),
                        BannerGuida(guida: g, compatto: true),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
          expect(t.takeException(), isNull);
        }
      }
      expect(find.text('Fuori percorso: torna sulla traccia'), findsWidgets);
      expect(find.byIcon(Icons.turn_right_rounded), findsWidgets);
    });
  });
}
