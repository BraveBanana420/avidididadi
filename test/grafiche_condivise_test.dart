import 'dart:convert';

import 'package:allenamenti_app/arrampicata.dart';
import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/l10n/lingua.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:allenamenti_app/registro_forza.dart';
import 'package:allenamenti_app/riepilogo_condiviso.dart';
import 'package:allenamenti_app/screens/condividi_screen.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le grafiche da condividere sport per sport: quali si propongono, i loro
/// numeri e il disegno nei quattro temi.
void main() {
  const tutto = (
    mappa: true,
    giri: true,
    quota: true,
    ripetute: true,
    esercizi: true,
    muscoli: true,
    arrampicata: true,
    grafici: true,
  );
  const niente = (
    mappa: false,
    giri: false,
    quota: false,
    ripetute: false,
    esercizi: false,
    muscoli: false,
    arrampicata: false,
    grafici: false,
  );
  const g = GraficaCondivisa.values;
  GraficaCondivisa n(String nome) => g.byName(nome);

  group('quali grafiche per sport', () {
    test('con tutti i dati: le tre dello sport, i grafici, la tua foto', () {
      final attese = {
        'Bici': ['classica', 'mappa', 'poster'],
        'Corsa': ['mappa', 'kmPerKm', 'poster'],
        'Camminata': ['mappa', 'profilo', 'poster'],
        'Nuoto': ['classica', 'ripetute', 'poster'],
        'Forza': ['esercizi', 'muscoli', 'poster'],
        'Mobilità': ['classica', 'esercizi', 'poster'],
        'Arrampicata': ['seduta', 'progressi', 'poster'],
        'Attività libera': ['classica', 'mappa', 'poster'],
      };
      for (final MapEntry(key: sport, value: nomi) in attese.entries) {
        expect(grafichePer(sport, tutto), [
          ...nomi.map(n),
          GraficaCondivisa.grafici,
          GraficaCondivisa.foto,
        ], reason: sport);
      }
    });

    test('senza dati la classica prende il posto, una volta sola', () {
      // Una corsa senza GPS (mai fatta, ma non deve rompersi).
      expect(grafichePer('Corsa', niente), [
        GraficaCondivisa.classica,
        GraficaCondivisa.poster,
        GraficaCondivisa.foto,
      ]);
      // Altra attività senza GPS: classica, poster e foto.
      expect(grafichePer('Attività libera', niente), [
        GraficaCondivisa.classica,
        GraficaCondivisa.poster,
        GraficaCondivisa.foto,
      ]);
      // La bici sui rulli: niente mappa.
      expect(
        grafichePer('Bici', niente).contains(GraficaCondivisa.mappa),
        isFalse,
      );
    });
  });

  group('i grafici da scorrere', () {
    final via = DateTime(2026, 11, 20, 18);
    List<Campione> serie(int n, double Function(int) v) => [
      for (var i = 0; i < n; i++)
        Campione(via.add(Duration(seconds: 5 * i)), v(i)),
    ];

    test('bici sul rullo: battito, potenza, velocità e cadenza', () {
      // Un'ora di intervalli: 150 W, poi 2 × 6 min a 210 W, pause a 0 W.
      final g = graficiSerie(
        'Bici',
        SerieSessione(
          fc: serie(720, (i) => i < 10 ? 0 : 120 + (i % 120) / 4),
          potenza: serie(720, (i) => i % 100 < 5 ? 0 : (i < 360 ? 150 : 210)),
          velocita: serie(720, (_) => 10), // 36 km/h
          cadenza: serie(720, (i) => i % 100 < 5 ? 0 : 90),
        ),
      );
      expect(g.map((x) => x.nome), [
        l10n.battito,
        l10n.potenza,
        l10n.velocita,
        l10n.cadenza,
      ]);
      // Il battito senza gli zeri del sensore che si collega.
      expect(g[0].secondo.$2, '150');
      // La potenza con gli zeri: smettere di pedalare abbassa la media.
      expect(g[1].primo.$2, '170');
      expect(g[1].secondo.$2, '210');
      expect(g[2].primo, (l10n.media, '36.0', 'km/h'));
      expect(g[3].primo, (l10n.media, '90', 'rpm'));
      expect(g.every((x) => x.punti.length <= 150), isTrue);
    });

    test('corsa: il passo dalla velocità, da fermi non conta', () {
      final g = graficiSerie(
        'Corsa',
        SerieSessione(
          // 5:00/km, un semaforo da fermi e l'ultimo tratto a 4:10/km.
          velocita: serie(600, (i) => i < 300 ? 3.333 : (i < 320 ? 0 : 4.0)),
          altitudine: serie(600, (i) => 200 + (i < 300 ? i / 5 : 60.0)),
        ),
      );
      expect(g.map((x) => x.nome), [l10n.passo, l10n.altitudine]);
      expect(g[0].secondo, (l10n.migliore, '4:10', 'min/km'));
      expect(g[1].primo.$2, '+60');
    });

    test('senza serie niente grafici, con pochi punti nemmeno', () {
      expect(graficiSerie('Corsa', const SerieSessione()), isEmpty);
      expect(
        graficiSerie('Corsa', SerieSessione(fc: serie(9, (_) => 140))),
        isEmpty,
      );
    });
  });

  group('i numeri delle grafiche', () {
    test('km per km dal GPS, con le pause tolte dal tempo', () {
      // Verso nord, 10 m ogni 3 s (5:00 al km); a metà del secondo km
      // una sosta di 5 minuti senza punti.
      final t0 = DateTime(2026, 11, 2, 18);
      final punti = <PuntoGps>[];
      var t = t0;
      for (var i = 0; i <= 250; i++) {
        if (i == 150) t = t.add(const Duration(minutes: 5));
        punti.add(PuntoGps(45 + i * 10 / 111195, 9, t));
        t = t.add(const Duration(seconds: 3));
      }
      final tempi = tempiPerKm(Percorso(punti));
      expect(tempi.length, 2);
      for (final x in tempi) {
        expect(x, closeTo(300, 3));
      }
    });

    test('oltre 15 km le righe si raggruppano', () {
      expect(righeKm([300, 310, 290]), [('1', 300), ('2', 310), ('3', 290)]);
      final mezza = righeKm(List.filled(21, 300));
      expect(mezza.length, 11);
      expect(mezza.first, ('1-2', 300));
      expect(mezza.last, ('21', 300));
    });

    test('nuoto: il passo ai 100 m delle ripetute, senza recuperi', () {
      expect(
        passiRipetute(const [
          IntervalloFatto(
            recupero: false,
            inizioS: 0,
            secondi: 140,
            metri: 100,
          ),
          IntervalloFatto(recupero: true, inizioS: 140, secondi: 20),
          IntervalloFatto(
            recupero: false,
            inizioS: 160,
            secondi: 116,
            metri: 100,
          ),
          IntervalloFatto(
            recupero: false,
            inizioS: 276,
            secondi: 280,
            metri: 200,
          ),
        ]),
        [140, 116, 140],
      );
    });

    test('mobilità: le serie dello stesso esercizio in una riga', () {
      expect(
        eserciziDaTratti(const [
          IntervalloFatto(
            recupero: false,
            inizioS: 0,
            secondi: 120,
            nome: 'Gatto e mucca',
          ),
          IntervalloFatto(
            recupero: false,
            inizioS: 120,
            secondi: 60,
            nome: 'Piccione 1/2',
          ),
          IntervalloFatto(recupero: true, inizioS: 180, secondi: 15),
          IntervalloFatto(
            recupero: false,
            inizioS: 195,
            secondi: 60,
            nome: 'Piccione 2/2',
          ),
        ]),
        [('Gatto e mucca', 120), ('Piccione', 120)],
      );
    });

    test('forza: il record di oggi solo se supera tutte le volte prima', () {
      SerieFatta serie(DateTime d, String nome, double kg) => SerieFatta(
        data: d,
        esercizio: '',
        nome: nome,
        serie: 1,
        ripetizioni: 8,
        kg: kg,
      );
      final prima = DateTime(2026, 10, 29), oggi = DateTime(2026, 11, 5);
      final tutte = [
        serie(prima, 'Squat', 55),
        serie(prima, 'Panca piana', 50),
        serie(oggi, 'Squat', 60),
        serie(oggi, 'Panca piana', 50),
        serie(oggi, 'Affondi', 20), // la prima volta: non è un record
      ];
      expect(recordDelGiorno(tutte, oggi), 'Squat 60 kg (prima 55 kg)');
      expect(recordDelGiorno(tutte.take(2).toList(), prima), isNull);
    });

    test('arrampicata: il grado più alto delle ultime sedute', () {
      SedutaArrampicata a(String id, int giorno, String grado) =>
          SedutaArrampicata(
            idSessione: id,
            data: DateTime(2026, 11, giorno),
            gradoMax: grado,
          );
      final tutte = [
        a('x', 1, '6a'),
        a('y', 3, '6a+'),
        SedutaArrampicata(
          idSessione: 'b',
          data: DateTime(2026, 11, 4),
          disciplina: Disciplina.boulder,
          gradoMax: '6A',
        ),
        a('z', 6, '6b+'),
        a('dopo', 9, '6c'),
      ];
      final p = progressiArrampicata(tutte, tutte[3]);
      expect(p.map((x) => x.$1), ['6a', '6a+', '6b+']);
      expect(p.last.$3, isTrue);
      expect(p.first.$2 < p.last.$2, isTrue);
    });

    test('il poster di ogni sport', () {
      final forza = posterDi(
        Sessione(
          id: 'f',
          data: DateTime(2026, 11, 5),
          sport: 'Forza',
          tipo: 'Gambe',
          durataMin: 50,
        ),
        kgTotali: 4520,
      );
      expect((forza.grande, forza.sotto), ('4520', 'kg sollevati in tutto'));
      expect(forza.etichetta, 'FORZA · GAMBE');

      final arr = posterDi(
        Sessione(
          id: 'a',
          data: DateTime(2026, 11, 6),
          sport: 'Arrampicata',
          durataMin: 130,
        ),
        arrampicata: SedutaArrampicata(
          idSessione: 'a',
          data: DateTime(2026, 11, 6),
          gradoMax: '6b+',
          stile: 'Lavorata',
          chiuse: 10,
        ),
      );
      expect(arr.grande, '6b+');
      expect(arr.sotto, 'il grado più alto di oggi · lavorata');
      expect(arr.etichetta, 'ARRAMPICATA · INDOOR');
      expect(arr.numeri.first, ('Vie', '10', ''));

      final kayak = posterDi(
        Sessione(
          id: 'k',
          data: DateTime(2026, 11, 8),
          sport: 'Attività libera',
          tipo: 'Kayak',
          durataMin: 90,
          distanzaKm: 9.4,
        ),
      );
      expect((kayak.grande, kayak.sotto), ('KAYAK', '1:30 ore'));

      final nuoto = posterDi(
        Sessione(
          id: 'n',
          data: DateTime(2026, 11, 4),
          sport: 'Nuoto',
          durataMin: 40,
          distanzaKm: 1.5,
        ),
      );
      expect((nuoto.grande, nuoto.sotto), ('1500', 'm'));
    });

    test('la classica senza percorso: il primo grafico che c\'è', () {
      final t0 = DateTime(2026, 11, 8, 9);
      final piatta = [
        for (var i = 0; i < 50; i++)
          Campione(t0.add(Duration(minutes: i)), 700),
      ];
      // Niente dati: resta lo spazio (nessun grafico).
      expect(graficoClassica(sport: 'Camminata'), isNull);
      // Quota piatta (senza salita): meglio i km.
      expect(
        graficoClassica(sport: 'Camminata', quota: piatta, tempi: [600, 620]),
        isNotNull,
      );
      expect(
        graficoClassica(sport: 'Camminata', quota: piatta, tempi: [600]),
        isNull,
      );
    });

    test('la salita si conta senza il rumore', () {
      final t0 = DateTime(2026, 11, 8, 9);
      // Sale di 400 m in 200 punti, con un tremolio di ±1 m.
      final quota = [
        for (var i = 0; i < 200; i++)
          Campione(
            t0.add(Duration(seconds: 30 * i)),
            700 + i * 2 + (i.isEven ? 1 : -1),
          ),
      ];
      expect(salitaTotale(quota), closeTo(398, 10));
    });
  });

  group('disegni nei quattro temi', () {
    // Un PNG di 1×1 pixel: basta come "foto della galleria".
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    );
    final oggi = DateTime(2026, 11, 5);
    final corsa = Sessione(
      id: 'c',
      data: oggi,
      sport: 'Corsa',
      tipo: 'Lento',
      durataMin: 52,
      distanzaKm: 10.24,
      fcMedia: 142,
    );
    final camminata = Sessione(
      id: 'w',
      data: oggi,
      sport: 'Camminata',
      durataMin: 102,
      distanzaKm: 7.8,
    );
    final nuoto = Sessione(
      id: 'n',
      data: oggi,
      sport: 'Nuoto',
      tipo: 'Tecnica',
      durataMin: 40,
      distanzaKm: 1.5,
    );
    final forza = Sessione(
      id: 'f',
      data: oggi,
      sport: 'Forza',
      tipo: 'Gambe',
      durataMin: 50,
    );
    final arrampicata = Sessione(
      id: 'a',
      data: oggi,
      sport: 'Arrampicata',
      durataMin: 130,
    );
    final scheda = SedutaArrampicata(
      idSessione: 'a',
      data: oggi,
      luogo: 'Palestra',
      gradoMax: '6b+',
      stile: 'Lavorata',
      chiuse: 10,
      provate: 2,
      corda: 'Da primo',
      progetto: '6c',
    );
    final graficiCorsa = graficiSerie(
      'Corsa',
      SerieSessione(
        fc: [
          for (var i = 0; i < 60; i++)
            Campione(oggi.add(Duration(minutes: i)), 130 + (i % 20) * 2.0),
        ],
        velocita: [
          for (var i = 0; i < 60; i++)
            Campione(oggi.add(Duration(minutes: i)), 3.2 + (i % 7) / 20),
        ],
      ),
    );
    testWidgets('grafici: si scorrono col dito, la pagina torna su', (t) async {
      final viste = <int>[];
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 450,
                child: ImmagineGrafici(
                  sessione: corsa,
                  grafici: graficiCorsa,
                  pagina: 0,
                  onPagina: viste.add,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text(l10n.battito), findsOneWidget);
      await t.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await t.pumpAndSettle();
      expect(viste, [1]);
      expect(find.text(l10n.passo), findsOneWidget);
    });
    final immagini = <String, Widget>{
      'km per km': ImmagineKmPerKm(
        sessione: corsa,
        righe: righeKm([318, 310, 307, 305, 306, 304, 302, 298, 301, 303]),
      ),
      'salita': ImmagineProfilo(
        sessione: camminata,
        quota: [
          for (var i = 0; i < 100; i++)
            Campione(
              oggi.add(Duration(minutes: i)),
              760 + (i < 50 ? i * 8 : (100 - i) * 8),
            ),
        ],
      ),
      'ripetute': ImmagineRipetute(
        sessione: nuoto,
        passi: const [150, 128, 126, 124, 125, 116, 122, 155],
      ),
      'muscoli': ImmagineMuscoli(
        sessione: forza,
        sesso: 'M',
        muscoli: const {'quadricipiti', 'glutei'},
        kgTotali: 4520,
        esercizi: 5,
      ),
      'seduta': ImmagineArrampicata(sessione: arrampicata, seduta: scheda),
      'progressi': ImmagineProgressi(
        sessione: arrampicata,
        seduta: scheda,
        punti: const [('6a', 12, false), ('6a+', 13, false), ('6b+', 15, true)],
      ),
      'foto': ImmagineFoto(sessione: corsa, foto: png),
      'grafici': ImmagineGrafici(
        sessione: corsa,
        grafici: graficiCorsa,
        pagina: 1,
        onPagina: (_) {},
      ),
      'grafici sulla foto': ImmagineGrafici(
        sessione: corsa,
        grafici: graficiCorsa,
        pagina: 0,
        onPagina: (_) {},
        foto: png,
      ),
      'classica con la salita': ImmagineSessione(
        sessione: camminata,
        grafico: graficoClassica(
          sport: 'Camminata',
          quota: [
            for (var i = 0; i < 100; i++)
              Campione(
                oggi.add(Duration(minutes: i)),
                760 + (i < 50 ? i * 8 : (100 - i) * 8),
              ),
          ],
        ),
      ),
      'classica km per km': ImmagineSessione(
        sessione: corsa,
        grafico: graficoClassica(
          sport: 'Corsa',
          tempi: const [318, 310, 307, 305, 306, 304, 302, 298, 301, 303],
        ),
      ),
      'classica battito': ImmagineSessione(
        sessione: corsa,
        grafico: graficoClassica(
          sport: 'Corsa',
          battito: [
            for (var i = 0; i < 60; i++)
              Campione(oggi.add(Duration(minutes: i)), 120 + (i % 20) * 2.0),
          ],
        ),
      ),
    };
    for (final (nome, tema) in [
      ('scuro rosso', creaTema(Brightness.dark)),
      ('chiaro rosso', creaTema(Brightness.light)),
      ('scuro neon', creaTema(Brightness.dark, neon: true)),
      ('chiaro neon', creaTema(Brightness.light, neon: true)),
    ]) {
      for (final MapEntry(key: grafica, value: w) in immagini.entries) {
        testWidgets('$grafica: $nome', (t) async {
          await t.pumpWidget(
            MaterialApp(
              theme: tema,
              home: Scaffold(
                body: Center(
                  child: SizedBox(width: 360, height: 450, child: w),
                ),
              ),
            ),
          );
          expect(find.text('#avidididadi'), findsOneWidget);
          expect(t.takeException(), isNull);
        });
      }
    }
  });
}
