import 'package:flutter/material.dart';

import '../avviso.dart';
import '../adattamento.dart';
import '../app_state.dart';
import '../feedback.dart';
import '../generatore_forza.dart';
import '../models.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';
import '../l10n/vocabolario.dart';

/// Apre il feedback rapido di fine sessione per il giorno [data].
Future<void> apriFeedback(
  BuildContext context,
  AppState state,
  DateTime data, [
  String sport = 'Forza',
  Sessione? attivita, // l'attività davvero svolta, se c'è
]) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _FeedbackSheet(
    state: state,
    data: soloData(data),
    sport: normSport(sport),
    attivita:
        attivita ??
        state.sessioni
            .where(
              (s) => s.data == soloData(data) && stessoSport(s.sport, sport),
            )
            .firstOrNull,
  ),
);

String _descrizioneFatica(int f) => switch (f) {
  <= 2 => l10n.moltoLeggera,
  <= 4 => l10n.parolaLeggera,
  <= 6 => l10n.parolaModerata,
  <= 8 => l10n.parolaImpegnativa,
  9 => l10n.moltoDura,
  _ => l10n.alMassimo,
};

class _FeedbackSheet extends StatefulWidget {
  final AppState state;
  final DateTime data;
  final String sport;
  final Sessione? attivita;
  const _FeedbackSheet({
    required this.state,
    required this.data,
    required this.sport,
    this.attivita,
  });

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  late final FeedbackSessione? prima = widget.attivita == null
      ? widget.state.feedbackDel(widget.data, widget.sport)
      : widget.state.feedbackDi(widget.attivita!);
  late final bool forza = stessoSport(widget.sport, 'Forza');
  late final String tipo = widget.state.tipoDel(widget.data, widget.sport);
  // La fatica attesa è quella di ciò che hai fatto davvero.
  late final int obiettivo = forza
      ? faticaObiettivo(widget.state.profilo.obiettivo)
      : widget.state
            .valutaFeedback(
              FeedbackSessione(
                data: widget.data,
                fatica: 5,
                sport: widget.sport,
                idSessione: widget.attivita?.id ?? '',
              ),
            )
            .atteso;
  // Nuoto con un passo target: com'è andato il passo nella principale.
  late final int? target = stessoSport(widget.sport, 'Nuoto')
      ? widget.state.passoTargetDel(widget.data)
      : null;
  late String esitoPasso = prima?.esitoPasso ?? '';
  late final TextEditingController passo = TextEditingController(
    text: (prima?.passoS ?? 0) > 0
        ? '${prima!.passoS ~/ 60}:${two(prima!.passoS % 60)}'
        : '',
  );
  late int fatica = prima?.fatica ?? obiettivo;
  late bool completata = prima?.completata ?? true;
  late bool dolore = prima?.dolore ?? false;
  late final TextEditingController note = TextEditingController(
    text: prima?.note,
  );
  bool inCorso = false;

  @override
  void dispose() {
    note.dispose();
    passo.dispose();
    super.dispose();
  }

  /// "2:45" in secondi; 0 se vuoto o non credibile.
  int get _passoS {
    final m = RegExp(r'^(\d{1,2})[:.,](\d{2})$').firstMatch(passo.text.trim());
    if (m == null) return 0;
    final v = int.parse(m[1]!) * 60 + int.parse(m[2]!);
    return passoCredibile(v) ? v : 0;
  }

  Future<void> _salva() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => inCorso = true);
    final messaggio = await widget.state.salvaFeedback(
      FeedbackSessione(
        data: widget.data,
        sport: widget.sport,
        fatica: fatica,
        completata: completata,
        dolore: dolore,
        note: note.text.trim(),
        idSessione: widget.attivita?.id ?? '',
        passoS: _passoS,
        esitoPasso: _passoS > 0 ? '' : esitoPasso,
      ),
    );
    if (!mounted) return;
    navigator.pop();
    // Corsa, nuoto e bici: cosa cambia davvero nelle prossime sedute.
    if (messaggio.contains('\n')) {
      await showDialog<void>(
        context: navigator.context,
        builder: (c) => AlertDialog(
          title: Text(l10n.feedbackSalvato2),
          content: Text(messaggio),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(l10n.ok2),
            ),
          ],
        ),
      );
      return;
    }
    messenger.showSnackBar(avviso(content: Text(messaggio)));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + spazioInBasso(context)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.comAndata, style: t.titleLarge),
            Text('${mostra(widget.sport)} · ${dataLunga(widget.data)}'),
            const SizedBox(height: 16),
            Text(
              l10n.fatica102(fatica, _descrizioneFatica(fatica)),
              style: t.titleMedium,
            ),
            Slider(
              value: fatica.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$fatica',
              onChanged: (v) => setState(() => fatica = v.round()),
            ),
            Text(
              forza
                  ? l10n.tuoObiettivoFaticaGiusta(obiettivo)
                  : l10n.sedutaFaticaPrevistaCirca(
                      tipo.isEmpty ? l10n.comeQuesta : tipo.toLowerCase(),
                      obiettivo,
                    ),
              style: t.bodySmall,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                forza ? l10n.hoCompletatoTutteSerie : l10n.hoFattoTuttaSeduta,
              ),
              value: completata,
              onChanged: (v) => setState(() => completata = v),
            ),
            if (target != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.passoNellaPartePrincipale(
                  target! ~/ 60,
                  two(target! % 60),
                ),
                style: t.titleSmall,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in nomiEsitiPasso.entries)
                    ChoiceChip(
                      label: Text(e.value),
                      selected: esitoPasso == e.key,
                      onSelected: (v) =>
                          setState(() => esitoPasso = v ? e.key : ''),
                    ),
                ],
              ),
              TextField(
                controller: passo,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: l10n.oppurePassoHaiTenuto,
                  suffixText: '/100 m',
                ),
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.hoSentitoDoloreO),
              value: dolore,
              onChanged: (v) => setState(() => dolore = v),
            ),
            TextField(
              controller: note,
              decoration: InputDecoration(labelText: l10n.noteFacoltative),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: inCorso ? null : _salva,
                child: Text(l10n.salva),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
