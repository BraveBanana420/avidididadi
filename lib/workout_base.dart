import 'models.dart';
import 'l10n/lingua.dart';

/// Workout fissi (da Garmin Connect) e regole per assegnarli alle sessioni.

WorkoutStep _step(
  String id,
  String sport,
  String nome,
  int tot,
  int ordine,
  String fase,
  String descrizione, {
  String serie = '',
  String distanzaM = '',
  String durataMin = '',
  String intensita = '',
  String recuperoS = '',
  String note = '',
}) => WorkoutStep(
  id: id,
  sport: sport,
  nome: nome,
  durataTot: tot,
  ordine: ordine,
  fase: fase,
  descrizione: descrizione,
  serie: serie,
  ripetizioni: '',
  distanzaM: distanzaM,
  durataMin: durataMin,
  intensita: intensita,
  recuperoS: recuperoS,
  note: note,
);

final List<WorkoutStep> workoutBase = [
  // Fartlek FC: 44 min, circa 6,4 km.
  _step(
    'fartlek_fc',
    'Corsa',
    'Fartlek FC',
    44,
    1,
    'riscaldamento',
    l10n.corsaFacile,
    durataMin: '10',
    intensita: 'FC 120-140 bpm',
  ),
  _step(
    'fartlek_fc',
    'Corsa',
    'Fartlek FC',
    44,
    2,
    'principale',
    l10n.corsaVeloce,
    serie: '6',
    durataMin: '2',
    intensita: 'FC 160-172 bpm',
    note: l10n.alternaRecupero6Volte,
  ),
  _step(
    'fartlek_fc',
    'Corsa',
    'Fartlek FC',
    44,
    3,
    'principale',
    l10n.recuperoCorricchiando,
    serie: '6',
    durataMin: '2',
    intensita: 'FC 120-145 bpm',
  ),
  _step(
    'fartlek_fc',
    'Corsa',
    'Fartlek FC',
    44,
    4,
    'defaticamento',
    l10n.corsaFacile,
    durataMin: '10',
    intensita: 'FC 120-140 bpm',
  ),

  // Tempo Run FC: 42 min, circa 5,5 km.
  _step(
    'tempo_run_fc',
    'Corsa',
    'Tempo Run FC',
    42,
    1,
    'riscaldamento',
    l10n.corsaFacile,
    durataMin: '10',
    intensita: 'FC fino a 140 bpm',
  ),
  _step(
    'tempo_run_fc',
    'Corsa',
    'Tempo Run FC',
    42,
    2,
    'principale',
    l10n.corsaRitmoSostenuto,
    durataMin: '22',
    intensita: 'FC 150-160 bpm',
  ),
  _step(
    'tempo_run_fc',
    'Corsa',
    'Tempo Run FC',
    42,
    3,
    'defaticamento',
    l10n.corsaFacile,
    durataMin: '10',
    intensita: 'FC fino a 140 bpm',
  ),

  // Lungo del sabato: tutto in zona 2.
  _step(
    'lungo',
    'Corsa',
    'Lungo',
    0,
    1,
    'principale',
    l10n.corsaLentaContinua,
    intensita: 'zona 2',
    note: l10n.restaZona2Tutta,
  ),

  // Piscina Base: 1150 m in vasca da 25 m.
  _step(
    'piscina_base',
    'Nuoto',
    l10n.piscinaBase1150M,
    0,
    1,
    'riscaldamento',
    l10n.stileScelta,
    distanzaM: '150',
    recuperoS: '30',
  ),
  _step(
    'piscina_base',
    'Nuoto',
    l10n.piscinaBase1150M,
    0,
    2,
    'principale',
    l10n.stileLiberoGambeTavoletta,
    serie: '2',
    distanzaM: '50',
    recuperoS: '30',
    note: l10n.tavolettaFront,
  ),
  _step(
    'piscina_base',
    'Nuoto',
    l10n.piscinaBase1150M,
    0,
    3,
    'principale',
    l10n.dorsoGambeTavoletta,
    serie: '2',
    distanzaM: '50',
    recuperoS: '30',
    note: l10n.tavolettaDorso,
  ),
  _step(
    'piscina_base',
    'Nuoto',
    l10n.piscinaBase1150M,
    0,
    4,
    'principale',
    l10n.stileLiberoBracciaPull,
    serie: '2',
    distanzaM: '100',
    recuperoS: '30',
    note: l10n.n25MSoloBraccio,
  ),
  _step(
    'piscina_base',
    'Nuoto',
    l10n.piscinaBase1150M,
    0,
    5,
    'principale',
    'Stile libero',
    serie: '8',
    distanzaM: '50',
    intensita: 'passo 2:50/100 m',
    recuperoS: '10',
  ),
  _step(
    'piscina_base',
    'Nuoto',
    l10n.piscinaBase1150M,
    0,
    6,
    'finale',
    l10n.dorsoDoppioGambeRana,
    distanzaM: '200',
  ),
];

/// Settimana di riferimento: il giovedì 15/10/2026 era Fartlek.
final _lunediFartlek = DateTime(2026, 10, 12);

/// Tipo di sessione previsto: giovedì Fartlek e Tempo run alternati, sabato Lungo.
String tipoPredefinito(DateTime d, String sport) {
  if (!stessoSport(sport, 'Corsa')) return '';
  if (d.weekday == DateTime.saturday) return 'Lungo';
  if (d.weekday == DateTime.thursday) {
    final lunedi = DateTime(d.year, d.month, d.day - (d.weekday - 1));
    final settimane = (lunedi.difference(_lunediFartlek).inHours / 168).round();
    return settimane.isEven ? 'Fartlek' : 'Tempo run';
  }
  return '';
}

/// Workout fisso da mostrare per una sessione, se ce n'è uno.
String? workoutPredefinito(DateTime d, String sport, String tipo) {
  final t = (tipo.isEmpty ? tipoPredefinito(d, sport) : tipo).toLowerCase();
  if (stessoSport(sport, 'Nuoto')) {
    return t.isEmpty || t == 'piscina' ? 'piscina_base' : null;
  }
  if (!stessoSport(sport, 'Corsa')) return null;
  return switch (t) {
    'fartlek' => 'fartlek_fc',
    'tempo run' => 'tempo_run_fc',
    'lungo' => 'lungo',
    _ => null,
  };
}
