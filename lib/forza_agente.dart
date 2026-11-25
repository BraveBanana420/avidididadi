import 'esercizi.dart';
import 'models.dart';
import 'registro_forza.dart';
import 'scheda.dart';
import 'l10n/lingua.dart';

// Schede di forza graduali preparate dall'assistente (per esempio Claude) con
// gli esercizi del catalogo dell'app: una o più fasi di qualche settimana,
// ognuna con i suoi giorni (Busto, Gambe…) ed esercizi con serie,
// ripetizioni, recupero e kg. Ogni fase diventa una scheda come quelle
// scritte a mano, e la fase dopo può essere più dura di quella prima.

/// Settimane massime di una scheda graduale dell'assistente.
const settimaneMaxForza = 16;

/// Fasi massime di una scheda graduale.
const fasiMaxForza = 8;

/// Una scheda di forza graduale proposta dall'assistente.
class PropostaForza {
  final String nome;
  final String motivo;
  final List<Scheda> fasi; // in ordine di data, senza sovrapposizioni
  const PropostaForza(this.nome, this.motivo, this.fasi);

  DateTime get inizio => fasi.first.inizio;
  DateTime get fine => fasi.last.fine!;

  /// I giorni della settimana (1 = lunedì) in cui c'è almeno una seduta.
  Set<int> get giorniSettimana => {
    for (final f in fasi)
      for (final g in f.giorni) ...g.giorni,
  };
}

String _testo(Object? v, int max) {
  final t = '${v ?? ''}'.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t.length > max ? t.substring(0, max) : t;
}

int? _intero(Object? v) =>
    v is num ? v.round() : int.tryParse('${v ?? ''}'.trim());

double? _kg(Object? v) {
  final n = v is num
      ? v.toDouble()
      : double.tryParse('${v ?? ''}'.trim().replaceAll(',', '.'));
  return n == null || !n.isFinite || n < 0 || n > 500 ? null : n;
}

/// L'esercizio del catalogo con quell'id o quel nome (in una lingua
/// qualsiasi), senza badare a maiuscole e spazi.
Esercizio? esercizioDelCatalogo(List<Esercizio> catalogo, String testo) {
  String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
  final t = norm(testo);
  if (t.isEmpty) return null;
  for (final e in catalogo) {
    if (norm(e.id) == t) return e;
  }
  for (final e in catalogo) {
    if (norm(e.nomeIt) == t || norm(e.nomeEn) == t || norm(e.nomeEl) == t) {
      return e;
    }
  }
  return null;
}

EsercizioScheda _esercizio(
  Map<dynamic, dynamic> m,
  String dove,
  List<Esercizio> catalogo,
) {
  final id = _testo(m['esercizio'] ?? m['id'], 80);
  final nome = _testo(m['nome'], 60);
  final dalCatalogo = esercizioDelCatalogo(catalogo, id.isEmpty ? nome : id);
  if (id.isNotEmpty && dalCatalogo == null && catalogo.isNotEmpty) {
    throw FormatException(l10n.forzaEsercizioSconosciuto(dove, id));
  }
  if (dalCatalogo == null && nome.isEmpty && id.isEmpty) {
    throw FormatException(l10n.forzaEsercizioSenzaNome(dove));
  }
  final serie = _intero(m['serie']) ?? 3;
  final recupero = _intero(m['recupero_s']) ?? 90;
  final rip = m['ripetizioni'];
  final ripetizioni = rip is num ? '${rip.round()}' : _testo(rip, 20);
  if (serie < 1 || serie > 10 || recupero < 0 || recupero > 600) {
    throw FormatException(l10n.forzaSerieNonValide(dove));
  }
  final kgGrezzi = m['kg'];
  final kg = [
    for (final x in kgGrezzi is List ? kgGrezzi.take(10) : [?kgGrezzi]) ?_kg(x),
  ];
  return EsercizioScheda(
    // I nomi del catalogo si salvano in italiano, come nelle sedute dell'app:
    // a schermo si vedono nella lingua scelta.
    // Senza catalogo (non ancora caricato) l'id resta com'è.
    esercizio: dalCatalogo?.id ?? (catalogo.isEmpty ? id : ''),
    nome: dalCatalogo?.nomeIt ?? (nome.isEmpty ? id : nome),
    serie: serie,
    ripetizioni: ripetizioni.isEmpty ? '10' : ripetizioni,
    recuperoS: recupero,
    kg: kg.every((x) => x == 0) ? const [] : kg,
    note: _testo(m['note'], 200),
  );
}

GiornoScheda _giorno(
  Map<dynamic, dynamic> m,
  String fase,
  int k,
  List<Esercizio> catalogo,
) {
  final nome = _testo(m['nome'], 40).isEmpty
      ? l10n.forzaGiornoN(k + 1)
      : _testo(m['nome'], 40);
  final dove = '$fase, $nome';
  final sett = m['giorni_settimana'] ?? m['giorni'];
  final giorni = <int>{
    for (final x in sett is List ? sett : [?sett])
      if (_intero(x) case final n? when n >= 1 && n <= 7) n,
  };
  final lista = m['esercizi'];
  if (giorni.isEmpty || lista is! List || lista.isEmpty || lista.length > 20) {
    throw FormatException(l10n.forzaGiornoNonValido(dove));
  }
  return GiornoScheda(
    nome: nome,
    giorni: giorni,
    esercizi: [
      for (final (i, e) in lista.indexed)
        if (e is Map) _esercizio(e, '$dove, ${i + 1}', catalogo),
    ],
  );
}

/// Legge la scheda graduale dal JSON dell'assistente. Ogni fase dura
/// "settimane" settimane e, se non ha "inizio", comincia il giorno dopo la
/// fine di quella prima. Con un [catalogo] gli esercizi con un id che non
/// c'è sono un errore, così l'assistente li corregge. Lancia
/// [FormatException] con un messaggio semplice se qualcosa non va.
PropostaForza propostaForzaDa(
  Map<dynamic, dynamic> m, {
  required DateTime oggi,
  List<Esercizio> catalogo = const [],
}) {
  final o = soloData(oggi);
  final nome = _testo(m['nome'], 40).isEmpty
      ? l10n.schedaForzaGraduale
      : _testo(m['nome'], 40);
  final lista = m['fasi'] ?? m['schede'];
  if (lista is! List || lista.isEmpty || lista.length > fasiMaxForza) {
    throw FormatException(l10n.forzaServonoFasi(fasiMaxForza));
  }
  final base = 'sch-${oggi.microsecondsSinceEpoch.toRadixString(36)}';
  final fasi = <Scheda>[];
  for (final (k, x) in lista.indexed) {
    if (x is! Map) continue;
    final nomeFase = _testo(x['nome'], 40).isEmpty
        ? l10n.forzaFaseN(k + 1)
        : _testo(x['nome'], 40);
    final testoInizio = _testo(x['inizio'] ?? x['data'], 20);
    final inizio = testoInizio.isNotEmpty
        ? parseData(testoInizio)
        : fasi.isEmpty
        ? o
        : fasi.last.fine!.add(const Duration(days: 1));
    if (inizio == null) {
      throw FormatException(l10n.forzaInizioNonValido(nomeFase));
    }
    if (inizio.isBefore(o)) {
      throw FormatException(l10n.forzaIniziaPrimaDiOggi(nomeFase));
    }
    if (fasi.isNotEmpty && !inizio.isAfter(fasi.last.fine!)) {
      throw FormatException(l10n.forzaFasiSovrapposte(nomeFase));
    }
    final settimane = _intero(x['settimane']) ?? 0;
    if (settimane < 1 || settimane > settimaneMaxForza) {
      throw FormatException(
        l10n.forzaSettimaneNonValide(nomeFase, settimaneMaxForza),
      );
    }
    final giorni = x['giorni'];
    if (giorni is! List || giorni.isEmpty || giorni.length > 7) {
      throw FormatException(l10n.forzaGiorniNonValidi(nomeFase));
    }
    final letti = [
      for (final (i, g) in giorni.indexed)
        if (g is Map) _giorno(g, nomeFase, i, catalogo),
    ];
    // Un giorno della settimana in due giorni della scheda: varrebbe solo il
    // primo, quindi meglio dirlo.
    final visti = <int>{};
    for (final g in letti) {
      for (final d in g.giorni) {
        if (!visti.add(d)) {
          throw FormatException(
            l10n.forzaGiornoDoppio(nomeFase, giorniSettimana[d - 1]),
          );
        }
      }
    }
    fasi.add(
      Scheda(
        id: '$base-${k + 1}',
        nome: lista.length == 1 ? nome : '$nome · $nomeFase',
        inizio: inizio,
        fine: inizio.add(Duration(days: settimane * 7 - 1)),
        giorni: letti,
      ),
    );
  }
  if (fasi.isEmpty) {
    throw FormatException(l10n.forzaServonoFasi(fasiMaxForza));
  }
  final limite = fasi.first.inizio.add(
    const Duration(days: settimaneMaxForza * 7),
  );
  if (!fasi.last.fine!.isBefore(limite)) {
    throw FormatException(l10n.forzaTroppoLunga(settimaneMaxForza));
  }
  return PropostaForza(nome, _testo(m['motivo'], 400), fasi);
}

/// Le schede con quella nuova al posto delle schede di forza che valgono
/// negli stessi giorni: quelle già iniziate finiscono il giorno prima,
/// quelle che inizierebbero dopo si tolgono. Restituisce anche i nomi di
/// quelle accorciate e tolte, da dire prima di confermare.
({List<Scheda> schede, List<String> accorciate, List<String> tolte})
conPropostaForza(List<Scheda> schede, PropostaForza p) {
  final accorciate = <String>[];
  final tolte = <String>[];
  final out = <Scheda>[];
  final da = p.inizio;
  for (final s in schede) {
    final tocca =
        stessoSport(s.sport, 'Forza') &&
        !s.archiviata &&
        (s.fine == null || !s.fine!.isBefore(da)) &&
        !s.inizio.isAfter(p.fine);
    if (!tocca) {
      out.add(s);
    } else if (s.inizio.isBefore(da)) {
      accorciate.add(s.nome);
      out.add(s.copyWith(fine: () => da.subtract(const Duration(days: 1))));
    } else {
      tolte.add(s.nome);
    }
  }
  return (
    schede: [...out, ...p.fasi]..sort((a, b) => a.inizio.compareTo(b.inizio)),
    accorciate: accorciate,
    tolte: tolte,
  );
}

/// I giorni della settimana della scheda in cui la settimana tipo non ha la
/// forza: lì la scheda non varrebbe, quindi si aggiungono.
List<int> giorniSenzaForza(List<Slot> settimana, PropostaForza p) => [
  for (final d in p.giorniSettimana.toList()..sort())
    if (!settimana.any((s) => s.giorno == d && stessoSport(s.sport, 'Forza')))
      d,
];

String _giornoBreve(int d) => giorniSettimana[d - 1].substring(0, 3);

/// Le righe sulla forza per l'assistente: attrezzatura, giorni di forza
/// della settimana tipo, schede in corso, serie fatte di recente ed esercizi
/// del catalogo fattibili. Così può preparare una scheda graduale che parte
/// da dove si è davvero, con gli esercizi che l'app conosce.
List<String> righeForzaAssistente({
  required DateTime oggi,
  required List<Esercizio> catalogo,
  required Attrezzatura attrezzatura,
  required List<SerieFatta> serie,
  List<Scheda> schede = const [],
  List<Slot> settimana = const [],
}) {
  final o = soloData(oggi);
  final righe = <String>[];
  righe.add(
    attrezzatura.isEmpty
        ? 'Attrezzatura: solo corpo libero'
        : 'Attrezzatura: ${[for (final MapEntry(key: a, value: pesi) in attrezzatura.entries) pesi.isEmpty ? a : '$a (${pesi.map(fmtKg).join(', ')} kg)'].join('; ')}',
  );
  final giorni = {
    for (final s in settimana)
      if (stessoSport(s.sport, 'Forza')) s.giorno,
  }.toList()..sort();
  if (giorni.isNotEmpty) {
    righe.add(
      'Forza nella settimana tipo: ${giorni.map(_giornoBreve).join(', ')}',
    );
  }
  for (final s in schede) {
    if (!stessoSport(s.sport, 'Forza') ||
        s.archiviata ||
        (s.fine != null && s.fine!.isBefore(o))) {
      continue;
    }
    righe.add(
      'Scheda di forza "${s.nome}" dal ${isoData(s.inizio)}'
      '${s.fine == null ? '' : ' al ${isoData(s.fine!)}'}: '
      '${[for (final g in s.giorni) '${g.nome} (${(g.giorni.toList()..sort()).map(_giornoBreve).join(', ')}): ${g.esercizi.map((e) => '${e.esercizio.isEmpty ? e.nome : e.esercizio} ${e.riassunto}').join('; ')}'].join(' | ')}',
    );
  }

  // Le serie delle ultime 6 settimane, una riga per esercizio e giorno.
  final recenti =
      serie
          .where((s) => !s.data.isAfter(o) && o.difference(s.data).inDays < 42)
          .toList()
        ..sort((a, b) {
          final c = a.data.compareTo(b.data);
          return c != 0 ? c : a.serie.compareTo(b.serie);
        });
  final perGiorno = <(DateTime, String), List<SerieFatta>>{};
  for (final s in recenti) {
    (perGiorno[(s.data, s.chiave)] ??= []).add(s);
  }
  righe.add(
    '\nSerie di forza fatte (ultime 6 settimane; id o nome: ripetizioni×kg):',
  );
  if (perGiorno.isEmpty) righe.add('- nessuna');
  final voci = perGiorno.entries.toList();
  for (final e in voci.skip(voci.length > 60 ? voci.length - 60 : 0)) {
    final l = e.value;
    righe.add(
      '- ${_gg(e.key.$1)} ${e.key.$2}: ${l.map((s) => s.aTempo
          ? '${s.secondi} s'
          : s.kg > 0
          ? '${s.ripetizioni}×${fmtKg(s.kg)}'
          : '${s.ripetizioni}').join(', ')}',
    );
  }

  final fattibili = [
    for (final e in catalogo)
      if (e.tipo == 'forza' && e.fattibile(attrezzatura)) e,
  ];
  righe.add(
    '\nEsercizi di forza dell\'app fattibili con l\'attrezzatura '
    '(id: nome, schema, livello):',
  );
  for (final e in fattibili) {
    righe.add('- ${e.id}: ${e.nome}, ${e.schema}, ${e.livello}');
  }
  return righe;
}

String _gg(DateTime d) =>
    '${isoData(d)} ${giorniSettimana[d.weekday - 1].substring(0, 3).toLowerCase()}';

/// Il formato per l'assistente (aggiunto alle istruzioni). [apri] e
/// [chiudi] sono i segni attorno al JSON.
String formatoForza(String apri, String chiudi) =>
    '''Per una scheda di FORZA con esercizi scelti da te, anche graduale (più fasi, ognuna più dura della precedente), usa invece:
```
$apri
{"forza": {"nome": "Forza graduale", "motivo": "...", "fasi": [
  {"nome": "Base", "inizio": "AAAA-MM-GG", "settimane": 2, "giorni": [
    {"nome": "Busto", "giorni_settimana": [1, 4], "esercizi": [
      {"esercizio": "Pushups", "serie": 3, "ripetizioni": "8-10", "recupero_s": 90},
      {"esercizio": "Bent_Over_Two-Dumbbell_Row", "serie": 3, "ripetizioni": "10", "recupero_s": 90, "kg": [12]}
    ]}
  ]},
  {"nome": "Carico", "settimane": 3, "giorni": [
    {"nome": "Busto", "giorni_settimana": [1, 4], "esercizi": [
      {"esercizio": "Pushups", "serie": 4, "ripetizioni": "10-12", "recupero_s": 75},
      {"esercizio": "Bent_Over_Two-Dumbbell_Row", "serie": 4, "ripetizioni": "8", "recupero_s": 120, "kg": [14, 16, 16, 16]}
    ]}
  ]}
]}}
$chiudi
```
"esercizio" è l'id di un esercizio della lista nei miei dati (usa solo quelli); per uno che non c'è scrivi solo "nome". "giorni_settimana": 1 = lunedì … 7 = domenica, meglio quelli in cui ho già la forza nella settimana tipo. "ripetizioni" un numero, un intervallo ("8-10") o un tempo ("30 s"); "kg" uno per tutte le serie o uno per serie (lascialo fuori a corpo libero). "settimane" da 1 a $settimaneMaxForza; senza "inizio" una fase comincia il giorno dopo la fine di quella prima. Al massimo $fasiMaxForza fasi e $settimaneMaxForza settimane in tutto. Parti dalle serie che ho fatto davvero e aumenta poco per volta (ripetizioni, serie o kg). La scheda prende il posto delle schede di forza in quei giorni e delle sedute di forza preparate dall'app.''';
