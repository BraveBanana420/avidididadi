import 'dart:convert';

import 'package:allenamenti_app/dati_live.dart';
import 'package:allenamenti_app/in_corso.dart';
import 'package:allenamenti_app/screens/opzioni_allenamento_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 1, 9);

  /// Passa al rilevatore una velocità al secondo per [secondi], da [da].
  bool? per(RilevaSosta r, double mps, int secondi, {required int da}) {
    bool? cambiato;
    for (var s = da; s < da + secondi; s++) {
      if (r.aggiorna(mps, t0.add(Duration(seconds: s)))) cambiato = r.fermo;
    }
    return cambiato;
  }

  test('"solo da fermo": salita off-road a 2,5 km/h non ferma il tempo', () {
    final r = RilevaSosta(sogliaDi(ModoPausa.ferma, 4));
    expect(per(r, 2.5 / 3.6, 120, da: 0), isNull);
    expect(r.fermo, isFalse);
  });

  test('"sotto i 4 km/h": la stessa salita invece lo ferma', () {
    final r = RilevaSosta(sogliaDi(ModoPausa.sotto, 4));
    expect(per(r, 2.5 / 3.6, 120, da: 0), isTrue);
  });

  test('semaforo: ferma dopo 8 s, riparte dopo 3 s di corsa', () {
    final r = RilevaSosta(sogliaFermo);
    per(r, 3, 60, da: 0); // corsa
    expect(per(r, 0.1, 7, da: 60), isNull); // 7 s: ancora no
    expect(per(r, 0.1, 3, da: 67), isTrue); // all'8° secondo sì
    expect(per(r, 3, 2, da: 70), isNull); // 2 s di corsa: ancora fermo
    expect(per(r, 3, 2, da: 72), isFalse); // al 3° riparte
  });

  test('allacciarsi una scarpa per 5 s non conta', () {
    final r = RilevaSosta(sogliaFermo);
    per(r, 3, 30, da: 0);
    expect(per(r, 0, 5, da: 30), isNull);
    expect(per(r, 3, 30, da: 35), isNull);
    expect(r.fermo, isFalse);
  });

  test('vicino alla soglia non va avanti e indietro', () {
    final r = RilevaSosta(sogliaDi(ModoPausa.sotto, 4)); // 1,11 m/s
    expect(per(r, 1.0, 10, da: 0), isTrue);
    // 1,2 m/s è sopra la soglia ma non del 20%: resta in pausa.
    expect(per(r, 1.2, 20, da: 10), isNull);
    expect(per(r, 1.5, 4, da: 30), isFalse);
  });

  test('senza velocità (GPS perso) non decide niente', () {
    final r = RilevaSosta(sogliaFermo);
    for (var s = 0; s < 30; s++) {
      expect(r.aggiorna(null, t0.add(Duration(seconds: s))), isFalse);
    }
  });

  test('una seduta salvata prima delle soste si rilegge', () {
    final j = {
      'sport': 'Camminata',
      'tipo': '',
      'nome': 'Camminata',
      'libera': true,
      'passi': <Object>[],
      'indice': 0,
      'finito': false,
      'registra': true,
      'totale_ms': 600000,
      'blocco_ms': 600000,
      'partenza': t0.toIso8601String(),
      'salvato': t0.toIso8601String(),
      'tempi': <String, Object>{},
      'fatte': <String, Object>{},
      'punti': <Object>[],
      'metri': 900.0,
      'giri': <Object>[],
      'fc': [0, 0, 0],
    };
    final r = AllenamentoInCorso.daJson(
      jsonDecode(jsonEncode(j)) as Map<String, dynamic>,
    )!;
    expect(r.soste, Duration.zero);
    expect(r.fermo, Duration.zero);
    final con = AllenamentoInCorso.daJson(
      jsonDecode(jsonEncode({...j, 'soste_ms': 45000, 'fermo_ms': 12000}))
          as Map<String, dynamic>,
    )!;
    expect(con.soste, const Duration(seconds: 45));
    expect(con.fermo, const Duration(seconds: 12));
    expect(con.alChiuso, isFalse);
    final rulli = AllenamentoInCorso.daJson(
      jsonDecode(jsonEncode({...j, 'al_chiuso': true})) as Map<String, dynamic>,
    )!;
    expect(rulli.alChiuso, isTrue);
  });

  test('soglia scritta bene', () {
    expect(fmtSoglia(4), '4');
    expect(fmtSoglia(4.5), '4,5');
  });
}
