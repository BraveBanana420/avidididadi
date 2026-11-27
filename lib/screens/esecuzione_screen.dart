import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../generatore_endurance.dart';
import '../app_state.dart';
import '../arrampicata.dart';
import '../attivita_libera.dart';
import '../avvisi.dart';
import '../navigazione.dart';
import '../calorie.dart';
import '../contapassi.dart';
import '../battito.dart';
import '../animazioni_esercizi.dart';
import '../dati_live.dart';
import '../esecuzione.dart';
import '../esercizi.dart';
import '../glossario.dart';
import '../immagini.dart';
import '../in_corso.dart';
import '../intervalli.dart';
import '../gps.dart';
import '../models.dart';
import '../notifica_allenamento.dart';
import '../obiettivo.dart';
import '../percorso.dart';
import '../potenza.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../scheda.dart';
import '../sensori_bici.dart';
import '../tema.dart';
import '../voce.dart';
import '../serie_sessione.dart';
import '../sincronizzazione.dart';
import '../widgets.dart';
import 'arrampicata_sheet.dart';
import 'battito_sheet.dart';
import 'serie_a_mano_screen.dart';
import 'colonna_dati.dart';
import 'feedback_sheet.dart';
import 'grafici_screen.dart';
import 'mappa_live.dart';
import 'mappa_percorso.dart';
import 'modifica_sessione_screen.dart';
import 'percorsi_screen.dart';
import 'profilo_allenamento.dart';
import 'vista_bici.dart';
import 'opzioni_allenamento_screen.dart';
import '../l10n/lingua.dart';
import '../l10n/vocabolario.dart';

const _canale = MethodChannel('avidididadi/avvio');

/// Tiene acceso lo schermo durante l'allenamento (no-op fuori da Android).
Future<void> _schermoAcceso(bool acceso) async {
  try {
    await _canale.invokeMethod('schermoAcceso', acceso);
  } catch (_) {}
}

/// Apre la modalità allenamento per una seduta.
void avviaAllenamento(
  BuildContext context,
  AppState state, {
  required String sport,
  required String tipo,
  required String nome,
  required List<WorkoutStep> passi,
  bool libera = false,
  bool conGps = false,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => EsecuzioneScreen(
        state: state,
        sport: sport,
        tipo: tipo,
        nome: nome,
        passi: passi,
        libera: libera,
        conGps: conGps,
      ),
    ),
  );
}

/// Riapre una seduta interrotta (app chiusa da Android o bloccata), in pausa.
void riprendiAllenamento(
  BuildContext context,
  AppState state,
  AllenamentoInCorso r,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => EsecuzioneScreen(
        state: state,
        sport: r.sport,
        tipo: r.tipo,
        nome: r.nome,
        passi: r.passi,
        libera: r.libera,
        conGps: r.conGps,
        ripresa: r,
      ),
    ),
  );
}

/// Modalità allenamento: un esercizio alla volta, con cronometro totale,
/// conto alla rovescia per i blocchi a tempo e i recuperi, e "Fatto" per gli
/// esercizi a ripetizioni.
class EsecuzioneScreen extends StatefulWidget {
  final AppState state;
  final String sport;
  final String tipo;
  final String nome;
  final List<WorkoutStep> passi;
  final bool libera; // fuori dal piano: si aggiunge a quello che c'è

  /// GPS scelto a mano (altra attività, es. kayak): corsa, camminata e bici
  /// ce l'hanno già.
  final bool conGps;
  final AllenamentoInCorso? ripresa; // seduta interrotta da riprendere
  const EsecuzioneScreen({
    super.key,
    required this.state,
    required this.sport,
    required this.tipo,
    required this.nome,
    required this.passi,
    this.libera = false,
    this.conGps = false,
    this.ripresa,
  });

  @override
  State<EsecuzioneScreen> createState() => _EsecuzioneScreenState();
}

class _EsecuzioneScreenState extends State<EsecuzioneScreen> {
  static const _preparazione = 5; // secondi prima del primo esercizio

  late final List<Blocco> blocchi = blocchiDa(widget.passi);
  late final int nPassi = blocchi.isEmpty ? 0 : blocchi.last.passo + 1;
  final totale = Stopwatch();
  final blocco = Stopwatch();

  // Tempo già fatto prima di una ripresa: i cronometri ripartono da zero.
  Duration _baseTotale = Duration.zero;
  Duration _baseBlocco = Duration.zero;
  Duration get _tempoTotale => _baseTotale + totale.elapsed;
  Duration get _tempoBlocco => _baseBlocco + blocco.elapsed;
  DateTime _salvatoIl = DateTime(0);
  DateTime _notificataIl = DateTime(0);

  // Soste: la pausa automatica (se scelta) ferma il cronometro; [_movimento]
  // capisce sempre quando si è fermi, per il passo medio "in movimento".
  bool _pausaAuto = false;
  late RilevaSosta _autoPausa = RilevaSosta(
    sogliaDi(modoPausa.value, sogliaPausaKmh.value),
  );
  final _movimento = RilevaSosta(sogliaFermo);
  Duration _soste = Duration.zero; // in pausa automatica
  Duration _fermo = Duration.zero; // fermi a cronometro acceso
  DateTime? _ultimoControllo;

  /// Il tempo su cui si calcola il passo medio, come scelto nelle impostazioni.
  Duration get _tempoMedia {
    if (mediaConSoste.value) return _tempoTotale + _soste;
    final t = _tempoTotale - _fermo;
    return t.isNegative ? Duration.zero : t;
  }

  bool get _inPausa => pausa || _pausaAuto;

  /// Km della seduta: quelli scritti a mano (tapis roulant, rulli) prima del
  /// GPS.
  double get _km =>
      kmScritti(_kmScritti.text) ??
      (gps == null || gps!.percorso.vuoto
          ? 0
          : double.parse(gps!.km.toStringAsFixed(2)));

  /// Calorie stimate con quello che si sa: potenza, battito o velocità.
  Calorie? get _calorie => stimaCalorie(
    sport: widget.sport,
    tempo: _tempoTotale,
    km: _km,
    potenzaMedia: potenza.media,
    fcMedia: fc.media,
    pesoKg: widget.state.ultimaMisura('peso_kg')?.$1,
    eta: widget.state.profilo.eta,
    sesso: widget.state.profilo.sesso,
  );
  final tempi = <int, Duration>{}; // tempo impiegato per ogni blocco

  /// I blocchi com'è andata davvero, in ordine: per il riepilogo diviso in
  /// sezioni. Dopo una ripresa quelli di prima non ci sono più, e un elenco a
  /// metà non si salva.
  final _tratti = <TrattoApp>[];
  DateTime? _inizioTratto;
  double _metriInizio = 0;
  late final bool _trattiCompleti = widget.ripresa == null;

  /// Metri fatti finora: GPS all'aperto, sensore di velocità sui rulli.
  double get _metriOra =>
      gps != null && !gps!.percorso.vuoto ? gps!.km * 1000 : _metriSensore;

  /// Chiude il blocco in corso: va chiamata prima di cambiare blocco.
  void _chiudiTratto() {
    final inizio = _inizioTratto;
    if (inizio == null || preparati) return;
    _tratti.add((
      blocco: i,
      inizio: inizio,
      fine: DateTime.now(),
      secondi: _tempoBlocco.inSeconds,
      metri: (_metriOra - _metriInizio).clamp(0, double.infinity).toDouble(),
    ));
    _inizioTratto = null;
  }

  Timer? _tic;
  int i = 0;
  bool preparati = true; // conto alla rovescia iniziale
  bool pausa = false;
  bool finito = false;
  int extra = 0; // secondi aggiunti al recupero con "+15 s"
  int _ultimoBip = -1;

  /// Forza: ripetizioni e kg di ogni serie fatta, per blocco.
  final fatte = <int, (int, double)>{};

  /// Valori proposti (e ritoccati) per le serie non ancora finite.
  final _valori = <int, (int, double)>{};

  /// Quando è partito davvero (dopo "Preparati").
  DateTime? _partenza;
  late bool registra =
      widget.libera ||
      !widget.state.sessioni.any(
        (s) =>
            s.data == soloData(DateTime.now()) &&
            stessoSport(s.sport, widget.sport),
      );

  /// Corsa e bici: il percorso GPS, raccolto mentre l'allenamento è in corso.
  /// Corsa, camminata e bici al chiuso (tapis roulant, rulli): niente GPS,
  /// i km si scrivono alla fine.
  late final bool _conPercorso =
      sportConPercorso(widget.sport, widget.tipo) || widget.conGps;

  /// Sport con tapis roulant o rulli: solo lì c'è l'interruttore "Al chiuso".
  late final bool _conAttrezzo = sportConPercorso(widget.sport, widget.tipo);
  late bool _alChiuso = _conPercorso && tipoAlChiuso(widget.tipo);

  /// Corsa, bici e camminata si preparano con calma (rullo, percorso, GPS):
  /// si parte col tasto Inizia, senza conto alla rovescia.
  bool get _aspettaIlVia => preparati && _conPercorso;

  /// Corsa, bici e camminata hanno tanti dati: il tempo è una barra sempre in
  /// vista, non un cerchio da cercare scorrendo. La bici al chiuso e la mappa a
  /// tutto schermo hanno già il loro tempo.
  bool get _tempoPiatto =>
      _conPercorso &&
      !preparati &&
      !(_bici && gps == null) &&
      !(gps != null && vistaMappa.value == VistaMappa.schermo);

  /// Attività libera: il nome lo sai già e "Fatto" lo dice già il tempo (barra
  /// o cerchio). Nelle sedute programmate il testo resta: dice cosa fare in
  /// quel blocco.
  bool get _senzaTesto => widget.libera;
  bool _sceltoAllAperto = false; // l'interruttore spento a mano
  final _kmScritti = TextEditingController();

  late RegistratoreGps? gps = _conPercorso && !_alChiuso
      ? RegistratoreGps(widget.sport)
      : null;

  /// Giri di 1 km (5 in bici): l'ultimo compare per qualche secondo.
  late GiriLive? giri = gps == null ? null : GiriLive(metriGiro(widget.sport));
  Giro? _giroAvviso;
  DateTime? _giroFino;

  /// Battito dal sensore Bluetooth, se collegato.
  final fc = Statistiche();
  late final Zone _zone = widget.state.zone;

  /// Bici: potenza, cadenza e (al chiuso) distanza dai sensori collegati.
  late final bool _bici = stessoSport(widget.sport, 'Bici');
  final potenza = Statistiche();
  final cadenza = Statistiche();
  double _metriSensore = 0;
  DateTime? _ultimoCampione;
  DateTime _statisticheIl = DateTime(0);
  late final ZonePotenza? _zonePotenza = widget.state.zonePotenza;

  /// Un campione al secondo dei sensori, per i grafici della sessione.
  final _serieFc = <Campione>[];
  final _seriePotenza = <Campione>[];
  final _serieCadenza = <Campione>[];
  final _serieVelocita = <Campione>[];

  /// Corsa e camminata: i passi dal sensore del telefono, a cronometro acceso.
  late final bool _siCammina = siCammina(widget.sport);
  final contaPassi = ContaPassi();
  late final sensorePassi = SensorePassi(
    contaPassi,
    attivo: () => !preparati && !finito && !_inPausa,
  );

  /// Voce: esercizio che inizia, km, ritmo o zona sbagliati.
  final voce = Voce();
  final ritmo = ControlloRitmo();
  final _ritmoCadenza = ControlloRitmo();
  StreamSubscription<int>? _battiti;
  bool _battitoArrivato = false; // almeno un battito in questa seduta

  /// Percorso da seguire (GPX): mappa, curve e fuori percorso a voce.
  PercorsoSalvato? _percorso;
  Traccia? _traccia;
  Guida? _guida;
  DateTime? _posizioneGuida; // l'ultimo punto GPS dato alla guida
  final _pagine = PageController();
  int _pagina = 0;

  Blocco get b => blocchi[i];

  @override
  void initState() {
    super.initState();
    _schermoAcceso(true);
    caricaAvvisi();
    final notifiche = permessoNotifiche();
    Future<void>? gpsAcceso;
    pausaDaNotifica = _pausaDaNotifica;
    sensoreBattito.avvia();
    if (_bici) sensoreBici.avvia();
    _battiti = sensoreBattito.valori.stream.listen((v) {
      _battitoArrivato = true;
      if (!preparati && !pausa && !finito) fc.aggiungi(v);
    });
    final r = widget.ripresa;
    if (r != null) {
      _ripristina(r);
      if (gps != null && !finito) gpsAcceso = _accendiGps();
      _notifica();
    } else if (gps == null) {
      blocco.start();
    } else {
      // Il conto alla rovescia parte dopo l'eventuale richiesta del permesso.
      gpsAcceso = _accendiGps();
    }
    if (_siCammina && !finito) _accendiPassi([notifiche, ?gpsAcceso]);
    _caricaPercorso();
    _tic = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _aggiorna(),
    );
  }

  /// Accende il contapassi dopo le altre richieste: Android mostra un
  /// permesso alla volta.
  Future<void> _accendiPassi(List<Future<void>> prima) async {
    for (final f in prima) {
      try {
        await f;
      } catch (_) {}
    }
    if (!mounted) return;
    await sensorePassi.avvia();
    if (mounted) setState(() {});
  }

  /// Il percorso assegnato alla seduta di oggi, o quello che si seguiva
  /// prima dell'interruzione.
  Future<void> _caricaPercorso() async {
    if (!_conPercorso) return;
    final r = widget.ripresa;
    final p = r != null
        ? widget.state.percorsoSalvato(r.idPercorso)
        : widget.libera
        ? null
        : widget.state.percorsoDellaSeduta(DateTime.now(), widget.sport);
    if (p != null) await _usaPercorso(p, riprendiDa: r?.progressoPercorso);
  }

  /// Segue [p] (null: nessun percorso).
  Future<void> _usaPercorso(PercorsoSalvato? p, {double? riprendiDa}) async {
    final t = p == null ? null : await widget.state.tracciaDi(p);
    if (!mounted) return;
    setState(() {
      _percorso = t == null ? null : p;
      _traccia = t;
      _guida = t == null ? null : Guida(t, bici: _bici);
      if (riprendiDa != null) _guida?.riprendiDa(riprendiDa);
      _posizioneGuida = null;
    });
  }

  Future<void> _scegliPercorso() async {
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PercorsiScreen(state: widget.state, scegli: true),
      ),
    );
    final p = id == null ? null : widget.state.percorsoSalvato(id);
    if (p == null) return;
    await _usaPercorso(p);
    // Se c'è ancora la rete, la mappa si scarica per i tratti senza segnale.
    scaricaMappa(widget.state, p);
  }

  /// Passa alla guida ogni nuovo punto GPS; dopo il via, dice le curve e
  /// se si esce dal percorso (con bip e vibrazione, anche a voce spenta).
  void _seguiPercorso() {
    final g = _guida;
    final pos = gps?.ultimo;
    if (g == null || pos == null || pos.t == _posizioneGuida) return;
    _posizioneGuida = pos.t;
    final avvisi = g.aggiorna(
      pos.lat,
      pos.lon,
      DateTime.now(),
      velocita: gps?.velocitaRecente,
    );
    if (preparati || pausa) return;
    for (final a in avvisi) {
      avviso(fine: a.urgente);
      voce.di(
        a.frase,
        urgente: a.urgente,
        valida: a.tipo == TipoAvvisoGuida.curva
            ? const Duration(seconds: 15)
            : const Duration(minutes: 1),
      );
    }
  }

  /// "Mancano 12 chilometri." dopo il giro, se si segue un percorso.
  String get _mancano {
    final g = _guida;
    final m = g?.metriMancanti;
    if (g == null || m == null || g.fuori || g.arrivato || m < 300) return '';
    return l10nVoce.mancano(parlaMetri(m));
  }

  /// Prima di partire: al chiuso il GPS si spegne, all'aperto si riaccende.
  void _cambiaAlChiuso(bool chiuso) {
    if (chiuso == _alChiuso || !preparati) return;
    setState(() {
      _alChiuso = chiuso;
      if (chiuso) {
        _spegniGps();
      } else {
        gps = RegistratoreGps(widget.sport);
        giri = GiriLive(metriGiro(widget.sport));
      }
    });
    if (!chiuso) _accendiGps();
  }

  void _spegniGps() {
    gps?.ferma();
    gps?.dispose();
    gps = null;
    giri = null;
  }

  /// Rullo collegato: si è al chiuso, senza doverlo dire. Vale anche se si
  /// collega dopo il via, ma non se si è già fatta strada col GPS o se si è
  /// scelto a mano "all'aperto".
  void _rulloVuolDireAlChiuso() {
    if (!_bici || !_conPercorso || _alChiuso || _sceltoAllAperto) return;
    if (!sensoreBici.rulloInUso) return;
    if (!preparati && (gps?.km ?? 0) >= 0.1) return;
    setState(() {
      _alChiuso = true;
      _spegniGps();
    });
    _salvaInCorso();
  }

  /// Rimette la seduta com'era al salvataggio; si riparte in pausa.
  void _ripristina(AllenamentoInCorso r) {
    if (r.alChiuso && gps != null) {
      gps!.dispose();
      gps = null;
      giri = null;
    }
    _alChiuso = r.alChiuso;
    i = r.indice.clamp(0, blocchi.isEmpty ? 0 : blocchi.length - 1);
    preparati = false;
    pausa = !r.finito;
    finito = r.finito;
    _partenza = r.partenza;
    registra = r.registra;
    _baseTotale = r.totale;
    _baseBlocco = r.blocco;
    tempi.addAll(r.tempi);
    fatte.addAll(r.fatte);
    fc.ripristina(r.fcSomma, r.fcN, r.fcMax);
    _soste = r.soste;
    _fermo = r.fermo;
    potenza.ripristina(r.potenza[0], r.potenza[1], r.potenza[2]);
    cadenza.ripristina(r.cadenza[0], r.cadenza[1], r.cadenza[2]);
    _metriSensore = r.metriSensore;
    contaPassi.passi = r.passiContati;
    if (gps != null) {
      gps!.filtro.punti.addAll(r.punti);
      gps!.filtro.metri = r.metri;
      giri!.ripristina(r.giri, r.metri, r.totale);
    }
  }

  /// Fotografia della seduta su in_corso.json, per riprenderla se l'app
  /// viene chiusa.
  void _salvaInCorso() {
    if (preparati || blocchi.isEmpty) return;
    _salvatoIl = DateTime.now();
    salvaInCorso(
      AllenamentoInCorso(
        sport: widget.sport,
        tipo: widget.tipo,
        nome: widget.nome,
        libera: widget.libera,
        conGps: widget.conGps,
        passi: widget.passi,
        indice: i,
        finito: finito,
        registra: registra,
        totale: _tempoTotale,
        blocco: _tempoBlocco,
        partenza: _partenza ?? DateTime.now(),
        salvato: _salvatoIl,
        tempi: Map.of(tempi),
        fatte: Map.of(fatte),
        punti: List.of(gps?.filtro.punti ?? const []),
        metri: gps?.filtro.metri ?? 0,
        giri: List.of(giri?.giri ?? const []),
        fcSomma: fc.somma,
        fcN: fc.n,
        fcMax: fc.massimo,
        soste: _soste,
        fermo: _fermo,
        alChiuso: _alChiuso,
        potenza: potenza.comeLista,
        cadenza: cadenza.comeLista,
        metriSensore: _metriSensore,
        passiContati: contaPassi.passi,
        idPercorso: _percorso?.id ?? '',
        progressoPercorso: _guida?.progresso,
      ),
    );
  }

  /// Notifica con esercizio, tempo e dati: si vede anche a schermo bloccato.
  void _notifica() {
    if (preparati || finito || blocchi.isEmpty) return;
    final ora = DateTime.now();
    _notificataIl = ora;
    final bpm = sensoreBattito.bpm;
    mostraNotifica(
      titolo: titoloNotifica(
        b,
        nome: widget.nome,
        libera: widget.libera,
        inPausa: _inPausa,
        prossimo: blocchi
            .skip(i + 1)
            .where((x) => x.tipo == TipoBlocco.lavoro)
            .firstOrNull,
      ),
      testo: [
        testoNotifica(
          sport: widget.sport,
          km: gps?.km ?? (_metriSensore > 0 ? _metriSensore / 1000 : null),
          mps: gps == null
              ? (_bici ? sensoreBici.velocita : null)
              : velocitaAttuale(
                  gps!.filtro.punti,
                  ora: ora,
                  finestra: finestraVelocita(widget.sport),
                ),
          bpm: bpm,
          zona: bpm == null ? 0 : _zone.zonaDi(bpm),
          watt: _bici ? sensoreBici.potenza : null,
          passi: contaPassi.passi,
        ),
        ?testoGuida(_guida),
      ].where((x) => x.isNotEmpty).join(' · '),
      // Nei blocchi a tempo il conto alla rovescia, negli altri il totale.
      base: b.aTempo
          ? ora.add(Duration(seconds: _restano.clamp(0, 99999).toInt()))
          : ora.subtract(_tempoTotale),
      contoAllaRovescia: b.aTempo,
      inPausa: _inPausa,
    );
  }

  /// Bici: distanza dalla velocità del sensore (utile ai rulli) e un
  /// campione al secondo di potenza e cadenza.
  void _campionaBici() {
    final ora = DateTime.now();
    final prima = _ultimoCampione;
    _ultimoCampione = ora;
    final dt = prima == null
        ? 0.0
        : ora.difference(prima).inMilliseconds / 1000;
    final v = sensoreBici.velocita;
    // Dopo una pausa il primo intervallo è lungo: non conta.
    if (v != null && dt <= 1) _metriSensore += v * dt;
    if (ora.difference(_statisticheIl) < const Duration(seconds: 1)) return;
    _statisticheIl = ora;
    if (v != null) _serieVelocita.add(Campione(ora, v));
    if (sensoreBici.potenza case final w?) {
      potenza.aggiungi(w);
      _seriePotenza.add(Campione(ora, w.toDouble()));
    }
    if (sensoreBici.cadenza case final c?) {
      _serieCadenza.add(Campione(ora, c));
      // La cadenza media si fa sulle pedalate: smettere di pedalare non conta.
      if (c > 0) cadenza.aggiungi(c.round());
    }
  }

  /// Il battito dal sensore, un campione al secondo, per il grafico.
  void _campionaBattito() {
    final ora = DateTime.now();
    final bpm = sensoreBattito.bpm;
    if (bpm == null) return;
    if (_serieFc.isNotEmpty &&
        ora.difference(_serieFc.last.t) < const Duration(seconds: 1)) {
      return;
    }
    _serieFc.add(Campione(ora, bpm.toDouble()));
  }

  /// Watt e cadenza si vedono solo col sensore collegato e se li manda davvero.
  /// Una volta arrivati restano: fermi al semaforo il riquadro non sparisce.
  bool get _conWatt =>
      _bici &&
      sensoreBici.stato == StatoSensore.collegato &&
      (sensoreBici.potenza != null || _seriePotenza.isNotEmpty);
  bool get _conCadenza =>
      _bici &&
      sensoreBici.stato == StatoSensore.collegato &&
      (sensoreBici.cadenza != null || _serieCadenza.isNotEmpty);

  /// Il battito si vede solo con la fascia collegata e dopo il primo valore:
  /// un sensore ricordato ma spento non lascia un riquadro vuoto.
  bool get _conBattito =>
      sensoreBattito.stato == StatoSensore.collegato &&
      (sensoreBattito.bpm != null || _battitoArrivato);

  /// La potenza degli ultimi 3 secondi: quella istantanea salta troppo.
  int? get _watt =>
      mediaRecente(_seriePotenza, DateTime.now()) ?? sensoreBici.potenza;

  /// La zona di potenza chiesta dal blocco di bici in corso, se c'è l'FTP.
  (int, int)? get _rangeBlocco {
    if (!_bici || preparati) return null;
    final zp = _zonePotenza;
    // I watt scritti valgono anche senza FTP.
    if (zp == null) return rangeWattScritti(b.intensita);
    return rangeWatt(b.intensita, zp, recupero: b.tipo == TipoBlocco.recupero);
  }

  /// La cadenza chiesta dal blocco, se l'obiettivo secondario la dice.
  (int, int)? get _rangeCadenza =>
      !_bici || preparati ? null : rangeCadenza(b.obiettivo2);

  /// Fuori cadenza adesso: 1 sopra, -1 sotto, 0 dentro.
  int get _versoCadenza {
    final r = _rangeCadenza;
    final c = sensoreBici.cadenza;
    return r == null || c == null ? 0 : versoCadenza(c.round(), r);
  }

  /// ERG: il rullo tiene i watt del blocco. Acceso di base; i tasti −5% e
  /// +5% spostano tutti i blocchi.
  bool _ergAcceso = true;
  double _ergScala = 1;

  /// Il diagramma dell'allenamento (bici con FTP e passi con un obiettivo).
  late final List<BarraAllenamento>? _barre = () {
    final zp = _zonePotenza;
    if (zp == null || !_bici || widget.libera) return null;
    final barre = barreDa(blocchi, zp);
    return barre.any((x) => x.range != null) ? barre : null;
  }();

  /// I watt che il rullo deve tenere adesso (null: rullo libero).
  int? get _wattErg {
    final r = _rangeBlocco;
    if (!_ergAcceso || pausa || finito || r == null) return null;
    return wattErg(r, scala: _ergScala);
  }

  /// Manda al rullo i watt del blocco, o lo libera.
  void _comandaRullo() {
    if (!sensoreBici.comandabile) return;
    final w = _wattErg;
    if (w != null) {
      sensoreBici.impostaWatt(w);
    } else if (sensoreBici.wattImposti != null) {
      sensoreBici.libera();
    }
  }

  /// Il tasto Pausa/Riprendi della notifica.
  void _pausaDaNotifica() {
    if (mounted && !preparati && !finito) _pausa();
  }

  Future<void> _accendiGps() async {
    await gps!.avvia();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tic?.cancel();
    _battiti?.cancel();
    voce.ferma();
    if (pausaDaNotifica == _pausaDaNotifica) pausaDaNotifica = null;
    togliNotifica();
    sensoreBattito.ferma();
    sensorePassi.ferma();
    if (_bici) sensoreBici.libera().whenComplete(sensoreBici.ferma);
    _schermoAcceso(false);
    gps?.dispose();
    _kmScritti.dispose();
    _pagine.dispose();
    super.dispose();
  }

  int get _durata => preparati ? _preparazione : (b.secondi ?? 0) + extra;
  int get _restano => _durata - _tempoBlocco.inSeconds;

  void _aggiorna() {
    if (!mounted || finito) return;
    _rulloVuolDireAlChiuso();
    // Anche in pausa: la mappa dice quanto è lontano il percorso.
    _seguiPercorso();
    if (pausa) return;
    // Si aspetta il tasto Inizia: solo lo stato di GPS e sensori si aggiorna.
    if (_aspettaIlVia) {
      setState(() {});
      return;
    }
    // Prima del via il conto alla rovescia aspetta: non corre mentre si
    // sceglie il percorso, si cambiano le opzioni o Android chiede un
    // permesso.
    if (preparati) {
      final davanti = ModalRoute.of(context)?.isCurrent ?? true;
      final stato = WidgetsBinding.instance.lifecycleState;
      final attiva = stato == null || stato == AppLifecycleState.resumed;
      if (!davanti || !attiva) {
        blocco.stop();
        return;
      }
      if (!blocco.isRunning) blocco.start();
    }
    if (!preparati && gps != null) _controllaSoste();
    if (_pausaAuto) {
      // Fermi: si aspetta solo di ripartire.
      setState(() {});
      return;
    }
    if (!preparati && _bici) {
      _campionaBici();
      _comandaRullo();
    }
    if (!preparati) _campionaBattito();
    if (!preparati &&
        DateTime.now().difference(_salvatoIl) > const Duration(seconds: 15)) {
      _salvaInCorso();
    }
    if (!preparati &&
        DateTime.now().difference(_notificataIl) > const Duration(seconds: 5)) {
      _notifica();
    }
    if (!preparati && giri != null) {
      final g = giri!.aggiorna(gps!.filtro.metri, _tempoTotale);
      if (g != null) {
        _giroAvviso = g;
        _giroFino = DateTime.now().add(const Duration(seconds: 6));
        avviso(fine: true);
        voce.di('${fraseGiro(widget.sport, g)}$_mancano');
      }
    }
    if (!preparati && b.tipo == TipoBlocco.lavoro) _controllaRitmo();
    if (_giroFino != null && DateTime.now().isAfter(_giroFino!)) {
      _giroAvviso = null;
      _giroFino = null;
    }
    if (preparati || b.aTempo) {
      final r = _restano;
      if (r <= secondiAvviso && r > 0 && r != _ultimoBip) {
        _ultimoBip = r;
        avviso();
      }
      if (r <= 0) {
        avviso(fine: true);
        _avanti(daTimer: true);
        return;
      }
    }
    setState(() {});
  }

  /// I numeri della seduta. [grande]: corsa e camminata uno per riga,
  /// con i numeri grandi (solo se ci stanno: vedi [GrandeSeCiSta]).
  Widget _numeri(BuildContext context, {required bool grande}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([sensoreBattito, sensoreBici]),
            builder: (_, _) {
              final bici = _bici && sensoreBici.ricordato;
              return Column(
                spacing: 8,
                children: [
                  const SizedBox.shrink(),
                  if (gps != null)
                    _GrigliaLive(
                      sport: widget.sport,
                      gps: gps!,
                      tempo: _tempoMedia,
                      ultimo: giri!.giri.lastOrNull,
                      zone: _zone,
                      // Pagina dei soli dati: numeri grandi, da leggere con un colpo
                      // d'occhio, se ci stanno.
                      grande: grande,
                    )
                  else if (bici)
                    // Rulli: velocità e km dal sensore.
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: _Dato(
                            etichetta: l10n.velocita,
                            valore: fmtVelocita(
                              widget.sport,
                              sensoreBici.velocita,
                            ),
                            unita: 'km/h',
                          ),
                        ),
                        Expanded(
                          child: _Dato(
                            etichetta: l10n.distanza,
                            valore: (_metriSensore / 1000)
                                .toStringAsFixed(2)
                                .replaceAll('.', ','),
                            unita: 'km',
                          ),
                        ),
                      ],
                    ),
                  // Solo i dati che arrivano davvero: un
                  // rullo ricordato ma lontano non conta.
                  if (_conWatt || _conCadenza)
                    Row(
                      spacing: 8,
                      children: [
                        if (_conWatt)
                          Expanded(
                            child: _DatoPotenza(
                              watt: _watt,
                              zone: _zonePotenza,
                              obiettivo: _rangeBlocco,
                              onTap: () => mostraSensoreBici(context),
                            ),
                          ),
                        if (_conCadenza)
                          Expanded(
                            child: _Dato(
                              etichetta: l10n.cadenza,
                              valore:
                                  sensoreBici.cadenza?.round().toString() ??
                                  '–',
                              unita: 'rpm',
                              onTap: () => mostraSensoreBici(context),
                            ),
                          ),
                      ],
                    ),
                  if (sensorePassi.disponibile)
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: _Dato(
                            etichetta: l10n.passi,
                            valore: fmtPassi(contaPassi.passi),
                            unita: '',
                          ),
                        ),
                        Expanded(
                          child: _Dato(
                            etichetta: l10n.passiAlMinuto,
                            valore:
                                contaPassi
                                    .cadenza(DateTime.now())
                                    ?.toString() ??
                                '–',
                            unita: '',
                          ),
                        ),
                      ],
                    ),
                  if (gps == null && _conBattito) _DatoBattito(zone: _zone),
                  if (bici && sensoreBici.comandabile)
                    ControlloErg(
                      acceso: _ergAcceso,
                      watt: _ergAcceso ? _wattErg : null,
                      scala: _ergScala,
                      cambia: (acceso) => setState(() {
                        _ergAcceso = acceso;
                        _comandaRullo();
                      }),
                      scalaCambia: (s) => setState(() {
                        _ergScala = s;
                        _comandaRullo();
                      }),
                    ),
                ],
              );
            },
          ),
          if (_barre case final barre?) ...[
            const SizedBox(height: 8),
            DiagrammaInCorso(
              barre: barre,
              zone: _zonePotenza!,
              corrente: i,
              trascorso: _tempoBlocco.inSeconds,
              durata: _durata,
            ),
          ],
        ],
      ),
    );
  }

  void _nuovoBlocco({required bool aMano}) {
    _inizioTratto = DateTime.now();
    _metriInizio = _metriOra;
    blocco
      ..reset()
      ..start();
    _baseBlocco = Duration.zero;
    extra = 0;
    _ultimoBip = -1;
    ritmo.azzera();
    _ritmoCadenza.azzera();
    // L'attività libera ha un passo solo: basta il cronometro.
    if (!widget.libera) {
      voce.diBlocco(b, aMano: aMano);
    }
    _salvaInCorso();
    _notifica();
  }

  // ---------------------------------------------------------------------
  // Registro delle serie di forza

  /// Vero se il blocco è una serie di forza a ripetizioni, da registrare.
  bool _daRegistrare(int k) {
    final x = blocchi[k];
    return x.tipo == TipoBlocco.lavoro &&
        !x.aTempo &&
        stessoSport(widget.sport, 'Forza') &&
        ripetizioniPreviste(x.ripetizioni) != null;
  }

  String _chiave(Blocco x) => x.esercizio.isEmpty ? x.titolo : x.esercizio;

  List<SerieFatta> _ultima(Blocco x) =>
      ultimaVolta(widget.state.serieFatte, _chiave(x), prima: DateTime.now());

  /// Mostra i kg se l'esercizio usa un peso (dal catalogo, dal piano o
  /// dall'ultima volta).
  bool _conKg(Blocco x) {
    if (x.kg != null || kgDalleNote(x.note) != null) return true;
    if (_ultima(x).any((s) => s.kg > 0)) return true;
    final e = widget.state.esercizi.where((e) => e.id == x.esercizio);
    return e.isNotEmpty && !e.first.corpoLibero;
  }

  (int, double) _valoriDi(int k) => _valori[k] ??= () {
    final x = blocchi[k];
    // La serie prima dello stesso esercizio, in questa seduta.
    (int, double)? precedente;
    for (var j = k - 1; j >= 0; j--) {
      if (blocchi[j].passo != x.passo) break;
      if (blocchi[j].tipo != TipoBlocco.lavoro) continue;
      precedente = fatte[j] ?? _valori[j];
      break;
    }
    return proposta(
      serie: x.serie,
      previste: ripetizioniPreviste(x.ripetizioni)!,
      ultima: _ultima(x),
      precedente: precedente,
      kgPiano: x.kg ?? kgDalleNote(x.note),
      kgPerSerie: x.kgPerSerie,
    );
  }();

  void _avanti({bool saltato = false, bool daTimer = false}) {
    if (!preparati && _daRegistrare(i)) {
      if (saltato) {
        fatte.remove(i);
      } else {
        fatte[i] = _valoriDi(i);
      }
    }
    if (preparati) {
      setState(() {
        preparati = false;
        _partenza ??= DateTime.now();
        totale.start();
        gps?.imposta(true);
        _nuovoBlocco(aMano: !daTimer);
      });
      return;
    }
    tempi[i] = (tempi[i] ?? Duration.zero) + _tempoBlocco;
    _chiudiTratto();
    if (i >= blocchi.length - 1) {
      _fine(aMano: !daTimer);
      return;
    }
    setState(() {
      i++;
      _nuovoBlocco(aMano: !daTimer);
    });
  }

  /// Zona (con il battito) o passo (se l'esercizio lo chiede) fuori obiettivo
  /// da un po': lo dice la voce.
  void _controllaRitmo() {
    final ora = DateTime.now();
    // La cadenza si controlla sempre, anche in ERG: quella la decide chi pedala.
    if (_rangeCadenza case final rc?) {
      final verso = _versoCadenza;
      if (_ritmoCadenza.controlla(verso, ora)) {
        voce.di(
          fraseCadenza(sensoreBici.cadenza!.round(), rc, verso),
          valida: const Duration(seconds: 20),
        );
      }
    }
    // In bici senza watt (all'aperto senza misuratore) i passi in % dell'FTP
    // o in watt si seguono col battito della zona che gli corrisponde.
    final zonaScritta = zonaObiettivo(b.intensita);
    final zona =
        zonaScritta ??
        (_bici ? zonaBattitoDi(b.intensita, _zonePotenza) : null);
    final r = _rangeBlocco;
    final w = _watt;
    if (r != null && w != null && _zonePotenza != null) {
      // In ERG i watt li tiene il rullo; in ruota libera niente avvisi.
      if (w == 0 || sensoreBici.wattImposti != null) {
        ritmo.azzera();
        return;
      }
      final verso = versoRange(w, r, _zonePotenza);
      if (ritmo.controlla(verso, ora)) {
        voce.di(fraseRange(w, r, verso), valida: const Duration(seconds: 20));
      }
      return;
    }
    final bpm = sensoreBattito.bpm;
    if (zona != null && bpm != null) {
      final n = _zone.zonaDi(bpm);
      var verso = versoZona(n, zona);
      // Zona ricavata dai watt: all'inizio del passo il battito deve ancora
      // salire, non è il momento di dire "spingi di più".
      if (zonaScritta == null && verso < 0 && _tempoBlocco < ritardoBattito) {
        verso = 0;
      }
      if (ritmo.controlla(verso, ora)) {
        voce.di(fraseZona(n, verso), valida: const Duration(seconds: 20));
      }
      return;
    }
    final obiettivo = velocitaObiettivo(
      '${b.intensita} ${b.dettaglio} ${b.note}',
    );
    if (obiettivo == null || gps == null) return;
    final v = velocitaAttuale(
      gps!.filtro.punti,
      ora: ora,
      finestra: finestraVelocita(widget.sport),
    );
    // Fermi (semaforo) o GPS appena partito: niente avvisi.
    if (v == null || v < 0.28) {
      ritmo.azzera();
      return;
    }
    final verso = versoVelocita(v, obiettivo);
    if (ritmo.controlla(verso, ora)) {
      voce.di(
        fraseVelocita(widget.sport, v, verso),
        valida: const Duration(seconds: 20),
      );
    }
  }

  void _indietro() {
    if (preparati || i == 0) return;
    _chiudiTratto();
    setState(() {
      i--;
      _nuovoBlocco(aMano: true);
    });
  }

  /// Tiene il conto delle soste e, se scelta, mette e toglie la pausa
  /// automatica. Mai nei recuperi: lì stare fermi è normale.
  void _controllaSoste() {
    final ora = DateTime.now();
    final dt = _ultimoControllo == null
        ? Duration.zero
        : ora.difference(_ultimoControllo!);
    _ultimoControllo = ora;
    final v = gps!.velocitaRecente;
    _movimento.aggiorna(v, ora);
    if (_pausaAuto) {
      _soste += dt;
    } else if (_movimento.fermo) {
      _fermo += dt;
    }
    if (modoPausa.value == ModoPausa.spenta ||
        b.tipo == TipoBlocco.recupero ||
        !_autoPausa.aggiorna(v, ora)) {
      return;
    }
    _pausaAuto = _autoPausa.fermo;
    gps!.imposta(!_pausaAuto);
    if (_pausaAuto) {
      totale.stop();
      blocco.stop();
      voce.di(l10nVoce.pausa3, valida: const Duration(seconds: 10));
    } else {
      totale.start();
      blocco.start();
      voce.di(l10nVoce.siRiparte, valida: const Duration(seconds: 10));
    }
    avviso();
    _salvaInCorso();
    _notifica();
  }

  /// Voce, bip e pausa automatica: le scelte nuove valgono subito.
  Future<void> _apriOpzioni() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OpzioniAllenamentoScreen()),
    );
    if (!mounted) return;
    setState(() {
      if (_pausaAuto) {
        // Si riparte; se si è ancora fermi la pausa torna con la scelta nuova.
        _pausaAuto = false;
        gps?.imposta(true);
        if (!pausa) {
          totale.start();
          blocco.start();
        }
      }
      _autoPausa = RilevaSosta(sogliaDi(modoPausa.value, sogliaPausaKmh.value));
    });
  }

  void _pausa() {
    // La pausa a mano comanda: quella automatica riparte da capo.
    if (_pausaAuto) {
      _pausaAuto = false;
      if (!pausa) gps?.imposta(true);
    }
    _autoPausa = RilevaSosta(sogliaDi(modoPausa.value, sogliaPausaKmh.value));
    _ultimoControllo = null;
    setState(() {
      pausa = !pausa;
      if (!preparati) gps?.imposta(!pausa);
      if (pausa) {
        totale.stop();
        blocco.stop();
        if (_bici) sensoreBici.libera();
      } else {
        if (!preparati) totale.start();
        blocco.start();
      }
    });
    _salvaInCorso();
    _notifica();
  }

  void _fine({bool aMano = true}) {
    totale.stop();
    blocco.stop();
    sensorePassi.ferma();
    if (_bici) sensoreBici.libera();
    // Spento il GPS se ne va anche la sua notifica; poi si toglie la nostra.
    (gps?.ferma() ?? Future<void>.value()).then((_) => togliNotifica());
    _schermoAcceso(false);
    avviso(fine: true);
    // Rulli con sensore di velocità: i km sono già lì, si possono correggere.
    if (_alChiuso && _metriSensore >= 100 && _kmScritti.text.isEmpty) {
      _kmScritti.text = (_metriSensore / 1000)
          .toStringAsFixed(2)
          .replaceAll('.', ',');
    }
    voce.di(
      l10nVoce.allenamentoCompletato(
        parlaDurata(_tempoTotale),
        gps == null || gps!.km < 0.05
            ? ''
            : l10nVoce.chilometri(decimaleVoce(gps!.km, 1)),
      ),
      urgente: aMano,
    );
    setState(() => finito = true);
    _salvaInCorso(); // anche il riepilogo si ritrova, se l'app si chiude
  }

  Future<bool> _confermaUscita() async {
    if (finito || preparati) return true;
    final r = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.interrompereAllenamento),
        content: Text(l10n.puoiTerminarloQuiVedere),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, 'esci'),
            child: Text(l10n.esci),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, 'termina'),
            child: Text(l10n.terminaQui),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l10n.continua),
          ),
        ],
      ),
    );
    if (r == 'termina') {
      tempi[i] = (tempi[i] ?? Duration.zero) + _tempoBlocco;
      _chiudiTratto();
      _fine();
    }
    if (r == 'esci') await cancellaInCorso();
    return r == 'esci';
  }

  /// Id della sessione che si salva alla fine.
  String get _idSessione {
    final inizio = _partenza ?? DateTime.now().subtract(_tempoTotale);
    return widget.libera
        ? idLibera(inizio, widget.sport)
        : 'app-${isoData(soloData(inizio))}-${widget.sport.toLowerCase()}';
  }

  Future<void> _salvaEChiudi({
    bool feedback = false,
    bool aMano = false,
  }) async {
    final navigator = Navigator.of(context);
    // Per scrivere i dati la seduta deve esserci.
    if (aMano) registra = true;
    final oggi = soloData(_partenza ?? DateTime.now());
    final percorso = gps?.percorso;
    // Il percorso si tiene anche se vale la sessione dell'orologio: la mappa
    // lo mostra quando Health Connect non ne ha uno.
    if (percorso != null && !percorso.vuoto) {
      await widget.state.salvaPercorsoApp(oggi, widget.sport, percorso);
    }
    if (_serieFc.isNotEmpty ||
        _seriePotenza.isNotEmpty ||
        _serieVelocita.isNotEmpty) {
      await widget.state.salvaSerieApp(
        oggi,
        widget.sport,
        SerieSessione(
          fc: _serieFc,
          potenza: _seriePotenza,
          cadenza: _serieCadenza,
          velocita: _serieVelocita,
        ),
      );
    }
    await widget.state.salvaSerie(oggi, [
      for (final e in fatte.entries)
        SerieFatta(
          data: oggi,
          esercizio: blocchi[e.key].esercizio,
          nome: blocchi[e.key].titolo,
          serie: blocchi[e.key].serie,
          ripetizioni: e.value.$1,
          kg: e.value.$2,
        ),
    ]);
    if (registra) {
      final inizio = _partenza ?? DateTime.now().subtract(_tempoTotale);
      final id = widget.libera
          ? idLibera(inizio, widget.sport)
          : 'app-${isoData(oggi)}-${widget.sport.toLowerCase()}';
      final calorie = _calorie;
      final fatta = Sessione(
        id: id,
        data: oggi,
        inizio: inizio,
        fine: inizio.add(_tempoTotale),
        sport: widget.sport,
        tipo: widget.tipo,
        durataMin: (_tempoTotale.inSeconds / 60).round().clamp(1, 600),
        // I km del display (tapis roulant, rulli) valgono più del GPS.
        distanzaKm: _km,
        calorieAttive: calorie?.attive.roundToDouble() ?? 0,
        calorieTotali: calorie?.totali.roundToDouble() ?? 0,
        fcMedia: fc.media,
        fcMax: fc.massimo,
        potenzaMedia: potenza.media,
        cadenzaMedia: cadenza.media,
        passi: contaPassi.passi,
        fonte: fonteApp,
        note: widget.nome,
      );
      await widget.state.registraSvolta(fatta);
      // I blocchi uno per uno: nel riepilogo, divisi in sezioni come la seduta
      // prevista. L'attività libera ha un blocco solo: non servono.
      if (_trattiCompleti && !widget.libera) {
        await widget.state.salvaIntervalliApp(
          id,
          intervalliDaTratti(
            blocchi,
            _tratti,
            fc: _serieFc,
            potenza: _seriePotenza,
            // Bici: i watt da tenere di ogni blocco, per il riepilogo.
            zone: _bici ? _zonePotenza : null,
          ),
        );
      }
      // I watt migliori servono alla stima dell'FTP (e al risultato dei test).
      if (_seriePotenza.isNotEmpty) {
        await widget.state.registraPotenza(fatta, _seriePotenza);
      }
      if (_alChiuso) {
        await widget.state.ritoccaSessione(RitoccoSessione(id, alChiuso: true));
      }
      // Nuoto e arrampicata non hanno niente che li misuri: subito i dati a mano.
      if ((aMano ||
              stessoSport(widget.sport, 'Nuoto') ||
              stessoSport(widget.sport, sportArrampicata)) &&
          mounted) {
        await cancellaInCorso();
        await navigator.push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ModificaSessioneScreen(state: widget.state, sessione: fatta),
          ),
        );
      }
      // Forza libera: un passo solo, senza esercizi da segnare durante. Alla
      // fine si scrivono quelli fatti, con serie e kg.
      if (widget.libera && stessoSport(widget.sport, 'Forza') && mounted) {
        await cancellaInCorso();
        await navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => SerieAManoScreen(state: widget.state, giorno: oggi),
          ),
        );
      }
      // Dopo i dati a mano, così parte la seduta giusta. In sottofondo: senza
      // rete non deve tenere ferma la fine dell'allenamento.
      unawaited(widget.state.inviaDopoAllenamento());
    }
    await cancellaInCorso();
    if (feedback && mounted) {
      await apriFeedback(context, widget.state, oggi, widget.sport);
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: finito || preparati,
      onPopInvokedWithResult: (fatto, _) async {
        if (fatto) return;
        final navigator = Navigator.of(context);
        if (await _confermaUscita()) navigator.pop();
      },
      child: Scaffold(
        bottomNavigationBar: const MargineBarraSistema(),
        body: SfondoPulse(
          child: SafeArea(
            child: blocchi.isEmpty
                ? Center(child: Text(l10n.questoAllenamentoNonHa))
                : finito
                ? _riepilogo(context)
                : _esecuzione(context),
          ),
        ),
      ),
    );
  }

  Widget _esecuzione(BuildContext context) {
    final recupero = !preparati && b.tipo == TipoBlocco.recupero;
    final prossimo = blocchi
        .skip(preparati ? 0 : i + 1)
        .where((x) => x.tipo == TipoBlocco.lavoro)
        .firstOrNull;
    final perId = {for (final e in widget.state.esercizi) e.id: e};
    final esercizio = preparati || recupero ? null : perId[b.esercizio];
    final esercizioPoi = recupero ? perId[prossimo?.esercizio] : null;
    final aTempo = preparati || b.aTempo;

    return Stack(
      children: [
        _colonnaEsecuzione(
          context,
          recupero: recupero,
          prossimo: prossimo,
          esercizio: esercizio,
          esercizioPoi: esercizioPoi,
          aTempo: aTempo,
        ),
        Positioned(
          top: 64,
          left: 20,
          right: 20,
          child: IgnorePointer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _giroAvviso == null
                  ? const SizedBox.shrink()
                  : _AvvisoGiro(
                      key: ValueKey(_giroAvviso!.numero),
                      giro: _giroAvviso!,
                      sport: widget.sport,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _colonnaEsecuzione(
    BuildContext context, {
    required bool recupero,
    required Blocco? prossimo,
    required Esercizio? esercizio,
    required Esercizio? esercizioPoi,
    required bool aTempo,
  }) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Senza dati dei sensori sotto resterebbe solo spazio vuoto: il movimento
    // lo riempie, in grande. Con un sensore torna piccolo accanto al nome.
    final figuraGrande =
        !_senzaTesto &&
        _conAnteprima(esercizio) &&
        gps == null &&
        !_conBattito &&
        !(_bici && sensoreBici.ricordato) &&
        !_conWatt &&
        !_conCadenza &&
        _barre == null;
    return Column(
      children: [
        // In alto: chiudi, tempo totale, pausa.
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.chiudi,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  if (await _confermaUscita()) navigator.pop();
                },
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      fmtTimer(_tempoTotale),
                      style: t.titleLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(l10n.tempoTotale, style: t.labelSmall),
                  ],
                ),
              ),
              // In modo semplice i sensori restano nascosti (Profilo →
              // Funzioni avanzate), a meno che uno sia già collegato.
              if (_bici &&
                  (widget.state.profilo.modoAvanzato ||
                      sensoreBici.stato == StatoSensore.collegato))
                ListenableBuilder(
                  listenable: sensoreBici,
                  builder: (_, _) => IconButton(
                    tooltip: l10n.sensoriBici,
                    onPressed: () => mostraSensoreBici(context),
                    icon: Icon(
                      sensoreBici.stato == StatoSensore.collegato
                          ? Icons.pedal_bike_rounded
                          : Icons.pedal_bike_outlined,
                    ),
                  ),
                ),
              if (widget.state.profilo.modoAvanzato ||
                  sensoreBattito.stato == StatoSensore.collegato)
                ListenableBuilder(
                  listenable: sensoreBattito,
                  builder: (_, _) => IconButton(
                    tooltip: l10n.battitoDalSensore,
                    onPressed: () => mostraBattito(context),
                    icon: Icon(
                      sensoreBattito.stato == StatoSensore.collegato
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                  ),
                ),
              IconButton(
                tooltip: l10n.bipVibrazione,
                onPressed: _apriOpzioni,
                icon: ValueListenableBuilder(
                  valueListenable: bipAttivo,
                  builder: (_, bip, _) => Icon(
                    bip ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  ),
                ),
              ),
              if (!_aspettaIlVia)
                IconButton(
                  tooltip: pausa ? l10n.riprendi : l10n.pausa2,
                  onPressed: _pausa,
                  icon: Icon(
                    pausa ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          // Prima del via solo il timer e le scelte: i dati arrivano dopo.
          child: preparati
              ? _preparati(context, prossimo)
              // Bici al chiuso: tutti i dati in una pagina, senza scorrere.
              : _bici && gps == null
              ? _vistaBici(context, recupero: recupero)
              : _centro(
                  context,
                  ColonnaDati(
                    sopra: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Un segmento per esercizio: pieni quelli fatti, mezzo quello in corso.
                          Row(
                            children: [
                              for (var k = 0; k < nPassi; k++) ...[
                                if (k > 0) const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: !preparati && k < b.passo
                                          ? null
                                          : !preparati && k == b.passo
                                          ? scheme.primary.withValues(
                                              alpha: 0.5,
                                            )
                                          : scheme.surfaceContainerHigh,
                                      gradient: !preparati && k < b.passo
                                          ? LinearGradient(
                                              colors: Pulse.di(context).anello,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Durante la seduta il GPS si nomina solo se non va.
                          if (gps != null && gps!.stato != StatoGps.pronto) ...[
                            const SizedBox(height: 8),
                            _StatoGps(gps: gps!, riaccendi: _accendiGps),
                          ],
                          if (gps != null &&
                              vistaMappa.value == VistaMappa.minimappa &&
                              _guida != null) ...[
                            const SizedBox(height: 8),
                            BannerGuida(guida: _guida!, compatto: true),
                          ],
                        ],
                      ),
                    ),
                    mappa:
                        gps != null && vistaMappa.value == VistaMappa.minimappa
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _mappaLive(compatta: true),
                            ),
                          )
                        : null,
                    // Attività libera all'aperto con le pagine: numeri
                    // grandi finché ci stanno, poi la griglia.
                    numeri:
                        gps != null &&
                            _senzaTesto &&
                            vistaMappa.value == VistaMappa.pagine
                        ? GrandeSeCiSta(
                            grande: _numeri(context, grande: true),
                            compatto: SingleChildScrollView(
                              child: _numeri(context, grande: false),
                            ),
                          )
                        : SingleChildScrollView(
                            child: _numeri(context, grande: false),
                          ),
                    testo: ListView(
                      shrinkWrap: true,
                      padding: _senzaTesto && _tempoPiatto
                          ? EdgeInsets.zero
                          : const EdgeInsets.fromLTRB(20, 10, 20, 8),
                      children: [
                        if (_senzaTesto)
                          const SizedBox.shrink()
                        else if (recupero)
                          EntrataMorbida(
                            key: ValueKey(i),
                            da: const Offset(24, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(titoloRecupero(b), style: t.titleMedium),
                                if (b.note.isNotEmpty)
                                  Text(mostraTesto(b.note), style: t.bodySmall),
                              ],
                            ),
                          )
                        else ...[
                          // Passando da un esercizio all'altro il testo nuovo
                          // entra da destra, senza scatti.
                          EntrataMorbida(
                            key: ValueKey(i),
                            da: const Offset(24, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // A sinistra l'anteprima del movimento, se c'è.
                                Row(
                                  children: [
                                    if (_conAnteprima(esercizio) &&
                                        !figuraGrande) ...[
                                      _AnteprimaEsercizio(
                                        esercizio: esercizio!,
                                        larghezza: 112,
                                        specchio: b.lato == latoSinistro,
                                      ),
                                      const SizedBox(width: 14),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Solo il nome, piccolo: titolo e durata
                                          // della seduta sono già stati scelti.
                                          TestoUnaRiga(
                                            mostra(b.titolo),
                                            style: t.titleSmall,
                                          ),
                                          if (dettaglioBreve(b).isNotEmpty)
                                            Text(
                                              dettaglioBreve(b),
                                              style: t.bodySmall,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (b.intensita.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      intensitaCon(
                                        mostraTesto(b.intensita),
                                        widget.sport,
                                        _zonePotenza,
                                        _zone,
                                      ),
                                      style: t.bodyMedium,
                                    ),
                                  ),
                                if (b.obiettivo2.isNotEmpty)
                                  Text(
                                    mostraTesto(b.obiettivo2),
                                    style: t.bodyMedium,
                                  ),
                                if (sensazioneDi(b.intensita) != null)
                                  Text(
                                    sensazioneDi(b.intensita)!,
                                    style: t.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                if (b.note.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      mostraTesto(b.note),
                                      style: t.bodySmall,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_daRegistrare(i)) ...[
                            const SizedBox(height: 16),
                            RegistroSerie(
                              valori: _valoriDi(i),
                              massimo: ripetizioniPreviste(b.ripetizioni)!.$2,
                              conKg: _conKg(b),
                              ultima: _ultima(b),
                              cambia: (v) => setState(() => _valori[i] = v),
                            ),
                          ],
                        ],
                        if (!_tempoPiatto) ...[
                          const SizedBox(height: 12),
                          Center(
                            // Durante "Preparati" un tocco sul timer fa partire subito.
                            child: GestureDetector(
                              onTap: preparati && !pausa ? _avanti : null,
                              child: _Orologio(
                                recupero: recupero,
                                aTempo: aTempo,
                                restano: aTempo
                                    ? _restano.clamp(0, 99999).toInt()
                                    : 0,
                                totale: aTempo ? _durata : 0,
                                trascorso: _tempoBlocco,
                                pausa: _inPausa,
                                // Piccolo: entra sotto il testo senza scorrere.
                                piccolo: true,
                              ),
                            ),
                          ),
                        ],
                        if (recupero && prossimo != null) ...[
                          const SizedBox(height: 24),
                          SuperficiePulse(
                            child: Row(
                              children: [
                                if (_conAnteprima(esercizioPoi))
                                  _AnteprimaEsercizio(
                                    esercizio: esercizioPoi!,
                                    larghezza: 84,
                                    specchio: prossimo.lato == latoSinistro,
                                  )
                                else
                                  const IconaQuadrata(
                                    Icons.skip_next_rounded,
                                    evidenza: true,
                                  ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.poi, style: t.bodySmall),
                                      TestoUnaRiga(
                                        mostra(prossimo.titolo),
                                        style: t.titleMedium,
                                      ),
                                      if (prossimo.dettaglio.isNotEmpty)
                                        Text(
                                          prossimo.dettaglio,
                                          style: t.bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    figura: figuraGrande
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            // L'immagine tiene le sue proporzioni e si allarga
                            // fin dove c'è posto.
                            child: Center(
                              child: EntrataMorbida(
                                key: ValueKey(i),
                                da: const Offset(24, 0),
                                child: _AnteprimaEsercizio(
                                  esercizio: esercizio!,
                                  specchio: b.lato == latoSinistro,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
        ),
        if (_tempoPiatto)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _TempoPiatto(
              recupero: recupero,
              aTempo: aTempo,
              restano: aTempo ? _restano.clamp(0, 99999).toInt() : 0,
              totale: aTempo ? _durata : 0,
              trascorso: _tempoBlocco,
              pausa: _inPausa,
              // Un blocco solo senza durata: il tempo è già quello in alto.
              conCronometro: blocchi.length > 1,
            ),
          ),
        // In basso: indietro, azione principale, +15 s o salta.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Row(
            children: [
              if (!_aspettaIlVia) ...[
                IconButton.filledTonal(
                  tooltip: l10n.esercizioPrecedente,
                  iconSize: 28,
                  onPressed: preparati || i == 0 ? null : _indietro,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: PulsantePrincipale(
                  altezza: 64,
                  onPressed: pausa ? null : _avanti,
                  icona: preparati
                      ? Icons.play_arrow_rounded
                      : recupero
                      ? Icons.fast_forward_rounded
                      : b.aTempo
                      ? Icons.skip_next_rounded
                      : Icons.check_rounded,
                  testo: _aspettaIlVia
                      ? l10n.inizia2
                      : preparati
                      ? l10n.iniziaSubito
                      : recupero
                      ? l10n.saltaRecupero
                      : b.aTempo
                      ? l10n.avanti
                      : l10n.fatto,
                ),
              ),
              if (!_aspettaIlVia) ...[
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: recupero ? l10n.n15SecondiPiu : l10n.salta,
                  iconSize: 28,
                  onPressed: pausa
                      ? null
                      : recupero
                      ? () => setState(() => extra += 15)
                      : () => _avanti(saltato: true),
                  icon: recupero
                      ? Text(
                          '+15',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSecondaryContainer,
                          ),
                        )
                      : const Icon(Icons.skip_next_rounded),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Prima del via: le scelte (al chiuso, percorso, sensori) e lo stato del
  /// GPS. La forza e le altre sedute senza preparativi hanno anche il timer
  /// grande al centro; corsa, bici e camminata aspettano il tasto Inizia.
  Widget _preparati(BuildContext context, Blocco? prossimo) {
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight - 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _aspettaIlVia ? l10n.partiQuandoVuoi : l10n.preparati,
                style: t.headlineMedium,
              ),
              const SizedBox(height: 4),
              TestoUnaRiga(
                widget.libera || !contaEsercizi(widget.sport)
                    ? mostra(widget.nome)
                    : l10n.esercizi2(mostra(widget.nome), nPassi),
                style: t.bodySmall,
                textAlign: TextAlign.center,
              ),
              if (prossimo != null)
                TestoUnaRiga(
                  l10n.siParte(mostra(prossimo.titolo)),
                  style: t.titleMedium,
                  textAlign: TextAlign.center,
                ),
              if (!_aspettaIlVia) ...[
                const SizedBox(height: 24),
                // Un tocco sul timer fa partire subito.
                GestureDetector(
                  onTap: pausa ? null : _avanti,
                  child: _Orologio(
                    recupero: false,
                    aTempo: true,
                    restano: _restano.clamp(0, 99999).toInt(),
                    totale: _durata,
                    trascorso: _tempoBlocco,
                    pausa: _inPausa,
                  ),
                ),
              ],
              if (_barre case final barre?) ...[
                const SizedBox(height: 20),
                DiagrammaInCorso(
                  barre: barre,
                  zone: _zonePotenza!,
                  corrente: -1,
                  trascorso: 0,
                  durata: 0,
                ),
              ],
              const SizedBox(height: 24),
              if (_conAttrezzo)
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      stessoSport(widget.sport, 'Bici')
                          ? Icons.pedal_bike_rounded
                          : Icons.directions_run_rounded,
                    ),
                    title: Text(l10n.indoor2(attrezzoAlChiuso(widget.sport))),
                    subtitle: Text(
                      _bici && sensoreBici.rulloInUso
                          ? l10n.senzaGpsVelocitaKm
                          : l10n.senzaGpsAllaFine,
                    ),
                    value: _alChiuso,
                    onChanged: (chiuso) {
                      _sceltoAllAperto = !chiuso;
                      _cambiaAlChiuso(chiuso);
                    },
                  ),
                ),
              if (gps != null) ...[
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.route_rounded),
                    title: Text(_percorso?.nome ?? l10n.seguiPercorso),
                    subtitle: Text(
                      _percorso == null
                          ? l10n.facoltativoGpxMappaIndicazioni
                          : descriviPercorso(_percorso!),
                    ),
                    trailing: _percorso == null
                        ? const Icon(Icons.chevron_right_rounded)
                        : IconButton(
                            tooltip: l10n.togliPercorso,
                            onPressed: () => _usaPercorso(null),
                            icon: const Icon(Icons.close_rounded),
                          ),
                    onTap: _scegliPercorso,
                  ),
                ),
                const SizedBox(height: 8),
                _StatoGps(gps: gps!, riaccendi: _accendiGps),
              ],
              if (_aspettaIlVia) _sensoriPrimaDelVia(),
            ],
          ),
        ),
      ),
    );
  }

  /// Rullo e battito si collegano qui, con calma, prima di partire.
  Widget _sensoriPrimaDelVia() {
    return ListenableBuilder(
      listenable: Listenable.merge([sensoreBici, sensoreBattito]),
      builder: (context, _) {
        final rullo = sensoreBici.stato == StatoSensore.collegato;
        final battito = sensoreBattito.stato == StatoSensore.collegato;
        return Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              if (_bici)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    rullo
                        ? Icons.pedal_bike_rounded
                        : Icons.pedal_bike_outlined,
                  ),
                  title: Text(
                    _alChiuso ? l10n.rulloSensori : l10n.sensoriBici2,
                  ),
                  subtitle: Text(
                    sensoreBici.daCalibrare
                        ? l10n.collegatoOraCalibrarlo
                        : rullo
                        ? l10n.collegato
                        : l10n.toccaCollegare,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => mostraSensoreBici(context),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  battito
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
                title: Text(l10n.battito),
                subtitle: Text(battito ? l10n.collegato : l10n.toccaCollegare),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => mostraBattito(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _vistaBici(BuildContext context, {required bool recupero}) {
    return ListenableBuilder(
      listenable: Listenable.merge([sensoreBattito, sensoreBici]),
      builder: (context, _) => VistaBici(
        dati: DatiVistaBici(
          watt: _watt,
          wattMedia: potenza.media,
          wattMassimo: potenza.massimo,
          seriePotenza: _seriePotenza,
          zonePotenza: _zonePotenza,
          bpm: sensoreBattito.bpm,
          zone: _zone,
          calorie: _calorie?.attive.round(),
          cadenza: sensoreBici.cadenza?.round().toString() ?? '–',
          velocita: fmtVelocita(widget.sport, sensoreBici.velocita),
          km: (_metriSensore / 1000).toStringAsFixed(2).replaceAll('.', ','),
          sensoriRicordati: sensoreBici.ricordato,
          titolo: recupero ? titoloRecupero(b) : mostra(b.titolo),
          dettaglio: dettaglioBreve(b),
          intensita: intensitaCon(
            b.intensita,
            widget.sport,
            _zonePotenza,
            _zone,
          ),
          note: mostraTesto(b.note),
          range: _rangeBlocco,
          obiettivo2: recupero ? '' : b.obiettivo2,
          versoSecondario: recupero ? 0 : _versoCadenza,
          wattErg: sensoreBici.comandabile ? _wattErg : null,
          restano: b.aTempo ? _restano.clamp(0, 99999).toInt() : null,
          trascorso: _tempoBlocco.inSeconds,
          durata: _durata,
          pausa: _inPausa,
          recupero: recupero,
          barre: _barre,
          corrente: i,
          comandabile: sensoreBici.comandabile,
          ergAcceso: _ergAcceso,
          ergScala: _ergScala,
        ),
        apriSensori: () => mostraSensoreBici(context),
        apriBattito: () => mostraBattito(context),
        cambiaErg: (acceso) => setState(() {
          _ergAcceso = acceso;
          _comandaRullo();
        }),
        cambiaScala: (s) => setState(() {
          _ergScala = s;
          _comandaRullo();
        }),
      ),
    );
  }

  /// La parte centrale: con il GPS, i dati e la mappa come scelto nelle
  /// impostazioni (due pagine, minimappa o mappa a tutto schermo).
  Widget _centro(BuildContext context, Widget dati) {
    if (gps == null) return dati;
    return switch (vistaMappa.value) {
      VistaMappa.minimappa => dati,
      VistaMappa.schermo when !preparati => _mappaSchermoIntero(context),
      _ => Column(
        children: [
          _SceltaPagina(
            pagina: _pagina,
            onTap: (k) => _pagine.animateToPage(
              k,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pagine,
              onPageChanged: (k) => setState(() => _pagina = k),
              children: [dati, _paginaMappa(context)],
            ),
          ),
        ],
      ),
    };
  }

  Widget _mappaLive({bool compatta = false}) => MappaLive(
    key: ValueKey(_percorso?.id),
    sport: widget.sport,
    gps: gps!,
    traccia: _traccia,
    direzioneDiRiserva: _guida?.direzioneTraccia,
    compatta: compatta,
  );

  bool get _conQuota => _traccia?.punti.any((p) => p.quota != null) ?? false;

  /// La seconda pagina: guida, mappa grande, due dati e l'altimetria.
  Widget _paginaMappa(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: Column(
      children: [
        if (_guida != null) ...[
          BannerGuida(guida: _guida!),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _mappaLive(),
          ),
        ),
        const SizedBox(height: 8),
        _DueDati(sport: widget.sport, gps: gps!, zone: _zone),
        if (_conQuota) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ProfiloAltimetrico(
              traccia: _traccia!,
              metri: _guida?.progresso,
            ),
          ),
        ],
      ],
    ),
  );

  /// Tutto schermo: la mappa sotto, guida, tempo e dati sopra.
  Widget _mappaSchermoIntero(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final recupero = b.tipo == TipoBlocco.recupero;
    final tempo = b.aTempo
        ? fmtTimer(Duration(seconds: _restano.clamp(0, 99999).toInt()))
        : fmtTimer(_tempoBlocco);
    return Stack(
      children: [
        Positioned.fill(child: _mappaLive()),
        Positioned(
          top: 8,
          left: 12,
          right: 64,
          child: Column(
            spacing: 8,
            children: [
              if (_guida != null) BannerGuida(guida: _guida!, compatto: true),
              Material(
                color: scheme.surfaceContainer.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TestoUnaRiga(
                          recupero ? titoloRecupero(b) : mostra(b.titolo),
                          style: t.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tempo,
                        style: t.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: _inPausa ? scheme.onSurfaceVariant : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 8,
          child: _DueDati(sport: widget.sport, gps: gps!, zone: _zone),
        ),
      ],
    );
  }

  Widget _riepilogo(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Tempo per esercizio: somma dei blocchi di lavoro di ogni passo.
    final perPasso = <int, (String, Duration)>{};
    final seriePasso = <int, List<SerieFatta>>{};
    for (var k = 0; k < blocchi.length; k++) {
      final x = blocchi[k];
      if (x.tipo != TipoBlocco.lavoro || tempi[k] == null) continue;
      final prima = perPasso[x.passo]?.$2 ?? Duration.zero;
      perPasso[x.passo] = (x.titolo, prima + tempi[k]!);
      final f = fatte[k];
      if (f != null) {
        (seriePasso[x.passo] ??= []).add(
          SerieFatta(
            data: DateTime.now(),
            esercizio: x.esercizio,
            nome: x.titolo,
            serie: x.serie,
            ripetizioni: f.$1,
            kg: f.$2,
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Center(
          child: AnelloPulse(
            valore: 1,
            dimensione: 120,
            spessore: 10,
            child: Icon(
              Icons.emoji_events_rounded,
              size: 52,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.allenamentoCompletato2,
          style: t.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.libera
              ? fmtTimer(_tempoTotale)
              : '${fmtTimer(_tempoTotale)} · ${quantiEsercizi(perPasso.length)}',
          style: t.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (gps != null && !gps!.percorso.vuoto) ...[
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 200,
              child: IgnorePointer(
                child: MappaPercorso(
                  percorso: gps!.percorso,
                  sport: widget.sport,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${fmtKm(gps!.km)} · ${ritmoMedio(widget.sport, gps!.km, _tempoMedia)}',
            style: t.titleMedium,
            textAlign: TextAlign.center,
          ),
          // Tutti e due i tempi, qualunque media si sia scelta.
          if (_soste + _fermo > const Duration(seconds: 30))
            Text(
              l10n.movimentoTotale(
                fmtTimer(_tempoTotale - _fermo),
                fmtTimer(_tempoTotale + _soste),
              ),
              style: t.bodyMedium,
              textAlign: TextAlign.center,
            ),
        ],
        if (fc.massimo > 0) ...[
          const SizedBox(height: 8),
          Text(
            l10n.battitoMedioBpmMassimo(fc.media, fc.massimo),
            style: t.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
        if (contaPassi.passi > 0) ...[
          const SizedBox(height: 8),
          Text(
            [
              l10n.quantiPassi(fmtPassi(contaPassi.passi)),
              if (mediaPassiAlMinuto(contaPassi.passi, _tempoTotale)
                  case final c?)
                '$c ${l10n.alMinuto}',
            ].join(' · '),
            style: t.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
        if (potenza.n > 0 && _seriePotenza.length < 60)
          Text(
            [
              l10n.potenzaMediaW(potenza.media),
              if (cadenza.n > 0) l10n.cadenzaRpm(cadenza.media),
            ].join(' · '),
            style: t.bodyMedium,
            textAlign: TextAlign.center,
          ),
        // Almeno un minuto di potenza: grafico e tempo nelle zone.
        if (_seriePotenza.length >= 60) ...[
          const SizedBox(height: 20),
          GraficoPotenza(serie: _seriePotenza, inizio: _seriePotenza.first.t),
          const SizedBox(height: 12),
          ZonePotenzaCard(serie: _seriePotenza, zone: _zonePotenza),
          if (cadenza.n > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.cadenzaMediaRpm(cadenza.media),
                style: t.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
        if (_calorie case final c? when c.attive >= 1)
          Text(
            l10n.circaKcal(c.attive.round()),
            style: t.bodyMedium,
            textAlign: TextAlign.center,
          ),
        if (giri != null && giri!.giri.isNotEmpty) ...[
          const SizedBox(height: 20),
          SuperficiePulse(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (final (k, g) in giri!.giri.indexed)
                  RigaPulse(
                    titolo: l10n.km(g.numero * g.metri ~/ 1000),
                    sottotitolo: fmtTimer(g.tempo),
                    linea: k < giri!.giri.length - 1,
                    fine: Text(ritmoGiro(widget.sport, g), style: t.titleSmall),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        SuperficiePulse(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final (k, (passo, e))
                  in perPasso.entries.map((x) => (x.key, x.value)).indexed)
                RigaPulse(
                  titolo: e.$1,
                  sottotitolo: seriePasso[passo] == null
                      ? null
                      : fmtSerie(seriePasso[passo]!),
                  linea: k < perPasso.length - 1,
                  fine: Text(fmtTimer(e.$2), style: t.titleSmall),
                ),
            ],
          ),
        ),
        // Al chiuso, o se il GPS non ha misurato niente: i km a mano.
        if (_conPercorso && (_alChiuso || (gps?.km ?? 0) < 0.1)) ...[
          const SizedBox(height: 20),
          TextField(
            controller: _kmScritti,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _alChiuso
                  ? l10n.km2(attrezzoAlChiuso(widget.sport))
                  : l10n.kmPercorsi,
              suffixText: 'km',
              helperText: kmScritti(_kmScritti.text) == null
                  ? l10n.facoltativoSenzaSessioneResta
                  : ritmoMedio(
                      widget.sport,
                      kmScritti(_kmScritti.text)!,
                      _tempoTotale,
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
        _PesiScheda(
          state: widget.state,
          nomeWorkout: widget.passi.firstOrNull?.nome ?? '',
          fatte: [for (final l in seriePasso.values) ...l],
        ),
        if (stessoSport(widget.sport, sportArrampicata)) ...[
          const SizedBox(height: 12),
          _RiepilogoArrampicata(
            state: widget.state,
            idSessione: _idSessione,
            onCambia: () => setState(() {}),
          ),
        ],
        Material(
          type: MaterialType.transparency,
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: registra,
            onChanged: (v) => setState(() => registra = v ?? false),
            title: Text(l10n.segnaComeFatto),
            subtitle: Text(l10n.seOrologioRegistraStesso),
          ),
        ),
        const SizedBox(height: 8),
        // Per chi non ha niente che misuri la seduta: durata, metri, battito…
        OutlinedButton.icon(
          onPressed: () => _salvaEChiudi(aMano: true),
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(l10n.inserisciDatiMano),
        ),
        const SizedBox(height: 8),
        PulsantePrincipale(
          onPressed: () => _salvaEChiudi(feedback: true),
          icona: Icons.rate_review_rounded,
          testo: l10n.comAndata,
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _salvaEChiudi, child: Text(l10n.chiudi)),
      ],
    );
  }
}

/// Riga del GPS: com'è il segnale; se è spento, come accenderlo.
class _StatoGps extends StatelessWidget {
  final RegistratoreGps gps;
  final Future<void> Function() riaccendi;
  const _StatoGps({required this.gps, required this.riaccendi});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final (icona, colore, testo) = switch (gps.stato) {
      StatoGps.pronto => (
        Icons.gps_fixed_rounded,
        const Color(0xFF22E07A),
        l10n.segnaleGpsBuonoM(gps.precisione.round()),
      ),
      StatoGps.cerca || StatoGps.spento => (
        Icons.gps_not_fixed_rounded,
        const Color(0xFFFFC233),
        l10n.cercoSegnaleGpsMeglio,
      ),
      StatoGps.permessoNegato => (
        Icons.gps_off_rounded,
        scheme.error,
        l10n.gpsNonPermessoTocca,
      ),
      StatoGps.disattivato => (
        Icons.gps_off_rounded,
        scheme.error,
        l10n.posizioneSpentaToccaAccenderla,
      ),
    };
    final spento =
        gps.stato == StatoGps.permessoNegato ||
        gps.stato == StatoGps.disattivato;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: spento
          ? () async {
              // Prima si richiede il permesso; se resta negato, le impostazioni.
              await riaccendi();
              if (gps.stato == StatoGps.permessoNegato ||
                  gps.stato == StatoGps.disattivato) {
                await apriImpostazioniGps(gps.stato);
              }
            }
          : null,
      child: Row(
        children: [
          Icon(icona, size: 16, color: colore),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              testo,
              style: t.bodySmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Dati" e "Mappa": le due pagine, si cambia anche toccando.
class _SceltaPagina extends StatelessWidget {
  final int pagina;
  final ValueChanged<int> onTap;
  const _SceltaPagina({required this.pagina, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          for (final (k, icona, nome) in [
            (0, Icons.speed_rounded, l10n.dati),
            (1, Icons.map_rounded, l10n.mappa),
          ])
            Material(
              color: k == pagina
                  ? scheme.primary.withValues(alpha: 0.18)
                  : Colors.transparent,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onTap(k),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Row(
                    spacing: 6,
                    children: [
                      Icon(
                        icona,
                        size: 16,
                        color: k == pagina
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      Text(nome, style: t.labelLarge),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sotto la mappa: distanza e passo (o velocità) di adesso, più il battito
/// se c'è il sensore.
class _DueDati extends StatelessWidget {
  final String sport;
  final RegistratoreGps gps;
  final Zone zone;
  const _DueDati({required this.sport, required this.gps, required this.zone});

  @override
  Widget build(BuildContext context) {
    final adesso = velocitaAttuale(
      gps.filtro.punti,
      ora: DateTime.now(),
      finestra: finestraVelocita(sport),
    );
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: _Dato(
            etichetta: l10n.distanza,
            valore: gps.km.toStringAsFixed(2).replaceAll('.', ','),
            unita: 'km',
          ),
        ),
        Expanded(
          child: _Dato(
            etichetta: stessoSport(sport, 'Bici') ? l10n.velocita : l10n.passo,
            valore: fmtVelocita(sport, adesso),
            unita: unitaRitmo(sport),
          ),
        ),
        if (sensoreBattito.ricordato) Expanded(child: _DatoBattito(zone: zone)),
      ],
    );
  }
}

/// Corsa, camminata e bici: distanza, passo (o velocità) di adesso e medio,
/// battito o ultimo giro. Grandi, da leggere mentre ci si muove.
class _GrigliaLive extends StatelessWidget {
  final String sport;
  final RegistratoreGps gps;
  final Duration tempo;
  final Giro? ultimo;
  final Zone zone;

  /// Un dato per riga, con i numeri grandi: riempie la pagina quando sotto
  /// non c'è altro.
  final bool grande;
  const _GrigliaLive({
    required this.sport,
    required this.gps,
    required this.tempo,
    required this.ultimo,
    required this.zone,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    final bici = stessoSport(sport, 'Bici');
    final unita = unitaRitmo(sport);
    final adesso = velocitaAttuale(
      gps.filtro.punti,
      ora: DateTime.now(),
      finestra: finestraVelocita(sport),
    );
    final s = tempo.inMilliseconds / 1000;
    final media = gps.filtro.metri < 50 || s == 0 ? null : gps.filtro.metri / s;
    final giro = metriGiro(sport) ~/ 1000;
    final ultimo = this.ultimo;
    final quarto = sensoreBattito.ricordato
        ? _DatoBattito(zone: zone, grande: grande)
        : _Dato(
            etichetta: giro == 1 ? l10n.ultimoKm : l10n.ultimiKm(giro),
            valore: ultimo == null
                ? '–'
                : fmtVelocita(
                    sport,
                    ultimo.metri / (ultimo.tempo.inMilliseconds / 1000),
                  ),
            unita: unita,
            grande: grande,
          );
    final distanza = _Dato(
      etichetta: l10n.distanza,
      valore: gps.km.toStringAsFixed(2).replaceAll('.', ','),
      unita: 'km',
      grande: grande,
    );
    final adessoDato = _Dato(
      etichetta: bici ? l10n.velocita : l10n.passo,
      valore: fmtVelocita(sport, adesso),
      unita: unita,
      grande: grande,
    );
    final mediaDato = _Dato(
      etichetta: bici ? l10n.velocitaMedia : l10n.passoMedio,
      valore: fmtVelocita(sport, media),
      unita: unita,
      grande: grande,
    );
    if (grande) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [distanza, adessoDato, mediaDato, quarto],
      );
    }
    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(child: distanza),
            Expanded(child: adessoDato),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(child: mediaDato),
            Expanded(child: quarto),
          ],
        ),
      ],
    );
  }
}

/// Un riquadro con un numero grande: piatto, senza ombre (è un dato).
class _Dato extends StatelessWidget {
  final String etichetta;
  final String valore;
  final String unita;
  final IconData? icona;
  final VoidCallback? onTap;
  final String? nota; // sotto il valore, es. il range da tenere
  final bool notaFuori; // fuori dal range: la nota si colora
  final bool grande; // numero grande, per la pagina dei soli dati
  const _Dato({
    required this.etichetta,
    required this.valore,
    required this.unita,
    this.icona,
    this.onTap,
    this.nota,
    this.notaFuori = false,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: grande
              ? const EdgeInsets.fromLTRB(18, 12, 18, 12)
              : const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icona != null) ...[
                    Icon(icona, size: 14, color: scheme.primary),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      maiuscole(etichetta),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: valore,
                        style: (grande ? t.displayMedium : t.headlineMedium)
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      if (unita.isNotEmpty)
                        TextSpan(
                          text: ' $unita',
                          style: (grande ? t.titleMedium : t.bodySmall)
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                  maxLines: 1,
                ),
              ),
              if (nota != null)
                Text(
                  nota!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    color: notaFuori ? scheme.error : scheme.onSurfaceVariant,
                    fontWeight: notaFuori ? FontWeight.w700 : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La potenza (media di 3 secondi) con la zona; nei blocchi con una zona
/// chiesta, sotto il range di watt da tenere.
class _DatoPotenza extends StatelessWidget {
  final int? watt;
  final ZonePotenza? zone;
  final (int, int)? obiettivo; // watt da tenere nel blocco
  final VoidCallback onTap;
  const _DatoPotenza({
    required this.watt,
    required this.zone,
    required this.obiettivo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final z = zone, w = watt, o = obiettivo;
    final n = z == null || w == null ? 0 : z.zonaDi(w);
    final verso = z == null || w == null || o == null || w == 0
        ? 0
        : versoRange(w, o, z);
    final zo = z == null || o == null ? 0 : z.zonaDi((o.$1 + o.$2) ~/ 2);
    return _Dato(
      icona: Icons.bolt_rounded,
      etichetta: n > 0 ? l10n.potenzaZ(n) : l10n.potenza,
      valore: w?.toString() ?? '–',
      unita: 'W',
      nota: o == null
          ? null
          : switch (verso) {
              1 => '▼ Z$zo ${fmtRange(o)}',
              -1 => '▲ Z$zo ${fmtRange(o)}',
              _ => 'Z$zo ${fmtRange(o)}',
            },
      notaFuori: verso != 0,
      onTap: onTap,
    );
  }
}

/// Il battito di adesso con la zona; un tocco apre il foglio del sensore.
class _DatoBattito extends StatelessWidget {
  final Zone zone;
  final bool grande;
  const _DatoBattito({required this.zone, this.grande = false});

  @override
  Widget build(BuildContext context) {
    final bpm = sensoreBattito.bpm;
    final n = bpm == null ? 0 : zone.zonaDi(bpm);
    return _Dato(
      icona: Icons.favorite_rounded,
      etichetta: switch (sensoreBattito.stato) {
        StatoSensore.collegato when n > 0 => l10n.battitoZ(n),
        StatoSensore.collegato => l10n.battito,
        StatoSensore.collega => l10n.miCollego,
        _ => l10n.battito,
      },
      valore: bpm?.toString() ?? '–',
      unita: 'bpm',
      onTap: () => mostraBattito(context),
      grande: grande,
    );
  }
}

/// Il giro appena chiuso: numero del km, tempo e passo, per qualche secondo.
class _AvvisoGiro extends StatelessWidget {
  final Giro giro;
  final String sport;
  const _AvvisoGiro({super.key, required this.giro, required this.sport});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final km = giro.numero * giro.metri ~/ 1000;
    final colore = scheme.onPrimaryContainer;
    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: scheme.shadow.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_rounded, size: 18, color: colore),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    // A piedi il tempo del km è già il passo; in bici no.
                    giro.metri == 1000
                        ? l10n.km(km)
                        : l10n.kmUltimi(
                            km,
                            giro.metri ~/ 1000,
                            fmtTimer(giro.tempo),
                          ),
                    style: t.titleMedium?.copyWith(color: colore),
                  ),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                ritmoGiro(sport, giro),
                maxLines: 1,
                style: t.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colore,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Il tempo in grande: anello sfumato che si svuota per i blocchi a tempo,
/// cronometro che sale per quelli a ripetizioni.
class _Orologio extends StatelessWidget {
  final bool recupero;
  final bool aTempo;
  final int restano; // secondi
  final int totale;
  final Duration trascorso;
  final bool pausa;
  final bool piccolo;
  const _Orologio({
    required this.recupero,
    required this.aTempo,
    required this.restano,
    required this.totale,
    required this.trascorso,
    required this.pausa,
    this.piccolo = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final cifre = t.displayLarge?.copyWith(
      fontSize: piccolo ? 52 : 68,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Semantics(
      label: aTempo ? l10n.mancanoSecondi(restano) : l10n.tempoTrascorso,
      child: AnelloPulse(
        valore: aTempo && totale > 0 ? restano / totale : 0,
        dimensione: piccolo ? 190 : 240,
        spessore: piccolo ? 12 : 14,
        alone: aTempo,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Oltre l'ora le cifre sono di più: si stringono invece di uscire.
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: piccolo ? 150 : 196),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  aTempo
                      ? fmtTimer(Duration(seconds: restano))
                      : fmtTimer(trascorso),
                  style: cifre,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pausa
                  ? l10n.pausa4
                  : aTempo
                  ? (recupero ? l10n.parolaMancano : l10n.poiPassaSolo)
                  : l10n.toccaFattoQuandoHai2,
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Il tempo del blocco in piano: una barra che si riempie e le cifre sotto.
/// Senza durata la barra non c'è, e senza [conCronometro] nemmeno le cifre.
class _TempoPiatto extends StatelessWidget {
  final bool recupero;
  final bool aTempo;
  final int restano; // secondi
  final int totale;
  final Duration trascorso;
  final bool pausa;
  final bool conCronometro;
  const _TempoPiatto({
    required this.recupero,
    required this.aTempo,
    required this.restano,
    required this.totale,
    required this.trascorso,
    required this.pausa,
    required this.conCronometro,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final etichetta = pausa
        ? l10n.pausa4
        : aTempo
        ? (recupero ? l10n.parolaMancano : l10n.poiPassaSolo)
        : l10n.toccaFattoQuandoHai2;
    return Semantics(
      label: aTempo ? l10n.mancanoSecondi(restano) : l10n.tempoTrascorso,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          if (aTempo && totale > 0)
            BarraAvanzamento((totale - restano) / totale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 8,
            children: [
              if (aTempo || conCronometro)
                Text(
                  aTempo
                      ? fmtTimer(Duration(seconds: restano))
                      : fmtTimer(trascorso),
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              Flexible(
                child: Text(
                  etichetta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ripetizioni e kg della serie in corso, con l'ultima volta sotto.
/// Se l'esercizio ha un'animazione o delle foto da mostrare.
bool _conAnteprima(Esercizio? e) =>
    e != null && (animazioneDi(e.id) != null || e.immagini.isNotEmpty);

/// Il movimento dell'esercizio in piccolo; un tocco lo apre in grande.
/// Senza [larghezza] occupa tutto lo spazio che ha.
class _AnteprimaEsercizio extends StatelessWidget {
  final Esercizio esercizio;
  final double? larghezza;

  /// Lato sinistro di un esercizio per lato: le animazioni mostrano il lato
  /// destro, quindi qui si girano in orizzontale (un video solo per esercizio).
  final bool specchio;
  const _AnteprimaEsercizio({
    required this.esercizio,
    this.larghezza,
    this.specchio = false,
  });

  @override
  Widget build(BuildContext context) {
    final e = esercizio;
    Widget girata(Widget w) => Transform.flip(flipX: specchio, child: w);
    return Semantics(
      button: true,
      label: l10n.guardaMovimento(e.nome),
      child: GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (d) => AlertDialog(
            title: Text(e.nome),
            content: SizedBox(
              width: double.maxFinite,
              child: girata(
                AnimazioneEsercizio(id: e.id, immagini: e.immagini),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(d),
                child: Text(l10n.chiudi),
              ),
            ],
          ),
        ),
        child: SizedBox(
          width: larghezza,
          child: girata(
            AnimazioneEsercizio(
              id: e.id,
              immagini: e.immagini,
              mini: larghezza != null,
            ),
          ),
        ),
      ),
    );
  }
}

class RegistroSerie extends StatelessWidget {
  final (int, double) valori;
  final int massimo; // ripetizioni massime previste
  final bool conKg;
  final List<SerieFatta> ultima;
  final ValueChanged<(int, double)> cambia;
  const RegistroSerie({
    super.key,
    required this.valori,
    required this.massimo,
    required this.conKg,
    required this.ultima,
    required this.cambia,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final (rip, kg) = valori;
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cosaHaiFatto, style: t.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Contatore(
                  etichetta: l10n.ripetizioni,
                  testo: '$rip',
                  meno: rip > 1 ? () => cambia((rip - 1, kg)) : null,
                  piu: () => cambia((rip + 1, kg)),
                  scrivi: (v) {
                    final n = int.tryParse(v);
                    if (n != null && n > 0 && n < 1000) cambia((n, kg));
                  },
                ),
              ),
              if (conKg) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _Contatore(
                    etichetta: l10n.kg3,
                    testo: fmtKg(kg),
                    meno: kg > 0
                        ? () => cambia((rip, (kg - 1).clamp(0, 999).toDouble()))
                        : null,
                    piu: () => cambia((rip, kg + 1)),
                    scrivi: (v) {
                      final n = double.tryParse(v.replaceAll(',', '.'));
                      if (n != null && n >= 0 && n < 1000) cambia((rip, n));
                    },
                  ),
                ),
              ],
            ],
          ),
          if (ultima.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(l10n.ultimaVolta(fmtSerie(ultima)), style: t.bodySmall),
            if (conKg && prontoPerAumentare(ultima, massimo))
              Text(
                l10n.aveviFattoTutteRipetizioni,
                style: t.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
          ],
        ],
      ),
    );
  }
}

/// Un numero con − e +; toccandolo si scrive a mano.
class _Contatore extends StatelessWidget {
  final String etichetta;
  final String testo;
  final VoidCallback? meno;
  final VoidCallback piu;
  final ValueChanged<String> scrivi;
  const _Contatore({
    required this.etichetta,
    required this.testo,
    required this.meno,
    required this.piu,
    required this.scrivi,
  });

  Future<void> _aMano(BuildContext context) async {
    final c = TextEditingController(text: testo);
    final v = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(etichetta),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSubmitted: (x) => Navigator.pop(d, x),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, c.text),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    c.dispose();
    if (v != null) scrivi(v.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(etichetta, style: t.labelMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              tooltip: l10n.meno2(etichetta),
              onPressed: meno,
              icon: const Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _aMano(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    testo,
                    textAlign: TextAlign.center,
                    style: t.headlineSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: l10n.piu2(etichetta),
              onPressed: piu,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

/// Se l'allenamento era della scheda e hai usato altri pesi: un tocco per
/// scriverli nella scheda, senza rifarla.
class _PesiScheda extends StatefulWidget {
  final AppState state;
  final String nomeWorkout;
  final List<SerieFatta> fatte;
  const _PesiScheda({
    required this.state,
    required this.nomeWorkout,
    required this.fatte,
  });

  @override
  State<_PesiScheda> createState() => _PesiSchedaState();
}

class _PesiSchedaState extends State<_PesiScheda> {
  bool _salvati = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = widget.state.schedaAttiva;
    final g = s?.giornoPer(DateTime.now());
    if (s == null || g == null || g.nome != widget.nomeWorkout) {
      return const SizedBox.shrink();
    }
    final cambi = pesiCambiati(g, widget.fatte);
    if (cambi.isEmpty) return const SizedBox.shrink();
    String kg(List<double> l) =>
        l.isEmpty ? l10n.nessunPeso2 : '${l.map(fmtKg).join(', ')} kg';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SuperficiePulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pesiDiversiDallaScheda, style: t.titleSmall),
            const SizedBox(height: 4),
            for (final (nome, prima, dopo) in cambi)
              Text('• $nome: ${kg(prima)} → ${kg(dopo)}', style: t.bodySmall),
            const SizedBox(height: 8),
            _salvati
                ? Text(l10n.scrittiNellaScheda, style: t.bodyMedium)
                : FilledButton.tonalIcon(
                    onPressed: () async {
                      await widget.state.aggiornaPesiScheda(s.id, {
                        for (final (nome, _, dopo) in cambi) nome: dopo,
                      });
                      if (mounted) setState(() => _salvati = true);
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: Text(l10n.aggiornaScheda),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Arrampicata: vie, blocchi e gradi della seduta appena finita.
class _RiepilogoArrampicata extends StatelessWidget {
  final AppState state;
  final String idSessione;
  final VoidCallback onCambia;
  const _RiepilogoArrampicata({
    required this.state,
    required this.idSessione,
    required this.onCambia,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final oggi = soloData(DateTime.now());
    final a = state.arrampicate
        .where((x) => x.idSessione == idSessione)
        .firstOrNull;
    Future<void> apri() async {
      await apriArrampicata(context, state, idSessione: idSessione, data: oggi);
      onCambia();
    }

    if (a == null) {
      return FilledButton.tonalIcon(
        onPressed: apri,
        icon: const Icon(Icons.terrain_rounded),
        label: Text(l10n.segnaVieBlocchiGradi),
      );
    }
    return SuperficiePulse(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in a.riassunto) Text(r, style: t.bodyMedium),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.modifica,
            onPressed: apri,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
  }
}
