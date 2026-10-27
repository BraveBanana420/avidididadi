import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

import 'dettagli_sessione.dart';
import 'percorso.dart';
import 'recupero.dart';
import 'sincronizzazione.dart';

enum DisponibilitaHc { disponibile, daAggiornare, nonInstallata, nonSupportata }

/// Modifiche arrivate da Health Connect dopo l'ultima sincronizzazione.
class ModificheHc {
  final List<RecordHc> aggiornati;
  final Set<String> cancellati; // uuid dei record
  final String token;
  final bool scaduto; // token troppo vecchio: serve una rilettura
  const ModificheHc(this.aggiornati, this.cancellati, this.token, this.scaduto);
}

enum StatoPercorso { dati, consenso, nessuno, errore }

class RispostaPercorso {
  final StatoPercorso stato;
  final Percorso? percorso;
  const RispostaPercorso(this.stato, [this.percorso]);
  const RispostaPercorso.dati(Percorso p) : this(StatoPercorso.dati, p);
}

/// Accesso in sola lettura a Health Connect tramite il pacchetto `health`.
class HealthConnectService {
  final _h = Health();
  bool _configurato = false;

  static const _canale = MethodChannel('avidididadi/avvio');

  static const metriche = [
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.STEPS,
  ];

  /// Tutti i dati letti, con il nome da mostrare nella pagina dei permessi.
  static const tipi = {
    HealthDataType.WORKOUT: 'Sessioni di allenamento',
    HealthDataType.HEART_RATE: 'Frequenza cardiaca',
    HealthDataType.DISTANCE_DELTA: 'Distanza',
    HealthDataType.ACTIVE_ENERGY_BURNED: 'Calorie attive',
    HealthDataType.TOTAL_CALORIES_BURNED: 'Calorie totali',
    HealthDataType.STEPS: 'Passi',
    HealthDataType.SPEED: 'Velocità',
    HealthDataType.RESTING_HEART_RATE: 'FC a riposo',
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD: 'Variabilità cardiaca (HRV)',
    HealthDataType.SLEEP_SESSION: 'Sonno',
  };

  static const tipiRecupero = [
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.SLEEP_SESSION,
  ];

  List<HealthDataAccess> _soloLettura(int n) =>
      List.filled(n, HealthDataAccess.READ);

  Future<void> _configura() async {
    if (_configurato) return;
    await _h.configure();
    _configurato = true;
  }

  Future<DisponibilitaHc> disponibilita() async {
    if (!Platform.isAndroid) return DisponibilitaHc.nonSupportata;
    await _configura();
    return switch (await _h.getHealthConnectSdkStatus()) {
      HealthConnectSdkStatus.sdkAvailable => DisponibilitaHc.disponibile,
      HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired =>
        DisponibilitaHc.daAggiornare,
      _ => DisponibilitaHc.nonInstallata,
    };
  }

  /// Apre il Play Store su Health Connect, per installarlo o aggiornarlo.
  Future<void> installa() => _h.installHealthConnect();

  /// Permessi concessi, tipo per tipo (anche se solo alcuni sono stati dati).
  Future<Map<HealthDataType, bool>> permessi() async {
    await _configura();
    return {
      for (final t in tipi.keys)
        t: await _h.hasPermissions([t], permissions: _soloLettura(1)) ?? false,
    };
  }

  /// Lettura dei dati più vecchi di 30 giorni dal momento del permesso.
  Future<bool> storicoAutorizzato() async {
    await _configura();
    return _h.isHealthDataHistoryAuthorized();
  }

  /// Chiede tutti i permessi di lettura e poi quello per lo storico.
  Future<void> chiediPermessi() async {
    await _configura();
    await _h.requestAuthorization(
      tipi.keys.toList(),
      permissions: _soloLettura(tipi.length),
    );
    if (!await _h.isHealthDataHistoryAuthorized()) {
      await _h.requestHealthDataHistoryAuthorization();
    }
  }

  /// Apre la pagina di Health Connect dove si rivedono i permessi dell'app.
  Future<void> apriPermessi() => _canale.invokeMethod('apriPermessiHc');

  /// Su Health Connect il pacchetto dell'app arriva in sourceName (sourceId è vuoto).
  String _pacchetto(HealthDataPoint p) =>
      p.sourceId.isNotEmpty ? p.sourceId : p.sourceName;

  RecordHc? _record(HealthDataPoint p) {
    final v = p.value;
    if (v is! WorkoutHealthValue) return null;
    return RecordHc(
      uuid: p.uuid,
      tipo: v.workoutActivityType.name,
      pacchetto: _pacchetto(p),
      nomeFonte: nomeFonte(_pacchetto(p), p.sourceName),
      inizio: p.dateFrom,
      fine: p.dateTo,
      distanzaM: v.totalDistance?.toDouble(),
      calorie: v.totalEnergyBurned?.toDouble(),
      passi: v.totalSteps,
    );
  }

  /// Sessioni di allenamento iniziate tra [da] e [a].
  Future<List<RecordHc>> sessioni(DateTime da, DateTime a) async {
    await _configura();
    final punti = await _h.getHealthDataFromTypes(
      types: [HealthDataType.WORKOUT],
      startTime: da,
      endTime: a,
    );
    return [for (final p in punti) ?_record(p)];
  }

  /// Frequenza cardiaca, distanza, calorie e passi nella finestra della sessione,
  /// da qualunque app li abbia scritti (per esempio l'orologio Garmin).
  Future<MetricheHc> metricheDi(RecordHc r) async {
    await _configura();
    final punti = await _h.getHealthDataFromTypes(
      types: metriche,
      startTime: r.inizio,
      endTime: r.fine,
    );
    List<CampioneHc> di(HealthDataType t) => [
      for (final p in punti)
        if (p.type == t && p.value is NumericHealthValue)
          CampioneHc(
            p.dateFrom,
            p.dateTo,
            (p.value as NumericHealthValue).numericValue.toDouble(),
          ),
    ];
    return MetricheHc(
      fc: di(HealthDataType.HEART_RATE),
      distanza: di(HealthDataType.DISTANCE_DELTA),
      calorieAttive: di(HealthDataType.ACTIVE_ENERGY_BURNED),
      calorieTotali: di(HealthDataType.TOTAL_CALORIES_BURNED),
      passi: di(HealthDataType.STEPS),
    );
  }

  /// FC a riposo, HRV e sonno tra [da] e [a], raggruppati per giorno. Legge
  /// solo i tipi per cui c'è il permesso.
  Future<List<GiornoRecupero>> recupero(DateTime da, DateTime a) async {
    await _configura();
    final concessi = [
      for (final t in tipiRecupero)
        if (await _h.hasPermissions([t], permissions: _soloLettura(1)) ?? false)
          t,
    ];
    if (concessi.isEmpty) return const [];
    final punti = await _h.getHealthDataFromTypes(
      types: concessi,
      startTime: da,
      endTime: a,
    );
    List<Misurazione> di(HealthDataType t) => [
      for (final p in punti)
        if (p.type == t && p.value is NumericHealthValue)
          (p.dateTo, (p.value as NumericHealthValue).numericValue.toDouble()),
    ];
    return giorniRecupero(
      fcRiposo: di(HealthDataType.RESTING_HEART_RATE),
      hrv: di(HealthDataType.HEART_RATE_VARIABILITY_RMSSD),
      sonno: di(HealthDataType.SLEEP_SESSION),
    );
  }

  /// Titoli delle sessioni, letti dal codice nativo (il pacchetto non li dà).
  Future<Map<String, String>> titoli(List<String> uuid) async {
    if (uuid.isEmpty) return const {};
    try {
      final r = await _canale.invokeMapMethod<String, String>(
        'titoliSessioni',
        {'uuid': uuid},
      );
      debugPrint(
        'Health Connect: titoli trovati ${r?.length ?? 0} su ${uuid.length}',
      );
      return r ?? const {};
    } on MissingPluginException {
      return const {};
    }
  }

  /// Segmenti, lap e distanze parziali di una sessione (codice nativo).
  Future<DettagliHc?> dettagli(String uuid) async {
    try {
      final r = await _canale.invokeMapMethod<Object?, Object?>(
        'dettagliSessione',
        uuid,
      );
      if (r == null || r['errore'] != null) return null;
      return DettagliHc.daMappa(r);
    } on MissingPluginException {
      return null;
    }
  }

  /// Percorso GPS di una sessione, letto dal codice nativo.
  Future<RispostaPercorso> percorso(String uuid) async {
    try {
      final r = await _canale.invokeMapMethod<String, Object?>(
        'percorsoSessione',
        uuid,
      );
      final punti = r?['punti'];
      return switch (r?['stato']) {
        'dati' when punti is List => RispostaPercorso.dati(
          Percorso.daPiatto(punti.cast<double>()),
        ),
        'consenso' => const RispostaPercorso(StatoPercorso.consenso),
        'nessuno' => const RispostaPercorso(StatoPercorso.nessuno),
        _ => const RispostaPercorso(StatoPercorso.errore),
      };
    } on MissingPluginException {
      return const RispostaPercorso(StatoPercorso.errore);
    }
  }

  /// Chiede a Health Connect il consenso per il percorso di quella sessione.
  Future<Percorso?> chiediPercorso(String uuid) async {
    try {
      final v = await _canale.invokeMethod<List<Object?>>(
        'chiediPercorso',
        uuid,
      );
      return v == null ? null : Percorso.daPiatto(v.cast<double>());
    } on MissingPluginException {
      return null;
    }
  }

  /// Token per chiedere, la volta dopo, solo le sessioni cambiate.
  Future<String?> tokenModifiche() async {
    await _configura();
    return _h.getChangesToken(types: [HealthDataType.WORKOUT]);
  }

  Future<ModificheHc> modifiche(String token) async {
    await _configura();
    final aggiornati = <RecordHc>[];
    final cancellati = <String>{};
    var t = token;
    while (true) {
      final r = await _h.getChanges(changesToken: t);
      if (r == null || r.changesTokenExpired) {
        return ModificheHc(const [], const {}, t, true);
      }
      for (final c in r.changes) {
        if (c.type == HealthChangeType.delete) {
          if (c.recordId != null) cancellati.add(c.recordId!);
        } else if (c.dataPoint != null) {
          final rec = _record(c.dataPoint!);
          if (rec != null) aggiornati.add(rec);
        }
      }
      t = r.nextChangesToken;
      if (!r.hasMore) return ModificheHc(aggiornati, cancellati, t, false);
    }
  }

  /// Azione con cui Android ha aperto l'app: se è Health Connect che chiede la
  /// spiegazione dei permessi, va mostrata la pagina sulla privacy.
  static Future<String?> azioneAvvio() async {
    try {
      return await _canale.invokeMethod<String>('azioneAvvio');
    } on MissingPluginException {
      return null;
    }
  }

  /// Messaggi da Android con l'app già aperta: Health Connect che chiede la
  /// privacy, oppure il pulsante ▶ del widget.
  static void quandoChiedePrivacy(
    void Function() apri, {
    void Function()? avviaDaWidget,
    void Function(String testo)? testoCondiviso,
  }) {
    _canale.setMethodCallHandler((call) async {
      if (call.method == 'apriPrivacy') apri();
      if (call.method == 'avviaDaWidget') avviaDaWidget?.call();
      if (call.method == 'testoCondiviso' && call.arguments is String) {
        testoCondiviso?.call(call.arguments as String);
      }
    });
  }

  static const azioniPrivacy = {
    'androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE',
    'android.intent.action.VIEW_PERMISSION_USAGE',
  };
}
