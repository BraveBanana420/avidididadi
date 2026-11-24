import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../assistente.dart';
import '../llm.dart';
import '../widgets.dart';
import 'agente_screen.dart';
import 'privacy_screen.dart';
import 'schede_proposte.dart';
import 'testo_formattato.dart';
import '../l10n/lingua.dart';

List<String> get _suggerimenti => [
  l10n.comAndataQuestaSettimana,
  l10n.giovediHoPocoTempo,
  l10n.adattaProssimiGiorniAl,
  l10n.sonoProntoGara,
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
        avviso(content: Text(errore), duration: const Duration(seconds: 8)),
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
                            Text(l10n.assistenteTitolo, style: t.titleLarge),
                            if (esterno)
                              Text(
                                l10n.collegato2(state.assistente.appEsterna),
                                style: t.bodySmall,
                              )
                            else if (pronto)
                              StatoAssistente(state: state),
                          ],
                        ),
                      ),
                      if (pronto && !esterno && state.chat.isNotEmpty)
                        IconButton(
                          tooltip: l10n.nuovaConversazione,
                          onPressed: state.assistenteInAttesa
                              ? null
                              : state.nuovaChat,
                          icon: const Icon(Icons.add_comment_rounded),
                        ),
                      IconButton(
                        tooltip: l10n.impostazioniAssistente,
                        onPressed: _impostazioni,
                        icon: const Icon(Icons.settings_rounded),
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
          Text(l10n.chiedimiDeiTuoiAllenamenti, style: t.bodyMedium),
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
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text(l10n.stoPensando),
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
            decoration: InputDecoration(
              hintText: l10n.scriviMessaggio,
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => _invia(),
          ),
        ),
        IconButton(
          tooltip: l10n.invia,
          onPressed: state.assistenteInAttesa ? null : _invia,
          icon: const Icon(Icons.send_rounded),
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
        Text(l10n.allenatoreCuiParlareDei, style: t.bodyMedium),
        const SizedBox(height: 12),
        for (final f in Fornitore.values)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              f == Fornitore.ollama
                  ? Icons.computer_rounded
                  : Icons.cloud_rounded,
            ),
            title: Text(nomiFornitori[f]!),
            subtitle: Text(descrizioniFornitori[f]!),
          ),
        const SizedBox(height: 8),
        Text(l10n.facoltativoSenzaAssistenteApp, style: t.bodySmall),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onConfigura,
          icon: const Icon(Icons.settings_rounded),
          label: Text(l10n.configuraAssistente),
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
    // Tutto quello che propone, per la scheda "Applica tutto".
    final tutta = RispostaAgente(
      modifiche: m.proposta,
      piano: m.piano,
      allenamenti: m.allenamenti,
      arrampicata: m.arrampicata,
      motivo: m.motivo,
    );
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
            if (tutta.parti > 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SchedaApplicaTutto(
                  state: state,
                  risposta: tutta,
                  messaggio: m,
                ),
              ),
            if (m.proposta != null)
              SchedaProposta(
                state: state,
                messaggio: m,
                conPulsante: tutta.parti < 2,
              ),
            if (m.allenamenti case final a?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SchedaAllenamenti(
                  state: state,
                  allenamenti: a,
                  motivo: m.motivo,
                  messaggio: m,
                  conPulsante: tutta.parti < 2,
                ),
              ),
            if (m.arrampicata case final a?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SchedaArrampicata(
                  state: state,
                  proposte: a,
                  messaggio: m,
                  conPulsante: tutta.parti < 2,
                ),
              ),
            if (m.piano case final p?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SchedaPiano(
                  state: state,
                  piano: p,
                  messaggio: m,
                  conPulsante: tutta.parti < 2,
                ),
              ),
            if (m.errore case final e?)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  e,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.error),
                ),
              ),
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

  /// Falso quando la risposta cambia più cose: si applica tutto insieme.
  final bool conPulsante;
  const SchedaProposta({
    super.key,
    required this.state,
    required this.messaggio,
    this.conPulsante = true,
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
            Text(l10n.modificheProposteAlPiano, style: t.titleSmall),
            const SizedBox(height: 6),
            if (messaggio.applicata)
              Text(l10n.applicateAlPiano)
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
                  l10n.nonApplicabili,
                  style: t.labelLarge?.copyWith(color: scheme.primary),
                ),
                for (final (m, motivo) in esito.scartate)
                  Text(
                    '• ${descriviModifica(m, state.piano)}: $motivo',
                    style: t.bodySmall,
                  ),
              ],
              const SizedBox(height: 8),
              if (esito.accettate.isNotEmpty && conPulsante)
                FilledButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final n = await state.applicaProposta(messaggio);
                    messenger.showSnackBar(
                      avviso(
                        content: Text(
                          n == 0
                              ? l10n.nienteApplicarePianoCambiato
                              : l10n.pianoAggiornatoModificheVedi(n),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.applicaModifiche(esito.accettate.length)),
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
    widget.state.preparaContestoAssistente();
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
      messenger.showSnackBar(avviso(content: Text(e.messaggio)));
      return;
    }
    if (!mounted) return;
    if (modelli.isEmpty) {
      messenger.showSnackBar(
        avviso(content: Text(l10n.nessunModelloDisponibileQuesta)),
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
                subtitle: m == consigliato ? Text(l10n.consigliato) : null,
                leading: Icon(
                  m == consigliato
                      ? Icons.star_rounded
                      : Icons.smart_toy_rounded,
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
        appBar: AppBar(title: Text(l10n.impostazioniAssistente)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Il coach nell'app dell'assistente (abbonamento, niente chiave).
            Card(
              child: c.esterno
                  ? ListTile(
                      leading: const Icon(Icons.link_rounded),
                      title: Text(l10n.collegato2(c.appEsterna)),
                      subtitle: Text(l10n.coachNellaSuaApp),
                    )
                  : ListTile(
                      leading: const Icon(Icons.forum_rounded),
                      title: Text(l10n.usaTuoAbbonamentoClaude),
                      subtitle: Text(l10n.senzaChiaveApiParli),
                      trailing: const Icon(Icons.chevron_right_rounded),
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
              c.esterno ? l10n.coachNellAppQuando : l10n.servizio,
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
              Text(l10n.chiaveApi, style: t.titleLarge),
              const SizedBox(height: 4),
              if (chiaveSalvata != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.key_rounded),
                    title: Text(l10n.chiaveSalvata(finale)),
                    subtitle: Text(l10n.cifrataSulTelefono),
                    trailing: TextButton(
                      onPressed: _eliminaChiave,
                      child: Text(l10n.elimina),
                    ),
                  ),
                )
              else ...[
                TextField(
                  controller: _chiave,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.incollaChiaveApi,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _salvaChiave,
                  child: Text(l10n.salvaChiave),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(l10n.siPagaConsumoSul, style: t.bodySmall),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(l10n.indirizzoOllama, style: t.titleLarge),
              const SizedBox(height: 4),
              TextField(
                controller: _url,
                onChanged: (_) => widget.state.connessioneDaVerificare(),
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.indirizzoPc,
                  hintText: 'http://192.168.1.10:11434',
                  border: OutlineInputBorder(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(l10n.sulPcInstallaOllama, style: t.bodySmall),
              ),
              const SizedBox(height: 16),
            ],
            Text(l10n.modello, style: t.titleLarge),
            const SizedBox(height: 4),
            TextField(
              controller: _modello,
              onChanged: (_) => widget.state.connessioneDaVerificare(),
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.nomeModello,
                hintText: modelliPredefiniti[f],
                helperText: l10n.vuotoPiuAdattoTra,
                border: const OutlineInputBorder(),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _scegliModello,
                icon: const Icon(Icons.list_alt_rounded),
                label: Text(l10n.scegliTraModelliDisponibili),
              ),
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: widget.state,
              builder: (context, _) =>
                  RiquadroConnessione(state: widget.state, onProva: _prova),
            ),
            const SizedBox(height: 20),
            Text(l10n.datiInviati, style: t.titleLarge),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.includiEtaSessoAltezza),
              subtitle: Text(l10n.nomeFotoNonVengono),
              value: c.datiPersonali,
              onChanged: (v) => setState(() => c.datiPersonali = v),
            ),
            Card(
              child: ExpansionTile(
                title: Text(l10n.vediEsattamenteCosaViene),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  ListenableBuilder(
                    listenable: widget.state,
                    builder: (context, _) => SelectableText(
                      widget.state.contestoAssistente,
                      style: t.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
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
                    ? l10n.acconsentoInviareQuestiDati2
                    : l10n.acconsentoInviareQuestiDati3(nomiFornitori[f]!),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
              child: Text(l10n.privacyUsoDeiDati),
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
        Icons.check_circle_rounded,
        l10n.connesso(nome),
        scheme.onSurface,
      ),
      StatoConnessione.errore => (
        Icons.error_outline_rounded,
        l10n.nonRaggiungibile(nome),
        scheme.primary,
      ),
      StatoConnessione.inVerifica => (
        Icons.sync_rounded,
        l10n.verifica(nome),
        scheme.onSurfaceVariant,
      ),
      StatoConnessione.daVerificare => (
        Icons.radio_button_unchecked_rounded,
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
          icon: const Icon(Icons.wifi_tethering_rounded),
          label: Text(l10n.provaConnessione2),
        );
      case StatoConnessione.inVerifica:
        return Card(
          child: ListTile(
            leading: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            title: Text(l10n.collegamento(nome)),
            subtitle: Text(dove),
          ),
        );
      case StatoConnessione.connesso:
        return Card(
          color: scheme.secondaryContainer,
          child: ListTile(
            leading: Icon(
              Icons.check_circle_rounded,
              size: 32,
              color: scheme.onSecondaryContainer,
            ),
            title: Text(
              l10n.connesso(nome),
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSecondaryContainer,
              ),
            ),
            subtitle: Text(
              dove,
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
            trailing: TextButton(onPressed: onProva, child: Text(l10n.riprova)),
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
                    Icon(Icons.error_outline_rounded, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.nonCollegato(nome),
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
                    child: Text(l10n.riprova),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
