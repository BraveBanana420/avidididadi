import 'package:allenamenti_app/battito.dart';
import 'package:allenamenti_app/dati_live.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 1, 8);

  /// Punti verso nord ogni secondo, [mps] metri al secondo.
  List<PuntoGps> retta(int secondi, double mps, {int da = 0}) => [
    for (var k = da; k <= da + secondi; k++)
      PuntoGps(45 + k * mps / 111195, 9, t0.add(Duration(seconds: k)), 5),
  ];

  group('velocità di adesso', () {
    test('corsa a 5:00 min/km', () {
      final p = retta(60, 1000 / 300);
      final v = velocitaAttuale(p, ora: p.last.t);
      expect(v, closeTo(3.333, 0.02));
      expect(fmtVelocita('Corsa', v), '5:00');
    });

    test('bici a 27 km/h', () {
      final p = retta(30, 7.5);
      final v = velocitaAttuale(
        p,
        ora: p.last.t,
        finestra: finestraVelocita('Bici'),
      );
      expect(fmtVelocita('Bici', v), '27.0');
    });

    test('guarda solo gli ultimi secondi: conta il cambio di ritmo', () {
      // 2 minuti piano (6:00/km), poi 40 s forte (4:00/km).
      final piano = retta(120, 1000 / 360);
      final forte = [
        for (var k = 1; k <= 40; k++)
          PuntoGps(
            piano.last.lat + k * (1000 / 240) / 111195,
            9,
            piano.last.t.add(Duration(seconds: k)),
            5,
          ),
      ];
      final p = [...piano, ...forte];
      expect(fmtVelocita('Corsa', velocitaAttuale(p, ora: p.last.t)), '4:00');
    });

    test('fermo al semaforo: niente punti nuovi, velocità 0', () {
      final p = retta(60, 3);
      final v = velocitaAttuale(
        p,
        ora: p.last.t.add(const Duration(seconds: 15)),
      );
      expect(v, 0);
      expect(fmtVelocita('Corsa', v), '–');
    });

    test('dopo una pausa il buco non conta', () {
      final prima = retta(60, 3);
      final dopo = retta(20, 3, da: 200);
      final p = [...prima, ...dopo];
      expect(velocitaAttuale(p, ora: p.last.t), closeTo(3, 0.05));
    });

    test('appena partiti non si sa ancora', () {
      final p = retta(3, 3);
      expect(velocitaAttuale(p, ora: p.last.t), isNull);
    });
  });

  group('giri', () {
    test('un km ogni 5:30, con il passaggio stimato tra due misure', () {
      final g = GiriLive(metriGiro('Corsa'));
      Giro? chiuso;
      // Misure ogni 10 s a 1000/330 m/s.
      for (var s = 0; s <= 700; s += 10) {
        chiuso = g.aggiorna(s * 1000 / 330, Duration(seconds: s)) ?? chiuso;
      }
      expect(g.giri.length, 2);
      expect(g.giri.first.tempo.inSeconds, 330);
      expect(g.giri[1].numero, 2);
      expect(ritmoGiro('Corsa', g.giri.first), '5:30 min/km');
    });

    test('in bici ogni 5 km, in km/h', () {
      final g = GiriLive(metriGiro('Bici'));
      for (var s = 0; s <= 700; s += 5) {
        g.aggiorna(s * 7.5, Duration(seconds: s));
      }
      expect(g.giri.single.metri, 5000);
      expect(ritmoGiro('Bici', g.giri.single), '27.0 km/h');
    });
  });

  group('battito Bluetooth', () {
    test('valore su 8 bit (fasce e Garmin)', () {
      expect(bpmDa([0x16, 142, 0x20, 0x03]), 142);
    });

    test('valore su 16 bit', () {
      expect(bpmDa([0x01, 0x2C, 0x01]), isNull); // 300: impossibile
      expect(bpmDa([0x01, 160, 0x00]), 160);
    });

    test('vuoto o zero (fascia appena indossata)', () {
      expect(bpmDa([]), isNull);
      expect(bpmDa([0x00, 0]), isNull);
      expect(bpmDa([0x01, 120]), isNull);
    });

    test('media e massimo', () {
      final f = Statistiche();
      for (final v in [120, 130, 141, 150]) {
        f.aggiungi(v);
      }
      expect(f.media, 135);
      expect(f.massimo, 150);
      expect(Statistiche().media, 0);
    });
  });

  group('al chiuso', () {
    test('si parte già al chiuso se la seduta lo dice', () {
      expect(tipoAlChiuso('Rulli'), isTrue);
      expect(tipoAlChiuso('Lento su tapis roulant'), isTrue);
      expect(tipoAlChiuso('Indoor'), isTrue);
      expect(tipoAlChiuso('Lento'), isFalse);
      expect(tipoAlChiuso(''), isFalse);
    });

    test('come si chiama l\'attrezzo', () {
      expect(attrezzoAlChiuso('Bici'), 'rulli');
      expect(attrezzoAlChiuso('Corsa'), 'tapis roulant');
      expect(attrezzoAlChiuso('Camminata'), 'tapis roulant');
    });

    test('km del display, con la virgola o il punto', () {
      expect(kmScritti('5,2'), 5.2);
      expect(kmScritti(' 10.45 '), 10.45);
      expect(kmScritti(''), isNull);
      expect(kmScritti('0'), isNull);
      expect(kmScritti('abc'), isNull);
      expect(kmScritti('5000'), isNull); // metri scritti per sbaglio
    });
  });
}
