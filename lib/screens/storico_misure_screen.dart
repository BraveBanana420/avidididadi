import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../charts.dart';
import '../models.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';

/// Peso e misure del profilo: nome da mostrare e unità.
Map<String, (String, String)> get campiStorico => {
  'peso_kg': (l10n.peso, 'kg'),
  'braccio_cm': (l10n.braccio, 'cm'),
  'petto_cm': (l10n.petto, 'cm'),
  'vita_cm': (l10n.vita, 'cm'),
  'fianchi_cm': (l10n.fianchi, 'cm'),
  'coscia_cm': (l10n.coscia, 'cm'),
};

/// Valori registrati di un campo, in ordine di data.
List<(DateTime, double)> storicoDi(AppState state, String campo) => [
  for (final m in state.misure)
    if ((m.valori[campo] ?? 0) > 0) (m.data, m.valori[campo]!),
];

/// Piccolo pulsante rotondo con l'andamento del peso disegnato dentro:
/// apre lo storico di peso e misure.
class PulsanteStorico extends StatelessWidget {
  final AppState state;
  const PulsanteStorico({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pesi = [for (final (_, v) in storicoDi(state, 'peso_kg')) v];
    return Tooltip(
      message: l10n.storicoPesoMisure,
      child: Material(
        color: scheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StoricoMisureScreen(state: state),
            ),
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: pesi.length < 2
                ? Icon(
                    Icons.show_chart_rounded,
                    size: 22,
                    color: scheme.primary,
                  )
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomPaint(
                      painter: _MiniGrafico(pesi, scheme.primary),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Linea dell'andamento, senza assi: solo la forma degli ultimi valori.
class _MiniGrafico extends CustomPainter {
  final List<double> valori;
  final Color colore;
  _MiniGrafico(List<double> tutti, this.colore)
    : valori = tutti.length > 12 ? tutti.sublist(tutti.length - 12) : tutti;

  @override
  void paint(Canvas canvas, Size size) {
    final lo = valori.reduce(math.min), hi = valori.reduce(math.max);
    final campo = hi - lo < 1e-9 ? 1.0 : hi - lo;
    Offset pt(int i) => Offset(
      size.width * i / (valori.length - 1),
      size.height * (1 - (valori[i] - lo) / campo),
    );
    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < valori.length; i++) {
      path.lineTo(pt(i).dx, pt(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = colore
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(pt(valori.length - 1), 2.5, Paint()..color = colore);
  }

  @override
  bool shouldRepaint(covariant _MiniGrafico old) => true;
}

/// Storico di peso e misure: grafico e valori registrati, campo per campo.
class StoricoMisureScreen extends StatefulWidget {
  final AppState state;
  const StoricoMisureScreen({super.key, required this.state});

  @override
  State<StoricoMisureScreen> createState() => _StoricoMisureScreenState();
}

class _StoricoMisureScreenState extends State<StoricoMisureScreen> {
  String campo = 'peso_kg';

  String _data(DateTime d) => '${two(d.day)}/${two(d.month)}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final (nome, unita) = campiStorico[campo]!;
    final valori = storicoDi(widget.state, campo);
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(l10n.storicoMisure)),
      body: GruppoGrafici(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in campiStorico.entries)
                  ChoiceChip(
                    label: Text(e.value.$1),
                    selected: campo == e.key,
                    onSelected: (_) => setState(() => campo = e.key),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('$nome ($unita)', style: t.titleLarge),
            const SizedBox(height: 8),
            if (valori.isEmpty)
              Text(l10n.nessunValoreAncoraInserito(nome.toLowerCase()))
            else ...[
              if (valori.length >= 2)
                GraficoLinea(
                  ys: [for (final (_, v) in valori) v],
                  etichette: [
                    for (final (d, _) in valori) '${d.day}/${d.month}',
                  ],
                  fmt: (v) => v.toStringAsFixed(1),
                  colore: Theme.of(context).colorScheme.primary,
                  dettagli: [
                    for (final (d, v) in valori)
                      '${fmtNum(v)} $unita\n${dataLunga(d)} ${d.year}',
                  ],
                )
              else
                Text(l10n.almenoDueValoriComparira),
              if (valori.length >= 2) ...[
                const SizedBox(height: 8),
                Text(() {
                  final diff = double.parse(
                    (valori.last.$2 - valori.first.$2).toStringAsFixed(1),
                  );
                  final dal = l10n.dal(_data(valori.first.$1));
                  if (diff == 0) return l10n.invariato(dal);
                  return '$dal: ${diff > 0 ? '+' : ''}${fmtNum(diff)} $unita';
                }(), style: t.bodySmall),
              ],
              const SizedBox(height: 16),
              Text(l10n.valoriInseriti, style: t.titleMedium),
              Card(
                child: Column(
                  children: [
                    for (final (d, v) in valori.reversed)
                      ListTile(
                        dense: true,
                        title: Text('${fmtNum(v)} $unita'),
                        trailing: Text(_data(d)),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
