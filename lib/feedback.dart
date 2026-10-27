import 'csv.dart';
import 'generatore_endurance.dart';
import 'models.dart';

const feedbackHeader = [
  'data',
  'fatica',
  'completata',
  'dolore',
  'note',
  'sport',
  // Colonne aggiunte: l'attività davvero svolta e il passo della principale.
  'id_sessione',
  'passo_s',
  'esito_passo',
];

/// Feedback rapido a fine sessione, per ogni sport.
class FeedbackSessione {
  final DateTime data;
  final String sport; // le righe vecchie, senza sport, sono di forza
  final int fatica; // 1-10
  final bool completata; // tutte le serie fatte
  final bool dolore; // dolore o fastidio
  final String note;
  final String idSessione; // l'attività svolta (es. hc-…), vuoto se non c'è
  final int passoS; // passo della principale (s/100 m nel nuoto), 0 = non detto
  final String esitoPasso; // tenuto, lento, molto_lento o vuoto
  const FeedbackSessione({
    required this.data,
    required this.fatica,
    this.sport = 'Forza',
    this.completata = true,
    this.dolore = false,
    this.note = '',
    this.idSessione = '',
    this.passoS = 0,
    this.esitoPasso = '',
  });

  List<String> toRow() => [
    isoData(data),
    '$fatica',
    completata ? 'si' : 'no',
    dolore ? 'si' : 'no',
    note,
    sport,
    idSessione,
    passoS > 0 ? '$passoS' : '',
    esitoPasso,
  ];

  bool di(DateTime giorno, String s) =>
      data == soloData(giorno) && stessoSport(sport, s);

  static FeedbackSessione? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    final f = numero(t.v(r, 'fatica')).round();
    if (d == null || f < 1 || f > 10) return null;
    return FeedbackSessione(
      data: d,
      fatica: f,
      sport: t.v(r, 'sport').isEmpty ? 'Forza' : normSport(t.v(r, 'sport')),
      completata: t.v(r, 'completata') != 'no',
      dolore: t.v(r, 'dolore') == 'si',
      note: t.v(r, 'note'),
      idSessione: t.v(r, 'id_sessione'),
      passoS: int.tryParse(t.v(r, 'passo_s')) ?? 0,
      esitoPasso: t.v(r, 'esito_passo'),
    );
  }
}

/// Com'è andata rispetto alla fatica prevista dall'obiettivo.
enum Esito { facile, giusto, duro }

Esito esito(FeedbackSessione f, int fatica) {
  if (!f.completata || f.dolore || f.fatica >= fatica + 2) return Esito.duro;
  if (f.fatica <= fatica - 2) return Esito.facile;
  return Esito.giusto;
}

const _ordineLivelli = ['principiante', 'intermedio', 'avanzato'];

/// Quanto si spostano i carichi rispetto al piano di partenza: da -3 a +5 passi.
const regolazioneMin = -3, regolazioneMax = 5;

/// Nuova regolazione dopo l'ultimo feedback di [storico] (in ordine di data).
/// [dalCambio]: solo i feedback dopo l'ultimo cambio di livello contano per il livello.
({int regolazione, String livello, String messaggio}) regola({
  required List<FeedbackSessione> storico,
  required int faticaObiettivo,
  required int regolazione,
  required String livello,
  DateTime? dalCambio,
}) {
  final ultimo = storico.last;
  final e = esito(ultimo, faticaObiettivo);
  var r = regolazione;
  var l = livello;
  final msg = <String>[];
  switch (e) {
    case Esito.facile:
      r++;
      msg.add('Bene! Dalla prossima sessione aumento un po\' il carico.');
    case Esito.duro:
      r--;
      msg.add(
        ultimo.dolore
            ? 'Hai segnalato dolore: alleggerisco le prossime sessioni. '
                  'Se il dolore continua, fermati e chiedi a un medico.'
            : 'Alleggerisco un po\' le prossime sessioni.',
      );
    case Esito.giusto:
      msg.add('Carico giusto: si continua così.');
  }

  // Tre sessioni di fila nello stesso verso cambiano il livello.
  final recenti = storico
      .where((f) => dalCambio == null || f.data.isAfter(dalCambio))
      .toList();
  if (recenti.length >= 3) {
    final ultimi = recenti
        .sublist(recenti.length - 3)
        .map((f) => esito(f, faticaObiettivo));
    final i = _ordineLivelli.indexOf(l);
    if (ultimi.every((x) => x == Esito.facile) &&
        i >= 0 &&
        i < _ordineLivelli.length - 1) {
      l = _ordineLivelli[i + 1];
      r = 0;
      msg.add('Ti alleni meglio di quanto pensavi: passo al livello $l.');
    } else if (ultimi.every((x) => x == Esito.duro) && i > 0) {
      l = _ordineLivelli[i - 1];
      r = 0;
      msg.add('Passo al livello $l, più adatto per ora.');
    }
  }
  return (
    regolazione: r.clamp(regolazioneMin, regolazioneMax).toInt(),
    livello: l,
    messaggio: msg.join(' '),
  );
}

/// Fatica attesa per un tipo di seduta di corsa, nuoto o bici.
int faticaPrevista(String tipo) {
  final t = tipo.toLowerCase();
  if (t.contains('ripetute')) return 8;
  if (t.contains('fartlek') ||
      t.contains('tempo') ||
      t.contains('soglia') ||
      t.contains('intervalli') ||
      t.contains('ritmo gara')) {
    return 7;
  }
  return 4; // lento, lungo, tecnica, uscita, allunghi
}

/// Volume di corsa, nuoto e bici: da -3 a +3 passi del 5%.
const regolazioneEnduranceMin = -3, regolazioneEnduranceMax = 3;

/// Nuova regolazione di uno sport di resistenza dopo un feedback.
({int regolazione, String messaggio}) regolaEndurance(
  FeedbackSessione f,
  String tipo,
  int regolazione, {
  String modo = progressioneAuto,
}) {
  final e = esito(f, faticaPrevista(tipo));
  final r = switch (e) {
    Esito.facile => regolazione + 1,
    Esito.duro => regolazione - 1,
    Esito.giusto => regolazione,
  }.clamp(regolazioneEnduranceMin, regolazioneEnduranceMax).toInt();
  final sport = f.sport.toLowerCase();
  // Cambia la durata o l'intensità, secondo il modo scelto per lo sport.
  final suIntensita =
      dividiProgressione(r, modo).$2 !=
      dividiProgressione(regolazione, modo).$2;
  final messaggio = switch (e) {
    _ when f.dolore =>
      'Hai segnalato dolore: alleggerisco le prossime sedute di $sport. '
          'Se il dolore continua, fermati e chiedi a un medico.',
    Esito.facile when r == regolazione =>
      "Bene! Le sedute di $sport sono già al massimo dell'aumento.",
    Esito.facile when suIntensita =>
      "Bene! Aumento un po' l'intensità delle prossime sedute di $sport, "
          'a parità di tempo.',
    Esito.facile => "Bene! Allungo un po' le prossime sedute di $sport.",
    Esito.duro when suIntensita =>
      "Rendo un po' meno intense le prossime sedute di $sport.",
    Esito.duro => "Accorcio un po' le prossime sedute di $sport.",
    Esito.giusto => 'Fatica giusta: si continua così.',
  };
  return (regolazione: r, messaggio: messaggio);
}
