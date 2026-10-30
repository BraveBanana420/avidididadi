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
}
