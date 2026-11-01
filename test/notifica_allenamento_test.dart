import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/notifica_allenamento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ripetuta = Blocco(
    tipo: TipoBlocco.lavoro,
    titolo: 'Ripetute',
    dettaglio: 'Serie 2 di 6 · 400 m',
    intensita: 'zona 4',
    passo: 1,
  );
  const recupero = Blocco(
    tipo: TipoBlocco.recupero,
    titolo: 'Recupero',
    secondi: 90,
    passo: 1,
  );

  test('titolo: esercizio, recupero, pausa, attività libera', () {
    expect(
      titoloNotifica(ripetuta, nome: 'Corsa', libera: false, inPausa: false),
      'Ripetute · Serie 2 di 6 · 400 m',
    );
    expect(
      titoloNotifica(
        recupero,
        nome: 'Corsa',
        libera: false,
        inPausa: false,
        prossimo: ripetuta,
      ),
      'Recupero · poi Ripetute',
    );
    expect(
      titoloNotifica(ripetuta, nome: 'Corsa', libera: false, inPausa: true),
      'In pausa · Ripetute · Serie 2 di 6 · 400 m',
    );
    expect(
      titoloNotifica(ripetuta, nome: 'Camminata', libera: true, inPausa: false),
      'Camminata',
    );
  });

  test('dati: km, passo e battito; solo quello che c\'è', () {
    expect(
      testoNotifica(
        sport: 'Camminata',
        km: 2.351,
        mps: 1000 / 612,
        bpm: 112,
        zona: 2,
      ),
      '2,35 km · 10:12 min/km · ♥ 112 Z2',
    );
    expect(
      testoNotifica(sport: 'Bici', km: 12.4, mps: 7.5),
      '12,40 km · 27.0 km/h',
    );
    // Fermi al semaforo: niente passo infinito.
    expect(testoNotifica(sport: 'Corsa', km: 3, mps: 0), '3,00 km');
    // Forza con la fascia: solo il battito.
    expect(testoNotifica(sport: 'Forza', bpm: 128, zona: 3), '♥ 128 Z3');
    expect(testoNotifica(sport: 'Forza'), '');
  });
}
