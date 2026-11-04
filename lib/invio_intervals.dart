import 'csv.dart';
import 'models.dart';
import 'potenza.dart';

// Invio del piano a intervals.icu: corsa, bici e nuoto dei prossimi giorni
// diventano allenamenti strutturati nel calendario di intervals.icu, che li
// passa a Garmin Connect (e all'orologio) se l'utente lo ha attivato lì.
// La forza resta nell'app: intervals.icu non ha serie, ripetizioni e pesi.

/// Giorni di piano mandati, a partire da oggi.
const giorniInvio = 14;

/// Prefisso dell'external_id degli eventi creati dall'app.
const prefissoInvio = 'avd-';

/// Tipo di attività di intervals.icu per uno sport del piano (null: non si manda).
String? tipoEventoIcu(String sport, String tipo) {
  final t = tipo.toLowerCase();
  if (stessoSport(sport, 'Corsa')) {
    return t.contains('tapis') ? 'VirtualRun' : 'Run';
  }
  if (stessoSport(sport, 'Bici')) {
    return t.contains('rulli') ? 'VirtualRide' : 'Ride';
  }
  if (stessoSport(sport, 'Nuoto')) return 'Swim';
  return null;
}

/// "zona 2" → "Z2 HR"; "passo 1:56/100 m" → "1:56/100m Pace"; altrimenti vuoto.
String obiettivoIcu(String intensita) {
  final z = RegExp(r'zona ([1-5])', caseSensitive: false).firstMatch(intensita);
  if (z != null) return 'Z${z.group(1)} HR';
  final p = RegExp(r'(\d+:\d\d)\s*/\s*100\s*m').firstMatch(intensita);
  if (p != null) return '${p.group(1)}/100m Pace';
  final km = RegExp(r'(\d+:\d\d)\s*/\s*km').firstMatch(intensita);
  if (km != null) return '${km.group(1)}/km Pace';
  return '';
}

/// Durata o distanza di un passo nel formato di intervals.icu: "10m", "1m30",
/// "45s", "400mtr", "2km"; "Press lap" se si chiude col tasto lap.
String quantitaIcu(WorkoutStep s) {
  final metri = int.tryParse(s.distanzaM.trim());
  if (metri != null && metri > 0) {
    return metri >= 1000 && metri % 100 == 0
        ? '${fmtNum(metri / 1000).replaceAll(',', '.')}km'
        : '${metri}mtr';
  }
  final min = double.tryParse(s.durataMin.replaceAll(',', '.'));
  if (min != null && min > 0) {
    final sec = (min * 60).round();
    if (sec % 60 == 0) return '${sec ~/ 60}m';
    return sec < 60 ? '${sec}s' : '${sec ~/ 60}m${sec % 60}';
  }
  final r = RegExp(r'^(\d+)\s*s\b').firstMatch(s.ripetizioni.trim());
  if (r != null) return '${r.group(1)}s';
  return 'Press lap';
}

/// Il nome del passo come etichetta: senza numeri, che intervals.icu
/// leggerebbe come durate o obiettivi.
String _etichetta(WorkoutStep s) {
  final testo = s.descrizione.isEmpty ? s.nome : s.descrizione;
  return testo
      // "da 3 minuti", "200 m": via la quantità intera, poi le cifre rimaste.
      .replaceAll(
        RegExp(
          r'(\bda\s+)?\d+([.,:/]\d+)*\s*'
          r'(minuti|minuto|min|secondi|sec|km|metri|m|s|%)?(?![a-zà-ù])',
          caseSensitive: false,
        ),
        ' ',
      )
      .replaceAll(RegExp(r'[0-9:/%=]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Il testo dell'allenamento per intervals.icu, una riga per passo.
/// Le ripetizioni diventano un blocco "Nx" con lavoro e recupero.
/// Con [potenza] (FTP noto) le zone della bici diventano % dell'FTP, che
/// Garmin mostra come obiettivo in watt.
String testoIcu(String sport, List<WorkoutStep> passi, {bool potenza = false}) {
  final nuoto = stessoSport(sport, 'Nuoto');
  final watt = potenza && stessoSport(sport, 'Bici');
  final righe = <String>[];
  String riga(WorkoutStep s) => [
    '-',
    _etichetta(s),
    quantitaIcu(s),
    (watt ? obiettivoPotenzaIcu(s.intensita) : null) ??
        obiettivoIcu(s.intensita),
  ].where((x) => x.isNotEmpty).join(' ');
  String recupero(int sec) => nuoto
      ? '- ${sec}s intensity=rest'
      : '- Recupero ${sec}s ${watt ? obiettivoPotenzaIcu('zona 1') : 'Z1 HR'}';

  final ordinati = [...passi]..sort((a, b) => a.ordine.compareTo(b.ordine));
  for (final s in ordinati) {
    final n = (int.tryParse(s.serie.trim()) ?? 1).clamp(1, 50);
    final rec = int.tryParse(s.recuperoS.trim()) ?? 0;
    final titolo = switch (s.fase) {
      'riscaldamento' => 'Warmup',
      'defaticamento' => 'Cooldown',
      _ => maiuscola(s.fase.isEmpty ? 'principale' : s.fase),
    };
    if (righe.isNotEmpty) righe.add('');
    if (n > 1) {
      righe
        ..add('$titolo ${n}x')
        ..add(riga(s));
      if (rec > 0) righe.add(recupero(rec));
    } else {
      righe
        ..add(titolo)
        ..add(riga(s));
      // Nel nuoto la pausa a bordo vasca c'è anche dopo un passo solo.
      if (rec > 0 && nuoto) righe.add(recupero(rec));
    }
  }
  return righe.join('\n');
}

/// Una seduta del piano da mandare.
class SedutaDaInviare {
  final DateTime data;
  final String sport;
  final String tipo;
  final int durataMin;
  final int indice; // seconda corsa dello stesso giorno: 1
  final List<WorkoutStep> passi;
  final bool potenza; // FTP noto: obiettivi della bici in watt
  const SedutaDaInviare({
    required this.data,
    required this.sport,
    required this.tipo,
    required this.durataMin,
    required this.passi,
    this.indice = 0,
    this.potenza = false,
  });

  String get externalId =>
      '$prefissoInvio${isoData(data)}-${sport.toLowerCase()}'
      '${indice > 0 ? '-${indice + 1}' : ''}';

  /// L'evento per l'API di intervals.icu (null se lo sport non si manda).
  Map<String, Object?>? evento() {
    final tipoIcu = tipoEventoIcu(sport, tipo);
    if (tipoIcu == null) return null;
    final testo = passi.isEmpty
        ? '- ${durataMin > 0 ? '${durataMin}m' : 'Press lap'}'
        : testoIcu(sport, passi, potenza: potenza);
    return {
      'category': 'WORKOUT',
      'start_date_local': '${isoData(data)}T00:00:00',
      'type': tipoIcu,
      'name': titoloSessione(sport, tipo),
      'description': testo,
      'external_id': externalId,
      if (durataMin > 0) 'moving_time': durataMin * 60,
    };
  }
}

const inviatiHeader = ['external_id', 'id', 'data', 'firma'];

/// Un evento già creato su intervals.icu: id e firma del contenuto mandato.
class EventoInviato {
  final String externalId;
  final int id;
  final DateTime data;
  final String firma;
  const EventoInviato(this.externalId, this.id, this.data, this.firma);

  List<String> toRow() => [externalId, '$id', isoData(data), firma];

  static EventoInviato? da(Tabella t, List<String> r) {
    final id = int.tryParse(t.v(r, 'id'));
    final d = parseData(t.v(r, 'data'));
    if (id == null || d == null) return null;
    return EventoInviato(t.v(r, 'external_id'), id, d, t.v(r, 'firma'));
  }
}

/// Impronta del contenuto (FNV-1a a 32 bit): se non cambia, non si rimanda.
String firmaDi(Map<String, Object?> evento) {
  var h = 0x811c9dc5;
  final testo =
      '${evento['start_date_local']}|${evento['type']}|${evento['name']}|'
      '${evento['description']}|${evento['moving_time']}';
  for (final c in testo.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h.toRadixString(16);
}

/// Cosa fare: gli eventi da creare e gli id da cancellare (cambiati o tolti
/// dal piano). I giorni passati non si toccano.
({List<Map<String, Object?>> nuovi, List<int> daCancellare}) pianoInvio(
  List<SedutaDaInviare> sedute,
  List<EventoInviato> inviati,
  DateTime oggi,
) {
  final eventi = {for (final s in sedute) s.externalId: ?s.evento()};
  final perId = {for (final x in inviati) x.externalId: x};
  final nuovi = <Map<String, Object?>>[];
  final daCancellare = <int>[];
  for (final MapEntry(key: id, value: e) in eventi.entries) {
    final prima = perId[id];
    if (prima != null && prima.firma == firmaDi(e)) continue;
    if (prima != null) daCancellare.add(prima.id);
    nuovi.add(e);
  }
  for (final x in inviati) {
    if (!eventi.containsKey(x.externalId) && !x.data.isBefore(oggi)) {
      daCancellare.add(x.id);
    }
  }
  return (nuovi: nuovi, daCancellare: daCancellare);
}
