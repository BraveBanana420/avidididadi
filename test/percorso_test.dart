import 'dart:convert';

import 'package:allenamenti_app/backup.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 10, 24, 8);
  // Circa 11,1 m di latitudine ogni 0.0001 gradi.
  PuntoGps p(double nord, int s, [double prec = 5]) =>
      PuntoGps(43.9 + nord * 0.0001, 10.9, t0.add(Duration(seconds: s)), prec);

  test('distanza tra due punti', () {
    final d = distanzaM(p(0, 0), p(10, 0));
    expect(d, closeTo(111.2, 0.5));
  });

  test('il filtro scarta punti imprecisi, tremolio e salti', () {
    final f = FiltroGps(velocitaMassima: 10);
    expect(f.aggiungi(p(0, 0)), isTrue);
    expect(f.aggiungi(p(1, 1, 40)), isFalse, reason: 'troppo impreciso');
    expect(f.aggiungi(p(0.1, 2)), isFalse, reason: 'tremolio da fermo');
    expect(f.aggiungi(p(3, 4)), isTrue);
    expect(f.aggiungi(p(30, 5)), isFalse, reason: '300 m in 1 s');
    expect(f.metri, closeTo(33.4, 0.5));
  });

  test('dopo la pausa il tratto percorso da fermi non conta', () {
    final f = FiltroGps(velocitaMassima: 10);
    f.aggiungi(p(0, 0));
    f.aggiungi(p(5, 10));
    f.riprendi();
    f.aggiungi(p(50, 60));
    f.aggiungi(p(55, 70));
    expect(f.metri, closeTo(2 * 55.6, 0.5));
    expect(f.punti.length, 4);
  });

  test('salvataggio e lettura del percorso', () {
    final orig = Percorso([p(0, 0), p(5, 10, 4.5), p(9, 20)]);
    final letto = Percorso.daCsv(orig.toCsvText());
    expect(letto.punti.length, 3);
    expect(letto.punti[1].lat, closeTo(orig.punti[1].lat, 1e-6));
    expect(letto.punti[1].t, orig.punti[1].t);
    expect(letto.distanzaKm, closeTo(orig.distanzaKm, 1e-4));
  });

  test('i punti da Android arrivano in fila', () {
    final r = Percorso.daPiatto([43.9, 10.9, 1000, 43.91, 10.91, 2000]);
    expect(r.punti.length, 2);
    expect(r.punti.last.t.millisecondsSinceEpoch, 2000);
  });

  test('i file dei percorsi finiscono nel backup', () {
    final a = filePercorsoApp(DateTime(2026, 10, 24), 'Corsa');
    final h = filePercorsoHc('7F3A-11bc-90');
    expect(a, 'percorso_app_2026_10_24_corsa.csv');
    expect(h, 'percorso_hc_7f3a_11bc_90.csv');
    expect(fileDaSalvare(a), isTrue);
    expect(fileDaSalvare(h), isTrue);
  });

  test('solo corsa e bici hanno il percorso', () {
    expect(sportConPercorso('Corsa'), isTrue);
    expect(sportConPercorso('bici'), isTrue);
    expect(sportConPercorso('Nuoto'), isFalse);
    expect(sportConPercorso('Nuoto', 'Acque libere'), isTrue);
  });

  test('lo stile della mappa contiene il percorso al neon', () {
    final orig = Percorso([p(0, 0), p(9, 20)]);
    final s = jsonDecode(
      stileMappa(
        scuro: true,
        colore: '#FF3B47',
        percorso: orig.geoJson(),
        estremi: orig.geoJsonEstremi(),
      ),
    ) as Map<String, dynamic>;
    final livelli = [for (final l in s['layers'] as List) l['id']];
    expect(livelli, containsAllInOrder(['strade', 'alone', 'luce', 'nucleo']));
    final dati = s['sources']['percorso']['data'] as Map;
    final coord = dati['features'][0]['geometry']['coordinates'] as List;
    expect(coord.first, [10.9, 43.9]);
  });

  test('ritmo medio e velocità', () {
    expect(ritmoMedio('Corsa', 10, const Duration(minutes: 55)), '5:30 min/km');
    expect(ritmoMedio('Bici', 30, const Duration(hours: 1)), '30.0 km/h');
    expect(ritmoMedio('Corsa', 0, const Duration(minutes: 5)), '–');
  });

  test('GPX di Garmin Connect', () {
    const gpx = """<?xml version="1.0" encoding="UTF-8"?>
<gpx creator="Garmin Connect" version="1.1" xmlns="http://www.topografix.com/GPX/1/1">
  <trk><name>Pistoia Corsa</name><trkseg>
    <trkpt lat="43.9300" lon="10.9100"><ele>70.2</ele><time>2026-10-20T07:12:03.000Z</time>
      <extensions><ns3:TrackPointExtension><ns3:hr>120</ns3:hr></ns3:TrackPointExtension></extensions>
    </trkpt>
    <trkpt lon="10.9105" lat="43.9310"><time>2026-10-20T07:12:13.000Z</time></trkpt>
    <trkpt lat='43.9320' lon='10.9110'/>
  </trkseg></trk>
</gpx>""";
    final r = percorsoDaGpx(gpx);
    expect(r.punti.length, 3);
    expect(r.punti[1].lat, 43.931);
    expect(r.punti[1].lon, 10.9105);
    expect(r.punti[1].t.difference(r.punti[0].t).inSeconds, 10);
    expect(giornoDi(r), DateTime(2026, 10, 20));
    expect(r.distanzaKm, greaterThan(0.2));
  });

  test('un file senza traccia non è un percorso', () {
    expect(
      () => percorsoDaGpx('<gpx><wpt lat="1" lon="2"/></gpx>'),
      throwsFormatException,
    );
  });

  test('passi al minuto della corsa', () {
    final inizio = DateTime(2026, 10, 20, 7);
    Sessione s(String sport, int passi) => Sessione(
      id: 'x',
      data: DateTime(2026, 10, 20),
      sport: sport,
      durataMin: 40,
      passi: passi,
      inizio: inizio,
      fine: inizio.add(const Duration(minutes: 50)),
    );
    expect(cadenza(s('Corsa', 8000)), 160);
    expect(cadenza(s('Bici', 8000)), isNull);
    expect(cadenza(s('Corsa', 0)), isNull);
    expect(cadenza(s('Corsa', 100)), isNull);
    expect(cadenza(s('Camminata', 5500)), 110);
  });

  test('GPX malformato: si legge comunque, in fretta', () {
    final b = StringBuffer('<gpx><trk><trkseg>');
    for (var i = 0; i < 20000; i++) {
      // tag mai chiusi: con la vecchia lettura servivano minuti
      b.write('<trkpt lat="43.${1000 + i}" lon="10.9"><time>x');
    }
    final orologio = Stopwatch()..start();
    final r = percorsoDaGpx(b.toString());
    expect(r.punti.length, 20000);
    expect(orologio.elapsed.inSeconds, lessThan(3));
  });

  test('GPX: coordinate impossibili scartate', () {
    final r = percorsoDaGpx(
      '<trkpt lat="95" lon="10"/><trkpt lat="43.9" lon="10.9"/>'
      '<trkpt lat="43.91" lon="10.91"/>',
    );
    expect(r.punti.length, 2);
  });
}
