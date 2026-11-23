import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutStep passo(
  int ordine,
  String descrizione, {
  String sport = 'Forza',
  String serie = '',
  String rip = '',
  String metri = '',
  String minuti = '',
  String recupero = '',
}) => WorkoutStep(
  id: 'w',
  sport: sport,
  nome: 'Prova',
  durataTot: 30,
  ordine: ordine,
  fase: 'principale',
  descrizione: descrizione,
  serie: serie,
  ripetizioni: rip,
  distanzaM: metri,
  durataMin: minuti,
  intensita: '',
  recuperoS: recupero,
  note: '',
);

void main() {
  test('serie a ripetizioni con recupero in mezzo e prima del passo dopo', () {
    final b = blocchiDa([
      passo(1, 'Squat', serie: '3', rip: '8-10', recupero: '90'),
      passo(2, 'Plank', serie: '2', rip: '30 s', recupero: '45'),
    ]);
    expect(b.map((x) => (x.tipo, x.secondi)), [
      (TipoBlocco.lavoro, null),
      (TipoBlocco.recupero, 90),
      (TipoBlocco.lavoro, null),
      (TipoBlocco.recupero, 90),
      (TipoBlocco.lavoro, null),
      (TipoBlocco.recupero, 90), // prima del plank
      (TipoBlocco.lavoro, 30),
      (TipoBlocco.recupero, 45),
      (TipoBlocco.lavoro, 30), // ultimo: niente recupero dopo
    ]);
    expect(b.first.dettaglio, 'Serie 1 di 3 · 8-10 ripetizioni');
    expect(b[1].dettaglio, 'Poi serie 2 di 3');
    expect(b.map((x) => x.passo).toSet(), {0, 1});
  });

  test('tempo dai minuti o dai secondi, "per lato" vale doppio', () {
    expect(secondiDi(passo(1, 'Corsa', minuti: '10')), 600);
    expect(secondiDi(passo(1, 'Corsa', minuti: '2,5')), 150);
    expect(secondiDi(passo(1, 'Allungamento', rip: '30 s per lato')), 60);
    expect(secondiDi(passo(1, 'Affondi', rip: '10 per lato')), isNull);
    expect(secondiDi(passo(1, 'Vasche', metri: '200')), isNull);
  });

  test('"30 s per lato": destra, pausa per girarsi, poi sinistra', () {
    final b = blocchiDa([
      passo(1, 'Allungamento dei flessori', serie: '2', rip: '30 s per lato'),
    ]);
    // Niente più "Cambia lato a metà" su un minuto unico: ogni lato ha il
    // suo conto alla rovescia.
    expect(b.map((x) => (x.tipo, x.secondi, x.lato, x.serie)), [
      (TipoBlocco.lavoro, 30, latoDestro, 1),
      (TipoBlocco.recupero, pausaCambioLato, latoSinistro, 1),
      (TipoBlocco.lavoro, 30, latoSinistro, 1),
      (TipoBlocco.lavoro, 30, latoDestro, 2),
      (TipoBlocco.recupero, pausaCambioLato, latoSinistro, 2),
      (TipoBlocco.lavoro, 30, latoSinistro, 2),
    ]);
    expect(b.first.dettaglio, 'Serie 1 di 2 · Lato destro · 30 s');
    expect(dettaglioBreve(b[2]), 'Serie 1 di 2 · Lato sinistro');
    // La pausa si chiama "Cambia lato", non "Recupero".
    expect(b[1].cambioLato, isTrue);
    expect(titoloRecupero(b[1]), 'Cambia lato');
    expect(b.where((x) => x.cambioLato).length, 2);
    expect(b.map((x) => x.passo).toSet(), {0});
  });

  test('"per lato" anche nei piani creati in inglese e in greco', () {
    for (final rip in ['30 s per side', '30 δευτ. ανά πλευρά']) {
      expect(secondiDi(passo(1, 'Stretch', rip: rip)), 60, reason: rip);
      expect(blocchiDa([passo(1, 'Stretch', rip: rip)]).map((x) => x.lato), [
        latoDestro,
        latoSinistro,
        latoSinistro,
      ], reason: rip);
    }
    expect(secondiDi(passo(1, 'Plank', rip: '45 δευτ.')), 45);
  });

  test('a ripetizioni per lato resta un blocco solo, con "Fatto"', () {
    final b = blocchiDa([
      passo(1, 'Rematore', serie: '3', rip: '8-12 per lato'),
    ]);
    expect(b.map((x) => (x.secondi, x.lato)), [
      (null, 0),
      (null, 0),
      (null, 0),
    ]);
  });

  test('fartlek: tratti veloci a tempo e recuperi corricchiando', () {
    final b = blocchiDa([
      passo(1, 'Corsa facile', sport: 'Corsa', minuti: '10'),
      passo(
        2,
        'Corsa veloce',
        sport: 'Corsa',
        serie: '6',
        minuti: '2',
        recupero: '120',
      ),
      passo(3, 'Corsa facile', sport: 'Corsa', minuti: '10'),
    ]);
    expect(b.where((x) => x.tipo == TipoBlocco.lavoro).length, 8);
    expect(b.where((x) => x.tipo == TipoBlocco.recupero).length, 6);
    expect(b[2].note, contains('senza fermarti'));
    final totale = b.fold(0, (t, x) => t + (x.secondi ?? 0));
    expect(totale, 10 * 60 + 6 * 120 + 6 * 120 + 10 * 60);
  });

  test('nuoto a distanza: si va avanti toccando', () {
    final b = blocchiDa([passo(1, 'Stile libero', serie: '4', metri: '50')]);
    expect(b.length, 4);
    expect(b.every((x) => !x.aTempo), true);
    expect(b.first.dettaglio, 'Serie 1 di 4 · 50 m');
  });

  test('formato del cronometro', () {
    expect(fmtTimer(const Duration(seconds: 65)), '1:05');
    expect(fmtTimer(const Duration(minutes: 62, seconds: 3)), '1:02:03');
  });
}
