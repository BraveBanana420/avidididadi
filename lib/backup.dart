import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'csv.dart';
import 'models.dart';
import 'l10n/lingua.dart';

/// Backup di tutti i dati in un unico file: i CSV e la foto del profilo, in un
/// JSON compresso. La chiave dell'assistente non c'è (sta nell'archivio cifrato)
/// e nemmeno il token di Health Connect, che vale solo su quel telefono: dopo
/// un ripristino la prossima sincronizzazione rilegge lo storico.

const _formato = 'avidididadi-backup';
const _versione = 1;

/// Un backup vero pesa pochi MB: oltre questi limiti (compresso e aperto)
/// il file non è un backup dell'app, o è costruito per esaurire la memoria.
const maxByteBackup = 50 * 1024 * 1024;
const maxByteBackupAperto = 200 * 1024 * 1024;

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
    l10n.creato(dataLunga(creato)),
    '${_righe('sessioni.csv') + _righe('health_connect_sessioni.csv')} sessioni',
    l10n.giorniPiano(_righe('piano.csv')),
    '${_righe('misure.csv')} misure',
    '${_righe('feedback.csv')} feedback',
    if (foto != null) l10n.fotoProfilo,
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
  if (bytes.length > maxByteBackup) {
    throw FormatException(l10n.fileTroppoGrandeEssere);
  }
  final Object? j;
  try {
    j = jsonDecode(utf8.decode(_apri(bytes)));
  } on _TroppoGrande {
    throw FormatException(l10n.fileTroppoGrandeEssere);
  } catch (_) {
    throw FormatException(l10n.fileNonBackupAvidididadi);
  }
  if (j is! Map || j['formato'] != _formato) {
    throw FormatException(l10n.fileNonBackupAvidididadi);
  }
  if ((j['versione'] as num? ?? 0) > _versione) {
    throw FormatException(l10n.backupCreatoVersionePiu);
  }
  final file = j['file'];
  final csv = <String, String>{
    if (file is Map)
      for (final e in file.entries)
        // Solo nomi semplici: niente percorsi fuori dalla cartella dell'app.
        if (e.key is String && fileDaSalvare(e.key) && e.value is String)
          e.key as String: e.value as String,
  };
  if (csv.isEmpty) throw FormatException(l10n.backupVuoto);
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

class _TroppoGrande implements Exception {}

/// Raccoglie i pezzi decompressi, ma si ferma oltre [maxByteBackupAperto].
class _Raccolta implements Sink<List<int>> {
  final dati = BytesBuilder(copy: false);

  @override
  void add(List<int> pezzo) {
    if (dati.length + pezzo.length > maxByteBackupAperto) {
      throw _TroppoGrande();
    }
    dati.add(pezzo);
  }

  @override
  void close() {}
}

/// Decomprime a pezzi: un file piccolo che si gonfia a dismisura si ferma
/// prima di riempire la memoria.
List<int> _apri(List<int> compressi) {
  final raccolta = _Raccolta();
  final apri = gzip.decoder.startChunkedConversion(raccolta);
  const pezzo = 64 * 1024;
  for (var i = 0; i < compressi.length; i += pezzo) {
    apri.add(
      compressi.sublist(
        i,
        i + pezzo > compressi.length ? compressi.length : i + pezzo,
      ),
    );
  }
  apri.close();
  return raccolta.dati.takeBytes();
}
