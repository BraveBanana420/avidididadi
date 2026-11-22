#!/usr/bin/env node
// Aiutante di /orchestra: tiene lo stato, crea i worktree, lancia i worker
// OpenCode, controlla il loro lavoro, unisce i branch e aggiorna GitHub.
// Solo moduli di Node, nessuna dipendenza. Uso: node agents/orchestra.mjs aiuto
import fs from 'node:fs';
import path from 'node:path';
import { spawn, execSync } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { fileURLToPath } from 'node:url';

const AGENTS = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(AGENTS, '..');
const RUNS = path.join(AGENTS, 'runs');
const STATUS = path.join(AGENTS, 'status.json');
const MODELS = path.join(AGENTS, 'models.json');
const GITHUB_CFG = path.join(AGENTS, 'github.json');
const WORKER_CFG = path.join(AGENTS, 'opencode-worker.json');
/** Riassunto ripulito per il pannello su claude.ai (resta fuori da git). */
const PANNELLO = path.join(AGENTS, 'pannello.json');
/** I worktree stanno fuori dal progetto, così flutter analyze non li vede. */
const WT_ROOT = path.resolve(REPO, '..', path.basename(REPO) + '_wt');
const BASE = 'staging';
const TIMEOUT_WORKER_MIN = 15;
const ATTESA_429_S = 60;

/** File che nessun worker può toccare (stessa idea dei divieti in opencode-worker.json). */
const VIETATI = [
  /(^|\/)\.env/,
  /key\.properties/,
  /\.(jks|keystore|p12|pem|der)$/,
  /NOTE_PRIVATE\.md$/,
  /build\.gradle/,
  /AndroidManifest\.xml$/,
  /^\.github\//,
  /^tool\/git-hooks\//,
  /^opencode.*\.json$/,
  /^agents\//,
  /^\.claude\//,
  /^CLAUDE\.md$/,
  /^pubspec\.(yaml|lock)$/,
  /^backup\//,
];
const vietato = (f) => VIETATI.some((r) => r.test(f.replace(/\\/g, '/')));

/** Il worker gira con GitHub e il push disattivati: anche se aggirasse i divieti, non può caricare niente. */
const ENV_WORKER = {
  OPENCODE_CONFIG: WORKER_CFG,
  GH_TOKEN: 'disattivato-per-i-worker',
  GITHUB_TOKEN: 'disattivato-per-i-worker',
  GIT_TERMINAL_PROMPT: '0',
  GIT_CONFIG_COUNT: '2',
  GIT_CONFIG_KEY_0: 'credential.helper',
  GIT_CONFIG_VALUE_0: '',
  GIT_CONFIG_KEY_1: 'remote.origin.pushurl',
  GIT_CONFIG_VALUE_1: 'https://push-disattivato-per-i-worker.invalid/',
};

// ---------- utilità ----------

const ora = () => new Date().toISOString();
const pad = (n) => String(n).padStart(2, '0');
const attendi = (ms) => new Promise((ok) => setTimeout(ok, ms));
const stampa = (...a) => console.log(...a);

function leggiJson(f, predefinito = null) {
  try {
    return JSON.parse(fs.readFileSync(f, 'utf8'));
  } catch {
    return predefinito;
  }
}

/** Scrive passando da un file temporaneo: la dashboard non legge mai un JSON a metà. */
function scriviJson(f, dati) {
  const tmp = `${f}.${process.pid}.tmp`;
  fs.writeFileSync(tmp, JSON.stringify(dati, null, 2) + '\n');
  for (let i = 0; ; i++) {
    try {
      fs.renameSync(tmp, f);
      return;
    } catch (e) {
      if (i >= 10) throw e;
      Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 50);
    }
  }
}

function uccidi(pid) {
  try {
    execSync(`taskkill /PID ${pid} /T /F`, { stdio: 'ignore' });
  } catch {
    /* già finito */
  }
}

/** Esegue un programma e aspetta. Con `out` l'uscita va dritta nel file. */
function esegui(cmd, args, { cwd = REPO, env = {}, out = null, timeoutMs = 0, shell = false } = {}) {
  return new Promise((ok) => {
    const fd = out ? fs.openSync(out, 'a') : null;
    let finito = false;
    let testo = '';
    let scaduto = false;
    const fine = (code) => {
      if (finito) return;
      finito = true;
      if (timer) clearTimeout(timer);
      if (fd !== null) fs.closeSync(fd);
      ok({ code: scaduto ? -1 : code, testo, scaduto });
    };
    const p = shell
      ? spawn([cmd, ...args].join(' '), { cwd, env: { ...process.env, ...env }, shell: true, windowsHide: true, stdio: ['ignore', fd ?? 'pipe', fd ?? 'pipe'] })
      : spawn(cmd, args, { cwd, env: { ...process.env, ...env }, windowsHide: true, stdio: ['ignore', fd ?? 'pipe', fd ?? 'pipe'] });
    if (fd === null) {
      p.stdout.on('data', (d) => (testo += d));
      p.stderr.on('data', (d) => (testo += d));
    }
    const timer = timeoutMs
      ? setTimeout(() => {
          scaduto = true;
          uccidi(p.pid);
        }, timeoutMs)
      : null;
    p.on('close', fine);
    p.on('error', (e) => {
      testo += String(e);
      fine(-2);
    });
  });
}

const git = (args, cwd = REPO) => esegui('git', args, { cwd });
const flutter = (args, cwd, out) => esegui('flutter', args, { cwd, out, shell: true });
const dart = (args, cwd, out) => esegui('dart', args, { cwd, out, shell: true });
const gh = (args, cwd = REPO) => esegui('gh', args, { cwd });

/** Un solo giro di controlli Flutter alla volta: in parallelo si rallentano a vicenda. */
let codaControlli = Promise.resolve();
function inCoda(fn) {
  const p = codaControlli.then(fn);
  codaControlli = p.catch(() => {});
  return p;
}

function opencodeExe() {
  try {
    const root = execSync('npm root -g', { encoding: 'utf8' }).trim();
    const exe = path.join(root, 'opencode-ai', 'bin', process.platform === 'win32' ? 'opencode.exe' : 'opencode');
    if (fs.existsSync(exe)) return exe;
  } catch {
    /* uso il nome */
  }
  return 'opencode';
}

// ---------- stato ----------

function stato() {
  return leggiJson(STATUS);
}

function esecuzioneCorrente() {
  const s = stato();
  if (!s?.esecuzione) throw new Error('Nessuna esecuzione: inizia con "nuova".');
  return s;
}

const cartellaRun = (s) => path.join(RUNS, s.esecuzione.id);

/** Modifica lo stato e ne tiene una copia nella cartella della corsa (per lo storico). */
function aggiorna(fn) {
  const s = stato() || {};
  fn(s);
  s.aggiornato = ora();
  scriviJson(STATUS, s);
  if (s.esecuzione?.id && fs.existsSync(path.join(RUNS, s.esecuzione.id))) {
    scriviJson(path.join(RUNS, s.esecuzione.id, 'stato.json'), s);
  }
  scriviPannello(s);
  return s;
}

/** Toglie percorsi del PC e nomi utente dai testi che escono dal computer. */
function ripulisci(testo, max = 400) {
  if (testo == null) return null;
  return String(testo)
    .replace(/[A-Za-z]:[\\/](?:Users|Utenti)[\\/][^\s'"`)]*/gi, '<percorso>')
    .replace(/\/(?:c\/)?(?:Users|home)\/[^\s'"`)]*/gi, '<percorso>')
    .slice(0, max);
}

/**
 * Riassunto per il pannello su claude.ai (agents/pannello.json, fuori da git):
 * un solo documento piatto, senza percorsi, prompt o chiavi. Claude lo carica nella pagina.
 */
function scriviPannello(s) {
  try {
    const e = s?.esecuzione || {};
    const q = s?.quota || {};
    const storico = fs.existsSync(RUNS)
      ? fs
          .readdirSync(RUNS)
          .filter((d) => /^\d{4}-\d{2}-\d{2}_\d{4}$/.test(d) && d !== e.id)
          .sort()
          .reverse()
          .slice(0, 15)
          .map((d) => leggiJson(path.join(RUNS, d, 'stato.json')))
          .filter((x) => x?.esecuzione)
          .map((x) => ({
            id: x.esecuzione.id,
            nome: x.esecuzione.nome,
            fase: x.esecuzione.fase,
            inizio: x.esecuzione.inizio,
            fatti: (x.tasks || []).filter((t) => t.stato === 'fatto').length,
            totale: (x.tasks || []).length,
            richieste: x.richieste_usate ?? (x.tasks || []).reduce((n, t) => n + (t.richieste || 0), 0),
            issue: x.issue?.url || null,
            pr: x.pr?.url || null,
          }))
      : [];
    scriviJson(PANNELLO, {
      aggiornato: ora(),
      id: e.id || null,
      nome: e.nome || null,
      richiesta: ripulisci(e.richiesta, 600),
      fase: e.fase || null,
      inizio: e.inizio || null,
      fine: e.fine || null,
      branch: e.branch || null,
      issue_url: s?.issue?.url || null,
      issue_numero: s?.issue?.numero || null,
      pr_url: s?.pr?.url || null,
      pr_numero: s?.pr?.numero || null,
      progetto: leggiJson(GITHUB_CFG)?.url || null,
      stima: s?.stima_richieste ?? null,
      errore: ripulisci(s?.ultimo_errore?.testo),
      errore_quando: s?.ultimo_errore?.quando || null,
      quota_rimaste: q.rimaste ?? null,
      quota_limite: q.limite ?? null,
      quota_usate: q.usate ?? null,
      quota_letta: q.letta || null,
      tasks: (s?.tasks || []).map((t) => ({
        id: t.id,
        titolo: ripulisci(t.titolo, 120),
        tipo: t.tipo || null,
        modello: t.modello || null,
        stato: t.stato,
        tentativi: t.tentativi || 0,
        richieste: t.richieste || 0,
        secondi: t.secondi || 0,
        nota: ripulisci(t.nota),
        riassunto: t.stato === 'fatto' ? ripulisci(t.riassunto) : null,
      })),
      storico,
    });
  } catch {
    /* il pannello non deve mai fermare una corsa */
  }
}

function aggiornaTask(id, campi) {
  return aggiorna((s) => {
    const t = s.tasks.find((x) => x.id === id);
    if (t) Object.assign(t, campi);
  });
}

function sommaTask(id, campi) {
  return aggiorna((s) => {
    const t = s.tasks.find((x) => x.id === id);
    if (t) for (const [k, v] of Object.entries(campi)) t[k] = (t[k] || 0) + v;
  });
}

async function impostaFase(fase, commento) {
  aggiorna((s) => {
    s.esecuzione.fase = fase;
    s.fasi = s.fasi || [];
    s.fasi.push({ fase, da: ora() });
  });
  if (commento) await commenta(commento);
}

async function segnaErrore(testo) {
  aggiorna((s) => {
    s.ultimo_errore = { testo, quando: ora() };
  });
  await commenta(`⚠️ ${testo}`);
}

// ---------- OpenRouter ----------

async function leggiQuota() {
  const key = process.env.OPENROUTER_API_KEY;
  if (!key) return null;
  try {
    const r = await fetch('https://openrouter.ai/api/v1/key', { headers: { Authorization: `Bearer ${key}` } });
    const q = (await r.json()).data?.free_model_daily_requests;
    return q ? { usate: q.used, limite: q.limit, rimaste: q.remaining, letta: ora() } : null;
  } catch {
    return null;
  }
}

async function aggiornaQuota() {
  const q = await leggiQuota();
  if (q && stato()) aggiorna((s) => (s.quota = q));
  return q;
}

async function modelliGratuiti() {
  const r = await fetch('https://openrouter.ai/api/v1/models');
  return new Set((await r.json()).data.map((m) => m.id).filter((id) => id.endsWith(':free')));
}

// ---------- GitHub (issue e Project) ----------

async function commenta(testo) {
  const s = stato();
  if (!s?.issue?.numero) return;
  const r = await gh(['issue', 'comment', String(s.issue.numero), '--body', testo]);
  if (r.code) stampa(`(avviso: commento alla issue non riuscito: ${r.testo.trim().slice(0, 200)})`);
}

/** Spunta (o segna come fallita) la casella di un task nel corpo della issue. */
async function spunta(id, riuscito, nota = '') {
  const s = stato();
  if (!s?.issue?.numero) return;
  const r = await gh(['issue', 'view', String(s.issue.numero), '--json', 'body', '-q', '.body']);
  if (r.code) return;
  const riga = new RegExp(`^- \\[[ x]\\] \\*\\*${id}\\*\\*(.*?)( · ❌.*)?$`, 'm');
  const corpo = r.testo.replace(/\r?\n$/, '').replace(riga, (_, resto) =>
    riuscito ? `- [x] **${id}**${resto}` : `- [ ] **${id}**${resto} · ❌ ${nota}`.slice(0, 300),
  );
  const f = path.join(cartellaRun(s), 'issue-corpo.md');
  fs.writeFileSync(f, corpo + '\n');
  await gh(['issue', 'edit', String(s.issue.numero), '--body-file', f]);
}

/** Sposta la issue in una colonna del Project (se il Project è configurato in agents/github.json). */
async function colonna(nome, s = stato()) {
  const cfg = leggiJson(GITHUB_CFG);
  if (!cfg || !s?.issue?.url) return;
  const opzione = cfg.colonne?.[nome];
  if (!opzione) return stampa(`(avviso: colonna "${nome}" non trovata in github.json)`);
  let item = s.issue.item;
  if (!item) {
    const r = await gh(['project', 'item-add', String(cfg.numero), '--owner', cfg.owner, '--url', s.issue.url, '--format', 'json']);
    if (r.code) return stampa(`(avviso: issue non aggiunta al Project: ${r.testo.trim().slice(0, 200)})`);
    item = JSON.parse(r.testo).id;
    if (stato()?.esecuzione?.id === s.esecuzione?.id) aggiorna((x) => (x.issue.item = item));
  }
  const r = await gh(['project', 'item-edit', '--id', item, '--project-id', cfg.project_id, '--field-id', cfg.campo_id, '--single-select-option-id', opzione]);
  if (r.code) stampa(`(avviso: colonna del Project non cambiata: ${r.testo.trim().slice(0, 200)})`);
  else if (stato()?.esecuzione?.id === s.esecuzione?.id) aggiorna((x) => (x.issue.colonna = nome));
}

// ---------- piano ----------

function leggiPiano(s) {
  const piano = leggiJson(path.join(cartellaRun(s), 'piano.json'));
  if (!piano?.tasks?.length) throw new Error(`Manca il piano: scrivi ${path.join(cartellaRun(s), 'piano.json')}`);
  return piano;
}

/**
 * Stima prudente: ~6 richieste di base + 2 per file, più un 30% per i tentativi ripetuti.
 * (Prove del 22/11: 6-8 richieste anche per un worker con compiti minimi.)
 */
function stimaRichieste(piano) {
  const base = piano.tasks.filter((t) => !t.manuale && !t.claude).reduce((n, t) => n + 6 + 2 * (t.file?.length || 1), 0);
  return Math.ceil(base * 1.3);
}

function chiTask(t) {
  if (t.manuale) return 'a mano (Dreamina)';
  if (t.claude) return 'Claude';
  return t.modello;
}

function pianoMarkdown(s, piano, stima) {
  const q = s.quota;
  const righe = [
    `# Piano ${s.esecuzione.id} – ${s.esecuzione.nome}`,
    '',
    `**Richiesta:** ${s.esecuzione.richiesta}`,
    '',
    `**Richieste OpenRouter stimate:** ~${stima}` + (q ? ` (oggi ne restano ${q.rimaste} su ${q.limite})` : ''),
    '',
    '| Task | Tipo | Chi lo fa | File |',
    '|---|---|---|---|',
    ...piano.tasks.map((t) => `| ${t.id} – ${t.titolo} | ${t.tipo} | ${chiTask(t)} | ${(t.file || []).map((f) => '`' + f + '`').join(', ')} |`),
    '',
  ];
  for (const t of piano.tasks) {
    righe.push(`## ${t.id} – ${t.titolo}`, '', `- **Obiettivo:** ${t.obiettivo}`, `- **File:** ${(t.file || []).map((f) => '`' + f + '`').join(', ')}`, `- **Fatto quando:** ${t.fatto}`);
    if (t.manuale) righe.push(`- **A mano con Dreamina.** Prompt: ${t.prompt_dreamina}`, `- **Dove mettere il file:** \`${t.destinazione}\``);
    else if (t.claude) righe.push(`- **Lo fa Claude** (${t.perche_claude || 'compito delicato'})`);
    else righe.push(`- **Modello:** \`${t.modello}\` (riserva: \`${t.riserva}\`)`);
    righe.push('');
  }
  return righe.join('\n');
}

function checklist(piano) {
  return piano.tasks.map((t) => `- [ ] **${t.id}** – ${t.titolo} · ${chiTask(t)}`).join('\n');
}

// ---------- worker ----------

function promptWorker(t, motivoPrecedente) {
  return [
    `Sei un worker del progetto Avidididadi (app Flutter/Dart per Android). Fai UN SOLO compito e poi fermati.`,
    '',
    `## Compito ${t.id}: ${t.titolo}`,
    `Obiettivo: ${t.obiettivo}`,
    `File che puoi modificare (SOLO questi): ${(t.file || []).join(', ')}`,
    `Fatto quando: ${t.fatto}`,
    t.istruzioni ? `Istruzioni: ${t.istruzioni}` : '',
    motivoPrecedente ? `\nATTENZIONE: un tentativo precedente è fallito per questo motivo, evitalo:\n${motivoPrecedente}` : '',
    '',
    '## Regole del progetto',
    '- Nomi in italiano: classi PascalCase, funzioni e variabili camelCase, privati con _.',
    '- Commenti brevi in italiano, con /// sopra classi e funzioni pubbliche, che spiegano il PERCHÉ.',
    '- Nessun testo visibile scritto fisso nel codice: va in lib/l10n/app_it.arb e app_en.arb con gli stessi segnaposto {p0}; poi esegui `flutter gen-l10n`.',
    '- Nessun colore fisso nei widget: usa Theme.of(context).colorScheme, Pulse.di(context), coloreSport(sport).',
    '- Avvisi con avviso(...) (lib/avviso.dart), mai SnackBar. Nessuna nuova dipendenza.',
    '- I valori salvati nei CSV restano in italiano; le colonne nuove vanno in fondo.',
    '- Non toccare file fuori dall\'elenco. Non fare commit, push o altri comandi git che cambiano qualcosa: ci pensa l\'orchestratore. Ignora le regole Git di CLAUDE.md.',
    '- Quando hai finito esegui `dart format` sui file cambiati e `flutter analyze`, e correggi i problemi che riguardano i tuoi file. I test (`flutter test`) li lancia l\'orchestratore dopo di te: tu non puoi.',
    '- Chiudi con un riassunto di 2-3 righe di cosa hai cambiato.',
  ]
    .filter((r) => r !== '')
    .join('\n');
}

/** Legge gli eventi JSON di OpenCode: richieste fatte, errori, ultimo testo. */
function leggiEventi(file, daByte) {
  const testo = fs.existsSync(file) ? fs.readFileSync(file, 'utf8').slice(daByte) : '';
  const ev = { richieste: 0, errore: null, limite: false, testo: '' };
  for (const riga of testo.split('\n')) {
    let j;
    try {
      j = JSON.parse(riga);
    } catch {
      continue;
    }
    if (j.type === 'step_finish') ev.richieste++;
    if (j.type === 'text' && j.part?.text) ev.testo = j.part.text;
    if (j.type === 'error') {
      const msg = j.error?.data?.message || j.error?.message || JSON.stringify(j.error);
      ev.errore = String(msg).slice(0, 300);
      if (/rate.?limit|429|too many requests/i.test(msg)) ev.limite = true;
    }
  }
  return ev;
}

async function lanciaWorker(t, modello, wt, exe, motivoPrecedente, tentativo, s) {
  const dir = cartellaRun(s);
  const log = path.join(dir, `${t.id}-tentativo${tentativo}.jsonl`);
  const prompt = promptWorker(t, motivoPrecedente);
  fs.writeFileSync(path.join(dir, `${t.id}-prompt${tentativo}.md`), prompt);
  let richieste = 0;
  const t0 = Date.now();
  for (let giro = 0; giro < 2; giro++) {
    const daByte = fs.existsSync(log) ? fs.statSync(log).size : 0;
    const r = await esegui(exe, ['run', '--agent', 'worker', '-m', `openrouter/${modello}`, '--format', 'json', '--title', `${s.esecuzione.id} ${t.id}`, prompt], {
      cwd: wt,
      env: ENV_WORKER,
      out: log,
      timeoutMs: TIMEOUT_WORKER_MIN * 60000,
    });
    const ev = leggiEventi(log, daByte);
    richieste += ev.richieste;
    const secondi = Math.round((Date.now() - t0) / 1000);
    if (r.scaduto) return { ok: false, motivo: `il worker non ha finito entro ${TIMEOUT_WORKER_MIN} minuti`, richieste, secondi };
    if (ev.limite) {
      // Il 429 può essere il limite del giorno: allora aspettare o cambiare modello non serve.
      const q = await aggiornaQuota();
      if (q && q.rimaste <= 0) return { ok: false, finite: true, motivo: 'richieste gratuite di oggi finite', richieste, secondi };
    }
    if (ev.limite && giro === 0) {
      aggiornaTask(t.id, { stato: 'in pausa (429)' });
      stampa(`${t.id}: ${modello} sovraccarico (429), aspetto ${ATTESA_429_S} s e riprovo una volta`);
      await attendi(ATTESA_429_S * 1000);
      aggiornaTask(t.id, { stato: 'al lavoro' });
      continue;
    }
    if (ev.limite) return { ok: false, motivo: `${modello} sovraccarico (429) anche dopo l'attesa`, richieste, secondi };
    if (ev.errore) return { ok: false, motivo: `errore di OpenCode: ${ev.errore}`, richieste, secondi };
    if (r.code !== 0) return { ok: false, motivo: `OpenCode è uscito con codice ${r.code}`, richieste, secondi };
    return { ok: true, richieste, secondi, riassunto: ev.testo };
  }
}

// ---------- controlli ----------

function consentito(f, file) {
  const ff = f.replace(/\\/g, '/');
  if ((file || []).some((p) => (p.endsWith('/') ? ff.startsWith(p) : ff === p))) return true;
  // Se il task cambia gli ARB, i file generati da flutter gen-l10n seguono.
  return (file || []).some((p) => p.endsWith('.arb')) && /^lib\/l10n\/app_localizations.*\.dart$/.test(ff);
}

async function fileCambiati(wt) {
  const r = await git(['status', '--porcelain', '-uall'], wt);
  return r.testo
    .split('\n')
    .filter((x) => x.trim())
    .map((x) => ({ codice: x.slice(0, 2), file: x.slice(3).split(' -> ').pop().replace(/^"|"$/g, '') }));
}

/** Controlli sul lavoro di un worker: file giusti, formattazione, analisi, test. */
async function controlla(t, wt, log, { daClaude = false } = {}) {
  let cambi = await fileCambiati(wt);
  if (!cambi.length) return { ok: false, motivo: 'il worker non ha cambiato nessun file' };
  const proibiti = daClaude ? [] : cambi.filter((c) => vietato(c.file));
  if (proibiti.length) return { ok: false, motivo: `ha toccato file vietati: ${proibiti.map((c) => c.file).join(', ')}` };
  const fuori = daClaude ? [] : cambi.filter((c) => !consentito(c.file, t.file));
  let nota = '';
  if (fuori.length) {
    for (const c of fuori) {
      if (c.codice === '??') fs.rmSync(path.join(wt, c.file), { force: true });
      else await git(['checkout', 'HEAD', '--', c.file], wt);
    }
    nota = `annullate modifiche fuori dal compito: ${fuori.map((c) => c.file).join(', ')}`;
    cambi = await fileCambiati(wt);
    if (!cambi.length) return { ok: false, motivo: `ha cambiato solo file fuori dal compito (${fuori.map((c) => c.file).join(', ')})` };
  }
  fs.appendFileSync(log, `\n=== Controlli ${t.id} ${ora()}\n`);
  await flutter(['pub', 'get'], wt, log);
  if (cambi.some((c) => c.file.endsWith('.arb'))) await flutter(['gen-l10n'], wt, log);
  const dartFile = (await fileCambiati(wt)).map((c) => c.file).filter((f) => f.endsWith('.dart') && fs.existsSync(path.join(wt, f)));
  if (dartFile.length) await dart(['format', ...dartFile], wt, log);
  const an = await flutter(['analyze'], wt);
  fs.appendFileSync(log, an.testo);
  if (!/No issues found/.test(an.testo)) {
    const problemi = an.testo.split('\n').filter((r) => /(error|warning|info) •/.test(r)).slice(0, 12).join('\n');
    return { ok: false, motivo: `flutter analyze ha trovato problemi:\n${problemi}`, nota };
  }
  const te = await flutter(['test'], wt);
  fs.appendFileSync(log, te.testo.slice(-20000));
  if (te.code !== 0 || !/All tests passed/.test(te.testo)) {
    const fallimenti = te.testo.split('\n').filter((r) => /\[E\]|Expected:|Actual:|Some tests failed/.test(r)).slice(0, 12).join('\n');
    return { ok: false, motivo: `flutter test non passa:\n${fallimenti}`, nota };
  }
  return { ok: true, nota };
}

async function committa(t, wt, chi) {
  await git(['add', '-A'], wt);
  const r = await git(['commit', '-q', '-m', `${t.titolo} (${t.id})`, '-m', `Orchestra: lavoro di ${chi}.`], wt);
  return r.code === 0 ? null : r.testo.trim().slice(0, 400);
}

/**
 * Cartella di lavoro di un task: un clone separato (non un git worktree).
 * OpenCode riconosce il progetto dalla cartella .git condivisa: con un
 * worktree prendeva la cartella principale come radice e i worker potevano
 * scriverci (successo il 22/11). Un clone con la sua .git e un codice di
 * progetto unico in .git/opencode resta un progetto a sé.
 */
async function preparaWorktree(s, t) {
  const wt = path.join(WT_ROOT, s.esecuzione.id, t.id);
  const branch = `orchestra/${s.esecuzione.id}/${t.id}`;
  if (!fs.existsSync(wt)) {
    fs.mkdirSync(path.dirname(wt), { recursive: true });
    const c = await git(['clone', '-q', '--shared', '--no-checkout', REPO, wt]);
    if (c.code) throw new Error(`clone non creato per ${t.id}: ${c.testo.trim()}`);
    const r = await git(['checkout', '-q', '-B', branch, s.esecuzione.base_commit], wt);
    if (r.code) throw new Error(`branch non creato per ${t.id}: ${r.testo.trim()}`);
    fs.writeFileSync(path.join(wt, '.git', 'opencode'), randomBytes(20).toString('hex'));
    // Stessa identità e stesso controllo pre-commit della cartella principale.
    for (const k of ['user.name', 'user.email']) {
      const v = (await git(['config', '--get', k])).testo.trim();
      if (v) await git(['config', k, v], wt);
    }
    await git(['config', 'core.hooksPath', 'tool/git-hooks'], wt);
  }
  aggiornaTask(t.id, { branch, cartella: wt });
  return wt;
}

/** Fotografia della cartella principale: i worker non devono mai cambiarla. */
const fotoRepo = async () => (await git(['status', '--porcelain', '-uall'])).testo;
let fotoIniziale = null;
/** Diventa vero se la cartella principale cambia durante il lavoro dei worker. */
let allarme = false;

/** Diventa vero quando OpenRouter dice che le richieste gratuite di oggi sono finite. */
let richiesteFinite = false;

async function eseguiTask(t, exe) {
  if (richiesteFinite || allarme) return;
  const s = stato();
  const log = path.join(cartellaRun(s), `${t.id}-controlli.log`);
  let wt;
  try {
    wt = await preparaWorktree(s, t);
  } catch (e) {
    aggiornaTask(t.id, { stato: 'fallito', nota: e.message });
    await segnaErrore(e.message);
    return;
  }
  const modelli = [t.modello, t.riserva].filter(Boolean);
  let motivo = null;
  for (let i = 0; i < modelli.length; i++) {
    const m = modelli[i];
    await git(['reset', '-q', '--hard', s.esecuzione.base_commit], wt);
    await git(['clean', '-fdq'], wt);
    aggiornaTask(t.id, { stato: 'al lavoro', modello: m, tentativi: i + 1, inizio: ora() });
    stampa(`${t.id}: tentativo ${i + 1} con ${m}`);
    const w = await lanciaWorker(t, m, wt, exe, motivo, i + 1, s);
    sommaTask(t.id, { richieste: w.richieste, secondi: w.secondi });
    if (fotoIniziale !== null && (await fotoRepo()) !== fotoIniziale) {
      allarme = true;
      const msg = `ALLARME: la cartella principale del progetto è cambiata mentre lavorava ${t.id} (${m}). Corsa fermata: controlla "git status" prima di tutto.`;
      stampa(msg);
      aggiornaTask(t.id, { stato: 'fallito', fine: ora(), nota: msg });
      await spunta(t.id, false, 'fermato per sicurezza');
      await segnaErrore(msg);
      return;
    }
    const q = await aggiornaQuota();
    if (w.finite || (!w.ok && q && q.rimaste <= 0)) {
      richiesteFinite = true;
      aggiornaTask(t.id, { stato: 'in attesa', nota: 'Fermato: richieste gratuite di oggi finite. Riprendi domani con "lancia".' });
      return;
    }
    if (!w.ok) {
      motivo = w.motivo;
      stampa(`${t.id}: ${m} non ce l'ha fatta: ${motivo}`);
      aggiornaTask(t.id, { nota: motivo });
      continue;
    }
    aggiornaTask(t.id, { stato: 'controlli', riassunto: (w.riassunto || '').slice(0, 600) });
    const c = await inCoda(() => controlla(t, wt, log));
    if (c.ok) {
      const errCommit = await committa(t, wt, `${m} (OpenCode)`);
      if (errCommit) {
        motivo = `commit rifiutato: ${errCommit}`;
        continue;
      }
      aggiornaTask(t.id, { stato: 'fatto', fine: ora(), nota: c.nota || null });
      stampa(`${t.id}: fatto con ${m}`);
      await spunta(t.id, true);
      return;
    }
    motivo = c.motivo;
    stampa(`${t.id}: controlli non superati con ${m}: ${motivo.split('\n')[0]}`);
    aggiornaTask(t.id, { nota: motivo });
  }
  aggiornaTask(t.id, { stato: 'fallito', fine: ora(), nota: motivo });
  await spunta(t.id, false, (motivo || '').split('\n')[0].slice(0, 120));
  await segnaErrore(`${t.id} (${t.titolo}) non riuscito dopo ${modelli.length} tentativi: ${(motivo || '').split('\n')[0]}`);
}

// ---------- comandi ----------

const comandi = {
  aiuto() {
    stampa(`Comandi (in ordine d'uso):
  riordina                          chiude le issue delle corse con la PR già unita
  nuova "<richiesta>" <nome-breve>   crea la corsa e agents/status.json
  quota                             richieste gratuite di oggi
  pannello                          rifà agents/pannello.json (riassunto per la pagina su claude.ai)
  modelli                           controlla che i modelli di models.json siano ancora gratuiti
  piano                             valida runs/<id>/piano.json, scrive piano.md e la stima
  issue [--aggiorna]                crea (o aggiorna) la issue con piano e checklist
  lancia [--paralleli 2] [--solo t1,t2]   worker + controlli + commit, con un'altra prova se fallisce
  prepara <task>                    crea il worktree di un task da fare a mano o da Claude
  completa <task> [chi]             controlli e commit di un task fatto fuori dai worker
  unisci                            unisce i task fatti in feature/<nome> (worktree "unione")
  verifica                          format, analyze, test e build apk --debug sull'unione
  pr                                push e pull request verso ${BASE} (con Closes #issue)
  pulisci                           toglie i worktree e scrive log.md
  fase <nome> ["commento"] | errore "<testo>" | commenta "<testo>" | colonna "<nome>"
  task <id> <stato> ["nota"] | stato | annulla`);
  },

  async nuova(richiesta, nome) {
    if (!richiesta || !/^[a-z0-9][a-z0-9-]{1,39}$/.test(nome || '')) throw new Error('Uso: nuova "<richiesta>" <nome-breve-con-trattini>');
    const s = stato();
    if (s?.esecuzione && !['finita', 'annullata'].includes(s.esecuzione.fase)) {
      throw new Error(`C'è già la corsa ${s.esecuzione.id} in fase "${s.esecuzione.fase}": finiscila o usa "annulla".`);
    }
    const d = new Date();
    const id = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}_${pad(d.getHours())}${pad(d.getMinutes())}`;
    fs.mkdirSync(path.join(RUNS, id), { recursive: true });
    const base = (await git(['rev-parse', BASE])).testo.trim();
    const q = await leggiQuota();
    const cfg = leggiJson(GITHUB_CFG);
    scriviJson(STATUS, {
      esecuzione: { id, nome, richiesta, fase: 'piano', inizio: ora(), fine: null, base: BASE, base_commit: base, branch: null },
      fasi: [{ fase: 'piano', da: ora() }],
      tasks: [],
      quota: q,
      quota_inizio: q,
      stima_richieste: null,
      ultimo_errore: null,
      issue: null,
      pr: null,
      progetto: cfg?.url || null,
      aggiornato: ora(),
    });
    aggiorna(() => {});
    stampa(`Corsa ${id} creata. Scrivi il piano in ${path.join(RUNS, id, 'piano.json')}`);
    if (q) stampa(`Richieste gratuite rimaste oggi: ${q.rimaste} su ${q.limite}`);
  },

  /** Rifà agents/pannello.json con la quota appena letta (anche senza corse in corso). */
  async pannello() {
    const q = await leggiQuota();
    const s = stato() || {};
    if (q) s.quota = q;
    scriviPannello(s);
    stampa(PANNELLO);
  },

  async quota() {
    const q = await aggiornaQuota();
    stampa(q ? `Richieste gratuite oggi: usate ${q.usate}, rimaste ${q.rimaste} su ${q.limite}` : 'Quota non leggibile (manca OPENROUTER_API_KEY o OpenRouter non risponde).');
  },

  async modelli() {
    const reg = leggiJson(MODELS);
    const liberi = await modelliGratuiti();
    for (const m of reg.modelli) stampa(`${liberi.has(m.id) ? '✅' : '❌'} ${m.id}${liberi.has(m.id) ? '' : '  (non è più gratuito: aggiorna models.json)'}`);
    const nuovi = [...liberi].filter((id) => !reg.modelli.some((m) => m.id === id) && !(id in (reg.scartati || {})));
    if (nuovi.length) stampa(`Nuovi modelli gratuiti mai valutati: ${nuovi.join(', ')}`);
  },

  async piano() {
    const s = esecuzioneCorrente();
    const piano = leggiPiano(s);
    const reg = leggiJson(MODELS);
    const noti = new Set(reg.modelli.map((m) => m.id));
    let liberi = null;
    try {
      liberi = await modelliGratuiti();
    } catch {
      /* offline: salto il controllo */
    }
    const bloccanti = [];
    const avvisi = [];
    const visti = new Map();
    const ids = new Set();
    for (const t of piano.tasks) {
      if (!/^t\d+$/.test(t.id) || ids.has(t.id)) bloccanti.push(`id non valido o ripetuto: ${t.id}`);
      ids.add(t.id);
      for (const k of ['titolo', 'tipo', 'obiettivo', 'fatto']) if (!t[k]) bloccanti.push(`${t.id}: manca "${k}"`);
      if (!t.file?.length) bloccanti.push(`${t.id}: manca l'elenco "file"`);
      if (!t.manuale && !t.claude) {
        if (!t.modello || !t.riserva) bloccanti.push(`${t.id}: servono "modello" e "riserva"`);
        if (t.modello === t.riserva) avvisi.push(`${t.id}: modello e riserva sono uguali`);
        for (const m of [t.modello, t.riserva].filter(Boolean)) {
          if (!noti.has(m)) bloccanti.push(`${t.id}: ${m} non è in models.json`);
          if (liberi && !liberi.has(m)) bloccanti.push(`${t.id}: ${m} non è più gratuito su OpenRouter`);
        }
        for (const f of t.file || []) if (vietato(f)) bloccanti.push(`${t.id}: ${f} è vietato ai worker (fallo fare a Claude con "claude": true)`);
      }
      if (t.manuale && (!t.prompt_dreamina || !t.destinazione)) bloccanti.push(`${t.id}: un task a mano vuole "prompt_dreamina" e "destinazione"`);
      for (const f of t.file || []) {
        if (visti.has(f)) avvisi.push(`${t.id} e ${visti.get(f)} toccano lo stesso file ${f}: possibili conflitti`);
        else visti.set(f, t.id);
      }
    }
    const q = (await aggiornaQuota()) || s.quota;
    const stima = stimaRichieste(piano);
    if (q && stima > q.rimaste) avvisi.push(`⚠️ La stima (~${stima}) supera le richieste rimaste oggi (${q.rimaste}): rischi di fermarti a metà.`);
    else if (q && stima > q.rimaste * 0.7) avvisi.push(`La stima (~${stima}) usa gran parte delle richieste rimaste (${q.rimaste}).`);
    const md = pianoMarkdown(stato(), piano, stima);
    fs.writeFileSync(path.join(cartellaRun(s), 'piano.md'), md);
    const prima = new Map((s.tasks || []).map((t) => [t.id, t]));
    aggiorna((x) => {
      x.stima_richieste = stima;
      x.tasks = piano.tasks.map((t) => ({
        id: t.id,
        titolo: t.titolo,
        tipo: t.tipo,
        chi: chiTask(t),
        modello: t.manuale || t.claude ? chiTask(t) : t.modello,
        riserva: t.riserva || null,
        stato: prima.get(t.id)?.stato === 'fatto' ? 'fatto' : t.manuale ? 'a mano' : 'in attesa',
        tentativi: 0,
        secondi: 0,
        richieste: 0,
        nota: null,
      }));
      if (!bloccanti.length && x.esecuzione.fase === 'piano') {
        x.esecuzione.fase = 'approvazione';
        x.fasi.push({ fase: 'approvazione', da: ora() });
      }
    });
    stampa(md);
    if (avvisi.length) stampa('\nAvvisi:\n- ' + avvisi.join('\n- '));
    if (bloccanti.length) {
      stampa('\nDa correggere prima di andare avanti:\n- ' + bloccanti.join('\n- '));
      process.exitCode = 2;
    }
  },

  async issue(opzione) {
    const s = esecuzioneCorrente();
    const piano = leggiPiano(s);
    const md = fs.readFileSync(path.join(cartellaRun(s), 'piano.md'), 'utf8');
    const corpo = `${md}\n## Checklist\n\n${checklist(piano)}\n\n---\nStato aggiornato in \`agents/status.json\`. Creata da \`/orchestra\`.\n`;
    const f = path.join(cartellaRun(s), 'issue-corpo.md');
    fs.writeFileSync(f, corpo);
    if (opzione === '--aggiorna' && s.issue?.numero) {
      await gh(['issue', 'edit', String(s.issue.numero), '--body-file', f]);
      await commenta('📝 Piano modificato.');
      return stampa(`Issue #${s.issue.numero} aggiornata.`);
    }
    await gh(['label', 'create', 'orchestra', '--color', '5319E7', '--description', 'Esecuzioni di /orchestra', '--force']);
    const r = await gh(['issue', 'create', '--title', `Orchestra: ${s.esecuzione.nome} (${s.esecuzione.id})`, '--label', 'orchestra', '--body-file', f]);
    const url = r.testo.trim().split('\n').pop();
    const numero = Number((url.match(/\/issues\/(\d+)/) || [])[1]);
    if (r.code || !numero) throw new Error(`Issue non creata: ${r.testo.trim()}`);
    aggiorna((x) => (x.issue = { numero, url, item: null, colonna: null }));
    await commenta('📋 Piano pronto: aspetta l\'approvazione in Claude Code.');
    await colonna('Da approvare');
    stampa(`Issue #${numero}: ${url}`);
  },

  async lancia(...arg) {
    const s = esecuzioneCorrente();
    const piano = leggiPiano(s);
    const iP = arg.indexOf('--paralleli');
    const paralleli = Math.min(3, Math.max(1, iP >= 0 ? Number(arg[iP + 1]) || 2 : 2));
    const iS = arg.indexOf('--solo');
    const solo = iS >= 0 ? arg[iS + 1].split(',') : null;
    const fatti = new Set(s.tasks.filter((t) => t.stato === 'fatto').map((t) => t.id));
    const coda = piano.tasks.filter((t) => !t.manuale && !t.claude && !fatti.has(t.id) && (!solo || solo.includes(t.id)));
    if (!coda.length) return stampa('Nessun task da dare ai worker.');
    const q = await aggiornaQuota();
    if (q && q.rimaste < 5) throw new Error(`Restano solo ${q.rimaste} richieste gratuite oggi: meglio riprovare domani.`);
    await impostaFase('worker', `🚀 Worker avviati: ${coda.map((t) => t.id).join(', ')} (massimo ${paralleli} insieme).`);
    await colonna('In corso');
    const exe = opencodeExe();
    fotoIniziale = await fotoRepo();
    await Promise.all(
      Array.from({ length: Math.min(paralleli, coda.length) }, async () => {
        while (coda.length) await eseguiTask(coda.shift(), exe);
      }),
    );
    const fine = stato();
    const riga = (t) => `${t.stato === 'fatto' ? '✅' : t.stato === 'fallito' ? '❌' : '⏸️'} ${t.id} ${t.titolo} · ${t.modello} · tentativi ${t.tentativi} · ${t.richieste} richieste · ${t.secondi}s`;
    const resoconto = fine.tasks.map(riga).join('\n');
    if (richiesteFinite) {
      await segnaErrore('Richieste gratuite di oggi finite: i task rimasti sono in attesa. Si riprende domani con "lancia".');
    }
    await commenta(`🔎 Worker finiti, controlli fatti:\n\n${resoconto}`);
    stampa(resoconto);
    if (fine.quota) stampa(`Richieste rimaste oggi: ${fine.quota.rimaste} su ${fine.quota.limite}`);
  },

  async prepara(id) {
    const s = esecuzioneCorrente();
    const t = leggiPiano(s).tasks.find((x) => x.id === id);
    if (!t) throw new Error(`Task ${id} non trovato`);
    const wt = await preparaWorktree(s, t);
    aggiornaTask(id, { stato: 'al lavoro', inizio: ora() });
    stampa(wt);
  },

  async completa(id, chi = 'Claude') {
    const s = esecuzioneCorrente();
    const t = leggiPiano(s).tasks.find((x) => x.id === id);
    const st = s.tasks.find((x) => x.id === id);
    if (!t || !st?.cartella) throw new Error(`Task ${id} senza worktree: usa prima "prepara ${id}"`);
    aggiornaTask(id, { stato: 'controlli' });
    const c = await inCoda(() => controlla(t, st.cartella, path.join(cartellaRun(s), `${id}-controlli.log`), { daClaude: chi === 'Claude' }));
    if (!c.ok) {
      aggiornaTask(id, { stato: 'fallito', nota: c.motivo });
      stampa(c.motivo);
      process.exitCode = 1;
      return;
    }
    const err = await committa(t, st.cartella, chi);
    if (err) throw new Error(err);
    aggiornaTask(id, { stato: 'fatto', fine: ora(), modello: chi, nota: c.nota || null });
    await spunta(id, true);
    stampa(`${id}: fatto (${chi})`);
  },

  async unisci() {
    const s = esecuzioneCorrente();
    const fatti = s.tasks.filter((t) => t.stato === 'fatto');
    if (!fatti.length) throw new Error('Nessun task fatto da unire.');
    const wt = path.join(WT_ROOT, s.esecuzione.id, 'unione');
    let branch = s.esecuzione.branch;
    if (!fs.existsSync(wt)) {
      branch = `feature/${s.esecuzione.nome}`;
      for (let n = 2; ; n++) {
        const locale = (await git(['rev-parse', '--verify', '-q', branch])).code === 0;
        const remoto = (await git(['ls-remote', '--exit-code', '--heads', 'origin', branch])).code === 0;
        if (!locale && !remoto) break;
        branch = `feature/${s.esecuzione.nome}-${n}`;
      }
      const r = await git(['worktree', 'add', '-q', '-b', branch, wt, s.esecuzione.base_commit]);
      if (r.code) throw new Error(r.testo);
      aggiorna((x) => {
        x.esecuzione.branch = branch;
        x.esecuzione.cartella_unione = wt;
      });
      await impostaFase('unione', `🔀 Unisco ${fatti.length} task in \`${branch}\`.`);
    }
    if (fs.existsSync(path.join(wt, '.git')) && (await git(['rev-parse', '-q', '--verify', 'MERGE_HEAD'], wt)).code === 0) {
      throw new Error(`Unione in sospeso in ${wt}: risolvi i conflitti e fai commit, poi rilancia "unisci".`);
    }
    for (const t of fatti) {
      // Il branch del task sta nel suo clone: lo porto nella repo principale.
      if (t.cartella && fs.existsSync(path.join(t.cartella, '.git'))) {
        const f = await git(['fetch', '-q', t.cartella, `+${t.branch}:${t.branch}`]);
        if (f.code) throw new Error(`Non riesco a prendere ${t.branch} da ${t.id}: ${f.testo.trim()}`);
      }
      if ((await git(['merge-base', '--is-ancestor', t.branch, 'HEAD'], wt)).code === 0) continue;
      const r = await git(['merge', '--no-ff', '-q', '-m', `Unisce ${t.id}: ${t.titolo}`, t.branch], wt);
      if (r.code) {
        const conf = (await git(['diff', '--name-only', '--diff-filter=U'], wt)).testo.trim();
        await segnaErrore(`Conflitto unendo ${t.id}: ${conf.split('\n').join(', ')}`);
        stampa(`CONFLITTO con ${t.id} in ${wt}\nFile: ${conf}\nRisolvi, fai commit e rilancia "unisci".`);
        process.exitCode = 3;
        return;
      }
      stampa(`Unito ${t.id}`);
    }
    stampa(`Tutti i task fatti sono in ${branch} (${wt}).`);
  },

  async verifica() {
    const s = esecuzioneCorrente();
    const wt = s.esecuzione.cartella_unione;
    if (!wt) throw new Error('Prima "unisci".');
    await impostaFase('controlli', '🧪 Controlli finali: formattazione, analisi, test e APK di debug.');
    const log = path.join(cartellaRun(s), 'verifica.log');
    fs.writeFileSync(log, `Verifica ${ora()}\n`);
    const esiti = {};
    await flutter(['pub', 'get'], wt, log);
    const cambiati = (await git(['diff', '--name-only', s.esecuzione.base_commit, 'HEAD'], wt)).testo;
    if (/\.arb/.test(cambiati)) {
      await flutter(['gen-l10n'], wt, log);
      esiti.testi_generati = (await git(['status', '--porcelain'], wt)).testo.trim() === '';
    }
    const fo = await dart(['format', '--output=none', '--set-exit-if-changed', 'lib', 'test'], wt);
    esiti.formattazione = fo.code === 0;
    const an = await flutter(['analyze'], wt);
    esiti.analisi = /No issues found/.test(an.testo);
    const te = await flutter(['test'], wt);
    esiti.test = te.code === 0 && /All tests passed/.test(te.testo);
    fs.appendFileSync(log, fo.testo + an.testo + te.testo.slice(-20000));
    const bu = await flutter(['build', 'apk', '--debug'], wt, log);
    esiti.build_debug = bu.code === 0;
    aggiorna((x) => (x.verifica = { ...esiti, quando: ora() }));
    const ok = Object.values(esiti).every(Boolean);
    const testo = Object.entries(esiti).map(([k, v]) => `${v ? '✅' : '❌'} ${k.replace('_', ' ')}`).join(' · ');
    await commenta(`${ok ? '✅' : '❌'} Controlli finali: ${testo}`);
    if (!ok) await segnaErrore(`Controlli finali non superati (dettagli in agents/runs/${s.esecuzione.id}/verifica.log)`);
    stampa(testo);
    process.exitCode = ok ? 0 : 1;
  },

  async pr() {
    const s = esecuzioneCorrente();
    const { branch, cartella_unione: wt } = s.esecuzione;
    if (!s.verifica || !Object.entries(s.verifica).every(([k, v]) => k === 'quando' || v)) throw new Error('Prima "verifica" deve passare.');
    const p = await git(['push', '-q', '-u', 'origin', branch], wt);
    if (p.code) throw new Error(`Push non riuscito: ${p.testo.trim()}`);
    const note = leggiFile(path.join(cartellaRun(s), 'pr-note.md'));
    const tabella = [
      '| Task | Fatto da | Tentativi | Richieste | Esito |',
      '|---|---|---|---|---|',
      ...s.tasks.map((t) => `| ${t.id} – ${t.titolo} | ${t.modello} | ${t.tentativi || '-'} | ${t.richieste || 0} | ${t.stato === 'fatto' ? '✅' : '❌ ' + (t.nota || '').split('\n')[0]} |`),
    ].join('\n');
    const corpo = [
      `Richiesta: ${s.esecuzione.richiesta}`,
      '',
      '## Cosa è stato fatto',
      '',
      tabella,
      '',
      note || '',
      '',
      `Controlli: formattazione, \`flutter analyze\`, \`flutter test\` e APK di debug passati.`,
      '',
      s.issue?.numero ? `Closes #${s.issue.numero}` : '',
      '',
      '🤖 Generated with [Claude Code](https://claude.com/claude-code)',
    ].join('\n');
    const f = path.join(cartellaRun(s), 'pr-corpo.md');
    fs.writeFileSync(f, corpo);
    const r = await gh(['pr', 'create', '--base', BASE, '--head', branch, '--title', leggiPiano(s).titolo_pr || `Orchestra: ${s.esecuzione.nome}`, '--body-file', f], wt);
    const url = r.testo.trim().split('\n').pop();
    if (r.code || !/\/pull\/\d+/.test(url)) throw new Error(`PR non creata: ${r.testo.trim()}`);
    aggiorna((x) => (x.pr = { url, numero: Number(url.match(/\/pull\/(\d+)/)[1]) }));
    await impostaFase('pr', `📬 Pull request aperta: ${url} — tocca a te revisionarla.`);
    await colonna('Da revisionare');
    stampa(url);
  },

  async pulisci() {
    const s = esecuzioneCorrente();
    await impostaFase('pulizia');
    const cartella = path.join(WT_ROOT, s.esecuzione.id);
    const wts = fs.existsSync(cartella) ? fs.readdirSync(cartella).map((d) => path.join(cartella, d)) : [];
    // "unione" è un worktree; le cartelle dei task sono cloni e si cancellano e basta.
    for (const wt of wts) if (fs.statSync(path.join(wt, '.git'), { throwIfNoEntry: false })?.isFile()) await git(['worktree', 'remove', '--force', wt]);
    await git(['worktree', 'prune']);
    for (const t of s.tasks) if (t.branch) await git(['branch', '-D', t.branch]);
    fs.rmSync(cartella, { recursive: true, force: true });
    const q = (await aggiornaQuota()) || s.quota;
    const usate = q && s.quota_inizio ? q.usate - s.quota_inizio.usate : null;
    const fine = stato();
    const log = [
      `# Log ${s.esecuzione.id} – ${s.esecuzione.nome}`,
      '',
      `- **Richiesta:** ${s.esecuzione.richiesta}`,
      `- **Inizio:** ${s.esecuzione.inizio} · **Fine:** ${ora()}`,
      `- **Branch:** ${s.esecuzione.branch || '-'} · **Issue:** ${s.issue?.url || '-'} · **PR:** ${s.pr?.url || '-'}`,
      `- **Richieste OpenRouter:** stimate ~${s.stima_richieste ?? '?'}, usate ${usate ?? '?'}` + (q ? ` (rimaste oggi ${q.rimaste} su ${q.limite})` : ''),
      '',
      '| Task | Modello | Tentativi | Richieste | Tempo | Esito |',
      '|---|---|---|---|---|---|',
      ...fine.tasks.map((t) => `| ${t.id} – ${t.titolo} | ${t.modello} | ${t.tentativi || '-'} | ${t.richieste || 0} | ${t.secondi || 0}s | ${t.stato}${t.nota ? ' – ' + t.nota.split('\n')[0] : ''} |`),
      '',
    ].join('\n');
    fs.writeFileSync(path.join(cartellaRun(s), 'log.md'), log);
    aggiorna((x) => {
      x.esecuzione.fine = ora();
      x.richieste_usate = usate;
    });
    await impostaFase('finita');
    stampa(log);
  },

  /** Chiude le issue delle corse la cui PR è stata unita (verso staging GitHub non lo fa da solo). */
  async riordina() {
    if (!fs.existsSync(RUNS)) return stampa('Nessuna corsa passata.');
    let n = 0;
    for (const d of fs.readdirSync(RUNS)) {
      const s = leggiJson(path.join(RUNS, d, 'stato.json'));
      if (!s?.issue?.numero || !s?.pr?.numero) continue;
      const iss = await gh(['issue', 'view', String(s.issue.numero), '--json', 'state', '-q', '.state']);
      if (iss.testo.trim() !== 'OPEN') continue;
      const pr = await gh(['pr', 'view', String(s.pr.numero), '--json', 'state', '-q', '.state']);
      const st = pr.testo.trim();
      if (st === 'MERGED') {
        await gh(['issue', 'close', String(s.issue.numero), '--comment', `✅ PR #${s.pr.numero} unita in ${BASE}.`]);
        await colonna('Fatto', s);
        stampa(`Chiusa la issue #${s.issue.numero} (PR #${s.pr.numero} unita)`);
        n++;
      } else if (st === 'CLOSED') {
        await gh(['issue', 'close', String(s.issue.numero), '--reason', 'not planned', '--comment', `PR #${s.pr.numero} chiusa senza unirla.`]);
        stampa(`Chiusa la issue #${s.issue.numero} (PR #${s.pr.numero} scartata)`);
        n++;
      }
    }
    if (!n) stampa('Niente da riordinare.');
  },

  async fase(nome, commento) {
    esecuzioneCorrente();
    await impostaFase(nome, commento);
  },
  async errore(testo) {
    esecuzioneCorrente();
    await segnaErrore(testo);
  },
  async commenta(testo) {
    await commenta(testo);
  },
  async colonna(nome) {
    await colonna(nome);
  },
  task(id, statoTask, nota) {
    aggiornaTask(id, { stato: statoTask, ...(nota ? { nota } : {}) });
  },
  stato() {
    stampa(JSON.stringify(stato(), null, 2));
  },
  async annulla() {
    const s = esecuzioneCorrente();
    await comandi.pulisci();
    await impostaFase('annullata', '🛑 Corsa annullata.');
    stampa(`Corsa ${s.esecuzione.id} annullata.`);
  },
};

function leggiFile(f) {
  try {
    return fs.readFileSync(f, 'utf8');
  } catch {
    return null;
  }
}

const [nome, ...argomenti] = process.argv.slice(2);
const comando = comandi[nome || 'aiuto'];
if (!comando) {
  stampa(`Comando sconosciuto: ${nome}`);
  comandi.aiuto();
  process.exit(1);
}
try {
  await comando(...argomenti);
} catch (e) {
  stampa(`ERRORE: ${e.message}`);
  try {
    if (stato()?.esecuzione) await segnaErrore(e.message);
  } catch {
    /* niente */
  }
  process.exitCode = 1;
}
