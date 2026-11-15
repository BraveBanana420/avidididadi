import 'package:flutter/material.dart';

import '../app_state.dart';
import '../arrampicata.dart';
import '../modifica_sessione.dart';
import '../models.dart';
import '../percorso.dart';
import '../pulse.dart';
import '../widgets.dart';
import 'arrampicata_sheet.dart';
import 'serie_a_mano_screen.dart';

/// Tutto quello che si corregge di una seduta, in una pagina sola: nome,
/// indoor o outdoor, durata, distanza, battito… e per il nuoto vasche e
/// tempo medio.
class ModificaSessioneScreen extends StatefulWidget {
  final AppState state;
  final Sessione sessione;

  /// Dal riepilogo di una sessione già nello storico: ci sono anche il
  /// cestino, gli esercizi della forza e "Torna ai dati originali". Chi
  /// chiede di eliminare esce con 'elimina'.
  final bool completa;
  const ModificaSessioneScreen({
    super.key,
    required this.state,
    required this.sessione,
    this.completa = false,
  });

  @override
  State<ModificaSessioneScreen> createState() => _ModificaSessioneScreenState();
}

class _ModificaSessioneScreenState extends State<ModificaSessioneScreen> {
  late final s = widget.sessione;
  late final bool nuoto = stessoSport(s.sport, 'Nuoto');
  late final bool arrampicata = stessoSport(s.sport, sportArrampicata);
  late final bool conDistanza = !arrampicata && !stessoSport(s.sport, 'Forza');
  late final SedutaNuoto? datiNuoto = widget.state.nuotoDi(s.id);

  String _n(num v) => v > 0 ? fmtNum(v.toDouble()) : '';

  late final nome = TextEditingController(
    text: widget.state.ritocchi[s.id]?.nome ?? '',
  );
  late final durata = TextEditingController(text: _n(s.durataMin));
  late final km = TextEditingController(text: _n(s.distanzaKm));
  late final metri = TextEditingController(
    text: _n((s.distanzaKm * 1000).round()),
  );
  late final vasche = TextEditingController(text: _n(datiNuoto?.vasche ?? 0));
  late final lunghezza = TextEditingController(
    text: '${datiNuoto?.lunghezzaM ?? 25}',
  );
  late final passo = TextEditingController(
    text: tempoScritto(datiNuoto?.passo100S ?? 0),
  );
  late String stile = datiNuoto?.stile ?? '';
  late final fcMedia = TextEditingController(text: _n(s.fcMedia));
  late final fcMax = TextEditingController(text: _n(s.fcMax));
  late final calorie = TextEditingController(text: _n(s.calorieAttive.round()));
  late final rpe = TextEditingController(text: _n(s.rpe));
  late final note = TextEditingController(
    text: s.note == s.sport ? '' : s.note,
  );
  late bool chiuso = widget.state.ritocchi[s.id]?.alChiuso ?? false;
  late DateTime inizio = s.inizio ?? s.data.add(const Duration(hours: 12));
  String? erroreDurata;

  @override
  void dispose() {
    for (final c in [
      nome,
      durata,
      km,
      metri,
      vasche,
      lunghezza,
      passo,
      fcMedia,
      fcMax,
      calorie,
      rpe,
      note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Vasche per lunghezza: i metri si scrivono da soli, restano correggibili.
  void _ricalcolaMetri() {
    final v = numeroScritto(vasche.text, 2000).round();
    final l = numeroScritto(lunghezza.text, 200).round();
    if (v > 0 && l > 0) metri.text = '${v * l}';
    setState(() {});
  }

  Future<void> _scegliOra() async {
    final o = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inizio),
    );
    if (o == null) return;
    setState(
      () => inizio = DateTime(
        inizio.year,
        inizio.month,
        inizio.day,
        o.hour,
        o.minute,
      ),
    );
  }

  Future<void> _salva() async {
    final minuti = numeroScritto(durata.text, 2880).round();
    if (minuti <= 0) {
      setState(() => erroreDurata = 'Scrivi quanti minuti è durata');
      return;
    }
    final navigator = Navigator.of(context);
    final state = widget.state;
    final distanza = nuoto
        ? numeroScritto(metri.text, 100000) / 1000
        : conDistanza
        ? numeroScritto(km.text, 1000)
        : s.distanzaKm;
    await state.modificaSessione(
      sessioneModificata(
        s,
        inizio: inizio,
        durataMin: minuti,
        distanzaKm: distanza,
        fcMedia: numeroScritto(fcMedia.text, 250).round(),
        fcMax: numeroScritto(fcMax.text, 250).round(),
        calorie: numeroScritto(calorie.text, 20000),
        rpe: numeroScritto(rpe.text, 10),
        note: note.text.trim(),
      ),
      nuoto: nuoto
          ? SedutaNuoto(
              idSessione: s.id,
              data: s.data,
              vasche: numeroScritto(vasche.text, 2000).round(),
              lunghezzaM: numeroScritto(lunghezza.text, 200).round() > 0
                  ? numeroScritto(lunghezza.text, 200).round()
                  : 25,
              passo100S: secondiDa(passo.text),
              stile: stile,
            )
          : null,
    );
    final prima = state.ritocchi[s.id];
    final testo = nome.text.trim();
    if (testo != (prima?.nome ?? '') || chiuso != (prima?.alChiuso ?? false)) {
      await state.ritoccaSessione(
        RitoccoSessione(s.id, nome: testo, alChiuso: chiuso),
      );
    }
    navigator.pop();
  }

  Widget _campo(
    TextEditingController c,
    String etichetta, {
    String? suffisso,
    String? aiuto,
    String? errore,
    bool decimali = false,
    bool tempo = false,
    ValueChanged<String>? cambia,
  }) => TextField(
    controller: c,
    keyboardType: tempo
        ? TextInputType.datetime
        : TextInputType.numberWithOptions(decimal: decimali),
    decoration: InputDecoration(
      labelText: etichetta,
      suffixText: suffisso,
      helperText: aiuto,
      errorText: errore,
    ),
    onChanged: cambia,
  );

  Widget _coppia(Widget a, Widget b) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: [
      Expanded(child: a),
      Expanded(child: b),
    ],
  );

  List<Widget> _nuoto() {
    final t = Theme.of(context).textTheme;
    return [
      Text('In vasca', style: t.titleMedium),
      _coppia(
        _campo(vasche, 'Vasche', cambia: (_) => _ricalcolaMetri()),
        _campo(
          lunghezza,
          'Lunghezza vasca',
          suffisso: 'm',
          cambia: (_) => _ricalcolaMetri(),
        ),
      ),
      Wrap(
        spacing: 8,
        children: [
          for (final l in lunghezzeVasca)
            ChoiceChip(
              label: Text('$l m'),
              selected: lunghezza.text == '$l',
              onSelected: (_) {
                lunghezza.text = '$l';
                _ricalcolaMetri();
              },
            ),
        ],
      ),
      _coppia(
        _campo(metri, 'Metri totali', suffisso: 'm'),
        _campo(
          passo,
          'Tempo medio',
          suffisso: '/100 m',
          aiuto: 'es. 1:55',
          tempo: true,
        ),
      ),
      Text('Stile', style: t.titleSmall),
      Wrap(
        spacing: 8,
        children: [
          for (final x in stiliNuoto)
            ChoiceChip(
              label: Text(x),
              selected: stile == x,
              onSelected: (si) => setState(() => stile = si ? x : ''),
            ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(
        title: const Text('Modifica la sessione'),
        actions: [
          // Nel colore degli errori e lontano da "Salva": non si tocca
          // per sbaglio, e prima di eliminare si chiede conferma.
          if (widget.completa)
            IconButton(
              tooltip: 'Elimina la sessione',
              color: Theme.of(context).colorScheme.error,
              onPressed: () => Navigator.pop(context, 'elimina'),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Text('${s.sport} · ${dataLunga(s.data)}', style: t.titleMedium),
              TextField(
                controller: nome,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: "Nome dell'allenamento",
                  helperText: 'Facoltativo',
                ),
              ),
              // Dove è stata fatta: l'orologio non lo manda.
              if (sportConPercorso(s.sport, s.tipo))
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    stessoSport(s.sport, 'Bici')
                        ? 'Indoor (rulli, Tacx)'
                        : 'Indoor (tapis roulant)',
                  ),
                  subtitle: const Text('Niente mappa né GPX'),
                  value: chiuso,
                  onChanged: (v) => setState(() => chiuso = v),
                ),
              _coppia(
                _campo(
                  durata,
                  'Durata',
                  suffisso: 'min',
                  errore: erroreDurata,
                  cambia: (_) {
                    if (erroreDurata != null) {
                      setState(() => erroreDurata = null);
                    }
                  },
                ),
                OutlinedButton.icon(
                  onPressed: _scegliOra,
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(
                    'Inizio ${two(inizio.hour)}:${two(inizio.minute)}',
                  ),
                ),
              ),
              if (nuoto) ..._nuoto(),
              if (conDistanza && !nuoto)
                _campo(km, 'Distanza', suffisso: 'km', decimali: true),
              if (arrampicata)
                OutlinedButton.icon(
                  onPressed: () => apriArrampicata(
                    context,
                    widget.state,
                    idSessione: s.id,
                    data: s.data,
                  ),
                  icon: const Icon(Icons.terrain_rounded),
                  label: const Text('Vie, blocchi e gradi'),
                ),
              // Forza: esercizi, serie e kg scritti a mano.
              if (widget.completa && stessoSport(s.sport, 'Forza'))
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          SerieAManoScreen(state: widget.state, giorno: s.data),
                    ),
                  ),
                  icon: const Icon(Icons.fitness_center_rounded),
                  label: const Text('Esercizi, serie e kg'),
                ),
              Text('Come è andata', style: t.titleMedium),
              _coppia(
                _campo(fcMedia, 'Battito medio', suffisso: 'bpm'),
                _campo(fcMax, 'Battito massimo', suffisso: 'bpm'),
              ),
              _coppia(
                _campo(calorie, 'Calorie', suffisso: 'kcal'),
                _campo(rpe, 'Fatica', suffisso: 'su 10', decimali: true),
              ),
              TextField(
                controller: note,
                minLines: 2,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Tutto quello che ti ricordi',
                ),
              ),
              PulsantePrincipale(
                onPressed: _salva,
                icona: Icons.check_rounded,
                testo: 'Salva',
              ),
              // Quanto scritto a mano si toglie: tornano i dati dell'orologio.
              if (widget.completa &&
                  widget.state.sessioniModificate.containsKey(s.id))
                TextButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await widget.state.annullaCorrezioni(s.id);
                    navigator.pop();
                  },
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('Torna ai dati originali'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
