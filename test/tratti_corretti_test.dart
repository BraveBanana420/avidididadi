import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/riepilogo_condiviso.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un caso vero: una nuotata in cui un 50 m a un braccio è stato fatto
/// partire e fermare in 11 secondi (per poterlo correggere dopo), e in cui
/// 2 minuti di chiacchiere sono finiti dentro gli ultimi 200 m.
void main() {
  IntervalloFatto t(int inizio, int secondi, double metri) => IntervalloFatto(
    recupero: metri == 0,
    inizioS: inizio,
    secondi: secondi,
    metri: metri,
  );

  final orologio = [
    t(0, 300, 200),
    t(300, 11, 50), // il 50 m segnato in 11"
    t(311, 30, 0),
    t(341, 75, 50),
    t(416, 30, 0),
    t(446, 420, 200), // 5 min di nuoto + 2 di pausa
  ];
  final corretti = [
    t(0, 300, 200),
    t(300, 80, 50), // il tempo vero del 50 m a un braccio
    t(380, 30, 0),
    t(410, 75, 50),
    t(485, 30, 0),
    t(515, 300, 200),
    t(815, 120, 0), // i 2 minuti di chiacchiere, ora pausa
  ];

  test('il 100 più veloce sbagliato sparisce con i tratti corretti', () {
    expect(passiRipetute(orologio), [150, 22, 150, 210]);
    expect(passiRipetute(corretti), [150, 160, 150, 150]);
  });

  test('passo medio delle sole vasche nuotate, senza le pause', () {
    // 755 s per 500 m.
    expect(passoNuotatoDaTratti(corretti), 151);
    expect(passoNuotatoDaTratti([t(0, 60, 0)]), isNull);
  });

  test('velocità per i grafici: un campione al secondo, pause a zero', () {
    final inizio = DateTime(2026, 11, 13, 7);
    final v = velocitaDaTratti(corretti, inizio);
    expect(v.length, 935);
    expect(v.first.t, inizio);
    expect(v.first.v, closeTo(200 / 300, 1e-9));
    expect(v[300].v, closeTo(50 / 80, 1e-9)); // il 50 m a un braccio
    expect(v[390].v, 0); // pausa
    expect(v.last.t, inizio.add(const Duration(seconds: 934)));
    expect(v.last.v, 0); // i 2 minuti di pausa in fondo
    // Nessun tratto più veloce di quello vero: niente 0:22 /100 m.
    final massimo = v.map((c) => c.v).reduce((a, b) => a > b ? a : b);
    expect(100 / massimo, closeTo(150, 0.1));
  });
}
