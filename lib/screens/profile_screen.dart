import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../charts.dart';
import '../figura.dart';
import '../models.dart';
import '../pulse.dart';
import '../profilo.dart';
import '../tema.dart';
import '../esercizi.dart';
import 'altre_pagine.dart';
import 'attrezzatura_screen.dart';
import 'benvenuto_screen.dart';
import 'catalogo_screen.dart';
import 'crea_piano_screen.dart';
import 'dati_personali_screen.dart';
import 'obiettivo_screen.dart';
import 'schede_screen.dart';
import 'tour.dart';
import 'storico_misure_screen.dart';
import '../generatore_forza.dart';

class ProfileScreen extends StatelessWidget {
  final AppState state;
  const ProfileScreen({super.key, required this.state});

  String _data(DateTime d) => '${two(d.day)}/${two(d.month)}/${d.year}';

  Future<void> _scegliFoto(BuildContext context, ImageSource sorgente) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final x = await ImagePicker().pickImage(
        source: sorgente,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (x == null) return;
      await state.impostaFoto(x.path);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Impossibile caricare la foto: $e')),
      );
    }
  }

  void _menuFoto(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Scegli dalla galleria'),
              onTap: () {
                Navigator.pop(ctx);
                _scegliFoto(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Scatta una foto'),
              onTap: () {
                Navigator.pop(ctx);
                _scegliFoto(context, ImageSource.camera);
              },
            ),
            if (state.fileFoto != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Rimuovi foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  state.rimuoviFoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _modificaMisura(
    BuildContext context,
    String campo,
    String titolo,
    String unita,
  ) async {
    final v = await _chiediNumero(
      context,
      titolo,
      unita,
      state.ultimaMisura(campo)?.$1 ?? 0,
      aiuto: 'Si registra con la data di oggi. Lascia vuoto per cancellare.',
    );
    if (v == null) return;
    await state.salvaMisura(campo, v);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final t = Theme.of(context).textTheme;
        final p = state.profilo;
        final peso = state.ultimaMisura('peso_kg');
        final foto = state.fileFoto;

        final riassunto = [
          if (p.eta != null) '${p.eta} anni',
          if (p.altezzaCm > 0) '${fmtNum(p.altezzaCm)} cm',
          if (peso != null) '${fmtNum(peso.$1)} kg',
        ].join(' · ');

        // Misure sulla figura e data dell'ultimo aggiornamento.
        final valori = <String, String>{};
        DateTime? ultimoAgg;
        for (final c in campiMisure.where((c) => c != 'peso_kg')) {
          final u = state.ultimaMisura(c);
          if (u == null) continue;
          valori[c] = '${fmtNum(u.$1)} cm';
          if (ultimoAgg == null || u.$2.isAfter(ultimoAgg)) ultimoAgg = u.$2;
        }

        final datiPersonali = [
          if (p.nomeCompleto.isNotEmpty) p.nomeCompleto,
          if (p.nascita != null) '${_data(p.nascita!)} (${p.eta} anni)',
          if (p.sesso.isNotEmpty) p.sesso,
          if (p.altezzaCm > 0) '${fmtNum(p.altezzaCm)} cm',
          if (peso != null) '${fmtNum(peso.$1)} kg',
        ];

        final o = p.obiettivoGara;
        final scheme = Theme.of(context).colorScheme;
        void apri(Widget w) =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
        Widget voce(
          IconData icona,
          String titolo,
          String sottotitolo,
          Widget pagina, {
          bool evidenza = false,
          bool linea = true,
          Key? chiave,
        }) => RigaPulse(
          key: chiave,
          segno: IconaQuadrata(icona, evidenza: evidenza),
          titolo: titolo,
          sottotitolo: sottotitolo,
          linea: linea,
          onTap: () => apri(pagina),
        );

        return SafeArea(
          bottom: false,
          child: GruppoGrafici(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, spazioBarra(context)),
              children: [
                // Chi sei: foto, nome e dati principali, con un solo "Modifica".
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _menuFoto(context),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: Pulse.di(context).primario,
                              boxShadow: Pulse.di(context).ombraPrimario,
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: scheme.surfaceContainerHigh,
                              backgroundImage: foto == null
                                  ? null
                                  : FileImage(foto),
                              child: foto != null
                                  ? null
                                  : p.iniziali.isEmpty
                                  ? const Icon(Icons.person, size: 40)
                                  : Text(p.iniziali, style: t.headlineSmall),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: scheme.primary,
                              child: Icon(
                                Icons.photo_camera,
                                size: 15,
                                color: scheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nomeCompleto.isEmpty
                                ? 'Il tuo profilo'
                                : p.nomeCompleto,
                            style: t.headlineSmall,
                          ),
                          if (riassunto.isNotEmpty)
                            Text(
                              riassunto,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () =>
                                apri(DatiPersonaliScreen(state: state)),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(
                              datiPersonali.isEmpty
                                  ? 'Inserisci i tuoi dati'
                                  : 'Modifica i tuoi dati',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Il giro guidato delle funzioni principali.
                    IconButton.filledTonal(
                      tooltip: 'Giro guidato',
                      onPressed: () => avviaTour(context),
                      icon: const Icon(Icons.question_mark),
                    ),
                  ],
                ),
                const TitoloSezione('Il mio allenamento'),
                Column(
                  children: [
                    voce(
                      Icons.flag_outlined,
                      'Il mio obiettivo',
                      o == null
                          ? 'Nessuna gara: ti alleni per stare in forma'
                          : '${o.nome} · ${dataLunga(o.data)}',
                      ObiettivoScreen(state: state),
                    ),
                    // "Prepara le sedute" e "Le mie schede" insieme, per il giro.
                    Column(
                      key: ChiaviTour.prepara,
                      children: [
                        voce(
                          Icons.auto_awesome,
                          'Prepara le sedute',
                          p.obiettivo.isEmpty && p.sportGenerati.isEmpty
                              ? "Scegli gli sport: l'app scrive gli allenamenti passo passo"
                              : [
                                  if (p.obiettivo.isNotEmpty)
                                    'Forza: ${obiettivi[p.obiettivo]?.$1.toLowerCase() ?? p.obiettivo}',
                                  ...p.sportGenerati,
                                ].join(' · '),
                          CreaPianoScreen(state: state),
                          evidenza: true,
                        ),
                        voce(
                          Icons.assignment_outlined,
                          'Le mie schede',
                          state.schedeAttive.isEmpty
                              ? "Le schede del personal trainer o dell'allenatore"
                              : 'In corso: ${state.schedeAttive.map((s) => s.nome.isEmpty ? s.sport : s.nome).join(', ')}',
                          SchedeScreen(state: state),
                        ),
                      ],
                    ),
                    voce(
                      Icons.fitness_center,
                      'La mia attrezzatura',
                      state.attrezzatura.isEmpty
                          ? 'Solo corpo libero'
                          : state.attrezzatura.keys
                                .map((k) => attrezzoDa(k)?.nome ?? k)
                                .join(', '),
                      AttrezzaturaScreen(state: state),
                    ),
                    voce(
                      Icons.menu_book_outlined,
                      'Esercizi',
                      'Come si fanno, con immagini e muscoli usati',
                      CatalogoScreen(state: state),
                    ),
                    voce(
                      Icons.monitor_heart_outlined,
                      'Le mie zone del cuore',
                      'Quanto spingere, in battiti al minuto',
                      ZoneScreen(state: state),
                      linea: false,
                    ),
                  ],
                ),
                TitoloSezione(
                  'Il mio corpo',
                  destra: PulsanteStorico(state: state),
                ),
                Text(
                  ultimoAgg == null
                      ? 'Tocca una misura per inserirla: vedrai come cambi nel tempo.'
                      : 'Ultimo aggiornamento: ${_data(ultimoAgg)}. Tocca una '
                            'misura per aggiornarla.',
                  style: t.bodySmall,
                ),
                const SizedBox(height: 8),
                SuperficiePulse(
                  raggio: 28,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: FiguraCorpo(
                    sesso: p.sesso,
                    valori: valori,
                    onTocca: (campo) => _modificaMisura(
                      context,
                      campo,
                      maiuscola(campo.replaceFirst('_cm', '')),
                      'cm',
                    ),
                  ),
                ),
                const TitoloSezione('Impostazioni e aiuto'),
                Column(
                  children: [
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.dark_mode_outlined),
                      titolo: 'Tema scuro',
                      sottotitolo: 'Fondo grafite oppure bianco',
                      onTap: cambiaTema,
                      fine: Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (_) => cambiaTema(),
                      ),
                    ),
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.auto_awesome_outlined),
                      titolo: 'Versione neon',
                      sottotitolo:
                          'Rosa, verde acqua e azzurro al posto del rosso',
                      onTap: cambiaNeon,
                      fine: Switch(
                        value: neon.value,
                        onChanged: (_) => cambiaNeon(),
                      ),
                    ),
                    voce(
                      Icons.sync,
                      'Dati e collegamenti',
                      'Orologio e app, backup dei dati',
                      DatiCollegamentiScreen(state: state),
                      chiave: ChiaviTour.collegamenti,
                    ),
                    voce(
                      Icons.school_outlined,
                      "Le parole dell'allenamento",
                      'Zone, carico, fartlek… spiegati semplici',
                      const GlossarioScreen(),
                    ),
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.restart_alt),
                      titolo: 'Configurazione guidata',
                      sottotitolo: 'Rifai il piano rispondendo a poche domande',
                      linea: false,
                      onTap: () => _rifaiConfigurazione(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _rifaiConfigurazione(BuildContext context) async {
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Rifare la configurazione?'),
        content: const Text(
          'Settimana tipo e piano da oggi in poi verranno sostituiti. Gli '
          'allenamenti già fatti e le misure restano.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Continua'),
          ),
        ],
      ),
    );
    if (ok == true) {
      navigator.push(
        MaterialPageRoute(builder: (_) => BenvenutoScreen(state: state)),
      );
    }
  }
}

/// Chiede un numero positivo; restituisce 0 se il campo viene svuotato,
/// null se si annulla.
Future<double?> _chiediNumero(
  BuildContext context,
  String titolo,
  String unita,
  double valore, {
  double massimo = 500,
  String? aiuto,
}) {
  final c = TextEditingController(text: valore > 0 ? fmtNum(valore) : '');
  String? errore;
  return showDialog<double>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, aggiorna) {
        void salva() {
          final testo = c.text.trim().replaceAll(',', '.');
          if (testo.isEmpty) {
            Navigator.pop(ctx, 0.0);
            return;
          }
          final v = double.tryParse(testo);
          if (v == null || v <= 0 || v > massimo) {
            aggiorna(() => errore = 'Inserisci un numero valido');
            return;
          }
          Navigator.pop(ctx, v);
        }

        return AlertDialog(
          title: Text(titolo),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: unita,
              errorText: errore,
              helperText: aiuto,
              helperMaxLines: 2,
            ),
            onSubmitted: (_) => salva(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            FilledButton(onPressed: salva, child: const Text('Salva')),
          ],
        );
      },
    ),
  );
}
