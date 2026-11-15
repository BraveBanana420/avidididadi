import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../battito.dart';
import '../gps.dart';
import '../models.dart';
import '../sensore_ble.dart';
import '../pulse.dart';
import '../sensori_bici.dart';

/// Foglio del battito: il sensore ricordato, oppure la ricerca di quelli vicini.
Future<void> mostraBattito(BuildContext context) => _mostra(
  context,
  _FoglioSensore(
    sensore: sensoreBattito,
    titolo: 'Battito dal sensore',
    spiegazione:
        "Una fascia cardio o un orologio che trasmette il battito via "
        "Bluetooth. Lo vedi durante l'allenamento; alla fine si salvano media "
        'e massimo.',
    icona: Icons.favorite_rounded,
    iconaVuota: Icons.favorite_border_rounded,
    iconaTrovato: Icons.monitor_heart_rounded,
    dati: () => sensoreBattito.bpm == null ? null : '${sensoreBattito.bpm} bpm',
    aiuto:
        'Garmin: sull\'orologio cerca "Trasmetti frequenza cardiaca" (di '
        'solito nei controlli, tenendo premuto il tasto della luce) e '
        'attivala: poi tocca "Cerca". Alcuni modelli vecchi la trasmettono '
        'solo in ANT+, che il telefono non legge.\n'
        "Fascia cardio: indossala bagnando un po' gli elettrodi, si accende "
        'da sola.\n'
        'Una volta scelto, il sensore si ricollega da solo a ogni allenamento.',
  ),
);

/// Foglio dei sensori della bici: velocità e cadenza, potenza, rulli smart.
Future<void> mostraSensoreBici(BuildContext context) => _mostra(
  context,
  _FoglioSensore(
    sensore: sensoreBici,
    titolo: 'Sensori della bici',
    spiegazione:
        'Rulli smart (Tacx, Wahoo, Elite…), misuratore di potenza o sensore '
        'di velocità e cadenza, via Bluetooth. Alla fine si salvano potenza e '
        'cadenza medie.',
    icona: Icons.pedal_bike_rounded,
    iconaVuota: Icons.pedal_bike_outlined,
    iconaTrovato: Icons.pedal_bike_outlined,
    dati: () => [
      if (sensoreBici.potenza case final w?) '$w W',
      if (sensoreBici.cadenza case final c?) '${c.round()} rpm',
      if (sensoreBici.velocita case final v?)
        '${(v * 3.6).toStringAsFixed(1)} km/h',
    ].join(' · ').emptyToNull,
    aiuto:
        'Rulli: accendili e smetti di usarli con altre app (Zwift, Tacx), '
        'perché molti si collegano a una sola app per volta.\n'
        'Sensore di velocità o di cadenza: si sveglia girando la ruota o i '
        'pedali.\n'
        'La circonferenza della ruota serve solo al sensore di velocità: la '
        'trovi scritta sul copertone (es. 700×25C = 2105 mm).',
    extra: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [_CalibraRullo(), _Circonferenza()],
    ),
  ),
);

Future<void> _mostra(BuildContext context, Widget foglio) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => foglio,
    );

extension on String {
  String? get emptyToNull => isEmpty ? null : this;
}

class _FoglioSensore extends StatefulWidget {
  final SensoreBle sensore;
  final String titolo;
  final String spiegazione;
  final IconData icona;
  final IconData iconaVuota;
  final IconData iconaTrovato;

  /// I dati di adesso ("142 bpm"), null se non ne arrivano.
  final String? Function() dati;
  final String aiuto;
  final Widget? extra;

  const _FoglioSensore({
    required this.sensore,
    required this.titolo,
    required this.spiegazione,
    required this.icona,
    required this.iconaVuota,
    required this.iconaTrovato,
    required this.dati,
    required this.aiuto,
    this.extra,
  });

  @override
  State<_FoglioSensore> createState() => _FoglioSensoreState();
}

class _FoglioSensoreState extends State<_FoglioSensore> {
  final trovati = <String, DiscoveredDevice>{};
  StreamSubscription<DiscoveredDevice>? _ricerca;
  Timer? _basta;
  bool cerco = false;

  SensoreBle get s => widget.sensore;

  @override
  void initState() {
    super.initState();
    s.carica().then((_) {
      if (mounted && !s.ricordato) _cerca();
    });
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
    final flusso = await s.cerca();
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
        listenable: s,
        builder: (context, _) {
          final dati = widget.dati();
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(widget.titolo, style: t.titleLarge),
                Text(widget.spiegazione, style: t.bodyMedium),
                if (s.stato == StatoSensore.permessoNegato) ...[
                  Text(
                    'Serve il permesso "Dispositivi nelle vicinanze".',
                    style: t.bodyMedium?.copyWith(color: scheme.error),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        apriImpostazioniGps(StatoGps.permessoNegato),
                    icon: const Icon(Icons.settings_rounded),
                    label: const Text('Apri le impostazioni'),
                  ),
                ],
                if (s.stato == StatoSensore.bluetoothSpento)
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
                        s.stato == StatoSensore.collegato
                            ? widget.icona
                            : widget.iconaVuota,
                        color: scheme.primary,
                      ),
                      title: Text(s.nome),
                      subtitle: Text(switch (s.stato) {
                        StatoSensore.collegato when dati != null =>
                          'Collegato · $dati',
                        StatoSensore.collegato => 'Collegato, aspetto i dati…',
                        StatoSensore.collega =>
                          "Mi collego… (dev'essere acceso e vicino)",
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
                            leading: Icon(widget.iconaTrovato),
                            title: Text(d.name.isEmpty ? s.nomeDiBase : d.name),
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
                    icon: const Icon(Icons.bluetooth_searching_rounded),
                    label: Text(
                      s.ricordato ? 'Cerca un altro sensore' : 'Cerca di nuovo',
                    ),
                  ),
                ?widget.extra,
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    title: Text('Come si collega', style: t.titleSmall),
                    children: [Text(widget.aiuto, style: t.bodySmall)],
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

/// La calibrazione del rullo, passo per passo: i passi li detta il rullo.
class _CalibraRullo extends StatelessWidget {
  const _CalibraRullo();

  // È un widget costante: il foglio non lo ridisegna, deve ascoltare da sé.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: sensoreBici,
    builder: (context, _) => _riquadro(context),
  );

  Widget _riquadro(BuildContext context) {
    final b = sensoreBici;
    final t = Theme.of(context).textTheme;
    // Mentre l'ERG comanda il rullo non si calibra: si fa prima di partire.
    if (!b.rulloInUso || !b.sapeCalibrare || b.wattImposti != null) {
      return const SizedBox.shrink();
    }
    final kmh = b.velocita == null
        ? ''
        : ' Adesso: ${(b.velocita! * 3.6).toStringAsFixed(1)} km/h.';
    final testo = switch (b.faseCalibrazione) {
      FaseCalibrazione.nessuna =>
        '${b.ultimaCalibrazione == null ? 'Mai fatta da qui.' : 'Ultima: ${dataLunga(b.ultimaCalibrazione!)}.'} '
            'Tiene precisi i watt: falla ogni due settimane circa e quando '
            'sposti il rullo, meglio dopo 10 minuti di pedalata.',
      FaseCalibrazione.avvio => 'Chiedo al rullo di iniziare…',
      FaseCalibrazione.accelera =>
        b.calibraKmhA == null
            ? 'Pedala e accelera finché il rullo non ti dice di smettere.$kmh'
            : 'Accelera fino a superare '
                  '${b.calibraKmhA!.toStringAsFixed(0)} km/h.$kmh',
      FaseCalibrazione.smetti =>
        'Smetti di pedalare e aspetta che il rullo si fermi.$kmh',
      FaseCalibrazione.riuscita => 'Calibrazione riuscita.',
      FaseCalibrazione.errore =>
        'Non è riuscita. Controlla che nessun\'altra app usi il rullo e '
            'riprova.',
    };
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text('Calibra il rullo', style: t.titleSmall),
          Text(testo, style: t.bodyMedium),
          if (b.calibrando)
            OutlinedButton(
              onPressed: b.annullaCalibrazione,
              child: const Text('Annulla'),
            )
          else if (b.faseCalibrazione != FaseCalibrazione.riuscita)
            OutlinedButton.icon(
              onPressed: b.calibra,
              icon: const Icon(Icons.tune_rounded),
              label: Text(
                b.faseCalibrazione == FaseCalibrazione.errore
                    ? 'Riprova'
                    : 'Inizia la calibrazione',
              ),
            ),
        ],
      ),
    );
  }
}

/// Circonferenza della ruota, per la velocità dal sensore sulla ruota.
class _Circonferenza extends StatefulWidget {
  const _Circonferenza();

  @override
  State<_Circonferenza> createState() => _CirconferenzaState();
}

class _CirconferenzaState extends State<_Circonferenza> {
  late final campo = TextEditingController(
    text: '${sensoreBici.circonferenza}',
  );

  @override
  void dispose() {
    campo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: campo,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      labelText: 'Circonferenza della ruota',
      suffixText: 'mm',
      helperText: 'Solo per il sensore di velocità. 700×25C: 2105 mm.',
    ),
    onChanged: (v) {
      final mm = int.tryParse(v.trim());
      if (mm != null && mm >= 1000 && mm <= 2400) {
        sensoreBici.impostaCirconferenza(mm);
      }
    },
  );
}
