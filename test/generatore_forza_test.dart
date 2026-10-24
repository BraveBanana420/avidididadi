import 'package:allenamenti_app/esercizi.dart';
import 'package:allenamenti_app/generatore_forza.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Piano di [settimane] settimane dal lunedì 19/10/2026: forza nei [giorniForza]
/// (1 = lunedì), Fartlek il giovedì e Lungo il sabato.
List<PianoRiga> pianoDiProva(
  int settimane, {
  List<int> giorniForza = const [1, 3, 5],
  int durata = 45,
}) {
  final righe = <PianoRiga>[];
  for (var i = 0; i < settimane * 7; i++) {
    final d = DateTime(2026, 10, 19 + i);
    if (giorniForza.contains(d.weekday)) {
      righe.add(
        PianoRiga(
          data: d,
          fascia: 'Mattina',
          sport: 'Forza',
          durataMin: durata,
        ),
      );
    }
    if (d.weekday == DateTime.thursday) {
      righe.add(
        PianoRiga(data: d, fascia: 'Mattina', sport: 'Corsa', tipo: 'Fartlek'),
      );
    }
    if (d.weekday == DateTime.saturday) {
      righe.add(
        PianoRiga(data: d, fascia: 'Mattina', sport: 'Corsa', tipo: 'Lungo'),
      );
    }
  }
  return righe;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Esercizio> esercizi;
  late Map<String, Esercizio> perId;
  setUpAll(() async {
    esercizi = await caricaEsercizi();
    perId = {for (final e in esercizi) e.id: e};
  });

  final lunedi = DateTime(2026, 10, 19);
  const Attrezzatura palestraCasa = {
    'manubri': [4, 6, 8, 10, 12, 14],
    'kettlebell': [16],
    'panca': [],
    'elastici': [],
  };

  PianoForza genera(
    List<PianoRiga> piano, {
    Attrezzatura attrezzatura = palestraCasa,
    String obiettivo = 'ipertrofia',
    String livello = 'intermedio',
  }) => generaPianoForza(
    piano: piano,
    esercizi: esercizi,
    attrezzatura: attrezzatura,
    obiettivo: obiettivo,
    livello: livello,
    inizio: lunedi,
    da: lunedi,
  );

  List<WorkoutStep> sessione(PianoForza p, DateTime d) =>
      p.passi.where((s) => s.id == '$prefissoForza${isoData(d)}').toList();

  test('un workout per ogni giorno di forza, con programma collegato', () {
    final p = genera(pianoDiProva(2));
    expect(p.programma.length, 6);
    for (final r in p.programma) {
      expect(r.sport, 'Forza');
      expect(sessione(p, r.data), isNotEmpty);
    }
  });

  test('riscaldamento, almeno 3 esercizi principali e mobilità finale', () {
    final s = sessione(genera(pianoDiProva(1)), lunedi);
    expect(s.first.fase, 'riscaldamento');
    expect(s.last.fase, 'mobilità');
    expect(
      s.where((x) => x.fase == 'principale').length,
      greaterThanOrEqualTo(3),
    );
    expect(
      s.where((x) => x.fase == 'mobilità').length,
      greaterThanOrEqualTo(3),
    );
    // Ogni passo rimanda a un esercizio del catalogo.
    expect(s.every((x) => perId.containsKey(x.esercizio)), isTrue);
  });

  test('la durata della settimana tipo cambia la quantità di esercizi', () {
    int principali(int durata) => sessione(
      genera(pianoDiProva(1, durata: durata)),
      lunedi,
    ).where((x) => x.fase == 'principale').length;
    expect(principali(75), greaterThan(principali(30)));
  });

  test('usa solo esercizi fattibili con l\'attrezzatura', () {
    for (final a in <Attrezzatura>[{}, palestraCasa]) {
      final p = genera(pianoDiProva(2), attrezzatura: a);
      for (final s in p.passi) {
        expect(perId[s.esercizio]!.fattibile(a), isTrue, reason: s.esercizio);
      }
    }
  });

  test('il giorno prima di Fartlek e Lungo le gambe restano leggere', () {
    final p = genera(pianoDiProva(1), obiettivo: 'generale');
    final venerdi = sessione(p, DateTime(2026, 10, 23)); // sabato Lungo
    final mercoledi = sessione(p, DateTime(2026, 10, 21)); // giovedì Fartlek
    final lunedi_ = sessione(p, lunedi);
    expect(venerdi.any((s) => s.note.contains('il Lungo')), isTrue);
    expect(mercoledi.any((s) => s.note.contains('il Fartlek')), isTrue);
    expect(lunedi_.any((s) => s.note.contains('Gambe leggere')), isFalse);
    // Niente pliometria prima delle corse impegnative.
    for (final s in [...venerdi, ...mercoledi]) {
      expect(perId[s.esercizio]!.schema, isNot('pliometria'));
    }
  });

  test('blocchi di 4 settimane: progressione, scarico, poi esercizi nuovi', () {
    final p = genera(pianoDiProva(5));
    List<WorkoutStep> principali(int settimana) => sessione(
      p,
      DateTime(2026, 10, 19 + 7 * settimana),
    ).where((s) => s.fase == 'principale').toList();
    final s1 = principali(0),
        s2 = principali(1),
        s4 = principali(3),
        s5 = principali(4);
    // Stessi esercizi nelle settimane del blocco.
    expect(s2.map((s) => s.esercizio), s1.map((s) => s.esercizio));
    // Settimana 2: una ripetizione in più.
    expect(s2.first.ripetizioni, isNot(s1.first.ripetizioni));
    // Settimana 4 di scarico: meno serie.
    expect(int.parse(s4.first.serie), lessThan(int.parse(s1.first.serie)));
    // Blocco nuovo: cambia almeno un esercizio.
    expect(
      s5.map((s) => s.esercizio).toList(),
      isNot(s1.map((s) => s.esercizio).toList()),
    );
  });

  test('il livello principiante esclude gli esercizi intermedi', () {
    final p = genera(pianoDiProva(2), livello: 'principiante');
    for (final s in p.passi.where((s) => s.fase == 'principale')) {
      expect(perId[s.esercizio]!.livello, 'principiante', reason: s.esercizio);
    }
  });

  test('con 4 sessioni a settimana alterna parte alta e parte bassa', () {
    final p = genera(pianoDiProva(1, giorniForza: [1, 2, 4, 5]));
    expect(sessione(p, lunedi).first.nome, startsWith('Parte alta'));
    expect(
      sessione(p, DateTime(2026, 10, 20)).first.nome,
      startsWith('Parte bassa'),
    );
  });

  test('suggerisce un peso tra quelli disponibili', () {
    final s = sessione(genera(pianoDiProva(1)), lunedi);
    final caricati = s.where((x) => x.note.contains('kg'));
    expect(caricati, isNotEmpty);
    for (final x in caricati) {
      expect(
        RegExp(r' (4|6|8|10|12|14|16) kg').hasMatch(x.note),
        isTrue,
        reason: x.note,
      );
    }
  });
}
