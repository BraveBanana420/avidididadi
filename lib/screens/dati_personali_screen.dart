import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../profilo.dart';
import '../widgets.dart';

/// Modifica di tutti i dati personali insieme, aperta dalla matita del Profilo.
class DatiPersonaliScreen extends StatefulWidget {
  final AppState state;
  const DatiPersonaliScreen({super.key, required this.state});

  @override
  State<DatiPersonaliScreen> createState() => _DatiPersonaliScreenState();
}

class _DatiPersonaliScreenState extends State<DatiPersonaliScreen> {
  late final p = widget.state.profilo;
  late final double pesoAttuale = widget.state.ultimaMisura('peso_kg')?.$1 ?? 0;
  late final nome = TextEditingController(text: p.nome);
  late final cognome = TextEditingController(text: p.cognome);
  late final altezza = TextEditingController(
    text: p.altezzaCm > 0 ? fmtNum(p.altezzaCm) : '',
  );
  late final peso = TextEditingController(
    text: pesoAttuale > 0 ? fmtNum(pesoAttuale) : '',
  );
  late DateTime? nascita = p.nascita;
  late String sesso = p.sesso;
  String? erroreAltezza, errorePeso;

  @override
  void dispose() {
    for (final c in [nome, cognome, altezza, peso]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Numero dal campo: 0 se vuoto, null se non valido o fuori da [min, max].
  double? _numero(TextEditingController c, double min, double max) {
    final t = c.text.trim().replaceAll(',', '.');
    if (t.isEmpty) return 0;
    final v = double.tryParse(t);
    return v == null || v < min || v > max ? null : v;
  }

  Future<void> _scegliNascita() async {
    final oggi = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: nascita ?? DateTime(oggi.year - 30),
      firstDate: DateTime(1920),
      lastDate: oggi,
      helpText: 'Data di nascita',
    );
    if (d != null) setState(() => nascita = soloData(d));
  }

  Future<void> _salva() async {
    final a = _numero(altezza, 50, 250);
    final kg = _numero(peso, 20, 300);
    setState(() {
      erroreAltezza = a == null ? 'Altezza in cm, tra 50 e 250' : null;
      errorePeso = kg == null ? 'Peso in kg, tra 20 e 300' : null;
    });
    if (a == null || kg == null) return;
    final navigator = Navigator.of(context);
    p
      ..nome = nome.text.trim()
      ..cognome = cognome.text.trim()
      ..nascita = nascita
      ..sesso = sesso
      ..altezzaCm = a;
    await widget.state.salvaProfilo();
    // Il peso è uno storico: un valore nuovo si registra con la data di oggi.
    if (kg > 0 && kg != pesoAttuale) {
      await widget.state.salvaMisura('peso_kg', kg);
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: const Text('Dati personali'),
        actions: [TextButton(onPressed: _salva, child: const Text('Salva'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nome,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cognome,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Cognome'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _scegliNascita,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data di nascita',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                nascita == null
                    ? 'Tocca per sceglierla'
                    : '${two(nascita!.day)}/${two(nascita!.month)}/${nascita!.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: [
              for (final s in sessi) ButtonSegment(value: s, label: Text(s)),
            ],
            selected: {if (sesso.isNotEmpty) sesso},
            emptySelectionAllowed: true,
            onSelectionChanged: (v) =>
                setState(() => sesso = v.isEmpty ? '' : v.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: altezza,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Altezza',
              suffixText: 'cm',
              errorText: erroreAltezza,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: peso,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Peso',
              suffixText: 'kg',
              helperText: 'Un peso nuovo si registra con la data di oggi.',
              errorText: errorePeso,
            ),
          ),
        ],
      ),
    );
  }
}
