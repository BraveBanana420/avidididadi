#!/usr/bin/env node
// Aiutante delle animazioni degli esercizi per /orchestra (nessuna dipendenza).
// Fa le parti meccaniche; le scelte (quale immagine, se il video va bene) le fa
// Claude guardando le anteprime. Spende crediti OpenRouter solo con la chiave
// OPENROUTER_VIDEO_KEY (con un tetto di spesa), mai con quella dei worker.
//
//   node agents/animazione.mjs credito
//   node agents/animazione.mjs partenza <cartella> --esercizio <ID> [--vista tre_quarti|lato|fronte] [--avatar | --quante 2 --posa "..."]
//   node agents/animazione.mjs video <cartella> --immagine <file> --movimento "..."
//   node agents/animazione.mjs converti <cartella> --esercizio <ID> [--intero | --taglio] [--fine N] [--accelera 1]
//   node agents/animazione.mjs integra <cartella> --esercizio <ID> --repo <cartella della repo>
//
// Regole delle animazioni: docs/animazioni/README.md.

import fs from 'node:fs';
import path from 'node:path';
import { spawn, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const AVATAR = path.join(REPO, 'docs', 'animazioni', 'avatar');
const API = 'https://openrouter.ai/api/v1';
const MODELLO_IMMAGINE = 'google/gemini-nano-banana-2.1';
const MODELLO_VIDEO = 'bytedance/seedance-2.0-mini';
/** Costi indicativi (22/11/2026): servono solo per il controllo prima di spendere. */
const COSTO = { immagine: 0.045, video: 0.15 };
/** Fondo delle animazioni nell'app (sfondoAnimazioni in lib/animazioni_esercizi.dart). */
const FONDO = 217;
const VISTE = {
  tre_quarti: { avatar: 'male_three_quarter.jpg', testo: 'in the same three-quarter view as the first attached image: the body is turned about 45 degrees, facing towards the left side of the image' },
  lato: { avatar: 'male_side.jpg', testo: 'seen from the side, like the attached side view, facing left' },
  fronte: { avatar: 'male_front.jpg', testo: 'seen from the front, like the attached front view' },
};
/** Lo stile degli avatar: senza dirlo, i video tendono a diventare realistici a metà movimento. */
const STILE = 'hand-drawn digital illustration: clean dark outlines, soft cel shading, smooth flat colours, like the attached avatar images. Not a photo, not a photorealistic or 3D render';
const VESTITI = 'black sleeveless top with red side panels, black shorts with red side panels over plain black leggings, black wrist wraps, black shoes with red soles';

// ---------- utilità ----------

const stampa = (...a) => console.log(...a);
function argomenti(lista) {
  const o = { _: [] };
  for (let i = 0; i < lista.length; i++) {
    const a = lista[i];
    if (a.startsWith('--')) {
      const k = a.slice(2);
      const v = lista[i + 1];
      if (v === undefined || v.startsWith('--')) o[k] = true;
      else (o[k] = v), i++;
    } else o._.push(a);
  }
  return o;
}
const leggiJson = (f, d = null) => (fs.existsSync(f) ? JSON.parse(fs.readFileSync(f, 'utf8')) : d);
const scriviJson = (f, v) => fs.writeFileSync(f, JSON.stringify(v, null, 2) + '\n');
const meta = (dir) => leggiJson(path.join(dir, 'meta.json'), { passi: [], costo: 0 });
function aggiungiMeta(dir, passo) {
  const m = meta(dir);
  m.passi.push({ ...passo, quando: new Date().toISOString() });
  m.costo = Math.round((m.costo + (passo.costo || 0)) * 10000) / 10000;
  scriviJson(path.join(dir, 'meta.json'), m);
  return m;
}
const base64 = (f) => fs.readFileSync(f).toString('base64');
const dataUrl = (f) => `data:image/${f.endsWith('.png') ? 'png' : 'jpeg'};base64,${base64(f)}`;
const nomeFile = (id) => id.toLowerCase();

function esercizio(id) {
  const tutti = leggiJson(path.join(REPO, 'assets', 'esercizi.json'));
  const e = tutti.find((x) => x.id === id);
  if (!e) throw new Error(`Esercizio ${id} non trovato in assets/esercizi.json`);
  return e;
}
const conAttrezzi = (e) => (e.attrezzi || []).some((g) => g.length);
const limiteKb = (e) => (conAttrezzi(e) ? 400 : 300);

function ffmpeg(args, opzioni = {}) {
  const r = spawnSync('ffmpeg', ['-v', 'error', '-y', ...args], { encoding: opzioni.input ? undefined : 'utf8', ...opzioni });
  if (r.error) throw new Error('ffmpeg non trovato: installalo con "winget install Gyan.FFmpeg" e riapri il terminale');
  if (r.status !== 0) throw new Error(`ffmpeg: ${String(r.stderr).slice(0, 400)}`);
  return r;
}
function sonda(f) {
  const r = spawnSync('ffprobe', ['-v', 'error', '-select_streams', 'v:0', '-count_frames', '-show_entries', 'stream=width,height,r_frame_rate,nb_read_frames', '-of', 'json', f], { encoding: 'utf8' });
  const s = JSON.parse(r.stdout).streams[0];
  return { w: s.width, h: s.height, fps: s.r_frame_rate, n: Number(s.nb_read_frames) };
}
/** Somiglianza (SSIM) tra primo e ultimo fotogramma: vicino a 1 = il giro non salta. */
function giro(f) {
  const n = sonda(f).n;
  const r = spawnSync('ffmpeg', ['-hide_banner', '-i', f, '-i', f, '-filter_complex', `[0:v]select='eq(n,0)'[a];[1:v]select='eq(n,${n - 1})'[b];[a][b]ssim`, '-f', 'null', '-'], { encoding: 'utf8' });
  return Number((r.stderr.match(/All:([0-9.]+)/) || [])[1] || 0);
}

// ---------- OpenRouter (solo chiave dei video) ----------

function chiave() {
  const k = process.env.OPENROUTER_VIDEO_KEY;
  if (!k) throw new Error('Manca OPENROUTER_VIDEO_KEY (la chiave con il tetto di spesa per immagini e video)');
  return k;
}
async function credito() {
  const r = await fetch(`${API}/key`, { headers: { Authorization: `Bearer ${chiave()}` } });
  if (!r.ok) throw new Error(`OpenRouter /key: ${r.status}`);
  const d = (await r.json()).data || {};
  return { tetto: d.limit, rimasto: d.limit_remaining, speso: d.usage };
}
/** Si ferma prima di spendere se il tetto della chiave non basta. */
async function controllaCredito(serve) {
  const c = await credito();
  if (c.rimasto != null && c.rimasto < serve + 0.05) throw new Error(`Sulla chiave dei video restano ${c.rimasto.toFixed(2)} $, ne servono circa ${serve.toFixed(2)}: alza il tetto su openrouter.ai/settings/keys`);
  return c;
}
async function attendi429(fn) {
  for (let giro = 0; ; giro++) {
    const r = await fn();
    if (r.status !== 429 || giro >= 1) return r;
    stampa('OpenRouter: troppe richieste (429), aspetto 60 s e riprovo una volta');
    await new Promise((ok) => setTimeout(ok, 60000));
  }
}

// ---------- comandi ----------

const comandi = {
  async credito() {
    const c = await credito();
    stampa(`Chiave dei video: tetto ${c.tetto ?? 'nessuno'} $, spesi ${Number(c.speso).toFixed(2)} $, restano ${c.rimasto != null ? c.rimasto.toFixed(2) + ' $' : 'senza limite'}`);
  },

  /** Immagine di partenza 16:9: l'avatar allargato (gratis) o generata con Nano Banana. */
  async partenza(a) {
    const dir = path.resolve(a._[0] || '.');
    fs.mkdirSync(dir, { recursive: true });
    const e = esercizio(a.esercizio);
    const vista = VISTE[a.vista || 'tre_quarti'];
    if (!vista) throw new Error(`Vista sconosciuta: ${a.vista} (tre_quarti, lato, fronte)`);
    if (a.avatar) {
      // Esercizio che parte in piedi: avatar al centro, fondo ricopiato dal suo bordo sinistro.
      const src = path.join(AVATAR, vista.avatar);
      const out = path.join(dir, 'partenza_1.jpg');
      ffmpeg(['-f', 'lavfi', '-i', 'color=c=0xC7C7C7:s=1280x720', '-i', src, '-filter_complex',
        "[1:v]split[x][y];[x]crop=8:ih:0:0,scale=1280:600[bg];[y]scale=-2:600,format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='255*clip(min(X,W-1-X)/50,0,1)'[fg];" +
        '[0:v][bg]overlay=0:60[c];[c]split[c1][c2];[c2]crop=1280:2:0:656,scale=1280:62[basso];[c1][basso]overlay=0:658[c3];[c3][fg]overlay=(W-w)/2:60:format=auto',
        '-frames:v', '1', '-q:v', '2', out]);
      aggiungiMeta(dir, { passo: 'partenza', esercizio: e.id, vista: a.vista || 'tre_quarti', fonte: `avatar ${vista.avatar} allargato a 16:9`, costo: 0 });
      return stampa(`Immagine di partenza (gratis): ${out}`);
    }
    if (!a.posa) throw new Error('Serve --posa "descrizione in inglese della posizione di partenza" (oppure --avatar se parte in piedi)');
    const quante = Math.min(4, Number(a.quante || 2));
    await controllaCredito(COSTO.immagine * quante);
    const attrezzi = conAttrezzi(e) ? ` The equipment (${e.attrezzi.map((g) => g.join(' + ')).join(' or ')}) is simple and clean, matte black and dark grey, no logos, no text, no brand.` : '';
    const prompt = `Use the attached character exactly as he is: same face, hair, beard, body proportions and outfit exactly as in the attached images (${VESTITI}), same drawing style (${STILE}).
Show him in the starting position of: ${e.nome_en.toUpperCase()}. ${a.posa}${attrezzi}
Seen ${vista.testo}.
Full body${conAttrezzi(e) ? ' and the whole equipment' : ''} visible with some margin, in the centre of the image, feet near the bottom. Plain light grey background (#D9D9DB) with a slightly lighter floor, soft studio light, soft shadow on the floor. No other objects, no other people, no text. Wide 16:9 image.`;
    fs.writeFileSync(path.join(dir, 'prompt-partenza.txt'), prompt);
    const immagini = ['male_three_quarter.jpg', 'male_front.jpg', 'male_side.jpg'].map((f) => ({ type: 'image_url', image_url: { url: dataUrl(path.join(AVATAR, f)) } }));
    let costo = 0;
    await Promise.all(Array.from({ length: quante }, async (_, k) => {
      const r = await attendi429(() => fetch(`${API}/chat/completions`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${chiave()}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ model: MODELLO_IMMAGINE, modalities: ['image', 'text'], image_config: { aspect_ratio: '16:9' }, usage: { include: true }, messages: [{ role: 'user', content: [{ type: 'text', text: prompt }, ...immagini] }] }),
      }));
      const t = await r.text();
      if (!r.ok) return stampa(`${k + 1}: errore ${r.status} ${t.slice(0, 300)}`);
      const j = JSON.parse(t);
      costo += j.usage?.cost ?? 0;
      const url = j.choices?.[0]?.message?.images?.[0]?.image_url?.url;
      const m = url?.match(/^data:image\/(\w+);base64,(.*)$/);
      if (!m) return stampa(`${k + 1}: nessuna immagine nella risposta`);
      const out = path.join(dir, `partenza_${k + 1}.${m[1] === 'jpeg' ? 'jpg' : m[1]}`);
      fs.writeFileSync(out, Buffer.from(m[2], 'base64'));
      stampa(`${k + 1}: ${out}`);
    }));
    const tot = aggiungiMeta(dir, { passo: 'partenza', esercizio: e.id, vista: a.vista || 'tre_quarti', fonte: `${MODELLO_IMMAGINE} (OpenRouter) dagli avatar`, costo });
    stampa(`Spesa: ${costo.toFixed(3)} $ (in tutto per questa animazione: ${tot.costo.toFixed(3)} $). Guarda le immagini e scegli la migliore.`);
  },

  /** Video da immagine (primo = ultimo fotogramma, così il giro si chiude). */
  async video(a) {
    const dir = path.resolve(a._[0] || '.');
    const img = path.resolve(dir, a.immagine || 'partenza_1.jpg');
    if (!fs.existsSync(img)) throw new Error(`Immagine di partenza non trovata: ${img}`);
    if (!a.movimento) throw new Error('Serve --movimento "una ripetizione, in inglese"');
    await controllaCredito(COSTO.video);
    const prompt = `The character performs one slow, controlled repetition: ${a.movimento} The movement ends exactly in the starting pose. Correct technique, anatomically correct movement. The character, outfit, equipment and plain grey background stay exactly as in the image. Keep exactly the same drawing style as the image in every frame (${STILE.replace(', like the attached avatar images', '')}): the character must never turn photorealistic or 3D-rendered. The camera is completely still: no zoom, no pan, no cuts. The video loops seamlessly. No text, no other people.`;
    fs.writeFileSync(path.join(dir, 'prompt-video.txt'), prompt);
    const frame = (tipo) => ({ type: 'image_url', image_url: { url: dataUrl(img) }, frame_type: tipo });
    const H = { Authorization: `Bearer ${chiave()}`, 'Content-Type': 'application/json' };
    const r = await attendi429(() => fetch(`${API}/videos`, {
      method: 'POST',
      headers: H,
      body: JSON.stringify({ model: a.modello || MODELLO_VIDEO, prompt, frame_images: [frame('first_frame'), frame('last_frame')], resolution: '480p', aspect_ratio: '16:9', duration: 4, generate_audio: false, seed: 42 }),
    }));
    const t = await r.text();
    if (!r.ok) throw new Error(`Video rifiutato: ${r.status} ${t.slice(0, 400)}`);
    const job = JSON.parse(t);
    stampa(`Video inviato (${job.id}), aspetto...`);
    const t0 = Date.now();
    for (;;) {
      await new Promise((ok) => setTimeout(ok, 20000));
      const s = await (await fetch(`${API}/videos/${job.id}`, { headers: H })).json();
      if (s.status === 'completed') {
        const v = await fetch(`${API}/videos/${job.id}/content?index=0`, { headers: H });
        fs.writeFileSync(path.join(dir, 'video.mp4'), Buffer.from(await v.arrayBuffer()));
        fs.copyFileSync(img, path.join(dir, 'partenza_scelta.jpg'));
        const tot = aggiungiMeta(dir, { passo: 'video', modello: a.modello || MODELLO_VIDEO, immagine: path.basename(img), costo: s.usage?.cost ?? 0 });
        // Anteprima: 6 fotogrammi per giudicare tecnica e personaggio.
        ffmpeg(['-i', path.join(dir, 'video.mp4'), '-vf', "select='not(mod(n\\,19))',scale=-2:240,tile=3x2", '-frames:v', '1', '-fps_mode', 'vfr', path.join(dir, 'anteprima-video.jpg')]);
        return stampa(`Fatto in ${Math.round((Date.now() - t0) / 1000)} s, spesa ${(s.usage?.cost ?? 0).toFixed(3)} $ (in tutto ${tot.costo.toFixed(3)} $). Anteprima: ${path.join(dir, 'anteprima-video.jpg')}`);
      }
      if (['failed', 'cancelled', 'expired'].includes(s.status)) throw new Error(`Video ${s.status}: ${JSON.stringify(s.error ?? '').slice(0, 300)}`);
      if (Date.now() - t0 > 15 * 60000) throw new Error(`Il video non è pronto dopo 15 minuti (id ${job.id})`);
    }
  },

  /** WebP dell'app: luce uniforme, fondo #D9D9DB, 640x320, il più fluido che sta nel limite. */
  async converti(a) {
    const dir = path.resolve(a._[0] || '.');
    const e = esercizio(a.esercizio);
    const ingresso = path.join(dir, 'video.mp4');
    if (!fs.existsSync(ingresso)) throw new Error('Manca video.mp4: prima "video"');
    // Con attrezzi di solito serve tutto il fotogramma (16:9 rimpicciolito); a corpo libero basta il taglio 2:1.
    const intero = a.intero ? true : a.taglio ? false : conAttrezzi(e);
    const limite = limiteKb(e);
    const uscita = path.join(dir, `${nomeFile(e.id)}.webp`);
    // --fine N: il video finisce al fotogramma N (dove torna uguale al primo:
    // a volte il modello muove la telecamera alla fine e il giro salterebbe).
    // --accelera: 0.75 di norma (4 s diventano 3); 1 per lasciarlo com'è.
    const fine = Number(a.fine || 0);
    const accelera = Number(a.accelera || 0.75);
    const prove = [[24, 75], [24, 65], [24, 55], [24, 45], [20, 55], [20, 45], [15, 55], [15, 45]];
    let scelta = null;
    for (const [fps, q] of prove) {
      await codifica(ingresso, uscita, { fps, q, intero, fine, accelera });
      const kb = Math.round(fs.statSync(uscita).size / 1024);
      stampa(`  ${fps} fps, qualità ${q}: ${kb} KB`);
      if (kb <= limite) {
        scelta = { fps, q, kb };
        break;
      }
    }
    if (!scelta) throw new Error(`Anche a 15 fps e qualità 45 supera ${limite} KB: accorcia il movimento o rigenera`);
    const ssim = giro(uscita);
    ffmpeg(['-i', uscita, '-vf', "select='not(mod(n\\,12))',tile=3x2", '-frames:v', '1', '-fps_mode', 'vfr', path.join(dir, 'anteprima-webp.png')]);
    aggiungiMeta(dir, { passo: 'converti', file: path.basename(uscita), ...scelta, intero, fine: fine || null, accelera, limite_kb: limite, giro_ssim: ssim, costo: 0 });
    stampa(`${uscita}: ${scelta.kb} KB (limite ${limite}), ${scelta.fps} fps, qualità ${scelta.q}, ${intero ? 'fotogramma intero' : 'taglio 2:1'}; primo/ultimo fotogramma simili al ${(ssim * 100).toFixed(1)}%${ssim < 0.95 ? ' ⚠️ il giro potrebbe saltare' : ''}. Anteprima: ${path.join(dir, 'anteprima-webp.png')}`);
  },

  /** Mette l'animazione nella repo indicata (di solito il clone del task). */
  async integra(a) {
    const dir = path.resolve(a._[0] || '.');
    const repo = path.resolve(a.repo || REPO);
    const e = esercizio(a.esercizio);
    const m = meta(dir);
    const nome = nomeFile(e.id);
    const webp = path.join(dir, `${nome}.webp`);
    for (const f of [webp, path.join(dir, 'video.mp4'), path.join(dir, 'partenza_scelta.jpg')]) if (!fs.existsSync(f)) throw new Error(`Manca ${f}: completa prima partenza, video e converti`);
    const orig = path.join(repo, 'docs', 'animazioni', 'originali');
    fs.mkdirSync(orig, { recursive: true });
    fs.copyFileSync(webp, path.join(repo, 'assets', 'exercises', 'animated', `${nome}.webp`));
    fs.copyFileSync(path.join(dir, 'video.mp4'), path.join(orig, `${nome}.mp4`));
    fs.copyFileSync(path.join(dir, 'partenza_scelta.jpg'), path.join(orig, `${nome}_primo.jpg`));

    // Riga nella mappa del codice (in ordine di inserimento, prima della chiusura).
    const dart = path.join(repo, 'lib', 'animazioni_esercizi.dart');
    const codice = fs.readFileSync(dart, 'utf8');
    if (!codice.includes(`'${e.id}':`)) {
      const eol = codice.includes('\r\n') ? '\r\n' : '\n';
      const righe = codice.split(/\r?\n/);
      const inizio = righe.findIndex((r) => r.startsWith('const animazioniEsercizi = <String, String>{'));
      if (inizio < 0) throw new Error('Mappa animazioniEsercizi non trovata in lib/animazioni_esercizi.dart');
      if (righe[inizio].endsWith('{};')) righe.splice(inizio, 1, 'const animazioniEsercizi = <String, String>{', `  '${e.id}': '${nome}.webp',`, '};');
      else righe.splice(righe.indexOf('};', inizio), 0, `  '${e.id}': '${nome}.webp',`);
      fs.writeFileSync(dart, righe.join(eol));
    }

    // Riga in FONTI.md: strumenti, data e video originale.
    const fonti = path.join(repo, 'docs', 'animazioni', 'FONTI.md');
    const testo = fs.readFileSync(fonti, 'utf8');
    if (!testo.includes(`\`${nome}.webp\``)) {
      const p = Object.fromEntries(m.passi.map((x) => [x.passo, x]));
      const partenza = p.partenza?.fonte?.startsWith('avatar') ? `start frame: ${p.partenza.fonte.replace('allargato a', 'widened to')}` : `start frame: Nano Banana 2.1 (Google) via the OpenRouter API, paid credits, from the project avatars`;
      const c = p.converti || {};
      const accelera = c.accelera ?? 0.75;
      const tempo = [c.fine ? `cut at frame ${c.fine}, where it matches the first` : '', accelera !== 1 ? `sped up ×${(1 / accelera).toFixed(2)}` : 'not sped up'].filter(Boolean).join(', ');
      const riga = `| \`${nome}.webp\` | \`${e.id}\` | AI · ${partenza} · video: Seedance 2.0 Mini (ByteDance, provider BytePlus "Seed") via the OpenRouter API, first and last frame = start frame · ffmpeg: exposure evened out frame by frame, background to \`#D9D9DB\`, ${c.intero ? 'whole 16:9 frame fitted in 640×320' : '2:1 crop, 640×320'}, ${tempo}, ${c.fps} fps | ${new Date().toISOString().slice(0, 10)} | [\`${nome}.mp4\`](originali/${nome}.mp4), [start frame](originali/${nome}_primo.jpg) |`;
      // In fondo alla tabella delle animazioni (la prima che inizia con "| File | Exercise").
      const eol = testo.includes('\r\n') ? '\r\n' : '\n';
      const righe = testo.split(/\r?\n/);
      const intest = righe.findIndex((r) => r.startsWith('| File | Exercise'));
      if (intest < 0) throw new Error('Tabella delle animazioni non trovata in docs/animazioni/FONTI.md');
      let fine = intest + 2;
      while (righe[fine]?.startsWith('|')) fine++;
      righe.splice(fine, 0, riga);
      fs.writeFileSync(fonti, righe.join(eol));
    }
    const py = spawnSync('python', ['tool/elenco_animazioni.py'], { cwd: repo, encoding: 'utf8' });
    if (py.status !== 0) throw new Error(`tool/elenco_animazioni.py: ${py.stderr}`);
    stampa(`Integrata ${e.id} in ${repo}: asset, mappa in lib/animazioni_esercizi.dart, FONTI.md, originali/, EXERCISES.md. Spesa totale: ${m.costo.toFixed(3)} $`);
  },
};

/** Luce uguale in ogni fotogramma (i video scuriscono piano piano) e fondo a #D9D9DB. */
function codifica(ingresso, uscita, { fps, q, intero, fine = 0, accelera = 0.75 }) {
  const { w: W, h: H, fps: fpsIn } = sonda(ingresso);
  const dim = W * H * 3;
  const wIn = 2 * Math.round((320 * W) / H / 2);
  const sx = Math.floor((640 - wIn) / 2);
  const dx = 640 - wIn - sx;
  // Fotogramma intero: i lati si riempiono allungando le colonne del bordo (fillborders sbaglia il lato destro).
  const adatta = intero
    ? `format=rgb24,scale=${wIn}:320,split=3[c][l][r];[l]crop=2:320:0:0,scale=${sx}:320[ls];[r]crop=2:320:${wIn - 2}:0,scale=${dx}:320[rs];[ls][c][rs]hstack=3`
    : 'crop=iw:iw/2,scale=640:320';
  const filtri = `setpts=${accelera}*PTS,fps=${fps},${adatta}`;
  const fondo = (f) => {
    // Mediana di quattro riquadri sul bordo (in alto e a metà dei lati): solo fondo.
    const medie = [[8, 8], [W - 48, 8], [8, Math.floor(H / 3)], [W - 48, Math.floor(H / 3)]].map(([x0, y0]) => {
      let s = 0;
      for (let y = y0; y < y0 + 40; y++) for (let x = x0; x < x0 + 40; x++) {
        const i = (y * W + x) * 3;
        s += f[i] + f[i + 1] + f[i + 2];
      }
      return s / (40 * 40 * 3);
    }).sort((p, q2) => p - q2);
    return (medie[1] + medie[2]) / 2;
  };
  return new Promise((ok, ko) => {
    const dec = spawn('ffmpeg', ['-v', 'error', '-i', ingresso, '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-']);
    const enc = spawn('ffmpeg', ['-v', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', `${W}x${H}`, '-r', fpsIn, '-i', '-', '-an', '-vf', filtri, '-c:v', 'libwebp_anim', '-quality', String(q), '-compression_level', '6', '-loop', '0', uscita]);
    let errore = '';
    enc.stderr.on('data', (d) => (errore += d));
    let buf = Buffer.alloc(0), rif = null, base = null, letti = 0;
    const curva = (v) => {
      const p = [[0, 0], [128, 128], [rif, FONDO], [255, 255]];
      for (let k = 1; k < p.length; k++) if (v <= p[k][0]) return p[k - 1][1] + ((v - p[k - 1][0]) * (p[k][1] - p[k - 1][1])) / (p[k][0] - p[k - 1][0]);
      return 255;
    };
    dec.stdout.on('data', (d) => {
      buf = Buffer.concat([buf, d]);
      while (buf.length >= dim) {
        const f = Buffer.from(buf.subarray(0, dim));
        buf = buf.subarray(dim);
        // Dopo il fotogramma di chiusura del giro non serve altro.
        if (fine && letti++ > fine) continue;
        const b = fondo(f);
        if (rif === null) rif = b;
        const lut = new Uint8Array(256);
        for (let v = 0; v < 256; v++) lut[v] = Math.max(0, Math.min(255, Math.round(curva(Math.min(255, (v * rif) / b)))));
        for (let i = 0; i < dim; i++) f[i] = lut[f[i]];
        // Zone ferme identiche al primo fotogramma: il WebP salva solo quello che si muove.
        if (!base) base = Buffer.from(f);
        else for (let i = 0; i < dim; i += 3) {
          if (Math.abs(f[i] - base[i]) < 12 && Math.abs(f[i + 1] - base[i + 1]) < 12 && Math.abs(f[i + 2] - base[i + 2]) < 12) {
            f[i] = base[i];
            f[i + 1] = base[i + 1];
            f[i + 2] = base[i + 2];
          }
        }
        enc.stdin.write(f);
      }
    });
    dec.on('close', () => enc.stdin.end());
    enc.on('close', (c) => (c === 0 ? ok() : ko(new Error(`codifica WebP: ${errore.slice(0, 300)}`))));
  });
}

const [cmd, ...resto] = process.argv.slice(2);
if (!comandi[cmd]) {
  stampa(fs.readFileSync(fileURLToPath(import.meta.url), 'utf8').split('\n').slice(1, 14).map((r) => r.replace(/^\/\/ ?/, '')).join('\n'));
  process.exit(cmd ? 1 : 0);
}
comandi[cmd](argomenti(resto)).catch((e) => {
  console.error(`ERRORE: ${e.message}`);
  process.exit(1);
});
