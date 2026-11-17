import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';
import '../l10n/vocabolario.dart';

class WeekScreen extends StatelessWidget {
  final AppState state;
  const WeekScreen({super.key, required this.state});

  Future<void> _aggiungi(BuildContext context, int giorno) async {
    final nuovo = await _modifica(
      context,
      Slot(giorno: giorno, fascia: 'Mattina', sport: 'Corsa'),
    );
    if (nuovo != null) {
      final prima = [...state.settimana];
      state.settimana.add(nuovo);
      if (context.mounted) await _salva(context, prima);
    }
  }

  Future<void> _modificaEsistente(BuildContext context, Slot s) async {
    final nuovo = await _modifica(context, s);
    if (nuovo != null) {
      final prima = [...state.settimana];
      final i = state.settimana.indexOf(s);
      if (i >= 0) state.settimana[i] = nuovo;
      if (context.mounted) await _salva(context, prima);
    }
  }

  /// Riapplica tutta la settimana tipo al calendario futuro, dopo conferma.
  Future<void> _riporta(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.riportareSettimanaNelCalendario),
        content: Text(l10n.giorniOggiPoiDiventano),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.riporta),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) await _salva(context, const []);
  }

  /// Salva e porta subito il cambio nel calendario, dicendo cosa è successo.
  Future<void> _salva(BuildContext context, List<Slot> prima) async {
    final messenger = ScaffoldMessenger.of(context);
    final n = await state.salvaSettimana(prima: prima);
    final fine = state.ultimoGiornoPiano;
    messenger.showSnackBar(
      avviso(
        content: Text(
          fine == null || fine.isBefore(soloData(DateTime.now()))
              ? l10n.settimanaSalvataCalendarioVuoto
              : n == 0
              ? l10n.settimanaSalvata
              : l10n.calendarioAggiornatoOggiAl(
                  n,
                  n == 1 ? l10n.parolaGiorno : l10n.parolaGiorni,
                  dataLunga(fine).toLowerCase(),
                ),
        ),
      ),
    );
  }

  Future<Slot?> _modifica(BuildContext context, Slot slot) => showDialog<Slot>(
    context: context,
    builder: (_) => SlotDialog(slot: slot, sport: state.sportScelti),
  );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    // Pagina aperta dal Calendario (non più una scheda della barra in basso).
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(l10n.settimanaTipo2)),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.scegliCosaFaiQuale),
            const SizedBox(height: 12),
            for (var g = 1; g <= 7; g++) _giorno(context, g, t),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _riporta(context),
              icon: const Icon(Icons.sync_rounded),
              label: Text(l10n.portaTuttaSettimanaNel),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.rifaGiorniOggiPoi, style: t.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _giorno(BuildContext context, int g, TextTheme t) {
    final slots = state.settimana.where((s) => s.giorno == g).toList()
      ..sort(
        (a, b) => fasce.indexOf(a.fascia).compareTo(fasce.indexOf(b.fascia)),
      );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(giorniSettimana[g - 1], style: t.titleMedium),
                ),
                IconButton(
                  tooltip: l10n.aggiungiSessione,
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _aggiungi(context, g),
                ),
              ],
            ),
            if (slots.isEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(l10n.nessunaSessione),
              ),
            for (final s in slots)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(iconaSport(s.sport), color: coloreSport(s.sport)),
                title: Text(titoloSessione(s.sport, s.tipo)),
                subtitle: Text(l10n.min3(s.fascia, s.durataMin)),
                onTap: () => _modificaEsistente(context, s),
                trailing: IconButton(
                  tooltip: l10n.elimina,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    final prima = [...state.settimana];
                    state.settimana.remove(s);
                    await _salva(context, prima);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SlotDialog extends StatefulWidget {
  final Slot slot;
  final String? titolo; // default: il giorno della settimana

  /// Gli sport tra cui scegliere: quelli delle attività scelte.
  final List<String> sport;
  const SlotDialog({
    super.key,
    required this.slot,
    this.titolo,
    this.sport = sportList,
  });

  @override
  State<SlotDialog> createState() => _SlotDialogState();
}

class _SlotDialogState extends State<SlotDialog> {
  late String fascia = widget.slot.fascia;
  late String sport = widget.slot.sport;
  late final TextEditingController tipo = TextEditingController(
    text: widget.slot.tipo,
  );
  late final TextEditingController durata = TextEditingController(
    text: '${widget.slot.durataMin}',
  );
  late final TextEditingController note = TextEditingController(
    text: widget.slot.note,
  );

  @override
  void dispose() {
    tipo.dispose();
    durata.dispose();
    note.dispose();
    super.dispose();
  }

  List<String> _con(List<String> lista, String v) =>
      lista.contains(v) ? lista : [...lista, v];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titolo ?? giorniSettimana[widget.slot.giorno - 1]),
      content: SingleChildScrollView(
        // Un po' di respiro tra i campi: le etichette non si toccano.
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: [
            DropdownButtonFormField<String>(
              initialValue: sport,
              decoration: InputDecoration(labelText: l10n.sport),
              items: _con(widget.sport, sport)
                  .map(
                    (s) => DropdownMenuItem(value: s, child: Text(mostra(s))),
                  )
                  .toList(),
              onChanged: (v) => setState(() => sport = v ?? sport),
            ),
            DropdownButtonFormField<String>(
              initialValue: fascia,
              decoration: InputDecoration(labelText: l10n.fascia),
              items: _con(fasce, fascia)
                  .map(
                    (s) => DropdownMenuItem(value: s, child: Text(mostra(s))),
                  )
                  .toList(),
              onChanged: (v) => setState(() => fascia = v ?? fascia),
            ),
            TextField(
              controller: tipo,
              decoration: InputDecoration(
                labelText: l10n.tipoSessioneFacoltativo,
              ),
            ),
            TextField(
              controller: durata,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.durataMinuti),
            ),
            TextField(
              controller: note,
              decoration: InputDecoration(labelText: l10n.note),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annulla),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            Slot(
              giorno: widget.slot.giorno,
              fascia: fascia,
              sport: sport,
              tipo: tipo.text.trim(),
              durataMin: int.tryParse(durata.text.trim()) ?? 0,
              note: note.text.trim(),
            ),
          ),
          child: Text(l10n.salva),
        ),
      ],
    );
  }
}
