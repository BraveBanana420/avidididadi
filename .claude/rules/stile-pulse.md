---
paths:
  - "lib/screens/**"
  - "lib/pulse.dart"
  - "lib/tema.dart"
  - "lib/widgets.dart"
  - "lib/main.dart"
---

# Linee guida grafiche (stile "Pulse")

**Temi**: due scelte indipendenti nel Profilo.
- **Fondo**: scuro grafite `#0B0B0D` oppure chiaro `#F6F6FA` (`tema`, salvato in `tema.txt`).
- **Accento**: **rosso** di default (`#FF3B47`, sfumatura `#FF6B73 → #FF3B47 → #B3122A`) oppure **neon** (rosa `#FF2E93`, verde acqua `#00D2C3`, azzurro `#2EA8FF`, viola `#B566FF`). Salvato con `neon` / `neonAttivo` in `neon.txt`.
- Le quattro varianti sono `Pulse.scuro`, `Pulse.chiaroRosso`, `Pulse.scuroNeon` e `Pulse.chiaro`, scelte con `Pulse.per(scuro:, neon:)`.
- **Mai colori fissi nei widget**: usa `Theme.of(context).colorScheme`, `Pulse.di(context)` e `coloreSport(sport)`.
- **Ogni modifica grafica va controllata nelle 4 combinazioni.** Senza telefono: `flutter test tool/schermate/schermate_test.dart` disegna le quattro sezioni, le pagine interne principali l'avvio dell'allenamento guidato, la pagina Dati della bici all'aperto e la bici al chiuso col rullo (finto) con dati di esempio nei 4 temi, in `build/schermate/<tema>/*.png` (mappe e dati dell'orologio non ci sono).
- **Movimento**: `durataMovimento(context)` dà la durata delle animazioni, zero se sul telefono sono spente. Anello e barra di avanzamento si riempiono da soli quando compaiono. `EntrataMorbida` (con `ValueKey(valore)`) fa entrare i numeri che cambiano e l'esercizio nuovo nell'allenamento guidato.
- **Icone**: sempre la famiglia arrotondata (`Icons.nome_rounded`). A contorno solo dove pieno/vuoto dice uno stato (cuore, cerchio da spuntare, sensore non collegato).
- **Numeri grandi che cambiano**: `stile?.cifreFisse` (cifre a larghezza fissa).
- **Grafici**: assi su numeri tondi con `scalaTonda` e `tacche` (`lib/assi.dart`).

**Colori degli sport**:

Stessa tinta nel chiaro e nello scuro, ma ogni colore deve staccare dal fondo (contrasto di almeno 3, lo controlla `test/tema_test.dart`). Dove il colore è uno solo vale per i due fondi; altrimenti "scuro / chiaro".

| Sport | Standard | Neon |
|---|---|---|
| Forza | `#8E8E96` / `#7B7B85` | `#9D4DFF` |
| Corsa | `#FF3B47` | `#FF2E93` |
| Nuoto | `#FF8A3D` / `#E0660A` | `#00B2FF` / `#0090DB` |
| Bici | `#CF2450` / `#B3123A` | `#00E0B8` / `#009C82` |
| Mobilità | `#F48FB1` / `#DB5C8E` | `#FF7A00` / `#E66400` |
| Arrampicata | `#4FA3A5` / `#3A8C8E` | `#FFE600` / `#A38500` |
| Attività libera | `#7C83FD` / `#6C73F5` | `#7C83FD` / `#6C73F5` |
| Camminata | `#E0A33A` / `#B87A0F` | `#C6FF3D` / `#5F9400` |

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
