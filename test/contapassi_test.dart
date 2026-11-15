import 'package:allenamenti_app/contapassi.dart';
import 'package:allenamenti_app/notifica_allenamento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final via = DateTime(2026, 11, 15, 8, 30);
  DateTime dopo(int s) => via.add(Duration(seconds: s));

  test('conta solo i passi fatti dopo la prima lettura', () {
    final c = ContaPassi();
    // Il sensore parte dai passi fatti dall'accensione del telefono.
    c.aggiorna(48210, 1000, attivo: true, ora: via);
    expect(c.passi, 0);
    c.aggiorna(48222, 7000, attivo: true, ora: dopo(6));
    c.aggiorna(48222, 7000, attivo: true, ora: dopo(7));
    c.aggiorna(48240, 16000, attivo: true, ora: dopo(15));
    expect(c.passi, 30);
  });

  test('in pausa (o prima del via) i passi non contano', () {
    final c = ContaPassi();
    c.aggiorna(100, 0, attivo: false, ora: via);
    // Si cammina verso la partenza: niente.
    c.aggiorna(160, 30000, attivo: false, ora: dopo(30));
    expect(c.passi, 0);
    c.aggiorna(270, 90000, attivo: true, ora: dopo(90));
    expect(c.passi, 110);
    // Pausa al bar: 40 passi che non entrano.
    c.aggiorna(310, 200000, attivo: false, ora: dopo(200));
    c.aggiorna(420, 260000, attivo: true, ora: dopo(260));
    expect(c.passi, 220);
  });

  test('telefono riavviato: il totale riparte e non si perde il conto', () {
    final c = ContaPassi(1500); // ripresa di una seduta interrotta
    c.aggiorna(12, 5000, attivo: true, ora: via);
    expect(c.passi, 1500);
    c.aggiorna(72, 35000, attivo: true, ora: dopo(30));
    expect(c.passi, 1560);
    // Un totale più basso di prima: sensore ripartito.
    c.aggiorna(5, 1000, attivo: true, ora: dopo(60));
    c.aggiorna(25, 11000, attivo: true, ora: dopo(70));
    expect(c.passi, 1580);
  });

  test('passi al minuto di adesso, dai momenti dei passi', () {
    final c = ContaPassi();
    c.aggiorna(1000, 0, attivo: true, ora: via);
    expect(c.cadenza(via), isNull);
    // Camminata a 110 passi al minuto; il sensore li dà a gruppi ogni 6 s.
    for (var k = 1; k <= 10; k++) {
      c.aggiorna(1000 + 11.0 * k, 6000.0 * k, attivo: true, ora: dopo(6 * k));
    }
    expect(c.cadenza(dopo(60)), 110);
    // Si accelera: corsa a 170.
    for (var k = 1; k <= 6; k++) {
      c.aggiorna(
        1110 + 17.0 * k,
        60000 + 6000.0 * k,
        attivo: true,
        ora: dopo(60 + 6 * k),
      );
    }
    expect(c.cadenza(dopo(96)), 170);
    // Fermi al semaforo: dopo un po' non si mostra più.
    expect(c.cadenza(dopo(120)), isNull);
    // Si riparte: la sosta non abbassa la cadenza.
    c.aggiorna(1223, 180000, attivo: true, ora: dopo(180));
    expect(c.cadenza(dopo(180)), isNull);
    c.aggiorna(1234, 186000, attivo: true, ora: dopo(186));
    expect(c.cadenza(dopo(186)), 110);
  });

  test('dopo una pausa la cadenza riparte da capo', () {
    final c = ContaPassi();
    c.aggiorna(0, 0, attivo: true, ora: via);
    c.aggiorna(11, 6000, attivo: true, ora: dopo(6));
    c.aggiorna(22, 12000, attivo: true, ora: dopo(12));
    expect(c.cadenza(dopo(12)), 110);
    c.aggiorna(22, 12000, attivo: false, ora: dopo(14));
    c.aggiorna(33, 20000, attivo: true, ora: dopo(20));
    expect(c.cadenza(dopo(20)), isNull);
  });

  test('media dei passi al minuto e numeri con le migliaia', () {
    expect(mediaPassiAlMinuto(6600, const Duration(minutes: 60)), 110);
    expect(mediaPassiAlMinuto(0, const Duration(minutes: 60)), isNull);
    expect(mediaPassiAlMinuto(20, const Duration(seconds: 10)), isNull);
    // Telefono lasciato sul tavolo: pochi passi, niente media.
    expect(mediaPassiAlMinuto(40, const Duration(minutes: 30)), isNull);
    expect(fmtPassi(0), '0');
    expect(fmtPassi(987), '987');
    expect(fmtPassi(1234), '1.234');
    expect(fmtPassi(12345), '12.345');
    expect(fmtPassi(1234567), '1.234.567');
  });

  test('notifica: i passi solo nella camminata', () {
    expect(
      testoNotifica(
        sport: 'Camminata',
        km: 2.351,
        mps: 1000 / 612,
        passi: 3120,
      ),
      '2,35 km · 10:12 min/km · 3.120 passi',
    );
    // Tapis roulant: senza km restano i passi.
    expect(testoNotifica(sport: 'Camminata', passi: 850), '850 passi');
    expect(
      testoNotifica(sport: 'Corsa', km: 5, mps: 1000 / 330, passi: 4800),
      '5,00 km · 5:30 min/km',
    );
  });
}
