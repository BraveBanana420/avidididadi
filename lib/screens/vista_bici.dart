import 'package:flutter/material.dart';

import '../esecuzione.dart';
import '../obiettivo.dart';
import '../potenza.dart';
import '../pulse.dart';
import '../serie_sessione.dart';
import 'profilo_allenamento.dart';

// La schermata della bici al chiuso durante l'allenamento: tutti i dati in
// una pagina, senza scorrere. In alto potenza e battito, poi il blocco in
// corso con il suo timer e quello dopo, in basso il diagramma della seduta.

/// Quello che la vista mostra: lo prepara la schermata dell'allenamento.
class DatiVistaBici {
  final int? watt;
  final int wattMedia;
  final int wattMassimo;
  final List<Campione> seriePotenza;
  final ZonePotenza? zonePotenza;
  final int? bpm;
  final Zone zone;
  final int? calorie;
  final String cadenza;
  final String velocita;
  final String km;
  final bool sensoriRicordati; // rullo o misuratore già scelti
  final String titolo;
  final String dettaglio;
  final String intensita; // scritta per esteso, per chi non ha i watt
  final String note;
  final (int, int)? range; // watt da tenere nel blocco
  final String obiettivo2; // obiettivo secondario, es. "85-90 rpm"
  final int versoSecondario; // 1 sopra, -1 sotto, 0 dentro
  final int? wattErg; // watt che il rullo sta tenendo
  final int? restano; // secondi; null = blocco senza tempo, si conta in su
  final int trascorso; // secondi nel blocco
  final int durata; // secondi del blocco (0 = senza tempo)
  final bool pausa;
  final bool recupero;
  final List<BarraAllenamento>? barre;
  final int corrente;
  final bool comandabile; // il rullo accetta i comandi
  final bool ergAcceso;
  final double ergScala;
  const DatiVistaBici({
    this.watt,
    this.wattMedia = 0,
    this.wattMassimo = 0,
    this.seriePotenza = const [],
    this.zonePotenza,
    this.bpm,
    required this.zone,
    this.calorie,
    this.cadenza = '–',
    this.velocita = '–',
    this.km = '0,00',
    this.sensoriRicordati = false,
    required this.titolo,
    this.dettaglio = '',
    this.intensita = '',
    this.note = '',
    this.range,
    this.obiettivo2 = '',
    this.versoSecondario = 0,
    this.wattErg,
    this.restano,
    this.trascorso = 0,
    this.durata = 0,
    this.pausa = false,
    this.recupero = false,
    this.barre,
    this.corrente = 0,
    this.comandabile = false,
    this.ergAcceso = true,
    this.ergScala = 1,
  });
}

/// Sotto quest'altezza (telefoni piccoli, tastiera) la pagina scorre.
const _altezzaMinima = 500.0;

class VistaBici extends StatelessWidget {
  final DatiVistaBici dati;
  final VoidCallback apriSensori;
  final VoidCallback apriBattito;
  final ValueChanged<bool> cambiaErg;
  final ValueChanged<double> cambiaScala;
  const VistaBici({
    super.key,
    required this.dati,
    required this.apriSensori,
    required this.apriBattito,
    required this.cambiaErg,
    required this.cambiaScala,
  });

  @override
  Widget build(BuildContext context) {
    final d = dati;
    final sopra = <Widget>[
      _Principali(dati: d, apriSensori: apriSensori, apriBattito: apriBattito),
      _Piccoli(dati: d, apriSensori: apriSensori),
      _BloccoInCorso(dati: d),
      if (d.comandabile)
        ControlloErg(
          acceso: d.ergAcceso,
          watt: d.wattErg,
          scala: d.ergScala,
          cambia: cambiaErg,
          scalaCambia: cambiaScala,
        )
      else if (!d.sensoriRicordati)
        _CollegaSensori(onTap: apriSensori),
    ];
    final diagramma = [
      if ((d.barre, d.zonePotenza) case (final barre?, final zp?))
        DiagrammaInCorso(
          barre: barre,
          zone: zp,
          corrente: d.corrente,
          trascorso: d.trascorso,
          durata: d.durata,
          conPoi: false,
        ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        const margine = EdgeInsets.fromLTRB(16, 8, 16, 4);
        if (box.maxHeight < _altezzaMinima) {
          return SingleChildScrollView(
            padding: margine,
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [...sopra, ...diagramma],
            ),
          );
        }
        return Padding(
          padding: margine,
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...sopra,
              // Lo spazio che avanza va al grafico; se è poco, non si mostra.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, spazio) =>
                      spazio.maxHeight < 64 || d.seriePotenza.length < 2
                      ? const SizedBox.shrink()
                      : GraficoPotenzaLive(dati: d),
                ),
              ),
              ...diagramma,
            ],
          ),
        );
      },
    );
  }
}

/// Riquadro piatto dei dati.
class _Riquadro extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  const _Riquadro({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(14, 8, 14, 10),
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainer,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// Potenza e battito grandi, con la zona in cui si è.
class _Principali extends StatelessWidget {
  final DatiVistaBici dati;
  final VoidCallback apriSensori;
  final VoidCallback apriBattito;
  const _Principali({
    required this.dati,
    required this.apriSensori,
    required this.apriBattito,
  });

  @override
  Widget build(BuildContext context) {
    final d = dati;
    final zw = d.zonePotenza != null && d.watt != null
        ? d.zonePotenza!.zonaDi(d.watt!)
        : 0;
    final zb = d.bpm == null ? 0 : d.zone.zonaDi(d.bpm!);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Expanded(
            child: _Grande(
              icona: Icons.bolt,
              etichetta: zw > 0 ? 'Potenza · Z$zw' : 'Potenza',
              valore: d.watt?.toString() ?? '–',
              unita: 'W',
              colori: d.zonePotenza == null ? null : coloriZonePotenza,
              zona: zw,
              onTap: apriSensori,
            ),
          ),
          Expanded(
            child: _Grande(
              icona: Icons.favorite,
              etichetta: zb > 0 ? 'Battito · Z$zb' : 'Battito',
              valore: d.bpm?.toString() ?? '–',
              unita: 'bpm',
              colori: coloriZoneBattito,
              zona: zb,
              onTap: apriBattito,
            ),
          ),
        ],
      ),
    );
  }
}

class _Grande extends StatelessWidget {
  final IconData icona;
  final String etichetta;
  final String valore;
  final String unita;
  final List<Color>? colori;
  final int zona;
  final VoidCallback onTap;
  const _Grande({
    required this.icona,
    required this.etichetta,
    required this.valore,
    required this.unita,
    required this.colori,
    required this.zona,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return _Riquadro(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icona, size: 14, color: scheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  etichetta.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: valore,
                    style: t.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  TextSpan(
                    text: ' $unita',
                    style: t.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
          if (colori case final c?) ...[
            const SizedBox(height: 4),
            BarraZone(colori: c, zona: zona),
          ],
        ],
      ),
    );
  }
}

/// Una tacca per zona: piena quella in cui si è, sbiadite le altre.
class BarraZone extends StatelessWidget {
  final List<Color> colori;
  final int zona; // da 1; 0 = nessuna
  const BarraZone({super.key, required this.colori, required this.zona});

  @override
  Widget build(BuildContext context) => Row(
    spacing: 2,
    children: [
      for (final (k, c) in colori.indexed)
        Expanded(
          child: Container(
            // La tacca attiva è anche più alta: non si distingue solo dal colore.
            height: k + 1 == zona ? 8 : 4,
            decoration: BoxDecoration(
              color: k + 1 == zona ? c : c.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
    ],
  );
}

/// Calorie, cadenza, velocità e distanza.
class _Piccoli extends StatelessWidget {
  final DatiVistaBici dati;
  final VoidCallback apriSensori;
  const _Piccoli({required this.dati, required this.apriSensori});

  @override
  Widget build(BuildContext context) {
    final d = dati;
    Widget uno(String etichetta, String valore, String unita) => Expanded(
      child: _Riquadro(
        onTap: apriSensori,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: _Piccolo(etichetta, valore, unita),
      ),
    );
    return Row(
      spacing: 6,
      children: [
        uno('Calorie', d.calorie?.toString() ?? '–', 'kcal'),
        uno('Cadenza', d.cadenza, 'rpm'),
        uno('Velocità', d.velocita, 'km/h'),
        uno('Distanza', d.km, 'km'),
      ],
    );
  }
}

class _Piccolo extends StatelessWidget {
  final String etichetta;
  final String valore;
  final String unita;
  const _Piccolo(this.etichetta, this.valore, this.unita);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final piano = t.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Column(
      children: [
        Text(
          etichetta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: piano,
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: valore,
                  style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(text: ' $unita', style: piano),
              ],
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

/// Il blocco in corso: cosa tenere, quanto manca e che cosa viene dopo.
class _BloccoInCorso extends StatelessWidget {
  final DatiVistaBici dati;
  const _BloccoInCorso({required this.dati});

  String? _poi() {
    final barre = dati.barre;
    final zp = dati.zonePotenza;
    if (barre == null || zp == null) return null;
    final k = dati.corrente + 1;
    if (k >= barre.length) return 'Ultimo blocco';
    return 'Poi: ${descriviBarra(barre[k], zp)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final d = dati;
    final r = d.range;
    final zp = d.zonePotenza;
    final zona = r == null || zp == null ? 0 : zp.zonaDi((r.$1 + r.$2) ~/ 2);
    // Con l'ERG i watt li tiene il rullo: l'avviso serve solo a mano.
    final verso = r == null || zp == null || d.watt == null || d.watt == 0
        ? 0
        : d.wattErg != null
        ? 0
        : versoRange(d.watt!, r, zp);
    final principale = d.wattErg != null
        ? '${d.wattErg} W'
        : r != null
        ? fmtRange(r)
        : '';
    final poi = _poi();
    return _Riquadro(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.titolo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleSmall,
                    ),
                    if (principale.isNotEmpty || d.obiettivo2.isNotEmpty)
                      // Primario grande, secondario accanto: "200 W · 85-90 rpm".
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              if (principale.isNotEmpty)
                                TextSpan(
                                  text: [
                                    if (verso > 0) '▼',
                                    if (verso < 0) '▲',
                                    principale,
                                  ].join(' '),
                                  style: t.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: verso == 0 ? null : scheme.error,
                                  ),
                                ),
                              if (d.obiettivo2.isNotEmpty)
                                TextSpan(
                                  text: [
                                    if (principale.isNotEmpty) ' ·',
                                    if (d.versoSecondario > 0) '▼',
                                    if (d.versoSecondario < 0) '▲',
                                    d.obiettivo2,
                                  ].join(' '),
                                  style: t.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: d.versoSecondario == 0
                                        ? null
                                        : scheme.error,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                        ),
                      ),
                    if (principale.isEmpty && d.intensita.isNotEmpty)
                      Text(
                        d.intensita,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyMedium,
                      ),
                    Text(
                      [
                        if (zona > 0) 'Z$zona ${ZonePotenza.nomi[zona - 1]}',
                        if (d.wattErg != null && r != null) fmtRange(r),
                        if (d.dettaglio.isNotEmpty) d.dettaglio,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmtTimer(Duration(seconds: d.restano ?? d.trascorso)),
                    style: t.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    d.pausa
                        ? 'in pausa'
                        : d.restano == null
                        ? 'passati'
                        : d.recupero
                        ? 'di recupero'
                        : 'a fine blocco',
                    style: t.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Si riempie man mano che il blocco va avanti.
          BarraAvanzamento(
            d.durata > 0 ? d.trascorso / d.durata : 0,
            altezza: 6,
          ),
          if (poi != null) ...[
            const SizedBox(height: 6),
            Text(
              poi,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.labelMedium,
            ),
          ] else if (d.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              d.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.labelMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Senza sensori i watt non arrivano: si dice dove collegarli.
class _CollegaSensori extends StatelessWidget {
  final VoidCallback onTap;
  const _CollegaSensori({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return _Riquadro(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.pedal_bike, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Collega il rullo o il misuratore: vedrai potenza, cadenza e '
              'velocità.',
              style: t.bodySmall,
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// La potenza degli ultimi minuti, con il range da tenere, la media e il
/// massimo della seduta.
class GraficoPotenzaLive extends StatelessWidget {
  final DatiVistaBici dati;
  const GraficoPotenzaLive({super.key, required this.dati});

  /// I minuti mostrati: abbastanza per vedere l'andamento del blocco.
  static const finestra = Duration(minutes: 5);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final d = dati;
    return _Riquadro(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Media ${d.wattMedia} W · Massimo ${d.wattMassimo} W',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _Andamento(
                serie: ultimiCampioni(d.seriePotenza, finestra),
                range: d.range,
                linea: scheme.primary,
                fascia: scheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// I campioni dell'ultimo [tratto], contando da quello più recente.
List<Campione> ultimiCampioni(List<Campione> serie, Duration tratto) {
  if (serie.isEmpty) return const [];
  final da = serie.last.t.subtract(tratto);
  var i = serie.length - 1;
  while (i > 0 && serie[i - 1].t.isAfter(da)) {
    i--;
  }
  return serie.sublist(i);
}

class _Andamento extends CustomPainter {
  final List<Campione> serie;
  final (int, int)? range;
  final Color linea;
  final Color fascia;
  _Andamento({
    required this.serie,
    required this.range,
    required this.linea,
    required this.fascia,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (serie.length < 2) return;
    final r = range;
    var tetto = r == null ? 0.0 : r.$2 * 1.15;
    for (final c in serie) {
      if (c.v * 1.05 > tetto) tetto = c.v * 1.05;
    }
    if (tetto <= 0) return;
    double y(double w) => size.height * (1 - w / tetto);
    if (r != null) {
      canvas.drawRect(
        Rect.fromLTRB(0, y(r.$2.toDouble()), size.width, y(r.$1.toDouble())),
        Paint()..color = fascia.withValues(alpha: 0.18),
      );
    }
    final inizio = serie.first.t;
    final durata = serie.last.t.difference(inizio).inMilliseconds;
    if (durata <= 0) return;
    double x(Campione c) =>
        c.t.difference(inizio).inMilliseconds / durata * size.width;
    final tratto = Path()..moveTo(x(serie.first), y(serie.first.v));
    for (final c in serie.skip(1)) {
      tratto.lineTo(x(c), y(c.v));
    }
    final pieno = Path.from(tratto)
      ..lineTo(size.width, size.height)
      ..lineTo(x(serie.first), size.height)
      ..close();
    canvas.drawPath(pieno, Paint()..color = linea.withValues(alpha: 0.22));
    canvas.drawPath(
      tratto,
      Paint()
        ..color = linea
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Andamento old) => true; // arrivano campioni ogni secondo
}

/// "Z4 · 181-210 W · 6:00": come si racconta un blocco.
String descriviBarra(BarraAllenamento b, ZonePotenza zone) {
  final r = b.range;
  final quanto = fmtTimer(Duration(seconds: b.secondi));
  return [
    if (r != null) 'Z${zone.zonaDi((r.$1 + r.$2) ~/ 2)} · ${fmtRange(r)}',
    if (b.obiettivo2.isNotEmpty) b.obiettivo2,
    quanto,
  ].join(' · ');
}

/// Il diagramma con sotto il blocco che viene dopo e quanto manca alla fine.
class DiagrammaInCorso extends StatelessWidget {
  final List<BarraAllenamento> barre;
  final ZonePotenza zone;
  final int corrente; // -1 prima del via
  final int trascorso; // secondi nel blocco in corso
  final int durata; // secondi del blocco in corso (0 se a "Fatto")
  final bool conPoi; // false: il blocco dopo è già scritto altrove
  const DiagrammaInCorso({
    super.key,
    required this.barre,
    required this.zone,
    required this.corrente,
    required this.trascorso,
    required this.durata,
    this.conPoi = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final restoBlocco = corrente < 0 ? 0 : (durata - trascorso).clamp(0, 99999);
    final dopo = [
      for (var k = corrente + 1; k < barre.length; k++) barre[k].secondi,
    ].fold(0, (a, b) => a + b);
    final poi = corrente + 1 < barre.length ? barre[corrente + 1] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfiloAllenamento(
          barre: barre,
          zone: zone,
          corrente: corrente,
          avanzamento: durata > 0 ? trascorso / durata : 0.5,
          altezza: conPoi ? 64 : 48,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                !conPoi
                    ? 'Blocco ${corrente + 1} di ${barre.length}'
                    : poi == null
                    ? 'Ultimo blocco'
                    : '${corrente < 0 ? 'Si parte' : 'Poi'}: '
                          '${descriviBarra(poi, zone)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.labelMedium,
              ),
            ),
            Text(
              'Fine tra ${fmtTimer(Duration(seconds: restoBlocco + dopo))}',
              style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

/// ERG del rullo: acceso o spento, i watt imposti e i tasti −5% / +5%.
class ControlloErg extends StatelessWidget {
  final bool acceso;
  final int? watt;
  final double scala;
  final ValueChanged<bool> cambia;
  final ValueChanged<double> scalaCambia;
  const ControlloErg({
    super.key,
    required this.acceso,
    required this.watt,
    required this.scala,
    required this.cambia,
    required this.scalaCambia,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final percento = ((scala - 1) * 100).round();
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
        child: Row(
          children: [
            Icon(Icons.tune, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    acceso ? 'Rullo in ERG' : 'Rullo libero',
                    style: t.labelLarge,
                  ),
                  Text(
                    acceso
                        ? [
                            watt == null ? 'senza obiettivo' : 'tiene $watt W',
                            if (percento != 0)
                              '${percento > 0 ? '+' : ''}$percento%',
                          ].join(' · ')
                        : 'i watt li decidi tu',
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
            if (acceso) ...[
              IconButton(
                tooltip: '5% in meno',
                onPressed: scala > 0.71
                    ? () => scalaCambia(((scala - 0.05) * 100).round() / 100)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                tooltip: '5% in più',
                onPressed: scala < 1.29
                    ? () => scalaCambia(((scala + 0.05) * 100).round() / 100)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
            Switch(value: acceso, onChanged: cambia),
          ],
        ),
      ),
    );
  }
}
