import 'dart:math' as math;

import 'feedback.dart';
import 'models.dart';

/// Adattamento delle sedute di corsa, nuoto e bici ai feedback: com'è andata
/// davvero (fatica rispetto all'attesa, passo rispetto al target) decide il
/// volume e l'intensità delle sedute future. La progressione parte da qui.

/// Una seduta in programma rispetto a quello che è stato fatto quel giorno.
enum StatoSeduta { svolta, sostituita, nonSvolta }

/// Oltre questa differenza di durata o distanza l'attività fatta non è la
/// seduta in programma, ma un'altra al suo posto.
const scartoSostituita = 0.4;

StatoSeduta statoSeduta({
  required PianoRiga previsto,
  required List<Sessione> fatte,
  int metriPrevisti = 0,
}) {
  final stesse = fatte
      .where(
        (s) => s.data == previsto.data && stessoSport(s.sport, previsto.sport),
      )
      .toList();
  if (stesse.isEmpty) return StatoSeduta.nonSvolta;
  final s = stesse.first;
  bool diversa(double fatto, double atteso) =>
      atteso > 0 &&
      fatto > 0 &&
      (fatto - atteso).abs() / atteso > scartoSostituita;
  if (diversa(s.durataMin.toDouble(), previsto.durataMin.toDouble()) ||
      diversa(s.distanzaKm * 1000, metriPrevisti.toDouble())) {
    return StatoSeduta.sostituita;
  }
  return StatoSeduta.svolta;
}

const _tipiNoti = [
  'test',
  'ftp',
  'lento',
  'lungo',
  'fartlek',
  'tempo',
  'ripetute',
  'ritmo gara',
  'allunghi',
  'tecnica',
  'soglia',
  'intervalli',
];

/// Fatica attesa (1-10) per quello che è stato fatto davvero: il tipo
/// dell'attività se si conosce, altrimenti quello in programma se è stato
/// fatto quello, altrimenti una seduta aerobica.
int faticaAttesa({
  Sessione? attivita,
  PianoRiga? previsto,
  StatoSeduta stato = StatoSeduta.svolta,
}) {
  final reale = (attivita?.tipo ?? '').toLowerCase();
  if (_tipiNoti.any(reale.contains)) return faticaPrevista(reale);
  if (stato == StatoSeduta.svolta && previsto != null) {
    return faticaPrevista(previsto.tipo);
  }
  return 4;
}

/// Risposte rapide sul passo della parte principale.
const esitiPasso = {'tenuto': 0.0, 'lento': 0.07, 'molto_lento': 0.15};

const nomiEsitiPasso = {
  'tenuto': 'Tenuto',
  'lento': 'Un po\' più lento',
  'molto_lento': 'Molto più lento',
};

/// Di quanto il passo eseguito è stato più lento del target (+0,10 = 10%).
/// Null se non si sa.
double? scartoPasso(FeedbackSessione f, int? target) {
  if (f.passoS > 0 && target != null && target > 0) {
    return f.passoS / target - 1;
  }
  return esitiPasso[f.esitoPasso];
}

enum EsitoSeduta { pesante, ok, facile }

/// Pesante: fatica di 2 o più sopra l'attesa, passo oltre il 5% più lento,
/// non completata o dolore. Facile: fatica di 2 o più sotto e target tenuto.
EsitoSeduta valutaSeduta({
  required FeedbackSessione f,
  required int atteso,
  double? scarto,
}) {
  if (!f.completata ||
      f.dolore ||
      f.fatica >= atteso + 2 ||
      (scarto != null && scarto > 0.05)) {
    return EsitoSeduta.pesante;
  }
  if (f.fatica <= atteso - 2 && (scarto == null || scarto <= 0.0)) {
    return EsitoSeduta.facile;
  }
  return EsitoSeduta.ok;
}

/// Il risultato degli esiti di uno sport: moltiplicatore del volume, passi di
/// intensità e, dopo due sedute pesanti di fila, settimana di scarico.
class Adattamento {
  final double volume;
  final int intensita;
  final DateTime? scaricoFino;
  const Adattamento({this.volume = 1, this.intensita = 0, this.scaricoFino});
}

const volumeMin = 0.6, volumeMax = 1.4;

/// Applica gli esiti in ordine di data. Pesante: volume -12,5% e intensità
/// non sopra lo zero. Nella norma: una sola variabile alla volta (+5% volume
/// oppure un passo di intensità, alternati in automatico). Facile: +7,5% o un
/// passo di intensità. [modo]: 'durata', 'intensita' o 'auto'.
Adattamento adatta(
  List<(DateTime, EsitoSeduta)> esiti, {
  String modo = 'auto',
}) {
  var volume = 1.0;
  var k = 0;
  var prossimaVolume = true;
  var pesantiDiFila = 0;
  DateTime? scarico;
  final ordinati = [...esiti]..sort((a, b) => a.$1.compareTo(b.$1));
  for (final (data, e) in ordinati) {
    final suVolume = switch (modo) {
      'durata' => true,
      'intensita' => false,
      _ => prossimaVolume,
    };
    switch (e) {
      case EsitoSeduta.pesante:
        volume *= 0.875;
        k = math.min(k, 0);
        pesantiDiFila++;
        if (pesantiDiFila >= 2) {
          scarico = soloData(data).add(const Duration(days: 7));
          pesantiDiFila = 0;
        }
      case EsitoSeduta.ok:
        if (suVolume) {
          volume *= 1.05;
        } else {
          k++;
        }
        prossimaVolume = !suVolume;
        pesantiDiFila = 0;
      case EsitoSeduta.facile:
        if (suVolume) {
          volume *= 1.075;
        } else {
          k++;
        }
        prossimaVolume = !suVolume;
        pesantiDiFila = 0;
    }
    volume = volume.clamp(volumeMin, volumeMax).toDouble();
    k = k.clamp(-3, 2);
  }
  return Adattamento(volume: volume, intensita: k, scaricoFino: scarico);
}

/// Passo target di una seduta di nuoto (secondi per 100 m) dai suoi step:
/// "passo 1:58/100 m" nella parte principale.
int? passoTargetDi(List<WorkoutStep> passi) {
  for (final p in passi.where((p) => p.fase == 'principale')) {
    final m = RegExp(r'(\d{1,2}):(\d{2})\s*/100').firstMatch(p.intensita);
    if (m != null) return int.parse(m[1]!) * 60 + int.parse(m[2]!);
  }
  return null;
}

/// Secondi di recupero previsti in una seduta (serie × recupero).
int recuperoPrevisto(List<WorkoutStep> passi) => passi.fold(0, (t, p) {
  final r = int.tryParse(p.recuperoS.trim()) ?? 0;
  final n = int.tryParse(p.serie.trim()) ?? 1;
  return t + r * math.max(1, n);
});

/// Un passo di nuoto credibile, in secondi per 100 m.
bool passoCredibile(num s) => s >= 60 && s <= 300;

/// Passo eseguito nella parte principale di una nuotata, in secondi per
/// 100 m: quello scritto nel feedback, oppure il target corretto dalla
/// risposta rapida, oppure una stima dal tempo in acqua (tolti i recuperi
/// previsti). Null se non si può dire.
int? passoEseguito({
  required Sessione s,
  FeedbackSessione? f,
  int? target,
  int recuperoS = 0,
}) {
  if (f != null && f.passoS > 0 && passoCredibile(f.passoS)) return f.passoS;
  final scarto = f == null ? null : esitiPasso[f.esitoPasso];
  if (scarto != null && target != null) {
    final v = (target * (1 + scarto)).round();
    if (passoCredibile(v)) return v;
  }
  final metri = s.distanzaKm * 1000;
  if (metri < 300 || s.durataMin <= 0) return null;
  final secondi = s.durataMin * 60 - recuperoS;
  // Senza recuperi noti si toglie il 15%, le pause tipiche in piscina.
  final inMovimento = recuperoS > 0 ? secondi : s.durataMin * 60 * 0.85;
  final v = (inMovimento / (metri / 100)).round();
  return passoCredibile(v) ? v : null;
}

double _mediana(List<int> v) {
  final s = [...v]..sort();
  final m = s.length ~/ 2;
  return s.length.isOdd ? s[m].toDouble() : (s[m - 1] + s[m]) / 2;
}

/// Passo di riferimento: mediana delle ultime 3 nuotate con un passo noto.
int? passoRiferimento(List<int> ultimiPassi) {
  final v = ultimiPassi.take(3).toList();
  return v.isEmpty ? null : _mediana(v).round();
}

/// Il target non è mai più veloce del 3% rispetto al riferimento.
int targetNuoto(int riferimento, {required bool soglia, int k = 0}) {
  final minimo = riferimento * 0.97;
  final base = soglia ? 0.97 : 1.0;
  final v = riferimento * (base - 0.01 * k);
  return math.max(minimo, v).round();
}

// ---------------------------------------------------------------------------
// Riepilogo delle modifiche davvero applicate a una seduta

final _metriNome = RegExp(r'(\d+)\s*m$');
final _passoTesto = RegExp(r'\d{1,2}:\d{2}/100 m');

String _quantita(WorkoutStep p) {
  final q = p.distanzaM.isNotEmpty
      ? '${p.distanzaM} m'
      : p.durataMin.isNotEmpty
      ? '${p.durataMin} min'
      : '';
  return p.serie.isNotEmpty && q.isNotEmpty ? '${p.serie}×$q' : q;
}

/// Le differenze tra la stessa seduta prima e dopo il ricalcolo, in parole:
/// "principale 3×200 m invece di 4×200 m", "passo 2:45/100 m invece di 1:58/100 m".
List<String> cambiSeduta(List<WorkoutStep> prima, List<WorkoutStep> dopo) {
  final out = <String>[];
  WorkoutStep? principale(List<WorkoutStep> l) =>
      l.where((p) => p.fase == 'principale').firstOrNull;
  final a = principale(prima), b = principale(dopo);
  if (a != null && b != null) {
    if (_quantita(a) != _quantita(b)) {
      out.add('principale ${_quantita(b)} invece di ${_quantita(a)}');
    }
    final pa = _passoTesto.firstMatch(a.intensita)?[0];
    final pb = _passoTesto.firstMatch(b.intensita)?[0];
    if (pa != null && pb != null && pa != pb) {
      out.add('passo $pb invece di $pa');
    } else if (pa == null &&
        a.intensita != b.intensita &&
        b.intensita.isNotEmpty) {
      out.add('intensità ${b.intensita} invece di ${a.intensita}');
    }
  }
  if (prima.isNotEmpty && dopo.isNotEmpty) {
    final ma = _metriNome.firstMatch(prima.first.nome)?[1];
    final mb = _metriNome.firstMatch(dopo.first.nome)?[1];
    if (ma != null && mb != null && ma != mb) {
      out.add('totale $mb m invece di $ma m');
    } else if (ma == null &&
        prima.first.durataTot != dopo.first.durataTot &&
        dopo.first.durataTot > 0) {
      out.add(
        'durata ${dopo.first.durataTot} min invece di ${prima.first.durataTot}',
      );
    }
  }
  return out;
}

/// La frase sull'esito del feedback, dai numeri veri.
String fraseEsito({
  required EsitoSeduta esito,
  required int fatica,
  required int atteso,
  double? scarto,
  bool scarico = false,
  required String sport,
}) {
  final s = sport.toLowerCase();
  final parti = <String>[
    switch (esito) {
      EsitoSeduta.pesante =>
        scarto != null && scarto > 0.05
            ? 'Passo più lento del target del ${(scarto * 100).round()}% '
                  '(fatica $fatica, attesa $atteso): alleggerisco il $s.'
            : 'Fatica $fatica, sopra l\'attesa ($atteso): alleggerisco il $s.',
      EsitoSeduta.ok =>
        'Fatica $fatica, in linea con l\'attesa ($atteso): progressione '
            'normale, una cosa alla volta.',
      EsitoSeduta.facile =>
        'Fatica $fatica, sotto l\'attesa ($atteso): piccola progressione.',
    },
    if (scarico) 'Due sedute pesanti di fila: settimana di scarico per il $s.',
  ];
  return parti.join(' ');
}

/// Metri previsti in una seduta (serie × distanza).
double metriDi(List<WorkoutStep> passi) => passi.fold(0.0, (t, p) {
  final m = double.tryParse(p.distanzaM.trim()) ?? 0;
  final n = int.tryParse(p.serie.trim()) ?? 1;
  return t + m * math.max(1, n);
});
