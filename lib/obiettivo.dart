import 'dart:math' as math;

import 'models.dart';
import 'l10n/lingua.dart';

/// Gare che si possono scegliere come obiettivo, per sport: chiave -> nome.
Map<String, Map<String, String>> get gare => <String, Map<String, String>>{
  'Corsa': {
    '5k': l10n.n5Km,
    '10k': l10n.n10Km,
    'mezza': l10n.mezzaMaratona,
    'maratona': l10n.maratona,
  },
  'Nuoto': {'750m': '750 m', '1500m': '1500 m', '3800m': '3,8 km'},
  'Bici': {'mediofondo': l10n.mediofondo, 'granfondo': l10n.granfondo},
  'Triathlon': {
    'sprint': l10n.triathlonSprint,
    'olimpico': l10n.triathlonOlimpico,
    '703': l10n.triathlon703,
    'ironman': 'Ironman',
  },
};

/// Fase della preparazione, in base alle settimane che mancano alla gara.
enum Fase { base, sviluppo, rifinitura, scarico, gara, libera }

Map<Fase, String> get nomiFasi => {
  Fase.base: l10n.base,
  Fase.sviluppo: l10n.sviluppo,
  Fase.rifinitura: l10n.rifinitura,
  Fase.scarico: l10n.scaricoPreGara,
  Fase.gara: l10n.settimanaGara,
  Fase.libera: l10n.senzaObiettivo,
};

Map<Fase, String> get spiegazioniFasi => {
  Fase.base: l10n.volumeCrescePianoQuasi,
  Fase.sviluppo: l10n.siAggiungonoSeduteQualita,
  Fase.rifinitura: l10n.lavoriAlRitmoGara,
  Fase.scarico: l10n.menoVolumePoIntensita,
  Fase.gara: l10n.pocheSeduteCorteSi,
  Fase.libera: l10n.pianoMantenimentoImpostaGara,
};

/// Una gara con una data: guida la progressione di tutti i piani.
class Obiettivo {
  final String sport; // Corsa, Nuoto, Bici, Triathlon
  final String gara; // chiave in [gare]
  final DateTime data;
  final int tempoMin; // tempo obiettivo in minuti, 0 = nessuno
  const Obiettivo({
    required this.sport,
    required this.gara,
    required this.data,
    this.tempoMin = 0,
  });

  String get nome => gare[sport]?[gara] ?? gara;

  int settimaneMancanti(DateTime oggi) =>
      (soloData(data).difference(soloData(oggi)).inDays / 7).ceil();

  /// Sport che la preparazione allena (il triathlon li allena tutti e tre).
  Set<String> get sportAllenati =>
      sport == 'Triathlon' ? {'Corsa', 'Nuoto', 'Bici'} : {sport};

  Fase fase(DateTime oggi) {
    final s = settimaneMancanti(oggi);
    if (s < 0) return Fase.libera;
    if (s <= 1) return Fase.gara;
    // Scarico più lungo per le gare lunghe.
    final scarico = {'maratona', 'ironman', '703', 'granfondo'}.contains(gara)
        ? 3
        : 2;
    if (s <= scarico) return Fase.scarico;
    if (s <= scarico + 4) return Fase.rifinitura;
    if (s <= scarico + 12) return Fase.sviluppo;
    return Fase.base;
  }
}

/// Fase per un giorno qualsiasi (anche futuro), con o senza obiettivo.
Fase faseDel(Obiettivo? o, DateTime giorno) => o?.fase(giorno) ?? Fase.libera;

/// Le cinque zone di frequenza cardiaca: (nome, da bpm, a bpm).
class Zone {
  final int fcMax;
  final int fcRiposo; // 0 = sconosciuta
  final bool fcMaxStimata;
  const Zone({
    required this.fcMax,
    this.fcRiposo = 0,
    this.fcMaxStimata = true,
  });

  static const _quote = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
  static List<String> get nomi => [
    'Recupero',
    l10n.aerobica,
    l10n.medio,
    'Soglia',
    l10n.massimale,
  ];

  /// Karvonen (riserva cardiaca) se si conosce la FC a riposo, altrimenti
  /// percentuale della FC massima.
  int _bpm(double q) => fcRiposo > 0
      ? (fcRiposo + q * (fcMax - fcRiposo)).round()
      : (q * fcMax).round();

  /// Zona [n] da 1 a 5: (da, a) in bpm.
  (int, int) zona(int n) => (_bpm(_quote[n - 1]), _bpm(_quote[n]) - 1);

  String testo(int n) {
    final (da, a) = zona(n);
    return l10n.zBpm(n, da, a);
  }

  /// In quale zona cade una frequenza cardiaca (0 se sotto la Z1).
  int zonaDi(int fc) {
    for (var n = 5; n >= 1; n--) {
      if (fc >= zona(n).$1) return n;
    }
    return 0;
  }
}

/// FC massima: la più alta registrata nell'ultimo anno (se credibile), altrimenti
/// stimata dall'età (Tanaka: 208 - 0,7 × età), altrimenti 190.
(int, bool) stimaFcMax(List<Sessione> sessioni, int? eta, DateTime oggi) {
  final daUnAnno = oggi.subtract(const Duration(days: 365));
  final osservata = sessioni
      .where((s) => s.data.isAfter(daUnAnno))
      .fold(0, (m, s) => math.max(m, math.max(s.fcMax, s.fcMedia)));
  if (osservata >= 150) return (osservata, true);
  if (eta != null && eta > 10) return ((208 - 0.7 * eta).round(), true);
  return (190, true);
}

/// Passo critico del nuoto (secondi per 100 m): il passo medio migliore delle
/// sessioni in piscina di almeno 400 m negli ultimi sei mesi. Null se mancano.
int? stimaPassoCritico(List<Sessione> sessioni, DateTime oggi) {
  final daSeiMesi = oggi.subtract(const Duration(days: 183));
  final passi = [
    for (final s in sessioni)
      if (stessoSport(s.sport, 'Nuoto') &&
          s.data.isAfter(daSeiMesi) &&
          s.distanzaKm >= 0.4 &&
          s.durataMin > 0)
        s.durataMin * 60 / (s.distanzaKm * 10),
  ];
  if (passi.isEmpty) return null;
  return passi.reduce(math.min).round();
}

String fmtPasso100(int secondi) =>
    '${secondi ~/ 60}:${two(secondi % 60)}/100 m';

/// "zona 2" in un testo diventa "zona 2 (125-137 bpm)".
String conBpm(String testo, Zone z) => testo.replaceAllMapped(
  RegExp(r'zona ([1-5])(?! \()', caseSensitive: false),
  (m) {
    final (da, a) = z.zona(int.parse(m[1]!));
    return l10n.bpm(m[0]!, da, a);
  },
);
