import 'package:allenamenti_app/backup_auto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lunedi = DateTime(2026, 11, 2, 7, 30);

  test('spento: mai', () {
    expect(backupDovuto(const ImpostazioniBackup(), lunedi), isFalse);
  });

  test('acceso senza backup: subito', () {
    const b = ImpostazioniBackup(cartella: 'content://x');
    expect(backupDovuto(b, lunedi), isTrue);
  });

  test('ogni giorno: aprendo l\'app un po\' prima il giorno dopo vale', () {
    final b = ImpostazioniBackup(
      cartella: 'content://x',
      frequenza: FrequenzaBackup.giorno,
      ultimo: lunedi,
    );
    expect(backupDovuto(b, lunedi.add(const Duration(hours: 3))), isFalse);
    expect(
      backupDovuto(b, lunedi.add(const Duration(hours: 23, minutes: 15))),
      isTrue,
    );
  });

  test('ogni settimana', () {
    final b = ImpostazioniBackup(cartella: 'content://x', ultimo: lunedi);
    expect(backupDovuto(b, lunedi.add(const Duration(days: 5))), isFalse);
    expect(
      backupDovuto(b, lunedi.add(const Duration(days: 6, hours: 23))),
      isTrue,
    );
  });

  test('nome del file come il backup a mano', () {
    expect(nomeBackup(lunedi), 'avidididadi_backup_2026-11-02.gz');
  });

  test('tiene gli ultimi 5 e non tocca gli altri file', () {
    final file = [
      for (var g = 1; g <= 8; g++)
        (
          'id$g',
          'avidididadi_backup_2026-10-${g.toString().padLeft(2, '0')}.gz',
        ),
      ('foto', 'vacanze.jpg'),
      ('mio', 'avidididadi_backup_vecchio_a_mano.gz'),
      ('copia', 'avidididadi_backup_2026-10-01 (1).gz'),
    ];
    expect(backupDaCancellare(file), unorderedEquals(['id1', 'id2', 'id3']));
  });

  test('impostazioni salvate e rilette', () {
    final b = ImpostazioniBackup(
      cartella: 'content://com.android.externalstorage.documents/tree/x',
      nomeCartella: 'Documents',
      frequenza: FrequenzaBackup.giorno,
      ultimo: lunedi,
      errore: '',
    );
    final r = ImpostazioniBackup.da(b.toText());
    expect(r.cartella, b.cartella);
    expect(r.nomeCartella, 'Documents');
    expect(r.frequenza, FrequenzaBackup.giorno);
    expect(r.ultimo, lunedi);
    expect(ImpostazioniBackup.da('').attivo, isFalse);
  });
}
