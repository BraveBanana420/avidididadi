import 'package:flutter/material.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../esercizi.dart';
import '../models.dart';
import '../potenza.dart';
import '../pulse.dart';
import '../registro_forza.dart';
import '../scheda.dart';
import '../widgets.dart';
import '../l10n/lingua.dart';

/// Le schede scritte a mano: forza (per esempio dal personal trainer) e
/// corsa, bici e nuoto (per esempio dall'allenatore o dal gruppo).
class SchedeScreen extends StatelessWidget {
  final AppState state;
  const SchedeScreen({super.key, required this.state});

  void _apri(BuildContext context, Scheda? s, [String sport = 'Forza']) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SchedaScreen(state: state, scheda: s, sport: sport),
        ),
      );

  /// Prima lo sport, poi la scheda.
  Future<void> _nuova(BuildContext context) async {
    final sport = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (sp, testo) in [
                ('Forza', l10n.eserciziSerieRipetizioniKg),
                ('Corsa', l10n.passiTempoODistanza),
                ('Bici', l10n.passiTempoODistanza2),
                ('Nuoto', l10n.vaschePasso100M),
              ])
                if (state.attivitaScelta(sp))
                  ListTile(
                    leading: Icon(iconaSport(sp), color: coloreSport(sp)),
                    title: Text(sp),
                    subtitle: Text(testo),
                    onTap: () => Navigator.pop(c, sp),
                  ),
            ],
          ),
        ),
      ),
    );
    if (sport != null && context.mounted) _apri(context, null, sport);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(l10n.mieSchede)),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final oggi = soloData(DateTime.now());
          final inCorso = [
            for (final s in state.schede.reversed)
              if (!s.archiviata && (s.fine == null || !oggi.isAfter(s.fine!)))
                s,
          ];
          final archivio = [
            for (final s in state.schede.reversed)
              if (!inCorso.contains(s)) s,
          ];
          Widget riga(Scheda s, bool linea) => RigaPulse(
            segno: IconaQuadrata(iconaSport(s.sport), evidenza: s.valida(oggi)),
            titolo: s.nome.isEmpty
                ? l10n.scheda3(s.sport.toLowerCase())
                : s.nome,
            sottotitolo: [
              descriviValidita(s),
              s.giorni.map((g) => g.nome).join(', '),
            ].where((x) => x.isNotEmpty).join(' · '),
            linea: linea,
            onTap: () => _apri(context, s),
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(l10n.scriviSchedaTuoPersonal, style: t.bodyMedium),
              const SizedBox(height: 16),
              PulsantePrincipale(
                onPressed: () => _nuova(context),
                icona: Icons.add_rounded,
                testo: l10n.nuovaScheda,
              ),
              if (inCorso.isNotEmpty) ...[
                TitoloSezione(l10n.corso2),
                SuperficiePulse(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final (i, s) in inCorso.indexed)
                        riga(s, i < inCorso.length - 1),
                    ],
                  ),
                ),
              ],
              if (archivio.isNotEmpty) ...[
                TitoloSezione(l10n.finite),
                SuperficiePulse(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final (i, s) in archivio.indexed)
                        riga(s, i < archivio.length - 1),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// "Dal 2 novembre al 16 novembre", "Dal 2 novembre, senza scadenza".
String descriviValidita(Scheda s) {
  String d(DateTime x) => '${x.day} ${mesiNomi[x.month - 1]}';
  if (s.archiviata) return l10n.archiviata;
  return s.fine == null
      ? l10n.dalSenzaScadenza(d(s.inizio))
      : l10n.dalAl(d(s.inizio), d(s.fine!));
}

List<String> get _iniziali => inizialiGiorni;
const _durate = [15, 30, 60];

/// Scrittura e modifica di una scheda.
class SchedaScreen extends StatefulWidget {
  final AppState state;
  final Scheda? scheda; // null: nuova
  final String sport; // per una scheda nuova
  const SchedaScreen({
    super.key,
    required this.state,
    this.scheda,
    this.sport = 'Forza',
  });

  @override
  State<SchedaScreen> createState() => _SchedaScreenState();
}

class _SchedaScreenState extends State<SchedaScreen> {
  late Scheda s =
      widget.scheda ??
      Scheda(
        id: 'sch-${DateTime.now().millisecondsSinceEpoch}',
        nome: '',
        sport: widget.sport,
        inizio: soloData(DateTime.now()),
        fine: soloData(DateTime.now()).add(const Duration(days: 14)),
        giorni: [
          GiornoScheda(
            nome: _nomeGiorno(0),
            giorni: _giorniSport().take(1).toSet(),
          ),
        ],
      );
  late final _nome = TextEditingController(text: s.nome);
  bool _modificata = false;

  String get _sport => widget.scheda?.sport ?? widget.sport;
  bool get _forza => stessoSport(_sport, 'Forza');

  String _nomeGiorno(int i) =>
      '${_forza ? l10n.giorno2 : l10n.seduta} ${String.fromCharCode(65 + i)}';

  /// I giorni della settimana con questo sport nella settimana tipo.
  Set<int> _giorniSport() => {
    for (final x in widget.state.settimana)
      if (stessoSport(x.sport, _sport)) x.giorno,
  };

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _cambia(Scheda nuova) => setState(() {
    s = nuova;
    _modificata = true;
  });

  void _cambiaGiorno(int i, GiornoScheda g) =>
      _cambia(s.copyWith(giorni: [...s.giorni]..[i] = g));

  Future<void> _salva() async {
    final navigator = Navigator.of(context);
    final vuoti = s.giorni.every((g) => g.esercizi.isEmpty);
    if (vuoti) {
      ScaffoldMessenger.of(context).showSnackBar(
        avviso(
          content: Text(
            _forza ? l10n.aggiungiAlmenoEsercizio : l10n.aggiungiAlmenoPasso,
          ),
        ),
      );
      return;
    }
    await widget.state.salvaScheda(s.copyWith(nome: _nome.text.trim()));
    navigator.pop();
  }

  /// Mette lo sport della scheda nei giorni della settimana tipo che non
  /// lo hanno, dicendo prima cosa si toglie da ciascun giorno.
  Future<void> _modificaSettimana(Set<int> giorni) async {
    final messenger = ScaffoldMessenger.of(context);
    final state = widget.state;
    final prima = [...state.settimana];
    var settimana = prima;
    var cambiati = 0;
    for (final d in giorni.toList()..sort()) {
      final sostituendo = conSportNelGiorno(settimana, d, _sport);
      final scelta = await _conferma(
        d,
        sostituendo.tolti,
        sostituendo.aggiunto,
      );
      if (scelta == null) continue;
      settimana = scelta
          ? sostituendo.settimana
          : conSportNelGiorno(
              settimana,
              d,
              _sport,
              sostituisci: false,
            ).settimana;
      cambiati++;
    }
    if (cambiati == 0) return;
    state.settimana = settimana;
    await state.salvaSettimana(prima: prima);
    if (!mounted) return;
    setState(() {});
    messenger.showSnackBar(avviso(content: Text(l10n.settimanaTipoAggiornata)));
  }

  /// true: sostituisci; false: aggiungi accanto; null: lascia com'è.
  Future<bool?> _conferma(int giorno, List<Slot> tolti, Slot aggiunto) {
    String descrivi(Slot x) => [
      titoloSessione(x.sport, x.tipo),
      x.fascia.toLowerCase(),
      '${x.durataMin} min',
    ].join(' · ');
    final nome = giorniSettimana[giorno - 1];
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.nellaSettimanaTipo(nome)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.aggiungo(descrivi(aggiunto))),
            const SizedBox(height: 12),
            if (tolti.isEmpty)
              Text(l10n.giornoRiposoNonTolgo(nome))
            else ...[
              Text(l10n.fargliPostoTolgoQuesto),
              for (final x in tolti) Text('• ${descrivi(x)}'),
              const SizedBox(height: 8),
              Text(l10n.oppurePuoiTenerleFare),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l10n.annulla),
          ),
          if (tolti.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l10n.tieniEntrambe),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(tolti.isEmpty ? l10n.aggiungi : l10n.sostituisci),
          ),
        ],
      ),
    );
  }

  Future<void> _elimina() async {
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.eliminareScheda),
        content: Text(l10n.seduteGiaFatteRestano),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.elimina),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.state.eliminaScheda(s.id);
    navigator.pop();
  }

  Future<void> _scegliInizio() async {
    final d = await showDatePicker(
      context: context,
      initialDate: s.inizio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    final durata = s.durataGiorni;
    _cambia(
      s.copyWith(
        inizio: d,
        fine: () => durata == null ? null : d.add(Duration(days: durata - 1)),
      ),
    );
  }

  Future<bool> _confermaUscita() async {
    if (!_modificata) return true;
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.uscireSenzaSalvare),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.esci),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.resta),
          ),
        ],
      ),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final forza = _giorniSport();
    final durata = s.durataGiorni;
    final senzaForza = {
      for (final g in s.giorni)
        for (final d in g.giorni)
          if (!forza.contains(d)) d,
    };
    return PopScope(
      canPop: !_modificata,
      onPopInvokedWithResult: (fatto, _) async {
        if (fatto) return;
        final navigator = Navigator.of(context);
        if (await _confermaUscita()) navigator.pop();
      },
      child: Scaffold(
        bottomNavigationBar: const MargineBarraSistema(),
        appBar: AppBar(
          title: Text(
            '${widget.scheda == null ? l10n.nuovaScheda : l10n.scheda4} · $_sport',
          ),
          actions: [
            if (widget.scheda != null)
              IconButton(
                tooltip: l10n.elimina,
                onPressed: _elimina,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextField(
              controller: _nome,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => _modificata = true,
              decoration: InputDecoration(
                labelText: l10n.nomeScheda,
                hintText: l10n.esSchedaNovembre,
              ),
            ),
            TitoloSezione(l10n.quantoDura),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final g in _durate)
                  ChoiceChip(
                    label: Text('$g giorni'),
                    selected: durata == g,
                    onSelected: (_) => _cambia(
                      s.copyWith(
                        fine: () => s.inizio.add(Duration(days: g - 1)),
                      ),
                    ),
                  ),
                ChoiceChip(
                  label: Text(l10n.fincheNonCambio),
                  selected: durata == null,
                  onSelected: (_) => _cambia(s.copyWith(fine: () => null)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text(descriviValidita(s), style: t.bodyMedium)),
                TextButton.icon(
                  onPressed: _scegliInizio,
                  icon: const Icon(Icons.event_rounded),
                  label: Text(l10n.inizio2),
                ),
              ],
            ),
            TitoloSezione(l10n.giorni),
            Text(
              _forza
                  ? l10n.ogniGiornoSchedaBusto
                  : l10n.ogniSedutaSchedaRipetute(_sport.toLowerCase()),
              style: t.bodySmall,
            ),
            if (senzaForza.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.nellaSettimanaTipoNon(
                    senzaForza.map((d) => giorniSettimana[d - 1]).join(', '),
                    _sport.toLowerCase(),
                  ),
                  style: t.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            if (senzaForza.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _modificaSettimana(senzaForza),
                  icon: const Icon(Icons.edit_calendar_rounded),
                  label: Text(l10n.modificaSettimana),
                ),
              ),
            const SizedBox(height: 8),
            for (final (i, g) in s.giorni.indexed) ...[
              _GiornoCard(
                state: widget.state,
                giorno: g,
                giorniForza: forza,
                sport: _sport,
                occupati: {
                  for (final (j, x) in s.giorni.indexed)
                    if (j != i) ...x.giorni,
                },
                cambia: (nuovo) => _cambiaGiorno(i, nuovo),
                elimina: s.giorni.length > 1
                    ? () => _cambia(
                        s.copyWith(giorni: [...s.giorni]..removeAt(i)),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () => _cambia(
                s.copyWith(
                  giorni: [
                    ...s.giorni,
                    GiornoScheda(nome: _nomeGiorno(s.giorni.length)),
                  ],
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(_forza ? l10n.aggiungiGiorno : l10n.aggiungiSeduta),
            ),
            const SizedBox(height: 24),
            PulsantePrincipale(
              onPressed: _salva,
              icona: Icons.check_rounded,
              testo: l10n.salvaScheda,
            ),
          ],
        ),
      ),
    );
  }
}

/// Un giorno della scheda: nome, giorni della settimana ed esercizi.
class _GiornoCard extends StatefulWidget {
  final AppState state;
  final GiornoScheda giorno;
  final Set<int> giorniForza; // con questo sport nella settimana tipo
  final String sport;
  final Set<int> occupati; // già presi da un altro giorno della scheda
  final ValueChanged<GiornoScheda> cambia;
  final VoidCallback? elimina;
  const _GiornoCard({
    required this.state,
    required this.giorno,
    required this.giorniForza,
    required this.sport,
    required this.occupati,
    required this.cambia,
    required this.elimina,
  });

  @override
  State<_GiornoCard> createState() => _GiornoCardState();
}

class _GiornoCardState extends State<_GiornoCard> {
  late final _nome = TextEditingController(text: widget.giorno.nome);

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  GiornoScheda get g => widget.giorno;

  @override
  void didUpdateWidget(_GiornoCard prima) {
    super.didUpdateWidget(prima);
    // Tolto un giorno sopra, questa scheda può mostrare un altro giorno.
    if (_nome.text.trim() != g.nome) _nome.text = g.nome;
  }

  bool get _forza => stessoSport(widget.sport, 'Forza');

  Future<void> _aggiungi() async {
    if (!_forza) {
      final nuovo = await modificaPasso(
        context,
        widget.sport,
        EsercizioScheda(
          nome: '',
          serie: 1,
          ripetizioni: '',
          recuperoS: 0,
          fase: g.esercizi.isEmpty ? 'riscaldamento' : 'principale',
          durataMin: '10',
        ),
      );
      if (nuovo == null) return;
      widget.cambia(g.copyWith(esercizi: [...g.esercizi, nuovo]));
      return;
    }
    final scelto = await Navigator.of(context).push<EsercizioScheda>(
      MaterialPageRoute(
        builder: (_) => SceltaEsercizioScreen(state: widget.state),
      ),
    );
    if (scelto == null || !mounted) return;
    final completo = await modificaEsercizio(context, scelto);
    if (completo == null) return;
    widget.cambia(g.copyWith(esercizi: [...g.esercizi, completo]));
  }

  Future<void> _modifica(int i) async {
    final e = _forza
        ? await modificaEsercizio(context, g.esercizi[i])
        : await modificaPasso(context, widget.sport, g.esercizi[i]);
    if (e == null) return;
    widget.cambia(g.copyWith(esercizi: [...g.esercizi]..[i] = e));
  }

  void _sposta(int i, int verso) {
    final l = [...g.esercizi];
    final x = l.removeAt(i);
    l.insert(i + verso, x);
    widget.cambia(g.copyWith(esercizi: l));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SuperficiePulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nome,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.nomeGiorno,
                    hintText: l10n.esBusto,
                  ),
                  onChanged: (v) => widget.cambia(g.copyWith(nome: v.trim())),
                ),
              ),
              if (widget.elimina != null)
                IconButton(
                  tooltip: l10n.togliQuestoGiorno,
                  onPressed: widget.elimina,
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  tooltip: giorniSettimana[d - 1],
                  label: Text(_iniziali[d - 1]),
                  showCheckmark: false,
                  // Con lo sport nella settimana tipo: bordo colorato; scelto:
                  // pieno dello stesso colore, un po' più chiaro. Scelto ma
                  // senza lo sport nella settimana: rosso.
                  side: BorderSide(
                    color:
                        g.giorni.contains(d) && !widget.giorniForza.contains(d)
                        ? scheme.error
                        : widget.giorniForza.contains(d)
                        ? scheme.primary
                        : scheme.outlineVariant,
                    width: widget.giorniForza.contains(d) ? 1.5 : 1,
                  ),
                  selectedColor: Color.lerp(
                    g.giorni.contains(d) && !widget.giorniForza.contains(d)
                        ? scheme.error
                        : scheme.primary,
                    Colors.white,
                    0.25,
                  ),
                  labelStyle: g.giorni.contains(d)
                      ? TextStyle(
                          color: widget.giorniForza.contains(d)
                              ? scheme.onPrimary
                              : scheme.onError,
                          fontWeight: FontWeight.w800,
                        )
                      : null,
                  selected: g.giorni.contains(d),
                  onSelected: widget.occupati.contains(d)
                      ? null
                      : (on) => widget.cambia(
                          g.copyWith(
                            giorni: on
                                ? {...g.giorni, d}
                                : ({...g.giorni}..remove(d)),
                          ),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (g.esercizi.isEmpty)
            Text(
              _forza ? l10n.nessunEsercizio : l10n.nessunPasso,
              style: t.bodySmall,
            ),
          Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (final (i, e) in g.esercizi.indexed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.nome),
                    subtitle: Text(e.riassunto),
                    onTap: () => _modifica(i),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Altro',
                      onSelected: (v) => switch (v) {
                        'su' => _sposta(i, -1),
                        'giu' => _sposta(i, 1),
                        _ => widget.cambia(
                          g.copyWith(esercizi: [...g.esercizi]..removeAt(i)),
                        ),
                      },
                      itemBuilder: (_) => [
                        if (i > 0)
                          PopupMenuItem(
                            value: 'su',
                            child: Text(l10n.spostaSu),
                          ),
                        if (i < g.esercizi.length - 1)
                          PopupMenuItem(
                            value: 'giu',
                            child: Text(l10n.spostaGiu),
                          ),
                        PopupMenuItem(value: 'via', child: Text(l10n.togli)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: _aggiungi,
            icon: const Icon(Icons.add_rounded),
            label: Text(_forza ? l10n.aggiungiEsercizio2 : l10n.aggiungiPasso),
          ),
        ],
      ),
    );
  }
}

/// I kg scritti come "20", "20 22,5 25" o "20; 22.5; 25", nell'ordine.
List<double> leggiKgSerie(String testo) => [
  for (final x
      in testo.replaceAll(', ', ' ').replaceAll(';', ' ').split(RegExp(r'\s+')))
    if (double.tryParse(x.replaceAll(',', '.')) case final v? when v >= 0) v,
];

/// Serie, ripetizioni, recupero, kg e note di un esercizio della scheda.
Future<EsercizioScheda?> modificaEsercizio(
  BuildContext context,
  EsercizioScheda e,
) {
  final rip = TextEditingController(text: e.ripetizioni);
  final rec = TextEditingController(text: '${e.recuperoS}');
  final kg = TextEditingController(text: e.kg.map(fmtKg).join(' '));
  final note = TextEditingController(text: e.note);
  var serie = e.serie;
  return showModalBottomSheet<EsercizioScheda>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => StatefulBuilder(
      builder: (c, aggiorna) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + spazioInBasso(c)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(e.nome, style: Theme.of(c).textTheme.titleLarge),
              Row(
                children: [
                  Expanded(child: Text(l10n.serie2)),
                  IconButton.filledTonal(
                    tooltip: l10n.serieMeno,
                    onPressed: serie > 1 ? () => aggiorna(() => serie--) : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '$serie',
                      textAlign: TextAlign.center,
                      style: Theme.of(c).textTheme.titleLarge,
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: l10n.seriePiu,
                    onPressed: serie < 20
                        ? () => aggiorna(() => serie++)
                        : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              TextField(
                controller: rip,
                decoration: InputDecoration(
                  labelText: l10n.ripetizioni,
                  helperText: l10n.es10810,
                ),
              ),
              TextField(
                controller: rec,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.recuperoSecondi),
              ),
              TextField(
                controller: kg,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.kg3,
                  helperText: l10n.pesoTutteSerie20,
                  helperMaxLines: 2,
                ),
              ),
              TextField(
                controller: note,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.notePersonalTrainer,
                  hintText: l10n.esScendi3Secondi,
                ),
              ),
              PulsantePrincipale(
                onPressed: () => Navigator.pop(
                  c,
                  e.copyWith(
                    serie: serie,
                    ripetizioni: rip.text.trim().isEmpty
                        ? '10'
                        : rip.text.trim(),
                    recuperoS: int.tryParse(rec.text.trim()) ?? 0,
                    kg: leggiKgSerie(kg.text),
                    note: note.text.trim(),
                  ),
                ),
                icona: Icons.check_rounded,
                testo: l10n.fatto,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Scelta di un esercizio dal catalogo (con l'attrezzatura che hai), oppure
/// scritto a mano se non c'è.
class SceltaEsercizioScreen extends StatefulWidget {
  final AppState state;
  const SceltaEsercizioScreen({super.key, required this.state});

  @override
  State<SceltaEsercizioScreen> createState() => _SceltaEsercizioScreenState();
}

class _SceltaEsercizioScreenState extends State<SceltaEsercizioScreen> {
  String _cerca = '';
  bool _tutti = false;

  Future<void> _aMano() async {
    final navigator = Navigator.of(context);
    final c = TextEditingController(text: _cerca);
    final nome = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.esercizioNonCatalogo),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.nome),
          onSubmitted: (x) => Navigator.pop(d, x),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, c.text),
            child: Text(l10n.aggiungi),
          ),
        ],
      ),
    );
    c.dispose();
    if (nome == null || nome.trim().isEmpty) return;
    navigator.pop(EsercizioScheda(nome: nome.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final lista = cercaEsercizi(
      state.esercizi,
      state.attrezzatura,
      _cerca,
      tutti: _tutti,
    );
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(l10n.scegliEsercizio)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: l10n.cercaEsLatPanca,
              ),
              onChanged: (v) => setState(() => _cerca = v),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              title: Text(l10n.soloMiaAttrezzatura),
              value: !_tutti,
              onChanged: (v) => setState(() => _tutti = !v),
            ),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_rounded),
                    title: Text(l10n.nonCScriviloMano),
                    onTap: _aMano,
                  ),
                  for (final e in lista)
                    ListTile(
                      leading: Icon(iconaSport('Forza')),
                      title: Text(e.nome),
                      subtitle: Text(
                        '${nomiSchemi[e.schema] ?? e.schema} · '
                        '${e.descrizioneAttrezzi}',
                      ),
                      onTap: () => Navigator.pop(
                        context,
                        EsercizioScheda(esercizio: e.id, nome: e.nome),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<(String, String)> get _fasi => [
  ('riscaldamento', 'Riscaldamento'),
  ('principale', l10n.principale),
  ('defaticamento', l10n.defaticamento),
];

/// Un passo di corsa, bici o nuoto: fase, cosa fare, quante volte, a tempo o
/// a distanza, zona o passo, recupero tra le ripetizioni.
Future<EsercizioScheda?> modificaPasso(
  BuildContext context,
  String sport,
  EsercizioScheda e,
) {
  final nuoto = stessoSport(sport, 'Nuoto');
  final nome = TextEditingController(text: e.nome);
  var aDistanza = e.distanzaM.isNotEmpty || (nuoto && e.durataMin.isEmpty);
  final quanto = TextEditingController(
    text: aDistanza ? e.distanzaM : e.durataMin,
  );
  final zona = RegExp(r'zona ([1-5])').firstMatch(e.intensita);
  var scelta = zona != null
      ? 'zona ${zona.group(1)}'
      : e.intensita.startsWith('passo')
      ? 'passo'
      : intensitaInWatt(e.intensita)
      ? 'watt'
      : '';
  final watt = TextEditingController(text: scelta == 'watt' ? e.intensita : '');
  final secondario = TextEditingController(text: e.obiettivo2);
  final passo = TextEditingController(
    text: e.intensita.startsWith('passo')
        ? e.intensita.substring(5).trim()
        : '',
  );
  final rec = TextEditingController(
    text: e.recuperoS > 0 ? '${e.recuperoS}' : '',
  );
  final note = TextEditingController(text: e.note);
  var fase = e.fase;
  var volte = e.serie;
  return showModalBottomSheet<EsercizioScheda>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => StatefulBuilder(
      builder: (c, aggiorna) {
        final t = Theme.of(c).textTheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + spazioInBasso(c)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(l10n.passo2(sport.toLowerCase()), style: t.titleLarge),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final (f, testo) in _fasi)
                      ChoiceChip(
                        label: Text(testo),
                        selected: fase == f,
                        onSelected: (_) => aggiorna(() => fase = f),
                      ),
                  ],
                ),
                TextField(
                  controller: nome,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.cosaFare,
                    hintText: nuoto
                        ? l10n.esStileLiberoGambe
                        : l10n.esCorsaFacileRipetute,
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: Text(l10n.quanteVolte)),
                    IconButton.filledTonal(
                      tooltip: l10n.meno3,
                      onPressed: volte > 1
                          ? () => aggiorna(() => volte--)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$volte',
                        textAlign: TextAlign.center,
                        style: t.titleLarge,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: l10n.piu3,
                      onPressed: volte < 50
                          ? () => aggiorna(() => volte++)
                          : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(l10n.tempo2),
                      icon: Icon(Icons.timer_rounded),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(l10n.distanza2),
                      icon: Icon(Icons.straighten_rounded),
                    ),
                  ],
                  selected: {aDistanza},
                  onSelectionChanged: (v) =>
                      aggiorna(() => aDistanza = v.first),
                ),
                TextField(
                  controller: quanto,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: aDistanza ? l10n.metri : l10n.minuti2,
                    hintText: aDistanza ? l10n.es400 : l10n.es10Oppure1,
                  ),
                ),
                Text(l10n.obiettivoPrincipale, style: t.titleSmall),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.libera),
                      selected: scelta.isEmpty,
                      onSelected: (_) => aggiorna(() => scelta = ''),
                    ),
                    for (var z = 1; z <= 5; z++)
                      ChoiceChip(
                        label: Text(l10n.zona(z)),
                        selected: scelta == 'zona $z',
                        onSelected: (_) => aggiorna(() => scelta = 'zona $z'),
                      ),
                    if (stessoSport(sport, 'Bici'))
                      ChoiceChip(
                        label: Text(l10n.watt),
                        selected: scelta == 'watt',
                        onSelected: (_) => aggiorna(() => scelta = 'watt'),
                      ),
                    if (!stessoSport(sport, 'Bici'))
                      ChoiceChip(
                        label: Text(l10n.passo),
                        selected: scelta == 'passo',
                        onSelected: (_) => aggiorna(() => scelta = 'passo'),
                      ),
                  ],
                ),
                if (scelta == 'passo')
                  TextField(
                    controller: passo,
                    decoration: InputDecoration(
                      labelText: l10n.passo,
                      hintText: nuoto ? l10n.es150100 : l10n.es500Km,
                    ),
                  ),
                if (scelta == 'watt')
                  TextField(
                    controller: watt,
                    decoration: InputDecoration(
                      labelText: l10n.watt,
                      hintText: l10n.es200Oppure190,
                    ),
                  ),
                TextField(
                  controller: secondario,
                  decoration: InputDecoration(
                    labelText: l10n.obiettivoSecondarioFacoltativo,
                    hintText: stessoSport(sport, 'Bici')
                        ? l10n.es8590Rpm
                        : stessoSport(sport, 'Corsa')
                        ? l10n.es170180Ppm
                        : l10n.es40BracciateAl,
                  ),
                ),
                TextField(
                  controller: rec,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.recuperoSecondi,
                    helperText: nuoto
                        ? l10n.pausaBordoVascaDopo
                        : l10n.traRipetizioneAltraVuoto,
                  ),
                ),
                TextField(
                  controller: note,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.note),
                ),
                PulsantePrincipale(
                  onPressed: () {
                    final q = quanto.text.trim().replaceAll(',', '.');
                    if ((double.tryParse(q) ?? 0) <= 0) {
                      ScaffoldMessenger.of(c).showSnackBar(
                        avviso(
                          content: Text(
                            aDistanza ? l10n.scriviMetri : l10n.scriviMinuti,
                          ),
                        ),
                      );
                      return;
                    }
                    final wattScritti = obiettivoWatt(watt.text);
                    if (scelta == 'watt' && wattScritti.isEmpty) {
                      ScaffoldMessenger.of(c).showSnackBar(
                        avviso(content: Text(l10n.scriviWattEsempio200)),
                      );
                      return;
                    }
                    final testo = nome.text.trim();
                    Navigator.pop(
                      c,
                      e.copyWith(
                        nome: testo.isEmpty
                            ? _fasi.firstWhere((x) => x.$1 == fase).$2
                            : testo,
                        fase: fase,
                        serie: volte,
                        durataMin: aDistanza ? '' : q,
                        distanzaM: aDistanza
                            ? '${double.parse(q).round()}'
                            : '',
                        intensita: scelta == 'passo'
                            ? (passo.text.trim().isEmpty
                                  ? ''
                                  : 'passo ${passo.text.trim()}')
                            : scelta == 'watt'
                            ? wattScritti
                            : scelta,
                        obiettivo2: normalizzaSecondario(
                          secondario.text,
                          sport,
                        ),
                        recuperoS: int.tryParse(rec.text.trim()) ?? 0,
                        note: note.text.trim(),
                      ),
                    );
                  },
                  icona: Icons.check_rounded,
                  testo: l10n.fatto,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
