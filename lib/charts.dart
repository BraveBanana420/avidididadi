import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models.dart';
import 'widgets.dart';

void _testo(Canvas canvas, String s, Offset o, Color c, {bool destra = false}) {
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(color: c, fontSize: 10),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final x = destra ? o.dx - tp.width : o.dx;
  tp.paint(canvas, Offset(x, o.dy - tp.height / 2));
}

String _asseOre(double v) => '${v.toStringAsFixed(1)} h';

/// Ore come "2 h 05 min" (o "45 min" sotto l'ora).
String fmtOre(double ore) {
  final m = (ore * 60).round();
  if (m < 60) return '$m min';
  return '${m ~/ 60} h ${two(m % 60)} min';
}

/// Riquadro con il dettaglio del punto toccato: la prima riga è in evidenza.
class _Dettaglio extends StatelessWidget {
  final List<String> righe;
  final Color colore;
  final VoidCallback onChiudi;
  const _Dettaglio({
    required this.righe,
    required this.colore,
    required this.onChiudi,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: colore),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(righe.first, style: t.titleSmall),
                        for (final r in righe.skip(1))
                          Text(r, style: t.bodySmall),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: IconButton(
                    tooltip: 'Chiudi',
                    onPressed: onChiudi,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 18),
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

/// Raggruppa i grafici di una schermata: un solo dettaglio aperto alla volta,
/// e un tocco fuori dai grafici li chiude tutti.
class GruppoGrafici extends StatefulWidget {
  final Widget child;
  const GruppoGrafici({super.key, required this.child});

  static ValueNotifier<Object?>? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_GruppoScope>()?.attivo;

  @override
  State<GruppoGrafici> createState() => _GruppoGraficiState();
}

class _GruppoGraficiState extends State<GruppoGrafici> {
  /// Il grafico che ha un dettaglio aperto, o null.
  final attivo = ValueNotifier<Object?>(null);

  @override
  void dispose() {
    attivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _GruppoScope(
    attivo: attivo,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => attivo.value = null,
      child: widget.child,
    ),
  );
}

class _GruppoScope extends InheritedWidget {
  final ValueNotifier<Object?> attivo;
  const _GruppoScope({required this.attivo, required super.child});

  @override
  bool updateShouldNotify(_GruppoScope old) => attivo != old.attivo;
}

/// Grafico a linea. Toccando un punto compare il suo dettaglio sotto il grafico.
class GraficoLinea extends StatefulWidget {
  final List<double> ys;
  final List<String> etichette;
  final String Function(double) fmt;
  final Color colore;

  /// Testo per ogni punto (righe separate da \n, la prima in evidenza).
  /// Se manca, mostra valore ed etichetta.
  final List<String>? dettagli;
  const GraficoLinea({
    super.key,
    required this.ys,
    required this.etichette,
    required this.fmt,
    required this.colore,
    this.dettagli,
  });

  @override
  State<GraficoLinea> createState() => _GraficoLineaState();
}

class _GraficoLineaState extends State<GraficoLinea> {
  static const _sx = 46.0, _dx = 8.0;
  int? sel;
  ValueNotifier<Object?>? _attivo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final a = GruppoGrafici.of(context);
    if (a != _attivo) {
      _attivo?.removeListener(_sync);
      _attivo = a?..addListener(_sync);
    }
  }

  @override
  void dispose() {
    _attivo?.removeListener(_sync);
    super.dispose();
  }

  /// Se un altro grafico (o un tocco fuori) prende il posto, chiude il dettaglio.
  void _sync() {
    if (_attivo!.value != this && sel != null) setState(() => sel = null);
  }

  void _imposta(int? nuovo) {
    setState(() => sel = nuovo);
    final a = _attivo;
    if (a == null) return;
    if (nuovo != null) {
      a.value = this;
    } else if (a.value == this) {
      a.value = null;
    }
  }

  @override
  void didUpdateWidget(covariant GraficoLinea old) {
    super.didUpdateWidget(old);
    if (old.ys.length != widget.ys.length) sel = null;
  }

  void _tocca(Offset p, double larghezza) {
    final n = widget.ys.length;
    final w = larghezza - _sx - _dx;
    final i = n == 1 ? 0 : ((p.dx - _sx) / w * (n - 1)).round().clamp(0, n - 1);
    _imposta(sel == i ? null : i);
  }

  @override
  Widget build(BuildContext context) {
    final ys = widget.ys;
    if (ys.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('Nessun dato per questo grafico.')),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final i = sel;
    final righe = i == null
        ? null
        : (widget.dettagli?[i] ??
                  '${widget.fmt(ys[i])}\n${widget.etichette[i]}')
              .split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _tocca(d.localPosition, c.maxWidth),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineaPainter(
                  ys,
                  widget.etichette,
                  widget.fmt,
                  widget.colore,
                  scheme.onSurfaceVariant,
                  scheme.outlineVariant,
                  i,
                ),
              ),
            ),
          ),
        ),
        if (righe != null)
          _Dettaglio(
            righe: righe,
            colore: widget.colore,
            onChiudi: () => _imposta(null),
          ),
      ],
    );
  }
}

class _LineaPainter extends CustomPainter {
  final List<double> ys;
  final List<String> etichette;
  final String Function(double) fmt;
  final Color colore;
  final Color testoC;
  final Color grigliaC;
  final int? sel;
  _LineaPainter(
    this.ys,
    this.etichette,
    this.fmt,
    this.colore,
    this.testoC,
    this.grigliaC,
    this.sel,
  );

  @override
  void paint(Canvas canvas, Size size) {
    const sx = 46.0, top = 10.0, bottom = 24.0, dx = 8.0;
    final w = size.width - sx - dx;
    final h = size.height - top - bottom;
    final minReale = ys.reduce(math.min);
    var lo = minReale;
    var hi = ys.reduce(math.max);
    if (hi - lo < 1e-9) {
      lo -= 1;
      hi += 1;
    }
    final pad = (hi - lo) * 0.12;
    lo -= pad;
    hi += pad;
    if (lo < 0 && minReale >= 0) lo = 0;

    final griglia = Paint()
      ..color = grigliaC
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = top + h * i / 2;
      canvas.drawLine(Offset(sx, y), Offset(size.width - dx, y), griglia);
      _testo(
        canvas,
        fmt(hi - (hi - lo) * i / 2),
        Offset(sx - 6, y),
        testoC,
        destra: true,
      );
    }

    Offset pt(int i) => Offset(
      sx + (ys.length == 1 ? w / 2 : w * i / (ys.length - 1)),
      top + h * (1 - (ys[i] - lo) / (hi - lo)),
    );

    final linea = Paint()
      ..color = colore
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < ys.length; i++) {
      path.lineTo(pt(i).dx, pt(i).dy);
    }
    canvas.drawPath(path, linea);
    if (ys.length <= 40) {
      final punto = Paint()..color = colore;
      for (var i = 0; i < ys.length; i++) {
        canvas.drawCircle(pt(i), 3, punto);
      }
    }
    final s = sel;
    if (s != null && s < ys.length) {
      final p = pt(s);
      canvas.drawLine(
        Offset(p.dx, top),
        Offset(p.dx, top + h),
        Paint()
          ..color = colore.withValues(alpha: 0.4)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(p, 8, Paint()..color = colore.withValues(alpha: 0.25));
      canvas.drawCircle(p, 4.5, Paint()..color = colore);
    }
    if (etichette.isNotEmpty) {
      _testo(canvas, etichette.first, Offset(sx, size.height - 8), testoC);
      _testo(
        canvas,
        etichette.last,
        Offset(size.width - dx, size.height - 8),
        testoC,
        destra: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineaPainter old) => true;
}

const _bSx = 40.0, _bTop = 10.0, _bBottom = 24.0, _bDx = 8.0;
const _bAltezza = 190.0;

double _massimoBarre(List<Map<String, double>> valori) {
  var m = 0.0;
  for (final v in valori) {
    final tot = v.values.fold<double>(0, (a, b) => a + b);
    if (tot > m) m = tot;
  }
  return (m <= 0 ? 1 : m) * 1.1;
}

/// Barre impilate: una barra per settimana, un colore per sport.
/// Toccando un blocco compaiono le ore di quello sport in quella settimana.
class GraficoBarre extends StatefulWidget {
  final List<Map<String, double>> valori;
  final List<String> sport;
  final List<String> etichette;

  /// Sessioni per settimana e sport, se note.
  final List<Map<String, int>>? conteggi;

  /// Come scrivere i valori nel dettaglio e sull'asse (ore di default).
  final String Function(double) formato;
  final String Function(double)? formatoAsse;

  /// Titolo di una colonna nel dettaglio (di default "Settimana dal …").
  final String Function(int)? titoloColonna;
  const GraficoBarre({
    super.key,
    required this.valori,
    required this.sport,
    required this.etichette,
    this.conteggi,
    this.formato = fmtOre,
    this.formatoAsse,
    this.titoloColonna,
  });

  @override
  State<GraficoBarre> createState() => _GraficoBarreState();
}

class _GraficoBarreState extends State<GraficoBarre> {
  int? settSel;
  String? sportSel;
  ValueNotifier<Object?>? _attivo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final a = GruppoGrafici.of(context);
    if (a != _attivo) {
      _attivo?.removeListener(_sync);
      _attivo = a?..addListener(_sync);
    }
  }

  @override
  void dispose() {
    _attivo?.removeListener(_sync);
    super.dispose();
  }

  /// Se un altro grafico (o un tocco fuori) prende il posto, chiude il dettaglio.
  void _sync() {
    if (_attivo!.value != this && settSel != null) {
      setState(() {
        settSel = null;
        sportSel = null;
      });
    }
  }

  void _imposta(int? sett, String? sport) {
    setState(() {
      settSel = sett;
      sportSel = sport;
    });
    final a = _attivo;
    if (a == null) return;
    if (sett != null) {
      a.value = this;
    } else if (a.value == this) {
      a.value = null;
    }
  }

  @override
  void didUpdateWidget(covariant GraficoBarre old) {
    super.didUpdateWidget(old);
    if (old.valori.length != widget.valori.length) {
      settSel = null;
      sportSel = null;
    }
  }

  void _tocca(Offset p, double larghezza) {
    final n = widget.valori.length;
    final slot = (larghezza - _bSx - _bDx) / n;
    final i = ((p.dx - _bSx) / slot).floor();
    if (p.dx < _bSx || i < 0 || i >= n) {
      _imposta(null, null);
      return;
    }
    // Quale blocco colorato è stato toccato (dal basso verso l'alto).
    final h = _bAltezza - _bTop - _bBottom;
    final massimo = _massimoBarre(widget.valori);
    var y = _bTop + h;
    String? trovato;
    for (final s in widget.sport) {
      final v = widget.valori[i][s] ?? 0;
      if (v <= 0) continue;
      final sh = h * v / massimo;
      if (p.dy <= y && p.dy >= y - sh) {
        trovato = s;
        break;
      }
      y -= sh;
    }
    if (settSel == i && sportSel == trovato) {
      _imposta(null, null);
    } else {
      _imposta(i, trovato);
    }
  }

  List<String> _righe(int i, String? s) {
    final v = widget.valori[i];
    final tot = v.values.fold<double>(0, (a, b) => a + b);
    final titSett =
        widget.titoloColonna?.call(i) ?? 'Settimana dal ${widget.etichette[i]}';
    String sessioni(int n) => '$n ${n == 1 ? 'sessione' : 'sessioni'}';
    if (s != null) {
      final nSess = widget.conteggi?[i][s];
      final totSport = widget.valori.fold<double>(0, (a, m) => a + (m[s] ?? 0));
      return [
        '$s: ${widget.formato(v[s] ?? 0)}',
        nSess == null ? titSett : '$titSett · ${sessioni(nSess)}',
        'Totale: ${widget.formato(tot)}',
        '$s in tutto il periodo: ${widget.formato(totSport)}',
      ];
    }
    if (tot <= 0) return [titSett, 'Nessun allenamento'];
    return [
      '$titSett: ${widget.formato(tot)}',
      for (final sp in widget.sport)
        if ((v[sp] ?? 0) > 0) '$sp: ${widget.formato(v[sp]!)}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final i = settSel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _tocca(d.localPosition, c.maxWidth),
            child: SizedBox(
              height: _bAltezza,
              width: double.infinity,
              child: CustomPaint(
                painter: _BarrePainter(
                  widget.valori,
                  widget.sport,
                  widget.etichette,
                  scheme.onSurfaceVariant,
                  scheme.outlineVariant,
                  scheme.onSurface,
                  settSel,
                  sportSel,
                  widget.formatoAsse ?? _asseOre,
                ),
              ),
            ),
          ),
        ),
        if (i != null)
          _Dettaglio(
            righe: _righe(i, sportSel),
            colore: sportSel == null ? scheme.primary : coloreSport(sportSel!),
            onChiudi: () => _imposta(null, null),
          ),
      ],
    );
  }
}

class _BarrePainter extends CustomPainter {
  final List<Map<String, double>> valori;
  final List<String> sport;
  final List<String> etichette;
  final Color testoC;
  final Color grigliaC;
  final Color bordoC;
  final int? settSel;
  final String? sportSel;
  final String Function(double) formatoAsse;
  _BarrePainter(
    this.valori,
    this.sport,
    this.etichette,
    this.testoC,
    this.grigliaC,
    this.bordoC,
    this.settSel,
    this.sportSel,
    this.formatoAsse,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - _bSx - _bDx;
    final h = size.height - _bTop - _bBottom;
    final massimo = _massimoBarre(valori);

    final griglia = Paint()
      ..color = grigliaC
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = _bTop + h * i / 2;
      canvas.drawLine(Offset(_bSx, y), Offset(size.width - _bDx, y), griglia);
      _testo(
        canvas,
        formatoAsse(massimo - massimo * i / 2),
        Offset(_bSx - 6, y),
        testoC,
        destra: true,
      );
    }

    final n = valori.length;
    final slot = w / n;
    final bw = slot * 0.72;
    for (var i = 0; i < n; i++) {
      final x = _bSx + slot * i + (slot - bw) / 2;
      // Con una settimana selezionata le altre si attenuano.
      final alpha = settSel != null && settSel != i ? 0.4 : 1.0;
      var y = _bTop + h;
      // Solo il blocco in cima alla colonna ha gli angoli superiori arrotondati.
      final cima = sport.lastWhere(
        (s) => (valori[i][s] ?? 0) > 0,
        orElse: () => '',
      );
      var primo = true;
      for (final s in sport) {
        final v = valori[i][s] ?? 0;
        if (v <= 0) continue;
        final sh = h * v / massimo;
        // Una fessura sopra ogni blocco tranne il primo: separa sport con grigi simili.
        final fessura = primo ? 0.0 : math.min(1.5, sh / 3);
        primo = false;
        final r = Rect.fromLTWH(x, y - sh, bw, sh - fessura);
        final raggio = s == cima
            ? Radius.circular(math.min(5.0, sh / 2))
            : Radius.zero;
        final rr = RRect.fromRectAndCorners(
          r,
          topLeft: raggio,
          topRight: raggio,
        );
        canvas.drawRRect(
          rr,
          Paint()..color = coloreSport(s).withValues(alpha: alpha),
        );
        if (settSel == i && sportSel == s) {
          canvas.drawRRect(
            rr.deflate(1),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = bordoC,
          );
        }
        y -= sh;
      }
    }
    if (etichette.isNotEmpty) {
      _testo(canvas, etichette.first, Offset(_bSx, size.height - 8), testoC);
      _testo(
        canvas,
        etichette.last,
        Offset(size.width - _bDx, size.height - 8),
        testoC,
        destra: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarrePainter old) => true;
}
