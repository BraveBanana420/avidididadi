import 'package:flutter/material.dart';

import '../app_state.dart';
import '../intervalli.dart';
import '../models.dart';
import '../serie_sessione.dart';
import 'profilo_allenamento.dart';
import '../l10n/lingua.dart';

/// La parte del riepilogo che vale solo per la bici: com'è andata la seduta
/// in watt, in un grafico solo. Dietro le barre del programma (i watt da
/// tenere blocco per blocco, come sul rullo in ERG), sopra la linea dei watt
/// tenuti davvero. Senza i watt al secondo (uscite dall'orologio) restano le
/// barre dei blocchi con le medie. Vuoto se non c'è niente da disegnare.
class RiepilogoBici extends StatefulWidget {
  final AppState state;
  final Sessione sessione;

  /// I tratti della seduta, così come sono stati letti.
  final List<IntervalloFatto> tratti;
  const RiepilogoBici({
    super.key,
    required this.state,
    required this.sessione,
    required this.tratti,
  });

  @override
  State<RiepilogoBici> createState() => _RiepilogoBiciState();
}

class _RiepilogoBiciState extends State<RiepilogoBici> {
  /// I watt al secondo delle sedute registrate con l'app (sul telefono,
  /// senza rete).
  late final Future<SerieSessione> _serie =
      widget.sessione.id.startsWith('app-')
      ? widget.state.serieApp(widget.sessione)
      : Future.value(const SerieSessione());

  @override
  Widget build(BuildContext context) {
    final s = widget.sessione;
    final zp = widget.state.zonePotenza;
    final tratti = widget.tratti;
    final barre = zp == null ? const <BarraAllenamento>[] : barreFatte(tratti);
    final previsti = tratti.any((i) => i.wattPrevisti != null);
    // Le sedute di prima non hanno i watt previsti: le barre sono le medie.
    final fasce = previsti ? fasceDaTratti(tratti) : fasceDaMedie(tratti);
    return FutureBuilder<SerieSessione>(
      future: _serie,
      builder: (context, snap) {
        final t = Theme.of(context).textTheme;
        final scheme = Theme.of(context).colorScheme;
        final watt = snap.data?.potenza ?? const <Campione>[];
        final conLinea = watt.length >= 60;
        // Finché i watt non sono letti non si sa quale dei due disegnare.
        if (snap.connectionState != ConnectionState.done ||
            (barre.isEmpty && !conLinea)) {
          return const SizedBox.shrink();
        }
        final nota = t.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(l10n.comAndata2, style: t.titleSmall),
              if (conLinea) ...[
                GraficoPotenzaSeduta(
                  serie: watt,
                  fasce: fasce,
                  inizio: s.inizio ?? watt.first.t,
                  zone: zp,
                ),
                Text(
                  fasce.isEmpty
                      ? l10n.tuoiWattTuttaSeduta
                      : previsti
                      ? l10n.barreColorateSonoProgramma
                      : l10n.barreColorateSonoWatt,
                  style: nota,
                ),
              ] else if (zp != null) ...[
                ProfiloAllenamento(barre: barre, zone: zp, altezza: 64),
                Text(
                  previsti
                      ? l10n.barraBloccoLargaQuanto
                      : l10n.barraBloccoLargaQuanto2,
                  style: nota,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
