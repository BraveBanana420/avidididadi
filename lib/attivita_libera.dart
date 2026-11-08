import 'attivita.dart';
import 'models.dart';

// Attività libera: si parte subito, fuori dal piano, e si aggiunge a quello
// che c'è già nel calendario (per esempio una camminata la sera).

/// Sport della camminata: con GPS e fatica bassa, non generato dal piano.
const sportCamminata = 'Camminata';

/// Forza fuori dal piano: alla fine si scrivono esercizi, serie e kg.
const tipoForzaLibera = 'Forza libera';

/// Tipo dell'altra attività finché non le dai un nome.
const tipoAltraAttivita = 'Altra attività';

/// Le attività che si possono avviare al volo: (sport, tipo, nome).
const attivitaLibere = [
  ('Corsa', 'Corsa libera', 'Corsa libera'),
  (sportCamminata, 'Camminata', 'Camminata'),
  ('Arrampicata', 'Arrampicata', 'Arrampicata'),
  ('Bici', 'Uscita libera', 'Uscita in bici'),
  ('Nuoto', 'Piscina', 'Nuoto libero'),
  ('Forza', tipoForzaLibera, tipoForzaLibera),
  ('Mobilità', 'Mobilità libera', 'Mobilità e stretching'),
  (sportAttivitaLibera, tipoAltraAttivita, tipoAltraAttivita),
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

/// Nomi già dati alle altre attività (es. "Kayak"), dal più recente: si
/// propongono per non riscriverli. Senza doppioni, maiuscole a parte.
List<String> nomiAltreAttivita(List<Sessione> sessioni, {int max = 8}) {
  final ordinate =
      sessioni
          .where(
            (s) =>
                stessoSport(s.sport, sportAttivitaLibera) &&
                s.tipo.trim().isNotEmpty &&
                !stessoSport(s.tipo, tipoAltraAttivita),
          )
          .toList()
        ..sort((a, b) => b.data.compareTo(a.data));
  final visti = <String>{};
  return [
    for (final s in ordinate)
      if (visti.add(s.tipo.trim().toLowerCase())) s.tipo.trim(),
  ].take(max).toList();
}

/// Il nome scritto, ripulito: spazi tolti e maiuscola iniziale ("kayak" →
/// "Kayak"). Vuoto se non c'è niente.
String pulisciNomeAttivita(String testo) =>
    maiuscola(testo.trim().replaceAll(RegExp(r'\s+'), ' '));
