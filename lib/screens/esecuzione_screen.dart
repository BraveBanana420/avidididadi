import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../esecuzione.dart';
import '../figura.dart';
import '../glossario.dart';
import '../gps.dart';
import '../models.dart';
import '../obiettivo.dart';
import '../percorso.dart';
import '../pulse.dart';
import '../tema.dart';
import '../sincronizzazione.dart';
import '../widgets.dart';
import 'feedback_sheet.dart';
import 'mappa_percorso.dart';

const _canale = MethodChannel('avidididadi/avvio');

/// Tiene acceso lo schermo durante l'allenamento (no-op fuori da Android).
Future<void> _schermoAcceso(bool acceso) async {
  try {
    await _canale.invokeMethod('schermoAcceso', acceso);
  } catch (_) {}
}

/// Apre la modalità allenamento per una seduta.
void avviaAllenamento(
  BuildContext context,
  AppState state, {
  required String sport,
  required String tipo,
  required String nome,
  required List<WorkoutStep> passi,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => EsecuzioneScreen(
        state: state,
        sport: sport,
        tipo: tipo,
        nome: nome,
        passi: passi,
      ),
    ),
  );
}

/// Modalità allenamento: un esercizio alla volta, con cronometro totale,
/// conto alla rovescia per i blocchi a tempo e i recuperi, e "Fatto" per gli
/// esercizi a ripetizioni.
class EsecuzioneScreen extends StatefulWidget {
  final AppState state;
  final String sport;
  final String tipo;
  final String nome;
  final List<WorkoutStep> passi;
  const EsecuzioneScreen({
    super.key,
    required this.state,
    required this.sport,
    required this.tipo,
    required this.nome,
    required this.passi,
  });

  @override
  State<EsecuzioneScreen> createState() => _EsecuzioneScreenState();
}

class _EsecuzioneScreenState extends State<EsecuzioneScreen> {
  static const _preparazione = 5; // secondi prima del primo esercizio

  late final List<Blocco> blocchi = blocchiDa(widget.passi);
  late final int nPassi = blocchi.isEmpty ? 0 : blocchi.last.passo + 1;
  final totale = Stopwatch();
  final blocco = Stopwatch();
  final tempi = <int, Duration>{}; // tempo impiegato per ogni blocco
  Timer? _tic;
  int i = 0;
  bool preparati = true; // conto alla rovescia iniziale
  bool pausa = false;
  bool finito = false;
  int extra = 0; // secondi aggiunti al recupero con "+15 s"
  int _ultimoBip = -1;
  late bool registra = !widget.state.sessioni.any(
    (s) =>
        s.data == soloData(DateTime.now()) &&
        stessoSport(s.sport, widget.sport),
  );

  /// Corsa e bici: il percorso GPS, raccolto mentre l'allenamento è in corso.
  late final RegistratoreGps? gps = sportConPercorso(widget.sport, widget.tipo)
      ? RegistratoreGps(widget.sport)
      : null;

  Blocco get b => blocchi[i];

  @override
  void initState() {
    super.initState();
    _schermoAcceso(true);
    if (gps == null) {
      blocco.start();
    } else {
      // Il conto alla rovescia parte dopo l'eventuale richiesta del permesso.
      _accendiGps();
    }
    _tic = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _aggiorna(),
    );
  }

  Future<void> _accendiGps() async {
    await gps!.avvia();
    if (!mounted) return;
    setState(() {
      if (preparati) {
        blocco
          ..reset()
          ..start();
      }
    });
  }

  @override
  void dispose() {
    _tic?.cancel();
    _schermoAcceso(false);
    gps?.dispose();
    super.dispose();
  }

  int get _durata => preparati ? _preparazione : (b.secondi ?? 0) + extra;
  int get _restano => _durata - blocco.elapsed.inSeconds;

  void _aggiorna() {
    if (!mounted || pausa || finito) return;
    if (preparati || b.aTempo) {
      final r = _restano;
      if (r <= 3 && r > 0 && r != _ultimoBip) {
        _ultimoBip = r;
        HapticFeedback.selectionClick();
      }
      if (r <= 0) {
        HapticFeedback.heavyImpact();
        _avanti();
        return;
      }
    }
    setState(() {});
  }

  void _nuovoBlocco() {
    blocco
      ..reset()
      ..start();
    extra = 0;
    _ultimoBip = -1;
  }

  void _avanti() {
    if (preparati) {
      setState(() {
        preparati = false;
        totale.start();
        gps?.imposta(true);
        _nuovoBlocco();
      });
      return;
    }
    tempi[i] = (tempi[i] ?? Duration.zero) + blocco.elapsed;
    if (i >= blocchi.length - 1) {
      _fine();
      return;
    }
    setState(() {
      i++;
      _nuovoBlocco();
    });
  }

  void _indietro() {
    if (preparati || i == 0) return;
    setState(() {
      i--;
      _nuovoBlocco();
    });
  }

  void _pausa() {
    setState(() {
      pausa = !pausa;
      if (!preparati) gps?.imposta(!pausa);
      if (pausa) {
        totale.stop();
        blocco.stop();
      } else {
        if (!preparati) totale.start();
        blocco.start();
      }
    });
  }

  void _fine() {
    totale.stop();
    blocco.stop();
    gps?.ferma();
    _schermoAcceso(false);
    HapticFeedback.heavyImpact();
    setState(() => finito = true);
  }

  Future<bool> _confermaUscita() async {
    if (finito || preparati) return true;
    final r = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Interrompere l'allenamento?"),
        content: const Text(
          'Puoi terminarlo qui e vedere il riepilogo, oppure uscire senza salvare.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, 'esci'),
            child: const Text('Esci'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, 'termina'),
            child: const Text('Termina qui'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Continua'),
          ),
        ],
      ),
    );
    if (r == 'termina') {
      tempi[i] = (tempi[i] ?? Duration.zero) + blocco.elapsed;
      _fine();
    }
    return r == 'esci';
  }

  Future<void> _salvaEChiudi({bool feedback = false}) async {
    final navigator = Navigator.of(context);
    final oggi = soloData(DateTime.now());
    final percorso = gps?.percorso;
    // Il percorso si tiene anche se vale la sessione dell'orologio: la mappa
    // lo mostra quando Health Connect non ne ha uno.
    if (percorso != null && !percorso.vuoto) {
      await widget.state.salvaPercorsoApp(oggi, widget.sport, percorso);
    }
    if (registra) {
      await widget.state.registraSvolta(
        Sessione(
          id: 'app-${isoData(oggi)}-${widget.sport.toLowerCase()}',
          data: oggi,
          sport: widget.sport,
          tipo: widget.tipo,
          durataMin: (totale.elapsed.inSeconds / 60).round().clamp(1, 600),
          distanzaKm: percorso == null || percorso.vuoto
              ? 0
              : double.parse(gps!.km.toStringAsFixed(2)),
          fonte: fonteApp,
          note: widget.nome,
        ),
      );
    }
    if (feedback && mounted) {
      await apriFeedback(context, widget.state, oggi, widget.sport);
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: finito || preparati,
      onPopInvokedWithResult: (fatto, _) async {
        if (fatto) return;
        final navigator = Navigator.of(context);
        if (await _confermaUscita()) navigator.pop();
      },
      child: Scaffold(
        bottomNavigationBar: const MargineBarraSistema(),
        body: SfondoPulse(
          child: SafeArea(
            child: blocchi.isEmpty
                ? const Center(child: Text('Questo allenamento non ha passi.'))
                : finito
                ? _riepilogo(context)
                : _esecuzione(context),
          ),
        ),
      ),
    );
  }

  Widget _esecuzione(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final recupero = !preparati && b.tipo == TipoBlocco.recupero;
    final prossimo = blocchi
        .skip(preparati ? 0 : i + 1)
        .where((x) => x.tipo == TipoBlocco.lavoro)
        .firstOrNull;
    final perId = {for (final e in widget.state.esercizi) e.id: e};
    final muscoli = preparati || recupero
        ? null
        : perId[b.esercizio]?.muscoli.toSet();
    final aTempo = preparati || b.aTempo;
    final faseNome = preparati ? '' : maiuscola(b.fase);

    return Column(
      children: [
        // In alto: chiudi, tempo totale, pausa.
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Chiudi',
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  if (await _confermaUscita()) navigator.pop();
                },
                icon: const Icon(Icons.close),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      fmtTimer(totale.elapsed),
                      style: t.titleLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text('tempo totale', style: t.labelSmall),
                  ],
                ),
              ),
              IconButton(
                tooltip: pausa ? 'Riprendi' : 'Pausa',
                onPressed: _pausa,
                icon: Icon(pausa ? Icons.play_arrow : Icons.pause),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Un segmento per esercizio: pieni quelli fatti, mezzo quello in corso.
              Row(
                children: [
                  for (var k = 0; k < nPassi; k++) ...[
                    if (k > 0) const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: !preparati && k < b.passo
                              ? null
                              : !preparati && k == b.passo
                              ? scheme.primary.withValues(alpha: 0.5)
                              : scheme.surfaceContainerHigh,
                          gradient: !preparati && k < b.passo
                              ? LinearGradient(colors: Pulse.di(context).anello)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (gps != null) ...[
                const SizedBox(height: 8),
                _StatoGps(
                  gps: gps!,
                  sport: widget.sport,
                  tempo: totale.elapsed,
                  riaccendi: _accendiGps,
                ),
              ],
              const SizedBox(height: 6),
              Text(
                preparati
                    ? '${widget.nome} · $nPassi esercizi'
                    : 'Esercizio ${b.passo + 1} di $nPassi'
                          '${faseNome.isEmpty ? '' : ' · $faseNome'}',
                style: t.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            children: [
              if (preparati) ...[
                Text('Preparati', style: t.headlineMedium),
                const SizedBox(height: 4),
                if (prossimo != null)
                  Text(
                    'Si parte con: ${prossimo.titolo}',
                    style: t.titleMedium,
                  ),
              ] else if (recupero) ...[
                Text('Recupero', style: t.headlineMedium),
                if (b.note.isNotEmpty) Text(b.note, style: t.bodyLarge),
              ] else ...[
                Text(b.titolo, style: t.headlineMedium),
                if (b.dettaglio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(b.dettaglio, style: t.titleLarge),
                  ),
                if (b.intensita.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Intensità: ${conBpm(b.intensita, widget.state.zone)}',
                      style: t.bodyLarge,
                    ),
                  ),
                if (sensazioneDi(b.intensita) != null)
                  Text(
                    'Come ti devi sentire: ${sensazioneDi(b.intensita)}',
                    style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                if (b.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(b.note, style: t.bodyMedium),
                  ),
              ],
              const SizedBox(height: 24),
              Center(
                child: _Orologio(
                  recupero: recupero,
                  aTempo: aTempo,
                  restano: aTempo ? _restano.clamp(0, 99999).toInt() : 0,
                  totale: aTempo ? _durata : 0,
                  trascorso: blocco.elapsed,
                  pausa: pausa,
                ),
              ),
              if (recupero && prossimo != null) ...[
                const SizedBox(height: 24),
                SuperficiePulse(
                  child: Row(
                    children: [
                      const IconaQuadrata(Icons.skip_next, evidenza: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Poi', style: t.bodySmall),
                            Text(prossimo.titolo, style: t.titleMedium),
                            if (prossimo.dettaglio.isNotEmpty)
                              Text(prossimo.dettaglio, style: t.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (muscoli != null && muscoli.isNotEmpty) ...[
                const SizedBox(height: 16),
                FiguraMuscoliFissa(
                  sesso: widget.state.profilo.sesso,
                  evidenziati: muscoli,
                  didascalia: '',
                ),
              ],
            ],
          ),
        ),
        // In basso: indietro, azione principale, +15 s o salta.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Esercizio precedente',
                iconSize: 28,
                onPressed: preparati || i == 0 ? null : _indietro,
                icon: const Icon(Icons.skip_previous),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PulsantePrincipale(
                  altezza: 64,
                  onPressed: pausa ? null : _avanti,
                  icona: preparati
                      ? Icons.play_arrow
                      : recupero
                      ? Icons.fast_forward
                      : b.aTempo
                      ? Icons.skip_next
                      : Icons.check,
                  testo: preparati
                      ? 'Inizia subito'
                      : recupero
                      ? 'Salta recupero'
                      : b.aTempo
                      ? 'Avanti'
                      : 'Fatto',
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                tooltip: recupero ? '15 secondi in più' : 'Salta',
                iconSize: 28,
                onPressed: pausa
                    ? null
                    : recupero
                    ? () => setState(() => extra += 15)
                    : _avanti,
                icon: recupero
                    ? Text(
                        '+15',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSecondaryContainer,
                        ),
                      )
                    : const Icon(Icons.skip_next),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _riepilogo(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Tempo per esercizio: somma dei blocchi di lavoro di ogni passo.
    final perPasso = <int, (String, Duration)>{};
    for (var k = 0; k < blocchi.length; k++) {
      final x = blocchi[k];
      if (x.tipo != TipoBlocco.lavoro || tempi[k] == null) continue;
      final prima = perPasso[x.passo]?.$2 ?? Duration.zero;
      perPasso[x.passo] = (x.titolo, prima + tempi[k]!);
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Center(
          child: AnelloPulse(
            valore: 1,
            dimensione: 120,
            spessore: 10,
            child: Icon(
              Icons.emoji_events_outlined,
              size: 52,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Allenamento completato!',
          style: t.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${fmtTimer(totale.elapsed)} · ${perPasso.length} esercizi',
          style: t.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (gps != null && !gps!.percorso.vuoto) ...[
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 200,
              child: IgnorePointer(
                child: MappaPercorso(
                  percorso: gps!.percorso,
                  sport: widget.sport,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${fmtKm(gps!.km)} · ${ritmoMedio(widget.sport, gps!.km, totale.elapsed)}',
            style: t.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 20),
        SuperficiePulse(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final (k, e) in perPasso.values.indexed)
                RigaPulse(
                  titolo: e.$1,
                  linea: k < perPasso.length - 1,
                  fine: Text(fmtTimer(e.$2), style: t.titleSmall),
                ),
            ],
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: registra,
            onChanged: (v) => setState(() => registra = v ?? false),
            title: const Text('Segna come fatto'),
            subtitle: const Text(
              "Se l'orologio registra lo stesso allenamento, vale il suo.",
            ),
          ),
        ),
        const SizedBox(height: 8),
        PulsantePrincipale(
          onPressed: () => _salvaEChiudi(feedback: true),
          icona: Icons.rate_review_outlined,
          testo: "Com'è andata?",
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _salvaEChiudi, child: const Text('Chiudi')),
      ],
    );
  }
}

/// Riga del GPS: segnale, distanza e ritmo; se è spento, come accenderlo.
class _StatoGps extends StatelessWidget {
  final RegistratoreGps gps;
  final String sport;
  final Duration tempo;
  final Future<void> Function() riaccendi;
  const _StatoGps({
    required this.gps,
    required this.sport,
    required this.tempo,
    required this.riaccendi,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final (icona, colore, testo) = switch (gps.stato) {
      StatoGps.pronto => (
        Icons.gps_fixed,
        const Color(0xFF22E07A),
        '${fmtKm(gps.km)} · ${ritmoMedio(sport, gps.km, tempo)}'
            ' · GPS ±${gps.precisione.round()} m',
      ),
      StatoGps.cerca || StatoGps.spento => (
        Icons.gps_not_fixed,
        const Color(0xFFFFC233),
        gps.km > 0
            ? '${fmtKm(gps.km)} · cerco il segnale GPS…'
            : "Cerco il segnale GPS… meglio all'aperto",
      ),
      StatoGps.permessoNegato => (
        Icons.gps_off,
        scheme.error,
        'GPS non permesso: tocca per attivarlo',
      ),
      StatoGps.disattivato => (
        Icons.gps_off,
        scheme.error,
        'Posizione spenta: tocca per accenderla',
      ),
    };
    final spento =
        gps.stato == StatoGps.permessoNegato ||
        gps.stato == StatoGps.disattivato;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: spento
          ? () async {
              // Prima si richiede il permesso; se resta negato, le impostazioni.
              await riaccendi();
              if (gps.stato == StatoGps.permessoNegato ||
                  gps.stato == StatoGps.disattivato) {
                await apriImpostazioniGps(gps.stato);
              }
            }
          : null,
      child: Row(
        children: [
          Icon(icona, size: 16, color: colore),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              testo,
              style: t.bodySmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il tempo in grande: anello sfumato che si svuota per i blocchi a tempo,
/// cronometro che sale per quelli a ripetizioni.
class _Orologio extends StatelessWidget {
  final bool recupero;
  final bool aTempo;
  final int restano; // secondi
  final int totale;
  final Duration trascorso;
  final bool pausa;
  const _Orologio({
    required this.recupero,
    required this.aTempo,
    required this.restano,
    required this.totale,
    required this.trascorso,
    required this.pausa,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final cifre = t.displayLarge?.copyWith(
      fontSize: 68,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Semantics(
      label: aTempo ? 'Mancano $restano secondi' : 'Tempo trascorso',
      child: AnelloPulse(
        valore: aTempo && totale > 0 ? restano / totale : 0,
        dimensione: 240,
        spessore: 14,
        alone: aTempo,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              aTempo
                  ? fmtTimer(Duration(seconds: restano))
                  : fmtTimer(trascorso),
              style: cifre,
            ),
            const SizedBox(height: 4),
            Text(
              pausa
                  ? 'in pausa'
                  : aTempo
                  ? (recupero ? 'mancano' : 'poi passa da solo')
                  : 'tocca Fatto quando hai finito',
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
