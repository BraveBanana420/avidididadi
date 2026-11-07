import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/voce.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cambiando blocco', () {
    const canale = MethodChannel('avidididadi/avvio');
    Blocco blocco(String titolo) => Blocco(
      tipo: TipoBlocco.lavoro,
      titolo: titolo,
      dettaglio: '',
      intensita: '',
      obiettivo2: '',
      note: '',
      fase: 'principale',
      esercizio: '',
      secondi: null,
      passo: 0,
      serie: 1,
      ripetizioni: '',
    );

    late List<Map<Object?, Object?>> dette;
    var risposta = 'parlato';
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      dette = [];
      risposta = 'parlato';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canale, (c) async {
            if (c.method == 'parla') {
              dette.add(c.arguments as Map<Object?, Object?>);
            }
            return risposta;
          });
    });
    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canale, null),
    );

    test('ogni titolo interrompe quello prima, senza coda', () async {
      final v = Voce();
      for (final t in [
        'Riscaldamento',
        'Serie 1',
        'Serie 2',
        'Defaticamento',
      ]) {
        await v.diBlocco(blocco(t));
      }
      expect(dette, hasLength(4));
      expect(dette.every((d) => d['urgente'] == true), isTrue);
      expect(dette.last['testo'], contains('Defaticamento'));
    });

    test('le altre frasi restano in coda, senza interrompere', () async {
      await Voce().di('Chilometro 3.');
      expect(dette.single['urgente'], false);
    });

    test('durante una chiamata conta solo l\'ultimo titolo', () async {
      final v = Voce();
      risposta = 'chiamata';
      await v.diBlocco(blocco('Serie 1'));
      await v.diBlocco(blocco('Serie 2'));
      // Il secondo non chiede nemmeno di parlare: aspetta la fine della chiamata.
      expect(dette, hasLength(1));
      v.ferma();
    });
  });

  group('a voce, per esteso', () {
    test('durate', () {
      expect(parlaDurata(const Duration(seconds: 42)), '42 secondi');
      expect(parlaDurata(const Duration(seconds: 1)), '1 secondo');
      expect(
        parlaDurata(const Duration(minutes: 5, seconds: 42)),
        '5 minuti e 42',
      );
      expect(parlaDurata(const Duration(minutes: 1)), '1 minuto');
      expect(
        parlaDurata(const Duration(hours: 1, minutes: 5, seconds: 20)),
        '1 ora e 5 minuti',
      );
    });

    test('passo e velocità', () {
      expect(parlaVelocita('Corsa', 1000 / 342), '5 e 42 al chilometro');
      expect(parlaVelocita('Camminata', 1000 / 600), '10 minuti al chilometro');
      expect(parlaVelocita('Bici', 28.4 / 3.6), "28 chilometri all'ora");
    });

    test('giri', () {
      expect(
        fraseGiro('Corsa', (
          numero: 3,
          metri: 1000,
          tempo: const Duration(minutes: 5, seconds: 42),
        )),
        'Chilometro 3. 5 e 42 al chilometro.',
      );
      expect(
        fraseGiro('Bici', (
          numero: 2,
          metri: 5000,
          tempo: const Duration(minutes: 11, seconds: 2),
        )),
        "Chilometro 10. Ultimi 5 in 11 minuti e 2, 27 chilometri all'ora.",
      );
    });

    test('le sigle dello schermo', () {
      expect(
        parlato('Serie 2 di 3 · 8-10 ripetizioni'),
        'Serie 2 di 3, da 8 a 10 ripetizioni',
      );
      expect(parlato('45 s per lato'), '45 secondi per lato');
      expect(parlato('10 min'), '10 minuti');
      expect(parlato('400 m · Z4'), '400 metri, zona 4');
      expect(parlato('7/10 di fatica'), '7 su 10 di fatica');
      expect(parlato('22,5 kg'), '22,5 chili');
    });

    test('esercizio che inizia e recupero', () {
      const corsa = Blocco(
        tipo: TipoBlocco.lavoro,
        titolo: 'Ripetute',
        dettaglio: 'Serie 1 di 6 · 400 m',
        intensita: 'zona 4',
        passo: 1,
      );
      expect(
        fraseBlocco(corsa),
        'Ora: Ripetute. Serie 1 di 6, 400 metri. zona 4.',
      );
      const rec = Blocco(
        tipo: TipoBlocco.recupero,
        titolo: 'Recupero',
        secondi: 90,
        passo: 1,
      );
      expect(fraseBlocco(rec), 'Recupero, 1 minuto e 30.');
    });
  });

  group('obiettivi', () {
    test('zona dal piano o dalle schede', () {
      expect(zonaObiettivo('zona 2'), 2);
      expect(zonaObiettivo('Z4'), 4);
      expect(zonaObiettivo('7/10 di fatica'), isNull);
    });

    test('passo o velocità scritti a mano', () {
      expect(velocitaObiettivo('5:30/km'), closeTo(1000 / 330, 1e-9));
      expect(velocitaObiettivo('ritmo 4:45 min/km'), closeTo(1000 / 285, 1e-9));
      expect(velocitaObiettivo('28 km/h'), closeTo(28 / 3.6, 1e-9));
      expect(velocitaObiettivo('zona 2'), isNull);
    });

    test('sopra o sotto la zona', () {
      expect(versoZona(4, 2), 1);
      expect(versoZona(1, 2), 0); // nel lento, più piano va bene
      expect(versoZona(2, 4), -1);
      expect(versoZona(4, 4), 0);
      expect(fraseZona(4, 1), 'Zona 4, rallenta.');
    });

    test('passo con margine del 5%', () {
      const obiettivo = 1000 / 330; // 5:30/km
      expect(versoVelocita(1000 / 325, obiettivo), 0);
      expect(versoVelocita(1000 / 300, obiettivo), 1);
      expect(versoVelocita(1000 / 360, obiettivo), -1);
      expect(
        fraseVelocita('Corsa', 1000 / 300, 1),
        "Passo 5 minuti al chilometro, rallenta un po'.",
      );
    });
  });

  test('avvisa solo se dura 20 s, poi non prima di un minuto', () {
    final c = ControlloRitmo();
    final t0 = DateTime(2026, 11, 1, 8);
    DateTime t(int s) => t0.add(Duration(seconds: s));
    expect(c.controlla(1, t(0)), isFalse);
    expect(c.controlla(1, t(10)), isFalse);
    expect(c.controlla(1, t(21)), isTrue);
    expect(c.controlla(1, t(50)), isFalse);
    expect(c.controlla(1, t(82)), isTrue);
    // Torna nel ritmo e poi riesce: si aspetta di nuovo.
    expect(c.controlla(0, t(90)), isFalse);
    expect(c.controlla(1, t(150)), isFalse);
    expect(c.controlla(1, t(171)), isTrue);
    // Un sorpasso di 10 s non conta.
    final d = ControlloRitmo();
    expect(d.controlla(1, t(0)), isFalse);
    expect(d.controlla(1, t(10)), isFalse);
    expect(d.controlla(0, t(12)), isFalse);
    expect(d.controlla(0, t(60)), isFalse);
  });
}
