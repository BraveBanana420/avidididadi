# Animazioni degli esercizi

[English](README.md) · **Italiano**

Ogni esercizio dell'app può mostrare una breve animazione che si ripete: nel
dettaglio dell'esercizio e durante l'allenamento guidato. Partiamo **da zero**: per
ora ogni esercizio mostra due foto. **Puoi aiutare senza scrivere codice.**

L'elenco degli esercizi, con quelli già fatti e quelli con l'immagine di partenza
pronta: [EXERCISES.md](EXERCISES.md). Parti dalla *Priorità 1*: sono quelli che usa
quasi ogni piano.

## Come funziona

1. **L'immagine di partenza la diamo noi**: l'avatar già nella posizione di
   partenza dell'esercizio, nella cartella [`start/`](start/). Tu la animi e basta.
2. **La trasformi in un breve video 2D** con uno strumento da immagine a video.
3. Noi la controlliamo e la aggiungiamo all'app.

**Non creare né modificare tu immagini degli avatar**, neanche piccoli ritocchi: le
immagini generate vengono sempre un po' diverse (viso, vestiti, proporzioni) e il
catalogo smetterebbe di sembrare un'unica serie. Se l'esercizio che vuoi non ha
ancora l'immagine di partenza, chiedila nella issue e la aggiungiamo noi.

## I due avatar

Solo come riferimento, per sapere come devono apparire in ogni fotogramma:

| Uomo: davanti | Uomo: lato | Uomo: dietro | Uomo: posa a T | Donna: davanti |
|---|---|---|---|---|
| <img src="avatar/male_front.jpg" width="140" alt="Avatar uomo, davanti"> | <img src="avatar/male_side.jpg" width="140" alt="Avatar uomo, lato"> | <img src="avatar/male_back.jpg" width="140" alt="Avatar uomo, dietro"> | <img src="avatar/male_t_pose.jpg" width="140" alt="Avatar uomo, posa a T"> | <img src="avatar/female_front.jpg" width="140" alt="Avatar donna, davanti"> |

Vestiti: canotta nera (top sportivo per la donna) con inserti rossi sui fianchi,
leggings neri con righe rosse (sopra, pantaloncini neri per l'uomo), fasce nere ai
polsi, scarpe nere con dettagli rossi. Stile cartone 3D semi-realistico.

## Regole per ogni animazione

| | |
|---|---|
| **Partenza** | l'immagine di [`start/`](start/), così com'è: stesso personaggio, vestiti, fondo, inquadratura e vista |
| **File finale** | WebP animato, **640 × 320 px** (2:1), circa **15 fotogrammi al secondo**, **2–3 secondi**, ripetizione infinita, senza audio, **al massimo 300 KB** |
| **Cosa mandi** | il WebP, oppure un video MP4: lo convertiamo noi |
| **Niente di nuovo** | niente scritte, loghi, filigrane, palestre, altre persone o oggetti che non sono nell'immagine di partenza |
| **Inquadratura** | ferma: niente zoom, movimenti o tagli. Tutto il corpo e gli attrezzi sempre dentro |
| **Movimento** | **una ripetizione completa**, lenta e controllata, con la tecnica giusta. Finisce esattamente nella posizione di partenza, così il giro è continuo |
| **Personaggio** | uguale all'immagine di partenza in ogni fotogramma: se cambiano viso, capelli o vestiti, riprova |

Per la tecnica giusta segui le istruzioni dell'esercizio in
[`assets/esercizi.json`](../../assets/esercizi.json) (campo `istruzioni`), le
stesse che mostra l'app.

## Come farla

### 1. Animazione (uno strumento da immagine a video, es. Dreamina, Kling, Runway, Veo)

Dagli l'immagine di partenza. Se lo strumento permette di scegliere il **primo e
l'ultimo fotogramma**, usa la stessa immagine per tutti e due: il giro sarà
continuo. Le richieste funzionano meglio in inglese, quindi lasciala così:

```text
The character performs one slow, controlled repetition of <EXERCISE NAME>:
<the movement in one or two lines>. Correct technique, realistic body mechanics.
The character, outfit and background stay exactly as in the image.
The camera is completely still: no zoom, no pan, no cuts. The movement ends
exactly in the starting position, so the video loops seamlessly. No text.
```

Fanne qualche versione e tieni quella con la tecnica migliore: mani, piedi e
articolazioni non devono piegarsi in modo strano.

### 2. Conversione in WebP (facoltativa)

Se hai [ffmpeg](https://ffmpeg.org/), taglia la ripetizione migliore (`-ss` è dove
inizia, `-t` quanto dura) e converti:

```sh
ffmpeg -ss 0.5 -t 2.0 -i video.mp4 -an \
  -vf "fps=15,scale=640:320:force_original_aspect_ratio=increase,crop=640:320" \
  -c:v libwebp -quality 75 -compression_level 6 -loop 0 id_esercizio.webp
```

Se il file supera i 300 KB abbassa `-quality` (es. 60) o accorcia `-t`. Se non hai
ffmpeg, manda direttamente l'MP4.

## Licenza e diritti (importante)

- Le animazioni sono pubblicate con licenza **[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/deed.it)**
  (pubblico dominio, come le foto degli esercizi): chiunque può riusarle. Anche gli
  avatar e le immagini di partenza sono CC0.
- Usa solo le immagini di partenza del progetto. Mai spezzoni, fotogrammi o
  personaggi presi da altre app, siti, video o giochi, e mai persone vere.
- Controlla che le condizioni dello strumento video permettano di pubblicare il
  risultato in un progetto open source (alcuni piani gratuiti no, o aggiungono una
  filigrana) e **scrivi quale strumento e quale piano hai usato** (gratuito o a
  pagamento). Se non sei sicuro, chiedi nella issue prima di mandarla: meglio
  aspettare che pubblicare qualcosa che non si può usare.
- **Manda anche le condizioni**: il link alle condizioni d'uso dello strumento e,
  se è separata, alla pagina del piano, più uno screenshot o un PDF della parte che
  dice di chi sono i risultati e se si possono pubblicare o usare per scopi
  commerciali, e la data in cui hai fatto l'animazione (le condizioni cambiano nel
  tempo). Le leggiamo prima di accettarla: se non lo permettono non possiamo
  pubblicarla, anche se è bellissima.

## Come mandarla

1. Scegli in [EXERCISES.md](EXERCISES.md) un esercizio con l'immagine di partenza
   pronta, e guarda le issue aperte, per non fare in due lo stesso esercizio.
2. Apri una issue con il modulo **Exercise animation / Animazione esercizio**,
   scrivendo su quale esercizio stai lavorando (o chiedendo la sua immagine di
   partenza).
3. Quando è pronta, trascina il WebP o l'MP4 nella issue (al massimo 10 MB),
   insieme alle condizioni dello strumento usato.
4. Noi controlliamo l'animazione e le condizioni, poi la aggiungiamo all'app.

Sai usare Git? Apri invece una pull request verso `staging`:

- aggiungi il file in `assets/exercises/animated/`, con l'ID dell'esercizio in
  minuscolo (`Bodyweight_Walking_Lunge` → `bodyweight_walking_lunge.webp`);
- aggiungi una riga in `animazioniEsercizi` in `lib/animazioni_esercizi.dart`;
- lancia `python tool/elenco_animazioni.py` per aggiornare [EXERCISES.md](EXERCISES.md).

Grazie! 💪
