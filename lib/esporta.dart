import 'models.dart';
import 'percorso.dart';

// Le sessioni registrate dall'app, fuori dall'app: un file GPX col percorso
// (per Strava, Garmin Connect, intervals.icu…) o un'attività di intervals.icu.
// Solo quelle dell'app: quelle dell'orologio ci sono già.

const inviateHeader = ['id_sessione', 'id_intervals'];

/// external_id su intervals.icu: la stessa sessione non si crea due volte.
String idEsterno(Sessione s) => 'avidididadi-${s.id}';

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
    if (alChiuso) 'trainer': true,
    'external_id': idEsterno(s),
  };
}
