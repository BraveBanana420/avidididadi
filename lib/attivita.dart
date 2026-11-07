import 'generator.dart';
import 'models.dart';

// Le attività di chi usa l'app: quelle scelte si vedono nei menu e nel piano.
// Quello che è stato fatto davvero resta sempre nello storico, anche se è di
// uno sport non scelto o che l'app non conosce (attività libera).

/// Gli sport tra cui scegliere, in ordine.
const attivitaDaScegliere = [
  'Forza',
  'Corsa',
  'Nuoto',
  'Bici',
  'Mobilità',
  'Arrampicata',
];

/// Quello che arriva dall'orologio e non è uno sport noto, o che si scrive a
/// mano: conta nello storico e ha i suoi grafici.
const sportAttivitaLibera = 'Attività libera';

/// Le attività di chi aveva già l'app quando non si sceglievano: quelle che
/// compaiono nei suoi dati, così non gli sparisce niente.
Set<String> attivitaDaiDati({
  required List<Slot> settimana,
  required List<PianoRiga> piano,
  required List<Sessione> sessioni,
  required Set<String> generati,
  required bool forza,
  required bool arrampicata,
}) {
  final trovate = {
    for (final s in settimana) normSport(s.sport),
    for (final r in piano) normSport(r.sport),
    for (final s in sessioni) normSport(s.sport),
    ...generati,
    if (forza) 'Forza',
    if (arrampicata) 'Arrampicata',
  };
  return {
    for (final a in attivitaDaScegliere)
      if (trovate.contains(a)) a,
  };
}

/// Gli sport dei menu del piano: quelli scelti più il riposo. Nessuna scelta
/// fatta (configurazione saltata): tutti.
List<String> sportDeiMenu(Set<String> scelte) => [
  for (final s in sportList)
    if (scelte.isEmpty || s == 'Riposo' || scelte.contains(s)) s,
];

/// Il calendario senza le sedute degli sport tolti, da [da] in poi. Quelle già
/// passate e quelle fatte ([fatta]) restano.
List<PianoRiga> senzaSedute(
  List<PianoRiga> piano,
  Set<String> tolti,
  DateTime da,
  bool Function(PianoRiga) fatta,
) => [
  for (final r in piano)
    if (r.data.isBefore(da) || !tolti.contains(normSport(r.sport)) || fatta(r))
      r,
];

/// Il calendario con le sedute di [slot], da [da] a [fine] compresi. Un giorno
/// che ha già lo stesso sport non si tocca: niente doppioni.
List<PianoRiga> conSeduteNuove(
  List<PianoRiga> piano,
  List<Slot> slot,
  DateTime da,
  DateTime fine,
) {
  final mesi = (fine.year - da.year) * 12 + fine.month - da.month + 1;
  final nuove = [
    for (final r in generaPiano(slot, da, mesi))
      if (!r.data.isAfter(fine) &&
          !piano.any((p) => p.data == r.data && stessoSport(p.sport, r.sport)))
        r,
  ];
  return [...piano, ...nuove]..sort((a, b) {
    final c = a.data.compareTo(b.data);
    return c != 0
        ? c
        : fasce.indexOf(a.fascia).compareTo(fasce.indexOf(b.fascia));
  });
}

/// Il nome di un'attività, senza maiuscole né separatori: "Rock_Climbing",
/// "rockClimbing" e "ROCK CLIMBING" sono la stessa cosa.
String _chiave(String nome) =>
    nome.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

const _nomiLiberi = {
  'other': 'Allenamento',
  'otherworkout': 'Allenamento',
  'workout': 'Allenamento',
  'unknown': 'Allenamento',
  'elliptical': 'Ellittica',
  'rowing': 'Canottaggio',
  'rowingmachine': 'Vogatore',
  'stairstepper': 'Stepper',
  'stairclimbing': 'Scale',
  'stairclimbingmachine': 'Stepper',
  'alpineski': 'Sci',
  'skiing': 'Sci',
  'backcountryski': 'Scialpinismo',
  'nordicski': 'Sci di fondo',
  'snowboard': 'Snowboard',
  'snowboarding': 'Snowboard',
  'iceskate': 'Pattinaggio',
  'iceskating': 'Pattinaggio',
  'inlineskate': 'Pattinaggio',
  'skating': 'Pattinaggio',
  'kayaking': 'Kayak',
  'canoeing': 'Canoa',
  'sailing': 'Vela',
  'surfing': 'Surf',
  'standuppaddling': 'SUP',
  'soccer': 'Calcio',
  'footballamerican': 'Football',
  'football': 'Calcio',
  'basketball': 'Basket',
  'volleyball': 'Pallavolo',
  'tabletennis': 'Ping pong',
  'dancing': 'Danza',
  'dance': 'Danza',
  'martialarts': 'Arti marziali',
  'boxing': 'Pugilato',
};

/// "StandUpPaddling" o "STAND_UP" diventano "Stand up paddling".
String _leggibile(String nome) {
  final t = nome
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .trim()
      .toLowerCase();
  return maiuscola(t);
}

/// Da un nome qualsiasi di un'attività a (sport, tipo) dell'app, in qualunque
/// lingua di orologio l'abbiamo vista scritta. Quello che non è uno sport noto
/// diventa un'attività libera col suo nome. Null solo se il nome è vuoto.
(String, String)? attivitaDaNome(String nome) {
  final k = _chiave(nome);
  if (k.isEmpty) return null;
  return switch (k) {
    'run' || 'running' || 'trailrun' || 'trailrunning' => ('Corsa', 'Corsa'),
    'treadmill' || 'runningtreadmill' => ('Corsa', 'Tapis roulant'),
    'ride' || 'cycling' || 'biking' || 'bike' => ('Bici', 'Uscita'),
    'swim' || 'swimming' => ('Nuoto', ''),
    'walk' || 'walking' || 'speedwalking' => ('Camminata', 'Camminata'),
    'hike' ||
    'hiking' ||
    'snowshoe' ||
    'snowshoeing' => ('Camminata', 'Escursione'),
    'rockclimbing' ||
    'rockclimb' ||
    'climbing' ||
    'climb' ||
    'indoorclimbing' ||
    'bouldering' => ('Arrampicata', 'Arrampicata'),
    'weighttraining' ||
    'strengthtraining' ||
    'weightlifting' => ('Forza', 'Pesi'),
    'highintensityintervaltraining' || 'hiit' => ('Forza', 'HIIT'),
    'crossfit' => ('Forza', 'CrossFit'),
    'calisthenics' => ('Forza', 'Corpo libero'),
    'yoga' => ('Mobilità', 'Yoga'),
    'pilates' => ('Mobilità', 'Pilates'),
    'stretching' || 'flexibility' => ('Mobilità', 'Stretching'),
    _ => (sportAttivitaLibera, _nomiLiberi[k] ?? _leggibile(nome)),
  };
}
