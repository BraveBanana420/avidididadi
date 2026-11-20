import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../avviso.dart';
import '../models.dart';
import '../pulse.dart';
import '../webhook.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';

/// La riga in "Dati e collegamenti" (funzioni avanzate): apre la pagina.
class SezioneWebhook extends StatelessWidget {
  final AppState state;
  const SezioneWebhook({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => SuperficiePulse(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => WebhookScreen(state: state)),
        ),
        child: Row(
          children: [
            const Icon(Icons.webhook_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.webhookTitolo, style: t.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    state.webhook.attivo
                        ? l10n.webhookAcceso
                        : l10n.webhookSottotitolo,
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
            if (state.webhook.attivo)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

/// Testo di un errore senza risposta HTTP ('timeout', 'rete'…).
String testoErroreWebhook(int codice, String tipo) => codice > 0
    ? l10n.webhookCodiceHttp(codice)
    : switch (tipo) {
        'timeout' => l10n.webhookErroreTimeout,
        'rete' => l10n.webhookErroreRete,
        'scaduto' => l10n.webhookErroreScaduto,
        _ => l10n.webhookErroreAltro,
      };

/// Chiede quali allenamenti mandare. Null se si chiude senza scegliere.
Future<String?> scegliOriginiWebhook(BuildContext context, int quanti) =>
    showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.webhookSceltaTitolo),
        content: Text(l10n.webhookSceltaTesto(quanti)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, origineTutti),
            child: Text(l10n.webhookTutti),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, origineApp),
            child: Text(l10n.webhookSoloApp),
          ),
        ],
      ),
    );

/// Le impostazioni del webhook: interruttore, indirizzo, chiave, eventi,
/// test e stato degli invii.
class WebhookScreen extends StatefulWidget {
  final AppState state;
  const WebhookScreen({super.key, required this.state});

  @override
  State<WebhookScreen> createState() => _WebhookScreenState();
}

class _WebhookScreenState extends State<WebhookScreen> {
  final _url = TextEditingController();
  final _chiave = TextEditingController();
  bool _mostraChiave = false;
  bool _urlSbagliato = false;
  bool _inCorso = false;
  String? _esitoTest;
  bool _esitoOk = false;

  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final url = await SegretiWebhook.url();
    final chiave = await SegretiWebhook.chiave();
    if (!mounted) return;
    setState(() {
      _url.text = url ?? '';
      _chiave.text = chiave ?? '';
    });
  }

  @override
  void dispose() {
    _url.dispose();
    _chiave.dispose();
    super.dispose();
  }

  void _avviso(String testo) =>
      ScaffoldMessenger.of(context).showSnackBar(avviso(content: Text(testo)));

  /// Controlla l'indirizzo; se va bene salva indirizzo e chiave.
  Future<bool> _salva({bool avvisa = true}) async {
    if (!urlWebhookValido(_url.text)) {
      setState(() => _urlSbagliato = true);
      _avviso(l10n.webhookPrimaUrl);
      return false;
    }
    await state.salvaSegretiWebhook(_url.text, _chiave.text);
    if (!mounted) return false;
    if (avvisa) _avviso(l10n.webhookSalvato);
    if (state.webhook.attivo) await state.svuotaCodaWebhook();
    return true;
  }

  Future<void> _accendi(bool acceso) async {
    if (!acceso) {
      await state.impostaWebhook(state.webhook.copyWith(attivo: false));
      return;
    }
    if (!await _salva(avvisa: false) || !mounted) return;
    var origini = state.webhook.origini;
    // La prima volta: solo gli allenamenti dell'app, o anche quelli importati.
    if (origini.isEmpty) {
      final scelta = await scegliOriginiWebhook(
        context,
        state.allenamentiDaMandareWebhook,
      );
      if (scelta == null) return;
      origini = scelta;
    }
    await state.impostaWebhook(
      state.webhook.copyWith(attivo: true, origini: origini),
    );
  }

  Future<void> _cambiaOrigini() async {
    final scelta = await scegliOriginiWebhook(
      context,
      state.allenamentiDaMandareWebhook,
    );
    if (scelta == null) return;
    await state.impostaWebhook(state.webhook.copyWith(origini: scelta));
  }

  Future<void> _evento(String evento, bool acceso) => state.impostaWebhook(
    state.webhook.copyWith(
      eventi: acceso
          ? {...state.webhook.eventi, evento}
          : ({...state.webhook.eventi}..remove(evento)),
    ),
  );

  Future<void> _test() async {
    if (!urlWebhookValido(_url.text)) {
      setState(() => _urlSbagliato = true);
      return;
    }
    setState(() {
      _inCorso = true;
      _esitoTest = null;
    });
    final e = await state.inviaTestWebhook(_url.text, _chiave.text);
    if (!mounted) return;
    setState(() {
      _inCorso = false;
      _esitoOk = e.riuscito;
      _esitoTest = e.riuscito
          ? l10n.webhookTestOk(e.codice)
          : l10n.webhookTestErrore(testoErroreWebhook(e.codice, e.errore));
    });
  }

  Future<void> _copiaChiave() async {
    await Clipboard.setData(ClipboardData(text: _chiave.text));
    if (mounted) _avviso(l10n.webhookChiaveCopiata);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(l10n.webhookTitolo)),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final w = state.webhook;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.webhookSpiegazione, style: t.bodyMedium),
              const SizedBox(height: 12),
              SuperficiePulse(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.webhookAttivo),
                        subtitle: w.attivo
                            ? null
                            : Text(l10n.webhookSpento, style: t.bodySmall),
                        value: w.attivo,
                        onChanged: _accendi,
                      ),
                    ),
                    TextField(
                      controller: _url,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: l10n.webhookIndirizzo,
                        hintText: 'https://',
                        errorText: _urlSbagliato
                            ? l10n.webhookUrlNonValido
                            : null,
                        errorMaxLines: 2,
                      ),
                      onChanged: (v) {
                        if (_urlSbagliato && urlWebhookValido(v)) {
                          setState(() => _urlSbagliato = false);
                        }
                      },
                    ),
                    TextField(
                      controller: _chiave,
                      obscureText: !_mostraChiave,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: l10n.webhookChiave,
                        helperText: l10n.webhookChiaveAiuto,
                        helperMaxLines: 3,
                        suffixIcon: IconButton(
                          tooltip: l10n.webhookMostraChiave,
                          icon: Icon(
                            _mostraChiave
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () =>
                              setState(() => _mostraChiave = !_mostraChiave),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _chiave.text = generaChiaveWebhook();
                            _mostraChiave = true;
                          }),
                          icon: const Icon(Icons.key_rounded),
                          label: Text(l10n.webhookGenera),
                        ),
                        OutlinedButton.icon(
                          onPressed: _copiaChiave,
                          icon: const Icon(Icons.copy_rounded),
                          label: Text(l10n.webhookCopia),
                        ),
                        FilledButton.icon(
                          onPressed: _salva,
                          icon: const Icon(Icons.save_rounded),
                          label: Text(l10n.webhookSalva),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TitoloSezione(l10n.webhookCosaInviare),
              Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    for (final (evento, titolo, sotto) in [
                      (
                        eventoAllenamento,
                        l10n.webhookEventoAllenamento,
                        l10n.webhookEventoAllenamentoSotto,
                      ),
                      (
                        eventoPiano,
                        l10n.webhookEventoPiano,
                        l10n.webhookEventoPianoSotto,
                      ),
                      (
                        eventoRecord,
                        l10n.webhookEventoRecord,
                        l10n.webhookEventoRecordSotto,
                      ),
                    ])
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(titolo),
                        subtitle: Text(sotto, style: t.bodySmall),
                        value: w.eventi.contains(evento),
                        onChanged: (v) => _evento(evento, v ?? false),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.webhookQualiAllenamenti),
                      subtitle: Text(
                        w.origini == origineTutti
                            ? l10n.webhookTutti
                            : l10n.webhookSoloApp,
                        style: t.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _cambiaOrigini,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _inCorso ? null : _test,
                icon: _inCorso
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(l10n.webhookInviaTest),
              ),
              if (_esitoTest != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        _esitoOk
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        size: 18,
                        color: _esitoOk ? scheme.primary : scheme.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(_esitoTest!, style: t.bodySmall)),
                    ],
                  ),
                ),
              TitoloSezione(l10n.webhookStato),
              ..._stato(context),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: Text(l10n.webhookComeFunziona),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Text(l10n.webhookComeFunzionaTesto, style: t.bodySmall),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _stato(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = state.statoWebhook;
    final ok = s.ultimoOk;
    final err = s.ultimoErrore;
    return [
      Text(
        ok == null
            ? l10n.webhookMaiInviato
            : l10n.webhookUltimoOk(dataLunga(ok), two(ok.hour), two(ok.minute)),
        style: t.bodySmall,
      ),
      // L'errore conta solo se è dopo l'ultimo invio riuscito.
      if (err != null && (ok == null || err.isAfter(ok)))
        Text(
          l10n.webhookUltimoErrore(
            dataLunga(err),
            two(err.hour),
            two(err.minute),
            testoErroreWebhook(s.codiceErrore, s.tipoErrore),
          ),
          style: t.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      Text(l10n.webhookInCoda(state.codaWebhook), style: t.bodySmall),
      if (s.scartati > 0)
        Text(l10n.webhookScartati(s.scartati), style: t.bodySmall),
    ];
  }
}
