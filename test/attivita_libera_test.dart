import 'package:allenamenti_app/attivita.dart';
import 'package:allenamenti_app/attivita_libera.dart';
import 'package:allenamenti_app/carico.dart';
import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:allenamenti_app/percorso.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final oggi = DateTime(2026, 10, 30);

  test('un passo solo, senza tempo: si chiude con "Fatto"', () {
    final b = blocchiDa(passiLiberi(sportCamminata, 'Camminata'));
    expect(b.length, 1);
    expect(b.single.aTempo, isFalse);
    expect(b.single.titolo, 'Camminata');
  });

  test('id con l\'ora: non sostituisce le sedute dello stesso giorno', () {
    expect(
      idLibera(DateTime(2026, 10, 30, 19, 5), sportCamminata),
      'app-2026-10-30-camminata-1905',
    );
  });

  test('camminata: GPS e fatica bassa', () {
    expect(sportConPercorso(sportCamminata), isTrue);
    final s = Sessione(
      id: 'x',
      data: oggi,
      sport: sportCamminata,
      durataMin: 40,
    );
    expect(faticaStimata(s, const Zone(fcMax: 190)), 3);
  });

  test('orologio e app: doppioni solo se gli orari si sovrappongono', () {
    Sessione app(int ora, {bool conOrario = true}) => Sessione(
      id: 'app-$ora',
      data: oggi,
      sport: 'Corsa',
      durataMin: 30,
      fonte: fonteApp,
      inizio: conOrario ? DateTime(2026, 10, 30, ora) : null,
      fine: conOrario ? DateTime(2026, 10, 30, ora, 30) : null,
    );
    final garmin = Sessione(
      id: 'hc-1',
      data: oggi,
      sport: 'Corsa',
      durataMin: 31,
      inizio: DateTime(2026, 10, 30, 7, 2),
      fine: DateTime(2026, 10, 30, 7, 33),
    );
    // La stessa corsa registrata da tutti e due: vale quella dell'orologio.
    expect(combina([app(7)], [garmin]).map((s) => s.id), ['hc-1']);
    // La sera, un'altra corsa: restano tutte e due.
    expect(combina([app(19)], [garmin]).length, 2);
    // Sedute vecchie senza orario: come prima, vale l'orologio.
    expect(combina([app(19, conOrario: false)], [garmin]).map((s) => s.id), [
      'hc-1',
    ]);
  });

  group('altra attività', () {
    Sessione libera(String tipo, DateTime data, {String sport = ''}) =>
        Sessione(
          id: 'app-$tipo-${data.day}',
          data: data,
          sport: sport.isEmpty ? sportAttivitaLibera : sport,
          tipo: tipo,
          durataMin: 60,
        );

    test('i nomi già usati, dal più recente e senza doppioni', () {
      final nomi = nomiAltreAttivita([
        libera('Kayak', DateTime(2026, 10, 1)),
        libera('Padel', DateTime(2026, 10, 20)),
        libera('kayak', DateTime(2026, 11, 2)),
        libera(tipoAltraAttivita, DateTime(2026, 11, 3)),
        libera('Lento', DateTime(2026, 11, 4), sport: 'Corsa'),
      ]);
      expect(nomi, ['kayak', 'Padel']);
    });

    test('il nome scritto si ripulisce', () {
      expect(pulisciNomeAttivita('  kayak   di mare '), 'Kayak di mare');
      expect(pulisciNomeAttivita('   '), '');
    });

    test('forza libera: nome chiaro, non "Allenamento libero"', () {
      final forza = attivitaLibere.firstWhere((a) => a.$1 == 'Forza');
      expect(forza.$2, tipoForzaLibera);
      expect(forza.$3, 'Forza libera');
    });
  });
}
