import 'models.dart';

// Calorie stimate per le sessioni registrate dall'app (quelle dell'orologio
// hanno le loro). Dal dato più preciso a quello più grezzo:
// 1. potenza (bici): il lavoro in kJ vale circa le kcal spese, perché il
//    corpo rende circa il 24% e 1 kcal = 4,184 kJ;
// 2. battito medio con età, sesso e peso (Keytel et al., 2005);
// 3. sport, velocità e peso (MET, con le formule ACSM per corsa e cammino).
// "Attive" sono quelle in più rispetto a stare fermi (1 MET).

typedef Calorie = ({double attive, double totali});

/// MET dello sport, alla velocità media se si sa ([kmh] 0 = non si sa).
double metDi(String sport, double kmh) {
  final mMin = kmh * 1000 / 60;
  if (stessoSport(sport, 'Corsa')) {
    return kmh > 0 ? (3.5 + 0.2 * mMin) / 3.5 : 9;
  }
  if (stessoSport(sport, 'Camminata')) {
    return kmh > 0 ? (3.5 + 0.1 * mMin) / 3.5 : 3.5;
  }
  if (stessoSport(sport, 'Bici')) {
    if (kmh <= 0) return 7;
    if (kmh < 16) return 4;
    if (kmh < 19) return 6;
    if (kmh < 22) return 8;
    if (kmh < 25) return 10;
    return 12;
  }
  if (stessoSport(sport, 'Nuoto')) return 7;
  if (stessoSport(sport, 'Forza')) return 5;
  if (stessoSport(sport, 'Mobilità')) return 2.5;
  return 4;
}

/// Kcal al minuto dal battito medio (Keytel 2005). Null senza i dati.
double? kcalMinutoDaBattito({
  required int fcMedia,
  required double pesoKg,
  required int eta,
  required String sesso,
}) {
  final v = switch (sesso) {
    'Uomo' => -55.0969 + 0.6309 * fcMedia + 0.1988 * pesoKg + 0.2017 * eta,
    'Donna' => -20.4022 + 0.4472 * fcMedia - 0.1263 * pesoKg + 0.074 * eta,
    _ => null,
  };
  return v == null ? null : v / 4.184;
}

/// Le calorie della seduta; null se non basta quello che si sa (manca il
/// peso e non c'è la potenza).
Calorie? stimaCalorie({
  required String sport,
  required Duration tempo,
  double km = 0,
  int potenzaMedia = 0,
  int fcMedia = 0,
  double? pesoKg,
  int? eta,
  String sesso = '',
}) {
  final ore = tempo.inSeconds / 3600;
  if (ore <= 0) return null;
  final riposo = pesoKg == null ? 0.0 : pesoKg * ore;
  Calorie da(double totali) => (
    attive: (totali - riposo).clamp(0, double.infinity).toDouble(),
    totali: totali,
  );

  if (potenzaMedia > 0) {
    final kj = potenzaMedia * tempo.inSeconds / 1000;
    return (attive: kj, totali: kj + riposo);
  }
  if (pesoKg == null) return null;
  // La formula viene da battiti da sforzo: sotto i 100 sovrastima molto.
  if (fcMedia >= 100 && eta != null) {
    final alMinuto = kcalMinutoDaBattito(
      fcMedia: fcMedia,
      pesoKg: pesoKg,
      eta: eta,
      sesso: sesso,
    );
    if (alMinuto != null && alMinuto * 60 * ore > riposo) {
      return da(alMinuto * 60 * ore);
    }
  }
  final kmh = km > 0 ? km / ore : 0.0;
  return da(metDi(sport, kmh) * pesoKg * ore);
}
