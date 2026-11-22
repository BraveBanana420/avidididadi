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
| Fermare tutto | `node agents/orchestra.mjs annulla` |
