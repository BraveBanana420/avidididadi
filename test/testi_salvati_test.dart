import 'dart:convert';
import 'dart:io';

import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/l10n/lingua.dart';
import 'package:allenamenti_app/l10n/testi_salvati.dart';
import 'package:allenamenti_app/l10n/vocabolario.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il piano creato con l'app in italiano e poi visto in greco (o inglese):
/// i testi salvati nei CSV si devono vedere nella lingua scelta.
void main() {
  setUpAll(() {
    // Come caricaEsercizi(), senza gli asset.
    final dati =
        json.decode(File('assets/esercizi.json').readAsStringSync()) as List;
    for (final j in dati) {
      final e = Esercizio.da(j as Map<String, dynamic>);
      registraNomeEsercizio(e.nomeIt, {'en': e.nomeEn, 'el': e.nomeEl});
    }
  });
  tearDown(() => usaLingua('it'));

  test('il titolo della forza con la settimana', () {
    usaLingua('el');
    expect(
      mostra('Corpo intero B · settimana 1 di 4'),
      'Όλο το σώμα B · εβδομάδα 1 από 4',
    );
    usaLingua('en');
    expect(mostra('Parte alta · settimana 3 di 4'), 'Upper body · week 3 of 4');
  });

  test('i nomi degli esercizi del catalogo', () {
    usaLingua('el');
    expect(
      mostra('Circonduzioni delle braccia'),
      isNot('Circonduzioni delle braccia'),
    );
    expect(mostra('Piegamenti sulle braccia'), 'Κάμψεις');
  });

  test('le sezioni e le fasce della seduta', () {
    usaLingua('el');
    expect(maiuscole(mostra('riscaldamento')), 'ΖΕΣΤΑΜΑ');
    expect(maiuscole(mostra('principale')), 'ΚΥΡΙΟ ΜΕΡΟΣ');
    expect(mostra('Mattina'), 'Πρωί');
    expect(mostra('Intervalli'), 'Διαλειμματικά');
  });

  test('le note fatte di più frasi', () {
    usaLingua('el');
    expect(
      mostraTesto(
        'Settimana 2: una ripetizione in più rispetto alla scorsa. '
        'Gambe leggere: domani hai il Lungo.',
      ),
      allOf(isNot(contains('Settimana')), contains('η Μεγάλη απόσταση')),
    );
  });

  test('in italiano i testi restano come sono', () {
    usaLingua('it');
    expect(
      mostra('Corpo intero B · settimana 1 di 4'),
      'Corpo intero B · settimana 1 di 4',
    );
    expect(
      mostraTesto('Mangia e bevi ogni 30-45 minuti.'),
      'Mangia e bevi ogni 30-45 minuti.',
    );
  });

  test('ogni testo salvato ha le traduzioni con gli stessi segnaposto', () {
    Set<String> segni(String s) => {
      for (final m in RegExp(r'\{p\d\}').allMatches(s)) m[0]!,
    };
    for (final (it, en, el) in testiSalvati) {
      expect(segni(en), segni(it), reason: it);
      expect(segni(el), segni(it), reason: it);
    }
  });

  test('le maiuscole greche non hanno accenti', () {
    expect(maiuscole('Αποθεραπεία'), 'ΑΠΟΘΕΡΑΠΕΙΑ');
    expect(maiuscole('mobilità'), 'MOBILITÀ');
  });
}
