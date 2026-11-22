#!/usr/bin/env node
// Dashboard di /orchestra: serve index.html e lo stato in sola lettura.
// Nessuna dipendenza. Ascolta solo su 127.0.0.1 (questo PC).
// Avvio: node agents/dashboard/server.js   →   http://127.0.0.1:4747
'use strict';
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const PORTA = Number(process.env.ORCHESTRA_PORTA) || 4747;
const HOST = '127.0.0.1';
const AGENTS = path.resolve(__dirname, '..');
const STATUS = path.join(AGENTS, 'status.json');
const RUNS = path.join(AGENTS, 'runs');
const PAGINA = path.join(__dirname, 'index.html');
const GITHUB = path.join(AGENTS, 'github.json');

/** Nomi host accettati: blocca le pagine esterne che provano a parlare col server (DNS rebinding). */
const HOST_AMMESSI = new Set([`127.0.0.1:${PORTA}`, `localhost:${PORTA}`]);

function leggiJson(f) {
  try {
    return JSON.parse(fs.readFileSync(f, 'utf8'));
  } catch {
    return null;
  }
}

/** Quota letta da OpenRouter al massimo una volta al minuto; la chiave resta qui, mai nella pagina. */
let quotaCache = null;
let quotaLetta = 0;
async function quota() {
  const key = process.env.OPENROUTER_API_KEY;
  if (!key || Date.now() - quotaLetta < 60_000) return quotaCache;
  quotaLetta = Date.now();
  try {
    const r = await fetch('https://openrouter.ai/api/v1/key', {
      headers: { Authorization: `Bearer ${key}` },
      signal: AbortSignal.timeout(8000),
    });
    const q = (await r.json()).data?.free_model_daily_requests;
    if (q) quotaCache = { usate: q.used, limite: q.limit, rimaste: q.remaining, letta: new Date().toISOString() };
  } catch {
    /* tengo l'ultima letta */
  }
  return quotaCache;
}

function storico() {
  if (!fs.existsSync(RUNS)) return [];
  return fs
    .readdirSync(RUNS)
    .filter((d) => /^\d{4}-\d{2}-\d{2}_\d{4}$/.test(d))
    .sort()
    .reverse()
    .slice(0, 30)
    .map((d) => {
      const s = leggiJson(path.join(RUNS, d, 'stato.json'));
      if (!s?.esecuzione) return { id: d };
      const tasks = s.tasks || [];
      return {
        id: d,
        nome: s.esecuzione.nome,
        richiesta: s.esecuzione.richiesta,
        fase: s.esecuzione.fase,
        inizio: s.esecuzione.inizio,
        fine: s.esecuzione.fine,
        fatti: tasks.filter((t) => t.stato === 'fatto').length,
        totale: tasks.length,
        richieste: s.richieste_usate ?? tasks.reduce((n, t) => n + (t.richieste || 0), 0),
        issue: s.issue?.url || null,
        pr: s.pr?.url || null,
        log: fs.existsSync(path.join(RUNS, d, 'log.md')),
      };
    });
}

function invia(res, codice, tipo, corpo) {
  res.writeHead(codice, {
    'Content-Type': tipo,
    'Cache-Control': 'no-store',
    'X-Content-Type-Options': 'nosniff',
    'Referrer-Policy': 'no-referrer',
    'X-Frame-Options': 'DENY',
    'Content-Security-Policy':
      "default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; connect-src 'self'; img-src 'self' data:; base-uri 'none'; form-action 'none'",
  });
  res.end(corpo);
}

const server = http.createServer(async (req, res) => {
  if (!HOST_AMMESSI.has(req.headers.host || '')) return invia(res, 421, 'text/plain; charset=utf-8', 'Host non ammesso');
  if (req.method !== 'GET') return invia(res, 405, 'text/plain; charset=utf-8', 'Solo lettura');
  const url = new URL(req.url, `http://${HOST}`);
  if (url.pathname === '/') return invia(res, 200, 'text/html; charset=utf-8', fs.readFileSync(PAGINA));
  if (url.pathname === '/api/stato') {
    const s = leggiJson(STATUS);
    const dati = {
      stato: s,
      quota: (await quota()) || s?.quota || null,
      storico: storico(),
      progetto: leggiJson(GITHUB)?.url || null,
      ora: new Date().toISOString(),
    };
    return invia(res, 200, 'application/json; charset=utf-8', JSON.stringify(dati));
  }
  if (url.pathname.startsWith('/api/log/')) {
    const id = url.pathname.slice('/api/log/'.length);
    if (!/^\d{4}-\d{2}-\d{2}_\d{4}$/.test(id)) return invia(res, 400, 'text/plain; charset=utf-8', 'Id non valido');
    const f = path.join(RUNS, id, 'log.md');
    if (!fs.existsSync(f)) return invia(res, 404, 'text/plain; charset=utf-8', 'Log non trovato');
    return invia(res, 200, 'text/plain; charset=utf-8', fs.readFileSync(f));
  }
  invia(res, 404, 'text/plain; charset=utf-8', 'Non trovato');
});

server.listen(PORTA, HOST, () => {
  console.log(`Dashboard di /orchestra: http://${HOST}:${PORTA}  (solo da questo PC, Ctrl+C per fermarla)`);
});
