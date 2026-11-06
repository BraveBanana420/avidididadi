import 'csv.dart';
import 'models.dart';

// Modifica a mano di una seduta già fatta: per chi non ha un orologio che la
// misura, i dati si scrivono dopo. Logica pura, la schermata è in screens/.

const nuotoHeader = [
  'id_sessione',
  'data',
  'vasche',
  'lunghezza_m',
  'passo_100_s',
  'stile',
];

/// Le lunghezze di vasca più comuni.
const lunghezzeVasca = [25, 50];

const stiliNuoto = ['Stile libero', 'Dorso', 'Rana', 'Delfino', 'Misti'];

/// Vasche e tempi di una nuotata scritti a mano: i metri stanno nella sessione.
class SedutaNuoto {
  final String idSessione;
  final DateTime data;
  final int vasche;
  final int lunghezzaM;
  final int passo100S; // tempo medio per 100 m (0 = non scritto)
  final String stile;
  const SedutaNuoto({
    required this.idSessione,
    required this.data,
    this.vasche = 0,
    this.lunghezzaM = 25,
    this.passo100S = 0,
    this.stile = '',
  });

  bool get vuota => vasche == 0 && passo100S == 0 && stile.isEmpty;

  List<String> toRow() => [
    idSessione,
    isoData(data),
    vasche == 0 ? '' : '$vasche',
    '$lunghezzaM',
    passo100S == 0 ? '' : '$passo100S',
    stile,
  ];

  static SedutaNuoto? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    final id = t.v(r, 'id_sessione');
    if (d == null || id.isEmpty) return null;
    return SedutaNuoto(
      idSessione: id,
      data: d,
      vasche: _intero(t.v(r, 'vasche'), 2000),
      lunghezzaM: _intero(t.v(r, 'lunghezza_m'), 200, base: 25),
      passo100S: _intero(t.v(r, 'passo_100_s'), 1800),
      stile: t.v(r, 'stile'),
    );
  }
}

int _intero(String testo, int massimo, {int base = 0}) {
  final v = numero(testo).round();
  return v <= 0 ? base : (v > massimo ? massimo : v);
}

/// Un numero scritto a mano, nei limiti di un allenamento vero. Vuoto o
/// sbagliato vale 0: il dato non c'è.
double numeroScritto(String testo, double massimo) {
  final v = numero(testo);
  return v <= 0 ? 0 : (v > massimo ? massimo : v);
}

/// Il tempo medio scritto a mano: "1:55", "1.55" o i soli secondi ("115").
int secondiDa(String testo) {
  final t = testo.trim().replaceAll('.', ':').replaceAll(',', ':');
  if (t.isEmpty) return 0;
  final parti = t.split(':');
  if (parti.length > 2) return 0;
  final a = int.tryParse(parti[0]);
  if (a == null || a < 0) return 0;
  if (parti.length == 1) return a;
  final b = int.tryParse(parti[1]);
  if (b == null || b < 0 || b >= 60) return 0;
  return a * 60 + b;
}

/// "1:55" per il campo del tempo medio (vuoto se non c'è).
String tempoScritto(int secondi) =>
    secondi <= 0 ? '' : '${secondi ~/ 60}:${two(secondi % 60)}';

/// La sessione con i dati scritti a mano. Il giorno e l'id non cambiano, perché
/// percorso, grafici e feedback sono legati a quelli; la fine segue la durata.
Sessione sessioneModificata(
  Sessione s, {
  required DateTime inizio,
  required int durataMin,
  required double distanzaKm,
  required int fcMedia,
  required int fcMax,
  required double calorie,
  required double rpe,
  required String note,
}) {
  final minuti = durataMin.clamp(1, 2880);
  return Sessione(
    id: s.id,
    data: s.data,
    sport: s.sport,
    tipo: s.tipo,
    durataMin: minuti,
    distanzaKm: distanzaKm,
    fcMedia: fcMedia,
    rpe: rpe,
    fonte: s.fonte,
    note: note,
    inizio: inizio,
    fine: inizio.add(Duration(minutes: minuti)),
    fcMax: fcMax,
    calorieAttive: calorie,
    calorieTotali: calorie != s.calorieAttive ? calorie : s.calorieTotali,
    passi: s.passi,
    origine: s.origine,
    potenzaMedia: s.potenzaMedia,
    cadenzaMedia: s.cadenzaMedia,
    parti: s.parti,
  );
}
