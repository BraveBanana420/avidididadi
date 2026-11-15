import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../tema.dart';

// Giro guidato: una maschera scura con un buco trasparente sul tasto da
// conoscere e una scheda che spiega a cosa serve. Toccando il buco (o
// "Avanti") si passa al passo dopo: il tasto non viene premuto davvero, così
// il giro non apre schermate e non cambia dati.

/// I punti dell'app da mostrare, agganciati ai widget veri.
class ChiaviTour {
  static final barra = GlobalKey(debugLabel: 'tour-barra');
  static final voci = [
    for (var i = 0; i < 4; i++) GlobalKey(debugLabel: 'tour-voce-$i'),
  ];
  static final giorno = GlobalKey(debugLabel: 'tour-giorno');
  static final energia = GlobalKey(debugLabel: 'tour-energia');
  static final settimana = GlobalKey(debugLabel: 'tour-settimana');
  static final settimanaTipo = GlobalKey(debugLabel: 'tour-settimana-tipo');
  static final feedback = GlobalKey(debugLabel: 'tour-feedback');
  static final prepara = GlobalKey(debugLabel: 'tour-prepara');
  static final collegamenti = GlobalKey(debugLabel: 'tour-collegamenti');
}

/// Un passo del giro.
class PassoTour {
  final String titolo;
  final String testo;
  final int? sezione; // 0 Oggi, 1 Progressi, 2 Coach, 3 Profilo
  final GlobalKey? chiave; // null o non visibile: solo la spiegazione
  final GlobalKey? ancora; // un widget già visibile nella stessa lista
  final String senzaTasto; // spiegazione se il tasto oggi non c'è
  const PassoTour({
    required this.titolo,
    required this.testo,
    this.sezione,
    this.chiave,
    this.ancora,
    this.senzaTasto = '',
  });
}

/// Le 10 funzioni principali, nell'ordine in cui si visitano.
final passiTour = [
  PassoTour(
    titolo: 'La barra in basso',
    testo:
        'Quattro sezioni: Oggi, Progressi, Coach e Profilo. Puoi anche '
        'scorrere di lato per passare dall\'una all\'altra.',
    sezione: 0,
    chiave: ChiaviTour.barra,
  ),
  PassoTour(
    titolo: 'La seduta del giorno',
    testo:
        'Qui trovi cosa fare oggi. Tocca la seduta per vedere i dettagli e ▶ '
        'per l\'allenamento guidato passo passo, con timer, bip e GPS.',
    sezione: 0,
    chiave: ChiaviTour.giorno,
  ),
  PassoTour(
    titolo: 'L\'energia',
    testo:
        'Com\'è il tuo recupero oggi, da sonno, battito a riposo e HRV. '
        'Toccala per i dettagli: se è bassa, meglio una seduta leggera.',
    sezione: 0,
    chiave: ChiaviTour.energia,
    senzaTasto:
        'Comparirà in alto a destra quando l\'orologio manda sonno e battito '
        'a riposo (Profilo → Dati e collegamenti).',
  ),
  PassoTour(
    titolo: 'La tua settimana',
    testo:
        'Un cerchio per giorno: pieno se fatto, col bordo se da fare. Tocca '
        'un giorno per vederlo sopra; scorri di lato sui cerchi per la '
        'settimana prima o dopo.',
    sezione: 0,
    chiave: ChiaviTour.settimana,
  ),
  PassoTour(
    titolo: 'La settimana tipo',
    testo:
        'Quali giorni ti alleni, quale sport e per quanto tempo. Da qui '
        'nasce tutto il calendario: cambiala quando cambiano i tuoi impegni.',
    sezione: 0,
    chiave: ChiaviTour.settimanaTipo,
    ancora: ChiaviTour.settimana,
  ),
  PassoTour(
    titolo: 'Com\'è andata?',
    testo:
        'Dopo ogni allenamento dai un voto alla fatica: le sedute dopo si '
        'adattano, più facili o più impegnative.',
    sezione: 0,
    chiave: ChiaviTour.feedback,
    senzaTasto:
        'Quando un allenamento fatto non ha ancora un voto, qui in Oggi '
        'compare "Com\'è andata?". Puoi darlo anche toccando la seduta fatta.',
  ),
  PassoTour(
    titolo: 'Progressi',
    testo:
        'Il carico di allenamento, i grafici e i resoconti di ogni sport: '
        'tocca uno sport per i dettagli.',
    sezione: 1,
    chiave: null, // la voce della barra, scelta sotto
  ),
  PassoTour(
    titolo: 'Coach',
    testo:
        'L\'assistente: chiedigli consigli sul piano o su come ti senti. '
        'Lo colleghi dalle impostazioni in alto (sul tuo PC o con la tua app).',
    sezione: 2,
  ),
  PassoTour(
    titolo: 'Sedute e schede',
    testo:
        '"Prepara le sedute": l\'app scrive gli allenamenti per te. "Le mie '
        'schede": scrivi quelli del tuo personal trainer o allenatore.',
    sezione: 3,
    chiave: ChiaviTour.prepara,
  ),
  PassoTour(
    titolo: 'Dati e collegamenti',
    testo:
        'Collega l\'orologio (Health Connect o intervals.icu) e fai il backup '
        'dei tuoi dati. Il giro lo ritrovi sempre qui sotto, in "Giro '
        "guidato dell'app\".",
    sezione: 3,
    chiave: ChiaviTour.collegamenti,
    ancora: ChiaviTour.prepara,
  ),
];

// ---------------------------------------------------------------------------
// Il giro è stato proposto? (tour.txt)

final tourProposto = ValueNotifier<bool>(true);

Future<File> _file() async =>
    File('${(await getApplicationDocumentsDirectory()).path}/tour.txt');

Future<void> caricaTour() async {
  try {
    tourProposto.value = await (await _file()).exists();
  } catch (_) {
    tourProposto.value = true; // nel dubbio non si insiste
  }
}

Future<void> segnaTourProposto() async {
  tourProposto.value = true;
  try {
    await (await _file()).writeAsString('si');
  } catch (_) {}
}

// ---------------------------------------------------------------------------
// La maschera

/// Cambia sezione: lo imposta la schermata principale.
void Function(int sezione)? vaiAllaSezione;

/// Avvia il giro guidato sopra tutta l'app; alla fine si torna alla sezione
/// [da] (0 Oggi, 3 Profilo).
void avviaTour(BuildContext context, {int da = 3}) {
  segnaTourProposto();
  late final OverlayEntry voce;
  voce = OverlayEntry(
    builder: (_) =>
        _Maschera(passi: passiTour, da: da, chiudi: () => voce.remove()),
  );
  Overlay.of(context, rootOverlay: true).insert(voce);
}

class _Maschera extends StatefulWidget {
  final List<PassoTour> passi;
  final int da;
  final VoidCallback chiudi;
  const _Maschera({
    required this.passi,
    required this.da,
    required this.chiudi,
  });

  @override
  State<_Maschera> createState() => _MascheraState();
}

class _MascheraState extends State<_Maschera>
    with SingleTickerProviderStateMixin {
  int i = 0;
  Rect? buco; // in coordinate dello schermo
  bool pronto = false;
  late final AnimationController _pulsa = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  /// Posizioni delle liste prima del giro, per rimetterle a posto alla fine.
  final _scorrimenti = <ScrollPosition, double>{};

  @override
  void initState() {
    super.initState();
    _prepara();
  }

  @override
  void dispose() {
    _pulsa.dispose();
    super.dispose();
  }

  PassoTour get p => widget.passi[i];

  Future<void> _attendi([int ms = 0]) async {
    if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
    await WidgetsBinding.instance.endOfFrame;
  }

  /// Porta in vista il punto del passo e ne misura il rettangolo.
  Future<void> _prepara() async {
    setState(() => pronto = false);
    final sezione = p.sezione;
    if (sezione != null) {
      vaiAllaSezione?.call(sezione);
      await _attendi(320);
    }
    // Progressi e Coach: si mostra la loro voce nella barra.
    final chiave =
        p.chiave ??
        (sezione != null && sezione > 0 && sezione < 3
            ? ChiaviTour.voci[sezione]
            : null);
    BuildContext? ctx = chiave?.currentContext;
    // Ancora non costruito (più in basso nella lista): si scorre per trovarlo.
    if (ctx == null && p.ancora?.currentContext != null) {
      final pos = Scrollable.maybeOf(p.ancora!.currentContext!)?.position;
      if (pos != null) {
        _scorrimenti.putIfAbsent(pos, () => pos.pixels);
        for (var k = 0; k < 12 && chiave?.currentContext == null; k++) {
          if (pos.pixels >= pos.maxScrollExtent) break;
          pos.jumpTo(
            (pos.pixels + pos.viewportDimension * 0.6).clamp(
              0,
              pos.maxScrollExtent,
            ),
          );
          await _attendi();
        }
        ctx = chiave?.currentContext;
      }
    }
    if (ctx != null && ctx.mounted) {
      final pos = Scrollable.maybeOf(ctx)?.position;
      if (pos != null) _scorrimenti.putIfAbsent(pos, () => pos.pixels);
      await Scrollable.ensureVisible(
        ctx,
        alignment: 0.35,
        duration: const Duration(milliseconds: 250),
      );
      await _attendi(60);
    }
    Rect? r;
    final box = chiave?.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize && box.attached) {
      final o = box.localToGlobal(Offset.zero);
      if (box.size.height > 4 && box.size.width > 4) r = o & box.size;
    }
    if (!mounted) return;
    setState(() {
      buco = r?.inflate(8);
      pronto = true;
    });
  }

  void _avanti() {
    if (i >= widget.passi.length - 1) return _fine();
    i++;
    _prepara();
  }

  void _indietro() {
    if (i == 0) return;
    i--;
    _prepara();
  }

  void _fine() {
    for (final MapEntry(key: pos, value: px) in _scorrimenti.entries) {
      try {
        pos.jumpTo(px);
      } catch (_) {}
    }
    vaiAllaSezione?.call(widget.da); // si torna da dove si è partiti
    widget.chiudi();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, vincoli) => _costruisci(context, vincoli.biggest),
    );
  }

  Widget _costruisci(BuildContext context, Size schermo) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final b = buco;
    final testo = b == null && p.senzaTasto.isNotEmpty
        ? '${p.testo}\n\n${p.senzaTasto}'
        : p.testo;
    // La scheda va dove c'è più spazio: sotto il buco o sopra.
    final sotto = b == null || b.center.dy < schermo.height * 0.5;
    final scheda = Material(
      color: scheme.surfaceContainerHigh,
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${i + 1} di ${widget.passi.length}',
              style: t.labelMedium?.copyWith(color: scheme.primary),
            ),
            const SizedBox(height: 4),
            Text(p.titolo, style: t.titleLarge),
            const SizedBox(height: 6),
            Text(testo, style: t.bodyMedium),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Tocca Avanti per continuare.',
                style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton(onPressed: _fine, child: const Text('Esci')),
                const Spacer(),
                if (i > 0)
                  IconButton(
                    tooltip: 'Indietro',
                    onPressed: _indietro,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                FilledButton(
                  onPressed: _avanti,
                  child: Text(i == widget.passi.length - 1 ? 'Fine' : 'Avanti'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Fondo scuro con il buco; un tocco nel buco va avanti.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                if (b != null && b.contains(d.globalPosition)) _avanti();
              },
              child: AnimatedBuilder(
                animation: _pulsa,
                builder: (_, _) => CustomPaint(
                  painter: _PittoreMaschera(
                    buco: pronto ? b : null,
                    // Velo leggero: antracite nel tema scuro, bianco nel chiaro.
                    fondo: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A30).withValues(alpha: 0.82)
                        : Colors.white.withValues(alpha: 0.78),
                    anello: Pulse.di(context).anello.first,
                    pulsazione: _pulsa.value,
                  ),
                ),
              ),
            ),
          ),
          if (pronto)
            Positioned(
              left: 16,
              right: 16,
              top: sotto
                  ? (b == null ? schermo.height * 0.3 : b.bottom + 20)
                  : null,
              bottom: sotto ? null : schermo.height - b.top + 20,
              child: SafeArea(top: false, bottom: false, child: scheda),
            ),
        ],
      ),
    );
  }
}

class _PittoreMaschera extends CustomPainter {
  final Rect? buco;
  final Color fondo;
  final Color anello;
  final double pulsazione; // 0..1
  _PittoreMaschera({
    required this.buco,
    required this.fondo,
    required this.anello,
    required this.pulsazione,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tutto = Path()..addRect(Offset.zero & size);
    final b = buco;
    if (b == null) {
      canvas.drawPath(tutto, Paint()..color = fondo);
      return;
    }
    final raggio = Radius.circular(
      (b.shortestSide / 2).clamp(12, 32).toDouble(),
    );
    final forma = RRect.fromRectAndRadius(b, raggio);
    canvas.drawPath(
      Path.combine(PathOperation.difference, tutto, Path()..addRRect(forma)),
      Paint()..color = fondo,
    );
    // Anello al neon che pulsa piano intorno al buco.
    final largo = forma.inflate(2 + 4 * pulsazione);
    canvas.drawRRect(
      largo,
      Paint()
        ..color = anello.withValues(alpha: 0.35 * (1 - pulsazione))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      forma,
      Paint()
        ..color = anello
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_PittoreMaschera o) =>
      o.buco != buco || o.pulsazione != pulsazione || o.fondo != fondo;
}

/// Invito, una volta sola, a fare il giro guidato (nella schermata Oggi).
class InvitoTour extends StatelessWidget {
  const InvitoTour({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: tourProposto,
    builder: (context, proposto, _) {
      if (proposto) return const SizedBox.shrink();
      final scheme = Theme.of(context).colorScheme;
      return Card(
        color: scheme.primaryContainer,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vuoi un giro guidato dell'app? Dieci passi, un minuto.",
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: segnaTourProposto,
                    child: const Text('No, grazie'),
                  ),
                  FilledButton(
                    onPressed: () => avviaTour(context, da: 0),
                    child: const Text('Sì'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
