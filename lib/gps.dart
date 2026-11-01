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

  /// L'ultima posizione buona, anche in pausa e prima di partire: per la
  /// mappa e per seguire un percorso.
  PuntoGps? ultimo;

  /// Direzione di marcia in gradi (0 nord), finché ci si muove: da fermi il
  /// GPS non la sa e resta l'ultima.
  double? direzione;

  /// Velocità degli ultimi secondi, anche in pausa: serve a capire quando ci
  /// si ferma e si riparte.
  final _velocita = <(DateTime, double)>[];

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
    if (buono) {
      // La velocità del servizio di posizione (anche dai sensori di movimento)
      // è più stabile della distanza tra due punti, che da fermi balla.
      final ora = DateTime.now();
      ultimo = PuntoGps(p.latitude, p.longitude, p.timestamp, p.accuracy);
      _velocita
        ..add((ora, p.speed < 0 ? 0 : p.speed))
        ..removeWhere((x) => ora.difference(x.$1) > const Duration(seconds: 5));
      // Da fermi il GPS "salta" e darebbe direzioni a caso: la mappa gira
      // solo se ci si muove davvero (da qualche secondo, non per un salto).
      if (p.heading >= 0 && p.speed > 1.2 && (velocitaRecente ?? 0) > 1.2) {
        direzione = p.heading;
      }
    }
    if (registra) {
      filtro.aggiungi(
        PuntoGps(p.latitude, p.longitude, p.timestamp, p.accuracy),
      );
    }
    notifyListeners();
  }

  /// Media della velocità degli ultimi 5 secondi; null senza punti buoni.
  double? get velocitaRecente {
    final ora = DateTime.now();
    final v = [
      for (final x in _velocita)
        if (ora.difference(x.$1) <= const Duration(seconds: 5)) x.$2,
    ];
    return v.isEmpty ? null : v.reduce((a, b) => a + b) / v.length;
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
