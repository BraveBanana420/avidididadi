import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Corsa e bici: i tratti solo se la seduta ha una struttura, i chilometri
/// in più in una riga.
void main() {
  WorkoutStep passo(
    int ordine,
    String nome,
    String fase,
    double minuti, {
    int serie = 1,
    int recupero = 0,
    String sport = 'Bici',
  }) => WorkoutStep(
    id: 'x',
    sport: sport,
    nome: 'Seduta',
    durataTot: 0,
    ordine: ordine,
    fase: fase,
    descrizione: nome,
    serie: '$serie',
    ripetizioni: '',
    distanzaM: '',
    durataMin: '$minuti',
    intensita: '',
    recuperoS: recupero == 0 ? '' : '$recupero',
    note: '',
  );

  final lungo = [
    passo(1, 'Corsa lunga continua', 'principale', 70, sport: 'Corsa'),
  ];
  final sweetSpot = [
    passo(1, 'Pedalata agile', 'riscaldamento', 10),
    passo(2, 'Sweet spot', 'principale', 8, serie: 3, recupero: 180),
    passo(3, 'Sciolto', 'defaticamento', 10),
  ];

  IntervalloFatto giro(int secondi, double metri, {String nome = ''}) =>
      IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: secondi,
        metri: metri,
        fcMedia: 140,
        wattMedi: 245,
        nome: nome,
      );

  test('un lungo è un passo solo: niente tratti; le ripetute sì', () {
    expect(sedutaStrutturata(lungo), isFalse);
    expect(sedutaStrutturata(sweetSpot), isTrue);
    expect(sedutaStrutturata(const []), isFalse);
  });

  test('i chilometri in più a fine seduta: una riga sola con le somme', () {
    // Caso reale: lungo da 15 km, 10 abbinati e cinque giri in più.
    final lista = [
      giro(3888, 10130, nome: 'Corsa lunga continua'),
      giro(405, 1000),
      giro(425, 1000),
      giro(462, 1000),
      giro(465, 1000),
      giro(439, 896),
    ];
    final uniti = conFuoriProgrammaUniti(lista);
    expect(uniti.length, 2);
    expect(uniti.last.nome, '');
    expect(uniti.last.metri, 4896);
    expect(uniti.last.secondi, 2196);
    expect(rigaIntervallo(uniti.last, 'Corsa'), startsWith('4,90 km · 36:36'));
    // Un tratto in più solo, o nessun nome: resta com'è.
    expect(conFuoriProgrammaUniti(lista.take(2).toList()).length, 2);
    expect(conFuoriProgrammaUniti(lista.skip(1).toList()).length, 5);
  });
}
