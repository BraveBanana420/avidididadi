import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/esecuzione.dart';
import 'package:allenamenti_app/generatore_forza.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/registro_forza.dart';
import 'package:allenamenti_app/scheda.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Lunedì 2 novembre 2026: scheda di 15 giorni, Busto il lunedì e Gambe il
  // mercoledì, come quella di un personal trainer.
  final lun = DateTime(2026, 11, 2);
  final scheda = SchedaForza(
    id: 'sch-1',
    nome: 'Novembre',
    inizio: lun,
    fine: lun.add(const Duration(days: 14)),
    giorni: const [
      GiornoScheda(
        nome: 'Busto',
        giorni: {1},
        esercizi: [
          EsercizioScheda(
            esercizio: 'Wide-Grip_Lat_Pulldown',
            nome: 'Lat machine presa larga',
            serie: 4,
            ripetizioni: '10',
            recuperoS: 90,
            kg: [40],
          ),
          EsercizioScheda(
            esercizio: 'Leverage_Chest_Press',
            nome: 'Chest press',
            serie: 3,
            ripetizioni: '12-10-8',
            kg: [30, 35, 40],
            note: 'Scendi in 3 secondi',
          ),
        ],
      ),
      GiornoScheda(
        nome: 'Gambe',
        giorni: {3},
        esercizi: [
          EsercizioScheda(
            nome: 'Affondi camminati',
            serie: 3,
            ripetizioni: '12',
          ),
        ],
      ),
    ],
  );

  test('quale giorno della scheda e quando vale', () {
    expect(scheda.giornoPer(lun)!.nome, 'Busto');
    expect(scheda.giornoPer(lun.add(const Duration(days: 2)))!.nome, 'Gambe');
    expect(scheda.giornoPer(lun.add(const Duration(days: 1))), isNull);
    // Lunedì 16 novembre è l'ultimo giorno; mercoledì 18 è già finita.
    expect(scheda.giornoPer(DateTime(2026, 11, 16))!.nome, 'Busto');
    expect(scheda.giornoPer(DateTime(2026, 11, 18)), isNull);
    expect(scheda.finita(DateTime(2026, 11, 16)), isFalse);
    expect(scheda.durataGiorni, 15);
    expect(scheda.finita(DateTime(2026, 11, 17)), isTrue);
    expect(
      scheda.copyWith(archiviata: true).finita(DateTime(2026, 11, 17)),
      isFalse,
    );
    final rinnovata = scheda.rinnovata(15);
    expect(rinnovata.inizio, DateTime(2026, 11, 17));
    expect(rinnovata.fine, DateTime(2026, 12, 1));
  });

  test('si salva e si rilegge dal CSV, giorni vuoti compresi', () {
    final conVuoto = scheda.copyWith(
      giorni: [
        ...scheda.giorni,
        const GiornoScheda(nome: 'Spalle', giorni: {5}),
      ],
    );
    Tabella t(List<String> h, List<List<String>> r) =>
        Tabella.da(toCsv([h, ...r]))!;
    final letta = schedeDa(
      t(schedeHeader, righeSchede([conVuoto])),
      t(schedeEserciziHeader, righeEserciziSchede([conVuoto])),
    ).single;
    expect(letta.nome, 'Novembre');
    expect(letta.fine, scheda.fine);
    expect(letta.giorni.map((g) => g.nome), ['Busto', 'Gambe', 'Spalle']);
    expect(letta.giorni[2].esercizi, isEmpty);
    expect(letta.giorni[2].giorni, {5});
    final chest = letta.giorni[0].esercizi[1];
    expect(chest.kg, [30, 35, 40]);
    expect(chest.ripetizioni, '12-10-8');
    expect(chest.note, 'Scendi in 3 secondi');
    expect(letta.giorni[1].esercizi.single.esercizio, '');
  });

  test('nel piano la scheda prende il posto della forza generata', () {
    final piano = [
      for (var i = 0; i < 21; i++)
        if ({1, 3}.contains(lun.add(Duration(days: i)).weekday))
          PianoRiga(
            data: lun.add(Duration(days: i)),
            fascia: 'Mattina',
            sport: 'Forza',
            durataMin: 50,
          ),
    ];
    // Un generato finto: un esercizio per giorno.
    final generato = PianoForza(
      [
        for (final r in piano)
          WorkoutStep(
            id: '$prefissoForza${isoData(r.data)}',
            sport: 'Forza',
            nome: 'Generato',
            durataTot: 50,
            ordine: 1,
            fase: 'principale',
            descrizione: 'Squat',
            serie: '3',
            ripetizioni: '10',
            distanzaM: '',
            durataMin: '',
            intensita: '',
            recuperoS: '60',
            note: '',
          ),
      ],
      [
        for (final r in piano)
          ProgrammaRiga(
            data: r.data,
            sport: 'Forza',
            idWorkout: '$prefissoForza${isoData(r.data)}',
          ),
      ],
    );
    final p = conScheda(generato, piano, [scheda]);
    List<WorkoutStep> del(DateTime d) =>
        p.passi.where((w) => w.id == '$prefissoForza${isoData(d)}').toList();
    expect(del(lun).map((w) => w.nome).toSet(), {'Busto'});
    expect(del(lun).length, 2);
    expect(del(lun)[1].kg, '30;35;40');
    expect(del(lun.add(const Duration(days: 2))).single.nome, 'Gambe');
    // Dopo la fine della scheda (mercoledì 18) resta il generato.
    expect(del(DateTime(2026, 11, 16)).first.nome, 'Busto');
    expect(del(DateTime(2026, 11, 18)).single.nome, 'Generato');
    expect(p.programma.length, generato.programma.length);
  });

  test('il player propone i kg della scheda serie per serie', () {
    final passi = passiScheda(scheda.giorni[0], lun, 50);
    final b = blocchiDa(passi).where((x) => x.tipo == TipoBlocco.lavoro);
    final chest = b.where((x) => x.titolo == 'Chest press').toList();
    expect(chest.map((x) => x.kg), [30, 35, 40]);
    expect(chest.first.kgPerSerie, isTrue);
    expect(b.first.kg, 40);
    expect(b.first.kgPerSerie, isFalse);
    expect(kgDellaSerie('20', 3), 20);
    expect(kgDellaSerie('', 1), isNull);
    // Piramide: vale la scheda anche se la serie prima era diversa.
    expect(
      proposta(
        serie: 2,
        previste: (12, 12),
        ultima: const [],
        precedente: (12, 30),
        kgPiano: 35,
        kgPerSerie: true,
      ),
      (12, 35.0),
    );
  });

  test('pesi diversi dalla scheda: si propongono quelli nuovi', () {
    SerieFatta f(String nome, int n, double kg) => SerieFatta(
      data: lun,
      esercizio: '',
      nome: nome,
      serie: n,
      ripetizioni: 10,
      kg: kg,
    );
    final g = scheda.giorni[0];
    // Lat machine uguale, chest press salita all'ultima serie.
    final cambi = pesiCambiati(g, [
      for (var n = 1; n <= 4; n++) f('Lat machine presa larga', n, 40),
      f('Chest press', 1, 30),
      f('Chest press', 2, 35),
      f('Chest press', 3, 42.5),
    ]);
    expect(cambi.single.$1, 'Chest press');
    expect(cambi.single.$3, [30, 35, 42.5]);
    // Tutte le serie a 45: basta un valore.
    expect(
      pesiCambiati(g, [
        for (var n = 1; n <= 4; n++) f('Lat machine presa larga', n, 45),
      ]).single.$3,
      [45],
    );
    final nuova = conPesi(scheda, {
      'Chest press': [30, 35, 42.5],
    });
    expect(nuova.giorni[0].esercizi[1].kg, [30, 35, 42.5]);
    expect(nuova.giorni[0].esercizi[0].kg, [40]);
  });
}
