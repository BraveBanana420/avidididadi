import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../aggiornamento.dart';
import '../avviso.dart';
import '../l10n/lingua.dart';

/// Cerca subito un aggiornamento (dal Profilo) e dice com'è andata.
Future<void> cercaAggiornamentoOra(BuildContext context) async {
  final messaggi = ScaffoldMessenger.of(context);
  final (esito, r) = await cercaAggiornamento(forza: true);
  if (!context.mounted) return;
  switch (esito) {
    case EsitoRicerca.nuova:
      await proponiAggiornamento(context, r!);
    case EsitoRicerca.ultima:
      final versione = (await PackageInfo.fromPlatform()).version;
      messaggi.showSnackBar(
        avviso(content: Text(l10n.haiUltimaVersione(versione))),
      );
    case EsitoRicerca.nessunaRisposta:
      messaggi.showSnackBar(avviso(content: Text(l10n.githubNonRisponde)));
  }
}

/// L'avviso della versione nuova: si chiude con "Più tardi" (ricompare il
/// giorno dopo) o parte con "Aggiorna".
Future<void> proponiAggiornamento(BuildContext context, Rilascio r) async {
  final t = Theme.of(context).textTheme;
  final aggiorna = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      icon: const Icon(Icons.system_update_rounded),
      title: Text(l10n.nuovaVersione(r.versione)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.aggiornamentoSpiegazione),
              if (r.novita.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.novitaVersione, style: t.titleSmall),
                const SizedBox(height: 4),
                for (final n in r.novita)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(n, style: t.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(l10n.piuTardi),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(l10n.aggiornaApp),
        ),
      ],
    ),
  );
  if (aggiorna == true && context.mounted) await _scaricaEInstalla(context, r);
}

/// Scarica con la barra di avanzamento (si può annullare), poi passa l'APK
/// all'installatore di Android.
Future<void> _scaricaEInstalla(BuildContext context, Rilascio r) async {
  final messaggi = ScaffoldMessenger.of(context);
  final navigatore = Navigator.of(context);
  final scarico = Scarico();
  final parte = ValueNotifier<double?>(null);
  var aperto = true;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (c) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.scaricoAggiornamento),
        content: ValueListenableBuilder<double?>(
          valueListenable: parte,
          builder: (_, v, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: v),
              if (v != null) ...[
                const SizedBox(height: 8),
                Text('${(v * 100).round()}%', textAlign: TextAlign.end),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: scarico.annulla, child: Text(l10n.annulla)),
        ],
      ),
    ),
  ).whenComplete(() => aperto = false);

  final (apk, errore) = await scaricaApk(
    r,
    scarico,
    avanzamento: (v) => parte.value = v,
  );
  if (aperto) navigatore.pop();
  parte.dispose();

  String? messaggio = switch (errore) {
    ErroreScarico.rete => l10n.aggiornamentoRete,
    ErroreScarico.impronta => l10n.aggiornamentoImpronta,
    ErroreScarico.annullato => l10n.aggiornamentoAnnullato,
    null => null,
  };
  if (apk != null) {
    messaggio = switch (await installaApk(apk)) {
      EsitoInstallazione.avviata => null,
      EsitoInstallazione.permessoNegato => l10n.aggiornamentoPermesso,
      EsitoInstallazione.errore => l10n.aggiornamentoErrore,
    };
  }
  if (messaggio != null) {
    messaggi.showSnackBar(avviso(content: Text(messaggio)));
  }
}

/// Testo dell'avviso per l'esito dell'installatore di Android.
String? testoEsitoInstallazione(String esito) => switch (esito) {
  'annullato' => l10n.aggiornamentoAnnullato,
  'errore' => l10n.aggiornamentoErrore,
  _ => null,
};
