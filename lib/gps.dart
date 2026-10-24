import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'percorso.dart';

enum StatoGps { spento, permessoNegato, disattivato, cerca, pronto }

/// Registra il percorso durante l'allenamento. La posizione arriva dal
/// servizio di Google Play (GPS + sensori di movimento); con la notifica fissa
/// continua anche a schermo spento.
class RegistratoreGps extends ChangeNotifier {
  final FiltroGps filtro;
  StreamSubscription<Position>? _flusso;
  StatoGps stato = StatoGps.spento;
  double precisione = 0; // ultimo margine di errore in metri
  bool registra = false; // false durante preparazione e pausa

  RegistratoreGps(String sport) : filtro = FiltroGps.per(sport);

  double get km => filtro.metri / 1000;
  Percorso get percorso => filtro.percorso;

  /// Chiede il permesso e accende il GPS. Restituisce lo stato raggiunto.
  Future<StatoGps> avvia() async {
    if (_flusso != null) return stato;
    if (!await Geolocator.isLocationServiceEnabled()) {
      return _cambia(StatoGps.disattivato);
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied ||
        p == LocationPermission.deniedForever) {
      return _cambia(StatoGps.permessoNegato);
    }
    _cambia(StatoGps.cerca);
    _flusso =
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 1),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'Avidididadi',
              notificationText: 'Sto registrando il percorso',
              notificationChannelName: 'Registrazione percorso',
              enableWakeLock: true,
              setOngoing: true,
            ),
          ),
        ).listen(
          _punto,
          onError: (Object e) {
            debugPrint('GPS: errore $e');
            _cambia(StatoGps.cerca);
          },
        );
    return stato;
  }

  void _punto(Position p) {
    precisione = p.accuracy;
    final buono = p.accuracy <= FiltroGps.precisioneMassima;
    stato = buono ? StatoGps.pronto : StatoGps.cerca;
    if (registra) {
      filtro.aggiungi(
        PuntoGps(p.latitude, p.longitude, p.timestamp, p.accuracy),
      );
    }
    notifyListeners();
  }

  /// Ferma o riprende la raccolta dei punti (pausa dell'allenamento).
  void imposta(bool attiva) {
    if (attiva && !registra) filtro.riprendi();
    registra = attiva;
  }

  StatoGps _cambia(StatoGps s) {
    stato = s;
    notifyListeners();
    return s;
  }

  Future<void> ferma() async {
    registra = false;
    await _flusso?.cancel();
    _flusso = null;
  }

  @override
  void dispose() {
    _flusso?.cancel();
    super.dispose();
  }
}

/// Apre le impostazioni della posizione (GPS spento) o dell'app (permesso negato).
Future<void> apriImpostazioniGps(StatoGps s) async {
  if (s == StatoGps.disattivato) {
    await Geolocator.openLocationSettings();
  } else {
    await Geolocator.openAppSettings();
  }
}
