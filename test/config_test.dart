import 'dart:io';

import 'package:allenamenti_app/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('il link delle donazioni è quello vero, non un segnaposto', () {
    // Nella prima 1.0.0 era rimasto example.org: non deve tornare.
    final uri = Uri.parse(urlDonazioni);
    expect(uri.scheme, 'https');
    expect(uri.host, 'ko-fi.com');
    expect(urlDonazioni, isNot(contains('example')));
  });

  test('app, GitHub e README puntano alla stessa pagina Ko-fi', () {
    final nome = Uri.parse(urlDonazioni).pathSegments.single;
    expect(
      File('.github/FUNDING.yml').readAsStringSync(),
      contains('ko_fi: $nome'),
    );
    for (final readme in ['README.md', 'README.it.md']) {
      expect(File(readme).readAsStringSync(), contains(urlDonazioni));
    }
  });

  test('il codice sorgente è il repository GitHub', () {
    expect(urlRepository, startsWith('https://github.com/'));
  });
}
