import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:flutter_test/flutter_test.dart';

/// Corsa e bici: i tratti solo se la seduta ha una struttura, i chilometri
/// in più in una riga, e le sedute sul rullo ricostruite dal programma.
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

  test('rullo senza blocchi salvati: i tratti dal programma, fino a dove '
      'si è arrivati', () {
    final inizio = DateTime(2026, 11, 10, 7, 14);
    // Sweet spot 3 × 8 chiuso dopo 46 minuti (previsti 53).
    final watt = [
      for (var s = 0; s < 46 * 60; s++)
        Campione(
          inizio.add(Duration(seconds: s)),
          s < 600 ? 110 : ((s - 600) % 660 < 480 ? 180 : 100),
        ),
    ];
    final l = intervalliDalPiano(
      sweetSpot,
      inizio: inizio,
      secondi: 46 * 60,
      potenza: watt,
    );
    expect(l.map((i) => i.nome), [
      'Pedalata agile',
      'Sweet spot 1/3',
      '',
      'Sweet spot 2/3',
      '',
      'Sweet spot 3/3',
      '',
      'Sciolto',
    ]);
    expect(l[1].secondi, 480);
    expect(l[1].wattMedi, 180);
    expect(l[2].recupero, isTrue);
    expect(l[2].wattMedi, 100);
    // L'ultimo è tagliato: 3 minuti dei 10 previsti.
    expect(l.last.secondi, 180);
    expect(l.last.previstoS, 600);
    expect(l.fold(0, (t, i) => t + i.secondi), 46 * 60);
    // Abbinati alla seduta prendono le sue sezioni.
    final fasi = fasiDegliIntervalli(
      abbinaAlPiano('Bici', l, sweetSpot),
      sweetSpot,
    );
    expect(fasi.first, 'riscaldamento');
    expect(fasi[1], 'principale');
    expect(fasi.last, 'defaticamento');
  });

  test('passi a distanza: i tempi non si conoscono, niente ricostruzione', () {
    final aMetri = [
      WorkoutStep(
        id: 'x',
        sport: 'Bici',
        nome: '',
        durataTot: 0,
        ordine: 1,
        fase: 'principale',
        descrizione: 'Giro',
        serie: '2',
        ripetizioni: '',
        distanzaM: '5000',
        durataMin: '',
        intensita: '',
        recuperoS: '',
        note: '',
      ),
    ];
    expect(
      intervalliDalPiano(aMetri, inizio: DateTime(2026), secondi: 3000),
      isEmpty,
    );
  });
}
