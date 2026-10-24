import 'dart:convert';
import 'dart:math';

import 'package:allenamenti_app/agente_esterno.dart';
import 'package:allenamenti_app/assistente.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codice = 'AVD-K7Q2XM';
  final oggi = DateTime(2026, 10, 26); // lunedì

  String blocco(Object json, [String c = codice]) =>
      'Ecco la proposta.\n```\n<avidididadi codice="$c">\n'
      '${jsonEncode(json)}\n</avidididadi>\n```';

  test('codice casuale nel formato giusto', () {
    final a = nuovoCodiceAgente(Random(1));
    expect(a, matches(RegExp(r'^AVD-[A-Z2-9]{6}$')));
    expect(nuovoCodiceAgente(Random(2)), isNot(a));
  });

  test('il messaggio contiene codice e dati, non la logica dell\'app', () {
    final m = messaggioInizialeAgente(
      codice: codice,
      contesto: 'SESSIONI: ...',
      oggi: oggi,
    );
    expect(m, contains('codice="$codice"'));
    expect(m, contains('SESSIONI: ...'));
    expect(
      datiAgente(codice: codice, contesto: 'X', oggi: oggi),
      contains(codice),
    );
  });

  test('legge le modifiche con il codice giusto', () {
    final r = leggiRispostaAgente(
      blocco({
        'modifiche': [
          {
            'azione': 'cambia',
            'data': '2026-10-28',
            'sport': 'Corsa',
            'durata_min': 30,
          },
        ],
      }),
      codice,
    );
    expect(r.modifiche!.single.azione, Azione.cambia);
    expect(r.piano, isNull);
  });

  test('rifiuta risposte senza blocco, con un altro codice o rotte', () {
    expect(() => leggiRispostaAgente('ciao', codice), throwsFormatException);
    expect(
      () =>
          leggiRispostaAgente(blocco({'modifiche': []}, 'AVD-ALTRO1'), codice),
      throwsFormatException,
    );
    expect(
      () => leggiRispostaAgente(
        '<avidididadi codice="$codice">{rotto</avidididadi>',
        codice,
      ),
      throwsFormatException,
    );
    // Dopo lo scollegamento il codice è vuoto: niente passa.
    expect(
      () => leggiRispostaAgente(blocco({'modifiche': []}), ''),
      throwsFormatException,
    );
  });

  Map<String, dynamic> seduta(String data, String sport, int min) => {
    'data': data,
    'sport': sport,
    'durata_min': min,
    'tipo': 'Lento',
  };

  PianoAgente pianoDi(List<Map<String, dynamic>> sedute) => leggiRispostaAgente(
    blocco({
      'piano': {'da': '2026-10-26', 'motivo': 'base', 'sedute': sedute},
    }),
    codice,
  ).piano!;

  test('piano nuovo valido: sostituisce dal giorno di inizio', () {
    final vecchio = [
      PianoRiga(
        data: DateTime(2026, 10, 20),
        fascia: 'Mattina',
        sport: 'Corsa',
        durataMin: 40,
      ),
      PianoRiga(
        data: DateTime(2026, 10, 27),
        fascia: 'Mattina',
        sport: 'Bici',
        durataMin: 60,
      ),
    ];
    final e = valutaPianoAgente(
      piano: vecchio,
      sessioni: const [],
      proposta: pianoDi([
        seduta('2026-10-27', 'Corsa', 40),
        seduta('2026-10-29', 'Forza', 40),
        seduta('2026-11-03', 'Corsa', 45),
        seduta('2026-11-05', 'Forza', 45),
      ]),
      oggi: oggi,
    );
    expect(e.problemi, isEmpty);
    expect(e.applicabile, isTrue);
    // La riga passata resta, la bici del 27 sparisce.
    expect(e.piano.map((r) => r.sport), [
      'Corsa',
      'Corsa',
      'Forza',
      'Corsa',
      'Forza',
    ]);
    expect(e.piano.first.data, DateTime(2026, 10, 20));
    expect(rigaDaAssistente(e.piano[1]), isTrue);
  });

  test(
    'piano nuovo: niente riposo, crescita troppo rapida, sedute sbagliate',
    () {
      final e = valutaPianoAgente(
        piano: const [],
        sessioni: const [],
        proposta: pianoDi([
          for (var g = 26; g <= 31; g++) seduta('2026-10-$g', 'Corsa', 20),
          seduta('2026-11-01', 'Corsa', 10),
          seduta('2026-11-03', 'Corsa', 200),
          seduta('2026-10-20', 'Corsa', 30),
          seduta('2026-11-04', 'Golf', 30),
          seduta('2026-11-05', 'Nuoto', 500),
        ]),
        oggi: oggi,
      );
      expect(e.applicabile, isFalse);
      final testo = e.problemi.join('\n');
      expect(testo, contains('manca un giorno di riposo'));
      expect(testo, contains('troppi'));
      expect(testo, contains("prima dell'inizio"));
      expect(testo, contains('sport non previsto'));
      expect(testo, contains('durata non sensata'));
      expect(correzioneAgente(e.problemi, codice), contains(codice));
    },
  );

  test('la partenza tiene conto delle settimane fatte', () {
    final sessioni = [
      for (var i = 0; i < 4; i++)
        Sessione(
          id: 's$i',
          data: DateTime(2026, 10, 20).subtract(Duration(days: 7 * i)),
          sport: 'Corsa',
          durataMin: 300,
        ),
    ];
    final e = valutaPianoAgente(
      piano: const [],
      sessioni: sessioni,
      proposta: pianoDi([
        seduta('2026-10-27', 'Corsa', 150),
        seduta('2026-10-29', 'Corsa', 150),
      ]),
      oggi: oggi,
    );
    expect(e.problemi, isEmpty);
  });
}
