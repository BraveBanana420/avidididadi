import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../models.dart';
import '../obiettivo.dart';
import '../potenza.dart';
import '../pulse.dart';
import '../test_soglia.dart';
import '../widgets.dart';
import 'esecuzione_screen.dart';
import '../l10n/lingua.dart';
import '../l10n/vocabolario.dart';

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
      helpText: l10n.dataGara,
    );
    if (d != null) setState(() => data = soloData(d));
  }

  Future<void> _salva() async {
    final min = _leggiTempo(tempo.text);
    if (min == null) {
      setState(() => erroreTempo = l10n.scriviOreMinutiEs);
      return;
    }
    if (data == null) {
      setState(() => erroreTempo = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(avviso(content: Text(l10n.scegliDataGara)));
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
        title: Text(l10n.obiettivo),
        actions: [TextButton(onPressed: _salva, child: Text(l10n.salva))],
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
          Text(
            mostra(sport),
            style: t.titleMedium,
            textAlign: TextAlign.center,
          ),
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
              decoration: InputDecoration(
                labelText: l10n.dataGara,
                suffixIcon: Icon(Icons.calendar_today_rounded),
              ),
              child: Text(
                data == null ? l10n.toccaSceglierla : _dataBreve(data!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tempo,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: l10n.tempoObiettivoFacoltativo,
              hintText: l10n.oreMinutiEs1,
              errorText: erroreTempo,
            ),
          ),
          if (anteprima != null) ...[
            const SizedBox(height: 20),
            Text(
              l10n.traSettimane(anteprima.settimaneMancanti(DateTime.now())),
              style: t.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.faseAttuale(
                nomiFasi[anteprima.fase(DateTime.now())]!,
                spiegazioniFasi[anteprima.fase(DateTime.now())]!,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.fasiAvanzanoSoleVerso, style: t.bodySmall),
          ],
          if (p.obiettivoGara != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _rimuovi,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.rimuoviObiettivo),
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
            child: Icon(Icons.pool_rounded, size: piccola),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Icon(Icons.directions_bike_rounded, size: piccola),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.directions_run_rounded, size: piccola),
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
      setState(() => errore = l10n.controllaValoriFcMax);
      return;
    }
    final navigator = Navigator.of(context);
    // Un FTP o un passo nuovo vale come confermato oggi.
    final oggi = soloData(DateTime.now());
    if (fw > 0 && fw != p.ftpManuale) p.ftpData = oggi;
    if (ps > 0 && ps != p.passoCriticoManuale) p.passoCriticoData = oggi;
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
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + spazioInBasso(c)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(nomeTestFtpCorsa, style: t.titleLarge),
            Text(l10n.n15MinutiFacili3),
            Text(l10n.telefonoNonMisuraWatt),
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
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.iniziaOra),
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
                  helpText: l10n.giorno,
                );
                if (data == null) return;
                final ok = await widget.state.programmaTestFtpCorsa(data);
                navigator.pop();
                messenger.showSnackBar(
                  avviso(
                    content: Text(
                      ok
                          ? l10n.testNelCalendarioPrende(dataLunga(data))
                          : l10n.scegliOggiOGiorno,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.event_available_rounded),
              label: Text(l10n.mettiloNelCalendario),
            ),
          ],
        ),
      );
    },
  );

  /// Il foglio di un test di bici o nuoto: cosa si fa, e farlo ora o in un
  /// altro giorno. [sopra] è un widget in cima con il suo stato (per la bici,
  /// dove si pedala); [inizia] e [programma] ricevono quello stato.
  Future<void> _foglioTest<T>({
    required String sport,
    required String titolo,
    required T scelta,
    required List<String> Function(T) testi,
    required void Function(T) inizia,
    required Future<bool> Function(DateTime, T) programma,
    Widget Function(T, void Function(T))? sopra,
    Widget? sotto,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) {
      var valore = scelta;
      final t = Theme.of(c).textTheme;
      return StatefulBuilder(
        builder: (c, aggiorna) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + spazioInBasso(c)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(titolo, style: t.titleLarge),
              if (sopra != null)
                sopra(valore, (v) => aggiorna(() => valore = v)),
              for (final x in testi(valore)) Text(x),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(c);
                  inizia(valore);
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.iniziaOra),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(c);
                  final messenger = ScaffoldMessenger.of(context);
                  final oggi = soloData(DateTime.now());
                  // Proposto il giorno della prossima seduta dura.
                  final proposta = widget.state.sedutaPerIlTest(sport)?.data;
                  final data = await showDatePicker(
                    context: c,
                    initialDate: proposta ?? oggi,
                    firstDate: oggi,
                    lastDate: oggi.add(const Duration(days: 365)),
                    helpText: l10n.giorno,
                  );
                  if (data == null) return;
                  final ok = await programma(data, valore);
                  navigator.pop();
                  messenger.showSnackBar(
                    avviso(
                      content: Text(
                        ok
                            ? l10n.tsTestNelCalendario(dataLunga(data))
                            : l10n.scegliOggiOGiorno,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.event_available_rounded),
                label: Text(l10n.mettiloNelCalendario),
              ),
              ?sotto,
            ],
          ),
        ),
      );
    },
  );

  /// Il test per l'FTP della bici: a rampa sul rullo smart, da 20 minuti
  /// su strada (o sul rullo senza ERG).
  Future<void> _apriTestBici() => _foglioTest<bool>(
    sport: 'Bici',
    titolo: l10n.tsTestFtpBici,
    scelta: widget.state.usaRullo,
    sopra: (rampa, cambia) => SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: true,
          icon: const Icon(Icons.home_rounded),
          label: Text(l10n.tsRulloSmart),
        ),
        ButtonSegment(
          value: false,
          icon: const Icon(Icons.landscape_rounded),
          label: Text(l10n.tsSuStrada),
        ),
      ],
      selected: {rampa},
      onSelectionChanged: (v) => cambia(v.first),
    ),
    testi: (rampa) {
      final ftp = widget.state.ftpBici;
      return rampa
          ? [l10n.tsRampaTesto1, l10n.tsRampaTesto2]
          : [
              l10n.tsVentiTesto1,
              ftp == null
                  ? l10n.tsVentiTesto2Senza
                  : l10n.tsVentiTesto2Con(ftp),
              l10n.tsVentiTesto3,
            ];
    },
    inizia: (rampa) => avviaAllenamento(
      context,
      widget.state,
      sport: 'Bici',
      tipo: tipoTestFtp,
      nome: rampa ? nomeTestFtpBiciRampa : nomeTestFtpBiciVenti,
      passi: widget.state.passiTestBici('libera', rampa: rampa),
      libera: true,
    ),
    programma: (d, rampa) => widget.state.programmaTestFtpBici(d, rampa: rampa),
  );

  /// Il test del passo critico in piscina, con i tempi da scrivere dopo.
  Future<void> _apriTestNuoto() => _foglioTest<bool>(
    sport: 'Nuoto',
    titolo: mostra(nomeTestNuoto),
    scelta: true,
    testi: (_) => [l10n.tsNuotoTesto1, l10n.tsNuotoTesto2],
    inizia: (_) => avviaAllenamento(
      context,
      widget.state,
      sport: 'Nuoto',
      tipo: tipoTestNuoto,
      nome: nomeTestNuoto,
      passi: passiTestNuoto('libera'),
      libera: true,
    ),
    programma: (d, _) => widget.state.programmaTestNuoto(d),
    sotto: Builder(
      builder: (c) => TextButton.icon(
        onPressed: () {
          Navigator.pop(c);
          _tempiNuoto();
        },
        icon: const Icon(Icons.edit_rounded),
        label: Text(l10n.tsHoFattoTest),
      ),
    ),
  );

  /// I tempi del 400 e del 200: diventano il passo critico.
  Future<void> _tempiNuoto() async {
    final t400 = TextEditingController(), t200 = TextEditingController();
    final pc = await showDialog<int>(
      context: context,
      builder: (c) {
        String? errore;
        return StatefulBuilder(
          builder: (c, aggiorna) => AlertDialog(
            title: Text(l10n.tsTempiTest),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                TextField(
                  controller: t400,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: '400 m',
                    hintText: l10n.tsEs400,
                  ),
                ),
                TextField(
                  controller: t200,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: '200 m',
                    hintText: l10n.tsEs200,
                    errorText: errore,
                    errorMaxLines: 3,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: Text(l10n.annulla),
              ),
              FilledButton(
                onPressed: () {
                  final a = _leggiTempo(t400.text), b = _leggiTempo(t200.text);
                  final v = a == null || b == null
                      ? null
                      : passoCriticoDaTest(a, b);
                  if (v == null) {
                    aggiorna(() => errore = l10n.tsControllaTempi);
                    return;
                  }
                  Navigator.pop(c, v);
                },
                child: Text(l10n.tsCalcola),
              ),
            ],
          ),
        );
      },
    );
    t400.dispose();
    t200.dispose();
    if (pc == null || !mounted) return;
    await widget.state.impostaPassoCritico(pc);
    passo.text = '${pc ~/ 60}:${two(pc % 60)}';
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(avviso(content: Text(l10n.tsPassoSalvato(fmtPasso100(pc)))));
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
        title: Text(l10n.zone),
        actions: [TextButton(onPressed: _salva, child: Text(l10n.salva))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.tueZoneFrequenzaCardiaca, style: t.titleMedium),
          const SizedBox(height: 4),
          Text(
            z.fcRiposo > 0
                ? l10n.calcolateRiservaCardiacaFc(z.fcMax, z.fcRiposo)
                : l10n.calcolateComePercentualeFc(z.fcMax),
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
                      l10n.bpm2(z.zona(n).$1, z.zona(n).$2),
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
              labelText: l10n.fcMassima,
              suffixText: 'bpm',
              helperText: l10n.vuotoStimaDaiTuoi(stimata),
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: fcRiposo,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.fcRiposo,
              suffixText: 'bpm',
              helperText: widget.state.fcRiposoMisurata > 0
                  ? l10n.vuotoQuellaMisurataBpm(widget.state.fcRiposoMisurata)
                  : l10n.misuralaAppenaSveglioO,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passo,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: l10n.passoCriticoNuoto,
              suffixText: 'min/100 m',
              hintText: l10n.mSsEs2,
              helperText: passoStimato == null
                  ? l10n.vuotoStimaDalleSessioni
                  : l10n.vuotoStimaDalleSessioni2(fmtPasso100(passoStimato)),
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _apriTestNuoto,
            icon: const Icon(Icons.timer_rounded),
            label: Text(l10n.tsFaiTestCalcolarlo),
          ),
          const SizedBox(height: 24),
          Text(l10n.tueZonePotenzaBici, style: t.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.partonoDallFtpPotenza, style: t.bodySmall),
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
              labelText: l10n.ftp,
              suffixText: 'W',
              helperText: widget.state.ftpIcu > 0
                  ? l10n.vuotoQuelloIntervalsIcu(widget.state.ftpIcu)
                  : l10n.tsSeNonSaiTest,
              helperMaxLines: 3,
            ),
          ),
          ListenableBuilder(
            listenable: widget.state,
            builder: (context, _) {
              final f = widget.state.ftpProposto;
              final u = widget.state.uscitaProposta;
              if (f == null || u == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SuperficiePulse(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(l10n.tsUsciteDicono(f), style: t.titleMedium),
                      Text(
                        u.test.isNotEmpty
                            ? l10n.tsDalTest(_dataBreve(u.data))
                            : l10n.tsHaiTenuto(_dataBreve(u.data), u.w20, f),
                        style: t.bodySmall,
                      ),
                      FilledButton.icon(
                        onPressed: () async {
                          await widget.state.impostaFtp(f);
                          ftp.text = '$f';
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(l10n.tsUsaloComeFtp),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _apriTestBici,
            icon: const Icon(Icons.timer_rounded),
            label: Text(l10n.tsFaiTestCalcolarlo),
          ),
          const SizedBox(height: 24),
          Text(l10n.tueZonePotenzaCorsa, style: t.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.ftpBiciNonVale, style: t.bodySmall),
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
              labelText: l10n.ftpCorsa,
              suffixText: 'W',
              helperText: widget.state.ftpCorsaIcu > 0
                  ? l10n.vuotoQuelloIntervalsIcu(widget.state.ftpCorsaIcu)
                  : widget.state.stimaFtpDiCorsa != null
                  ? l10n.vuotoStimaEtaPeso(widget.state.stimaFtpDiCorsa!)
                  : l10n.vuotoStimaEtaPeso2,
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _apriTest,
            icon: const Icon(Icons.timer_rounded),
            label: Text(l10n.faiTestCalcolarla),
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
