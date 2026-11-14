import 'intervalli.dart';
import 'models.dart';
import 'obiettivo.dart';
import 'serie_sessione.dart';
import 'voce.dart';

// Previsto e fatto in un grafico solo, per la corsa: gli obiettivi dei
// blocchi cambiano unità (una zona di battito, un passo al km), quindi tutto
// si porta su una scala sola, il "livello": la zona n va da n a n+1, sotto
// la zona 1 si sta tra 0 e 1, il massimo è 6.

/// Il livello di un battito nelle zone dell'utente: 3,5 = a metà della zona 3.
double livelloBattito(num bpm, Zone z) {
  final n = z.zonaDi(bpm.round());
  if (n == 0) {
    final da = z.zona(1).$1;
    return da <= 0 ? 0 : (bpm / da).clamp(0.0, 1.0).toDouble();
  }
  final (da, fine) = z.zona(n);
  final a = fine + 1;
  if (a <= da) return n.toDouble();
  return (n + (bpm - da) / (a - da)).clamp(0.0, 6.0).toDouble();
}

/// Dove iniziano le zone del passo, in parti della velocità di soglia; l'ultimo
/// numero chiude la zona 5.
const _quoteVelocita = [0.60, 0.78, 0.88, 0.95, 1.02, 1.12];

/// Il livello di una velocità (m/s) rispetto a quella di soglia. La soglia è
/// una stima: sposta in alto o in basso fascia e linea insieme, quindi il
/// confronto tra previsto e fatto resta giusto.
double livelloVelocita(double v, double soglia) {
  if (soglia <= 0 || v <= 0) return 0;
  final r = v / soglia;
  const q = _quoteVelocita;
  if (r < q[0]) return r / q[0];
  for (var n = 1; n < q.length; n++) {
    if (r < q[n]) return n + (r - q[n - 1]) / (q[n] - q[n - 1]);
  }
  return 6;
}

/// La velocità di soglia della corsa (m/s), stimata: la corsa più veloce di
/// almeno 20 minuti negli ultimi sei mesi. Null se non ce ne sono.
double? sogliaCorsa(List<Sessione> sessioni, DateTime oggi) {
  final daSeiMesi = oggi.subtract(const Duration(days: 183));
  double? migliore;
  for (final s in sessioni) {
    if (!stessoSport(s.sport, 'Corsa') ||
        !s.data.isAfter(daSeiMesi) ||
        s.durataMin < 20 ||
        s.distanzaKm <= 0) {
      continue;
    }
    final v = s.distanzaKm * 1000 / (s.durataMin * 60);
    // Fuori da qui non è una corsa: un errore del GPS o dei dati.
    if (v < 1.5 || v > 7) continue;
    if (migliore == null || v > migliore) migliore = v;
  }
  return migliore;
}

/// Un blocco con l'intensità da tenere, in secondi dall'inizio della seduta:
/// tra i livelli [giu] e [su]. [passo]: l'obiettivo era un passo al km (la
/// linea lì si disegna dalla velocità), altrimenti una zona di battito.
typedef FasciaIntensita = ({int da, int a, double giu, double su, bool passo});

/// "Ripetuta 2/6" → "Ripetuta".
String _senzaNumero(String nome) =>
    nome.trim().replaceFirst(RegExp(r'\s+\d+/\d+$'), '');

/// Le fasce dell'intensità prevista, tratto per tratto: l'obiettivo è quello
/// del passo in programma con lo stesso nome. Prima la zona ("zona 3"), poi
/// il passo ("5:30/km", con il 5% di margine come negli avvisi a voce), che
/// vale solo se c'è una [soglia]. Recuperi, tratti fuori programma e passi
/// "a sensazione" non hanno fascia.
List<FasciaIntensita> fasceIntensita(
  List<IntervalloFatto> tratti,
  List<WorkoutStep> passi, {
  double? soglia,
}) {
  final testi = <String, String>{};
  for (final p in passi) {
    final testo = '${p.intensita} ${p.note}';
    for (final nome in [p.descrizione.trim(), p.nome.trim()]) {
      if (nome.isNotEmpty) testi.putIfAbsent(nome, () => testo);
    }
  }
  final ordinati = [...tratti]..sort((a, b) => a.inizioS.compareTo(b.inizioS));
  final out = <FasciaIntensita>[];
  for (final (k, i) in ordinati.indexed) {
    if (i.recupero || i.secondi <= 0 || i.nome.isEmpty) continue;
    final testo = testi[i.nome.trim()] ?? testi[_senzaNumero(i.nome)];
    if (testo == null) continue;
    final fine = k + 1 < ordinati.length && ordinati[k + 1].inizioS > i.inizioS
        ? ordinati[k + 1].inizioS
        : i.inizioS + i.secondi;
    if (zonaObiettivo(testo) case final z?) {
      out.add((
        da: i.inizioS,
        a: fine,
        giu: z.toDouble(),
        su: z + 1.0,
        passo: false,
      ));
    } else if (velocitaObiettivo(testo) case final v? when soglia != null) {
      out.add((
        da: i.inizioS,
        a: fine,
        giu: livelloVelocita(v * (1 - margineVelocita), soglia),
        su: livelloVelocita(v * (1 + margineVelocita), soglia),
        passo: true,
      ));
    }
  }
  return out;
}

/// La media di una serie ogni [passo] secondi dall'[inizio]: pezzo → media.
Map<int, double> _medie(List<Campione> serie, DateTime inizio, int passo) {
  final somme = <int, (double, int)>{};
  for (final c in serie) {
    final s = c.t.difference(inizio).inSeconds;
    if (s < 0) continue;
    final (t, n) = somme[s ~/ passo] ?? (0.0, 0);
    somme[s ~/ passo] = (t + c.v, n + 1);
  }
  return {for (final e in somme.entries) e.key: e.value.$1 / e.value.$2};
}

/// L'intensità tenuta in tutta la seduta, un punto ogni [passo] secondi.
/// Dentro una fascia a passo si guarda la velocità; altrove il battito, e
/// solo se il battito manca la velocità.
List<({double s, double livello})> lineaIntensita(
  SerieSessione serie,
  DateTime inizio,
  List<FasciaIntensita> fasce,
  Zone zone, {
  double? soglia,
  int passo = 15,
}) {
  final fc = _medie(serie.fc, inizio, passo);
  final vel = soglia == null
      ? const <int, double>{}
      : _medie(serie.velocita, inizio, passo);
  final chiavi = {...fc.keys, ...vel.keys}.toList()..sort();
  final out = <({double s, double livello})>[];
  for (final k in chiavi) {
    final s = k * passo + passo / 2;
    final aPasso = fasce.any((f) => f.passo && s >= f.da && s < f.a);
    final v = vel[k], b = fc[k];
    final double? livello;
    if (aPasso && v != null) {
      livello = livelloVelocita(v, soglia!);
    } else if (b != null && !aPasso) {
      livello = livelloBattito(b, zone);
    } else if (fc.isEmpty && v != null) {
      livello = livelloVelocita(v, soglia!);
    } else {
      livello = null;
    }
    if (livello != null) out.add((s: s, livello: livello));
  }
  return out;
}
