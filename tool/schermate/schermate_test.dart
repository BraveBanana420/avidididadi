// Fotografa le schermate dell'app, con dati di esempio, nelle 4 combinazioni
// di tema. Serve a controllare la grafica senza telefono:
//
//   flutter test tool/schermate/schermate_test.dart
//
// Le immagini finiscono in build/schermate/<tema>/. Non è un test vero: sta
// fuori da test/ per non rallentare `flutter test`.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/feedback.dart';
import 'package:allenamenti_app/main.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/profilo.dart';
import 'package:allenamenti_app/recupero.dart';
import 'package:allenamenti_app/screens/privacy_screen.dart';
import 'package:allenamenti_app/screens/tour.dart';
import 'package:allenamenti_app/storage.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _cornice = GlobalKey();
final _uscita = Directory('build/schermate');

/// I caratteri veri (nei test, senza questo, il testo è fatto di rettangoli).
Future<void> _caricaCaratteri() async {
  final elenco =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final f in elenco.cast<Map<String, dynamic>>()) {
    final c = FontLoader(f['family'] as String);
    for (final a in (f['fonts'] as List).cast<Map<String, dynamic>>()) {
      c.addFont(rootBundle.load(a['asset'] as String));
    }
    await c.load();
  }
}

/// Otto settimane di allenamenti, recupero e peso di una persona che fa un
/// po' di tutto: abbastanza per riempire Oggi, Progressi e i grafici.
Future<void> _preparaDati() async {
  final s = AppState();
  await s.load();
  await s.accettaTermini(versioneTermini);
  await s.configuraDaZero(
    nome: 'Giulia',
    sport: ['Forza', 'Corsa', 'Nuoto', 'Bici', 'Mobilità'],
    giorni: 5,
    minuti: 45,
    livello: 'intermedio',
  );
  final oggi = soloData(DateTime.now());
  DateTime g(int fa) => oggi.subtract(Duration(days: fa));
  // (giorni fa, sport, tipo, minuti, km, battito, fatica)
  const fatte = [
    (0, 'Corsa', 'Lento', 42, 7.1, 142, 4.0),
    (1, 'Forza', 'Full body', 48, 0.0, 118, 6.0),
    (2, 'Bici', 'Fondo', 75, 31.4, 136, 5.0),
    (4, 'Nuoto', 'Tecnica', 40, 1.6, 128, 4.0),
    (5, 'Corsa', 'Ripetute', 46, 8.2, 158, 8.0),
    (6, 'Mobilità', '', 20, 0.0, 0, 2.0),
    (8, 'Forza', 'Full body', 50, 0.0, 121, 6.0),
    (9, 'Corsa', 'Lungo', 78, 13.5, 148, 6.0),
    (11, 'Bici', 'Soglia', 60, 26.0, 149, 7.0),
    (12, 'Nuoto', 'Fondo', 45, 1.9, 131, 5.0),
    (14, 'Camminata', '', 65, 5.8, 104, 2.0),
    (15, 'Forza', 'Full body', 47, 0.0, 119, 5.0),
    (16, 'Corsa', 'Lento', 40, 6.6, 144, 4.0),
    (18, 'Arrampicata', 'Blocchi', 90, 0.0, 122, 6.0),
    (19, 'Bici', 'Fondo', 95, 40.2, 134, 5.0),
    (22, 'Corsa', 'Ritmo gara', 50, 9.0, 155, 7.0),
    (23, 'Forza', 'Full body', 45, 0.0, 117, 6.0),
    (25, 'Nuoto', 'Tecnica', 38, 1.5, 126, 3.0),
    (26, 'Corsa', 'Lungo', 72, 12.2, 147, 6.0),
    (29, 'Bici', 'Fondo', 80, 33.0, 133, 5.0),
    (30, 'Forza', 'Full body', 44, 0.0, 116, 5.0),
    (33, 'Corsa', 'Lento', 38, 6.1, 143, 4.0),
    (36, 'Nuoto', 'Fondo', 42, 1.7, 129, 5.0),
    (37, 'Forza', 'Full body', 46, 0.0, 118, 6.0),
    (40, 'Corsa', 'Ripetute', 44, 7.6, 157, 8.0),
    (43, 'Bici', 'Fondo', 70, 28.5, 132, 4.0),
    (47, 'Corsa', 'Lento', 36, 5.7, 141, 3.0),
    (50, 'Forza', 'Full body', 42, 0.0, 115, 5.0),
    (54, 'Corsa', 'Lungo', 65, 10.8, 146, 6.0),
  ];
  await Storage.write('sessioni.csv', sessioniHeader, [
    for (final (i, f) in fatte.indexed)
      Sessione(
        id: 'prova-$i',
        data: g(f.$1),
        sport: f.$2,
        tipo: f.$3,
        durataMin: f.$4,
        distanzaKm: f.$5,
        fcMedia: f.$6,
        rpe: f.$7,
        fonte: 'manuale',
        inizio: g(f.$1).add(const Duration(hours: 7, minutes: 30)),
        fine: g(f.$1).add(Duration(hours: 7, minutes: 30 + f.$4)),
        fcMax: f.$6 == 0 ? 0 : f.$6 + 18,
        calorieAttive: f.$4 * 8.5,
      ).toRow(),
  ]);
  await Storage.write('recupero.csv', recuperoHeader, [
    for (var i = 0; i < 40; i++)
      GiornoRecupero(
        g(i),
        fcRiposo: 51 + (i * 7) % 5,
        hrv: 58 + ((i * 11) % 13).toDouble(),
        sonnoMin: 400 + (i * 37) % 80,
      ).toRow(),
  ]);
  await Storage.write('feedback.csv', feedbackHeader, [
    for (final f in fatte.skip(1).take(12))
      FeedbackSessione(
        data: g(f.$1),
        sport: f.$2,
        fatica: f.$7.round(),
      ).toRow(),
  ]);
  await Storage.write('misure.csv', misureHeader, [
    for (var i = 8; i >= 0; i--)
      Misura(g(i * 7), {
        'peso_kg': 61.5 + i * 0.25,
        'vita_cm': 70 + i * 0.3,
      }).toRow(),
  ]);
}

/// Fa passare un po' di tempo vero (i file) e finto (le animazioni).
Future<void> _assesta(WidgetTester t, [int giri = 12]) async {
  for (var i = 0; i < giri; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await t.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _foto(WidgetTester t, String cartella, String nome) async {
  final r = t.renderObject<RenderRepaintBoundary>(find.byKey(_cornice));
  await t.runAsync(() async {
    final img = await r.toImage(pixelRatio: 2);
    final b = await img.toByteData(format: ui.ImageByteFormat.png);
    final f = File('${_uscita.path}/$cartella/$nome.png');
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(b!.buffer.asUint8List());
    img.dispose();
  });
}

Future<void> _scorri(WidgetTester t, [double quanto = 560]) async {
  await t.dragFrom(const Offset(180, 620), Offset(0, -quanto));
  await _assesta(t, 4);
}

void main() {
  late Directory dati;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dati = Directory.systemTemp.createTempSync('schermate');
    final m = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => dati.path,
    );
    for (final c in const [
      'avidididadi/avvio',
      'plugins.it_nomads.com/flutter_secure_storage',
      'flutter_health',
      'dev.fluttercommunity.plus/package_info',
    ]) {
      m.setMockMethodCallHandler(MethodChannel(c), (_) async => null);
    }
    await _caricaCaratteri();
    await _preparaDati();
  });

  tearDownAll(() => dati.deleteSync(recursive: true));

  for (final (nome, scuro, conNeon) in const [
    ('scuro_rosso', true, false),
    ('chiaro_rosso', false, false),
    ('scuro_neon', true, true),
    ('chiaro_neon', false, true),
  ]) {
    testWidgets('schermate: $nome', (t) async {
      // Telefono stretto (360 × 780), con barra di stato e barra dei gesti.
      t.view.physicalSize = const Size(1080, 2340);
      t.view.devicePixelRatio = 3;
      t.view.padding = const FakeViewPadding(top: 84, bottom: 48);
      addTearDown(t.view.reset);
      tema.value = scuro ? ThemeMode.dark : ThemeMode.light;
      neon.value = conNeon;
      // Nei test le ombre sono rettangoli neri: qui servono quelle vere.
      debugDisableShadows = false;
      try {
        await t.pumpWidget(
          RepaintBoundary(key: _cornice, child: const AllenamentiApp()),
        );
        // I dati si leggono da file veri: si aspetta finché compare il nome.
        for (
          var i = 0;
          i < 400 && find.text('Ciao Giulia').evaluate().isEmpty;
          i++
        ) {
          await _assesta(t, 1);
        }
        await _assesta(t, 20);

        await _foto(t, nome, '01_oggi');
        await _scorri(t);
        await _foto(t, nome, '02_oggi_giu');
        await _scorri(t);
        await _foto(t, nome, '03_oggi_fondo');

        await t.tap(find.byKey(ChiaviTour.voci[1]));
        await _assesta(t);
        await _foto(t, nome, '04_progressi');
        await _scorri(t);
        await _foto(t, nome, '05_progressi_giu');
        await _scorri(t);
        await _foto(t, nome, '06_progressi_fondo');

        await t.tap(find.byKey(ChiaviTour.voci[2]));
        await _assesta(t);
        await _foto(t, nome, '07_coach');

        await t.tap(find.byKey(ChiaviTour.voci[3]));
        await _assesta(t);
        await _foto(t, nome, '08_profilo');
        await _scorri(t);
        await _foto(t, nome, '09_profilo_giu');
        await _scorri(t);
        await _foto(t, nome, '10_profilo_fondo');

        // Chiude l'app e lascia scadere i timer rimasti.
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(seconds: 3));
      } finally {
        debugDisableShadows = true;
      }
    });
  }
}
