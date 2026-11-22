---
description: Scompone una richiesta in micro-task, li fa fare a worker gratuiti (OpenCode + OpenRouter) e apre una pull request verso staging
argument-hint: <la richiesta, in parole semplici>
---

# /orchestra

Richiesta dell'utente: **$ARGUMENTS**

Sei l'**orchestratore**: scomponi, fai lavorare i worker, controlli, rimonti e apri la PR. Le parti meccaniche le fa l'aiutante `node agents/orchestra.mjs <comando>` (`aiuto` li elenca): ogni comando aggiorna **`agents/status.json`**, la **issue** della corsa e il **Project**, così il pannello di controllo è sempre aggiornato (punto h). Parla all'utente in italiano semplice, fase per fase.

## Regole fisse

- La PR va **sempre verso `staging`**. **Mai** unire niente in `main` o in `staging` da solo: la PR la approva l'utente.
- Ai worker (modelli esterni) va **solo codice della repo**, che è pubblica: mai `NOTE_PRIVATE.md`, CSV o backup dell'utente, chiavi, nomi, email, numeri di serie, indirizzi IP.
- I worker **non toccano**: firma e chiavi (`key.properties*`, `*.jks`, `*.keystore`), `build.gradle*`, `AndroidManifest.xml`, `.github/`, `tool/git-hooks/`, `pubspec.*`, `agents/`, `.claude/`, `CLAUDE.md`, `opencode*.json`. Se servono, quel task lo fai tu (`"claude": true`), sempre dopo l'approvazione.
- Massimo **3 worker insieme** (di solito 2).
- **429** (modello sovraccarico): l'aiutante aspetta 60 s e riprova una volta, poi passa al modello di riserva. Non insistere oltre.

## 0. Preparazione

1. Su `staging`, con `git status` pulito: `git fetch` e `git pull --ff-only`. Se ci sono modifiche in sospeso, chiedi all'utente prima di andare avanti.
2. `node agents/orchestra.mjs riordina` (chiude le issue delle corse già unite).
3. `node agents/orchestra.mjs quota` e `node agents/orchestra.mjs modelli`. Se restano meno di 10 richieste gratuite, dillo e chiedi se rimandare. Se un modello non è più gratuito, o ce n'è uno nuovo mai valutato, segnalalo (ma non cambiare `models.json` senza chiedere).

## a. Piano

1. Leggi la richiesta e il codice interessato tu stesso (Read, Grep): non costa richieste OpenRouter. Rispetta `CLAUDE.md`.
2. Scegli un nome breve con i trattini (es. `commenti-modelli`), poi: `node agents/orchestra.mjs nuova "<richiesta>" <nome>`. L'aiutante stampa l'id della corsa (`AAAA-MM-GG_HHMM`).
3. Scrivi `agents/runs/<id>/piano.json`:

```json
{
  "titolo_pr": "Titolo chiaro in italiano",
  "tasks": [
    {
      "id": "t1",
      "titolo": "Commenti /// in lib/models.dart",
      "tipo": "documentazione",
      "obiettivo": "Cosa deve ottenere, in 1-2 frasi",
      "file": ["lib/models.dart"],
      "fatto": "Criterio verificabile: quando è finito",
      "istruzioni": "Tutto il contesto che serve al worker: vede solo questo testo e i file della repo",
      "modello": "particle-ai/particle-1:free",
      "riserva": "nvidia/nemotron-3-ultra-550b-a55b:free"
    }
  ]
}
```

   - **Micro-task**: 1–3 file, meno di ~150 righe cambiate, indipendenti, **file diversi tra loro** quando possibile. Un file in comune è un rischio di conflitto: meglio un task solo.
   - **`tipo`** è una delle chiavi di `tipi_compito` in `agents/models.json`. **`modello`** è quello con il punteggio più alto per quel tipo (a parità vince l'affidabilità più alta); **`riserva`** è il secondo.
   - **`file`**: percorsi esatti, oppure una cartella che finisce con `/`. I file generati da `flutter gen-l10n` seguono gli ARB da soli.
   - **Immagini, GIF, animazioni**: `"manuale": true`, con `"prompt_dreamina"` (il testo da incollare in Dreamina, che rispetta `docs/animazioni`) e `"destinazione"` (dove mettere il file). Un worker poi può collegarlo all'app in un altro task.
   - **Task delicati** (file vietati ai worker, ragionamento su tanti file, sicurezza e privacy): `"claude": true` con `"perche_claude"`.
4. `node agents/orchestra.mjs piano`: controlla il piano, scrive `piano.md` e stima le richieste. Se segnala qualcosa "da correggere", correggi e rilancia.
5. `node agents/orchestra.mjs issue`: crea la issue (etichetta `orchestra`) con piano e checklist, e la mette in "Da approvare" nel Project.

## b. Approvazione

Mostra all'utente: la tabella dei task (cosa, chi lo fa, file), la **stima delle richieste rispetto a quelle rimaste oggi**, gli avvisi e il link della issue. Se la stima supera le richieste rimaste, o ne usa più del 70%, **dillo chiaramente** e proponi di dividere il lavoro in più giorni. **Aspetta l'ok.** Se l'utente chiede cambi: modifica `piano.json`, poi `piano` e `issue --aggiorna`, e mostra di nuovo.

Dopo l'ok: `node agents/orchestra.mjs fase worker "✅ Piano approvato"`.

**Task a mano (Dreamina)**: dai all'utente il prompt e la cartella di destinazione, e aspetta che ti dica di aver messo il file. Poi `prepara <id>`, copia il file nel worktree e `completa <id> utente`.

## c. Worker

Ogni task lavora in un **git worktree**: una seconda cartella collegata alla stessa repo, con un suo branch (`orchestra/<id>/<task>`), fuori dal progetto (`..\allenamenti_app_wt\`). Così i worker lavorano insieme senza pestarsi i piedi, e la cartella dell'utente non viene toccata.

- Lancia `node agents/orchestra.mjs lancia --paralleli 2` **in background** e aspetta l'avviso di fine (niente controlli ogni pochi secondi). Per ogni task l'aiutante: crea il worktree, avvia `opencode run --agent worker` con il modello scelto e con permessi ristretti (`agents/opencode-worker.json`), conta le richieste e gestisce i 429.
- I task `"claude": true` li fai tu nel frattempo: `node agents/orchestra.mjs prepara <id>` (stampa la cartella), lavori lì dentro, poi `node agents/orchestra.mjs completa <id>`.

## d. Controlli

`lancia` controlla ogni task appena finito: file toccati (solo quelli del task; quelli vietati fanno fallire il task, quelli fuori dal task vengono annullati), `dart format`, `flutter analyze`, `flutter test`. Se va bene fa il commit nel branch del task. Se no, **riprova una volta con il modello di riserva**, passandogli il motivo dell'errore.

Per un task ancora `fallito`: guarda il motivo in `status.json` e il lavoro rimasto nel worktree. Se è una correzione piccola, sistemala tu e `completa <id>`; se no spiega all'utente cosa non va e chiedi se farlo tu o toglierlo. Se vuoi riprovare con i worker: `lancia --solo <id>`.

## e. Unione

1. `node agents/orchestra.mjs unisci`: crea `feature/<nome>` (worktree `unione`) e ci unisce i task fatti. Se c'è un **conflitto**, risolvilo in quella cartella, fai commit e rilancia `unisci`.
2. `node agents/orchestra.mjs verifica` **in background** (circa 5 minuti): formattazione, testi generati, `flutter analyze`, `flutter test`, `flutter build apk --debug`. Se qualcosa fallisce (dettagli in `agents/runs/<id>/verifica.log`), correggi nel worktree `unione`, fai commit e rilancia `verifica`.
3. Rileggi il diff completo (`git diff <base_commit>..HEAD` nel worktree `unione`), come farebbe un revisore: deve rispettare `CLAUDE.md` (testi in tutti e due gli ARB, niente colori fissi, nomi e commenti in italiano, niente dati personali).

## f. Pull request

1. Scrivi `agents/runs/<id>/pr-note.md`: **"Cosa devi controllare tu"**, con punti concreti (quali schermate aprire, quali casi provare, le 4 combinazioni di tema se cambia la grafica, cosa è stato fatto da te e non dai worker).
2. `node agents/orchestra.mjs pr`: push del branch e PR verso `staging` con tabella (task, chi l'ha fatto, tentativi, richieste), note e `Closes #<issue>`. Sposta la issue in "Da revisionare".
3. **Non unire la PR.**

## g. Pulizia e log

`node agents/orchestra.mjs pulisci`: toglie i worktree e i branch dei task (il branch `feature/…` resta per la PR), scrive `agents/runs/<id>/log.md` (task, modello, esito, richieste usate) e chiude la corsa.

## h. Pannello di controllo (sempre)

I comandi dell'aiutante aggiornano già `status.json`, le caselle e i commenti della issue e la colonna del Project. Per gli eventi in più usa:
- `fase <nome> "commento"` a ogni cambio di fase che fai tu;
- `errore "testo"` per qualsiasi problema (lo vede anche il telefono);
- `commenta "testo"` per note utili all'utente.

Se l'utente vuole fermare tutto: `node agents/orchestra.mjs annulla`.

## Messaggio finale all'utente

Link alla PR e alla issue, tabella breve (task, chi, esito), richieste usate e quante ne restano oggi, e cosa deve controllare. Usa parole semplici.
