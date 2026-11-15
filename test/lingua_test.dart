import 'dart:convert';
import 'dart:io';

import 'package:allenamenti_app/assistente.dart';
import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/glossario.dart';
import 'package:allenamenti_app/l10n/lingua.dart';
import 'package:allenamenti_app/l10n/vocabolario.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/navigazione.dart';
import 'package:allenamenti_app/voce.dart';
import 'package:allenamenti_app/screens/lingua_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String lingua) =>
    json.decode(File('lib/l10n/app_$lingua.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _segnaposto(String testo) => {
  for (final m in RegExp(r'\{(p\d+|\w+)\}').allMatches(testo)) m[1]!,
};

void main() {
  tearDown(() {
    usaLingua('it');
    linguaVoceScelta.value = 'app';
  });

  group('file ARB', () {
    final it = _arb('it');
    final en = _arb('en');
    final chiavi = it.keys.where((k) => !k.startsWith('@')).toSet();

    test('le stesse chiavi in italiano e in inglese', () {
      final inglesi = en.keys.where((k) => !k.startsWith('@')).toSet();
      expect(chiavi.difference(inglesi), isEmpty);
      expect(inglesi.difference(chiavi), isEmpty);
    });

    test('nessun testo inglese vuoto', () {
      for (final k in chiavi) {
        expect((en[k] as String).trim(), isNotEmpty, reason: k);
      }
    });

    test('gli stessi segnaposto, così nessun dato si perde', () {
      // Eccezioni volute: desinenze italiane ("provate", "provati").
      const desinenze = {'provatSenzaChiuderl', 'quanteProvate'};
      for (final k in chiavi) {
        if (desinenze.contains(k)) continue;
        expect(
          _segnaposto(en[k] as String),
          _segnaposto(it[k] as String),
          reason: k,
        );
      }
    });

    test('le iniziali dei giorni sono sette', () {
      expect((it['widgetLettere'] as String).split(','), hasLength(7));
      expect((en['widgetLettere'] as String).split(','), hasLength(7));
    });

    test('il greco ha tutti i testi, pieni e con gli stessi segnaposto', () {
      final el = _arb('el');
      final greci = el.keys.where((k) => !k.startsWith('@')).toSet();
      expect(chiavi.difference(greci), isEmpty);
      expect(greci.difference(chiavi), isEmpty);
      for (final k in chiavi) {
        expect((el[k] as String).trim(), isNotEmpty, reason: k);
        expect(
          _segnaposto(el[k] as String),
          _segnaposto(en[k] as String),
          reason: k,
        );
      }
      expect((el['widgetLettere'] as String).split(','), hasLength(7));
    });
  });

  test('in greco cambiano testi, giorni, mesi e nomi dei dati', () {
    usaLingua('el');
    expect(codiceLingua, 'el');
    expect(inInglese, isFalse);
    expect(l10n.parolaOggi, 'σήμερα');
    // Dentro una data il mese è al genitivo, da solo al nominativo.
    expect(dataLunga(DateTime(2026, 11, 16)), 'Δευτέρα 16 Νοεμβρίου');
    expect(nomeMese(11), 'Νοέμβριος');
    // Giugno e luglio non si confondono negli assi dei grafici.
    expect(meseBreve(6), isNot(meseBreve(7)));
    expect(inizialiGiorni.first, 'Δ');
    expect(mostra('Corsa'), 'Τρέξιμο');
    expect(mostra('lento'), 'χαλαρό');
    expect(titoloSessione('Corsa', 'Lento'), 'Τρέξιμο: Χαλαρό');
    expect(mostraTesto('zona 2'), 'ζώνη 2');
    expect(sensazioneDi(mostraTesto('intensità zona 2')), isNotNull);
    expect(istruzioniAssistente(''), contains('στα ελληνικά'));
    expect(istruzioniAssistente(''), contains('"sport": "Corsa"'));
  });

  test('con l\'app in greco anche la voce parla greco', () {
    usaLingua('el');
    expect(codiceVocePer('app', 'it'), 'el');
    expect(fraseProvaVoce(), 'Σε 200 μέτρα, στρίψε δεξιά.');
  });

  test('di base l\'app parla italiano', () {
    expect(codiceLingua, 'it');
    expect(l10n.parolaOggi, 'oggi');
    expect(giorniSettimana.first, 'Lunedì');
    expect(mesiNomi[10], 'novembre');
    expect(inizialiGiorni, ['L', 'M', 'M', 'G', 'V', 'S', 'D']);
  });

  test('in inglese cambiano i testi, giorni e mesi', () {
    usaLingua('en');
    expect(codiceLingua, 'en');
    expect(inInglese, isTrue);
    expect(l10n.parolaOggi, 'today');
    expect(dataLunga(DateTime(2026, 11, 16)), 'Monday 16 November');
    expect(inizialiGiorni.first, 'M');
    expect(l10n.battitiAlMinuto(142), '142 bpm');
  });

  test('il coach risponde nella lingua scelta', () {
    expect(istruzioniAssistente(''), contains('Rispondi in italiano'));
    usaLingua('en');
    expect(istruzioniAssistente(''), contains('in English'));
    // I valori dei blocchi restano quelli che l'app sa leggere.
    expect(istruzioniAssistente(''), contains('"sport": "Corsa"'));
  });

  test('una lingua sconosciuta torna all\'italiano', () {
    usaLingua('fr');
    expect(codiceLingua, 'it');
  });

  group('nomi salvati nei CSV', () {
    test('in italiano restano come sono', () {
      expect(mostra('Corsa'), 'Corsa');
      expect(mostraTesto('zona 2'), 'zona 2');
      expect(titoloSessione('Corsa', 'Lento'), 'Corsa: Lento');
    });

    test('in inglese si traducono solo a schermo', () {
      usaLingua('en');
      expect(mostra('Corsa'), 'Running');
      expect(mostra('Mattina'), 'Morning');
      expect(mostra('lento'), 'easy');
      expect(mostra('Milano giro lungo'), 'Milano giro lungo');
      expect(titoloSessione('Corsa', 'Lento'), 'Running: Easy');
      expect(nomeSessione('Nuoto', ''), 'Swimming');
      expect(mostraTesto('zona 2'), 'zone 2');
      expect(mostraTesto('passo 5:00/km'), 'pace 5:00/km');
      expect(mostraTesto('FC 120-140 bpm'), 'HR 120-140 bpm');
    });

    test('le zone si riconoscono nelle due lingue', () {
      expect(sensazioneDi('intensità zona 2'), isNotNull);
      usaLingua('en');
      expect(sensazioneDi(mostraTesto('intensità zona 2')), isNotNull);
    });
  });

  test('il catalogo ha nome e istruzioni nelle due lingue', () {
    final dati =
        json.decode(File('assets/esercizi.json').readAsStringSync()) as List;
    final esercizi = [
      for (final j in dati) Esercizio.da(j as Map<String, dynamic>),
    ];
    for (final e in esercizi) {
      expect(e.istruzioniEn, isNotEmpty, reason: e.id);
      expect(e.nomeEl, isNotEmpty, reason: e.id);
      // Le frasi greche sono tradotte dall'italiano, una per una.
      expect(e.istruzioniEl, hasLength(e.istruzioniIt.length), reason: e.id);
    }
    final e = esercizi.firstWhere((e) => e.id == 'Pushups');
    expect(e.nome, 'Piegamenti sulle braccia');
    usaLingua('en');
    expect(e.nome, 'Pushups');
    expect(e.istruzioni.first, startsWith('Lie on the floor'));
    usaLingua('el');
    expect(e.nome, 'Κάμψεις');
    expect(e.istruzioni.first, startsWith('Χέρια στο πάτωμα'));
    expect(e.descrizioneAttrezzi, isNotEmpty);
  });

  testWidgets('la pagina della lingua cambia i testi e la salva', (t) async {
    usaLingua('it');
    await t.pumpWidget(const MaterialApp(home: LinguaScreen(primoAvvio: true)));
    expect(find.text('Italiano'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Ελληνικά'), findsOneWidget);
    await t.tap(find.text('English'));
    await t.pump();
    expect(codiceLingua, 'en');
    expect(find.text('Continue'), findsOneWidget);
  });

  group('lingua della voce', () {
    test('di base è quella dell\'app', () {
      expect(codiceVocePer('app', 'el'), 'it');
      usaLingua('en');
      expect(codiceVocePer('app', 'el'), 'en');
    });

    test('come il telefono, se la voce conosce la sua lingua', () {
      expect(codiceVocePer('telefono', 'el'), 'el');
      expect(codiceVocePer('telefono', 'en'), 'en');
      // Una lingua senza frasi: resta quella dell'app.
      expect(codiceVocePer('telefono', 'ja'), 'it');
      expect(codiceVocePer('el', 'it'), 'el');
    });

    test('app in inglese, indicazioni stradali in greco', () {
      usaLingua('en');
      linguaVoceScelta.value = 'el';
      expect(codiceVoce, 'el');
      expect(fraseProvaVoce(), 'Σε 200 μέτρα, στρίψε δεξιά.');
      expect(parlaMetri(1200), '1,2 χιλιόμετρα');
      expect(testoPerVoce('zona 2'), 'ζώνη 2');
      expect(fraseZona(4, 1), 'Ζώνη 4, χαλάρωσε.');
      // Sullo schermo le curve restano nella lingua dell'app.
      expect(const Curva(0, 90).frase, 'turn right');
    });

    test('app in italiano, voce in greco: anche i nomi dei blocchi', () {
      linguaVoceScelta.value = 'el';
      expect(nomePerVoce('Riscaldamento'), 'Ζέσταμα');
      expect(nomePerVoce('Defaticamento'), 'Αποθεραπεία');
      // Sullo schermo restano in italiano.
      expect(mostra('Riscaldamento'), 'Riscaldamento');
      // Un nome scritto dall'utente resta com'è.
      expect(nomePerVoce('Giro del lago'), 'Giro del lago');
    });

    test('in inglese i decimali col punto', () {
      usaLingua('en');
      expect(parlaMetri(1200), '1.2 kilometers');
      usaLingua('it');
      expect(parlaMetri(1200), '1,2 chilometri');
    });

    test(
      'ogni frase della voce esiste in greco, con gli stessi segnaposto',
      () {
        final it = _arb('it');
        final el = _arb('el');
        final usate = <String>{};
        for (final f in Directory('lib').listSync(recursive: true)) {
          if (f is! File || !f.path.endsWith('.dart')) continue;
          final testo = f.readAsStringSync();
          for (final m in RegExp(r'l10nVoce\.(\w+)').allMatches(testo)) {
            usate.add(m[1]!);
          }
        }
        // Le curve e le distanze passano dai testi della voce con "t.".
        usate.addAll([
          'destra',
          'sinistra',
          'tieniDestra',
          'tieniSinistra',
          'giraVerso',
          'curvaStretta',
          'tornaIndietro',
          'poiSubito',
          'poiCurva',
          'tra',
          'quantiMetri',
          'parolaChilometro',
          'parolaChilometri',
        ]);
        expect(usate.length, greaterThan(40));
        for (final k in usate) {
          expect(el.containsKey(k), isTrue, reason: 'manca in app_el.arb: $k');
          expect(
            _segnaposto(el[k] as String),
            _segnaposto(it[k] as String),
            reason: k,
          );
        }
      },
    );
  });
}
