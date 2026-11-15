import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../gps.dart';
import '../navigazione.dart';
import '../percorso.dart';
import '../widgets.dart';
import 'mappa_percorso.dart';
import '../l10n/lingua.dart';

/// L'icona della curva, come nei navigatori.
IconData iconaCurva(Curva c) => switch (c.tipo) {
  TipoCurva.leggera =>
    c.destra ? Icons.turn_slight_right_rounded : Icons.turn_slight_left_rounded,
  TipoCurva.normale =>
    c.destra ? Icons.turn_right_rounded : Icons.turn_left_rounded,
  TipoCurva.stretta =>
    c.destra ? Icons.turn_sharp_right_rounded : Icons.turn_sharp_left_rounded,
  TipoCurva.inversione =>
    c.destra ? Icons.u_turn_right_rounded : Icons.u_turn_left_rounded,
};

/// La mappa durante l'allenamento: segue la posizione e gira nella direzione
/// di marcia (la strada davanti è sempre in alto). Con [traccia] mostra il
/// percorso da seguire, senza quello fatto finora. Un tocco allarga o
/// stringe la vista.
class MappaLive extends StatefulWidget {
  final String sport;
  final RegistratoreGps gps;
  final Traccia? traccia;

  /// Direzione da usare da fermi (quella della traccia dove si è).
  final double? direzioneDiRiserva;
  final bool compatta;

  const MappaLive({
    super.key,
    required this.sport,
    required this.gps,
    this.traccia,
    this.direzioneDiRiserva,
    this.compatta = false,
  });

  @override
  State<MappaLive> createState() => _MappaLiveState();
}

class _MappaLiveState extends State<MappaLive> {
  MapLibreMapController? _mappa;
  bool _stileCaricato = false;
  bool _lontano = false;
  double _direzione = 0;
  DateTime _mossaIl = DateTime(0);
  DateTime _lineaIl = DateTime(0);
  final _stili = <(TipoMappa, bool), Future<String>>{};

  double get _zoom =>
      _lontano ? (widget.compatta ? 13 : 14) : (widget.compatta ? 15.5 : 16.5);

  @override
  void initState() {
    super.initState();
    leggiTipoMappa();
    widget.gps.addListener(_muovi);
  }

  @override
  void didUpdateWidget(MappaLive old) {
    super.didUpdateWidget(old);
    if (old.gps != widget.gps) {
      old.gps.removeListener(_muovi);
      widget.gps.addListener(_muovi);
    }
  }

  @override
  void dispose() {
    widget.gps.removeListener(_muovi);
    super.dispose();
  }

  Future<String> _stile(TipoMappa tipo, bool scuro) {
    final t = widget.traccia;
    final p = t?.comePercorso;
    return stileConPercorso(
      tipo: tipo,
      scuro: scuro,
      colore: esadecimale(coloreSport(widget.sport)),
      percorso: p?.geoJson(),
      estremi: p?.geoJsonEstremi(),
    );
  }

  /// Al massimo una volta al secondo: la camera scivola sulla posizione.
  void _muovi({bool subito = false}) {
    final c = _mappa;
    final pos = widget.gps.ultimo;
    if (c == null || !_stileCaricato || pos == null) return;
    final ora = DateTime.now();
    if (!subito &&
        ora.difference(_mossaIl) < const Duration(milliseconds: 900)) {
      return;
    }
    _mossaIl = ora;
    _direzione =
        widget.gps.direzione ?? widget.direzioneDiRiserva ?? _direzione;
    c.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.lat, pos.lon),
          zoom: _zoom,
          bearing: _direzione,
        ),
      ),
      duration: const Duration(milliseconds: 900),
    );
    // Senza percorso da seguire, la linea è la strada fatta finora.
    if (widget.traccia == null &&
        ora.difference(_lineaIl) > const Duration(seconds: 5)) {
      _lineaIl = ora;
      c.setGeoJsonSource('percorso', widget.gps.percorso.geoJson());
    }
  }

  CameraPosition get _inizio {
    final pos = widget.gps.ultimo;
    if (pos != null) {
      return CameraPosition(target: LatLng(pos.lat, pos.lon), zoom: _zoom);
    }
    final t = widget.traccia;
    if (t != null && !t.vuota) {
      final p = t.punti.first;
      return CameraPosition(target: LatLng(p.lat, p.lon), zoom: _zoom);
    }
    return const CameraPosition(target: LatLng(42.5, 12.5), zoom: 4);
  }

  @override
  Widget build(BuildContext context) {
    final scuro = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<TipoMappa>(
      valueListenable: tipoMappa,
      builder: (context, tipo, _) => FutureBuilder<String>(
        future: _stili.putIfAbsent((tipo, scuro), () => _stile(tipo, scuro)),
        builder: (context, snap) {
          if (!snap.hasData) return ColoredBox(color: scheme.surface);
          return Stack(
            children: [
              Positioned.fill(
                child: MapLibreMap(
                  key: ValueKey((tipo, scuro)),
                  styleString: snap.data!,
                  initialCameraPosition: _inizio,
                  onMapCreated: (c) => _mappa = c,
                  onStyleLoadedCallback: () {
                    _stileCaricato = true;
                    _lineaIl = DateTime(0);
                    _muovi(subito: true);
                  },
                  onMapClick: (_, _) {
                    setState(() => _lontano = !_lontano);
                    _muovi(subito: true);
                  },
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  doubleClickZoomEnabled: false,
                  logoEnabled: false,
                  // La "i" dei crediti va fuori dallo schermo: al suo posto
                  // c'è il tasto dei livelli, e i crediti sono nel suo foglio.
                  attributionButtonPosition:
                      AttributionButtonPosition.bottomRight,
                  attributionButtonMargins: const math.Point(-200, -200),
                ),
              ),
              // La posizione: sempre al centro, la freccia punta avanti.
              Center(
                child: IgnorePointer(
                  child: _Freccia(
                    colore: coloreSport(widget.sport),
                    bordo: scheme.surface,
                    ferma: widget.gps.ultimo == null,
                  ),
                ),
              ),
              // I livelli, dove prima c'era la "i": anche nella minimappa.
              Positioned(
                right: 6,
                bottom: 6,
                child: PulsanteLivelli(piccolo: widget.compatta),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Freccia extends StatelessWidget {
  final Color colore;
  final Color bordo;
  final bool ferma;
  const _Freccia({
    required this.colore,
    required this.bordo,
    required this.ferma,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: bordo,
      boxShadow: [
        BoxShadow(color: colore.withValues(alpha: 0.6), blurRadius: 14),
      ],
    ),
    child: Icon(
      ferma ? Icons.gps_not_fixed_rounded : Icons.navigation_rounded,
      color: colore,
      size: 26,
    ),
  );
}

/// In cima alla mappa: la prossima curva, o se si è fuori percorso, o quanto
/// è lontana la traccia prima di salirci. Sotto, quanto manca.
class BannerGuida extends StatelessWidget {
  final Guida guida;
  final bool compatto;
  const BannerGuida({super.key, required this.guida, this.compatto = false});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final g = guida;
    final (
      IconData icona,
      String grande,
      String piccolo,
      bool allarme,
    ) = switch (g) {
      _ when g.arrivato => (
        Icons.sports_score_rounded,
        l10n.arrivo,
        l10n.percorsoCompletato,
        false,
      ),
      _ when g.progresso == null => (
        Icons.near_me_rounded,
        g.distanza == null ? '…' : fmtMetri(g.distanza!),
        g.distanza == null
            ? l10n.cercoPosizione
            : l10n.percorsoQuestaParteRaggiungilo,
        false,
      ),
      _ when g.fuori => (
        Icons.wrong_location_rounded,
        fmtMetri(g.distanza ?? 0),
        l10n.fuoriPercorsoTornaSulla,
        true,
      ),
      _ => switch (g.prossimaCurva) {
        (final c, final m) => (
          iconaCurva(c),
          fmtMetri(m),
          c.frase[0].toUpperCase() + c.frase.substring(1),
          false,
        ),
        null => (
          Icons.straight_rounded,
          fmtMetri(g.metriMancanti ?? 0),
          l10n.drittoFinoAllArrivo,
          false,
        ),
      },
    };
    final fondo = allarme ? scheme.errorContainer : scheme.surfaceContainerHigh;
    final testo = allarme ? scheme.onErrorContainer : scheme.onSurface;
    final mancano = g.metriMancanti;
    final fatto = g.traccia.metri <= 0 || g.progresso == null
        ? 0.0
        : (g.progresso! / g.traccia.metri).clamp(0.0, 1.0);
    return Material(
      color: fondo,
      borderRadius: BorderRadius.circular(compatto ? 16 : 20),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          compatto ? 8 : 10,
          14,
          compatto ? 8 : 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icona, size: compatto ? 30 : 40, color: testo),
                const SizedBox(width: 10),
                Text(
                  grande,
                  style: (compatto ? t.titleLarge : t.headlineSmall)?.copyWith(
                    color: testo,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    piccolo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyMedium?.copyWith(color: testo),
                  ),
                ),
              ],
            ),
            if (!compatto && mancano != null && !g.arrivato) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fatto,
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.mancanoAncora(fmtMetri(mancano)),
                    style: t.labelMedium?.copyWith(color: testo),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// La riga della notifica con la guida: "↱ 150 m · gira a destra".
String? testoGuida(Guida? g) {
  if (g == null) return null;
  if (g.arrivato) return l10n.percorsoCompletato;
  if (g.progresso == null) {
    return g.distanza == null ? null : l10n.percorso(fmtMetri(g.distanza!));
  }
  if (g.fuori) return l10n.fuoriPercorso(fmtMetri(g.distanza ?? 0));
  final p = g.prossimaCurva;
  if (p == null) return l10n.arrivoTra(fmtMetri(g.metriMancanti ?? 0));
  return '${fmtMetri(p.$2)}: ${p.$1.frase}';
}
