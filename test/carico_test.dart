import 'package:allenamenti_app/carico.dart';
import 'package:allenamenti_app/models.dart';
import 'package:allenamenti_app/obiettivo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const zone = Zone(fcMax: 180, fcRiposo: 50);
  final oggi = DateTime(2026, 10, 22); // giovedì
  Sessione s(
    int giorniFa, {
    String sport = 'Corsa',
    int min = 45,
    int fc = 0,
    String tipo = '',
  }) => Sessione(
    id: '$giorniFa$sport$min',
    data: oggi.subtract(Duration(days: giorniFa)),
    sport: sport,
    durataMin: min,
    fcMedia: fc,
    tipo: tipo,
  );

  group('fatica e carico', () {
    test('il feedback ha la precedenza', () {
      expect(faticaStimata(s(0, fc: 150), zone, rpe: 9), 9);
      expect(carico(s(0, min: 40), zone, rpe: 6), 240);
    });

    test('senza feedback la fatica viene dalla FC media', () {
      // 130 bpm = 61,5% della riserva: zona 2, fatica ~5.
      expect(faticaStimata(s(0, fc: 130), zone), closeTo(5.5, 0.1));
      // 165 bpm = 88%: soglia alta, fatica ~9.
      expect(faticaStimata(s(0, fc: 165), zone), closeTo(9.4, 0.1));
      expect(faticaStimata(s(0, fc: 60), zone), 1);
    });

    test('senza FC si usa il tipo di seduta', () {
      expect(faticaStimata(s(0, tipo: 'Lungo'), zone), 4);
      expect(faticaStimata(s(0, tipo: 'Fartlek'), zone), 7);
      expect(faticaStimata(s(0, tipo: 'HIIT'), zone), 8);
      expect(faticaStimata(s(0), zone), 5);
    });
  });

  group('rapporto acuto/cronico', () {
    Map<DateTime, double> settimane(List<double> perSettimana) {
      // Un giorno di carico per settimana, dalla più vecchia alla più recente.
      final out = <DateTime, double>{};
      for (var i = 0; i < perSettimana.length; i++) {
        out[soloData(
              oggi.subtract(Duration(days: 7 * (perSettimana.length - 1 - i))),
            )] =
            perSettimana[i];
      }
      return out;
    }

    test('carico costante: rapporto 1, equilibrato', () {
      final r = rapportoAcutoCronico(settimane([500, 500, 500, 500]), oggi)!;
      expect(r, closeTo(1, 0.01));
      expect(statoCarico(r), StatoCarico.equilibrato);
    });

    test('settimana molto più carica: rischio', () {
      final r = rapportoAcutoCronico(settimane([400, 400, 400, 1200]), oggi)!;
      expect(r, closeTo(2.0, 0.01));
      expect(statoCarico(r), StatoCarico.rischio);
      expect(statoCarico(0.5), StatoCarico.inCalo);
      expect(statoCarico(1.4), StatoCarico.attenzione);
    });

    test('con meno di tre settimane di dati non si calcola', () {
      expect(rapportoAcutoCronico(settimane([500, 500]), oggi), isNull);
      expect(rapportoAcutoCronico({}, oggi), isNull);
    });
  });

  group('piano e svolto', () {
    final lunedi = lunediDi(oggi);
    PianoRiga p(int giorno, String sport, {int min = 45}) => PianoRiga(
      data: lunedi.add(Duration(days: giorno)),
      fascia: 'Mattina',
      sport: sport,
      durataMin: min,
    );
    Sessione fatta(int giorno, String sport, {int min = 44}) => Sessione(
      id: '$giorno$sport',
      data: lunedi.add(Duration(days: giorno)),
      sport: sport,
      durataMin: min,
    );

    test('fatte, saltate, da fare e in più', () {
      final piano = [
        p(0, 'Forza'), // lunedì: fatta
        p(1, 'Bici'), // martedì: saltata
        p(3, 'Corsa'), // giovedì (oggi): da fare
        p(5, 'Corsa'), // sabato: da fare
        p(6, 'Riposo'), // non conta
      ];
      final svolte = [fatta(0, 'Forza'), fatta(2, 'Nuoto', min: 30)];
      final c = confrontaSettimana(piano, svolte, lunedi, oggi);
      expect(c.fatte.map((r) => r.sport), ['Forza']);
      expect(c.saltate.map((r) => r.sport), ['Bici']);
      expect(c.daFare.length, 2);
      expect(c.extra.map((s) => s.sport), ['Nuoto']);
      expect(c.previste, 4);
      expect(c.minutiPrevisti, 180);
      expect(c.minutiFatti, 74);
    });
  });
}
