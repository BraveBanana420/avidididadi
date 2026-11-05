import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'sensore_ble.dart';

// Sensori della bici via Bluetooth, nei tre tipi standard:
// - velocità e cadenza (CSC), con la circonferenza della ruota;
// - misuratore di potenza (Cycling Power), spesso con la cadenza;
// - rulli smart (FTMS, Indoor Bike Data: Tacx, Wahoo, Elite…), che danno
//   velocità, cadenza e potenza insieme.

final servizioCsc = Uuid.parse('1816');
final _misuraCsc = Uuid.parse('2a5b');
final servizioPotenza = Uuid.parse('1818');
final _misuraPotenza = Uuid.parse('2a63');
final servizioRulli = Uuid.parse('1826');
final _datiRulli = Uuid.parse('2ad2');
final _comandiRulli = Uuid.parse('2ad9'); // Fitness Machine Control Point
final _funzioniRulli = Uuid.parse('2acc'); // Fitness Machine Feature
final _statoRulli = Uuid.parse('2ada'); // Fitness Machine Status

// Comandi FTMS al rullo (tutti con risposta: 0x80, comando, esito).
const _chiediControllo = 0x00;
const _potenzaObiettivo = 0x05; // ERG: watt da tenere
const _parti = 0x07;
const _fermaPausa = 0x08; // 1 = ferma, 2 = pausa
const _calibrazione = 0x13; // Spin Down Control: 1 = inizia, 2 = lascia stare
const _statoCalibrazione = 0x14; // nel Fitness Machine Status

/// Il comando ERG: "tieni [watt]" (sint16, little endian).
List<int> comandoWatt(int watt) {
  final w = watt.clamp(0, 2000);
  return [_potenzaObiettivo, w & 0xFF, (w >> 8) & 0xFF];
}

/// La risposta del rullo a un comando: true se riuscito, false se rifiutato,
/// null se il pacchetto non è una risposta a [comando].
bool? esitoComando(List<int> d, int comando) {
  if (d.length < 3 || d[0] != 0x80 || d[1] != comando) return null;
  return d[2] == 0x01;
}

/// Il rullo dichiara di saper fare la calibrazione via Bluetooth: bit 15 delle
/// "Target Setting Features" (i secondi 4 byte di Fitness Machine Feature).
bool calibrazioneSupportata(List<int> funzioni) =>
    funzioni.length >= 6 && funzioni[5] & 0x80 != 0;

/// A che punto è la calibrazione del rullo.
enum FaseCalibrazione { nessuna, avvio, accelera, smetti, riuscita, errore }

/// La risposta al comando di calibrazione: l'esito e, se c'è, tra quali
/// velocità bisogna arrivare (uint16 in centesimi di km/h). Null se il
/// pacchetto è la risposta a un altro comando.
({bool riuscito, double? kmhDa, double? kmhA})? rispostaCalibrazione(
  List<int> d,
) {
  final esito = esitoComando(d, _calibrazione);
  if (esito == null) return null;
  if (!esito || d.length < 7) return (riuscito: esito, kmhDa: null, kmhA: null);
  return (riuscito: true, kmhDa: _u16(d, 3) / 100, kmhA: _u16(d, 5) / 100);
}

/// Il passo successivo da un messaggio di stato del rullo; null se il
/// messaggio parla d'altro.
FaseCalibrazione? faseDaStato(List<int> d) {
  if (d.length < 2 || d[0] != _statoCalibrazione) return null;
  return switch (d[1]) {
    0x01 => FaseCalibrazione.accelera,
    0x02 => FaseCalibrazione.riuscita,
    0x03 => FaseCalibrazione.errore,
    0x04 => FaseCalibrazione.smetti,
    _ => null,
  };
}

String _esadecimale(List<int> d) =>
    d.map((x) => x.toRadixString(16).padLeft(2, '0')).join(' ');

/// Circonferenza della ruota se non si sa: 700×25C, la più comune su strada.
const circonferenzaDiBase = 2105; // mm

int _u16(List<int> d, int i) => d[i] | (d[i + 1] << 8);
int _s16(List<int> d, int i) {
  final v = _u16(d, i);
  return v >= 0x8000 ? v - 0x10000 : v;
}

int _u32(List<int> d, int i) =>
    d[i] | (d[i + 1] << 8) | (d[i + 2] << 16) | (d[i + 3] << 24);

/// Giri e orario dell'ultimo giro (in 1/1024 di secondo), come li contano i
/// sensori: numeri che crescono e ricominciano da zero.
typedef Giri = ({int giri, int tempo});

/// "CSC Measurement": giri della ruota e dei pedali.
({Giri? ruota, Giri? pedali}) cscDa(List<int> d) {
  if (d.isEmpty) return (ruota: null, pedali: null);
  final f = d[0];
  var i = 1;
  Giri? ruota;
  Giri? pedali;
  if (f & 0x01 != 0 && d.length >= i + 6) {
    ruota = (giri: _u32(d, i), tempo: _u16(d, i + 4));
    i += 6;
  }
  if (f & 0x02 != 0 && d.length >= i + 4) {
    pedali = (giri: _u16(d, i), tempo: _u16(d, i + 2));
  }
  return (ruota: ruota, pedali: pedali);
}

/// "Cycling Power Measurement": watt e, se ci sono, i giri dei pedali.
({int? watt, Giri? pedali}) potenzaDa(List<int> d) {
  if (d.length < 4) return (watt: null, pedali: null);
  final f = _u16(d, 0);
  final watt = _s16(d, 2);
  var i = 4;
  if (f & 0x01 != 0) i += 1; // bilanciamento dei pedali
  if (f & 0x04 != 0) i += 2; // coppia accumulata
  if (f & 0x10 != 0) i += 6; // giri della ruota
  Giri? pedali;
  if (f & 0x20 != 0 && d.length >= i + 4) {
    pedali = (giri: _u16(d, i), tempo: _u16(d, i + 2));
  }
  return (watt: watt < 0 ? 0 : watt, pedali: pedali);
}

/// "Indoor Bike Data" dei rulli smart: km/h, cadenza, watt.
({double? kmh, double? rpm, int? watt}) rulliDa(List<int> d) {
  if (d.length < 2) return (kmh: null, rpm: null, watt: null);
  final f = _u16(d, 0);
  var i = 2;
  double? kmh;
  double? rpm;
  int? watt;
  bool c(int n) => d.length >= i + n;
  // Bit 0 a zero vuol dire "c'è la velocità" (al contrario degli altri).
  if (f & 0x0001 == 0 && c(2)) {
    kmh = _u16(d, i) / 100;
    i += 2;
  }
  if (f & 0x0002 != 0) i += 2; // velocità media
  if (f & 0x0004 != 0 && c(2)) {
    rpm = _u16(d, i) / 2;
    i += 2;
  }
  if (f & 0x0008 != 0) i += 2; // cadenza media
  if (f & 0x0010 != 0) i += 3; // distanza totale
  if (f & 0x0020 != 0) i += 2; // resistenza
  if (f & 0x0040 != 0 && c(2)) {
    final w = _s16(d, i);
    watt = w < 0 ? 0 : w;
  }
  return (kmh: kmh, rpm: rpm, watt: watt);
}

/// Da due letture di giri: giri al secondo. Null se il sensore non ha
/// contato giri nuovi (stessa lettura ripetuta).
double? giriAlSecondo(Giri prima, Giri dopo, {int modulo = 0x10000}) {
  final dt = ((dopo.tempo - prima.tempo) & 0xFFFF) / 1024;
  if (dt <= 0) return null;
  final giri = (dopo.giri - prima.giri) % modulo;
  // Un salto enorme è un sensore rimesso a zero: meglio non dire niente.
  if (giri > 50) return null;
  return giri / dt;
}

/// Velocità e cadenza da giri che arrivano nel tempo: se per 3 secondi non
/// ci sono giri nuovi, ci si è fermati.
class Contagiri {
  final int modulo;
  Giri? _ultima;
  DateTime? _ultimoGiro;
  double _valore = 0;

  Contagiri({this.modulo = 0x10000});

  double aggiorna(Giri g, DateTime ora) {
    final prima = _ultima;
    _ultima = g;
    if (prima != null) {
      final v = giriAlSecondo(prima, g, modulo: modulo);
      if (v != null) {
        _valore = v;
        _ultimoGiro = ora;
      }
    }
    if (_ultimoGiro == null ||
        ora.difference(_ultimoGiro!) > const Duration(seconds: 3)) {
      _valore = 0;
    }
    return _valore;
  }

  void azzera() {
    _ultima = null;
    _ultimoGiro = null;
    _valore = 0;
  }
}

/// I sensori della bici scelti dall'utente (ricordati in sensore_bici.txt).
class SensoreBici extends SensoreBle {
  SensoreBici()
    : super(
        nomeFile: 'sensore_bici.txt',
        nomeDiBase: 'Sensore bici',
        servizi: [servizioRulli, servizioPotenza, servizioCsc],
      );

  /// Circonferenza della ruota in mm, per la velocità dai giri.
  int circonferenza = circonferenzaDiBase;

  final _velocita = ValoreFresco<double>(); // m/s
  final _cadenza = ValoreFresco<double>(); // rpm
  final _potenza = ValoreFresco<int>(); // W
  final _ruota = Contagiri(modulo: 0x100000000);
  final _pedaliCsc = Contagiri();
  final _pedaliPotenza = Contagiri();

  /// Il rullo manda i dati FTMS: si può comandare in ERG.
  bool comandabile = false;

  /// Un rullo smart collegato adesso: vuol dire che si pedala al chiuso.
  bool get rulloInUso => comandabile && stato == StatoSensore.collegato;
  bool _funzioniLette = false;

  /// Il rullo ha dichiarato di saper fare la calibrazione.
  bool sapeCalibrare = false;
  FaseCalibrazione faseCalibrazione = FaseCalibrazione.nessuna;
  double? calibraKmhDa;
  double? calibraKmhA;
  Timer? _scadenzaCalibrazione;

  /// Durante la calibrazione il rullo non riceve watt.
  bool get calibrando => const {
    FaseCalibrazione.avvio,
    FaseCalibrazione.accelera,
    FaseCalibrazione.smetti,
  }.contains(faseCalibrazione);
  bool _controllo = false; // il rullo ha accettato i comandi da noi
  int? _wattMandati;
  DateTime _mandatiIl = DateTime(0);

  double? get velocita => _velocita.valore;
  double? get cadenza => _cadenza.valore;
  int? get potenza => _potenza.valore;

  @override
  List<String> get altreRighe => ['$circonferenza'];
  @override
  set altreRighe(List<String> righe) {
    final v = righe.isEmpty ? null : int.tryParse(righe.first.trim());
    if (v != null && v >= 1000 && v <= 2400) circonferenza = v;
  }

  Future<void> impostaCirconferenza(int mm) async {
    circonferenza = mm.clamp(1000, 2400);
    await ricorda();
    notifyListeners();
  }

  Stream<List<int>> _flusso(Uuid servizio, Uuid c, String id) =>
      ble.subscribeToCharacteristic(
        QualifiedCharacteristic(
          serviceId: servizio,
          characteristicId: c,
          deviceId: id,
        ),
      );

  // Si chiede tutto: quello che il sensore non ha dà errore e si ignora.
  // L'ultimo è il punto dei comandi del rullo: le sue risposte arrivano lì
  // (e il rullo accetta i comandi solo se lo si ascolta).
  @override
  List<Stream<List<int>>> flussi(String id) => [
    _flusso(servizioRulli, _datiRulli, id),
    _flusso(servizioPotenza, _misuraPotenza, id),
    _flusso(servizioCsc, _misuraCsc, id),
    _flusso(servizioRulli, _comandiRulli, id),
    _flusso(servizioRulli, _statoRulli, id),
  ];

  /// Una volta per collegamento: che cosa dichiara di saper fare il rullo.
  Future<void> _leggiFunzioni() async {
    if (_funzioniLette || id.isEmpty) return;
    _funzioniLette = true;
    try {
      final funzioni = await ble.readCharacteristic(
        QualifiedCharacteristic(
          serviceId: servizioRulli,
          characteristicId: _funzioniRulli,
          deviceId: id,
        ),
      );
      sapeCalibrare = calibrazioneSupportata(funzioni);
      debugPrint('RulloCalibra funzioni=${_esadecimale(funzioni)}');
      notifyListeners();
    } catch (e) {
      debugPrint('RulloCalibra funzioni non lette: $e');
    }
  }

  void _fase(FaseCalibrazione f) {
    faseCalibrazione = f;
    if (!calibrando) {
      _scadenzaCalibrazione?.cancel();
      // Finita: per i prossimi watt il controllo si richiede da capo.
      _controllo = false;
    }
    notifyListeners();
  }

  /// Chiede al rullo la calibrazione: poi lui dice cosa fare (accelerare,
  /// smettere di pedalare) e come è andata. Se tace per 3 minuti, è fallita.
  Future<void> calibra() async {
    if (!rulloInUso || calibrando) return;
    _wattMandati = null;
    calibraKmhDa = null;
    calibraKmhA = null;
    _fase(FaseCalibrazione.avvio);
    _scadenzaCalibrazione = Timer(const Duration(minutes: 3), () {
      if (calibrando) _fase(FaseCalibrazione.errore);
    });
    if (!await _scrivi(const [_chiediControllo]) ||
        !await _scrivi(const [_calibrazione, 0x01])) {
      if (calibrando) _fase(FaseCalibrazione.errore);
      return;
    }
    _controllo = true;
  }

  /// Lascia perdere la calibrazione in corso.
  Future<void> annullaCalibrazione() async {
    if (calibrando) await _scrivi(const [_calibrazione, 0x02]);
    _fase(FaseCalibrazione.nessuna);
  }

  Future<bool> _scrivi(List<int> comando) async {
    if (id.isEmpty || stato != StatoSensore.collegato) return false;
    try {
      await ble.writeCharacteristicWithResponse(
        QualifiedCharacteristic(
          serviceId: servizioRulli,
          characteristicId: _comandiRulli,
          deviceId: id,
        ),
        value: comando,
      );
      return true;
    } catch (e) {
      debugPrint('Rullo: comando non riuscito $e');
      _controllo = false;
      return false;
    }
  }

  /// ERG: il rullo tiene [watt] qualunque rapporto e cadenza. Lo stesso
  /// valore si rimanda ogni 10 secondi, se il rullo se lo fosse perso.
  Future<void> impostaWatt(int watt) async {
    if (!comandabile || calibrando) return;
    final ora = DateTime.now();
    if (watt == _wattMandati &&
        ora.difference(_mandatiIl) < const Duration(seconds: 10)) {
      return;
    }
    _wattMandati = watt;
    _mandatiIl = ora;
    if (!_controllo) {
      if (!await _scrivi(const [_chiediControllo])) return;
      _controllo = true;
      await _scrivi(const [_parti]);
    }
    await _scrivi(comandoWatt(watt));
  }

  /// Rullo libero (pausa, ERG spento, fine): niente più watt imposti.
  Future<void> libera() async {
    if (!comandabile || _wattMandati == null) return;
    _wattMandati = null;
    if (_controllo) await _scrivi(const [_fermaPausa, 0x01]);
    _controllo = false;
  }

  /// I watt chiesti al rullo adesso (null se è libero).
  int? get wattImposti => _wattMandati;

  @override
  void leggi(int k, List<int> pacchetto) {
    final ora = DateTime.now();
    switch (k) {
      case 0:
        comandabile = true;
        _leggiFunzioni();
        final r = rulliDa(pacchetto);
        if (r.kmh != null) _velocita.imposta(r.kmh! / 3.6);
        if (r.rpm != null) _cadenza.imposta(r.rpm!);
        if (r.watt != null) _potenza.imposta(r.watt!);
      case 1:
        final p = potenzaDa(pacchetto);
        if (p.watt != null) _potenza.imposta(p.watt!);
        if (p.pedali != null) {
          _cadenza.imposta(_pedaliPotenza.aggiorna(p.pedali!, ora) * 60);
        }
      case 2:
        final c = cscDa(pacchetto);
        // Col rullo la velocità buona è la sua: i giri non la sovrascrivono.
        if (c.ruota != null && !comandabile) {
          _velocita.imposta(
            _ruota.aggiorna(c.ruota!, ora) * circonferenza / 1000,
          );
        }
        if (c.pedali != null) {
          _cadenza.imposta(_pedaliCsc.aggiorna(c.pedali!, ora) * 60);
        }
      case 3:
        if (calibrando) {
          debugPrint('RulloCalibra risposta=${_esadecimale(pacchetto)}');
          if (esitoComando(pacchetto, _chiediControllo) == false) {
            _fase(FaseCalibrazione.errore);
          }
          if (rispostaCalibrazione(pacchetto) case final r?) {
            calibraKmhDa = r.kmhDa;
            calibraKmhA = r.kmhA;
            _fase(
              r.riuscito ? FaseCalibrazione.accelera : FaseCalibrazione.errore,
            );
          }
        }
        // Rifiutato (un'altra app ha il controllo): si richiede la volta dopo.
        if (esitoComando(pacchetto, _chiediControllo) == false ||
            esitoComando(pacchetto, _potenzaObiettivo) == false) {
          debugPrint('Rullo: comando rifiutato');
          _controllo = false;
          _mandatiIl = DateTime(0);
        }
      case 4:
        if (!calibrando) return;
        debugPrint('RulloCalibra stato=${_esadecimale(pacchetto)}');
        if (faseDaStato(pacchetto) case final f?) _fase(f);
    }
  }

  @override
  void azzera() {
    _velocita.azzera();
    _cadenza.azzera();
    _potenza.azzera();
    _ruota.azzera();
    _pedaliCsc.azzera();
    _pedaliPotenza.azzera();
    // Staccato: la prossima uscita può essere su strada, con un altro sensore.
    comandabile = false;
    _funzioniLette = false;
    sapeCalibrare = false;
    _scadenzaCalibrazione?.cancel();
    faseCalibrazione = FaseCalibrazione.nessuna;
    // Ricollegato: il rullo ha dimenticato tutto, si richiede il controllo.
    _controllo = false;
    _wattMandati = null;
    _mandatiIl = DateTime(0);
  }
}

/// Uno solo per tutta l'app, come quello del battito.
final sensoreBici = SensoreBici();
