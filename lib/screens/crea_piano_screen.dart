import 'package:flutter/material.dart';

import '../app_state.dart';
import '../esercizi.dart';
import '../generatore_endurance.dart';
import '../generatore_forza.dart';
import '../models.dart';
import '../obiettivo.dart';
import '../widgets.dart';
import 'attrezzatura_screen.dart';
import 'calendar_screen.dart';
import 'week_screen.dart';

const _sportPreparabili = ['Forza', 'Corsa', 'Nuoto', 'Bici', 'Mobilità'];

const _descrizioni = {
  'Forza':
      'Esercizi scelti per te e la tua attrezzatura, con serie, ripetizioni e '
      'pesi. Finisce sempre con un po\' di mobilità.',
  'Corsa':
      'Corse facili, una seduta più intensa (fartlek, tempo, ripetute) e il '
      'lungo che cresce verso la gara.',
  'Nuoto': 'Tecnica e serie al tuo ritmo, alternate a quelle più intense.',
  'Bici': 'Uscite facili, intervalli e uscita lunga.',
  'Mobilità':
      'Stretching e movimenti lenti, a tempo: ogni volta una zona del corpo '
      'diversa. Ottima anche per recuperare.',
};

/// Una sola pagina per far preparare all'app le sedute: si scelgono gli sport
/// e si generano solo quelli. Giorni e minuti vengono dalla settimana tipo.
class CreaPianoScreen extends StatefulWidget {
  final AppState state;

  /// Sport da trovare già spuntato (es. arrivando da una seduta senza esercizi).
  final String? sportIniziale;
  const CreaPianoScreen({super.key, required this.state, this.sportIniziale});

  @override
  State<CreaPianoScreen> createState() => _CreaPianoScreenState();
}

class _CreaPianoScreenState extends State<CreaPianoScreen> {
  late final _p = widget.state.profilo;
  late String obiettivo = _p.obiettivo.isEmpty ? 'generale' : _p.obiettivo;
  late String livello = _p.livello.isEmpty ? 'intermedio' : _p.livello;
  late final Map<String, String> progressione = {..._p.progressione};

  /// Sport già preparati dall'app.
  late final Set<String> attivi = {
    if (_p.obiettivo.isNotEmpty) 'Forza',
    ..._p.sportGenerati,
  };

  /// Scelta iniziale: quelli già attivi; la prima volta tutti quelli della
  /// settimana tipo.
  late final Set<String> scelti = {
    ...(attivi.isNotEmpty
        ? attivi
        : {
            for (final s in _sportPreparabili)
              if (_volte(s) > 0) s,
          }),
    if (widget.sportIniziale != null && _volte(widget.sportIniziale!) > 0)
      normSport(widget.sportIniziale!),
  };
  bool inCorso = false;

  int _volte(String sport) =>
      widget.state.settimana.where((x) => stessoSport(x.sport, sport)).length;

  Future<void> _prepara() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final tolti = attivi.difference(scelti);
    if (tolti.isNotEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Togliere ${tolti.join(' e ')}?'),
          content: Text(
            'Le sedute di ${tolti.join(' e ').toLowerCase()} restano nel '
            'calendario, ma senza esercizi preparati. Quelle già fatte non '
            'cambiano.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Togli'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => inCorso = true);
    final n = await widget.state.preparaSedute(
      sport: scelti,
      obiettivoForza: obiettivo,
      livelloForza: livello,
      progressione: {
        for (final e in progressione.entries)
          if (scelti.contains(e.key)) e.key: e.value,
      },
    );
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          scelti.isEmpty
              ? 'Sedute preparate tolte.'
              : 'Pronte $n sedute di ${scelti.join(', ').toLowerCase()}. '
                    'Le trovi in Oggi.',
        ),
      ),
    );
  }

  Widget _scelta(
    String titolo,
    Map<String, (String, String)> opzioni,
    String valore,
    void Function(String) imposta,
  ) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titolo, style: t.titleMedium),
        RadioGroup<String>(
          groupValue: valore,
          onChanged: (v) => setState(() => imposta(v ?? valore)),
          child: Column(
            children: [
              for (final e in opzioni.entries)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: e.key,
                  title: Text(e.value.$1),
                  subtitle: Text(e.value.$2),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Opzioni della forza: obiettivo, livello, attrezzatura.
  Widget _opzioniForza(AppState state) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        initiallyExpanded: !attivi.contains('Forza'),
        leading: Icon(iconaSport('Forza'), color: coloreSport('Forza')),
        title: const Text('Forza: come la vuoi'),
        subtitle: Text(
          '${obiettivi[obiettivo]?.$1} · ${livelli[livello]?.$1.toLowerCase()}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scelta('Obiettivo', obiettivi, obiettivo, (v) => obiettivo = v),
          const SizedBox(height: 8),
          _scelta('Livello', livelli, livello, (v) => livello = v),
          Text(
            'Non preoccuparti di sbagliare: il livello si adatta ai voti che '
            'dai a fine seduta.',
            style: t.bodySmall,
          ),
          const SizedBox(height: 12),
          Text('Attrezzatura', style: t.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              state.attrezzatura.isEmpty
                  ? 'Solo corpo libero'
                  : state.attrezzatura.entries
                        .map(
                          (e) => [
                            attrezzoDa(e.key)?.nome ?? e.key,
                            if (e.value.isNotEmpty) '(${scriviPesi(e.value)})',
                          ].join(' '),
                        )
                        .join(', '),
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AttrezzaturaScreen(state: state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Corsa, nuoto e bici: come crescere quando le sedute sono facili.
  Widget _opzioniResistenza(List<String> sport) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading: const Icon(Icons.trending_up),
        title: Text('${sport.join(', ')}: come crescere'),
        subtitle: const Text('Quando le sedute ti sembrano facili'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final sp in sport) ...[
            Text(sp, style: t.labelLarge),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  for (final e in modiProgressione.entries)
                    ButtonSegment(value: e.key, label: Text(e.value.$1)),
                ],
                selected: {progressione[sp] ?? progressioneAuto},
                onSelectionChanged: (v) =>
                    setState(() => progressione[sp] = v.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                modiProgressione[progressione[sp] ?? progressioneAuto]!.$2,
                style: t.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final t = Theme.of(context).textTheme;
    final oggi = soloData(DateTime.now());
    final o = state.profilo.obiettivoGara;
    final resistenza = [
      for (final s in sportEndurance)
        if (scelti.contains(s)) s,
    ];
    final ultimo = state.ultimoGiornoPiano;
    final calendarioVuoto = ultimo == null || ultimo.isBefore(oggi);
    // Sport scelti che nella settimana ci sono ma nel calendario no.
    final assenti = [
      for (final s in scelti)
        if (!state.piano.any(
          (r) => stessoSport(r.sport, s) && !r.data.isBefore(oggi),
        ))
          s,
    ];
    final cambia =
        scelti.length != attivi.length || !scelti.containsAll(attivi);

    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: const Text('Prepara le sedute')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Scegli per quali sport vuoi che l\'app scriva gli allenamenti '
              'passo passo. Prepara solo quelli che spunti.',
              style: t.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Per quali sport?', style: t.titleLarge),
            const SizedBox(height: 4),
            Card(
              child: Column(
                children: [
                  for (final sp in _sportPreparabili)
                    () {
                      final n = _volte(sp);
                      return CheckboxListTile(
                        secondary: Icon(
                          iconaSport(sp),
                          color: n == 0 ? null : coloreSport(sp),
                        ),
                        value: scelti.contains(sp),
                        onChanged: n == 0
                            ? null
                            : (v) => setState(
                                () => v == true
                                    ? scelti.add(sp)
                                    : scelti.remove(sp),
                              ),
                        title: Text(
                          [
                            sp,
                            n == 0
                                ? 'non è nella tua settimana'
                                : '$n ${n == 1 ? 'volta' : 'volte'} a settimana',
                            if (attivi.contains(sp)) 'già preparato',
                          ].join(' · '),
                        ),
                        subtitle: Text(_descrizioni[sp]!),
                      );
                    }(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => WeekScreen(state: state)),
                ),
                icon: const Icon(Icons.view_week_outlined),
                label: const Text('Cambia giorni e minuti (settimana tipo)'),
              ),
            ),
            if (scelti.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Le tue preferenze', style: t.titleLarge),
              const SizedBox(height: 4),
              if (scelti.contains('Forza')) _opzioniForza(state),
              if (resistenza.isNotEmpty) _opzioniResistenza(resistenza),
              if (resistenza.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Text(
                    o == null || o.fase(oggi) == Fase.libera
                        ? 'Senza una gara le sedute crescono a blocchi di 4 '
                              'settimane, con una più leggera. Puoi fissare una '
                              'gara dal Profilo, alla voce Il mio obiettivo.'
                        : '${o.nome}: le sedute cambiano con l\'avvicinarsi '
                              'della gara.',
                    style: t.bodySmall,
                  ),
                ),
            ],
            if (!calendarioVuoto && assenti.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 12),
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(
                    '${assenti.join(' e ')}: nessun giorno nel calendario',
                  ),
                  subtitle: const Text(
                    'È nella settimana tipo ma non ancora nel calendario. '
                    'Apri la settimana tipo e tocca "Porta tutta la settimana '
                    'nel calendario".',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => WeekScreen(state: state)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (calendarioVuoto)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_busy),
                  title: const Text('Il calendario è vuoto'),
                  subtitle: const Text(
                    'Prima allunga il calendario: poi le sedute si riempiono.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => GeneraSheet(state: state),
                  ),
                ),
              )
            else
              Text(
                'Le sedute si preparano fino a ${dataLunga(ultimo).toLowerCase()}; quando '
                'allunghi il calendario si aggiungono da sole.',
                style: t.bodySmall,
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed:
                    inCorso ||
                        calendarioVuoto ||
                        (scelti.isEmpty && attivi.isEmpty)
                    ? null
                    : _prepara,
                icon: inCorso
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  scelti.isEmpty
                      ? (attivi.isEmpty
                            ? 'Scegli almeno uno sport'
                            : 'Togli le sedute preparate')
                      : !cambia && attivi.isNotEmpty
                      ? 'Aggiorna le sedute'
                      : 'Prepara ${scelti.join(', ').toLowerCase()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
