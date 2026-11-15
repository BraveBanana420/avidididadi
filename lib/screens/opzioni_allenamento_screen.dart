import 'package:flutter/material.dart';

import '../avvisi.dart';
import '../dati_live.dart';
import '../voce.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';

/// Durante l'allenamento: voce, bip, vibrazione, pausa automatica e come si
/// calcola il passo medio. Si apre dal Profilo e dal tasto 🔊 dell'allenamento.
class OpzioniAllenamentoScreen extends StatefulWidget {
  const OpzioniAllenamentoScreen({super.key});

  @override
  State<OpzioniAllenamentoScreen> createState() =>
      _OpzioniAllenamentoScreenState();
}

class _OpzioniAllenamentoScreenState extends State<OpzioniAllenamentoScreen> {
  final _voce = Voce();

  @override
  void initState() {
    super.initState();
    caricaAvvisi();
  }

  /// Il nome di una scelta della lingua della voce.
  String _nomeScelta(String scelta) => switch (scelta) {
    'app' => l10n.linguaVoceComeApp,
    'telefono' =>
      '${l10n.linguaVoceComeTelefono} (${lingueVoce[codiceVocePer('telefono', codiceTelefono())] ?? ''})'
          .replaceAll(' ()', ''),
    _ => lingueVoce[scelta] ?? scelta,
  };

  Future<void> _scegliLinguaVoce() async {
    final scelta = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(l10n.linguaVoce),
        children: [
          RadioGroup<String>(
            groupValue: linguaVoceScelta.value,
            onChanged: (v) => Navigator.pop(c, v),
            child: Column(
              children: [
                for (final s in ['app', 'telefono', ...lingueVoce.keys])
                  RadioListTile<String>(value: s, title: Text(_nomeScelta(s))),
              ],
            ),
          ),
        ],
      ),
    );
    if (scelta == null || !mounted) return;
    // Una lingua diversa da quella dell'app: serve la sua voce sul telefono.
    final codice = codiceVocePer(scelta, codiceTelefono());
    if (codice != codiceLingua && !await voceDisponibile(codice)) {
      if (!mounted) return;
      final installa = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(l10n.voceNonInstallata(lingueVoce[codice] ?? codice)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l10n.annulla),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l10n.installaVoce),
            ),
          ],
        ),
      );
      if (installa == true) await apriImpostazioniVoce();
      return;
    }
    await salvaAvvisi(linguaVoce: scelta);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    Widget nota(String testo) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        testo,
        style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(l10n.duranteAllenamento)),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          bipAttivo,
          vibrazioneAttiva,
          voceAttiva,
          modoPausa,
          sogliaPausaKmh,
          mediaConSoste,
          vistaMappa,
          linguaVoceScelta,
        ]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.avvisi, style: t.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.record_voice_over_rounded),
                    title: Text(l10n.voce),
                    subtitle: Text(l10n.diceEsercizioIniziaKm),
                    value: voceAttiva.value,
                    onChanged: (v) => salvaAvvisi(voce: v),
                  ),
                  ListTile(
                    leading: const Icon(Icons.translate_rounded),
                    title: Text(l10n.linguaVoce),
                    subtitle: Text(
                      '${_nomeScelta(linguaVoceScelta.value)}\n'
                      '${l10n.linguaVoceSpiega}',
                    ),
                    isThreeLine: true,
                    onTap: _scegliLinguaVoce,
                  ),
                  ListTile(
                    leading: const Icon(Icons.play_circle_outline_rounded),
                    title: Text(l10n.provaVoce),
                    subtitle: Text(fraseProvaVoce()),
                    onTap: _voce.prova,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up_rounded),
                    title: Text(l10n.bip),
                    subtitle: Text(
                      l10n.negliUltimiSecondiRecuperi(secondiAvviso),
                    ),
                    value: bipAttivo.value,
                    onChanged: (v) => salvaAvvisi(bip: v),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration_rounded),
                    title: Text(l10n.vibrazione),
                    subtitle: Text(l10n.insiemeAiBip),
                    value: vibrazioneAttiva.value,
                    onChanged: (v) => salvaAvvisi(vibrazione: v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.pausaAutomatica, style: t.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.corsaBiciCamminataTempo,
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<ModoPausa>(
                groupValue: modoPausa.value,
                onChanged: (v) => salvaAvvisi(pausa: v),
                child: Column(
                  children: [
                    RadioListTile(
                      value: ModoPausa.spenta,
                      title: Text(l10n.spenta),
                      subtitle: Text(l10n.tempoNonSiFerma),
                    ),
                    RadioListTile(
                      value: ModoPausa.ferma,
                      title: Text(l10n.soloQuandoSeiFermo),
                      subtitle: Text(l10n.alSemaforoOSosta),
                    ),
                    RadioListTile(
                      value: ModoPausa.sotto,
                      title: Text(
                        l10n.sottoKmH(fmtSoglia(sogliaPausaKmh.value)),
                      ),
                      subtitle: Text(l10n.comeCerteAppAttento),
                    ),
                    if (modoPausa.value == ModoPausa.sotto) ...[
                      Slider(
                        value: sogliaPausaKmh.value,
                        min: 2,
                        max: 15,
                        divisions: 26,
                        label: '${fmtSoglia(sogliaPausaKmh.value)} km/h',
                        onChanged: (v) => salvaAvvisi(sogliaKmh: v),
                      ),
                      nota(l10n.camminataTranquilla45),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.passoMedio, style: t.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<bool>(
                groupValue: mediaConSoste.value,
                onChanged: (v) => salvaAvvisi(conSoste: v),
                child: Column(
                  children: [
                    RadioListTile(
                      value: false,
                      title: Text(l10n.soloMovimento),
                      subtitle: Text(l10n.sosteNonContanoAnche),
                    ),
                    RadioListTile(
                      value: true,
                      title: Text(l10n.soste),
                      subtitle: Text(l10n.distanzaDivisoTuttoTempo),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            nota(l10n.allaFineRiepilogoMostra),
            const SizedBox(height: 16),
            Text(l10n.mappa, style: t.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.corsaCamminataBiciAll,
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<VistaMappa>(
                groupValue: vistaMappa.value,
                onChanged: (v) => salvaAvvisi(mappa: v),
                child: Column(
                  children: [
                    RadioListTile(
                      value: VistaMappa.pagine,
                      secondary: Icon(Icons.view_carousel_rounded),
                      title: Text(l10n.duePagine),
                      subtitle: Text(l10n.scorriLatoTimerDati),
                    ),
                    RadioListTile(
                      value: VistaMappa.minimappa,
                      secondary: Icon(Icons.picture_in_picture_rounded),
                      title: Text(l10n.minimappa),
                      subtitle: Text(l10n.mappaPiccolaSempreVista),
                    ),
                    RadioListTile(
                      value: VistaMappa.schermo,
                      secondary: Icon(Icons.fullscreen_rounded),
                      title: Text(l10n.tuttoSchermo),
                      subtitle: Text(l10n.mappaOccupaTuttoTempo),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "4" o "4,5".
String fmtSoglia(double kmh) => kmh == kmh.roundToDouble()
    ? '${kmh.round()}'
    : kmh.toStringAsFixed(1).replaceAll('.', ',');
