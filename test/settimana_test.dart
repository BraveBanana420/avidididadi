import 'package:allenamenti_app/generator.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lunedi = DateTime(2026, 10, 26);
  final prima = [
    Slot(giorno: 1, fascia: 'Mattina', sport: 'Forza', durataMin: 45),
    Slot(giorno: 6, fascia: 'Mattina', sport: 'Corsa', durataMin: 60),
  ];
  final piano = generaPiano(prima, lunedi, 1);
  final fine = piano.map((r) => r.data).reduce((a, b) => a.isAfter(b) ? a : b);

  test('aggiungere la domenica la porta in tutte le domeniche', () {
    final dopo = [
      ...prima,
      Slot(giorno: 7, fascia: 'Sera', sport: 'Mobilità', durataMin: 20),
    ];
    expect(giorniCambiati(prima, dopo), {7});
    final nuovo = applicaSettimana(
      piano: piano,
      prima: prima,
      dopo: dopo,
      da: lunedi,
      fine: fine,
    );
    final domeniche = nuovo.where((r) => r.sport == 'Mobilità').toList();
    expect(domeniche, isNotEmpty);
    expect(domeniche.every((r) => r.data.weekday == 7), true);
    // Gli altri giorni restano gli stessi oggetti: le modifiche a mano non si perdono.
    expect(
      nuovo.where((r) => r.sport != 'Mobilità').every(piano.contains),
      true,
    );
  });

  test('i giorni da tenere (già fatti) non cambiano', () {
    final dopo = [
      prima.first,
      Slot(giorno: 6, fascia: 'Mattina', sport: 'Bici', durataMin: 90),
    ];
    final primoSabato = lunedi.add(const Duration(days: 5));
    final nuovo = applicaSettimana(
      piano: piano,
      prima: prima,
      dopo: dopo,
      da: lunedi,
      fine: fine,
      daTenere: (d) => d == primoSabato,
    );
    expect(nuovo.firstWhere((r) => r.data == primoSabato).sport, 'Corsa');
    expect(
      nuovo
          .where((r) => r.data.weekday == 6 && r.data != primoSabato)
          .every((r) => r.sport == 'Bici'),
      true,
    );
  });

  test(
    'riportare tutta la settimana: ogni giorno con attività viene rifatto',
    () {
      expect(giorniCambiati(const [], prima), {1, 6});
    },
  );
}
