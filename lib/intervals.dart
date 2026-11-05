import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models.dart';
import 'percorso.dart';
import 'potenza.dart';
import 'serie_sessione.dart';

/// Collegamento a intervals.icu, che riceve le attività da Garmin, Polar,
/// Suunto, Coros, Wahoo, Zwift…: nome vero, rulli, percorso, altitudine,
/// potenza. Si usa la chiave API personale (Impostazioni → Developer
/// settings), senza server: le richieste partono dal telefono.

const baseIntervals = 'https://intervals.icu';

/// La chiave API, cifrata sul telefono come quelle dell'assistente.
class ChiaveIntervals {
  static const _archivio = FlutterSecureStorage();
  static const _nome = 'chiave_intervals';

  static Future<String?> leggi() async {
    try {
      final v = await _archivio.read(key: _nome);
      return v == null || v.isEmpty ? null : v;
    } catch (_) {
      return null;
    }
  }

  static Future<void> salva(String chiave) =>
      _archivio.write(key: _nome, value: chiave.trim());

  static Future<void> elimina() => _archivio.delete(key: _nome);
}

class ErroreIntervals implements Exception {
  final String messaggio;
  const ErroreIntervals(this.messaggio);
  @override
  String toString() => messaggio;
}

/// Un'attività di intervals.icu già nel formato dell'app.
class AttivitaIcu {
  final Sessione sessione;
  final bool alChiuso; // rulli, Tacx, tapis roulant
  const AttivitaIcu(this.sessione, {this.alChiuso = false});
}

/// Sport e tipo dell'app dal tipo di intervals.icu. Null per quelli che
/// arrivano da Health Connect (forza, mobilità) o che l'app non segue.
(String, String)? sportDaTipoIcu(String tipo) => switch (tipo) {
  'Run' || 'TrailRun' => ('Corsa', 'Corsa'),
  'VirtualRun' => ('Corsa', 'Tapis roulant'),
  'Ride' ||
  'GravelRide' ||
  'MountainBikeRide' ||
  'EBikeRide' => ('Bici', 'Uscita'),
  'VirtualRide' => ('Bici', 'Rulli'),
  'Swim' => ('Nuoto', 'Piscina'),
  'OpenWaterSwim' => ('Nuoto', 'Acque libere'),
  _ => null,
};

const _sorgenti = {
  'GARMIN_CONNECT': 'Garmin',
  'POLAR': 'Polar',
  'SUUNTO': 'Suunto',
  'COROS': 'Coros',
  'WAHOO': 'Wahoo',
  'ZWIFT': 'Zwift',
  'STRAVA': 'Strava',
  'ZEPP': 'Zepp',
};

/// Prefisso degli id delle sessioni di intervals.icu.
const prefissoIcu = 'icu-';

num? _numero(Object? v) => v is num ? v : null;

/// Da un'attività dell'API (JSON) a una sessione dell'app.
AttivitaIcu? attivitaDaIcu(Map<String, dynamic> j) {
  final sport = sportDaTipoIcu('${j['type'] ?? ''}');
  final id = '${j['id'] ?? ''}';
  final inizio = DateTime.tryParse('${j['start_date_local'] ?? ''}');
  if (sport == null || id.isEmpty || inizio == null) return null;
  final secondi = (_numero(j['elapsed_time']) ?? _numero(j['moving_time']) ?? 0)
      .round();
  final nome = '${j['name'] ?? ''}'.trim();
  final alChiuso = j['trainer'] == true || sport.$2 == 'Rulli';
  final sorgente = _sorgenti['${j['source']}'] ?? 'intervals.icu';
  return AttivitaIcu(
    Sessione(
      id: '$prefissoIcu$id',
      data: soloData(inizio),
      sport: sport.$1,
      // Il nome dato sull'orologio o su Garmin Connect (es. "Test FTP").
      tipo: nome.isEmpty ? sport.$2 : nome,
      durataMin: (secondi / 60).round(),
      distanzaKm: ((_numero(j['distance']) ?? 0) / 10).round() / 100,
      fcMedia: (_numero(j['average_heartrate']) ?? 0).round(),
      fcMax: (_numero(j['max_heartrate']) ?? 0).round(),
      calorieAttive: (_numero(j['calories']) ?? 0).toDouble(),
      potenzaMedia:
          (_numero(j['icu_average_watts']) ?? _numero(j['average_watts']) ?? 0)
              .round(),
      cadenzaMedia: (_numero(j['average_cadence']) ?? 0).round(),
      fonte: '$sorgente (intervals.icu)',
      origine: 'intervals.icu',
      inizio: inizio,
      fine: inizio.add(Duration(seconds: secondi)),
    ),
    alChiuso: alChiuso,
  );
}

/// Pendenza in % ogni 50 m circa, dall'altitudine e dalla distanza.
List<Campione> pendenzaDa(List<Campione> altitudine, List<Campione> distanza) {
  final perTempo = {for (final d in distanza) d.t: d.v};
  final punti = [
    for (final a in altitudine)
      if (perTempo[a.t] != null) (a.t, perTempo[a.t]!, a.v),
  ];
  final out = <Campione>[];
  var j = 0;
  for (var i = 1; i < punti.length; i++) {
    final metri = punti[i].$2 - punti[j].$2;
    if (metri < 50) continue;
    final p = (punti[i].$3 - punti[j].$3) / metri * 100;
    out.add(Campione(punti[i].$1, p.clamp(-30, 30).toDouble()));
    j = i;
  }
  return out;
}

/// I dati nel tempo dell'API ([{type, data}, …]) come serie dell'app. Si
/// leggono quelli riconosciuti, gli altri si ignorano.
SerieSessione serieDaIcu(List<dynamic> streams, DateTime inizio) {
  final perTipo = <String, List<dynamic>>{
    for (final s in streams)
      if (s is Map && s['data'] is List) '${s['type']}': s['data'] as List,
  };
  final tempo = perTipo['time'];
  if (tempo == null) return const SerieSessione();
  List<Campione> di(String tipo) {
    final dati = perTipo[tipo];
    if (dati == null) return const [];
    return [
      for (var i = 0; i < math.min(dati.length, tempo.length); i++)
        if (dati[i] is num && tempo[i] is num)
          Campione(
            inizio.add(Duration(seconds: (tempo[i] as num).round())),
            (dati[i] as num).toDouble(),
          ),
    ];
  }

  final altitudine = di('altitude').isNotEmpty
      ? di('altitude')
      : di('fixed_altitude');
  return SerieSessione(
    fc: di('heartrate'),
    velocita: di('velocity_smooth'),
    altitudine: altitudine,
    pendenza: pendenzaDa(altitudine, di('distance')),
    potenza: di('watts'),
    cadenza: di('cadence'),
  );
}

/// Il percorso dalle coordinate della mappa di intervals.icu (senza orari:
/// i punti sono distanziati di un secondo, basta per disegnarlo).
Percorso percorsoDaIcu(Map<String, dynamic> mappa, DateTime inizio) {
  final punti = <PuntoGps>[];
  for (final p in (mappa['latlngs'] as List? ?? const [])) {
    if (p is List && p.length >= 2 && p[0] is num && p[1] is num) {
      punti.add(
        PuntoGps(
          (p[0] as num).toDouble(),
          (p[1] as num).toDouble(),
          inizio.add(Duration(seconds: punti.length)),
        ),
      );
    }
  }
  return Percorso(punti);
}

/// L'id dell'attività creata: nella risposta, o nella prima delle attività
/// (il caricamento di un file ne restituisce un elenco).
String? idAttivitaCreata(Object? j) {
  if (j is! Map) return null;
  final id = j['id'];
  if (id != null && '$id'.isNotEmpty) return '$id';
  final elenco = j['activities'];
  if (elenco is List && elenco.isNotEmpty && elenco.first is Map) {
    final primo = (elenco.first as Map)['id'];
    return primo == null ? null : '$primo';
  }
  return null;
}

/// Le richieste all'API di intervals.icu, con la chiave dell'utente.
class ClientIntervals {
  final String chiave;
  const ClientIntervals(this.chiave);

  Future<Object?> _get(String percorso, [Map<String, String>? query]) =>
      _richiesta('GET', percorso, query);

  Future<Object?> _richiesta(
    String metodo,
    String percorso, [
    Map<String, String>? query,
    Object? dati,
    (List<int>, String)? grezzo, // corpo già pronto e il suo tipo
  ]) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final req = await client.openUrl(
        metodo,
        Uri.parse('$baseIntervals$percorso').replace(queryParameters: query),
      );
      req.headers
        ..set(
          HttpHeaders.authorizationHeader,
          'Basic ${base64Encode(utf8.encode('API_KEY:$chiave'))}',
        )
        ..set(HttpHeaders.acceptHeader, 'application/json')
        ..set(HttpHeaders.userAgentHeader, 'Avidididadi');
      if (dati != null) {
        req.headers.contentType = ContentType.json;
        req.add(utf8.encode(jsonEncode(dati)));
      } else if (grezzo != null) {
        req.headers.set(HttpHeaders.contentTypeHeader, grezzo.$2);
        req.add(grezzo.$1);
      }
      final res = await req.close().timeout(const Duration(seconds: 40));
      final corpo = await res.transform(utf8.decoder).join();
      switch (res.statusCode) {
        case >= 200 && < 300:
          return corpo.isEmpty ? null : jsonDecode(corpo);
        case 401 || 403:
          throw const ErroreIntervals(
            'Chiave API non valida: ricopiala da intervals.icu → Impostazioni '
            '→ Developer settings.',
          );
        case 404:
          return null;
        case 429:
          throw const ErroreIntervals(
            'intervals.icu ha ricevuto troppe richieste: riprova tra qualche '
            'minuto.',
          );
        default:
          throw ErroreIntervals(
            'intervals.icu ha risposto con un errore (${res.statusCode}).',
          );
      }
    } on SocketException {
      throw const ErroreIntervals('Nessuna connessione a internet.');
    } on TimeoutException {
      throw const ErroreIntervals('intervals.icu non risponde: riprova.');
    } on FormatException {
      throw const ErroreIntervals('Risposta di intervals.icu non leggibile.');
    } finally {
      client.close();
    }
  }

  /// Carica un file GPX come attività; restituisce l'id su intervals.icu.
  Future<String?> caricaGpx(
    String gpx, {
    required String nomeFile,
    required String nome,
    required String idEsterno,
  }) async {
    final confine = 'avidididadi${DateTime.now().microsecondsSinceEpoch}';
    final corpo = [
      ...utf8.encode(
        '--$confine\r\n'
        'Content-Disposition: form-data; name="file"; filename="$nomeFile"\r\n'
        'Content-Type: application/gpx+xml\r\n\r\n',
      ),
      ...utf8.encode(gpx),
      ...utf8.encode('\r\n--$confine--\r\n'),
    ];
    final j = await _richiesta(
      'POST',
      '/api/v1/athlete/0/activities',
      {'name': nome, 'external_id': idEsterno},
      null,
      (corpo, 'multipart/form-data; boundary=$confine'),
    );
    return idAttivitaCreata(j);
  }

  /// Crea un'attività senza file (tempo, km, battito); restituisce l'id.
  Future<String?> creaAttivita(Map<String, Object?> attivita) async =>
      idAttivitaCreata(
        await _richiesta(
          'POST',
          '/api/v1/athlete/0/activities/manual',
          null,
          attivita,
        ),
      );

  /// Prova la chiave: restituisce il nome dell'atleta (o una stringa vuota).
  Future<String> verifica() async {
    final j = await _get('/api/v1/athlete/0');
    if (j is! Map) throw const ErroreIntervals('Chiave API non valida.');
    return '${j['name'] ?? ''}'.trim();
  }

  /// Gli FTP di bici e corsa impostati su intervals.icu (null se non ci sono).
  Future<({int? bici, int? corsa})> soglie() async {
    final atleta = await _get('/api/v1/athlete/0');
    return (
      bici: ftpDaAtletaIcu(atleta),
      corsa: ftpDaAtletaIcu(atleta, tipo: 'Run'),
    );
  }

  /// Le attività tra [da] e [a] (date locali).
  Future<List<AttivitaIcu>> attivita(DateTime da, DateTime a) async {
    final j = await _get('/api/v1/athlete/0/activities', {
      'oldest': isoData(da),
      'newest': '${isoData(a)}T23:59:59',
    });
    return [
      for (final x in (j is List ? j : const []))
        if (x is Map<String, dynamic>) ?attivitaDaIcu(x),
    ];
  }

  /// Battito, velocità, altitudine, potenza… di un'attività.
  Future<SerieSessione> serie(String id, DateTime inizio) async {
    final j = await _get('/api/v1/activity/$id/streams.json');
    return j is List ? serieDaIcu(j, inizio) : const SerieSessione();
  }

  /// Crea gli allenamenti nel calendario; restituisce external_id e id di
  /// quelli creati. Con upsert, uno con lo stesso external_id si aggiorna.
  Future<Map<String, int>> creaEventi(List<Map<String, Object?>> eventi) async {
    if (eventi.isEmpty) return const {};
    final j = await _richiesta('POST', '/api/v1/athlete/0/events/bulk', {
      'upsert': 'true',
      'upsertOnUid': 'false',
      'updatePlanApplied': 'false',
    }, eventi);
    return {
      for (final e in (j is List ? j : const []))
        if (e is Map && e['id'] is int && e['external_id'] is String)
          e['external_id'] as String: e['id'] as int,
    };
  }

  /// Cancella dal calendario gli eventi creati prima dall'app.
  Future<void> cancellaEventi(List<int> id) async {
    if (id.isEmpty) return;
    await _richiesta('PUT', '/api/v1/athlete/0/events/bulk-delete', null, [
      for (final x in id) {'id': x},
    ]);
  }

  /// Il percorso GPS (vuoto per le attività al chiuso).
  Future<Percorso> percorso(String id, DateTime inizio) async {
    final j = await _get('/api/v1/activity/$id/map');
    return j is Map<String, dynamic>
        ? percorsoDaIcu(j, inizio)
        : const Percorso([]);
  }
}
