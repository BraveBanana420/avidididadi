import 'dart:async';

import 'package:flutter/services.dart';

import 'avvisi.dart';
import 'dati_live.dart';
import 'esecuzione.dart';
import 'models.dart';

// La voce dell'allenamento: frasi scritte per essere ascoltate ("zona 4",
// "5 minuti e 42 al chilometro"), non le sigle dello schermo. Le frasi sono
// logica pura; [voce] le passa alla sintesi vocale di Android.

const _canale = MethodChannel('avidididadi/avvio');

/// "42 secondi", "5 minuti e 42", "1 ora e 5 minuti".
String parlaDurata(Duration d) {
  final s = d.inSeconds;
  String unita(int n, String uno, String tanti) => '$n ${n == 1 ? uno : tanti}';
  if (s < 60) return unita(s, 'secondo', 'secondi');
  if (s < 3600) {
    final m = s ~/ 60;
    final r = s % 60;
    return r == 0
        ? unita(m, 'minuto', 'minuti')
        : '${unita(m, 'minuto', 'minuti')} e $r';
  }
  final m = s % 3600 ~/ 60;
  final ore = unita(s ~/ 3600, 'ora', 'ore');
  return m == 0 ? ore : '$ore e ${unita(m, 'minuto', 'minuti')}';
}

/// "5 e 42 al chilometro" a piedi, "27 chilometri all'ora" in bici.
String parlaVelocita(String sport, double mps) {
  final kmh = mps * 3.6;
  if (stessoSport(sport, 'Bici')) return "${kmh.round()} chilometri all'ora";
  final s = (3600 / kmh).round();
  final r = s % 60;
  return r == 0
      ? '${s ~/ 60} minuti al chilometro'
      : '${s ~/ 60} e $r al chilometro';
}

/// Il giro appena chiuso, a voce.
String fraseGiro(String sport, Giro g) {
  final km = g.numero * g.metri ~/ 1000;
  final mps = g.metri / (g.tempo.inMilliseconds / 1000);
  if (g.metri == 1000) {
    return 'Chilometro $km. ${parlaVelocita(sport, mps)}.';
  }
  return 'Chilometro $km. Ultimi ${g.metri ~/ 1000} in '
      '${parlaDurata(g.tempo)}, ${parlaVelocita(sport, mps)}.';
}

/// Le sigle dello schermo dette per esteso: "8-10" → "da 8 a 10",
/// "45 s" → "45 secondi", "Z2" → "zona 2", " · " → pausa.
String parlato(String testo) {
  var t = testo.replaceAll(' · ', ', ');
  String plurale(Match m, String uno, String tanti) =>
      '${m[1]} ${m[1] == '1' ? uno : tanti}';
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+)-(\d+)\b'),
    (m) => 'da ${m[1]} a ${m[2]}',
  );
  t = t.replaceAllMapped(RegExp(r'\bZ([1-5])\b'), (m) => 'zona ${m[1]}');
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?min\b'),
    (m) => plurale(m, 'minuto', 'minuti'),
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?s\b'),
    (m) => plurale(m, 'secondo', 'secondi'),
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?km\b'),
    (m) => plurale(m, 'chilometro', 'chilometri'),
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?m\b'),
    (m) => plurale(m, 'metro', 'metri'),
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+(?:,\d+)?) ?kg\b'),
    (m) => '${m[1]} chili',
  );
  t = t.replaceAll('/10', ' su 10');
  t = t.replaceAll(RegExp(r'\brpm\b', caseSensitive: false), 'giri al minuto');
  t = t.replaceAllMapped(RegExp(r'\b(\d+) ?W\b'), (m) => '${m[1]} watt');
  return t;
}

/// Il blocco che inizia: cosa fare, quanto e a che intensità.
String fraseBlocco(Blocco b) {
  if (b.tipo == TipoBlocco.recupero) {
    return b.secondi == null
        ? 'Recupero.'
        : 'Recupero, ${parlaDurata(Duration(seconds: b.secondi!))}.';
  }
  final pezzi = [
    'Ora: ${b.titolo}',
    if (b.dettaglio.isNotEmpty) parlato(b.dettaglio),
    if (b.intensita.isNotEmpty) parlato(b.intensita),
    if (b.obiettivo2.isNotEmpty) parlato(b.obiettivo2),
  ];
  return '${pezzi.map((p) => p.trim().replaceAll(RegExp(r'[.\s]+$'), '')).join('. ')}.';
}

/// La zona chiesta dall'esercizio ("zona 4", "Z2"), se c'è.
int? zonaObiettivo(String intensita) {
  final m = RegExp(
    r'\b(?:zona\s*|Z)([1-5])\b',
    caseSensitive: false,
  ).firstMatch(intensita);
  return m == null ? null : int.parse(m[1]!);
}

/// Il passo (o la velocità in bici) chiesto dall'esercizio, in m/s: "5:30/km",
/// "5:30 min/km", "28 km/h". Null se non c'è.
double? velocitaObiettivo(String testo) {
  final passo = RegExp(r'(\d{1,2}):(\d{2})\s*(?:min)?\s*/\s*km')
      .firstMatch(testo);
  if (passo != null) {
    final s = int.parse(passo[1]!) * 60 + int.parse(passo[2]!);
    return s > 0 ? 1000 / s : null;
  }
  final kmh = RegExp(r'(\d+(?:[.,]\d+)?)\s*km/h').firstMatch(testo);
  if (kmh != null) {
    final v = double.parse(kmh[1]!.replaceAll(',', '.'));
    return v > 0 ? v / 3.6 : null;
  }
  return null;
}

/// Margine sul passo chiesto prima di avvisare.
const margineVelocita = 0.05;

/// Decide quando avvisare di un ritmo sbagliato: solo se dura da almeno
/// [attesa] (non per un sorpasso o una salita breve) e non più di una volta
/// ogni [intervallo].
class ControlloRitmo {
  static const attesa = Duration(seconds: 20);
  static const intervallo = Duration(seconds: 60);

  int _verso = 0;
  DateTime? _da;
  DateTime? _ultimo;

  /// Nuovo esercizio: si riparte da capo.
  void azzera() {
    _verso = 0;
    _da = null;
  }

  /// [verso]: 1 troppo forte, -1 troppo piano, 0 giusto. True se è il momento
  /// di dirlo.
  bool controlla(int verso, DateTime ora) {
    if (verso != _verso || _da == null) {
      _verso = verso;
      _da = ora;
      return false;
    }
    if (verso == 0 || ora.difference(_da!) < attesa) return false;
    if (_ultimo != null && ora.difference(_ultimo!) < intervallo) return false;
    _ultimo = ora;
    return true;
  }
}

/// Fuori zona: 1 sopra, -1 sotto (solo per le zone dalla 3 in su: andare più
/// piano in un lento va bene), 0 dentro.
int versoZona(int zona, int obiettivo) => zona > obiettivo
    ? 1
    : zona < obiettivo && obiettivo >= 3
    ? -1
    : 0;

String fraseZona(int zona, int verso) => verso > 0
    ? 'Zona $zona, rallenta.'
    : 'Zona $zona, puoi spingere un po\' di più.';

/// Fuori passo: 1 troppo veloce, -1 troppo lento, 0 nel margine.
int versoVelocita(double mps, double obiettivo) =>
    mps > obiettivo * (1 + margineVelocita)
    ? 1
    : mps < obiettivo * (1 - margineVelocita)
    ? -1
    : 0;

String fraseVelocita(String sport, double mps, int verso) {
  final quanto = stessoSport(sport, 'Bici') ? 'Velocità' : 'Passo';
  return verso > 0
      ? '$quanto ${parlaVelocita(sport, mps)}, rallenta un po\'.'
      : '$quanto ${parlaVelocita(sport, mps)}, accelera un po\'.';
}

/// La sintesi vocale. Durante una chiamata tace: tiene da parte solo l'ultima
/// frase e la dice a chiamata finita, se è ancora utile.
class Voce {
  String? _attesa;
  DateTime? _scade;
  Timer? _riprova;

  Future<String> _parla(String testo, {bool urgente = false}) async {
    try {
      return await _canale.invokeMethod<String>('parla', {
            'testo': testo,
            'urgente': urgente,
          }) ??
          'errore';
    } catch (_) {
      return 'errore';
    }
  }

  /// Dice [testo]; se c'è una chiamata, lo ritenta finché vale ([valida]).
  /// [urgente]: interrompe la frase in corso e quelle in coda (le curve).
  Future<void> di(
    String testo, {
    Duration valida = const Duration(minutes: 2),
    bool urgente = false,
  }) async {
    if (!voceAttiva.value) return;
    if (_attesa != null) {
      // Si sta aspettando la fine di una chiamata: conta solo l'ultima.
      _attesa = testo;
      _scade = DateTime.now().add(valida);
      return;
    }
    if (await _parla(testo, urgente: urgente) != 'chiamata') return;
    _attesa = testo;
    _scade = DateTime.now().add(valida);
    _riprova = Timer.periodic(const Duration(seconds: 3), (_) async {
      final t = _attesa;
      if (t == null || DateTime.now().isAfter(_scade!)) {
        ferma();
        return;
      }
      if (await _parla(t) != 'chiamata') ferma();
    });
  }

  /// Fine allenamento: niente frasi in sospeso.
  void ferma() {
    _riprova?.cancel();
    _riprova = null;
    _attesa = null;
  }
}
