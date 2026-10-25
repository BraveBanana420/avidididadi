import 'package:flutter/material.dart';

import '../app_state.dart';
import '../assistente.dart';
import '../llm.dart';
import '../widgets.dart';
import 'agente_screen.dart';
import 'privacy_screen.dart';
import 'testo_formattato.dart';

const _suggerimenti = [
  "Com'è andata questa settimana?",
  'Giovedì ho poco tempo: cosa sposto?',
  'Adatta i prossimi giorni al mio recupero',
  'Sono pronto per la gara?',
];

/// Pagina dell'assistente: chat con il modello scelto dall'utente. Le modifiche
/// al piano proposte si applicano solo con un tocco su "Applica".
class AssistenteScreen extends StatefulWidget {
  final AppState state;
  const AssistenteScreen({super.key, required this.state});

  @override
  State<AssistenteScreen> createState() => _AssistenteScreenState();
}

class _AssistenteScreenState extends State<AssistenteScreen> {
  final _testo = TextEditingController();
  final _scorri = ScrollController();
  late Future<bool> _pronto = _controlla();

  Future<bool> _controlla() async {
    final state = widget.state;
    final c = state.assistente;
    if (c.esterno) return true; // il coach è nell'app dell'assistente
    if (!c.consenso) return false;
    if (serveChiave(c.fornitore)) {
      return await ChiaviAssistente.leggi(c.fornitore) != null;
    }
    // Con Ollama la verifica è gratis: si fa da sola a ogni apertura.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => state.verificaAssistente(),
    );
    return true;
  }

  @override
  void dispose() {
    _testo.dispose();
    _scorri.dispose();
    super.dispose();
  }

  Future<void> _impostazioni() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImpostazioniAssistenteScreen(state: widget.state),
      ),
    );
    if (mounted) setState(() => _pronto = _controlla());
  }

  Future<void> _invia([String? testo]) async {
    final t = (testo ?? _testo.text).trim();
    if (t.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    _testo.clear();
    _inFondo();
    final errore = await widget.state.chiediAllAssistente(t);
    if (!mounted) return;
    if (errore != null) {
      _testo.text = t; // il messaggio non è andato: si può riprovare
      messenger.showSnackBar(
        SnackBar(content: Text(errore), duration: const Duration(seconds: 8)),
      );
    }
    _inFondo();
  }

  void _inFondo() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scorri.hasClients) {
      _scorri.animateTo(
        _scorri.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final t = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => FutureBuilder<bool>(
          future: _pronto,
          builder: (context, snap) {
            final pronto = snap.data == true;
            final esterno = state.assistente.esterno;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Assistente', style: t.titleLarge),
                            if (esterno)
                              Text(
                                'Collegato a ${state.assistente.appEsterna}',
                                style: t.bodySmall,
                              )
                            else if (pronto)
                              StatoAssistente(state: state),
                          ],
                        ),
                      ),
                      if (pronto && !esterno && state.chat.isNotEmpty)
                        IconButton(
                          tooltip: 'Nuova conversazione',
                          onPressed: state.assistenteInAttesa
                              ? null
                              : state.nuovaChat,
                          icon: const Icon(Icons.add_comment_outlined),
                        ),
                      IconButton(
                        tooltip: 'Impostazioni assistente',
                        onPressed: _impostazioni,
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: !snap.hasData
                      ? const SizedBox.shrink()
                      : esterno
                      ? PannelloAgente(state: state)
                      : !pronto
                      ? _Presentazione(onConfigura: _impostazioni)
                      : _conversazione(state),
                ),
                if (pronto && !esterno) _barraInvio(state),
                // Sotto, lo spazio della barra fluttuante (se la tastiera è
                // chiusa: aperta, la copre comunque).
                SizedBox(
                  height: MediaQuery.viewInsetsOf(context).bottom > 0
                      ? 0
                      : MediaQuery.paddingOf(context).bottom,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _conversazione(AppState state) {
    final t = Theme.of(context).textTheme;
    if (state.chat.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Chiedimi dei tuoi allenamenti: vedo le ultime 4 settimane, i "
            "feedback, il recupero e il piano dei prossimi 14 giorni. Se propongo "
            "di cambiare il piano, decidi tu se applicare.",
            style: t.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _suggerimenti)
                ActionChip(label: Text(s), onPressed: () => _invia(s)),
            ],
          ),
        ],
      );
    }
    return ListView(
      controller: _scorri,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      children: [
        for (final m in state.chat) _Fumetto(state: state, messaggio: m),
        if (state.assistenteInAttesa)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Sto pensando…'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _barraInvio(AppState state) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _testo,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Scrivi un messaggio',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => _invia(),
          ),
        ),
        IconButton(
          tooltip: 'Invia',
          onPressed: state.assistenteInAttesa ? null : _invia,
          icon: const Icon(Icons.send),
        ),
      ],
    ),
  );
}

class _Presentazione extends StatelessWidget {
  final VoidCallback onConfigura;
  const _Presentazione({required this.onConfigura});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Un allenatore con cui parlare dei tuoi allenamenti, che può proporre '
          'modifiche al piano. Usi il modello che preferisci:',
          style: t.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final f in Fornitore.values)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              f == Fornitore.ollama ? Icons.computer : Icons.cloud_outlined,
            ),
            title: Text(nomiFornitori[f]!),
            subtitle: Text(descrizioniFornitori[f]!),
          ),
        const SizedBox(height: 8),
        Text(
          'È facoltativo: senza assistente l\'app funziona come sempre.',
          style: t.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onConfigura,
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Configura assistente'),
        ),
      ],
    );
  }
}

class _Fumetto extends StatelessWidget {
  final AppState state;
  final MessaggioChat messaggio;
  const _Fumetto({required this.state, required this.messaggio});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final m = messaggio;
    return Align(
      alignment: m.utente ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        child: Column(
          crossAxisAlignment: m.utente
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: m.utente
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              // Le risposte dell'assistente con grassetti, titoli ed elenchi.
              child: m.utente
                  ? SelectableText(
                      m.testo,
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    )
                  : TestoFormattato(m.testo, colore: scheme.onSurface),
            ),
            if (m.proposta != null) SchedaProposta(state: state, messaggio: m),
          ],
        ),
      ),
    );
  }
}

/// Le modifiche proposte, già controllate: prima → dopo, quelle scartate col
/// motivo, e il pulsante per applicarle.
class SchedaProposta extends StatelessWidget {
  final AppState state;
  final MessaggioChat messaggio;
  const SchedaProposta({
    super.key,
    required this.state,
    required this.messaggio,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final esito = valutaProposta(
      state.piano,
      messaggio.proposta!,
      DateTime.now(),
    );
    return Card(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modifiche proposte al piano', style: t.titleSmall),
            const SizedBox(height: 6),
            if (messaggio.applicata)
              const Text('Applicate al piano.')
            else ...[
              for (final m in esito.accettate) ...[
                Text('• ${descriviModifica(m, state.piano)}'),
                if (m.motivo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(m.motivo, style: t.bodySmall),
                  ),
              ],
              if (esito.scartate.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Non applicabili',
                  style: t.labelLarge?.copyWith(color: scheme.primary),
                ),
                for (final (m, motivo) in esito.scartate)
                  Text(
                    '• ${descriviModifica(m, state.piano)}: $motivo',
                    style: t.bodySmall,
                  ),
              ],
              const SizedBox(height: 8),
              if (esito.accettate.isNotEmpty)
                FilledButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final n = await state.applicaProposta(messaggio);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          n == 0
                              ? 'Niente da applicare: il piano è cambiato nel frattempo.'
                              : 'Piano aggiornato: $n modifiche. Le vedi nel calendario.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: Text('Applica ${esito.accettate.length} modifiche'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Scelta del fornitore, chiave API, modello e consenso all'invio dei dati.
class ImpostazioniAssistenteScreen extends StatefulWidget {
  final AppState state;
  const ImpostazioniAssistenteScreen({super.key, required this.state});

  @override
  State<ImpostazioniAssistenteScreen> createState() =>
      _ImpostazioniAssistenteScreenState();
}

class _ImpostazioniAssistenteScreenState
    extends State<ImpostazioniAssistenteScreen> {
  ConfigAssistente get c => widget.state.assistente;
  late final _modello = TextEditingController(text: c.modelli[c.fornitore]);
  late final _url = TextEditingController(text: c.urlOllama);
  final _chiave = TextEditingController();
  String? chiaveSalvata;

  @override
  void initState() {
    super.initState();
    _leggiChiave();
  }

  @override
  void dispose() {
    _modello.dispose();
    _url.dispose();
    _chiave.dispose();
    super.dispose();
  }

  Future<void> _leggiChiave() async {
    final k = await ChiaviAssistente.leggi(c.fornitore);
    if (mounted) setState(() => chiaveSalvata = k);
  }

  /// Copia nei campi di configurazione quello che è scritto nei campi di testo.
  void _raccogli() {
    final m = _modello.text.trim();
    if (m.isEmpty) {
      c.modelli.remove(c.fornitore);
    } else {
      c.modelli[c.fornitore] = m;
    }
    if (_url.text.trim().isNotEmpty) c.urlOllama = _url.text.trim();
  }

  Future<void> _salva() async {
    _raccogli();
    await widget.state.salvaAssistente();
  }

  Future<void> _cambiaFornitore(Fornitore f) async {
    _raccogli();
    widget.state.connessioneDaVerificare();
    setState(() {
      c.fornitore = f;
      _modello.text = c.modelli[f] ?? '';
      _chiave.clear();
      chiaveSalvata = null;
    });
    await _salva();
    await _leggiChiave();
  }

  Future<void> _salvaChiave() async {
    final k = _chiave.text.trim();
    if (k.isEmpty) return;
    await ChiaviAssistente.salva(c.fornitore, k);
    widget.state.connessioneDaVerificare();
    _chiave.clear();
    await _leggiChiave();
  }

  Future<void> _eliminaChiave() async {
    await ChiaviAssistente.elimina(c.fornitore);
    await _leggiChiave();
  }

  /// Elenco dei modelli che la chiave può usare: un tocco sceglie.
  Future<void> _scegliModello() async {
    final messenger = ScaffoldMessenger.of(context);
    _raccogli();
    final List<String> modelli;
    try {
      modelli = await modelliDisponibili(
        c,
        await ChiaviAssistente.leggi(c.fornitore),
      );
    } on ErroreLlm catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.messaggio)));
      return;
    }
    if (!mounted) return;
    if (modelli.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Nessun modello disponibile con questa chiave.'),
        ),
      );
      return;
    }
    final consigliato = modelloConsigliato(c.fornitore, modelli);
    final ordinati = [
      ?consigliato,
      for (final m in modelli..sort())
        if (m != consigliato) m,
    ];
    final scelto = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final m in ordinati)
              ListTile(
                title: Text(m),
                subtitle: m == consigliato ? const Text('Consigliato') : null,
                leading: Icon(
                  m == consigliato ? Icons.star : Icons.smart_toy_outlined,
                ),
                onTap: () => Navigator.pop(c, m),
              ),
          ],
        ),
      ),
    );
    if (scelto == null || !mounted) return;
    setState(() => _modello.text = scelto);
    widget.state.connessioneDaVerificare();
    await _prova();
  }

  Future<void> _prova() async {
    _raccogli();
    await widget.state.salvaAssistente();
    await widget.state.verificaAssistente();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final f = c.fornitore;
    final finale = chiaveSalvata == null || chiaveSalvata!.length < 4
        ? ''
        : chiaveSalvata!.substring(chiaveSalvata!.length - 4);
    return PopScope(
      onPopInvokedWithResult: (_, _) => _salva(),
      child: Scaffold(
        bottomNavigationBar: const MargineBarraSistema(),
        appBar: AppBar(title: const Text('Impostazioni assistente')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Il coach nell'app dell'assistente (abbonamento, niente chiave).
            Card(
              child: c.esterno
                  ? ListTile(
                      leading: const Icon(Icons.link),
                      title: Text('Collegato a ${c.appEsterna}'),
                      subtitle: const Text(
                        'Il coach è nella sua app. Scollega dalla pagina '
                        'Coach per tornare al servizio qui sotto.',
                      ),
                    )
                  : ListTile(
                      leading: const Icon(Icons.forum_outlined),
                      title: const Text(
                        'Usa il tuo abbonamento (Claude, ChatGPT, Gemini…)',
                      ),
                      subtitle: const Text(
                        "Senza chiave API: parli con il coach nell'app del "
                        'tuo assistente.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CollegaAgenteScreen(state: widget.state),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              c.esterno ? "Coach nell'app (quando scolleghi)" : 'Servizio',
              style: t.titleLarge,
            ),
            Card(
              child: RadioGroup<Fornitore>(
                groupValue: f,
                onChanged: (v) => v == null ? null : _cambiaFornitore(v),
                child: Column(
                  children: [
                    for (final x in Fornitore.values)
                      RadioListTile<Fornitore>(
                        value: x,
                        title: Text(nomiFornitori[x]!),
                        subtitle: Text(descrizioniFornitori[x]!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (serveChiave(f)) ...[
              Text('Chiave API', style: t.titleLarge),
              const SizedBox(height: 4),
              if (chiaveSalvata != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.key),
                    title: Text('Chiave salvata ••••$finale'),
                    subtitle: const Text('Cifrata sul telefono.'),
                    trailing: TextButton(
                      onPressed: _eliminaChiave,
                      child: const Text('Elimina'),
                    ),
                  ),
                )
              else ...[
                TextField(
                  controller: _chiave,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Incolla la chiave API',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _salvaChiave,
                  child: const Text('Salva chiave'),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Si paga a consumo sul tuo account: una domanda costa di '
                  'solito pochi centesimi o meno. Puoi impostare un limite di '
                  'spesa sul sito del servizio.',
                  style: t.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text('Indirizzo di Ollama', style: t.titleLarge),
              const SizedBox(height: 4),
              TextField(
                controller: _url,
                onChanged: (_) => widget.state.connessioneDaVerificare(),
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Indirizzo del PC',
                  hintText: 'http://192.168.1.10:11434',
                  border: OutlineInputBorder(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Sul PC: installa Ollama, scarica un modello (ollama pull '
                  'llama3.1) e avvialo con OLLAMA_HOST=0.0.0.0 così il telefono '
                  'lo raggiunge. L\'indirizzo IP del PC lo trovi con "ipconfig".',
                  style: t.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('Modello', style: t.titleLarge),
            const SizedBox(height: 4),
            TextField(
              controller: _modello,
              onChanged: (_) => widget.state.connessioneDaVerificare(),
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Nome del modello',
                hintText: modelliPredefiniti[f],
                helperText: 'Vuoto = il più adatto tra quelli disponibili',
                border: const OutlineInputBorder(),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _scegliModello,
                icon: const Icon(Icons.list_alt),
                label: const Text('Scegli tra i modelli disponibili'),
              ),
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: widget.state,
              builder: (context, _) =>
                  RiquadroConnessione(state: widget.state, onProva: _prova),
            ),
            const SizedBox(height: 20),
            Text('Dati inviati', style: t.titleLarge),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Includi età, sesso, altezza e peso'),
              subtitle: const Text('Nome e foto non vengono mai inviati.'),
              value: c.datiPersonali,
              onChanged: (v) => setState(() => c.datiPersonali = v),
            ),
            Card(
              child: ExpansionTile(
                title: const Text('Vedi esattamente cosa viene inviato'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  SelectableText(
                    widget.state.contestoAssistente,
                    style: t.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: c.consenso,
              onChanged: (v) => setState(
                () => v == true ? c.consensi.add(f) : c.consensi.remove(f),
              ),
              title: Text(
                f == Fornitore.ollama
                    ? 'Acconsento a inviare questi dati al mio PC con Ollama'
                    : 'Acconsento a inviare questi dati a ${nomiFornitori[f]} '
                          'a ogni messaggio',
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
              child: const Text('Privacy e uso dei dati'),
            ),
          ],
        ),
      ),
    );
  }
}

String _nomeBreve(Fornitore f) => switch (f) {
  Fornitore.claude => 'Claude',
  Fornitore.openai => 'GPT',
  Fornitore.gemini => 'Gemini',
  Fornitore.ollama => 'Ollama',
};

/// Riga di stato sotto il titolo: servizio, modello e se risponde. Forma
/// dell'icona diversa per ogni stato, non solo il colore.
class StatoAssistente extends StatelessWidget {
  final AppState state;
  const StatoAssistente({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final c = state.assistente;
    final nome = _nomeBreve(c.fornitore);
    final (icona, testo, colore) = switch (state.connessione) {
      StatoConnessione.connesso => (
        Icons.check_circle,
        '$nome connesso',
        scheme.onSurface,
      ),
      StatoConnessione.errore => (
        Icons.error_outline,
        '$nome non raggiungibile',
        scheme.primary,
      ),
      StatoConnessione.inVerifica => (
        Icons.sync,
        'Verifica di $nome…',
        scheme.onSurfaceVariant,
      ),
      StatoConnessione.daVerificare => (
        Icons.radio_button_unchecked,
        nome,
        scheme.onSurfaceVariant,
      ),
    };
    return Row(
      children: [
        Icon(icona, size: 14, color: colore),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$testo · ${c.modello}',
            style: t.bodySmall?.copyWith(color: colore),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Al posto del pulsante "Prova connessione": diventa un riquadro che dice
/// chiaramente se il servizio è collegato o cosa non va.
class RiquadroConnessione extends StatelessWidget {
  final AppState state;
  final VoidCallback onProva;
  const RiquadroConnessione({
    super.key,
    required this.state,
    required this.onProva,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final c = state.assistente;
    final nome = _nomeBreve(c.fornitore);
    final dove = c.fornitore == Fornitore.ollama
        ? '${c.modello} · ${c.urlOllama.replaceFirst(RegExp(r'^https?://'), '')}'
        : c.modello;
    switch (state.connessione) {
      case StatoConnessione.daVerificare:
        return OutlinedButton.icon(
          onPressed: onProva,
          icon: const Icon(Icons.wifi_tethering),
          label: const Text('Prova connessione'),
        );
      case StatoConnessione.inVerifica:
        return Card(
          child: ListTile(
            leading: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            title: Text('Collegamento a $nome…'),
            subtitle: Text(dove),
          ),
        );
      case StatoConnessione.connesso:
        return Card(
          color: scheme.secondaryContainer,
          child: ListTile(
            leading: Icon(
              Icons.check_circle,
              size: 32,
              color: scheme.onSecondaryContainer,
            ),
            title: Text(
              '$nome connesso',
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSecondaryContainer,
              ),
            ),
            subtitle: Text(
              dove,
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
            trailing: TextButton(
              onPressed: onProva,
              child: const Text('Riprova'),
            ),
          ),
        );
      case StatoConnessione.errore:
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$nome non collegato',
                        style: t.titleMedium?.copyWith(color: scheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(state.erroreConnessione ?? '', style: t.bodySmall),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onProva,
                    child: const Text('Riprova'),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
