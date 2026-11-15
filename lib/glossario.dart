import 'l10n/lingua.dart';

// Spiegazioni in parole semplici dei termini dell'allenamento, per chi non si
// è mai allenato: si leggono nella seduta, così si impara usando l'app.

Map<String, String> get spiegazioniSedute => {
  'lento': l10n.corsaRitmoTranquilloDevi,
  'lungo': l10n.corsaPiuLungaSettimana,
  'fartlek': l10n.giocoVelocitaAlterniTratti,
  'tempo run': l10n.corsaRitmoSostenutoMa,
  'ripetute': l10n.trattiBreviVelociPausa,
  'ritmo gara': l10n.blocchiAlRitmoVuoi,
  'allunghi': l10n.corsaFacileQualcheAccelerazione,
  'tecnica': l10n.nuotoCalmoEserciziMigliorare,
  'soglia': l10n.serieVascheRitmoSostenuto,
  'uscita': l10n.pedalataCostanteRitmoFacile,
  'uscita lunga': l10n.pedalataPiuLungaSettimana,
  'intervalli': l10n.trattiPedalataImpegnativaSalita,
  'mobilità': l10n.movimentiLentiAllungamentiQuasi,
  'anche e gambe': l10n.mobilitaAncheCoscePolpacci,
  'schiena': l10n.mobilitaSchienaBustoUtile,
  'spalle e petto': l10n.mobilitaSpallePettoBraccia,
  'forza': l10n.eserciziMuscoliCorpoLibero,
};

/// Spiegazione del tipo di seduta (o dello sport), se c'è.
String? spiegaSeduta(String sport, String tipo) =>
    spiegazioniSedute[tipo.trim().toLowerCase()] ??
    (tipo.isEmpty ? spiegazioniSedute[sport.trim().toLowerCase()] : null);

/// Come si riconosce ogni zona di frequenza cardiaca, senza cardiofrequenzimetro.
Map<int, String> get sensazioniZone => {
  1: l10n.moltoFacileComeCamminata,
  2: l10n.facileRiesciParlare,
  3: l10n.medioParliMaFatica,
  4: l10n.impegnativoSoloPocheParole,
  5: l10n.alMassimoSiRegge,
};

final _zona = RegExp(r'(?:zon[ae]|[ζΖ]ώνη) (\d)');

/// "intensità zona 2" diventa anche "facile: riesci a parlare".
String? sensazioneDi(String testo) {
  final m = _zona.firstMatch(testo);
  return m == null ? null : sensazioniZone[int.parse(m.group(1)!)];
}

/// Parole che si incontrano nell'app, spiegate in breve.
Map<String, String> get glossario => {
  l10n.zoneFrequenzaCardiaca: l10n.cinqueFasceBattitiAl,
  l10n.fatica110: l10n.quantoTiSembrataDura,
  l10n.carico: l10n.quantoTiSeiAllenato,
  l10n.settimanaScarico: l10n.ogniQuattroSettimanePiu,
  l10n.glossarioRecupero: l10n.comeStaiOggiSonno,
  l10n.glossarioMobilita: l10n.movimentiLentiSciogliereArticolazioni,
};
