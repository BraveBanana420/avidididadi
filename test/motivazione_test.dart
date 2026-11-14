import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/motivazione.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Venerdì 13 novembre 2026; il lunedì di quella settimana è il 9.
  final oggi = DateTime(2026, 11, 13);
  var n = 0;
  Sessione s(DateTime d, {String sport = 'Corsa', double km = 0}) =>
      Sessione(id: 's${n++}', data: d, sport: sport, distanzaKm: km);

  group('settimane di fila', () {
    test('nessuna sessione: zero', () {
      expect(settimaneDiFila(const [], oggi), 0);
    });

    test('tre settimane con questa compresa', () {
      final x = [
        s(DateTime(2026, 11, 10)),
        s(DateTime(2026, 11, 8)), // domenica della settimana prima
        s(DateTime(2026, 10, 26)), // lunedì di due settimane prima
      ];
      expect(settimaneDiFila(x, oggi), 3);
      expect(settimanaFatta(x, oggi), true);
    });

    test('questa settimana ancora vuota: la fila non si interrompe', () {
      final x = [s(DateTime(2026, 11, 4)), s(DateTime(2026, 10, 30))];
      expect(settimaneDiFila(x, oggi), 2);
      expect(settimanaFatta(x, oggi), false);
    });

    test('una settimana saltata interrompe la fila', () {
      final x = [
        s(DateTime(2026, 11, 10)),
        s(DateTime(2026, 10, 28)), // la settimana del 2 novembre è vuota
        s(DateTime(2026, 10, 20)),
      ];
      expect(settimaneDiFila(x, oggi), 1);
    });

    test("a cavallo del cambio dell'ora (25 ottobre 2026)", () {
      final x = [for (var w = 0; w < 5; w++) s(DateTime(2026, 11, 11 - 7 * w))];
      expect(settimaneDiFila(x, oggi), 5);
    });
  });

  group('traguardi', () {
    List<Sessione> tante(int quante, DateTime ultima) => [
      for (var i = 0; i < quante; i++)
        s(DateTime(ultima.year, ultima.month, ultima.day - i)),
    ];

    test('il decimo allenamento, fatto ieri', () {
      expect(traguardoRecente(tante(10, DateTime(2026, 11, 12)), oggi), 10);
    });

    test('undici allenamenti: niente', () {
      expect(traguardoRecente(tante(11, oggi), oggi), isNull);
    });

    test('il decimo di una settimana fa non si festeggia più', () {
      expect(traguardoRecente(tante(10, DateTime(2026, 11, 6)), oggi), isNull);
    });

    test('senza sessioni: niente', () {
      expect(traguardoRecente(const [], oggi), isNull);
    });
  });

  group('distanza più lunga', () {
    test('la corsa di ieri batte tutte le altre', () {
      final x = [
        s(DateTime(2026, 10, 1), km: 5),
        s(DateTime(2026, 10, 8), km: 6.2),
        s(DateTime(2026, 11, 12), km: 8.04),
      ];
      expect(distanzaRecord(x, oggi), 'La tua corsa più lunga: 8,0 km');
    });

    test('con due sole corse non è un record', () {
      final x = [
        s(DateTime(2026, 10, 8), km: 6.2),
        s(DateTime(2026, 11, 12), km: 8),
      ];
      expect(distanzaRecord(x, oggi), isNull);
    });

    test('il record vecchio non si ripete', () {
      final x = [
        s(DateTime(2026, 10, 1), km: 10),
        s(DateTime(2026, 10, 8), km: 6.2),
        s(DateTime(2026, 11, 12), km: 8),
      ];
      expect(distanzaRecord(x, oggi), isNull);
    });

    test('nuoto in metri, e gli sport non si mescolano', () {
      final x = [
        s(DateTime(2026, 10, 1), sport: 'Nuoto', km: 0.5),
        s(DateTime(2026, 10, 8), sport: 'Nuoto', km: 0.6),
        s(DateTime(2026, 11, 13), sport: 'Nuoto', km: 0.8),
        s(DateTime(2026, 11, 1), km: 12),
      ];
      expect(distanzaRecord(x, oggi), 'La tua nuotata più lunga: 800 m');
    });
  });

  group('righe in Oggi', () {
    test('niente da dire: nessuna riga', () {
      final x = [s(DateTime(2026, 11, 10)), s(DateTime(2026, 10, 1))];
      expect(spinte(sessioni: x, serie: const [], oggi: oggi), isEmpty);
    });

    test('fila con la settimana già fatta: un complimento', () {
      final x = [
        s(DateTime(2026, 11, 10)),
        s(DateTime(2026, 11, 4)),
        s(DateTime(2026, 10, 1)),
      ];
      final r = spinte(sessioni: x, serie: const [], oggi: oggi);
      expect(r.single.testo, '2 settimane di fila: grande!');
    });

    test('fila con la settimana ancora da fare: un invito gentile', () {
      final x = [
        s(DateTime(2026, 11, 4)),
        s(DateTime(2026, 10, 30)),
        s(DateTime(2026, 10, 1)),
      ];
      final r = spinte(sessioni: x, serie: const [], oggi: oggi);
      expect(r.single.tipo, TipoSpinta.fila);
      expect(r.single.testo, '2 settimane di fila. Vai per la 3?');
    });

    test('primo allenamento', () {
      final r = spinte(sessioni: [s(oggi)], serie: const [], oggi: oggi);
      expect(r.single.testo, 'Primo allenamento fatto!');
    });
  });
}
