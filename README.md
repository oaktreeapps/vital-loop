# VitalLoop: a GenUI + Gemini demo

A demo health tracking app where screens are **not pre-built in Dart**. A small
Python server asks Gemini for each screen, Gemini answers with
[A2UI](https://a2ui.org/) JSON, and the app draws it with Flutter's
[`GenUI`](https://pub.dev/packages/genui) package.

The demo app has: forms, validation, custom components such as temperature input, a saved log, a daily summary written by Gemini, a PDF
report etc.

Try it [here](https://vital-loop-555131973673.us-central1.run.app/)
with a free [Gemini API key](https://aistudio.google.com/app/apikey). Your key stays in the browser session and is
cleared when you close the window.

Gemini populates the data in each flow from your earlier answers as you go, so two people logging the same thing may see
different suggestions, symptoms list and summaries.

- **Gemini writes; the catalog draws.** Gemini answers in A2UI JSON and can
  only use the components defined the catalog. The app draws them as real Flutter
  widgets while the JSON is still streaming in.
- **Templates set the layout; Gemini fills it in.** Each flow is defined as
  JSON templates in `server/flows/`. Gemini adds your earlier answers and writes
  only the parts marked for it: the symptoms list, medication suggestions, the
  overview for your doctor etc.
- **Code, not Gemini, handles your readings.** The normal, high and low ranges
  for blood pressure, heart rate, temperature and blood sugar are defined
  `client/lib/models/vitals/`, so the status never depends on what the
  model says.

> **Not a medical software.** The app is intended to be a demo. It does not give medical advice,
> and it sends what you enter to the Gemini API to build the next screen (The city you enter is send to OpenStreetMap to find it on the map).
> Places found nearby are listings from Google Maps, not recommendations.

## Repository layout

| Folder | What it is | Details |
| --- | --- | --- |
| [`client/`](client/) | The Flutter app (Android, iOS, web) | [client/README.md](client/README.md) |
| [`server/`](server/) | The Python server: an ADK agent per flow, served over A2A | [server/README.md](server/README.md) |

The client draws the screens; the server and Gemini decide what each screen holds.

## Features

| Flow | What you log | Custom components |
| --- | --- | --- |
| **Pain** | Where it hurts (front/back body map), pain level, when it started, notes | `BodyMapPicker`, `SeverityInput` |
| **Symptoms** | Symptoms from a list Gemini suggests each time, severity and notes | `SeverityInput` |
| **Vitals** | Blood pressure, heart rate, temperature, blood sugar, with normal/high/low ranges | `BloodPressureInput`, `HeartRateInput`, `TemperatureInput`, `BloodSugarInput` |
| **Medications** | Medication suggestions written by Gemini, dosage and schedule | |
| **Food / Nutrition** | Meal type, food items, serving size, meal times | `IconBadge` |
| **Daily summary** | Everything logged today, with an overview Gemini writes for your doctor; care providers near a city you search based on what you logged, a PDF to share or print | `CareMap`, `CareList`, `PdfReport` |

Also:

- The dashboard shows how many entries each flow has logged today. The "Generate summary"
  button is enabled once something is logged.
- Start over: The dashboard's start over button clears the logs from today.
- Screens stream in: The header shows first, then each card is drawn as soon as Gemini has written it.
- One shared theme (colors, font, text styles) for every screen. The app is
  light-theme only for now.
- Colored logs that show how every class passes data to the next.

## How it works

```
┌─────────── client/ (Flutter) ───────────┐          ┌─────────── server/ (Python) ───────────┐
│ DashboardScreen                         │          │ main.py      one A2A agent per flow    │
│  └ TrackingFlowScreen (one flow)        │   A2A    │ agent_executor.py  streams screens     │
│     └ GenUISession                      │ ───────▶ │ agent.py     ADK agent ───────▶ Gemini │
│        ├ BackendTransport (A2A client)  │ ◀─────── │ streaming.py partial JSON → screens    │
│        └ SurfaceController (GenUI)      │  A2UI    │ screens.py   flow templates            │
│           └ catalog: basic + custom     │  JSON    │ flows/<flow>/ prompt.md, *.json        │
└─────────────────────────────────────────┘          └────────────────────────────────────────┘
```

1. You tap a flow on the dashboard. The client sends a start message to that
   flow's agent, e.g. `http://localhost:10002/pain`.
2. The server's [ADK](https://google.github.io/adk-docs/) agent gives Gemini the instructions (`prompt.md`) and the screen templates. Gemini answers with the A2UI messages for the next screen: `createSurface`, `updateDataModel` and
   `updateComponents` (see the [A2UI v0.9 specification](https://a2ui.org/specification/v0.9-a2ui/)).
3. While Gemini writes, the server goes through the JSON and sends every
   complete part of the screen to the client as an A2A status update. GenUI
   renders each one, so the screen fills from top to bottom.
4. When you tap a button, GenUI sends its action (e.g. `bodyAreasSelected`, with
   the values you picked) back to the agent, and `flow.json` says which screen
   comes next. Some actions are handled on client side, e.g. `goToDashboard`.
5. When a flow saves, the entry goes into `HealthLog`, which is an in-memory log on client side. The dashboard badges and the daily summary are built from it.

### Who writes what

- **Screen layout**: the JSON templates in `server/flows/`. Gemini fills in the
  `{{placeholders}}` with your earlier answers.
- **Generated parts**: any value written as
  `{"$ai": "what to generate", "example": ...}`, e.g. the symptoms list, the
  medication suggestions, the summary's overview for your doctor etc. If Gemini
  leaves one empty, the example is used.
- **Custom components**: Flutter widgets registered as GenUI `CatalogItem`s in
  `client/lib/catalog/`. Only pre-defined components from the catalog can be used.

## The catalog

28 components in total: 18 basic components lay out every
screen, and 10 of the app's custom components draw the health cards. Each custom component is
declared once in `client/lib/catalog/<component>/`: a schema tells Gemini
what it takes, and a plain Flutter widget draws it. The catalog button on the dashboard shows every component, with an example JSON and schema.

The [Figma file](https://www.figma.com/design/I2u4OYGUp0aT4EmnXVMEeG/VitalLoop-%C2%B7-A2UI-Component-CatalogHealth-Tracker-%C2%B7-A2UI-Component-Catalog?node-id=0-1&p=f&t=hbUnixnlCE6pc8cH-0) has all the components, built from shared parts and bound
to VitalLoop's colors, spacing, radii and text styles as variables and styles.

| Family | Components |
| --- | --- |
| Layout and text | `Text`, `Row`, `Column`, `Card`, `Divider`, `Icon` |
| Inputs and actions | `Button`, `TextField`, `ChoicePicker`, `Slider`, `DateTimeInput` |
| Body and pain | `BodyMapPicker`, `SeverityInput` |
| Vitals | `BloodPressureInput`, `HeartRateInput`, `TemperatureInput`, `BloodSugarInput` |
| Summary and care | `CareMap`, `CareList`, `PdfReport` |
| Page header | `IconBadge` |

The first two families come from GenUI; the rest are custom catalog items. The
custom cards share one look defined in `client/lib/catalog/shared/`. A screen can
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

The server runs on `http://localhost:10002`, with one agent per flow. In a new
terminal, you can check what it replies back with:

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

An Android emulator, an iOS simulator and the web app can connect to the server directly. For a real phone, see
[Connecting to the server](client/README.md#connecting-to-the-server).

### 3. Add your Gemini API key

The first time the app opens, it asks the server whether it has a working
Gemini API key. If not, a dialog asks you for one: create a free key at
[Google AI Studio](https://aistudio.google.com/app/apikey) and paste it here. The
server checks it with Google and saves it to `server/.env`, and the app starts.

You can also put the key in `server/.env` yourself before starting the server
(`cp .env.example .env`, then set `GEMINI_API_KEY`). `server/.env` is
git-ignored.

### Care nearby

The daily summary's **Find care nearby** shows real places from Google Maps
on an OpenStreetMap map. It needs nothing extra: the search runs on the
Gemini API key (see [server/README.md](server/README.md#care-nearby)).

## Tests

Both test suites run offline: no server and no API key are required.

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

- [GenUI](https://github.com/flutter/genui) 
- [A2UI](https://a2ui.org/) ([v0.9 specification](https://a2ui.org/specification/v0.9-a2ui/)), [A2A](https://a2a-protocol.org/) and the
  [Agent Development Kit](https://google.github.io/adk-docs/).
- The body map from the Daily Health Tracker project (Apache 2.0).

## License

Licensed under the [Apache License, Version 2.0](LICENSE). See
[NOTICE](NOTICE) for attribution, and
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the third-party code this
project includes or adapts, which keeps its own license.
