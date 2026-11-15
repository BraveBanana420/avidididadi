import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';

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
        title: const Text('Riportare la settimana nel calendario?'),
        content: const Text(
          'I giorni da oggi in poi diventano uguali alla settimana tipo: le '
          'modifiche fatte a mano su quei giorni vengono sostituite. I giorni '
          'già fatti restano.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Riporta'),
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
              ? 'Settimana salvata. Il calendario è vuoto: allungalo da Oggi.'
              : n == 0
              ? 'Settimana salvata.'
              : 'Calendario aggiornato: $n ${n == 1 ? 'giorno' : 'giorni'} '
                    'da oggi al ${dataLunga(fine).toLowerCase()}.',
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
      appBar: AppBar(title: const Text('Settimana tipo')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Scegli cosa fai e in quale giorno. I cambi valgono subito nel '
              'calendario, da oggi in poi; i giorni già fatti non cambiano.',
            ),
            const SizedBox(height: 12),
            for (var g = 1; g <= 7; g++) _giorno(context, g, t),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _riporta(context),
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Porta tutta la settimana nel calendario'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Rifà i giorni da oggi in poi uguali alla settimana tipo. Utile '
                'se il calendario non corrisponde più.',
                style: t.bodySmall,
              ),
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
                  tooltip: 'Aggiungi sessione',
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _aggiungi(context, g),
                ),
              ],
            ),
            if (slots.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Nessuna sessione'),
              ),
            for (final s in slots)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(iconaSport(s.sport), color: coloreSport(s.sport)),
                title: Text(titoloSessione(s.sport, s.tipo)),
                subtitle: Text('${s.fascia}, ${s.durataMin} min'),
                onTap: () => _modificaEsistente(context, s),
                trailing: IconButton(
                  tooltip: 'Elimina',
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
              decoration: const InputDecoration(labelText: 'Sport'),
              items: _con(
                widget.sport,
                sport,
              ).map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => sport = v ?? sport),
            ),
            DropdownButtonFormField<String>(
              initialValue: fascia,
              decoration: const InputDecoration(labelText: 'Fascia'),
              items: _con(
                fasce,
                fascia,
              ).map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => fascia = v ?? fascia),
            ),
            TextField(
              controller: tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo di sessione (facoltativo)',
              ),
            ),
            TextField(
              controller: durata,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Durata (minuti)'),
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
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
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
