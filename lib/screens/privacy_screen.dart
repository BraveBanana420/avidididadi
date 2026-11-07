import 'package:flutter/material.dart';

import '../widgets.dart';

/// Versione di Termini e informativa: se cambia, all'apertura si chiede di
/// accettarli di nuovo.
const versioneTermini = '2026-11-06.3';
const aggiornamentoTermini = '30 ottobre 2026';

/// Una pagina di testo a sezioni (informativa, termini).
class PaginaTesto extends StatelessWidget {
  final String titolo;
  final String? introduzione;
  final List<(String, String)> sezioni;
  const PaginaTesto({
    super.key,
    required this.titolo,
    this.introduzione,
    required this.sezioni,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: const MargineBarraSistema(),
      appBar: AppBar(title: Text(titolo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Ultimo aggiornamento: $aggiornamentoTermini',
            style: t.bodySmall,
          ),
          if (introduzione != null) ...[
            const SizedBox(height: 8),
            Text(introduzione!),
          ],
          const SizedBox(height: 16),
          for (final (titolo, testo) in sezioni)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titolo, style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text(testo),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Informativa sull'uso dei dati. Health Connect la apre quando l'utente
/// chiede perché l'app vuole accedere ai dati.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) => const PaginaTesto(
    titolo: 'Privacy e uso dei dati',
    introduzione:
        "In breve: i tuoi dati restano sul telefono. L'app non ha server, "
        "account né pubblicità e non vende né condivide i tuoi dati. Escono "
        "dal telefono solo nei casi descritti qui sotto, quasi tutti scelti "
        "da te.",
    sezioni: [
      (
        'Dati che inserisci tu',
        "Nome, data di nascita, sesso, altezza, peso e misure, foto del "
            "profilo, obiettivo e gara, settimana tipo, attrezzatura, feedback "
            "dopo gli allenamenti (fatica, completata, dolore), ripetizioni e "
            "kg delle serie di forza, vie, blocchi, gradi e allenamenti dell'arrampicata, vasche, tempi e altri dati delle sedute scritti a mano, "
            "schede scritte a mano e sessioni "
            "importate da file CSV. Servono a preparare il piano e a mostrare i "
            "progressi.",
      ),
      (
        'Dati letti da Health Connect (solo lettura)',
        "Con il tuo permesso l'app legge da Health Connect le sessioni di "
            "allenamento (tipo, titolo, inizio e fine) e, nel tempo di ogni "
            "sessione, frequenza cardiaca, distanza, calorie, passi e velocità. "
            "Legge anche FC a riposo, variabilità cardiaca (HRV) e sonno per "
            "valutare il recupero, e lo storico oltre i 30 giorni se lo concedi. "
            "Sono i dati scritti da Garmin Connect, Freeletics e dalle altre app "
            "collegate a Health Connect. L'app non scrive, non modifica e non "
            "cancella nulla in Health Connect.",
      ),
      (
        'Percorsi GPS delle sessioni',
        "Se l'app che ha registrato una corsa o un'uscita in bici ha salvato "
            "anche il percorso in Health Connect, Avidididadi lo legge solo con "
            "il tuo permesso: per la singola sessione (te lo chiede Health "
            "Connect) oppure per tutte, se scegli \"Consenti sempre\" nelle "
            "impostazioni di Health Connect. Puoi anche aggiungere tu un "
            "percorso caricando un file GPX (per esempio esportato da Garmin "
            "Connect). Una copia del percorso resta nell'app per mostrare la "
            "mappa. I percorsi da seguire che aggiungi a \"I miei percorsi\" "
            "(file GPX di gare, giri, amici) restano solo sul telefono e nel "
            "backup; non vanno all'assistente.",
      ),
      (
        'Posizione durante l\'allenamento',
        "Solo per corsa, camminata e bici, e solo mentre la modalità allenamento è "
            "aperta, l'app usa la posizione precisa (GPS e servizio di "
            "posizione di Google Play sul telefono) per registrare percorso, "
            "distanza e ritmo. Mentre registra mostra una notifica fissa e "
            "continua anche a schermo spento; quando chiudi l'allenamento il "
            "GPS si spegne. L'app non usa la posizione in nessun altro momento "
            "e non la raccoglie in background. Il percorso viene salvato solo "
            "sul telefono: non va in Health Connect, non va all'assistente e non "
            "viene inviato a nessuno, a meno che sia tu ad accendere l'invio a "
            "intervals.icu o a salvarlo in un file GPX. Mentre ti alleni, una "
            "copia della seduta "
            "in corso (percorso compreso) resta sul telefono per riprenderla "
            "se l'app si chiude; si cancella quando finisci.",
      ),
      (
        'Sensori Bluetooth (battito e bici)',
        "Solo se lo scegli tu, durante la modalità allenamento l'app si "
            "collega via Bluetooth a una fascia cardio, a un orologio che "
            "trasmette il battito o ai sensori della bici (rulli, potenza, "
            "velocità e cadenza), per mostrarteli mentre ti alleni. Alla fine "
            "salva nella sessione battito medio e massimo, potenza e cadenza "
            "medie e, per i grafici, un valore al secondo di battito, potenza, "
            "cadenza e velocità: tutto sul telefono. Nome e indirizzo Bluetooth dei sensori (e "
            "la circonferenza della ruota) restano sul telefono per "
            "ricollegarsi la volta dopo: li cancelli con \"Dimentica\". Il "
            "permesso \"Dispositivi nelle vicinanze\" serve solo a trovare il "
            "sensore, non a sapere dove sei.",
      ),
      (
        'Mappe',
        "Per disegnare la mappa l'app scarica i riquadri della zona "
            "mostrata: da OpenFreeMap (tiles.openfreemap.org, dati © "
            "OpenStreetMap) per le mappe Pulse e Strade, e da Esri "
            "(server.arcgisonline.com) solo se scegli la vista Satellite. Come "
            "per qualsiasi sito, quei servizi ricevono l'indirizzo IP del "
            "telefono e quali riquadri vengono chiesti, quindi possono capire "
            "quale zona stai guardando. Il percorso, i tempi e gli altri dati "
            "dell'allenamento non vengono inviati: la linea viene disegnata sul "
            "telefono. Per i percorsi da seguire l'app scarica in anticipo i "
            "riquadri della fascia attorno alla traccia, per vederli senza "
            "rete: OpenFreeMap riceve quei riquadri, e quindi la zona del "
            "percorso. Restano nella memoria dell'app finché non togli la "
            "mappa o il percorso.",
      ),
      (
        'intervals.icu (facoltativo)',
        "Se colleghi intervals.icu con la tua chiave API, l'app scarica da lì "
            "le tue attività di corsa, bici e nuoto (nome, orari, distanza, "
            "battito, velocità, altitudine, potenza, percorso GPS) e il tuo "
            "FTP di bici e corsa, per le zone di potenza. intervals.icu "
            "le riceve dal tuo orologio (Garmin, Polar, Suunto…) perché lo hai "
            "collegato tu, con le sue condizioni sulla privacy. La chiave resta "
            "cifrata sul telefono. Solo se accendi \"Manda piano e sedute a "
            "intervals.icu\", l'app scrive nel tuo calendario di intervals.icu "
            "le sedute di corsa, bici e nuoto dei prossimi 14 giorni (data, "
            "sport, nome, durata, passi con zone di battito, potenza o passo): niente "
            "nome, foto, misure, feedback o forza. Spegnendolo, le sedute future "
            "mandate dall'app vengono tolte. Con questo invio acceso, ogni "
            "sessione che registri con l'app (forza compresa) va da sola sul "
            "tuo account appena finita; spento, solo se tocchi \"Invia a "
            "intervals.icu\" su quella sessione. Partono orario, sport, nome, "
            "durata, distanza, battito medio e massimo e, se c'è, il percorso "
            "GPS. Allo stesso "
            "modo \"Salva GPX\" crea un file col percorso dove scegli tu. Le "
            "attività scaricate "
            "restano sul telefono ed entrano nel backup; scollegando, vengono "
            "tolte.",
      ),
      (
        'Immagini degli esercizi',
        "Le foto degli esercizi vengono scaricate, quando servono, dalla "
            "raccolta pubblica free-exercise-db su GitHub. GitHub riceve "
            "l'indirizzo IP del telefono e quale immagine viene chiesta, "
            "nient'altro.",
      ),
      (
        'Assistente (facoltativo)',
        "Solo se lo attivi tu, l'assistente invia un riassunto dei tuoi "
            "allenamenti (sessioni delle ultime 4 settimane, feedback, recupero, "
            "zone di battito e FTP della bici, piano dei prossimi 14 giorni) al "
            "servizio che scegli: "
            "Anthropic, OpenAI, Google oppure Ollama sul tuo PC. Nome, foto e "
            "percorsi GPS non vengono mai inviati; età, sesso e peso solo se lo "
            "permetti. Prima di attivarlo puoi vedere esattamente cosa viene "
            "inviato. La chiave API resta cifrata sul telefono. Per i servizi "
            "online valgono le loro condizioni sulla privacy e gli eventuali "
            "costi del tuo abbonamento.",
      ),
      (
        "Assistente nella tua app (facoltativo)",
        "Se colleghi l'app del tuo assistente (Claude, ChatGPT, Gemini o "
            "altre), Avidididadi prepara un messaggio con lo stesso riassunto "
            "descritto sopra e lo passa a quell'app solo quando tocchi Condividi "
            "o Copia. Da quel momento i dati sono nella chat del servizio scelto e "
            "valgono le sue regole: con un abbonamento normale le chat possono "
            "servire ad addestrare il modello, secondo le impostazioni del tuo "
            "account. Le risposte che condividi o incolli nell'app vengono lette "
            "solo se contengono il codice del tuo collegamento, e le modifiche al "
            "piano si applicano solo dopo la tua conferma. Finché non lo colleghi, "
            "Avidididadi non riceve testo da altre app; quando lo scolleghi, il "
            "codice smette di valere.",
      ),
      (
        'Widget sulla schermata home',
        "Se aggiungi il widget, la seduta di oggi e la settimana sono "
            "visibili sulla schermata home, quindi anche a chi vede il telefono "
            "sbloccato.",
      ),
      (
        'Dove restano i dati',
        "Nella cartella privata dell'app sul telefono, a cui le altre app "
            "non possono accedere. Non finiscono nel backup automatico di "
            "Android su Google né nel trasferimento a un nuovo telefono: per "
            "spostarli usa il backup dell'app.",
      ),
      (
        'Backup',
        "Il file di backup che crei contiene tutti i dati dell'app, "
            "compresi dati sulla salute, foto e percorsi GPS (non la chiave "
            "API). Lo salvi dove scegli tu: tienilo in un posto sicuro e non "
            "condividerlo. Se accendi il backup automatico, l'app scrive lo "
            "stesso file da sola nella cartella che hai scelto e tiene gli "
            "ultimi 5; le altre app che leggono quella cartella possono "
            "vederlo.",
      ),
      (
        'Permessi del telefono',
        "Health Connect (lettura dei dati elencati sopra), posizione precisa "
            "(solo durante corsa, camminata e bici), dispositivi nelle "
            "vicinanze (solo per il sensore del battito), internet (mappe, "
            "immagini, assistente), notifiche (solo quella dell'allenamento in "
            "corso, con tempo e dati, visibile anche a schermo bloccato). Puoi "
            "negare ognuno di questi permessi: l'app continua a funzionare senza "
            "la parte che ne ha bisogno.",
      ),
      (
        'Come revocare o cancellare',
        "Health Connect: Impostazioni di Health Connect → Permessi delle "
            "app → Avidididadi, oppure dal Profilo con \"Rivedi permessi\". "
            "Posizione e dispositivi nelle vicinanze: Impostazioni di Android → "
            "App → Avidididadi → Permessi. Sensore del battito: \"Dimentica\" "
            "nel foglio del battito, durante l'allenamento. "
            "Assistente: disattivalo e cancella la chiave nella pagina Coach. "
            "Per cancellare tutto: Impostazioni di Android → App → Avidididadi → "
            "Memoria → Cancella dati, oppure disinstalla l'app. I dati in Health "
            "Connect restano lì, perché sono delle app che li hanno scritti.",
      ),
      (
        'Modifiche',
        "Se questa informativa cambia, all'apertura l'app te lo dice e ti "
            "chiede di accettarla di nuovo.",
      ),
    ],
  );
}

/// Termini e condizioni d'uso.
class TerminiScreen extends StatelessWidget {
  const TerminiScreen({super.key});

  @override
  Widget build(BuildContext context) => const PaginaTesto(
    titolo: 'Termini e condizioni',
    sezioni: [
      (
        'Cos\'è Avidididadi',
        "Un'app personale per pianificare e seguire allenamenti di forza, "
            "corsa, nuoto, bici e mobilità, e per vedere storico e progressi. "
            "Usandola accetti questi termini e l'informativa sulla privacy.",
      ),
      (
        'Non è un consiglio medico',
        "Piani, carichi, zone di frequenza cardiaca, valutazione del "
            "recupero e risposte dell'assistente sono stime automatiche a scopo "
            "informativo. Non sono una diagnosi né un parere medico e non "
            "sostituiscono medico, fisioterapista o allenatore. Prima di "
            "iniziare un programma di allenamento, soprattutto se hai problemi "
            "di salute, sei in gravidanza o non ti alleni da tempo, chiedi a un "
            "medico. Se senti dolore, vertigini, fiato corto anomalo o dolore al "
            "petto, fermati e cerca assistenza.",
      ),
      (
        'Allenati in sicurezza',
        "Ti alleni sotto la tua responsabilità: scegli carichi e ritmi "
            "adatti a te, usa attrezzatura in buono stato e rispetta il codice "
            "della strada. Durante corsa, camminata e bici non guardare il telefono mentre "
            "ti muovi nel traffico.",
      ),
      (
        'Precisione dei dati',
        "GPS, distanze, ritmo, passi e i dati letti da Health Connect "
            "possono contenere errori (per esempio tra palazzi alti o sotto gli "
            "alberi). Calcoli e grafici dipendono da questi dati e dalla loro "
            "completezza.",
      ),
      (
        'Servizi di terzi',
        "Alcune funzioni usano servizi di altri: Health Connect e le app che "
            "vi scrivono (es. Garmin Connect), OpenFreeMap e OpenStreetMap per le "
            "mappe, GitHub per le immagini degli esercizi e, se lo attivi, il "
            "servizio di intelligenza artificiale che scegli. Questi servizi "
            "hanno condizioni proprie, possono cambiare o non essere "
            "disponibili. Chiave API e costi del servizio di intelligenza "
            "artificiale sono a tuo carico.",
      ),
      (
        'I tuoi dati',
        "I dati restano sul tuo telefono e ne sei responsabile tu: fai "
            "backup periodici e conserva il file in un posto sicuro. "
            "Disinstallando l'app senza backup i dati vanno persi.",
      ),
      (
        'Nessuna garanzia',
        "L'app è fornita così com'è, senza garanzie di funzionamento "
            "continuo o privo di errori. Nei limiti consentiti dalla legge, chi "
            "l'ha sviluppata non risponde di danni derivanti dall'uso dell'app, "
            "da dati non corretti o dalla perdita di dati.",
      ),
      (
        'Modifiche',
        "Questi termini possono essere aggiornati. Se cambiano, all'apertura "
            "l'app te lo dice e ti chiede di accettarli di nuovo prima di "
            "continuare.",
      ),
    ],
  );
}
