import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'navigazione.dart';
import 'percorso.dart';

// La mappa di un percorso da usare senza rete: si scarica una fascia attorno
// alla traccia (a pezzi, non un rettangolo enorme) nella cache di MapLibre.
// Le mappe Pulse e Strade usano gli stessi riquadri di OpenFreeMap, che hanno
// i dettagli fino al livello 14: più vicino si ingrandisce quello. Il
// satellite resta solo con la rete.

/// Livelli di zoom scaricati: dalla vista larga al massimo dettaglio.
const zoomOfflineMin = 10.0;
const zoomOfflineMax = 14.0;

/// Peso medio di un riquadro (stima per dire quanto si scarica).
const byteRiquadro = 35 * 1024;

typedef Zona = (double latMin, double lonMin, double latMax, double lonMax);

/// Le zone da scaricare: un rettangolo ogni [passo] metri di traccia, largo
/// [margine] metri attorno ai suoi punti.
List<Zona> zoneDaScaricare(
  Traccia t, {
  double passo = 5000,
  double margine = 1000,
}) {
  if (t.vuota) return const [];
  final zone = <Zona>[];
  var inizio = 0;
  for (var i = 1; i < t.punti.length; i++) {
    final ultimo = i == t.punti.length - 1;
    if (!ultimo && t.progressivi[i] - t.progressivi[inizio] < passo) continue;
    var (a, b, c, d) = (90.0, 180.0, -90.0, -180.0);
    for (var k = inizio; k <= i; k++) {
      final p = t.punti[k];
      a = math.min(a, p.lat);
      b = math.min(b, p.lon);
      c = math.max(c, p.lat);
      d = math.max(d, p.lon);
    }
    final dLat = margine / 111195;
    final dLon = margine / (111195 * math.cos((a + c) / 2 * math.pi / 180));
    zone.add((a - dLat, b - dLon, c + dLat, d + dLon));
    inizio = i;
  }
  return zone;
}

/// I riquadri (z, x, y) che coprono le zone, senza doppioni.
Set<(int, int, int)> riquadriDi(List<Zona> zone, {int min = 10, int max = 14}) {
  int x(double lon, int z) =>
      ((lon + 180) / 360 * (1 << z)).floor().clamp(0, (1 << z) - 1);
  int y(double lat, int z) {
    final r = lat * math.pi / 180;
    final v =
        (1 - math.log(math.tan(r) + 1 / math.cos(r)) / math.pi) / 2 * (1 << z);
    return v.floor().clamp(0, (1 << z) - 1);
  }

  final out = <(int, int, int)>{};
  for (final (a, b, c, d) in zone) {
    for (var z = min; z <= max; z++) {
      for (var i = x(b, z); i <= x(d, z); i++) {
        for (var j = y(c, z); j <= y(a, z); j++) {
          out.add((z, i, j));
        }
      }
    }
  }
  return out;
}

/// "circa 12 MB".
String pesoStimato(Traccia t) {
  final n = riquadriDi(zoneDaScaricare(t)).length;
  final mb = (n * byteRiquadro / (1024 * 1024)).ceil();
  return 'circa ${math.max(1, mb)} MB';
}

/// Le mappe offline dei percorsi: cosa c'è già, cosa si sta scaricando.
class MappeOffline extends ChangeNotifier {
  /// Percorsi con la mappa tutta scaricata.
  Set<String> scaricati = {};

  /// Durante il download: id del percorso → avanzamento da 0 a 1.
  final avanzamento = <String, double>{};

  /// L'ultimo errore per percorso, da mostrare.
  final errori = <String, String>{};

  bool _letto = false;

  /// Legge dalla cache di MapLibre quali percorsi sono completi.
  Future<void> carica({bool ancora = false}) async {
    if (_letto && !ancora) return;
    _letto = true;
    try {
      final parti = <String, (int fatte, int totali)>{};
      for (final r in await getListOfRegions()) {
        final id = r.metadata['percorso'];
        if (id is! String) continue;
        final tot = (r.metadata['parti'] as num?)?.toInt() ?? 0;
        final (f, _) = parti[id] ?? (0, tot);
        parti[id] = (f + (r.metadata['fatto'] == true ? 1 : 0), tot);
      }
      scaricati = {
        for (final e in parti.entries)
          if (e.value.$2 > 0 && e.value.$1 >= e.value.$2) e.key,
      };
      notifyListeners();
    } catch (e) {
      debugPrint('Mappe offline: $e');
    }
  }

  bool inCorso(String id) => avanzamento.containsKey(id);

  /// Scarica la mappa attorno al percorso, pezzo per pezzo. Se manca la
  /// rete si ferma e si può riprovare (si riparte da capo).
  Future<void> scarica(String id, Traccia t) async {
    if (inCorso(id)) return;
    await carica();
    if (scaricati.contains(id)) return;
    final zone = zoneDaScaricare(t);
    if (zone.isEmpty) return;
    avanzamento[id] = 0;
    errori.remove(id);
    notifyListeners();
    try {
      await _togli(id);
      for (final (k, (a, b, c, d)) in zone.indexed) {
        final fatto = Completer<bool>();
        final meta = {'percorso': id, 'parte': k, 'parti': zone.length};
        final r = await downloadOfflineRegion(
          OfflineRegionDefinition(
            bounds: LatLngBounds(
              southwest: LatLng(a, b),
              northeast: LatLng(c, d),
            ),
            mapStyleUrl: fonteStrade,
            minZoom: zoomOfflineMin,
            maxZoom: zoomOfflineMax,
          ),
          metadata: meta,
          onEvent: (e) {
            if (e is InProgress) {
              final p = e.progress > 1 ? e.progress / 100 : e.progress;
              avanzamento[id] = (k + p.clamp(0.0, 1.0)) / zone.length;
              notifyListeners();
            } else if (e is Success) {
              if (!fatto.isCompleted) fatto.complete(true);
            } else if (e is Error) {
              if (!fatto.isCompleted) fatto.complete(false);
            }
          },
        );
        if (!await fatto.future) {
          throw StateError('download interrotto');
        }
        await updateOfflineRegionMetadata(r.id, {...meta, 'fatto': true});
      }
      scaricati = {...scaricati, id};
    } catch (e) {
      debugPrint('Mappa offline di $id: $e');
      errori[id] = 'Download non riuscito: serve la rete. Riprova più tardi.';
    } finally {
      avanzamento.remove(id);
      notifyListeners();
    }
  }

  /// Toglie la mappa offline del percorso (percorso eliminato).
  Future<void> elimina(String id) async {
    try {
      await _togli(id);
    } catch (e) {
      debugPrint('Mappe offline: $e');
    }
    scaricati = {...scaricati}..remove(id);
    errori.remove(id);
    notifyListeners();
  }

  Future<void> _togli(String id) async {
    for (final r in await getListOfRegions()) {
      if (r.metadata['percorso'] == id) await deleteOfflineRegion(r.id);
    }
  }
}

final mappeOffline = MappeOffline();
