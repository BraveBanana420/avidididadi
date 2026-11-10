import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gli intervalli di una nuotata vera (Garmin con "registro allenamento",
/// letta da intervals.icu): 200 + 4 × 50 + 4 × 200 = 1200 m.
void main() {
  Map<String, Object?> tratto(
    String tipo,
    int da,
    int a, [
    double? metri,
    int fc = 0,
  ]) => {
    'type': tipo,
    'start_time': da,
    'end_time': a,
    'elapsed_time': a - da,
    'moving_time': a - da,
    'distance': metri,
    'average_heartrate': fc,
  };

  final risposta = {
    'id': 'i208265343',
    'icu_intervals': [
      tratto('WORK', 0, 332, 200, 109),
      tratto('WORK', 332, 465, 50, 119),
      tratto('RECOVERY', 465, 517, null, 117),
      tratto('WORK', 517, 632, 50, 122),
      tratto('RECOVERY', 632, 648, null, 137),
      tratto('WORK', 648, 737, 50, 127),
      tratto('RECOVERY', 737, 758, null, 123),
      tratto('WORK', 758, 843, 50, 148),
      tratto('RECOVERY', 843, 909, null, 121),
      tratto('WORK', 909, 1203, 200, 117),
      tratto('RECOVERY', 1203, 1291, null, 123),
      tratto('WORK', 1291, 1596, 200, 144),
      tratto('RECOVERY', 1596, 1656, null, 133),
      tratto('WORK', 1656, 1961, 200, 148),
      tratto('RECOVERY', 1961, 2018, null, 138),
      tratto('WORK', 2018, 2363, 200, 136),
      tratto('RECOVERY', 2363, 2375, null, 139),
    ],
  };

  WorkoutStep passo(
    int ordine,
    String nome,
    int metri, {
    int serie = 1,
    String fase = 'principale',
  }) => WorkoutStep(
    id: 'nuoto_2026-11-10',
    sport: 'Nuoto',
    nome: 'Tecnica',
    durataTot: 40,
    ordine: ordine,
    fase: fase,
    descrizione: nome,
    serie: '$serie',
    ripetizioni: '',
    distanzaM: '$metri',
    durataMin: '',
    intensita: '',
    recuperoS: '20',
    note: '',
  );

  final piano = [
    passo(1, 'Riscaldamento', 200),
    passo(2, 'Gambe con tavoletta', 50, serie: 4),
    passo(3, 'Stile libero', 200, serie: 3),
    passo(4, 'Defaticamento', 200),
  ];

  test('da intervals.icu: lavoro e recuperi, con metri, tempo e battito', () {
    final l = intervalliDaIcu(risposta);
    expect(l.length, 17);
    final lavoro = l.where((i) => !i.recupero).toList();
    expect(lavoro.length, 9);
    expect(lavoro.fold(0.0, (t, i) => t + i.metri), 1200);
    expect(
      rigaIntervallo(l.first, 'Nuoto'),
      '200 m · 5:32 · 2:46/100 m · FC 109',
    );
    expect(rigaIntervallo(l[2], 'Nuoto'), 'Recupero 0:52');
    expect(intervalliDaIcu({'icu_intervals': null}), isEmpty);
    expect(intervalliDaIcu('errore'), isEmpty);
  });

  test('i metri combaciano col programma: ogni tratto prende il suo nome', () {
    final l = conNomiDelPiano(intervalliDaIcu(risposta), piano);
    expect(l.where((i) => !i.recupero).map((i) => i.nome), [
      'Riscaldamento',
      'Gambe con tavoletta 1/4',
      'Gambe con tavoletta 2/4',
      'Gambe con tavoletta 3/4',
      'Gambe con tavoletta 4/4',
      'Stile libero 1/3',
      'Stile libero 2/3',
      'Stile libero 3/3',
      'Defaticamento',
    ]);
    expect(l.where((i) => i.recupero).every((i) => i.nome.isEmpty), isTrue);
  });

  test('un passo fatto in due tratti resta lo stesso passo', () {
    final spezzato = [
      const IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: 160,
        metri: 100,
      ),
      const IntervalloFatto(
        recupero: false,
        inizioS: 160,
        secondi: 170,
        metri: 100,
      ),
      const IntervalloFatto(
        recupero: false,
        inizioS: 330,
        secondi: 80,
        metri: 50,
      ),
    ];
    expect(conNomiDelPiano(spezzato, piano).map((i) => i.nome), [
      'Riscaldamento',
      'Riscaldamento',
      'Gambe con tavoletta 1/4',
    ]);
  });

  test('se non combacia ci si ferma: niente nomi sbagliati', () {
    final altro = [
      const IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: 330,
        metri: 200,
      ),
      const IntervalloFatto(
        recupero: false,
        inizioS: 330,
        secondi: 700,
        metri: 400,
      ),
      const IntervalloFatto(
        recupero: false,
        inizioS: 1030,
        secondi: 80,
        metri: 50,
      ),
    ];
    expect(conNomiDelPiano(altro, piano).map((i) => i.nome), [
      'Riscaldamento',
      '',
      '',
    ]);
    // Senza programma restano come sono.
    expect(
      conNomiDelPiano(altro, const []).every((i) => i.nome.isEmpty),
      isTrue,
    );
  });

  test('salvati e riletti restano uguali', () {
    final l = intervalliDaIcu(risposta);
    final r = intervalliDaCsv(intervalliCsv(l));
    expect(r.length, l.length);
    expect(
      r.map((i) => rigaIntervallo(i, 'Nuoto')),
      l.map((i) => rigaIntervallo(i, 'Nuoto')),
    );
    expect(fileIntervalli('icu-i208265343'), 'intervalli_icu_i208265343.csv');
  });

  test('corsa e bici: passo al km e velocità', () {
    const km = IntervalloFatto(
      recupero: false,
      inizioS: 0,
      secondi: 300,
      metri: 1000,
      fcMedia: 150,
    );
    expect(rigaIntervallo(km, 'Corsa'), '1,00 km · 5:00 · 5:00/km · FC 150');
    expect(passoIntervallo(km, 'Bici'), '12,0 km/h');
  });

  test('tornando nell\'app si risincronizza, ma non a ogni cambio di app', () {
    final ora = DateTime(2026, 11, 10, 14);
    expect(daRisincronizzare(null, ora), isFalse); // avvio ancora in corso
    expect(
      daRisincronizzare(ora.subtract(const Duration(minutes: 2)), ora),
      isFalse,
    );
    expect(
      daRisincronizzare(ora.subtract(const Duration(minutes: 40)), ora),
      isTrue,
    );
  });

  test(
    'corretti a mano: una ripetuta in meno, l\'ultimo è il defaticamento',
    () {
      // In programma 3 × 200 e poi il defaticamento da 200: fatte 2 ripetute.
      final fatti = [
        for (final m in [200.0, 50.0, 50.0, 50.0, 50.0, 200.0, 200.0, 200.0])
          IntervalloFatto(recupero: false, inizioS: 0, secondi: 300, metri: m),
      ];
      final auto = conNomiDelPiano(fatti, piano);
      // Da sola l'app non può saperlo: lo chiama terza ripetuta.
      expect(auto.last.nome, 'Stile libero 3/3');
      expect(nomiDeiPassi(piano), [
        'Riscaldamento',
        'Gambe con tavoletta',
        'Stile libero',
        'Defaticamento',
      ]);
      // A mano: nome corretto e un recupero aggiunto; salvato e riletto.
      final corretti = [
        ...auto.take(7),
        const IntervalloFatto(recupero: true, inizioS: 0, secondi: 45),
        auto.last.conNome('Defaticamento'),
      ];
      final t = Tabella.da(
        [
          intervalliModificatiHeader.join(','),
          for (final r in righeIntervalli('icu-i1', corretti)) r.join(','),
          for (final r in righeIntervalli('icu-i2', auto.take(2).toList()))
            r.join(','),
        ].join('\n'),
      );
      final letti = intervalliModificatiDa(t!);
      expect(letti.keys, ['icu-i1', 'icu-i2']);
      expect(letti['icu-i1']!.length, 9);
      expect(letti['icu-i1']!.last.nome, 'Defaticamento');
      expect(letti['icu-i1']![7].recupero, isTrue);
      expect(rigaIntervallo(letti['icu-i1']![7], 'Nuoto'), 'Recupero 0:45');
      expect(letti['icu-i2']!.map((i) => i.nome), [
        'Riscaldamento',
        'Gambe con tavoletta 1/4',
      ]);
    },
  );
  test(
    'ogni tratto prende la sezione del suo passo, i recuperi quella di prima',
    () {
      final passi = [
        passo(1, 'Riscaldamento', 200, fase: 'riscaldamento'),
        passo(2, 'Gambe con tavoletta', 50, serie: 4),
        passo(3, 'Stile libero', 200, serie: 3),
        passo(4, 'Defaticamento', 200, fase: 'defaticamento'),
      ];
      final l = conNomiDelPiano(intervalliDaIcu(risposta), passi);
      final fasi = fasiDegliIntervalli(l, passi);
      expect(fasi.length, l.length);
      expect(fasi.first, 'riscaldamento'); // 200 m
      expect(fasi[1], 'principale'); // Gambe 1/4
      expect(fasi[2], 'principale'); // recupero dopo Gambe
      expect(fasi[13], 'principale'); // Stile libero 3/3
      expect(fasi[15], 'defaticamento'); // ultimi 200 m
      expect(fasi.last, 'defaticamento'); // il recupero finale
    },
  );

  test('stesso nome in due sezioni: vale quella che viene dopo', () {
    final passi = [
      passo(1, 'Stile libero', 100, fase: 'riscaldamento'),
      passo(2, 'Stile libero', 100, serie: 2),
    ];
    const l = [
      IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: 120,
        metri: 100,
        nome: 'Stile libero',
      ),
      IntervalloFatto(
        recupero: false,
        inizioS: 130,
        secondi: 110,
        metri: 100,
        nome: 'Stile libero 1/2',
      ),
      IntervalloFatto(
        recupero: false,
        inizioS: 250,
        secondi: 110,
        metri: 100,
        nome: 'Stile libero 2/2',
      ),
    ];
    expect(fasiDegliIntervalli(l, passi), [
      'riscaldamento',
      'principale',
      'principale',
    ]);
  });

  test('i tratti senza nome o fuori programma restano senza sezione', () {
    final passi = [passo(1, 'Riscaldamento', 200, fase: 'riscaldamento')];
    const l = [
      IntervalloFatto(
        recupero: false,
        inizioS: 0,
        secondi: 300,
        metri: 200,
        nome: 'Riscaldamento',
      ),
      IntervalloFatto(recupero: true, inizioS: 300, secondi: 30),
      IntervalloFatto(recupero: false, inizioS: 330, secondi: 300, metri: 200),
      IntervalloFatto(recupero: true, inizioS: 630, secondi: 30),
      IntervalloFatto(
        recupero: false,
        inizioS: 660,
        secondi: 90,
        metri: 50,
        nome: 'Farfalla',
      ),
    ];
    expect(fasiDegliIntervalli(l, passi), [
      'riscaldamento',
      'riscaldamento',
      '',
      '',
      '',
    ]);
    expect(fasiDegliIntervalli(l, const []), ['', '', '', '', '']);
  });

  group('corsa e bici a tempo', () {
    // Fartlek ricostruito sul Garmin: 15 min, 6 × 2 min con 1 min di
    // recupero, 10 min di defaticamento.
    final fartlek = [
      _passoCorsa(1, 'riscaldamento', 'Riscaldamento', minuti: '15'),
      _passoCorsa(
        2,
        'principale',
        'Veloce',
        minuti: '2',
        serie: 6,
        recupero: '60',
      ),
      _passoCorsa(3, 'defaticamento', 'Defaticamento', minuti: '10'),
    ];

    test('ogni giro prende il nome del suo passo, anche i recuperi', () {
      final giri = [
        _giro(903, metri: 2700),
        for (var k = 0; k < 6; k++) ...[
          _giro(118 + k, metri: 520),
          if (k < 5) _giro(61, metri: 180, recupero: k.isEven),
        ],
        // Il recupero dopo l'ultima ripetizione non c'è: si riparte subito.
        _giro(596, metri: 1700),
      ];
      final l = abbinaAlPiano('Corsa', giri, fartlek);
      expect(l.first.nome, 'Riscaldamento');
      expect(l[1].nome, 'Veloce 1/6');
      expect(l[2].recupero, isTrue); // anche se l'orologio lo dava "lavoro"
      expect(l[2].previstoS, 60);
      expect(l[11].nome, 'Veloce 6/6');
      expect(l.last.nome, 'Defaticamento');
      expect(fasiDegliIntervalli(l, fartlek).last, 'defaticamento');
      expect(rigaIntervallo(l[1], 'Corsa'), '520 m · 1:58 · 3:47/km');
    });

    test('un giro che non torna: nessun nome, meglio che sbagliato', () {
      final giri = [
        _giro(900),
        _giro(120),
        _giro(60),
        _giro(300), // ripetuta lasciata a metà, poi corsa libera
        _giro(120),
      ];
      final l = abbinaAlPiano('Corsa', giri, fartlek);
      expect(l.every((i) => i.nome.isEmpty), isTrue);
    });

    test('fermarsi prima della fine della seduta va bene', () {
      final giri = [_giro(900), _giro(120), _giro(60), _giro(119)];
      final l = abbinaAlPiano('Corsa', giri, fartlek);
      expect(l.map((i) => i.nome), [
        'Riscaldamento',
        'Veloce 1/6',
        '',
        'Veloce 2/6',
      ]);
    });

    test('corsa con i giri automatici di 1 km: nessun abbinamento', () {
      final giri = [for (var k = 0; k < 8; k++) _giro(330, metri: 1000)];
      final l = abbinaAlPiano('Corsa', giri, fartlek);
      expect(l.every((i) => i.nome.isEmpty), isTrue);
    });

    test('passi a distanza: 4 × 1 km', () {
      final passi = [
        _passoCorsa(1, 'principale', 'Ripetuta', metri: '1000', serie: 4),
      ];
      final l = abbinaAlPiano('Corsa', [
        for (var k = 0; k < 4; k++) _giro(240 + k, metri: 1004),
      ], passi);
      expect(l.map((i) => i.nome), [
        'Ripetuta 1/4',
        'Ripetuta 2/4',
        'Ripetuta 3/4',
        'Ripetuta 4/4',
      ]);
    });
  });

  group('le corse vere di giovedì (Garmin, giro automatico a 1 km)', () {
    IntervalloFatto g(int s, double m, {bool r = false}) =>
        IntervalloFatto(recupero: r, inizioS: 0, secondi: s, metri: m);

    test('tempo run del 5/11: ritmo sostenuto chiuso a 20 minuti su 25', () {
      final previsto = [
        _passoCorsa(1, 'riscaldamento', 'Corsa facile', minuti: '10'),
        _passoCorsa(2, 'principale', 'Corsa a ritmo sostenuto', minuti: '25'),
        _passoCorsa(3, 'defaticamento', 'Corsa facile', minuti: '10'),
      ];
      final giri = [
        g(380, 1004),
        g(221, 594),
        g(365, 1001),
        g(374, 999),
        g(461, 997),
        g(642, 1667),
        g(258, 803),
        g(61, 176),
        g(29, 72, r: true),
      ];
      final l = abbinaAlPiano('Corsa', giri, previsto);
      expect(l.map((i) => i.nome), [
        'Corsa facile',
        'Corsa facile',
        'Corsa a ritmo sostenuto',
        'Corsa a ritmo sostenuto',
        'Corsa a ritmo sostenuto',
        'Corsa facile',
        '',
        '',
        '',
      ]);
      expect(fasiDegliIntervalli(l, previsto), [
        'riscaldamento',
        'riscaldamento',
        'principale',
        'principale',
        'principale',
        'defaticamento',
        '',
        '',
        '',
      ]);
      // Il defaticamento è un giro solo: si vede il previsto.
      expect(rigaIntervallo(l[5], 'Corsa'), contains('10:42 (previsti 10:00)'));
    });

    test('fartlek del 29/10: 6 × 2 minuti con 2 di recupero', () {
      final previsto = [
        _passoCorsa(1, 'riscaldamento', 'Corsa facile', minuti: '10'),
        _passoCorsa(
          2,
          'principale',
          'Corsa veloce',
          minuti: '2',
          serie: 6,
          recupero: '120',
        ),
        _passoCorsa(3, 'defaticamento', 'Corsa facile', minuti: '10'),
      ];
      final giri = [
        g(429, 1002),
        g(172, 441),
        g(121, 402),
        g(119, 273, r: true),
        g(120, 406),
        g(120, 305, r: true),
        g(120, 381),
        g(120, 273, r: true),
        g(120, 386),
        g(120, 247, r: true),
        g(120, 390),
        g(120, 210, r: true),
        g(120, 383),
        g(525, 1000),
        g(1, 2, r: true),
        g(75, 137),
      ];
      final l = abbinaAlPiano('Corsa', giri, previsto);
      expect(l.take(3).map((i) => i.nome), [
        'Corsa facile',
        'Corsa facile',
        'Corsa veloce 1/6',
      ]);
      expect(l[3].recupero, isTrue);
      expect(l[12].nome, 'Corsa veloce 6/6');
      // Dopo l'ultima ripetuta niente recupero: subito il defaticamento,
      // spezzato in tre giri.
      expect(l.skip(13).map((i) => i.nome), [
        'Corsa facile',
        'Corsa facile',
        'Corsa facile',
      ]);
      expect(fasiDegliIntervalli(l, previsto).last, 'defaticamento');
      expect(l.every((i) => i.recupero || i.nome.isNotEmpty), isTrue);
    });
  });

  group("sedute registrate con l'app", () {
    // Rulli in ERG: 10 min, 3 × 8 min con 2 min di recupero.
    final passi = [
      _passoCorsa(
        1,
        'riscaldamento',
        'Riscaldamento',
        minuti: '10',
        sport: 'Bici',
      ),
      _passoCorsa(
        2,
        'principale',
        'Soglia',
        minuti: '8',
        serie: 3,
        recupero: '120',
        sport: 'Bici',
      ),
    ];
    final blocchi = blocchiDa(passi);
    final t0 = DateTime(2026, 11, 10, 7);
    TrattoApp tratto(int blocco, int da, int secondi) => (
      blocco: blocco,
      inizio: t0.add(Duration(seconds: da)),
      fine: t0.add(Duration(seconds: da + secondi)),
      secondi: secondi,
      metri: secondi * 8.0,
    );

    test('un blocco da 8 minuti chiuso dopo 2 si vede', () {
      final fc = [
        for (var s = 0; s < 1500; s += 5)
          Campione(t0.add(Duration(seconds: s)), s < 600 ? 120 : 160),
      ];
      final potenza = [
        for (var s = 0; s < 1500; s += 5)
          Campione(t0.add(Duration(seconds: s)), s < 600 ? 150 : 230),
      ];
      final l = intervalliDaTratti(
        blocchi,
        [
          tratto(0, 0, 600),
          tratto(1, 600, 480),
          tratto(2, 1080, 120),
          tratto(3, 1200, 120), // cambiato dopo 2 minuti
        ],
        fc: fc,
        potenza: potenza,
      );
      expect(l.map((i) => i.nome), [
        'Riscaldamento',
        'Soglia 1/3',
        '',
        'Soglia 2/3',
      ]);
      expect(l.map((i) => i.fase), [
        'riscaldamento',
        'principale',
        'principale',
        'principale',
      ]);
      expect(l[2].recupero, isTrue);
      expect(l[1].wattMedi, 230);
      expect(l[1].fcMedia, 160);
      expect(l.last.inizioS, 1200);
      expect(
        rigaIntervallo(l.last, 'Bici'),
        '960 m · 2:00 (previsti 8:00) · 28,8 km/h · 230 W · FC 160',
      );
      expect(rigaIntervallo(l[1], 'Bici'), contains('8:00 · '));
      expect(fasiDegliIntervalli(l, const []).first, 'riscaldamento');
    });

    test('salvati e riletti restano uguali, anche col nome con la virgola', () {
      final l = intervalliDaTratti(blocchi, [
        tratto(0, 0, 600),
        tratto(1, 600, 120),
      ]);
      final conVirgola = [l.first.copia(nome: 'Riscaldamento, facile'), l.last];
      final riletti = intervalliDaCsv(intervalliCsv(conVirgola));
      expect(riletti.first.nome, 'Riscaldamento, facile');
      expect(riletti.last.previstoS, 480);
      expect(riletti.last.fase, 'principale');
      expect(riletti.last.secondi, 120);
    });

    test('i file vecchi a 5 colonne si leggono ancora', () {
      final l = intervalliDaCsv('l,0,332,200,109\nr,332,52,0,117');
      expect(l.length, 2);
      expect(l.first.metri, 200);
      expect(l.first.previstoS, 0);
      expect(l.last.recupero, isTrue);
    });
  });
}

WorkoutStep _passoCorsa(
  int ordine,
  String fase,
  String nome, {
  String minuti = '',
  String metri = '',
  int serie = 1,
  String recupero = '',
  String sport = 'Corsa',
}) => WorkoutStep(
  id: 'corsa_2026-11-05',
  sport: sport,
  nome: 'Fartlek',
  durataTot: 50,
  ordine: ordine,
  fase: fase,
  descrizione: nome,
  serie: '$serie',
  ripetizioni: '',
  distanzaM: metri,
  durataMin: minuti,
  intensita: '',
  recuperoS: recupero,
  note: '',
);

IntervalloFatto _giro(int secondi, {double metri = 0, bool recupero = false}) =>
    IntervalloFatto(
      recupero: recupero,
      inizioS: 0,
      secondi: secondi,
      metri: metri,
    );
