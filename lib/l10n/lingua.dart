import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'app_localizations.dart';

/// Lingue dell'app: codice e nome scritto nella lingua stessa.
const lingueApp = {'it': 'Italiano', 'en': 'English'};

/// Lingua scelta dall'utente, salvata in lingua.txt. Null finché non l'ha
/// scelta (primo avvio): allora l'app chiede quale usare.
final lingua = ValueNotifier<String?>(null);

AppLocalizations _testi = lookupAppLocalizations(const Locale('it'));

/// I testi dell'app nella lingua in uso. È globale, e non legato a un
/// BuildContext, perché molti testi nascono fuori dalle schermate
/// (generatori del piano, messaggi di AppState, voce, notifiche).
AppLocalizations get l10n => _testi;

/// La lingua in uso adesso ('it' finché non se ne sceglie un'altra).
String get codiceLingua => _testi.localeName;

/// True se l'app è in inglese: serve ai pochi testi costruiti a mano
/// (vocabolario dei dati, voce, formati).
bool get inInglese => codiceLingua == 'en';

/// Lingua del telefono, se è una di quelle dell'app; altrimenti l'inglese.
String linguaDelTelefono() {
  final c = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return lingueApp.containsKey(c) ? c : 'en';
}

/// Imposta la lingua dei testi senza salvarla (anche nei test).
void usaLingua(String codice) {
  final c = lingueApp.containsKey(codice) ? codice : 'it';
  _testi = lookupAppLocalizations(Locale(c));
  lingua.value = c;
}

Future<File> _file() async {
  final d = await getApplicationDocumentsDirectory();
  return File('${d.path}/lingua.txt');
}

/// Legge la lingua salvata. Se non c'è, resta null (si chiederà al primo
/// avvio) e i testi restano in italiano.
Future<void> caricaLingua() async {
  try {
    final f = await _file();
    if (await f.exists()) {
      final c = (await f.readAsString()).trim();
      if (lingueApp.containsKey(c)) usaLingua(c);
    }
  } catch (_) {
    // file illeggibile: si richiede la lingua
  }
}

/// Sceglie e salva la lingua, poi ridisegna tutta l'app: i testi sono
/// letti da [l10n] e non dipendono dal contesto, quindi ogni widget va
/// ricostruito a mano.
Future<void> scegliLingua(String codice) async {
  usaLingua(codice);
  try {
    await (await _file()).writeAsString(codiceLingua);
  } catch (_) {
    // non salvata: vale solo per questa sessione
  }
  ridisegnaTutto();
}

/// Ricostruisce ogni widget dell'albero, anche quelli costanti.
void ridisegnaTutto() {
  final radice = WidgetsBinding.instance.rootElement;
  if (radice == null) return;
  void segna(Element e) {
    e.markNeedsBuild();
    e.visitChildren(segna);
  }

  radice.visitChildren(segna);
}
