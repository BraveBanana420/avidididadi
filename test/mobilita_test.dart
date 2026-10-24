import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/generatore_mobilita.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Esercizio> catalogo;
  setUpAll(() async => catalogo = await caricaEsercizi());
  final lunedi = DateTime(2026, 10, 26);

  test('seduta a tempo, sulla zona scelta, senza attrezzi', () {
    final s = sedutaMobilita(
      esercizi: catalogo,
      attrezzatura: const {},
      data: lunedi,
      minuti: 20,
      focus: 'Anche e gambe',
    );
    expect(s, isNotEmpty);
    expect(s.every((x) => x.sport == 'Mobilità'), true);
    // Tutta a tempo: la modalità allenamento passa da sola.
    expect(
      blocchiDa(s)
          .where((b) => b.tipo == TipoBlocco.lavoro)
          .every((b) => b.aTempo),
      true,
    );
    final perId = {for (final e in catalogo) e.id: e};
    final gambe = focusMobilita['Anche e gambe']!;
    final inZona = s.where(
      (x) => perId[x.esercizio]!.muscoli.any(gambe.contains),
    );
    expect(inZona.length, greaterThanOrEqualTo(s.length ~/ 2));
    // Niente rullo se non c'è nell'attrezzatura.
    expect(s.any((x) => perId[x.esercizio]!.schema == 'rullo'), false);
    // Durata vicina a quella prevista (cambi compresi).
    final secondi = blocchiDa(s).fold(0, (t, b) => t + (b.secondi ?? 0));
    expect(secondi, inInclusiveRange(12 * 60, 24 * 60));
  });

  test('nel piano: dopo la corsa tocca alle gambe, poi le zone ruotano', () {
    PianoRiga r(int g, String sport) => PianoRiga(
      data: lunedi.add(Duration(days: g)),
      fascia: 'Sera',
      sport: sport,
      durataMin: 20,
    );
    final p = generaPianoMobilita(
      piano: [
        r(1, 'Corsa'),
        r(2, 'Mobilità'),
        r(4, 'Mobilità'),
        r(6, 'Mobilità'),
      ],
      esercizi: catalogo,
      attrezzatura: const {},
      da: lunedi,
    );
    expect(p.programma.length, 3);
    expect(p.tipi[lunedi.add(const Duration(days: 2))], 'Anche e gambe');
    expect(
      {
        p.tipi[lunedi.add(const Duration(days: 4))],
        p.tipi[lunedi.add(const Duration(days: 6))],
      }.length,
      2,
    );
    expect(
      p.programma.every((x) => x.idWorkout.startsWith(prefissoMobilita)),
      true,
    );
  });

  test('yoga e stretching diventano mobilità', () {
    expect(normSport('yoga'), 'Mobilità');
    expect(normSport('mobilita'), 'Mobilità');
    expect(normSport('MOBILITÀ'), 'Mobilità');
    expect(mappaAttivita('YOGA'), ('Mobilità', 'Yoga'));
    expect(mappaAttivita('FLEXIBILITY'), ('Mobilità', 'Stretching'));
  });
}
