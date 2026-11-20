import 'package:flutter/material.dart';

import '../models.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';

/// Versione di Termini e informativa: se cambia, all'apertura si chiede di
/// accettarli di nuovo.
const versioneTermini = '2026-11-15.1';
final aggiornamentoTermini = DateTime(2026, 11, 15);

/// Una pagina di testo a sezioni (informativa, termini).
class PaginaTesto extends StatelessWidget {
  final String titolo;
  final String? introduzione;
  final List<(String, String)> sezioni;
  const PaginaTesto({
    super.key,
    required this.titolo,
    this.introduzione,
    required this.sezioni,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(titolo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.ultimoAggiornamento(
              '${aggiornamentoTermini.day} ${mesiNomi[aggiornamentoTermini.month - 1]} ${aggiornamentoTermini.year}',
            ),
            style: t.bodySmall,
          ),
          if (introduzione != null) ...[
            const SizedBox(height: 8),
            Text(introduzione!),
          ],
          const SizedBox(height: 16),
          for (final (titolo, testo) in sezioni)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titolo, style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text(testo),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Informativa sull'uso dei dati. Health Connect la apre quando l'utente
/// chiede perché l'app vuole accedere ai dati.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginaTesto(
    titolo: l10n.privacyUsoDeiDati,
    introduzione: l10n.breveTuoiDatiRestano,
    sezioni: [
      (l10n.datiInserisciTu, l10n.nomeDataNascitaSesso),
      (l10n.datiLettiHealthConnect, l10n.tuoPermessoAppLegge),
      (l10n.percorsiGpsDelleSessioni, l10n.seAppHaRegistrato),
      (l10n.posizioneDuranteAllenamento, l10n.soloCorsaCamminataBici),
      (l10n.passiDuranteAllenamento, l10n.soloCorsaCamminataPassi),
      (l10n.sensoriBluetoothBattitoBici, l10n.soloSeScegliTu),
      (l10n.mappe, l10n.disegnareMappaAppScarica),
      (l10n.intervalsIcuFacoltativo, l10n.seColleghiIntervalsIcu),
      (l10n.webhookFacoltativo, l10n.webhookPrivacy),
      (l10n.immaginiDegliEsercizi, l10n.fotoDegliEserciziVengono),
      (l10n.assistenteFacoltativo2, l10n.soloSeAttiviTu),
      (l10n.assistenteNellaTuaApp, l10n.seColleghiAppTuo),
      (l10n.widgetSullaSchermataHome, l10n.seAggiungiWidgetSeduta),
      (l10n.doveRestanoDati, l10n.nellaCartellaPrivataDell),
      (l10n.backup, l10n.fileBackupCreiContiene),
      (l10n.permessiTelefono, l10n.healthConnectLetturaDei),
      (l10n.comeRevocareOCancellare, l10n.healthConnectImpostazioniHealth),
      (l10n.modifiche, l10n.seQuestaInformativaCambia),
    ],
  );
}

/// Termini e condizioni d'uso.
class TerminiScreen extends StatelessWidget {
  const TerminiScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginaTesto(
    titolo: l10n.terminiCondizioni,
    sezioni: [
      (l10n.cosAvidididadi, l10n.appPersonalePianificareSeguire),
      (l10n.nonConsiglioMedico, l10n.pianiCarichiZoneFrequenza),
      (l10n.allenatiSicurezza, l10n.tiAlleniSottoTua),
      (l10n.precisioneDeiDati, l10n.gpsDistanzeRitmoPassi),
      (l10n.serviziTerzi, l10n.alcuneFunzioniUsanoServizi),
      (l10n.tuoiDati, l10n.datiRestanoSulTuo),
      (l10n.nessunaGaranzia, l10n.appFornitaCosiCom),
      (l10n.modifiche, l10n.questiTerminiPossonoEssere),
    ],
  );
}
