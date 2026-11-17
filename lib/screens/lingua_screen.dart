import 'package:flutter/material.dart';

import '../l10n/lingua.dart';
import '../pulse.dart';
import '../widgets.dart';

/// Scelta della lingua: al primo avvio (prima dei termini) e dal Profilo.
/// Ogni lingua è scritta nella lingua stessa, così si riconosce subito.
class LinguaScreen extends StatefulWidget {
  /// Al primo avvio non si può tornare indietro senza scegliere.
  final bool primoAvvio;
  const LinguaScreen({super.key, this.primoAvvio = false});

  @override
  State<LinguaScreen> createState() => _LinguaScreenState();
}

class _LinguaScreenState extends State<LinguaScreen> {
  late String scelta = lingua.value ?? linguaDelTelefono();

  @override
  void initState() {
    super.initState();
    // I testi della pagina seguono subito la lingua proposta.
    if (codiceLingua != scelta) usaLingua(scelta);
  }

  void _prova(String codice) {
    setState(() => scelta = codice);
    usaLingua(codice);
    ridisegnaTutto();
  }

  Future<void> _conferma() async {
    final navigator = Navigator.of(context);
    await scegliLingua(scelta);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return PopScope(
      canPop: !widget.primoAvvio,
      child: Scaffold(
        appBar: widget.primoAvvio ? null : AppBar(title: Text(l10n.lingua)),
        bottomNavigationBar: const MargineBarraSistema(),
        body: SfondoPulse(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    children: [
                      if (widget.primoAvvio) ...[
                        const Icon(Icons.translate_rounded, size: 40),
                        const SizedBox(height: 16),
                        Text(l10n.linguaTitolo, style: t.headlineMedium),
                        const SizedBox(height: 6),
                      ],
                      Text(l10n.linguaSpiega, style: t.bodyMedium),
                      const SizedBox(height: 16),
                      Material(
                        type: MaterialType.transparency,
                        child: RadioGroup<String>(
                          groupValue: scelta,
                          onChanged: (v) => _prova(v ?? scelta),
                          child: Column(
                            children: [
                              for (final e in lingueApp.entries)
                                RadioListTile<String>(
                                  value: e.key,
                                  title: Text(e.value, style: t.titleMedium),
                                  contentPadding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: PulsantePrincipale(
                    onPressed: _conferma,
                    icona: Icons.arrow_forward_rounded,
                    testo: l10n.continua,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
