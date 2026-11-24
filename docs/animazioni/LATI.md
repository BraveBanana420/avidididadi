# Esercizi per lato: destra e sinistra

Appunti di lavoro (23/11/2026) per gli esercizi che si fanno **prima su un lato
e poi sull'altro**: cosa c'era che non andava, cosa è già sistemato e cosa
manca, con le richieste pronte per generare le animazioni.

## Il problema

In allenamento un passo "30 s per lato" era **un unico blocco da 60 s** con la
nota "Cambia lato a metà.": niente bip né voce a 30 s. Chi era distratto poteva
fare 55 s da una parte e 5 dall'altra.

## Cosa c'era nel catalogo (analisi)

- Nessun campo diceva "si fa su un lato": il cambio di lato era scritto solo
  nelle istruzioni ("Tieni 15-30 secondi, poi cambia lato.").
- **Mobilità**: il generatore decideva "per lato" dal nome, non
  dall'esercizio. Così:
  - gatto, posizione del bambino, ponte con retroversione, parte alta della
    schiena e apertura del petto (due lati insieme) avevano "30 s per lato";
  - le circonduzioni di anca e caviglie (una gamba alla volta) avevano
    "30 s" in tutto;
  - rullo su bandelletta e glutei: "60 s" senza cambio lato.
- **Forza**:
  - il plank laterale aveva "30 s" in tutto, un solo fianco;
  - gli esercizi a un braccio o una gamba avevano "8-12" senza dire "per lato".
- **Lingue**: "per side" (inglese) e "ανά πλευρά" (greco) non valevano doppio;
  i secondi in greco ("30 δευτ.") non erano riconosciuti come tempo.
- **Animazioni**: nessuno di questi esercizi ne ha una. Le sole animazioni sono
  `Bodyweight_Squat` e `Leg_Extensions`, che si fanno con i due lati insieme.
  Gli altri mostrano le due foto di free-exercise-db alternate ogni secondo:
  una persona vera, non l'avatar, e un lato solo.

Gli esercizi **alternati** a ogni ripetizione (dead bug, affondi, step-up,
mountain climber, torsione della colonna…) non c'entrano: lì il timer va bene.

## Già fatto (commit "Esercizi per lato: il timer divide lato destro e lato sinistro")

- Campo `"lati": true` in `assets/esercizi.json` (elenco `LATI` in
  `tool/genera_esercizi.py`), letto in `Esercizio.lati`.
- `blocchiDa` (`lib/esecuzione.dart`): "30 s per lato" → due blocchi da 30 s,
  "Lato destro" e "Lato sinistro" (`Blocco.lato` = `latoDestro` / `latoSinistro`).
  In mezzo, 5 s di pausa "Cambia lato" per girarsi. La voce dice il lato
  nella sua lingua (`fraseBlocco`). "8-12 per lato" (a
  ripetizioni) resta un blocco solo con "Fatto".
- Generatori: `durataMobilita()` (`lib/generatore_mobilita.dart`) usa `lati`;
  la forza scrive "N s per lato" o "8-12 per lato" e conta il doppio del tempo.
- Riconosciuti "per side", "ανά πλευρά" e "δευτ.".
- Test: `esecuzione_test`, `voce_test`, `mobilita_test`,
  `generatore_forza_test` e `esercizi_test`. Quest'ultimo controlla che ogni
  esercizio che nelle istruzioni dice "cambia lato/gamba/braccio/piede" abbia `lati`.

## Da fare

1. **Animazioni del lato destro**, partendo dai 13 di mobilità qui sotto (sono
   a tempo, quindi quelli dove il problema si sente di più), con la ricetta
   unica di [README.it.md](README.it.md) (`agents/animazione.mjs`). Le
   richieste approvate sono in [`richieste.json`](richieste.json), tutte e 13.
   **Fatto (24/11):** `Kneeling_Hip_Flexor`, da 3/4 invece che di lato (si
   vedono insieme l'anca che si allunga e il busto dritto). Il video spostava
   la telecamera alla fine: tagliato al fotogramma 68, dove torna uguale al
   primo (`converti --fine 68 --accelera 1`).
   **Fatti (24/11), scelti tra i più proposti dai generatori:**
   `Seated_Floor_Hamstring_Stretch` (2 s fermo piegato in avanti,
   `--pausa 50:2`), `Runners_Stretch` (immagine ferma, tipo "posizione"),
   `Worlds_Greatest_Stretch` (solo la rotazione, mano sinistra a terra e
   braccio destro in alto, 2 s ferma in alto, poi torna per la stessa strada
   con `--andata 26`; la mano esce un po' in alto). Le istruzioni dell'app sono
   state corrette allo stesso modo (mano opposta alla gamba avanti).
   **Ancora da fare:** `Hip_Circles_prone`: Seedance fa avanti e indietro
   (una mezzaluna) invece del giro completo del ginocchio; da riprovare con
   un'altra vista o un altro modello.
2. ~~Lato sinistro = animazione specchiata~~: fatto. Nel blocco con
   `lato == latoSinistro` (e nella pausa "Cambia lato" prima), l'allenamento
   guidato mostra la stessa animazione girata in orizzontale
   (`_AnteprimaEsercizio(specchio: true)`, con `Transform.flip`). Nel
   dettaglio dell'esercizio resta quella normale. Così si genera un video solo
   per esercizio.
3. ~~Qualche secondo per cambiare lato~~: fatto. Tra i due lati c'è una pausa
   "Cambia lato" di `pausaCambioLato` (5 s), un blocco di recupero con
   `lato == latoSinistro` (`Blocco.cambioLato`); la voce dice "Cambia lato.".
4. Le istruzioni del **corridore** (`Runners_Stretch`) non dicono di cambiare
   lato: aggiungere "poi cambia lato" in italiano, inglese e greco.

## Regola per le animazioni per lato

- **Si anima il lato destro**: il lato che lavora o si allunga è il destro (per
  i flessori dell'anca è l'anca della gamba dietro, quindi ginocchio destro a
  terra e piede sinistro avanti).
- Il personaggio non cambia lato durante il video: una ripetizione (o la
  tenuta) di un lato solo, che finisce nella posizione di partenza.
- Inquadratura: di solito 3/4 o di lato, con il lato destro ben visibile.

## Richieste (mobilità, lato destro)

Vista, posizione di partenza e movimento dei 13 di mobilità sono in
[`richieste.json`](richieste.json), l'unico posto da cui li legge lo script
(lì sono scritti per intero, in inglese, con il lato destro).

## Gli altri esercizi per lato (forza)

Si animano dopo la mobilità, con la stessa regola (lato destro):
`Single_Leg_Glute_Bridge`, `Glute_Kickback`, `Side_Bridge`,
`One-Arm_Dumbbell_Row`, `Split_Squat_with_Dumbbells`, `Dumbbell_Side_Bend`,
`Kettlebell_One-Legged_Deadlift`, `Kettlebell_Turkish_Get-Up_Squat_style`,
`One-Arm_Kettlebell_Row`, `One-Arm_Kettlebell_Military_Press_To_The_Side`,
`One-Arm_Kettlebell_Clean`, `Kettlebell_Windmill`,
`External_Rotation_with_Band`, `Seated_One-arm_Cable_Pulley_Rows`,
`Standing_Low-Pulley_Deltoid_Raise`, `Pallof_Press`,
`Standing_Cable_Wood_Chop`, `Smith_Single-Leg_Split_Squat`,
`One-Legged_Cable_Kickback`.

In [EXERCISES.md](EXERCISES.md) sono segnati con ↔.
