import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'sensore_ble.dart';

export 'sensore_ble.dart' show Statistiche, StatoSensore;

// Battito live via Bluetooth: fasce cardio e orologi che "trasmettono il
// battito" (Garmin, Polar, Coros…) usano lo stesso servizio standard Heart
// Rate.

final _servizio = Uuid.parse('180d');
final _misura = Uuid.parse('2a37');

/// Battito dal pacchetto "Heart Rate Measurement": il primo bit dice se il
/// valore è su 8 o 16 bit. Null se manca o è 0 (fascia appena indossata).
int? bpmDa(List<int> dati) {
  if (dati.length < 2) return null;
  final sedici = dati[0] & 0x01 == 1;
  if (sedici && dati.length < 3) return null;
  final bpm = sedici ? dati[1] | (dati[2] << 8) : dati[1];
  return bpm > 0 && bpm < 250 ? bpm : null;
}

/// Il sensore del battito scelto dall'utente (ricordato in sensore_battito.txt).
class SensoreBattito extends SensoreBle {
  SensoreBattito()
    : super(
        nomeFile: 'sensore_battito.txt',
        nomeDiBase: 'Sensore del battito',
        servizi: [_servizio],
      );

  final _bpm = ValoreFresco<int>();

  /// Ogni valore nuovo, per media e massimo.
  final valori = StreamController<int>.broadcast();

  /// Il battito di adesso; null se da qualche secondo non arriva niente.
  int? get bpm => _bpm.valore;

  @override
  List<Stream<List<int>>> flussi(String id) => [
    ble.subscribeToCharacteristic(
      QualifiedCharacteristic(
        serviceId: _servizio,
        characteristicId: _misura,
        deviceId: id,
      ),
    ),
  ];

  @override
  void leggi(int k, List<int> pacchetto) {
    final v = bpmDa(pacchetto);
    if (v == null) return;
    _bpm.imposta(v);
    valori.add(v);
  }

  @override
  void azzera() => _bpm.azzera();
}

/// Uno solo per tutta l'app: lo usano l'allenamento e il suo foglio.
final sensoreBattito = SensoreBattito();
