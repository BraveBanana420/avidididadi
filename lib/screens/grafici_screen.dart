import 'package:flutter/material.dart';

import '../app_state.dart';
import '../assi.dart';
import '../charts.dart';
import '../intervalli.dart';
import '../models.dart';
import '../obiettivo.dart';
import '../percorso.dart';
import '../potenza.dart';
import '../pulse.dart';
import '../serie_sessione.dart';
import '../test_soglia.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';

/// I grafici di un'attività: battito, tempo nelle zone, velocità o passo.
class GraficiScreen extends StatefulWidget {
  final AppState state;
  final Sessione sessione;
  const GraficiScreen({super.key, required this.state, required this.sessione});

  @override
  State<GraficiScreen> createState() => _GraficiScreenState();
}

class _GraficiScreenState extends State<GraficiScreen> {
  late final Future<SerieSessione> _serie = widget.state.serieDi(
    widget.sessione,
  );

  @override
  Widget build(BuildContext context) {
    final s = widget.sessione;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: Text(l10n.grafici(titoloSessione(s.sport, s.tipo))),
      ),
      body: FutureBuilder<SerieSessione>(
        future: _serie,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final serie = snap.data!;
          // Nuoto con i tratti corretti a mano: il passo si rifà da quelli,
          // senza gli errori dell'orologio (una vasca segnata in 11").
          final aMano = stessoSport(s.sport, 'Nuoto')
              ? widget.state.intervalliModificati[s.id]
              : null;
          final inizio = s.inizio ?? (serie.vuota ? s.data : _inizio(serie));
          final velocita = aMano == null
              ? serie.velocita
              : velocitaDaTratti(aMano, inizio);
          if (serie.vuota && velocita.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(24),
              child: Text(l10n.questaAttivitaNonCi),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (serie.fc.isNotEmpty) ...[
                _Battito(serie: serie.fc, inizio: _inizio(serie)),
                const SizedBox(height: 12),
                _Zone(fc: serie.fc, zone: widget.state.zone),
                const SizedBox(height: 12),
              ],
              if (velocita.isNotEmpty) ...[
                _Velocita(serie: velocita, inizio: inizio, sport: s.sport),
                const SizedBox(height: 12),
              ],
              if (serie.altitudine.isNotEmpty) ...[
                _Semplice(
                  titolo: l10n.altitudine,
                  serie: serie.altitudine,
                  inizio: _inizio(serie),
                  unita: 'm',
                  colore: const Color(0xFF8E8E96),
                  numeri: [
                    (l10n.minima, '${_min(serie.altitudine).round()} m'),
                    (l10n.massima, '${massimo(serie.altitudine).round()} m'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (serie.pendenza.isNotEmpty) ...[
                _Semplice(
                  titolo: l10n.pendenza,
                  serie: serie.pendenza,
                  inizio: _inizio(serie),
                  unita: '%',
                  colore: const Color(0xFFFFC233),
                  numeri: [
                    (
                      l10n.salitaMassima,
                      '${massimo(serie.pendenza).round()} %',
                    ),
                    (l10n.discesaMassima, '${_min(serie.pendenza).round()} %'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (serie.potenza.isNotEmpty) ...[
                GraficoPotenza(serie: serie.potenza, inizio: _inizio(serie)),
                const SizedBox(height: 12),
                // Ogni sport con la sua soglia; gli altri non hanno zone.
                if (stessoSport(s.sport, 'Bici')) ...[
                  ZonePotenzaCard(
                    serie: serie.potenza,
                    zone: widget.state.zonePotenza,
                  ),
                  const SizedBox(height: 12),
                  _SogliaDaBici(
                    state: widget.state,
                    sessione: s,
                    serie: serie.potenza,
                  ),
                ] else if (stessoSport(s.sport, 'Corsa')) ...[
                  ListenableBuilder(
                    listenable: widget.state,
                    builder: (context, _) => ZonePotenzaCard(
                      serie: serie.potenza,
                      zone: widget.state.zonePotenzaCorsa,
                      nota: widget.state.ftpCorsaStimata
                          ? l10n.ftpCorsaStimataEta
                          : null,
                      aiuto: l10n.zoneServeTuoPeso,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SogliaDaCorsa(
                    state: widget.state,
                    sessione: s,
                    serie: serie.potenza,
                  ),
                ],
              ],
              if (siCammina(s.sport))
                // Corsa e camminata: passi al minuto, non giri.
                if (passiAlMinuto(serie.cadenza, s.sport) case final p
                    when p.isNotEmpty) ...[
                  _Semplice(
                    titolo: l10n.passiAlMinuto,
                    serie: p,
                    inizio: _inizio(serie),
                    unita: 'ppm',
                    colore: const Color(0xFF2EA8FF),
                    numeri: [
                      (l10n.media, '${media(p).round()} ppm'),
                      (l10n.massima, '${massimo(p).round()} ppm'),
                    ],
                  ),
                  const SizedBox(height: 12),
                ] else
                  const SizedBox.shrink()
              else if (serie.cadenza.isNotEmpty) ...[
                _Semplice(
                  titolo: stessoSport(s.sport, 'Nuoto')
                      ? l10n.bracciateAlMinuto
                      : l10n.cadenza,
                  serie: serie.cadenza,
                  inizio: _inizio(serie),
                  unita: stessoSport(s.sport, 'Bici') ? 'rpm' : l10n.alMinuto,
                  colore: const Color(0xFF2EA8FF),
                  numeri: [
                    (
                      l10n.media,
                      '${media(serie.cadenza.where((c) => c.v > 0).toList()).round()}',
                    ),
                    (l10n.massima, '${massimo(serie.cadenza).round()}'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (notaDatiMancanti(
                    conPercorso: sportConPercorso(s.sport, s.tipo),
                    alChiuso: widget.state.alChiuso(s),
                    intervalsCollegato: widget.state.intervalsCollegato,
                    conAltitudine: serie.altitudine.isNotEmpty,
                    conPotenza: serie.potenza.isNotEmpty,
                  )
                  case final nota?)
                Text(nota, style: Theme.of(context).textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }

  DateTime _inizio(SerieSessione s) =>
      widget.sessione.inizio ??
      [
        ...s.fc,
        ...s.velocita,
        ...s.potenza,
      ].map((c) => c.t).reduce((a, b) => a.isBefore(b) ? a : b);
}

/// Minuti dall'inizio, es. "12:30".
String _dal(DateTime inizio, DateTime t) {
  final s = t.difference(inizio).inSeconds;
  if (s >= 3600) return '${s ~/ 3600}:${two((s % 3600) ~/ 60)}:${two(s % 60)}';
  return '${s ~/ 60}:${two(s % 60)}';
}

class _Riquadro extends StatelessWidget {
  final String titolo;
  final List<(String, String)> numeri;
  final Widget grafico;
  const _Riquadro({
    required this.titolo,
    required this.numeri,
    required this.grafico,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo, style: t.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (nome, valore) in numeri)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(valore, style: t.titleLarge?.cifreFisse),
                      Text(nome, style: t.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          grafico,
        ],
      ),
    );
  }
}

class _Battito extends StatelessWidget {
  final List<Campione> serie;
  final DateTime inizio;
  const _Battito({required this.serie, required this.inizio});

  @override
  Widget build(BuildContext context) {
    final r = ricampiona(serie);
    return _Riquadro(
      titolo: l10n.frequenzaCardiaca,
      numeri: [
        (l10n.media, '${media(serie).round()} bpm'),
        (l10n.massima, '${massimo(serie).round()} bpm'),
      ],
      grafico: GraficoLinea(
        ys: [for (final c in r) c.v],
        etichette: [for (final c in r) _dal(inizio, c.t)],
        fmt: (v) => '${v.round()}',
        colore: const Color(0xFFFF3B47),
        dettagli: [
          for (final c in r) '${c.v.round()} bpm\n${_dal(inizio, c.t)}',
        ],
      ),
    );
  }
}

/// Tempo in ogni zona, come le barre di Garmin: dalla 5 (in alto) alla 1.
class _Zone extends StatelessWidget {
  final List<Campione> fc;
  final Zone zone;
  const _Zone({required this.fc, required this.zone});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tempi = tempoNelleZone(fc, zone);
    final totale = tempi.values.fold(Duration.zero, (a, b) => a + b);
    if (totale == Duration.zero) return const SizedBox.shrink();
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tempoNelleZone, style: t.titleMedium),
          const SizedBox(height: 10),
          for (var n = 5; n >= 1; n--)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 104,
                    child: Text('Z$n ${Zone.nomi[n - 1]}', style: t.bodySmall),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: tempi[n]!.inSeconds / totale.inSeconds,
                        minHeight: 12,
                        color: coloriZoneBattito[n - 1],
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(
                      '${tempi[n]!.inMinutes} min',
                      textAlign: TextAlign.right,
                      style: t.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          Text(l10n.zoneCalcolateSullaTua(zone.fcMax), style: t.bodySmall),
        ],
      ),
    );
  }
}

class _Velocita extends StatelessWidget {
  final List<Campione> serie;
  final DateTime inizio;
  final String sport;
  const _Velocita({
    required this.serie,
    required this.inizio,
    required this.sport,
  });

  @override
  Widget build(BuildContext context) {
    final bici = stessoSport(sport, 'Bici');
    final nuoto = stessoSport(sport, 'Nuoto');
    // In acqua si va piano: gli esercizi di tecnica stanno sotto 0,5 m/s.
    final inMoto = serie.where((c) => c.v >= (nuoto ? 0.2 : 0.5)).toList();
    final r = ricampiona(inMoto.isEmpty ? serie : inMoto);
    final colore = coloreSport(sport);
    if (bici) {
      return _Riquadro(
        titolo: l10n.velocita,
        numeri: [
          (l10n.media, '${(media(inMoto) * 3.6).toStringAsFixed(1)} km/h'),
          (l10n.massima, '${(massimo(inMoto) * 3.6).toStringAsFixed(1)} km/h'),
        ],
        grafico: GraficoLinea(
          ys: [for (final c in r) c.v * 3.6],
          etichette: [for (final c in r) _dal(inizio, c.t)],
          fmt: (v) => v.toStringAsFixed(0),
          colore: colore,
          dettagli: [
            for (final c in r)
              '${(c.v * 3.6).toStringAsFixed(1)} km/h\n${_dal(inizio, c.t)}',
          ],
        ),
      );
    }
    if (nuoto) {
      // Passo ogni 100 m: più in alto = più veloce.
      double passo(double v) => v < 0.2 ? 0 : 100 / v;
      return _Riquadro(
        titolo: l10n.passo,
        numeri: [
          (l10n.medio, '${fmtMinSec(passo(media(inMoto)))} /100 m'),
          (l10n.migliore, '${fmtMinSec(passo(massimo(inMoto)))} /100 m'),
        ],
        grafico: GraficoLinea(
          ys: [for (final c in r) -passo(c.v).clamp(0, 600).toDouble()],
          etichette: [for (final c in r) _dal(inizio, c.t)],
          fmt: (v) => fmtMinSec(-v),
          colore: colore,
          dettagli: [
            for (final c in r)
              '${fmtMinSec(passo(c.v))} /100 m\n${_dal(inizio, c.t)}',
          ],
        ),
      );
    }
    // Passo: più in alto = più veloce, come su Garmin.
    final passi = [for (final c in r) -passoDa(c.v).clamp(0, 900).toDouble()];
    return _Riquadro(
      titolo: l10n.passo,
      numeri: [
        (l10n.medio, '${fmtMinSec(passoDa(media(inMoto)))} /km'),
        (l10n.migliore, '${fmtMinSec(passoDa(massimo(inMoto)))} /km'),
      ],
      grafico: GraficoLinea(
        ys: passi,
        etichette: [for (final c in r) _dal(inizio, c.t)],
        fmt: (v) => fmtMinSec(-v),
        colore: colore,
        // I tratti più lenti (soste, recuperi camminati) restano sul bordo.
        minimoAsse: percentile(passi, 0.05),
        passiAsse: passiTempo,
        dettagli: [
          for (final c in r)
            '${fmtMinSec(passoDa(c.v))} /km\n${_dal(inizio, c.t)}',
        ],
      ),
    );
  }
}

/// Dopo il test, o una corsa più forte della soglia di adesso: propone la
/// soglia nuova (il 95% dei migliori 20 minuti).
class _SogliaDaCorsa extends StatelessWidget {
  final AppState state;
  final Sessione sessione;
  final List<Campione> serie;
  const _SogliaDaCorsa({
    required this.state,
    required this.sessione,
    required this.serie,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final soglia = sogliaDaVenti(serie);
    if (soglia == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final attuale = state.zonePotenzaCorsa?.ftp;
        // Il test fatto col player vale anche per la corsa dell'orologio dello
        // stesso giorno, che ha un altro nome: quella ha i watt.
        final prova = RegExp(r'test|ftp', caseSensitive: false);
        final giorno = soloData(sessione.data);
        final test =
            prova.hasMatch(sessione.tipo) ||
            state.storicoCsv.any(
              (x) =>
                  soloData(x.data) == giorno &&
                  stessoSport(x.sport, 'Corsa') &&
                  prova.hasMatch(x.tipo),
            ) ||
            state.piano.any(
              (r) =>
                  r.data == giorno &&
                  stessoSport(r.sport, 'Corsa') &&
                  prova.hasMatch(r.tipo),
            );
        if (soglia == attuale || !(test || soglia > (attuale ?? 0))) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SuperficiePulse(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tuaFtpCorsaW(soglia), style: t.titleMedium),
                const SizedBox(height: 4),
                Text(l10n.n95DeiTuoiMigliori, style: t.bodySmall),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => state.impostaFtpCorsa(soglia),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.usalaComeFtpCorsa),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dopo un test in bici, o un'uscita più forte dell'FTP di adesso: propone
/// l'FTP nuovo. Dal test vale anche se è più basso.
class _SogliaDaBici extends StatelessWidget {
  final AppState state;
  final Sessione sessione;
  final List<Campione> serie;
  const _SogliaDaBici({
    required this.state,
    required this.sessione,
    required this.serie,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final test = state.testBiciDel(sessione);
    final p = potenzaMiglioreDa(sessione.id, sessione.data, serie, test: test);
    final ftp = p?.ftp;
    if (p == null || ftp == null || ftp < 50 || ftp > 600) {
      return const SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final attuale = state.ftpBici;
        // Un'uscita normale dice solo "almeno": vale se è più alta del 3%.
        final mostra = test.isNotEmpty
            ? ftp != attuale
            : attuale == null || ftp >= attuale * 1.03;
        if (!mostra) return const SizedBox.shrink();
        final come = switch (test) {
          'rampa' => l10n.tsComeRampa(p.w1),
          'venti' => l10n.tsComeVenti(p.w20),
          _ => l10n.tsComeUscita(p.w20),
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SuperficiePulse(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tsTuoFtp(ftp), style: t.titleMedium),
                const SizedBox(height: 4),
                Text(
                  attuale == null ? come : '$come ${l10n.tsAdessoUsi(attuale)}',
                  style: t.bodySmall,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => state.impostaFtp(ftp),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.tsUsaloComeFtp),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// La potenza nel tempo, con media, normalizzata e massima.
class GraficoPotenza extends StatelessWidget {
  final List<Campione> serie;
  final DateTime inizio;
  const GraficoPotenza({super.key, required this.serie, required this.inizio});

  @override
  Widget build(BuildContext context) {
    final r = ricampiona(serie);
    final np = potenzaNormalizzata(serie);
    return _Riquadro(
      titolo: l10n.potenza,
      numeri: [
        (l10n.media, '${media(serie).round()} W'),
        if (np != null) (l10n.normalizzata, '$np W'),
        (l10n.massima, '${massimo(serie).round()} W'),
      ],
      grafico: GraficoLinea(
        ys: [for (final c in r) c.v],
        etichette: [for (final c in r) _dal(inizio, c.t)],
        fmt: (v) => v.toStringAsFixed(0),
        colore: const Color(0xFFB566FF),
        dettagli: [for (final c in r) '${c.v.round()} W\n${_dal(inizio, c.t)}'],
      ),
    );
  }
}

/// Tempo in ogni zona di potenza, dalla 7 (in alto) alla 1. Senza FTP
/// spiega dove scriverlo.
class ZonePotenzaCard extends StatelessWidget {
  final List<Campione> serie;
  final ZonePotenza? zone;
  final String? nota; // da dove viene la soglia, se è solo una stima
  final String? aiuto; // cosa fare se non c'è la soglia
  const ZonePotenzaCard({
    super.key,
    required this.serie,
    required this.zone,
    this.nota,
    this.aiuto,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final z = zone;
    if (z == null) {
      return SuperficiePulse(
        child: Text(aiuto ?? l10n.zonePotenzaServeFtp, style: t.bodySmall),
      );
    }
    final tempi = tempoNelleZonePotenza(serie, z);
    final totale = tempi.values.fold(Duration.zero, (a, b) => a + b);
    if (totale == Duration.zero) return const SizedBox.shrink();
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tempoNelleZonePotenza, style: t.titleMedium),
          const SizedBox(height: 10),
          for (var n = z.numero; n >= 1; n--)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Text('Z$n ${z.nomiZone[n - 1]}', style: t.bodySmall),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: tempi[n]!.inSeconds / totale.inSeconds,
                        minHeight: 12,
                        color: z.colori[n - 1],
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(
                      '${tempi[n]!.inMinutes} min',
                      textAlign: TextAlign.right,
                      style: t.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          Text(nota ?? l10n.zoneCalcolateSulTuo(z.ftp), style: t.bodySmall),
        ],
      ),
    );
  }
}

double _min(List<Campione> s) =>
    s.isEmpty ? 0 : s.map((c) => c.v).reduce((a, b) => a < b ? a : b);

/// Un grafico semplice con due numeri sopra (altitudine, pendenza, potenza…).
class _Semplice extends StatelessWidget {
  final String titolo;
  final List<Campione> serie;
  final DateTime inizio;
  final String unita;
  final Color colore;
  final List<(String, String)> numeri;
  const _Semplice({
    required this.titolo,
    required this.serie,
    required this.inizio,
    required this.unita,
    required this.colore,
    required this.numeri,
  });

  @override
  Widget build(BuildContext context) {
    final r = ricampiona(serie);
    return _Riquadro(
      titolo: titolo,
      numeri: numeri,
      grafico: GraficoLinea(
        ys: [for (final c in r) c.v],
        etichette: [for (final c in r) _dal(inizio, c.t)],
        fmt: (v) => v.toStringAsFixed(0),
        colore: colore,
        dettagli: [
          for (final c in r)
            '${c.v.toStringAsFixed(c.v.abs() < 10 ? 1 : 0)} $unita\n${_dal(inizio, c.t)}',
        ],
      ),
    );
  }
}
