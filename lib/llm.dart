import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'assistente.dart';
import 'l10n/lingua.dart';

/// Chiavi API nell'archivio cifrato del telefono, una per fornitore. Non
/// finiscono mai nei CSV né nei backup dei dati.
class ChiaviAssistente {
  static const _archivio = FlutterSecureStorage();

  static String _nome(Fornitore f) => 'chiave_${f.name}';

  static Future<String?> leggi(Fornitore f) async {
    try {
      final v = await _archivio.read(key: _nome(f));
      return v == null || v.isEmpty ? null : v;
    } catch (_) {
      return null; // archivio illeggibile (per esempio dopo un ripristino)
    }
  }

  static Future<void> salva(Fornitore f, String chiave) =>
      _archivio.write(key: _nome(f), value: chiave.trim());

  static Future<void> elimina(Fornitore f) => _archivio.delete(key: _nome(f));
}

/// Indirizzo di Ollama senza la barra finale. In chiaro (http) solo verso la
/// rete di casa: su internet i dati viaggerebbero leggibili, serve https.
String baseOllama(ConfigAssistente c) {
  final base = c.urlOllama.trim().replaceAll(RegExp(r'/+$'), '');
  final u = Uri.tryParse(base);
  if (u == null ||
      u.host.isEmpty ||
      (u.scheme != 'http' && u.scheme != 'https')) {
    throw ErroreLlm(l10n.indirizzoOllamaNonValido);
  }
  if (u.scheme == 'http' && !retePrivata(u.host)) {
    throw ErroreLlm(l10n.proteggereTuoiDatiIndirizzo);
  }
  return base;
}

/// Indirizzi della rete locale (casa, Wi-Fi, VPN tipo Tailscale) e nomi locali.
bool retePrivata(String host) {
  final h = host.toLowerCase();
  if (h == 'localhost' ||
      h.endsWith('.local') ||
      h.endsWith('.lan') ||
      h.endsWith('.home.arpa')) {
    return true;
  }
  final n = h.split('.').map(int.tryParse).toList();
  if (n.length != 4 || n.any((x) => x == null || x > 255)) return false;
  final a = n[0]!, b = n[1]!;
  return a == 10 ||
      a == 127 ||
      (a == 192 && b == 168) ||
      (a == 172 && b >= 16 && b <= 31) ||
      (a == 169 && b == 254) ||
      (a == 100 && b >= 64 && b <= 127);
}

/// Una chiamata HTTP pronta da inviare.
class RichiestaLlm {
  final Uri url;
  final Map<String, String> intestazioni;
  final Map<String, dynamic> corpo;
  const RichiestaLlm(this.url, this.intestazioni, this.corpo);
}

/// Prepara la richiesta per il fornitore scelto: [sistema] sono le istruzioni
/// con i dati, [storia] la conversazione (l'ultimo messaggio è dell'utente).
RichiestaLlm richiestaPer(
  ConfigAssistente c,
  String? chiave,
  String sistema,
  List<MessaggioChat> storia,
) {
  final k = chiave ?? '';
  switch (c.fornitore) {
    case Fornitore.claude:
      return RichiestaLlm(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        {'x-api-key': k, 'anthropic-version': '2023-06-01'},
        {
          'model': c.modello,
          // Un piano di più settimane o un allenamento lungo occupano spazio.
          'max_tokens': 4096,
          'system': sistema,
          'messages': [
            for (final m in storia)
              {'role': m.utente ? 'user' : 'assistant', 'content': m.testo},
          ],
        },
      );
    case Fornitore.openai:
      return RichiestaLlm(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        {'Authorization': 'Bearer $k'},
        {
          'model': c.modello,
          'messages': [
            {'role': 'system', 'content': sistema},
            for (final m in storia)
              {'role': m.utente ? 'user' : 'assistant', 'content': m.testo},
          ],
        },
      );
    case Fornitore.gemini:
      return RichiestaLlm(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/'
          '${Uri.encodeComponent(c.modello)}:generateContent',
        ),
        {'x-goog-api-key': k},
        {
          'systemInstruction': {
            'parts': [
              {'text': sistema},
            ],
          },
          'contents': [
            for (final m in storia)
              {
                'role': m.utente ? 'user' : 'model',
                'parts': [
                  {'text': m.testo},
                ],
              },
          ],
        },
      );
    case Fornitore.ollama:
      final base = baseOllama(c);
      return RichiestaLlm(Uri.parse('$base/api/chat'), const {}, {
        'model': c.modello,
        'stream': false,
        'messages': [
          {'role': 'system', 'content': sistema},
          for (final m in storia)
            {'role': m.utente ? 'user' : 'assistant', 'content': m.testo},
        ],
      });
  }
}

/// Il testo della risposta, dal JSON restituito dal fornitore.
String testoRisposta(Fornitore f, Map<String, dynamic> j) {
  String? testo;
  switch (f) {
    case Fornitore.claude:
      final c = j['content'];
      if (c is List) {
        testo = c
            .whereType<Map>()
            .where((x) => x['type'] == 'text')
            .map((x) => '${x['text']}')
            .join('\n');
      }
    case Fornitore.openai:
      final c = j['choices'];
      if (c is List && c.isNotEmpty) {
        testo = '${c.first['message']?['content']}';
      }
    case Fornitore.gemini:
      final c = j['candidates'];
      if (c is List && c.isNotEmpty) {
        final parts = c.first['content']?['parts'];
        if (parts is List) {
          testo = parts.map((p) => '${p['text'] ?? ''}').join();
        }
      }
    case Fornitore.ollama:
      testo = j['message']?['content']?.toString();
  }
  if (testo == null || testo.trim().isEmpty || testo == 'null') {
    throw ErroreLlm(l10n.rispostaVuotaDalModello);
  }
  return testo.trim();
}

class ErroreLlm implements Exception {
  final String messaggio;
  const ErroreLlm(this.messaggio);
  @override
  String toString() => messaggio;
}

/// Messaggio comprensibile per un errore HTTP.
String spiegaErrore(Fornitore f, int stato, String corpo) {
  final dettaglio = () {
    try {
      final j = jsonDecode(corpo);
      final e = j is Map ? j['error'] : null;
      if (e is Map && e['message'] != null) return '${e['message']}';
      if (e is String) return e;
    } catch (_) {}
    return corpo.length > 200 ? '${corpo.substring(0, 200)}…' : corpo;
  }();
  final d = dettaglio.toLowerCase();
  // Gemini risponde 400 anche per una chiave sbagliata: lo si capisce dal testo.
  if (d.contains('api key') || d.contains('api_key')) {
    return l10n.chiaveApiNonValida3(dettaglio);
  }
  final base = switch (stato) {
    400 => l10n.richiestaRifiutataControllaNome,
    401 || 403 => l10n.chiaveApiNonValida4,
    404 =>
      f == Fornitore.ollama
          ? l10n.modelloNonTrovatoSu
          : l10n.modelloNonTrovatoControlla,
    429 => l10n.limiteRichiesteRaggiuntoO,
    >= 500 => l10n.servizioHaProblemaQuesto,
    _ => l10n.errore2(stato),
  };
  return dettaglio.isEmpty ? base : '$base\n($dettaglio)';
}

/// Richiesta dell'elenco dei modelli disponibili con quella chiave (gratis).
RichiestaLlm richiestaModelli(ConfigAssistente c, String? chiave) {
  final k = chiave ?? '';
  return switch (c.fornitore) {
    Fornitore.claude => RichiestaLlm(
      Uri.parse('https://api.anthropic.com/v1/models?limit=100'),
      {'x-api-key': k, 'anthropic-version': '2023-06-01'},
      const {},
    ),
    Fornitore.openai => RichiestaLlm(
      Uri.parse('https://api.openai.com/v1/models'),
      {'Authorization': 'Bearer $k'},
      const {},
    ),
    Fornitore.gemini => RichiestaLlm(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?pageSize=200',
      ),
      {'x-goog-api-key': k},
      const {},
    ),
    Fornitore.ollama => RichiestaLlm(
      Uri.parse('${baseOllama(c)}/api/tags'),
      const {},
      const {},
    ),
  };
}

final _nonChat = RegExp(
  r'embed|image|imagen|tts|audio|realtime|transcribe|moderation|whisper|dall-e|'
  r'aqa|veo|search|computer-use|robotics|live',
);

/// Modelli di chat dalla risposta dell'elenco, per fornitore.
List<String> modelliDa(Fornitore f, Map<String, dynamic> j) {
  switch (f) {
    case Fornitore.ollama:
      return modelliOllama(j);
    case Fornitore.gemini:
      return [
        for (final m in (j['models'] as List? ?? const []))
          if (m is Map &&
              (m['supportedGenerationMethods'] as List? ?? const []).contains(
                'generateContent',
              ))
            '${m['name']}'.replaceFirst('models/', ''),
      ].where((n) => n.startsWith('gemini') && !_nonChat.hasMatch(n)).toList();
    case Fornitore.openai:
    case Fornitore.claude:
      return [
        for (final m in (j['data'] as List? ?? const []))
          if (m is Map && m['id'] != null) '${m['id']}',
      ].where((n) {
        if (_nonChat.hasMatch(n)) return false;
        return f == Fornitore.claude
            ? n.startsWith('claude')
            : n.startsWith('gpt') || RegExp(r'^o\d').hasMatch(n);
      }).toList();
  }
}

List<int> _versione(String nome) => [
  for (final m in RegExp(r'\d+').allMatches(nome)) int.parse(m.group(0)!),
];

int _confronta(List<int> a, List<int> b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) return a[i].compareTo(b[i]);
  }
  return a.length.compareTo(b.length);
}

/// Il modello da usare se l'utente non ne ha scelto uno: il più recente della
/// famiglia veloce ed economica (flash, mini, sonnet), stabile se possibile.
String? modelloConsigliato(Fornitore f, List<String> modelli) {
  if (modelli.isEmpty) return null;
  if (f == Fornitore.ollama) return modelli.first;
  final famiglia = switch (f) {
    Fornitore.gemini => 'flash',
    Fornitore.openai => 'mini',
    _ => 'sonnet',
  };
  bool sperimentale(String n) =>
      RegExp(r'preview|exp|lite|thinking|nano|latest').hasMatch(n);
  for (final filtro in [
    (String n) => n.contains(famiglia) && !sperimentale(n),
    (String n) => n.contains(famiglia),
    (String n) => true,
  ]) {
    final c = modelli.where(filtro).toList()
      ..sort((a, b) => _confronta(_versione(b), _versione(a)));
    if (c.isNotEmpty) return c.first;
  }
  return null;
}

/// Elenco dei modelli disponibili con la chiave: verifica anche la chiave.
Future<List<String>> modelliDisponibili(
  ConfigAssistente c,
  String? chiave,
) async {
  if (serveChiave(c.fornitore) && (chiave == null || chiave.isEmpty)) {
    throw ErroreLlm(l10n.mancaChiaveApiAggiungila);
  }
  final r = richiestaModelli(c, chiave);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  try {
    final req = await client.getUrl(r.url);
    r.intestazioni.forEach(req.headers.set);
    final res = await req.close().timeout(const Duration(seconds: 20));
    final corpo = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      throw ErroreLlm(spiegaErrore(c.fornitore, res.statusCode, corpo));
    }
    return modelliDa(c.fornitore, jsonDecode(corpo) as Map<String, dynamic>);
  } on SocketException catch (e) {
    throw ErroreLlm(
      c.fornitore == Fornitore.ollama
          ? l10n.nonRiescoRaggiungereOllama(c.urlOllama, e.message)
          : l10n.nessunaConnessioneInternet2(e.message),
    );
  } on TimeoutException {
    throw ErroreLlm(l10n.servizioNonRispondeRiprova);
  } on FormatException {
    throw ErroreLlm(l10n.rispostaNonLeggibile);
  } on ArgumentError {
    throw ErroreLlm(l10n.indirizzoNonValido);
  } finally {
    client.close();
  }
}

/// Nomi dei modelli dalla risposta di Ollama a /api/tags.
List<String> modelliOllama(Map<String, dynamic> j) => [
  for (final m in (j['models'] as List? ?? const []))
    if (m is Map && m['name'] != null) '${m['name']}',
];

/// Il modello scelto c'è tra quelli installati? "llama3.1" vale anche per
/// "llama3.1:latest".
bool modelloPresente(String modello, List<String> installati) =>
    installati.contains(modello) || installati.contains('$modello:latest');

/// Controlla che il servizio risponda. Prima l'elenco dei modelli (gratis):
/// verifica la chiave e che il modello esista. Se il campo del modello è vuoto
/// e quello predefinito non c'è più, restituisce il modello consigliato da
/// usare. Per i servizi online poi una domanda minima, per il credito.
Future<String?> verificaConnessione(ConfigAssistente c, String? chiave) async {
  if (c.fornitore != Fornitore.ollama) {
    final disponibili = await modelliDisponibili(c, chiave);
    String? nuovo;
    if (disponibili.isNotEmpty && !modelloPresente(c.modello, disponibili)) {
      final scelto = (c.modelli[c.fornitore] ?? '').isNotEmpty;
      final consigliato = modelloConsigliato(c.fornitore, disponibili);
      if (scelto || consigliato == null) {
        throw ErroreLlm(
          l10n.chiaveFunzionaMaModello(
            c.modello,
            consigliato == null ? '' : l10n.esempio(consigliato),
          ),
        );
      }
      nuovo = consigliato;
      c.modelli[c.fornitore] = consigliato;
    }
    await chiediAssistente(c, chiave, 'Rispondi solo con la parola OK.', [
      MessaggioChat(true, l10n.provaConnessione),
    ]);
    return nuovo;
  }
  final base = baseOllama(c);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  try {
    final req = await client.getUrl(Uri.parse('$base/api/tags'));
    final res = await req.close().timeout(const Duration(seconds: 10));
    final corpo = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      throw ErroreLlm(spiegaErrore(c.fornitore, res.statusCode, corpo));
    }
    final installati = modelliOllama(jsonDecode(corpo) as Map<String, dynamic>);
    if (!modelloPresente(c.modello, installati)) {
      throw ErroreLlm(
        l10n.ollamaRispondeMaModello(
          c.modello,
          installati.isEmpty ? l10n.parolaNessuno : installati.join(', '),
        ),
      );
    }
    return null;
  } on SocketException catch (e) {
    throw ErroreLlm(l10n.nonRiescoRaggiungereOllama2(c.urlOllama, e.message));
  } on TimeoutException {
    throw ErroreLlm(l10n.ollamaNonRispondePc);
  } on FormatException {
    throw ErroreLlm(l10n.indirizzoNonValidoO);
  } on ArgumentError {
    throw ErroreLlm(l10n.indirizzoNonValidoScrivilo);
  } finally {
    client.close();
  }
}

/// Invia la conversazione e restituisce il testo della risposta.
Future<String> chiediAssistente(
  ConfigAssistente c,
  String? chiave,
  String sistema,
  List<MessaggioChat> storia,
) async {
  if (serveChiave(c.fornitore) && (chiave == null || chiave.isEmpty)) {
    throw ErroreLlm(l10n.mancaChiaveApiAggiungila2);
  }
  final r = richiestaPer(c, chiave, sistema, storia);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final req = await client.postUrl(r.url);
    req.headers.contentType = ContentType.json;
    r.intestazioni.forEach(req.headers.set);
    req.add(utf8.encode(jsonEncode(r.corpo)));
    final res = await req.close().timeout(
      Duration(seconds: c.fornitore == Fornitore.ollama ? 300 : 120),
    );
    final corpo = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      throw ErroreLlm(spiegaErrore(c.fornitore, res.statusCode, corpo));
    }
    final j = jsonDecode(corpo);
    if (j is! Map<String, dynamic>) {
      throw ErroreLlm(l10n.rispostaNonLeggibile);
    }
    return testoRisposta(c.fornitore, j);
  } on SocketException catch (e) {
    throw ErroreLlm(
      c.fornitore == Fornitore.ollama
          ? l10n.nonRiescoRaggiungereOllama3(c.urlOllama, e.message)
          : l10n.nessunaConnessioneInternet2(e.message),
    );
  } on TimeoutException {
    throw ErroreLlm(l10n.modelloCiStaMettendo);
  } on FormatException {
    throw ErroreLlm(l10n.rispostaNonLeggibile);
  } finally {
    client.close();
  }
}
