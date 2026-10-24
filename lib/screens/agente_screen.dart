import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../agente_esterno.dart';
import '../app_state.dart';
import '../condivisione.dart';
import '../models.dart';
import '../pulse.dart';
import '../widgets.dart';
import 'assistente_screen.dart';
import 'privacy_screen.dart';

/// Collegamento dell'assistente nell'app dell'utente: quale app, cosa viene
/// inviato e consenso.
class CollegaAgenteScreen extends StatefulWidget {
  final AppState state;
  const CollegaAgenteScreen({super.key, required this.state});

  @override
  State<CollegaAgenteScreen> createState() => _CollegaAgenteScreenState();
}

class _CollegaAgenteScreenState extends State<CollegaAgenteScreen> {
  String app = appAgente.first;
  bool consenso = false;

  Future<void> _collega() async {
    final navigator = Navigator.of(context);
    await widget.state.salvaAssistente(); // dati personali sì/no
    await widget.state.collegaAgente(app);
    navigator.popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = widget.state.assistente;
    Widget passo(String n, String testo) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, child: Text(n, style: t.labelMedium)),
          const SizedBox(width: 10),
          Expanded(child: Text(testo)),
        ],
      ),
    );
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('Usa il tuo assistente')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Parli con il coach nell'app del tuo assistente, con il tuo "
            'abbonamento (anche gratuito): nessuna chiave API.',
            style: t.bodyLarge,
          ),
          const SizedBox(height: 16),
          passo(
            '1',
            "Avidididadi prepara un messaggio con i tuoi dati: lo "
                "mandi all'assistente con Condividi.",
          ),
          passo('2', "Parli con l'assistente nella sua app, quanto vuoi."),
          passo(
            '3',
            'Quando propone modifiche o un piano nuovo, condividi la '
                'risposta con Avidididadi: vedi l\'anteprima e decidi tu.',
          ),
          const SizedBox(height: 12),
          Text('Quale app usi?', style: t.titleMedium),
          Wrap(
            spacing: 8,
            children: [
              for (final a in appAgente)
                ChoiceChip(
                  label: Text(a),
                  selected: app == a,
                  onSelected: (_) => setState(() => app = a),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SuperficiePulse(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.privacy_tip_outlined),
                    const SizedBox(width: 8),
                    Text('Prima di iniziare', style: t.titleSmall),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Con un abbonamento normale le chat possono servire ad '
                  'addestrare il modello, secondo le impostazioni del tuo '
                  'account. Nome, foto e percorsi GPS non vengono mai inviati.',
                ),
                const SizedBox(height: 6),
                Text(privacyAgente[app]!, style: t.bodySmall),
              ],
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Includi età, sesso, altezza e peso'),
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
            value: consenso,
            onChanged: (v) => setState(() => consenso = v ?? false),
            title: Text(
              'Acconsento a inviare questi dati a $app quando tocco Condividi '
              'o Copia',
            ),
          ),
          const SizedBox(height: 8),
          PulsantePrincipale(
            onPressed: consenso ? _collega : null,
            icona: Icons.link,
            testo: 'Collega $app',
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
            child: const Text('Privacy e uso dei dati'),
          ),
        ],
      ),
    );
  }
}

/// Coach quando è collegato l'assistente esterno: manda i dati, porta qui
/// la risposta, scollega.
class PannelloAgente extends StatelessWidget {
  final AppState state;
  const PannelloAgente({super.key, required this.state});

  String get _app => state.assistente.appEsterna.isEmpty
      ? "l'assistente"
      : state.assistente.appEsterna;

  Future<void> _manda(BuildContext context, {required bool completo}) async {
    final testo = await state.messaggioAgente(completo: completo);
    await Condivisione.condividi(testo, 'Manda a $_app');
  }

  Future<void> _copiaMessaggio(BuildContext context, bool completo) async {
    final messenger = ScaffoldMessenger.of(context);
    final testo = await state.messaggioAgente(completo: completo);
    await Clipboard.setData(ClipboardData(text: testo));
    messenger.showSnackBar(
      SnackBar(content: Text('Messaggio copiato: incollalo in $_app.')),
    );
  }

  Future<void> _copia(BuildContext context, String testo, String fatto) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: testo));
    messenger.showSnackBar(SnackBar(content: Text(fatto)));
  }

  Future<void> _incolla(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final testo = d?.text ?? '';
    if (testo.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Gli appunti sono vuoti: copia prima la risposta di $_app.',
          ),
        ),
      );
      return;
    }
    state.riceviDaAgente(testo);
  }

  Future<void> _scollega(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Scollegare $_app?'),
        content: const Text(
          'Torni al coach dentro l\'app (per esempio Ollama sul tuo PC). Le '
          'risposte della conversazione attuale non verranno più accettate: '
          'se ricolleghi, manda di nuovo i dati.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Scollega'),
          ),
        ],
      ),
    );
    if (ok == true) await state.scollegaAgente();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = state.assistente;
    final iniziato = c.ultimoInvioEsterno != null;
    final ultimo = c.ultimoInvioEsterno;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, spazioBarra(context)),
      children: [
        // Risposta portata qui: anteprima e conferma.
        if (state.erroreAgente != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Risposta non usabile'),
              subtitle: Text(state.erroreAgente!),
            ),
          ),
        if (state.propostaAgente != null)
          SchedaProposta(state: state, messaggio: state.propostaAgente!),
        if (state.rispostaAgente?.piano case final p?)
          _SchedaPiano(state: state, piano: p),
        SuperficiePulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1 · Parla con $_app', style: t.titleMedium),
              const SizedBox(height: 4),
              Text(
                iniziato
                    ? 'Hai fatto allenamenti nuovi? Manda i dati aggiornati '
                          'nella stessa conversazione.'
                    : 'Manda il primo messaggio: istruzioni da coach e i tuoi '
                          'dati. Scegli $_app dal menu Condividi.',
              ),
              if (ultimo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Ultimo invio: ${dataLunga(ultimo)}, '
                    '${two(ultimo.hour)}:${two(ultimo.minute)}',
                    style: t.bodySmall,
                  ),
                ),
              const SizedBox(height: 12),
              PulsantePrincipale(
                altezza: 52,
                onPressed: () => _manda(context, completo: !iniziato),
                icona: Icons.ios_share,
                testo: iniziato ? 'Manda dati aggiornati' : 'Inizia con $_app',
              ),
              Wrap(
                spacing: 4,
                children: [
                  if (iniziato)
                    TextButton(
                      onPressed: () => _manda(context, completo: true),
                      child: const Text('Nuova conversazione'),
                    ),
                  TextButton(
                    onPressed: () => _copiaMessaggio(context, !iniziato),
                    child: const Text('Copia invece'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SuperficiePulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('2 · Porta qui le modifiche', style: t.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Quando $_app propone di cambiare il piano, nella sua '
                'risposta tocca Condividi e scegli Avidididadi. Oppure '
                'copiala e tocca qui sotto.',
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _incolla(context),
                icon: const Icon(Icons.content_paste),
                label: const Text('Incolla la risposta'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ExpansionTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: const Text('Consiglio: le istruzioni una volta sola'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Incolla le istruzioni da coach in un Progetto di Claude, in '
                'un GPT personalizzato o in un Gem di Gemini. Poi ti basta '
                'mandare i dati aggiornati.',
              ),
              TextButton.icon(
                onPressed: () => _copia(
                  context,
                  istruzioniAgente(c.codiceEsterno),
                  'Istruzioni copiate.',
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copia solo le istruzioni'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => _scollega(context),
            icon: const Icon(Icons.link_off),
            label: Text('Scollega $_app'),
          ),
        ),
      ],
    );
  }
}

/// Anteprima di un piano nuovo dell'agente: settimane, problemi, conferma.
class _SchedaPiano extends StatelessWidget {
  final AppState state;
  final PianoAgente piano;
  const _SchedaPiano({required this.state, required this.piano});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final esito = state.valutaPianoDa(piano);
    final settimane = <DateTime, List<PianoRiga>>{};
    for (final r in esito.sedute) {
      final w = r.data.subtract(Duration(days: r.data.weekday - 1));
      (settimane[w] ??= []).add(r);
    }
    final app = state.assistente.appEsterna;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Piano nuovo da ${dataLunga(piano.da)}', style: t.titleSmall),
            if (piano.motivo.isNotEmpty) Text(piano.motivo, style: t.bodySmall),
            const SizedBox(height: 8),
            if (state.rispostaApplicata)
              const Text('Applicato: lo trovi nel calendario.')
            else ...[
              Text(
                '${esito.sedute.length} sedute in ${settimane.length} '
                'settimane. Sostituisce il calendario da quel giorno in poi.',
              ),
              for (final e in settimane.entries.take(3))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Settimana del ${e.key.day}/${e.key.month}: '
                    '${e.value.map((r) => '${giorniSettimana[r.data.weekday - 1].substring(0, 3)} ${titoloSessione(r.sport, r.tipo)} ${r.durataMin}′').join(' · ')}',
                    style: t.bodySmall,
                  ),
                ),
              if (settimane.length > 3)
                Text('…e le altre settimane.', style: t.bodySmall),
              if (esito.problemi.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Non applicabile',
                  style: t.labelLarge?.copyWith(color: scheme.primary),
                ),
                for (final p in esito.problemi.take(6))
                  Text('• $p', style: t.bodySmall),
                TextButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(
                      ClipboardData(
                        text: correzioneAgente(
                          esito.problemi,
                          state.assistente.codiceEsterno,
                        ),
                      ),
                    );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Copiato: incollalo in $app per correggere.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text('Copia i problemi per $app'),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilledButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final n = await state.applicaPianoAgente(piano);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            n == 0
                                ? 'Il piano non è più applicabile: riprova.'
                                : 'Piano applicato: $n sedute nel calendario.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Applica il piano'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
