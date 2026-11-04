import 'package:flutter/services.dart';

/// Scambio di testo con le altre app tramite la condivisione di Android:
/// verso l'app dell'assistente e, solo se collegato, la risposta indietro.
class Condivisione {
  static const _canale = MethodChannel('avidididadi/avvio');

  /// Apre il menu "Condividi" di Android con il testo.
  static Future<void> condividi(String testo, String titolo) async {
    try {
      await _canale.invokeMethod('condividi', {
        'testo': testo,
        'titolo': titolo,
      });
    } on MissingPluginException {
      // fuori da Android: niente menu
    }
  }

  /// Apre il menu "Condividi" con un'immagine (PNG in cache/condivisi) e,
  /// se c'è, un testo di accompagnamento.
  static Future<void> condividiImmagine(
    String percorso, {
    String testo = '',
    required String titolo,
  }) async {
    try {
      await _canale.invokeMethod('condividiImmagine', {
        'percorso': percorso,
        'testo': testo,
        'titolo': titolo,
      });
    } on MissingPluginException {
      // fuori da Android: niente menu
    }
  }

  /// Accende o spegne Avidididadi tra le app a cui condividere un testo.
  static Future<void> ricevi(bool attiva) async {
    try {
      await _canale.invokeMethod('ricezioneAgente', attiva);
    } on MissingPluginException {
      // fuori da Android
    }
  }

  /// Testo condiviso con cui è stata aperta l'app (una volta sola).
  static Future<String?> testoAllAvvio() async {
    try {
      return await _canale.invokeMethod<String>('testoCondiviso');
    } on MissingPluginException {
      return null;
    }
  }
}
