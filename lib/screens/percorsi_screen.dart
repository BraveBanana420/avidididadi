import 'dart:convert';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../mappa_offline.dart';
import '../navigazione.dart';
import '../percorso.dart';
import '../pulse.dart';
import '../widgets.dart';
import 'mappa_percorso.dart';
import '../l10n/lingua.dart';

/// Sceglie un file GPX e lo aggiunge a "I miei percorsi". Null se annullato
/// o non valido (con il motivo in un messaggio).
Future<PercorsoSalvato?> aggiungiGpx(
  BuildContext context,
  AppState state,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final files = await FilePicker.pickFiles(type: FileType.any);
    if (files.isEmpty) return null;
    final f = files.first;
    if ((await f.length() ?? 0) > maxByteGpx) {
      throw FormatException(l10n.fileTroppoGrandeGpx2);
    }
    final nomeFile = f.name.replaceFirst(
      RegExp(r'\.gpx$', caseSensitive: false),
      '',
    );
    final t = tracciaDaGpx(
      utf8.decode(await f.readAsBytes(), allowMalformed: true),
      nomeFile: nomeFile.isEmpty ? 'Percorso' : nomeFile,
    );
    final p = await state.aggiungiPercorso(t);
    scaricaMappa(state, p);
    messenger.showSnackBar(
      avviso(content: Text(l10n.aggiunto(p.nome, fmtKm(p.km)))),
    );
    return p;
  } on FormatException catch (e) {
    messenger.showSnackBar(avviso(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(
      avviso(content: Text(l10n.impossibileLeggereFile(e))),
    );
  }
  return null;
}

/// Pallino della partenza, come sulla mappa.
const verdePartenza = Color(0xFF22E07A);

/// Scarica (se non c'è già) la mappa attorno al percorso, per usarla senza
/// rete. Va avanti da sola: lo stato si vede nella pagina del percorso.
Future<void> scaricaMappa(AppState state, PercorsoSalvato p) async {
  final t = await state.tracciaDi(p);
  if (t != null) await mappeOffline.scarica(p.id, t);
}

/// "42,20 km · 320 m di salita".
String descriviPercorso(PercorsoSalvato p) => [
  fmtKm(p.km),
  if (p.dislivello > 0) l10n.mSalita2(p.dislivello),
].join(' · ');

/// "I miei percorsi": i GPX da seguire. Con [scegli] un tocco sceglie il
/// percorso e torna indietro con il suo id.
class PercorsiScreen extends StatelessWidget {
  final AppState state;
  final bool scegli;
  const PercorsiScreen({super.key, required this.state, this.scegli = false});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: Text(scegli ? l10n.scegliPercorso : l10n.mieiPercorsi),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final p = await aggiungiGpx(context, state);
          if (p != null && scegli && context.mounted) {
            Navigator.pop(context, p.id);
          }
        },
        icon: const Icon(Icons.upload_file_rounded),
        label: Text(l10n.aggiungiGpx),
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final lista = state.percorsiSalvati;
          if (lista.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              children: [
                Icon(Icons.route_rounded, size: 56, color: scheme.primary),
                const SizedBox(height: 12),
                Text(
                  l10n.nessunPercorso,
                  style: t.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aggiungiFileGpxGara,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium,
                ),
                const SizedBox(height: 16),
                const _DoveTrovarli(),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              for (final p in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VocePercorso(
                    state: state,
                    percorso: p,
                    onTap: scegli
                        ? () => Navigator.pop(context, p.id)
                        : () => _apri(context, p),
                    onInfo: scegli ? () => _apri(context, p) : null,
                  ),
                ),
              const _DoveTrovarli(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _apri(BuildContext context, PercorsoSalvato p) async {
    final scelto = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PercorsoScreen(state: state, percorso: p, scegli: scegli),
      ),
    );
    if (scelto != null && context.mounted) Navigator.pop(context, scelto);
  }
}

/// Dove si scaricano i GPX: in una sezione da aprire.
class _DoveTrovarli extends StatelessWidget {
  const _DoveTrovarli();

  @override
  Widget build(BuildContext context) => Card(
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(Icons.help_outline_rounded),
        title: Text(l10n.doveTrovoGpx),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(l10n.sitoGaraSpessoC)],
      ),
    ),
  );
}

class _VocePercorso extends StatelessWidget {
  final AppState state;
  final PercorsoSalvato percorso;
  final VoidCallback onTap;
  final VoidCallback? onInfo;
  const _VocePercorso({
    required this.state,
    required this.percorso,
    required this.onTap,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Quali mappe sono già scaricate (si legge una volta sola).
    mappeOffline.carica();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: FutureBuilder<Traccia?>(
                  future: state.tracciaDi(percorso),
                  builder: (context, snap) => snap.data == null
                      ? const SizedBox.shrink()
                      : SagomaTraccia(traccia: snap.data!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      percorso.nome,
                      style: t.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descriviPercorso(percorso),
                      style: t.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    ListenableBuilder(
                      listenable: mappeOffline,
                      builder: (context, _) =>
                          mappeOffline.scaricati.contains(percorso.id)
                          ? Row(
                              children: [
                                Icon(
                                  Icons.offline_pin_rounded,
                                  size: 14,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(l10n.ancheSenzaRete, style: t.labelSmall),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              if (onInfo != null)
                IconButton(
                  tooltip: l10n.vediPercorso,
                  onPressed: onInfo,
                  icon: const Icon(Icons.map_rounded),
                )
              else
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un percorso: mappa, km, salita, profilo altimetrico, curve.
class PercorsoScreen extends StatefulWidget {
  final AppState state;
  final PercorsoSalvato percorso;
  final bool scegli;
  const PercorsoScreen({
    super.key,
    required this.state,
    required this.percorso,
    this.scegli = false,
  });

  @override
  State<PercorsoScreen> createState() => _PercorsoScreenState();
}

class _PercorsoScreenState extends State<PercorsoScreen> {
  late final Future<Traccia?> _traccia = widget.state.tracciaDi(
    widget.percorso,
  );

  Future<void> _rinomina(PercorsoSalvato p) async {
    final c = TextEditingController(text: p.nome);
    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nomePercorso),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: Text(l10n.salva),
          ),
        ],
      ),
    );
    if (nome != null) await widget.state.rinominaPercorso(p.id, nome);
  }

  Future<void> _elimina(PercorsoSalvato p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.eliminarePercorso),
        content: Text(l10n.sparisceDallaRaccoltaDalle(p.nome)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.elimina),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.state.eliminaPercorso(p.id);
    await mappeOffline.elimina(p.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final p =
          widget.state.percorsoSalvato(widget.percorso.id) ?? widget.percorso;
      final t = Theme.of(context).textTheme;
      return Scaffold(
        bottomNavigationBar: widget.scegli
            ? SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: PulsantePrincipale(
                  testo: l10n.usaQuestoPercorso,
                  icona: Icons.check_rounded,
                  onPressed: () => Navigator.pop(context, p.id),
                ),
              )
            : const MargineBarraSistema(),
        appBar: AppBar(
          title: Text(p.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: l10n.rinomina,
              onPressed: () => _rinomina(p),
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: l10n.elimina,
              onPressed: () => _elimina(p),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        body: FutureBuilder<Traccia?>(
          future: _traccia,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final tr = snap.data;
            if (tr == null) {
              return Center(child: Text(l10n.filePercorsoMancante));
            }
            final curve = curveDi(tr);
            final conQuota = tr.punti.any((x) => x.quota != null);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: MappaPercorso(
                            percorso: tr.comePercorso,
                            sport: 'Corsa',
                            interattiva: true,
                          ),
                        ),
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: PulsanteLivelli(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SuperficiePulse(
                  child: Row(
                    children: [
                      for (final (valore, etichetta) in [
                        (fmtKm(p.km), l10n.distanza),
                        (conQuota ? '${p.dislivello} m' : '–', l10n.salita),
                        ('${curve.length}', l10n.curve),
                      ])
                        Expanded(
                          child: Column(
                            children: [
                              FittedBox(
                                child: Text(valore, style: t.titleLarge),
                              ),
                              Text(etichetta, style: t.bodySmall),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MappaOfflineCard(state: widget.state, percorso: p, traccia: tr),
                if (conQuota) ...[
                  const SizedBox(height: 16),
                  Text(l10n.altimetria, style: t.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(height: 120, child: ProfiloAltimetrico(traccia: tr)),
                ],
                const SizedBox(height: 16),
                Text(
                  tr.anello ? l10n.giroAdAnelloSi : l10n.partenzaAlPallinoVerde,
                  style: t.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(l10n.seguirloPrimaPartireCorsa, style: t.bodySmall),
              ],
            );
          },
        ),
      );
    },
  );
}

/// La forma del percorso, piccola: per gli elenchi (niente mappa da
/// scaricare).
class SagomaTraccia extends StatelessWidget {
  final Traccia traccia;
  const SagomaTraccia({super.key, required this.traccia});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: CustomPaint(
        painter: _PittoreSagoma(
          traccia,
          colore: scheme.primary,
          partenza: verdePartenza,
          fondo: scheme.surface,
        ),
      ),
    );
  }
}

class _PittoreSagoma extends CustomPainter {
  final Traccia traccia;
  final Color colore;
  final Color partenza;
  final Color fondo;
  _PittoreSagoma(
    this.traccia, {
    required this.colore,
    required this.partenza,
    required this.fondo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (traccia.vuota) return;
    final (a, b, c, d) = traccia.limiti;
    final k = math.cos((a + c) / 2 * math.pi / 180);
    final w = math.max((d - b) * k, 1e-9);
    final h = math.max(c - a, 1e-9);
    const margine = 10.0;
    final scala = math.min(
      (size.width - 2 * margine) / w,
      (size.height - 2 * margine) / h,
    );
    final ox = (size.width - w * scala) / 2;
    final oy = (size.height - h * scala) / 2;
    Offset o(PuntoTraccia p) =>
        Offset(ox + (p.lon - b) * k * scala, oy + (c - p.lat) * scala);
    final path = Path()
      ..moveTo(o(traccia.punti.first).dx, o(traccia.punti.first).dy);
    for (final p in traccia.punti.skip(1)) {
      final q = o(p);
      path.lineTo(q.dx, q.dy);
    }
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = colore.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawPath(
        path,
        Paint()
          ..color = colore
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    for (final (p, col) in [
      (traccia.punti.last, colore),
      (traccia.punti.first, partenza),
    ]) {
      canvas
        ..drawCircle(o(p), 4, Paint()..color = fondo)
        ..drawCircle(o(p), 3, Paint()..color = col);
    }
  }

  @override
  bool shouldRepaint(_PittoreSagoma old) =>
      old.traccia != traccia || old.colore != colore;
}

/// Il profilo altimetrico: quota lungo il percorso. Con [metri] segna dove
/// sei.
class ProfiloAltimetrico extends StatelessWidget {
  final Traccia traccia;
  final double? metri;
  const ProfiloAltimetrico({super.key, required this.traccia, this.metri});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    // Tutto lo spazio che c'è: in una colonna senza larghezza sarebbe zero.
    return CustomPaint(
      size: Size.infinite,
      painter: _PittoreProfilo(
        traccia,
        metri: metri,
        colore: scheme.primary,
        linee: scheme.outlineVariant,
        testo: t.labelSmall!.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _PittoreProfilo extends CustomPainter {
  final Traccia traccia;
  final double? metri;
  final Color colore;
  final Color linee;
  final TextStyle testo;
  _PittoreProfilo(
    this.traccia, {
    required this.metri,
    required this.colore,
    required this.linee,
    required this.testo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tot = traccia.metri;
    if (tot <= 0) return;
    // Un campione ogni pochi pixel basta, anche per tracce lunghe.
    final n = math.max(2, (size.width / 3).round());
    final quote = <double>[];
    for (var i = 0; i < n; i++) {
      final q = traccia.quotaA(tot * i / (n - 1));
      if (q != null) quote.add(q);
    }
    if (quote.length < 2) return;
    var min = quote.reduce(math.min);
    var max = quote.reduce(math.max);
    // Almeno 50 m di scala: una pianura non deve sembrare una montagna.
    if (max - min < 50) {
      final m = (max + min) / 2;
      min = m - 25;
      max = m + 25;
    }
    const sopra = 14.0;
    final h = size.height - sopra - 2;
    double y(double q) => sopra + h - (q - min) / (max - min) * h;
    final linea = Path();
    for (var i = 0; i < quote.length; i++) {
      final x = size.width * i / (quote.length - 1);
      i == 0 ? linea.moveTo(x, y(quote[i])) : linea.lineTo(x, y(quote[i]));
    }
    final area = Path.from(linea)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colore.withValues(alpha: 0.35),
              colore.withValues(alpha: 0.02),
            ],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        linea,
        Paint()
          ..color = colore
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    final m = metri;
    if (m != null) {
      final x = size.width * (m / tot).clamp(0.0, 1.0);
      final q = traccia.quotaA(m);
      canvas.drawLine(
        Offset(x, sopra),
        Offset(x, size.height),
        Paint()
          ..color = linee
          ..strokeWidth = 1.5,
      );
      if (q != null) {
        canvas.drawCircle(Offset(x, y(q)), 5, Paint()..color = colore);
      }
    }
    // Quota più alta e più bassa, in piccolo.
    final alta = quote.reduce(math.max).round();
    final bassa = quote.reduce(math.min).round();
    final tp = TextPainter(
      text: TextSpan(text: l10n.mMinM(alta, bassa), style: testo),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(_PittoreProfilo old) =>
      old.traccia != traccia || old.metri != metri || old.colore != colore;
}

/// Nella pagina di una seduta in programma (corsa, camminata, bici): il
/// percorso da seguire, da scegliere o cambiare.
class PercorsoDellaSeduta extends StatelessWidget {
  final AppState state;
  final DateTime giorno;
  final String sport;
  const PercorsoDellaSeduta({
    super.key,
    required this.state,
    required this.giorno,
    required this.sport,
  });

  Future<void> _scegli(BuildContext context) async {
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PercorsiScreen(state: state, scegli: true),
      ),
    );
    if (id == null) return;
    await state.assegnaPercorso(giorno, sport, id);
    if (state.percorsoSalvato(id) case final p?) scaricaMappa(state, p);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = state.percorsoDellaSeduta(giorno, sport);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(Icons.route_rounded, color: coloreSport(sport)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p == null ? l10n.percorsoSeguire : p.nome,
                    style: t.titleSmall,
                  ),
                  Text(
                    p == null
                        ? l10n.facoltativoGpxMappaIndicazioni
                        : descriviPercorso(p),
                    style: t.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (p != null)
              IconButton(
                tooltip: l10n.togliPercorso,
                onPressed: () => state.assegnaPercorso(giorno, sport, null),
                icon: const Icon(Icons.close_rounded),
              ),
            TextButton(
              onPressed: () => _scegli(context),
              child: Text(p == null ? l10n.scegli : l10n.cambia),
            ),
          ],
        ),
      ),
    );
  }
}

/// La mappa del percorso senza rete: scaricata, in download, da scaricare.
class MappaOfflineCard extends StatefulWidget {
  final AppState state;
  final PercorsoSalvato percorso;
  final Traccia traccia;
  const MappaOfflineCard({
    super.key,
    required this.state,
    required this.percorso,
    required this.traccia,
  });

  @override
  State<MappaOfflineCard> createState() => _MappaOfflineCardState();
}

class _MappaOfflineCardState extends State<MappaOfflineCard> {
  late final String _peso = pesoStimato(widget.traccia);

  @override
  void initState() {
    super.initState();
    mappeOffline.carica();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final id = widget.percorso.id;
    return ListenableBuilder(
      listenable: mappeOffline,
      builder: (context, _) {
        final avanti = mappeOffline.avanzamento[id];
        final fatto = mappeOffline.scaricati.contains(id);
        final errore = mappeOffline.errori[id];
        final (IconData icona, String titolo, String testo) = avanti != null
            ? (
                Icons.downloading_rounded,
                l10n.scaricoMappa((avanti * 100).round()),
                l10n.puoiUsareAppIntanto,
              )
            : fatto
            ? (
                Icons.offline_pin_rounded,
                l10n.mappaScaricata,
                l10n.stradePercorsoSiVedono,
              )
            : (
                Icons.cloud_download_rounded,
                l10n.mappaSenzaRete,
                errore ?? l10n.scaricaZonaAttornoAl(_peso),
              );
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icona, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titolo, style: t.titleSmall),
                          Text(
                            testo,
                            style: t.bodySmall?.copyWith(
                              color: errore != null && !fatto
                                  ? scheme.error
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (avanti == null)
                      TextButton(
                        onPressed: fatto
                            ? () => mappeOffline.elimina(id)
                            : () => mappeOffline.scarica(id, widget.traccia),
                        child: Text(
                          fatto
                              ? l10n.togli
                              : errore != null
                              ? l10n.riprova
                              : l10n.scarica,
                        ),
                      ),
                  ],
                ),
                if (avanti != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: LinearProgressIndicator(value: avanti),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
