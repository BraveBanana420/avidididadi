# Note e appunti – Avidididadi

## Da fare / da ricordare

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

## Appunti

