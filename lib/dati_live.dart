import 'models.dart';
import 'percorso.dart';

// Dati mostrati durante corsa, camminata e bici: velocità degli ultimi secondi
// e tempo di ogni tratto (giro). Logica pura, senza schermate.

/// Per quanti secondi si guarda indietro per la velocità "adesso": in bici
/// cambia in fretta, a piedi serve una media più lunga perché il GPS balla.
Duration finestraVelocita(String sport) => stessoSport(sport, 'Bici')
    ? const Duration(seconds: 10)
    : const Duration(seconds: 30);

/// Velocità attuale in m/s dai punti tenuti dal filtro. 0 se da [ora] non
/// arrivano punti nuovi da un po' (fermo: il filtro scarta il tremolio); null
/// se i punti sono troppo pochi per dirlo.
double? velocitaAttuale(
  List<PuntoGps> punti, {
  required DateTime ora,
  Duration finestra = const Duration(seconds: 30),
}) {
  if (punti.length < 2) return null;
  final ultimo = punti.last;
  if (ora.difference(ultimo.t) > const Duration(seconds: 10)) return 0;
  var metri = 0.0;
  var primo = ultimo;
  for (var k = punti.length - 2; k >= 0; k--) {
    final p = punti[k];
    if (ultimo.t.difference(p.t) > finestra) break;
    // Un buco lungo è una pausa: il tratto prima non c'entra.
    if (primo.t.difference(p.t) > const Duration(seconds: 10)) break;
    metri += distanzaM(p, primo);
    primo = p;
  }
  final s = ultimo.t.difference(primo.t).inMilliseconds / 1000;
  if (s < 5) return null;
  return metri / s;
}

/// Velocità (m/s) come la vuole lo sport: "5:42 min/km" o "24.3 km/h".
/// Sotto 1 km/h si è fermi: niente passo infinito.
String fmtVelocita(String sport, double? mps) {
  if (mps == null || mps < 0.28) return '–';
  final kmh = mps * 3.6;
  return fmtRitmo(sport, stessoSport(sport, 'Bici') ? kmh : 60 / kmh);
}

/// Lunghezza di un giro: 1 km a piedi, 5 km in bici (a 1 km suonerebbe ogni
/// due minuti).
int metriGiro(String sport) => stessoSport(sport, 'Bici') ? 5000 : 1000;

/// Un giro chiuso: quale (1, 2, …), quanto è lungo e quanto ci è voluto.
typedef Giro = ({int numero, int metri, Duration tempo});

/// Tiene il conto dei giri mentre crescono distanza e tempo (a cronometro
/// fermo in pausa, così le soste non contano).
class GiriLive {
  final int lunghezza; // metri
  final giri = <Giro>[];
  double _metri = 0;
  Duration _tempo = Duration.zero;
  Duration _inizioGiro = Duration.zero;

  GiriLive(this.lunghezza);

  /// Aggiorna con la distanza e il tempo di adesso; restituisce il giro se
  /// se n'è appena chiuso uno.
  Giro? aggiorna(double metri, Duration tempo) {
    Giro? chiuso;
    final soglia = (giri.length + 1) * lunghezza;
    if (metri >= soglia && metri > _metri) {
      // Il momento del passaggio, stimato tra la misura prima e questa.
      final quota = (soglia - _metri) / (metri - _metri);
      final passaggio = _tempo + (tempo - _tempo) * quota.clamp(0.0, 1.0);
      chiuso = (
        numero: giri.length + 1,
        metri: lunghezza,
        tempo: passaggio - _inizioGiro,
      );
      giri.add(chiuso);
      _inizioGiro = passaggio;
    }
    _metri = metri;
    _tempo = tempo;
    return chiuso;
  }
}

/// "5:42 min/km" (a piedi) o "28.4 km/h" (bici) di un giro.
String ritmoGiro(String sport, Giro g) =>
    '${fmtVelocita(sport, g.metri / (g.tempo.inMilliseconds / 1000))}'
    ' ${unitaRitmo(sport)}';
