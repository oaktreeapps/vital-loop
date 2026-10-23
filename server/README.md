# VitalLoop server (Python)

The Python server of [VitalLoop](../README.md): it generates the
[client](../client/)'s screens with Gemini. It works like
the [Verdure](https://github.com/flutter/genui/tree/main/examples/verdure) example:
an [ADK](https://google.github.io/adk-docs/) agent served over
[A2A](https://a2a-protocol.org/), answering each request with
[A2UI](https://a2ui.org/) JSON that the Flutter app renders with `genui`. The
screens follow the [A2UI v0.9 specification](https://a2ui.org/specification/v0.9-a2ui/).

## How it works

```
Flutter app ──A2A──▶ main.py ──▶ agent_executor.py ──▶ agent.py ──▶ Gemini
 (genui_a2a)          one URL       reads the request     prompt.md + screen
                      per flow      sends A2UI back       templates (screens.py)
```

Start reading at `main.py`: its docstring lists the steps of a request and
which file does each one, and every file's docstring says where it fits.

- `main.py`: starts the server, with one A2A agent per folder in `flows/`, e.g.
  `http://localhost:10002/nutrition`.
- `agent_executor.py`: takes the app's request (text to start a flow, or a button
  tap's UI action), asks the agent, and streams the A2UI messages back.
- `agent.py`: the ADK agent. Its instructions are the flow's `prompt.md` and all of
  its screen templates; Gemini answers each step with the matching template, filling
  `{{placeholders}}` with the user's earlier answers.
- `streaming.py`: reads Gemini's reply while it is still being written and turns
  every complete part into a partial screen, so the app builds the screen live
  (sent as A2A `working` updates; the full screen ends the request).
- `screens.py`: loads a flow's templates (`flow.json`, shared screens, `$include`).
- `key_setup.py`: the first-run Gemini API key check the app does (see
  [The Gemini API key](#the-gemini-api-key)).
- `places.py`: the `search_care_places` tool Gemini calls for the daily
  summary's care nearby screen, and the check that keeps only places Google
  returned (see [Care nearby](#care-nearby)).
- `flows/<flow>/`: everything about one flow:
  - `flow.json`: which screen answers which request: `start` for the first one,
    otherwise the name of the UI action the user just sent.
  - `prompt.md`: the flow's instructions for Gemini.
  - `*.json`: one A2UI screen per step.
- `flows/shared/`: screens and the theme every flow reuses.

### LLM-generated parts

To let Gemini write part of a screen instead of the JSON, replace that value with
`{"$ai": "<what to generate>", "example": <a sample of the same shape>}`. For
example, the medicine chips in `flows/medication/01_medicine_name.json`:

```json
"options": {
  "$ai": "6 common medicines people log at home ...",
  "example": [{"label": "Paracetamol", "value": "Paracetamol"}, ...]
}
```

Gemini replaces the whole object with its own value in the example's shape. The
example is used instead if Gemini leaves it unfilled, and by the app's tests.

### Places from Google

A value `{"$places": [...]}` is a list of places the `search_care_places` tool
found (see `flows/daily_summary/02_nearby_care.json`). Gemini fills it like a
`$ai` part, writing only the `id` and a `reason` for each place it picks
(copying every fact made the screen slow to write). Before the app gets the
screen, the server adds the facts Google returned for each `id` (name,
address, phone, position) and drops any place no search returned. So a
made-up place never reaches the app.

A value `{"$place": "<id>"}` is one place, e.g. the one the user picked on
the care nearby screen, which the report screen shows under the PDF card
(`flows/daily_summary/03_report.json`). Gemini only fills in the id; the
server puts that place's facts there, or removes the value when no search
returned the id (e.g. nothing was picked).

Edit the JSON or `prompt.md` files to change a flow; the server reads them on every
request, so no restart is needed. To add a flow, add a folder here (and its
`TrackingFlow` in the client, with the same `name`; see
[client/README.md](../client/README.md#add-a-flow)).

## Running

Needs Python 3.11 or newer and a Gemini API key from
https://aistudio.google.com/app/apikey. From this `server/` folder:

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python main.py
```

The server starts even without a key: the app asks for one the first time it
opens (see below). To set it yourself instead, `cp .env.example .env` and put
your key in `.env` before starting.

The server starts on `http://localhost:10002`. Check it with:

```bash
curl http://localhost:10002/nutrition/.well-known/agent-card.json
```

Then run the [client](../client/README.md) (`flutter run` in `client/`). An
Android emulator reaches the server at `10.0.2.2` automatically. For a physical
phone, start the server with `--host 0.0.0.0` and run the client with
`--dart-define=BACKEND_URL=http://<your computer's IP>:10002`.

To restart the server after changing Python code:

```bash
pkill -f "main.py"; .venv/bin/python main.py
```

Changes to `flows/` (JSON or `prompt.md`) need no restart: they are read on
every request.

## The Gemini API key

Every flow needs Gemini, so the app checks the key before anything else, at
`/setup/gemini-key`:

| Request | Answer |
| --- | --- |
| `GET /setup/gemini-key` | `{"state": "ok" \| "missing" \| "invalid", "message": ..., "keyUrl": ...}` |
| `POST /setup/gemini-key` with `{"key": "..."}` | Checks the key with Google, saves it to `.env`, and switches every flow to it |

- A key is checked with Google once, and the answer is cached. If Google can't
  be reached, the key counts as working, so being offline never locks the app.
- `.env.example`'s placeholder (`your_key_here`) counts as no key.
- **A working key can't be replaced through the app.** The server only accepts
  a key while it has none or Google rejects the one it has, so nobody who can
  reach the server (e.g. on your Wi-Fi with `--host 0.0.0.0`) can swap your
  key. To change a working key, edit `.env` and restart.
- The key is never sent back to the app or written to the logs. `.env` is
  created readable by your user only.

## Care nearby

The daily summary's **Find care nearby** button opens a screen with hospitals,
clinics and doctors near a city the user types, picked to fit what they logged
(e.g. orthopedic clinics for knee pain). The app asks for the city and sends
`findNearbyCare`; Gemini calls `search_care_places` (`places.py`) with the city
and one to three kinds of care, and fills the screen's map and list.

No Google Maps key is needed: the search uses the Gemini API key.

1. The city's center comes from OpenStreetMap's free
   [Nominatim](https://nominatim.org/) service (only cities, towns, states and
   countries, never a shop).
2. Gemini, with [Grounding with Google Maps](https://ai.google.dev/gemini-api/docs/maps-grounding),
   finds the places, then gives their details (address, position, rating,
   phone). That's two Gemini requests per search.
3. Only places Google Maps really returned are kept (by Google's place id),
   and only near the city. `resolve_places()` then drops any place in Gemini's
   screen that the search didn't find, so the screen never shows a made-up
   place.

Grounding with Google Maps has its own, lower request limits on the Gemini
API. When they're reached, the screen says so; try again later.

A search takes about 25–30 seconds: Gemini decides what to search for
(~5s), the two Google Maps requests (~5s and ~8s, with low thinking), then
Gemini writes the screen (~10s).

## Configuration

| Setting | Where | Default |
| --- | --- | --- |
| `GEMINI_API_KEY` | `.env`, or entered in the app | required |
| `GEMINI_MODEL` | `.env` | `gemini-3-flash-preview` |
| `--host`, `--port` | `main.py` arguments | `localhost`, `10002` |

## Tests

```bash
.venv/bin/python -m unittest -v                         # everything
.venv/bin/python -m unittest tests.test_places -v       # one file
```

The tests are in `tests/`, one file per module:

```
tests/
  test_agent.py           agent.py: the instruction, parsing replies, $ai parts
  test_agent_executor.py  agent_executor.py: reading the app's requests
  test_key_setup.py       key_setup.py: checking and saving the Gemini key
  test_places.py          places.py: the care search and the place check
  test_screens.py         screens.py: finding flows, includes and {{slots}}
  test_streaming.py       streaming.py: building screens live
  flows/                  Checks on the flow templates themselves
  support/fakes.py        Fake OpenStreetMap and Gemini, so no key or network
```

To add a test, put it in the file for its module, as a `unittest.TestCase`
method with a docstring.

The client's tests (`flutter test` in `client/`) also use these flows: they read
the templates from `../server/flows/` and check every flow against them.

## Dependencies

`requirements.txt` keeps `a2a-sdk` below 1.0 on purpose. The client's A2A
library (`genui_a2a`) speaks A2A 0.3. `a2a-sdk` 1.x can still answer 0.3
clients, but its compatibility layer sends every number as a decimal (`72.0`
instead of `72`), which the client doesn't expect. Move to 1.x once
`genui_a2a` supports A2A 1.0.
