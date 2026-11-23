import 'dart:async';

import 'package:flutter/services.dart';

import 'avvisi.dart';
import 'dati_live.dart';
import 'esecuzione.dart';
import 'models.dart';
import 'navigazione.dart';
import 'l10n/lingua.dart';
import 'l10n/vocabolario.dart';

// La voce dell'allenamento: frasi scritte per essere ascoltate ("zona 4",
// "5 minuti e 42 al chilometro"), non le sigle dello schermo. Le frasi sono
// logica pura; [voce] le passa alla sintesi vocale di Android.

const _canale = MethodChannel('avidididadi/avvio');

/// "42 secondi", "5 minuti e 42", "1 ora e 5 minuti".
String parlaDurata(Duration d) {
  final s = d.inSeconds;
  String unita(int n, String uno, String tanti) => '$n ${n == 1 ? uno : tanti}';
  if (s < 60) return unita(s, l10nVoce.parolaSecondo, l10nVoce.parolaSecondi);
  if (s < 3600) {
    final m = s ~/ 60;
    final r = s % 60;
    return r == 0
        ? unita(m, l10nVoce.parolaMinuto, l10nVoce.parolaMinuti)
        : l10nVoce.unoEAltro(
            unita(m, l10nVoce.parolaMinuto, l10nVoce.parolaMinuti),
            r,
          );
  }
  final m = s % 3600 ~/ 60;
  final ore = unita(s ~/ 3600, l10nVoce.parolaOra, l10nVoce.parolaOre);
  return m == 0
      ? ore
      : l10nVoce.unoEAltro(
          ore,
          unita(m, l10nVoce.parolaMinuto, l10nVoce.parolaMinuti),
        );
}

/// "5 e 42 al chilometro" a piedi, "27 chilometri all'ora" in bici.
String parlaVelocita(String sport, double mps) {
  final kmh = mps * 3.6;
  if (stessoSport(sport, 'Bici')) return l10nVoce.chilometriAllOra(kmh.round());
  final s = (3600 / kmh).round();
  final r = s % 60;
  return r == 0
      ? l10nVoce.minutiAlChilometro(s ~/ 60)
      : l10nVoce.alChilometro(s ~/ 60, r);
}

/// Il giro appena chiuso, a voce.
String fraseGiro(String sport, Giro g) {
  final km = g.numero * g.metri ~/ 1000;
  final mps = g.metri / (g.tempo.inMilliseconds / 1000);
  if (g.metri == 1000) {
    return l10nVoce.chilometro(km, parlaVelocita(sport, mps));
  }
  return l10nVoce.chilometroUltimi(
    km,
    g.metri ~/ 1000,
    parlaDurata(g.tempo),
    parlaVelocita(sport, mps),
  );
}

/// I gradi dell'arrampicata per la sintesi vocale: "6a+" → "6 A più", altrimenti
/// "6a" si legge "sesta". "6a-6c" → "da 6 A a 6 C".
String gradiParlati(String testo) {
  const grado = r'(?<![\w:.,/])([4-9])([abcABC])(\+?)(?!\w)';
  String di(String n, String l, String p) =>
      '$n ${l.toUpperCase()}${p.isEmpty ? '' : l10nVoce.piu4}';
  final t = testo.replaceAllMapped(
    RegExp('$grado-([4-9])([abcABC])(\\+?)(?!\\w)'),
    (m) => l10nVoce.daA(di(m[1]!, m[2]!, m[3]!), di(m[4]!, m[5]!, m[6]!)),
  );
  return t.replaceAllMapped(RegExp(grado), (m) => di(m[1]!, m[2]!, m[3]!));
}

/// Le sigle dello schermo dette per esteso: "8-10" → "da 8 a 10",
/// "45 s" → "45 secondi", "Z2" → "zona 2", " · " → pausa.
String parlato(String testo) {
  var t = gradiParlati(testo).replaceAll(' · ', ', ');
  String plurale(Match m, String uno, String tanti) =>
      '${m[1]} ${m[1] == '1' ? uno : tanti}';
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+)-(\d+)\b'),
    (m) => l10nVoce.daA(m[1]!, m[2]!),
  );
  t = t.replaceAllMapped(
    RegExp(r'\bZ([1-5])\b'),
    (m) => '${l10nVoce.parolaZona} ${m[1]}',
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?min\b'),
    (m) => plurale(m, l10nVoce.parolaMinuto, l10nVoce.parolaMinuti),
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?s\b'),
    (m) => plurale(m, l10nVoce.parolaSecondo, l10nVoce.parolaSecondi),
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?km\b'),
    (m) => plurale(m, l10nVoce.parolaChilometro, l10nVoce.parolaChilometri),
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?m\b'),
    (m) => plurale(m, l10nVoce.parolaMetro, l10nVoce.parolaMetri),
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+(?:,\d+)?) ?kg\b'),
    (m) => l10nVoce.quantiChili(m[1]!),
  );
  t = t.replaceAll('/10', l10nVoce.su102);
  t = t.replaceAll(
    RegExp(r'\brpm\b', caseSensitive: false),
    l10nVoce.giriAlMinuto,
  );
  t = t.replaceAllMapped(
    RegExp(r'\b(\d+) ?W\b'),
    (m) => l10nVoce.quantiWatt(m[1]!),
  );
  return t;
}

/// Il blocco che inizia: cosa fare, quanto e a che intensità.
String fraseBlocco(Blocco b) {
  if (b.cambioLato) return l10nVoce.cambiaLatoVoce;
  if (b.tipo == TipoBlocco.recupero) {
    return b.secondi == null
        ? l10nVoce.recupero3
        : l10nVoce.recupero4(parlaDurata(Duration(seconds: b.secondi!)));
  }
  final pezzi = [
    // Il nome del blocco è salvato in italiano: si dice nella lingua
    // della voce, se è tra quelli noti.
    l10nVoce.ora(gradiParlati(nomePerVoce(b.titolo))),
    if (b.dettaglio.isNotEmpty) parlato(_latoPerVoce(b)),
    // Intensità e obiettivo sono scritti in italiano nei dati.
    if (b.intensita.isNotEmpty) parlato(testoPerVoce(b.intensita)),
    if (b.obiettivo2.isNotEmpty) parlato(testoPerVoce(b.obiettivo2)),
  ];
  return '${pezzi.map((p) => p.trim().replaceAll(RegExp(r'[.\s]+$'), '')).join('. ')}.';
}

/// Il dettaglio del blocco con "Lato destro" o "Lato sinistro" nella lingua
/// della voce: il dettaglio è scritto nella lingua dell'app.
String _latoPerVoce(Blocco b) => switch (b.lato) {
  latoDestro => b.dettaglio.replaceFirst(l10n.latoDestro, l10nVoce.latoDestro),
  latoSinistro => b.dettaglio.replaceFirst(
    l10n.latoSinistro,
    l10nVoce.latoSinistro,
  ),
  _ => b.dettaglio,
};

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

String fraseZona(int zona, int verso) =>
    verso > 0 ? l10nVoce.zonaRallenta(zona) : l10nVoce.zonaPuoiSpingerePo(zona);

/// Fuori passo: 1 troppo veloce, -1 troppo lento, 0 nel margine.
int versoVelocita(double mps, double obiettivo) =>
    mps > obiettivo * (1 + margineVelocita)
    ? 1
    : mps < obiettivo * (1 - margineVelocita)
    ? -1
    : 0;

String fraseVelocita(String sport, double mps, int verso) {
  final quanto = stessoSport(sport, 'Bici')
      ? l10nVoce.velocita
      : l10nVoce.passo;
  return verso > 0
      ? l10nVoce.rallentaPo(quanto, parlaVelocita(sport, mps))
      : l10nVoce.acceleraPo(quanto, parlaVelocita(sport, mps));
}

/// Se sul telefono c'è la voce per [codice] (es. 'el'). Senza risposta (nei
/// test, o se la sintesi vocale manca) si considera di sì.
Future<bool> voceDisponibile(String codice) async {
  try {
    return await _canale.invokeMethod<bool>('voceDisponibile', codice) ?? true;
  } catch (_) {
    return true;
  }
}

/// Apre le impostazioni della sintesi vocale del telefono.
Future<void> apriImpostazioniVoce() async {
  try {
    await _canale.invokeMethod('impostazioniVoce');
  } catch (_) {}
}

/// Una frase di prova nella lingua della voce: un'indicazione stradale.
String fraseProvaVoce() {
  final t = l10nVoce;
  return t.tra(parlaMetri(200), const Curva(0, 90).fraseIn(t), '');
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
            'lingua': codiceVoce,
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

  /// Il blocco appena aperto. Scorrendo a mano ([aMano]) toglie la voce a quello
  /// di prima, così si sente solo quello che è sullo schermo; quando passa da
  /// solo, col timer, non taglia un avviso in corso (una svolta, un chilometro).
  Future<void> diBlocco(Blocco b, {required bool aMano}) =>
      di(fraseBlocco(b), valida: const Duration(seconds: 30), urgente: aMano);

  /// Dice una frase di prova, anche con la voce spenta negli avvisi.
  Future<void> prova() => _parla(fraseProvaVoce(), urgente: true);

  /// Fine allenamento: niente frasi in sospeso.
  void ferma() {
    _riprova?.cancel();
    _riprova = null;
    _attesa = null;
  }
}
