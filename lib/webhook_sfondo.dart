import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'csv.dart';
import 'webhook.dart';

// Invio della coda del webhook ad app chiusa, con WorkManager di Android:
// l'app gli chiede "quando c'è internet, avviami un momento". Parte solo se il
// webhook è acceso e ci sono messaggi in coda; con la coda vuota si cancella.

const _nomeLavoro = 'webhook_coda';
const _compito = 'svuota_coda_webhook';

/// Il punto d'ingresso che Android chiama ad app chiusa. Deve stare fuori da
/// ogni classe, con il pragma, perché lo cerca per nome.
@pragma('vm:entry-point')
void avvioSfondoWebhook() {
  Workmanager().executeTask((compito, _) async {
    if (compito != _compito) return true;
    WidgetsFlutterBinding.ensureInitialized();
    final cartella = await getApplicationDocumentsDirectory();
    final rimasti = await svuotaCodaDa(cartella);
    // false = "non ho finito": Android ritenta da solo, sempre con la rete.
    return rimasti == 0;
  });
}

/// Svuota la coda leggendo impostazioni e segreti dalla cartella. Restituisce
/// quanti messaggi restano (0 anche se il webhook è spento: non c'è niente da
/// ritentare).
Future<int> svuotaCodaDa(Directory cartella) async {
  final f = File('${cartella.path}/$fileImpostazioniWebhook');
  final imp = ImpostazioniWebhook.da(
    await f.exists() ? Tabella.da(await f.readAsString()) : null,
  );
  final url = await SegretiWebhook.url();
  if (!imp.attivo || url == null) return 0;
  final client = http.Client();
  try {
    final r = await CodaWebhook(
      cartella,
    ).svuota(client: client, url: url, chiave: await SegretiWebhook.chiave());
    return r.rimasti;
  } finally {
    client.close();
  }
}

/// Prepara WorkManager all'avvio dell'app. Non deve mai fermare l'avvio.
Future<void> preparaSfondoWebhook() async {
  try {
    await Workmanager().initialize(avvioSfondoWebhook);
  } catch (_) {
    // Nei test e senza il plugin: l'invio ad app aperta funziona lo stesso.
  }
}

/// Chiede ad Android di ritentare appena c'è rete, non prima di [quando].
Future<void> pianificaSfondoWebhook(DateTime? quando) async {
  final attesa = quando == null
      ? Duration.zero
      : quando.difference(DateTime.now());
  try {
    await Workmanager().registerOneOffTask(
      _nomeLavoro,
      _compito,
      initialDelay: attesa.isNegative ? Duration.zero : attesa,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
    );
  } catch (_) {}
}

/// Niente più da mandare: il lavoro in attesa si toglie.
Future<void> annullaSfondoWebhook() async {
  try {
    await Workmanager().cancelByUniqueName(_nomeLavoro);
  } catch (_) {}
}
