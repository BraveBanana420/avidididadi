import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'dati_live.dart';

/// Bip negli ultimi secondi dei blocchi a tempo (recuperi compresi).
final bipAttivo = ValueNotifier<bool>(true);

/// Vibrazione insieme ai bip: a gusto personale.
final vibrazioneAttiva = ValueNotifier<bool>(true);

/// Voce: km, esercizio che inizia, ritmo o zona sbagliati.
final voceAttiva = ValueNotifier<bool>(true);

/// Pausa automatica di corsa, bici e camminata (spenta all'inizio).
final modoPausa = ValueNotifier<ModoPausa>(ModoPausa.spenta);

/// Con [ModoPausa.sotto]: sotto questa velocità (km/h) va in pausa.
final sogliaPausaKmh = ValueNotifier<double>(4);

/// Passo medio con le soste (tempo totale) o solo in movimento.
final mediaConSoste = ValueNotifier<bool>(false);

/// Dove sta la mappa durante corsa, camminata e bici all'aperto.
enum VistaMappa { pagine, minimappa, schermo }

const nomiVisteMappa = {
  VistaMappa.pagine: 'Due pagine',
  VistaMappa.minimappa: 'Minimappa',
  VistaMappa.schermo: 'Tutto schermo',
};

final vistaMappa = ValueNotifier<VistaMappa>(VistaMappa.pagine);

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
      if (chiave.trim() == 'pausa') {
        modoPausa.value = ModoPausa.values.firstWhere(
          (m) => m.name == valore.trim(),
          orElse: () => ModoPausa.spenta,
        );
      }
      if (chiave.trim() == 'soglia_kmh') {
        final v = double.tryParse(valore.trim());
        if (v != null) sogliaPausaKmh.value = v.clamp(2, 15).toDouble();
      }
      if (chiave.trim() == 'mappa') {
        vistaMappa.value = VistaMappa.values.firstWhere(
          (m) => m.name == valore.trim(),
          orElse: () => VistaMappa.pagine,
        );
      }
      if (chiave.trim() == 'media') {
        mediaConSoste.value = valore.trim() == 'soste';
      }
      if (chiave.trim() == 'vibrazione') {
        vibrazioneAttiva.value = valore.trim() != 'no';
      }
    }
  } catch (_) {
    // restano accesi entrambi
  }
}

Future<void> salvaAvvisi({
  bool? bip,
  bool? vibrazione,
  bool? voce,
  ModoPausa? pausa,
  double? sogliaKmh,
  bool? conSoste,
  VistaMappa? mappa,
}) async {
  if (bip != null) bipAttivo.value = bip;
  if (vibrazione != null) vibrazioneAttiva.value = vibrazione;
  if (voce != null) voceAttiva.value = voce;
  if (pausa != null) modoPausa.value = pausa;
  if (sogliaKmh != null) sogliaPausaKmh.value = sogliaKmh;
  if (conSoste != null) mediaConSoste.value = conSoste;
  if (mappa != null) vistaMappa.value = mappa;
  try {
    await (await _file()).writeAsString(
      'bip=${bipAttivo.value ? 'si' : 'no'}\n'
      'vibrazione=${vibrazioneAttiva.value ? 'si' : 'no'}\n'
      'voce=${voceAttiva.value ? 'si' : 'no'}\n'
      'pausa=${modoPausa.value.name}\n'
      'soglia_kmh=${sogliaPausaKmh.value}\n'
      'media=${mediaConSoste.value ? 'soste' : 'movimento'}\n'
      'mappa=${vistaMappa.value.name}\n',
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
