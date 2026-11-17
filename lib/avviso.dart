import 'package:flutter/material.dart';

import 'l10n/lingua.dart';

/// Tempo minimo per poter toccare "Annulla" prima che l'avviso sparisca.
const minimoConAnnulla = Duration(milliseconds: 3500);

/// Quanto resta un avviso: poco, ma abbastanza da leggerlo tutto.
Duration durataAvviso(String testo, {bool conAnnulla = false}) {
  final ms = (2000 + testo.length * 25).clamp(2000, 5000);
  final durata = Duration(milliseconds: ms);
  return conAnnulla && durata < minimoConAnnulla ? minimoConAnnulla : durata;
}

/// L'avviso in basso di tutta l'app: si chiude da solo o scorrendolo in
/// qualsiasi direzione. Con [annulla] mostra il tasto "Annulla" con il bordo.
///
/// Il tasto è nel contenuto e non in `SnackBar.action`: con `action` Flutter
/// tiene l'avviso aperto finché non lo si tocca, e non permette il bordo.
SnackBar avviso({
  required Widget content,
  Duration? duration,
  VoidCallback? annulla,
}) {
  final testo = content is Text ? content.data ?? '' : '';
  return SnackBar(
    padding: EdgeInsets.zero,
    // Il Dismissible di SnackBar segue un solo asse: l'altro è in _ScorriPerChiudere.
    dismissDirection: DismissDirection.horizontal,
    duration: duration ?? durataAvviso(testo, conAnnulla: annulla != null),
    content: _ScorriPerChiudere(
      child: annulla == null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: content,
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 10, 2),
              child: Row(
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 12),
                  _TastoAnnulla(alTocco: annulla),
                ],
              ),
            ),
    ),
  );
}

/// Chiude l'avviso quando lo si scorre in su o in giù.
class _ScorriPerChiudere extends StatefulWidget {
  const _ScorriPerChiudere({required this.child});

  final Widget child;

  @override
  State<_ScorriPerChiudere> createState() => _ScorriPerChiudereState();
}

class _ScorriPerChiudereState extends State<_ScorriPerChiudere> {
  double _percorso = 0;
  bool _chiuso = false;

  void _trascina(DragUpdateDetails d) {
    _percorso += d.delta.dy;
    if (_chiuso || _percorso.abs() < 16) return;
    _chiuso = true;
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(reason: SnackBarClosedReason.swipe);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onVerticalDragStart: (_) => _percorso = 0,
    onVerticalDragUpdate: _trascina,
    child: widget.child,
  );
}

/// "Annulla" a pillola con il bordo. Vale una volta sola: un secondo tocco
/// mentre l'avviso si chiude non deve ripetere l'azione.
class _TastoAnnulla extends StatefulWidget {
  const _TastoAnnulla({required this.alTocco});

  final VoidCallback alTocco;

  @override
  State<_TastoAnnulla> createState() => _TastoAnnullaState();
}

class _TastoAnnullaState extends State<_TastoAnnulla> {
  bool _toccato = false;

  void _tocca() {
    if (_toccato) return;
    _toccato = true;
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(reason: SnackBarClosedReason.action);
    widget.alTocco();
  }

  @override
  Widget build(BuildContext context) {
    // Lo stesso colore del testo dell'avviso, che ha il fondo opposto al tema.
    final colore = Theme.of(context).colorScheme.onInverseSurface;
    return OutlinedButton(
      onPressed: _tocca,
      style: OutlinedButton.styleFrom(
        foregroundColor: colore,
        side: BorderSide(color: colore, width: 1.5),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(l10n.annulla),
    );
  }
}
