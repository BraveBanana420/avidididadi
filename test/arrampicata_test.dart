import 'package:allenamenti_app/arrampicata.dart';
import 'package:allenamenti_app/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scale dei gradi in ordine', () {
    expect(gradiFalesia.first, '3');
    expect(gradiFalesia.last, '9c');
    expect(
      livello(Disciplina.falesia, '6b+') > livello(Disciplina.falesia, '6b'),
      isTrue,
    );
    expect(
      livello(Disciplina.falesia, '7a') > livello(Disciplina.falesia, '6c+'),
      isTrue,
    );
    expect(gradiBoulder, containsAllInOrder(['5+', '6A', '6A+', '7A']));
    expect(gradiBoulder.last, '9A');
  });

  test('CSV: si rilegge uguale', () {
    final a = SedutaArrampicata(
      idSessione: 'app-2026-10-31-arrampicata',
      data: DateTime(2026, 10, 31),
      ambiente: Ambiente.outdoor,
      disciplina: Disciplina.falesia,
      luogo: 'Arco, Massone',
      gradoMax: '6b+',
      stile: 'Lavorata',
      chiuse: 8,
      provate: 2,
      corda: 'Da primo',
      altezzaM: 25,
      progetto: '7a',
    );
    final t = Tabella(
      {for (final (i, c) in arrampicataHeader.indexed) c: i},
      [a.toRow()],
    );
    final b = SedutaArrampicata.da(t, t.righe.single)!;
    expect(b.toRow(), a.toRow());
    expect(b.metri, 200);
    expect(b.riassunto, [
      'Outdoor · Falesia · Arco, Massone',
      'Grado più difficile: 6b+ (lavorata)',
      '8 vie chiuse, 2 provate',
      'circa 200 m saliti · da primo',
      'Progetto: 7a',
    ]);
  });

  test('boulder: niente metri né corda', () {
    final a = SedutaArrampicata(
      idSessione: 'x',
      data: DateTime(2026, 10, 31),
      disciplina: Disciplina.boulder,
      chiuse: 12,
      corda: 'Da primo',
      altezzaM: 15,
    );
    expect(a.metri, 0);
    expect(a.toRow()[9], '');
    expect(a.riassunto.last, '12 blocchi chiusi');
  });

  test('record e scheda della sessione dell\'orologio', () {
    final tutte = [
      SedutaArrampicata(
        idSessione: 'a',
        data: DateTime(2026, 10, 1),
        gradoMax: '6c',
      ),
      SedutaArrampicata(
        idSessione: 'b',
        data: DateTime(2026, 10, 8),
        gradoMax: '6b+',
      ),
      SedutaArrampicata(
        idSessione: 'c',
        data: DateTime(2026, 10, 9),
        disciplina: Disciplina.boulder,
        gradoMax: '7A',
      ),
    ];
    expect(recordArrampicata(tutte, Disciplina.falesia), (
      '6c',
      DateTime(2026, 10, 1),
    ));
    expect(recordArrampicata(tutte, Disciplina.boulder)?.$1, '7A');
    // L'orologio ha preso il posto della seduta dell'app: vale lo stesso giorno.
    expect(
      arrampicataDi(tutte, 'hc-99', DateTime(2026, 10, 8))?.idSessione,
      'b',
    );
  });
}
