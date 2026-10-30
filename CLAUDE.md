# CLAUDE.md – Avidididadi

Guida permanente per lavorare su questo progetto. Rispondi all'utente in **italiano**, con parole semplici.

## 1. Panoramica

**Avidididadi** è un'app Android personale (Flutter) per pianificare e seguire gli allenamenti di forza, corsa, nuoto, bici e mobilità. Tutti i dati restano sul telefono: niente server, account o pubblicità.

Funzioni principali:
- **Piano**: settimana tipo → calendario. Generatori per forza, corsa/nuoto/bici e mobilità. Adattamento ai feedback (fatica, passo).
- **Oggi**: seduta del giorno, settimana, energia/recupero (sonno, HRV, FC a riposo), feedback "Com'è andata?".
- **Allenamento guidato**: player passo passo con timer e recuperi, GPS per corsa e bici (anche a schermo spento).
- **Health Connect** (solo lettura): sessioni di Garmin e Freeletics, battito, sonno, HRV, percorsi.
- **intervals.icu** (facoltativo, chiave API dell'utente): corsa, bici e nuoto complete da Garmin, Polar, Suunto… (nome, rulli, percorso, altitudine, pendenza, potenza). Sostituiscono le stesse attività di Health Connect, senza doppioni. Se l'utente lo accende, corsa, bici e nuoto dei prossimi 14 giorni vanno nel suo calendario di intervals.icu (e da lì a Garmin).
- **Mappe**: MapLibre + OpenFreeMap con i colori del tema; import GPX.
- **Progressi**: carico, grafici, report per sport.
- **Coach (assistente AI)**: Claude, GPT, Gemini con chiave API, Ollama sul PC (anche via Tailscale), oppure l'app dell'assistente dell'utente con un codice di collegamento.
- **Altro**: catalogo esercizi con animazioni, figura dei muscoli, widget per la schermata home, backup e ripristino su file.

## 2. Stack tecnico

- **Flutter 3.47** (stable), **Dart 3.13**, solo **Android** (non c'è la cartella `ios/`).
- `applicationId`: `it.avidididadi.app`. `minSdk` 26 (per Health Connect).
- Dipendenze principali:

| Pacchetto | Uso |
|---|---|
| `health` | Health Connect (lettura) |
| `flutter_secure_storage` | chiavi API cifrate |
| `maplibre_gl` | mappe |
| `geolocator` | GPS con notifica in primo piano |
| `path_provider` | cartella privata dei dati |
| `file_picker` | backup, CSV, GPX |
| `image_picker` | foto del profilo |
| `path_drawing` | figura dei muscoli (tracciati SVG) |
| `package_info_plus` | versione dell'app |
| `flutter_localizations` | tutta l'app in italiano |

- **Codice nativo Kotlin** ([android/app/src/main/kotlin/it/avidididadi/app/](android/app/src/main/kotlin/it/avidididadi/app/)):
  - `MainActivity.kt`: canale `avidididadi/avvio` per titoli e dettagli delle sessioni Health Connect, percorsi, condivisione, schermo acceso, bip e vibrazione, widget;
  - `WidgetOggi.kt`: widget per la schermata home.
- **Nessuna libreria di state management**: un solo `AppState` (`ChangeNotifier`). I dati sono CSV nella cartella privata dell'app.

## 3. Struttura

```
lib/
  main.dart            avvio, tema, barra in basso (Oggi, Progressi, Coach, Profilo)
  app_state.dart       stato unico: carica e salva i CSV, sincronizza, rigenera il piano
  models.dart          PianoRiga, Sessione, WorkoutStep, Slot e funzioni di data e formato
  storage.dart         lettura e scrittura dei CSV (path_provider)
  tema.dart            temi (chiaro o scuro × rosso o neon), estensione Pulse
  pulse.dart           componenti grafici dello stile Pulse
  widgets.dart         coloreSport, iconaSport, card comuni
  generator*.dart      generatori del piano (forza, endurance, mobilità)
  adattamento.dart     adattamento ai feedback, passo del nuoto, riepilogo modifiche
  feedback.dart        feedback e regole di carico
  recupero.dart        energia e prontezza dai dati di recupero
  sincronizzazione.dart / health_connect.dart   Health Connect → Sessione
  intervals.dart       client API intervals.icu e conversione (attività, streams, mappa)
  invio_intervals.dart piano → allenamenti strutturati nel calendario di intervals.icu
  serie_sessione.dart  serie nel tempo per i grafici (battito, velocità, quota, potenza)
  registro_forza.dart  ripetizioni e kg di ogni serie, storico e record per esercizio
  avvisi.dart          bip e vibrazione degli ultimi 5 secondi (avvisi.txt)
  assistente.dart / llm.dart / agente_esterno.dart   coach AI
  percorso.dart / gps.dart   GPS, GPX, stile della mappa
  backup.dart          backup in .gz (JSON di tutti i CSV)
  screens/             una schermata o un foglio per file (*_screen.dart, *_sheet.dart)
assets/                esercizi.json, fonts/ (Manrope, Space Grotesk), exercises/animated/*.webp
test/                  un file *_test.dart per area
tool/                  script Python (catalogo esercizi, icona), git-hooks/pre-commit
android/               progetto Android, firma, manifest, widget
NOTE.md                appunti e lavori in sospeso (pubblico)
NOTE_PRIVATE.md        dati personali (indirizzi, percorsi della firma): solo locale, ignorato da git
```

**Dati dell'app** (CSV nella cartella privata):
- `piano.csv`, `settimana_tipo.csv`, `workout.csv`, `programma.csv`;
- `sessioni.csv`, `health_connect_sessioni.csv`;
- `feedback.csv`, `profilo.csv`, `misure.csv`, `assistente.csv`, `recupero.csv`;
- `ritocchi_sessioni.csv`, `percorso_*.csv`;
- `intervals_sessioni.csv`, `intervals.csv`, `intervals_inviati.csv`;
- `serie.csv` (ripetizioni e kg della forza).

I nuovi file devono rispettare `^[a-z0-9_]+\.csv$`, altrimenti non entrano nel backup. Le colonne nuove si aggiungono **in fondo**, e le righe vecchie devono restare leggibili.

## 4. Comandi

```sh
flutter pub get
dart format lib test                        # formattazione
flutter analyze                             # deve dare "No issues found!"
flutter test                                # tutti i test devono passare
flutter build apk --release --split-per-abi # APK firmato, arm64 ~32 MB
adb -s RFCY916AAVK install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

- **Firma**: `android/key.properties` (fuori da git, modello in `key.properties.example`). Un APK di debug ha un'altra firma e non si installa sopra quello di rilascio.
- **Telefono** (Samsung `RFCY916AAVK`): installa **senza avviare** l'app; niente tocchi né screenshot se non li chiede l'utente. In Git Bash, per i percorsi dentro `adb shell` usa `MSYS_NO_PATHCONV=1`.
- **Senza cavo**: Debug wireless + Tailscale (telefono su un Wi-Fi qualsiasi). `adb connect <IP Tailscale del telefono>:<porta>`: l'IP è in `NOTE_PRIVATE.md`, la porta la comunica l'utente (cambia quando il Debug wireless si riaccende). Poi usa `adb -s <ip>:<porta>` al posto del numero di serie.
- **APK per gli amici**: copialo in `Desktop\Avidididadi-<versione>.apk` solo se l'utente lo chiede. La versione attuale è `1.0.2+3`: si cambia solo quando lo chiede l'utente.
- **Modifiche ai file con script**: scrivi gli script Python con lo strumento Write. Gli heredoc di bash rovinano `\'` e `\n`.

## 5. Linee guida grafiche (stile "Pulse")

**Temi**: due scelte indipendenti nel Profilo.
- **Fondo**: scuro grafite `#0B0B0D` oppure chiaro `#F6F6FA` (`tema`, salvato in `tema.txt`).
- **Accento**: **rosso** di default (`#FF3B47`, sfumatura `#FF6B73 → #FF3B47 → #B3122A`) oppure **neon** (rosa `#FF2E93`, verde acqua `#00D2C3`, azzurro `#2EA8FF`, viola `#B566FF`). Salvato con `neon` / `neonAttivo` in `neon.txt`.
- Le quattro varianti sono `Pulse.scuro`, `Pulse.chiaroRosso`, `Pulse.scuroNeon` e `Pulse.chiaro`, scelte con `Pulse.per(scuro:, neon:)`.
- **Mai colori fissi nei widget**: usa `Theme.of(context).colorScheme`, `Pulse.di(context)` e `coloreSport(sport)`.
- **Ogni modifica grafica va controllata nelle 4 combinazioni.**

**Colori degli sport** (uguali nel chiaro e nello scuro):

| Sport | Standard | Neon |
|---|---|---|
| Forza | `#8E8E96` | `#9D4DFF` |
| Corsa | `#FF3B47` | `#FF2E93` |
| Nuoto | `#FF8A3D` | `#00B2FF` |
| Bici | `#B3123A` | `#00E0B8` |
| Mobilità | `#F48FB1` | `#FF7A00` |

- Le **spunte** sui pallini e i quadrati degli sport hanno sempre il colore del fondo (`colorScheme.surface`), mai bianco o nero a seconda del pallino.
- **Energia**: verde `#22E07A`, giallo `#FFC233`, rosso `#FF3B47`, con alone al neon (`FulmineNeon`).

**Caratteri**:
- **Space Grotesk** w700 per titoli e numeri (letterSpacing negativo);
- **Manrope** (400–800) per i testi;
- dimensioni di Material 3 (`Typography.englishLike2021`).

**Componenti** (`pulse.dart`):
- `SuperficiePulse`: riquadro in rilievo, raggio 24, padding 16;
- `PulsantePrincipale`: pillola con sfumatura, altezza 60;
- `AnelloPulse`: anello sfumato con alone;
- `RigaPulse`: riga di elenco con icona, titolo, sottotitolo e linea;
- `IconaQuadrata`, `PallinoPulse`, `PillolaPulse`, `BarraAvanzamento`, `TitoloSezione`;
- `SfondoPulse`: fondo con bagliori;
- `BarraPulse`: barra di navigazione fluttuante.

**Forme**:
- card raggio 24, dialoghi 28, campi di testo 16;
- pulsanti, chip e segmenti a pillola (`StadiumBorder`);
- immagini degli esercizi raggio 14;
- i `Card` hanno elevazione 0.

**Spaziature**:
- margine laterale delle pagine 16–20;
- spazi tra blocchi 8, 12, 16 o 24;
- nei moduli, `spacing: 12–14` tra i campi;
- in basso `spazioBarra(context)`, perché la barra fluttua sopra il contenuto (`extendBody`).

**Rilievo**: sfumature e ombre morbide colorate **solo** su seduta di oggi, pulsanti principali, anelli e barra. Testi ed elenchi stanno su fondi piatti.

**UX per principianti**:
- parole semplici;
- dettagli tecnici dentro sezioni da aprire;
- spiegazioni brevi ("Cos'è" chiuso di default);
- distinguere con forma e icona, non solo con il colore;
- la figura dei muscoli resta.

**Sopra `SfondoPulse`**, `CheckboxListTile` e `ListTile` vanno dentro `Material(type: MaterialType.transparency)`, altrimenti l'effetto al tocco non si vede.

## 6. Convenzioni di codice

- **Nomi in italiano**: classi `PascalCase` (`PianoRiga`, `SuperficiePulse`), funzioni e variabili `camelCase` (`coloreSport`, `valutaSeduta`), privati con `_`. I file in `snake_case` italiano.
- **Commenti** brevi in italiano, con `///` sopra classi e funzioni pubbliche, che spiegano il *perché*. Testi dell'interfaccia in italiano semplice.
- **Logica pura** (generatori, calcoli, parsing) in file senza Flutter UI, testabile. Le schermate leggono `AppState` con `ListenableBuilder` e chiamano i suoi metodi `Future`, che salvano e poi chiamano `notifyListeners()`.
- **Modelli** immutabili con `toRow()` e `static X? da(Tabella, riga)` per i CSV, più `copyWith` se serve.
- **Native**: un solo `MethodChannel('avidididadi/avvio')`; le liste numeriche arrivano "piatte" (`DoubleArray`).
- **Test**: per ogni logica nuova un test in `test/<area>_test.dart`, con dati realistici (anche casi reali dell'utente).
- **Prima di consegnare**: `dart format`, `flutter analyze` senza problemi, `flutter test` tutto verde.

### Sicurezza e privacy (non rompere)

- Health Connect **solo lettura**. GPS solo durante l'allenamento di corsa e bici.
- Chiavi API (assistente e intervals.icu) solo in `flutter_secure_storage`: mai in CSV, backup o log.
- Ollama in `http` solo verso la rete locale o Tailscale (`baseOllama` / `retePrivata`).
- Il pulsante ▶ del widget passa dall'alias non esportato `.AvviaDaWidget`. La ricezione dall'assistente esterno (`.RiceviDaAgente`) è attiva solo se l'assistente è collegato, e le risposte valgono solo con il codice giusto.
- `allowBackup=false`: il backup è quello dell'app.
- GPX: massimo 20 MB.
- All'assistente non vanno mai nome, foto o percorsi GPS.
- Se cambiano i dati raccolti, aggiorna l'informativa (`privacy_screen.dart`) e alza `versioneTermini`.

## 7. Regola Git (obbligatoria)

Repository: `https://github.com/BraveBanana420/avidididadi`, branch `main`. Identità dei commit: `BraveBanana420 <347462779+BraveBanana420@users.noreply.github.com>`.

- **Al termine di ogni modifica completata e funzionante esegui sempre**:
  1. `git add` dei file della modifica;
  2. `git commit` con un **messaggio chiaro in italiano** che descriva la modifica;
  3. `git push` sul branch corrente su GitHub.
- **Prima del push verifica che il progetto compili senza errori**: `flutter analyze` senza problemi, `flutter test` verde e, se hai toccato codice Android, `flutter build apk --release --split-per-abi`.
- **Non committare mai file sensibili**: chiavi, password, token, `.env`, `key.properties`, `*.jks`, `backup/`, `NOTE_PRIVATE.md`, APK. Verifica che siano nel `.gitignore`.
  - Il controllo `tool/git-hooks/pre-commit` (attivo con `git config core.hooksPath tool/git-hooks`) blocca segreti, email personali, percorsi della cartella utente di Windows e indirizzi Tailscale. Se blocca un commit, sposta il dato in `NOTE_PRIVATE.md`: **non aggirarlo**.
- **Se il push fallisce, spiega all'utente il motivo** invece di forzarlo: **mai** `git push --force`, né altre riscritture della storia già caricata.
