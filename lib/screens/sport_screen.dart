import 'package:flutter/material.dart';

import '../pulse.dart';
import '../arrampicata.dart';
import '../charts.dart';
import '../models.dart';
import '../widgets.dart';

/// Dashboard di un singolo sport nel periodo scelto in Progressi.
class SportScreen extends StatelessWidget {
  final String sport;
  final List<Sessione> sessioni;
  final List<DateTime> inizi; // lunedì di ogni settimana del periodo
  final List<SedutaArrampicata> arrampicate; // vie, blocchi e gradi segnati
  const SportScreen({
    super.key,
    required this.sport,
    required this.sessioni,
    required this.inizi,
    this.arrampicate = const [],
  });

  DateTime _lunedi(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));

  @override
  Widget build(BuildContext context) {
    final d = _Dati(this);
    final sp = sport.toLowerCase();
    final tiles = <_Tile>[];
    final grafici = <_Grafico>[];

    switch (sp) {
      case 'corsa':
        tiles.addAll([
          _Tile('${d.km.toStringAsFixed(1)} km', 'distanza totale'),
          _Tile('${sessioni.length}', 'uscite'),
          _Tile(d.passoMedio(), 'passo medio (min/km)'),
          _Tile('${d.maxKm.toStringAsFixed(1)} km', 'corsa più lunga'),
          _Tile(d.migliorRitmo(minKm: 3), 'passo migliore (≥ 3 km)'),
          _Tile(d.fcMedia(), 'FC media'),
        ]);
        grafici.addAll([
          d.settimanale('Km a settimana', (s) => s.distanzaKm, 1),
          d.perSessione(
            'Passo per uscita (min/km)',
            ritmo,
            (v) => fmtRitmo(sport, v),
          ),
          d.perSessione(
            'Distanza per uscita (km)',
            (s) => s.distanzaKm > 0 ? s.distanzaKm : null,
            (v) => v.toStringAsFixed(1),
          ),
          d.perSessione(
            'Efficienza aerobica (metri per battito)',
            _efficienza,
            (v) => v.toStringAsFixed(2),
          ),
          d.perSessione(
            'FC media per uscita (bpm)',
            _fc,
            (v) => v.toStringAsFixed(0),
          ),
        ]);
      case 'nuoto':
        tiles.addAll([
          _Tile('${(d.km * 1000).round()} m', 'distanza totale'),
          _Tile('${sessioni.length}', 'sessioni'),
          _Tile(d.passoMedio(), 'passo medio (min/100 m)'),
          _Tile('${(d.maxKm * 1000).round()} m', 'sessione più lunga'),
          _Tile(d.migliorRitmo(minKm: 0.3), 'passo migliore (≥ 300 m)'),
          _Tile(d.fcMedia(), 'FC media'),
        ]);
        grafici.addAll([
          d.settimanale('Metri a settimana', (s) => s.distanzaKm * 1000, 0),
          d.perSessione(
            'Passo per sessione (min/100 m)',
            ritmo,
            (v) => fmtRitmo(sport, v),
          ),
          d.perSessione(
            'Metri per sessione',
            (s) => s.distanzaKm > 0 ? s.distanzaKm * 1000 : null,
            (v) => v.toStringAsFixed(0),
          ),
          d.perSessione(
            'FC media per sessione (bpm)',
            _fc,
            (v) => v.toStringAsFixed(0),
          ),
        ]);
      case 'bici':
        tiles.addAll([
          _Tile('${d.km.toStringAsFixed(0)} km', 'distanza totale'),
          _Tile('${sessioni.length}', 'uscite'),
          _Tile(d.velocitaMedia(), 'velocità media (km/h)'),
          _Tile('${d.maxKm.toStringAsFixed(1)} km', 'uscita più lunga'),
          _Tile(d.migliorRitmo(minKm: 5), 'velocità massima media'),
          _Tile(d.fcMedia(), 'FC media'),
        ]);
        grafici.addAll([
          d.settimanale('Km a settimana', (s) => s.distanzaKm, 0),
          d.perSessione(
            'Velocità media per uscita (km/h)',
            ritmo,
            (v) => v.toStringAsFixed(1),
          ),
          d.perSessione(
            'Distanza per uscita (km)',
            (s) => s.distanzaKm > 0 ? s.distanzaKm : null,
            (v) => v.toStringAsFixed(0),
          ),
          d.perSessione(
            'FC media per uscita (bpm)',
            _fc,
            (v) => v.toStringAsFixed(0),
          ),
        ]);
      case 'forza':
        tiles.addAll([
          _Tile('${sessioni.length}', 'sessioni'),
          _Tile('${(d.minuti / 60).toStringAsFixed(1)} h', 'tempo totale'),
          _Tile('${(d.minuti / sessioni.length).round()} min', 'durata media'),
          _Tile(
            (sessioni.length / inizi.length).toStringAsFixed(1),
            'sessioni a settimana',
          ),
          _Tile('${d.maxMin} min', 'sessione più lunga'),
          _Tile(d.fcMedia(), 'FC media'),
        ]);
        grafici.addAll([
          d.settimanale('Sessioni a settimana', (s) => 1, 0),
          d.settimanale('Minuti a settimana', (s) => s.durataMin.toDouble(), 0),
          d.perSessione(
            'Durata per sessione (min)',
            (s) => s.durataMin > 0 ? s.durataMin.toDouble() : null,
            (v) => v.toStringAsFixed(0),
          ),
          d.perSessione(
            'FC media per sessione (bpm)',
            _fc,
            (v) => v.toStringAsFixed(0),
          ),
        ]);
      case 'arrampicata':
        SedutaArrampicata? scheda(Sessione s) =>
            arrampicataDi(arrampicate, s.id, s.data);
        final schede = [for (final s in sessioni) ?scheda(s)];
        final chiuse = schede.fold(0, (a, x) => a + x.chiuse);
        final metri = schede.fold(0, (a, x) => a + x.metri);
        final viaMax = recordArrampicata(schede, Disciplina.falesia);
        final bloccoMax = recordArrampicata(schede, Disciplina.boulder);
        _Grafico gradi(String titolo, Disciplina x) =>
            d.perSessione(titolo, (s) {
              final a = scheda(s);
              if (a == null || a.disciplina != x) return null;
              final l = livello(x, a.gradoMax);
              return l < 0 ? null : l.toDouble();
            }, (v) => gradiDi(x)[v.round().clamp(0, gradiDi(x).length - 1)]);
        tiles.addAll([
          _Tile('${sessioni.length}', 'sessioni'),
          _Tile('${(d.minuti / 60).toStringAsFixed(1)} h', 'tempo totale'),
          if (chiuse > 0) _Tile('$chiuse', 'vie e blocchi chiusi'),
          if (metri > 0) _Tile('$metri m', 'metri saliti'),
          if (viaMax != null) _Tile(viaMax.$1, 'via più difficile'),
          if (bloccoMax != null) _Tile(bloccoMax.$1, 'blocco più difficile'),
          _Tile(d.fcMedia(), 'FC media'),
        ]);
        grafici.addAll(
          [
            d.settimanale(
              'Minuti a settimana',
              (s) => s.durataMin.toDouble(),
              0,
            ),
            d.settimanale(
              'Vie e blocchi chiusi a settimana',
              (s) => (scheda(s)?.chiuse ?? 0).toDouble(),
              0,
            ),
            gradi('Grado più difficile: vie', Disciplina.falesia),
            gradi('Grado più difficile: blocchi', Disciplina.boulder),
            d.perSessione(
              'FC media per sessione (bpm)',
              _fc,
              (v) => v.toStringAsFixed(0),
            ),
          ].where((g) => g.ys.any((y) => y > 0)),
        );
      default:
        tiles.addAll([
          _Tile('${sessioni.length}', 'sessioni'),
          _Tile('${(d.minuti / 60).toStringAsFixed(1)} h', 'tempo totale'),
          if (d.km > 0)
            _Tile('${d.km.toStringAsFixed(1)} km', 'distanza totale'),
          _Tile(d.fcMedia(), 'FC media'),
        ]);
        grafici.addAll(
          [
            d.settimanale(
              'Minuti a settimana',
              (s) => s.durataMin.toDouble(),
              0,
            ),
            d.settimanale('Km a settimana', (s) => s.distanzaKm, 1),
            d.perSessione(
              'FC media per sessione (bpm)',
              _fc,
              (v) => v.toStringAsFixed(0),
            ),
          ].where((g) => g.ys.any((y) => y > 0)),
        );
    }

    final t = Theme.of(context).textTheme;
    final colore = coloreSport(sport);
    // Le linee dei grafici nel rosso del tema, ben visibile su entrambi gli sfondi.
    final coloreLinea = Theme.of(context).colorScheme.primary;
    final tipi = <String, int>{};
    for (final s in sessioni) {
      final k = s.tipo.isEmpty ? sport : s.tipo;
      tipi[k] = (tipi[k] ?? 0) + 1;
    }
    final tipiOrdinati = tipi.keys.toList()
      ..sort((a, b) => tipi[b]!.compareTo(tipi[a]!));

    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(iconaSport(sport), color: colore),
            const SizedBox(width: 8),
            Text(sport),
          ],
        ),
      ),
      body: GruppoGrafici(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [
                for (final tile in tiles)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tile.valore, style: t.titleLarge?.cifreFisse),
                          Text(
                            tile.etichetta,
                            style: t.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (tipiOrdinati.length > 1) ...[
              const SizedBox(height: 20),
              Text('Tipi di sessione', style: t.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final k in tipiOrdinati)
                    Chip(label: Text('$k  ${tipi[k]}')),
                ],
              ),
            ],
            for (final g in grafici) ...[
              const SizedBox(height: 20),
              Text(g.titolo, style: t.titleMedium),
              const SizedBox(height: 8),
              GraficoLinea(
                ys: g.ys,
                etichette: g.et,
                fmt: g.fmt,
                colore: coloreLinea,
                dettagli: g.det,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

double? _fc(Sessione s) => s.fcMedia > 0 ? s.fcMedia.toDouble() : null;

/// Metri percorsi per battito cardiaco: più alto è, più si è efficienti.
double? _efficienza(Sessione s) {
  if (s.distanzaKm <= 0 || s.durataMin <= 0 || s.fcMedia <= 0) return null;
  return s.distanzaKm * 1000 / (s.durataMin * s.fcMedia);
}

class _Tile {
  final String valore;
  final String etichetta;
  const _Tile(this.valore, this.etichetta);
}

class _Grafico {
  final String titolo;
  final List<double> ys;
  final List<String> et;
  final String Function(double) fmt;
  final List<String> det; // dettaglio di ogni punto, mostrato al tocco
  const _Grafico(this.titolo, this.ys, this.et, this.fmt, this.det);
}

/// Unità di misura ricavata dal titolo del grafico.
String _unitaDa(String titolo) {
  const fisse = {
    'Km a settimana': 'km',
    'Metri a settimana': 'm',
    'Metri per sessione': 'm',
    'Sessioni a settimana': 'sessioni',
    'Minuti a settimana': 'min',
    'Efficienza aerobica (metri per battito)': 'm/battito',
  };
  final f = fisse[titolo];
  if (f != null) return f;
  final a = titolo.lastIndexOf('(');
  final b = titolo.lastIndexOf(')');
  return a >= 0 && b > a ? titolo.substring(a + 1, b) : '';
}

/// Testo di dettaglio di una sessione: valore del grafico, giorno e dati principali.
String _dettaglioSessione(Sessione s, String valore) {
  final parti = [
    if (s.durataMin > 0) '${s.durataMin} min',
    if (s.distanzaKm > 0)
      s.sport.toLowerCase() == 'nuoto'
          ? '${(s.distanzaKm * 1000).round()} m'
          : '${fmtNum(s.distanzaKm)} km',
    if (s.fcMedia > 0) 'FC ${s.fcMedia} bpm',
  ];
  return [
    valore,
    '${dataLunga(s.data)} ${s.data.year} · ${titoloSessione(s.sport, s.tipo)}',
    if (parti.isNotEmpty) parti.join(' · '),
  ].join('\n');
}

/// Calcoli comuni sulle sessioni di uno sport.
class _Dati {
  final SportScreen w;
  final double km;
  final int minuti;
  final double maxKm;
  final int maxMin;
  _Dati(this.w)
    : km = w.sessioni.fold(0.0, (a, s) => a + s.distanzaKm),
      minuti = w.sessioni.fold(0, (a, s) => a + s.durataMin),
      maxKm = w.sessioni.fold(
        0.0,
        (a, s) => s.distanzaKm > a ? s.distanzaKm : a,
      ),
      maxMin = w.sessioni.fold(0, (a, s) => s.durataMin > a ? s.durataMin : a);

  List<Sessione> get _conDistanza =>
      w.sessioni.where((s) => s.distanzaKm > 0 && s.durataMin > 0).toList();

  String passoMedio() {
    final l = _conDistanza;
    if (l.isEmpty) return '-';
    final m = l.fold(0, (a, s) => a + s.durataMin);
    final k = l.fold(0.0, (a, s) => a + s.distanzaKm);
    final v = w.sport.toLowerCase() == 'nuoto' ? m / (k * 10) : m / k;
    return fmtRitmo(w.sport, v);
  }

  String velocitaMedia() {
    final l = _conDistanza;
    if (l.isEmpty) return '-';
    final m = l.fold(0, (a, s) => a + s.durataMin);
    final k = l.fold(0.0, (a, s) => a + s.distanzaKm);
    return (k / (m / 60)).toStringAsFixed(1);
  }

  /// Miglior ritmo tra le sessioni di almeno [minKm]: il più basso, o il più alto per la bici.
  String migliorRitmo({required double minKm}) {
    final bici = w.sport.toLowerCase() == 'bici';
    final valori = _conDistanza
        .where((s) => s.distanzaKm >= minKm)
        .map((s) => ritmo(s)!)
        .toList();
    if (valori.isEmpty) return '-';
    final best = valori.reduce(
      (a, b) => bici ? (a > b ? a : b) : (a < b ? a : b),
    );
    return bici ? '${best.toStringAsFixed(1)} km/h' : fmtRitmo(w.sport, best);
  }

  String fcMedia() {
    final l = w.sessioni.where((s) => s.fcMedia > 0).toList();
    if (l.isEmpty) return '-';
    return '${(l.fold(0, (a, s) => a + s.fcMedia) / l.length).round()} bpm';
  }

  _Grafico settimanale(String titolo, double Function(Sessione) f, int dec) {
    final unita = _unitaDa(titolo);
    final n = w.inizi.length;
    final indice = {for (var i = 0; i < n; i++) isoData(w.inizi[i]): i};
    final somma = List<double>.filled(n, 0);
    final conta = List<int>.filled(n, 0);
    for (final s in w.sessioni) {
      final i = indice[isoData(w._lunedi(s.data))];
      if (i == null) continue;
      somma[i] += f(s);
      conta[i]++;
    }
    final et = [for (final d in w.inizi) '${d.day}/${d.month}'];
    String sessioni(int c) => '$c ${c == 1 ? 'sessione' : 'sessioni'}';
    return _Grafico(titolo, somma, et, (v) => v.toStringAsFixed(dec), [
      for (var i = 0; i < n; i++)
        '${somma[i].toStringAsFixed(dec)} $unita\n'
            'Settimana dal ${et[i]}'
            '${unita == 'sessioni' ? '' : ' · ${sessioni(conta[i])}'}',
    ]);
  }

  _Grafico perSessione(
    String titolo,
    double? Function(Sessione) f,
    String Function(double) fmt,
  ) {
    final unita = _unitaDa(titolo);
    final l = w.sessioni.where((s) => f(s) != null).toList()
      ..sort((a, b) => a.data.compareTo(b.data));
    return _Grafico(
      titolo,
      [for (final s in l) f(s)!],
      [for (final s in l) '${s.data.day}/${s.data.month}'],
      fmt,
      [for (final s in l) _dettaglioSessione(s, '${fmt(f(s)!)} $unita'.trim())],
    );
  }
}
