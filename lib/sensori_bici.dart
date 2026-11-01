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
  @override
  List<Stream<List<int>>> flussi(String id) => [
    _flusso(servizioRulli, _datiRulli, id),
    _flusso(servizioPotenza, _misuraPotenza, id),
    _flusso(servizioCsc, _misuraCsc, id),
  ];

  @override
  void leggi(int k, List<int> pacchetto) {
    final ora = DateTime.now();
    switch (k) {
      case 0:
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
        if (c.ruota != null) {
          _velocita.imposta(
            _ruota.aggiorna(c.ruota!, ora) * circonferenza / 1000,
          );
        }
        if (c.pedali != null) {
          _cadenza.imposta(_pedaliCsc.aggiorna(c.pedali!, ora) * 60);
        }
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
  }
}

/// Uno solo per tutta l'app, come quello del battito.
final sensoreBici = SensoreBici();
