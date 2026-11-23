# Note e appunti – Avidididadi

## Da fare / da ricordare

- [ ] **Animazioni degli esercizi per lato** (dal 23/11/2026). Analisi
  completa, regola e richieste pronte in
  [docs/animazioni/LATI.md](docs/animazioni/LATI.md). Gli esercizi
  con `"lati": true` in `assets/esercizi.json` (32: 13 di mobilità, 19 di
  forza) in allenamento si dividono già in "Lato destro" e "Lato sinistro",
  ognuno con il suo tempo (`Blocco.lato`). Restano:
  - generare le animazioni del lato destro, partendo dai 13 di mobilità
    (serve la chiave OpenRouter, dal PC con Remote Control);
  - nel blocco del lato sinistro mostrare la stessa animazione specchiata;
  - forse qualche secondo di pausa per cambiare lato tra i due blocchi (oggi
    il lato sinistro parte subito, annunciato dalla voce).
  - aggiungere "poi cambia lato" alle istruzioni del corridore
    (`Runners_Stretch`) nelle tre lingue.

- [x] **Progressione: scegliere tra durata e intensità.** (fatto il 23/10/2026:
  Crea piano → "Quando le sedute ti sembrano facili", per ogni sport)
  Oggi, dopo un feedback "facile", corsa, nuoto e bici allungano le sedute
  successive del 5% (fino a +15%). Serve un'opzione per scegliere *come*
  progredire:
  - **Durata**: sedute più lunghe del 5% (come adesso);
  - **Intensità**: stessa durata, ma sforzo maggiore (per esempio più
    ripetute o più minuti in zona 3–4, recuperi più brevi, passo un po' più
    veloce). Utile quando il tempo a disposizione non aumenta: non è detto
    di avere sempre il 5% di tempo in più, ma a parità di tempo lo sforzo
    cresce comunque.
  - Magari una scelta per sport, o anche "automatico" (prima l'intensità, poi
    la durata quando c'è tempo).

- [x] **Configurare Ollama con gpt-oss** (quando il download è finito).
  Sul PC: avviare Ollama con `OLLAMA_HOST=0.0.0.0` e trovare l'IP con
  `ipconfig`. Nell'app: Assistente → Impostazioni → Ollama, indirizzo
  `http://<IP-del-PC>:11434`, modello `gpt-oss:20b` (il nome esatto lo dà
  `ollama list`), poi "Prova connessione".
  Fuori casa (24/10/2026): Tailscale su PC e telefono, stesso account.
  Indirizzo Tailscale del PC: in NOTE_PRIVATE.md (solo sul PC, non in git).
  Il PC deve restare acceso e non andare in sospensione.

- [x] **Identificativo e firma** (23/10/2026): l'app ora è
  `it.avidididadi.app`, firmata con la chiave
  indicata in NOTE_PRIVATE.md (solo sul PC, non in git).
  Backup ripristinato nella nuova app e vecchia app disinstallata.
  Permessi di Health Connect ridati e cartella della firma copiata al sicuro.

- [ ] **Gemini da riprendere** (23/10/2026): la chiave funziona (l'elenco dei
  modelli arriva) e il modello giusto è `gemini-3.8-flash` (Google dice che
  `gemini-2.5-flash` non è più disponibile per le chiavi nuove). Ma l'invio del
  messaggio si interrompe sul telefono con "Software caused connection abort".
  Da provare: misurare dopo quanti secondi cade, provare la risposta in
  streaming (`streamGenerateContent?alt=sse`) o la nuova Interactions API
  consigliata da Google.

- [x] **Percorsi GPS** (24/10/2026): mappa MapLibre + OpenFreeMap (gratis, senza
  chiave) con i colori del tema e il percorso al neon. Corsa e bici registrano
  il GPS durante la modalità allenamento; le sessioni di Health Connect
  mostrano il percorso se l'app d'origine lo ha condiviso.
- [ ] **Da verificare**: se Garmin Connect scrive il percorso in Health Connect.
  Se no: c'è il pulsante tondo "GPX" nella sessione (fatto il 24/10/2026) per
  caricare il file esportato da connect.garmin.com.
- [ ] **Più avanti**: mappa satellite/terreno selezionabile (serve un servizio
  con chiave, es. MapTiler); "corsa libera" senza seduta in programma; APK più
  leggero con `--split-per-abi` (con la mappa è passato a ~88 MB).
- [x] **Revisione di sicurezza** (24/10/2026): il pulsante ▶ del widget non
  può più essere usato da altre app; Ollama in http solo nella rete di casa;
  niente backup automatico di Android (per cambiare telefono: backup dell'app);
  GPX con limite di 20 MB e lettura robusta.
- [x] **Coach nella tua app** (24/10/2026): Coach → Impostazioni → "Usa il tuo
  abbonamento". Si manda il messaggio con Condividi, si riporta la risposta
  con Condividi → Avidididadi (o "Incolla la risposta"). Codice di
  collegamento: le risposte senza codice giusto vengono ignorate. Scollega
  dalla pagina Coach per tornare a Ollama.
- [ ] **Da provare**: con Claude Pro, chiedere un piano nuovo di 4 settimane e
  applicarlo dal pannello Coach.
- [x] **Invio a intervals.icu** (30/10/2026): Dati e collegamenti → "Manda il
  piano a intervals.icu". Corsa, bici e nuoto dei prossimi 14 giorni, con
  external_id `avd-<data>-<sport>`; le cambiate si cancellano (per id) e si
  rimandano. Forza esclusa.
- [ ] **Da verificare dal vivo**: che le sedute arrivino su Garmin Connect
  (intervals.icu → Impostazioni → Garmin → "Upload planned workouts"), le
  pause del nuoto con `intensity=rest`, il passo `1:56/100m Pace`, e se
  `upsert=true` funziona con la chiave API (senza app OAuth).
- [ ] **Invia allo smartwatch, resto** (ripreso in parte il 30/10/2026).
  Già verificato:
  - intervals.icu: API con chiave (Basic, utente `API_KEY`, athlete `0`),
    `POST /api/v1/athlete/0/events/bulk?upsert=true` con `external_id`,
    `PUT .../events/bulk-delete`; testo allenamento in `description`
    (`- 50mtr 2:50/100m Pace`, `8x`, `Press lap`; niente ripetizioni annidate).
    Da provare dal vivo: `Pool length: 25m`, `intensity=rest`.
  - Nuoto: stile, esercizi e attrezzi (tavoletta, panino) non esistono in
    intervals.icu né nell'invio a Garmin (richiesta aperta sul forum).
  - Forza: intervals.icu non ha serie/ripetizioni/pesi. Alternativa:
    script Python con python-garminconnect (fuori dall'app).
  - OAuth intervals.icu: registrazione a mano e client secret (servirebbe un
    server): meglio la chiave API.
  - File FIT: libreria `fit_tool` (Stages Cycling, BSD-3, ferma da 3 anni);
    il FIT ha stile e attrezzo del nuoto; l'app Garmin Connect non lo importa,
    si copia sull'orologio via USB (GARMIN/NewFiles).
  - Piano proposto: modello StructuredWorkout indipendente, WorkoutExporter
    (prima IntervalsIcuExporter), collegamento guidato nel browser,
    sincronizzazione con coda offline, export FIT, script forza.
- [x] **intervals.icu** (30/10/2026): Profilo → Dati e collegamenti → incolla
  la chiave API. Corsa, bici e nuoto arrivano da lì (nome vero, rulli,
  percorso, altitudine, pendenza, potenza) al posto di Health Connect.
- [ ] **Da verificare con la chiave vera**: nomi dei dati nel tempo
  (`heartrate`, `velocity_smooth`, `altitude`, `distance`, `watts`,
  `cadence`, presi dal forum) e formato di `/activity/{id}/map` (`latlngs`).
  Se un grafico non compare, controllare la risposta di `streams.json`.
- [ ] **Da installare sul telefono**: la versione con intervals.icu, mappa a
  livelli e grafici (telefono scollegato il 30/10).

## In sospeso dal 13/11/2026: rendere l'app più facile per tutti

Partito da una recensione dell'app (voto 7/10: ottima per chi ha già un
orologio, difficile da ottenere e da iniziare per gli altri).

Fatto (su `staging`, da provare sul telefono e nei 4 temi):
- [x] **"Inizia oggi"** al primo avvio: scelti gli sport, piano pronto con
  3 sedute da 30 minuti (lun-mer-ven, weekend libero), livello principiante,
  senza seduta lunga; la prima seduta è anticipata a oggi.
- [x] **Seduta lunga** di corsa e bici: si spegne da Prepara le sedute →
  "come crescere".
- [x] **Backup proposto in Oggi**, con "Non ora" (torna dopo 14 giorni, poi
  30) e avviso se l'ultimo backup non è riuscito.
- [x] **Motivazione in Oggi**: settimane di fila, traguardi, record.
- [x] **Modo semplice** (Profilo → Funzioni avanzate): nasconde "Le mie
  zone", le icone dei sensori in allenamento, intervals.icu e l'import da file.

- [x] **Riepilogo della sessione** (14/11): accanto all'icona solo il nome
  della seduta (anche nel Condividi); la matita apre una pagina sola (nome,
  indoor, dati, esercizi della forza, cestino, "Torna ai dati originali");
  in basso "Grafici" e il Condividi tondo.
- [x] **Previsto e fatto** (14/11): corsa strutturata in un grafico solo, in
  zone (`intensita.dart`: battito dove l'obiettivo è una zona, passo dove è
  un passo, con la soglia stimata dalla corsa più veloce di almeno 20 minuti
  degli ultimi sei mesi); bici in un grafico solo (fasce e linea dei watt,
  le barre restano solo senza i watt al secondo). Da guardare con sedute
  vere: i nomi dei tratti devono combaciare con i passi in programma.
- [x] **Grafica leggibile** (14-15/11, ramo `ccr-ab3c04e0-ed0jix` unito in
  `staging` il 15/11): colori degli sport più scuri sul fondo chiaro, assi
  dei grafici su numeri tondi (`assi.dart`), mappa a tema più contrastata,
  "+" di Oggi che si sposta scorrendo, anello e barra animati, pagina "Dati"
  della bici all'aperto con numeri grandi (griglia con watt o cadenza),
  niente tratti di zero secondi. La prova "rosso e oro" è stata annullata.
  `tool/schermate` disegna le schermate nei 4 temi senza telefono. Da
  guardare sul telefono nei 4 temi.

- [x] **Rifiniture grafiche** (15/11): "Prepara le sedute" con titoli corti;
  icone tutte arrotondate (a contorno solo dove dice uno stato); cifre a
  larghezza fissa (`cifreFisse`); `EntrataMorbida` per numeri ed esercizi;
  2 px tra i pezzi delle colonne; `tool/schermate` disegna anche la bici al
  chiuso col rullo (`31_bici_rullo.png`). Da guardare sul telefono.
- [x] **Bici al chiuso senza fascia** (15/11): il riquadro del battito
  compare solo se il battito arriva; senza, la potenza prende tutta la riga
  (la fascia si collega dal cuore in alto o da "I miei sensori").

Da riprendere, forse:
- [ ] **Provare il primo avvio** su un telefono pulito (o dopo un backup):
  "Inizia oggi", il riquadro del backup, le righe di motivazione.
- [ ] **Modo semplice, resto**: le scritte "zona 2" nelle sedute, i grafici e
  la pagina Progressi non sono stati toccati. In modo semplice la fascia
  cardio non si può collegare finché non si accendono le funzioni avanzate:
  decidere se va bene.
- [x] **"I miei sensori" nel Profilo** (fatto il 13/11): voce sempre
  visibile, anche in modo semplice, che apre le finestre di battito e
  sensori della bici. Collegando un sensore si accendono le funzioni
  avanzate, con un avviso e il tasto Annulla. Informativa aggiornata e
  termini da riaccettare (`versioneTermini` 2026-11-13.1).
  Da provare con la fascia e con il rullo veri.
- [ ] **Chi parte con "Inizia oggi" salta la pagina sull'orologio**: forse
  riproporla dopo, in Oggi.
- [ ] **Chi sceglie le domande complete** ha ancora lo schema con il sabato
  (lun-mer-sab) e la seduta lunga accesa: decidere se allinearlo.
- [ ] **Salvataggio su Google Drive**: la cartella del backup automatico
  resta sul telefono (Drive di solito non compare nella scelta della
  cartella: da verificare). Un vero backup su Drive chiede l'accesso con
  Google: da fare insieme al Play Store.
- [ ] **F-Droid e IzzyOnDroid** (rimandati il 18/11/2026): il lavoro è nei
  commit `7d9ca5e` (cartella `fastlane/` con testi e screenshot in JPG) e
  `b77214f` (variante foss: `tool/prepara_foss.py` e lavoro `foss` nella CI),
  tolti dopo; si recuperano con `git revert` del commit che li ha tolti.
  IzzyOnDroid prende i nostri APK dalle Releases (anche con il GPS di
  Google), ma il limite indicativo è 30 MB per APK e non ama le app per le
  piattaforme AI; F-Droid compila da sé e vuole la variante foss.
- [ ] **Play Store** (se si decide di pubblicare): account sviluppatore
  (25 $), informativa privacy su una pagina web (GitHub Pages, dal testo di
  `privacy_screen.dart`), modulo "Sicurezza dei dati", dichiarazioni per
  Health Connect e per il GPS a schermo spento. Il DPO non serve: i dati
  restano sul telefono (parere non legale).
- [ ] **Inglese**: per ultimo, i testi sono sparsi in tutta l'app.
- Scartati per ora: parte social e classifiche, app per l'orologio, iOS,
  coach senza chiave (servirebbe un server), Strava diretto (basta
  intervals.icu), cambio del nome.

## Appunti

