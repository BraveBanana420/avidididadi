import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../invio_intervals.dart';
import '../models.dart';
import '../pulse.dart';
import '../l10n/lingua.dart';

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
        title: Text(l10n.scollegareIntervalsIcu),
        content: Text(l10n.attivitaTornanoQuelleHealth),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.scollega),
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
            Text(l10n.attivitaCompleteGarminPolar, style: t.bodyMedium),
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
            ? l10n.sincronizzazioneCorso
            : u == null
            ? l10n.collegato4
            : l10n.collegatoUltimaSincronizzazioneAttivita(
                dataLunga(u),
                two(u.hour),
                two(u.minute),
                state.sessioniIcu.length,
              ),
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
            label: Text(l10n.sincronizzaOra),
          ),
          TextButton(onPressed: _scollega, child: Text(l10n.scollega)),
        ],
      ),
      const Divider(height: 24),
      Material(
        type: MaterialType.transparency,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.mandaPianoSeduteIntervals),
          subtitle: Text(
            l10n.corsaBiciNuotoDei(giorniInvio),
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
              ? l10n.invioCorso
              : state.ultimoInvio == null
              ? l10n.nonAncoraMandato
              : l10n.ultimoInvioSeduteCalendario(
                  dataLunga(state.ultimoInvio!),
                  two(state.ultimoInvio!.hour),
                  two(state.ultimoInvio!.minute),
                  state.inviatiIcu.length,
                ),
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
          label: Text(l10n.inviaOra),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(l10n.averleSullOrologioGarmin, style: t.titleSmall),
          children: [Text(l10n.suIntervalsIcuImpostazioni, style: t.bodySmall)],
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
      passo('1', l10n.creaAccountGratuitoSu),
      passo('2', l10n.liImpostazioniCollegaGarmin),
      passo('3', l10n.sempreImpostazioniFondoDeveloper),
      passo('4', l10n.incollalaQuiSottoTocca),
      const SizedBox(height: 6),
      TextField(
        controller: _chiave,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: l10n.chiaveApiIntervalsIcu,
          suffixIcon: IconButton(
            tooltip: l10n.incollaDagliAppunti,
            onPressed: _incolla,
            icon: const Icon(Icons.content_paste_rounded),
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(l10n.chiaveRestaCifrataSul, style: t.bodySmall),
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
        label: Text(l10n.collega2),
      ),
    ];
  }
}
