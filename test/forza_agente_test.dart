import 'dart:convert';
import 'dart:io';

import 'package:allenamenti_app/agente_esterno.dart';
import 'package:allenamenti_app/assistente.dart';
import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/forza_agente.dart';
import 'package:allenamenti_app/generatore_forza.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/registro_forza.dart';
import 'package:allenamenti_app/scheda.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalogo = [
    for (final j
        in jsonDecode(File('assets/esercizi.json').readAsStringSync()) as List)
      Esercizio.da(j as Map<String, dynamic>),
  ];
  // Le date partono da lunedì prossimo: il controllo "non prima di oggi" usa
  // il giorno vero.
  final oggi = soloData(DateTime.now());
  final lunedi = oggi.add(Duration(days: 8 - oggi.weekday));

  // Una progressione a corpo libero con i manubri, in tre fasi, come la
  // scriverebbe Claude partendo dalle serie fatte (prima su Freeletics).
  Map<String, Object> busto(int serie, String rip, int rec, [List<int>? kg]) =>
      {
        'nome': 'Busto',
        'giorni_settimana': [1, 4],
        'esercizi': [
          {
            'esercizio': 'Pushups',
            'serie': serie,
            'ripetizioni': rip,
            'recupero_s': rec,
          },
          {
            'esercizio': 'Bent_Over_Two-Dumbbell_Row',
            'serie': serie,
            'ripetizioni': 10,
            'recupero_s': rec,
            'kg': ?kg,
          },
          {'nome': 'Burpees lenti', 'serie': 2, 'ripetizioni': '8'},
        ],
      };
  final graduale = {
    'nome': 'Forza graduale',
    'motivo': 'Parti dalle 3×10 piegamenti che fai già.',
    'fasi': [
      {
        'nome': 'Base',
        'inizio': isoData(lunedi),
        'settimane': 2,
        'giorni': [
          busto(3, '8-10', 90, [12]),
        ],
      },
      {
        'nome': 'Volume',
        'settimane': 3,
        'giorni': [
          busto(4, '10-12', 75, [12, 14, 14, 14]),
        ],
      },
      {
        'nome': 'Carico',
        'settimane': 2,
        'giorni': [
          busto(4, '6-8', 120, [16]),
        ],
      },
    ],
  };

  group('lettura della scheda graduale', () {
    test('ogni fase diventa una scheda, una dopo l\'altra', () {
      final p = propostaForzaDa(graduale, oggi: oggi, catalogo: catalogo);
      expect(p.fasi, hasLength(3));
      expect(p.fasi[0].inizio, lunedi);
      expect(p.fasi[0].fine, lunedi.add(const Duration(days: 13)));
      expect(p.fasi[1].inizio, lunedi.add(const Duration(days: 14)));
      expect(p.fasi[2].fine, lunedi.add(const Duration(days: 7 * 7 - 1)));
      expect(p.fasi[1].nome, 'Forza graduale · Volume');
      expect(p.giorniSettimana, {1, 4});
      expect({for (final f in p.fasi) f.id}, hasLength(3));
    });

    test('gli esercizi del catalogo prendono id e nome dell\'app', () {
      final p = propostaForzaDa(graduale, oggi: oggi, catalogo: catalogo);
      final e = p.fasi[1].giorni.single.esercizi;
      expect(e[0].esercizio, 'Pushups');
      expect(e[0].nome, 'Piegamenti sulle braccia');
      expect(e[0].serie, 4);
      expect(e[0].ripetizioni, '10-12');
      expect(e[0].recuperoS, 75);
      expect(e[1].ripetizioni, '10');
      expect(e[1].kg, [12, 14, 14, 14]);
      // Scritto a mano: resta con il suo nome, senza id.
      expect(e[2].esercizio, '');
      expect(e[2].nome, 'Burpees lenti');
      expect(e[2].recuperoS, 90);
    });

    test('accetta anche il nome dell\'esercizio al posto dell\'id', () {
      expect(
        esercizioDelCatalogo(catalogo, 'piegamenti sulle braccia')?.id,
        'Pushups',
      );
      expect(
        esercizioDelCatalogo(catalogo, 'bent over two dumbbell row')?.id,
        'Bent_Over_Two-Dumbbell_Row',
      );
      expect(esercizioDelCatalogo(catalogo, 'Muscle-up col mantello'), isNull);
    });

    test('un id che non c\'è nell\'app si fa correggere', () {
      final m = jsonDecode(jsonEncode(graduale)) as Map;
      (((m['fasi'] as List)[0]['giorni'] as List)[0]['esercizi'] as List).add({
        'esercizio': 'Freeletics_Aphrodite',
      });
      expect(
        () => propostaForzaDa(m, oggi: oggi, catalogo: catalogo),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'messaggio',
            contains('Freeletics_Aphrodite'),
          ),
        ),
      );
    });

    test('errori: date, settimane, giorni doppi, troppo lunga', () {
      Map<String, Object> con(Map<String, Object> fase) => {
        'fasi': [
          {
            'nome': 'A',
            'settimane': 2,
            'giorni': [busto(3, '10', 90)],
            ...fase,
          },
        ],
      };
      void sbaglia(Map<String, Object> m) => expect(
        () => propostaForzaDa(m, oggi: oggi, catalogo: catalogo),
        throwsFormatException,
      );
      sbaglia(con({'inizio': 'domani'}));
      sbaglia(con({'inizio': isoData(oggi.subtract(const Duration(days: 1)))}));
      sbaglia(con({'settimane': 0}));
      sbaglia(con({'settimane': settimaneMaxForza + 1}));
      sbaglia(
        con({
          'giorni': [busto(3, '10', 90), busto(3, '10', 90)],
        }),
      );
      sbaglia({'fasi': []});
      sbaglia({
        'fasi': [
          for (var i = 0; i < 3; i++)
            {
              'settimane': 6,
              'giorni': [busto(3, '10', 90)],
            },
        ],
      });
      // Una fase che si accavalla a quella prima.
      sbaglia({
        'fasi': [
          {
            'inizio': isoData(lunedi),
            'settimane': 2,
            'giorni': [busto(3, '10', 90)],
          },
          {
            'inizio': isoData(lunedi.add(const Duration(days: 7))),
            'settimane': 2,
            'giorni': [busto(3, '10', 90)],
          },
        ],
      });
    });

    test('senza inizio la prima fase parte oggi', () {
      final p = propostaForzaDa({
        'fasi': [
          {
            'settimane': 1,
            'giorni': [busto(3, '10', 90)],
          },
        ],
      }, oggi: oggi);
      expect(p.inizio, oggi);
      // Una fase sola: la scheda ha il nome della proposta.
      expect(p.fasi.single.nome, p.nome);
    });
  });

  group('dal blocco dell\'assistente', () {
    test('l\'assistente esterno manda la scheda con il codice', () {
      const codice = 'AVD-K7Q2XM';
      final r = leggiRispostaAgente(
        'Ecco la scheda.\n```\n<avidididadi codice="$codice">\n'
        '${jsonEncode({'forza': graduale})}\n</avidididadi>\n```',
        codice,
        catalogo: catalogo,
      );
      expect(r.forza?.fasi, hasLength(3));
      expect(r.motivo, contains('piegamenti'));
    });

    test('anche dalla chat del coach', () {
      final r = leggiProposta(
        'Ti propongo questa.\n<proposta>${jsonEncode({'forza': graduale})}'
        '</proposta>',
        catalogo: catalogo,
      );
      expect(r.errore, isNull);
      expect(r.proposta?.forza?.nome, 'Forza graduale');
    });

    test('il formato spiega il blocco con gli id degli esercizi', () {
      final f = formatoProposte('<a>', '</a>');
      expect(f, contains('"forza"'));
      expect(f, contains('"esercizio": "Pushups"'));
      // Gli id degli esempi esistono davvero.
      expect(
        esercizioDelCatalogo(catalogo, 'Bent_Over_Two-Dumbbell_Row'),
        isNotNull,
      );
    });
  });

  group('nelle schede e nel piano', () {
    final p = propostaForzaDa(graduale, oggi: oggi, catalogo: catalogo);

    test('prende il posto delle schede di forza negli stessi giorni', () {
      final inCorso = Scheda(
        id: 'pt',
        nome: 'Scheda del PT',
        inizio: oggi.subtract(const Duration(days: 20)),
      );
      final futura = Scheda(
        id: 'fut',
        nome: 'Dopo Natale',
        inizio: lunedi.add(const Duration(days: 21)),
      );
      final corsa = Scheda(
        id: 'corsa',
        nome: 'Ripetute',
        sport: 'Corsa',
        inizio: oggi,
      );
      final r = conPropostaForza([inCorso, futura, corsa], p);
      expect(r.accorciate, ['Scheda del PT']);
      expect(r.tolte, ['Dopo Natale']);
      expect(
        r.schede.firstWhere((s) => s.id == 'pt').fine,
        lunedi.subtract(const Duration(days: 1)),
      );
      expect(r.schede.map((s) => s.id), isNot(contains('fut')));
      expect(r.schede.map((s) => s.id), contains('corsa'));
      // La fase giusta in ogni settimana.
      final giovedi4 = lunedi.add(const Duration(days: 7 * 3 + 3));
      expect(schedaDel(r.schede, giovedi4)?.nome, 'Forza graduale · Volume');
      expect(
        schedaDel(r.schede, lunedi.add(const Duration(days: 7 * 6)))?.nome,
        'Forza graduale · Carico',
      );
    });

    test('nei giorni di forza del piano gli esercizi sono quelli scelti', () {
      final giorno = lunedi.add(const Duration(days: 7 * 5 + 3)); // giovedì
      final piano = [
        PianoRiga(data: giorno, fascia: 'Sera', sport: 'Forza', durataMin: 45),
      ];
      final f = conScheda(const PianoForza([], []), piano, p.fasi);
      final passi = f.passi.where(
        (w) => w.id == '$prefissoForza${isoData(giorno)}',
      );
      expect(passi.map((w) => w.esercizio), [
        'Pushups',
        'Bent_Over_Two-Dumbbell_Row',
        '',
      ]);
      expect(passi.first.ripetizioni, '6-8');
      expect(passi.elementAt(1).kg, '16');
    });

    test('i giorni senza forza nella settimana tipo', () {
      final settimana = [
        Slot(giorno: 1, fascia: 'Sera', sport: 'Forza', durataMin: 45),
        Slot(giorno: 4, fascia: 'Sera', sport: 'Corsa', durataMin: 40),
      ];
      expect(giorniSenzaForza(settimana, p), [4]);
    });
  });

  test('il riassunto per l\'assistente ha serie fatte ed esercizi', () {
    final ieri = oggi.subtract(const Duration(days: 1));
    final righe = righeForzaAssistente(
      oggi: oggi,
      catalogo: catalogo,
      attrezzatura: {
        'manubri': [8, 12, 16],
      },
      serie: [
        SerieFatta(
          data: ieri,
          esercizio: 'Pushups',
          nome: 'Piegamenti sulle braccia',
          serie: 1,
          ripetizioni: 12,
        ),
        SerieFatta(
          data: ieri,
          esercizio: 'Pushups',
          nome: 'Piegamenti sulle braccia',
          serie: 2,
          ripetizioni: 10,
        ),
        SerieFatta(
          data: ieri,
          esercizio: 'Bent_Over_Two-Dumbbell_Row',
          nome: 'Rematore',
          serie: 1,
          ripetizioni: 10,
          kg: 12.5,
        ),
        SerieFatta(
          data: ieri,
          esercizio: 'Plank',
          nome: 'Plank',
          serie: 1,
          ripetizioni: 0,
          secondi: 45,
        ),
        // Troppo vecchia.
        SerieFatta(
          data: oggi.subtract(const Duration(days: 60)),
          esercizio: 'Pushups',
          nome: 'Piegamenti',
          serie: 1,
          ripetizioni: 5,
        ),
      ],
      settimana: [
        Slot(giorno: 1, fascia: 'Sera', sport: 'Forza', durataMin: 45),
      ],
    );
    final testo = righe.join('\n');
    expect(testo, contains('manubri (8, 12, 16 kg)'));
    expect(testo, contains('Pushups: 12, 10'));
    expect(testo, contains('Bent_Over_Two-Dumbbell_Row: 10×12,5'));
    expect(testo, contains('Plank: 45 s'));
    expect(testo, isNot(contains(': 5\n')));
    expect(testo, contains('- Pushups: Piegamenti sulle braccia'));
    // Senza bilanciere niente esercizi col bilanciere.
    expect(testo, isNot(contains('- Barbell_Squat:')));
    expect(testo, contains('Forza nella settimana tipo:'));
  });

  test('le righe della forza finiscono nel messaggio all\'assistente', () {
    final c = contestoAllenamento(
      oggi: oggi,
      zone: Zone(fcMax: 190),
      sessioni: const [],
      piano: const [],
      feedback: const [],
      recupero: const [],
      forza: ['- Pushups: Piegamenti sulle braccia'],
    );
    expect(c, contains('Forza:\n- Pushups'));
  });
}
