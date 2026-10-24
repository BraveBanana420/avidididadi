import 'dart:convert';
import 'dart:math';

import 'assistente.dart';
import 'carico.dart';
import 'models.dart';

/// Coach nell'app del proprio assistente (Claude, ChatGPT, Gemini…), senza
/// chiave API: l'app prepara il messaggio da mandare e legge il blocco con le
/// modifiche nella risposta. All'agente vanno solo i dati e il formato della
/// risposta: generatori, esercizi e regole restano nell'app.

const appAgente = ['Claude', 'ChatGPT', 'Gemini', 'Altro'];

/// Come evitare che la chat venga usata per addestrare il modello.
const privacyAgente = {
  'Claude':
      'In Claude: Impostazioni → Privacy → disattiva "Aiuta a migliorare '
      'Claude".',
  'ChatGPT':
      'In ChatGPT: Impostazioni → Controlli dati → disattiva "Migliora il '
      'modello per tutti".',
  'Gemini':
      'In Gemini: disattiva "Attività nelle app Gemini" (o "Mantieni '
      'attività") dal tuo account Google.',
  'Altro':
      "Controlla nelle impostazioni dell'app se le chat servono ad addestrare "
      'il modello e, se vuoi, disattivalo.',
};

const _lettere = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// Codice casuale che lega le risposte dell'agente a questo telefono.
String nuovoCodiceAgente([Random? r]) {
  final g = r ?? Random.secure();
  return 'AVD-${List.generate(6, (_) => _lettere[g.nextInt(_lettere.length)]).join()}';
}

/// Settimane massime di un piano nuovo.
const settimaneMaxPiano = 16;

const _sport = {'Corsa', 'Nuoto', 'Bici', 'Forza', 'Mobilità'};

String _formato(String codice) =>
    '''Quando vuoi cambiare il piano, metti IN FONDO alla risposta un blocco di codice con dentro solo questo (JSON valido), che io copio nell'app:
```
<avidididadi codice="$codice">
{"modifiche": [
  {"azione": "cambia", "data": "AAAA-MM-GG", "sport": "Corsa", "durata_min": 40, "tipo": "Lento", "motivo": "..."},
  {"azione": "sposta", "data": "AAAA-MM-GG", "sport": "Forza", "nuova_data": "AAAA-MM-GG", "motivo": "..."},
  {"azione": "rimuovi", "data": "AAAA-MM-GG", "sport": "Bici", "motivo": "..."},
  {"azione": "aggiungi", "data": "AAAA-MM-GG", "sport": "Nuoto", "durata_min": 45, "tipo": "Tecnica", "fascia": "Mattina", "motivo": "..."}
]}
</avidididadi>
```
Per un piano nuovo, che sostituisce il calendario da quella data in poi (al massimo $settimaneMaxPiano settimane), usa invece:
```
<avidididadi codice="$codice">
{"piano": {"da": "AAAA-MM-GG", "motivo": "...", "sedute": [
  {"data": "AAAA-MM-GG", "sport": "Corsa", "tipo": "Lento", "durata_min": 40, "fascia": "Mattina"},
  {"data": "AAAA-MM-GG", "sport": "Forza", "durata_min": 45, "fascia": "Sera"}
]}}
</avidididadi>
```
Regole: solo date da oggi in poi; sport tra Corsa, Nuoto, Bici, Forza e Mobilità; tipi di corsa: Lento, Lungo, Fartlek, Tempo run, Ripetute, Ritmo gara, Allunghi; nuoto: Tecnica, Soglia; bici: Uscita, Intervalli, Uscita lunga; fasce: Mattina, Pranzo, Pomeriggio, Sera; durata tra 10 e 300 minuti.
Ogni settimana (da lunedì) almeno un giorno di riposo; i minuti di una settimana al massimo il 10% in più della settimana più impegnativa fino a quel momento. Gli esercizi delle sedute li prepara l'app: tu scegli giorno, sport, tipo e durata.
Usa sempre esattamente il codice $codice. Se non serve cambiare il piano, non aggiungere il blocco.''';

/// Primo messaggio: il ruolo, il formato delle risposte e i dati.
String messaggioInizialeAgente({
  required String codice,
  required String contesto,
  required DateTime oggi,
}) => '''${istruzioniAgente(codice)}

${datiAgente(codice: codice, contesto: contesto, oggi: oggi)}''';

/// Solo le istruzioni fisse (per un Progetto di Claude, un GPT o un Gem).
String istruzioniAgente(String codice) =>
    '''Da adesso sei il mio allenatore personale. Io seguo gli allenamenti nell'app Avidididadi (corsa, nuoto, bici, forza, mobilità); tu mi aiuti a capire come vanno e prepari o cambi il piano.
Rispondi in italiano, in modo breve e concreto, basandoti sui miei dati più recenti. Non fare diagnosi mediche: se segnalo un dolore che continua, consigliami di fermarmi e sentire un medico.

${_formato(codice)}''';

/// I dati aggiornati, da mandare quando ci sono allenamenti nuovi.
String datiAgente({
  required String codice,
  required String contesto,
  required DateTime oggi,
}) =>
    '''I MIEI DATI, aggiornati a ${dataLunga(oggi)} (codice $codice). Usa questi al posto di quelli mandati prima.
$contesto''';

/// Quello che l'app ha trovato nella risposta dell'agente.
class RispostaAgente {
  final List<Modifica>? modifiche;
  final PianoAgente? piano;
  const RispostaAgente({this.modifiche, this.piano});
}

/// Un piano nuovo proposto dall'agente, ancora da controllare.
class PianoAgente {
  final DateTime da;
  final String motivo;
  final List<Map<String, dynamic>> sedute;
  const PianoAgente(this.da, this.motivo, this.sedute);
}

final _blocco = RegExp(
  r'''<avidididadi\s+codice\s*=\s*["']?([A-Za-z0-9-]+)["']?\s*>(.*?)</avidididadi\s*>''',
  dotAll: true,
);

/// Legge il blocco nella risposta incollata o condivisa. Lancia
/// [FormatException] con un messaggio semplice se non va bene.
RispostaAgente leggiRispostaAgente(String testo, String codice) {
  final blocchi = _blocco.allMatches(testo).toList();
  if (blocchi.isEmpty) {
    throw const FormatException(
      "Nella risposta non c'è il blocco per l'app. Chiedi all'assistente di "
      'scrivere le modifiche nel formato <avidididadi>.',
    );
  }
  final validi = blocchi
      .where((m) => m[1]!.toUpperCase() == codice.toUpperCase())
      .toList();
  if (codice.isEmpty || validi.isEmpty) {
    throw const FormatException(
      'Il codice nella risposta non è quello di questo telefono: forse è di '
      'un collegamento vecchio. Manda di nuovo i dati e riprova.',
    );
  }
  final interno = validi.last[2]!
      .replaceAll(RegExp(r'```[a-zA-Z]*'), '')
      .trim();
  final Object? j;
  try {
    j = jsonDecode(interno);
  } on FormatException {
    throw const FormatException(
      "Il blocco non è leggibile. Chiedi all'assistente di riscriverlo.",
    );
  }
  if (j is! Map) {
    throw const FormatException(
      "Il blocco non è leggibile. Chiedi all'assistente di riscriverlo.",
    );
  }
  final piano = j['piano'];
  if (piano is Map) {
    final da = parseData('${piano['da'] ?? ''}');
    final sedute = piano['sedute'];
    if (da == null || sedute is! List) {
      throw const FormatException(
        'Nel piano mancano la data di inizio o le sedute.',
      );
    }
    return RispostaAgente(
      piano: PianoAgente(da, '${piano['motivo'] ?? j['motivo'] ?? ''}'.trim(), [
        for (final s in sedute)
          if (s is Map) Map<String, dynamic>.from(s),
      ]),
    );
  }
  final lista = j['modifiche'];
  final modifiche = [
    if (lista is List)
      for (final x in lista)
        if (x is Map) ?Modifica.da(Map<String, dynamic>.from(x)),
  ];
  if (modifiche.isEmpty) {
    throw const FormatException('Nel blocco non ci sono modifiche valide.');
  }
  return RispostaAgente(modifiche: modifiche);
}

/// Esito dei controlli su un piano nuovo: se ci sono problemi non si applica.
class EsitoPiano {
  final List<PianoRiga> sedute;
  final List<String> problemi;
  final List<PianoRiga> piano; // il piano che risulterebbe
  const EsitoPiano(this.sedute, this.problemi, this.piano);
  bool get applicabile => problemi.isEmpty && sedute.isNotEmpty;
}

String _breve(DateTime d) =>
    '${giorniSettimana[d.weekday - 1].substring(0, 3)} ${d.day}/${d.month}';

/// Controlla il piano nuovo: date, sport, durate, giorno di riposo e crescita
/// dei minuti. Il punto di partenza sono le settimane fatte di recente.
EsitoPiano valutaPianoAgente({
  required List<PianoRiga> piano,
  required List<Sessione> sessioni,
  required PianoAgente proposta,
  required DateTime oggi,
}) {
  final o = soloData(oggi);
  final da = soloData(proposta.da);
  final fine = da.add(const Duration(days: 7 * settimaneMaxPiano));
  final problemi = <String>[];
  final sedute = <PianoRiga>[];
  if (da.isBefore(o)) problemi.add("La data di inizio è già passata.");
  for (final s in proposta.sedute) {
    final data = parseData('${s['data'] ?? ''}');
    final sport = normSport('${s['sport'] ?? ''}');
    final v = s['durata_min'];
    final durata = v is num ? v.round() : int.tryParse('$v');
    final tipo = '${s['tipo'] ?? ''}'.trim();
    final nome = '${data == null ? '?' : _breve(data)} $sport';
    String? errore;
    if (data == null) {
      errore = 'data mancante';
    } else if (data.isBefore(da) || data.isBefore(o)) {
      errore = 'prima dell\'inizio del piano';
    } else if (!data.isBefore(fine)) {
      errore = 'oltre le $settimaneMaxPiano settimane';
    } else if (!_sport.contains(sport)) {
      errore = 'sport non previsto';
    } else if (durata == null || durata < 10 || durata > 300) {
      errore = 'durata non sensata';
    } else if (sedute.any((r) => r.data == data && r.sport == sport)) {
      errore = 'due sedute di $sport lo stesso giorno';
    }
    if (errore != null) {
      problemi.add('$nome: $errore.');
      continue;
    }
    final fascia = '${s['fascia'] ?? ''}'.trim();
    sedute.add(
      PianoRiga(
        data: data!,
        fascia: fasce.contains(fascia) ? fascia : 'Mattina',
        sport: sport,
        tipo: tipo,
        durataMin: durata!,
        note: proposta.motivo.isEmpty
            ? notaAssistente
            : '$notaAssistente: ${proposta.motivo}',
      ),
    );
  }

  // Minuti per settimana del piano nuovo.
  final settimane = <DateTime, int>{};
  final giorni = <DateTime, Set<DateTime>>{};
  for (final r in sedute) {
    final w = lunediDi(r.data);
    settimane[w] = (settimane[w] ?? 0) + r.durataMin;
    (giorni[w] ??= {}).add(r.data);
  }
  // Partenza: le ultime 4 settimane fatte, almeno 2 ore.
  final lunedi = lunediDi(o);
  final fatti = sessioni
      .where(
        (s) =>
            !s.data.isBefore(lunedi.subtract(const Duration(days: 28))) &&
            s.data.isBefore(lunedi),
      )
      .fold(0, (t, s) => t + s.durataMin);
  var massimo = max(120, (fatti / 4).round());
  for (final w in settimane.keys.toList()..sort()) {
    if ((giorni[w]?.length ?? 0) >= 7) {
      problemi.add('Settimana del ${_breve(w)}: manca un giorno di riposo.');
    }
    final limite = (massimo * 1.1).round();
    final m = settimane[w]!;
    if (m > limite) {
      problemi.add(
        'Settimana del ${_breve(w)}: $m minuti, troppi rispetto alle '
        'settimane prima (al massimo $limite).',
      );
    }
    massimo = max(massimo, m);
  }

  final risultato = [...piano.where((r) => r.data.isBefore(da)), ...sedute]
    ..sort((a, b) {
      final c = a.data.compareTo(b.data);
      return c != 0
          ? c
          : fasce.indexOf(a.fascia).compareTo(fasce.indexOf(b.fascia));
    });
  return EsitoPiano(sedute, problemi, risultato);
}

/// Messaggio da rimandare all'agente quando il piano non va bene.
String correzioneAgente(List<String> problemi, String codice) =>
    "L'app non ha accettato il piano per questi motivi:\n"
    '${problemi.map((p) => '- $p').join('\n')}\n'
    'Correggilo e rimandalo nel blocco <avidididadi> con il codice $codice.';
