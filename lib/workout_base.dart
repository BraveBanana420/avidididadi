import 'models.dart';

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
    'Corsa facile',
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
    'Corsa veloce',
    serie: '6',
    durataMin: '2',
    intensita: 'FC 160-172 bpm',
    note: 'Alterna con il recupero, 6 volte',
  ),
  _step(
    'fartlek_fc',
    'Corsa',
    'Fartlek FC',
    44,
    3,
    'principale',
    'Recupero corricchiando',
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
    'Corsa facile',
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
    'Corsa facile',
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
    'Corsa a ritmo sostenuto',
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
    'Corsa facile',
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
    'Corsa lenta continua',
    intensita: 'zona 2',
    note: 'Resta in zona 2 per tutta la durata',
  ),

  // Piscina Base: 1150 m in vasca da 25 m.
  _step(
    'piscina_base',
    'Nuoto',
    'Piscina Base (1150 m, vasca 25 m)',
    0,
    1,
    'riscaldamento',
    'Stile a scelta',
    distanzaM: '150',
    recuperoS: '30',
  ),
  _step(
    'piscina_base',
    'Nuoto',
    'Piscina Base (1150 m, vasca 25 m)',
    0,
    2,
    'principale',
    'Stile libero, gambe con tavoletta',
    serie: '2',
    distanzaM: '50',
    recuperoS: '30',
    note: 'Tavoletta front',
  ),
  _step(
    'piscina_base',
    'Nuoto',
    'Piscina Base (1150 m, vasca 25 m)',
    0,
    3,
    'principale',
    'Dorso, gambe con tavoletta',
    serie: '2',
    distanzaM: '50',
    recuperoS: '30',
    note: 'Tavoletta dorso',
  ),
  _step(
    'piscina_base',
    'Nuoto',
    'Piscina Base (1150 m, vasca 25 m)',
    0,
    4,
    'principale',
    'Stile libero, braccia con pull buoy',
    serie: '2',
    distanzaM: '100',
    recuperoS: '30',
    note: '25 m solo braccio DX, 25 m solo braccio SX, 50 m alternato',
  ),
  _step(
    'piscina_base',
    'Nuoto',
    'Piscina Base (1150 m, vasca 25 m)',
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
    'Piscina Base (1150 m, vasca 25 m)',
    0,
    6,
    'finale',
    'Dorso doppio, gambe rana',
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
