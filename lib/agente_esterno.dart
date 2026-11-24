import 'dart:math';

import 'assistente.dart';
import 'carico.dart';
import 'models.dart';
import 'l10n/lingua.dart';

/// Coach nell'app del proprio assistente (Claude, ChatGPT, Gemini…), senza
/// chiave API: l'app prepara il messaggio da mandare e legge il blocco con le
/// modifiche nella risposta. All'agente vanno solo i dati e il formato della
/// risposta: generatori, esercizi e regole restano nell'app.

const appAgente = ['Claude', 'ChatGPT', 'Gemini', 'Altro'];

/// Come evitare che la chat venga usata per addestrare il modello.
Map<String, String> get privacyAgente => {
  'Claude': l10n.claudeImpostazioniPrivacyDisattiva,
  'ChatGPT': l10n.chatgptImpostazioniControlliDati,
  'Gemini': l10n.geminiDisattivaAttivitaNelle,
  'Altro': l10n.controllaNelleImpostazioniDell,
};

const _lettere = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// Codice casuale che lega le risposte dell'agente a questo telefono.
String nuovoCodiceAgente([Random? r]) {
  final g = r ?? Random.secure();
  return 'AVD-${List.generate(6, (_) => _lettere[g.nextInt(_lettere.length)]).join()}';
}

const _sport = {'Corsa', 'Nuoto', 'Bici', 'Forza', 'Mobilità'};

String _formato(String codice) =>
    '''Quando vuoi cambiare il piano, metti IN FONDO alla risposta un blocco di codice con dentro solo questo (JSON valido), che io copio nell'app:
${formatoProposte('<avidididadi codice="$codice">', '</avidididadi>')}
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
Rispondi in $linguaRisposta, in modo breve e concreto, basandoti sui miei dati più recenti. Non fare diagnosi mediche: se segnalo un dolore che continua, consigliami di fermarmi e sentire un medico.

${_formato(codice)}''';

/// I dati aggiornati, da mandare quando ci sono allenamenti nuovi.
String datiAgente({
  required String codice,
  required String contesto,
  required DateTime oggi,
}) =>
    '''I MIEI DATI, aggiornati a ${dataLunga(oggi)} (codice $codice). Usa questi al posto di quelli mandati prima.
$contesto''';

final _blocco = RegExp(
  r'''<avidididadi\s+codice\s*=\s*["']?([A-Za-z0-9-]+)["']?\s*>(.*?)</avidididadi\s*>''',
  dotAll: true,
);

/// Legge il blocco nella risposta incollata o condivisa. Lancia
/// [FormatException] con un messaggio semplice se non va bene.
RispostaAgente leggiRispostaAgente(String testo, String codice) {
  final blocchi = _blocco.allMatches(testo).toList();
  if (blocchi.isEmpty) {
    throw FormatException(l10n.nellaRispostaNonC);
  }
  final validi = blocchi
      .where((m) => m[1]!.toUpperCase() == codice.toUpperCase())
      .toList();
  if (codice.isEmpty || validi.isEmpty) {
    throw FormatException(l10n.codiceNellaRispostaNon);
  }
  // Tutti i blocchi con il codice giusto diventano una proposta sola: se
  // l'agente ne scrive due (togliere una seduta e un allenamento preciso),
  // basta incollare la risposta una volta.
  final lette = <RispostaAgente>[];
  for (final m in validi) {
    final Map<dynamic, dynamic> j;
    try {
      j = jsonBlocco(m[2]!);
    } on FormatException {
      throw FormatException(l10n.bloccoNonLeggibileChiedi);
    }
    lette.add(rispostaDaJson(j));
  }
  return unisciRisposte(lette);
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
  if (da.isBefore(o)) problemi.add(l10n.dataInizioGiaPassata);
  for (final s in proposta.sedute) {
    final data = parseData('${s['data'] ?? ''}');
    final sport = normSport('${s['sport'] ?? ''}');
    final v = s['durata_min'];
    final durata = v is num ? v.round() : int.tryParse('$v');
    final tipo = '${s['tipo'] ?? ''}'.trim();
    final nome = '${data == null ? '?' : _breve(data)} $sport';
    String? errore;
    if (data == null) {
      errore = l10n.dataMancante;
    } else if (data.isBefore(da) || data.isBefore(o)) {
      errore = l10n.primaDellInizioPiano;
    } else if (!data.isBefore(fine)) {
      errore = l10n.oltreSettimane(settimaneMaxPiano);
    } else if (!_sport.contains(sport)) {
      errore = l10n.sportNonPrevisto;
    } else if (durata == null || durata < 10 || durata > 300) {
      errore = l10n.durataNonSensata;
    } else if (sedute.any((r) => r.data == data && r.sport == sport)) {
      errore = l10n.dueSeduteStessoGiorno(sport);
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
      problemi.add(l10n.settimanaMancaGiornoRiposo(_breve(w)));
    }
    final limite = (massimo * 1.1).round();
    final m = settimane[w]!;
    if (m > limite) {
      problemi.add(l10n.settimanaMinutiTroppiRispetto(_breve(w), m, limite));
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
    l10n.appNonHaAccettato(problemi.map((p) => '- $p').join('\n'), codice);
