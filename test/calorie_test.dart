import 'package:allenamenti_app/calorie.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ora = Duration(hours: 1);

  test('corsa 10 km in un\'ora, 70 kg, senza battito: circa 740 kcal', () {
    final c = stimaCalorie(sport: 'Corsa', tempo: ora, km: 10, pesoKg: 70)!;
    expect(c.totali, closeTo(736, 2));
    expect(c.attive, closeTo(666, 2)); // meno 1 kcal/kg/h da fermi
  });

  test('camminata a 5 km/h: circa un terzo della corsa', () {
    final c = stimaCalorie(sport: 'Camminata', tempo: ora, km: 5, pesoKg: 70)!;
    expect(c.totali, closeTo(237, 2));
    expect(c.attive, closeTo(167, 2));
  });

  test('bici con la potenza: 200 W per un\'ora sono 720 kcal attive', () {
    final c = stimaCalorie(
      sport: 'Bici',
      tempo: ora,
      km: 28,
      potenzaMedia: 200,
      fcMedia: 140,
      pesoKg: 72,
      eta: 35,
      sesso: 'Uomo',
    )!;
    expect(c.attive, 720);
    expect(c.totali, 792);
    // La potenza basta anche senza peso.
    expect(
      stimaCalorie(sport: 'Bici', tempo: ora, potenzaMedia: 200)!.attive,
      720,
    );
  });

  test('con il battito (uomo, 35 anni, 75 kg, 145 bpm per 45 min)', () {
    final c = stimaCalorie(
      sport: 'Corsa',
      tempo: const Duration(minutes: 45),
      km: 8,
      fcMedia: 145,
      pesoKg: 75,
      eta: 35,
      sesso: 'Uomo',
    )!;
    expect(c.totali, closeTo(627.6, 1));
    expect(c.attive, closeTo(571.3, 1));
  });

  test('donna: la sua formula', () {
    final perMinuto = kcalMinutoDaBattito(
      fcMedia: 150,
      pesoKg: 60,
      eta: 30,
      sesso: 'Donna',
    )!;
    expect(perMinuto, closeTo(9.88, 0.01));
  });

  test('battito basso (mobilità): la formula non vale, si usa il MET', () {
    final c = stimaCalorie(
      sport: 'Mobilità',
      tempo: const Duration(minutes: 30),
      fcMedia: 85,
      pesoKg: 70,
      eta: 35,
      sesso: 'Uomo',
    )!;
    expect(c.totali, closeTo(87.5, 0.1)); // 2,5 MET × 70 kg × 0,5 h
  });

  test('senza peso e senza potenza non si stima', () {
    expect(stimaCalorie(sport: 'Corsa', tempo: ora, km: 10), isNull);
    expect(
      stimaCalorie(sport: 'Corsa', tempo: Duration.zero, pesoKg: 70),
      isNull,
    );
  });

  test('MET della bici per velocità, e al chiuso senza km', () {
    expect(metDi('Bici', 15), 4);
    expect(metDi('Bici', 27), 12);
    expect(metDi('Bici', 0), 7);
    expect(metDi('Forza', 0), 5);
  });
}
