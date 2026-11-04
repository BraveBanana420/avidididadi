import 'package:flutter/material.dart';

import '../esecuzione.dart';
import '../potenza.dart';

/// Una barra del diagramma: quanto dura e che watt chiede.
class BarraAllenamento {
  final int secondi;
  final (int, int)? range; // null: passo senza obiettivo di potenza
  const BarraAllenamento(this.secondi, this.range);
}

/// Le barre dai blocchi: i passi senza tempo (a "Fatto") contano un minuto.
List<BarraAllenamento> barreDa(List<Blocco> blocchi, ZonePotenza p) => [
  for (final b in blocchi)
    BarraAllenamento(
      b.secondi ?? 60,
      rangeWatt(b.intensita, p, recupero: b.tipo == TipoBlocco.recupero),
    ),
];

/// Il diagramma dell'allenamento, come quello di Garmin: una barra per
/// blocco, larga quanto dura, alta quanti watt chiede e colorata con la sua
/// zona. Quelle passate sono sbiadite; la riga bianca è il punto di adesso.
class ProfiloAllenamento extends StatelessWidget {
  final List<BarraAllenamento> barre;
  final ZonePotenza zone;
  final int corrente; // blocco in corso; -1 = non ancora partiti
  final double avanzamento; // 0-1 del blocco in corso
  final double altezza;
  const ProfiloAllenamento({
    super.key,
    required this.barre,
    required this.zone,
    this.corrente = -1,
    this.avanzamento = 0,
    this.altezza = 64,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Diagramma dell\'allenamento',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: altezza,
          width: double.infinity,
          child: CustomPaint(
            painter: _Disegno(
              barre: barre,
              zone: zone,
              corrente: corrente,
              avanzamento: avanzamento.clamp(0, 1).toDouble(),
              vuota: scheme.surfaceContainerHighest,
              segno: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _Disegno extends CustomPainter {
  final List<BarraAllenamento> barre;
  final ZonePotenza zone;
  final int corrente;
  final double avanzamento;
  final Color vuota;
  final Color segno;
  _Disegno({
    required this.barre,
    required this.zone,
    required this.corrente,
    required this.avanzamento,
    required this.vuota,
    required this.segno,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totale = barre.fold(0, (t, b) => t + b.secondi);
    if (totale == 0) return;
    // L'altezza piena è il passo più duro (almeno l'FTP).
    final tetto = barre.fold<double>(
      zone.ftp.toDouble(),
      (m, b) => b.range == null ? m : (b.range!.$2 > m ? b.range!.$2 * 1.0 : m),
    );
    var x = 0.0;
    double? xAdesso;
    for (final (k, b) in barre.indexed) {
      final w = b.secondi / totale * size.width;
      final r = b.range;
      final centro = r == null ? zone.ftp * 0.4 : (r.$1 + r.$2) / 2;
      final h = (centro / tetto).clamp(0.12, 1.0) * size.height;
      final colore = r == null
          ? vuota
          : coloriZonePotenza[zone.zonaDi(centro.round()) - 1];
      final passata = corrente >= 0 && k < corrente;
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - h, (w - 1).clamp(1, w), h),
        Paint()..color = passata ? colore.withValues(alpha: 0.35) : colore,
      );
      if (k == corrente) xAdesso = x + w * avanzamento;
      x += w;
    }
    if (xAdesso != null) {
      canvas.drawRect(
        Rect.fromLTWH(xAdesso - 1.5, 0, 3, size.height),
        Paint()..color = segno,
      );
    }
  }

  @override
  bool shouldRepaint(_Disegno old) =>
      old.corrente != corrente ||
      old.avanzamento != avanzamento ||
      old.barre != barre ||
      old.zone.ftp != zone.ftp ||
      old.vuota != vuota;
}
