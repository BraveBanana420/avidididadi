import 'csv.dart';
import 'models.dart';
import 'obiettivo.dart';

const sessi = ['Uomo', 'Donna'];

const profiloHeader = ['chiave', 'valore'];

/// Dati anagrafici, salvati in profilo.csv come coppie chiave/valore.
class Profilo {
  String nome = '';
  String cognome = '';
  DateTime? nascita;
  String sesso = '';
  double altezzaCm = 0;
  String foto = ''; // nome del file nella cartella dell'app
  // Piano di forza: scelti alla creazione; il livello poi si adatta ai feedback.
  String obiettivo = '';
  String livello = '';
  DateTime? inizioForza; // da qui si contano i blocchi di 4 settimane
  int regolazione = 0; // passi di carico decisi dai feedback
  DateTime? cambioLivello; // ultimo cambio di livello automatico
  // Corsa, nuoto e bici generati dall'app (vuoto = workout Garmin fissi).
  Set<String> sportGenerati = {};
  // Le attività scelte: si vedono solo queste (vuoto = non ancora scelte, tutte).
  Set<String> attivita = {};
  DateTime? inizioEndurance; // da qui si contano i blocchi di 4 settimane
  Map<String, int> regolazioneEndurance = {}; // per sport, dai feedback
  Map<String, String> progressione = {}; // per sport: durata, intensita, auto
  bool benvenuto = false; // configurazione guidata già fatta (o saltata)
  // Funzioni avanzate (zone, watt, sensori, intervals.icu): 'si', 'no', o
  // vuoto per chi usava l'app prima di questa scelta, che le vede tutte.
  String avanzata = '';

  /// In modo semplice le funzioni avanzate restano nascoste.
  bool get modoAvanzato => avanzata != 'no';

  // Niente seduta lunga di corsa e bici: durano tutte quanto scelto.
  bool senzaLungo = false;
  String terminiAccettati = ''; // versione di termini e informativa accettata
  // Gara obiettivo (vuota = nessuna).
  String garaSport = '';
  String garaTipo = '';
  DateTime? garaData;
  int garaTempoMin = 0;
  // Correzioni manuali delle zone (0 = usa la stima).
  int fcMaxManuale = 0;
  int fcRiposoManuale = 0;
  int passoCriticoManuale = 0; // secondi per 100 m
  int ftpManuale = 0; // watt; 0 = quello di intervals.icu, se c'è
  int ftpCorsaManuale = 0; // watt; 0 = intervals.icu, altrimenti la stima
  // Quando l'FTP della bici e il passo critico sono stati confermati (scritti,
  // da un test o da una proposta accettata): servono a proporre un test.
  DateTime? ftpData;
  DateTime? passoCriticoData;
  // Test proposti e rimandati: sport -> fino a quando non riproporli.
  final Map<String, DateTime> testRimandati = {};

  Obiettivo? get obiettivoGara => garaSport.isEmpty || garaData == null
      ? null
      : Obiettivo(
          sport: garaSport,
          gara: garaTipo,
          data: garaData!,
          tempoMin: garaTempoMin,
        );

  String get nomeCompleto => '$nome $cognome'.trim();

  String get iniziali => [
    nome,
    cognome,
  ].where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).join();

  /// Età calcolata dalla data di nascita, così resta sempre aggiornata.
  int? get eta {
    final n = nascita;
    if (n == null) return null;
    final oggi = DateTime.now();
    var a = oggi.year - n.year;
    final primaDelCompleanno =
        oggi.month < n.month || (oggi.month == n.month && oggi.day < n.day);
    return primaDelCompleanno ? a - 1 : a;
  }

  List<List<String>> toRows() => [
    ['nome', nome],
    ['cognome', cognome],
    ['nascita', nascita == null ? '' : isoData(nascita!)],
    ['sesso', sesso],
    ['altezza_cm', fmtNum(altezzaCm)],
    ['foto', foto],
    ['obiettivo', obiettivo],
    ['livello', livello],
    ['inizio_forza', inizioForza == null ? '' : isoData(inizioForza!)],
    ['regolazione', '$regolazione'],
    ['cambio_livello', cambioLivello == null ? '' : isoData(cambioLivello!)],
    ['sport_generati', sportGenerati.join(',')],
    [
      'inizio_endurance',
      inizioEndurance == null ? '' : isoData(inizioEndurance!),
    ],
    [
      'regolazione_endurance',
      regolazioneEndurance.entries.map((e) => '${e.key}:${e.value}').join(','),
    ],
    ['benvenuto', benvenuto ? 'si' : ''],
    ['termini', terminiAccettati],
    [
      'progressione',
      progressione.entries.map((e) => '${e.key}:${e.value}').join(','),
    ],
    ['gara_sport', garaSport],
    ['gara_tipo', garaTipo],
    ['gara_data', garaData == null ? '' : isoData(garaData!)],
    ['gara_tempo_min', garaTempoMin == 0 ? '' : '$garaTempoMin'],
    ['fc_max', fcMaxManuale == 0 ? '' : '$fcMaxManuale'],
    ['fc_riposo', fcRiposoManuale == 0 ? '' : '$fcRiposoManuale'],
    ['passo_critico_s', passoCriticoManuale == 0 ? '' : '$passoCriticoManuale'],
    ['ftp', ftpManuale == 0 ? '' : '$ftpManuale'],
    ['ftp_corsa', ftpCorsaManuale == 0 ? '' : '$ftpCorsaManuale'],
    ['attivita', attivita.join(',')],
    ['senza_lungo', senzaLungo ? 'si' : ''],
    ['avanzata', avanzata],
    ['ftp_data', ftpData == null ? '' : isoData(ftpData!)],
    [
      'passo_critico_data',
      passoCriticoData == null ? '' : isoData(passoCriticoData!),
    ],
    [
      'test_rimandati',
      testRimandati.entries
          .map((e) => '${e.key}:${isoData(e.value)}')
          .join(','),
    ],
  ];

  static Profilo da(Tabella? t) {
    final p = Profilo();
    if (t == null) return p;
    final m = {for (final r in t.righe) t.v(r, 'chiave'): t.v(r, 'valore')};
    p.nome = m['nome'] ?? '';
    p.cognome = m['cognome'] ?? '';
    p.nascita = parseData(m['nascita'] ?? '');
    p.sesso = m['sesso'] ?? '';
    p.altezzaCm = numero(m['altezza_cm'] ?? '');
    p.foto = m['foto'] ?? '';
    p.obiettivo = m['obiettivo'] ?? '';
    p.livello = m['livello'] ?? '';
    p.inizioForza = parseData(m['inizio_forza'] ?? '');
    p.regolazione = int.tryParse(m['regolazione'] ?? '') ?? 0;
    p.cambioLivello = parseData(m['cambio_livello'] ?? '');
    p.sportGenerati = (m['sport_generati'] ?? '')
        .split(',')
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty)
        .toSet();
    p.attivita = (m['attivita'] ?? '')
        .split(',')
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty)
        .toSet();
    p.inizioEndurance = parseData(m['inizio_endurance'] ?? '');
    p.benvenuto = m['benvenuto'] == 'si';
    p.senzaLungo = m['senza_lungo'] == 'si';
    p.avanzata = m['avanzata'] ?? '';
    p.terminiAccettati = m['termini'] ?? '';
    for (final x in (m['regolazione_endurance'] ?? '').split(',')) {
      final kv = x.split(':');
      final v = kv.length == 2 ? int.tryParse(kv[1]) : null;
      if (v != null) p.regolazioneEndurance[kv[0].trim()] = v;
    }
    for (final x in (m['progressione'] ?? '').split(',')) {
      final kv = x.split(':');
      if (kv.length == 2 && kv[1].trim().isNotEmpty) {
        p.progressione[kv[0].trim()] = kv[1].trim();
      }
    }
    p.garaSport = m['gara_sport'] ?? '';
    p.garaTipo = m['gara_tipo'] ?? '';
    p.garaData = parseData(m['gara_data'] ?? '');
    p.garaTempoMin = int.tryParse(m['gara_tempo_min'] ?? '') ?? 0;
    p.fcMaxManuale = int.tryParse(m['fc_max'] ?? '') ?? 0;
    p.fcRiposoManuale = int.tryParse(m['fc_riposo'] ?? '') ?? 0;
    p.passoCriticoManuale = int.tryParse(m['passo_critico_s'] ?? '') ?? 0;
    p.ftpManuale = int.tryParse(m['ftp'] ?? '') ?? 0;
    p.ftpCorsaManuale = int.tryParse(m['ftp_corsa'] ?? '') ?? 0;
    p.ftpData = parseData(m['ftp_data'] ?? '');
    p.passoCriticoData = parseData(m['passo_critico_data'] ?? '');
    for (final x in (m['test_rimandati'] ?? '').split(',')) {
      final kv = x.split(':');
      final d = kv.length == 2 ? parseData(kv[1].trim()) : null;
      if (d != null) p.testRimandati[kv[0].trim()] = d;
    }
    return p;
  }
}

/// Dà una data all'FTP e al passo critico scritti prima che l'app salvasse
/// quando sono stati confermati. Vero se ha cambiato qualcosa.
bool datePerSoglieVecchie(Profilo p, DateTime oggi) {
  var cambiato = false;
  if (p.ftpManuale > 0 && p.ftpData == null) {
    p.ftpData = oggi;
    cambiato = true;
  }
  if (p.passoCriticoManuale > 0 && p.passoCriticoData == null) {
    p.passoCriticoData = oggi;
    cambiato = true;
  }
  return cambiato;
}

/// Campi delle misure corporee, nell'ordine delle colonne di misure.csv.
const campiMisure = [
  'peso_kg',
  'braccio_cm',
  'petto_cm',
  'vita_cm',
  'fianchi_cm',
  'coscia_cm',
];
const misureHeader = ['data', ...campiMisure];

/// Peso e misure rilevati in un giorno; un campo assente non è stato misurato.
class Misura {
  final DateTime data;
  final Map<String, double> valori;
  Misura(this.data, this.valori);

  List<String> toRow() => [
    isoData(data),
    for (final c in campiMisure) fmtNum(valori[c] ?? 0),
  ];

  static Misura? da(Tabella t, List<String> r) {
    final d = parseData(t.v(r, 'data'));
    if (d == null) return null;
    return Misura(d, {
      for (final c in campiMisure)
        if (numero(t.v(r, c)) > 0) c: numero(t.v(r, c)),
    });
  }
}
