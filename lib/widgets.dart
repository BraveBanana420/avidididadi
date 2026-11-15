import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models.dart';
import 'tema.dart';
import 'l10n/lingua.dart';
import 'l10n/vocabolario.dart';

/// Riserva in fondo alla pagina lo spazio della barra di navigazione del telefono,
/// così l'ultimo contenuto non resta coperto. Si usa come bottomNavigationBar.
class MargineBarraSistema extends StatelessWidget {
  const MargineBarraSistema({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: MediaQuery.paddingOf(context).bottom);
}

/// Spazio in basso per le finestre che salgono dal basso: la tastiera se è aperta,
/// altrimenti la barra di navigazione del telefono.
double spazioInBasso(BuildContext context) {
  final mq = MediaQuery.of(context);
  return math.max(mq.viewInsets.bottom, mq.viewPadding.bottom);
}

IconData iconaSport(String sport) {
  switch (sport.toLowerCase()) {
    case 'freeletics':
    case 'forza':
      return Icons.fitness_center_rounded;
    case 'corsa':
      return Icons.directions_run_rounded;
    case 'nuoto':
      return Icons.pool_rounded;
    case 'bici':
      return Icons.directions_bike_rounded;
    case 'mobilità':
      return Icons.self_improvement_rounded;
    case 'camminata':
      return Icons.directions_walk_rounded;
    case 'arrampicata':
      return Icons.terrain_rounded;
    case 'attività libera':
      return Icons.bolt_rounded;
    case 'riposo':
      return Icons.bedtime_rounded;
    default:
      return Icons.sports_rounded;
  }
}

/// Quanto stringere un testo largo [larghezza] per farlo stare in [disponibile]:
/// 1 se ci sta già, mai sotto [minima] perché resti leggibile.
double scalaTesto(double larghezza, double disponibile, {double minima = 0.7}) {
  if (larghezza <= disponibile || larghezza <= 0) return 1;
  // Un soffio di margine: gli arrotondamenti non devono far comparire i "…".
  return (disponibile * 0.995 / larghezza).clamp(minima, 1.0);
}

/// Un nome che resta su una riga su ogni telefono: se non ci sta il carattere
/// si rimpicciolisce quanto serve; solo i nomi lunghissimi finiscono con "…".
/// Tiene conto della larghezza dello schermo e della dimensione del testo
/// scelta nelle impostazioni del telefono.
class TestoUnaRiga extends StatelessWidget {
  final String testo;
  final TextStyle? style;
  final TextAlign? textAlign;
  const TestoUnaRiga(this.testo, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final base = DefaultTextStyle.of(context).style.merge(style);
        final misura = TextPainter(
          text: TextSpan(text: testo, style: base),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final scala = scalaTesto(misura.width, box.maxWidth);
        misura.dispose();
        return Text(
          testo,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: base.copyWith(
            fontSize: (base.fontSize ?? 14) * scala,
            letterSpacing: base.letterSpacing == null
                ? null
                : base.letterSpacing! * scala,
          ),
        );
      },
    );
  }
}

// Colori degli sport: standard nei toni del rosso (ben distinti per tinta e
// luminosità) oppure neon. La tinta è la stessa nel tema chiaro e nello scuro,
// ma dove serve cambia la luminosità: ogni colore deve staccare dal fondo
// (contrasto di almeno 3), altrimenti icone e pallini non si vedono.
const _palette = [
  Color(0xFFE57373),
  Color(0xFFFFA270),
  Color(0xFF8D6E63),
  Color(0xFFC2185B),
  Color(0xFFBDBDBD),
];

/// Il colore per il fondo in uso: [scuro] sul grafite, [chiaro] sul bianco.
Color _sulFondo(int scuro, int chiaro) =>
    Color(temaScuroAttivo ? scuro : chiaro);

Color coloreSport(String sport) {
  final n = neonAttivo;
  switch (sport.toLowerCase()) {
    case 'freeletics':
    case 'forza':
      return n ? const Color(0xFF9D4DFF) : _sulFondo(0xFF8E8E96, 0xFF7B7B85);
    case 'corsa':
      return n ? const Color(0xFFFF2E93) : const Color(0xFFFF3B47);
    case 'nuoto':
      return n
          ? _sulFondo(0xFF00B2FF, 0xFF0090DB)
          : _sulFondo(0xFFFF8A3D, 0xFFE0660A);
    case 'bici':
      return n
          ? _sulFondo(0xFF00E0B8, 0xFF009C82)
          : _sulFondo(0xFFCF2450, 0xFFB3123A);
    case 'mobilità':
      return n
          ? _sulFondo(0xFFFF7A00, 0xFFE66400)
          : _sulFondo(0xFFF48FB1, 0xFFDB5C8E);
    case 'camminata':
      return n
          ? _sulFondo(0xFFC6FF3D, 0xFF5F9400)
          : _sulFondo(0xFFE0A33A, 0xFFB87A0F);
    case 'arrampicata':
      return n
          ? _sulFondo(0xFFFFE600, 0xFFA38500)
          : _sulFondo(0xFF4FA3A5, 0xFF3A8C8E);
    case 'attività libera':
      return _sulFondo(0xFF7C83FD, 0xFF6C73F5);
    case 'riposo':
      return temaScuroAttivo
          ? const Color(0xFF6E6E6E)
          : const Color(0xFF9A9AA5);
    default:
      final somma = sport.codeUnits.fold<int>(0, (a, b) => a + b);
      return _palette[somma % _palette.length];
  }
}

class SessioneCard extends StatelessWidget {
  final PianoRiga riga;
  final VoidCallback? onTap;
  const SessioneCard({super.key, required this.riga, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = coloreSport(riga.sport);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: c.withValues(alpha: 0.18),
          child: Icon(iconaSport(riga.sport), color: c),
        ),
        title: Text(titoloSessione(riga.sport, riga.tipo)),
        subtitle: Text(
          riga.durataMin > 0
              ? l10n.min3(mostra(riga.fascia), riga.durataMin)
              : mostra(riga.fascia),
        ),
        trailing: onTap == null
            ? null
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

/// Una sessione già svolta (dallo storico).
class SessioneSvoltaTile extends StatelessWidget {
  final Sessione sessione;
  final VoidCallback? onTap;
  const SessioneSvoltaTile({super.key, required this.sessione, this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = sessione;
    final c = coloreSport(s.sport);
    final parti = <String>[
      // Nome dato dall'app (es. "Milano - Fartlek FC") per le sessioni di Health Connect.
      if (s.id.startsWith('hc-') && s.note.isNotEmpty) s.note,
      if (s.durataMin > 0) '${s.durataMin} min',
      if (s.distanzaKm > 0) '${fmtNum(s.distanzaKm)} km',
      if (s.fcMedia > 0) '${s.fcMedia} bpm',
    ];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: c,
          // La spunta ha il colore del fondo del tema, su ogni sport.
          child: Icon(
            Icons.check_rounded,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        title: Text(titoloSessione(s.sport, s.tipo)),
        subtitle: parti.isEmpty ? null : Text(parti.join(', ')),
      ),
    );
  }
}
