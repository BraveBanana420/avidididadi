# CLAUDE.md – Avidididadi

Guida permanente per lavorare su questo progetto. Rispondi all'utente in **italiano**, con parole semplici.

## 1. Panoramica

**Avidididadi** è un'app Android personale (Flutter) per pianificare e seguire gli allenamenti di forza, corsa, nuoto, bici, mobilità e arrampicata. Tutti i dati restano sul telefono: niente server, account o pubblicità.

Le funzioni sono elencate in `README.md`.

## 2. Stack tecnico

- **Flutter 3.47** (stable), **Dart 3.13**, solo **Android** (non c'è la cartella `ios/`).
- `applicationId`: `it.avidididadi.app`. `minSdk` 26 (per Health Connect).
- **Codice nativo Kotlin** ([android/app/src/main/kotlin/it/avidididadi/app/](android/app/src/main/kotlin/it/avidididadi/app/)):
  - `MainActivity.kt`: canale `avidididadi/avvio` per titoli e dettagli delle sessioni Health Connect, percorsi, condivisione, schermo acceso, bip, vibrazione e voce, notifica dell'allenamento, cartella del backup automatico, permessi Bluetooth e notifiche, widget;
  - `WidgetOggi.kt`: widget per la schermata home.
- **Nessuna libreria di state management**: un solo `AppState` (`ChangeNotifier`). I dati sono CSV nella cartella privata dell'app.

## 3. Struttura

- `lib/screens/`: una schermata o un foglio per file (`*_screen.dart`, `*_sheet.dart`).
- Avvisi in basso: usare `avviso(...)` (`lib/avviso.dart`), non `SnackBar`.
- `NOTE.md`: appunti e lavori in sospeso (pubblico). `CHANGELOG.md`: novità di ogni versione distribuita.
- **Dati dell'app**: CSV nella cartella privata. I nuovi file devono rispettare `^[a-z0-9_]+\.csv$`, altrimenti non entrano nel backup. Le colonne nuove si aggiungono **in fondo**, e le righe vecchie devono restare leggibili.

## 4. Comandi

```sh
flutter pub get
dart format lib test                        # formattazione
flutter analyze                             # deve dare "No issues found!"
flutter test                                # tutti i test devono passare
flutter build apk --release --split-per-abi --dart-define=COMMIT=$(git rev-parse --short HEAD) # APK firmato, arm64 ~32 MB
adb -s <seriale> install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

- **Firma**: `android/key.properties` (fuori da git, modello in `key.properties.example`). Un APK di debug ha un'altra firma e non si installa sopra quello di rilascio.
- **Telefono** (numero di serie in `NOTE_PRIVATE.md`, qui `<seriale>`): installa **senza avviare** l'app; niente tocchi né screenshot se non li chiede l'utente. In Git Bash, per i percorsi dentro `adb shell` usa `MSYS_NO_PATHCONV=1`.
- **Senza cavo**: Debug wireless + Tailscale (telefono su un Wi-Fi qualsiasi). `adb connect <IP Tailscale del telefono>:<porta>`: l'IP è in `NOTE_PRIVATE.md`, la porta la comunica l'utente (cambia quando il Debug wireless si riaccende). Poi usa `adb -s <ip>:<porta>` al posto del numero di serie.
- **Versione** (`version:` in `pubspec.yaml`, `MAJOR.MINOR.PATCH+build`): **prima della pubblicazione il primo numero resta 0**. La **1.0.0** arriva solo quando l'utente pubblica l'app.
  - **Resta ferma su `staging`**, anche a ogni installazione e negli APK dei tester: le prove si riconoscono dal **commit**, che l'APK mostra nel Profilo ("versione 0.1.0 (32) · prova a1b2c3d") grazie a `--dart-define=COMMIT=...` nel comando di build.
  - Si alza **solo quando l'utente decide di portare `staging` su `main`**: su `staging`, subito prima dell'unione, una volta sola per tutte le modifiche dall'ultima unione:
    - solo correzioni o piccoli ritocchi → PATCH (0.1.0 → 0.1.1);
    - funzioni nuove → MINOR (0.1.1 → 0.2.0);
    - prima di 1.0 anche i cambi che rompono i dati sono MINOR (chiedi prima all'utente).
  - Il numero di build (`+N`) sale di 1 insieme alla versione e **non scende mai**: Android rifiuta di installare un numero più basso sopra uno più alto (per questo dopo la 1.12.4+32 si è ripartiti da 0.1.0+32).
  - Attuale: `0.1.0+32` (su `staging`; `main` ha ancora la 1.12.3+31 fino alla prossima unione).
- **Installazione a ogni aggiornamento di `staging`**: dopo il push prova sempre a installare sul telefono. Prima la stessa Wi-Fi (`adb mdns services`, poi `adb connect <ip>:<porta>`), poi Tailscale. Se non è raggiungibile, dillo e installa alla prima occasione.
- **APK per gli amici (tester)**: è lo **stesso APK di `staging` installato sul telefono**, con la stessa versione e lo stesso nome (`Avidididadi-<versione>.apk`, niente "staging" nel nome). Copialo in `Desktop\Avidididadi-<versione>.apk` (togliendo quello vecchio) **solo quando l'utente lo chiede**.
  - Insieme all'APK: aggiorna `CHANGELOG.md` (novità rispetto all'ultima versione distribuita, per chi usa l'app: estremamente sintetico, una riga per punto, nessun a capo dentro le righe) e copia quella sezione sul Desktop come `Avidididadi-<versione>-novita.txt`, togliendo quello vecchio.
- **Modifiche ai file con script**: scrivi gli script Python con lo strumento Write. Gli heredoc di bash rovinano `\'` e `\n`.

## 5. Linee guida grafiche (stile "Pulse")

- **Mai colori fissi nei widget**: usa `Theme.of(context).colorScheme`, `Pulse.di(context)` e `coloreSport(sport)`.
- **Ogni modifica grafica va controllata nelle 4 combinazioni** (fondo chiaro o scuro × accento rosso o neon).
- Il resto (colori, caratteri, componenti, forme, spaziature, UX) è in `.claude/rules/stile-pulse.md`: si carica da solo quando lavori sull'interfaccia; se serve altrove, leggilo.

## 6. Convenzioni di codice

- **Nomi in italiano**: classi `PascalCase` (`PianoRiga`, `SuperficiePulse`), funzioni e variabili `camelCase` (`coloreSport`, `valutaSeduta`), privati con `_`. I file in `snake_case` italiano.
- **Commenti** brevi in italiano, con `///` sopra classi e funzioni pubbliche, che spiegano il *perché*. Testi dell'interfaccia in italiano semplice.
- **Logica pura** (generatori, calcoli, parsing) in file senza Flutter UI, testabile. Le schermate leggono `AppState` con `ListenableBuilder` e chiamano i suoi metodi `Future`, che salvano e poi chiamano `notifyListeners()`.
- **Modelli** immutabili con `toRow()` e `static X? da(Tabella, riga)` per i CSV, più `copyWith` se serve.
- **Native**: un solo `MethodChannel('avidididadi/avvio')`; le liste numeriche arrivano "piatte" (`DoubleArray`).
- **Test**: per ogni logica nuova un test in `test/<area>_test.dart`, con dati realistici (anche casi reali dell'utente).
- **Prima di consegnare**: `dart format`, `flutter analyze` senza problemi, `flutter test` tutto verde.

### Sicurezza e privacy (non rompere)

- Health Connect **solo lettura**. GPS solo durante l'allenamento di corsa, camminata e bici, o di un'altra attività se l'utente lo sceglie all'inizio. Bluetooth (battito e sensori della bici) solo con la modalità allenamento o la pagina "I miei sensori" aperta.
- Chiavi API (assistente e intervals.icu) solo in `flutter_secure_storage`: mai in CSV, backup o log.
- Ollama in `http` solo verso la rete locale o Tailscale (`baseOllama` / `retePrivata`).
- Il pulsante ▶ del widget passa dall'alias non esportato `.AvviaDaWidget`. La ricezione dall'assistente esterno (`.RiceviDaAgente`) è attiva solo se l'assistente è collegato, e le risposte valgono solo con il codice giusto.
- `allowBackup=false`: il backup è quello dell'app.
- GPX: massimo 20 MB.
- All'assistente non vanno mai nome, foto o percorsi GPS.
- Se cambiano i dati raccolti, aggiorna l'informativa (`privacy_screen.dart`) e alza `versioneTermini`.

## 7. Regola Git (obbligatoria)

Repository: `https://github.com/BraveBanana420/avidididadi`, branch principale `main`. Identità dei commit: `BraveBanana420 <347462779+BraveBanana420@users.noreply.github.com>`.

- **Dove si lavora**:
  - **`staging`**: tutte le modifiche, piccole e grandi, si fanno qui e si installano sul telefono da qui. Commit e push su `staging`, che non si cancella mai;
  - **`main`**: la versione stabile, destinata a diventare pubblica. Resta ferma finché l'utente non decide di rilasciare l'aggiornamento: solo allora si unisce `staging` (`git merge --no-ff staging`, poi push). Mai modifiche dirette su `main`;
  - **rami `funzione/<nome-breve>`**: solo se una funzione grossa va provata a parte. Nascono da `staging` e tornano in `staging`; dopo l'unione si cancellano, anche su GitHub;
  - **APK per gli amici (tester)**: da `staging`, senza etichetta (si riconosce dal commit mostrato nell'app). L'etichetta della versione (`git tag -a v<versione>`, poi `git push origin v<versione>`) va sul commit di `main` a ogni unione. Mai spostare un'etichetta già caricata.
- **Al termine di ogni modifica completata e funzionante esegui sempre**:
  1. `git add` dei file della modifica;
  2. `git commit` con un **messaggio chiaro in italiano** che descriva la modifica;
  3. `git push` sul branch corrente su GitHub.
- **Prima del push verifica che il progetto compili senza errori**: `flutter analyze` senza problemi, `flutter test` verde e, se hai toccato codice Android, `flutter build apk --release --split-per-abi`.
- **Non committare mai file sensibili**: chiavi, password, token, `.env`, `key.properties`, `*.jks`, `backup/`, `NOTE_PRIVATE.md`, APK. Verifica che siano nel `.gitignore`.
  - Il controllo `tool/git-hooks/pre-commit` (attivo con `git config core.hooksPath tool/git-hooks`) blocca segreti, email personali, percorsi della cartella utente di Windows e indirizzi Tailscale. Se blocca un commit, sposta il dato in `NOTE_PRIVATE.md`: **non aggirarlo**.
- **Se il push fallisce, spiega all'utente il motivo** invece di forzarlo: **mai** `git push --force`, né altre riscritture della storia già caricata.
