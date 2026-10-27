/// Dettagli di una sessione di Health Connect oltre ai totali: segmenti
/// (esercizi con ripetizioni), lap e distanze parziali.
class SegmentoHc {
  final DateTime inizio;
  final DateTime fine;
  final int tipo; // ExerciseSegment.SEGMENT_TYPE_*
  final int ripetizioni;
  const SegmentoHc(this.inizio, this.fine, this.tipo, this.ripetizioni);
  Duration get durata => fine.difference(inizio);
}

class LapHc {
  final DateTime inizio;
  final DateTime fine;
  final double? metri;
  const LapHc(this.inizio, this.fine, this.metri);
  Duration get durata => fine.difference(inizio);
}

class TrattoHc {
  final DateTime inizio;
  final DateTime fine;
  final double metri;
  const TrattoHc(this.inizio, this.fine, this.metri);
  Duration get durata => fine.difference(inizio);
}

class DettagliHc {
  final String titolo;
  final String note;
  final List<SegmentoHc> segmenti;
  final List<LapHc> lap;
  final List<TrattoHc> distanze;
  const DettagliHc({
    this.titolo = '',
    this.note = '',
    this.segmenti = const [],
    this.lap = const [],
    this.distanze = const [],
  });

  static DateTime _t(double ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms.round());

  /// Dalle liste piatte mandate da Android.
  factory DettagliHc.daMappa(Map<Object?, Object?> m) {
    List<double> l(String k) => (m[k] as List?)?.cast<double>() ?? const [];
    final s = l('segmenti'), p = l('lap'), d = l('distanze');
    return DettagliHc(
      titolo: '${m['titolo'] ?? ''}',
      note: '${m['note'] ?? ''}',
      segmenti: [
        for (var i = 0; i + 3 < s.length; i += 4)
          SegmentoHc(
            _t(s[i]),
            _t(s[i + 1]),
            s[i + 2].round(),
            s[i + 3].round(),
          ),
      ],
      lap: [
        for (var i = 0; i + 2 < p.length; i += 3)
          LapHc(_t(p[i]), _t(p[i + 1]), p[i + 2] < 0 ? null : p[i + 2]),
      ],
      distanze: [
        for (var i = 0; i + 2 < d.length; i += 3)
          TrattoHc(_t(d[i]), _t(d[i + 1]), d[i + 2]),
      ],
    );
  }
}
