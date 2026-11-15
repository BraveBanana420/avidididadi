import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path_provider/path_provider.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../arrampicata.dart';
import '../attivita_libera.dart';
import '../carico.dart';
import '../condivisione.dart';
import '../esercizi.dart';
import '../figura.dart';
import '../health_connect.dart';
import '../intervalli.dart';
import '../models.dart';
import '../percorso.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../riepilogo_condiviso.dart';
import '../serie_sessione.dart';
import '../tema.dart';
import '../widgets.dart';
import 'mappa_percorso.dart';
import 'profilo_allenamento.dart';
import '../l10n/lingua.dart';

// Immagini da condividere su WhatsApp, Instagram…: una sessione o la
// settimana, nei colori del tema. Si crea sul telefono e parte solo verso
// l'app scelta nel menu Condividi.

/// Lato corto e lungo dell'immagine (4:5, come i post); il PNG è 3 volte più
/// grande (1080 × 1350).
const _larghezza = 360.0;
const _altezza = 450.0;

/// Disegna [chiave] in PNG e apre il menu Condividi di Android.
Future<bool> _condividi(GlobalKey chiave, String testo) async {
  final ro = chiave.currentContext?.findRenderObject();
  if (ro is! RenderRepaintBoundary) return false;
  final img = await ro.toImage(pixelRatio: 3);
  final dati = await img.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  if (dati == null) return false;
  // Una cartella sola, svuotata ogni volta: le immagini vecchie non restano.
  final dir = Directory('${(await getTemporaryDirectory()).path}/condivisi');
  if (await dir.exists()) await dir.delete(recursive: true);
  await dir.create(recursive: true);
  final f = File(
    '${dir.path}/avidididadi_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await f.writeAsBytes(dati.buffer.asUint8List(), flush: true);
  await Condivisione.condividiImmagine(
    f.path,
    testo: testo,
    titolo: l10n.condividi,
  );
  return true;
}

/// Apre l'anteprima dell'immagine di una sessione.
Future<void> apriCondividiSessione(
  BuildContext context,
  AppState state,
  Sessione s,
) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => _CondividiSessione(state: state, sessione: s),
  ),
);

/// Apre l'anteprima dell'immagine della settimana (da questa all'indietro).
Future<void> apriCondividiSettimana(BuildContext context, AppState state) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CondividiSettimana(state: state),
      ),
    );

/// La pagina: anteprima in alto, scelte e tasto Condividi sotto.
class _Pagina extends StatelessWidget {
  final String titolo;
  final GlobalKey chiave;
  final Widget immagine;
  final List<Widget> scelte;
  final String testo;

  /// Prima della foto (es. la mappa diventa un'immagine): false se non è
  /// pronta. [dopo] rimette com'era.
  final Future<bool> Function()? prima;
  final VoidCallback? dopo;
  const _Pagina({
    required this.titolo,
    required this.chiave,
    required this.immagine,
    required this.scelte,
    required this.testo,
    this.prima,
    this.dopo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(titolo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FittedBox(
                child: RepaintBoundary(
                  key: chiave,
                  child: SizedBox(
                    width: _larghezza,
                    height: _altezza,
                    child: immagine,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...scelte,
          const SizedBox(height: 8),
          PulsantePrincipale(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              if (prima != null && !await prima!()) {
                messenger.showSnackBar(
                  avviso(content: Text(l10n.mappaNonProntaRiprova)),
                );
                return;
              }
              final bool ok;
              try {
                ok = await _condividi(chiave, testo);
              } finally {
                dopo?.call();
              }
              if (!ok) {
                messenger.showSnackBar(
                  avviso(content: Text(l10n.immagineNonRiuscitaRiprova)),
                );
              }
            },
            icona: Icons.share_rounded,
            testo: l10n.condividi,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.immagineSiCreaSul,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sessione

class _CondividiSessione extends StatefulWidget {
  final AppState state;
  final Sessione sessione;
  const _CondividiSessione({required this.state, required this.sessione});

  @override
  State<_CondividiSessione> createState() => _CondividiSessioneState();
}

class _CondividiSessioneState extends State<_CondividiSessione> {
  final _chiave = GlobalKey();
  final _mappa = GlobalKey<_MappaCondivisaState>();
  Percorso? _percorso;
  // Spento di base: il percorso dice da dove si parte (spesso casa).
  bool _conPercorso = false;
  GraficaCondivisa? _grafica; // null: la prima dello sport
  TipoMappa _tipo = tipoMappa.value;
  List<IntervalloFatto> _tratti = const [];
  List<Campione> _quota = const [];

  /// La mappa fotografata subito prima di condividere: le mappe vere non
  /// finiscono da sole nell'immagine.
  Uint8List? _istantanea;

  /// La foto scelta dalla galleria: resta solo in memoria, non si salva.
  Uint8List? _foto;

  @override
  void initState() {
    super.initState();
    final s = widget.sessione;
    if (sportConPercorso(s.sport, s.tipo) && !widget.state.alChiuso(s)) {
      widget.state.percorsoDi(s).then((r) {
        if (!mounted) return;
        if (r.stato == StatoPercorso.dati && !(r.percorso?.vuoto ?? true)) {
          setState(() => _percorso = r.percorso);
        }
      });
    }
    leggiTipoMappa().then((_) {
      if (mounted) setState(() => _tipo = tipoMappa.value);
    });
    // Bici: i blocchi del poster; nuoto: le ripetute; mobilità: gli esercizi.
    if (['Bici', 'Nuoto', 'Mobilità'].any((x) => stessoSport(s.sport, x))) {
      widget.state.intervalliDi(s).then((l) {
        if (mounted) setState(() => _tratti = l);
      });
    }
    // Camminata: la quota per il profilo della salita.
    if (stessoSport(s.sport, sportCamminata)) {
      widget.state.serieDi(s).then((x) {
        if (mounted) setState(() => _quota = x.altitudine);
      });
    }
  }

  GraficaCondivisa _scelta(List<GraficaCondivisa> grafiche) {
    final g = _grafica;
    if (g == GraficaCondivisa.foto && _foto == null) return grafiche.first;
    return g != null && grafiche.contains(g) ? g : grafiche.first;
  }

  Future<void> _scegliFoto() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2160,
      imageQuality: 92,
    );
    if (x == null) return;
    final dati = await x.readAsBytes();
    if (!mounted) return;
    setState(() {
      _foto = dati;
      _grafica = GraficaCondivisa.foto;
    });
  }

  Future<bool> _fotografa(GraficaCondivisa grafica) async {
    if (grafica != GraficaCondivisa.mappa) return true;
    final foto = await _mappa.currentState?.istantanea();
    if (foto == null || !mounted) return false;
    await precacheImage(MemoryImage(foto), context);
    setState(() => _istantanea = foto);
    await WidgetsBinding.instance.endOfFrame;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final s = widget.sessione;
    // I tratti corretti a mano (pause e ripetute sistemate dopo) valgono
    // più di quelli dell'orologio, come nel riepilogo.
    final aMano = state.intervalliModificati[s.id];
    final tratti = aMano ?? _tratti;
    // Nuoto: il passo scritto a mano, altrimenti quello delle vasche
    // corrette a mano (senza le pause); 0 = calcolato sulla durata.
    final scritto = state.nuotoDi(s.id)?.passo100S ?? 0;
    final passoNuoto = !stessoSport(s.sport, 'Nuoto')
        ? 0
        : scritto > 0
        ? scritto
        : (aMano == null ? null : passoNuotatoDaTratti(aMano)) ?? 0;
    final forza = stessoSport(s.sport, 'Forza');
    final serie = forza
        ? state.serieDel(s.data)
        : const <String, List<SerieFatta>>{};
    final kg = serie.values
        .expand((x) => x)
        .fold(0.0, (t, x) => t + x.ripetizioni * x.kg);
    final esercizi = forza
        ? [for (final e in serie.entries) (e.key, fmtSerie(e.value))]
        : [
            for (final (nome, sec) in eserciziDaTratti(tratti))
              (nome, fmtSecondi(sec)),
          ];
    final ids = {for (final x in serie.values.expand((x) => x)) x.esercizio};
    final muscoli = {
      for (final e in state.esercizi)
        if (ids.contains(e.id)) ...e.muscoli,
    };
    final arrampicata = stessoSport(s.sport, sportArrampicata)
        ? arrampicataDi(state.arrampicate, s.id, s.data)
        : null;
    final tempi = _percorso == null || !siCammina(s.sport)
        ? const <int>[]
        : tempiPerKm(_percorso!);
    final ripetute = stessoSport(s.sport, 'Nuoto')
        ? passiRipetute(tratti)
        : const <int>[];
    final grafiche = grafichePer(s.sport, (
      mappa: _percorso != null,
      giri: tempi.length >= 2,
      quota: _quota.length >= 10,
      ripetute: ripetute.length >= 2,
      esercizi: esercizi.isNotEmpty,
      muscoli: muscoli.isNotEmpty,
      arrampicata: arrampicata != null && arrampicata.gradoMax.isNotEmpty,
    ));
    final grafica = _scelta(grafiche);
    final percorso = _conPercorso ? _percorso : null;
    final zp = state.zonePotenza;
    final barre = zp == null || !stessoSport(s.sport, 'Bici')
        ? const <BarraAllenamento>[]
        : barreFatte(tratti);
    final record = forza ? recordDelGiorno(state.serieFatte, s.data) : null;
    final t = Theme.of(context).textTheme;
    return _Pagina(
      titolo: l10n.condividiSessione,
      chiave: _chiave,
      testo: testoSessione(s),
      prima: () => _fotografa(grafica),
      dopo: () {
        if (mounted) setState(() => _istantanea = null);
      },
      immagine: switch (grafica) {
        GraficaCondivisa.mappa => ImmagineMappa(
          sessione: s,
          mappa: Stack(
            fit: StackFit.expand,
            children: [
              _MappaCondivisa(
                key: _mappa,
                percorso: _percorso!,
                sport: s.sport,
                tipo: _tipo,
              ),
              if (_istantanea case final f?) Image.memory(f, fit: BoxFit.cover),
            ],
          ),
          crediti: creditiMappe[_tipo]!,
        ),
        GraficaCondivisa.poster => ImmaginePoster(
          sessione: s,
          indoor: state.alChiuso(s),
          dati: posterDi(
            s,
            kgTotali: kg,
            arrampicata: arrampicata,
            passoNuoto: passoNuoto,
          ),
          grafico: barre.isNotEmpty && zp != null
              ? ProfiloAllenamento(barre: barre, zone: zp, altezza: 96)
              : record != null
              ? _Record(record)
              : stessoSport(s.sport, 'Nuoto')
              ? CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: _Onde(coloreSport(s.sport)),
                )
              : percorso == null
              ? null
              : CustomPaint(
                  size: const Size(double.infinity, 110),
                  painter: _Giro(percorso, coloreSport(s.sport)),
                ),
        ),
        GraficaCondivisa.kmPerKm => ImmagineKmPerKm(
          sessione: s,
          righe: righeKm(tempi),
        ),
        GraficaCondivisa.profilo => ImmagineProfilo(sessione: s, quota: _quota),
        GraficaCondivisa.ripetute => ImmagineRipetute(
          sessione: s,
          passi: ripetute,
          passoMedio: passoNuoto,
        ),
        GraficaCondivisa.muscoli => ImmagineMuscoli(
          sessione: s,
          sesso: state.profilo.sesso,
          muscoli: muscoli,
          kgTotali: kg,
          esercizi: serie.length,
        ),
        GraficaCondivisa.seduta => ImmagineArrampicata(
          sessione: s,
          seduta: arrampicata!,
        ),
        GraficaCondivisa.progressi => ImmagineProgressi(
          sessione: s,
          seduta: arrampicata!,
          punti: progressiArrampicata(state.arrampicate, arrampicata),
        ),
        GraficaCondivisa.foto => ImmagineFoto(
          sessione: s,
          foto: _foto!,
          passoNuoto: passoNuoto,
        ),
        GraficaCondivisa.classica ||
        GraficaCondivisa.esercizi => ImmagineSessione(
          sessione: s,
          percorso: percorso,
          kgTotali: kg,
          esercizi: esercizi.take(5).toList(),
          passoNuoto: passoNuoto,
        ),
      },
      scelte: [
        Text(l10n.grafica, style: t.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in grafiche)
              ChoiceChip(
                avatar: Icon(_iconaGrafica(g), size: 18),
                label: Text(nomiGrafiche[g]!),
                selected: g == grafica,
                showCheckmark: false,
                onSelected: (_) {
                  if (g == GraficaCondivisa.foto && _foto == null) {
                    _scegliFoto();
                  } else {
                    setState(() => _grafica = g);
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (grafica == GraficaCondivisa.mappa) ...[
          Text(l10n.tipoMappa, style: t.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<TipoMappa>(
            segments: [
              for (final m in TipoMappa.values)
                ButtonSegment(
                  value: m,
                  label: Text(nomiMappe[m]!),
                  icon: Icon(iconeMappe[m]),
                ),
            ],
            selected: {_tipo},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => _tipo = v.first),
          ),
          const SizedBox(height: 8),
          Text(l10n.mappaFaVedereDove, style: t.bodySmall),
        ] else if (grafica == GraficaCondivisa.foto) ...[
          OutlinedButton.icon(
            onPressed: _scegliFoto,
            icon: const Icon(Icons.photo_library_rounded),
            label: Text(l10n.scegliAltraFoto),
          ),
          const SizedBox(height: 8),
          Text(l10n.spostaIngrandisciFotoDue, style: t.bodySmall),
        ] else if (_percorso != null &&
            (grafica == GraficaCondivisa.classica ||
                grafica == GraficaCondivisa.poster))
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.mostraPercorso),
              subtitle: Text(l10n.faVedereFormaGiro),
              value: _conPercorso,
              onChanged: (v) => setState(() => _conPercorso = v),
            ),
          ),
      ],
    );
  }
}

IconData _iconaGrafica(GraficaCondivisa g) => switch (g) {
  GraficaCondivisa.classica => Icons.view_agenda_rounded,
  GraficaCondivisa.mappa => Icons.map_rounded,
  GraficaCondivisa.poster => Icons.text_fields_rounded,
  GraficaCondivisa.kmPerKm => Icons.format_list_numbered_rounded,
  GraficaCondivisa.profilo => Icons.landscape_rounded,
  GraficaCondivisa.ripetute => Icons.bar_chart_rounded,
  GraficaCondivisa.esercizi => Icons.checklist_rounded,
  GraficaCondivisa.muscoli => Icons.accessibility_new_rounded,
  GraficaCondivisa.seduta => Icons.terrain_rounded,
  GraficaCondivisa.progressi => Icons.trending_up_rounded,
  GraficaCondivisa.foto => Icons.photo_rounded,
};

/// Il marchio dell'app in cima alle immagini: "#avidididadi", minuscolo,
/// nel colore del testo (bianco sul fondo scuro).
class _Marchio extends StatelessWidget {
  const _Marchio();

  @override
  Widget build(BuildContext context) => Text(
    '#avidididadi',
    maxLines: 1,
    softWrap: false,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontFamily: famigliaTitoli,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}

/// Il fondo comune: colore del tema con i bagliori, marchio e data in alto.
class _Cornice extends StatelessWidget {
  final String data;
  final Widget child;
  const _Cornice({required this.data, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = Pulse.di(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surface),
      child: Stack(
        children: [
          for (final g in p.sfondo)
            Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(gradient: g)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _Marchio(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La mappa vera dietro l'immagine: il tipo scelto, il percorso inquadrato,
/// nessun tocco. Lo stile sta in un file perché la foto della mappa
/// (MapSnapshotter) sa leggerlo solo così.
class _MappaCondivisa extends StatefulWidget {
  final Percorso percorso;
  final String sport;
  final TipoMappa tipo;
  const _MappaCondivisa({
    super.key,
    required this.percorso,
    required this.sport,
    required this.tipo,
  });

  @override
  State<_MappaCondivisa> createState() => _MappaCondivisaState();
}

class _MappaCondivisaState extends State<_MappaCondivisa> {
  MapLibreMapController? _controllo;
  bool _pronta = false;
  final _stili = <(TipoMappa, bool), Future<String>>{};

  Future<String> _stile(TipoMappa tipo, bool scuro) async {
    final json = await stileConPercorso(
      tipo: tipo,
      scuro: scuro,
      colore: esadecimale(coloreSport(widget.sport)),
      percorso: widget.percorso.geoJson(),
      estremi: widget.percorso.geoJsonEstremi(),
    );
    final f = File(
      '${(await getTemporaryDirectory()).path}/'
      'stile_condivisa_${tipo.name}_${scuro ? 's' : 'c'}.json',
    );
    await f.writeAsString(json, flush: true);
    return f.path;
  }

  LatLngBounds get _limiti {
    final (a, b, c, d) = widget.percorso.limiti;
    return LatLngBounds(southwest: LatLng(a, b), northeast: LatLng(c, d));
  }

  /// La mappa com'è adesso, in PNG; null se non è ancora pronta.
  Future<Uint8List?> istantanea() async {
    final c = _controllo;
    if (c == null || !_pronta) return null;
    try {
      await c.waitUntilMapTilesAreLoaded().timeout(const Duration(seconds: 8));
    } catch (_) {
      // si fotografa quello che c'è
    }
    try {
      return await c.takeSnapshot();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scuro = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final chiave = (widget.tipo, scuro);
    final (a, b, c, d) = widget.percorso.limiti;
    return FutureBuilder<String>(
      future: _stili.putIfAbsent(chiave, () => _stile(widget.tipo, scuro)),
      builder: (context, snap) {
        if (!snap.hasData) return ColoredBox(color: scheme.surface);
        return IgnorePointer(
          child: MapLibreMap(
            key: ValueKey(chiave),
            styleString: snap.data!,
            initialCameraPosition: CameraPosition(
              target: LatLng((a + c) / 2, (b + d) / 2),
              zoom: 12,
            ),
            onMapCreated: (m) {
              _controllo = m;
              _pronta = false;
            },
            onStyleLoadedCallback: () {
              // Il percorso nella parte alta: sotto c'è la fascia dei numeri.
              _controllo?.moveCamera(
                CameraUpdate.newLatLngBounds(
                  _limiti,
                  left: 40,
                  top: 70,
                  right: 40,
                  bottom: 170,
                ),
              );
              _pronta = true;
            },
            compassEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            doubleClickZoomEnabled: false,
            logoEnabled: false,
            // I crediti sono scritti nell'immagine.
            attributionButtonMargins: const math.Point(-200, -200),
          ),
        );
      },
    );
  }
}

/// La grafica con la mappa a tutta pagina: marchio e data in alto, sotto
/// una fascia con sport, titolo e tre numeri.
class ImmagineMappa extends StatelessWidget {
  final Sessione sessione;
  final Widget mappa;
  final String crediti;
  const ImmagineMappa({
    super.key,
    required this.sessione,
    required this.mappa,
    required this.crediti,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final colore = coloreSport(s.sport);
    final numeri = numeriSessione(s).take(3).toList();
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: scheme.surface, child: mappa),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 84,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface.withValues(alpha: 0.9),
                  scheme.surface.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 16,
          child: Row(
            children: [
              const _Marchio(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dataLunga(s.data),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(iconaSport(s.sport), color: colore, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nomeSessione(s.sport, s.tipo),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final n in numeri) Expanded(child: _Numero(n)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    crediti,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelSmall?.copyWith(
                      fontSize: 8,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Il poster: un numero gigante (distanza o tempo), il grafico della seduta
/// se c'è (bici: i blocchi per zona) e tre numeri. Va bene anche indoor,
/// dove non c'è mappa.
class ImmaginePoster extends StatelessWidget {
  final Sessione sessione;
  final bool indoor;
  final Widget? grafico;
  final DatiPoster? dati; // null: distanza o tempo
  const ImmaginePoster({
    super.key,
    required this.sessione,
    this.indoor = false,
    this.grafico,
    this.dati,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final d = dati ?? posterDi(s);
    final (grande, sotto, numeri) = (d.grande, d.sotto, d.numeri);
    return _Cornice(
      data: dataLunga(s.data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconaSport(s.sport), color: coloreSport(s.sport), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  d.etichetta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (indoor)
                DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: scheme.surfaceContainerHighest,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: Text('Indoor', style: t.labelSmall),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              grande,
              maxLines: 1,
              style: t.displayLarge?.copyWith(
                fontFamily: famigliaTitoli,
                fontSize: 104,
                fontWeight: FontWeight.w700,
                letterSpacing: -4,
                height: 1,
              ),
            ),
          ),
          Text(
            sotto,
            style: t.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const Spacer(),
          ?grafico,
          const SizedBox(height: 16),
          Row(children: [for (final n in numeri) Expanded(child: _Numero(n))]),
        ],
      ),
    );
  }
}

/// Il record battuto oggi, nel poster della forza.
class _Record extends StatelessWidget {
  final String testo;
  const _Record(this.testo);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.nuovoRecord(testo),
                maxLines: 2,
                style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tre onde nel colore del nuoto, per il poster.
class _Onde extends CustomPainter {
  final Color colore;
  _Onde(this.colore);

  @override
  void paint(Canvas canvas, Size size) {
    for (var k = 0; k < 3; k++) {
      final y = size.height * (0.25 + 0.3 * k);
      final onda = Path()..moveTo(0, y);
      for (var x = 0.0; x < size.width; x += 52) {
        onda.quadraticBezierTo(x + 13, y - 14, x + 26, y);
        onda.quadraticBezierTo(x + 39, y + 14, x + 52, y);
      }
      canvas.drawPath(
        onda,
        Paint()
          ..color = colore.withValues(alpha: 1 - 0.35 * k)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(_Onde old) => old.colore != colore;
}

/// Sport e titolo in cima alle grafiche con un grafico.
class _Titolo extends StatelessWidget {
  final Sessione sessione;
  final String? destra;
  const _Titolo(this.sessione, {this.destra});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = sessione;
    return Row(
      children: [
        Icon(iconaSport(s.sport), color: coloreSport(s.sport), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            nomeSessione(s.sport, s.tipo),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (destra != null)
          Text(
            destra!,
            style: t.titleMedium?.copyWith(
              fontFamily: famigliaTitoli,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

Widget _treNumeri(List<(String, String, String)> numeri) => Row(
  children: [for (final n in numeri.take(3)) Expanded(child: _Numero(n))],
);

/// Corsa: il tempo di ogni chilometro, la barra più lunga è il più veloce.
class ImmagineKmPerKm extends StatelessWidget {
  final Sessione sessione;
  final List<(String, int)> righe;
  const ImmagineKmPerKm({
    super.key,
    required this.sessione,
    required this.righe,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final colore = coloreSport(s.sport);
    final veloce = righe.map((r) => r.$2).reduce(math.min);
    final lento = righe.map((r) => r.$2).reduce(math.max);
    final medio = righe.fold(0, (a, r) => a + r.$2) ~/ righe.length;
    return _Cornice(
      data: dataLunga(s.data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titolo(
            s,
            destra: s.distanzaKm > 0
                ? fmtDistanza(s.sport, s.distanzaKm)
                : null,
          ),
          const SizedBox(height: 12),
          // Le righe si dividono lo spazio che c'è: fino a 15, anche strette.
          Expanded(
            child: Column(
              children: [
                for (final (km, sec) in righe)
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            km,
                            style: t.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            fmtMinSec(sec.toDouble()),
                            style: t.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: sec == veloce ? colore : null,
                            ),
                          ),
                        ),
                        Expanded(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: lento == veloce
                                ? 1
                                : 0.55 +
                                      0.45 * (lento - sec) / (lento - veloce),
                            child: Container(
                              height: righe.length > 10 ? 9 : 12,
                              decoration: ShapeDecoration(
                                shape: const StadiumBorder(),
                                color: sec == veloce
                                    ? colore
                                    : scheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _treNumeri([
            (l10n.passoMedio, fmtMinSec(medio.toDouble()), '/km'),
            (l10n.kmPiuVeloce, fmtMinSec(veloce.toDouble()), '/km'),
            if (s.fcMedia > 0)
              (l10n.battitoMedio, '${s.fcMedia}', 'bpm')
            else
              (l10n.tempo, fmtDurataBreve(s.durataMin), ''),
          ]),
        ],
      ),
    );
  }
}

/// Camminata: il profilo della quota con la salita totale.
class ImmagineProfilo extends StatelessWidget {
  final Sessione sessione;
  final List<Campione> quota;
  const ImmagineProfilo({
    super.key,
    required this.sessione,
    required this.quota,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final colore = coloreSport(s.sport);
    final alta = massimo(quota).round();
    return _Cornice(
      data: dataLunga(s.data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titolo(s),
          const SizedBox(height: 10),
          Row(
            spacing: 24,
            children: [
              _Numero((l10n.mSalita, '+${salitaTotale(quota)}', '')),
              _Numero((l10n.quotaMassima, fmtNum(alta.toDouble()), 'm')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _Quota(
                ricampiona(quota, punti: 150),
                colore,
                scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _treNumeri(
            numeriSessione(s).where((n) => n.$1 != l10n.passo).toList(),
          ),
        ],
      ),
    );
  }
}

class _Quota extends CustomPainter {
  final List<Campione> punti;
  final Color colore;
  final Color cima;
  _Quota(this.punti, this.colore, this.cima);

  @override
  void paint(Canvas canvas, Size size) {
    if (punti.length < 2) return;
    final basso = punti.map((c) => c.v).reduce(math.min);
    final alto = punti.map((c) => c.v).reduce(math.max);
    final salto = math.max(alto - basso, 20);
    double y(double v) => size.height * (1 - 0.1 - 0.8 * (v - basso) / salto);
    double x(int i) => i / (punti.length - 1) * size.width;
    final linea = Path()..moveTo(0, y(punti.first.v));
    for (var i = 1; i < punti.length; i++) {
      linea.lineTo(x(i), y(punti[i].v));
    }
    final pieno = Path.from(linea)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      pieno,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colore.withValues(alpha: 0.5),
            colore.withValues(alpha: 0.04),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      linea,
      Paint()
        ..color = colore
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
    final i = punti.indexWhere((c) => c.v == alto);
    canvas.drawCircle(Offset(x(i), y(alto)), 4, Paint()..color = cima);
  }

  @override
  bool shouldRepaint(_Quota old) => old.punti != punti || old.colore != colore;
}

/// Nuoto: il passo ai 100 m di ogni ripetuta, la più alta è la più veloce.
class ImmagineRipetute extends StatelessWidget {
  final Sessione sessione;
  final List<int> passi; // secondi ai 100 m
  final int passoMedio; // secondi ai 100 m; 0 = media delle ripetute
  const ImmagineRipetute({
    super.key,
    required this.sessione,
    required this.passi,
    this.passoMedio = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final colore = coloreSport(s.sport);
    final veloce = passi.reduce(math.min);
    final medio = passoMedio > 0
        ? passoMedio
        : passi.fold(0, (a, b) => a + b) ~/ passi.length;
    return _Cornice(
      data: dataLunga(s.data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titolo(
            s,
            destra: s.distanzaKm > 0
                ? fmtDistanza(s.sport, s.distanzaKm)
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.passoOgni100M,
            style: t.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: passi.length > 16 ? 2 : 5,
              children: [
                for (final p in passi.take(30))
                  Expanded(
                    child: FractionallySizedBox(
                      heightFactor: (veloce / p).clamp(0.2, 1).toDouble(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: p == veloce
                              ? colore
                              : colore.withValues(alpha: 0.55),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _treNumeri([
            (l10n.passoMedio, fmtMinSec(medio.toDouble()), '/100 m'),
            (l10n.n100PiuVeloce, fmtMinSec(veloce.toDouble()), ''),
            (l10n.tempo, fmtDurataBreve(s.durataMin), ''),
          ]),
        ],
      ),
    );
  }
}

/// Forza: la figura dei muscoli allenati, davanti e dietro.
class ImmagineMuscoli extends StatelessWidget {
  final Sessione sessione;
  final String sesso;
  final Set<String> muscoli;
  final double kgTotali;
  final int esercizi;
  const ImmagineMuscoli({
    super.key,
    required this.sessione,
    required this.sesso,
    required this.muscoli,
    this.kgTotali = 0,
    this.esercizi = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    return _Cornice(
      data: dataLunga(s.data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titolo(s),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 28,
              children: [
                MappaMuscoli(sesso: sesso, evidenziati: muscoli),
                MappaMuscoli(sesso: sesso, retro: true, evidenziati: muscoli),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [for (final m in muscoli.take(4)) nomiMuscoli[m] ?? m].join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          _treNumeri([
            (l10n.tempo, fmtDurataBreve(s.durataMin), ''),
            if (kgTotali > 0)
              (l10n.sollevati, fmtNum(kgTotali.roundToDouble()), 'kg'),
            if (esercizi > 0) (l10n.esercizi, '$esercizi', ''),
          ]),
        ],
      ),
    );
  }
}

/// Arrampicata: la scheda della seduta, come l'hai scritta.
class ImmagineArrampicata extends StatelessWidget {
  final Sessione sessione;
  final SedutaArrampicata seduta;
  const ImmagineArrampicata({
    super.key,
    required this.sessione,
    required this.seduta,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final a = seduta;
    final colore = coloreSport(s.sport);
    final righe = a.riassunto.skip(1).toList();
    return _Cornice(
      data: dataLunga(s.data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titolo(s),
          const SizedBox(height: 6),
          Text(
            a.riassunto.first,
            style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            a.gradoMax,
            style: t.displayLarge?.copyWith(
              fontFamily: famigliaTitoli,
              fontWeight: FontWeight.w700,
              letterSpacing: -3,
              color: colore,
              height: 1,
            ),
          ),
          Text(
            a.stile.isEmpty
                ? l10n.gradoPiuAlto
                : l10n.gradoPiuAlto2(a.stile.toLowerCase()),
            style: t.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          for (final r in righe.skip(1))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 10),
                    child: Icon(Icons.circle_rounded, size: 8, color: colore),
                  ),
                  Expanded(
                    child: Text(
                      r,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          _treNumeri([
            if (a.chiuse > 0)
              (
                a.falesia ? l10n.vieChiuse2 : l10n.blocchiChiusi2,
                '${a.chiuse}',
                '',
              ),
            if (a.metri > 0) (l10n.saliti, '${a.metri}', 'm'),
            (l10n.tempo, fmtDurataBreve(s.durataMin), ''),
          ]),
        ],
      ),
    );
  }
}

/// Arrampicata: il grado più alto delle ultime sedute, oggi colorato.
class ImmagineProgressi extends StatelessWidget {
  final Sessione sessione;
  final SedutaArrampicata seduta;
  final List<(String, int, bool)> punti;
  const ImmagineProgressi({
    super.key,
    required this.sessione,
    required this.seduta,
    required this.punti,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final colore = coloreSport(s.sport);
    final basso = punti.map((p) => p.$2).reduce(math.min);
    final alto = punti.map((p) => p.$2).reduce(math.max);
    return _Cornice(
      data: dataLunga(s.data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titolo(s, destra: seduta.gradoMax),
          const SizedBox(height: 4),
          Text(
            punti.length < 2
                ? l10n.primaSedutaQuiSi
                : l10n.gradoPiuAltoDelle(punti.length),
            style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: [
                for (final (grado, livello, oggi) in punti)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          grado,
                          maxLines: 1,
                          style: t.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: oggi ? colore : scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: alto == basso
                                ? 0.8
                                : 0.3 +
                                      0.7 * (livello - basso) / (alto - basso),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: oggi
                                    ? colore
                                    : scheme.surfaceContainerHighest,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _treNumeri([
            if (seduta.chiuse > 0)
              (seduta.falesia ? 'Vie' : l10n.blocchi, '${seduta.chiuse}', ''),
            (l10n.tempo, fmtDurataBreve(s.durataMin), ''),
            if (seduta.progetto.isNotEmpty)
              (l10n.progetto2, seduta.progetto, ''),
          ]),
        ],
      ),
    );
  }
}

/// La tua foto a tutta pagina, con marchio in alto e i numeri su una fascia
/// scura in basso. Testi sempre chiari: stanno sopra una foto, non sul tema.
class ImmagineFoto extends StatelessWidget {
  final Sessione sessione;
  final Uint8List foto;
  final int passoNuoto; // secondi ai 100 m; 0 = dalla durata
  const ImmagineFoto({
    super.key,
    required this.sessione,
    required this.foto,
    this.passoNuoto = 0,
  });

  static const _testo = Colors.white;
  static const _velo = Colors.black;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = sessione;
    final numeri = numeriSessione(s, passoNuoto: passoNuoto).take(3).toList();
    TextStyle? chiaro(TextStyle? x, [double alfa = 1]) =>
        x?.copyWith(color: _testo.withValues(alpha: alfa));
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: SizedBox.expand(
              child: Image.memory(foto, fit: BoxFit.cover),
            ),
          ),
        ),
        IgnorePointer(
          child: Column(
            children: [
              Container(
                height: 84,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _velo.withValues(alpha: 0.5),
                      _velo.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _velo.withValues(alpha: 0),
                      _velo.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 16,
          child: IgnorePointer(
            child: Row(
              children: [
                Text(
                  '#avidididadi',
                  maxLines: 1,
                  softWrap: false,
                  style: chiaro(
                    t.titleMedium?.copyWith(
                      fontFamily: famigliaTitoli,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dataLunga(s.data),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: chiaro(t.labelMedium),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 18,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titoloSessione(s.sport, s.tipo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: chiaro(
                    t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final (etichetta, valore, unita) in numeri)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unita.isEmpty ? valore : '$valore $unita',
                              maxLines: 1,
                              style: chiaro(
                                t.titleLarge?.copyWith(
                                  fontFamily: famigliaTitoli,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(etichetta, style: chiaro(t.labelSmall, 0.75)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Un numero grande con unità ed etichetta.
class _Numero extends StatelessWidget {
  final (String, String, String) dato;
  const _Numero(this.dato);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final (etichetta, valore, unita) = dato;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: valore,
                  style: t.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                if (unita.isNotEmpty)
                  TextSpan(
                    text: ' $unita',
                    style: t.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            maxLines: 1,
          ),
        ),
        Text(
          etichetta,
          style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// L'immagine di una sessione: sport, titolo, numeri, il percorso se scelto,
/// per la forza i primi esercizi.
class ImmagineSessione extends StatelessWidget {
  final Sessione sessione;
  final Percorso? percorso;
  final double kgTotali;
  final List<(String, String)> esercizi; // nome, serie fatte
  final int passoNuoto; // secondi ai 100 m; 0 = dalla durata
  const ImmagineSessione({
    super.key,
    required this.sessione,
    this.percorso,
    this.kgTotali = 0,
    this.esercizi = const [],
    this.passoNuoto = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final colore = coloreSport(s.sport);
    final numeri = numeriSessione(
      s,
      kgTotali: kgTotali,
      passoNuoto: passoNuoto,
    ).take(6).toList();
    return _Cornice(
      data: dataLunga(s.data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colore.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconaSport(s.sport), color: colore, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nomeSessione(s.sport, s.tipo),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (percorso case final p?)
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _Giro(p, colore),
              ),
            )
          else if (esercizi.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (nome, fatto) in esercizi)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$nome  ',
                              style: t.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: fatto,
                              style: t.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            )
          else
            const Spacer(),
          const SizedBox(height: 12),
          // Due colonne di numeri.
          Wrap(
            runSpacing: 14,
            children: [
              for (final n in numeri)
                SizedBox(width: (_larghezza - 48) / 2, child: _Numero(n)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// La forma del giro, nel colore dello sport.
class _Giro extends CustomPainter {
  final Percorso percorso;
  final Color colore;
  _Giro(this.percorso, this.colore);

  @override
  void paint(Canvas canvas, Size size) {
    final punti = percorso.punti;
    if (punti.length < 2) return;
    var minLat = punti.first.lat, maxLat = minLat;
    var minLon = punti.first.lon, maxLon = minLon;
    for (final p in punti) {
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
      minLon = math.min(minLon, p.lon);
      maxLon = math.max(maxLon, p.lon);
    }
    // I gradi di longitudine si stringono verso i poli.
    final k = math.cos((minLat + maxLat) / 2 * math.pi / 180);
    final w = math.max((maxLon - minLon) * k, 1e-9);
    final h = math.max(maxLat - minLat, 1e-9);
    final scala = math.min(size.width / w, size.height / h) * 0.92;
    final dx = (size.width - w * scala) / 2;
    final dy = (size.height - h * scala) / 2;
    Offset o(PuntoGps p) => Offset(
      dx + (p.lon - minLon) * k * scala,
      dy + (maxLat - p.lat) * scala,
    );
    final linea = Path()..moveTo(o(punti.first).dx, o(punti.first).dy);
    for (final p in punti.skip(1)) {
      final q = o(p);
      linea.lineTo(q.dx, q.dy);
    }
    canvas.drawPath(
      linea,
      Paint()
        ..color = colore.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      linea,
      Paint()
        ..color = colore
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Giro old) =>
      old.percorso != percorso || old.colore != colore;
}

// ---------------------------------------------------------------------
// Settimana

class _CondividiSettimana extends StatefulWidget {
  final AppState state;
  const _CondividiSettimana({required this.state});

  @override
  State<_CondividiSettimana> createState() => _CondividiSettimanaState();
}

class _CondividiSettimanaState extends State<_CondividiSettimana> {
  final _chiave = GlobalKey();
  int _indietro = 0; // 0 = questa settimana

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final oggi = soloData(DateTime.now());
    final lunedi = lunediDi(oggi).subtract(Duration(days: 7 * _indietro));
    final r = riepilogoSettimana(
      widget.state.piano,
      widget.state.sessioni,
      lunedi,
      oggi,
    );
    return _Pagina(
      titolo: l10n.condividiSettimana,
      chiave: _chiave,
      testo: testoSettimana(r),
      immagine: ImmagineSettimana(riepilogo: r),
      scelte: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.settimanaPrima,
              onPressed: _indietro < 52
                  ? () => setState(() => _indietro++)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                _indietro == 0
                    ? l10n.questaSettimana
                    : periodoSettimana(lunedi),
                textAlign: TextAlign.center,
                style: t.titleSmall,
              ),
            ),
            IconButton(
              tooltip: l10n.settimanaDopo,
              onPressed: _indietro > 0
                  ? () => setState(() => _indietro--)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

/// L'immagine della settimana: anello delle sedute, tempo e km, i sette
/// giorni con gli sport fatti e il riassunto per sport.
class ImmagineSettimana extends StatelessWidget {
  final RiepilogoSettimana riepilogo;
  const ImmagineSettimana({super.key, required this.riepilogo});

  static List<String> get _lettere => inizialiGiorni;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final r = riepilogo;
    return _Cornice(
      data: l10n.settimana(periodoSettimana(r.lunedi)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnelloPulse(
                valore: r.previste == 0
                    ? (r.fatte > 0 ? 1 : 0)
                    : (r.fatte / r.previste).clamp(0, 1).toDouble(),
                dimensione: 104,
                spessore: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.previste == 0
                          ? '${r.fatte}'
                          : '${r.fatte}/${r.previste}',
                      style: t.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.parolaSedute,
                      style: t.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    _Numero(
                      r.minuti >= 60
                          ? (
                              l10n.tempo,
                              '${r.minuti ~/ 60}:${two(r.minuti % 60)}',
                              'h',
                            )
                          : (l10n.tempo, '${r.minuti}', 'min'),
                    ),
                    if (r.km >= 0.1)
                      _Numero((
                        l10n.distanza,
                        fmtDistanza('Corsa', r.km).split(' ').first,
                        'km',
                      )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // I sette giorni: un pallino colorato per ogni sport fatto.
          Row(
            children: [
              for (var g = 0; g < 7; g++)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _lettere[g],
                        style: t.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (r.perGiorno[g].isEmpty)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                        )
                      else
                        for (final sport in r.perGiorno[g].take(2))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: coloreSport(sport),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                iconaSport(sport),
                                size: 15,
                                color: scheme.surface,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (r.vuota)
            Text(
              l10n.nessunaSessioneQuestaSettimana,
              style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            )
          else
            for (final x in r.perSport.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      iconaSport(x.sport),
                      color: coloreSport(x.sport),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        x.sedute == 1 ? x.sport : '${x.sport} ×${x.sedute}',
                        style: t.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      [
                        fmtDurataBreve(x.minuti),
                        if (x.km > 0) fmtDistanza(x.sport, x.km),
                      ].join(' · '),
                      style: t.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
