/// CSV da importare: oltre non è un elenco di allenamenti (e riempirebbe la
/// memoria).
const maxByteCsv = 20 * 1024 * 1024;

String _esc(String s) =>
    (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r'))
    ? '"${s.replaceAll('"', '""')}"'
    : s;

/// Compone il CSV: mette tra virgolette i campi con virgole, virgolette o a
/// capo, e chiude con un a capo finale.
String toCsv(List<List<String>> rows) =>
    '${rows.map((r) => r.map(_esc).join(',')).join('\n')}\n';

/// Legge un CSV: gestisce i campi tra virgolette ("" vale una virgoletta), gli
/// a capo \r\n e scarta le righe vuote.
List<List<String>> parseCsv(String text, {String sep = ','}) {
  final rows = <List<String>>[];
  var row = <String>[];
  final campo = StringBuffer();
  var tra = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (tra) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          campo.write('"');
          i++;
        } else {
          tra = false;
        }
      } else {
        campo.write(c);
      }
    } else if (c == '"') {
      tra = true;
    } else if (c == sep) {
      row.add(campo.toString());
      campo.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(campo.toString());
      campo.clear();
      rows.add(row);
      row = <String>[];
    } else {
      campo.write(c);
    }
  }
  if (campo.isNotEmpty || row.isNotEmpty) {
    row.add(campo.toString());
    rows.add(row);
  }
  return rows.where((r) => !(r.length == 1 && r[0].isEmpty)).toList();
}

/// CSV letto per nome di colonna (l'ordine delle colonne non conta).
class Tabella {
  /// Collega il nome della colonna (in minuscolo) alla sua posizione.
  final Map<String, int> idx;

  /// Le righe dei dati, senza l'intestazione.
  final List<List<String>> righe;

  /// Costruisce la tabella con l'indice delle colonne e le sue righe.
  Tabella(this.idx, this.righe);

  /// Valore della colonna (già senza spazi), '' se manca o la riga è corta.
  String v(List<String> r, String col) {
    final i = idx[col];
    return (i == null || i >= r.length) ? '' : r[i].trim();
  }

  /// Vero se ci sono tutte le colonne indicate.
  bool ha(List<String> colonne) => colonne.every(idx.containsKey);

  /// Tabella dal testo: toglie il BOM, sceglie ; o , dalla prima riga e
  /// restituisce null se il testo è vuoto.
  static Tabella? da(String testo) {
    final t = testo.replaceFirst('\ufeff', '');
    final prima = t.split('\n').first;
    final sep = ';'.allMatches(prima).length > ','.allMatches(prima).length
        ? ';'
        : ',';
    final rows = parseCsv(t, sep: sep);
    if (rows.isEmpty) return null;
    final idx = <String, int>{};
    for (var i = 0; i < rows[0].length; i++) {
      idx[rows[0][i].trim().toLowerCase()] = i;
    }
    return Tabella(idx, rows.sublist(1));
  }
}
