import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('numero: "NaN" e "Infinity" valgono 0, la virgola va bene', () {
    expect(numero('5,2'), 5.2);
    expect(numero('NaN'), 0);
    expect(numero('Infinity'), 0);
    expect(numero('-Infinity'), 0);
    expect(numero('abc'), 0);
  });

  Sessione? riga(Map<String, String> v) {
    final t = Tabella.da(toCsv([v.keys.toList(), v.values.toList()]))!;
    return Sessione.da(t, t.righe.single);
  }

  test('valori impossibili: nei limiti, senza bloccare', () {
    final s = riga({
      'data': '2026-10-24',
      'sport': 'Corsa',
      'durata_min': 'NaN',
      'distanza_km': '-5',
      'fc_media': '9999',
      'fc_max': 'Infinity',
      'rpe': '42',
      'calorie_attive': '1e12',
      'passi': '-1',
    })!;
    expect(s.durataMin, 0);
    expect(s.distanzaKm, 0);
    expect(s.fcMedia, 250);
    expect(s.fcMax, 0);
    expect(s.rpe, 10);
    expect(s.calorieAttive, 20000);
    expect(s.passi, 0);
  });

  test('una corsa vera resta com\'è', () {
    final s = riga({
      'data': '2026-10-24',
      'sport': 'Corsa',
      'durata_min': '99',
      'distanza_km': '14,54',
      'fc_media': '131',
      'note': 'Pistoia Corsa',
    })!;
    expect(s.durataMin, 99);
    expect(s.distanzaKm, 14.54);
    expect(s.fcMedia, 131);
    expect(s.note, 'Pistoia Corsa');
  });

  test('testi lunghissimi si accorciano', () {
    final s = riga({
      'id_sessione': 'x' * 5000,
      'data': '2026-10-24',
      'sport': 'Bici',
      'note': 'n' * 100000,
    })!;
    expect(s.id.length, 100);
    expect(s.note.length, 2000);
  });
}
