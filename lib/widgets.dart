import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models.dart';
import 'tema.dart';

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
      return Icons.fitness_center;
    case 'corsa':
      return Icons.directions_run;
    case 'nuoto':
      return Icons.pool;
    case 'bici':
      return Icons.directions_bike;
    case 'mobilità':
      return Icons.self_improvement;
    case 'riposo':
      return Icons.bedtime_outlined;
    default:
      return Icons.sports;
  }
}

// Colori degli sport, diversi per tema: nello scuro toni caldi accanto al
// rosso (forza in grigio); nel chiaro i neon (forza in nero). Cambiano sia la
// tinta sia la luminosità, così si distinguono anche quando sono piccoli.
const _palette = [
  Color(0xFFE57373),
  Color(0xFFFFA270),
  Color(0xFF8D6E63),
  Color(0xFFC2185B),
  Color(0xFFBDBDBD),
];

Color coloreSport(String sport) {
  final scuro = temaScuroAttivo;
  switch (sport.toLowerCase()) {
    case 'freeletics':
    case 'forza':
      return scuro ? const Color(0xFF8E8E96) : const Color(0xFF14141A);
    case 'corsa':
      return scuro ? const Color(0xFFFF3B47) : const Color(0xFFFF2E93);
    case 'nuoto':
      return scuro ? const Color(0xFFFF7A59) : const Color(0xFF2EA8FF);
    case 'bici':
      return scuro ? const Color(0xFFD9324A) : const Color(0xFF00BFB1);
    case 'mobilità':
      return scuro ? const Color(0xFFE8A598) : const Color(0xFFB566FF);
    case 'riposo':
      return scuro ? const Color(0xFF6E6E6E) : const Color(0xFF9A9AA5);
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
              ? '${riga.fascia}, ${riga.durataMin} min'
              : riga.fascia,
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
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
      // Nome dato dall'app (es. "Pistoia - Fartlek FC") per le sessioni di Health Connect.
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
          // Spunta nera sui grigi chiari, bianca su quelli scuri.
          child: Icon(
            Icons.check,
            color: ThemeData.estimateBrightnessForColor(c) == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        title: Text(titoloSessione(s.sport, s.tipo)),
        subtitle: parti.isEmpty ? null : Text(parti.join(', ')),
      ),
    );
  }
}
