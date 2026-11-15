import 'dart:convert';
import 'dart:io';

import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/glossario.dart';
import 'package:allenamenti_app/l10n/lingua.dart';
import 'package:allenamenti_app/l10n/vocabolario.dart';
import 'package:allenamenti_app/models.dart';
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
  tearDown(() => usaLingua('it'));

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
      // Unica eccezione voluta: "Provat{0} senza chiuderl{1}" (desinenze).
      const desinenze = {'provatSenzaChiuderl'};
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
      expect(mostra('Pistoia giro lungo'), 'Pistoia giro lungo');
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
    }
    final e = esercizi.firstWhere((e) => e.id == 'Pushups');
    expect(e.nome, 'Piegamenti sulle braccia');
    usaLingua('en');
    expect(e.nome, 'Pushups');
    expect(e.istruzioni.first, startsWith('Lie on the floor'));
  });

  testWidgets('la pagina della lingua cambia i testi e la salva', (t) async {
    usaLingua('it');
    await t.pumpWidget(const MaterialApp(home: LinguaScreen(primoAvvio: true)));
    expect(find.text('Italiano'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await t.tap(find.text('English'));
    await t.pump();
    expect(codiceLingua, 'en');
    expect(find.text('Continue'), findsOneWidget);
  });
}
