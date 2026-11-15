import 'package:flutter/services.dart';

import 'dati_live.dart';
import 'esecuzione.dart';
import 'models.dart';
import 'percorso.dart';
import 'l10n/lingua.dart';
import 'l10n/vocabolario.dart';

// La notifica dell'allenamento in corso, visibile anche dalla schermata di
// blocco: esercizio, tempo (che scorre da solo), km, passo e battito, con il
// tasto Pausa/Riprendi. Con il GPS acceso prende il posto della sua notifica.

const _canale = MethodChannel('avidididadi/avvio');

/// Il tasto Pausa/Riprendi della notifica: lo imposta l'allenamento aperto.
void Function()? pausaDaNotifica;

/// Da Android 13 le notifiche vanno permesse (anche quella del GPS).
Future<void> permessoNotifiche() async {
  try {
    await _canale.invokeMethod<bool>('permessoNotifiche');
  } catch (_) {}
}

/// Mostra o aggiorna la notifica. Il tempo parte da [base]: in avanti, oppure
/// al contrario fino a [base] se [contoAllaRovescia].
Future<void> mostraNotifica({
  required String titolo,
  required String testo,
  required DateTime base,
  bool contoAllaRovescia = false,
  bool inPausa = false,
}) async {
  try {
    await _canale.invokeMethod('notificaAllenamento', {
      'titolo': titolo,
      'testo': testo,
      'base': base.millisecondsSinceEpoch,
      'indietro': contoAllaRovescia,
      'pausa': inPausa,
      // Testi fissi della notifica nella lingua dell'app.
      'canale': l10n.notificaCanale,
      'allenamento': l10n.notificaAllenamento,
      'riprendi': l10n.riprendi,
      'pausa_testo': l10n.pausa2,
    });
  } catch (_) {}
}

Future<void> togliNotifica() async {
  try {
    await _canale.invokeMethod('togliNotifica');
  } catch (_) {}
}

/// Titolo: l'esercizio di adesso ("Ripetute · Serie 2 di 6"), o il recupero
/// con quello che viene dopo.
String titoloNotifica(
  Blocco b, {
  required String nome,
  required bool libera,
  required bool inPausa,
  Blocco? prossimo,
}) {
  final titolo = mostra(b.titolo);
  final cosa = libera
      ? mostra(nome)
      : b.tipo == TipoBlocco.recupero
      ? (prossimo == null
            ? l10n.parolaRecupero
            : l10n.recuperoPoi(mostra(prossimo.titolo)))
      : (b.dettaglio.isEmpty ? titolo : '$titolo · ${b.dettaglio}');
  return inPausa ? l10n.pausa(cosa) : cosa;
}

/// Riga dei dati: "2,35 km · 10:12 min/km · ♥ 112 Z2". Vuota senza GPS e
/// senza battito.
String testoNotifica({
  required String sport,
  double? km,
  double? mps,
  int? bpm,
  int zona = 0,
  int? watt,
}) => [
  if (km != null) fmtKm(km),
  if (km != null && fmtVelocita(sport, mps) != '–')
    '${fmtVelocita(sport, mps)} ${unitaRitmo(sport)}',
  if (watt != null) '$watt W',
  if (bpm != null) '♥ $bpm${zona > 0 ? ' Z$zona' : ''}',
].join(' · ');
