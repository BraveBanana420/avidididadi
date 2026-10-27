import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import 'muscoli_dati.dart';

/// Parti del corpo che non sono muscoli: disegnate in grigio.
const _neutre = {'head', 'hair', 'hands', 'feet'};

/// Colori della figura: corpo in grigio, muscoli evidenziati nel colore del tema.
class _Colori {
  final Color muscoli, spento, neutro, evidenza;
  const _Colori(this.muscoli, this.spento, this.neutro, this.evidenza);

  // L'evidenza segue l'accento scelto: rosso standard o rosa neon.
  factory _Colori.di(BuildContext context) {
    final evidenza = Theme.of(context).colorScheme.primary;
    return Theme.of(context).brightness == Brightness.dark
        ? _Colori(
            const Color(0xFF8C8C8C),
            const Color(0xFF4A4A4A),
            const Color(0xFF5A5A5A),
            evidenza,
          )
        : _Colori(
            const Color(0xFF8C8C8C),
            const Color(0xFFC4C4C4),
            const Color(0xFFA6A6A6),
            evidenza,
          );
  }
}

DatiVista _vista(String sesso, bool retro) => sesso == 'Donna'
    ? (retro ? donnaRetro : donnaFronte)
    : (retro ? uomoRetro : uomoFronte);

/// Tracciati già convertiti da SVG, per non rileggerli a ogni disegno.
final _cache = <DatiVista, List<(String, String, Path)>>{};

List<(String, String, Path)> _tracciati(DatiVista v) => _cache.putIfAbsent(
  v,
  () => [for (final (m, l, d) in v.tracciati) (m, l, parseSvgPathData(d))],
);

/// Scala e spostamento per far stare l'area SVG al centro di [size].
(double, Offset) _adatta(Rect area, Size size) {
  final s = math.min(size.width / area.width, size.height / area.height);
  return (
    s,
    Offset(
      (size.width - area.width * s) / 2 - area.left * s,
      (size.height - area.height * s) / 2 - area.top * s,
    ),
  );
}

class _MuscoliPainter extends CustomPainter {
  final DatiVista vista;
  final Set<String> evidenziati;
  final List<(Offset, Offset)> collegamenti; // punto -> bordo dell'etichetta
  final Color lineaC;
  final _Colori colori;
  _MuscoliPainter({
    required this.vista,
    required this.colori,
    this.evidenziati = const {},
    this.collegamenti = const [],
    this.lineaC = Colors.transparent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final (s, o) = _adatta(vista.area, size);
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(s);
    for (final (muscolo, _, path) in _tracciati(vista)) {
      // Come in Freeletics: se ci sono muscoli evidenziati, gli altri si spengono.
      final colore = _neutre.contains(muscolo)
          ? colori.neutro
          : evidenziati.isEmpty
          ? colori.muscoli
          : evidenziati.contains(muscolo)
          ? colori.evidenza
          : colori.spento;
      canvas.drawPath(path, Paint()..color = colore);
    }
    canvas.restore();

    final linea = Paint()
      ..color = lineaC
      ..strokeWidth = 1;
    for (final (punto, etichetta) in collegamenti) {
      canvas.drawLine(punto, etichetta, linea);
      canvas.drawCircle(
        punto,
        6,
        Paint()..color = colori.evidenza.withValues(alpha: 0.35),
      );
      canvas.drawCircle(punto, 3.5, Paint()..color = colori.evidenza);
    }
  }

  @override
  bool shouldRepaint(covariant _MuscoliPainter old) => true;
}

/// Sagoma muscolare (fronte o retro); se [evidenziati] non è vuoto, solo quei
/// muscoli restano blu.
class MappaMuscoli extends StatelessWidget {
  final String sesso;
  final bool retro;
  final Set<String> evidenziati;
  const MappaMuscoli({
    super.key,
    required this.sesso,
    this.retro = false,
    this.evidenziati = const {},
  });

  @override
  Widget build(BuildContext context) {
    final v = _vista(sesso, retro);
    return AspectRatio(
      aspectRatio: v.area.width / v.area.height,
      child: CustomPaint(
        painter: _MuscoliPainter(
          vista: v,
          colori: _Colori.di(context),
          evidenziati: evidenziati,
        ),
      ),
    );
  }
}

/// Dove sta il punto di una misura, ricavato dal muscolo corrispondente.
class _Punto {
  final String nome;
  final bool sinistra; // etichetta a sinistra del corpo
  final String muscolo;
  final Offset frazione; // posizione dentro il riquadro del muscolo (0-1)
  const _Punto(this.nome, this.sinistra, this.muscolo, this.frazione);
}

const _punti = <String, _Punto>{
  'braccio_cm': _Punto('Braccio', false, 'biceps', Offset(0.5, 0.5)),
  'petto_cm': _Punto('Petto', true, 'chest', Offset(0.5, 0.45)),
  'vita_cm': _Punto('Vita', false, 'obliques', Offset(0.5, 0.45)),
  'fianchi_cm': _Punto('Fianchi', true, 'quadriceps', Offset(0.25, 0.05)),
  'coscia_cm': _Punto('Coscia', false, 'quadriceps', Offset(0.5, 0.4)),
};

/// Riquadro (in coordinate SVG) della parte di un muscolo che sta
/// a sinistra o a destra di chi guarda.
Rect _riquadro(DatiVista v, String muscolo, bool sinistra) {
  final perLato = <String, Rect>{};
  for (final (m, lato, path) in _tracciati(v)) {
    if (m != muscolo) continue;
    final b = path.getBounds();
    perLato[lato] = perLato[lato]?.expandToInclude(b) ?? b;
  }
  final parti = perLato.values.toList()
    ..sort((a, b) => a.center.dx.compareTo(b.center.dx));
  return sinistra ? parti.first : parti.last;
}

/// Sagoma del corpo con le misure: toccando un'etichetta si modifica quella misura.
class FiguraCorpo extends StatelessWidget {
  final String sesso;
  final Map<String, String> valori; // campo -> testo mostrato, es. "98 cm"
  final void Function(String campo) onTocca;
  const FiguraCorpo({
    super.key,
    required this.sesso,
    required this.valori,
    required this.onTocca,
  });

  static const _larghezzaEtichetta = 84.0;
  static const _altezzaEtichetta = 48.0;

  @override
  Widget build(BuildContext context) {
    final v = _vista(sesso, false);
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final proporzione = v.area.width / v.area.height;
        final h = math.min(
          420.0,
          (w - 2 * _larghezzaEtichetta - 8) / proporzione,
        );
        final size = Size(w, h);
        final (s, o) = _adatta(v.area, size);

        // Punti sul corpo, in coordinate dello schermo.
        final punti = {
          for (final e in _punti.entries)
            e.key: () {
              final r = _riquadro(v, e.value.muscolo, e.value.sinistra);
              final p = Offset(
                r.left + r.width * e.value.frazione.dx,
                r.top + r.height * e.value.frazione.dy,
              );
              return Offset(o.dx + p.dx * s, o.dy + p.dy * s);
            }(),
        };

        // Etichette all'altezza del loro punto, distanziate per non sovrapporsi.
        final yEtichetta = <String, double>{};
        for (final sinistra in [true, false]) {
          final campi =
              _punti.keys.where((k) => _punti[k]!.sinistra == sinistra).toList()
                ..sort((a, b) => punti[a]!.dy.compareTo(punti[b]!.dy));
          var minimo = _altezzaEtichetta / 2;
          for (final k in campi) {
            final y = math.max(punti[k]!.dy, minimo);
            yEtichetta[k] = y;
            minimo = y + _altezzaEtichetta + 6;
          }
        }

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MuscoliPainter(
                    vista: v,
                    colori: _Colori.di(context),
                    lineaC: Theme.of(context).colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                    collegamenti: [
                      for (final e in _punti.entries)
                        (
                          punti[e.key]!,
                          Offset(
                            e.value.sinistra
                                ? _larghezzaEtichetta
                                : w - _larghezzaEtichetta,
                            yEtichetta[e.key]!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              for (final e in _punti.entries)
                Positioned(
                  left: e.value.sinistra ? 0 : null,
                  right: e.value.sinistra ? null : 0,
                  top: yEtichetta[e.key]! - _altezzaEtichetta / 2,
                  width: _larghezzaEtichetta,
                  height: _altezzaEtichetta,
                  child: _Etichetta(
                    nome: e.value.nome,
                    valore: valori[e.key] ?? '—',
                    sinistra: e.value.sinistra,
                    onTap: () => onTocca(e.key),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Etichetta extends StatelessWidget {
  final String nome;
  final String valore;
  final bool sinistra;
  final VoidCallback onTap;
  const _Etichetta({
    required this.nome,
    required this.valore,
    required this.sinistra,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          // Con caratteri di sistema grandi il testo si rimpicciolisce invece di uscire.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: sinistra ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: sinistra
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                Text(valore, style: t.titleSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Figura fronte e retro in cima alla pagina, con una didascalia sotto.
class FiguraMuscoliFissa extends StatelessWidget {
  final String sesso;
  final Set<String> evidenziati;
  final String didascalia;
  const FiguraMuscoliFissa({
    super.key,
    required this.sesso,
    required this.evidenziati,
    required this.didascalia,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MappaMuscoli(sesso: sesso, evidenziati: evidenziati),
                  const SizedBox(width: 32),
                  MappaMuscoli(
                    sesso: sesso,
                    retro: true,
                    evidenziati: evidenziati,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              didascalia,
              style: t.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
