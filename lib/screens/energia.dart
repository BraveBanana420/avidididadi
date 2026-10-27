import 'package:flutter/material.dart';

import '../recupero.dart';

/// Colore dell'energia di oggi: verde, giallo o rosso al neon (entrambi i temi).
Color coloreEnergia(StatoRecupero s) => switch (s) {
  StatoRecupero.buono => const Color(0xFF22E07A),
  StatoRecupero.normale => const Color(0xFFFFC233),
  StatoRecupero.basso => const Color(0xFFFF3B47),
};

/// Il dettaglio dell'energia di oggi: fulmine, consiglio e una barra per ogni
/// dato (sonno, HRV, FC a riposo) rispetto al tuo solito.
Future<void> mostraEnergia(BuildContext context, Prontezza p, {String? nota}) =>
    showDialog<void>(
      context: context,
      builder: (c) => _DettaglioEnergia(p: p, nota: nota),
    );

class _DettaglioEnergia extends StatelessWidget {
  final Prontezza p;
  final String? nota;
  const _DettaglioEnergia({required this.p, this.nota});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final colore = coloreEnergia(p.stato);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colore.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: colore.withValues(alpha: 0.35),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: CustomPaint(painter: FulmineNeon(colore)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(nomiRecupero[p.stato]!, style: t.headlineSmall),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(consigliRecupero[p.stato]!, style: t.bodyLarge),
            if (p.indicatori.isNotEmpty) ...[
              const SizedBox(height: 18),
              for (final i in p.indicatori) _RigaIndicatore(i),
            ] else if (p.motivi.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final m in p.motivi) Text('• $m'),
            ],
            if (nota != null) ...[
              const SizedBox(height: 8),
              Text(nota!, style: t.bodySmall),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ok'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un dato con la sua barra: a sinistra peggio, a destra meglio, il segno al
/// centro è il tuo solito.
class _RigaIndicatore extends StatelessWidget {
  final Indicatore i;
  const _RigaIndicatore(this.i);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final colore = switch (i.verso) {
      1 => const Color(0xFF22E07A),
      -1 => const Color(0xFFFF3B47),
      _ => const Color(0xFFFFC233),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(i.nome, style: t.titleSmall)),
              Text(
                i.valore,
                style: t.titleMedium?.copyWith(
                  color: colore,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 16,
            child: LayoutBuilder(
              builder: (context, v) {
                final x = (v.maxWidth - 16) * i.posizione;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // Fondo sfumato: rosso, giallo, verde.
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF3B47).withValues(alpha: 0.55),
                            const Color(0xFFFFC233).withValues(alpha: 0.55),
                            const Color(0xFF22E07A).withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    // Il tuo solito.
                    Positioned(
                      left: v.maxWidth / 2 - 1,
                      child: Container(
                        width: 2,
                        height: 14,
                        color: scheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                    // Oggi.
                    Positioned(
                      left: x,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colore,
                          border: Border.all(color: scheme.surface, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: colore.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(i.riferimento, style: t.bodySmall),
        ],
      ),
    );
  }
}

/// Il fulmine al neon, disegnato in una griglia 24×24.
class FulmineNeon extends CustomPainter {
  final Color colore;
  const FulmineNeon(this.colore);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final fulmine = Path()
      ..moveTo(13 * k, 2 * k)
      ..lineTo(4 * k, 14 * k)
      ..lineTo(11 * k, 14 * k)
      ..lineTo(10 * k, 22 * k)
      ..lineTo(19 * k, 10 * k)
      ..lineTo(12 * k, 10 * k)
      ..close();
    // Alone: lo stesso tratto, più largo e sfocato.
    canvas.drawPath(
      fulmine,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5 * k
        ..strokeJoin = StrokeJoin.round
        ..color = colore.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.5 * k),
    );
    canvas.drawPath(
      fulmine,
      Paint()
        ..style = PaintingStyle.fill
        ..color = colore.withValues(alpha: 0.18),
    );
    canvas.drawPath(
      fulmine,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2 * k
        ..color = colore,
    );
  }

  @override
  bool shouldRepaint(FulmineNeon o) => o.colore != colore;
}
