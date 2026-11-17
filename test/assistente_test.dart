import 'package:allenamenti_app/assistente.dart';
import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/generatore_endurance.dart';
import 'package:allenamenti_app/llm.dart';
import 'package:allenamenti_app/modifica_sessione.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/test_soglia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final oggi = DateTime(2026, 10, 22); // giovedì
  final lunedi = DateTime(2026, 10, 19);
  PianoRiga r(int giorno, String sport, int min, {String tipo = ''}) =>
      PianoRiga(
        data: lunedi.add(Duration(days: giorno)),
        fascia: 'Mattina',
        sport: sport,
        tipo: tipo,
        durataMin: min,
      );
  // Questa settimana: 300 minuti, domenica libera.
  final piano = [
    r(0, 'Forza', 45),
    r(1, 'Bici', 60),
    r(3, 'Corsa', 60, tipo: 'Tempo run'),
    r(4, 'Forza', 45),
    r(5, 'Corsa', 90, tipo: 'Lungo'),
  ];

  group('lettura della proposta', () {
    test('il blocco <proposta> si separa dal testo', () {
      final (testo, p) = estraiProposta('''Oggi vai piano.
<proposta>
{"modifiche": [{"azione": "cambia", "data": "2026-10-22", "sport": "corsa",
  "durata_min": 40, "tipo": "Lento", "motivo": "HRV bassa"}]}
</proposta>''');
      expect(testo, 'Oggi vai piano.');
      expect(p!.single.azione, Azione.cambia);
      expect(p.single.sport, 'Corsa');
      expect(p.single.durataMin, 40);
    });

    test('anche un blocco ```json va bene; JSON rotto = nessuna proposta', () {
      final (_, p) = estraiProposta(
        'Ecco:\n```json\n{"modifiche":[{"azione":"rimuovi","data":"2026-10-23","sport":"Forza"}]}\n```',
      );
      expect(p!.single.azione, Azione.rimuovi);
      final (testo, rotta) = estraiProposta(
        'Ciao <proposta>{non json</proposta>',
      );
      expect(rotta, isNull);
      expect(testo, 'Ciao');
      expect(estraiProposta('Solo testo').$2, isNull);
    });
  });

  group('controlli sulla proposta', () {
    Modifica m(
      Azione a,
      int giorno,
      String sport, {
      int? min,
      int? nuovo,
      String tipo = '',
    }) => Modifica(
      azione: a,
      data: lunedi.add(Duration(days: giorno)),
      sport: sport,
      durataMin: min,
      tipo: tipo,
      nuovaData: nuovo == null ? null : lunedi.add(Duration(days: nuovo)),
    );

    test('una corsa più facile oggi si applica e resta fissa', () {
      final e = valutaProposta(piano, [
        m(Azione.cambia, 3, 'Corsa', min: 40, tipo: 'Lento'),
      ], oggi);
      expect(e.scartate, isEmpty);
      final corsa = e.piano.firstWhere(
        (x) => x.data == lunedi.add(const Duration(days: 3)),
      );
      expect((corsa.tipo, corsa.durataMin), ('Lento', 40));
      expect(rigaDaAssistente(corsa), true);
      expect(
        descriviModifica(e.accettate.single, piano),
        'Gio 22/10 Corsa: Tempo run 60 min → Lento 40 min',
      );
    });

    test('date passate e sedute inesistenti vengono scartate', () {
      final e = valutaProposta(piano, [
        m(Azione.rimuovi, 1, 'Bici'), // martedì: già passato
        m(Azione.cambia, 4, 'Nuoto', min: 30), // venerdì non c'è nuoto
      ], oggi);
      expect(e.accettate, isEmpty);
      expect(e.scartate.map((x) => x.$2), [
        'la data è già passata',
        "quel giorno non c'è una seduta di Nuoto",
      ]);
    });

    test('non più del 10% di minuti in più nella settimana', () {
      final e = valutaProposta(piano, [
        m(Azione.cambia, 5, 'Corsa', min: 110), // +20: 320 su 300, ok
        m(Azione.aggiungi, 4, 'Corsa', min: 30), // 350: oltre il 10%
      ], oggi);
      expect(e.accettate.length, 1);
      expect(e.scartate.single.$2, contains('oltre +10%'));
    });

    test('la settimana deve tenere un giorno di riposo', () {
      // Settimana con un solo giorno libero (domenica) e tanti minuti.
      final pieno = [for (var g = 0; g < 6; g++) r(g, 'Forza', 60)];
      final e = valutaProposta(pieno, [
        m(Azione.aggiungi, 6, 'Corsa', min: 30),
      ], oggi);
      expect(e.scartate.single.$2, contains('riposo'));
    });

    test('spostare una seduta in un giorno libero', () {
      final e = valutaProposta(piano, [
        m(Azione.sposta, 4, 'Forza', nuovo: 6),
      ], oggi);
      expect(e.accettate.length, 1);
      expect(
        e.piano.any(
          (x) =>
              x.sport == 'Forza' &&
              x.data == lunedi.add(const Duration(days: 6)),
        ),
        true,
      );
    });
  });

  group('riassunto e configurazione', () {
    test('senza permesso niente dati personali', () {
      final c = contestoAllenamento(
        oggi: oggi,
        zone: const Zone(fcMax: 180, fcRiposo: 50),
        sessioni: [
          Sessione(
            id: '1',
            data: oggi.subtract(const Duration(days: 1)),
            sport: 'Corsa',
            tipo: 'Lento',
            durataMin: 45,
            distanzaKm: 8,
          ),
        ],
        piano: piano,
        feedback: const [],
        recupero: const [],
      );
      expect(c, isNot(contains('Atleta')));
      expect(c, contains('2026-10-21 mer Corsa, Lento, 45 min, 8 km'));
      expect(c, contains('2026-10-24 sab Corsa, Lungo, 90 min'));
      expect(c, isNot(contains('2026-10-20'))); // piano passato escluso
    });

    test('test FTP a rampa: watt di ogni gradino e gradino più alto', () {
      final ieri = oggi.subtract(const Duration(days: 1));
      final blocchi = [
        const IntervalloFatto(
          recupero: false,
          inizioS: 0,
          secondi: 600,
          previstoS: 600,
          wattMedi: 112,
          nome: 'Pedalata facile',
          fase: 'riscaldamento',
        ),
        for (var i = 0; i < 12; i++)
          IntervalloFatto(
            recupero: false,
            inizioS: 600 + i * 60,
            secondi: 60,
            previstoS: 60,
            wattMedi: 151 + i * 15,
            wattPrevisti: (150 + i * 15, 150 + i * 15),
            nome: 'Gradino ${i + 1}',
            fase: 'principale',
            fcMedia: 120 + i * 4,
          ),
        // Il 13° gradino lasciato dopo 25 secondi.
        const IntervalloFatto(
          recupero: false,
          inizioS: 1320,
          secondi: 25,
          previstoS: 60,
          wattMedi: 340,
          wattPrevisti: (330, 330),
          nome: 'Gradino 13',
          fase: 'principale',
        ),
      ];
      final c = contestoAllenamento(
        oggi: oggi,
        zone: const Zone(fcMax: 180, fcRiposo: 50),
        ftp: 250,
        sessioni: [
          Sessione(
            id: 'app-bici',
            data: ieri,
            sport: 'Bici',
            tipo: 'Test FTP',
            durataMin: 33,
            potenzaMedia: 190,
            cadenzaMedia: 90,
          ),
        ],
        piano: piano,
        feedback: const [],
        recupero: const [],
        blocchi: {'app-bici': blocchi},
        potenze: [
          PotenzaMigliore(
            idSessione: 'app-bici',
            data: ieri,
            w20: 0,
            w1: 330,
            test: 'rampa',
          ),
        ],
      );
      expect(c, contains('190 W medi, cadenza 90 rpm'));
      expect(c, contains('Test FTP a rampa, miglior minuto 330 W'));
      expect(c, contains('FTP che ne risulta 248 W'));
      expect(
        c,
        contains(
          'Blocco completato con i watt medi più alti: Gradino 12 (316 W)',
        ),
      );
      expect(
        c,
        contains('Gradino 5, principale, 1:00/1:00, 211 W (previsti 210)'),
      );
      expect(c, contains('Gradino 13, principale, 0:25/1:00, NON completato'));
    });

    test('nuoto: passo di ogni tratto e dati scritti a mano', () {
      final ieri = oggi.subtract(const Duration(days: 1));
      final c = contestoAllenamento(
        oggi: oggi,
        zone: const Zone(fcMax: 180, fcRiposo: 50),
        sessioni: [
          Sessione(
            id: 'app-nuoto',
            data: ieri,
            sport: 'Nuoto',
            tipo: 'Tecnica',
            durataMin: 40,
            distanzaKm: 1.5,
          ),
        ],
        piano: piano,
        feedback: const [],
        recupero: const [],
        blocchi: {
          'app-nuoto': const [
            IntervalloFatto(
              recupero: false,
              inizioS: 0,
              secondi: 250,
              metri: 200,
              nome: 'Stile libero facile',
              fase: 'riscaldamento',
            ),
            IntervalloFatto(
              recupero: false,
              inizioS: 250,
              secondi: 48,
              metri: 50,
              nome: 'Stile libero svelto 1/4',
              fase: 'principale',
            ),
            IntervalloFatto(
              recupero: true,
              inizioS: 298,
              secondi: 20,
              previstoS: 20,
              fase: 'principale',
            ),
          ],
        },
        nuotate: [
          SedutaNuoto(
            idSessione: 'app-nuoto',
            data: ieri,
            vasche: 60,
            passo100S: 115,
            stile: 'Stile libero',
          ),
        ],
      );
      expect(
        c,
        contains('60 vasche da 25 m, passo medio 1:55/100 m, stile libero'),
      );
      expect(
        c,
        contains(
          '1. Stile libero facile, riscaldamento, 4:10, 200 m, 2:05/100 m',
        ),
      );
      expect(
        c,
        contains(
          '2. Stile libero svelto 1/4, principale, 0:48, 50 m, 1:36/100 m',
        ),
      );
      expect(c, contains('3. recupero, principale, 0:20/0:20'));
    });

    test('configurazione salvata e riletta, chiave esclusa', () {
      final c = ConfigAssistente()
        ..fornitore = Fornitore.ollama
        ..modelli[Fornitore.ollama] = 'qwen3'
        ..urlOllama = 'http://192.168.1.20:11434'
        ..consensi = {Fornitore.ollama}
        ..datiPersonali = true;
      final righe = [configAssistenteHeader, ...c.toRows()];
      final t = Tabella.da(righe.map((r) => r.join(',')).join('\n'));
      final l = ConfigAssistente.da(t);
      expect(l.fornitore, Fornitore.ollama);
      expect(l.modello, 'qwen3');
      expect(l.urlOllama, 'http://192.168.1.20:11434');
      expect(l.consenso, true);
      expect(l.datiPersonali, true);
      expect(ConfigAssistente().modello, modelliPredefiniti[Fornitore.gemini]);
    });
  });

  group('richieste ai fornitori', () {
    final storia = [MessaggioChat(true, 'Ciao')];

    test('Claude: istruzioni a parte e chiave nell\'intestazione', () {
      final c = ConfigAssistente()..fornitore = Fornitore.claude;
      final r = richiestaPer(c, 'k1', 'SISTEMA', storia);
      expect(r.url.host, 'api.anthropic.com');
      expect(r.intestazioni['x-api-key'], 'k1');
      expect(r.corpo['system'], 'SISTEMA');
      expect(r.corpo['messages'], [
        {'role': 'user', 'content': 'Ciao'},
      ]);
      expect(
        testoRisposta(Fornitore.claude, {
          'content': [
            {'type': 'text', 'text': 'Ok'},
          ],
        }),
        'Ok',
      );
    });

    test('Gemini e OpenAI', () {
      final g = richiestaPer(
        ConfigAssistente()..fornitore = Fornitore.gemini,
        'k2',
        'S',
        storia,
      );
      expect(g.url.path, endsWith('gemini-2.5-flash:generateContent'));
      expect(g.intestazioni['x-goog-api-key'], 'k2');
      expect(
        testoRisposta(Fornitore.gemini, {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Ciao'},
                ],
              },
            },
          ],
        }),
        'Ciao',
      );
      final o = richiestaPer(
        ConfigAssistente()..fornitore = Fornitore.openai,
        'k3',
        'S',
        storia,
      );
      expect(o.intestazioni['Authorization'], 'Bearer k3');
      expect((o.corpo['messages'] as List).first['role'], 'system');
    });

    test('Ollama: indirizzo del PC, senza chiave né streaming', () {
      final c = ConfigAssistente()
        ..fornitore = Fornitore.ollama
        ..urlOllama = 'http://192.168.1.20:11434/';
      final r = richiestaPer(c, null, 'S', storia);
      expect(r.url.toString(), 'http://192.168.1.20:11434/api/chat');
      expect(r.corpo['stream'], false);
      expect(r.intestazioni, isEmpty);
      expect(
        testoRisposta(Fornitore.ollama, {
          'message': {'content': 'Ehi'},
        }),
        'Ehi',
      );
      expect(
        () => testoRisposta(Fornitore.ollama, {}),
        throwsA(isA<ErroreLlm>()),
      );
    });

    test('Ollama: il modello scelto deve essere tra quelli installati', () {
      final installati = modelliOllama({
        'models': [
          {'name': 'gpt-oss:20b'},
          {'name': 'llama3.1:latest'},
        ],
      });
      expect(installati, ['gpt-oss:20b', 'llama3.1:latest']);
      expect(modelloPresente('gpt-oss:20b', installati), true);
      expect(modelloPresente('llama3.1', installati), true);
      expect(modelloPresente('gpt-oss', installati), false);
      expect(modelliOllama({}), isEmpty);
    });

    test('errori comprensibili', () {
      expect(
        spiegaErrore(
          Fornitore.claude,
          401,
          '{"error":{"message":"invalid x-api-key"}}',
        ),
        contains('Chiave API non valida'),
      );
      expect(spiegaErrore(Fornitore.ollama, 404, ''), contains('ollama pull'));
    });
  });

  test('il generatore rispetta le sedute decise dall\'assistente', () {
    final righe = [
      r(3, 'Corsa', 60),
      PianoRiga(
        data: lunedi.add(const Duration(days: 5)),
        fascia: 'Mattina',
        sport: 'Corsa',
        tipo: 'Lento',
        durataMin: 35,
        note: '$notaAssistente: recupero basso',
      ),
    ];
    final p = generaPianoEndurance(
      piano: righe,
      storico: const [],
      sport: {'Corsa'},
      inizio: lunedi,
      da: lunedi,
    );
    final sabato = lunedi.add(const Duration(days: 5));
    expect(p.tipi[(sabato, 'Corsa')], 'Lento');
    expect(
      p.passi.firstWhere((w) => w.id == 'corsa_${isoData(sabato)}').durataTot,
      35,
    );
  });

  group('elenco dei modelli', () {
    test('Gemini: solo i modelli di chat, senza "models/"', () {
      final l = modelliDa(Fornitore.gemini, {
        'models': [
          {
            'name': 'models/gemini-2.5-flash',
            'supportedGenerationMethods': ['generateContent'],
          },
          {
            'name': 'models/gemini-3.1-flash',
            'supportedGenerationMethods': ['generateContent'],
          },
          {
            'name': 'models/gemini-3.1-flash-lite',
            'supportedGenerationMethods': ['generateContent'],
          },
          {
            'name': 'models/gemini-3.2-flash-preview',
            'supportedGenerationMethods': ['generateContent'],
          },
          {
            'name': 'models/text-embedding-004',
            'supportedGenerationMethods': ['embedContent'],
          },
          {
            'name': 'models/gemini-2.5-flash-preview-tts',
            'supportedGenerationMethods': ['generateContent'],
          },
        ],
      });
      expect(l, [
        'gemini-2.5-flash',
        'gemini-3.1-flash',
        'gemini-3.1-flash-lite',
        'gemini-3.2-flash-preview',
      ]);
      // Il più recente stabile della famiglia flash.
      expect(modelloConsigliato(Fornitore.gemini, l), 'gemini-3.1-flash');
    });

    test('OpenAI e Claude', () {
      final o = modelliDa(Fornitore.openai, {
        'data': [
          {'id': 'gpt-5-mini'},
          {'id': 'gpt-5'},
          {'id': 'whisper-1'},
          {'id': 'gpt-4o-realtime'},
          {'id': 'o4-mini'},
        ],
      });
      expect(o, ['gpt-5-mini', 'gpt-5', 'o4-mini']);
      expect(modelloConsigliato(Fornitore.openai, o), 'gpt-5-mini');
      final c = modelliDa(Fornitore.claude, {
        'data': [
          {'id': 'claude-sonnet-5-5'},
          {'id': 'claude-opus-5-5'},
          {'id': 'claude-sonnet-4-5'},
        ],
      });
      expect(modelloConsigliato(Fornitore.claude, c), 'claude-sonnet-5-5');
    });

    test('la chiave sbagliata di Gemini si riconosce anche con errore 400', () {
      expect(
        spiegaErrore(
          Fornitore.gemini,
          400,
          '{"error":{"message":"API key not valid. Please pass a valid API key."}}',
        ),
        startsWith('Chiave API non valida'),
      );
    });

    test("richiesta dell'elenco per Gemini", () {
      final r = richiestaModelli(
        ConfigAssistente()..fornitore = Fornitore.gemini,
        'k',
      );
      expect(r.url.path, '/v1beta/models');
      expect(r.intestazioni['x-goog-api-key'], 'k');
    });
  });

  test('Ollama in chiaro solo nella rete di casa', () {
    String base(String url) => baseOllama(
      ConfigAssistente()
        ..fornitore = Fornitore.ollama
        ..urlOllama = url,
    );
    expect(base('http://192.168.1.10:11434/'), 'http://192.168.1.10:11434');
    expect(base('http://10.0.0.5:11434'), 'http://10.0.0.5:11434');
    expect(base('http://100.101.2.3:11434'), 'http://100.101.2.3:11434');
    expect(base('http://mio-pc.local:11434'), 'http://mio-pc.local:11434');
    expect(base('https://ollama.esempio.it'), 'https://ollama.esempio.it');
    expect(() => base('http://8.8.8.8:11434'), throwsA(isA<ErroreLlm>()));
    expect(() => base('http://ollama.esempio.it'), throwsA(isA<ErroreLlm>()));
    expect(() => base('http://172.32.0.1:11434'), throwsA(isA<ErroreLlm>()));
    expect(() => base('ftp://192.168.1.10'), throwsA(isA<ErroreLlm>()));
    expect(() => base('192.168.1.10:11434'), throwsA(isA<ErroreLlm>()));
  });

  group('il coach con la chiave API propone come l\'assistente esterno', () {
    test('le istruzioni spiegano piano nuovo e allenamenti', () {
      final i = istruzioniAssistente('DATI');
      expect(i, contains('<proposta>'));
      expect(i, contains('"allenamenti"'));
      expect(i, contains('"piano"'));
      expect(i, isNot(contains('avidididadi')));
    });

    test('un allenamento in watt nella risposta', () {
      final r = leggiProposta('''Ecco le ripetute per giovedì.
<proposta>
{"allenamenti": [{"data": "2026-11-06", "sport": "Bici", "nome": "5x4", "motivo": "VO2max",
  "passi": [
    {"fase": "riscaldamento", "minuti": 10, "intensita": "55-65%"},
    {"fase": "principale", "ripeti": 5, "minuti": 4, "intensita": "110%", "recupero_s": 180}
  ]}]}
</proposta>''');
      expect(r.testo, 'Ecco le ripetute per giovedì.');
      expect(r.errore, isNull);
      final a = r.proposta!.allenamenti!.single;
      expect(a.passi, hasLength(2));
      expect(r.proposta!.motivo, 'VO2max');
    });

    test('anche un piano nuovo, pure dentro un blocco di codice', () {
      final r = leggiProposta('''Ti propongo questo.
```json
{"piano": {"da": "2026-11-09", "sedute": [{"data": "2026-11-09", "sport": "Corsa", "durata_min": 40}]}}
```''');
      expect(r.proposta!.piano!.da, DateTime(2026, 11, 9));
      expect(r.proposta!.piano!.sedute, hasLength(1));
    });

    test('blocco rotto o passi sbagliati: si dice perché', () {
      final rotto = leggiProposta(
        'Ok.\n<proposta>{"allenamenti": [</proposta>',
      );
      expect(rotto.testo, 'Ok.');
      expect(rotto.proposta, isNull);
      expect(rotto.errore, contains('non è leggibile'));
      final sbagliato = leggiProposta(
        '<proposta>{"allenamenti": [{"data": "2026-11-06", "sport": "Bici", '
        '"passi": [{"nome": "senza durata"}]}]}</proposta>',
      );
      expect(sbagliato.errore, contains('minuti'));
    });

    test('le modifiche di prima funzionano come sempre', () {
      final (_, m) = estraiProposta(
        '<proposta>{"modifiche": [{"azione": "rimuovi", "data": "2026-11-06", '
        '"sport": "Bici"}]}</proposta>',
      );
      expect(m, hasLength(1));
    });
  });
}
