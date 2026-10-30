import 'models.dart';

// Attività libera: si parte subito, fuori dal piano, e si aggiunge a quello
// che c'è già nel calendario (per esempio una camminata la sera).

/// Sport della camminata: con GPS e fatica bassa, non generato dal piano.
const sportCamminata = 'Camminata';

/// Le attività che si possono avviare al volo: (sport, tipo, nome).
const attivitaLibere = [
  ('Corsa', 'Corsa libera', 'Corsa libera'),
  (sportCamminata, 'Camminata', 'Camminata'),
  ('Bici', 'Uscita libera', 'Uscita in bici'),
  ('Nuoto', 'Piscina', 'Nuoto libero'),
  ('Forza', 'Allenamento libero', 'Allenamento libero'),
  ('Mobilità', 'Mobilità libera', 'Mobilità e stretching'),
];

/// Un passo solo, senza tempo né distanza: il cronometro sale e si chiude
/// con "Fatto".
List<WorkoutStep> passiLiberi(String sport, String nome) => [
  WorkoutStep(
    id: 'libera',
    sport: sport,
    nome: nome,
    durataTot: 0,
    ordine: 1,
    fase: 'principale',
    descrizione: nome,
    serie: '',
    ripetizioni: '',
    distanzaM: '',
    durataMin: '',
    intensita: '',
    recuperoS: '',
    note: 'Tocca "Fatto" quando hai finito.',
  ),
];

/// Id della sessione: con l'ora di inizio, così non sostituisce le sedute
/// dello stesso sport già fatte quel giorno.
String idLibera(DateTime inizio, String sport) =>
    'app-${isoData(inizio)}-${sport.toLowerCase()}-'
    '${two(inizio.hour)}${two(inizio.minute)}';
