// Spiegazioni in parole semplici dei termini dell'allenamento, per chi non si
// è mai allenato: si leggono nella seduta, così si impara usando l'app.

const spiegazioniSedute = {
  'lento':
      'Corsa a ritmo tranquillo: devi riuscire a parlare senza fiatone. '
      'Costruisce la resistenza ed è la base di tutto.',
  'lungo':
      'La corsa più lunga della settimana, sempre a ritmo facile. Abitua il '
      'corpo a durare nel tempo.',
  'fartlek':
      'Gioco di velocità: alterni tratti veloci e tratti facili, senza mai '
      'fermarti. Allena a cambiare ritmo.',
  'tempo run':
      'Corsa a ritmo sostenuto ma costante, "comodamente impegnativo": '
      'parli a fatica, ma lo tieni per molti minuti.',
  'ripetute':
      'Tratti brevi e veloci con una pausa per recuperare tra uno e l\'altro. '
      'Rendono più veloci.',
  'ritmo gara':
      'Blocchi al ritmo che vuoi tenere il giorno della gara, per prenderci '
      'confidenza.',
  'allunghi':
      'Corsa facile con qualche accelerazione breve (20 secondi), veloce ma '
      'rilassata. Tiene le gambe brillanti senza stancare.',
  'tecnica':
      'Nuoto calmo con esercizi per migliorare il movimento: nuotare bene '
      'costa meno fatica.',
  'soglia':
      'Serie di vasche a ritmo sostenuto e costante con brevi pause. '
      'Migliora la velocità che riesci a tenere a lungo.',
  'uscita': 'Pedalata costante a ritmo facile: costruisce la resistenza.',
  'uscita lunga':
      'La pedalata più lunga della settimana, a ritmo facile. Porta acqua e '
      'qualcosa da mangiare.',
  'intervalli':
      'Tratti di pedalata impegnativa (in salita o in pianura) con pause '
      'facili in mezzo.',
  'mobilità':
      'Movimenti lenti e allungamenti, quasi tutti a tempo. Sciolgono '
      'articolazioni e muscoli, aiutano a recuperare e a muoversi meglio. '
      'Non deve mai fare male.',
  'anche e gambe':
      'Mobilità per anche, cosce e polpacci: le parti che lavorano di più '
      'in corsa e in bici.',
  'schiena': 'Mobilità per la schiena e il busto: utile se stai molto seduto.',
  'spalle e petto': 'Mobilità per spalle, petto e braccia: apre la postura e aiuta nel nuoto.',
  'forza':
      'Esercizi per i muscoli, a corpo libero o con i pesi, seguiti da qualche '
      'minuto di mobilità. Rendono più forti e proteggono da infortuni.',
};

/// Spiegazione del tipo di seduta (o dello sport), se c'è.
String? spiegaSeduta(String sport, String tipo) =>
    spiegazioniSedute[tipo.trim().toLowerCase()] ??
    (tipo.isEmpty ? spiegazioniSedute[sport.trim().toLowerCase()] : null);

/// Come si riconosce ogni zona di frequenza cardiaca, senza cardiofrequenzimetro.
const sensazioniZone = {
  1: 'molto facile, come una camminata veloce',
  2: 'facile: riesci a parlare',
  3: 'medio: parli, ma a fatica',
  4: 'impegnativo: solo poche parole',
  5: 'al massimo: si regge per poco',
};

final _zona = RegExp(r'zona (\d)');

/// "intensità zona 2" diventa anche "facile: riesci a parlare".
String? sensazioneDi(String testo) {
  final m = _zona.firstMatch(testo);
  return m == null ? null : sensazioniZone[int.parse(m.group(1)!)];
}

/// Parole che si incontrano nell'app, spiegate in breve.
const glossario = {
  'Zone di frequenza cardiaca':
      'Cinque fasce di battiti al minuto, dalla più facile (1) alla più dura '
      '(5). Le calcola l\'app dai tuoi dati: segui la zona indicata e '
      'l\'allenamento ha l\'effetto giusto.',
  'Fatica (da 1 a 10)':
      'Quanto ti è sembrata dura la seduta: 1 è una passeggiata, 10 è il '
      'massimo. Dirlo dopo ogni seduta aiuta l\'app ad adattare il piano.',
  'Carico':
      'Quanto ti sei allenato, tenendo conto di durata e fatica. Conta come '
      'cresce: aumentare poco alla volta evita di farsi male.',
  'Settimana di scarico':
      'Ogni quattro settimane una più leggera: il corpo assorbe il lavoro fatto '
      'e riparte più forte.',
  'Recupero':
      'Come stai oggi, da sonno e battiti a riposo. Se è basso, meglio una '
      'seduta facile.',
  'Mobilità': 'Movimenti lenti per sciogliere le articolazioni a fine seduta.',
};
