# Start images / Immagini di partenza

The avatar already in the starting position of each exercise: the first (and
last) frame of its animation. **Made only by the project maintainer**, so that
every image shows exactly the same characters. To animate one, see the
[guide](../README.md).

L'avatar già nella posizione di partenza di ogni esercizio: il primo (e l'ultimo)
fotogramma della sua animazione. **Le crea solo chi mantiene il progetto**, così
tutte mostrano esattamente gli stessi personaggi. Per animarne una, vedi la
[guida](../README.it.md).

## File

- Name / Nome: `<exercise ID>_male.jpg` or / o `<exercise ID>_female.jpg`, with the
  ID exactly as in [EXERCISES.md](../EXERCISES.md) (e.g. `Pushups_male.jpg`,
  `Bodyweight_Walking_Lunge_female.jpg`). PNG also works / Va bene anche PNG.
- Wide 2:1 image, at least 1280 × 640 px; under 300 KB if possible.
- After adding one, run / Dopo averne aggiunta una, lancia:
  `python tool/elenco_animazioni.py` (updates the ✅ in EXERCISES.md).

## Per chi le crea (maintainer)

Con Nano Banana / Gemini: carica le immagini dell'avatar in
[`../avatar/`](../avatar/) (davanti e lato) e chiedi la posizione di partenza.
Prima di salvarla, confrontala con l'avatar: viso, capelli, vestiti e proporzioni
devono essere uguali. Le condizioni d'uso dello strumento valgono anche qui.

```text
Use the attached character exactly as he is: same face, hair, body and outfit
(black sleeveless top with red side panels, black shorts over black leggings with
red stripes, black wrist wraps, black shoes with red details), same semi-realistic
3D cartoon style.
Show him in the starting position of: <EXERCISE NAME> (<one line from the
instructions>), seen from the <side / front>.
Full body visible with some margin, feet near the bottom, plain light grey
background (#D9D9DB) with a slightly lighter floor, soft studio light. No text,
no logo, no other objects <except: EQUIPMENT in matte black>. Wide 2:1 image.
```

Per la donna: "she" al posto di "he" e i vestiti "black sports bra with red
details, black leggings with red stripes, black wrist wraps, black shoes with red
details".

Vista: **di lato** per quasi tutti gli esercizi; **di fronte** quando il
movimento è laterale (es. jumping jack, alzate laterali).
