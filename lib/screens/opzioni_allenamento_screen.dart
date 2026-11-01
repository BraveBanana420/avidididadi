import 'package:flutter/material.dart';

import '../avvisi.dart';
import '../dati_live.dart';
import '../widgets.dart';

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
      appBar: AppBar(title: const Text("Durante l'allenamento")),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          bipAttivo,
          vibrazioneAttiva,
          voceAttiva,
          modoPausa,
          sogliaPausaKmh,
          mediaConSoste,
        ]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Avvisi', style: t.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.record_voice_over_outlined),
                    title: const Text('Voce'),
                    subtitle: const Text(
                      "Dice l'esercizio che inizia, i km e se sei fuori zona "
                      'o fuori passo. Durante le chiamate sta zitta.',
                    ),
                    value: voceAttiva.value,
                    onChanged: (v) => salvaAvvisi(voce: v),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up),
                    title: const Text('Bip'),
                    subtitle: const Text(
                      'Negli ultimi $secondiAvviso secondi di recuperi ed '
                      'esercizi a tempo, e a ogni km (5 km in bici). Usa il '
                      'volume dei media.',
                    ),
                    value: bipAttivo.value,
                    onChanged: (v) => salvaAvvisi(bip: v),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration),
                    title: const Text('Vibrazione'),
                    subtitle: const Text('Insieme ai bip.'),
                    value: vibrazioneAttiva.value,
                    onChanged: (v) => salvaAvvisi(vibrazione: v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Pausa automatica', style: t.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Corsa, bici e camminata: il tempo si ferma quando ti fermi e '
              'riparte da solo. Mai durante i recuperi.',
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<ModoPausa>(
                groupValue: modoPausa.value,
                onChanged: (v) => salvaAvvisi(pausa: v),
                child: Column(
                  children: [
                    const RadioListTile(
                      value: ModoPausa.spenta,
                      title: Text('Spenta'),
                      subtitle: Text('Il tempo non si ferma mai da solo.'),
                    ),
                    const RadioListTile(
                      value: ModoPausa.ferma,
                      title: Text('Solo quando sei fermo'),
                      subtitle: Text(
                        'Al semaforo o a una sosta. Se vai piano, anche in '
                        'salita, il tempo continua.',
                      ),
                    ),
                    RadioListTile(
                      value: ModoPausa.sotto,
                      title: Text(
                        'Sotto i ${fmtSoglia(sogliaPausaKmh.value)} km/h',
                      ),
                      subtitle: const Text(
                        'Come certe app: attento, se vai più piano di così '
                        'il tempo si ferma.',
                      ),
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
                      nota(
                        'Camminata tranquilla 4-5 km/h, corsa lenta 8-10, '
                        'bici in salita anche 6-8.',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Passo medio', style: t.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<bool>(
                groupValue: mediaConSoste.value,
                onChanged: (v) => salvaAvvisi(conSoste: v),
                child: const Column(
                  children: [
                    RadioListTile(
                      value: false,
                      title: Text('Solo in movimento'),
                      subtitle: Text(
                        'Le soste non contano, anche con la pausa automatica '
                        'spenta: è il passo con cui ti sei mosso.',
                      ),
                    ),
                    RadioListTile(
                      value: true,
                      title: Text('Con le soste'),
                      subtitle: Text(
                        'Distanza diviso tutto il tempo, soste comprese.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            nota(
              'Alla fine il riepilogo mostra comunque tutti e due i tempi: '
              'in movimento e totale.',
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
