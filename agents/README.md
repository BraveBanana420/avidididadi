# /orchestra – guida veloce

`/orchestra` fa lavorare dei **modelli gratuiti** (i "worker", via OpenCode e OpenRouter) su piccoli pezzi di una richiesta. **Claude Code** fa da capo: divide il lavoro, controlla, rimonta e apre una **pull request verso `staging`**. La PR la approvi sempre tu.

## Cosa serve (una volta sola)

- **OpenCode** (`npm i -g opencode-ai`), **Node**, **Flutter** e **GitHub CLI** con il permesso dei Project (`gh auth refresh -s project`).
- La chiave di OpenRouter nella variabile d'ambiente `OPENROUTER_API_KEY`: **mai** in un file della repo. Conviene darle un tetto di spesa di **0 $** (da openrouter.ai/settings/keys): i worker usano solo modelli `:free`, così non possono spendere niente.
- Richieste gratuite: **50 al giorno**, **1000** con almeno 10 $ di crediti sul conto.

## Come si usa

In Claude Code scrivi `/orchestra <la richiesta in parole semplici>`. Poi:

1. Claude legge il codice e prepara il **piano** (micro-task, modello per ognuno, richieste stimate) e una **issue** su GitHub.
2. **Tu approvi** il piano (o chiedi cambi).
3. I worker lavorano, al massimo 2-3 insieme. Ogni task viene controllato (`dart format`, `flutter analyze`, `flutter test`); se fallisce si riprova una volta con il modello di riserva.
4. Claude unisce i task in `feature/<nome>`, rifà tutti i controlli e l'APK di debug, e apre la **PR**. **Tu la rivedi e la unisci.**

## Animazioni degli esercizi

Chiedi per esempio `/orchestra fai le animazioni di affondi e curl con manubri`. Le fa **Claude**, non i worker, con `agents/animazione.mjs` e due modelli **a pagamento** su OpenRouter: Nano Banana 2.1 per l'immagine di partenza (~0,04 $, non serve se l'esercizio parte in piedi) e Seedance 2.0 Mini per il video (~0,14 $). Claude guarda ogni immagine e ogni video prima di andare avanti, poi crea il WebP (il più fluido che sta in 300 KB, 400 KB con attrezzi) e lo mette nell'app con la sua fonte in `docs/animazioni/FONTI.md`.

- Serve una **seconda chiave** solo per questi modelli, `OPENROUTER_VIDEO_KEY`, con un **tetto di spesa** (per esempio 3 $): il piano mostra la spesa prevista e l'aiutante si ferma se il credito non basta. `node agents/animazione.mjs credito` dice quanto resta.
- Serve **ffmpeg** (`winget install Gyan.FFmpeg`).
- Le regole delle animazioni (avatar, vista da 3/4, fondo, peso, licenza) sono in `docs/animazioni/README.md`.
- Vista, posa e movimento di ogni esercizio sono **fissi** in `docs/animazioni/richieste.json`: per un esercizio nuovo il piano propone la richiesta e tu la approvi insieme al piano. È la stessa ricetta che usano i volontari, così le animazioni escono tutte uguali.

## Seguire una corsa

- **Issue** con etichetta `orchestra`: piano, caselle dei task, un commento per ogni fase.
- **Project** "Orchestra Avidididadi" su GitHub: colonne Da approvare → In corso → Da revisionare → Fatto.
- **Dashboard sul PC**: `node agents/dashboard/server.js`, poi http://127.0.0.1:4747 (sola lettura, si aggiorna ogni 10 s).
- **Dal telefono**: `tailscale serve --bg --yes --http 4747 http://127.0.0.1:4747` (solo dentro la tua rete Tailscale, mai Funnel), oppure il pannello su claude.ai, aggiornato da Claude: l'indirizzo sta in `agents/locale.json`, solo sul PC.

## File

| File | A cosa serve |
|---|---|
| `.claude/commands/orchestra.md` | Le istruzioni che segue Claude |
| `agents/orchestra.mjs` | L'aiutante: `node agents/orchestra.mjs aiuto` elenca i comandi |
| `agents/animazione.mjs` | L'aiutante delle animazioni: `node agents/animazione.mjs` elenca i comandi |
| `agents/models.json` | Modelli gratuiti, punteggi per tipo di compito e riserve |
| `agents/opencode-worker.json` | Cosa possono fare i worker (permessi) |
| `agents/github.json` | Project e colonne |
| `agents/status.json`, `agents/runs/` | Stato e storico delle corse: **solo sul PC** (in `.gitignore`) |

**Cambiare modello**: in `agents/models.json` modifica i punteggi (1-10) o aggiungi un modello con il suo ID `:free`. `node agents/orchestra.mjs modelli` controlla che siano ancora gratuiti.

## Sicurezza

- Ogni task lavora in un **clone separato** fuori dal progetto (`../<progetto>_wt/`), con un codice di progetto OpenCode tutto suo; l'aiutante imposta anche `PWD` su quella cartella. Con i git worktree, o lasciando `PWD` sulla cartella principale, OpenCode lavorerebbe nella cartella principale.
- Un **guardiano** ferma la corsa se la cartella principale cambia mentre lavorano i worker.
- I worker non possono uscire dal clone, usare internet, fare push o usare GitHub, e non toccano firma, chiavi, `build.gradle`, manifest, `.github/`, `pubspec.*`, `agents/`, `.claude/`. Dopo ogni task l'aiutante controlla i file cambiati.
- Ai worker va solo codice della repo (pubblica), mai dati personali.

## Problemi comuni

| Cosa vedi | Cosa fare |
|---|---|
| `429` (modello sovraccarico) | L'aiutante aspetta 60 s e riprova, poi passa alla riserva. Se capita spesso, abbassa il punteggio di quel modello |
| "richieste gratuite di oggi finite" | Si riprende il giorno dopo con `node agents/orchestra.mjs lancia` |
| `ALLARME: la cartella principale…` | Guarda `git status` e annulla le modifiche che non sono tue prima di ripartire |
| Un task resta `fallito` | Il motivo è in `agents/status.json`; Claude lo sistema o ti chiede cosa fare |
| La dashboard non si apre | Avvia il server; se la porta 4747 è occupata è già acceso |
| Errore 401 da OpenRouter | Chiave sbagliata o scaduta: creane una nuova e riapri VS Code |
| "Sulla chiave dei video restano…" | Alza il tetto della chiave dei video su openrouter.ai/settings/keys, o fai meno animazioni |
| Un'animazione supera il limite di peso | `converti` prova già fino a 15 fps: rigenera il video con un movimento più corto |
| Fermare tutto | `node agents/orchestra.mjs annulla` |
