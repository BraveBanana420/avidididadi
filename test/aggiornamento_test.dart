import 'package:allenamenti_app/aggiornamento.dart';
import 'package:flutter_test/flutter_test.dart';

/// Risposta di GitHub com'è per la release 1.0.2 (accorciata).
Map<String, dynamic> release({
  String tag = 'v1.0.2',
  bool prerelease = false,
  List<String>? file,
}) => {
  'tag_name': tag,
  'draft': false,
  'prerelease': prerelease,
  'body':
      '- Immagini da condividere: la scritta #avidididadi ora ha il carattere del logo.\n'
      '\n'
      'Install `Avidididadi-1.0.2-arm64-v8a.apk` on almost every recent phone.',
  'assets': [
    for (final n
        in file ??
            [
              'Avidididadi-1.0.2-arm64-v8a.apk',
              'Avidididadi-1.0.2-armeabi-v7a.apk',
              'Avidididadi-1.0.2-x86_64.apk',
              'SHA256SUMS.txt',
            ])
      {
        'name': n,
        'browser_download_url':
            'https://github.com/BraveBanana420/avidididadi/releases/download/v1.0.2/$n',
      },
  ],
};

void main() {
  test('indirizzo dell\'ultima release del progetto', () {
    expect(
      urlUltimaRelease.toString(),
      'https://api.github.com/repos/BraveBanana420/avidididadi/releases/latest',
    );
  });

  group('versioni', () {
    test('si leggono con o senza v e numero di build', () {
      expect(numeriVersione('v1.0.2'), [1, 0, 2]);
      expect(numeriVersione('1.12.4+32'), [1, 12, 4]);
      expect(numeriVersione('staging'), isNull);
    });

    test('più nuova: prima MAJOR, poi MINOR, poi PATCH', () {
      expect(piuNuova('1.0.3', '1.0.2'), isTrue);
      expect(piuNuova('1.1.0', '1.0.9'), isTrue);
      expect(piuNuova('2.0.0', '1.12.4'), isTrue);
      // 1.10 viene dopo 1.9, non prima come nell'ordine alfabetico.
      expect(piuNuova('1.10.0', '1.9.0'), isTrue);
      expect(piuNuova('1.0.2', '1.0.2'), isFalse);
      expect(piuNuova('1.0.1', '1.0.2'), isFalse);
    });

    test('l\'APK di prova di staging non vede la sua stessa versione', () {
      expect(piuNuova('v1.0.2', '1.0.2'), isFalse);
      expect(piuNuova('qualcosa', '1.0.2'), isFalse);
    });
  });

  group('release da GitHub', () {
    test('sceglie l\'APK del telefono e prende le novità', () {
      final r = rilascioDa(release(), 'arm64-v8a')!;
      expect(r.versione, '1.0.2');
      expect(r.nomeApk, 'Avidididadi-1.0.2-arm64-v8a.apk');
      expect(r.apk.path, endsWith('/Avidididadi-1.0.2-arm64-v8a.apk'));
      expect(r.somme.path, endsWith('/SHA256SUMS.txt'));
      expect(r.novita, [
        'Immagini da condividere: la scritta #avidididadi ora ha il carattere del logo.',
      ]);
      expect(
        rilascioDa(release(), 'armeabi-v7a')!.nomeApk,
        'Avidididadi-1.0.2-armeabi-v7a.apk',
      );
    });

    test('niente avviso se manca qualcosa o non è una release vera', () {
      expect(rilascioDa(release(), 'mips'), isNull);
      expect(rilascioDa(release(prerelease: true), 'arm64-v8a'), isNull);
      expect(
        rilascioDa(
          release(file: ['Avidididadi-1.0.2-arm64-v8a.apk']),
          'arm64-v8a',
        ),
        isNull,
        reason: 'senza SHA256SUMS.txt non si può controllare il file',
      );
      expect(rilascioDa(release(tag: 'prova'), 'arm64-v8a'), isNull);
    });

    test('solo file scaricati da GitHub', () {
      final j = release();
      for (final a in j['assets'] as List) {
        (a as Map)['browser_download_url'] =
            'http://altro.example/${a['name']}';
      }
      expect(rilascioDa(j, 'arm64-v8a'), isNull);
    });
  });

  test('impronta dal file di sha256sum', () {
    final a = 'a' * 64, b = 'B' * 64;
    final somme =
        '$a  Avidididadi-1.0.2-arm64-v8a.apk\n'
        '$b *Avidididadi-1.0.2-armeabi-v7a.apk\n';
    expect(impronta(somme, 'Avidididadi-1.0.2-arm64-v8a.apk'), a);
    expect(impronta(somme, 'Avidididadi-1.0.2-armeabi-v7a.apk'), 'b' * 64);
    expect(impronta(somme, 'Avidididadi-1.0.2-x86_64.apk'), isNull);
  });

  test('si chiede a GitHub al massimo una volta al giorno', () {
    final ieri = DateTime(2026, 11, 22, 8);
    expect(daControllare(null, ieri), isTrue);
    expect(daControllare(ieri, DateTime(2026, 11, 22, 20)), isFalse);
    expect(daControllare(ieri, DateTime(2026, 11, 23, 7)), isTrue);
    // Orologio tornato indietro: meglio controllare che restare fermi.
    expect(daControllare(ieri, DateTime(2026, 11, 21)), isTrue);
  });

  test('impostazioni: acceso di serie, ultima data conservata', () {
    final ultimo = DateTime(2026, 11, 23, 9, 30);
    expect(leggiImpostazioni(''), (true, null));
    expect(leggiImpostazioni(testoImpostazioni(false, ultimo)), (
      false,
      ultimo,
    ));
    expect(leggiImpostazioni(testoImpostazioni(true, null)), (true, null));
    expect(leggiImpostazioni('ultimo=rotto'), (true, null));
  });
}
