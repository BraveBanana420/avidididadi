import 'package:allenamenti_app/intensita.dart';
import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutStep _passo(int ordine, String nome, String intensita) => WorkoutStep(
  id: 'corsa-ripetute',
  sport: 'Corsa',
  nome: 'Ripetute',
  durataTot: 50,
  ordine: ordine,
  fase: 'Principale',
  descrizione: nome,
  serie: '1',
  ripetizioni: '',
  distanzaM: '',
  durataMin: '10',
  intensita: intensita,
  recuperoS: '',
  note: '',
);

void main() {
  // Massima 190, a riposo 50: zona 2 da 134, zona 3 da 148, zona 4 da 162.
  const zone = Zone(fcMax: 190, fcRiposo: 50);
  final inizio = DateTime(2026, 11, 14, 7);

  test('il battito diventa un livello dentro la zona', () {
    expect(livelloBattito(148, zone), 3);
    expect(livelloBattito(155, zone), closeTo(3.5, 0.01));
    expect(livelloBattito(60, zone), lessThan(1));
    expect(livelloBattito(230, zone), lessThanOrEqualTo(6));
  });

  test('la velocità diventa un livello rispetto alla soglia', () {
    // Soglia 4:10 al km = 4 m/s.
    expect(livelloVelocita(4, 4), closeTo(4.71, 0.01));
    expect(livelloVelocita(3.3, 4), closeTo(2.45, 0.01));
    expect(livelloVelocita(0, 4), 0);
    expect(livelloVelocita(9, 4), 6);
    // Più forte, più in alto.
    expect(livelloVelocita(3.6, 4), greaterThan(livelloVelocita(3.3, 4)));
  });

  test('la soglia stimata: la corsa più veloce di almeno 20 minuti', () {
    Sessione corsa(
      int giorniFa,
      int min,
      double km, [
      String sport = 'Corsa',
    ]) => Sessione(
      id: 'c$giorniFa',
      data: inizio.subtract(Duration(days: giorniFa)),
      sport: sport,
      tipo: '',
      durataMin: min,
      distanzaKm: km,
    );
    expect(sogliaCorsa(const [], inizio), isNull);
    final v = sogliaCorsa([
      corsa(3, 50, 9), // 3 m/s
      corsa(10, 40, 9.6), // 4 m/s
      corsa(12, 10, 3), // corta: non conta
      corsa(300, 40, 12), // vecchia
      corsa(5, 60, 30, 'Bici'),
    ], inizio);
    expect(v, closeTo(4, 0.01));
  });

  group('previsto e fatto', () {
    final passi = [
      _passo(1, 'Riscaldamento', 'zona 2'),
      _passo(2, 'Ripetuta', '4:30/km'),
      _passo(3, 'Defaticamento', 'facile, a sensazione'),
    ];
    const tratti = [
      IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: 600,
        nome: 'Riscaldamento',
      ),
      IntervalloFatto(
        recupero: false,
        inizioS: 600,
        secondi: 300,
        nome: 'Ripetuta 1/2',
      ),
      IntervalloFatto(recupero: true, inizioS: 900, secondi: 120),
      IntervalloFatto(
        recupero: false,
        inizioS: 1020,
        secondi: 300,
        nome: 'Ripetuta 2/2',
      ),
      IntervalloFatto(
        recupero: false,
        inizioS: 1320,
        secondi: 600,
        nome: 'Defaticamento',
      ),
    ];

    test('una fascia per blocco con un obiettivo, in zone o al passo', () {
      final f = fasceIntensita(tratti, passi, soglia: 4);
      expect(f.length, 3);
      expect(
        (f[0].da, f[0].a, f[0].giu, f[0].su, f[0].passo),
        (0, 600, 2.0, 3.0, false),
      );
      // 4:30/km = 3,70 m/s, con il 5% di margine sopra e sotto.
      expect(f[1].passo, isTrue);
      expect((f[1].da, f[1].a), (600, 900));
      expect(f[1].giu, closeTo(livelloVelocita(3.70 * 0.95, 4), 0.02));
      expect(f[1].su, greaterThan(f[1].giu));
      expect(f[2].da, 1020);
      // Senza soglia i passi al km non si possono mettere tra le zone.
      expect(fasceIntensita(tratti, passi).length, 1);
    });

    test('la linea: battito nei blocchi a zona, passo in quelli a passo', () {
      final f = fasceIntensita(tratti, passi, soglia: 4);
      List<Campione> ogni10(double Function(int s) v) => [
        for (var s = 0; s < 1920; s += 10)
          Campione(inizio.add(Duration(seconds: s)), v(s)),
      ];
      final serie = SerieSessione(
        fc: ogni10((_) => 140),
        velocita: ogni10((s) => s >= 600 && s < 900 ? 3.7 : 2.8),
      );
      final linea = lineaIntensita(serie, inizio, f, zone, soglia: 4);
      double a(int s) =>
          linea.firstWhere((p) => p.s > s && p.s <= s + 15).livello;
      // Riscaldamento a 140 bpm: dentro la zona 2.
      expect(a(300), inInclusiveRange(2.0, 3.0));
      // Ripetuta al passo giusto: dentro la sua fascia.
      expect(a(700), inInclusiveRange(f[1].giu, f[1].su));
      // Senza battito si usa il passo dappertutto.
      final soloPasso = lineaIntensita(
        SerieSessione(velocita: serie.velocita),
        inizio,
        f,
        zone,
        soglia: 4,
      );
      expect(soloPasso, isNotEmpty);
      expect(
        lineaIntensita(
          SerieSessione(velocita: serie.velocita),
          inizio,
          f,
          zone,
        ),
        isEmpty,
      );
    });
  });
}
