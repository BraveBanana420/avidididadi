import 'dart:math' as math;

import 'obiettivo.dart';
import 'models.dart';
import 'percorso.dart';

/// Le serie nel tempo di un'attività (battito, velocità) per i grafici, come
/// nel dettaglio di Garmin. Da Health Connect arrivano un campione ogni 15-20
/// secondi circa; altitudine, pendenza e potenza arrivano solo da intervals.icu.

class Campione {
  final DateTime t;
  final double v;
  const Campione(this.t, this.v);
}

class SerieSessione {
  final List<Campione> fc; // battiti al minuto
  final List<Campione> velocita; // metri al secondo
  // Solo da intervals.icu: Health Connect non le ha.
  final List<Campione> altitudine; // metri
  final List<Campione> pendenza; // %
  final List<Campione> potenza; // watt
  final List<Campione> cadenza; // giri o passi al minuto
  const SerieSessione({
    this.fc = const [],
    this.velocita = const [],
    this.altitudine = const [],
    this.pendenza = const [],
    this.potenza = const [],
    this.cadenza = const [],
  });
  bool get vuota =>
      fc.isEmpty && velocita.isEmpty && altitudine.isEmpty && potenza.isEmpty;
}

/// La nota sotto i grafici, solo quando serve davvero: all'aperto, senza
/// intervals.icu. Al chiuso altitudine e pendenza non esistono, e con
/// intervals.icu già collegato non c'è niente da fare.
String? notaDatiMancanti({
  required bool conPercorso,
  required bool alChiuso,
  required bool intervalsCollegato,
  required bool conAltitudine,
  required bool conPotenza,
}) {
  if (!conPercorso || alChiuso || intervalsCollegato || conAltitudine) {
    return null;
  }
  final cosa = conPotenza
      ? 'Altitudine e pendenza'
      : 'Altitudine, pendenza e potenza';
  return '$cosa non ci sono: per averle collega intervals.icu '
      '(Profilo → Dati e collegamenti).';
}

/// Al massimo [punti] valori: media dei campioni in intervalli uguali di
/// tempo, così il grafico resta leggibile e veloce.
List<Campione> ricampiona(List<Campione> serie, {int punti = 120}) {
  if (serie.length <= punti) return serie;
  final ordinata = [...serie]..sort((a, b) => a.t.compareTo(b.t));
  final da = ordinata.first.t.millisecondsSinceEpoch;
  final durata = ordinata.last.t.millisecondsSinceEpoch - da;
  if (durata <= 0) return ordinata.take(punti).toList();
  final somme = List.filled(punti, 0.0), conti = List.filled(punti, 0);
  for (final c in ordinata) {
    final i = ((c.t.millisecondsSinceEpoch - da) / durata * (punti - 1))
        .round();
    somme[i] += c.v;
    conti[i]++;
  }
  return [
    for (var i = 0; i < punti; i++)
      if (conti[i] > 0)
        Campione(
          DateTime.fromMillisecondsSinceEpoch(
            da + (durata * i / (punti - 1)).round(),
          ),
          somme[i] / conti[i],
        ),
  ];
}

/// La cadenza di corsa e camminata in passi al minuto: si raddoppia se è
/// contata su un piede solo. Lo decide il valore centrale della seduta, così
/// un tratto strano non cambia la scala; i momenti da fermi non contano.
List<Campione> passiAlMinuto(List<Campione> cadenza, String sport) {
  final inMoto = [
    for (final c in cadenza)
      if (c.v > 0) c,
  ];
  if (inMoto.isEmpty) return const [];
  final ordinati = [for (final c in inMoto) c.v]..sort();
  final doppio = cadenzaDiUnPiede(ordinati[ordinati.length ~/ 2], sport);
  return doppio ? [for (final c in inMoto) Campione(c.t, c.v * 2)] : inMoto;
}

/// Passi al minuto dai conteggi di Health Connect (inizio, fine, passi). Quelli
/// lunghi (il totale del giorno o della seduta) non dicono com'è andata nel
/// tempo, e con meno di 3 punti il grafico non serve.
List<Campione> passiDaConteggi(List<(DateTime, DateTime, double)> conteggi) {
  final out = <Campione>[
    for (final (da, a, passi) in conteggi)
      if (a.difference(da).inSeconds case final s when s >= 5 && s <= 600)
        if (passi / s * 60 case final v when v >= 30 && v <= 260)
          Campione(da, v),
  ]..sort((x, y) => x.t.compareTo(y.t));
  return out.length < 3 ? const [] : out;
}

/// Tempo passato in ogni zona di battito (1-5); i buchi oltre il minuto tra
/// due campioni non contano (pause, orologio tolto).
Map<int, Duration> tempoNelleZone(List<Campione> fc, Zone z) {
  final out = {for (var n = 1; n <= 5; n++) n: Duration.zero};
  final ordinata = [...fc]..sort((a, b) => a.t.compareTo(b.t));
  for (var i = 1; i < ordinata.length; i++) {
    final dt = ordinata[i].t.difference(ordinata[i - 1].t);
    if (dt.inSeconds <= 0 || dt.inSeconds > 60) continue;
    final bpm = ordinata[i - 1].v;
    var zona = 0;
    for (var n = 5; n >= 1; n--) {
      if (bpm >= z.zona(n).$1) {
        zona = n;
        break;
      }
    }
    if (zona > 0) out[zona] = out[zona]! + dt;
  }
  return out;
}

/// Velocità dai punti GPS registrati dall'app, mediata su circa 30 secondi
/// per togliere il tremolio del GPS.
List<Campione> velocitaDaPercorso(Percorso p) {
  final out = <Campione>[];
  final punti = p.punti;
  var i = 0;
  for (var j = 1; j < punti.length; j++) {
    final dt = punti[j].t.difference(punti[i].t).inMilliseconds / 1000;
    if (dt < 30) continue;
    var metri = 0.0;
    for (var k = i + 1; k <= j; k++) {
      metri += distanzaM(punti[k - 1], punti[k]);
    }
    if (dt < 120) out.add(Campione(punti[j].t, metri / dt));
    i = j;
  }
  return out;
}

double media(List<Campione> s) =>
    s.isEmpty ? 0 : s.fold(0.0, (t, c) => t + c.v) / s.length;

double massimo(List<Campione> s) =>
    s.isEmpty ? 0 : s.map((c) => c.v).reduce(math.max);

/// Passo in secondi al km da una velocità in m/s (0 se fermo).
double passoDa(double ms) => ms < 0.5 ? 0 : 1000 / ms;

/// "5:42" da secondi.
String fmtMinSec(double secondi) {
  final s = secondi.round();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}
