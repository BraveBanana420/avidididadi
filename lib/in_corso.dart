import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'csv.dart';
import 'dati_live.dart';
import 'models.dart';
import 'percorso.dart';

// La seduta in corso, salvata spesso su in_corso.json: se Android chiude
// l'app o si blocca, alla riapertura si riprende da lì. Resta solo sul
// telefono (non entra nel backup) e si cancella a fine allenamento.

/// Oltre questo tempo una seduta interrotta non si propone più.
const scadenzaInCorso = Duration(hours: 24);

class AllenamentoInCorso {
  final String sport;
  final String tipo;
  final String nome;
  final bool libera;
  final bool conGps; // GPS scelto a mano (altra attività)
  final List<WorkoutStep> passi;
  final int indice; // blocco a cui si era arrivati
  final bool finito; // già al riepilogo
  final bool registra;
  final Duration totale;
  final Duration blocco;
  final DateTime partenza;
  final DateTime salvato;
  final Map<int, Duration> tempi;
  final Map<int, (int, double)> fatte;
  final List<PuntoGps> punti;
  final double metri;
  final List<Giro> giri;
  final int fcSomma;
  final int fcN;
  final int fcMax;
  final Duration soste; // in pausa automatica
  final Duration fermo; // fermi a cronometro acceso
  final bool alChiuso; // tapis roulant o rulli: senza GPS
  final List<int> potenza; // somma, quanti, massimo
  final List<int> cadenza;
  final double metriSensore; // dai sensori della bici
  final int passiContati; // dal contapassi del telefono (corsa, camminata)
  final String idPercorso; // percorso seguito ('' = nessuno)
  final double? progressoPercorso; // metri fatti sulla traccia

  const AllenamentoInCorso({
    required this.sport,
    required this.tipo,
    required this.nome,
    required this.libera,
    this.conGps = false,
    required this.passi,
    required this.indice,
    required this.finito,
    required this.registra,
    required this.totale,
    required this.blocco,
    required this.partenza,
    required this.salvato,
    this.tempi = const {},
    this.fatte = const {},
    this.punti = const [],
    this.metri = 0,
    this.giri = const [],
    this.fcSomma = 0,
    this.fcN = 0,
    this.fcMax = 0,
    this.soste = Duration.zero,
    this.fermo = Duration.zero,
    this.alChiuso = false,
    this.potenza = const [0, 0, 0],
    this.cadenza = const [0, 0, 0],
    this.metriSensore = 0,
    this.passiContati = 0,
    this.idPercorso = '',
    this.progressoPercorso,
  });

  Map<String, Object?> toJson() => {
    'sport': sport,
    'tipo': tipo,
    'nome': nome,
    'libera': libera,
    'gps': conGps,
    // I passi come righe di workout.csv: si rileggono con lo stesso codice.
    'passi': [for (final p in passi) p.toRow()],
    'indice': indice,
    'finito': finito,
    'registra': registra,
    'totale_ms': totale.inMilliseconds,
    'blocco_ms': blocco.inMilliseconds,
    'partenza': partenza.toIso8601String(),
    'salvato': salvato.toIso8601String(),
    'tempi': {
      for (final e in tempi.entries) '${e.key}': e.value.inMilliseconds,
    },
    'fatte': {
      for (final e in fatte.entries) '${e.key}': [e.value.$1, e.value.$2],
    },
    // lat, lon, tempo, precisione uno dopo l'altro: il file resta piccolo.
    'punti': [
      for (final p in punti) ...[
        p.lat,
        p.lon,
        p.t.millisecondsSinceEpoch,
        p.precisione,
      ],
    ],
    'metri': metri,
    'giri': [
      for (final g in giri) [g.numero, g.metri, g.tempo.inMilliseconds],
    ],
    'fc': [fcSomma, fcN, fcMax],
    'soste_ms': soste.inMilliseconds,
    'fermo_ms': fermo.inMilliseconds,
    'al_chiuso': alChiuso,
    'potenza': potenza,
    'cadenza': cadenza,
    'metri_sensore': metriSensore,
    'passi_contati': passiContati,
    'percorso': idPercorso,
    'progresso_percorso': progressoPercorso,
  };

  static AllenamentoInCorso? daJson(Map<String, dynamic> j) {
    try {
      final idx = {for (final (k, c) in workoutHeader.indexed) c: k};
      final t = Tabella(idx, const []);
      final passi = [
        for (final r in j['passi'] as List)
          ?WorkoutStep.da(t, [for (final c in r as List) '$c']),
      ];
      final p = (j['punti'] as List).cast<num>();
      final fc = (j['fc'] as List).cast<num>();
      return AllenamentoInCorso(
        sport: j['sport'] as String,
        tipo: j['tipo'] as String,
        nome: j['nome'] as String,
        libera: j['libera'] as bool,
        conGps: j['gps'] == true,
        passi: passi,
        indice: (j['indice'] as num).toInt(),
        finito: j['finito'] as bool,
        registra: j['registra'] as bool,
        totale: Duration(milliseconds: (j['totale_ms'] as num).toInt()),
        blocco: Duration(milliseconds: (j['blocco_ms'] as num).toInt()),
        partenza: DateTime.parse(j['partenza'] as String),
        salvato: DateTime.parse(j['salvato'] as String),
        tempi: {
          for (final e in (j['tempi'] as Map).entries)
            int.parse(e.key as String): Duration(
              milliseconds: (e.value as num).toInt(),
            ),
        },
        fatte: {
          for (final e in (j['fatte'] as Map).entries)
            int.parse(e.key as String): (
              ((e.value as List)[0] as num).toInt(),
              ((e.value as List)[1] as num).toDouble(),
            ),
        },
        punti: [
          for (var k = 0; k + 3 < p.length; k += 4)
            PuntoGps(
              p[k].toDouble(),
              p[k + 1].toDouble(),
              DateTime.fromMillisecondsSinceEpoch(p[k + 2].toInt()),
              p[k + 3].toDouble(),
            ),
        ],
        metri: (j['metri'] as num).toDouble(),
        giri: [
          for (final g in j['giri'] as List)
            (
              numero: ((g as List)[0] as num).toInt(),
              metri: (g[1] as num).toInt(),
              tempo: Duration(milliseconds: (g[2] as num).toInt()),
            ),
        ],
        fcSomma: fc[0].toInt(),
        fcN: fc[1].toInt(),
        fcMax: fc[2].toInt(),
        soste: Duration(milliseconds: (j['soste_ms'] as num? ?? 0).toInt()),
        fermo: Duration(milliseconds: (j['fermo_ms'] as num? ?? 0).toInt()),
        alChiuso: j['al_chiuso'] == true,
        potenza: _tre(j['potenza']),
        cadenza: _tre(j['cadenza']),
        metriSensore: (j['metri_sensore'] as num? ?? 0).toDouble(),
        passiContati: (j['passi_contati'] as num? ?? 0).toInt(),
        idPercorso: j['percorso'] as String? ?? '',
        progressoPercorso: (j['progresso_percorso'] as num?)?.toDouble(),
      );
    } catch (_) {
      return null; // file rovinato (es. scritto a metà): non si propone
    }
  }

  static List<int> _tre(Object? v) => v is List && v.length == 3
      ? [for (final x in v) (x as num).toInt()]
      : const [0, 0, 0];

  /// "Corsa · 32 min · 5,20 km" per la domanda alla riapertura.
  String get riassunto => [
    nome.isEmpty ? sport : nome,
    '${totale.inMinutes} min',
    if (metri >= 50) fmtKm(metri / 1000),
  ].join(' · ');
}

Future<File> _file() async =>
    File('${(await getApplicationDocumentsDirectory()).path}/in_corso.json');

/// Scrive prima su un file a parte e poi lo rinomina: se l'app si chiude a
/// metà scrittura, resta valida la copia di prima.
Future<void> salvaInCorso(AllenamentoInCorso a) async {
  try {
    final f = await _file();
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(jsonEncode(a.toJson()), flush: true);
    await tmp.rename(f.path);
  } catch (_) {
    // al prossimo salvataggio
  }
}

/// La seduta interrotta, se c'è e non è troppo vecchia (altrimenti si butta).
Future<AllenamentoInCorso?> leggiInCorso({DateTime? ora}) async {
  try {
    final f = await _file();
    if (!await f.exists()) return null;
    final a = AllenamentoInCorso.daJson(
      jsonDecode(await f.readAsString()) as Map<String, dynamic>,
    );
    if (a == null ||
        (ora ?? DateTime.now()).difference(a.salvato) > scadenzaInCorso) {
      await f.delete();
      return null;
    }
    return a;
  } catch (_) {
    return null;
  }
}

Future<void> cancellaInCorso() async {
  try {
    final f = await _file();
    if (await f.exists()) await f.delete();
  } catch (_) {
    // niente da cancellare
  }
}
