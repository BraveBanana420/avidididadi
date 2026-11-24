import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../avviso.dart';
import '../agente_esterno.dart';
import '../app_state.dart';
import '../condivisione.dart';
import '../models.dart';
import '../pulse.dart';
import '../widgets.dart';
import 'assistente_screen.dart';
import 'privacy_screen.dart';
import 'schede_proposte.dart';
import '../l10n/lingua.dart';

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

  @override
  void initState() {
    super.initState();
    widget.state.preparaContestoAssistente();
  }

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
      appBar: AppBar(title: Text(l10n.usaTuoAssistente)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.parliCoachNellApp, style: t.bodyLarge),
          const SizedBox(height: 16),
          passo('1', l10n.avidididadiPreparaMessaggioTuoi),
          passo('2', l10n.parliAssistenteNellaSua),
          passo('3', l10n.quandoProponeModificheO),
          const SizedBox(height: 12),
          Text(l10n.qualeAppUsi, style: t.titleMedium),
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
                    const Icon(Icons.privacy_tip_rounded),
                    const SizedBox(width: 8),
                    Text(l10n.primaIniziare, style: t.titleSmall),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l10n.abbonamentoNormaleChatPossono),
                const SizedBox(height: 6),
                Text(privacyAgente[app]!, style: t.bodySmall),
              ],
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.includiEtaSessoAltezza),
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
            value: consenso,
            onChanged: (v) => setState(() => consenso = v ?? false),
            title: Text(l10n.acconsentoInviareQuestiDati(app)),
          ),
          const SizedBox(height: 8),
          PulsantePrincipale(
            onPressed: consenso ? _collega : null,
            icona: Icons.link_rounded,
            testo: l10n.collega(app),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
            child: Text(l10n.privacyUsoDeiDati),
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
      ? l10n.assistente
      : state.assistente.appEsterna;

  Future<void> _manda(BuildContext context, {required bool completo}) async {
    final testo = await state.messaggioAgente(completo: completo);
    await Condivisione.condividi(testo, l10n.manda(_app));
  }

  Future<void> _copiaMessaggio(BuildContext context, bool completo) async {
    final messenger = ScaffoldMessenger.of(context);
    final testo = await state.messaggioAgente(completo: completo);
    await Clipboard.setData(ClipboardData(text: testo));
    messenger.showSnackBar(
      avviso(content: Text(l10n.messaggioCopiatoIncollalo(_app))),
    );
  }

  Future<void> _copia(BuildContext context, String testo, String fatto) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: testo));
    messenger.showSnackBar(avviso(content: Text(fatto)));
  }

  Future<void> _incolla(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final testo = d?.text ?? '';
    if (testo.trim().isEmpty) {
      messenger.showSnackBar(
        avviso(content: Text(l10n.appuntiSonoVuotiCopia(_app))),
      );
      return;
    }
    state.riceviDaAgente(testo);
  }

  Future<void> _scollega(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.scollegare(_app)),
        content: Text(l10n.torniAlCoachDentro),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.scollega),
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
    final unaParte = (state.rispostaAgente?.parti ?? 0) < 2;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, spazioBarra(context)),
      children: [
        // Risposta portata qui: anteprima e conferma.
        if (state.erroreAgente != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: Text(l10n.rispostaNonUsabile),
              subtitle: Text(state.erroreAgente!),
            ),
          ),
        if (state.rispostaAgente case final r? when r.parti > 1)
          SchedaApplicaTutto(state: state, risposta: r),
        if (state.propostaAgente != null)
          SchedaProposta(
            state: state,
            messaggio: state.propostaAgente!,
            conPulsante: unaParte,
          ),
        if (state.rispostaAgente?.piano case final p?)
          SchedaPiano(state: state, piano: p, conPulsante: unaParte),
        if (state.rispostaAgente?.arrampicata case final a?)
          SchedaArrampicata(state: state, proposte: a, conPulsante: unaParte),
        if (state.rispostaAgente?.allenamenti case final a?)
          SchedaAllenamenti(
            state: state,
            allenamenti: a,
            motivo: state.rispostaAgente!.motivo,
            conPulsante: unaParte,
          ),
        SuperficiePulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.n1Parla(_app), style: t.titleMedium),
              const SizedBox(height: 4),
              Text(
                iniziato
                    ? l10n.haiFattoAllenamentiNuovi
                    : l10n.mandaPrimoMessaggioIstruzioni(_app),
              ),
              if (ultimo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.ultimoInvio(
                      dataLunga(ultimo),
                      two(ultimo.hour),
                      two(ultimo.minute),
                    ),
                    style: t.bodySmall,
                  ),
                ),
              const SizedBox(height: 12),
              PulsantePrincipale(
                altezza: 52,
                onPressed: () => _manda(context, completo: !iniziato),
                icona: Icons.ios_share_rounded,
                testo: iniziato ? l10n.mandaDatiAggiornati : l10n.inizia(_app),
              ),
              Wrap(
                spacing: 4,
                children: [
                  if (iniziato)
                    TextButton(
                      onPressed: () => _manda(context, completo: true),
                      child: Text(l10n.nuovaConversazione),
                    ),
                  TextButton(
                    onPressed: () => _copiaMessaggio(context, !iniziato),
                    child: Text(l10n.copiaInvece),
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
              Text(l10n.n2PortaQuiModifiche, style: t.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.quandoProponeCambiarePiano(_app)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _incolla(context),
                icon: const Icon(Icons.content_paste_rounded),
                label: Text(l10n.incollaRisposta),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ExpansionTile(
            leading: const Icon(Icons.lightbulb_outline_rounded),
            title: Text(l10n.consiglioIstruzioniVoltaSola),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.incollaIstruzioniCoachProgetto),
              TextButton.icon(
                onPressed: () => _copia(
                  context,
                  istruzioniAgente(c.codiceEsterno),
                  l10n.istruzioniCopiate,
                ),
                icon: const Icon(Icons.copy_rounded),
                label: Text(l10n.copiaSoloIstruzioni),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => _scollega(context),
            icon: const Icon(Icons.link_off_rounded),
            label: Text(l10n.scollega2(_app)),
          ),
        ),
      ],
    );
  }
}
