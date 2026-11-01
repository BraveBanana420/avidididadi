import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:path_provider/path_provider.dart';

// Sensori Bluetooth dell'allenamento (battito, bici): ricerca, scelta,
// ricollegamento se cade e memoria del sensore scelto. Ogni tipo di sensore
// dice solo quali servizi cercare e come leggere i suoi dati. Il collegamento
// c'è solo mentre la modalità allenamento è aperta.

const _canale = MethodChannel('avidididadi/avvio');

/// Media e massimo di un valore della seduta (battito, potenza, cadenza),
/// solo a cronometro acceso.
class Statistiche {
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

  void aggiungi(int v) {
    _somma += v;
    _n++;
    massimo = math.max(massimo, v);
  }

  int get media => _n == 0 ? 0 : (_somma / _n).round();

  /// Per la seduta in corso: somma, quanti, massimo.
  List<int> get comeLista => [_somma, _n, massimo];
}

enum StatoSensore {
  spento,
  permessoNegato,
  bluetoothSpento,
  collega,
  collegato,
}

/// Un valore letto dal sensore, che vale finché è fresco (5 secondi).
class ValoreFresco<T> {
  T? _v;
  DateTime? _quando;

  T? get valore =>
      _quando != null &&
          DateTime.now().difference(_quando!) < const Duration(seconds: 5)
      ? _v
      : null;

  void imposta(T v) {
    _v = v;
    _quando = DateTime.now();
  }

  void azzera() {
    _v = null;
    _quando = null;
  }
}

abstract class SensoreBle extends ChangeNotifier {
  /// Dove si ricorda il sensore scelto (id, nome e altre righe).
  final String nomeFile;

  /// Il nome se il sensore non ne ha uno.
  final String nomeDiBase;

  /// I servizi da cercare: basta che il sensore ne abbia uno.
  final List<Uuid> servizi;

  SensoreBle({
    required this.nomeFile,
    required this.nomeDiBase,
    required this.servizi,
  });

  FlutterReactiveBle? _bleCreato;
  @protected
  FlutterReactiveBle get ble => _bleCreato ??= FlutterReactiveBle();

  StatoSensore stato = StatoSensore.spento;
  String id = '';
  String nome = '';
  bool _vuole = false; // l'allenamento è aperto: se cade, si ricollega
  bool _letto = false;
  StreamSubscription<ConnectionStateUpdate>? _collegamento;
  final _dati = <StreamSubscription<List<int>>>[];
  Timer? _riprova;

  bool get ricordato => id.isNotEmpty;

  /// Collegato: si iscrive ai dati che il sensore manda.
  @protected
  List<Stream<List<int>>> flussi(String id);

  /// Un pacchetto arrivato dal flusso [k] di [flussi].
  @protected
  void leggi(int k, List<int> pacchetto);

  /// Righe in più da ricordare (es. la circonferenza della ruota).
  @protected
  List<String> get altreRighe => const [];
  @protected
  set altreRighe(List<String> righe) {}

  /// I valori vecchi non valgono più (sensore staccato).
  @protected
  void azzera();

  Future<File> _file() async =>
      File('${(await getApplicationDocumentsDirectory()).path}/$nomeFile');

  Future<void> carica() async {
    if (_letto) return;
    _letto = true;
    try {
      final f = await _file();
      if (!await f.exists()) return;
      final righe = (await f.readAsString()).split('\n');
      id = righe.first.trim();
      nome = righe.length > 1 ? righe[1].trim() : '';
      altreRighe = righe.length > 2 ? righe.sublist(2) : const [];
    } catch (_) {
      // nessun sensore ricordato
    }
  }

  @protected
  Future<void> ricorda() async {
    try {
      final f = await _file();
      if (id.isEmpty) {
        if (await f.exists()) await f.delete();
      } else {
        await f.writeAsString([id, nome, ...altreRighe].join('\n'));
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
    await carica();
    _vuole = true;
    if (ricordato) await _collega();
  }

  /// Alla chiusura dell'allenamento: scollega, ma ricorda il sensore.
  Future<void> ferma() async {
    _vuole = false;
    await _stacca();
    _cambia(StatoSensore.spento);
  }

  /// Cerca i sensori vicini. Null se manca il permesso o il Bluetooth è spento.
  Future<Stream<DiscoveredDevice>?> cerca() async {
    if (!await _permesso()) {
      _cambia(StatoSensore.permessoNegato);
      return null;
    }
    if (ble.status == BleStatus.poweredOff) {
      _cambia(StatoSensore.bluetoothSpento);
      return null;
    }
    return ble.scanForDevices(withServices: servizi);
  }

  /// Sceglie un sensore trovato con [cerca] e lo ricorda.
  Future<void> scegli(DiscoveredDevice d) async {
    await _stacca();
    id = d.id;
    nome = d.name.isEmpty ? nomeDiBase : d.name;
    await ricorda();
    _vuole = true;
    await _collega();
  }

  /// Dimentica il sensore: non si ricollega più da solo.
  Future<void> dimentica() async {
    await _stacca();
    id = '';
    nome = '';
    await ricorda();
    _cambia(StatoSensore.spento);
  }

  Future<void> _collega() async {
    if (!await _permesso()) {
      _cambia(StatoSensore.permessoNegato);
      return;
    }
    if (ble.status == BleStatus.poweredOff) {
      _cambia(StatoSensore.bluetoothSpento);
      _ritenta();
      return;
    }
    await _stacca();
    _cambia(StatoSensore.collega);
    _collegamento = ble
        .connectToDevice(id: id, connectionTimeout: const Duration(seconds: 15))
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
            debugPrint('$nomeDiBase: collegamento non riuscito $e');
            _caduto();
          },
        );
  }

  void _ascolta() {
    for (final d in _dati) {
      d.cancel();
    }
    _dati.clear();
    for (final (k, flusso) in flussi(id).indexed) {
      _dati.add(
        flusso.listen(
          (pacchetto) {
            leggi(k, pacchetto);
            stato = StatoSensore.collegato;
            notifyListeners();
          },
          // Un dato che il sensore non ha (es. la cadenza su un misuratore
          // di sola potenza): si ignora, il collegamento resta.
          onError: (Object e) => debugPrint('$nomeDiBase: $e'),
        ),
      );
    }
    _cambia(StatoSensore.collegato);
  }

  /// Il sensore si è allontanato o spento: si riprova finché l'allenamento
  /// è aperto.
  void _caduto() {
    for (final d in _dati) {
      d.cancel();
    }
    _dati.clear();
    if (!_vuole || !ricordato) return;
    _cambia(StatoSensore.collega);
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
    for (final d in _dati) {
      await d.cancel();
    }
    _dati.clear();
    await _collegamento?.cancel();
    _collegamento = null;
    azzera();
  }

  void _cambia(StatoSensore s) {
    stato = s;
    notifyListeners();
  }
}
