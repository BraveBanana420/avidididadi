import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../pulse.dart';
import '../widgets.dart';
import 'privacy_screen.dart';

/// Prima di entrare nell'app: cosa fa con i dati, in breve, e la spunta
/// obbligatoria per accettare termini e informativa. Non si può saltare.
class AccettazioneScreen extends StatefulWidget {
  final AppState state;
  const AccettazioneScreen({super.key, required this.state});

  @override
  State<AccettazioneScreen> createState() => _AccettazioneScreenState();
}

class _AccettazioneScreenState extends State<AccettazioneScreen> {
  bool accetto = false;

  // Già accettata una versione precedente: sono cambiati.
  bool get aggiornati => widget.state.profilo.terminiAccettati.isNotEmpty;

  Future<void> _entra() async {
    final navigator = Navigator.of(context);
    await widget.state.accettaTermini(versioneTermini);
    navigator.pop();
  }

  void _apri(Widget pagina) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => pagina));

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    Widget punto(IconData icona, String titolo, String testo) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconaQuadrata(icona),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titolo, style: t.titleSmall),
                Text(testo, style: t.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        bottomNavigationBar: const MargineBarraSistema(),
        body: SfondoPulse(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    children: [
                      Text(
                        aggiornati
                            ? 'Abbiamo aggiornato le regole'
                            : 'Benvenuto in Avidididadi',
                        style: t.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        aggiornati
                            ? 'Termini e informativa sono cambiati. Leggili e accettali per '
                                  'continuare.'
                            : 'Prima di iniziare, ecco in breve come funziona '
                                  "l'app con i tuoi dati.",
                        style: t.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      punto(
                        Icons.phone_android,
                        'I dati restano sul telefono',
                        "Nessun account, nessun server, nessuna pubblicità.",
                      ),
                      punto(
                        Icons.favorite_outline,
                        'Health Connect solo in lettura',
                        'Allenamenti, battito, sonno e percorsi delle tue app '
                            '(es. Garmin), solo se lo permetti.',
                      ),
                      punto(
                        Icons.gps_fixed,
                        'GPS solo durante corsa e bici',
                        "Mentre ti alleni con l'app, con una notifica fissa. "
                            'Mai in altri momenti.',
                      ),
                      punto(
                        Icons.map_outlined,
                        'Mappe e immagini da internet',
                        'Scaricate da OpenFreeMap e GitHub: il percorso non '
                            'viene inviato.',
                      ),
                      punto(
                        Icons.forum_outlined,
                        'Assistente facoltativo',
                        'Invia un riassunto degli allenamenti al servizio che '
                            'scegli, solo se lo attivi tu.',
                      ),
                      punto(
                        Icons.health_and_safety_outlined,
                        'Non è un consiglio medico',
                        'Piani e consigli sono stime: in caso di dubbi o '
                            'problemi di salute, chiedi al medico.',
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _apri(const TerminiScreen()),
                            icon: const Icon(Icons.gavel_outlined),
                            label: const Text('Termini e condizioni'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _apri(const PrivacyScreen()),
                            icon: const Icon(Icons.privacy_tip_outlined),
                            label: const Text('Informativa privacy'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 20, 16),
                  child: Column(
                    children: [
                      // Material: il tocco si vede anche sopra lo sfondo Pulse.
                      Material(
                        type: MaterialType.transparency,
                        child: CheckboxListTile(
                          value: accetto,
                          onChanged: (v) =>
                              setState(() => accetto = v ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Ho letto e accetto i Termini e condizioni e '
                            "l'Informativa sulla privacy",
                            style: t.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: PulsantePrincipale(
                          onPressed: accetto ? _entra : null,
                          icona: Icons.arrow_forward,
                          testo: 'Entra',
                        ),
                      ),
                      TextButton(
                        onPressed: () => SystemNavigator.pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.onSurfaceVariant,
                        ),
                        child: const Text('Non accetto, esci'),
                      ),
                    ],
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
