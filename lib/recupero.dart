import 'csv.dart';
import 'models.dart';

/// Dati di recupero giorno per giorno, da Health Connect: FC a riposo, HRV
/// (RMSSD) e sonno della notte che finisce quel giorno.

const recuperoHeader = ['data', 'fc_riposo', 'hrv_ms', 'sonno_min'];

class GiornoRecupero {
  final DateTime data;
  final int fcRiposo; // 0 = non misurata
  final double hrv; // ms, 0 = non misurata
  final int sonnoMin; // 0 = non misurato
  const GiornoRecupero(
    this.data, {
    this.fcRiposo = 0,
    this.hrv = 0,
    this.sonnoMin = 0,
  });

  List<String> toRow() => [
    isoData(data),
    fcRiposo == 0 ? '' : '$fcRiposo',
    hrv == 0 ? '' : hrv.toStringAsFixed(1),
    sonnoMin == 0 ? '' : '$sonnoMin',
  ];

  static GiornoRecupero? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    if (d == null) return null;
    return GiornoRecupero(
      d,
      fcRiposo: numero(t.v(r, 'fc_riposo')).round(),
      hrv: numero(t.v(r, 'hrv_ms')).toDouble(),
      sonnoMin: numero(t.v(r, 'sonno_min')).round(),
    );
  }
}

/// Un valore letto da Health Connect: quando è finito e quanto vale.
typedef Misurazione = (DateTime, double);

/// Raggruppa per giorno: la FC a riposo più bassa, la media dell'HRV e la somma
/// del sonno finito quel giorno (la notte conta per il giorno del risveglio).
List<GiornoRecupero> giorniRecupero({
  List<Misurazione> fcRiposo = const [],
  List<Misurazione> hrv = const [],
  List<Misurazione> sonno = const [],
}) {
  final fc = <DateTime, double>{};
  for (final (t, v) in fcRiposo) {
    final d = soloData(t);
    if (v > 0 && (fc[d] == null || v < fc[d]!)) fc[d] = v;
  }
  final hrvGiorno = <DateTime, List<double>>{};
  for (final (t, v) in hrv) {
    if (v > 0) (hrvGiorno[soloData(t)] ??= []).add(v);
  }
  final dormito = <DateTime, double>{};
  for (final (t, v) in sonno) {
    final d = soloData(t);
    dormito[d] = (dormito[d] ?? 0) + v;
  }
  final giorni = {...fc.keys, ...hrvGiorno.keys, ...dormito.keys}.toList()
    ..sort();
  return [
    for (final d in giorni)
      GiornoRecupero(
        d,
        fcRiposo: (fc[d] ?? 0).round(),
        hrv: hrvGiorno[d] == null
            ? 0
            : hrvGiorno[d]!.reduce((a, b) => a + b) / hrvGiorno[d]!.length,
        sonnoMin: (dormito[d] ?? 0).round(),
      ),
  ];
}

/// Unisce i giorni appena letti a quelli salvati: un giorno riletto sostituisce
/// quello vecchio.
List<GiornoRecupero> unisciRecupero(
  List<GiornoRecupero> vecchi,
  List<GiornoRecupero> nuovi,
) {
  final m = {
    for (final g in vecchi) g.data: g,
    for (final g in nuovi) g.data: g,
  };
  return m.values.toList()..sort((a, b) => a.data.compareTo(b.data));
}

double _mediana(List<double> v) {
  final s = [...v]..sort();
  final m = s.length ~/ 2;
  return s.length.isOdd ? s[m] : (s[m - 1] + s[m]) / 2;
}

/// FC a riposo tipica: mediana degli ultimi 14 giorni (0 se non ci sono dati).
int fcRiposoTipica(List<GiornoRecupero> giorni, DateTime oggi) {
  final v = [
    for (final g in giorni)
      if (g.fcRiposo > 0 &&
          !g.data.isAfter(oggi) &&
          oggi.difference(g.data).inDays < 14)
        g.fcRiposo.toDouble(),
  ];
  return v.isEmpty ? 0 : _mediana(v).round();
}

enum StatoRecupero { buono, normale, basso }

// Come la pillola in alto: "Energia" buona, normale o bassa.
const nomiRecupero = {
  StatoRecupero.buono: 'Energia buona',
  StatoRecupero.normale: 'Energia normale',
  StatoRecupero.basso: 'Energia bassa',
};

const consigliRecupero = {
  StatoRecupero.buono: 'Giornata adatta anche a una seduta di qualità.',
  StatoRecupero.normale: 'Allenati come previsto, ascoltando le sensazioni.',
  StatoRecupero.basso:
      'Meglio una seduta facile o un giorno di riposo: abbassa l\'intensità.',
};

/// Un dato del recupero di oggi, da disegnare su una barra: [posizione] va
/// da 0 a 1 (0,5 = il tuo solito), [verso] dice se è buono (+1), nella norma
/// (0) o un campanello (-1).
class Indicatore {
  final String nome;
  final String valore;
  final String riferimento;
  final double posizione;
  final int verso;
  const Indicatore(
    this.nome,
    this.valore,
    this.riferimento,
    this.posizione,
    this.verso,
  );
}

class Prontezza {
  final StatoRecupero stato;
  final List<String> motivi;
  final GiornoRecupero giorno;
  final List<Indicatore> indicatori;
  const Prontezza(
    this.stato,
    this.motivi,
    this.giorno, [
    this.indicatori = const [],
  ]);
}

double _sulla(double v, double da, double a) =>
    ((v - da) / (a - da)).clamp(0.0, 1.0).toDouble();

/// Com'è il recupero di oggi rispetto alle tue ultime 4 settimane. Null se
/// oggi non c'è nessun dato.
Prontezza? valutaRecupero(List<GiornoRecupero> giorni, DateTime oggi) {
  final o = soloData(oggi);
  final g = giorni.where((x) => x.data == o).firstOrNull;
  if (g == null) return null;
  final prima = giorni.where(
    (x) => x.data.isBefore(o) && o.difference(x.data).inDays <= 28,
  );
  var punti = 0;
  final motivi = <String>[];
  final indicatori = <Indicatore>[];

  final hrv = [
    for (final x in prima)
      if (x.hrv > 0) x.hrv,
  ];
  if (g.hrv > 0 && hrv.length >= 5) {
    final media = hrv.reduce((a, b) => a + b) / hrv.length;
    indicatori.add(
      Indicatore(
        'Variabilità cardiaca (HRV)',
        '${g.hrv.round()} ms',
        'di solito ${media.round()} ms · più alta è meglio',
        _sulla(g.hrv, media * 0.7, media * 1.3),
        g.hrv < media * 0.9 ? -1 : (g.hrv > media * 1.05 ? 1 : 0),
      ),
    );
    if (g.hrv < media * 0.9) {
      punti -= 1;
      motivi.add(
        'HRV ${g.hrv.round()} ms, sotto la tua media (${media.round()} ms)',
      );
    } else if (g.hrv > media * 1.05) {
      punti += 1;
      motivi.add('HRV ${g.hrv.round()} ms, sopra la tua media');
    }
  }

  final fc = [
    for (final x in prima)
      if (x.fcRiposo > 0) x.fcRiposo.toDouble(),
  ];
  if (g.fcRiposo > 0 && fc.length >= 5) {
    final tipica = _mediana(fc);
    // Barra rovesciata: più bassa è meglio, quindi va verso destra.
    indicatori.add(
      Indicatore(
        'FC a riposo',
        '${g.fcRiposo} bpm',
        'di solito ${tipica.round()} bpm · più bassa è meglio',
        _sulla(-g.fcRiposo.toDouble(), -(tipica + 10), -(tipica - 10)),
        g.fcRiposo >= tipica + 5 ? -1 : (g.fcRiposo <= tipica - 3 ? 1 : 0),
      ),
    );
    if (g.fcRiposo >= tipica + 5) {
      punti -= 1;
      motivi.add(
        'FC a riposo ${g.fcRiposo} bpm, più alta del solito (${tipica.round()})',
      );
    }
  }

  if (g.sonnoMin > 0) {
    final ore =
        '${g.sonnoMin ~/ 60} h ${(g.sonnoMin % 60).toString().padLeft(2, '0')}';
    indicatori.add(
      Indicatore(
        'Sonno',
        ore,
        'bene da 7 h 30 in su, poco sotto le 6 h',
        _sulla(g.sonnoMin.toDouble(), 240, 540),
        g.sonnoMin < 360 ? -1 : (g.sonnoMin >= 450 ? 1 : 0),
      ),
    );
    if (g.sonnoMin < 360) {
      punti -= 1;
      motivi.add('Hai dormito poco ($ore)');
    } else if (g.sonnoMin >= 450) {
      punti += 1;
      motivi.add('Hai dormito bene ($ore)');
    }
  }

  final stato = punti <= -2
      ? StatoRecupero.basso
      : punti >= 1
      ? StatoRecupero.buono
      : StatoRecupero.normale;
  return Prontezza(stato, motivi, g, indicatori);
}
