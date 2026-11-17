import 'csv.dart';
import 'models.dart';
import 'l10n/lingua.dart';

// Registro dell'arrampicata: dove, cosa (vie in falesia o boulder), grado più
// difficile chiuso e come, quante salite e quanti metri. Una riga per seduta.

const sportArrampicata = 'Arrampicata';

const arrampicataHeader = [
  'id_sessione',
  'data',
  'ambiente',
  'disciplina',
  'luogo',
  'grado_max',
  'stile',
  'chiuse',
  'provate',
  'corda',
  'altezza_m',
  'progetto',
];

/// Indoor (palestra) o outdoor (roccia).
enum Ambiente { indoor, outdoor }

/// Vie con la corda o boulder, blocchi bassi sul materasso. Nel file la prima
/// resta "falesia".
enum Disciplina { falesia, boulder }

/// Come è stato chiuso il grado più difficile.
const stili = ['A vista', 'Flash', 'Lavorata'];

/// Come si sale in falesia.
const corde = ['Da primo', 'Da secondo'];

/// Scala francese per le vie: 4a … 9c.
final gradiFalesia = [
  '3',
  for (final n in [4, 5])
    for (final l in ['a', 'b', 'c']) '$n$l',
  for (final n in [6, 7, 8, 9])
    for (final l in ['a', 'b', 'c'])
      for (final p in ['', '+'])
        if (!(n == 9 && l == 'c' && p == '+')) '$n$l$p',
];

/// Scala Fontainebleau per i blocchi: 3 … 9A.
final gradiBoulder = [
  '3',
  '4',
  '4+',
  '5',
  '5+',
  for (final n in [6, 7, 8])
    for (final l in ['A', 'B', 'C'])
      for (final p in ['', '+']) '$n$l$p',
  '9A',
];

List<String> gradiDi(Disciplina d) =>
    d == Disciplina.falesia ? gradiFalesia : gradiBoulder;

/// Posizione del grado nella sua scala (-1 se non c'è): per confrontarli.
int livello(Disciplina d, String grado) => gradiDi(d).indexOf(grado);

/// Altezza tipica di una via, per stimare i metri saliti.
int altezzaTipica(Ambiente a) => a == Ambiente.indoor ? 15 : 25;

/// Quello che si segna dopo una seduta di arrampicata.
class SedutaArrampicata {
  final String idSessione;
  final DateTime data;
  final Ambiente ambiente;
  final Disciplina disciplina;
  final String luogo; // palestra o falesia
  final String gradoMax; // il più difficile chiuso
  final String stile; // a vista, flash, lavorata
  final int chiuse; // vie o blocchi chiusi
  final int provate; // provati senza chiuderli
  final String corda; // da primo o da secondo (solo vie)
  final int altezzaM; // altezza media delle vie (solo falesia)
  final String progetto; // grado che sta provando, non ancora chiuso
  const SedutaArrampicata({
    required this.idSessione,
    required this.data,
    this.ambiente = Ambiente.indoor,
    this.disciplina = Disciplina.falesia,
    this.luogo = '',
    this.gradoMax = '',
    this.stile = '',
    this.chiuse = 0,
    this.provate = 0,
    this.corda = '',
    this.altezzaM = 0,
    this.progetto = '',
  });

  bool get falesia => disciplina == Disciplina.falesia;

  /// Metri saliti: vie chiuse per altezza media (il boulder non li conta).
  int get metri => falesia ? chiuse * altezzaM : 0;

  List<String> toRow() => [
    idSessione,
    isoData(data),
    ambiente.name,
    disciplina.name,
    luogo,
    gradoMax,
    stile,
    '$chiuse',
    '$provate',
    falesia ? corda : '',
    falesia && altezzaM > 0 ? '$altezzaM' : '',
    progetto,
  ];

  static SedutaArrampicata? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    final id = t.v(r, 'id_sessione');
    if (d == null || id.isEmpty) return null;
    return SedutaArrampicata(
      idSessione: id,
      data: d,
      ambiente: t.v(r, 'ambiente') == 'outdoor'
          ? Ambiente.outdoor
          : Ambiente.indoor,
      disciplina: t.v(r, 'disciplina') == 'boulder'
          ? Disciplina.boulder
          : Disciplina.falesia,
      luogo: t.v(r, 'luogo'),
      gradoMax: t.v(r, 'grado_max'),
      stile: t.v(r, 'stile'),
      chiuse: int.tryParse(t.v(r, 'chiuse')) ?? 0,
      provate: int.tryParse(t.v(r, 'provate')) ?? 0,
      // Le sedute segnate prima con il vecchio nome.
      corda: t.v(r, 'corda') == 'Moulinette' ? 'Da secondo' : t.v(r, 'corda'),
      altezzaM: int.tryParse(t.v(r, 'altezza_m')) ?? 0,
      progetto: t.v(r, 'progetto'),
    );
  }

  /// Righe brevi per il dettaglio della seduta.
  List<String> get riassunto => [
    [
      ambiente == Ambiente.indoor ? 'Indoor' : 'Outdoor',
      falesia ? 'Vie' : 'Boulder',
      if (luogo.isNotEmpty) luogo,
    ].join(' · '),
    if (gradoMax.isNotEmpty)
      l10n.gradoPiuDifficile(
        gradoMax,
        stile.isEmpty ? '' : ' (${stile.toLowerCase()})',
      ),
    if (chiuse > 0 || provate > 0)
      [
        if (chiuse > 0)
          '$chiuse ${falesia ? l10n.vieChiuse : l10n.blocchiChiusi}',
        if (provate > 0) l10n.quanteProvate(provate, falesia ? 'e' : 'i'),
      ].join(', '),
    if (metri > 0 || (falesia && corda.isNotEmpty))
      [
        if (metri > 0) l10n.circaMSaliti(metri),
        if (corda.isNotEmpty) corda.toLowerCase(),
      ].join(' · '),
    if (progetto.isNotEmpty) l10n.progetto(progetto),
  ];
}

/// La scheda di una sessione: per id, altrimenti quella dello stesso giorno
/// (se vale la sessione dell'orologio, l'id dell'app non c'è più).
SedutaArrampicata? arrampicataDi(
  List<SedutaArrampicata> tutte,
  String idSessione,
  DateTime data,
) =>
    tutte.where((a) => a.idSessione == idSessione).firstOrNull ??
    tutte.where((a) => a.data == soloData(data)).firstOrNull;

/// Il grado più difficile chiuso in una disciplina, con il giorno.
(String, DateTime)? recordArrampicata(
  List<SedutaArrampicata> tutte,
  Disciplina d,
) {
  (String, DateTime)? best;
  for (final a in tutte) {
    if (a.disciplina != d || livello(d, a.gradoMax) < 0) continue;
    if (best == null || livello(d, a.gradoMax) > livello(d, best.$1)) {
      best = (a.gradoMax, a.data);
    }
  }
  return best;
}
