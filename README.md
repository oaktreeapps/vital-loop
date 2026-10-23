# VitalLoop: a GenUI + Gemini demo

A Flutter health tracking app whose screens are **not built in Dart**. A small
Python server asks Gemini for each screen, Gemini answers with
[A2UI](https://a2ui.org/) JSON, and the app draws it with Flutter's
[`genui`](https://pub.dev/packages/genui) package. The screen streams in and
builds up live, piece by piece, while Gemini is still writing it.

It is a working example of generative UI with real flows: forms, validation,
custom components (a tappable body map, a 1–10 severity scale, and vital sign
cards with a thermometer, rulers and a live ECG trace), a saved
log, a daily summary written by Gemini, care nearby on a map, and a PDF
report.

Try it at [vital-loop on Cloud Run](https://vital-loop-555131973673.us-central1.run.app/)
with a free [Gemini API key](https://aistudio.google.com/app/apikey); the
catalog there needs no key. Your key stays in that browser session and is
cleared when you close the window.

No screen is built into the app. Gemini fills in each flow's screens from your
earlier answers as you go, so two people logging the same thing can see
different suggestions, symptom lists and summaries.

- **Gemini writes; the catalog draws.** Gemini answers in A2UI JSON and can
  only use the components in the catalog. The app draws them as real Flutter
  widgets while the JSON is still streaming in.
- **Templates set the layout; Gemini fills it in.** Each flow's screens are
  JSON templates in `server/flows/`. Gemini adds your earlier answers and writes
  only the parts marked for it: the symptom list, medicine suggestions and the
  overview for your doctor.
- **Code, not Gemini, judges your readings.** The normal, high and low ranges
  for blood pressure, heart rate, temperature and blood sugar are in
  `client/lib/models/vitals/`, so a reading's status never depends on what the
  model says.

> **Not medical software.** This is a demo. It does not give medical advice,
> and it sends what you enter to the Gemini API to build the next screen (and,
> for care nearby, the city you type to OpenStreetMap to find it on the map).
> Places found nearby are listings from Google Maps, not recommendations.
> Don't enter real personal health data unless you are fine with that.

## Repository layout

| Folder | What it is | Details |
| --- | --- | --- |
| [`client/`](client/) | The Flutter app (Android, iOS, web) | [client/README.md](client/README.md) |
| [`server/`](server/) | The Python server: an ADK agent per flow, served over A2A | [server/README.md](server/README.md) |

The client draws the screens; the server and Gemini decide what is on them.

## Features

| Flow | What you log | Custom components |
| --- | --- | --- |
| **Pain** | Where it hurts (front/back body map), pain level, when it started, notes | `BodyMapPicker`, `SeverityInput` |
| **Symptoms** | Symptoms from a list Gemini writes each time, then severity and details | `SeverityInput` |
| **Vitals** | Blood pressure, heart rate, temperature, blood sugar, with normal/high/low ranges | `BloodPressureInput`, `HeartRateInput`, `TemperatureInput`, `BloodSugarInput` |
| **Medications** | Medicine (suggestions written by Gemini), dose and schedule | |
| **Food / Nutrition** | Meal type, food items, quantities, meal time | `IconBadge` |
| **Daily summary** | Everything logged today, with an overview Gemini writes for your doctor; hospitals, clinics and doctors near a city you pick that fit what you logged, on a map and in a list; and a PDF to share or print | `CareMap`, `CareList`, `PdfReport` |

Also:

- The dashboard shows how many entries each flow has today. Its "Generate summary"
  button turns on once something is logged.
- Start over: the dashboard's restart button clears today's log after asking.
  The report's Finish button clears it too and goes back to the dashboard.
- Screens stream in: the header shows first, then each card as soon as Gemini
  has written it.
- One shared theme (colors, font, text styles) for every screen. The app is
  light-only for now.
- Colored logs that show how every class passes data to the next.

## How it works

```
┌─────────── client/ (Flutter) ───────────┐          ┌─────────── server/ (Python) ───────────┐
│ DashboardScreen                         │          │ main.py      one A2A agent per flow    │
│  └ TrackingFlowScreen (one flow)        │   A2A    │ agent_executor.py  streams screens     │
│     └ GenUiSession                      │ ───────▶ │ agent.py     ADK agent ───────▶ Gemini │
│        ├ BackendTransport (A2A client)  │ ◀─────── │ streaming.py partial JSON → screens    │
│        └ SurfaceController (genui)      │  A2UI    │ screens.py   flow templates            │
│           └ catalog: basic + custom     │  JSON    │ flows/<flow>/ prompt.md, *.json        │
└─────────────────────────────────────────┘          └────────────────────────────────────────┘
```

1. You tap a flow on the dashboard. The client sends a start message to that
   flow's agent, e.g. `http://localhost:10002/pain`.
2. The server's [ADK](https://google.github.io/adk-docs/) agent gives Gemini the
   flow's instructions (`prompt.md`) and its screen templates. Gemini answers with
   the A2UI messages for the next screen: `createSurface`, `updateDataModel` and
   `updateComponents` (see the [A2UI v0.9 specification](https://a2ui.org/specification/v0.9-a2ui/)).
3. While Gemini writes, the server reads the unfinished JSON and sends every
   complete part of the screen to the client as an A2A status update. genui
   renders each one, so the screen fills from top to bottom.
4. When you tap a button, genui sends its action (e.g. `bodyAreasSelected`, with
   the values you picked) back to the agent, and `flow.json` says which screen
   comes next. Some actions are handled in the client only, e.g. `goToDashboard`.
5. When a flow saves, the entry goes into `HealthLog`, an in-memory log in the
   client. The dashboard badges and the daily summary are built from it.

### Who writes what

- **Screen layout**: the JSON templates in `server/flows/`. Gemini fills in the
  `{{placeholders}}` with your earlier answers.
- **Generated parts**: any value written as
  `{"$ai": "what to generate", "example": ...}`, e.g. the symptom list, the
  medicine suggestions, or the summary's overview for your doctor. If Gemini
  leaves one empty, the example is used.
- **Custom components**: Flutter widgets registered as genui `CatalogItem`s in
  `client/lib/catalog/`. The JSON can only use components from the catalog.

## The catalog

28 components in six families: 18 of genui's basic components lay out every
screen, and 10 of the app's own draw the health cards. Each custom component is
declared once in `client/lib/catalog/<component>/`: a schema that tells Gemini
what it takes, and a plain Flutter widget that draws it. The app's
**Component Catalog** screen (the catalog button on the dashboard) shows every
one live, with its example JSON and schema, in **Default** and **Custom** tabs.

The [Figma file](https://www.figma.com/design/I2u4OYGUp0aT4EmnXVMEeG/VitalLoop-%C2%B7-A2UI-Component-CatalogHealth-Tracker-%C2%B7-A2UI-Component-Catalog?node-id=0-1&p=f&t=hbUnixnlCE6pc8cH-0)
holds every component as a Figma component, built from shared parts and bound
to VitalLoop's colours, spacing, radii and text styles as variables and
styles. It also has the foundations, the shared building blocks, and the
flows screen by screen.

| Family | Components |
| --- | --- |
| Layout and text | `Text`, `Row`, `Column`, `Card`, `Divider`, `Icon` |
| Inputs and actions | `Button`, `TextField`, `ChoicePicker`, `Slider`, `DateTimeInput` |
| Body and pain | `BodyMapPicker`, `SeverityInput` |
| Vitals | `BloodPressureInput`, `HeartRateInput`, `TemperatureInput`, `BloodSugarInput` |
| Summary and care | `CareMap`, `CareList`, `PdfReport` |
| Page header | `IconBadge` |

The first two families come from genui; the rest are VitalLoop's own. The
custom cards share one look and the parts in `client/lib/catalog/shared/`: the
status chip, unit toggle, round icon button and care place card. A screen can
only use components from this list, and each custom component's schema
description is exactly what Gemini reads about it.

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.41 or newer (Dart 3.11)
- Python 3.11 or newer
- A Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

## Running the app

Start the server first, then the client.

### 1. Start the server

```bash
cd server
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python main.py
```

It listens on `http://localhost:10002`, with one agent per flow. In a new
terminal, check that it answers:

```bash
curl http://localhost:10002/pain/.well-known/agent-card.json
```

### 2. Run the client

In a new terminal:

```bash
cd client
flutter pub get
flutter run
```

An Android emulator, an iOS simulator and the web app find the server on
their own. For a real phone, see
[Connecting to the server](client/README.md#connecting-to-the-server).

### 3. Add your Gemini API key

The first time the app opens, it asks the server whether it has a working
Gemini API key. If not, a dialog asks you for one: create a free key at
[Google AI Studio](https://aistudio.google.com/app/apikey) and paste it in. The
server checks it with Google and saves it to `server/.env`, and the app starts.
Next time, the key is already there.

You can also put the key in `server/.env` yourself before starting the server
(`cp .env.example .env`, then set `GEMINI_API_KEY`). `server/.env` is
git-ignored: never commit it.

### Care nearby

The daily summary's **Find care nearby** shows real places from Google Maps
on an OpenStreetMap map. It needs nothing extra: the search runs on the
Gemini API key (see [server/README.md](server/README.md#care-nearby)).

## Tests

Both test suites run offline: no server and no API key needed.

```bash
cd client && flutter test                          # every flow, against the real templates
cd server && .venv/bin/python -m unittest -v       # templates, routing, streaming
```

Each `test/` folder mirrors the code it tests; see
[client/README.md](client/README.md#tests) and
[server/README.md](server/README.md#tests).


## Contributing

Issues and pull requests are welcome. Before you open a PR:

- In `client/`: `flutter analyze` shows no issues, `dart format .` changes
  nothing, and `flutter test` passes. Every class, function and field needs a
  doc comment; the `public_member_api_docs` lint checks public ones.
- In `server/`: `.venv/bin/python -m unittest` passes, and every module, class
  and function has a docstring.
- Never commit API keys or `.env` files.

## Acknowledgements

- [genui](https://github.com/flutter/genui) 
- [A2UI](https://a2ui.org/) ([v0.9 specification](https://a2ui.org/specification/v0.9-a2ui/)), [A2A](https://a2a-protocol.org/) and the
  [Agent Development Kit](https://google.github.io/adk-docs/).
- The body map from the Daily Health Tracker project (Apache 2.0).

## License

Licensed under the [Apache License, Version 2.0](LICENSE). See
[NOTICE](NOTICE) for attribution, and
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the third-party code this
project includes or adapts, which keeps its own license.
