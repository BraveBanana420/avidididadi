import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Bip negli ultimi secondi dei blocchi a tempo (recuperi compresi).
final bipAttivo = ValueNotifier<bool>(true);

/// Vibrazione insieme ai bip: a gusto personale.
final vibrazioneAttiva = ValueNotifier<bool>(true);

/// Voce: km, esercizio che inizia, ritmo o zona sbagliati.
final voceAttiva = ValueNotifier<bool>(true);

/// Da quanti secondi dalla fine partono i bip.
const secondiAvviso = 5;

const _canale = MethodChannel('avidididadi/avvio');
bool _letti = false;

Future<File> _file() async =>
    File('${(await getApplicationDocumentsDirectory()).path}/avvisi.txt');

/// Legge le scelte salvate in avvisi.txt (bip=si, vibrazione=no…).
Future<void> caricaAvvisi() async {
  if (_letti) return;
  _letti = true;
  try {
    final f = await _file();
    if (!await f.exists()) return;
    for (final riga in (await f.readAsString()).split('\n')) {
      final [chiave, valore] = [...riga.split('='), ''].take(2).toList();
      if (chiave.trim() == 'bip') bipAttivo.value = valore.trim() != 'no';
      if (chiave.trim() == 'voce') voceAttiva.value = valore.trim() != 'no';
      if (chiave.trim() == 'vibrazione') {
        vibrazioneAttiva.value = valore.trim() != 'no';
      }
    }
  } catch (_) {
    // restano accesi entrambi
  }
}

Future<void> salvaAvvisi({bool? bip, bool? vibrazione, bool? voce}) async {
  if (bip != null) bipAttivo.value = bip;
  if (vibrazione != null) vibrazioneAttiva.value = vibrazione;
  if (voce != null) voceAttiva.value = voce;
  try {
    await (await _file()).writeAsString(
      'bip=${bipAttivo.value ? 'si' : 'no'}\n'
      'vibrazione=${vibrazioneAttiva.value ? 'si' : 'no'}\n'
      'voce=${voceAttiva.value ? 'si' : 'no'}\n',
    );
  } catch (_) {
    // vale solo per questa sessione
  }
}

/// Avviso di un secondo che manca ([fine]: il blocco è finito, bip lungo).
void avviso({bool fine = false}) {
  if (bipAttivo.value) {
    _canale.invokeMethod('bip', fine).catchError((_) => null);
  }
  if (vibrazioneAttiva.value) {
    _canale.invokeMethod('vibra', fine).catchError((_) => null);
  }
}
