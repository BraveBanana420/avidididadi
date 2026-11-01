import 'package:allenamenti_app/feedback.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/sessioni_eliminate.dart';
import 'package:allenamenti_app/sincronizzazione.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final giorno = DateTime(2026, 10, 30);
  final app = Sessione(
    id: 'app-2026-10-30-camminata-1905',
    data: giorno,
    sport: 'Camminata',
    durataMin: 35,
    fonte: fonteApp,
  );
  final garmin = Sessione(
    id: 'hc-abc',
    data: giorno,
    sport: 'Corsa',
    durataMin: 48,
  );
  final fbGarmin = FeedbackSessione(
    data: giorno,
    sport: 'Corsa',
    fatica: 6,
    idSessione: 'hc-abc',
  );
  final fbAMano = FeedbackSessione(data: giorno, fatica: 5);

  test('quella dell\'app si cancella davvero', () {
    final r = togliSessione(
      app,
      storico: [app],
      nascoste: {},
      feedback: [fbAMano],
    );
    expect(r.storico, isEmpty);
    expect(r.nascoste, isEmpty);
    expect(r.feedback, [fbAMano]);
  });

  test('quella dell\'orologio si nasconde, con il suo feedback', () {
    final r = togliSessione(
      garmin,
      storico: [app],
      nascoste: {},
      feedback: [fbGarmin, fbAMano],
    );
    expect(r.storico, [app]);
    expect(r.nascoste, {'hc-abc'});
    expect(r.feedback, [fbAMano]);
    // Alla sincronizzazione dopo torna da Health Connect, ma resta fuori.
    expect(senzaNascoste([app, garmin], r.nascoste), [app]);
  });

  test('il feedback legato a un pezzo della sessione va via anche lui', () {
    Sessione pezzo(String id) =>
        Sessione(id: id, data: giorno, sport: 'Corsa', durataMin: 24);
    final ricomposta = Sessione(
      id: 'hc-1',
      data: giorno,
      sport: 'Corsa',
      durataMin: 48,
      parti: [pezzo('hc-1'), pezzo('hc-2')],
    );
    final fb = FeedbackSessione(data: giorno, fatica: 7, idSessione: 'hc-2');
    final r = togliSessione(
      ricomposta,
      storico: [],
      nascoste: {},
      feedback: [fb],
    );
    expect(r.feedback, isEmpty);
  });
}
