import 'package:flutter/material.dart';

import '../app_state.dart';
import '../charts.dart';
import '../health_connect.dart';
import '../models.dart';
import '../obiettivo.dart';
import '../percorso.dart';
import '../potenza.dart';
import '../pulse.dart';
import '../serie_sessione.dart';
import '../sincronizzazione.dart';
import '../widgets.dart';

/// I grafici di un'attività: battito, tempo nelle zone, velocità o passo.
class GraficiScreen extends StatefulWidget {
  final AppState state;
  final Sessione sessione;
  const GraficiScreen({super.key, required this.state, required this.sessione});

  @override
  State<GraficiScreen> createState() => _GraficiScreenState();
}

class _GraficiScreenState extends State<GraficiScreen> {
  late final Future<SerieSessione> _serie = _carica();

  Future<SerieSessione> _carica() async {
    final s = widget.sessione;
    // Da intervals.icu: tutti i dati dell'orologio (anche quota e potenza).
    final icu = await widget.state.serieIcu(s);
    if (icu != null && !icu.vuota) return icu;
    var serie = const SerieSessione();
    if (s.inizio != null && s.fine != null && s.origine.isNotEmpty) {
      // Con Freeletics il battito arriva dall'orologio: niente filtro sull'app.
      serie = await widget.state.hc.serie(
        s.inizio!,
        s.fine!,
        origine: daFreeletics(s) ? '' : s.origine,
      );
    }
    // Battito, potenza e cadenza dai sensori collegati all'app (rulli,
    // misuratore di potenza, fascia cardio).
    final app = await widget.state.serieApp(s);
    if (!app.vuota) {
      serie = SerieSessione(
        fc: serie.fc.isEmpty ? app.fc : serie.fc,
        velocita: serie.velocita,
        potenza: app.potenza,
        cadenza: app.cadenza,
      );
    }
    if (serie.velocita.isEmpty && sportConPercorso(s.sport, s.tipo)) {
      final r = await widget.state.percorsoDi(s);
      if (r.stato == StatoPercorso.dati && r.percorso != null) {
        serie = SerieSessione(
          fc: serie.fc,
          velocita: velocitaDaPercorso(r.percorso!),
          potenza: serie.potenza,
          cadenza: serie.cadenza,
        );
      }
    }
    return serie;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sessione;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: Text('Grafici · ${titoloSessione(s.sport, s.tipo)}'),
      ),
      body: FutureBuilder<SerieSessione>(
        future: _serie,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final serie = snap.data!;
          if (serie.vuota) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Per questa attività non ci sono dati nel tempo: servono il '
                'battito o la velocità registrati dall\'orologio.',
              ),
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
              if (serie.velocita.isNotEmpty) ...[
                _Velocita(
                  serie: serie.velocita,
                  inizio: _inizio(serie),
                  sport: s.sport,
                ),
                const SizedBox(height: 12),
              ],
              if (serie.altitudine.isNotEmpty) ...[
                _Semplice(
                  titolo: 'Altitudine',
                  serie: serie.altitudine,
                  inizio: _inizio(serie),
                  unita: 'm',
                  colore: const Color(0xFF8E8E96),
                  numeri: [
                    ('Minima', '${_min(serie.altitudine).round()} m'),
                    ('Massima', '${massimo(serie.altitudine).round()} m'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (serie.pendenza.isNotEmpty) ...[
                _Semplice(
                  titolo: 'Pendenza',
                  serie: serie.pendenza,
                  inizio: _inizio(serie),
                  unita: '%',
                  colore: const Color(0xFFFFC233),
                  numeri: [
                    ('Salita massima', '${massimo(serie.pendenza).round()} %'),
                    ('Discesa massima', '${_min(serie.pendenza).round()} %'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (serie.potenza.isNotEmpty) ...[
                GraficoPotenza(serie: serie.potenza, inizio: _inizio(serie)),
                const SizedBox(height: 12),
                ZonePotenzaCard(
                  serie: serie.potenza,
                  zone: widget.state.zonePotenza,
                ),
                const SizedBox(height: 12),
              ],
              if (serie.cadenza.isNotEmpty) ...[
                _Semplice(
                  titolo: 'Cadenza',
                  serie: serie.cadenza,
                  inizio: _inizio(serie),
                  unita: stessoSport(s.sport, 'Bici') ? 'rpm' : 'ppm',
                  colore: const Color(0xFF2EA8FF),
                  numeri: [
                    (
                      'Media',
                      '${media(serie.cadenza.where((c) => c.v > 0).toList()).round()}',
                    ),
                    ('Massima', '${massimo(serie.cadenza).round()}'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (serie.altitudine.isEmpty)
                Text(
                  '${serie.potenza.isEmpty ? 'Altitudine, pendenza e potenza' : 'Altitudine e pendenza'} '
                  'non ci sono: Health Connect non le riceve. Collega '
                  'intervals.icu (Profilo → Dati e collegamenti) per averle.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
                      Text(valore, style: t.titleLarge),
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
      titolo: 'Frequenza cardiaca',
      numeri: [
        ('Media', '${media(serie).round()} bpm'),
        ('Massima', '${massimo(serie).round()} bpm'),
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

  static const _colori = [
    Color(0xFF9A9AA5),
    Color(0xFF2EA8FF),
    Color(0xFF22E07A),
    Color(0xFFFFC233),
    Color(0xFFFF3B47),
  ];

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
          Text('Tempo nelle zone', style: t.titleMedium),
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
                        color: _colori[n - 1],
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
          Text(
            'Zone calcolate sulla tua FC massima (${zone.fcMax} bpm).',
            style: t.bodySmall,
          ),
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
    final inMoto = serie.where((c) => c.v >= 0.5).toList();
    final r = ricampiona(inMoto.isEmpty ? serie : inMoto);
    final colore = coloreSport(sport);
    if (bici) {
      return _Riquadro(
        titolo: 'Velocità',
        numeri: [
          ('Media', '${(media(inMoto) * 3.6).toStringAsFixed(1)} km/h'),
          ('Massima', '${(massimo(inMoto) * 3.6).toStringAsFixed(1)} km/h'),
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
    // Passo: più in alto = più veloce, come su Garmin.
    return _Riquadro(
      titolo: 'Passo',
      numeri: [
        ('Medio', '${fmtMinSec(passoDa(media(inMoto)))} /km'),
        ('Migliore', '${fmtMinSec(passoDa(massimo(inMoto)))} /km'),
      ],
      grafico: GraficoLinea(
        ys: [for (final c in r) -passoDa(c.v).clamp(0, 900).toDouble()],
        etichette: [for (final c in r) _dal(inizio, c.t)],
        fmt: (v) => fmtMinSec(-v),
        colore: colore,
        dettagli: [
          for (final c in r)
            '${fmtMinSec(passoDa(c.v))} /km\n${_dal(inizio, c.t)}',
        ],
      ),
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
      titolo: 'Potenza',
      numeri: [
        ('Media', '${media(serie).round()} W'),
        if (np != null) ('Normalizzata', '$np W'),
        ('Massima', '${massimo(serie).round()} W'),
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
  const ZonePotenzaCard({super.key, required this.serie, required this.zone});

  static const _colori = [
    Color(0xFF9A9AA5),
    Color(0xFF2EA8FF),
    Color(0xFF22E07A),
    Color(0xFFFFC233),
    Color(0xFFFF8A3D),
    Color(0xFFFF3B47),
    Color(0xFFB566FF),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final z = zone;
    if (z == null) {
      return SuperficiePulse(
        child: Text(
          'Per le zone di potenza serve l\'FTP: scrivilo in Profilo → '
          'Zone, oppure impostalo su intervals.icu.',
          style: t.bodySmall,
        ),
      );
    }
    final tempi = tempoNelleZonePotenza(serie, z);
    final totale = tempi.values.fold(Duration.zero, (a, b) => a + b);
    if (totale == Duration.zero) return const SizedBox.shrink();
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tempo nelle zone di potenza', style: t.titleMedium),
          const SizedBox(height: 10),
          for (var n = 7; n >= 1; n--)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      'Z$n ${ZonePotenza.nomi[n - 1]}',
                      style: t.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: tempi[n]!.inSeconds / totale.inSeconds,
                        minHeight: 12,
                        color: _colori[n - 1],
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
          Text('Zone calcolate sul tuo FTP (${z.ftp} W).', style: t.bodySmall),
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
