import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'animazioni_esercizi.dart';
import 'rete.dart';
import 'storage.dart';
import 'l10n/lingua.dart';

const _base =
    'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';

/// Download già avviati, per non scaricare due volte la stessa immagine.
final _inCorso = <String, Future<File?>>{};

/// Restituisce l'immagine dalla cartella dell'app, scaricandola la prima volta.
/// Null se non c'è e non si riesce a scaricarla (per esempio senza rete).
Future<File?> immagineEsercizio(String percorso) =>
    _inCorso.putIfAbsent(percorso, () async {
      try {
        final dir = Directory('${await Storage.cartella()}/esercizi_img');
        final f = File('${dir.path}/${percorso.replaceAll('/', '_')}');
        if (await f.exists() && await f.length() > 0) return f;
        // Una foto di esercizio pesa qualche centinaio di KB.
        final dati = await scaricaLimitato(
          Uri.parse(_base + percorso),
          maxByte: 5 * 1024 * 1024,
          tipo: 'image/',
        );
        if (dati == null) return null;
        await dir.create(recursive: true);
        // Prima su un file temporaneo: un download interrotto non lascia immagini rotte.
        final tmp = File('${f.path}.tmp');
        await tmp.writeAsBytes(dati, flush: true);
        return await tmp.rename(f.path);
      } catch (_) {
        return null;
      } finally {
        _inCorso.remove(percorso);
      }
    });

/// Il movimento di un esercizio: il WebP animato se c'è (vedi
/// animazioni_esercizi.dart), altrimenti le sue foto alternate ogni secondo.
/// [mini]: anteprima piccola, senza la scritta quando manca la rete.
class AnimazioneEsercizio extends StatelessWidget {
  final String id;
  final List<String> immagini;
  final bool mini;
  const AnimazioneEsercizio({
    super.key,
    this.id = '',
    required this.immagini,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final webp = animazioneDi(id);
    return webp != null
        ? AnimazioneWebp(webp)
        // La chiave cambia con l'esercizio: si ricaricano le sue foto, non
        // restano quelle di prima (es. l'anteprima durante la seduta).
        : _DueFotogrammi(
            key: ValueKey(immagini.join('|')),
            immagini: immagini,
            mini: mini,
          );
  }
}

/// Le foto di un esercizio alternate ogni secondo, per mostrare il movimento.
class _DueFotogrammi extends StatefulWidget {
  final List<String> immagini;
  final bool mini;
  const _DueFotogrammi({super.key, required this.immagini, required this.mini});

  @override
  State<_DueFotogrammi> createState() => _DueFotogrammiState();
}

class _DueFotogrammiState extends State<_DueFotogrammi> {
  late final Future<List<File?>> _file = Future.wait(
    widget.immagini.map(immagineEsercizio),
  );
  Timer? _timer;
  int _indice = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Le foto del catalogo sono 3:2 (850×567): stesso formato, niente bande.
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: Colors.white,
          child: FutureBuilder<List<File?>>(
            future: _file,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final file = snap.data!.whereType<File>().toList();
              if (file.isEmpty && widget.mini) {
                return ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              if (file.isEmpty) {
                return ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.immagineNonDisponibileSenza,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (file.length > 1) {
                _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
                  if (mounted) {
                    setState(() => _indice = (_indice + 1) % file.length);
                  }
                });
              }
              return IndexedStack(
                index: _indice % file.length,
                sizing: StackFit.expand,
                children: [
                  for (final f in file) Image.file(f, fit: BoxFit.cover),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
