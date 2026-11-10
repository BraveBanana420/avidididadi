import 'dart:io' show gzip;
import 'dart:typed_data';

// Lettura dei giri (lap) da un file FIT, il formato dei file degli orologi
// Garmin. intervals.icu per le corse senza watt calcola gli intervalli a modo
// suo; i giri veri dell'orologio (uno per passo dell'allenamento, più i giri
// automatici di 1 km) stanno solo nel file originale.
// Formato: intestazione, poi record di definizione (come sono fatti i
// messaggi di un tipo) e record di dati. Qui servono solo i messaggi "lap".

/// Un giro dell'orologio.
class GiroFit {
  final DateTime inizio;
  final int secondi; // tempo del cronometro (senza le pause)
  final double metri;
  final int fcMedia; // 0 se manca
  final int wattMedi; // 0 se mancano
  final bool riposo; // segnato come recupero dall'allenamento sull'orologio
  const GiroFit({
    required this.inizio,
    required this.secondi,
    this.metri = 0,
    this.fcMedia = 0,
    this.wattMedi = 0,
    this.riposo = false,
  });
}

const _lap = 19; // numero del messaggio "lap" nel profilo FIT

// Campi del messaggio lap che servono.
const _inizio = 2; // start_time, secondi dal 31/12/1989
const _tempoTotale = 7; // total_elapsed_time, millisecondi
const _tempoCronometro = 8; // total_timer_time, millisecondi
const _distanza = 9; // total_distance, centimetri
const _fcMedia = 15; // avg_heart_rate, bpm
const _wattMedi = 19; // avg_power, W
const _intensita = 23; // intensity: 0 attivo, 1 riposo, 2 riscaldamento…

/// Il giorno zero dei tempi FIT.
final _zeroFit = DateTime.utc(1989, 12, 31);

class _Definizione {
  final bool grandeFine; // big-endian
  final int globale;
  final List<(int, int)> campi; // (numero, byte)
  final int byteSviluppatore; // campi aggiunti dalle app: si saltano
  const _Definizione(
    this.grandeFine,
    this.globale,
    this.campi,
    this.byteSviluppatore,
  );
}

/// Il file arriva anche compresso (gzip): lo si apre.
List<int> _aperto(List<int> dati) =>
    dati.length > 2 && dati[0] == 0x1f && dati[1] == 0x8b
    ? gzip.decode(dati)
    : dati;

/// Un intero senza segno di [n] byte; null se vale "non valido" (tutti 1).
int? _intero(ByteData b, int pos, int n, bool grandeFine) {
  final e = grandeFine ? Endian.big : Endian.little;
  final (v, nonValido) = switch (n) {
    1 => (b.getUint8(pos), 0xFF),
    2 => (b.getUint16(pos, e), 0xFFFF),
    4 => (b.getUint32(pos, e), 0xFFFFFFFF),
    _ => (null, 0),
  };
  return v == null || v == nonValido ? null : v;
}

/// I giri di un file FIT, in ordine. Vuoto se il file non è un FIT (per
/// esempio un GPX caricato a mano) o è rovinato.
List<GiroFit> giriDaFit(List<int> file) {
  try {
    final dati = Uint8List.fromList(_aperto(file));
    if (dati.length < 12) return const [];
    final b = ByteData.sublistView(dati);
    final intestazione = dati[0];
    if (intestazione < 12 ||
        String.fromCharCodes(dati.sublist(8, 12)) != '.FIT') {
      return const [];
    }
    final lunghezza = b.getUint32(4, Endian.little);
    final fine = (intestazione + lunghezza).clamp(0, dati.length);
    final definizioni = <int, _Definizione>{};
    final giri = <GiroFit>[];
    var pos = intestazione;
    while (pos < fine) {
      final h = dati[pos++];
      if (h & 0x80 != 0) {
        // Intestazione compressa (col tempo): sempre un messaggio di dati.
        final d = definizioni[(h >> 5) & 0x03];
        if (d == null) return giri;
        pos = _leggiDati(b, pos, d, giri);
        continue;
      }
      final locale = h & 0x0F;
      if (h & 0x40 != 0) {
        // Definizione: come sono fatti i messaggi di questo tipo.
        final grandeFine = dati[pos + 1] == 1;
        final globale = b.getUint16(
          pos + 2,
          grandeFine ? Endian.big : Endian.little,
        );
        final n = dati[pos + 4];
        pos += 5;
        final campi = <(int, int)>[];
        for (var k = 0; k < n; k++) {
          campi.add((dati[pos], dati[pos + 1]));
          pos += 3;
        }
        var sviluppatore = 0;
        if (h & 0x20 != 0) {
          final m = dati[pos++];
          for (var k = 0; k < m; k++) {
            sviluppatore += dati[pos + 1];
            pos += 3;
          }
        }
        definizioni[locale] = _Definizione(
          grandeFine,
          globale,
          campi,
          sviluppatore,
        );
      } else {
        final d = definizioni[locale];
        if (d == null) return giri;
        pos = _leggiDati(b, pos, d, giri);
      }
    }
    return giri;
  } on RangeError {
    return const []; // file tagliato o rovinato
  } on FormatException {
    return const []; // gzip rovinato
  }
}

/// Legge un messaggio di dati; se è un giro lo aggiunge. Restituisce la
/// posizione dopo il messaggio.
int _leggiDati(ByteData b, int pos, _Definizione d, List<GiroFit> giri) {
  final valori = <int, int?>{};
  for (final (numero, byte) in d.campi) {
    if (d.globale == _lap) valori[numero] = _intero(b, pos, byte, d.grandeFine);
    pos += byte;
  }
  pos += d.byteSviluppatore;
  if (d.globale == _lap) {
    final inizio = valori[_inizio];
    final ms = valori[_tempoCronometro] ?? valori[_tempoTotale];
    if (inizio != null && ms != null && ms > 0) {
      giri.add(
        GiroFit(
          inizio: _zeroFit.add(Duration(seconds: inizio)),
          secondi: (ms / 1000).round(),
          metri: (valori[_distanza] ?? 0) / 100,
          fcMedia: valori[_fcMedia] ?? 0,
          wattMedi: valori[_wattMedi] ?? 0,
          riposo: valori[_intensita] == 1,
        ),
      );
    }
  }
  return pos;
}
