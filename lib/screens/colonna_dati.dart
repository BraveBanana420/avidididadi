import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Sotto questa altezza la minimappa non serve più a orientarsi.
const altezzaMinimaMappa = 150.0;

/// Il testo del blocco non ruba alla mappa più di questa parte dello schermo:
/// oltre, scorre.
const _parteMassimaTesto = 0.3;

/// Anche in poco spazio il nome del blocco deve leggersi.
const _altezzaMinimaTesto = 56.0;

/// La figura dell'esercizio sotto il testo non scende sotto questa altezza:
/// se il testo è lungo, è il testo a scorrere.
const altezzaMinimaFigura = 120.0;

/// Con la mappa aperta ogni altro pezzo prende quello che gli serve, e la mappa
/// tutto il resto: così non resta mai spazio vuoto, qualunque dato ci sia.
/// Senza mappa il resto va a [testo], oppure, se c'è, a [figura] sotto il
/// testo. Su uno schermo piccolo i pezzi scorrono invece di uscire: [numeri] e
/// [testo] devono poter scorrere da soli.
class ColonnaDati extends StatelessWidget {
  final Widget sopra;
  final Widget? mappa;
  final Widget numeri;
  final Widget testo;

  /// Riempie lo spazio sotto il testo (senza mappa): per esempio il movimento
  /// dell'esercizio in grande, quando non ci sono dati dei sensori.
  final Widget? figura;
  const ColonnaDati({
    super.key,
    required this.sopra,
    this.mappa,
    required this.numeri,
    required this.testo,
    this.figura,
  });

  @override
  Widget build(BuildContext context) => CustomMultiChildLayout(
    delegate: _Disposizione(),
    children: [
      LayoutId(id: _Pezzo.sopra, child: sopra),
      if (mappa case final m?) LayoutId(id: _Pezzo.mappa, child: m),
      LayoutId(id: _Pezzo.numeri, child: numeri),
      LayoutId(id: _Pezzo.testo, child: testo),
      if (mappa == null && figura != null)
        LayoutId(id: _Pezzo.figura, child: figura!),
    ],
  );
}

enum _Pezzo { sopra, mappa, numeri, testo, figura }

class _Disposizione extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final h = size.height, w = size.width;
    BoxConstraints fino(double massimo) => BoxConstraints(
      minWidth: w,
      maxWidth: w,
      maxHeight: math.max(0, massimo),
    );

    final conMappa = hasChild(_Pezzo.mappa);
    final alto = layoutChild(_Pezzo.sopra, fino(h)).height;
    final numeri = layoutChild(
      _Pezzo.numeri,
      // Senza mappa si tiene un po' di posto per il testo.
      fino(h - alto - (conMappa ? altezzaMinimaMappa : _altezzaMinimaTesto)),
    ).height;
    final resto = math.max(0.0, h - alto - numeri);

    var y = alto;
    positionChild(_Pezzo.sopra, Offset.zero);
    if (conMappa) {
      final testo = layoutChild(
        _Pezzo.testo,
        fino(
          math.max(
            math.min(h * _parteMassimaTesto, resto - altezzaMinimaMappa),
            math.min(_altezzaMinimaTesto, resto),
          ),
        ),
      ).height;
      final mappa = math.max(0.0, resto - testo);
      layoutChild(
        _Pezzo.mappa,
        BoxConstraints.tightFor(width: w, height: mappa),
      );
      positionChild(_Pezzo.mappa, Offset(0, y));
      y += mappa;
      positionChild(_Pezzo.numeri, Offset(0, y));
      positionChild(_Pezzo.testo, Offset(0, y + numeri));
    } else if (hasChild(_Pezzo.figura)) {
      // Il testo prende quello che gli serve, la figura tutto il resto.
      final testo = layoutChild(
        _Pezzo.testo,
        fino(
          math.min(
            resto,
            math.max(_altezzaMinimaTesto, resto - altezzaMinimaFigura),
          ),
        ),
      ).height;
      layoutChild(
        _Pezzo.figura,
        BoxConstraints.tightFor(width: w, height: math.max(0, resto - testo)),
      );
      positionChild(_Pezzo.numeri, Offset(0, y));
      positionChild(_Pezzo.testo, Offset(0, y + numeri));
      positionChild(_Pezzo.figura, Offset(0, y + numeri + testo));
    } else {
      layoutChild(
        _Pezzo.testo,
        BoxConstraints.tightFor(width: w, height: resto),
      );
      positionChild(_Pezzo.numeri, Offset(0, y));
      positionChild(_Pezzo.testo, Offset(0, y + numeri));
    }
  }

  @override
  bool shouldRelayout(_Disposizione oldDelegate) => false;
}

/// Mostra [grande] se ci sta tutto nell'altezza a disposizione, altrimenti
/// [compatto] (che può scorrere). Così i numeri grandi restano finché c'è
/// posto e, quando arrivano altri dati (sensori della bici, passi), la
/// pagina si riorganizza da sola invece di scorrere.
class GrandeSeCiSta extends MultiChildRenderObjectWidget {
  GrandeSeCiSta({super.key, required Widget grande, required Widget compatto})
    : super(children: [grande, compatto]);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderGrande();
}

class _DatiGrande extends ContainerBoxParentData<RenderBox> {}

class _RenderGrande extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _DatiGrande>,
        RenderBoxContainerDefaultsMixin<RenderBox, _DatiGrande> {
  RenderBox? _scelto;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _DatiGrande) child.parentData = _DatiGrande();
  }

  @override
  void performLayout() {
    final grande = firstChild!;
    final compatto = childAfter(grande)!;
    // Il grande si misura senza limite di altezza: se poi non ci sta, vince
    // il compatto, che si adatta allo spazio e al limite scorre.
    grande.layout(
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      ),
      parentUsesSize: true,
    );
    compatto.layout(constraints, parentUsesSize: true);
    _scelto = grande.size.height <= constraints.maxHeight ? grande : compatto;
    size = constraints.constrain(_scelto!.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_scelto case final c?) context.paintChild(c, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      _scelto?.hitTest(result, position: position) ?? false;

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_scelto case final c?) visitor(c);
  }
}
