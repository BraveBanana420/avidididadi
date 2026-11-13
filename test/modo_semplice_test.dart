import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/profilo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Profilo riletto(Profilo p) =>
      Profilo.da(Tabella.da(toCsv([profiloHeader, ...p.toRows()])));

  test('chi usava già l\'app (riga assente) vede le funzioni avanzate', () {
    expect(Profilo.da(null).modoAvanzato, true);
    final vecchio = Tabella.da(
      toCsv([
        profiloHeader,
        ['nome', 'Anna'],
        ['benvenuto', 'si'],
      ]),
    );
    expect(Profilo.da(vecchio).modoAvanzato, true);
    expect(Profilo.da(vecchio).senzaLungo, false);
  });

  test('modo semplice e seduta lunga spenta restano salvati', () {
    final p = Profilo()
      ..avanzata = 'no'
      ..senzaLungo = true;
    final r = riletto(p);
    expect(r.modoAvanzato, false);
    expect(r.senzaLungo, true);
  });

  test('funzioni avanzate accese a mano', () {
    final p = Profilo()..avanzata = 'si';
    expect(riletto(p).modoAvanzato, true);
  });
}
