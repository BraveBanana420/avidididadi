# Webhook

Avidididadi can send your training data to **a web address you choose**, so it
reaches your own dashboards and automations: Home Assistant, n8n, Node-RED,
Make, Zapier, a Google Sheet behind an Apps Script, or your own server.

There is no Avidididadi server in the middle: the app sends a plain HTTPS
`POST` with a JSON body straight from your phone to your URL. The feature is
**off by default** and nothing is sent until you turn it on.

*Riassunto in italiano [in fondo](#riassunto-in-italiano).*

- [How to turn it on](#how-to-turn-it-on)
- [Events](#events)
- [The request](#the-request)
- [Payloads](#payloads)
- [Verifying the signature](#verifying-the-signature)
- [Retries and offline queue](#retries-and-offline-queue)
- [Receiving examples](#receiving-examples)
- [Privacy](#privacy)

## How to turn it on

1. In the app, turn on **Profile → Advanced features**.
2. Open **Profile → Data and connections → Webhook** (below the manual CSV
   import).
3. Enter your **URL**. Only full `https://` addresses are accepted.
4. Optional but recommended: tap **Generate** to create a **secret key**, then
   **Copy the key** and paste it into your receiver, so it can check the
   signature of every message.
5. Tap **Save**, then **Send test**: the app sends a `test` event and shows the
   result (the HTTP status code, or the error).
6. Turn on **Send data to the webhook**. The first time, the app asks **which
   workouts** to send:
   - **Only those recorded with the app** (default choice);
   - **Imported ones too**: also sessions coming from Health Connect,
     intervals.icu and CSV files, **including the ones already saved**. This
     can be hundreds of workouts: they are queued and sent one at a time, so
     the first sync may take a while.

   You can change this later from the same page.
7. Tick the **events** you want (all three are ticked by default).

The status line at the bottom shows the last successful send, the last error,
how many messages are queued and how many were discarded.

The URL and the secret key are stored in Android's encrypted storage, never in
CSV files, backups or logs.

## Events

| Event | When it is sent |
|---|---|
| `allenamento_completato` | A workout is finished in the app (guided workout or free activity). With *Imported ones too*, also every new session that arrives from Health Connect, intervals.icu or a CSV import (plus, once, the ones already saved). |
| `piano_aggiornato` | The training plan changes (new plan, a day edited, the coach's changes…). Sent a few seconds after the change, and only if the plan is really different from the last one sent. The first message after turning the webhook on contains the current plan. |
| `nuovo_record` | A new personal best in the last 3 days: more kg than ever in a strength exercise, or the longest distance ever in running, cycling, swimming or walking (with at least 3 sessions of that sport). Each record is sent once. |
| `test` | Only from the **Send test** button. |

Event names and stored values (sports, session types, times of day) are in
Italian, exactly as in the app's CSV files, in every app language. Field
names are in English.

| Value | Meaning |
|---|---|
| `Corsa`, `Bici`, `Nuoto`, `Forza`, `Mobilità`, `Arrampicata`, `Camminata` | running, cycling, swimming, strength, mobility, climbing, walking |
| `Mattina`, `Pranzo`, `Pomeriggio`, `Sera` | morning, lunch, afternoon, evening |
| `zona 2`, `passo 5:00/km` | heart rate zone 2, pace 5:00 per km |

## The request

```http
POST /your/path HTTP/1.1
Content-Type: application/json
X-Avidididadi-Event: allenamento_completato
X-Avidididadi-Signature: sha256=9d1c…e04b
User-Agent: Avidididadi/1.0.2

{"schema_version":1,"event":"allenamento_completato","id":"…","sent_at":"…","app_version":"1.0.2","data":{…}}
```

| Header | Content |
|---|---|
| `Content-Type` | Always `application/json` (UTF-8). |
| `X-Avidididadi-Event` | The event name, same as `event` in the body. |
| `X-Avidididadi-Signature` | `sha256=` + the hex HMAC-SHA256 of the **exact body bytes**, with your secret key. Only present if a secret key is set. |
| `User-Agent` | `Avidididadi/<app version>`. |

Any `2xx` answer means "received". The response body is ignored. Each request
times out after **10 seconds**.

### Envelope

Every body has the same envelope:

| Field | Type | Description |
|---|---|---|
| `schema_version` | integer | Version of this format, currently `1`. It changes only for incompatible changes; new fields can be added to `data` without changing it. |
| `event` | string | `allenamento_completato`, `piano_aggiornato`, `nuovo_record` or `test`. |
| `id` | string | Unique UUID v4 of the event. **It stays the same on every retry**: use it to drop duplicates. |
| `sent_at` | string | When this attempt was sent, ISO 8601 with the phone's time zone offset (`2026-11-18T19:16:04+01:00`). Changes on each retry. |
| `app_version` | string | App version (`1.0.2`). |
| `data` | object | The event content, described below. |

Missing numbers are `null` (for example `hr_avg` without a heart rate
monitor), never `0`.

## Payloads

The examples are pretty-printed for reading; the real body is compact (no
spaces or new lines).

### `allenamento_completato`: strength

```json
{
  "schema_version": 1,
  "event": "allenamento_completato",
  "id": "3f8a2c1e-7b4d-4e9a-9c21-5d0e8b6f4a17",
  "sent_at": "2026-11-18T19:16:04+01:00",
  "app_version": "1.0.2",
  "data": {
    "session_id": "app-2026-11-18-forza",
    "date": "2026-11-18",
    "sport": "Forza",
    "session_type": "Forza A",
    "start": "2026-11-18T18:30:00+01:00",
    "end": "2026-11-18T19:15:00+01:00",
    "duration_min": 45,
    "distance_km": null,
    "hr_avg": 112,
    "hr_max": 151,
    "rpe": 7.0,
    "calories_active": 260.0,
    "calories_total": 340.0,
    "steps": null,
    "power_avg": null,
    "cadence_avg": null,
    "source": "Avidididadi",
    "origin": "",
    "notes": "Forza A",
    "exercises": [
      {
        "exercise_id": "squat",
        "name": "Squat",
        "sets": [
          { "set": 1, "reps": 8, "kg": 57.5, "seconds": null },
          { "set": 2, "reps": 8, "kg": 60.0, "seconds": null },
          { "set": 3, "reps": 7, "kg": 60.0, "seconds": null }
        ]
      },
      {
        "exercise_id": "panca_piana",
        "name": "Panca piana",
        "sets": [
          { "set": 1, "reps": 10, "kg": 40.0, "seconds": null },
          { "set": 2, "reps": 9, "kg": 40.0, "seconds": null }
        ]
      },
      {
        "exercise_id": "plank",
        "name": "Plank",
        "sets": [
          { "set": 1, "reps": null, "kg": null, "seconds": 45 }
        ]
      }
    ]
  }
}
```

### `allenamento_completato`: cycling with power

```json
{
  "schema_version": 1,
  "event": "allenamento_completato",
  "id": "8c0b6e52-1f3a-4d7e-a2b9-64e1c0d93f28",
  "sent_at": "2026-11-19T08:03:11+01:00",
  "app_version": "1.0.2",
  "data": {
    "session_id": "app-2026-11-19-bici",
    "date": "2026-11-19",
    "sport": "Bici",
    "session_type": "Rulli",
    "start": "2026-11-19T07:00:00+01:00",
    "end": "2026-11-19T08:02:00+01:00",
    "duration_min": 62,
    "distance_km": 31.4,
    "hr_avg": 138,
    "hr_max": 165,
    "rpe": null,
    "calories_active": 640.0,
    "calories_total": null,
    "steps": null,
    "power_avg": 182,
    "cadence_avg": 88,
    "source": "Avidididadi",
    "origin": "",
    "notes": "Soglia 3 x 8 minuti",
    "exercises": []
  }
}
```

Workout fields (`data`), taken from the app's `sessioni.csv` columns:

| Field | CSV column | Type | Description |
|---|---|---|---|
| `session_id` | `id_sessione` | string | Session id in the app. Recording the same sport again on the same day keeps the same id: **upsert by `session_id`** if you store sessions. |
| `date` | `data` | string | Day, `YYYY-MM-DD`. |
| `sport` | `sport` | string | `Corsa`, `Bici`, `Nuoto`, `Forza`… (see the table above). |
| `session_type` | `tipo_sessione` | string | Session name or type (`Lungo`, `Rulli`, `Forza A`…), may be empty. |
| `start`, `end` | `inizio`, `fine` | string or null | ISO 8601 with offset. |
| `duration_min` | `durata_min` | integer | Minutes. |
| `distance_km` | `distanza_km` | number or null | Kilometers. |
| `hr_avg`, `hr_max` | `fc_media`, `fc_max` | integer or null | Average and max heart rate (bpm). |
| `rpe` | `rpe` | number or null | Perceived effort 1–10. |
| `calories_active`, `calories_total` | `calorie_attive`, `calorie_totali` | number or null | kcal. |
| `steps` | `passi` | integer or null | Steps. |
| `power_avg` | `potenza_media` | integer or null | Average power (W). |
| `cadence_avg` | `cadenza_media` | integer or null | Average cycling cadence (rpm). |
| `source` | `fonte` | string | Where it comes from: `Avidididadi` for workouts recorded with the app, otherwise the watch or app that recorded it (for Health Connect and intervals.icu) or what the CSV says (`Manuale`…). |
| `origin` | `origine` | string | Android package that wrote it to Health Connect, empty otherwise. |
| `notes` | `note` | string | Notes or workout name. |
| `exercises` | `serie.csv` | array | Strength sessions only (otherwise empty): the exercises done that day. |
| `exercises[].exercise_id` | `esercizio` | string or null | Id in the app's exercise catalog, `null` for custom exercises. |
| `exercises[].name` | `nome` | string | Exercise name. |
| `exercises[].sets[].set` | `serie` | integer | Set number, from 1. |
| `exercises[].sets[].reps` | `ripetizioni` | integer or null | Repetitions (`null` for timed sets). |
| `exercises[].sets[].kg` | `kg` | number or null | Load in kg (`null` = bodyweight). |
| `exercises[].sets[].seconds` | `secondi` | integer or null | Duration of timed sets (plank, holds). |

### `piano_aggiornato`

```json
{
  "schema_version": 1,
  "event": "piano_aggiornato",
  "id": "c41f7a90-2d6b-4b18-8e3f-0a95d7c2b6e1",
  "sent_at": "2026-11-20T08:12:40+01:00",
  "app_version": "1.0.2",
  "data": {
    "from": "2026-11-20",
    "sessions": [
      {
        "date": "2026-11-20",
        "slot": "Sera",
        "sport": "Forza",
        "session_type": "Forza B",
        "duration_min": 45,
        "distance_km": null,
        "intensity": "",
        "notes": ""
      },
      {
        "date": "2026-11-22",
        "slot": "Mattina",
        "sport": "Corsa",
        "session_type": "Lungo",
        "duration_min": 75,
        "distance_km": 14.0,
        "intensity": "zona 2",
        "notes": "Ultimi 2 km un po' più veloci"
      }
    ]
  }
}
```

| Field | CSV column (`piano.csv`) | Type | Description |
|---|---|---|---|
| `from` | | string | First day included (today). Past days are not sent. |
| `sessions` | | array | **All** planned sessions from `from` on, sorted by date. It replaces the previous plan: it is not a diff. |
| `sessions[].date` | `data` | string | `YYYY-MM-DD`. |
| `sessions[].slot` | `fascia` | string | `Mattina`, `Pranzo`, `Pomeriggio`, `Sera`. |
| `sessions[].sport` | `sport` | string | Sport. |
| `sessions[].session_type` | `tipo_sessione` | string | Session type, may be empty. |
| `sessions[].duration_min` | `durata_min` | integer | Planned minutes (0 if not set). |
| `sessions[].distance_km` | `distanza_km` | number or null | Planned distance. |
| `sessions[].intensity` | `intensita` | string | Target, such as `zona 2` or `passo 5:00/km`. |
| `sessions[].notes` | `note` | string | Notes. |

### `nuovo_record`: strength

```json
{
  "schema_version": 1,
  "event": "nuovo_record",
  "id": "5b7e2d14-9a0c-4f63-b8d1-27c4e6a0f9b3",
  "sent_at": "2026-11-18T19:16:09+01:00",
  "app_version": "1.0.2",
  "data": {
    "record_type": "strength",
    "date": "2026-11-18",
    "sport": "Forza",
    "exercise_id": "squat",
    "name": "Squat",
    "value": 60.0,
    "unit": "kg",
    "previous_value": 55.0,
    "reps": 8,
    "session_id": null
  }
}
```

### `nuovo_record`: distance

```json
{
  "schema_version": 1,
  "event": "nuovo_record",
  "id": "e2a9c6f1-4b3d-4a8e-9f07-81d5b2c3e4a6",
  "sent_at": "2026-11-18T10:41:52+01:00",
  "app_version": "1.0.2",
  "data": {
    "record_type": "distance",
    "date": "2026-11-18",
    "sport": "Corsa",
    "exercise_id": null,
    "name": null,
    "value": 15.2,
    "unit": "km",
    "previous_value": 12.0,
    "reps": null,
    "session_id": "app-2026-11-18-corsa"
  }
}
```

| Field | Type | Description |
|---|---|---|
| `record_type` | string | `strength` (heaviest load in an exercise) or `distance` (longest distance in a sport). |
| `date` | string | Day of the record, `YYYY-MM-DD`. |
| `sport` | string | `Forza` for strength, otherwise the sport. |
| `exercise_id`, `name` | string or null | The exercise (strength only). |
| `value` | number | The new best: kg or km. |
| `unit` | string | `kg` or `km`. |
| `previous_value` | number | The previous best. |
| `reps` | integer or null | Repetitions done with the record load (strength only). |
| `session_id` | string or null | The session of the record (distance only). |

### `test`

```json
{
  "schema_version": 1,
  "event": "test",
  "id": "3f8a2c1e-7b4d-4e9a-9c21-5d0e8b6f4a17",
  "sent_at": "2026-11-18T19:16:04+01:00",
  "app_version": "1.0.2",
  "data": {
    "message": "Test from Avidididadi"
  }
}
```

## Verifying the signature

If you set a secret key, every request has
`X-Avidididadi-Signature: sha256=<hex>`, the HMAC-SHA256 of the **raw body
bytes** with the key. To check it:

1. read the body **as raw bytes, before parsing the JSON** (parsing and
   re-serializing changes the bytes: `60.0` becomes `60`, spaces move…);
2. compute HMAC-SHA256 of those bytes with your key, as lowercase hex;
3. compare it with the header (after `sha256=`) using a **constant-time**
   comparison;
4. reject the request (for example with `401`) if they differ. The app will
   not retry a `401`, and the error shows up in its status line.

Test vector: with the key `my-secret` this exact body

```text
{"schema_version":1,"event":"test","id":"3f8a2c1e-7b4d-4e9a-9c21-5d0e8b6f4a17","sent_at":"2026-11-18T19:16:04+01:00","app_version":"1.0.2","data":{"message":"Test from Avidididadi"}}
```

must give

```text
sha256=3ef6639aaf08f3ad47b850e78703c475a3e30dfb95aecc1c4c62a1e599ec1331
```

To make replayed messages useless too, also store the `id`s you have already
seen and drop repeats.

### Python

```python
import hashlib
import hmac


def signature_ok(body: bytes, header: str | None, secret: str) -> bool:
    """body: the raw request body; header: X-Avidididadi-Signature."""
    if not header or not header.startswith("sha256="):
        return False
    expected = hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, header[len("sha256="):])


# Flask example
from flask import Flask, abort, request

app = Flask(__name__)
SECRET = "paste-the-key-from-the-app"


@app.post("/avidididadi")
def avidididadi():
    body = request.get_data()  # raw bytes, before any JSON parsing
    if not signature_ok(body, request.headers.get("X-Avidididadi-Signature"), SECRET):
        abort(401)
    event = request.get_json()
    print(event["event"], event["data"])
    return "", 204
```

### JavaScript (Node.js, no dependencies)

```js
const crypto = require("node:crypto");
const http = require("node:http");

const SECRET = "paste-the-key-from-the-app";

function signatureOk(body, header, secret) {
  // body: Buffer with the raw request body; header: X-Avidididadi-Signature
  if (!header || !header.startsWith("sha256=")) return false;
  const expected = crypto.createHmac("sha256", secret).update(body).digest();
  const received = Buffer.from(header.slice("sha256=".length), "hex");
  return received.length === expected.length &&
    crypto.timingSafeEqual(received, expected);
}

http.createServer((req, res) => {
  const chunks = [];
  req.on("data", (c) => chunks.push(c));
  req.on("end", () => {
    const body = Buffer.concat(chunks);
    if (!signatureOk(body, req.headers["x-avidididadi-signature"], SECRET)) {
      res.writeHead(401).end();
      return;
    }
    const event = JSON.parse(body.toString("utf8"));
    console.log(event.event, event.data);
    res.writeHead(204).end();
  });
}).listen(8080);
```

With Express, use `express.raw({ type: "application/json" })` on the route,
so that `req.body` is the raw `Buffer`.

## Retries and offline queue

- If a send fails because of **no network, a timeout (10 s), a `5xx` error or
  `429 Too Many Requests`**, the message is saved in a queue on the phone and
  retried after **1, 5 and 15 minutes, then every 60 minutes**.
- After **10 attempts** or **7 days** it is discarded, and the app counts it
  in "Discarded messages".
- Other **`4xx` errors** (wrong URL, `401` for a bad signature, `404`…) and
  certificate errors are **not retried**: the message is discarded at once,
  because sending it again would not help. Fix the setting and use **Send
  test**.
- The queue is tried again **when the app starts, when you come back to it,
  every minute while it is open**, and, **with the app closed**, through
  Android's WorkManager as soon as the phone has a network connection. Android
  decides the exact moment: usually within minutes, later with battery saver
  on. If you force-stop the app from Android settings, pending background
  work is cancelled until you open the app again.
- Messages are sent oldest first, one at a time. With no network the app
  stops at the first failure and keeps everything for later.
- Saving a workout never waits for the webhook: sending happens in the
  background and cannot block the app or lose data.
- Delivery is **at least once**: in rare cases (the phone loses connection
  right after your server answered) the same message can arrive twice, with
  the same `id`. Drop duplicates by `id`.
- Turning the webhook off empties the queue without sending.
- The queue (`webhook_coda.json`) and the status (`webhook_stato.json`) are
  not included in the app's backup.

## Receiving examples

### webhook.site (quick test)

1. Open <https://webhook.site>: it gives you a unique URL like
   `https://webhook.site/1a2b3c4d-…`.
2. Paste it in the app, tap **Save**, then **Send test**.
3. The request appears on the page with all headers and the body. You can
   check the signature with the test vector above.

webhook.site is a public third-party service: use it only for tests, not for
your real data.

### Home Assistant (webhook trigger)

Add an automation (Settings → Automations → Create → Edit in YAML):

```yaml
alias: Avidididadi workouts
triggers:
  - trigger: webhook
    webhook_id: avidididadi-change-this-to-something-long-and-random
    allowed_methods: [POST]
    local_only: false   # true if the phone only sends from your home network
actions:
  - choose:
      - conditions: "{{ trigger.json.event == 'allenamento_completato' }}"
        sequence:
          - action: notify.persistent_notification
            data:
              title: "Workout done"
              message: >-
                {{ trigger.json.data.sport }}:
                {{ trigger.json.data.duration_min }} min
                {%- if trigger.json.data.distance_km %},
                {{ trigger.json.data.distance_km }} km{% endif %}
      - conditions: "{{ trigger.json.event == 'nuovo_record' }}"
        sequence:
          - action: notify.persistent_notification
            data:
              title: "New record!"
              message: >-
                {{ trigger.json.data.name or trigger.json.data.sport }}:
                {{ trigger.json.data.value }} {{ trigger.json.data.unit }}
                (before {{ trigger.json.data.previous_value }})
mode: queued
```

The URL to paste in the app is
`https://<your-home-assistant>/api/webhook/<webhook_id>`, for example through
Nabu Casa (`https://xxxx.ui.nabu.casa/api/webhook/…`) or your own HTTPS
address. The app only accepts `https://`.

Home Assistant's webhook trigger cannot check the HMAC signature: there the
**`webhook_id` is the secret**, so make it long and random (you can use the
app's **Generate** button and copy the key into the id). To store values,
use `input_number` / `input_text` helpers, or a template sensor that reads
`trigger.json.data`.

### n8n

1. Add a **Webhook** node: *HTTP Method* `POST`, choose a *Path*, *Respond*
   `Immediately`. Copy the **Production URL**
   (`https://<your-n8n>/webhook/<path>`) into the app and activate the
   workflow (the *Test URL* only works while you are listening in the editor).
2. Route by event with a **Switch** node on `{{ $json.body.event }}`.
3. Use `{{ $json.body.data.sport }}`, `{{ $json.body.data.duration_min }}`…
   in the following nodes (Google Sheets "Append row", a database, Telegram…).

To check the signature in n8n, turn on the Webhook node option **Raw Body**
and add a **Code** node that computes the HMAC of the raw bytes, as in the
JavaScript example above (`require('crypto')` needs
`NODE_FUNCTION_ALLOW_BUILTIN=crypto` on self-hosted n8n). Do not compute it
from `JSON.stringify($json.body)`: the bytes would not be the same.

### Node-RED, Make, Zapier, Google Sheets

- **Node-RED**: an `http in` node (`POST`, URL `/avidididadi`) followed by an
  `http response` node; `msg.payload` contains the JSON. Node-RED must be
  reachable over HTTPS.
- **Make**: *Webhooks → Custom webhook*, then let it learn the structure with
  **Send test**.
- **Zapier**: *Webhooks by Zapier → Catch Hook*.
- **Google Sheets**: an Apps Script web app (`doPost(e)`, body in
  `e.postData.contents`) that appends a row; deploy it and paste the
  `https://script.google.com/macros/s/…/exec` URL.

## Privacy

- Data goes **only** to the address you enter, and only for the events you
  tick. The receiver's own privacy terms apply.
- Never sent: your name, photo, body measurements, GPS routes, API keys.
- The URL and the secret key stay encrypted on the phone and are not in
  backups. The secret key is never sent: only the signature is.
- Turning the webhook off stops all sending and empties the queue.

---

## Riassunto in italiano

**Cos'è.** Con il webhook l'app manda i tuoi dati di allenamento a un
indirizzo web scelto da te (Home Assistant, n8n, Node-RED, Make, Zapier,
Google Sheets…). Nessun server di Avidididadi in mezzo. È **spento di
default**.

**Come si accende.** Accendi *Profilo → Funzioni avanzate*, poi apri *Profilo
→ Dati e collegamenti → Webhook*. Scrivi l'indirizzo (solo `https://`), se
vuoi genera una **chiave segreta** e copiala in chi riceve, tocca **Salva** e
**Invia test**. Poi accendi l'interruttore. La prima volta l'app chiede se
mandare **solo gli allenamenti registrati con l'app** o **anche quelli
importati** (Health Connect, intervals.icu, CSV), compresi quelli già salvati:
possono essere centinaia e il primo invio può richiedere un po'.

**Eventi.** `allenamento_completato` (allenamento finito, con esercizi, serie
e kg per la forza), `piano_aggiornato` (tutte le sedute da oggi in poi, quando
il piano cambia), `nuovo_record` (più kg di sempre in un esercizio o distanza
più lunga in uno sport), `test` (dal pulsante "Invia test").

**Formato.** `POST` con JSON e header `Content-Type: application/json`,
`X-Avidididadi-Event`, `User-Agent: Avidididadi/<versione>` e, se hai una
chiave, `X-Avidididadi-Signature: sha256=<HMAC-SHA256 del corpo>`. Il corpo
ha `schema_version` (oggi 1), `event`, `id` (uguale a ogni tentativo: serve
a scartare i doppioni), `sent_at`, `app_version` e `data`. I nomi dei campi
sono in inglese; i valori (`Corsa`, `Sera`, `zona 2`) restano in italiano
come nei CSV dell'app.

**Firma.** Calcola l'HMAC-SHA256 dei byte **grezzi** del corpo (prima di
leggere il JSON) con la tua chiave e confrontalo con l'header in tempo
costante. Esempi in Python e JavaScript qui sopra, con un vettore di prova.

**Se non arriva.** Senza rete, dopo un timeout di 10 secondi, con un errore
`5xx` o `429` il messaggio resta in coda e si ritenta dopo 1, 5, 15 minuti e
poi ogni ora, anche ad app chiusa (WorkManager di Android, appena torna la
rete), al massimo 10 volte o 7 giorni. Gli altri errori `4xx` non si
ritentano. Salvare un allenamento non aspetta mai il webhook.

**Privacy.** Partono solo i dati degli eventi spuntati, solo verso il tuo
indirizzo. Mai nome, foto, misure del corpo, percorsi GPS o chiavi. Indirizzo
e chiave restano cifrati sul telefono, fuori dal backup.
