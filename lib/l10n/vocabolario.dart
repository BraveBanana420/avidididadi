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

/// Gli stessi nomi in greco. Nomi d'uso comune tra chi si allena in Grecia
/// (Fartlek, Tempo run, Boulder, Lead) restano come sono.
const _greco = {
  'Corsa': 'Τρέξιμο',
  'Nuoto': 'Κολύμβηση',
  'Bici': 'Ποδήλατο',
  'Forza': 'Δύναμη',
  'Mobilità': 'Κινητικότητα',
  'Arrampicata': 'Αναρρίχηση',
  'Camminata': 'Περπάτημα',
  'Riposo': 'Ξεκούραση',
  'Attività libera': 'Ελεύθερη δραστηριότητα',
  'Altra attività': 'Άλλη δραστηριότητα',
  'Altro': 'Άλλο',
  'Mattina': 'Πρωί',
  'Pranzo': 'Μεσημέρι',
  'Pomeriggio': 'Απόγευμα',
  'Sera': 'Βράδυ',
  'Uomo': 'Άνδρας',
  'Donna': 'Γυναίκα',
  // Tipi di seduta.
  'Lento': 'Χαλαρό',
  'Lungo': 'Μεγάλη απόσταση',
  'Fartlek': 'Fartlek',
  'Tempo run': 'Tempo run',
  'Ripetute': 'Διαλειμματικά',
  'Ritmo gara': 'Ρυθμός αγώνα',
  'Allunghi': 'Επιταχύνσεις',
  'Tecnica': 'Τεχνική',
  'Soglia': 'Κατώφλι',
  'Uscita': 'Διαδρομή',
  'Uscita lunga': 'Μεγάλη διαδρομή',
  'Intervalli': 'Διαλειμματικά',
  'Recupero': 'Αποκατάσταση',
  'Test FTP': 'Τεστ FTP',
  'Test FTP di corsa': 'Τεστ FTP τρεξίματος',
  'Corpo intero': 'Όλο το σώμα',
  'Corpo intero A': 'Όλο το σώμα A',
  'Corpo intero B': 'Όλο το σώμα B',
  'Corpo intero C': 'Όλο το σώμα C',
  'Parte alta': 'Πάνω μέρος',
  'Parte bassa': 'Κάτω μέρος',
  'Forza libera': 'Ελεύθερη δύναμη',
  'Corsa libera': 'Ελεύθερο τρέξιμο',
  'Uscita libera': 'Ελεύθερη διαδρομή',
  'Uscita in bici': 'Βόλτα με ποδήλατο',
  'Nuoto libero': 'Ελεύθερη κολύμβηση',
  'Mobilità libera': 'Ελεύθερη κινητικότητα',
  'Mobilità e stretching': 'Κινητικότητα και διατάσεις',
  'Anche e gambe': 'Ισχία και πόδια',
  'Schiena': 'Πλάτη',
  'Spalle e petto': 'Ώμοι και στήθος',
  'Allenamento': 'Προπόνηση',
  'Tapis roulant': 'Διάδρομος',
  'Rulli': 'Προπονητήριο',
  'Cyclette': 'Στατικό ποδήλατο',
  'Piscina': 'Πισίνα',
  'Acque libere': 'Ανοιχτά νερά',
  'Escursione': 'Πεζοπορία',
  'Pesi': 'Βάρη',
  'Corpo libero': 'Βάρος σώματος',
  'Snowboard': 'Snowboard',
  'Football': 'Αμερικανικό ποδόσφαιρο',
  'Manuale': 'Χειροκίνητα',
  // Nuoto.
  'Stile libero': 'Ελεύθερο',
  'Dorso': 'Ύπτιο',
  'Rana': 'Πρόσθιο',
  'Delfino': 'Πεταλούδα',
  'Misti': 'Μικτή',
  // Arrampicata.
  'Vie': 'Διαδρομές',
  'Boulder': 'Boulder',
  'Indoor': 'Εσωτερικός χώρος',
  'Outdoor': 'Εξωτερικός χώρος',
  'A vista': 'Onsight',
  'Flash': 'Flash',
  'Lavorata': 'Redpoint',
  'Da primo': 'Lead',
  'Da secondo': 'Top rope',
  'Capacità aerobica': 'Αερόβια ικανότητα',
  'Potenza aerobica': 'Αερόβια ισχύς',
  'Resistenza anaerobica': 'Αναερόβια αντοχή',
  'Forza delle dita': 'Δύναμη δαχτύλων',
  'Forza massima': 'Μέγιστη δύναμη',
  'Potenza': 'Ισχύς',
  'Riscaldamento': 'Ζέσταμα',
  'Principale': 'Κύριο μέρος',
  'Defaticamento': 'Αποθεραπεία',
};

/// I nomi tradotti, per lingua (in italiano restano come sono).
const _nomi = {'en': _inglese, 'el': _greco};

/// Parole dentro le intensità ("zona 2", "passo 5:00/km", "FC 120-140
/// bpm") e nei testi corti salvati dai generatori, per lingua.
final _parole = <String, List<(RegExp, String)>>{
  'en': [
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
  ],
  'el': [
    (RegExp(r'\bzona\b'), 'ζώνη'),
    (RegExp(r'\bZona\b'), 'Ζώνη'),
    (RegExp(r'\bpasso\b'), 'ρυθμός'),
    (RegExp(r'\bPasso\b'), 'Ρυθμός'),
    (RegExp(r'\bFC\b'), 'παλμοί'),
    (RegExp(r'\bbpm\b'), 'παλμοί το λεπτό'),
    (RegExp(r'\bfino a\b'), 'έως'),
    (RegExp(r'\bper lato\b'), 'ανά πλευρά'),
    (RegExp(r'\bripetizioni\b'), 'επαναλήψεις'),
    (RegExp(r'\brip\b'), 'επαναλήψεις'),
    (RegExp(r'\bserie\b'), 'σετ'),
    (RegExp(r'\brecupero\b'), 'αποκατάσταση'),
    (RegExp(r'\bintensità\b'), 'ένταση'),
    (RegExp(r'\bpoi\b'), 'μετά'),
    (RegExp(r'\bfacile\b'), 'εύκολα'),
    (RegExp(r'\bmedio\b'), 'μέτρια'),
    (RegExp(r'\bsostenuto\b'), 'έντονα'),
    (RegExp(r'\bcostante\b'), 'σταθερά'),
    (RegExp(r'\brespirazione regolare\b'), 'σταθερή αναπνοή'),
    (RegExp(r'\bdi fatica\b'), 'κόπωση'),
    (RegExp(r'\blenti\b'), 'αργές'),
  ],
};

/// Il nome salvato in italiano, mostrato nella lingua in uso.
String mostra(String s) => traduciNome(s, codiceLingua);

/// Come [mostra], per quello che dice la voce: con l'app in italiano e la
/// voce in greco, "Riscaldamento" si sente "Ζέσταμα".
String nomePerVoce(String s) => traduciNome(s, codiceVoce);

/// [s] (un nome salvato in italiano) in [lingua], se è tra quelli noti;
/// altrimenti con le parole note tradotte.
String traduciNome(String s, String lingua) {
  final nomi = _nomi[lingua];
  if (nomi == null || s.isEmpty) return s;
  final esatto = nomi[s] ?? nomi[s.trim()];
  if (esatto != null) return esatto;
  final maiuscolo = s[0].toUpperCase() + s.substring(1);
  final m = nomi[maiuscolo];
  if (m != null) return s[0] == maiuscolo[0] ? m : m.toLowerCase();
  return traduciTesto(s, lingua);
}

/// Un testo corto salvato dai generatori (intensità, ripetizioni, riepilogo
/// di un passo), con le parole note tradotte. In italiano resta com'è.
String mostraTesto(String s) => traduciTesto(s, codiceLingua);

/// Come [mostraTesto], per quello che dice la voce (nella sua lingua).
String testoPerVoce(String s) => traduciTesto(s, codiceVoce);

/// [s] (scritto in italiano nei dati) con le parole note in [lingua].
String traduciTesto(String s, String lingua) {
  final parole = _parole[lingua];
  if (parole == null || s.isEmpty) return s;
  var t = s;
  for (final (rx, tradotta) in parole) {
    t = t.replaceAll(rx, tradotta);
  }
  return t;
}
