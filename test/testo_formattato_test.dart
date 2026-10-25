import 'package:allenamenti_app/screens/testo_formattato.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _risposta = '''## Settimana

Hai fatto **4 sedute** su 5, *ottimo*.

- Corsa: **Lungo** 70 min
  - ritmo `5:40/km`
- Nuoto: tecnica

1. Riposo lunedì
2) Fartlek giovedì

> Ascolta le gambe.

| Giorno | Seduta |
|---|:---:|
| Mar | Corsa |
| Gio | Forza |

---
Fine.''';

void main() {
  test('divide la risposta in blocchi', () {
    final b = leggiBlocchi(_risposta);
    final tipi = [for (final x in b) x.tipo];
    expect(tipi, [
      TipoBloccoMd.titolo,
      TipoBloccoMd.paragrafo,
      TipoBloccoMd.elenco,
      TipoBloccoMd.elenco,
      TipoBloccoMd.elenco,
      TipoBloccoMd.numerato,
      TipoBloccoMd.numerato,
      TipoBloccoMd.citazione,
      TipoBloccoMd.tabella,
      TipoBloccoMd.linea,
      TipoBloccoMd.paragrafo,
    ]);
    expect(b[0].livello, 2);
    expect(b[3].livello, 1, reason: 'sottoelenco rientrato');
    expect(b[6].segno, '2.');
    expect(b[8].celle, [
      ['Giorno', 'Seduta'],
      ['Mar', 'Corsa'],
      ['Gio', 'Forza'],
    ]);
  });

  test('grassetto, corsivo, codice e link nel testo', () {
    const base = TextStyle();
    final s = righeInLinea(
      'Fai **3 serie** e *piano*, poi `Z2` e [qui](https://x.it). nome_file ok',
      base,
    ).cast<TextSpan>();
    String? testo(FontWeight w) =>
        s.where((x) => x.style?.fontWeight == w).firstOrNull?.text;
    expect(testo(FontWeight.w700), '3 serie');
    expect(
      s.firstWhere((x) => x.style?.fontStyle == FontStyle.italic).text,
      'piano',
    );
    expect(s.firstWhere((x) => x.style?.fontFamily == 'monospace').text, 'Z2');
    expect(
      s.firstWhere((x) => x.style?.decoration == TextDecoration.underline).text,
      'qui',
    );
    // Il trattino basso dentro una parola non diventa corsivo.
    expect(s.last.text, contains('nome_file ok'));
    expect(s.map((x) => x.text).join(), isNot(contains('**')));
  });

  test('codice tra le tre virgolette resta com\'è', () {
    final b = leggiBlocchi(
      'Prima\n```\n- 10m Z2\n**non grassetto**\n```\nDopo',
    );
    expect(b.map((x) => x.tipo), [
      TipoBloccoMd.paragrafo,
      TipoBloccoMd.codice,
      TipoBloccoMd.paragrafo,
    ]);
    expect(b[1].testo, '- 10m Z2\n**non grassetto**');
  });

  testWidgets('si disegna senza errori', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: creaTema(Brightness.dark),
        home: Scaffold(
          body: SingleChildScrollView(
            child: TestoFormattato(_risposta, colore: Colors.white),
          ),
        ),
      ),
    );
    expect(find.textContaining('Settimana'), findsOneWidget);
    expect(find.text('•'), findsNWidgets(3));
  });
}
