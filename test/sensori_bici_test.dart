import 'package:allenamenti_app/notifica_allenamento.dart';
import 'package:allenamenti_app/sensore_ble.dart';
import 'package:allenamenti_app/sensori_bici.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 1, 18);

  group('velocità e cadenza (CSC)', () {
    test('ruota e pedali nello stesso pacchetto', () {
      // giri ruota 1000, tempo 1 s; giri pedali 50, tempo 2 s.
      final c = cscDa([0x03, 0xE8, 0x03, 0, 0, 0x00, 0x04, 0x32, 0, 0, 0x08]);
      expect(c.ruota, (giri: 1000, tempo: 1024));
      expect(c.pedali, (giri: 50, tempo: 2048));
    });

    test('solo pedali (sensore di cadenza)', () {
      final c = cscDa([0x02, 0x32, 0, 0, 0x08]);
      expect(c.ruota, isNull);
      expect(c.pedali, (giri: 50, tempo: 2048));
    });

    test('4 giri di ruota in un secondo: 30,3 km/h con 2105 mm', () {
      final r = Contagiri(modulo: 0x100000000);
      r.aggiorna((giri: 1000, tempo: 1024), t0);
      final giriAlSec = r.aggiorna((
        giri: 1004,
        tempo: 2048,
      ), t0.add(const Duration(seconds: 1)));
      expect(giriAlSec * 2.105 * 3.6, closeTo(30.3, 0.05));
    });

    test('cadenza: un giro di pedali ogni 0,7 s fa circa 86 rpm', () {
      final p = Contagiri();
      p.aggiorna((giri: 50, tempo: 2048), t0);
      final v = p.aggiorna((
        giri: 51,
        tempo: 2048 + 717,
      ), t0.add(const Duration(milliseconds: 700)));
      expect(v * 60, closeTo(85.7, 0.3));
    });

    test('l\'orologio del sensore ricomincia da zero', () {
      expect(
        giriAlSecondo((giri: 65535, tempo: 65000), (giri: 1, tempo: 500)),
        closeTo(2 / (1036 / 1024), 1e-9),
      );
    });

    test('se non arrivano giri nuovi per 3 s, ci si è fermati', () {
      final p = Contagiri();
      p.aggiorna((giri: 50, tempo: 1024), t0);
      expect(
        p.aggiorna((giri: 51, tempo: 1741), t0.add(const Duration(seconds: 1))),
        greaterThan(0),
      );
      // Il sensore ripete l'ultima lettura: stessi giri, stesso orario.
      expect(
        p.aggiorna((giri: 51, tempo: 1741), t0.add(const Duration(seconds: 2))),
        greaterThan(0),
      );
      expect(
        p.aggiorna((giri: 51, tempo: 1741), t0.add(const Duration(seconds: 5))),
        0,
      );
    });
  });

  group('misuratore di potenza', () {
    test('watt e giri dei pedali', () {
      final p = potenzaDa([0x20, 0x00, 0xFA, 0x00, 0x0A, 0x00, 0x00, 0x04]);
      expect(p.watt, 250);
      expect(p.pedali, (giri: 10, tempo: 1024));
    });

    test('con bilanciamento e coppia prima dei pedali', () {
      final p = potenzaDa([
        0x25, 0x00, 0xC8, 0x00, // flag, 200 W
        0x32, // bilanciamento
        0x10, 0x00, // coppia
        0x0B, 0x00, 0x00, 0x08, // pedali
      ]);
      expect(p.watt, 200);
      expect(p.pedali, (giri: 11, tempo: 2048));
    });

    test('solo watt; negativi a zero', () {
      expect(potenzaDa([0x00, 0x00, 0x2C, 0x01]).watt, 300);
      expect(potenzaDa([0x00, 0x00, 0xFF, 0xFF]).watt, 0);
      expect(potenzaDa([0x00]).watt, isNull);
    });
  });

  group('rulli smart (FTMS)', () {
    test('velocità, cadenza e potenza', () {
      final r = rulliDa([
        0x44, 0x00, // flag: cadenza e potenza (velocità c'è sempre)
        0xB2, 0x0C, // 32,50 km/h
        0xB4, 0x00, // 90 rpm (in mezzi giri)
        0xD7, 0x00, // 215 W
      ]);
      expect(r.kmh, 32.5);
      expect(r.rpm, 90);
      expect(r.watt, 215);
    });

    test('con distanza e resistenza in mezzo', () {
      final r = rulliDa([
        0x74, 0x00, // cadenza, distanza, resistenza, potenza
        0x10, 0x0E, // 36 km/h
        0xA0, 0x00, // 80 rpm
        0x10, 0x27, 0x00, // 10000 m
        0x05, 0x00, // resistenza
        0x2C, 0x01, // 300 W
      ]);
      expect(r.kmh, 36);
      expect(r.rpm, 80);
      expect(r.watt, 300);
    });
  });

  test('media e massimo per la seduta ripresa', () {
    final s = Statistiche();
    for (final w in [180, 220, 250]) {
      s.aggiungi(w);
    }
    expect(s.comeLista, [650, 3, 250]);
    expect(s.media, 217);
  });

  test('notifica con i watt', () {
    expect(
      testoNotifica(sport: 'Bici', km: 12.4, mps: 7.5, watt: 210, bpm: 141),
      '12,40 km · 27.0 km/h · 210 W · ♥ 141',
    );
  });
}
