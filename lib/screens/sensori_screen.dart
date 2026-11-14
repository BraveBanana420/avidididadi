import 'package:flutter/material.dart';

import '../app_state.dart';
import '../avviso.dart';
import '../battito.dart';
import '../pulse.dart';
import '../sensore_ble.dart';
import '../sensori_bici.dart';
import '../widgets.dart';
import 'battito_sheet.dart';

/// "I miei sensori" nel Profilo: fascia cardio e sensori della bici si
/// collegano da qui, senza aspettare un allenamento. Si vede anche in modo
/// semplice: chi collega un sensore passa alle funzioni avanzate, con un
/// avviso.
class SensoriScreen extends StatefulWidget {
  final AppState state;
  const SensoriScreen({super.key, required this.state});

  @override
  State<SensoriScreen> createState() => _SensoriScreenState();
}

class _SensoriScreenState extends State<SensoriScreen> {
  @override
  void initState() {
    super.initState();
    // Per sapere se c'è già un sensore ricordato: non accende il Bluetooth.
    sensoreBattito.carica().then((_) {
      if (mounted) setState(() {});
    });
    sensoreBici.carica().then((_) {
      if (mounted) setState(() {});
    });
  }

  /// Apre il foglio del sensore: si collega finché il foglio resta aperto
  /// (per vedere che funziona), poi si stacca. In allenamento si ricollega
  /// da solo.
  Future<void> _apri(SensoreBle sensore) async {
    final messenger = ScaffoldMessenger.of(context);
    final state = widget.state;
    final prima = sensore.ricordato;
    await sensore.avvia();
    if (!mounted) return;
    if (sensore == sensoreBici) {
      await mostraSensoreBici(context);
      await sensoreBici.libera().whenComplete(sensoreBici.ferma);
    } else {
      await mostraBattito(context);
      await sensoreBattito.ferma();
    }
    if (mounted) setState(() {});
    // Un sensore nuovo, con l'app in modo semplice: servono i suoi dati.
    if (!prima && sensore.ricordato && !state.profilo.modoAvanzato) {
      await state.impostaAvanzata(true);
      messenger.showSnackBar(
        avviso(
          content: const Text(
            'Sensore collegato: ho acceso le funzioni avanzate.',
          ),
          annulla: () => state.impostaAvanzata(false),
        ),
      );
    }
  }

  Widget _riga(
    SensoreBle sensore,
    IconData icona,
    String titolo,
    String vuoto, {
    bool linea = true,
  }) => RigaPulse(
    segno: IconaQuadrata(icona, evidenza: sensore.ricordato),
    titolo: titolo,
    sottotitolo: sensore.ricordato ? 'Ricordato: ${sensore.nome}' : vuoto,
    linea: linea,
    onTap: () => _apri(sensore),
  );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final bici = widget.state.attivitaScelta('Bici');
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('I miei sensori')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Collega qui i sensori Bluetooth: li scegli una volta sola, poi '
            'si ricollegano da soli a ogni allenamento.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 12),
          _riga(
            sensoreBattito,
            Icons.favorite_border,
            'Battito',
            'Fascia cardio o orologio che trasmette il battito',
            linea: bici,
          ),
          if (bici)
            _riga(
              sensoreBici,
              Icons.pedal_bike_outlined,
              'Bici',
              'Rullo smart, potenza, velocità e cadenza',
              linea: false,
            ),
          const SizedBox(height: 16),
          Text(
            "Il Bluetooth si usa solo mentre questa pagina o l'allenamento "
            'sono aperti.',
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}
