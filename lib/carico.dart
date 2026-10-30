import 'models.dart';
import 'obiettivo.dart';

/// Carico di allenamento unico per tutti gli sport (metodo sRPE):
/// carico = durata in minuti × fatica da 1 a 10.

/// FC a riposo usata se non è nota, per stimare la riserva cardiaca.
const _riposoTipico = 60;

/// Fatica di una sessione da 1 a 10: dal feedback se c'è, altrimenti dalla FC
/// media rispetto alla riserva cardiaca, altrimenti dal tipo di seduta.
double faticaStimata(Sessione s, Zone z, {int? rpe}) {
  if (rpe != null && rpe > 0) return rpe.toDouble();
  if (s.rpe > 0) return s.rpe;
  if (s.fcMedia > 0 && z.fcMax > 0) {
    final riposo = z.fcRiposo > 0 ? z.fcRiposo : _riposoTipico;
    if (z.fcMax > riposo) {
      final riserva = (s.fcMedia - riposo) / (z.fcMax - riposo);
      // 30% della riserva = fatica 1, poi un punto ogni 7%: Z2 ≈ 5-6, soglia ≈ 8.
      return ((riserva - 0.3) / 0.07 + 1).clamp(1, 10).toDouble();
    }
  }
  if (stessoSport(s.sport, 'Camminata')) return 3;
  final t = s.tipo.toLowerCase();
  if (t.contains('ripetute') || t.contains('hiit')) return 8;
  if (t.contains('fartlek') || t.contains('tempo')) return 7;
  if (t.contains('lento') || t.contains('lungo') || t.contains('recupero')) {
    return 4;
  }
  return 5;
}

double carico(Sessione s, Zone z, {int? rpe}) =>
    s.durataMin * faticaStimata(s, z, rpe: rpe);

DateTime lunediDi(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));

/// Carico per giorno, sommando le sessioni.
Map<DateTime, double> caricoPerGiorno(
  List<Sessione> sessioni,
  Zone z, {
  int? Function(Sessione)? rpeDi,
}) {
  final out = <DateTime, double>{};
  for (final s in sessioni) {
    final d = soloData(s.data);
    out[d] = (out[d] ?? 0) + carico(s, z, rpe: rpeDi?.call(s));
  }
  return out;
}

/// Rapporto tra il carico degli ultimi 7 giorni e la media settimanale degli
/// ultimi 28 (acuto / cronico). Null se lo storico è troppo corto.
double? rapportoAcutoCronico(Map<DateTime, double> perGiorno, DateTime oggi) {
  final fine = soloData(oggi).add(const Duration(days: 1));
  double somma(int giorni) => perGiorno.entries
      .where(
        (e) =>
            e.key.isBefore(fine) &&
            !e.key.isBefore(fine.subtract(Duration(days: giorni))),
      )
      .fold(0.0, (t, e) => t + e.value);
  // Servono almeno tre settimane di dati per un cronico sensato.
  final primo = perGiorno.keys.fold<DateTime?>(
    null,
    (a, b) => a == null || b.isBefore(a) ? b : a,
  );
  if (primo == null || fine.difference(primo).inDays < 21) return null;
  final cronico = somma(28) / 4;
  if (cronico <= 0) return null;
  return somma(7) / cronico;
}

enum StatoCarico { inCalo, equilibrato, attenzione, rischio }

StatoCarico statoCarico(double rapporto) => rapporto < 0.8
    ? StatoCarico.inCalo
    : rapporto <= 1.3
    ? StatoCarico.equilibrato
    : rapporto <= 1.5
    ? StatoCarico.attenzione
    : StatoCarico.rischio;

const descrizioniCarico = {
  StatoCarico.inCalo: 'In calo: stai facendo meno del solito.',
  StatoCarico.equilibrato: 'Equilibrato: aumento sostenibile.',
  StatoCarico.attenzione: 'Attenzione: stai aumentando in fretta.',
  StatoCarico.rischio: 'Rischio: troppo carico rispetto alle ultime settimane.',
};

/// Confronto tra quello che era in programma e quello che è stato fatto.
class Confronto {
  final List<PianoRiga> fatte; // previste e svolte
  final List<PianoRiga> saltate; // previste, giorno passato, non svolte
  final List<PianoRiga> daFare; // previste, da oggi in poi
  final List<Sessione> extra; // svolte senza nulla in programma
  final int minutiPrevisti;
  final int minutiFatti;
  const Confronto(
    this.fatte,
    this.saltate,
    this.daFare,
    this.extra,
    this.minutiPrevisti,
    this.minutiFatti,
  );

  int get previste => fatte.length + saltate.length + daFare.length;
}

/// Confronto della settimana che inizia il lunedì [lunedi].
Confronto confrontaSettimana(
  List<PianoRiga> piano,
  List<Sessione> sessioni,
  DateTime lunedi,
  DateTime oggi,
) {
  final fine = lunedi.add(const Duration(days: 7));
  bool dentro(DateTime d) => !d.isBefore(lunedi) && d.isBefore(fine);
  final previste = piano
      .where((r) => dentro(r.data) && !stessoSport(r.sport, 'Riposo'))
      .toList();
  final svolte = sessioni.where((s) => dentro(s.data)).toList();
  final usate = <Sessione>{};
  final fatte = <PianoRiga>[], saltate = <PianoRiga>[], daFare = <PianoRiga>[];
  for (final r in previste) {
    final s = svolte.where(
      (s) =>
          !usate.contains(s) &&
          soloData(s.data) == r.data &&
          stessoSport(s.sport, r.sport),
    );
    if (s.isNotEmpty) {
      usate.add(s.first);
      fatte.add(r);
    } else if (r.data.isBefore(soloData(oggi))) {
      saltate.add(r);
    } else {
      daFare.add(r);
    }
  }
  return Confronto(
    fatte,
    saltate,
    daFare,
    svolte.where((s) => !usate.contains(s)).toList(),
    previste.fold(0, (t, r) => t + r.durataMin),
    svolte.fold(0, (t, s) => t + s.durataMin),
  );
}
