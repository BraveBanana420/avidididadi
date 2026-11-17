import 'models.dart';
import 'l10n/lingua.dart';

// Configurazione guidata per chi apre l'app la prima volta: poche domande
// semplici diventano la settimana tipo e il piano.

/// Sport proposti, con una frase per chi non li conosce.
Map<String, String> get sportBenvenuto => {
  'Corsa': l10n.bastaPaioScarpeSi,
  'Forza': l10n.casaOPalestraAnche,
  'Nuoto': l10n.piscinaDelicatoSulleArticolazioni,
  'Bici': l10n.allApertoOSui,
  'Mobilità': l10n.stretchingMovimentiLentiPerfetta,
  'Arrampicata': l10n.palestraOFalesiaSegni,
};

/// Quanto si allena oggi: diventa il livello del piano di forza.
Map<String, (String, String)> get livelliBenvenuto => {
  'principiante': (l10n.maiOQuasiMai, l10n.siPartePianoSedute),
  'intermedio': (l10n.ogniTanto, l10n.qualcheAllenamentoAlMese),
  'avanzato': (l10n.regolarmente, l10n.miAllenoQuasiOgni),
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

/// Giorni di "Inizia oggi": dal lunedì al venerdì, così il fine settimana
/// resta libero per chi non vuole o non può allenarsi (il sabato entra solo
/// con sei allenamenti).
const _feriali = {
  3: [1, 3, 5],
  4: [1, 2, 4, 5],
  5: [1, 2, 3, 4, 5],
};

/// Settimana tipo dalle risposte. Gli sport si alternano partendo dall'ultimo
/// giorno, così la corsa (se c'è) cade il sabato, il giorno del lungo.
/// Con [feriali] ("Inizia oggi") i giorni sono solo dal lunedì al venerdì.
List<Slot> settimanaDa({
  required List<String> sport,
  required int giorni,
  required int minuti,
  bool feriali = false,
}) {
  if (sport.isEmpty) return [];
  final ordine = [
    if (sport.contains('Corsa')) 'Corsa',
    for (final s in sport)
      if (s != 'Corsa') s,
  ];
  final g = (feriali ? _feriali[giorni] : null) ?? _giorni[giorni.clamp(1, 6)]!;
  final out = <Slot>[];
  for (var i = 0; i < g.length; i++) {
    out.add(
      Slot(
        giorno: g[g.length - 1 - i],
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

/// "Inizia oggi": se oggi non c'è niente in programma, la prossima seduta
/// viene anticipata a oggi (solo questa volta: la settimana tipo non cambia).
/// Così si parte subito, senza sedute in più e senza due giorni di fila.
List<PianoRiga> conPrimaSedutaOggi(List<PianoRiga> piano, DateTime oggi) {
  if (piano.any((r) => r.data == oggi)) return piano;
  final prossima = piano.where((r) => r.data.isAfter(oggi)).firstOrNull?.data;
  if (prossima == null) return piano;
  return [
    for (final r in piano)
      r.data == prossima
          ? PianoRiga(
              data: oggi,
              fascia: r.fascia,
              sport: r.sport,
              tipo: r.tipo,
              durataMin: r.durataMin,
              distanzaKm: r.distanzaKm,
              intensita: r.intensita,
              note: r.note,
            )
          : r,
  ];
}
