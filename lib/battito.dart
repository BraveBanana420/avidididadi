import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:path_provider/path_provider.dart';

// Battito live via Bluetooth: fasce cardio e orologi che "trasmettono il
// battito" (Garmin, Polar, Coros…) usano lo stesso servizio standard Heart
// Rate. Il collegamento c'è solo mentre la modalità allenamento è aperta.

final _servizio = Uuid.parse('180d');
final _misura = Uuid.parse('2a37');
const _canale = MethodChannel('avidididadi/avvio');

/// Battito dal pacchetto "Heart Rate Measurement": il primo bit dice se il
/// valore è su 8 o 16 bit. Null se manca o è 0 (fascia appena indossata).
int? bpmDa(List<int> dati) {
  if (dati.length < 2) return null;
  final sedici = dati[0] & 0x01 == 1;
  if (sedici && dati.length < 3) return null;
  final bpm = sedici ? dati[1] | (dati[2] << 8) : dati[1];
  return bpm > 0 && bpm < 250 ? bpm : null;
}

/// Media e massimo del battito della seduta, solo a cronometro acceso.
class StatisticheBattito {
  int _somma = 0;
  int _n = 0;
  int massimo = 0;

  int get somma => _somma;
  int get n => _n;

  /// Riparte dai valori salvati (seduta ripresa dopo una chiusura).
  void ripristina(int somma, int n, int max) {
    _somma = somma;
    _n = n;
    massimo = max;
  }

  void aggiungi(int bpm) {
    _somma += bpm;
    _n++;
    massimo = math.max(massimo, bpm);
  }

  int get media => _n == 0 ? 0 : (_somma / _n).round();
}

enum StatoBattito {
  spento,
  permessoNegato,
  bluetoothSpento,
  collega,
  collegato,
}

/// Il sensore del battito scelto dall'utente (ricordato in sensore_battito.txt).
class SensoreBattito extends ChangeNotifier {
  FlutterReactiveBle? _bleCreato;
  FlutterReactiveBle get _ble => _bleCreato ??= FlutterReactiveBle();

  StatoBattito stato = StatoBattito.spento;
  String id = '';
  String nome = '';
  int? _bpm;
  DateTime? _quando;
  bool _vuole = false; // l'allenamento è aperto: se cade, si ricollega
  bool _letto = false;
  StreamSubscription<ConnectionStateUpdate>? _collegamento;
  StreamSubscription<List<int>>? _dati;
  Timer? _riprova;

  /// Ogni valore nuovo, per media e massimo.
  final valori = StreamController<int>.broadcast();

  bool get ricordato => id.isNotEmpty;

  /// Il battito di adesso; null se da qualche secondo non arriva niente.
  int? get bpm =>
      _quando != null &&
          DateTime.now().difference(_quando!) < const Duration(seconds: 5)
      ? _bpm
      : null;

  Future<File> _file() async => File(
    '${(await getApplicationDocumentsDirectory()).path}/sensore_battito.txt',
  );

  Future<void> _carica() async {
    if (_letto) return;
    _letto = true;
    try {
      final f = await _file();
      if (!await f.exists()) return;
      final righe = (await f.readAsString()).split('\n');
      id = righe.first.trim();
      nome = righe.length > 1 ? righe[1].trim() : '';
    } catch (_) {
      // nessun sensore ricordato
    }
  }

  Future<void> _ricorda() async {
    try {
      final f = await _file();
      if (id.isEmpty) {
        if (await f.exists()) await f.delete();
      } else {
        await f.writeAsString('$id\n$nome\n');
      }
    } catch (_) {
      // vale solo per questo allenamento
    }
  }

  /// Chiede i permessi del Bluetooth (Android 12+) o della posizione (prima).
  Future<bool> _permesso() async {
    try {
      return await _canale.invokeMethod<bool>('permessoBluetooth') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// All'apertura dell'allenamento: si ricollega al sensore ricordato.
  Future<void> avvia() async {
    await _carica();
    _vuole = true;
    if (ricordato) await _collega();
  }

  /// Alla chiusura dell'allenamento: scollega, ma ricorda il sensore.
  Future<void> ferma() async {
    _vuole = false;
    await _stacca();
    _cambia(StatoBattito.spento);
  }

  /// Cerca i sensori vicini. Null se manca il permesso o il Bluetooth è spento.
  Future<Stream<DiscoveredDevice>?> cerca() async {
    if (!await _permesso()) {
      _cambia(StatoBattito.permessoNegato);
      return null;
    }
    if (_ble.status == BleStatus.poweredOff) {
      _cambia(StatoBattito.bluetoothSpento);
      return null;
    }
    return _ble.scanForDevices(withServices: [_servizio]);
  }

  /// Sceglie un sensore trovato con [cerca] e lo ricorda.
  Future<void> scegli(DiscoveredDevice d) async {
    await _stacca();
    id = d.id;
    nome = d.name.isEmpty ? 'Sensore del battito' : d.name;
    await _ricorda();
    _vuole = true;
    await _collega();
  }

  /// Dimentica il sensore: non si ricollega più da solo.
  Future<void> dimentica() async {
    await _stacca();
    id = '';
    nome = '';
    await _ricorda();
    _cambia(StatoBattito.spento);
  }

  Future<void> _collega() async {
    if (!await _permesso()) {
      _cambia(StatoBattito.permessoNegato);
      return;
    }
    if (_ble.status == BleStatus.poweredOff) {
      _cambia(StatoBattito.bluetoothSpento);
      _ritenta();
      return;
    }
    await _stacca();
    _cambia(StatoBattito.collega);
    _collegamento = _ble
        .connectToDevice(
          id: id,
          servicesWithCharacteristicsToDiscover: {
            _servizio: [_misura],
          },
          connectionTimeout: const Duration(seconds: 15),
        )
        .listen(
          (u) {
            if (u.connectionState == DeviceConnectionState.connected) {
              _ascolta();
            } else if (u.connectionState ==
                DeviceConnectionState.disconnected) {
              _caduto();
            }
          },
          onError: (Object e) {
            debugPrint('Battito: collegamento non riuscito $e');
            _caduto();
          },
        );
  }

  void _ascolta() {
    _dati?.cancel();
    _dati = _ble
        .subscribeToCharacteristic(
          QualifiedCharacteristic(
            serviceId: _servizio,
            characteristicId: _misura,
            deviceId: id,
          ),
        )
        .listen((pacchetto) {
          final v = bpmDa(pacchetto);
          if (v == null) return;
          _bpm = v;
          _quando = DateTime.now();
          valori.add(v);
          stato = StatoBattito.collegato;
          notifyListeners();
        }, onError: (Object e) => _caduto());
    _cambia(StatoBattito.collegato);
  }

  /// Il sensore si è allontanato o spento: si riprova finché l'allenamento
  /// è aperto.
  void _caduto() {
    _dati?.cancel();
    _dati = null;
    if (!_vuole || !ricordato) return;
    _cambia(StatoBattito.collega);
    _ritenta();
  }

  void _ritenta() {
    _riprova?.cancel();
    _riprova = Timer(const Duration(seconds: 5), () {
      if (_vuole && ricordato) _collega();
    });
  }

  Future<void> _stacca() async {
    _riprova?.cancel();
    await _dati?.cancel();
    await _collegamento?.cancel();
    _dati = null;
    _collegamento = null;
    _bpm = null;
  }

  void _cambia(StatoBattito s) {
    stato = s;
    notifyListeners();
  }
}

/// Uno solo per tutta l'app: lo usano l'allenamento e il suo foglio.
final sensoreBattito = SensoreBattito();
