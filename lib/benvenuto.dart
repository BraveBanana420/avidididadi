import 'models.dart';

// Configurazione guidata per chi apre l'app la prima volta: poche domande
// semplici diventano la settimana tipo e il piano.

/// Sport proposti, con una frase per chi non li conosce.
const sportBenvenuto = {
  'Corsa': 'Basta un paio di scarpe. Si parte anche camminando.',
  'Forza': 'A casa o in palestra, anche senza attrezzi.',
  'Nuoto': 'In piscina, delicato sulle articolazioni.',
  'Bici': "All'aperto o sui rulli, a ritmo tranquillo.",
  'Mobilità':
      'Stretching e movimenti lenti: perfetta per iniziare o recuperare.',
  'Arrampicata': 'In palestra o in falesia: segni vie, blocchi e gradi.',
};

/// Quanto si allena oggi: diventa il livello del piano di forza.
const livelliBenvenuto = {
  'principiante': (
    'Mai o quasi mai',
    'Si parte piano: sedute semplici per imparare i movimenti.',
  ),
  'intermedio': (
    'Ogni tanto',
    'Qualche allenamento al mese, ma senza costanza.',
  ),
  'avanzato': ('Regolarmente', 'Mi alleno quasi ogni settimana da mesi.'),
};

/// Giorni della settimana (1 = lunedì) per ogni numero di allenamenti:
/// distanziati, con il sabato libero per la seduta più lunga.
const _giorni = {
  1: [6],
  2: [2, 6],
  3: [1, 3, 6],
  4: [1, 3, 5, 6],
  5: [1, 2, 4, 5, 6],
  6: [1, 2, 3, 4, 5, 6],
};

/// Settimana tipo dalle risposte. Gli sport si alternano partendo dall'ultimo
/// giorno, così la corsa (se c'è) cade il sabato, il giorno del lungo.
///
/// Con [oggi] (1 = lunedì) i giorni scorrono in avanti del minimo che serve
/// perché oggi sia un giorno di allenamento: chi tocca "Inizia oggi" trova
/// subito una seduta, senza aspettare il lunedì.
List<Slot> settimanaDa({
  required List<String> sport,
  required int giorni,
  required int minuti,
  int? oggi,
}) {
  if (sport.isEmpty) return [];
  final ordine = [
    if (sport.contains('Corsa')) 'Corsa',
    for (final s in sport)
      if (s != 'Corsa') s,
  ];
  final g = _giorni[giorni.clamp(1, 6)]!;
  var sposta = 0;
  if (oggi != null) {
    sposta = 7;
    for (final d in g) {
      final k = (oggi - d) % 7;
      if (k < sposta) sposta = k;
    }
  }
  final out = <Slot>[];
  for (var i = 0; i < g.length; i++) {
    out.add(
      Slot(
        giorno: (g[g.length - 1 - i] - 1 + sposta) % 7 + 1,
        fascia: 'Mattina',
        sport: ordine[i % ordine.length],
        durataMin: minuti,
      ),
    );
  }
  return out..sort((a, b) => a.giorno.compareTo(b.giorno));
}

/// Giorni a settimana di "Inizia oggi": tre, o uno per sport se sono di più.
int giorniSubito(int sport) => sport.clamp(3, 6);
