import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../invio_intervals.dart';
import '../models.dart';
import '../pulse.dart';

/// Collegamento a intervals.icu: attività complete da Garmin, Polar, Suunto…
class SezioneIntervals extends StatefulWidget {
  final AppState state;
  const SezioneIntervals({super.key, required this.state});

  @override
  State<SezioneIntervals> createState() => _SezioneIntervalsState();
}

class _SezioneIntervalsState extends State<SezioneIntervals> {
  final _chiave = TextEditingController();
  bool _inCorso = false;

  @override
  void dispose() {
    _chiave.dispose();
    super.dispose();
  }

  Future<void> _incolla() async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    if (d?.text != null) setState(() => _chiave.text = d!.text!.trim());
  }

  Future<void> _esegui(Future<String> Function() azione) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _inCorso = true);
    final msg = await azione();
    if (!mounted) return;
    setState(() => _inCorso = false);
    if (msg.isNotEmpty) {
      messenger.showSnackBar(avviso(content: Text(msg)));
    }
  }

  Future<void> _scollega() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Scollegare intervals.icu?'),
        content: const Text(
          'Le attività tornano quelle di Health Connect, con meno dettagli. '
          'La chiave viene cancellata dal telefono.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Scollega'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.state.scollegaIntervals();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = widget.state;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => SuperficiePulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.watch_rounded),
                const SizedBox(width: 10),
                Expanded(child: Text('intervals.icu', style: t.titleMedium)),
                if (state.intervalsCollegato)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF22E07A),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Attività complete da Garmin, Polar, Suunto, Coros, Wahoo, '
              'Zwift: nome vero, rulli, percorso, altitudine, potenza.',
              style: t.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (state.intervalsCollegato)
              ..._collegato(context)
            else
              ..._passi(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _collegato(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = widget.state;
    final u = state.ultimaIntervals;
    return [
      Text(
        state.sincronizzandoIntervals
            ? 'Sincronizzazione in corso…'
            : u == null
            ? 'Collegato.'
            : 'Collegato · ultima sincronizzazione ${dataLunga(u)}, '
                  '${two(u.hour)}:${two(u.minute)} · '
                  '${state.sessioniIcu.length} attività',
        style: t.bodySmall,
      ),
      if (state.erroreIntervals != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            state.erroreIntervals!,
            style: t.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _inCorso || state.sincronizzandoIntervals
                ? null
                : () => _esegui(state.sincronizzaIntervals),
            icon: const Icon(Icons.sync_rounded),
            label: const Text('Sincronizza ora'),
          ),
          TextButton(onPressed: _scollega, child: const Text('Scollega')),
        ],
      ),
      const Divider(height: 24),
      Material(
        type: MaterialType.transparency,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Manda piano e sedute a intervals.icu'),
          subtitle: Text(
            'Corsa, bici e nuoto dei prossimi $giorniInvio giorni, passo per '
            'passo: si aggiornano da soli quando il piano cambia. Le sedute '
            "registrate con l'app partono da sole appena finite, con il "
            'percorso se c\'è.',
            style: t.bodySmall,
          ),
          value: state.invioIntervals,
          onChanged: _inCorso || state.inviando
              ? null
              : (v) => _esegui(() => state.impostaInvioIntervals(v)),
        ),
      ),
      if (state.invioIntervals) ...[
        Text(
          state.inviando
              ? 'Invio in corso…'
              : state.ultimoInvio == null
              ? 'Non ancora mandato.'
              : 'Ultimo invio ${dataLunga(state.ultimoInvio!)}, '
                    '${two(state.ultimoInvio!.hour)}:'
                    '${two(state.ultimoInvio!.minute)} · '
                    '${state.inviatiIcu.length} sedute in calendario',
          style: t.bodySmall,
        ),
        if (state.erroreInvio != null)
          Text(
            state.erroreInvio!,
            style: t.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _inCorso || state.inviando
              ? null
              : () => _esegui(state.inviaPianoIntervals),
          icon: const Icon(Icons.send_rounded),
          label: const Text('Invia ora'),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text("Per averle sull'orologio Garmin", style: t.titleSmall),
          children: [
            Text(
              'Su intervals.icu: Impostazioni → Garmin Connect → attiva '
              '"Upload planned workouts". Le sedute passano nel calendario '
              'di Garmin Connect e da lì all\'orologio. Battito: zone di '
              'intervals.icu; nuoto: passo per 100 m.',
              style: t.bodySmall,
            ),
          ],
        ),
      ],
    ];
  }

  List<Widget> _passi(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget passo(String n, String testo) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 11, child: Text(n, style: t.labelSmall)),
          const SizedBox(width: 10),
          Expanded(child: Text(testo, style: t.bodySmall)),
        ],
      ),
    );
    return [
      passo('1', 'Crea un account gratuito su intervals.icu (dal browser).'),
      passo(
        '2',
        'Lì, in Impostazioni, collega Garmin Connect (o il tuo orologio): le '
            'attività arrivano da sole.',
      ),
      passo(
        '3',
        'Sempre in Impostazioni, in fondo, "Developer settings": crea la '
            'chiave API e copiala.',
      ),
      passo('4', 'Incollala qui sotto e tocca Collega.'),
      const SizedBox(height: 6),
      TextField(
        controller: _chiave,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: 'Chiave API di intervals.icu',
          suffixIcon: IconButton(
            tooltip: 'Incolla dagli appunti',
            onPressed: _incolla,
            icon: const Icon(Icons.content_paste_rounded),
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'La chiave resta cifrata sul telefono. Serve a leggere le tue '
        'attività e, solo se lo accendi, a mandare il piano al tuo calendario.',
        style: t.bodySmall,
      ),
      const SizedBox(height: 10),
      FilledButton.icon(
        onPressed: _inCorso
            ? null
            : () => _esegui(() => widget.state.collegaIntervals(_chiave.text)),
        icon: _inCorso
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.link_rounded),
        label: const Text('Collega'),
      ),
    ];
  }
}
