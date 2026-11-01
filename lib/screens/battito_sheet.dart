import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../battito.dart';
import '../gps.dart';

/// Foglio del battito: il sensore ricordato, oppure la ricerca di quelli vicini.
Future<void> mostraBattito(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => const _FoglioBattito(),
);

class _FoglioBattito extends StatefulWidget {
  const _FoglioBattito();

  @override
  State<_FoglioBattito> createState() => _FoglioBattitoState();
}

class _FoglioBattitoState extends State<_FoglioBattito> {
  final trovati = <String, DiscoveredDevice>{};
  StreamSubscription<DiscoveredDevice>? _ricerca;
  Timer? _basta;
  bool cerco = false;

  @override
  void initState() {
    super.initState();
    if (!sensoreBattito.ricordato) _cerca();
  }

  @override
  void dispose() {
    _ricerca?.cancel();
    _basta?.cancel();
    super.dispose();
  }

  Future<void> _cerca() async {
    await _ricerca?.cancel();
    _basta?.cancel();
    setState(() {
      trovati.clear();
      cerco = true;
    });
    final flusso = await sensoreBattito.cerca();
    if (!mounted) return;
    if (flusso == null) {
      setState(() => cerco = false);
      return;
    }
    _ricerca = flusso.listen(
      (d) {
        if (mounted) setState(() => trovati[d.id] = d);
      },
      onError: (Object e) {
        if (mounted) setState(() => cerco = false);
      },
    );
    // La ricerca consuma batteria: dopo mezzo minuto basta.
    _basta = Timer(const Duration(seconds: 30), () {
      _ricerca?.cancel();
      if (mounted) setState(() => cerco = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListenableBuilder(
        listenable: sensoreBattito,
        builder: (context, _) {
          final s = sensoreBattito;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text('Battito dal sensore', style: t.titleLarge),
                Text(
                  "Una fascia cardio o un orologio che trasmette il battito "
                  "via Bluetooth. Lo vedi durante l'allenamento; alla fine "
                  "si salvano media e massimo.",
                  style: t.bodyMedium,
                ),
                if (s.stato == StatoBattito.permessoNegato) ...[
                  Text(
                    'Serve il permesso "Dispositivi nelle vicinanze".',
                    style: t.bodyMedium?.copyWith(color: scheme.error),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        apriImpostazioniGps(StatoGps.permessoNegato),
                    icon: const Icon(Icons.settings),
                    label: const Text('Apri le impostazioni'),
                  ),
                ],
                if (s.stato == StatoBattito.bluetoothSpento)
                  Text(
                    'Il Bluetooth è spento: accendilo e riprova.',
                    style: t.bodyMedium?.copyWith(color: scheme.error),
                  ),
                if (s.ricordato)
                  Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        s.stato == StatoBattito.collegato
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: scheme.primary,
                      ),
                      title: Text(s.nome),
                      subtitle: Text(switch (s.stato) {
                        StatoBattito.collegato when s.bpm != null =>
                          'Collegato · ${s.bpm} bpm',
                        StatoBattito.collegato =>
                          'Collegato, aspetto il battito…',
                        StatoBattito.collega =>
                          'Mi collego… (dev\'essere acceso e vicino)',
                        _ => 'Non collegato',
                      }),
                      trailing: TextButton(
                        onPressed: () async {
                          await s.dimentica();
                          await _cerca();
                        },
                        child: const Text('Dimentica'),
                      ),
                    ),
                  ),
                if (!s.ricordato || trovati.isNotEmpty || cerco) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cerco ? 'Cerco i sensori vicini…' : 'Sensori trovati',
                          style: t.titleSmall,
                        ),
                      ),
                      if (cerco)
                        const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  if (!cerco && trovati.isEmpty)
                    Text(
                      'Nessun sensore trovato.',
                      style: t.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  Material(
                    type: MaterialType.transparency,
                    child: Column(
                      children: [
                        for (final d in trovati.values)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.monitor_heart_outlined),
                            title: Text(
                              d.name.isEmpty ? 'Sensore del battito' : d.name,
                            ),
                            subtitle: Text(_segnale(d.rssi)),
                            onTap: () async {
                              await _ricerca?.cancel();
                              await s.scegli(d);
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
                if (!cerco)
                  OutlinedButton.icon(
                    onPressed: _cerca,
                    icon: const Icon(Icons.bluetooth_searching),
                    label: Text(
                      s.ricordato ? 'Cerca un altro sensore' : 'Cerca di nuovo',
                    ),
                  ),
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    title: Text('Come si collega', style: t.titleSmall),
                    children: [
                      Text(
                        'Garmin: sull\'orologio cerca "Trasmetti frequenza '
                        'cardiaca" (di solito nei controlli, tenendo premuto '
                        'il tasto della luce) e attivala: poi tocca "Cerca". '
                        'Alcuni modelli vecchi la trasmettono solo in ANT+, '
                        'che il telefono non legge.\n'
                        'Fascia cardio: indossala bagnando un po\' gli '
                        'elettrodi, si accende da sola.\n'
                        'Una volta scelto, il sensore si ricollega da solo a '
                        'ogni allenamento.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _segnale(int rssi) => rssi >= -65
      ? 'Segnale forte'
      : rssi >= -80
      ? 'Segnale medio'
      : 'Segnale debole';
}
