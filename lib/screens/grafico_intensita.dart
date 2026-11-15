import 'package:flutter/material.dart';

import '../intensita.dart';
import '../esecuzione.dart';
import '../pulse.dart';

/// Previsto e fatto in tutta la seduta di corsa: dietro le fasce
/// dell'intensità da tenere blocco per blocco, sopra la linea di quella
/// tenuta davvero. In verticale le zone, da Z1 a Z5: così il grafico è uno
/// anche se l'obiettivo passa dal battito al passo.
class GraficoIntensitaSeduta extends StatelessWidget {
  final List<({double s, double livello})> punti;
  final List<FasciaIntensita> fasce;
  final Color colore;
  final double altezza;
  const GraficoIntensitaSeduta({
    super.key,
    required this.punti,
    required this.fasce,
    required this.colore,
    this.altezza = 150,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final fine = [
      if (punti.isNotEmpty) punti.last.s,
      for (final f in fasce) f.a.toDouble(),
    ].fold(0.0, (m, v) => v > m ? v : m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Semantics(
          label: 'Intensità prevista e tenuta in tutta la seduta',
          child: SizedBox(
            height: altezza,
            child: CustomPaint(
              painter: _Intensita(
                punti: punti,
                fasce: fasce,
                fine: fine,
                linea: scheme.onSurface,
                fascia: colore,
                griglia: scheme.outlineVariant,
                etichetta: (t.labelSmall ?? const TextStyle()).cifreFisse
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: _Intensita.margine),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0:00', style: t.labelSmall),
              Text(
                fmtTimer(Duration(seconds: fine.round())),
                style: t.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Intensita extends CustomPainter {
  /// Lo spazio a sinistra per i nomi delle zone.
  static const margine = 24.0;

  final List<({double s, double livello})> punti;
  final List<FasciaIntensita> fasce;
  final double fine;
  final Color linea;
  final Color fascia;
  final Color griglia;
  final TextStyle etichetta;
  _Intensita({
    required this.punti,
    required this.fasce,
    required this.fine,
    required this.linea,
    required this.fascia,
    required this.griglia,
    required this.etichetta,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fine <= 0 || size.width <= margine) return;
    final largo = size.width - margine;
    double x(num s) => margine + s / fine * largo;
    double y(num livello) => size.height * (1 - livello / 6);
    // Una riga per zona, con il nome a sinistra.
    final riga = Paint()..color = griglia;
    for (var n = 1; n <= 5; n++) {
      canvas.drawLine(Offset(margine, y(n)), Offset(size.width, y(n)), riga);
      final testo = TextPainter(
        text: TextSpan(text: 'Z$n', style: etichetta),
        textDirection: TextDirection.ltr,
      )..layout();
      testo.paint(canvas, Offset(0, y(n + 0.5) - testo.height / 2));
    }
    // Le fasce da tenere: alte quanto l'obiettivo (almeno 6 px).
    for (final f in fasce) {
      var alto = y(f.su), basso = y(f.giu);
      if (basso - alto < 6) {
        final m = (alto + basso) / 2;
        alto = m - 3;
        basso = m + 3;
      }
      final r = Rect.fromLTRB(x(f.da), alto, x(f.a) - 1, basso);
      canvas.drawRect(r, Paint()..color = fascia.withValues(alpha: 0.30));
      canvas.drawRect(
        Rect.fromLTWH(r.left, r.top, r.width, 2),
        Paint()..color = fascia,
      );
    }
    if (punti.length < 2) return;
    final tratto = Path()..moveTo(x(punti.first.s), y(punti.first.livello));
    for (final p in punti.skip(1)) {
      tratto.lineTo(x(p.s), y(p.livello));
    }
    canvas.drawPath(
      tratto,
      Paint()
        ..color = linea
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Intensita old) =>
      old.punti != punti ||
      old.fasce != fasce ||
      old.linea != linea ||
      old.fascia != fascia;
}
