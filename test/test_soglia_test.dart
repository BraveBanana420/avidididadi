import 'package:allenamenti_app/assistente.dart';
import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/generatore_endurance.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/profilo.dart';
import 'package:allenamenti_app/serie_sessione.dart';
import 'package:allenamenti_app/test_soglia.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una serie di potenza al secondo: [blocchi] di (secondi, watt).
List<Campione> serie(List<(int, double)> blocchi) {
  final t0 = DateTime(2026, 11, 10, 18);
  final out = <Campione>[];
  var s = 0;
  for (final (durata, watt) in blocchi) {
    for (var i = 0; i < durata; i++) {
      out.add(Campione(t0.add(Duration(seconds: s++)), watt));
    }
  }
  return out;
}

void main() {
  final oggi = DateTime(2026, 11, 16);

  group('passi dei test', () {
    test('rampa con FTP 220: da 110 W, +15 W al minuto, poi defaticamento', () {
      final p = passiTestRampa('t', ftp: 220);
      final gradini = p.where((w) => w.fase == 'principale').toList();
      expect(gradini.first.intensita, '110 W');
      expect(gradini[1].intensita, '125 W');
      expect(gradini.every((w) => w.durataMin == '1'), isTrue);
      // Arriva oltre il 150% dell'FTP: nessuno finisce i gradini.
      expect(
        int.parse(gradini.last.intensita.split(' ').first),
        greaterThan(330),
      );
      expect(p.first.fase, 'riscaldamento');
      expect(p.last.fase, 'defaticamento');
      expect(p.first.nome, nomeTestFtpBiciRampa);
    });

    test('rampa senza FTP: da 100 W di 20 in 20', () {
      final gradini = passiTestRampa('t')
          .where((w) => w.fase == 'principale')
          .toList();
      expect(gradini.first.intensita, '100 W');
      expect(gradini[1].intensita, '120 W');
      expect(gradini.length, 20);
    });

    test('20 minuti: con l\'FTP suggerisce i watt, il test è senza ERG', () {
      final p = passiTestVenti('t', ftp: 250);
      final prova = p.firstWhere((w) => w.durataMin == '20');
      expect(prova.intensita, isEmpty); // il rullo non blocca i watt
      expect(prova.note, contains('255 W'));
      expect(
        passiTestVenti('t').firstWhere((w) => w.durataMin == '20').note,
        contains('Parti un po\''),
      );
    });

    test('nuoto: 400 e 200 m al massimo', () {
      final p = passiTestNuoto('t');
      expect(p.map((w) => w.distanzaM), containsAll(['400', '200']));
      expect(p.first.nome, nomeTestNuoto);
    });
  });

  test('passo critico dai tempi: (400 - 200) / 2', () {
    // 8:20 e 3:55: (500 - 235) / 2 = 132,5 → 2:13/100 m.
    expect(passoCriticoDaTest(500, 235), 133);
    expect(passoCriticoDaTest(235, 500), isNull);
    expect(passoCriticoDaTest(400, 235), isNull); // 400 troppo svelto
  });

  group('potenze migliori', () {
    test('rampa: 75% del minuto migliore', () {
      final s = serie([(600, 100), (60, 300), (60, 320), (60, 340)]);
      final p = potenzaMiglioreDa('a', oggi, s, test: 'rampa')!;
      expect(p.w1, 340);
      expect(p.ftp, 255);
    });

    test('20 minuti: 95% della media, anche da un\'uscita normale', () {
      final s = serie([(900, 150), (1200, 240), (600, 120)]);
      final p = potenzaMiglioreDa('a', oggi, s)!;
      expect(p.w20, 240);
      expect(p.ftp, 228);
    });

    test('in CSV e ritorno', () {
      final p = PotenzaMigliore(
        idSessione: 'icu-i123',
        data: oggi,
        w20: 240,
        w1: 330,
        test: 'venti',
      );
      final t = Tabella.da(toCsv([potenzeMiglioriHeader, p.toRow()]))!;
      final q = PotenzaMigliore.da(t, t.righe.first)!;
      expect(
        (q.idSessione, q.w20, q.w1, q.test, q.data),
        ('icu-i123', 240, 330, 'venti', oggi),
      );
    });

    test('la proposta: solo se almeno il 3% sopra, solo 6 settimane', () {
      final potenze = [
        PotenzaMigliore(idSessione: 'a', data: oggi, w20: 240, w1: 300),
        PotenzaMigliore(
          idSessione: 'b',
          data: oggi.subtract(const Duration(days: 60)),
          w20: 300,
          w1: 400,
        ),
      ];
      // 240 × 0,95 = 228: la vecchia da 285 non conta più.
      expect(ftpDaProporre(potenze, 215, oggi), 228);
      expect(ftpDaProporre(potenze, 225, oggi), isNull); // +1%: rumore
      expect(ftpDaProporre(potenze, null, oggi), 228);
      expect(ftpDaProporre(potenze, 260, oggi), isNull); // non scende
    });
  });

  group('quando proporre il test in bici', () {
    MotivoTest? motivo({
      int? ftp = 230,
      bool potenza = true,
      DateTime? prova,
      DateTime? ultimoTest,
      List<(int, bool)> intervalli = const [],
      DateTime? rimandato,
    }) => motivoTestBici(
      ftp: ftp,
      potenzaMisurata: potenza,
      ultimaProva: prova ?? oggi.subtract(const Duration(days: 20)),
      ultimoTest: ultimoTest,
      intervalli: intervalli,
      oggi: oggi,
      rimandatoFino: rimandato,
    );

    test('niente watt, niente test', () {
      expect(motivo(potenza: false, ftp: null), isNull);
    });
    test('senza FTP', () => expect(motivo(ftp: null), MotivoTest.manca));
    test('FTP confermato da poco: niente', () => expect(motivo(), isNull));
    test('più di 8 settimane', () {
      expect(
        motivo(prova: oggi.subtract(const Duration(days: 60))),
        MotivoTest.vecchio,
      );
    });
    test('intervalli troppo facili o non finiti', () {
      expect(
        motivo(intervalli: const [(3, true), (2, true), (3, true)]),
        MotivoTest.troppoFacile,
      );
      expect(
        motivo(intervalli: const [(9, false), (8, true), (9, false)]),
        MotivoTest.troppoDuro,
      );
      expect(
        motivo(intervalli: const [(3, true), (6, true), (3, true)]),
        isNull,
      );
    });
    test(
      'almeno 4 settimane dall\'ultimo test, e "non ora" vale 2 settimane',
      () {
        expect(
          motivo(
            ftp: null,
            ultimoTest: oggi.subtract(const Duration(days: 20)),
          ),
          isNull,
        );
        expect(
          motivo(ftp: null, rimandato: oggi.add(const Duration(days: 3))),
          isNull,
        );
      },
    );
  });

  test('nuoto: subito se manca il passo, poi ogni 8 settimane', () {
    expect(
      motivoTestNuoto(ultimoTest: null, passoScritto: false, oggi: oggi),
      MotivoTest.manca,
    );
    expect(
      motivoTestNuoto(
        ultimoTest: oggi.subtract(const Duration(days: 30)),
        passoScritto: true,
        oggi: oggi,
      ),
      isNull,
    );
    expect(
      motivoTestNuoto(
        ultimoTest: oggi.subtract(const Duration(days: 57)),
        passoScritto: true,
        oggi: oggi,
      ),
      MotivoTest.vecchio,
    );
  });

  group('giorno del test', () {
    // Inizio del piano lunedì 26/10: la settimana del 23/11 viene dopo lo
    // scarico (la quarta).
    final inizio = DateTime(2026, 10, 26);
    PianoRiga r(DateTime d, String tipo, {String sport = 'Bici'}) =>
        PianoRiga(data: d, fascia: '', sport: sport, tipo: tipo);

    test('meglio le intervalli dopo la settimana di scarico', () {
      final piano = [
        r(DateTime(2026, 11, 18), 'Intervalli'),
        r(DateTime(2026, 11, 21), 'Uscita lunga'),
        r(DateTime(2026, 11, 25), 'Intervalli'),
      ];
      expect(
        sedutaPerTest(piano, 'Bici', oggi, inizio: inizio)!.data,
        DateTime(2026, 11, 25),
      );
      // Senza sapere l'inizio: la prossima seduta dura.
      expect(sedutaPerTest(piano, 'Bici', oggi)!.data, DateTime(2026, 11, 18));
    });

    test('mai al posto del lungo; nuoto al posto della soglia', () {
      expect(
        sedutaPerTest(
          [r(DateTime(2026, 11, 21), 'Uscita lunga')],
          'Bici',
          oggi,
        ),
        isNull,
      );
      expect(
        sedutaPerTest(
          [
            r(DateTime(2026, 11, 17), 'Tecnica', sport: 'Nuoto'),
            r(DateTime(2026, 11, 19), 'Soglia', sport: 'Nuoto'),
          ],
          'Nuoto',
          oggi,
        )!.data,
        DateTime(2026, 11, 19),
      );
    });
  });

  test('FTP scritto con la versione di prima: confermato adesso', () {
    final p = Profilo()..ftpManuale = 245;
    expect(datePerSoglieVecchie(p, oggi), isTrue);
    expect(p.ftpData, oggi);
    expect(p.passoCriticoData, isNull); // nessun passo scritto
    expect(datePerSoglieVecchie(p, oggi), isFalse); // una volta sola
  });

  test('il nome dato sull\'orologio dice il test', () {
    expect(testBiciDa('Ramp test'), 'rampa');
    expect(testBiciDa('Test FTP rampa'), 'rampa');
    expect(testBiciDa('FTP 20 min'), 'venti');
  });

  test('il nome dice il test', () {
    expect(testBiciDa('Test FTP $nomeTestFtpBiciRampa'), 'rampa');
    expect(testBiciDa('Test FTP'), 'venti');
    expect(testBiciDa('Uscita'), '');
    expect(eTest('Contest'), isFalse);
  });

  test('il generatore: "Test FTP" dell\'assistente diventa il test', () {
    final lunedi = DateTime(2026, 10, 19);
    PianoRiga riga(int g, String sport, String tipo) => PianoRiga(
      data: lunedi.add(Duration(days: g)),
      fascia: 'Mattina',
      sport: sport,
      tipo: tipo,
      durataMin: 60,
      note: '$notaAssistente: test',
    );
    final p = generaPianoEndurance(
      piano: [
        riga(1, 'Bici', 'Test FTP'),
        riga(3, 'Nuoto', 'Test'),
        riga(5, 'Corsa', 'Test FTP'),
      ],
      storico: const [],
      sport: {'Bici', 'Nuoto', 'Corsa'},
      inizio: lunedi,
      da: lunedi,
      ftpBici: 200,
      rampaBici: true,
    );
    final martedi = lunedi.add(const Duration(days: 1));
    expect(p.tipi[(martedi, 'Bici')], tipoTestFtp);
    final bici = p.passi.where((w) => w.id == 'bici_${isoData(martedi)}');
    expect(bici.first.nome, nomeTestFtpBiciRampa);
    expect(bici.where((w) => w.fase == 'principale').first.intensita, '100 W');
    expect(p.tipi[(lunedi.add(const Duration(days: 3)), 'Nuoto')], 'Test');
    expect(p.tipi[(lunedi.add(const Duration(days: 5)), 'Corsa')], tipoTestFtp);
  });

  test('profilo: date e test rimandati restano nel CSV', () {
    final p = Profilo()
      ..ftpData = DateTime(2026, 11, 1)
      ..passoCriticoData = DateTime(2026, 10, 1);
    p.testRimandati['Bici'] = DateTime(2026, 11, 30);
    final t = Tabella.da(toCsv([profiloHeader, ...p.toRows()]));
    final q = Profilo.da(t);
    expect(q.ftpData, DateTime(2026, 11, 1));
    expect(q.passoCriticoData, DateTime(2026, 10, 1));
    expect(q.testRimandati['Bici'], DateTime(2026, 11, 30));
    // Un profilo vecchio, senza le chiavi nuove, si legge lo stesso.
    final vecchio = Profilo.da(
      Tabella.da(
        toCsv([
          profiloHeader,
          ['ftp', '230'],
        ]),
      ),
    );
    expect(vecchio.ftpManuale, 230);
    expect(vecchio.ftpData, isNull);
    expect(vecchio.testRimandati, isEmpty);
  });
}
