import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/potenza.dart';
import 'package:allenamenti_app/screens/profilo_allenamento.dart';
import 'package:allenamenti_app/screens/vista_bici.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const zp = ZonePotenza(214);
  const fc = Zone(fcMax: 190);
  final t0 = DateTime(2026, 11, 5, 23);
  final serie = [
    for (var s = 0; s < 600; s++)
      Campione(t0.add(Duration(seconds: s)), 140.0 + s % 30),
  ];

  // La seduta "Intervalli 6 min." di Tacx: 15 min, 2 × 6 min con recupero.
  final blocchi = blocchiDa([
    for (final (k, nome, minuti, serie, intensita, recupero) in [
      (1, 'Riscaldamento', '15', '', 'zona 2', ''),
      (2, 'Ripetute', '6', '2', 'zona 4', '180'),
      (3, 'Defaticamento', '10', '', 'zona 1', ''),
    ])
      WorkoutStep(
        id: 'w',
        sport: 'Bici',
        nome: 'Intervalli',
        durataTot: 43,
        ordine: k,
        fase: 'principale',
        descrizione: nome,
        serie: serie,
        ripetizioni: '',
        distanzaM: '',
        durataMin: minuti,
        intensita: intensita,
        recuperoS: recupero,
        note: '',
      ),
  ]);

  DatiVistaBici completa({bool rullo = true}) => DatiVistaBici(
    watt: 152,
    wattMedia: 148,
    wattMassimo: 312,
    seriePotenza: serie,
    zonePotenza: zp,
    bpm: 132,
    zone: fc,
    calorie: 210,
    cadenza: '88',
    velocita: '28.4',
    km: '12,34',
    sensoriRicordati: rullo,
    titolo: 'Riscaldamento',
    intensita: 'zona 2 (118-160 W · 129-142 bpm)',
    range: rangeWatt('zona 2', zp),
    wattErg: rullo ? 140 : null,
    restano: 2683,
    trascorso: 17,
    durata: 2700,
    barre: barreDa(blocchi, zp),
    comandabile: rullo,
  );

  Future<void> disegna(
    WidgetTester t,
    DatiVistaBici d,
    Size spazio, {
    ThemeData? tema,
  }) async {
    await t.pumpWidget(
      MaterialApp(
        theme: tema ?? creaTema(Brightness.dark, neon: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox.fromSize(
              size: spazio,
              child: VistaBici(
                dati: d,
                apriSensori: () {},
                apriBattito: () {},
                cambiaErg: (_) {},
                cambiaScala: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Lo spazio vero del Samsung dello screenshot, tra barra in alto e tasti.
  const samsung = Size(360, 556);

  testWidgets('il timer e il diagramma stanno nello schermo, senza scorrere', (
    t,
  ) async {
    await disegna(t, completa(), samsung);
    expect(t.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsNothing);
    final timer = t.getRect(find.text('44:43'));
    expect(timer.bottom, lessThan(samsung.height));
    expect(
      t.getRect(find.byType(ProfiloAllenamento)).bottom,
      lessThan(samsung.height),
    );
    expect(find.text('140 W', findRichText: true), findsOneWidget);
    expect(find.text('Rullo in ERG'), findsOneWidget);
    expect(find.textContaining('Poi: Z4'), findsOneWidget);
    expect(find.textContaining('Massimo 312 W'), findsOneWidget);
    for (final x in ['152', '132', '210', '88', '28.4', '12,34']) {
      expect(find.textContaining(x, findRichText: true), findsOneWidget);
    }
  });

  testWidgets('nelle 4 combinazioni di tema nessun errore', (t) async {
    for (final b in Brightness.values) {
      for (final neon in [false, true]) {
        await disegna(t, completa(), samsung, tema: creaTema(b, neon: neon));
        expect(t.takeException(), isNull);
      }
    }
  });

  testWidgets('telefono piccolo: si scorre, niente sbordi', (t) async {
    await disegna(t, completa(), const Size(320, 400));
    expect(t.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('senza sensori né FTP: il timer c\'è e si dice cosa collegare', (
    t,
  ) async {
    await disegna(
      t,
      DatiVistaBici(
        zone: fc,
        titolo: 'Pedalata costante',
        intensita: 'zona 2 (129-142 bpm)',
        restano: 2683,
        trascorso: 17,
        durata: 2700,
      ),
      samsung,
    );
    expect(t.takeException(), isNull);
    expect(find.text('44:43'), findsOneWidget);
    expect(find.textContaining('zona 2 (129-142 bpm)'), findsOneWidget);
    expect(find.textContaining('Collega il rullo'), findsOneWidget);
    expect(find.byType(ProfiloAllenamento), findsNothing);
  });

  testWidgets('a mano, fuori dal range: la freccia dice da che parte', (
    t,
  ) async {
    final d = completa(rullo: false);
    await disegna(
      t,
      DatiVistaBici(
        watt: 200,
        zonePotenza: zp,
        zone: fc,
        titolo: d.titolo,
        range: d.range,
        restano: 60,
        durata: 120,
        trascorso: 60,
      ),
      samsung,
    );
    expect(find.textContaining('▼'), findsOneWidget);
  });

  testWidgets('primario grande e secondario accanto, con la freccia', (
    t,
  ) async {
    await disegna(
      t,
      DatiVistaBici(
        zone: fc,
        titolo: 'Ripetute',
        range: (200, 200),
        wattErg: 200,
        obiettivo2: '85-90 rpm',
        versoSecondario: -1,
        restano: 60,
        durata: 120,
        trascorso: 60,
      ),
      samsung,
    );
    expect(t.takeException(), isNull);
    expect(
      find.textContaining('200 W · ▲ 85-90 rpm', findRichText: true),
      findsOneWidget,
    );
  });

  test('il grafico guarda solo gli ultimi minuti', () {
    final u = ultimiCampioni(serie, const Duration(minutes: 5));
    expect(u.last, serie.last);
    expect(u.length, 300);
    expect(ultimiCampioni(const [], const Duration(minutes: 5)), isEmpty);
    expect(
      ultimiCampioni(serie.take(10).toList(), const Duration(minutes: 5)),
      hasLength(10),
    );
  });

  test('durante il blocco la durata non si ripete: la dice il timer', () {
    Blocco b(String d, int? s) => Blocco(
      tipo: TipoBlocco.lavoro,
      titolo: 'x',
      dettaglio: d,
      secondi: s,
      passo: 0,
    );
    expect(dettaglioBreve(b('10 min', 600)), '');
    expect(dettaglioBreve(b('Serie 2 di 5 · 6 min', 360)), 'Serie 2 di 5');
    expect(dettaglioBreve(b('45 s', 45)), '');
    // Senza timer le quantità servono.
    expect(
      dettaglioBreve(b('Serie 1 di 3 · 8-10 ripetizioni', null)),
      'Serie 1 di 3 · 8-10 ripetizioni',
    );
    expect(dettaglioBreve(b('400 m', null)), '400 m');
  });

  test('il blocco raccontato in breve', () {
    expect(
      descriviBarra(const BarraAllenamento(360, (195, 225)), zp),
      'Z4 · 195-225 W · 6:00',
    );
    expect(descriviBarra(const BarraAllenamento(60, null), zp), '1:00');
    expect(
      descriviBarra(const BarraAllenamento(360, (200, 200), '85-90 rpm'), zp),
      'Z4 · 200 W · 85-90 rpm · 6:00',
    );
  });
}
