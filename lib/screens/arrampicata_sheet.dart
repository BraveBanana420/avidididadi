import 'package:flutter/material.dart';

import '../app_state.dart';
import '../arrampicata.dart';
import '../models.dart';
import '../widgets.dart';

/// Apre la scheda dell'arrampicata di una seduta: si compila dopo aver
/// arrampicato e si può correggere quando si vuole.
Future<void> apriArrampicata(
  BuildContext context,
  AppState state, {
  required String idSessione,
  required DateTime data,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => ArrampicataSheet(
    state: state,
    idSessione: idSessione,
    data: data,
    prima: arrampicataDi(state.arrampicate, idSessione, data),
  ),
);

class ArrampicataSheet extends StatefulWidget {
  final AppState state;
  final String idSessione;
  final DateTime data;
  final SedutaArrampicata? prima;
  const ArrampicataSheet({
    super.key,
    required this.state,
    required this.idSessione,
    required this.data,
    this.prima,
  });

  @override
  State<ArrampicataSheet> createState() => _ArrampicataSheetState();
}

class _ArrampicataSheetState extends State<ArrampicataSheet> {
  // Le scelte dell'ultima volta come proposta: di solito si torna nello
  // stesso posto a fare la stessa cosa.
  late final _ultima = widget.state.arrampicate.lastOrNull;
  late Ambiente? ambiente =
      widget.prima?.ambiente ?? _ultima?.ambiente ?? Ambiente.indoor;
  // Il grado si sceglie dopo aver detto se è falesia o boulder.
  late Disciplina? disciplina = widget.prima?.disciplina;
  late final luogo = TextEditingController(
    text: widget.prima?.luogo ?? _ultima?.luogo ?? '',
  );
  late String gradoMax = widget.prima?.gradoMax ?? '';
  late String stile = widget.prima?.stile ?? '';
  late int chiuse = widget.prima?.chiuse ?? 0;
  late int provate = widget.prima?.provate ?? 0;
  late String corda = widget.prima?.corda ?? '';
  late int altezza = widget.prima?.altezzaM ?? 0;
  late String progetto = widget.prima?.progetto ?? '';

  @override
  void dispose() {
    luogo.dispose();
    super.dispose();
  }

  void _cambiaDisciplina(Disciplina d) => setState(() {
    if (d == disciplina) return;
    disciplina = d;
    // I gradi delle due scale non si confrontano: si riparte da capo.
    gradoMax = '';
    progetto = '';
  });

  Future<void> _salva() async {
    final d = disciplina;
    if (d == null) return;
    final navigator = Navigator.of(context);
    await widget.state.salvaArrampicata(
      SedutaArrampicata(
        idSessione: widget.prima?.idSessione ?? widget.idSessione,
        data: soloData(widget.data),
        ambiente: ambiente ?? Ambiente.indoor,
        disciplina: d,
        luogo: luogo.text.trim(),
        gradoMax: gradoMax,
        stile: stile,
        chiuse: chiuse,
        provate: provate,
        corda: corda,
        altezzaM: d == Disciplina.falesia
            ? (altezza > 0 ? altezza : altezzaTipica(ambiente!))
            : 0,
        progetto: progetto,
      ),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final d = disciplina;
    final falesia = d == Disciplina.falesia;
    final h = altezza > 0 ? altezza : altezzaTipica(ambiente!);
    final record = d == null
        ? null
        : recordArrampicata(
            widget.state.arrampicate
                .where((a) => a.idSessione != widget.prima?.idSessione)
                .toList(),
            d,
          );
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + spazioInBasso(context)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Text('La tua arrampicata', style: t.titleLarge),
            _Titolo('Dove'),
            SegmentedButton<Ambiente>(
              segments: const [
                ButtonSegment(
                  value: Ambiente.indoor,
                  label: Text('Indoor'),
                  icon: Icon(Icons.roofing),
                ),
                ButtonSegment(
                  value: Ambiente.outdoor,
                  label: Text('Outdoor'),
                  icon: Icon(Icons.landscape_outlined),
                ),
              ],
              selected: {ambiente!},
              onSelectionChanged: (v) => setState(() => ambiente = v.first),
            ),
            TextField(
              controller: luogo,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: ambiente == Ambiente.indoor
                    ? 'Palestra'
                    : 'Falesia o zona',
                hintText: 'Facoltativo',
              ),
            ),
            _Titolo('Cosa hai fatto'),
            SegmentedButton<Disciplina>(
              emptySelectionAllowed: true,
              segments: const [
                ButtonSegment(value: Disciplina.falesia, label: Text('Vie')),
                ButtonSegment(
                  value: Disciplina.boulder,
                  label: Text('Boulder'),
                ),
              ],
              selected: {?d},
              onSelectionChanged: (v) {
                if (v.isNotEmpty) _cambiaDisciplina(v.first);
              },
            ),
            if (d == null)
              Text(
                'Scegli vie o boulder: i gradi hanno due scale diverse.',
                style: t.bodySmall,
              )
            else ...[
              _SceltaGrado(
                etichetta: 'Grado più difficile chiuso',
                gradi: gradiDi(d),
                valore: gradoMax,
                onChanged: (g) => setState(() => gradoMax = g),
              ),
              if (record != null)
                Text(
                  gradoMax.isNotEmpty &&
                          livello(d, gradoMax) > livello(d, record.$1)
                      ? 'Nuovo record! Prima era ${record.$1}.'
                      : 'Il tuo record: ${record.$1} (${record.$2.day} '
                            '${mesiNomi[record.$2.month - 1]} ${record.$2.year}).',
                  style: t.bodySmall,
                ),
              if (gradoMax.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    for (final s in stili)
                      ChoiceChip(
                        label: Text(s),
                        selected: stile == s,
                        onSelected: (v) => setState(() => stile = v ? s : ''),
                      ),
                  ],
                ),
              if (gradoMax.isNotEmpty)
                Text(switch (stile) {
                  'A vista' => 'Al primo tentativo, senza sapere niente prima.',
                  'Flash' => 'Al primo tentativo, sapendo già i movimenti.',
                  'Lavorata' => 'Chiusa dopo averla provata più volte.',
                  _ => 'Come l\'hai chiusa? (facoltativo)',
                }, style: t.bodySmall),
              _Contatore(
                etichetta: falesia ? 'Vie chiuse' : 'Blocchi chiusi',
                valore: chiuse,
                onChanged: (v) => setState(() => chiuse = v),
              ),
              _Contatore(
                etichetta:
                    'Provat${falesia ? 'e' : 'i'} senza chiuderl${falesia ? 'e' : 'i'}',
                valore: provate,
                onChanged: (v) => setState(() => provate = v),
              ),
              if (falesia) ...[
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in corde)
                      ChoiceChip(
                        label: Text(c),
                        selected: corda == c,
                        onSelected: (v) => setState(() => corda = v ? c : ''),
                      ),
                  ],
                ),
                _Contatore(
                  etichetta: 'Altezza media delle vie (m)',
                  valore: h,
                  minimo: 5,
                  onChanged: (v) => setState(() => altezza = v),
                ),
                if (chiuse > 0)
                  Text('Circa ${chiuse * h} metri saliti.', style: t.bodySmall),
              ],
              _SceltaGrado(
                etichetta: 'Progetto (il grado che stai provando)',
                gradi: gradiDi(d),
                valore: progetto,
                onChanged: (g) => setState(() => progetto = g),
              ),
            ],
            const SizedBox(height: 4),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: d == null ? null : _salva,
              icon: const Icon(Icons.check),
              label: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Titolo extends StatelessWidget {
  final String testo;
  const _Titolo(this.testo);

  @override
  Widget build(BuildContext context) =>
      Text(testo, style: Theme.of(context).textTheme.titleSmall);
}

/// Menu dei gradi, con "Nessuno" per lasciarlo vuoto.
class _SceltaGrado extends StatelessWidget {
  final String etichetta;
  final List<String> gradi;
  final String valore;
  final ValueChanged<String> onChanged;
  const _SceltaGrado({
    required this.etichetta,
    required this.gradi,
    required this.valore,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    key: ValueKey('$etichetta-${gradi.first}-${gradi.length}'),
    initialValue: gradi.contains(valore) ? valore : '',
    decoration: InputDecoration(labelText: etichetta),
    menuMaxHeight: 360,
    items: [
      const DropdownMenuItem(value: '', child: Text('Nessuno')),
      for (final g in gradi) DropdownMenuItem(value: g, child: Text(g)),
    ],
    onChanged: (g) => onChanged(g ?? ''),
  );
}

/// Un numero con − e +.
class _Contatore extends StatelessWidget {
  final String etichetta;
  final int valore;
  final int minimo;
  final ValueChanged<int> onChanged;
  const _Contatore({
    required this.etichetta,
    required this.valore,
    required this.onChanged,
    this.minimo = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(etichetta, style: t.bodyLarge)),
        IconButton.filledTonal(
          tooltip: 'Meno',
          onPressed: valore > minimo ? () => onChanged(valore - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$valore',
            textAlign: TextAlign.center,
            style: t.titleLarge,
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Più',
          onPressed: () => onChanged(valore + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
