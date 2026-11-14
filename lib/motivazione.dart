import 'carico.dart';
import 'models.dart';
import 'registro_forza.dart';
import 'riepilogo_condiviso.dart';

// Motivazione leggera in Oggi: settimane di fila, traguardi e record.
// Solo numeri veri dello storico: niente punti, livelli o medaglie.

enum TipoSpinta { fila, traguardo, record }

/// Una riga di incoraggiamento: il tipo decide l'icona.
class Spinta {
  final TipoSpinta tipo;
  final String testo;
  const Spinta(this.tipo, this.testo);
}

/// Numeri di allenamenti che meritano una riga.
const traguardiAllenamenti = [1, 5, 10, 25, 50, 100, 150, 200, 300, 500, 1000];

/// Un traguardo o un record resta in vista per questi giorni dopo la seduta.
const _giorniInVista = 2;

DateTime _settimanaPrima(DateTime lunedi) =>
    DateTime(lunedi.year, lunedi.month, lunedi.day - 7);

/// Settimane di fila (da lunedì a domenica) con almeno un allenamento. La
/// settimana in corso non interrompe la fila finché non è finita.
int settimaneDiFila(Iterable<Sessione> sessioni, DateTime oggi) {
  final piene = {for (final s in sessioni) lunediDi(soloData(s.data))};
  var l = lunediDi(soloData(oggi));
  if (!piene.contains(l)) l = _settimanaPrima(l);
  var n = 0;
  while (piene.contains(l)) {
    n++;
    l = _settimanaPrima(l);
  }
  return n;
}

/// Questa settimana c'è già almeno un allenamento?
bool settimanaFatta(Iterable<Sessione> sessioni, DateTime oggi) {
  final l = lunediDi(soloData(oggi));
  return sessioni.any((s) => lunediDi(soloData(s.data)) == l);
}

bool _recente(DateTime giorno, DateTime oggi) {
  final g = soloData(oggi).difference(soloData(giorno)).inDays;
  return g >= 0 && g <= _giorniInVista;
}

/// Il traguardo appena toccato (es. 50 allenamenti), o null.
int? traguardoRecente(List<Sessione> sessioni, DateTime oggi) {
  if (!traguardiAllenamenti.contains(sessioni.length)) return null;
  final ultima = sessioni
      .map((s) => soloData(s.data))
      .reduce((a, b) => a.isAfter(b) ? a : b);
  return _recente(ultima, oggi) ? sessioni.length : null;
}

const _piuLunga = {
  'Corsa': 'La tua corsa più lunga',
  'Bici': 'La tua uscita in bici più lunga',
  'Nuoto': 'La tua nuotata più lunga',
  'Camminata': 'La tua camminata più lunga',
};

String _distanza(double km) => km >= 1
    ? '${km.toStringAsFixed(1).replaceAll('.', ',')} km'
    : '${(km * 1000).round()} m';

/// La distanza più lunga di sempre in uno sport, se è di questi giorni.
/// Servono almeno tre sedute: con una o due ogni uscita sarebbe un record.
String? distanzaRecord(List<Sessione> sessioni, DateTime oggi) {
  for (final e in _piuLunga.entries) {
    final mie = [
      for (final s in sessioni)
        if (stessoSport(s.sport, e.key) && s.distanzaKm > 0) s,
    ];
    if (mie.length < 3) continue;
    final migliore = mie.reduce((a, b) => b.distanzaKm > a.distanzaKm ? b : a);
    final pari = mie.where((s) => s.distanzaKm == migliore.distanzaKm).length;
    if (pari == 1 && _recente(migliore.data, oggi)) {
      return '${e.value}: ${_distanza(migliore.distanzaKm)}';
    }
  }
  return null;
}

/// Il record di forza di questi giorni, "Squat 60 kg (prima 55 kg)".
String? forzaRecord(List<SerieFatta> serie, DateTime oggi) {
  final d = soloData(oggi);
  for (var g = 0; g <= _giorniInVista; g++) {
    final r = recordDelGiorno(serie, DateTime(d.year, d.month, d.day - g));
    if (r != null) return r;
  }
  return null;
}

/// Le righe da mostrare in Oggi, dalla più importante. Vuoto se non c'è
/// niente da festeggiare: meglio il silenzio di una frase vuota.
List<Spinta> spinte({
  required List<Sessione> sessioni,
  required List<SerieFatta> serie,
  required DateTime oggi,
}) {
  final out = <Spinta>[];
  final n = traguardoRecente(sessioni, oggi);
  if (n != null) {
    out.add(
      Spinta(
        TipoSpinta.traguardo,
        n == 1 ? 'Primo allenamento fatto!' : 'Hai fatto $n allenamenti!',
      ),
    );
  }
  final forza = forzaRecord(serie, oggi);
  if (forza != null) out.add(Spinta(TipoSpinta.record, 'Record: $forza'));
  final km = distanzaRecord(sessioni, oggi);
  if (km != null) out.add(Spinta(TipoSpinta.record, km));
  final fila = settimaneDiFila(sessioni, oggi);
  if (fila >= 2) {
    out.add(
      Spinta(
        TipoSpinta.fila,
        // Un invito, non un ordine: niente scadenze né "devi".
        settimanaFatta(sessioni, oggi)
            ? '$fila settimane di fila: grande!'
            : '$fila settimane di fila. Vai per la ${fila + 1}?',
      ),
    );
  }
  return out;
}
