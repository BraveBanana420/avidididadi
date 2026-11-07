import 'dart:convert';

import 'package:allenamenti_app/agente_esterno.dart';
import 'package:allenamenti_app/allenamento_agente.dart';
import 'package:allenamenti_app/allenamento_arrampicata.dart';
import 'package:allenamenti_app/assistente.dart';
import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // I due allenamenti presi da uno screenshot, come li scriverebbe GPT.
  final cinquanta = {
    'nome': '50-50',
    'categoria': 'Capacità aerobica',
    'tipi': ['vie', 'boulder'],
    'durata_min': 45,
    'data': '2026-11-10',
    'fascia': 'Sera',
    'descrizione': 'Giri misti: metà via facile, metà al limite a vista.',
    'da_segnare': 'grado medio tra le due parti',
    'esercizi': [
      {
        'nome': 'Vie: metà facile, metà difficile',
        'serie': 3,
        'ripetizioni': 4,
        'recupero_s': 600,
        'intensita': 'facile + a vista',
      },
    ],
  };
  final trave = {
    'nome': '7:3s 40%',
    'categoria': 'Capacità aerobica',
    'tipi': ['trave'],
    'durata_min': 20,
    'esercizi': [
      {
        'nome': 'Sospensioni',
        'serie': 5,
        'ripetizioni': 6,
        'lavoro_s': 7,
        'pausa_s': 3,
        'recupero_s': 120,
        'intensita': '40%',
      },
    ],
  };
  const codice = 'AVD-K7Q2XM';
  String blocco(Object json) =>
      '```\n<avidididadi codice="$codice">\n${jsonEncode(json)}\n</avidididadi>\n```';

  test('si leggono nome, tipi, durata ed esercizi', () {
    final a = AllenamentoArrampicata.da(cinquanta, id: 'x1');
    expect(a.nome, '50-50');
    expect(a.tipi, {'vie', 'boulder'});
    expect(a.minuti, 45);
    expect(a.esercizi.single.serie, 3);
    expect(a.esercizi.single.ripetizioni, 4);
    expect(
      a.esercizi.single.riassunto,
      '3 serie · 4 ripetizioni · recupero 10 min · facile + a vista',
    );
    final t = AllenamentoArrampicata.da(trave, id: 'x2');
    expect(
      t.esercizi.single.riassunto,
      '5 serie · 6 × 7 s / 3 s · recupero 2 min · 40%',
    );
  });

  test('la trave: ripetizioni a tempo con la pausa, recupero tra le serie', () {
    final t = AllenamentoArrampicata.da(trave, id: 'x2');
    final b = blocchiDa(t.passi('w'));
    final lavori = b.where(
      (x) => x.tipo == TipoBlocco.lavoro && x.titolo.startsWith('Sospensioni'),
    );
    expect(lavori, hasLength(30)); // 5 serie × 6 ripetizioni
    expect(lavori.first.secondi, 7);
    expect(lavori.first.dettaglio, 'Ripetizione 1 di 6 · 7 s');
    expect(lavori.first.titolo, 'Sospensioni · serie 1 di 5');
    expect(b[1].tipo, TipoBlocco.recupero);
    expect(b[1].secondi, 3);
    final tra = b.where((x) => x.titolo == 'Recupero tra le serie').toList();
    expect(tra, hasLength(4));
    expect(tra.first.secondi, 120);
  });

  test('le vie: ripetizioni a "Fatto", 10 minuti tra le serie', () {
    final a = AllenamentoArrampicata.da(cinquanta, id: 'x1');
    final b = blocchiDa(a.passi('w'));
    final vie = b.where((x) => x.titolo.startsWith('Vie')).toList();
    expect(vie, hasLength(12));
    expect(vie.every((x) => x.secondi == null), isTrue);
    expect(
      b.where((x) => x.titolo == 'Recupero tra le serie').first.secondi,
      600,
    );
  });

  test(
    'nel calendario: al posto della seduta di arrampicata, con la durata',
    () {
      final a = AllenamentoArrampicata.da(cinquanta, id: 'x1');
      final g = a.perIlGiorno(DateTime(2026, 11, 10), fascia: 'Sera');
      expect(g.durataMin, 45);
      expect(g.passi.first.id, 'agente-2026-11-10-arrampicata');
      final piano = pianoCon([
        PianoRiga(
          data: DateTime(2026, 11, 10),
          fascia: 'Pomeriggio',
          sport: 'Arrampicata',
          durataMin: 90,
        ),
      ], g);
      expect(piano.single.tipo, '50-50');
      expect(piano.single.durataMin, 45);
    },
  );

  test('si salvano nel CSV e si rileggono uguali', () {
    final a = AllenamentoArrampicata.da(trave, id: 'abc123');
    final testo = toCsv([allenamentiArrampicataHeader, a.toRow()]);
    final t = Tabella.da(testo)!;
    final b = AllenamentoArrampicata.daRiga(t, t.righe.single)!;
    expect(b.nome, a.nome);
    expect(b.tipi, a.tipi);
    expect(b.durataMin, 20);
    expect(b.esercizi.single.lavoroS, 7);
    expect(b.esercizi.single.pausaS, 3);
    expect(b.esercizi.single.intensita, '40%');
  });

  test(
    'dall\'assistente: con data nel calendario, senza solo nella raccolta',
    () {
      final r = leggiRispostaAgente(
        blocco({
          'arrampicata': [cinquanta, trave],
        }),
        codice,
      );
      final p = r.arrampicata!;
      expect(p, hasLength(2));
      expect(p.first.data, DateTime(2026, 11, 10));
      expect(p.first.fascia, 'Sera');
      expect(p.last.data, isNull);
      expect(p.first.allenamento.id, isNot(p.last.allenamento.id));
    },
  );

  test('errori chiari', () {
    expect(
      () => proposteArrampicata([
        {...trave, 'data': 'martedì prossimo'},
      ], DateTime(2026, 11, 5)),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => AllenamentoArrampicata.da({'nome': 'x', 'esercizi': []}, id: 'a'),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => AllenamentoArrampicata.da({
        'nome': 'x',
        'esercizi': [
          {'nome': 'y', 'serie': 99},
        ],
      }, id: 'a'),
      throwsA(isA<FormatException>()),
    );
  });

  test('le istruzioni spiegano il formato, sia all\'agente sia al coach', () {
    expect(istruzioniAgente(codice), contains('"arrampicata"'));
    expect(istruzioniAgente(codice), contains('lavoro_s'));
    expect(istruzioniAssistente('DATI'), contains('"arrampicata"'));
    final r = leggiProposta(
      'Ecco.\n<proposta>${jsonEncode({
        'arrampicata': [trave],
      })}</proposta>',
    );
    expect(r.proposta!.arrampicata, hasLength(1));
  });
}
