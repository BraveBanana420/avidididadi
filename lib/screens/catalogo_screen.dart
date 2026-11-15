import 'package:flutter/material.dart';

import '../app_state.dart';
import '../esercizi.dart';
import '../figura.dart';
import '../immagini.dart';
import '../models.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../widgets.dart';

class CatalogoScreen extends StatefulWidget {
  final AppState state;
  const CatalogoScreen({super.key, required this.state});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String cerca = '';
  String tipo = 'tutti'; // tutti | forza | mobilita
  bool soloMiei = true;
  Esercizio? selezionato; // i suoi muscoli si vedono nella figura in alto

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final t = Theme.of(context).textTheme;
    final q = cerca.trim().toLowerCase();
    final lista = state.esercizi.where(
      (e) =>
          (tipo == 'tutti' || e.tipo == tipo) &&
          (!soloMiei || e.fattibile(state.attrezzatura)) &&
          (q.isEmpty ||
              e.nome.toLowerCase().contains(q) ||
              e.nomeEn.toLowerCase().contains(q) ||
              e.muscoli.any(
                (m) => (nomiMuscoli[m] ?? m).toLowerCase().contains(q),
              )),
    );

    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('Catalogo esercizi')),
      body: Column(
        children: [
          // Una sola figura, fissa in alto: muscoli dell'esercizio selezionato.
          FiguraMuscoliFissa(
            sesso: state.profilo.sesso,
            evidenziati: selezionato?.muscoli.toSet() ?? const {},
            didascalia: selezionato == null
                ? 'Tocca un esercizio per vedere i muscoli che allena.'
                : '${selezionato!.nome}: ${selezionato!.muscoli.map((m) => nomiMuscoli[m] ?? m).join(', ')}',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Cerca per nome o muscolo',
                    ),
                    onChanged: (v) => setState(() => cerca = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'tutti', label: Text('Tutti')),
                      ButtonSegment(value: 'forza', label: Text('Forza')),
                      ButtonSegment(value: 'mobilita', label: Text('Mobilità')),
                    ],
                    selected: {tipo},
                    onSelectionChanged: (s) => setState(() => tipo = s.first),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Solo con la mia attrezzatura'),
                  value: soloMiei,
                  onChanged: (v) => setState(() => soloMiei = v),
                ),
                if (lista.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nessun esercizio con questi filtri.'),
                  ),
                // Una sezione per schema di movimento, chiusa di default: si apre
                // con la freccia. Cercando, si aprono quelle con dei risultati.
                for (final schema in nomiSchemi.keys)
                  if (lista.any((e) => e.schema == schema))
                    Card(
                      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        key: ValueKey('$schema-${q.isNotEmpty}'),
                        initiallyExpanded: q.isNotEmpty,
                        title: Text(
                          nomiSchemi[schema]!,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          quantiEsercizi(
                            lista.where((e) => e.schema == schema).length,
                          ),
                        ),
                        children: [
                          for (final e in lista.where(
                            (e) => e.schema == schema,
                          ))
                            ListTile(
                              // Tocco: seleziona e mostra i muscoli in alto. Freccia: dettaglio.
                              selected: selezionato == e,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              onTap: () => setState(
                                () => selezionato = selezionato == e ? null : e,
                              ),
                              title: Text(e.nome),
                              subtitle: Text(
                                e.fattibile(state.attrezzatura)
                                    ? '${e.descrizioneAttrezzi} · ${e.livello}'
                                    : 'Serve: ${e.descrizioneAttrezzi}',
                              ),
                              trailing: IconButton(
                                tooltip: 'Immagini e istruzioni',
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EsercizioScreen(
                                      state: state,
                                      esercizio: e,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dettaglio di un esercizio: movimento, muscoli e istruzioni.
class EsercizioScreen extends StatelessWidget {
  final AppState state;
  final Esercizio esercizio;
  const EsercizioScreen({
    super.key,
    required this.state,
    required this.esercizio,
  });

  @override
  Widget build(BuildContext context) {
    final e = esercizio;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    String muscoli(List<String> l) =>
        l.map((m) => nomiMuscoli[m] ?? m).join(', ');

    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(e.nome)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimazioneEsercizio(id: e.id, immagini: e.immagini),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(label: Text(maiuscola(e.livello))),
              Chip(label: Text(nomiSchemi[e.schema] ?? e.schema)),
              Chip(
                avatar: const Icon(Icons.fitness_center, size: 18),
                label: Text(e.descrizioneAttrezzi),
              ),
            ],
          ),
          if (state.serieFatte.any((x) => x.chiave == e.id)) ...[
            const SizedBox(height: 16),
            _StoricoEsercizio(serie: state.serieFatte, chiave: e.id),
          ],
          const SizedBox(height: 16),
          Text('Muscoli', style: t.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MappaMuscoli(
                  sesso: state.profilo.sesso,
                  evidenziati: e.muscoli.toSet(),
                ),
                MappaMuscoli(
                  sesso: state.profilo.sesso,
                  retro: true,
                  evidenziati: e.muscoli.toSet(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Principali: ${muscoli(e.muscoli)}'),
          if (e.muscoliSecondari.isNotEmpty)
            Text(
              'Secondari: ${muscoli(e.muscoliSecondari)}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          const SizedBox(height: 16),
          Text('Come si esegue', style: t.titleLarge),
          const SizedBox(height: 8),
          for (var i = 0; i < e.istruzioni.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: scheme.primary,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(fontSize: 12, color: scheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.istruzioni[i])),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Immagini da free-exercise-db (${e.nomeEn}).',
            style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Le tue serie di un esercizio: record e ultime sedute.
class _StoricoEsercizio extends StatelessWidget {
  final List<SerieFatta> serie;
  final String chiave;
  const _StoricoEsercizio({required this.serie, required this.chiave});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final sue = serie.where((s) => s.chiave == chiave).toList();
    final giorni = sue.map((s) => s.data).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final record = recordDi(sue, chiave)!;
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Le tue serie', style: t.titleMedium),
          const SizedBox(height: 4),
          Text(
            record.aTempo
                ? 'Record: ${fmtSecondi(record.secondi)}'
                : record.kg > 0
                ? 'Record: ${fmtKg(record.kg)} kg × ${record.ripetizioni}'
                : 'Record: ${record.ripetizioni} ripetizioni',
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final g in giorni.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${dataLunga(g)}: '
                '${fmtSerie(sue.where((s) => s.data == g).toList()..sort((a, b) => a.serie.compareTo(b.serie)))}',
                style: t.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
