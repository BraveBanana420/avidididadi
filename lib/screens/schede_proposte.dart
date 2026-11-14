import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../avviso.dart';
import '../agente_esterno.dart';
import '../allenamento_agente.dart';
import '../allenamento_arrampicata.dart';
import '../app_state.dart';
import '../assistente.dart';
import '../esecuzione.dart';
import '../models.dart';
import '../potenza.dart';
import 'allenamenti_arrampicata_screen.dart';
import 'profilo_allenamento.dart';

// Anteprime delle proposte del coach (chat con la chiave API) e
// dell'assistente esterno: allenamenti passo per passo e piano nuovo.

/// Anteprima degli allenamenti scritti dall'agente: giorno, durata, passi (in
/// bici con il diagramma dei watt) e conferma.
class SchedaAllenamenti extends StatelessWidget {
  final AppState state;
  final List<AllenamentoAgente> allenamenti;
  final String motivo;
  final MessaggioChat?
  messaggio; // dalla chat del coach; null: assistente esterno
  const SchedaAllenamenti({
    super.key,
    required this.state,
    required this.allenamenti,
    required this.motivo,
    this.messaggio,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final oggi = soloData(DateTime.now());
    final zp = state.zonePotenza;
    final passati = allenamenti.where((a) => a.data.isBefore(oggi)).length;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              allenamenti.length == 1
                  ? 'Allenamento nuovo'
                  : '${allenamenti.length} allenamenti nuovi',
              style: t.titleSmall,
            ),
            if (motivo.isNotEmpty) Text(motivo, style: t.bodySmall),
            for (final a in allenamenti) ...[
              Text(
                '${titoloSessione(a.sport, a.tipo)} · ${dataLunga(a.data)}'
                '${a.durataMin > 0 ? ' · ${a.durataMin} min' : ''}',
                style: t.titleSmall,
              ),
              Text(a.nome, style: t.bodySmall),
              if (zp != null && stessoSport(a.sport, 'Bici'))
                ProfiloAllenamento(
                  barre: barreDa(blocchiDa(a.passi), zp),
                  zone: zp,
                  altezza: 48,
                ),
              for (final s in a.passi)
                Text(
                  '• ${s.descrizione}: ${intensitaCon(s.riepilogo, a.sport, zp, state.zone)}',
                  style: t.bodySmall,
                ),
              if (state.piano.any(
                (r) =>
                    r.data == a.data &&
                    stessoSport(r.sport, a.sport) &&
                    !a.data.isBefore(oggi),
              ))
                Text(
                  'Prende il posto della seduta di ${a.sport.toLowerCase()} '
                  'di quel giorno.',
                  style: t.bodySmall,
                ),
            ],
            if (passati > 0)
              Text(
                passati == 1
                    ? 'Uno è in un giorno passato: non si mette.'
                    : '$passati sono in giorni passati: non si mettono.',
                style: t.bodySmall,
              ),
            if (messaggio?.applicata ?? state.rispostaApplicata)
              const Text('Messo nel calendario.')
            else
              FilledButton.icon(
                onPressed: passati == allenamenti.length
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final n = await state.applicaAllenamentiAgente(
                          allenamenti,
                          da: messaggio,
                        );
                        messenger.showSnackBar(
                          avviso(
                            content: Text(
                              n == 0
                                  ? 'Niente da mettere: le date sono passate.'
                                  : n == 1
                                  ? 'Allenamento messo nel calendario.'
                                  : '$n allenamenti messi nel calendario.',
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.event_available),
                label: const Text('Metti nel calendario'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Anteprima di un piano nuovo dell'agente: settimane, problemi, conferma.
class SchedaPiano extends StatelessWidget {
  final AppState state;
  final PianoAgente piano;
  final MessaggioChat?
  messaggio; // dalla chat del coach; null: assistente esterno
  const SchedaPiano({
    super.key,
    required this.state,
    required this.piano,
    this.messaggio,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final esito = state.valutaPianoDa(piano);
    final settimane = <DateTime, List<PianoRiga>>{};
    for (final r in esito.sedute) {
      final w = r.data.subtract(Duration(days: r.data.weekday - 1));
      (settimane[w] ??= []).add(r);
    }
    final app = state.assistente.appEsterna;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Piano nuovo da ${dataLunga(piano.da)}', style: t.titleSmall),
            if (piano.motivo.isNotEmpty) Text(piano.motivo, style: t.bodySmall),
            const SizedBox(height: 8),
            if (messaggio?.applicata ?? state.rispostaApplicata)
              const Text('Applicato: lo trovi nel calendario.')
            else ...[
              Text(
                '${esito.sedute.length} sedute in ${settimane.length} '
                'settimane. Sostituisce il calendario da quel giorno in poi.',
              ),
              for (final e in settimane.entries.take(3))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Settimana del ${e.key.day}/${e.key.month}: '
                    '${e.value.map((r) => '${giorniSettimana[r.data.weekday - 1].substring(0, 3)} ${titoloSessione(r.sport, r.tipo)} ${r.durataMin}′').join(' · ')}',
                    style: t.bodySmall,
                  ),
                ),
              if (settimane.length > 3)
                Text('…e le altre settimane.', style: t.bodySmall),
              if (esito.problemi.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Non applicabile',
                  style: t.labelLarge?.copyWith(color: scheme.primary),
                ),
                for (final p in esito.problemi.take(6))
                  Text('• $p', style: t.bodySmall),
                if (messaggio != null)
                  Text('Scrivi al coach di correggerlo.', style: t.bodySmall)
                else
                  TextButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(
                        ClipboardData(
                          text: correzioneAgente(
                            esito.problemi,
                            state.assistente.codiceEsterno,
                          ),
                        ),
                      );
                      messenger.showSnackBar(
                        avviso(
                          content: Text(
                            'Copiato: incollalo in $app per correggere.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: Text('Copia i problemi per $app'),
                  ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilledButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final n = await state.applicaPianoAgente(
                        piano,
                        da: messaggio,
                      );
                      messenger.showSnackBar(
                        avviso(
                          content: Text(
                            n == 0
                                ? 'Il piano non è più applicabile: riprova.'
                                : 'Piano applicato: $n sedute nel calendario.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Applica il piano'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Anteprima degli allenamenti di arrampicata dell'assistente: vanno nella
/// raccolta e, quelli con la data, nel calendario.
class SchedaArrampicata extends StatelessWidget {
  final AppState state;
  final List<PropostaArrampicata> proposte;
  final MessaggioChat?
  messaggio; // dalla chat del coach; null: assistente esterno
  const SchedaArrampicata({
    super.key,
    required this.state,
    required this.proposte,
    this.messaggio,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final oggi = soloData(DateTime.now());
    final conData = proposte.where((p) => p.data != null).length;
    final passate = proposte
        .where((p) => p.data != null && p.data!.isBefore(oggi))
        .length;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              proposte.length == 1
                  ? 'Allenamento di arrampicata'
                  : '${proposte.length} allenamenti di arrampicata',
              style: t.titleSmall,
            ),
            for (final p in proposte) ...[
              Row(
                children: [
                  for (final tipo in p.allenamento.tipi)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(iconaTipoArrampicata(tipo), size: 18),
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${p.allenamento.nome} · ${p.allenamento.minuti} min',
                      style: t.titleSmall,
                    ),
                  ),
                ],
              ),
              Text(
                [
                  if (p.allenamento.categoria.isNotEmpty)
                    p.allenamento.categoria,
                  p.data == null
                      ? 'nella raccolta'
                      : 'nel calendario ${dataLunga(p.data!)}',
                ].join(' · '),
                style: t.bodySmall,
              ),
              for (final e in p.allenamento.esercizi)
                Text('• ${e.nome}: ${e.riassunto}', style: t.bodySmall),
            ],
            if (passate > 0)
              Text(
                'Le date passate non vanno nel calendario, ma l\'allenamento '
                'si salva lo stesso.',
                style: t.bodySmall,
              ),
            if (messaggio?.applicata ?? state.rispostaApplicata)
              const Text('Salvato.')
            else
              FilledButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final (salvati, messi) = await state
                      .applicaProposteArrampicata(proposte, da: messaggio);
                  messenger.showSnackBar(
                    avviso(
                      content: Text(
                        [
                          salvati == 1
                              ? 'Salvato negli allenamenti di arrampicata.'
                              : '$salvati salvati negli allenamenti di arrampicata.',
                          if (messi > 0)
                            messi == 1
                                ? 'Uno è nel calendario.'
                                : '$messi sono nel calendario.',
                        ].join(' '),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.save_alt),
                label: Text(
                  conData > passate ? 'Salva e metti nel calendario' : 'Salva',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
