import 'esercizi.dart';
import 'models.dart';
import 'l10n/lingua.dart';

// Mobilità e stretching: sedute di movimenti lenti e allungamenti, quasi tutti
// a tempo, che si seguono bene nella modalità allenamento. Ogni seduta insiste
// su una zona del corpo, a rotazione; dopo corsa o bici tocca a anche e gambe.

const sportMobilita = 'Mobilità';
const prefissoMobilita = 'mobilita_';

/// Zone del corpo su cui può insistere una seduta, con i muscoli di ognuna.
const focusMobilita = {
  'Anche e gambe': {
    'quadriceps',
    'hamstring',
    'gluteal',
    'calves',
    'adductors',
    'abductors',
  },
  'Schiena': {'lower-back', 'upper-back', 'lats', 'abdominals', 'obliques'},
  'Spalle e petto': {'deltoids', 'chest', 'triceps', 'biceps', 'trapezius'},
};

/// Ripetizioni di un esercizio di mobilità: tutto a tempo, così la modalità
/// allenamento passa da sola al successivo. Quelli su un lato solo hanno
/// 30 secondi per lato, che l'allenamento divide in destra e sinistra; gli
/// altri lo stesso tempo tutto insieme (le circonduzioni delle braccia, che
/// scaldano, la metà).
String durataMobilita(Esercizio e) => e.lati
    ? l10n.n30SLato
    : _circonduzione(e)
    ? '30 s'
    : '60 s';

/// Le circonduzioni vanno all'inizio: scaldano. Si riconoscono dall'id, che
/// non cambia con la lingua.
bool _circonduzione(Esercizio e) => e.id.contains('Circles');

/// Una seduta di [minuti] minuti centrata su [focus]. [rotazione] cambia gli
/// esercizi da una seduta all'altra.
List<WorkoutStep> sedutaMobilita({
  required List<Esercizio> esercizi,
  required Attrezzatura attrezzatura,
  required DateTime data,
  required int minuti,
  required String focus,
  int rotazione = 0,
}) {
  final opzioni = [
    for (final e in esercizi)
      if (e.tipo == 'mobilita' && e.fattibile(attrezzatura)) e,
  ];
  if (opzioni.isEmpty) return const [];
  final zona = focusMobilita[focus] ?? const <String>{};
  final n = opzioni.length;
  final girati = [for (var i = 0; i < n; i++) opzioni[(i + rotazione) % n]];
  int punteggio(Esercizio e) =>
      {...e.muscoli, ...e.muscoliSecondari}.intersection(zona).length;
  // Prima quelli della zona scelta; a parità resta l'ordine della rotazione.
  final ordine = [for (var i = 0; i < n; i++) i]
    ..sort((a, b) {
      final c = punteggio(girati[b]).compareTo(punteggio(girati[a]));
      return c != 0 ? c : a.compareTo(b);
    });
  // Circa 75 secondi per esercizio, cambio compreso.
  final posti = (minuti * 60 / 75).floor().clamp(4, 40).toInt();
  final quanti = posti < n ? posti : n;
  final giri = posti >= quanti * 1.6 ? 2 : 1;
  final scelti = [for (final i in ordine.take(quanti)) girati[i]]
    // Le circonduzioni scaldano: vanno all'inizio.
    ..sort(
      (a, b) =>
          (_circonduzione(b) ? 1 : 0).compareTo(_circonduzione(a) ? 1 : 0),
    );
  final nome = '$focus · $minuti min';
  return [
    for (var i = 0; i < scelti.length; i++)
      WorkoutStep(
        id: '$prefissoMobilita${isoData(data)}',
        sport: sportMobilita,
        nome: nome,
        durataTot: minuti,
        ordine: i + 1,
        fase: _circonduzione(scelti[i]) ? 'riscaldamento' : 'mobilità',
        descrizione: scelti[i].nome,
        serie: giri > 1 ? '$giri' : '',
        ripetizioni: durataMobilita(scelti[i]),
        distanzaM: '',
        durataMin: '',
        intensita: '',
        recuperoS: '15',
        // Il consiglio una volta sola, sul primo esercizio.
        note: i == 0 ? l10n.movimentiLentiRespiraCalma : '',
        esercizio: scelti[i].id,
      ),
  ];
}

class PianoMobilita {
  final List<WorkoutStep> passi;
  final List<ProgrammaRiga> programma;
  final Map<DateTime, String> tipi; // zona del corpo di ogni seduta
  const PianoMobilita(this.passi, this.programma, this.tipi);
}

/// Sedute di mobilità per i giorni del piano da [da] in poi.
PianoMobilita generaPianoMobilita({
  required List<PianoRiga> piano,
  required List<Esercizio> esercizi,
  required Attrezzatura attrezzatura,
  required DateTime da,
}) {
  final giorni = <DateTime, PianoRiga>{};
  for (final r in piano) {
    if (stessoSport(r.sport, sportMobilita) && !r.data.isBefore(da)) {
      giorni.putIfAbsent(r.data, () => r);
    }
  }
  final date = giorni.keys.toList()..sort();
  final focus = focusMobilita.keys.toList();
  final passi = <WorkoutStep>[];
  final programma = <ProgrammaRiga>[];
  final tipi = <DateTime, String>{};
  for (var k = 0; k < date.length; k++) {
    final d = date[k];
    final ieri = DateTime(d.year, d.month, d.day - 1);
    final gambe = piano.any(
      (r) =>
          (r.data == ieri || r.data == d) &&
          (stessoSport(r.sport, 'Corsa') || stessoSport(r.sport, 'Bici')),
    );
    final f = gambe ? focus.first : focus[k % focus.length];
    final minuti = giorni[d]!.durataMin > 0 ? giorni[d]!.durataMin : 20;
    final s = sedutaMobilita(
      esercizi: esercizi,
      attrezzatura: attrezzatura,
      data: d,
      minuti: minuti,
      focus: f,
      rotazione: k * 3,
    );
    if (s.isEmpty) continue;
    passi.addAll(s);
    programma.add(
      ProgrammaRiga(data: d, sport: sportMobilita, idWorkout: s.first.id),
    );
    tipi[d] = f;
  }
  return PianoMobilita(passi, programma, tipi);
}
