import 'package:flutter/material.dart';

/// Animazioni WebP degli esercizi, al posto dei due fotogrammi alternati.
/// Si fanno solo con la ricetta unica (agents/animazione.mjs e
/// docs/animazioni/richieste.json): il suo comando "integra" copia il .webp in
/// assets/exercises/animated/ e aggiunge qui la riga "id dell'esercizio: nome
/// del file" (guida in docs/animazioni/README.md). Solo quelle fatte con gli avatar del progetto
/// e con licenza CC0; da dove viene ognuna è scritto in docs/animazioni/FONTI.md.
const animazioniEsercizi = <String, String>{
  'Bodyweight_Squat': 'bodyweight_squat.webp',
  'Leg_Extensions': 'leg_extensions.webp',
  'Kneeling_Hip_Flexor': 'kneeling_hip_flexor.webp',
};

/// Cartella delle animazioni negli asset dell'app.
const cartellaAnimazioni = 'assets/exercises/animated/';

/// In futuro le animazioni potranno arrivare da un server (es. una VPS):
/// basterà mettere qui l'indirizzo https della cartella. Vuoto = solo asset.
const baseAnimazioniRemote = '';

/// Da dove prendere l'animazione di un esercizio: asset locale o, se c'è
/// una base remota, il suo indirizzo. Null se l'esercizio non ne ha una.
String? animazioneDi(String idEsercizio) {
  final file = animazioniEsercizi[idEsercizio];
  if (file == null) return null;
  return baseAnimazioniRemote.isEmpty
      ? '$cartellaAnimazioni$file'
      : '$baseAnimazioniRemote$file';
}

/// Lo sfondo dei video: un grigio chiaro, anche nel tema scuro.
const sfondoAnimazioni = Color(0xFFD9D9DB);

/// Il WebP animato di un esercizio in un riquadro 2:1 con angoli arrotondati.
/// Si decodifica alla larghezza del file (640 px) e solo quando è sullo
/// schermo, cioè nel dettaglio dell'esercizio.
class AnimazioneWebp extends StatelessWidget {
  final String sorgente;
  const AnimazioneWebp(this.sorgente, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget errore(BuildContext c, Object e, StackTrace? s) => Center(
      child: Icon(Icons.broken_image_rounded, color: scheme.onSurfaceVariant),
    );
    return AspectRatio(
      aspectRatio: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: sfondoAnimazioni,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: sorgente.startsWith('https://')
              ? Image.network(
                  sorgente,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  cacheWidth: 640,
                  errorBuilder: errore,
                )
              : Image.asset(
                  sorgente,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  cacheWidth: 640,
                  errorBuilder: errore,
                ),
        ),
      ),
    );
  }
}
