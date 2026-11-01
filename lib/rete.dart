import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// Scarica [url] con dei limiti: entro [tempo] (connessione compresa), al
/// massimo [maxByte], e solo se il tipo comincia con [tipo] (per esempio
/// "image/": un Wi-Fi pubblico che risponde con la sua pagina di accesso non
/// lascia un'immagine rotta). Null se qualcosa non va.
Future<Uint8List?> scaricaLimitato(
  Uri url, {
  required int maxByte,
  String? tipo,
  Duration tempo = const Duration(seconds: 20),
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  Future<Uint8List?> scarica() async {
    final res = await (await client.getUrl(url)).close();
    if (res.statusCode != 200) return null;
    final mime = res.headers.contentType?.mimeType ?? '';
    if (tipo != null && !mime.startsWith(tipo)) return null;
    if (res.contentLength > maxByte) return null;
    final dati = BytesBuilder(copy: false);
    await for (final pezzo in res) {
      if (dati.length + pezzo.length > maxByte) return null;
      dati.add(pezzo);
    }
    return dati.takeBytes();
  }

  try {
    return await scarica().timeout(tempo);
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}
