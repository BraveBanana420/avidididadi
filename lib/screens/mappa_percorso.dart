import 'dart:convert';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../app_state.dart';
import '../health_connect.dart';
import '../models.dart';
import '../percorso.dart';
import '../pulse.dart';
import '../widgets.dart';

String _esadecimale(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// La mappa con i colori del tema e il percorso acceso al neon.
class MappaPercorso extends StatefulWidget {
  final Percorso percorso;
  final String sport;
  final bool interattiva;
  const MappaPercorso({
    super.key,
    required this.percorso,
    required this.sport,
    this.interattiva = false,
  });

  @override
  State<MappaPercorso> createState() => _MappaPercorsoState();
}

class _MappaPercorsoState extends State<MappaPercorso> {
  MapLibreMapController? _mappa;

  LatLngBounds get _limiti {
    final (a, b, c, d) = widget.percorso.limiti;
    return LatLngBounds(southwest: LatLng(a, b), northeast: LatLng(c, d));
  }

  /// Zoom iniziale approssimato, poi si inquadra il percorso con precisione.
  CameraPosition get _inizio {
    final (a, b, c, d) = widget.percorso.limiti;
    final lat = (a + c) / 2;
    final metri = math.max(
      distanzaM(PuntoGps(a, b, DateTime(0)), PuntoGps(c, b, DateTime(0))),
      distanzaM(PuntoGps(lat, b, DateTime(0)), PuntoGps(lat, d, DateTime(0))),
    );
    final z =
        math.log(
          156543 * math.cos(lat * math.pi / 180) * 280 / math.max(metri, 200),
        ) /
        math.ln2;
    return CameraPosition(
      target: LatLng(lat, (b + d) / 2),
      zoom: z.clamp(3, 17).toDouble(),
    );
  }

  void _inquadra() {
    _mappa?.moveCamera(
      CameraUpdate.newLatLngBounds(
        _limiti,
        left: 36,
        top: 36,
        right: 36,
        bottom: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scuro = Theme.of(context).brightness == Brightness.dark;
    final g = widget.interattiva;
    return MapLibreMap(
      styleString: stileMappa(
        scuro: scuro,
        colore: _esadecimale(coloreSport(widget.sport)),
        percorso: widget.percorso.geoJson(),
        estremi: widget.percorso.geoJsonEstremi(),
      ),
      initialCameraPosition: _inizio,
      onMapCreated: (c) => _mappa = c,
      onStyleLoadedCallback: _inquadra,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      scrollGesturesEnabled: g,
      zoomGesturesEnabled: g,
      doubleClickZoomEnabled: g,
      logoEnabled: false,
      attributionButtonPosition: AttributionButtonPosition.bottomRight,
      attributionButtonColor: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

/// Il percorso nella pagina di una sessione svolta: anteprima da toccare per
/// la mappa intera. Se Health Connect vuole il permesso, lo chiede.
class AnteprimaPercorso extends StatefulWidget {
  final AppState state;
  final Sessione sessione;
  const AnteprimaPercorso({
    super.key,
    required this.state,
    required this.sessione,
  });

  @override
  State<AnteprimaPercorso> createState() => _AnteprimaPercorsoState();
}

class _AnteprimaPercorsoState extends State<AnteprimaPercorso> {
  late Future<RispostaPercorso> _risposta = widget.state.percorsoDi(
    widget.sessione,
  );

  bool get _daHc => widget.sessione.origine.isNotEmpty;

  Future<void> _chiedi() async {
    final p = await widget.state.chiediPercorso(widget.sessione);
    if (!mounted) return;
    if (p == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Percorso non concesso. Puoi sempre permetterlo da Health Connect.',
          ),
        ),
      );
      return;
    }
    setState(() => _risposta = Future.value(RispostaPercorso.dati(p)));
  }

  /// File GPX scaricato da Garmin Connect: diventa il percorso della sessione.
  Future<void> _aggiungiGpx() async {
    final messenger = ScaffoldMessenger.of(context);
    final s = widget.sessione;
    final Percorso p;
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);
      if (files.isEmpty) return;
      if ((await files.first.length() ?? 0) > maxByteGpx) {
        throw const FormatException(
          'File troppo grande: un GPX di un allenamento pesa al massimo pochi MB.',
        );
      }
      p = percorsoDaGpx(
        utf8.decode(await files.first.readAsBytes(), allowMalformed: true),
      );
    } on FormatException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Impossibile leggere il file: $e')),
      );
      return;
    }
    final giorno = giornoDi(p);
    if (giorno != null && giorno != s.data && mounted) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Giorno diverso'),
          content: Text(
            'Il file è di ${dataLunga(giorno)}, la sessione di '
            '${dataLunga(s.data)}. Usarlo lo stesso?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Usalo'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await widget.state.salvaPercorsoGpx(s, p);
    if (!mounted) return;
    setState(() => _risposta = Future.value(RispostaPercorso.dati(p)));
    messenger.showSnackBar(
      SnackBar(content: Text('Percorso aggiunto: ${fmtKm(p.distanzaKm)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RispostaPercorso>(
      future: _risposta,
      builder: (context, snap) {
        final r = snap.data;
        if (r == null) return const SizedBox.shrink();
        return switch (r.stato) {
          StatoPercorso.dati when !r.percorso!.vuoto => _mappa(r.percorso!),
          StatoPercorso.consenso => _consenso(context),
          StatoPercorso.nessuno when _daHc => _assente(context),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _mappa(Percorso p) {
    final s = widget.sessione;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 200,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: MappaPercorso(percorso: p, sport: s.sport),
                ),
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            MappaPercorsoScreen(percorso: p, sessione: s),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: PillolaPulse('Apri la mappa'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _consenso(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Questa sessione ha il percorso GPS',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Health Connect chiede il tuo permesso per mostrarlo. '
            'Per non doverlo dare ogni volta: Health Connect → Avidididadi → '
            'Percorsi di allenamento → Consenti sempre.',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _chiedi,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Mostra il percorso'),
              ),
              TextButton(
                onPressed: widget.state.hc.apriPermessi,
                child: const Text('Consenti sempre'),
              ),
              TextButton.icon(
                onPressed: _aggiungiGpx,
                icon: const Icon(Icons.upload_file),
                label: const Text('Aggiungi GPX'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  /// Nessun percorso da Health Connect: si può aggiungere il file GPX.
  Widget _assente(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final fonte = widget.sessione.fonte.isEmpty
        ? "L'app che ha registrato la sessione"
        : widget.sessione.fonte;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SuperficiePulse(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nessun percorso GPS', style: t.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '$fonte non lo ha condiviso. Puoi aggiungerlo tu: su '
                    "connect.garmin.com apri l'attività, ingranaggio → "
                    'Esporta in GPX, poi carica qui il file.',
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filled(
                  tooltip: 'Aggiungi GPX',
                  iconSize: 26,
                  onPressed: _aggiungiGpx,
                  icon: const Icon(Icons.add_location_alt_outlined),
                ),
                Text('GPX', style: t.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// La mappa intera, con distanza, tempo e ritmo.
class MappaPercorsoScreen extends StatelessWidget {
  final Percorso percorso;
  final Sessione sessione;
  const MappaPercorsoScreen({
    super.key,
    required this.percorso,
    required this.sessione,
  });

  @override
  Widget build(BuildContext context) {
    final s = sessione;
    final t = Theme.of(context).textTheme;
    final km = s.distanzaKm > 0 ? s.distanzaKm : percorso.distanzaKm;
    final tempo = s.durataMin > 0
        ? Duration(minutes: s.durataMin)
        : percorso.durata;
    final dati = [
      ('Distanza', fmtKm(km)),
      ('Tempo', '${tempo.inMinutes} min'),
      (
        stessoSport(s.sport, 'Bici') ? 'Velocità' : 'Ritmo',
        ritmoMedio(s.sport, km, tempo),
      ),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(titoloSessione(s.sport, s.tipo)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MappaPercorso(
              percorso: percorso,
              sport: s.sport,
              interattiva: true,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
            child: SuperficiePulse(
              child: Row(
                children: [
                  for (final (etichetta, valore) in dati)
                    Expanded(
                      child: Column(
                        children: [
                          FittedBox(child: Text(valore, style: t.titleLarge)),
                          Text(etichetta, style: t.bodySmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
