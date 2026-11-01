import 'dart:io';

import 'package:allenamenti_app/rete.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Uri base;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = Uri.parse('http://127.0.0.1:${server.port}');
    server.listen((req) async {
      final r = req.response;
      switch (req.uri.path) {
        case '/foto.jpg':
          r.headers.contentType = ContentType('image', 'jpeg');
          r.add(List.filled(1000, 1));
        case '/grande.jpg':
          r.headers.contentType = ContentType('image', 'jpeg');
          // Senza dimensione dichiarata: il limite scatta mentre arriva.
          r.headers.chunkedTransferEncoding = true;
          for (var k = 0; k < 20; k++) {
            r.add(List.filled(1000, 1));
          }
        case '/accesso':
          // La pagina di login di un Wi-Fi pubblico.
          r.headers.contentType = ContentType.html;
          r.write('<html>Accedi al Wi-Fi</html>');
        case '/lento.jpg':
          r.headers.contentType = ContentType('image', 'jpeg');
          await Future<void>.delayed(const Duration(seconds: 3));
          r.add([1, 2, 3]);
        default:
          r.statusCode = 404;
      }
      await r.close();
    });
  });

  tearDown(() => server.close(force: true));

  test('un\'immagine piccola arriva intera', () async {
    final d = await scaricaLimitato(
      base.resolve('/foto.jpg'),
      maxByte: 5000,
      tipo: 'image/',
    );
    expect(d, hasLength(1000));
  });

  test('oltre il limite: niente', () async {
    expect(
      await scaricaLimitato(base.resolve('/grande.jpg'), maxByte: 5000),
      isNull,
    );
  });

  test('una pagina al posto dell\'immagine: niente', () async {
    expect(
      await scaricaLimitato(
        base.resolve('/accesso'),
        maxByte: 5000,
        tipo: 'image/',
      ),
      isNull,
    );
  });

  test('troppo lento: niente, senza restare appeso', () async {
    final prima = DateTime.now();
    expect(
      await scaricaLimitato(
        base.resolve('/lento.jpg'),
        maxByte: 5000,
        tempo: const Duration(milliseconds: 500),
      ),
      isNull,
    );
    expect(DateTime.now().difference(prima).inSeconds, lessThan(2));
  });

  test('errore del server: niente', () async {
    expect(
      await scaricaLimitato(base.resolve('/manca'), maxByte: 5000),
      isNull,
    );
  });
}
