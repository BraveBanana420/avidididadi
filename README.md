# Avidididadi

App Android (Flutter) per pianificare e seguire allenamenti di forza, corsa,
nuoto, bici e mobilità: piano generato e adattato dai feedback, modalità
allenamento passo passo, percorsi GPS con mappa, progressi e un coach con
l'assistente scelto dall'utente.

I dati restano sul telefono: niente server, account o pubblicità.

## Funzioni

- **Piano**: settimana tipo, generatori per forza, corsa/nuoto/bici e mobilità,
  progressione per durata o intensità, adattamento ai feedback e al recupero.
- **Allenamento guidato**: un esercizio alla volta, timer, recuperi, GPS per
  corsa e bici (anche a schermo spento).
- **Health Connect** (solo lettura): sessioni di Garmin, Freeletics e altre app,
  frequenza cardiaca, sonno, HRV, percorsi.
- **Mappe**: MapLibre + OpenFreeMap, con i colori del tema; import GPX.
- **Coach**: Claude, GPT, Gemini (chiave API) oppure Ollama sul proprio PC;
  oppure l'app del proprio assistente, senza chiave, con il collegamento a
  codice.
- **Widget** per la schermata home, **backup** in un file.

## Compilare

Serve Flutter (vedi `environment` in `pubspec.yaml`) e l'SDK Android.

```sh
flutter pub get
flutter test
flutter build apk --release --split-per-abi
```

Per la firma di rilascio copia `android/key.properties.example` in
`android/key.properties` e compila i valori. Il file e la chiave restano fuori
da git.

## Prima di fare commit

Attiva il controllo che blocca segreti e dati personali:

```sh
git config core.hooksPath tool/git-hooks
```

Le note private (indirizzi, percorsi della firma) vanno in `NOTE_PRIVATE.md`,
che git ignora.

## Licenze

Caratteri Manrope e Space Grotesk: SIL Open Font License (`assets/fonts`).
Esercizi da [free-exercise-db](https://github.com/yuhonas/free-exercise-db).
Mappe © OpenStreetMap, riquadri OpenFreeMap.
