import 'dart:io' show gzip;
import 'dart:typed_data';

import 'package:allenamenti_app/fit.dart';
import 'package:allenamenti_app/intervalli.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un piccolo file FIT scritto a mano, come quello di un orologio: un
/// messaggio "record" (da saltare), poi i giri.
class _ScriviFit {
  final _b = BytesBuilder();
  final bool grandeFine;
  _ScriviFit({this.grandeFine = false});

  Endian get _e => grandeFine ? Endian.big : Endian.little;

  void _n(int v, int byte) {
    final d = ByteData(byte);
    switch (byte) {
      case 1:
        d.setUint8(0, v);
      case 2:
        d.setUint16(0, v, _e);
      case 4:
        d.setUint32(0, v, _e);
    }
    _b.add(d.buffer.asUint8List());
  }

  void definizione(
    int locale,
    int globale,
    List<(int, int)> campi, {
    int sviluppatore = 0,
  }) {
    _b.addByte(0x40 | locale | (sviluppatore > 0 ? 0x20 : 0));
    _b.addByte(0);
    _b.addByte(grandeFine ? 1 : 0);
    _n(globale, 2);
    _b.addByte(campi.length);
    for (final (numero, byte) in campi) {
      _b.add([numero, byte, byte == 1 ? 0x02 : (byte == 2 ? 0x84 : 0x86)]);
    }
    if (sviluppatore > 0) {
      _b.addByte(1);
      _b.add([0, sviluppatore, 0]);
    }
  }

  void dati(int locale, List<(int, int)> valori, {int sviluppatore = 0}) {
    _b.addByte(locale);
    for (final (v, byte) in valori) {
      _n(v, byte);
    }
    _b.add(List.filled(sviluppatore, 0xAA));
  }

  List<int> file() {
    final corpo = _b.toBytes();
    final h = ByteData(14)
      ..setUint8(0, 14)
      ..setUint8(1, 0x20)
      ..setUint16(2, 2100, Endian.little)
      ..setUint32(4, corpo.length, Endian.little);
    final out = BytesBuilder()
      ..add(h.buffer.asUint8List(0, 8))
      ..add('.FIT'.codeUnits)
      ..add([0, 0])
      ..add(corpo)
      ..add([0, 0]); // CRC: non si controlla
    return out.toBytes();
  }
}

// Campi del giro nell'ordine scritto: start_time, total_elapsed_time,
// total_timer_time, total_distance, avg_heart_rate, avg_power, intensity.
const _campiGiro = [(2, 4), (7, 4), (8, 4), (9, 4), (15, 1), (19, 2), (23, 1)];

/// 5 novembre 2026 alle 7:17 (ora italiana), in secondi FIT.
final _inizio = DateTime.utc(
  2026,
  11,
  5,
  6,
  17,
).difference(DateTime.utc(1989, 12, 31)).inSeconds;

List<(int, int)> _giro(
  int da,
  int secondi,
  double metri, {
  int fc = 0xFF,
  int watt = 0xFFFF,
  int intensita = 0,
}) => [
  (_inizio + da, 4),
  (secondi * 1000 + 400, 4),
  (secondi * 1000, 4),
  ((metri * 100).round(), 4),
  (fc, 1),
  (watt, 2),
  (intensita, 1),
];

List<int> _tempoRun({bool grandeFine = false}) {
  final w = _ScriviFit(grandeFine: grandeFine)
    // Un punto del percorso (record, 20): non è un giro, si salta.
    ..definizione(0, 20, [(253, 4), (3, 1)], sviluppatore: 2)
    ..dati(0, [(_inizio, 4), (110, 1)], sviluppatore: 2)
    ..definizione(1, 19, _campiGiro);
  // Il tempo run del 5/11 come lo dà il Garmin: 10 min di riscaldamento
  // (spezzati dal giro automatico di 1 km), 25 min, 10 min, 1:30 in più.
  var da = 0;
  for (final (s, m, fc) in const [
    (380, 1004.0, 117),
    (221, 594.0, 121),
    (365, 1001.0, 148),
    (374, 999.0, 156),
    (461, 997.0, 158),
    (300, 650.0, 157),
    (342, 1017.0, 152),
    (258, 803.0, 140),
    (90, 248.0, 141),
  ]) {
    w.dati(1, _giro(da, s, m, fc: fc));
    da += s;
  }
  return w.file();
}

void main() {
  test('i giri del tempo run, con tempo, metri e battito', () {
    final g = giriDaFit(_tempoRun());
    expect(g.length, 9);
    expect(g.first.inizio, DateTime.utc(2026, 11, 5, 6, 17));
    expect(g.first.secondi, 380); // il cronometro, non il tempo totale
    expect(g.first.metri, 1004);
    expect(g.first.fcMedia, 117);
    expect(g.first.wattMedi, 0); // senza misuratore: non valido → 0
    expect(g[5].secondi, 300);
    expect(g.fold(0, (t, x) => t + x.secondi), 2791);
  });

  test('anche big-endian e compresso con gzip', () {
    expect(giriDaFit(_tempoRun(grandeFine: true)).length, 9);
    expect(giriDaFit(gzip.encode(_tempoRun())).length, 9);
  });

  test('giri di riposo e watt della bici', () {
    final w = _ScriviFit()
      ..definizione(3, 19, _campiGiro)
      ..dati(3, _giro(0, 480, 4000, fc: 160, watt: 231))
      ..dati(3, _giro(480, 120, 700, fc: 130, watt: 110, intensita: 1));
    final g = giriDaFit(w.file());
    expect(g.first.wattMedi, 231);
    expect(g.first.riposo, isFalse);
    expect(g.last.riposo, isTrue);
  });

  test('un file che non è un FIT o è tagliato non dà giri', () {
    expect(giriDaFit('<gpx></gpx>'.codeUnits), isEmpty);
    expect(giriDaFit(const []), isEmpty);
    final f = _tempoRun();
    expect(giriDaFit(f.sublist(0, f.length ~/ 2)).length, lessThan(9));
  });

  test('dal file al riepilogo: 10 + 25 + 10 minuti, poi 1:30 in più', () {
    WorkoutStep passo(int ordine, String fase, String nome, String minuti) =>
        WorkoutStep(
          id: 'corsa_2026-11-05',
          sport: 'Corsa',
          nome: 'Tempo run',
          durataTot: 45,
          ordine: ordine,
          fase: fase,
          descrizione: nome,
          serie: '1',
          ripetizioni: '',
          distanzaM: '',
          durataMin: minuti,
          intensita: '',
          recuperoS: '',
          note: '',
        );
    final previsto = [
      passo(1, 'riscaldamento', 'Corsa facile', '10'),
      passo(2, 'principale', 'Corsa a ritmo sostenuto', '25'),
      passo(3, 'defaticamento', 'Corsa facile', '10'),
    ];
    final l = abbinaAlPiano(
      'Corsa',
      intervalliDaGiri(giriDaFit(_tempoRun())),
      previsto,
    );
    final fasi = fasiDegliIntervalli(l, previsto);
    int minuti(String fase) => [
      for (var k = 0; k < l.length; k++)
        if (fasi[k] == fase) l[k].secondi,
    ].fold(0, (a, b) => a + b);
    expect(minuti('riscaldamento'), 601);
    expect(minuti('principale'), 1500);
    expect(minuti('defaticamento'), 600);
    expect(fasi.last, ''); // il minuto e mezzo in più: fuori programma
    expect(l.first.inizioS, 0);
    // Una riga per fase: i giri di 1 km sono uniti.
    expect(l.map((i) => i.nome), [
      'Corsa facile',
      'Corsa a ritmo sostenuto',
      'Corsa facile',
      '',
    ]);
    expect(l[1].inizioS, 601);
    expect(l[1].metri, 3647);
    expect(l[1].fcMedia, 155); // media pesata sul tempo dei 4 giri
    expect(rigaIntervallo(l[1], 'Corsa'), startsWith('3,65 km · 25:00 · '));
  });
}
