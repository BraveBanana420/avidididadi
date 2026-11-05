import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../obiettivo.dart';
import '../potenza.dart';
import '../widgets.dart';
import 'esecuzione_screen.dart';

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
          // Icone al posto dei nomi: "Triathlon" non ci stava in una riga.
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              for (final s in gare.keys)
                ButtonSegment(
                  value: s,
                  tooltip: s,
                  icon: s == 'Triathlon'
                      ? const IconaTriathlon()
                      : Icon(iconaSport(s)),
                ),
            ],
            selected: {sport},
            onSelectionChanged: (v) => setState(() {
              sport = v.first;
              gara = gare[sport]!.keys.first;
            }),
          ),
          const SizedBox(height: 8),
          Text(sport, style: t.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
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

/// Nuoto, bici e corsa piccoli, a triangolo: l'icona del triathlon.
class IconaTriathlon extends StatelessWidget {
  const IconaTriathlon({super.key});

  @override
  Widget build(BuildContext context) {
    final dim = IconTheme.of(context).size ?? 18;
    final piccola = dim * 0.62;
    return SizedBox(
      width: dim * 1.35,
      height: dim * 1.2,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Icon(Icons.pool, size: piccola),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Icon(Icons.directions_bike, size: piccola),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.directions_run, size: piccola),
          ),
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
  late final ftp = TextEditingController(
    text: p.ftpManuale > 0 ? '${p.ftpManuale}' : '',
  );
  late final ftpCorsa = TextEditingController(
    text: p.ftpCorsaManuale > 0 ? '${p.ftpCorsaManuale}' : '',
  );
  String? errore;

  @override
  void dispose() {
    for (final c in [fcMax, fcRiposo, passo, ftp, ftpCorsa]) {
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
    final fw = _intero(ftp, 50, 600);
    final fc = _intero(ftpCorsa, 50, 600);
    if (mx == null ||
        rp == null ||
        ps == null ||
        (ps > 0 && ps < 50) ||
        fw == null ||
        fc == null) {
      setState(
        () => errore =
            'Controlla i valori: FC max 120-230, FC riposo 30-100, passo m:ss, '
            'FTP 50-600 W.',
      );
      return;
    }
    final navigator = Navigator.of(context);
    p
      ..fcMaxManuale = mx
      ..fcRiposoManuale = rp
      ..passoCriticoManuale = ps
      ..ftpManuale = fw
      ..ftpCorsaManuale = fc;
    await widget.state.salvaProfilo();
    navigator.pop();
  }

  /// Il test per l'FTP di corsa: cosa si fa, e farlo ora o in un altro giorno.
  Future<void> _apriTest() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) {
      final t = Theme.of(c).textTheme;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(nomeTestFtpCorsa, style: t.titleLarge),
            const Text(
              '15 minuti facili e 3 allunghi, poi 20 minuti al massimo che '
              'riesci a tenere, poi 10 minuti lentissimi. Circa 50 minuti.',
            ),
            const Text(
              'Il telefono non misura i watt di corsa: registra la corsa anche '
              'con l\'orologio. Poi apri i grafici di quella corsa: lì trovi '
              'la tua FTP e il tasto per salvarla.',
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(c);
                avviaAllenamento(
                  context,
                  widget.state,
                  sport: 'Corsa',
                  tipo: 'Test FTP',
                  nome: nomeTestFtpCorsa,
                  passi: passiTestFtpCorsa('libera'),
                  libera: true,
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Inizia ora'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(c);
                final messenger = ScaffoldMessenger.of(context);
                final oggi = soloData(DateTime.now());
                final data = await showDatePicker(
                  context: c,
                  initialDate: oggi,
                  firstDate: oggi,
                  lastDate: oggi.add(const Duration(days: 365)),
                  helpText: 'In che giorno?',
                );
                if (data == null) return;
                final ok = await widget.state.programmaTestFtpCorsa(data);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Test nel calendario: ${dataLunga(data)}. Prende '
                                'il posto della corsa di quel giorno.'
                          : 'Scegli oggi o un giorno dopo.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.event_available),
              label: const Text('Mettilo nel calendario'),
            ),
          ],
        ),
      );
    },
  );

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
          const SizedBox(height: 24),
          Text('Le tue zone di potenza (bici)', style: t.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Partono dall\'FTP, la potenza che riesci a tenere per circa '
            'un\'ora. Le sedute di bici ti danno il range di watt da tenere.',
            style: t.bodySmall,
          ),
          if (widget.state.zonePotenza case final zp?) ...[
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (var n = 1; n <= 7; n++)
                    ListTile(
                      dense: true,
                      leading: CircleAvatar(radius: 14, child: Text('$n')),
                      title: Text(ZonePotenza.nomi[n - 1]),
                      trailing: Text(zp.testo(n), style: t.titleSmall),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: ftp,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'FTP',
              suffixText: 'W',
              helperText: widget.state.ftpIcu > 0
                  ? 'Vuoto = quello di intervals.icu: ${widget.state.ftpIcu} W.'
                  : 'Se non lo sai: pedala 20 minuti più forte che puoi, '
                        'l\'FTP è circa il 95% della potenza media.',
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text('Le tue zone di potenza (corsa)', style: t.titleMedium),
          const SizedBox(height: 4),
          Text(
            'L\'FTP della bici non vale correndo: la corsa ha la sua. Serve ai '
            'grafici delle corse registrate con un orologio che misura i watt.',
            style: t.bodySmall,
          ),
          if (widget.state.zonePotenzaCorsa case final zc?) ...[
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (var n = 1; n <= zc.numero; n++)
                    ListTile(
                      dense: true,
                      leading: CircleAvatar(radius: 14, child: Text('$n')),
                      title: Text(zc.nomiZone[n - 1]),
                      trailing: Text(zc.testo(n), style: t.titleSmall),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: ftpCorsa,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'FTP di corsa',
              suffixText: 'W',
              helperText: widget.state.ftpCorsaIcu > 0
                  ? 'Vuoto = quello di intervals.icu: '
                        '${widget.state.ftpCorsaIcu} W.'
                  : widget.state.stimaFtpDiCorsa != null
                  ? 'Vuoto = stima da età e peso: '
                        '${widget.state.stimaFtpDiCorsa} W. È solo un punto di '
                        'partenza.'
                  : 'Vuoto = stima da età e peso: scrivi il peso nel Profilo.',
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _apriTest,
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Fai il test per calcolarla'),
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
