import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tema.dart';

// Componenti dello stile "Pulse": superfici in rilievo, pulsante principale
// sfumato, anello con alone, sfondo con bagliore, barra fluttuante.

/// Spazio da lasciare in fondo alle schede. Con la barra fluttuante
/// (extendBody) il padding in basso comprende già la barra stessa.
double spazioBarra(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 16;

/// Riquadro in rilievo: sfumatura e ombra del tema. Con [gradiente] e [ombra]
/// diventa per esempio il riquadro della seduta di oggi.
class SuperficiePulse extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double raggio;
  final Gradient? gradiente;
  final List<BoxShadow>? ombra;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margine;
  const SuperficiePulse({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.raggio = 24,
    this.gradiente,
    this.ombra,
    this.onTap,
    this.margine = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pulse.di(context);
    final r = BorderRadius.circular(raggio);
    return Padding(
      padding: margine,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradiente ?? p.superficie,
          borderRadius: r,
          boxShadow: ombra ?? p.ombraSuperficie,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: r,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Il pulsante dell'azione principale: pillola sfumata con ombra colorata.
class PulsantePrincipale extends StatelessWidget {
  final String testo;
  final IconData? icona;
  final VoidCallback? onPressed;
  final double altezza;
  final Gradient? gradiente; // di default quello primario del tema
  final Color? colore; // testo e icona
  const PulsantePrincipale({
    super.key,
    required this.testo,
    this.icona,
    required this.onPressed,
    this.altezza = 60,
    this.gradiente,
    this.colore,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pulse.di(context);
    final attivo = onPressed != null;
    final c = colore ?? p.suPrimario;
    final r = BorderRadius.circular(altezza);
    return Semantics(
      button: true,
      enabled: attivo,
      child: Opacity(
        opacity: attivo ? 1 : 0.45,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradiente ?? p.primario,
            borderRadius: r,
            boxShadow: attivo && gradiente == null ? p.ombraPrimario : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: r,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                height: altezza,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icona != null) ...[
                      Icon(icona, color: c, size: 24),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        testo,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: famigliaTesto,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: c,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Anello di avanzamento sfumato con alone (tempo, settimana).
class AnelloPulse extends StatelessWidget {
  final double valore; // 0-1
  final double dimensione;
  final double spessore;
  final Widget? child;
  final bool alone;
  const AnelloPulse({
    super.key,
    required this.valore,
    this.dimensione = 220,
    this.spessore = 12,
    this.child,
    this.alone = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pulse.di(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: dimensione,
      height: dimensione,
      child: CustomPaint(
        painter: _Anello(
          valore: valore.clamp(0, 1).toDouble(),
          spessore: spessore,
          colori: p.anello,
          traccia: scheme.surfaceContainerHigh,
          bagliore: alone ? p.bagliore : null,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _Anello extends CustomPainter {
  final double valore;
  final double spessore;
  final List<Color> colori;
  final Color traccia;
  final Color? bagliore;
  _Anello({
    required this.valore,
    required this.spessore,
    required this.colori,
    required this.traccia,
    required this.bagliore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arco = rect.deflate(spessore / 2 + 2);
    canvas.drawArc(
      arco,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = spessore
        ..color = traccia,
    );
    if (valore <= 0) return;
    final sweep = 2 * math.pi * valore;
    if (bagliore != null) {
      canvas.drawArc(
        arco,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = spessore * 1.6
          ..strokeCap = StrokeCap.round
          ..color = bagliore!
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }
    canvas.drawArc(
      arco,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = spessore
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colori,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_Anello o) =>
      o.valore != valore || o.colori != colori || o.traccia != traccia;
}

/// Fondo delle schede principali: il colore del tema con i suoi bagliori.
class SfondoPulse extends StatelessWidget {
  final Widget child;
  const SfondoPulse({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = Pulse.di(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Stack(
        children: [
          for (final g in p.sfondo)
            Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(gradient: g)),
            ),
          // La chiave tiene lo stesso contenuto anche se cambia il numero di
          // bagliori (un tema ne ha uno, l'altro due): così cambiando tema non
          // si perde la scheda aperta né il punto in cui si era.
          Positioned.fill(key: const ValueKey('contenuto'), child: child),
        ],
      ),
    );
  }
}

/// Etichetta a pillola (muscoli, attrezzi, sport).
class PillolaPulse extends StatelessWidget {
  final String testo;
  final Color? sfondo;
  final Color? colore;
  const PillolaPulse(this.testo, {super.key, this.sfondo, this.colore});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sfondo ?? scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        testo,
        style: TextStyle(
          fontFamily: famigliaTesto,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: colore ?? scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// Una voce della barra di navigazione.
class VoceBarra {
  final IconData icona;
  final String etichetta;
  const VoceBarra(this.icona, this.etichetta);
}

/// Barra di navigazione fluttuante: la sezione attiva si allarga con il nome,
/// le altre restano icone.
class BarraPulse extends StatelessWidget {
  final List<VoceBarra> voci;
  final int attiva;
  final void Function(int) onTocca;
  final List<GlobalKey>? chiavi; // una per voce, per il giro guidato
  const BarraPulse({
    super.key,
    required this.voci,
    required this.attiva,
    required this.onTocca,
    this.chiavi,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pulse.di(context);
    final basso = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + basso),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: p.barra,
          borderRadius: BorderRadius.circular(999),
          boxShadow: p.ombraSuperficie,
        ),
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (var i = 0; i < voci.length; i++)
                  Expanded(
                    flex: i == attiva ? 2 : 1,
                    child: Semantics(
                      selected: i == attiva,
                      button: true,
                      label: voci[i].etichetta,
                      excludeSemantics: true,
                      child: AnimatedContainer(
                        key: chiavi?[i],
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: i == attiva ? p.primario : null,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          borderRadius: BorderRadius.circular(999),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => onTocca(i),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  voci[i].icona,
                                  size: 22,
                                  color: i == attiva ? p.suPrimario : p.suBarra,
                                ),
                                if (i == attiva) ...[
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      voci[i].etichetta,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontFamily: famigliaTesto,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: p.suPrimario,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Riga di un elenco senza riquadro: segno a sinistra (pallino o icona),
/// titolo, sottotitolo e freccia. Separata dalla successiva da una linea.
class RigaPulse extends StatelessWidget {
  final Widget? segno;
  final String titolo;
  final String? sottotitolo;
  final VoidCallback? onTap;
  final bool linea;
  final Widget? fine;
  const RigaPulse({
    super.key,
    this.segno,
    required this.titolo,
    this.sottotitolo,
    this.onTap,
    this.linea = true,
    this.fine,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: linea
              ? Border(bottom: BorderSide(color: scheme.outlineVariant))
              : null,
        ),
        child: Row(
          children: [
            if (segno != null) ...[segno!, const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titolo, style: t.titleSmall?.copyWith(fontSize: 15)),
                  if (sottotitolo != null && sottotitolo!.isNotEmpty)
                    Text(
                      sottotitolo!,
                      style: t.bodySmall?.copyWith(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (fine != null)
              fine!
            else if (onTap != null)
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Pallino colorato (lo sport di una riga).
class PallinoPulse extends StatelessWidget {
  final Color colore;
  final double d;
  const PallinoPulse(this.colore, {super.key, this.d = 10});

  @override
  Widget build(BuildContext context) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(color: colore, shape: BoxShape.circle),
  );
}

/// Icona in un quadratino arrotondato; [evidenza] la mette sul gradiente.
class IconaQuadrata extends StatelessWidget {
  final IconData icona;
  final bool evidenza;
  final Color? colore;
  const IconaQuadrata(
    this.icona, {
    super.key,
    this.evidenza = false,
    this.colore,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pulse.di(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: evidenza ? p.primario : null,
        color: evidenza
            ? null
            : (colore?.withValues(alpha: 0.16) ?? scheme.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icona,
        size: 20,
        color: evidenza ? p.suPrimario : (colore ?? scheme.onSurface),
      ),
    );
  }
}

/// Barra di avanzamento sfumata, con un leggero alone.
class BarraAvanzamento extends StatelessWidget {
  final double valore;
  final double altezza;
  const BarraAvanzamento(this.valore, {super.key, this.altezza = 8});

  @override
  Widget build(BuildContext context) {
    final p = Pulse.di(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: altezza,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(altezza),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: valore.clamp(0, 1).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: p.anello),
            borderRadius: BorderRadius.circular(altezza),
            boxShadow: [BoxShadow(color: p.bagliore, blurRadius: 10)],
          ),
        ),
      ),
    );
  }
}

/// Titolo di sezione con un testo a destra (es. "5 di 7 fatti").
class TitoloSezione extends StatelessWidget {
  final String testo;
  final Widget? destra;
  const TitoloSezione(this.testo, {super.key, this.destra});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(testo, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?destra,
      ],
    ),
  );
}
