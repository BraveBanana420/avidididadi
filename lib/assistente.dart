import 'dart:convert';

import 'carico.dart';
import 'csv.dart';
import 'feedback.dart';
import 'allenamento_agente.dart';
import 'allenamento_arrampicata.dart';
import 'models.dart';
import 'obiettivo.dart';
import 'recupero.dart';
import 'l10n/lingua.dart';

/// Assistente facoltativo: un modello linguistico scelto dall'utente (Claude,
/// GPT, Gemini o Ollama sul proprio PC) legge un riassunto degli allenamenti
/// e può proporre modifiche al piano, che si applicano solo dopo l'approvazione.

enum Fornitore { claude, openai, gemini, ollama }

Map<Fornitore, String> get nomiFornitori => {
  Fornitore.claude: 'Claude (Anthropic)',
  Fornitore.openai: 'GPT (OpenAI)',
  Fornitore.gemini: 'Gemini (Google)',
  Fornitore.ollama: l10n.ollamaSulTuoPc,
};

const modelliPredefiniti = {
  Fornitore.claude: 'claude-sonnet-5-5',
  Fornitore.openai: 'gpt-5-mini',
  Fornitore.gemini: 'gemini-2.5-flash',
  Fornitore.ollama: 'llama3.1',
};

Map<Fornitore, String> get descrizioniFornitori => {
  Fornitore.claude: l10n.serveChiaveApiConsole,
  Fornitore.openai: l10n.serveChiaveApiPlatform,
  Fornitore.gemini: l10n.serveChiaveApiAistudio,
  Fornitore.ollama: l10n.gratisPrivatoModelloGira,
};

bool serveChiave(Fornitore f) => f != Fornitore.ollama;

enum StatoConnessione { daVerificare, inVerifica, connesso, errore }

const configAssistenteHeader = ['chiave', 'valore'];

/// Impostazioni dell'assistente (la chiave API no: sta nell'archivio sicuro).
class ConfigAssistente {
  Fornitore fornitore = Fornitore.gemini;
  Map<Fornitore, String> modelli = {};
  String urlOllama = 'http://192.168.1.10:11434';
  Set<Fornitore> consensi = {}; // fornitori a cui l'utente ha detto sì
  bool datiPersonali = false; // età, sesso, peso nel riassunto
  // Assistente nell'app dell'utente (Claude, ChatGPT…), senza chiave API.
  bool esterno = false;
  String appEsterna = '';
  String codiceEsterno = ''; // lega le risposte a questo telefono
  DateTime? ultimoInvioEsterno;

  String get modello => (modelli[fornitore] ?? '').isEmpty
      ? modelliPredefiniti[fornitore]!
      : modelli[fornitore]!;

  bool get consenso => consensi.contains(fornitore);

  List<List<String>> toRows() => [
    ['fornitore', fornitore.name],
    for (final e in modelli.entries) ['modello_${e.key.name}', e.value],
    ['url_ollama', urlOllama],
    ['consensi', consensi.map((f) => f.name).join(',')],
    ['dati_personali', datiPersonali ? 'si' : 'no'],
    ['esterno', esterno ? 'si' : ''],
    ['app_esterna', appEsterna],
    ['codice_esterno', codiceEsterno],
    ['ultimo_invio_esterno', ultimoInvioEsterno?.toIso8601String() ?? ''],
  ];

  static ConfigAssistente da(Tabella? t) {
    final c = ConfigAssistente();
    if (t == null) return c;
    final m = {for (final r in t.righe) t.v(r, 'chiave'): t.v(r, 'valore')};
    Fornitore? perNome(String n) =>
        Fornitore.values.where((f) => f.name == n).firstOrNull;
    c.fornitore = perNome(m['fornitore'] ?? '') ?? c.fornitore;
    for (final f in Fornitore.values) {
      final v = m['modello_${f.name}'] ?? '';
      if (v.isNotEmpty) c.modelli[f] = v;
    }
    if ((m['url_ollama'] ?? '').isNotEmpty) c.urlOllama = m['url_ollama']!;
    c.consensi = {
      for (final n in (m['consensi'] ?? '').split(',')) ?perNome(n.trim()),
    };
    c.datiPersonali = m['dati_personali'] == 'si';
    c.appEsterna = m['app_esterna'] ?? '';
    c.codiceEsterno = m['codice_esterno'] ?? '';
    // Collegato solo se c'è anche il codice.
    c.esterno = m['esterno'] == 'si' && c.codiceEsterno.isNotEmpty;
    c.ultimoInvioEsterno = DateTime.tryParse(m['ultimo_invio_esterno'] ?? '');
    return c;
  }
}

class MessaggioChat {
  final bool utente;
  final String testo;
  // Solo nelle risposte dell'assistente: quello che propone.
  final List<Modifica>? proposta;
  final PianoAgente? piano;
  final List<AllenamentoAgente>? allenamenti;
  final List<PropostaArrampicata>? arrampicata;
  final String motivo;
  final String? errore; // la proposta c'era ma non si legge
  bool applicata = false;
  MessaggioChat(
    this.utente,
    this.testo, {
    this.proposta,
    this.piano,
    this.allenamenti,
    this.arrampicata,
    this.motivo = '',
    this.errore,
  });
}

// ---------------------------------------------------------------------------
// Riassunto dei dati inviati

String _gg(DateTime d) =>
    '${isoData(d)} ${giorniSettimana[d.weekday - 1].substring(0, 3).toLowerCase()}';

/// Riassunto compatto dei dati di allenamento da inviare al modello. Niente
/// nome, foto o identificativi; età, sesso e peso solo se [personali] non è null.
String contestoAllenamento({
  required DateTime oggi,
  String? personali,
  Obiettivo? gara,
  required Zone zone,
  int? ftp,
  int? passoCritico,
  required List<Sessione> sessioni,
  required List<PianoRiga> piano,
  required List<FeedbackSessione> feedback,
  required List<GiornoRecupero> recupero,
  Set<String> sportGenerati = const {},
  Set<String> attivita = const {},
}) {
  final o = soloData(oggi);
  final b = StringBuffer()..writeln('Oggi: ${_gg(o)}');
  if (personali != null && personali.isNotEmpty) {
    b.writeln('Atleta: $personali');
  }
  if (gara == null) {
    b.writeln('Gara obiettivo: nessuna');
  } else {
    b.writeln(
      'Gara obiettivo: ${gara.nome} il ${isoData(gara.data)} '
      '(tra ${gara.settimaneMancanti(o)} settimane, fase ${nomiFasi[gara.fase(o)]})',
    );
  }
  b.writeln(
    'FC max ${zone.fcMax}${zone.fcMaxStimata ? ' (stimata)' : ''}'
    '${zone.fcRiposo > 0 ? ', FC a riposo ${zone.fcRiposo}' : ''}. Zone: '
    '${[for (var z = 1; z <= 5; z++) 'Z$z ${zone.zona(z).$1}-${zone.zona(z).$2}'].join(', ')}',
  );
  if (ftp != null) {
    b.writeln('FTP bici: $ftp W (zone di potenza di Coggan in % dell\'FTP)');
  }
  if (passoCritico != null) {
    b.writeln('Passo critico nuoto: ${fmtPasso100(passoCritico)}');
  }
  if (attivita.isNotEmpty) {
    b.writeln(
      'Attività scelte dall\'atleta: ${attivita.join(', ')}. Proponi solo '
      'queste, salvo che chieda altro.',
    );
  }
  if (sportGenerati.isNotEmpty) {
    b.writeln('Sedute generate dall\'app: ${sportGenerati.join(', ')}, Forza');
  }

  int? rpe(Sessione s) {
    for (final f in feedback) {
      if (f.di(s.data, s.sport)) return f.fatica;
    }
    return null;
  }

  final perGiorno = caricoPerGiorno(sessioni, zone, rpeDi: rpe);
  final acwr = rapportoAcutoCronico(perGiorno, o);
  if (acwr != null) {
    b.writeln(
      'Carico ultimi 7 giorni / media 4 settimane: ${acwr.toStringAsFixed(2)} '
      '(${descrizioniCarico[statoCarico(acwr)]})',
    );
  }

  final recenti =
      sessioni
          .where((s) => !s.data.isAfter(o) && o.difference(s.data).inDays < 28)
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));
  b.writeln('\nSessioni svolte (ultime 4 settimane):');
  if (recenti.isEmpty) b.writeln('- nessuna');
  for (final s in recenti.skip(recenti.length > 40 ? recenti.length - 40 : 0)) {
    final f = feedback.where((x) => x.di(s.data, s.sport)).firstOrNull;
    b.writeln(
      [
        '- ${_gg(s.data)} ${s.sport}',
        if (s.tipo.isNotEmpty) s.tipo,
        '${s.durataMin} min',
        if (s.distanzaKm > 0) '${fmtNum(s.distanzaKm)} km',
        if (s.fcMedia > 0) 'FC media ${s.fcMedia}',
        if (f != null) 'fatica ${f.fatica}/10',
        if (f != null && !f.completata) 'non completata',
        if (f != null && f.dolore) 'DOLORE',
        if (f != null && f.note.isNotEmpty) 'note: "${f.note}"',
      ].join(', '),
    );
  }

  final rec = recupero
      .where((g) => !g.data.isAfter(o) && o.difference(g.data).inDays < 7)
      .toList();
  if (rec.isNotEmpty) {
    b.writeln('\nRecupero (ultimi 7 giorni):');
    for (final g in rec) {
      b.writeln(
        [
          '- ${_gg(g.data)}',
          if (g.sonnoMin > 0) 'sonno ${g.sonnoMin ~/ 60}h${g.sonnoMin % 60}',
          if (g.fcRiposo > 0) 'FC riposo ${g.fcRiposo}',
          if (g.hrv > 0) 'HRV ${g.hrv.round()} ms',
        ].join(', '),
      );
    }
  }

  final prossimi =
      piano
          .where((r) => !r.data.isBefore(o) && r.data.difference(o).inDays < 14)
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));
  b.writeln('\nPiano dei prossimi 14 giorni:');
  if (prossimi.isEmpty) b.writeln('- nessuna seduta');
  for (final r in prossimi) {
    b.writeln(
      [
        '- ${_gg(r.data)} ${r.sport}',
        if (r.tipo.isNotEmpty) r.tipo,
        '${r.durataMin} min',
        r.fascia.toLowerCase(),
      ].join(', '),
    );
  }
  return b.toString().trim();
}

/// Istruzioni di sistema: ruolo, sicurezza e formato delle proposte.
String istruzioniAssistente(String contesto) =>
    '''Sei l'allenatore personale dell'utente nell'app Avidididadi (corsa, nuoto, bici, forza).
Rispondi in italiano, in modo breve e concreto, basandoti sui dati qui sotto.
Non fare diagnosi mediche: in caso di dolore che continua, consiglia di fermarsi e sentire un medico.

Se proponi di cambiare il piano, un piano nuovo o un allenamento preciso, aggiungi IN FONDO alla risposta un blocco così (solo JSON valido dentro):
${formatoProposte('<proposta>', '</proposta>')}
L'utente vedrà la proposta e deciderà se applicarla.
Se non serve cambiare il piano, non aggiungere il blocco.

DATI DELL'UTENTE
$contesto''';

// ---------------------------------------------------------------------------
// Proposte di modifica

/// Settimane massime di un piano nuovo.
const settimaneMaxPiano = 16;

/// I formati delle proposte, uguali per il coach con la chiave API e per
/// l'assistente nella sua app: cambiare sedute, un piano nuovo, allenamenti
/// passo per passo. [apri] e [chiudi] sono i segni attorno al JSON.
String formatoProposte(String apri, String chiudi) =>
    '''```
$apri
{"modifiche": [
  {"azione": "cambia", "data": "AAAA-MM-GG", "sport": "Corsa", "durata_min": 40, "tipo": "Lento", "motivo": "..."},
  {"azione": "sposta", "data": "AAAA-MM-GG", "sport": "Forza", "nuova_data": "AAAA-MM-GG", "motivo": "..."},
  {"azione": "rimuovi", "data": "AAAA-MM-GG", "sport": "Bici", "motivo": "..."},
  {"azione": "aggiungi", "data": "AAAA-MM-GG", "sport": "Nuoto", "durata_min": 45, "tipo": "Tecnica", "fascia": "Mattina", "motivo": "..."}
]}
$chiudi
```
Per un piano nuovo, che sostituisce il calendario da quella data in poi (al massimo $settimaneMaxPiano settimane), usa invece:
```
$apri
{"piano": {"da": "AAAA-MM-GG", "motivo": "...", "sedute": [
  {"data": "AAAA-MM-GG", "sport": "Corsa", "tipo": "Lento", "durata_min": 40, "fascia": "Mattina"},
  {"data": "AAAA-MM-GG", "sport": "Forza", "durata_min": 45, "fascia": "Sera"}
]}}
$chiudi
```
Per un allenamento preciso di corsa, bici o nuoto con i passi scelti da te (per esempio delle ripetute in watt per il rullo), usa:
```
$apri
{"allenamenti": [
  {"data": "AAAA-MM-GG", "sport": "Bici", "tipo": "Intervalli", "nome": "VO2max 5x4", "fascia": "Sera", "motivo": "...", "passi": [
    {"fase": "riscaldamento", "nome": "Pedalata agile", "minuti": 10, "intensita": "55-65%"},
    {"fase": "principale", "nome": "Ripetute", "ripeti": 5, "minuti": 4, "intensita": "106-112%", "secondario": "85-90 rpm", "recupero_s": 180},
    {"fase": "defaticamento", "nome": "Sciolto", "minuti": 10, "intensita": "zona 1"}
  ]}
]}
$chiudi
```
"durata_min" (facoltativa) è la durata totale, utile se ci sono passi a distanza. Nei passi: "minuti" (oppure "metri"), "ripeti" e "recupero_s" (secondi tra una ripetizione e l'altra) se si ripete. "intensita": in bici una % dell'FTP ("88-94%"), dei watt ("200-220 W") o una zona ("zona 2"); i recuperi in bici sono al 45-55% se non dici altro. Nella corsa una zona o un passo ("passo 5:00/km"); nel nuoto un passo ("passo 1:50/100 m"). "secondario" (facoltativo) è il secondo obiettivo del passo: in bici la cadenza ("85-90 rpm"), altrimenti quello che serve. L'allenamento prende il posto della seduta dello stesso sport in quel giorno; con un rullo smart l'app gli manda i watt di ogni passo. Al massimo 40 passi e 5 ore.
${formatoArrampicata(apri, chiudi)}
Regole: solo date da oggi in poi; sport tra Corsa, Nuoto, Bici, Forza e Mobilità; tipi di corsa: Lento, Lungo, Fartlek, Tempo run, Ripetute, Ritmo gara, Allunghi; nuoto: Tecnica, Soglia; bici: Uscita, Intervalli, Uscita lunga; fasce: Mattina, Pranzo, Pomeriggio, Sera; durata tra 10 e 300 minuti.
Ogni settimana (da lunedì) almeno un giorno di riposo; i minuti di una settimana al massimo il 10% in più della settimana più impegnativa fino a quel momento. Con {"piano"} i passi delle sedute li prepara l'app da tipo e durata; se vuoi passi precisi, per esempio con i passi gara della persona, manda quelle sedute con {"allenamenti"}.''';

/// Quello che l'app ha trovato nella risposta dell'agente.
class RispostaAgente {
  final List<Modifica>? modifiche;
  final PianoAgente? piano;
  final List<AllenamentoAgente>? allenamenti;
  final List<PropostaArrampicata>? arrampicata;
  final String motivo; // perché l'assistente propone gli allenamenti
  const RispostaAgente({
    this.modifiche,
    this.piano,
    this.allenamenti,
    this.arrampicata,
    this.motivo = '',
  });
}

/// Un piano nuovo proposto dall'agente, ancora da controllare.
class PianoAgente {
  final DateTime da;
  final String motivo;
  final List<Map<String, dynamic>> sedute;
  const PianoAgente(this.da, this.motivo, this.sedute);
}

/// Le proposte in un blocco JSON (modifiche, piano nuovo o allenamenti).
/// Lancia [FormatException] con un messaggio semplice se non va bene.
RispostaAgente rispostaDaJson(Map<dynamic, dynamic> j) {
  final arrampicata = j['arrampicata'];
  if (arrampicata is List) {
    return RispostaAgente(
      arrampicata: proposteArrampicata(arrampicata, DateTime.now()),
    );
  }
  final allenamenti = j['allenamenti'];
  if (allenamenti is List) {
    final lista = [
      for (final a in allenamenti)
        if (a is Map) allenamentoDa(Map<String, dynamic>.from(a)),
    ];
    if (lista.isEmpty) {
      throw FormatException(l10n.nelBloccoNonCi2);
    }
    final motivi = {
      for (final a in allenamenti)
        if (a is Map && '${a['motivo'] ?? ''}'.trim().isNotEmpty)
          '${a['motivo']}'.trim(),
    };
    return RispostaAgente(allenamenti: lista, motivo: motivi.join(' '));
  }
  final piano = j['piano'];
  if (piano is Map) {
    final da = parseData('${piano['da'] ?? ''}');
    final sedute = piano['sedute'];
    if (da == null || sedute is! List) {
      throw FormatException(l10n.nelPianoMancanoData);
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
    throw FormatException(l10n.nelBloccoNonCi3);
  }
  return RispostaAgente(modifiche: modifiche);
}

enum Azione { cambia, sposta, rimuovi, aggiungi }

class Modifica {
  final Azione azione;
  final DateTime data;
  final String sport;
  final DateTime? nuovaData;
  final int? durataMin;
  final String tipo;
  final String fascia;
  final String motivo;
  const Modifica({
    required this.azione,
    required this.data,
    required this.sport,
    this.nuovaData,
    this.durataMin,
    this.tipo = '',
    this.fascia = '',
    this.motivo = '',
  });

  static Modifica? da(Map<String, dynamic> m) {
    final azione = Azione.values
        .where((a) => a.name == '${m['azione']}'.toLowerCase().trim())
        .firstOrNull;
    final data = parseData('${m['data'] ?? ''}');
    final sport = normSport('${m['sport'] ?? ''}');
    if (azione == null || data == null || sport.isEmpty) return null;
    final durata = m['durata_min'];
    return Modifica(
      azione: azione,
      data: data,
      sport: sport,
      nuovaData: parseData('${m['nuova_data'] ?? ''}'),
      durataMin: durata is num ? durata.round() : int.tryParse('$durata'),
      tipo: '${m['tipo'] ?? ''}'.trim(),
      fascia: '${m['fascia'] ?? ''}'.trim(),
      motivo: '${m['motivo'] ?? ''}'.trim(),
    );
  }
}

final _blocco = RegExp(r'<proposta>([\s\S]*?)</proposta>');
final _json = RegExp(
  r'```(?:json)?\s*(\{[\s\S]*?"(?:modifiche|piano|allenamenti|arrampicata)"[\s\S]*\})\s*```',
);

/// Separa il testo della risposta dalla proposta: modifiche, piano nuovo o
/// allenamenti. [errore] dice perché un blocco c'era ma non si legge.
({String testo, RispostaAgente? proposta, String? errore}) leggiProposta(
  String risposta,
) {
  final m = _blocco.firstMatch(risposta) ?? _json.firstMatch(risposta);
  if (m == null) return (testo: risposta.trim(), proposta: null, errore: null);
  final testo = risposta.replaceRange(m.start, m.end, '').trim();
  final Object? j;
  try {
    j = jsonDecode(m.group(1)!.replaceAll(RegExp(r'```[a-zA-Z]*'), '').trim());
  } on FormatException {
    return (
      testo: testo,
      proposta: null,
      errore: l10n.propostaNonLeggibileChiedi,
    );
  }
  if (j is! Map) {
    return (
      testo: testo,
      proposta: null,
      errore: l10n.propostaNonLeggibileChiedi,
    );
  }
  try {
    return (testo: testo, proposta: rispostaDaJson(j), errore: null);
  } on FormatException catch (e) {
    return (testo: testo, proposta: null, errore: e.message);
  }
}

/// Solo le modifiche alle sedute (null se non ce ne sono).
(String, List<Modifica>?) estraiProposta(String risposta) {
  final r = leggiProposta(risposta);
  return (r.testo, r.proposta?.modifiche);
}

const _sportPiano = {'Corsa', 'Nuoto', 'Bici', 'Forza', 'Mobilità'};

/// Esito dei controlli: le modifiche accettate, quelle scartate con il
/// motivo e il piano che risulterebbe.
class EsitoProposta {
  final List<Modifica> accettate;
  final List<(Modifica, String)> scartate;
  final List<PianoRiga> piano;
  const EsitoProposta(this.accettate, this.scartate, this.piano);
}

PianoRiga _copia(
  PianoRiga r, {
  DateTime? data,
  int? durata,
  String? tipo,
  String? fascia,
  String? note,
}) => PianoRiga(
  data: data ?? r.data,
  fascia: fascia ?? r.fascia,
  sport: r.sport,
  tipo: tipo ?? r.tipo,
  durataMin: durata ?? r.durataMin,
  distanzaKm: r.distanzaKm,
  intensita: r.intensita,
  note: note ?? r.note,
);

/// Le righe toccate dall'assistente lo dicono nelle note: così il generatore
/// rispetta tipo e durata scelti.
const notaAssistente = 'Assistente';

bool rigaDaAssistente(PianoRiga r) => r.note.startsWith(notaAssistente);

String _nota(Modifica m) =>
    m.motivo.isEmpty ? notaAssistente : '$notaAssistente: ${m.motivo}';

/// Applica una modifica; restituisce il motivo se non si può applicare.
String? _applica(List<PianoRiga> p, Modifica m, DateTime oggi) {
  if (!_sportPiano.contains(m.sport)) return l10n.sportNonPrevisto2(m.sport);
  if (m.data.isBefore(oggi)) return l10n.dataGiaPassata;
  final d = m.durataMin;
  if (d != null && (d < 10 || d > 300)) return l10n.durataNonSensataMin(d);
  final i = p.indexWhere(
    (r) => r.data == m.data && stessoSport(r.sport, m.sport),
  );
  switch (m.azione) {
    case Azione.aggiungi:
      if (i >= 0) return l10n.cGiaSedutaQuel(m.sport);
      if (d == null) return l10n.mancaDurata;
      p.add(
        PianoRiga(
          data: m.data,
          fascia: fasce.contains(m.fascia) ? m.fascia : 'Mattina',
          sport: m.sport,
          tipo: m.tipo,
          durataMin: d,
          note: _nota(m),
        ),
      );
    case Azione.cambia:
      if (i < 0) return l10n.quelGiornoNonC(m.sport);
      p[i] = _copia(
        p[i],
        durata: d,
        tipo: m.tipo.isEmpty ? null : m.tipo,
        fascia: fasce.contains(m.fascia) ? m.fascia : null,
        note: _nota(m),
      );
    case Azione.sposta:
      if (i < 0) return l10n.quelGiornoNonC(m.sport);
      final n = m.nuovaData;
      if (n == null || n.isBefore(oggi)) return l10n.nuovaDataMancanteO;
      if (p.any((r) => r.data == n && stessoSport(r.sport, m.sport))) {
        return l10n.cGiaSedutaGiorno(m.sport);
      }
      p[i] = _copia(p[i], data: n, note: _nota(m));
    case Azione.rimuovi:
      if (i < 0) return l10n.quelGiornoNonC(m.sport);
      p.removeAt(i);
  }
  return null;
}

/// Settimane toccate da una modifica (lunedì).
Set<DateTime> _settimane(Modifica m) => {
  lunediDi(m.data),
  if (m.nuovaData != null) lunediDi(m.nuovaData!),
};

int _minuti(List<PianoRiga> p, DateTime lunedi) => p
    .where((r) => lunediDi(r.data) == lunedi && !stessoSport(r.sport, 'Riposo'))
    .fold(0, (t, r) => t + r.durataMin);

bool _haRiposo(List<PianoRiga> p, DateTime lunedi) {
  final attivi = {
    for (final r in p)
      if (lunediDi(r.data) == lunedi && !stessoSport(r.sport, 'Riposo')) r.data,
  };
  return attivi.length < 7;
}

/// Controlla e applica la proposta su una copia del piano. Una modifica che fa
/// crescere i minuti di una settimana oltre il 10% o toglie l'ultimo giorno di
/// riposo viene scartata.
EsitoProposta valutaProposta(
  List<PianoRiga> piano,
  List<Modifica> modifiche,
  DateTime oggi,
) {
  final o = soloData(oggi);
  final accettate = <Modifica>[];
  final scartate = <(Modifica, String)>[];
  var p = [...piano];
  for (final m in modifiche) {
    final prova = [...p];
    final errore = _applica(prova, m, o);
    if (errore != null) {
      scartate.add((m, errore));
      continue;
    }
    String? limite;
    for (final w in _settimane(m)) {
      final prima = _minuti(piano, w);
      final dopo = _minuti(prova, w);
      if (dopo > prima && dopo > (prima * 1.1).round()) {
        limite = l10n.settimanaPasserebbeMinutiOltre(prima, dopo);
      } else if (_haRiposo(piano, w) && !_haRiposo(prova, w)) {
        limite = l10n.settimanaResterebbeSenzaGiorno;
      }
    }
    if (limite != null) {
      scartate.add((m, limite));
      continue;
    }
    p = prova;
    accettate.add(m);
  }
  p.sort((a, b) {
    final c = a.data.compareTo(b.data);
    return c != 0
        ? c
        : fasce.indexOf(a.fascia).compareTo(fasce.indexOf(b.fascia));
  });
  return EsitoProposta(accettate, scartate, p);
}

String _giorno(DateTime d) =>
    '${giorniSettimana[d.weekday - 1].substring(0, 3)} ${d.day}/${d.month}';

String _seduta(PianoRiga r) =>
    [if (r.tipo.isNotEmpty) r.tipo, '${r.durataMin} min'].join(' ');

/// "Prima → dopo" di una modifica, rispetto al piano attuale.
String descriviModifica(Modifica m, List<PianoRiga> piano) {
  final r = piano
      .where((x) => x.data == m.data && stessoSport(x.sport, m.sport))
      .firstOrNull;
  final dove = '${_giorno(m.data)} ${m.sport}';
  return switch (m.azione) {
    Azione.aggiungi => l10n.nuovaSeduta(
      dove,
      [if (m.tipo.isNotEmpty) m.tipo, '${m.durataMin} min'].join(' '),
    ),
    Azione.rimuovi => l10n.tolta(dove, r == null ? '' : ' (${_seduta(r)})'),
    Azione.sposta =>
      '$dove → ${m.nuovaData == null ? '?' : _giorno(m.nuovaData!)}',
    Azione.cambia =>
      '$dove: ${r == null ? '?' : _seduta(r)} → '
          '${[if (m.tipo.isNotEmpty) m.tipo else if (r != null && r.tipo.isNotEmpty) r.tipo, '${m.durataMin ?? r?.durataMin ?? 0} min'].join(' ')}',
  };
}
