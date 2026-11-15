import 'lingua.dart';

/// Nomi che l'app salva in italiano nei CSV (sport, fasce, tipi di seduta,
/// stili, categorie): restano così nei file, perché il codice li confronta
/// e li rilegge, e si traducono solo quando si mostrano.
const _inglese = {
  'Corsa': 'Running',
  'Nuoto': 'Swimming',
  'Bici': 'Cycling',
  'Forza': 'Strength',
  'Mobilità': 'Mobility',
  'Arrampicata': 'Climbing',
  'Camminata': 'Walking',
  'Riposo': 'Rest',
  'Attività libera': 'Free activity',
  'Altra attività': 'Other activity',
  'Altro': 'Other',
  'Mattina': 'Morning',
  'Pranzo': 'Lunch',
  'Pomeriggio': 'Afternoon',
  'Sera': 'Evening',
  'Uomo': 'Male',
  'Donna': 'Female',
  // Tipi di seduta.
  'Lento': 'Easy',
  'Lungo': 'Long run',
  'Fartlek': 'Fartlek',
  'Tempo run': 'Tempo run',
  'Ripetute': 'Intervals',
  'Ritmo gara': 'Race pace',
  'Allunghi': 'Strides',
  'Tecnica': 'Technique',
  'Soglia': 'Threshold',
  'Uscita': 'Ride',
  'Uscita lunga': 'Long ride',
  'Intervalli': 'Intervals',
  'Recupero': 'Recovery',
  'Test FTP': 'FTP test',
  'Test FTP di corsa': 'Running FTP test',
  'Corpo intero': 'Full body',
  'Corpo intero A': 'Full body A',
  'Corpo intero B': 'Full body B',
  'Corpo intero C': 'Full body C',
  'Parte alta': 'Upper body',
  'Parte bassa': 'Lower body',
  'Forza libera': 'Free strength',
  'Corsa libera': 'Free run',
  'Uscita libera': 'Free ride',
  'Uscita in bici': 'Bike ride',
  'Nuoto libero': 'Free swim',
  'Mobilità libera': 'Free mobility',
  'Mobilità e stretching': 'Mobility and stretching',
  'Anche e gambe': 'Hips and legs',
  'Schiena': 'Back',
  'Spalle e petto': 'Shoulders and chest',
  'Allenamento': 'Workout',
  'Tapis roulant': 'Treadmill',
  'Rulli': 'Trainer',
  'Cyclette': 'Stationary bike',
  'Piscina': 'Pool',
  'Acque libere': 'Open water',
  'Escursione': 'Hiking',
  'Pesi': 'Weights',
  'Corpo libero': 'Bodyweight',
  'Snowboard': 'Snowboard',
  'Football': 'American football',
  'Manuale': 'Manual',
  // Nuoto.
  'Stile libero': 'Freestyle',
  'Dorso': 'Backstroke',
  'Rana': 'Breaststroke',
  'Delfino': 'Butterfly',
  'Misti': 'Medley',
  // Arrampicata.
  'Vie': 'Routes',
  'Boulder': 'Boulder',
  'Indoor': 'Indoor',
  'Outdoor': 'Outdoor',
  'A vista': 'Onsight',
  'Flash': 'Flash',
  'Lavorata': 'Redpoint',
  'Da primo': 'Lead',
  'Da secondo': 'Top rope',
  'Capacità aerobica': 'Aerobic capacity',
  'Potenza aerobica': 'Aerobic power',
  'Resistenza anaerobica': 'Anaerobic endurance',
  'Forza delle dita': 'Finger strength',
  'Forza massima': 'Max strength',
  'Potenza': 'Power',
  'Riscaldamento': 'Warm-up',
  'Principale': 'Main set',
  'Defaticamento': 'Cool-down',
};

/// Parole dentro le intensità ("zona 2", "passo 5:00/km", "FC 120-140
/// bpm") e nei testi corti salvati dai generatori.
final _parole = [
  (RegExp(r'\bzona\b'), 'zone'),
  (RegExp(r'\bZona\b'), 'Zone'),
  (RegExp(r'\bpasso\b'), 'pace'),
  (RegExp(r'\bPasso\b'), 'Pace'),
  (RegExp(r'\bFC\b'), 'HR'),
  (RegExp(r'\bfino a\b'), 'up to'),
  (RegExp(r'\bper lato\b'), 'per side'),
  (RegExp(r'\bripetizioni\b'), 'reps'),
  (RegExp(r'\brip\b'), 'reps'),
  (RegExp(r'\bserie\b'), 'sets'),
  (RegExp(r'\brecupero\b'), 'rest'),
  (RegExp(r'\bintensità\b'), 'intensity'),
  (RegExp(r'\bpoi\b'), 'then'),
  (RegExp(r'\bfacile\b'), 'easy'),
  (RegExp(r'\bmedio\b'), 'moderate'),
  (RegExp(r'\bsostenuto\b'), 'sustained'),
  (RegExp(r'\bcostante\b'), 'steady'),
  (RegExp(r'\brespirazione regolare\b'), 'regular breathing'),
  (RegExp(r'\bdi fatica\b'), 'effort'),
  (RegExp(r'\blenti\b'), 'slow'),
];

/// Il nome salvato in italiano, mostrato nella lingua in uso.
String mostra(String s) {
  if (!inInglese || s.isEmpty) return s;
  final esatto = _inglese[s] ?? _inglese[s.trim()];
  if (esatto != null) return esatto;
  final maiuscolo = s[0].toUpperCase() + s.substring(1);
  final m = _inglese[maiuscolo];
  if (m != null) return s[0] == maiuscolo[0] ? m : m.toLowerCase();
  return mostraTesto(s);
}

/// Un testo corto salvato dai generatori (intensità, ripetizioni, riepilogo
/// di un passo), con le parole note tradotte. In italiano resta com'è.
String mostraTesto(String s) {
  if (!inInglese || s.isEmpty) return s;
  var t = s;
  for (final (rx, en) in _parole) {
    t = t.replaceAll(rx, en);
  }
  return t;
}
