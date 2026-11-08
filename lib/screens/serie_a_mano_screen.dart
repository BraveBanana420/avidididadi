import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../scheda.dart';
import '../widgets.dart';
import 'schede_screen.dart';

/// Forza fatta senza la modalità allenamento guidata (o dall'orologio): si
/// scrivono gli esercizi, con ripetizioni e kg di ogni serie. Contano nello
/// storico dell'esercizio e nei record, come quelli segnati in allenamento.
class SerieAManoScreen extends StatefulWidget {
  final AppState state;
  final DateTime giorno;
  const SerieAManoScreen({
    super.key,
    required this.state,
    required this.giorno,
  });

  @override
  State<SerieAManoScreen> createState() => _SerieAManoScreenState();
}

/// Una serie in modifica: due campi, ripetizioni e kg.
class _Serie {
  final rip = TextEditingController();
  final kg = TextEditingController();
  _Serie([int r = 0, double k = 0]) {
    if (r > 0) rip.text = '$r';
    if (k > 0) kg.text = fmtKg(k);
  }
  void dispose() {
    rip.dispose();
    kg.dispose();
  }
}

class _Esercizio {
  final String esercizio; // id del catalogo, vuoto se scritto a mano
  final String nome;
  final List<_Serie> serie;
  _Esercizio(this.esercizio, this.nome, this.serie);
}

class _SerieAManoScreenState extends State<SerieAManoScreen> {
  late final List<_Esercizio> _esercizi = [
    for (final e in eserciziDaSerie(
      widget.state.serieFatte
          .where((s) => s.data == soloData(widget.giorno))
          .toList(),
    ))
      _Esercizio(e.esercizio, e.nome, [
        for (final (r, k) in e.serie) _Serie(r, k),
      ]),
  ];

  @override
  void dispose() {
    for (final e in _esercizi) {
      for (final s in e.serie) {
        s.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _aggiungi() async {
    final scelto = await Navigator.of(context).push<EsercizioScheda>(
      MaterialPageRoute(
        builder: (_) => SceltaEsercizioScreen(state: widget.state),
      ),
    );
    if (scelto == null || !mounted) return;
    // Si parte dai numeri dell'ultima volta, se l'esercizio è già stato fatto.
    final chiave = scelto.esercizio.isEmpty ? scelto.nome : scelto.esercizio;
    final prima = ultimaVolta(
      widget.state.serieFatte,
      chiave,
      prima: soloData(widget.giorno),
    );
    setState(
      () => _esercizi.add(
        _Esercizio(scelto.esercizio, scelto.nome, [
          if (prima.isEmpty)
            _Serie()
          else
            for (final s in prima) _Serie(s.ripetizioni, s.kg),
        ]),
      ),
    );
  }

  Future<void> _salva() async {
    final navigator = Navigator.of(context);
    double kg(String t) => double.tryParse(t.trim().replaceAll(',', '.')) ?? 0;
    await widget.state.scriviSerieDel(
      widget.giorno,
      serieDaEsercizi(widget.giorno, [
        for (final e in _esercizi)
          (
            esercizio: e.esercizio,
            nome: e.nome,
            serie: [
              for (final s in e.serie)
                (int.tryParse(s.rip.text.trim()) ?? 0, kg(s.kg.text)),
            ],
          ),
      ]),
    );
    navigator.pop();
  }

  Widget _numero(
    TextEditingController c,
    String etichetta, {
    bool dec = false,
  }) => Expanded(
    child: TextField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: dec),
      decoration: InputDecoration(labelText: etichetta, isDense: true),
    ),
  );

  Widget _esercizio(BuildContext context, int i) {
    final e = _esercizi[i];
    final t = Theme.of(context).textTheme;
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(child: Text(e.nome, style: t.titleMedium)),
              IconButton(
                tooltip: 'Togli l\'esercizio',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() {
                  for (final s in _esercizi.removeAt(i).serie) {
                    s.dispose();
                  }
                }),
              ),
            ],
          ),
          for (var j = 0; j < e.serie.length; j++)
            Row(
              spacing: 12,
              children: [
                SizedBox(
                  width: 28,
                  child: Text('${j + 1}ª', style: t.titleSmall),
                ),
                _numero(e.serie[j].rip, 'Ripetizioni'),
                _numero(e.serie[j].kg, 'kg', dec: true),
                IconButton(
                  tooltip: 'Togli la serie',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () =>
                      setState(() => e.serie.removeAt(j).dispose()),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Serie'),
              // La nuova serie copia l'ultima: di solito si ripete uguale.
              onPressed: () => setState(() {
                final u = e.serie.lastOrNull;
                e.serie.add(
                  u == null
                      ? _Serie()
                      : (_Serie()
                          ..rip.text = u.rip.text
                          ..kg.text = u.kg.text),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('Esercizi e serie')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text('Forza · ${dataLunga(widget.giorno)}', style: t.titleMedium),
              Text(
                'Scrivi cosa hai fatto: ripetizioni e kg di ogni serie '
                '(kg vuoto = corpo libero). Restano nello storico '
                "dell'esercizio.",
                style: t.bodySmall,
              ),
              for (var i = 0; i < _esercizi.length; i++) _esercizio(context, i),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi esercizio'),
                onPressed: _aggiungi,
              ),
              PulsantePrincipale(
                onPressed: _salva,
                icona: Icons.check,
                testo: 'Salva',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
