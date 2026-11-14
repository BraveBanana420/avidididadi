import 'package:flutter/material.dart';

import '../esecuzione.dart';
import '../intervalli.dart';

import '../potenza.dart';
import '../serie_sessione.dart';

/// Una barra del diagramma: quanto dura e che watt chiede.
class BarraAllenamento {
  final int secondi;
  final (int, int)? range; // null: passo senza obiettivo di potenza
  final String obiettivo2; // obiettivo secondario, es. "85-90 rpm"
  final int? fatto; // watt medi tenuti davvero (solo nel riepilogo)
  const BarraAllenamento(
    this.secondi,
    this.range, [
    this.obiettivo2 = '',
    this.fatto,
  ]);
}

/// Le barre dai blocchi: i passi senza tempo (a "Fatto") contano un minuto.
List<BarraAllenamento> barreDa(List<Blocco> blocchi, ZonePotenza p) => [
  for (final b in blocchi)
    BarraAllenamento(
      b.secondi ?? 60,
      rangeWatt(b.intensita, p, recupero: b.tipo == TipoBlocco.recupero),
      b.obiettivo2,
    ),
];

/// Le barre della seduta com'è andata: una per tratto fatto, larga quanto è
/// durato. Se i tratti hanno i watt previsti (sedute dell'app) la barra è il
/// range da tenere e il segno sopra i watt medi tenuti; altrimenti la barra è
/// alta quanto i watt medi (grigia se mancano). Vuote se non c'è nessun watt.
List<BarraAllenamento> barreFatte(List<IntervalloFatto> tratti) {
  final conTempo = tratti.where((i) => i.secondi > 0).toList();
  final previsti = conTempo.any((i) => i.wattPrevisti != null);
  if (!previsti && !conTempo.any((i) => i.wattMedi > 0)) return const [];
  return [
    for (final i in conTempo)
      previsti
          ? BarraAllenamento(
              i.secondi,
              i.wattPrevisti,
              '',
              i.wattMedi > 0 ? i.wattMedi : null,
            )
          : BarraAllenamento(
              i.secondi,
              i.wattMedi > 0 ? (i.wattMedi, i.wattMedi) : null,
            ),
  ];
}

/// Il diagramma dell'allenamento, come quello di Garmin: una barra per
/// blocco, larga quanto dura, alta quanti watt chiede e colorata con la sua
/// zona. Quelle passate sono sbiadite; la riga bianca è il punto di adesso.
/// Nel riepilogo un trattino su ogni barra segna i watt tenuti davvero.
class ProfiloAllenamento extends StatelessWidget {
  final List<BarraAllenamento> barre;
  final ZonePotenza zone;
  final int corrente; // blocco in corso; -1 = non ancora partiti
  final double avanzamento; // 0-1 del blocco in corso
  final double altezza;
  const ProfiloAllenamento({
    super.key,
    required this.barre,
    required this.zone,
    this.corrente = -1,
    this.avanzamento = 0,
    this.altezza = 64,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Diagramma dell\'allenamento',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: altezza,
          width: double.infinity,
          child: CustomPaint(
            painter: _Disegno(
              barre: barre,
              zone: zone,
              corrente: corrente,
              avanzamento: avanzamento.clamp(0, 1).toDouble(),
              vuota: scheme.surfaceContainerHighest,
              segno: scheme.onSurface,
              fondo: scheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}

class _Disegno extends CustomPainter {
  final List<BarraAllenamento> barre;
  final ZonePotenza zone;
  final int corrente;
  final double avanzamento;
  final Color vuota;
  final Color segno;
  final Color fondo;
  _Disegno({
    required this.barre,
    required this.zone,
    required this.corrente,
    required this.avanzamento,
    required this.vuota,
    required this.segno,
    required this.fondo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totale = barre.fold(0, (t, b) => t + b.secondi);
    if (totale == 0) return;
    // L'altezza piena è il passo più duro; sopra l'FTP resta un po' di spazio,
    // così la sua linea si vede anche nelle sedute facili.
    var tetto = zone.ftp * 1.1;
    for (final b in barre) {
      if (b.range case (_, final a) when a > tetto) tetto = a * 1.0;
      if (b.fatto case final f? when f * 1.05 > tetto) tetto = f * 1.05;
    }
    var x = 0.0;
    double? xAdesso;
    for (final (k, b) in barre.indexed) {
      final w = b.secondi / totale * size.width;
      final r = b.range;
      final centro = r == null ? zone.ftp * 0.4 : (r.$1 + r.$2) / 2;
      final h = (centro / tetto).clamp(0.12, 1.0) * size.height;
      final colore = r == null
          ? vuota
          : coloriZonePotenza[zone.zonaDi(centro.round()) - 1];
      final passata = corrente >= 0 && k < corrente;
      final larga = (w - 1).clamp(1, w).toDouble();
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - h, larga, h),
        Paint()..color = passata ? colore.withValues(alpha: 0.35) : colore,
      );
      // I watt tenuti: un trattino col bordo del fondo, che si vede su ogni
      // colore di zona.
      if (b.fatto case final f?) {
        final y = (size.height * (1 - f / tetto)).clamp(2.0, size.height - 2);
        final trattino = Rect.fromLTWH(x, y - 1.5, larga, 3);
        canvas.drawRect(trattino.inflate(1), Paint()..color = fondo);
        canvas.drawRect(trattino, Paint()..color = segno);
      }
      if (k == corrente) xAdesso = x + w * avanzamento;
      x += w;
    }
    // La linea tratteggiata dell'FTP: sopra si fatica davvero.
    final yFtp = size.height * (1 - zone.ftp / tetto);
    final tratteggio = Paint()
      ..color = segno.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var px = 0.0; px < size.width; px += 8) {
      canvas.drawLine(Offset(px, yFtp), Offset(px + 4, yFtp), tratteggio);
    }
    if (xAdesso != null) {
      canvas.drawRect(
        Rect.fromLTWH(xAdesso - 1.5, 0, 3, size.height),
        Paint()..color = segno,
      );
    }
  }

  @override
  bool shouldRepaint(_Disegno old) =>
      old.corrente != corrente ||
      old.avanzamento != avanzamento ||
      old.barre != barre ||
      old.zone.ftp != zone.ftp ||
      old.vuota != vuota ||
      old.fondo != fondo;
}

/// Un tratto con i watt da tenere, in secondi dall'inizio della seduta.
typedef FasciaWatt = ({int da, int a, (int, int) range});

/// Le fasce dei watt previsti, tratto per tratto: ognuna finisce dove inizia
/// la successiva, così le pause in mezzo non le spostano rispetto ai watt
/// veri. I tratti senza watt previsti non hanno fascia.
List<FasciaWatt> fasceDaTratti(List<IntervalloFatto> tratti) {
  final ordinati = [...tratti]..sort((a, b) => a.inizioS.compareTo(b.inizioS));
  return [
    for (final (k, i) in ordinati.indexed)
      if (i.wattPrevisti case final r? when i.secondi > 0)
        (
          da: i.inizioS,
          a: k + 1 < ordinati.length && ordinati[k + 1].inizioS > i.inizioS
              ? ordinati[k + 1].inizioS
              : i.inizioS + i.secondi,
          range: r,
        ),
  ];
}

/// Le sedute senza watt previsti (quelle di prima, o i blocchi "a
/// sensazione"): una barra per tratto alta quanto i watt medi tenuti.
List<FasciaWatt> fasceDaMedie(List<IntervalloFatto> tratti) => [
  for (final i in tratti)
    if (i.wattMedi > 0 && i.secondi > 0)
      (
        da: i.inizioS,
        a: i.inizioS + i.secondi,
        range: (i.wattMedi, i.wattMedi),
      ),
];

/// I watt di tutta la seduta, un valore ogni [passo] secondi (media dei
/// campioni dentro): la linea resta leggibile anche in un'ora di rullo.
List<({double s, double w})> wattMediati(
  List<Campione> serie,
  DateTime inizio, {
  int passo = 10,
}) {
  final somme = <int, (double, int)>{};
  for (final c in serie) {
    final s = c.t.difference(inizio).inSeconds;
    if (s < 0) continue;
    final k = s ~/ passo;
    final (t, n) = somme[k] ?? (0, 0);
    somme[k] = (t + c.v, n + 1);
  }
  final chiavi = somme.keys.toList()..sort();
  return [
    for (final k in chiavi)
      (s: k * passo + passo / 2, w: somme[k]!.$1 / somme[k]!.$2),
  ];
}

/// Tutta la seduta: dietro le barre dei watt da tenere, colorate per zona e
/// piene fino in basso (in ERG il range è un numero solo: una fascia sottile
/// sparirebbe sotto la linea), sopra la linea dei watt tenuti davvero. Come il grafico durante
/// l'allenamento, ma dall'inizio alla fine.
class GraficoPotenzaSeduta extends StatelessWidget {
  final List<Campione> serie;
  final List<FasciaWatt> fasce;
  final DateTime inizio;
  final ZonePotenza? zone;
  final double altezza;
  const GraficoPotenzaSeduta({
    super.key,
    required this.serie,
    required this.fasce,
    required this.inizio,
    required this.zone,
    this.altezza = 140,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final punti = wattMediati(serie, inizio);
    final fine = [
      if (punti.isNotEmpty) punti.last.s,
      for (final f in fasce) f.a.toDouble(),
    ].fold(0.0, (m, v) => v > m ? v : m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Semantics(
          label: 'Watt previsti e tenuti in tutta la seduta',
          child: SizedBox(
            height: altezza,
            child: CustomPaint(
              painter: _Seduta(
                punti: punti,
                fasce: fasce,
                fine: fine,
                zone: zone,
                linea: scheme.onSurface,
                fascia: scheme.tertiary,
                griglia: scheme.outlineVariant,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0:00', style: t.labelSmall),
            Text(
              fmtTimer(Duration(seconds: fine.round())),
              style: t.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _Seduta extends CustomPainter {
  final List<({double s, double w})> punti;
  final List<FasciaWatt> fasce;
  final double fine;
  final ZonePotenza? zone;
  final Color linea;
  final Color fascia;
  final Color griglia;
  _Seduta({
    required this.punti,
    required this.fasce,
    required this.fine,
    required this.zone,
    required this.linea,
    required this.fascia,
    required this.griglia,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fine <= 0) return;
    var tetto = (zone?.ftp ?? 0) * 1.1;
    for (final p in punti) {
      if (p.w * 1.08 > tetto) tetto = p.w * 1.08;
    }
    for (final f in fasce) {
      if (f.range.$2 * 1.08 > tetto) tetto = f.range.$2 * 1.08;
    }
    if (tetto <= 0) return;
    double x(num s) => s / fine * size.width;
    double y(num w) => size.height * (1 - w / tetto);
    // La riga di base e quella dell'FTP.
    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      Paint()..color = griglia,
    );
    // Le fasce dei watt da tenere: alte quanto il range (almeno 6 px, così
    // anche un watt preciso si vede), nel colore della zona.
    for (final f in fasce) {
      final (da, a) = f.range;
      final centro = (da + a) / 2;
      final colore = zone == null
          ? fascia
          : coloriZonePotenza[zone!.zonaDi(centro.round()) - 1];
      var alto = y(a), basso = y(da);
      if (basso - alto < 6) {
        final m = (alto + basso) / 2;
        alto = m - 3;
        basso = m + 3;
      }
      final r = Rect.fromLTRB(x(f.da), alto, x(f.a) - 1, basso);
      // La barra del blocco, dal basso fino ai watt da tenere.
      canvas.drawRect(
        Rect.fromLTRB(r.left, r.bottom, r.right, size.height),
        Paint()..color = colore.withValues(alpha: 0.20),
      );
      canvas.drawRect(r, Paint()..color = colore.withValues(alpha: 0.32));
      canvas.drawRect(
        Rect.fromLTWH(r.left, r.top, r.width, 2),
        Paint()..color = colore,
      );
    }
    if (zone case final z?) {
      final yFtp = y(z.ftp);
      final tratteggio = Paint()
        ..color = linea.withValues(alpha: 0.45)
        ..strokeWidth = 1;
      for (var px = 0.0; px < size.width; px += 8) {
        canvas.drawLine(Offset(px, yFtp), Offset(px + 4, yFtp), tratteggio);
      }
    }
    if (punti.length < 2) return;
    final tratto = Path()..moveTo(x(punti.first.s), y(punti.first.w));
    for (final p in punti.skip(1)) {
      tratto.lineTo(x(p.s), y(p.w));
    }
    canvas.drawPath(
      tratto,
      Paint()
        ..color = linea
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Seduta old) =>
      old.punti != punti ||
      old.fasce != fasce ||
      old.zone?.ftp != zone?.ftp ||
      old.linea != linea;
}
