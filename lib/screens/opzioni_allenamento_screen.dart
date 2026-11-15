import 'package:flutter/material.dart';

import '../avvisi.dart';
import '../dati_live.dart';
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
  @override
  void initState() {
    super.initState();
    caricaAvvisi();
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
