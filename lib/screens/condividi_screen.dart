import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../carico.dart';
import '../condivisione.dart';
import '../health_connect.dart';
import '../models.dart';
import '../percorso.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../riepilogo_condiviso.dart';
import '../tema.dart';
import '../widgets.dart';

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
    titolo: 'Condividi',
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
  const _Pagina({
    required this.titolo,
    required this.chiave,
    required this.immagine,
    required this.scelte,
    required this.testo,
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
              final ok = await _condividi(chiave, testo);
              if (!ok) {
                messenger.showSnackBar(
                  avviso(content: Text('Immagine non riuscita: riprova.')),
                );
              }
            },
            icona: Icons.share,
            testo: 'Condividi',
          ),
          const SizedBox(height: 8),
          Text(
            "L'immagine si crea sul telefono e va solo all'app che scegli "
            '(WhatsApp, Instagram…).',
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
  Percorso? _percorso;
  // Spento di base: il percorso dice da dove si parte (spesso casa).
  bool _conPercorso = false;

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
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sessione;
    final serie = stessoSport(s.sport, 'Forza')
        ? widget.state.serieDel(s.data)
        : const <String, List<SerieFatta>>{};
    final kg = serie.values
        .expand((x) => x)
        .fold(0.0, (t, x) => t + x.ripetizioni * x.kg);
    return _Pagina(
      titolo: 'Condividi la sessione',
      chiave: _chiave,
      testo: testoSessione(s),
      immagine: ImmagineSessione(
        sessione: s,
        percorso: _conPercorso ? _percorso : null,
        kgTotali: kg,
        esercizi: [
          for (final e in serie.entries.take(5)) (e.key, fmtSerie(e.value)),
        ],
      ),
      scelte: [
        if (_percorso != null)
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mostra il percorso'),
              subtitle: const Text(
                'Fa vedere la forma del giro: occhio se parti da casa.',
              ),
              value: _conPercorso,
              onChanged: (v) => setState(() => _conPercorso = v),
            ),
          ),
      ],
    );
  }
}

/// Il fondo comune: colore del tema con i bagliori, marchio e data in alto,
/// firma in basso.
class _Cornice extends StatelessWidget {
  final String sopra;
  final String data;
  final Widget child;
  const _Cornice({
    required this.sopra,
    required this.data,
    required this.child,
  });

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
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sopra.toUpperCase(),
                        style: t.labelMedium?.copyWith(
                          color: scheme.primary,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      data,
                      style: t.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(child: child),
                Text(
                  'Allenato con Avidididadi',
                  style: t.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.6,
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
  const ImmagineSessione({
    super.key,
    required this.sessione,
    this.percorso,
    this.kgTotali = 0,
    this.esercizi = const [],
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = sessione;
    final colore = coloreSport(s.sport);
    final numeri = numeriSessione(s, kgTotali: kgTotali).take(6).toList();
    return _Cornice(
      sopra: 'Avidididadi',
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
                  titoloSessione(s.sport, s.tipo),
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
      titolo: 'Condividi la settimana',
      chiave: _chiave,
      testo: testoSettimana(r),
      immagine: ImmagineSettimana(riepilogo: r),
      scelte: [
        Row(
          children: [
            IconButton(
              tooltip: 'Settimana prima',
              onPressed: _indietro < 52
                  ? () => setState(() => _indietro++)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                _indietro == 0 ? 'Questa settimana' : periodoSettimana(lunedi),
                textAlign: TextAlign.center,
                style: t.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Settimana dopo',
              onPressed: _indietro > 0
                  ? () => setState(() => _indietro--)
                  : null,
              icon: const Icon(Icons.chevron_right),
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

  static const _lettere = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final r = riepilogo;
    return _Cornice(
      sopra: 'La mia settimana',
      data: periodoSettimana(r.lunedi),
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
                      'sedute',
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
                              'Tempo',
                              '${r.minuti ~/ 60}:${two(r.minuti % 60)}',
                              'h',
                            )
                          : ('Tempo', '${r.minuti}', 'min'),
                    ),
                    if (r.km >= 0.1)
                      _Numero((
                        'Distanza',
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
              'Nessuna sessione in questa settimana.',
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
