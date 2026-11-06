import 'intervals.dart';
import 'models.dart';
import 'percorso.dart';
import 'sincronizzazione.dart';

// Le sessioni registrate dall'app, fuori dall'app: un file GPX col percorso
// (per Strava, Garmin Connect, intervals.icu…) o un'attività di intervals.icu.
// Solo quelle dell'app: quelle dell'orologio ci sono già.

const inviateHeader = ['id_sessione', 'id_intervals'];

/// external_id su intervals.icu: la stessa sessione non si crea due volte.
/// Con l'orario, perché due sedute uguali nello stesso giorno hanno lo stesso
/// id nell'app ma là sono due attività.
String idEsterno(Sessione s) {
  final base = 'avidididadi-${s.id}';
  final inizio = s.inizio;
  return inizio == null ? base : '$base-${inizio.millisecondsSinceEpoch}';
}

/// Come una sessione arriva a intervals.icu.
enum InvioSessione {
  /// Non c'entra: viene dall'orologio, o intervals.icu non è collegato.
  nessuno,

  /// Solo a mano: l'invio è spento, o la seduta è di prima di accenderlo.
  tasto,

  /// Parte da sola, senza chiedere niente.
  automatico,

  /// È già là.
  inviata,
}

/// [invioDal] è quando è stato acceso l'invio (null = spento): le sedute di
/// prima non partono da sole, altrimenti accenderlo manderebbe tutto lo storico.
InvioSessione invioDi(
  Sessione s, {
  required bool collegato,
  required bool inviata,
  required DateTime? invioDal,
}) {
  if (s.fonte != fonteApp || !collegato) return InvioSessione.nessuno;
  if (inviata) return InvioSessione.inviata;
  if (invioDal == null || (s.inizio ?? s.data).isBefore(invioDal)) {
    return InvioSessione.tasto;
  }
  return InvioSessione.automatico;
}

/// Le attività di intervals.icu senza quelle mandate dall'app: sono copie delle
/// sue sedute, non vengono da un orologio e non devono prenderne il posto (la
/// seduta non si potrebbe più modificare). Restano nascoste anche se la seduta
/// viene tolta dallo storico. [inviate] va da id della seduta a id là; se l'id
/// là non è arrivato, la copia si riconosce dallo stesso orario di partenza.
List<Sessione> senzaCopieInviate(
  List<Sessione> icu,
  Map<String, String> inviate,
  List<Sessione> storico,
) {
  if (inviate.isEmpty) return icu;
  final idCopie = {
    for (final id in inviate.values)
      if (id.isNotEmpty) '$prefissoIcu$id',
  };
  final senzaId = [
    for (final s in storico)
      if (s.inizio != null && inviate[s.id]?.isEmpty == true) s,
  ];
  bool stessaPartenza(Sessione a, Sessione b) =>
      stessoSport(a.sport, b.sport) &&
      b.inizio != null &&
      a.inizio!.difference(b.inizio!).abs() <= const Duration(minutes: 1);
  return [
    for (final s in icu)
      if (!idCopie.contains(s.id) && !senzaId.any((x) => stessaPartenza(x, s)))
        s,
  ];
}

/// Tipo di attività di intervals.icu (e di Strava) per una sessione svolta.
String tipoAttivitaIcu(String sport, {bool alChiuso = false}) {
  if (stessoSport(sport, 'Corsa')) return alChiuso ? 'VirtualRun' : 'Run';
  if (stessoSport(sport, 'Bici')) return alChiuso ? 'VirtualRide' : 'Ride';
  if (stessoSport(sport, 'Camminata')) return 'Walk';
  if (stessoSport(sport, 'Nuoto')) return 'Swim';
  if (stessoSport(sport, 'Forza')) return 'WeightTraining';
  return 'Workout';
}

/// Nome dell'attività: quello scritto a mano, altrimenti "Corsa · Lento".
String nomeAttivita(Sessione s, String nomeRitoccato) {
  if (nomeRitoccato.isNotEmpty) return nomeRitoccato;
  if (s.note.isNotEmpty && s.note != s.sport) return '${s.sport} · ${s.note}';
  return s.tipo.isEmpty ? s.sport : '${s.sport} · ${s.tipo}';
}

String _xml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// File GPX 1.1 con la traccia e gli orari (in UTC, come vuole il formato).
String gpxDa(Percorso p, {required String nome, required String sport}) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<gpx version="1.1" creator="Avidididadi" '
      'xmlns="http://www.topografix.com/GPX/1/1">',
    )
    ..writeln('  <trk>')
    ..writeln('    <name>${_xml(nome)}</name>')
    ..writeln('    <type>${_xml(tipoAttivitaIcu(sport))}</type>')
    ..writeln('    <trkseg>');
  for (final x in p.punti) {
    b.writeln(
      '      <trkpt lat="${x.lat.toStringAsFixed(7)}" '
      'lon="${x.lon.toStringAsFixed(7)}">'
      '<time>${x.t.toUtc().toIso8601String()}</time></trkpt>',
    );
  }
  b
    ..writeln('    </trkseg>')
    ..writeln('  </trk>')
    ..writeln('</gpx>');
  return b.toString();
}

/// Nome del file GPX: "avidididadi_2026-11-01_corsa.gpx".
String nomeFileGpx(Sessione s) =>
    'avidididadi_${isoData(s.data)}_${s.sport.toLowerCase()}.gpx';

/// Attività manuale di intervals.icu (senza percorso): tempo, km, battito.
Map<String, Object?> attivitaManuale(
  Sessione s, {
  required String nome,
  bool alChiuso = false,
}) {
  final inizio = s.inizio ?? s.data.add(const Duration(hours: 12));
  String locale(DateTime d) => d.toIso8601String().split('.').first;
  return {
    'start_date_local': locale(inizio),
    'type': tipoAttivitaIcu(s.sport, alChiuso: alChiuso),
    'name': nome,
    'moving_time': s.durataMin * 60,
    'elapsed_time': s.inizio != null && s.fine != null
        ? s.fine!.difference(s.inizio!).inSeconds
        : s.durataMin * 60,
    if (s.distanzaKm > 0) 'distance': (s.distanzaKm * 1000).round(),
    if (s.fcMedia > 0) 'average_heartrate': s.fcMedia,
    if (s.fcMax > 0) 'max_heartrate': s.fcMax,
    if (s.calorieAttive > 0) 'calories': s.calorieAttive.round(),
    if (alChiuso) 'trainer': true,
    'external_id': idEsterno(s),
  };
}
