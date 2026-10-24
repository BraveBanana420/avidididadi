import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../obiettivo.dart';
import '../widgets.dart';

String _dataBreve(DateTime d) => '${two(d.day)}/${two(d.month)}/${d.year}';

/// "1:45" (ore:minuti) o "105" (minuti) -> minuti; null se non valido.
int? _leggiTempo(String t) {
  final s = t.trim();
  if (s.isEmpty) return 0;
  final p = s.split(RegExp(r'[:.]'));
  if (p.length == 2) {
    final h = int.tryParse(p[0]), m = int.tryParse(p[1]);
    if (h == null || m == null || m >= 60) return null;
    return h * 60 + m;
  }
  return int.tryParse(s);
}

String _scriviTempo(int min) => min == 0 ? '' : '${min ~/ 60}:${two(min % 60)}';

/// Gara obiettivo: sport, distanza, data e tempo facoltativo.
class ObiettivoScreen extends StatefulWidget {
  final AppState state;
  const ObiettivoScreen({super.key, required this.state});

  @override
  State<ObiettivoScreen> createState() => _ObiettivoScreenState();
}

class _ObiettivoScreenState extends State<ObiettivoScreen> {
  late final p = widget.state.profilo;
  late String sport = p.garaSport.isEmpty ? 'Corsa' : p.garaSport;
  late String gara = p.garaTipo.isEmpty ? gare[sport]!.keys.first : p.garaTipo;
  late DateTime? data = p.garaData;
  late final tempo = TextEditingController(text: _scriviTempo(p.garaTempoMin));
  String? erroreTempo;

  @override
  void dispose() {
    tempo.dispose();
    super.dispose();
  }

  Future<void> _scegliData() async {
    final oggi = soloData(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: data ?? oggi.add(const Duration(days: 84)),
      firstDate: oggi,
      lastDate: DateTime(oggi.year + 3),
      helpText: 'Data della gara',
    );
    if (d != null) setState(() => data = soloData(d));
  }

  Future<void> _salva() async {
    final min = _leggiTempo(tempo.text);
    if (min == null) {
      setState(() => erroreTempo = 'Scrivi ore:minuti, es. 1:45');
      return;
    }
    if (data == null) {
      setState(() => erroreTempo = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scegli la data della gara.')),
      );
      return;
    }
    final navigator = Navigator.of(context);
    p
      ..garaSport = sport
      ..garaTipo = gara
      ..garaData = data
      ..garaTempoMin = min;
    await widget.state.salvaProfilo();
    navigator.pop();
  }

  Future<void> _rimuovi() async {
    final navigator = Navigator.of(context);
    p
      ..garaSport = ''
      ..garaTipo = ''
      ..garaData = null
      ..garaTempoMin = 0;
    await widget.state.salvaProfilo();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final anteprima = data == null
        ? null
        : Obiettivo(sport: sport, gara: gara, data: data!);
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: const Text('Obiettivo'),
        actions: [TextButton(onPressed: _salva, child: const Text('Salva'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: [
              for (final s in gare.keys)
                ButtonSegment(value: s, label: Text(s)),
            ],
            selected: {sport},
            onSelectionChanged: (v) => setState(() {
              sport = v.first;
              gara = gare[sport]!.keys.first;
            }),
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<String>(
              groupValue: gara,
              onChanged: (v) => setState(() => gara = v ?? gara),
              child: Column(
                children: [
                  for (final e in gare[sport]!.entries)
                    RadioListTile<String>(value: e.key, title: Text(e.value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _scegliData,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data della gara',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                data == null ? 'Tocca per sceglierla' : _dataBreve(data!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tempo,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: 'Tempo obiettivo (facoltativo)',
              hintText: 'ore:minuti, es. 1:45',
              errorText: erroreTempo,
            ),
          ),
          if (anteprima != null) ...[
            const SizedBox(height: 20),
            Text(
              'Tra ${anteprima.settimaneMancanti(DateTime.now())} settimane',
              style: t.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Fase attuale: ${nomiFasi[anteprima.fase(DateTime.now())]}. '
              '${spiegazioniFasi[anteprima.fase(DateTime.now())]}',
            ),
            const SizedBox(height: 4),
            Text(
              'Le fasi avanzano da sole verso la gara: base, sviluppo, '
              'rifinitura e scarico.',
              style: t.bodySmall,
            ),
          ],
          if (p.obiettivoGara != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _rimuovi,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Rimuovi obiettivo'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Zone di frequenza cardiaca e passo critico del nuoto, con le correzioni.
class ZoneScreen extends StatefulWidget {
  final AppState state;
  const ZoneScreen({super.key, required this.state});

  @override
  State<ZoneScreen> createState() => _ZoneScreenState();
}

class _ZoneScreenState extends State<ZoneScreen> {
  late final p = widget.state.profilo;
  late final fcMax = TextEditingController(
    text: p.fcMaxManuale > 0 ? '${p.fcMaxManuale}' : '',
  );
  late final fcRiposo = TextEditingController(
    text: p.fcRiposoManuale > 0 ? '${p.fcRiposoManuale}' : '',
  );
  late final passo = TextEditingController(
    text: p.passoCriticoManuale > 0
        ? '${p.passoCriticoManuale ~/ 60}:${two(p.passoCriticoManuale % 60)}'
        : '',
  );
  String? errore;

  @override
  void dispose() {
    for (final c in [fcMax, fcRiposo, passo]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _intero(TextEditingController c, int min, int max) {
    final t = c.text.trim();
    if (t.isEmpty) return 0;
    final v = int.tryParse(t);
    return v == null || v < min || v > max ? null : v;
  }

  Future<void> _salva() async {
    final mx = _intero(fcMax, 120, 230);
    final rp = _intero(fcRiposo, 30, 100);
    final ps = _leggiTempo(passo.text); // m:ss letto come ore:minuti -> secondi
    if (mx == null || rp == null || ps == null || (ps > 0 && ps < 50)) {
      setState(
        () => errore =
            'Controlla i valori: FC max 120-230, FC riposo 30-100, passo m:ss.',
      );
      return;
    }
    final navigator = Navigator.of(context);
    p
      ..fcMaxManuale = mx
      ..fcRiposoManuale = rp
      ..passoCriticoManuale = ps;
    await widget.state.salvaProfilo();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final z = widget.state.zone;
    final (stimata, _) = stimaFcMax(
      widget.state.sessioni,
      p.eta,
      DateTime.now(),
    );
    final passoStimato = stimaPassoCritico(
      widget.state.sessioni,
      DateTime.now(),
    );
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: const Text('Zone'),
        actions: [TextButton(onPressed: _salva, child: const Text('Salva'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Le tue zone di frequenza cardiaca', style: t.titleMedium),
          const SizedBox(height: 4),
          Text(
            z.fcRiposo > 0
                ? 'Calcolate con la riserva cardiaca (FC max ${z.fcMax}, a riposo ${z.fcRiposo}).'
                : 'Calcolate come percentuale della FC max (${z.fcMax}). '
                      'Con la FC a riposo diventano più precise.',
            style: t.bodySmall,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (var n = 1; n <= 5; n++)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(radius: 14, child: Text('$n')),
                    title: Text(Zone.nomi[n - 1]),
                    trailing: Text(
                      '${z.zona(n).$1}-${z.zona(n).$2} bpm',
                      style: t.titleSmall,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: fcMax,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'FC massima',
              suffixText: 'bpm',
              helperText:
                  'Vuoto = stima dai tuoi dati: $stimata bpm (la più alta dell\'ultimo anno, o dall\'età).',
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: fcRiposo,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'FC a riposo',
              suffixText: 'bpm',
              helperText: widget.state.fcRiposoMisurata > 0
                  ? 'Vuoto = quella misurata: ${widget.state.fcRiposoMisurata} bpm.'
                  : 'Misurala appena sveglio, o lascia vuoto.',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passo,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: 'Passo critico del nuoto',
              suffixText: 'min/100 m',
              hintText: 'm:ss, es. 2:05',
              helperText: passoStimato == null
                  ? 'Vuoto = stima dalle sessioni in piscina (non ancora disponibile).'
                  : 'Vuoto = stima dalle sessioni in piscina: ${fmtPasso100(passoStimato)}.',
              helperMaxLines: 2,
            ),
          ),
          if (errore != null) ...[
            const SizedBox(height: 12),
            Text(
              errore!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
