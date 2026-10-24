import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/widget_home.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final oggi = DateTime(2026, 10, 23); // venerdì
  PianoRiga r(int giorno, String sport, {String tipo = '', int min = 45}) =>
      PianoRiga(
        data: DateTime(2026, 10, giorno),
        fascia: 'Mattina',
        sport: sport,
        tipo: tipo,
        durataMin: min,
      );

  final dati = datiWidget(
    piano: [
      r(19, 'Forza'),
      r(22, 'Corsa', tipo: 'Fartlek'),
      r(23, 'Forza'),
      r(24, 'Corsa', tipo: 'Lungo', min: 60),
      r(25, 'Riposo'),
    ],
    sessioni: [
      Sessione(
        id: 'a',
        data: DateTime(2026, 10, 22),
        sport: 'Corsa',
        durataMin: 40,
      ),
    ],
    oggi: oggi,
    scuro: true,
    cartellaIcone: '/icone',
    haPassi: (r) => r.sport == 'Forza',
  );
  final giorni = dati['giorni'] as Map<String, dynamic>;

  test('due settimane da lunedì, una voce per giorno', () {
    expect(giorni.length, 14);
    expect(giorni.keys.first, '2026-10-19');
    expect(giorni.keys.last, '2026-11-01');
  });

  test('oggi: seduta da fare con il pulsante per iniziare', () {
    final g = giorni['2026-10-23'];
    expect(g['stato'], 'previsto');
    expect(g['titolo'], 'Forza');
    expect(g['sottotitolo'], '45 min · mattina');
    expect(g['passi'], true);
    expect(g['icona'], '/icone/forza.png');
  });

  test('giorni fatti, da fare e di riposo per i cerchi della settimana', () {
    expect(giorni['2026-10-22']['stato'], 'fatto');
    expect(giorni['2026-10-22']['cerchio'], 'fatto');
    expect(giorni['2026-10-22']['coloreCerchio'], isNot(0));
    expect(giorni['2026-10-19']['cerchio'], 'previsto'); // non fatto
    expect(giorni['2026-10-24']['titolo'], 'Lungo');
    expect(giorni['2026-10-24']['sottotitolo'], 'Corsa · 60 min · mattina');
    expect(giorni['2026-10-25']['stato'], 'riposo');
    expect(giorni['2026-10-25']['cerchio'], 'vuoto');
  });

  test('i colori seguono il tema scelto nell\'app', () {
    expect(dati['scuro'], true);
    expect((dati['colori'] as Map)['accento'], 0xFFFF3B47);
  });
}
