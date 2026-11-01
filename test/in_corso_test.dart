import 'dart:convert';

import 'package:allenamenti_app/dati_live.dart';
import 'package:allenamenti_app/in_corso.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final partenza = DateTime(2026, 11, 1, 8, 10);
  WorkoutStep passo(int ordine, String descrizione, {String durata = ''}) =>
      WorkoutStep(
        id: 'corsa-lenta',
        sport: 'Corsa',
        nome: 'Corsa lenta',
        durataTot: 40,
        ordine: ordine,
        fase: 'Corpo',
        descrizione: descrizione,
        serie: '',
        ripetizioni: '',
        distanzaM: '',
        durataMin: durata,
        intensita: 'zona 2',
        recuperoS: '',
        note: 'Respira col naso, ritmo da chiacchiera',
      );

  final seduta = AllenamentoInCorso(
    sport: 'Corsa',
    tipo: 'Lento',
    nome: 'Corsa lenta',
    libera: false,
    passi: [
      passo(1, 'Riscaldamento', durata: '10'),
      passo(2, 'Corsa continua', durata: '30'),
    ],
    indice: 1,
    finito: false,
    registra: true,
    totale: const Duration(minutes: 32, seconds: 5),
    blocco: const Duration(minutes: 22, seconds: 5),
    partenza: partenza,
    salvato: partenza.add(const Duration(minutes: 33)),
    tempi: {0: const Duration(minutes: 10)},
    fatte: {3: (10, 22.5)},
    punti: [
      PuntoGps(45.4642, 9.19, partenza.add(const Duration(minutes: 1)), 4.5),
      PuntoGps(45.4651, 9.19, partenza.add(const Duration(minutes: 2)), 6),
    ],
    metri: 5230,
    giri: [
      for (var k = 1; k <= 5; k++)
        (numero: k, metri: 1000, tempo: const Duration(minutes: 6, seconds: 4)),
    ],
    fcSomma: 140 * 1900,
    fcN: 1900,
    fcMax: 158,
  );

  test('salvata e riletta resta uguale', () {
    final r = AllenamentoInCorso.daJson(
      jsonDecode(jsonEncode(seduta.toJson())) as Map<String, dynamic>,
    )!;
    expect(r.sport, 'Corsa');
    expect(r.passi.map((p) => p.descrizione), [
      'Riscaldamento',
      'Corsa continua',
    ]);
    expect(r.passi.last.note, 'Respira col naso, ritmo da chiacchiera');
    expect(r.indice, 1);
    expect(r.totale, seduta.totale);
    expect(r.blocco, seduta.blocco);
    expect(r.partenza, partenza);
    expect(r.tempi, {0: const Duration(minutes: 10)});
    expect(r.fatte, {3: (10, 22.5)});
    expect(r.punti.length, 2);
    expect(r.punti.last.lat, 45.4651);
    expect(r.punti.last.t, partenza.add(const Duration(minutes: 2)));
    expect(r.punti.first.precisione, 4.5);
    expect(r.metri, 5230);
    expect(r.giri.length, 5);
    expect(r.giri.last.tempo, const Duration(minutes: 6, seconds: 4));
    expect((r.fcSomma / r.fcN).round(), 140);
    expect(r.fcMax, 158);
    expect(r.riassunto, 'Corsa lenta · 32 min · 5,23 km');
  });

  test('file rovinato: non si propone', () {
    expect(AllenamentoInCorso.daJson({'sport': 'Corsa'}), isNull);
  });

  test('dopo la ripresa il km seguente si misura dal passaggio giusto', () {
    final g = GiriLive(1000)
      ..ripristina(seduta.giri, 5230, const Duration(minutes: 32, seconds: 5));
    // Il 6° km arriva 6 minuti dopo la ripresa, a 6000 m.
    final giro = g.aggiorna(6000, const Duration(minutes: 37, seconds: 25));
    expect(giro?.numero, 6);
    // 37:25 - 5 × 6:04 (30:20) = 7:05
    expect(giro?.tempo, const Duration(minutes: 7, seconds: 5));
  });
}
