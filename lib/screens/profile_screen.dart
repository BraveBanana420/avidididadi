import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../avviso.dart';
import '../app_state.dart';
import '../charts.dart';
import '../figura.dart';
import '../models.dart';
import '../pulse.dart';
import '../profilo.dart';
import '../tema.dart';
import '../esercizi.dart';
import 'allenamenti_arrampicata_screen.dart';
import 'attivita_screen.dart';
import 'altre_pagine.dart';
import 'attrezzatura_screen.dart';
import 'benvenuto_screen.dart';
import 'catalogo_screen.dart';
import 'crea_piano_screen.dart';
import 'dati_personali_screen.dart';
import 'obiettivo_screen.dart';
import 'opzioni_allenamento_screen.dart';
import 'percorsi_screen.dart';
import 'schede_screen.dart';
import 'sensori_screen.dart';
import 'tour.dart';
import 'storico_misure_screen.dart';
import '../generatore_forza.dart';
import '../l10n/lingua.dart';
import '../l10n/vocabolario.dart';
import 'lingua_screen.dart';
import '../config.dart';
import '../link.dart';

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
        avviso(content: Text(l10n.impossibileCaricareFoto(e))),
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
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.scegliDallaGalleria),
              onTap: () {
                Navigator.pop(ctx);
                _scegliFoto(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.scattaFoto),
              onTap: () {
                Navigator.pop(ctx);
                _scegliFoto(context, ImageSource.camera);
              },
            ),
            if (state.fileFoto != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(l10n.rimuoviFoto),
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
      aiuto: l10n.siRegistraDataOggi,
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
          if (p.nascita != null) l10n.anni(_data(p.nascita!), p.eta ?? 0),
          if (p.sesso.isNotEmpty) mostra(p.sesso),
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
                                  ? const Icon(Icons.person_rounded, size: 40)
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
                                Icons.photo_camera_rounded,
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
                                ? l10n.tuoProfilo
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
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: Text(
                              datiPersonali.isEmpty
                                  ? l10n.inserisciTuoiDati
                                  : l10n.modificaTuoiDati,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TitoloSezione(l10n.mioAllenamento),
                Column(
                  children: [
                    voce(
                      Icons.flag_rounded,
                      l10n.mioObiettivo,
                      o == null
                          ? l10n.nessunaGaraTiAlleni
                          : '${o.nome} · ${dataLunga(o.data)}',
                      ObiettivoScreen(state: state),
                    ),
                    voce(
                      Icons.tune_rounded,
                      l10n.mieAttivita,
                      state.attivitaScelte.join(', '),
                      AttivitaScreen(state: state),
                    ),
                    // "Prepara le sedute" e "Le mie schede" insieme, per il giro.
                    Column(
                      key: ChiaviTour.prepara,
                      children: [
                        voce(
                          Icons.auto_awesome_rounded,
                          l10n.preparaSedute,
                          p.obiettivo.isEmpty && p.sportGenerati.isEmpty
                              ? l10n.scegliSportAppScrive
                              : [
                                  if (p.obiettivo.isNotEmpty)
                                    l10n.forza(
                                      obiettivi[p.obiettivo]?.$1
                                              .toLowerCase() ??
                                          p.obiettivo,
                                    ),
                                  ...p.sportGenerati,
                                ].join(' · '),
                          CreaPianoScreen(state: state),
                          evidenza: true,
                        ),
                        voce(
                          Icons.assignment_rounded,
                          l10n.mieSchede,
                          state.schedeAttive.isEmpty
                              ? l10n.schedePersonalTrainerO
                              : l10n.corso(
                                  state.schedeAttive
                                      .map(
                                        (s) =>
                                            s.nome.isEmpty ? s.sport : s.nome,
                                      )
                                      .join(', '),
                                ),
                          SchedeScreen(state: state),
                        ),
                      ],
                    ),
                    voce(
                      Icons.fitness_center_rounded,
                      l10n.miaAttrezzatura,
                      state.attrezzatura.isEmpty
                          ? l10n.soloCorpoLibero
                          : state.attrezzatura.keys
                                .map((k) => attrezzoDa(k)?.nome ?? k)
                                .join(', '),
                      AttrezzaturaScreen(state: state),
                    ),
                    voce(
                      Icons.menu_book_rounded,
                      l10n.esercizi,
                      l10n.comeSiFannoImmagini,
                      CatalogoScreen(state: state),
                      linea: p.modoAvanzato,
                    ),
                    if (p.modoAvanzato)
                      voce(
                        Icons.monitor_heart_rounded,
                        l10n.mieZone,
                        l10n.quantoSpingereBattitiAl,
                        ZoneScreen(state: state),
                        linea: false,
                      ),
                  ],
                ),
                TitoloSezione(
                  l10n.mioCorpo,
                  destra: PulsanteStorico(state: state),
                ),
                Text(
                  ultimoAgg == null
                      ? l10n.toccaMisuraInserirlaVedrai
                      : l10n.ultimoAggiornamentoToccaMisura(_data(ultimoAgg)),
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
                TitoloSezione(l10n.impostazioniAiuto),
                Column(
                  children: [
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.dark_mode_rounded),
                      titolo: l10n.temaScuro,
                      sottotitolo: l10n.fondoGrafiteOppureBianco,
                      onTap: cambiaTema,
                      fine: Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (_) => cambiaTema(),
                      ),
                    ),
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.auto_awesome_rounded),
                      titolo: l10n.versioneNeon,
                      sottotitolo: l10n.rosaVerdeAcquaAzzurro,
                      onTap: cambiaNeon,
                      fine: Switch(
                        value: neon.value,
                        onChanged: (_) => cambiaNeon(),
                      ),
                    ),
                    voce(
                      Icons.translate_rounded,
                      l10n.lingua,
                      lingueApp[codiceLingua]!,
                      const LinguaScreen(),
                    ),
                    voce(
                      Icons.bluetooth_rounded,
                      l10n.mieiSensori,
                      l10n.fasciaCardioRulloSensori,
                      SensoriScreen(state: state),
                    ),
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.speed_rounded),
                      titolo: l10n.funzioniAvanzate,
                      sottotitolo: l10n.zoneWattSensoriBluetooth,
                      onTap: () => state.impostaAvanzata(!p.modoAvanzato),
                      fine: Switch(
                        value: p.modoAvanzato,
                        onChanged: state.impostaAvanzata,
                      ),
                    ),
                    voce(
                      Icons.directions_run_rounded,
                      l10n.duranteAllenamento,
                      l10n.voceBipPausaAutomatica,
                      const OpzioniAllenamentoScreen(),
                    ),
                    if (state.attivitaScelta('Arrampicata'))
                      voce(
                        Icons.terrain_rounded,
                        l10n.allenamentiArrampicata,
                        l10n.tuoiAllenamentiCrealiFalli,
                        AllenamentiArrampicataScreen(state: state),
                      ),
                    voce(
                      Icons.route_rounded,
                      l10n.mieiPercorsi,
                      l10n.gpxSeguireMappaIndicazioni,
                      PercorsiScreen(state: state),
                    ),
                    voce(
                      Icons.sync_rounded,
                      l10n.datiCollegamenti,
                      l10n.orologioAppBackupDei,
                      DatiCollegamentiScreen(state: state),
                      chiave: ChiaviTour.collegamenti,
                    ),
                    // Il giro guidato, vicino agli altri aiuti.
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.help_outline_rounded),
                      titolo: l10n.giroGuidatoDellApp,
                      sottotitolo: l10n.n10FunzioniPrincipaliAlla,
                      onTap: () => avviaTour(context),
                    ),
                    voce(
                      Icons.school_rounded,
                      l10n.paroleDellAllenamento,
                      l10n.zoneCaricoFartlekSpiegati,
                      const GlossarioScreen(),
                    ),
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.restart_alt_rounded),
                      titolo: l10n.configurazioneGuidata,
                      sottotitolo: l10n.rifaiPianoRispondendoPoche,
                      onTap: () => _rifaiConfigurazione(context),
                    ),
                    // Solo un link: donare non sblocca nessuna funzione.
                    RigaPulse(
                      segno: const IconaQuadrata(Icons.favorite_rounded),
                      titolo: l10n.sostieniProgetto,
                      sottotitolo: l10n.sostieniSotto,
                      linea: false,
                      fine: const Icon(Icons.open_in_new_rounded, size: 20),
                      onTap: () => apriLink(context, urlDonazioni),
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
        title: Text(l10n.rifareConfigurazione),
        content: Text(l10n.settimanaTipoPianoOggi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.annulla),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.continua),
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
            aggiorna(() => errore = l10n.inserisciNumeroValido);
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
              child: Text(l10n.annulla),
            ),
            FilledButton(onPressed: salva, child: Text(l10n.salva)),
          ],
        );
      },
    ),
  );
}
