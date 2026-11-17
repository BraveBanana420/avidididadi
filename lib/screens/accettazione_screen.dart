import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../pulse.dart';
import '../widgets.dart';
import 'privacy_screen.dart';
import '../l10n/lingua.dart';

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
                            ? l10n.abbiamoAggiornatoRegole
                            : l10n.benvenutoAvidididadi,
                        style: t.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        aggiornati
                            ? l10n.terminiInformativaSonoCambiati
                            : l10n.primaIniziareEccoBreve,
                        style: t.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      punto(
                        Icons.phone_android_rounded,
                        l10n.datiRestanoSulTelefono,
                        l10n.nessunAccountNessunServer,
                      ),
                      punto(
                        Icons.favorite_outline_rounded,
                        l10n.healthConnectSoloLettura,
                        l10n.allenamentiBattitoSonnoPercorsi,
                      ),
                      punto(
                        Icons.gps_fixed_rounded,
                        l10n.gpsSoloDuranteCorsa,
                        l10n.mentreTiAlleniApp,
                      ),
                      punto(
                        Icons.map_rounded,
                        l10n.mappeImmaginiInternet,
                        l10n.openfreemapEsriSatelliteGithub,
                      ),
                      punto(
                        Icons.forum_rounded,
                        l10n.assistenteFacoltativo,
                        l10n.inviaRiassuntoDegliAllenamenti,
                      ),
                      punto(
                        Icons.health_and_safety_rounded,
                        l10n.nonConsiglioMedico,
                        l10n.pianiConsigliSonoStime,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _apri(const TerminiScreen()),
                            icon: const Icon(Icons.gavel_rounded),
                            label: Text(l10n.terminiCondizioni),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _apri(const PrivacyScreen()),
                            icon: const Icon(Icons.privacy_tip_rounded),
                            label: Text(l10n.informativaPrivacy),
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
                            l10n.hoLettoAccettoTermini,
                            style: t.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: PulsantePrincipale(
                          onPressed: accetto ? _entra : null,
                          icona: Icons.arrow_forward_rounded,
                          testo: l10n.entra,
                        ),
                      ),
                      TextButton(
                        onPressed: () => SystemNavigator.pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.onSurfaceVariant,
                        ),
                        child: Text(l10n.nonAccettoEsci),
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
