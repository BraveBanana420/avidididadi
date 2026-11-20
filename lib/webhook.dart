import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'csv.dart';
import 'models.dart';
import 'registro_forza.dart';

// Webhook in uscita: a ogni evento scelto (allenamento finito, piano cambiato,
// record) l'app manda un JSON a un indirizzo https scelto dall'utente (Home
// Assistant, n8n, Node-RED…). Nessun server nostro. Se l'invio non riesce il
// messaggio resta in una coda su file e si ritenta più tardi, anche con l'app
// chiusa (vedi webhook_sfondo.dart). Formato descritto in docs/WEBHOOK.md.

/// Versione del formato del JSON: sale solo se cambia in modo incompatibile.
const versioneSchemaWebhook = 1;

const eventoAllenamento = 'allenamento_completato';
const eventoPiano = 'piano_aggiornato';
const eventoRecord = 'nuovo_record';
const eventoTest = 'test';

/// Gli eventi che l'utente può scegliere, nell'ordine della pagina.
const eventiWebhook = [eventoAllenamento, eventoPiano, eventoRecord];

/// Quali allenamenti mandare: solo quelli registrati con l'app, o anche quelli
/// arrivati da Health Connect, intervals.icu e CSV. Vuoto: non ancora scelto.
const origineApp = 'app';
const origineTutti = 'tutti';

/// Attesa prima di ogni richiesta: oltre si considera fallita.
const tempoRichiestaWebhook = Duration(seconds: 10);

/// Dopo questi tentativi falliti il messaggio si scarta.
const maxTentativiWebhook = 10;

/// Un messaggio più vecchio di così si scarta anche se ha tentativi.
const durataMaxWebhook = Duration(days: 7);

/// File dentro la cartella privata. La coda e lo stato sono .json, apposta
/// fuori dal backup: non ha senso ripristinare invii vecchi.
const fileImpostazioniWebhook = 'webhook.csv';
const fileInviatiWebhook = 'webhook_inviati.csv';
const fileCodaWebhook = 'webhook_coda.json';
const fileStatoWebhook = 'webhook_stato.json';
const _fileBlocco = 'webhook_coda.lock';

// ---------------------------------------------------------------------------
// Impostazioni

/// Interruttore, eventi scelti e origine degli allenamenti. L'indirizzo e la
/// chiave segreta stanno invece in [SegretiWebhook].
class ImpostazioniWebhook {
  final bool attivo;
  final Set<String> eventi;
  final String origini; // origineApp, origineTutti o '' se non ancora scelto
  final String hashPiano; // impronta dell'ultimo piano mandato

  const ImpostazioniWebhook({
    this.attivo = false,
    this.eventi = const {eventoAllenamento, eventoPiano, eventoRecord},
    this.origini = '',
    this.hashPiano = '',
  });

  ImpostazioniWebhook copyWith({
    bool? attivo,
    Set<String>? eventi,
    String? origini,
    String? hashPiano,
  }) => ImpostazioniWebhook(
    attivo: attivo ?? this.attivo,
    eventi: eventi ?? this.eventi,
    origini: origini ?? this.origini,
    hashPiano: hashPiano ?? this.hashPiano,
  );

  bool vuole(String evento) => attivo && eventi.contains(evento);

  List<List<String>> toRows() => [
    ['attivo', attivo ? 'si' : ''],
    ['eventi', eventiWebhook.where(eventi.contains).join(' ')],
    ['origini', origini],
    ['hash_piano', hashPiano],
  ];

  static ImpostazioniWebhook da(Tabella? t) {
    if (t == null) return const ImpostazioniWebhook();
    final m = {for (final r in t.righe) t.v(r, 'chiave'): t.v(r, 'valore')};
    return ImpostazioniWebhook(
      attivo: m['attivo'] == 'si',
      eventi: m.containsKey('eventi')
          ? {
              for (final e in m['eventi']!.split(' '))
                if (eventiWebhook.contains(e)) e,
            }
          : const ImpostazioniWebhook().eventi,
      origini: switch (m['origini']) {
        origineApp => origineApp,
        origineTutti => origineTutti,
        _ => '',
      },
      hashPiano: m['hash_piano'] ?? '',
    );
  }
}

/// Indirizzo e chiave segreta nell'archivio cifrato di Android: mai nei CSV,
/// nel backup o nei log. Anche l'indirizzo, perché spesso contiene già un
/// segreto (l'id del webhook di Home Assistant, per esempio).
class SegretiWebhook {
  static const _archivio = FlutterSecureStorage();
  static const _url = 'webhook_url';
  static const _chiave = 'webhook_chiave';

  static Future<String?> _leggi(String nome) async {
    try {
      final v = await _archivio.read(key: nome);
      return v == null || v.isEmpty ? null : v;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> url() => _leggi(_url);
  static Future<String?> chiave() => _leggi(_chiave);

  static Future<void> salva(String url, String chiave) async {
    await _archivio.write(key: _url, value: url.trim());
    if (chiave.trim().isEmpty) {
      await _archivio.delete(key: _chiave);
    } else {
      await _archivio.write(key: _chiave, value: chiave.trim());
    }
  }
}

/// Solo indirizzi https completi: i dati degli allenamenti non viaggiano in
/// chiaro.
bool urlWebhookValido(String testo) {
  final t = testo.trim();
  if (t.isEmpty || t.contains(RegExp(r'\s'))) return false;
  final u = Uri.tryParse(t);
  return u != null &&
      u.scheme == 'https' &&
      u.host.isNotEmpty &&
      u.userInfo.isEmpty;
}

// ---------------------------------------------------------------------------
// Firma, id e date

/// `sha256=<hex>`: HMAC-SHA256 del corpo esatto con la chiave segreta. Chi
/// riceve rifà il conto e scarta i messaggi che non tornano.
String firmaWebhook(String corpo, String chiave) {
  final h = Hmac(sha256, utf8.encode(chiave)).convert(utf8.encode(corpo));
  return 'sha256=$h';
}

/// Chiave segreta nuova: 32 byte casuali in esadecimale (64 caratteri).
String generaChiaveWebhook([math.Random? caso]) {
  final r = caso ?? math.Random.secure();
  return [
    for (var i = 0; i < 32; i++)
      r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// Uuid versione 4 (casuale), per riconoscere i doppioni da chi riceve.
String uuidV4([math.Random? caso]) {
  final r = caso ?? math.Random.secure();
  final b = [for (var i = 0; i < 16; i++) r.nextInt(256)];
  b[6] = (b[6] & 0x0f) | 0x40; // versione 4
  b[8] = (b[8] & 0x3f) | 0x80; // variante RFC 4122
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}

/// "2026-11-20T08:15:30+01:00": ora locale con il fuso, come vuole ISO 8601
/// (toIso8601String di Dart il fuso lo mette solo per l'UTC).
String isoConFuso(DateTime d) {
  final l = d.toLocal();
  final o = l.timeZoneOffset;
  final segno = o.isNegative ? '-' : '+';
  final m = o.inMinutes.abs();
  return '${isoData(l)}T${two(l.hour)}:${two(l.minute)}:${two(l.second)}'
      '$segno${two(m ~/ 60)}:${two(m % 60)}';
}

// ---------------------------------------------------------------------------
// Dati degli eventi (campi del CSV in inglese, snake_case)

int? _int(int v) => v > 0 ? v : null;
double? _num(double v) => v > 0 ? double.parse(v.toStringAsFixed(3)) : null;

/// Gli esercizi di forza di un giorno, con le serie in ordine.
List<Map<String, Object?>> datiEsercizi(List<SerieFatta> serie) {
  final gruppi = <String, List<SerieFatta>>{};
  for (final s in serie) {
    (gruppi[s.chiave] ??= []).add(s);
  }
  return [
    for (final g in gruppi.values)
      {
        'exercise_id': g.first.esercizio.isEmpty ? null : g.first.esercizio,
        'name': g.first.nome,
        'sets': [
          for (final s in g..sort((a, b) => a.serie.compareTo(b.serie)))
            {
              'set': s.serie,
              'reps': _int(s.ripetizioni),
              'kg': _num(s.kg),
              'seconds': _int(s.secondi),
            },
        ],
      },
  ];
}

/// L'allenamento fatto. Per la forza anche le serie dello stesso giorno.
/// Niente percorso GPS: resta sul telefono.
Map<String, Object?> datiAllenamento(Sessione s, List<SerieFatta> serie) {
  final d = soloData(s.data);
  final forza = stessoSport(s.sport, 'Forza')
      ? serie.where((x) => x.data == d).toList()
      : const <SerieFatta>[];
  return {
    'session_id': s.id,
    'date': isoData(s.data),
    'sport': s.sport,
    'session_type': s.tipo,
    'start': s.inizio == null ? null : isoConFuso(s.inizio!),
    'end': s.fine == null ? null : isoConFuso(s.fine!),
    'duration_min': s.durataMin,
    'distance_km': _num(s.distanzaKm),
    'hr_avg': _int(s.fcMedia),
    'hr_max': _int(s.fcMax),
    'rpe': s.rpe > 0 ? s.rpe : null,
    'calories_active': _num(s.calorieAttive),
    'calories_total': _num(s.calorieTotali),
    'steps': _int(s.passi),
    'power_avg': _int(s.potenzaMedia),
    'cadence_avg': _int(s.cadenzaMedia),
    'source': s.fonte,
    'origin': s.origine,
    'notes': s.note,
    'exercises': datiEsercizi(forza),
  };
}

/// Le sedute in programma da oggi in poi.
Map<String, Object?> datiPiano(List<PianoRiga> piano, DateTime oggi) {
  final d = soloData(oggi);
  final prossime = piano.where((r) => !r.data.isBefore(d)).toList()
    ..sort((a, b) => a.data.compareTo(b.data));
  return {
    'from': isoData(d),
    'sessions': [
      for (final r in prossime)
        {
          'date': isoData(r.data),
          'slot': r.fascia,
          'sport': r.sport,
          'session_type': r.tipo,
          'duration_min': r.durataMin,
          'distance_km': double.tryParse(r.distanzaKm.replaceAll(',', '.')),
          'intensity': r.intensita,
          'notes': r.note,
        },
    ],
  };
}

/// Impronta del piano: si manda solo quando cambia davvero, non a ogni
/// salvataggio uguale (all'avvio l'app riscrive il piano spesso).
String hashPiano(List<PianoRiga> piano) => sha256
    .convert(utf8.encode(toCsv([for (final r in piano) r.toRow()])))
    .toString();

/// Un record nuovo, con la chiave che lo rende unico (per non mandarlo due
/// volte).
class RecordWebhook {
  final String chiave;
  final Map<String, Object?> dati;
  const RecordWebhook(this.chiave, this.dati);
}

/// Sport in cui conta la distanza più lunga.
const _sportDistanza = ['Corsa', 'Bici', 'Nuoto', 'Camminata'];

/// I record degli ultimi [giorni] giorni: più kg di sempre in un esercizio
/// (come "record" in Oggi) e distanza più lunga di sempre in uno sport, con
/// almeno tre sedute (con una o due ogni uscita sarebbe un record).
List<RecordWebhook> recordRecenti({
  required List<SerieFatta> serie,
  required List<Sessione> sessioni,
  required DateTime oggi,
  int giorni = 2,
}) {
  final o = soloData(oggi);
  final da = DateTime(o.year, o.month, o.day - giorni);
  final out = <RecordWebhook>[];
  final conKg = serie.where((s) => s.kg > 0).toList();
  final giorniForza = {
    for (final s in conKg)
      if (!s.data.isBefore(da) && !s.data.isAfter(o)) s.data,
  }.toList()..sort();
  for (final d in giorniForza) {
    final delGiorno = conKg.where((s) => s.data == d);
    for (final chiave in {for (final s in delGiorno) s.chiave}) {
      final mie = delGiorno.where((s) => s.chiave == chiave).toList();
      final prima = conKg.where(
        (s) => s.chiave == chiave && s.data.isBefore(d),
      );
      if (prima.isEmpty) continue;
      final kg = mie.map((s) => s.kg).reduce(math.max);
      final kgPrima = prima.map((s) => s.kg).reduce(math.max);
      if (kg <= kgPrima) continue;
      final rip = mie
          .where((s) => s.kg == kg)
          .map((s) => s.ripetizioni)
          .reduce(math.max);
      out.add(
        RecordWebhook('record:forza:$chiave:${isoData(d)}:${fmtKg(kg)}', {
          'record_type': 'strength',
          'date': isoData(d),
          'sport': 'Forza',
          'exercise_id': mie.first.esercizio.isEmpty
              ? null
              : mie.first.esercizio,
          'name': mie.first.nome,
          'value': kg,
          'unit': 'kg',
          'previous_value': kgPrima,
          'reps': rip,
          'session_id': null,
        }),
      );
    }
  }
  for (final sport in _sportDistanza) {
    final mie = [
      for (final s in sessioni)
        if (stessoSport(s.sport, sport) && s.distanzaKm > 0) s,
    ];
    if (mie.length < 3) continue;
    final migliore = mie.reduce((a, b) => b.distanzaKm > a.distanzaKm ? b : a);
    final altre = mie.where((s) => !identical(s, migliore));
    final prima = altre.map((s) => s.distanzaKm).reduce(math.max);
    final d = soloData(migliore.data);
    if (prima >= migliore.distanzaKm || d.isBefore(da) || d.isAfter(o)) {
      continue;
    }
    out.add(
      RecordWebhook('record:distanza:$sport:${migliore.id}', {
        'record_type': 'distance',
        'date': isoData(d),
        'sport': migliore.sport,
        'exercise_id': null,
        'name': null,
        'value': _num(migliore.distanzaKm),
        'unit': 'km',
        'previous_value': _num(prima),
        'reps': null,
        'session_id': migliore.id,
      }),
    );
  }
  return out;
}

// ---------------------------------------------------------------------------
// Messaggi e invio

/// Un evento da mandare, com'è salvato nella coda. L'id resta lo stesso a
/// ogni tentativo: chi riceve può scartare i doppioni.
class MessaggioWebhook {
  final String id;
  final String evento;
  final DateTime creato;
  final String versioneApp;
  final Map<String, Object?> dati;
  final int tentativi;
  final DateTime prossimo; // non prima di questo momento

  const MessaggioWebhook({
    required this.id,
    required this.evento,
    required this.creato,
    required this.versioneApp,
    required this.dati,
    this.tentativi = 0,
    required this.prossimo,
  });

  factory MessaggioWebhook.nuovo(
    String evento,
    Map<String, Object?> dati, {
    required String versioneApp,
    DateTime? ora,
  }) {
    final o = ora ?? DateTime.now();
    return MessaggioWebhook(
      id: uuidV4(),
      evento: evento,
      creato: o,
      versioneApp: versioneApp,
      dati: dati,
      prossimo: o,
    );
  }

  MessaggioWebhook riprova(DateTime ora) => MessaggioWebhook(
    id: id,
    evento: evento,
    creato: creato,
    versioneApp: versioneApp,
    dati: dati,
    tentativi: tentativi + 1,
    prossimo: ora.add(attesaWebhook(tentativi + 1)),
  );

  /// Il corpo della richiesta, con l'ora dell'invio.
  String corpo(DateTime ora) => jsonEncode({
    'schema_version': versioneSchemaWebhook,
    'event': evento,
    'id': id,
    'sent_at': isoConFuso(ora),
    'app_version': versioneApp,
    'data': dati,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'evento': evento,
    'creato': creato.toUtc().toIso8601String(),
    'versione_app': versioneApp,
    'dati': dati,
    'tentativi': tentativi,
    'prossimo': prossimo.toUtc().toIso8601String(),
  };

  static MessaggioWebhook? daJson(Object? j) {
    if (j is! Map) return null;
    final creato = DateTime.tryParse('${j['creato']}');
    final prossimo = DateTime.tryParse('${j['prossimo']}');
    final dati = j['dati'];
    if (creato == null || prossimo == null || dati is! Map) return null;
    return MessaggioWebhook(
      id: '${j['id']}',
      evento: '${j['evento']}',
      creato: creato.toLocal(),
      versioneApp: '${j['versione_app'] ?? ''}',
      dati: dati.cast<String, Object?>(),
      tentativi: (j['tentativi'] as num?)?.toInt() ?? 0,
      prossimo: prossimo.toLocal(),
    );
  }
}

/// Attesa dopo l'n-esimo tentativo fallito: 1, 5, 15 minuti, poi un'ora.
Duration attesaWebhook(int tentativi) => switch (tentativi) {
  <= 1 => const Duration(minutes: 1),
  2 => const Duration(minutes: 5),
  3 => const Duration(minutes: 15),
  _ => const Duration(minutes: 60),
};

/// Come è andata una richiesta: il codice HTTP, oppure un errore senza
/// risposta ('timeout', 'rete', 'altro').
class EsitoWebhook {
  final int codice; // 0 se non è arrivata una risposta
  final String errore;
  const EsitoWebhook.http(this.codice) : errore = '';
  const EsitoWebhook.errore(this.errore) : codice = 0;

  bool get riuscito => codice >= 200 && codice < 300;

  /// Offline, timeout, errore del server o "troppe richieste": si ritenta.
  /// Gli altri 4xx (indirizzo o chiave sbagliati) no: non cambierebbe niente.
  bool get daRitentare =>
      codice == 0 && errore != 'altro' || codice == 429 || codice >= 500;
}

/// Gli header della richiesta. La chiave non compare: solo la firma.
Map<String, String> headerWebhook(
  String evento,
  String corpo,
  String? chiave,
  String versioneApp,
) => {
  'Content-Type': 'application/json',
  'X-Avidididadi-Event': evento,
  if (chiave != null && chiave.isNotEmpty)
    'X-Avidididadi-Signature': firmaWebhook(corpo, chiave),
  'User-Agent': 'Avidididadi/$versioneApp',
};

/// Manda un messaggio, con [tempoRichiestaWebhook] di tempo al massimo.
Future<EsitoWebhook> inviaWebhook(
  http.Client client,
  String url,
  String? chiave,
  MessaggioWebhook m, {
  DateTime? ora,
}) async {
  final corpo = m.corpo(ora ?? DateTime.now());
  try {
    final r = await client
        .post(
          Uri.parse(url),
          headers: headerWebhook(m.evento, corpo, chiave, m.versioneApp),
          body: utf8.encode(corpo),
        )
        .timeout(tempoRichiestaWebhook);
    return EsitoWebhook.http(r.statusCode);
  } on TimeoutException {
    return const EsitoWebhook.errore('timeout');
  } on SocketException {
    return const EsitoWebhook.errore('rete');
  } on HandshakeException {
    return const EsitoWebhook.errore('altro');
  } on http.ClientException {
    return const EsitoWebhook.errore('rete');
  } on HttpException {
    return const EsitoWebhook.errore('rete');
  } catch (_) {
    return const EsitoWebhook.errore('altro');
  }
}

// ---------------------------------------------------------------------------
// Stato e coda

/// Quello che mostra la riga di stato: ultimo invio riuscito, ultimo errore,
/// messaggi scartati. Su file, perché lo scrive anche l'invio ad app chiusa.
class StatoWebhook {
  final DateTime? ultimoOk;
  final DateTime? ultimoErrore;
  final int codiceErrore;
  final String tipoErrore; // 'timeout', 'rete', 'altro', 'scaduto' o ''
  final int scartati;

  const StatoWebhook({
    this.ultimoOk,
    this.ultimoErrore,
    this.codiceErrore = 0,
    this.tipoErrore = '',
    this.scartati = 0,
  });

  StatoWebhook conOk(DateTime ora) => StatoWebhook(
    ultimoOk: ora,
    ultimoErrore: ultimoErrore,
    codiceErrore: codiceErrore,
    tipoErrore: tipoErrore,
    scartati: scartati,
  );

  StatoWebhook conErrore(
    DateTime ora, {
    int codice = 0,
    String tipo = '',
    bool scartato = false,
  }) => StatoWebhook(
    ultimoOk: ultimoOk,
    ultimoErrore: ora,
    codiceErrore: codice,
    tipoErrore: tipo,
    scartati: scartati + (scartato ? 1 : 0),
  );

  Map<String, Object?> toJson() => {
    'ultimo_ok': ultimoOk?.toUtc().toIso8601String(),
    'ultimo_errore': ultimoErrore?.toUtc().toIso8601String(),
    'codice_errore': codiceErrore,
    'tipo_errore': tipoErrore,
    'scartati': scartati,
  };

  static StatoWebhook daJson(Object? j) {
    if (j is! Map) return const StatoWebhook();
    return StatoWebhook(
      ultimoOk: DateTime.tryParse('${j['ultimo_ok']}')?.toLocal(),
      ultimoErrore: DateTime.tryParse('${j['ultimo_errore']}')?.toLocal(),
      codiceErrore: (j['codice_errore'] as num?)?.toInt() ?? 0,
      tipoErrore: '${j['tipo_errore'] ?? ''}',
      scartati: (j['scartati'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Com'è finito uno svuotamento della coda.
class RisultatoCoda {
  final StatoWebhook stato;
  final int rimasti;
  final DateTime? prossimo; // il primo tentativo in attesa
  const RisultatoCoda(this.stato, this.rimasti, this.prossimo);
}

/// La coda dei messaggi da mandare, in un file JSON della cartella privata.
/// La usano sia l'app aperta sia l'invio ad app chiusa: un file di blocco
/// evita che svuotino la coda insieme.
class CodaWebhook {
  final Directory cartella;
  CodaWebhook(this.cartella);

  File get _coda => File('${cartella.path}/$fileCodaWebhook');
  File get _stato => File('${cartella.path}/$fileStatoWebhook');
  File get _blocco => File('${cartella.path}/$_fileBlocco');

  Future<List<MessaggioWebhook>> leggi() async {
    try {
      if (!await _coda.exists()) return [];
      final j = jsonDecode(await _coda.readAsString());
      if (j is! List) return [];
      return j
          .map(MessaggioWebhook.daJson)
          .whereType<MessaggioWebhook>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _scrivi(List<MessaggioWebhook> m) async {
    final tmp = File('${_coda.path}.tmp');
    await tmp.writeAsString(jsonEncode([for (final x in m) x.toJson()]));
    await tmp.rename(_coda.path);
  }

  Future<StatoWebhook> stato() async {
    try {
      if (!await _stato.exists()) return const StatoWebhook();
      return StatoWebhook.daJson(jsonDecode(await _stato.readAsString()));
    } catch (_) {
      return const StatoWebhook();
    }
  }

  Future<void> _scriviStato(StatoWebhook s) =>
      _stato.writeAsString(jsonEncode(s.toJson()));

  /// Il blocco: preso se il file non c'era. Uno rimasto da un processo
  /// chiuso a metà vale al massimo tre minuti.
  Future<bool> _prendi(DateTime ora) async {
    try {
      await _blocco.create(exclusive: true);
      return true;
    } on FileSystemException {
      try {
        final quando = await _blocco.lastModified();
        if (ora.difference(quando) < const Duration(minutes: 3)) return false;
        await _blocco.delete();
        await _blocco.create(exclusive: true);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<void> _lascia() async {
    try {
      await _blocco.delete();
    } catch (_) {}
  }

  /// Aggiunge in fondo alla coda.
  Future<void> aggiungi(List<MessaggioWebhook> nuovi) async {
    if (nuovi.isEmpty) return;
    await _scrivi([...await leggi(), ...nuovi]);
  }

  /// Toglie tutto (quando si spegne il webhook).
  Future<void> svuotaSenzaInviare() async {
    if (await _coda.exists()) await _coda.delete();
  }

  /// Manda i messaggi già pronti, dal più vecchio, al massimo [max] per volta.
  /// Senza rete si ferma al primo errore: anche gli altri fallirebbero.
  Future<RisultatoCoda> svuota({
    required http.Client client,
    required String url,
    String? chiave,
    DateTime Function()? orologio,
    int max = 100,
  }) async {
    final adesso = orologio ?? DateTime.now;
    var stato = await this.stato();
    if (!await _prendi(adesso())) {
      final tutti = await leggi();
      return RisultatoCoda(stato, tutti.length, _primo(tutti));
    }
    try {
      final coda = await leggi()
        ..sort((a, b) => a.creato.compareTo(b.creato));
      final fatti = <String>{}; // mandati o scartati
      final cambiati = <String, MessaggioWebhook>{};
      var mandati = 0;
      for (final m in coda) {
        final ora = adesso();
        if (ora.difference(m.creato) > durataMaxWebhook) {
          fatti.add(m.id);
          stato = stato.conErrore(ora, tipo: 'scaduto', scartato: true);
          continue;
        }
        if (m.prossimo.isAfter(ora)) continue;
        if (mandati >= max) break;
        mandati++;
        final e = await inviaWebhook(client, url, chiave, m, ora: ora);
        if (e.riuscito) {
          fatti.add(m.id);
          stato = stato.conOk(adesso());
          continue;
        }
        final ancora = e.daRitentare && m.tentativi + 1 < maxTentativiWebhook;
        stato = stato.conErrore(
          adesso(),
          codice: e.codice,
          tipo: e.errore,
          scartato: !ancora,
        );
        if (ancora) {
          cambiati[m.id] = m.riprova(adesso());
        } else {
          fatti.add(m.id);
        }
        if (e.codice == 0 && e.daRitentare) break; // niente rete
      }
      // Riletta: un messaggio aggiunto nel frattempo non si perde.
      final dopo = [
        for (final m in await leggi())
          if (!fatti.contains(m.id)) cambiati[m.id] ?? m,
      ];
      await _scrivi(dopo);
      await _scriviStato(stato);
      return RisultatoCoda(stato, dopo.length, _primo(dopo));
    } finally {
      await _lascia();
    }
  }

  static DateTime? _primo(List<MessaggioWebhook> m) => m.isEmpty
      ? null
      : m.map((x) => x.prossimo).reduce((a, b) => a.isBefore(b) ? a : b);
}
