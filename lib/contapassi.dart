import 'dart:async';

import 'package:flutter/services.dart';

// Passi contati dal sensore del telefono (lo stesso del contapassi di
// Android), solo durante corsa e camminata: non serve l'orologio.

const _canale = MethodChannel('avidididadi/avvio');

/// Senza passi nuovi da così tanto si è fermi: la cadenza non si mostra.
const fermoDopo = Duration(seconds: 15);

/// La cadenza di adesso si fa sugli ultimi secondi di passi.
const _finestraMs = 20000.0;

/// Somma i passi fatti a cronometro acceso, partendo dal totale del sensore
/// (i passi dall'accensione del telefono).
class ContaPassi {
  /// Passi fatti a cronometro acceso.
  int passi;
  ContaPassi([this.passi = 0]);

  double? _ultimo; // l'ultimo totale letto dal sensore
  DateTime? _cambiatoIl; // quando è arrivato l'ultimo passo

  /// Letture recenti (momento dell'ultimo passo in millisecondi, totale).
  final _recenti = <(double, double)>[];

  /// Una lettura del sensore: [totale] passi dall'accensione del telefono,
  /// l'ultimo fatto a [tempoMs]. In pausa ([attivo] falso) i passi non contano.
  void aggiorna(
    double totale,
    double tempoMs, {
    required bool attivo,
    required DateTime ora,
  }) {
    final prima = _ultimo;
    _ultimo = totale;
    // Prima lettura, o telefono riavviato (il totale riparte da zero).
    if (prima == null || totale < prima) {
      _recenti.clear();
      return;
    }
    if (!attivo) {
      _recenti.clear();
      return;
    }
    if (totale == prima) return;
    passi += (totale - prima).round();
    _cambiatoIl = ora;
    // Dopo una sosta la cadenza riparte da capo.
    if (_recenti.isNotEmpty &&
        tempoMs - _recenti.last.$1 > fermoDopo.inMilliseconds) {
      _recenti.clear();
    }
    _recenti.add((tempoMs, totale));
    while (_recenti.length > 2 && tempoMs - _recenti[1].$1 >= _finestraMs) {
      _recenti.removeAt(0);
    }
  }

  /// Passi al minuto di adesso; null da fermi o nei primi secondi.
  int? cadenza(DateTime ora) {
    final c = _cambiatoIl;
    if (c == null || ora.difference(c) > fermoDopo || _recenti.length < 2) {
      return null;
    }
    final (t0, p0) = _recenti.first;
    final (t1, p1) = _recenti.last;
    final ms = t1 - t0;
    if (ms < 4000) return null;
    final v = ((p1 - p0) / ms * 60000).round();
    return v >= 30 && v <= 260 ? v : null;
  }
}

/// Passi al minuto medi; null se sono troppo pochi per dirlo.
int? mediaPassiAlMinuto(int passi, Duration tempo) {
  if (passi <= 0 || tempo.inSeconds < 30) return null;
  final v = (passi / (tempo.inSeconds / 60)).round();
  return v >= 30 && v <= 260 ? v : null;
}

/// "12.345": i passi con il punto delle migliaia.
String fmtPassi(int n) {
  final s = '$n';
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

/// Il contapassi del telefono: legge il sensore una volta al secondo finché
/// l'allenamento è aperto.
class SensorePassi {
  final ContaPassi conta;

  /// Vero a cronometro acceso (non prima del via, in pausa o alla fine).
  final bool Function() attivo;
  SensorePassi(this.conta, {required this.attivo});

  Timer? _tic;

  /// Falso se il telefono non ha il sensore o il permesso non c'è.
  bool disponibile = false;

  /// Chiede il permesso "Attività fisica" (una volta) e accende il sensore.
  Future<void> avvia() async {
    if (_tic != null) return;
    try {
      disponibile = await _canale.invokeMethod<bool>('passiAvvia') ?? false;
    } catch (_) {
      disponibile = false;
    }
    if (!disponibile) return;
    _tic = Timer.periodic(const Duration(seconds: 1), (_) => _leggi());
  }

  Future<void> _leggi() async {
    try {
      final v = await _canale.invokeMethod<List<Object?>>('passiLetti');
      if (v == null || v.length < 2) return;
      conta.aggiorna(
        (v[0] as num).toDouble(),
        (v[1] as num).toDouble(),
        attivo: attivo(),
        ora: DateTime.now(),
      );
    } catch (_) {}
  }

  void ferma() {
    if (_tic == null) return;
    _tic?.cancel();
    _tic = null;
    _canale.invokeMethod<void>('passiFerma').catchError((_) {});
  }
}
