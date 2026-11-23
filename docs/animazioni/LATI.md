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
  La voce dice il lato nella sua lingua (`fraseBlocco`). "8-12 per lato" (a
  ripetizioni) resta un blocco solo con "Fatto".
- Generatori: `durataMobilita()` (`lib/generatore_mobilita.dart`) usa `lati`;
  la forza scrive "N s per lato" o "8-12 per lato" e conta il doppio del tempo.
- Riconosciuti "per side", "ανά πλευρά" e "δευτ.".
- Test: `esecuzione_test`, `voce_test`, `mobilita_test`,
  `generatore_forza_test` e `esercizi_test`. Quest'ultimo controlla che ogni
  esercizio che nelle istruzioni dice "cambia lato/gamba/braccio/piede" abbia `lati`.

## Da fare

1. **Animazioni del lato destro**, partendo dai 13 di mobilità qui sotto (sono
   a tempo, quindi quelli dove il problema si sente di più). Stesso metodo
   delle prime due (vedi [FONTI.md](FONTI.md)): immagine di partenza con Nano
   Banana dagli avatar, video con Seedance 2.0 Mini, tutto tramite l'API di
   OpenRouter (crediti a pagamento). La chiave OpenRouter è sul PC: si lavora
   da lì con Remote Control.
2. **Lato sinistro = animazione specchiata.** Nel blocco con
   `lato == latoSinistro`, l'allenamento guidato mostra la stessa animazione
   girata in orizzontale (`Transform.flip(flipX: true)` attorno ad
   `AnimazioneEsercizio`). Nel dettaglio dell'esercizio resta quella normale.
   Così si genera un video solo per esercizio.
3. Forse **qualche secondo per cambiare lato** tra i due blocchi: oggi il
   sinistro parte subito, annunciato dalla voce. Da decidere con l'utente.
4. Le istruzioni del **corridore** (`Runners_Stretch`) non dicono di cambiare
   lato: aggiungere "poi cambia lato" in italiano, inglese e greco.

## Regola per le animazioni per lato

- **Si anima il lato destro**: il lato che lavora o si allunga è il destro (per
  i flessori dell'anca è l'anca della gamba dietro, quindi ginocchio destro a
  terra e piede sinistro avanti).
- Il personaggio non cambia lato durante il video: una ripetizione (o la
  tenuta) di un lato solo, che finisce nella posizione di partenza.
- Inquadratura: di solito 3/4 o di lato, con il lato destro ben visibile.

## Richieste pronte (mobilità, lato destro)

Da usare con i modelli di [README.it.md](README.it.md): `<EXERCISE NAME>` e
`<the movement…>` sono qui sotto. Per gli stretching "tenuti", il movimento è
l'entrata lenta nella posizione, una breve tenuta e il ritorno, così il giro
si chiude.

| ID | Inquadratura | Posizione di partenza | Movimento (lato destro) |
|---|---|---|---|
| `Kneeling_Hip_Flexor` | di lato | kneeling on a mat, right knee down, left foot forward with the knee at 90° | shifts the hips slowly forward until the front of the right hip stretches, holds, comes back |
| `Worlds_Greatest_Stretch` | 3/4 | deep lunge with the right foot forward, left knee close to the floor | places the right hand on the floor, rotates the torso lifting the left arm to the ceiling, brings it back, then straightens the right leg moving the hips back, and returns to the lunge (da controllare: le istruzioni dell'app dicono la mano "dal lato della gamba anteriore") |
| `Seated_Floor_Hamstring_Stretch` | 3/4 | seated, right leg straight, left foot against the inside of the right thigh | hinges forward from the hips towards the right ankle, holds, sits back up |
| `Calf_Stretch_Hands_Against_Wall` | di lato | hands on a wall, left foot forward, right foot back with the leg straight and heel down | pushes the hips towards the wall keeping the right heel down, holds, comes back |
| `Standing_Soleus_And_Achilles_Stretch` | di lato | standing, left foot forward, right foot back, both heels down | bends both knees shifting the weight onto the right (back) leg, holds, straightens |
| `On_Your_Side_Quad_Stretch` | di lato | lying on the left side, left leg bent in front for balance | bends the right leg, grabs the right foot with the right hand, pushes the hip forward, holds, releases |
| `Runners_Stretch` | di lato | from standing, left leg steps back, hands on the floor beside the right foot | keeps the right heel down, lifts the hips straightening the right leg, then bends it back |
| `Hip_Circles_prone` | 3/4 | on all fours | lifts the bent right knee and draws one wide slow circle, then puts it back down |
| `Shoulder_Stretch` | di fronte | standing | brings the straight right arm across the chest, holds it close with the left hand, releases |
| `Triceps_Stretch` | 3/4 | standing | puts the right hand behind the head, the left hand gently pulls the right elbow, releases |
| `Ankle_Circles` | 3/4 | standing, right foot slightly lifted | rotates the right ankle in one slow wide circle, puts the foot back down |
| `Iliotibial_Tract-SMR` | di lato | lying on the right side, foam roller under the outer right thigh, on the right forearm, left foot on the floor | rolls slowly from the hip to the knee and back |
| `Piriformis-SMR` | 3/4 | seated on a foam roller, right ankle crossed over the left knee | leans towards the right side and rolls slowly over the right glute, and back |

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
