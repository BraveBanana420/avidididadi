import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'csv.dart';
import 'models.dart';

/// Backup di tutti i dati in un unico file: i CSV e la foto del profilo, in un
/// JSON compresso. La chiave dell'assistente non c'è (sta nell'archivio cifrato)
/// e nemmeno il token di Health Connect, che vale solo su quel telefono: dopo
/// un ripristino la prossima sincronizzazione rilegge lo storico.

const _formato = 'avidididadi-backup';
const _versione = 1;

/// File che non vanno nel backup.
const esclusiDalBackup = {'health_connect.csv'};

final _nomeCsv = RegExp(r'^[a-z0-9_]+\.csv$');
final _nomeFoto = RegExp(r'^foto_\d+\.jpg$');

bool fileDaSalvare(String nome) =>
    _nomeCsv.hasMatch(nome) && !esclusiDalBackup.contains(nome);

class DatiBackup {
  final DateTime creato;
  final Map<String, String> csv; // nome del file → contenuto
  final String? nomeFoto;
  final Uint8List? foto;
  const DatiBackup(this.creato, this.csv, {this.nomeFoto, this.foto});

  int _righe(String nome) {
    final t = csv[nome] == null ? null : Tabella.da(csv[nome]!);
    return t?.righe.length ?? 0;
  }

  /// Riassunto per la conferma prima del ripristino.
  String get riassunto => [
    'Creato il ${dataLunga(creato)}',
    '${_righe('sessioni.csv') + _righe('health_connect_sessioni.csv')} sessioni',
    '${_righe('piano.csv')} giorni di piano',
    '${_righe('misure.csv')} misure',
    '${_righe('feedback.csv')} feedback',
    if (foto != null) 'foto del profilo',
  ].join(' · ');
}

Uint8List creaBackup(
  Map<String, String> csv, {
  String? nomeFoto,
  List<int>? foto,
  required DateTime creato,
}) {
  final j = {
    'formato': _formato,
    'versione': _versione,
    'creato': creato.toIso8601String(),
    'file': {
      for (final e in csv.entries)
        if (fileDaSalvare(e.key)) e.key: e.value,
    },
    if (foto != null && nomeFoto != null && _nomeFoto.hasMatch(nomeFoto))
      'foto': {'nome': nomeFoto, 'dati': base64Encode(foto)},
  };
  return Uint8List.fromList(gzip.encode(utf8.encode(jsonEncode(j))));
}

/// Legge un file di backup; FormatException se non è un backup dell'app.
DatiBackup leggiBackup(List<int> bytes) {
  final Object? j;
  try {
    j = jsonDecode(utf8.decode(gzip.decode(bytes)));
  } catch (_) {
    throw const FormatException('Il file non è un backup di Avidididadi.');
  }
  if (j is! Map || j['formato'] != _formato) {
    throw const FormatException('Il file non è un backup di Avidididadi.');
  }
  if ((j['versione'] as num? ?? 0) > _versione) {
    throw const FormatException(
      'Backup creato da una versione più recente dell\'app: aggiornala.',
    );
  }
  final file = j['file'];
  final csv = <String, String>{
    if (file is Map)
      for (final e in file.entries)
        // Solo nomi semplici: niente percorsi fuori dalla cartella dell'app.
        if (e.key is String && fileDaSalvare(e.key) && e.value is String)
          e.key as String: e.value as String,
  };
  if (csv.isEmpty) throw const FormatException('Il backup è vuoto.');
  final f = j['foto'];
  String? nomeFoto;
  Uint8List? foto;
  if (f is Map && f['nome'] is String && _nomeFoto.hasMatch(f['nome'])) {
    try {
      foto = base64Decode(f['dati'] as String);
      nomeFoto = f['nome'] as String;
    } catch (_) {
      // foto rovinata: si ripristina il resto
    }
  }
  return DatiBackup(
    DateTime.tryParse('${j['creato']}') ?? DateTime.now(),
    csv,
    nomeFoto: nomeFoto,
    foto: foto,
  );
}
