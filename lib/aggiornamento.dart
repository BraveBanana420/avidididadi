import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'config.dart';
import 'rete.dart';

// Aggiornamenti dall'interno dell'app, senza passare da Obtainium: al massimo
// una volta al giorno l'app chiede a GitHub l'ultima release pubblicata su
// main. Se è più nuova, propone di scaricarla: l'APK va nella cache privata
// dell'app (mai in Download), si controlla con SHA256SUMS.txt della release,
// passa all'installatore di Android e si cancella subito.

const _canale = MethodChannel('avidididadi/avvio');

/// Ultima release pubblicata (le bozze e le pre-release non compaiono qui).
final urlUltimaRelease = Uri.parse(
  '${urlRepository.replaceFirst('https://github.com/', 'https://api.github.com/repos/')}'
  '/releases/latest',
);

/// Ogni quanto si chiede a GitHub, al massimo.
const intervalloControllo = Duration(hours: 20);

/// Un APK più grande di così non è nostro (oggi arm64 pesa ~32 MB).
const maxByteApk = 150 * 1024 * 1024;

/// Se cercare gli aggiornamenti all'apertura: acceso di serie, si spegne dal
/// Profilo. Salvato in aggiornamenti.txt.
final aggiornamentiAttivi = ValueNotifier<bool>(true);

/// Esito dell'installatore di Android (passa dal canale nativo), quando
/// l'installazione non va a buon fine. Se riesce, Android chiude l'app.
void Function(String esito)? esitoAggiornamento;

/// I tre numeri di "1.2.3", "v1.2.3" o "1.2.3+35"; null se non è una versione.
List<int>? numeriVersione(String testo) {
  final m = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)').firstMatch(testo.trim());
  if (m == null) return null;
  return [for (var i = 1; i <= 3; i++) int.parse(m.group(i)!)];
}

/// Se [remota] è più nuova di [installata] (MAJOR, poi MINOR, poi PATCH).
/// Il numero di build non conta: gli APK di prova di staging hanno la stessa
/// versione dell'ultima release e non devono proporre aggiornamenti.
bool piuNuova(String remota, String installata) {
  final r = numeriVersione(remota);
  final i = numeriVersione(installata);
  if (r == null || i == null) return false;
  for (var k = 0; k < 3; k++) {
    if (r[k] != i[k]) return r[k] > i[k];
  }
  return false;
}

/// Una release da proporre: versione, novità e i due file da scaricare.
class Rilascio {
  final String versione;
  final List<String> novita;
  final String nomeApk;
  final Uri apk;
  final Uri somme;
  const Rilascio({
    required this.versione,
    required this.novita,
    required this.nomeApk,
    required this.apk,
    required this.somme,
  });
}

/// La release dalla risposta di GitHub, con l'APK per [abi] (es.
/// "arm64-v8a"). Null se manca qualcosa: meglio nessun avviso che uno che
/// non porta da nessuna parte.
Rilascio? rilascioDa(Map<String, dynamic> j, String abi) {
  if (j['draft'] == true || j['prerelease'] == true) return null;
  final tag = j['tag_name'];
  if (tag is! String || numeriVersione(tag) == null) return null;
  final versione = tag.startsWith('v') ? tag.substring(1) : tag;
  final nomeApk = 'Avidididadi-$versione-$abi.apk';
  Uri? apk, somme;
  for (final a in (j['assets'] as List?) ?? const []) {
    if (a is! Map) continue;
    final url = a['browser_download_url'];
    if (url is! String || !url.startsWith('https://github.com/')) continue;
    if (a['name'] == nomeApk) apk = Uri.parse(url);
    if (a['name'] == 'SHA256SUMS.txt') somme = Uri.parse(url);
  }
  if (apk == null || somme == null) return null;
  return Rilascio(
    versione: versione,
    novita: novitaDa(j['body'] is String ? j['body'] as String : ''),
    nomeApk: nomeApk,
    apk: apk,
    somme: somme,
  );
}

/// Le righe "- ..." delle note (la sezione del CHANGELOG), senza il segno.
List<String> novitaDa(String note) => [
  for (final r in const LineSplitter().convert(note))
    if (r.trimLeft().startsWith('- ')) r.trimLeft().substring(2).trim(),
];

/// L'impronta SHA-256 di [nome] in un file come quello di `sha256sum`.
String? impronta(String somme, String nome) {
  for (final r in const LineSplitter().convert(somme)) {
    final m = RegExp(r'^([0-9a-fA-F]{64})\s+\*?(.+)$').firstMatch(r.trim());
    if (m != null && m.group(2)!.trim() == nome) {
      return m.group(1)!.toLowerCase();
    }
  }
  return null;
}

/// Se è ora di chiedere di nuovo a GitHub (anche se l'orologio è tornato
/// indietro).
bool daControllare(DateTime? ultimo, DateTime ora) =>
    ultimo == null ||
    ora.isBefore(ultimo) ||
    ora.difference(ultimo) >= intervalloControllo;

/// Il contenuto di aggiornamenti.txt: "attivo=1" e "ultimo=<data ISO>".
String testoImpostazioni(bool attivo, DateTime? ultimo) => [
  'attivo=${attivo ? 1 : 0}',
  if (ultimo != null) 'ultimo=${ultimo.toIso8601String()}',
].join('\n');

/// Il contrario di [testoImpostazioni]: attivo se non c'è scritto il contrario.
(bool, DateTime?) leggiImpostazioni(String testo) {
  var attivo = true;
  DateTime? ultimo;
  for (final r in const LineSplitter().convert(testo)) {
    final i = r.indexOf('=');
    if (i < 0) continue;
    final v = r.substring(i + 1).trim();
    switch (r.substring(0, i).trim()) {
      case 'attivo':
        attivo = v != '0';
      case 'ultimo':
        ultimo = DateTime.tryParse(v);
    }
  }
  return (attivo, ultimo);
}

// ---------- telefono e rete ----------

DateTime? _ultimoControllo;

Future<File> _fileImpostazioni() async => File(
  '${(await getApplicationDocumentsDirectory()).path}/aggiornamenti.txt',
);

Future<void> _salva() async {
  try {
    await (await _fileImpostazioni()).writeAsString(
      testoImpostazioni(aggiornamentiAttivi.value, _ultimoControllo),
    );
  } catch (_) {
    // non salvato: al prossimo avvio si controlla di nuovo, niente di grave
  }
}

/// Legge aggiornamenti.txt all'avvio.
Future<void> caricaAggiornamenti() async {
  try {
    final f = await _fileImpostazioni();
    if (await f.exists()) {
      final (attivo, ultimo) = leggiImpostazioni(await f.readAsString());
      aggiornamentiAttivi.value = attivo;
      _ultimoControllo = ultimo;
    }
  } catch (_) {
    // file illeggibile: restano le impostazioni di serie
  }
}

/// Accende o spegne il controllo all'apertura.
Future<void> impostaAggiornamenti(bool attivo) async {
  aggiornamentiAttivi.value = attivo;
  await _salva();
}

/// Esito di una ricerca fatta a mano dal Profilo.
enum EsitoRicerca { nuova, ultima, nessunaRisposta }

/// Cerca una versione più nuova di quella installata. All'apertura
/// ([forza] falso) solo se il controllo è acceso e non è già stato fatto da
/// poco; dal Profilo ([forza] vero) sempre.
Future<(EsitoRicerca, Rilascio?)> cercaAggiornamento({
  bool forza = false,
}) async {
  if (!forza &&
      (!aggiornamentiAttivi.value ||
          !daControllare(_ultimoControllo, DateTime.now()))) {
    return (EsitoRicerca.ultima, null);
  }
  final dati = await scaricaLimitato(
    urlUltimaRelease,
    maxByte: 512 * 1024,
    tipo: 'application/json',
  );
  if (dati == null) return (EsitoRicerca.nessunaRisposta, null);
  _ultimoControllo = DateTime.now();
  await _salva();
  try {
    final abi = await _canale.invokeMethod<String>('abiTelefono') ?? '';
    final installata = (await PackageInfo.fromPlatform()).version;
    final j = jsonDecode(utf8.decode(dati));
    final r = j is Map<String, dynamic> ? rilascioDa(j, abi) : null;
    if (r == null || !piuNuova(r.versione, installata)) {
      return (EsitoRicerca.ultima, null);
    }
    return (EsitoRicerca.nuova, r);
  } catch (_) {
    return (EsitoRicerca.nessunaRisposta, null);
  }
}

/// Perché il download non è andato.
enum ErroreScarico { rete, impronta, annullato }

/// Il download in corso: [annulla] lo ferma e cancella il file a metà.
class Scarico {
  bool _annullato = false;
  HttpClient? _client;

  void annulla() {
    _annullato = true;
    _client?.close(force: true);
  }
}

/// Cartella dell'APK scaricato, dentro la cache dell'app.
Future<Directory> _cartella() async =>
    Directory('${(await getTemporaryDirectory()).path}/aggiornamento');

/// Toglie gli APK rimasti (download interrotto, installazione annullata).
/// Si chiama a ogni avvio: così sul telefono non resta mai niente.
Future<void> pulisciAggiornamenti() async {
  try {
    final d = await _cartella();
    if (await d.exists()) await d.delete(recursive: true);
  } catch (_) {
    // ci riprova al prossimo avvio
  }
}

/// Scarica l'APK di [r] nella cache e controlla che sia identico a quello
/// pubblicato. [avanzamento] va da 0 a 1 (null se GitHub non dice quanto pesa).
Future<(File?, ErroreScarico?)> scaricaApk(
  Rilascio r,
  Scarico s, {
  void Function(double? parte)? avanzamento,
}) async {
  await pulisciAggiornamenti();
  final somme = await scaricaLimitato(r.somme, maxByte: 16 * 1024);
  final attesa = somme == null ? null : impronta(utf8.decode(somme), r.nomeApk);
  if (attesa == null) {
    return (null, s._annullato ? ErroreScarico.annullato : ErroreScarico.rete);
  }
  final d = await _cartella();
  await d.create(recursive: true);
  final file = File('${d.path}/${r.nomeApk}');
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  s._client = client;
  IOSink? uscita;
  try {
    final res = await (await client.getUrl(r.apk)).close();
    if (res.statusCode != 200 || res.contentLength > maxByteApk) {
      throw const HttpException('risposta inattesa');
    }
    final totale = res.contentLength;
    final hash = _Raccogli();
    final calcolo = sha256.startChunkedConversion(hash);
    uscita = file.openWrite();
    var letti = 0;
    await for (final pezzo in res.timeout(const Duration(seconds: 30))) {
      if (s._annullato) break;
      letti += pezzo.length;
      if (letti > maxByteApk) throw const HttpException('troppo grande');
      calcolo.add(pezzo);
      uscita.add(pezzo);
      avanzamento?.call(totale > 0 ? letti / totale : null);
    }
    await uscita.close();
    uscita = null;
    if (s._annullato) throw const HttpException('annullato');
    calcolo.close();
    if (hash.valore.toString() != attesa) {
      await pulisciAggiornamenti();
      return (null, ErroreScarico.impronta);
    }
    return (file, null);
  } catch (_) {
    await uscita?.close().catchError((_) {});
    await pulisciAggiornamenti();
    return (null, s._annullato ? ErroreScarico.annullato : ErroreScarico.rete);
  } finally {
    client.close(force: true);
  }
}

/// Raccoglie l'impronta calcolata a pezzi.
class _Raccogli implements Sink<Digest> {
  Digest? _valore;
  Digest get valore => _valore!;
  @override
  void add(Digest data) => _valore = data;
  @override
  void close() {}
}

/// Esito della consegna all'installatore di Android.
enum EsitoInstallazione { avviata, permessoNegato, errore }

/// Passa l'APK all'installatore di Android, che chiede conferma. La parte
/// nativa lo copia nella sessione di installazione e cancella il file: da
/// lì in poi la copia la tiene (e poi la toglie) Android.
Future<EsitoInstallazione> installaApk(File apk) async {
  try {
    final esito = await _canale.invokeMethod<String>(
      'installaAggiornamento',
      apk.path,
    );
    return switch (esito) {
      'avviata' => EsitoInstallazione.avviata,
      'permesso' => EsitoInstallazione.permessoNegato,
      _ => EsitoInstallazione.errore,
    };
  } catch (_) {
    return EsitoInstallazione.errore;
  } finally {
    await pulisciAggiornamenti();
  }
}
