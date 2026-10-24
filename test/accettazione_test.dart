import 'package:allenamenti_app/app_state.dart';
import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/profilo.dart';
import 'package:allenamenti_app/pulse.dart';
import 'package:allenamenti_app/screens/accettazione_screen.dart';
import 'package:allenamenti_app/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('senza la spunta non si entra', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: creaTema(Brightness.dark),
        home: AccettazioneScreen(state: AppState()),
      ),
    );
    PulsantePrincipale entra() =>
        t.widget<PulsantePrincipale>(find.byType(PulsantePrincipale));
    expect(entra().onPressed, isNull);
    await t.tap(find.byType(Checkbox));
    await t.pump();
    expect(entra().onPressed, isNotNull);
  });

  test('la versione accettata si salva nel profilo', () {
    final p = Profilo()..terminiAccettati = '2026-10-24';
    final letto = Profilo.da(Tabella.da(toCsv([profiloHeader, ...p.toRows()])));
    expect(letto.terminiAccettati, '2026-10-24');
    expect(Profilo.da(null).terminiAccettati, isEmpty);
  });
}
