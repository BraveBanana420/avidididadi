// Quali esercizi propongono più spesso i generatori? Serve a scegliere quali
// animare per primi. Genera tanti piani di 8 settimane con profili diversi
// (attrezzatura, livello, obiettivo, giorni) e conta le sedute in cui compare
// ogni esercizio. Si lancia a mano:
//   flutter test tool/frequenza_esercizi_test.dart
import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/generatore_forza.dart';
import 'package:allenamenti_app/generatore_mobilita.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

final _lunedi = DateTime(2026, 10, 19);

List<PianoRiga> _piano(String sport, List<int> giorni, {int durata = 45}) => [
  for (var i = 0; i < 8 * 7; i++)
    if (giorni.contains(DateTime(2026, 10, 19 + i).weekday))
      PianoRiga(
        data: DateTime(2026, 10, 19 + i),
        fascia: 'Mattina',
        sport: sport,
        durataMin: durata,
      ),
  for (var i = 0; i < 8 * 7; i++)
    if (DateTime(2026, 10, 19 + i).weekday == DateTime.saturday)
      PianoRiga(
        data: DateTime(2026, 10, 19 + i),
        fascia: 'Mattina',
        sport: 'Corsa',
        tipo: 'Lungo',
      ),
];

const _manubri = <double>[2, 4, 6, 8, 10, 12, 14];
final Map<String, Attrezzatura> _profili = {
  'corpo libero': {},
  'elastici': {'elastici': []},
  'manubri e panca': {'manubri': _manubri, 'panca': [], 'elastici': []},
  'casa completa': {
    'manubri': _manubri,
    'kettlebell': [12, 16],
    'panca': [],
    'elastici': [],
    'sbarra': [],
    'rullo': [],
  },
  'palestra': {
    for (final a in attrezzi) a.chiave: <double>[],
    'manubri': [for (var p = 2.0; p <= 30; p += 2) p],
    'kettlebell': [8, 12, 16, 20, 24],
    'bilanciere': [20],
    'dischi': [1.25, 2.5, 5, 10, 15, 20],
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('frequenza degli esercizi proposti', () async {
    final esercizi = await caricaEsercizi();
    final perId = {for (final e in esercizi) e.id: e};
    final conta = <String, int>{};
    final principianti = <String, int>{};
    void aggiungi(Iterable<WorkoutStep> passi, {bool principiante = false}) {
      // Una volta per seduta: conta in quante sedute compare.
      final visti = {for (final p in passi) '${p.id}|${p.esercizio}'};
      for (final v in visti) {
        final id = v.split('|').last;
        if (id.isEmpty) continue;
        conta[id] = (conta[id] ?? 0) + 1;
        if (principiante) principianti[id] = (principianti[id] ?? 0) + 1;
      }
    }

    var piani = 0;
    for (final attrezzatura in _profili.values) {
      for (final livello in ['principiante', 'intermedio', 'avanzato']) {
        for (final obiettivo in [
          'forza',
          'ipertrofia',
          'resistenza',
          'generale',
        ]) {
          for (final giorni in [
            [2, 5],
            [1, 3, 5],
            [1, 2, 4, 5],
          ]) {
            final p = generaPianoForza(
              piano: _piano('Forza', giorni),
              esercizi: esercizi,
              attrezzatura: attrezzatura,
              obiettivo: obiettivo,
              livello: livello,
              inizio: _lunedi,
              da: _lunedi,
            );
            aggiungi(p.passi, principiante: livello == 'principiante');
            piani++;
          }
        }
      }
    }
    for (final attrezzatura in [
      <String, List<double>>{},
      <String, List<double>>{'rullo': []},
    ]) {
      for (final giorni in [
        [3],
        [2, 6],
        [1, 3, 5],
        [1, 2, 3, 4, 5, 6, 7],
      ]) {
        for (final durata in [15, 30]) {
          final p = generaPianoMobilita(
            piano: _piano(sportMobilita, giorni, durata: durata),
            esercizi: esercizi,
            attrezzatura: attrezzatura,
            da: _lunedi,
          );
          aggiungi(p.passi, principiante: true);
          piani++;
        }
      }
    }

    final ordine = conta.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final righe = StringBuffer('piani: $piani\n');
    for (final e in ordine.take(60)) {
      final x = perId[e.key];
      righe.writeln(
        '${e.value}\t${principianti[e.key] ?? 0}\t${e.key}\t${x?.tipo}\t'
        '${x?.lati == true ? '↔' : ''}\t${x?.attrezzi.map((g) => g.join('+')).join(' / ')}',
      );
    }
    // ignore: avoid_print
    print(righe);
  });
}
