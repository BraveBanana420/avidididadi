import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/registro_forza.dart';
import 'package:allenamenti_app/webhook.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Un messaggio pronto da mandare, creato [fa] prima di [ora].
MessaggioWebhook _msg(
  DateTime ora, {
  String id = 'm1',
  Duration fa = Duration.zero,
  int tentativi = 0,
  DateTime? prossimo,
}) => MessaggioWebhook(
  id: id,
  evento: eventoAllenamento,
  creato: ora.subtract(fa),
  versioneApp: '1.0.2',
  dati: {'session_id': id},
  tentativi: tentativi,
  prossimo: prossimo ?? ora.subtract(fa),
);

void main() {
  group('firma HMAC', () {
    test('vettore noto RFC 4231 (caso 2)', () {
      expect(
        firmaWebhook('what do ya want for nothing?', 'Jefe'),
        'sha256=5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843',
      );
    });

    test('la firma è sul corpo esatto: un carattere diverso la cambia', () {
      const chiave = 'segreta';
      expect(
        firmaWebhook('{"a":1}', chiave),
        isNot(firmaWebhook('{"a":2}', chiave)),
      );
    });

    test('header: firma solo con la chiave, e la chiave non compare', () {
      const chiave = 'chiave-super-segreta';
      final con = headerWebhook(eventoTest, '{}', chiave, '1.0.2');
      expect(con['Content-Type'], 'application/json');
      expect(con['X-Avidididadi-Event'], eventoTest);
      expect(con['User-Agent'], 'Avidididadi/1.0.2');
      expect(con['X-Avidididadi-Signature'], firmaWebhook('{}', chiave));
      expect(con.values.join(' '), isNot(contains(chiave)));
      final senza = headerWebhook(eventoTest, '{}', null, '1.0.2');
      expect(senza.containsKey('X-Avidididadi-Signature'), isFalse);
      expect(
        headerWebhook(eventoTest, '{}', '', '1.0.2'),
        isNot(contains('X-Avidididadi-Signature')),
      );
    });

    test('chiave generata: 64 caratteri esadecimali, ogni volta diversa', () {
      final a = generaChiaveWebhook();
      expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(generaChiaveWebhook(), isNot(a));
    });
  });

  group('indirizzo', () {
    test('solo https completi', () {
      expect(urlWebhookValido('https://ha.local:8123/api/webhook/abc'), isTrue);
      expect(urlWebhookValido(' https://n8n.example.com/webhook/x '), isTrue);
      expect(urlWebhookValido('http://example.com/hook'), isFalse);
      expect(urlWebhookValido('https://'), isFalse);
      expect(urlWebhookValido('example.com/hook'), isFalse);
      expect(urlWebhookValido('https://exa mple.com'), isFalse);
      expect(urlWebhookValido('https://utente:pw@example.com'), isFalse);
      expect(urlWebhookValido(''), isFalse);
    });
  });

  group('payload', () {
    final giorno = DateTime(2026, 11, 18);
    final serie = [
      SerieFatta(
        data: giorno,
        esercizio: 'squat',
        nome: 'Squat',
        serie: 2,
        ripetizioni: 8,
        kg: 60,
      ),
      SerieFatta(
        data: giorno,
        esercizio: 'squat',
        nome: 'Squat',
        serie: 1,
        ripetizioni: 8,
        kg: 57.5,
      ),
      SerieFatta(
        data: giorno,
        esercizio: '',
        nome: 'Plank',
        serie: 1,
        ripetizioni: 0,
        secondi: 45,
      ),
      // Un altro giorno: non c'entra.
      SerieFatta(
        data: DateTime(2026, 11, 11),
        esercizio: 'squat',
        nome: 'Squat',
        serie: 1,
        ripetizioni: 8,
        kg: 55,
      ),
    ];
    final forza = Sessione(
      id: 'app-2026-11-18-forza',
      data: giorno,
      inizio: DateTime(2026, 11, 18, 18, 30),
      fine: DateTime(2026, 11, 18, 19, 15),
      sport: 'Forza',
      tipo: 'Gambe',
      durataMin: 45,
      fcMedia: 112,
      fcMax: 151,
      calorieAttive: 260,
      fonte: 'App',
      note: 'Forza A',
    );

    test('allenamento di forza: campi in inglese, serie in ordine', () {
      final d = datiAllenamento(forza, serie);
      expect(d['session_id'], 'app-2026-11-18-forza');
      expect(d['date'], '2026-11-18');
      expect(d['sport'], 'Forza'); // i valori restano quelli salvati
      expect(d['session_type'], 'Gambe');
      expect(d['duration_min'], 45);
      expect(d['distance_km'], isNull);
      expect(d['hr_avg'], 112);
      expect(d['hr_max'], 151);
      expect(d['calories_active'], 260.0);
      expect(d['power_avg'], isNull);
      expect(d['notes'], 'Forza A');
      expect(d['start'], startsWith('2026-11-18T18:30:00'));
      final es = d['exercises']! as List;
      expect(es, hasLength(2));
      final squat = es.first as Map;
      expect(squat['exercise_id'], 'squat');
      expect(squat['name'], 'Squat');
      expect(squat['sets'], [
        {'set': 1, 'reps': 8, 'kg': 57.5, 'seconds': null},
        {'set': 2, 'reps': 8, 'kg': 60.0, 'seconds': null},
      ]);
      final plank = es.last as Map;
      expect(plank['exercise_id'], isNull);
      expect((plank['sets'] as List).single, {
        'set': 1,
        'reps': null,
        'kg': null,
        'seconds': 45,
      });
    });

    test('bici con watt e cadenza, senza esercizi', () {
      final bici = Sessione(
        id: 'app-2026-11-18-bici',
        data: giorno,
        sport: 'Bici',
        tipo: 'Rulli',
        durataMin: 60,
        distanzaKm: 28.4567,
        fcMedia: 138,
        potenzaMedia: 182,
        cadenzaMedia: 88,
      );
      final d = datiAllenamento(bici, serie);
      expect(d['distance_km'], 28.457);
      expect(d['power_avg'], 182);
      expect(d['cadence_avg'], 88);
      expect(d['exercises'], isEmpty);
      expect(d['start'], isNull);
    });

    test('busta con versione dello schema, uuid e ora col fuso', () {
      final m = MessaggioWebhook.nuovo(
        eventoAllenamento,
        datiAllenamento(forza, serie),
        versioneApp: '1.0.2',
      );
      final j = jsonDecode(m.corpo(DateTime(2026, 11, 18, 19, 16)));
      expect(j['schema_version'], 1);
      expect(j['event'], 'allenamento_completato');
      expect(
        j['id'],
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(
        j['sent_at'],
        matches(RegExp(r'^2026-11-18T19:16:00[+-]\d\d:\d\d$')),
      );
      expect(j['app_version'], '1.0.2');
      expect((j['data'] as Map)['session_id'], 'app-2026-11-18-forza');
    });

    test('uuid diversi e sempre di versione 4', () {
      final r = math.Random(7);
      final a = uuidV4(r);
      final b = uuidV4(r);
      expect(a, isNot(b));
      expect(a[14], '4');
      expect('89ab', contains(a[19]));
    });

    test('ora con il fuso, anche per l\'UTC', () {
      final s = isoConFuso(DateTime.utc(2026, 1, 2, 3, 4, 5));
      final l = DateTime.utc(2026, 1, 2, 3, 4, 5).toLocal();
      expect(s, startsWith('${isoData(l)}T${two(l.hour)}:'));
      expect(s, matches(RegExp(r'[+-]\d\d:\d\d$')));
    });

    test('piano: solo da oggi in poi, in ordine', () {
      final piano = [
        PianoRiga(
          data: DateTime(2026, 11, 22),
          fascia: 'Mattina',
          sport: 'Corsa',
          tipo: 'Lungo',
          durataMin: 75,
          distanzaKm: '14',
          intensita: 'zona 2',
        ),
        PianoRiga(data: DateTime(2026, 11, 17), fascia: 'Sera', sport: 'Forza'),
        PianoRiga(
          data: DateTime(2026, 11, 20),
          fascia: 'Sera',
          sport: 'Nuoto',
          durataMin: 40,
          distanzaKm: '1,5',
        ),
      ];
      final d = datiPiano(piano, DateTime(2026, 11, 20, 9));
      expect(d['from'], '2026-11-20');
      final s = d['sessions']! as List;
      expect(s.map((x) => (x as Map)['date']), ['2026-11-20', '2026-11-22']);
      expect((s.first as Map)['distance_km'], 1.5);
      expect((s.last as Map)['intensity'], 'zona 2');
      expect((s.last as Map)['slot'], 'Mattina');
      // L'impronta cambia solo se cambia il piano.
      expect(hashPiano(piano), hashPiano([...piano]));
      expect(hashPiano(piano), isNot(hashPiano(piano.sublist(1))));
    });
  });

  group('record', () {
    final oggi = DateTime(2026, 11, 20);
    SerieFatta s(DateTime d, double kg, {int rip = 5}) => SerieFatta(
      data: d,
      esercizio: 'stacco',
      nome: 'Stacco',
      serie: 1,
      ripetizioni: rip,
      kg: kg,
    );
    Sessione corsa(String id, DateTime d, double km) =>
        Sessione(id: id, data: d, sport: 'Corsa', distanzaKm: km);

    test('più kg di sempre in un esercizio, negli ultimi giorni', () {
      final r = recordRecenti(
        serie: [
          s(DateTime(2026, 11, 1), 80),
          s(DateTime(2026, 11, 10), 85),
          s(oggi, 90, rip: 3),
          s(oggi, 85, rip: 5),
        ],
        sessioni: const [],
        oggi: oggi,
      );
      expect(r, hasLength(1));
      expect(r.single.dati['record_type'], 'strength');
      expect(r.single.dati['value'], 90.0);
      expect(r.single.dati['previous_value'], 85.0);
      expect(r.single.dati['reps'], 3);
      expect(r.single.chiave, 'record:forza:stacco:2026-11-20:90');
    });

    test('la prima volta non è un record, né lo stesso peso', () {
      expect(
        recordRecenti(serie: [s(oggi, 90)], sessioni: const [], oggi: oggi),
        isEmpty,
      );
      expect(
        recordRecenti(
          serie: [s(DateTime(2026, 11, 1), 90), s(oggi, 90)],
          sessioni: const [],
          oggi: oggi,
        ),
        isEmpty,
      );
    });

    test('distanza più lunga, con almeno tre sedute', () {
      final prima = [
        corsa('a', DateTime(2026, 11, 2), 10),
        corsa('b', DateTime(2026, 11, 9), 12),
      ];
      expect(
        recordRecenti(
          serie: const [],
          sessioni: [...prima.take(1), corsa('c', oggi, 15)],
          oggi: oggi,
        ),
        isEmpty,
      );
      final r = recordRecenti(
        serie: const [],
        sessioni: [...prima, corsa('c', oggi, 15.2)],
        oggi: oggi,
      );
      expect(r.single.dati['record_type'], 'distance');
      expect(r.single.dati['value'], 15.2);
      expect(r.single.dati['previous_value'], 12.0);
      expect(r.single.dati['session_id'], 'c');
      // Un record di un mese fa non riparte.
      expect(
        recordRecenti(
          serie: const [],
          sessioni: [...prima, corsa('c', DateTime(2026, 10, 1), 20)],
          oggi: oggi,
        ),
        isEmpty,
      );
    });
  });

  group('impostazioni', () {
    test('spento di default, con tutti gli eventi', () {
      const w = ImpostazioniWebhook();
      expect(w.attivo, isFalse);
      expect(w.vuole(eventoAllenamento), isFalse);
      expect(w.eventi, eventiWebhook.toSet());
      expect(ImpostazioniWebhook.da(null).attivo, isFalse);
    });

    test('si rilegge dal CSV', () {
      const w = ImpostazioniWebhook(
        attivo: true,
        eventi: {eventoRecord},
        origini: origineTutti,
        hashPiano: 'abc',
      );
      final t = Tabella.da(
        toCsv([
          ['chiave', 'valore'],
          ...w.toRows(),
        ]),
      );
      final r = ImpostazioniWebhook.da(t);
      expect(r.attivo, isTrue);
      expect(r.eventi, {eventoRecord});
      expect(r.vuole(eventoRecord), isTrue);
      expect(r.vuole(eventoPiano), isFalse);
      expect(r.origini, origineTutti);
      expect(r.hashPiano, 'abc');
    });
  });

  group('coda e tentativi', () {
    late Directory cartella;
    late CodaWebhook coda;
    final ora = DateTime(2026, 11, 20, 10);
    setUp(() async {
      cartella = await Directory.systemTemp.createTemp('webhook_test');
      coda = CodaWebhook(cartella);
    });
    tearDown(() => cartella.delete(recursive: true));

    /// Un server finto che risponde sempre [codice] e ricorda le richieste.
    (http.Client, List<http.Request>) server(int codice) {
      final ricevute = <http.Request>[];
      return (
        MockClient((r) async {
          ricevute.add(r);
          return http.Response('', codice);
        }),
        ricevute,
      );
    }

    Future<RisultatoCoda> svuota(http.Client c, {String? chiave}) =>
        coda.svuota(
          client: c,
          url: 'https://example.com/hook',
          chiave: chiave,
          orologio: () => ora,
        );

    test('attese crescenti: 1, 5, 15 minuti, poi un\'ora', () {
      expect(
        [for (var i = 1; i <= 6; i++) attesaWebhook(i).inMinutes],
        [1, 5, 15, 60, 60, 60],
      );
    });

    test('cosa si ritenta e cosa no', () {
      expect(const EsitoWebhook.http(200).riuscito, isTrue);
      expect(const EsitoWebhook.http(204).riuscito, isTrue);
      expect(const EsitoWebhook.http(500).daRitentare, isTrue);
      expect(const EsitoWebhook.http(503).daRitentare, isTrue);
      expect(const EsitoWebhook.http(429).daRitentare, isTrue);
      expect(const EsitoWebhook.http(400).daRitentare, isFalse);
      expect(const EsitoWebhook.http(401).daRitentare, isFalse);
      expect(const EsitoWebhook.http(404).daRitentare, isFalse);
      expect(const EsitoWebhook.errore('timeout').daRitentare, isTrue);
      expect(const EsitoWebhook.errore('rete').daRitentare, isTrue);
      expect(const EsitoWebhook.errore('altro').daRitentare, isFalse);
    });

    test('riuscito: esce dalla coda, con header e firma giusti', () async {
      await coda.aggiungi([_msg(ora)]);
      final (c, ricevute) = server(200);
      final r = await svuota(c, chiave: 'k');
      expect(r.rimasti, 0);
      expect(r.stato.ultimoOk, ora);
      expect(await coda.leggi(), isEmpty);
      final req = ricevute.single;
      expect(req.method, 'POST');
      expect(req.headers['X-Avidididadi-Event'], eventoAllenamento);
      expect(req.headers['User-Agent'], 'Avidididadi/1.0.2');
      expect(
        req.headers['X-Avidididadi-Signature'],
        firmaWebhook(req.body, 'k'),
      );
      expect((jsonDecode(req.body) as Map)['id'], 'm1');
    });

    test(
      'errore 5xx: resta, con un tentativo in più e la prossima attesa',
      () async {
        await coda.aggiungi([_msg(ora)]);
        final (c, _) = server(503);
        final r = await svuota(c);
        expect(r.rimasti, 1);
        expect(r.stato.codiceErrore, 503);
        expect(r.stato.scartati, 0);
        final m = (await coda.leggi()).single;
        expect(m.tentativi, 1);
        expect(m.prossimo, ora.add(const Duration(minutes: 1)));
        expect(m.id, 'm1'); // stesso id a ogni tentativo
      },
    );

    test('non ancora il momento: non parte', () async {
      await coda.aggiungi([
        _msg(ora, prossimo: ora.add(const Duration(minutes: 5))),
      ]);
      final (c, ricevute) = server(200);
      final r = await svuota(c);
      expect(ricevute, isEmpty);
      expect(r.rimasti, 1);
      expect(r.prossimo, ora.add(const Duration(minutes: 5)));
    });

    test('errore 4xx: scartato subito, senza ritentare', () async {
      await coda.aggiungi([_msg(ora)]);
      final (c, _) = server(404);
      final r = await svuota(c);
      expect(r.rimasti, 0);
      expect(r.stato.scartati, 1);
      expect(r.stato.codiceErrore, 404);
    });

    test('429: si ritenta', () async {
      await coda.aggiungi([_msg(ora)]);
      final (c, _) = server(429);
      expect((await svuota(c)).rimasti, 1);
    });

    test('dopo 10 tentativi si scarta', () async {
      await coda.aggiungi([_msg(ora, tentativi: 9)]);
      final (c, _) = server(500);
      final r = await svuota(c);
      expect(r.rimasti, 0);
      expect(r.stato.scartati, 1);
    });

    test('più vecchio di 7 giorni: scartato senza mandarlo', () async {
      await coda.aggiungi([_msg(ora, fa: const Duration(days: 7, minutes: 1))]);
      final (c, ricevute) = server(200);
      final r = await svuota(c);
      expect(ricevute, isEmpty);
      expect(r.rimasti, 0);
      expect(r.stato.tipoErrore, 'scaduto');
      expect(r.stato.scartati, 1);
    });

    test('senza rete: si ferma al primo e tiene tutto', () async {
      await coda.aggiungi([
        _msg(ora, id: 'a', fa: const Duration(minutes: 2)),
        _msg(ora, id: 'b', fa: const Duration(minutes: 1)),
      ]);
      var chiamate = 0;
      final c = MockClient((_) async {
        chiamate++;
        throw const SocketException('offline');
      });
      final r = await svuota(c);
      expect(chiamate, 1);
      expect(r.rimasti, 2);
      expect(r.stato.tipoErrore, 'rete');
      final m = {for (final x in await coda.leggi()) x.id: x};
      expect(m['a']!.tentativi, 1);
      expect(m['b']!.tentativi, 0);
    });

    test(
      'in ordine dal più vecchio, e quelli aggiunti nel frattempo restano',
      () async {
        await coda.aggiungi([
          _msg(ora, id: 'nuovo', fa: const Duration(minutes: 1)),
          _msg(ora, id: 'vecchio', fa: const Duration(minutes: 9)),
        ]);
        final ordine = <String>[];
        var aggiunto = false;
        final c = MockClient((r) async {
          ordine.add((jsonDecode(r.body) as Map)['id'] as String);
          if (!aggiunto) {
            aggiunto = true;
            // Un allenamento salvato mentre si manda la coda.
            await coda.aggiungi([
              _msg(
                ora,
                id: 'intanto',
                prossimo: ora.add(const Duration(hours: 1)),
              ),
            ]);
          }
          return http.Response('ok', 200);
        });
        final r = await svuota(c);
        expect(ordine, ['vecchio', 'nuovo']);
        expect(r.rimasti, 1);
        expect((await coda.leggi()).single.id, 'intanto');
      },
    );

    test('lo stato e la coda sopravvivono alla chiusura dell\'app', () async {
      await coda.aggiungi([_msg(ora)]);
      final (c, _) = server(500);
      await svuota(c);
      final dopo = CodaWebhook(cartella);
      expect((await dopo.leggi()).single.tentativi, 1);
      expect((await dopo.stato()).codiceErrore, 500);
    });

    test('mentre un altro la sta mandando, non la manda due volte', () async {
      await coda.aggiungi([_msg(ora)]);
      await File('${cartella.path}/webhook_coda.lock').create();
      final (c, ricevute) = server(200);
      final r = await coda.svuota(
        client: c,
        url: 'https://example.com/hook',
        orologio: DateTime.now,
      );
      expect(ricevute, isEmpty);
      expect(r.rimasti, 1);
    });

    test('timeout e certificato: uno si ritenta, l\'altro no', () async {
      final lento = MockClient((_) => throw TimeoutException('lento'));
      final e = await inviaWebhook(
        lento,
        'https://example.com',
        null,
        _msg(ora),
      );
      expect(e.errore, 'timeout');
      expect(e.daRitentare, isTrue);
      final cert = MockClient(
        (_) => throw const HandshakeException('certificato scaduto'),
      );
      final c = await inviaWebhook(
        cert,
        'https://example.com',
        null,
        _msg(ora),
      );
      expect(c.errore, 'altro');
      expect(c.daRitentare, isFalse);
    });

    test('file della coda rovinato: si riparte da vuota', () async {
      await File('${cartella.path}/$fileCodaWebhook').writeAsString('{rotto');
      expect(await coda.leggi(), isEmpty);
    });
  });

  test('coda e stato restano fuori dal backup, le impostazioni no', () {
    final csv = RegExp(r'^[a-z0-9_]+\.csv$');
    expect(csv.hasMatch(fileCodaWebhook), isFalse);
    expect(csv.hasMatch(fileStatoWebhook), isFalse);
    expect(csv.hasMatch(fileImpostazioniWebhook), isTrue);
    expect(csv.hasMatch(fileInviatiWebhook), isTrue);
  });
}
