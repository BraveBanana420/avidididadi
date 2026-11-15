import 'dart:math' as math;

/// Scala di un asse con tacche su numeri tondi: da [lo] a [hi], una ogni
/// [passo].
typedef ScalaAsse = ({double lo, double hi, double passo});

/// Passi tondi per i tempi in secondi (passo al km, durate).
const passiTempo = <double>[5, 10, 15, 30, 60, 120, 300, 600, 900, 1800, 3600];

/// La scala più fitta, su numeri tondi, che contiene [min]-[max] con al
/// massimo [intervalli] spazi tra le tacche: 126-585 W diventa 0-600 con una
/// tacca ogni 200, invece di 126, 356 e 585.
/// Con [passi] si scelgono solo quelli (es. [passiTempo]); se nessuno basta si
/// torna ai passi decimali (1, 2, 2,5 e 5 per le potenze di dieci).
ScalaAsse scalaTonda(
  double min,
  double max, {
  int intervalli = 4,
  List<double>? passi,
}) {
  if (!min.isFinite || !max.isFinite) return (lo: 0, hi: 1, passo: 1);
  if (max < min) (min, max) = (max, min);
  if (max - min < 1e-9) {
    // Una linea piatta: un po' di spazio sopra e sotto.
    final margine = math.max(min.abs() * 0.1, 1.0);
    min -= margine;
    max += margine;
  }
  ScalaAsse? prova(double passo) {
    final lo = (min / passo + 1e-9).floorToDouble() * passo;
    final hi = (max / passo - 1e-9).ceilToDouble() * passo;
    final n = ((hi - lo) / passo).round();
    return n <= intervalli ? (lo: lo + 0.0, hi: hi + 0.0, passo: passo) : null;
  }

  for (final p in passi ?? const <double>[]) {
    final s = prova(p);
    if (s != null) return s;
  }
  final esponente = (math.log(max - min) / math.ln10).floor() - 2;
  for (var e = esponente; ; e++) {
    final decina = math.pow(10, e).toDouble();
    for (final base in const [1, 2, 2.5, 5]) {
      final s = prova(base * decina);
      if (s != null) return s;
    }
  }
}

/// Le tacche di [s], dalla più alta alla più bassa.
List<double> tacche(ScalaAsse s) {
  final n = ((s.hi - s.lo) / s.passo).round();
  // "+ 0.0" toglie lo zero negativo, che si scriverebbe "-0".
  return [for (var i = 0; i <= n; i++) s.hi - s.passo * i + 0.0];
}

/// Il valore sotto cui sta la frazione [q] (0-1) di [valori]: serve a non
/// far decidere la scala a pochi picchi isolati.
double percentile(List<double> valori, double q) {
  if (valori.isEmpty) return 0;
  final v = [...valori]..sort();
  return v[((v.length - 1) * q.clamp(0, 1)).round()];
}

/// Il numero di una tacca: intero se è tondo ("6", non "6.0"), altrimenti con
/// un decimale ("0.5").
String numeroAsse(double v) => (v - v.roundToDouble()).abs() < 0.05
    ? '${v.round()}'
    : v.toStringAsFixed(1);
