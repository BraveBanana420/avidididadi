import 'package:flutter/material.dart';

/// Testo con la formattazione Markdown che usano gli assistenti: titoli,
/// elenchi, grassetto, corsivo, codice, citazioni e tabelle semplici.
/// Selezionabile, con i colori del tema.
class TestoFormattato extends StatelessWidget {
  final String testo;
  final Color colore;
  const TestoFormattato(this.testo, {super.key, required this.colore});

  @override
  Widget build(BuildContext context) {
    final blocchi = leggiBlocchi(testo);
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, b) in blocchi.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : _spazioPrima(b)),
              child: _blocco(context, b),
            ),
        ],
      ),
    );
  }

  double _spazioPrima(Blocco b) => switch (b.tipo) {
    TipoBloccoMd.titolo => 12,
    TipoBloccoMd.elenco || TipoBloccoMd.numerato => 4,
    _ => 8,
  };

  Widget _blocco(BuildContext context, Blocco b) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final base = t.bodyMedium!.copyWith(color: colore, height: 1.35);
    switch (b.tipo) {
      case TipoBloccoMd.titolo:
        final stile =
            (b.livello <= 1
                    ? t.titleLarge
                    : b.livello == 2
                    ? t.titleMedium
                    : t.titleSmall)!
                .copyWith(color: colore, fontWeight: FontWeight.w700);
        return Text.rich(TextSpan(children: righeInLinea(b.testo, stile)));
      case TipoBloccoMd.elenco:
      case TipoBloccoMd.numerato:
        return Padding(
          padding: EdgeInsets.only(left: 14.0 * b.livello),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: b.tipo == TipoBloccoMd.numerato ? 24 : 16,
                child: Text(
                  b.tipo == TipoBloccoMd.numerato ? b.segno : '•',
                  style: base.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(children: righeInLinea(b.testo, base)),
                ),
              ),
            ],
          ),
        );
      case TipoBloccoMd.citazione:
        return Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: scheme.primary, width: 3)),
          ),
          child: Text.rich(
            TextSpan(
              children: righeInLinea(
                b.testo,
                base.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ),
        );
      case TipoBloccoMd.codice:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              b.testo,
              style: base.copyWith(fontFamily: 'monospace', fontSize: 12.5),
            ),
          ),
        );
      case TipoBloccoMd.linea:
        return Divider(color: colore.withValues(alpha: 0.3), height: 8);
      case TipoBloccoMd.tabella:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.symmetric(
              inside: BorderSide(color: colore.withValues(alpha: 0.2)),
            ),
            children: [
              for (final (r, riga) in b.celle.indexed)
                TableRow(
                  children: [
                    for (final cella in riga)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: righeInLinea(
                              cella,
                              r == 0
                                  ? base.copyWith(fontWeight: FontWeight.w700)
                                  : base,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      case TipoBloccoMd.paragrafo:
        return Text.rich(TextSpan(children: righeInLinea(b.testo, base)));
    }
  }
}

enum TipoBloccoMd {
  paragrafo,
  titolo,
  elenco,
  numerato,
  citazione,
  codice,
  linea,
  tabella,
}

class Blocco {
  final TipoBloccoMd tipo;
  final String testo;
  final int livello; // titolo: 1-6; elenco: rientro
  final String segno; // "1." negli elenchi numerati
  final List<List<String>> celle;
  const Blocco(
    this.tipo,
    this.testo, {
    this.livello = 0,
    this.segno = '',
    this.celle = const [],
  });
}

final _titolo = RegExp(r'^(#{1,6})\s+(.*?)\s*#*\s*$');
final _elenco = RegExp(r'^(\s*)[-*+•]\s+(.*)$');
final _numerato = RegExp(r'^(\s*)(\d{1,3})[.)]\s+(.*)$');
final _linea = RegExp(r'^\s*([-*_])(\s*\1){2,}\s*$');
final _rigaTabella = RegExp(r'^\s*\|.*\|\s*$');
final _separatoreTabella = RegExp(
  r'^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$',
);

List<String> _celle(String riga) {
  var r = riga.trim();
  if (r.startsWith('|')) r = r.substring(1);
  if (r.endsWith('|')) r = r.substring(0, r.length - 1);
  return [for (final c in r.split('|')) c.trim()];
}

/// Divide il testo in blocchi: titoli, elenchi, paragrafi, codice, tabelle.
List<Blocco> leggiBlocchi(String testo) {
  final righe = testo.replaceAll('\r\n', '\n').split('\n');
  final out = <Blocco>[];
  final paragrafo = <String>[];
  void chiudi() {
    if (paragrafo.isNotEmpty) {
      out.add(Blocco(TipoBloccoMd.paragrafo, paragrafo.join('\n')));
      paragrafo.clear();
    }
  }

  for (var i = 0; i < righe.length; i++) {
    final r = righe[i];
    if (r.trimLeft().startsWith('```')) {
      chiudi();
      final codice = <String>[];
      i++;
      while (i < righe.length && !righe[i].trimLeft().startsWith('```')) {
        codice.add(righe[i]);
        i++;
      }
      out.add(Blocco(TipoBloccoMd.codice, codice.join('\n')));
      continue;
    }
    if (r.trim().isEmpty) {
      chiudi();
      continue;
    }
    // Tabella: riga con |, seguita dalla riga di separazione.
    if (_rigaTabella.hasMatch(r) &&
        i + 1 < righe.length &&
        _separatoreTabella.hasMatch(righe[i + 1])) {
      chiudi();
      final celle = [_celle(r)];
      i += 2;
      while (i < righe.length && _rigaTabella.hasMatch(righe[i])) {
        celle.add(_celle(righe[i]));
        i++;
      }
      i--;
      final colonne = celle.fold(0, (m, c) => c.length > m ? c.length : m);
      out.add(
        Blocco(
          TipoBloccoMd.tabella,
          '',
          celle: [
            for (final c in celle)
              [...c, for (var k = c.length; k < colonne; k++) ''],
          ],
        ),
      );
      continue;
    }
    if (_linea.hasMatch(r)) {
      chiudi();
      out.add(const Blocco(TipoBloccoMd.linea, ''));
      continue;
    }
    final ti = _titolo.firstMatch(r);
    if (ti != null) {
      chiudi();
      out.add(Blocco(TipoBloccoMd.titolo, ti[2]!, livello: ti[1]!.length));
      continue;
    }
    final el = _elenco.firstMatch(r);
    if (el != null) {
      chiudi();
      out.add(Blocco(TipoBloccoMd.elenco, el[2]!, livello: el[1]!.length ~/ 2));
      continue;
    }
    final nu = _numerato.firstMatch(r);
    if (nu != null) {
      chiudi();
      out.add(
        Blocco(
          TipoBloccoMd.numerato,
          nu[3]!,
          livello: nu[1]!.length ~/ 2,
          segno: '${nu[2]}.',
        ),
      );
      continue;
    }
    if (r.trimLeft().startsWith('>')) {
      chiudi();
      final citazione = <String>[];
      while (i < righe.length && righe[i].trimLeft().startsWith('>')) {
        citazione.add(righe[i].trimLeft().substring(1).trimLeft());
        i++;
      }
      i--;
      out.add(Blocco(TipoBloccoMd.citazione, citazione.join('\n')));
      continue;
    }
    paragrafo.add(r.trim());
  }
  chiudi();
  return out;
}

final _inLinea = RegExp(
  r'(\*\*\*(.+?)\*\*\*)' // grassetto corsivo
  r'|(\*\*(.+?)\*\*|__(.+?)__)' // grassetto
  r'|(~~(.+?)~~)' // barrato
  r'|(`([^`]+)`)' // codice
  r'|(\[([^\]]+)\]\(([^)\s]+)\))' // link: si mostra il testo
  r'|((?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*]))' // corsivo con *
  r'|((?<![\w_])_(?!\s)(.+?)(?<!\s)_(?![\w_]))', // corsivo con _
);

/// Grassetto, corsivo, codice e link dentro una riga di testo.
List<InlineSpan> righeInLinea(String testo, TextStyle base) {
  final out = <InlineSpan>[];
  var da = 0;
  for (final m in _inLinea.allMatches(testo)) {
    if (m.start > da) {
      out.add(TextSpan(text: testo.substring(da, m.start), style: base));
    }
    if (m[1] != null) {
      out.addAll(
        righeInLinea(
          m[2]!,
          base.copyWith(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else if (m[3] != null) {
      out.addAll(
        righeInLinea(m[4] ?? m[5]!, base.copyWith(fontWeight: FontWeight.w700)),
      );
    } else if (m[6] != null) {
      out.addAll(
        righeInLinea(
          m[7]!,
          base.copyWith(decoration: TextDecoration.lineThrough),
        ),
      );
    } else if (m[8] != null) {
      out.add(
        TextSpan(
          text: m[9],
          style: base.copyWith(
            fontFamily: 'monospace',
            backgroundColor: base.color?.withValues(alpha: 0.08),
          ),
        ),
      );
    } else if (m[10] != null) {
      out.addAll(
        righeInLinea(
          m[11]!,
          base.copyWith(decoration: TextDecoration.underline),
        ),
      );
    } else {
      out.addAll(
        righeInLinea(
          m[14] ?? m[16]!,
          base.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }
    da = m.end;
  }
  if (da < testo.length) {
    out.add(TextSpan(text: testo.substring(da), style: base));
  }
  return out;
}
