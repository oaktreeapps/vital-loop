# VitalLoop client (Flutter)

The Flutter app of [VitalLoop](../README.md). It has no screens of its own
for the tracking flows: it asks the [server](../server/) for each screen and
draws the [A2UI](https://a2ui.org/) v1.0 JSON it gets back with
[`a2ui_flutter`](https://pub.dev/packages/a2ui_flutter) and
[`a2ui_core`](https://pub.dev/packages/a2ui_core), adding a few custom components of
its own (body map, severity scale, vital sign cards, care map and list, PDF
report).

## Running

Start the [server](../server/README.md) first, then:

```bash
flutter pub get
flutter run
```

In Android Studio or VS Code, open this `client/` folder (not the repository
root) as the project.

### Connecting to the server

The app finds the server at `http://localhost:10002` by default, or at
`http://10.0.2.2:10002` on the Android emulator (the emulator's name for your
computer).

| Device | What to do |
| --- | --- |
| iOS simulator, web | Nothing |
| Android emulator | Nothing |
| Android phone over USB | Run `adb reverse tcp:10002 tcp:10002` (again after each reconnect), then `flutter run --dart-define=BACKEND_URL=http://localhost:10002` |
| Any phone over Wi-Fi | Start the server with `--host 0.0.0.0`, then `flutter run --dart-define=BACKEND_URL=http://<your computer's IP>:10002` |

`BACKEND_URL` overrides the default; see `lib/services/backend_transport.dart`.

### The Gemini API key

On start, `GeminiKeyGate` asks the server whether it has a working Gemini API
key (`lib/services/gemini_key_setup.dart`). Until it does, the dashboard can't be
used:

- **No key, or a key Google rejects:** a dialog asks for one, with a link to
  create it. The server checks the key with Google and saves it to
  `server/.env`; a rejected key shows Google's reason.
- **Server not running:** a dialog says how to start it, with a Retry button.

The key lives on the server only; the app never stores it.

### The care map

The daily summary's care nearby screen shows the places on an
[OpenStreetMap](https://www.openstreetmap.org/) map
([`flutter_map`](https://pub.dev/packages/flutter_map)), on every platform.
It needs no key. The map credits "OpenStreetMap contributors" and sends the
app's id with each tile request, as OpenStreetMap's
[tile usage policy](https://operations.osmfoundation.org/policies/tiles/)
asks; that policy is meant for light use like this demo. The places
themselves come from the server (see
[Care nearby](../server/README.md#care-nearby)). With no places, a card links
to the city on Google Maps instead of the map.

## Project structure

```
lib/
  main.dart                  App entry point: logging, theme, DashboardScreen
  core/                      App-wide setup
    app_logging.dart         Colored logs for every class (package:logging → logger)
    router/                  The screens' paths (app_routes) and the go_router setup
    theme/                   The app's colors, a screen's JSON theme → Flutter theme,
                             and the Text component's Markdown (headings)
    utils/                   Readable dates, times and answers
  models/                    Plain data and rules, no widgets
    tracking_flow.dart       A flow: name, start message, catalog, what it saves
    health_log.dart          In-memory log of saved entries
    health_option.dart       The options on the dashboard
    health_report.dart       The daily report's content
    severity_level.dart      Severity bands (mild … severe)
    care_place.dart          A place to get care, as the nearby search found it
    vitals/                  Ranges, units and status of each vital sign
    body_map/                The body map's regions and their outlines
  services/                  Talking to the server, and building the PDF
    transport.dart           What a flow's backend must do (Transport)
    a2a_client.dart          A small A2A client: message/stream over HTTP
    backend_transport.dart   The Transport to one flow's agent on the server
    gemini_key_setup.dart    Checks the server's Gemini API key, sends a new one
    genui_session.dart       Connects a Transport to a2ui_core's MessageProcessor
    pdf_report_builder.dart  Builds the daily report PDF
  flows/                     One file per flow: its TrackingFlow and catalog
  catalog/                   VitalLoop's A2UI v1.0 catalog
    vitalloop_catalog.dart   The catalog: a2ui_flutter's basic components and
                             functions, plus the app's own
    shared/                  Used by several components: catalog_item.dart
                             (what a component is), count_function.dart
                             (the app's one extra function), data_binding.dart
                             (reading JSON props, binding a value),
                             care_place_schema.dart, open_link.dart and
                             widgets/ (status chip, unit switch, round button)
    <component>/             One of the 10 custom components: the CatalogItem
                             (schema + builder), and widgets/
                             with the widgets only that component uses:
      blood_pressure_input/  heart_rate_input/  temperature_input/
      blood_sugar_input/     severity_input/    body_map_picker/
      icon_badge/            pdf_report/        care_map/
      care_list/
  screens/
    dashboard_screen.dart    Home: the flows, today's badges, Generate summary
    tracking_flow_screen.dart  Runs one flow and shows its latest screen
    catalog_screen.dart      Preview of every catalog component, with its JSON
                             and schema
    gemini_key_gate.dart     First-run key check; blocks the app until the key works
  widgets/                   The screens' widgets, one per file
    common/                  Shared by screens: the dialog frame, the text field
                             style, the green button, line icons
    dashboard/               Option cards, badges, the summary bar
    flow/                    A flow's body, loading and error views, and the
                             care nearby city dialog
    key_setup/               The Gemini key and "can't reach the server" dialogs
    component_preview/       The catalog preview's cards and JSON views
test/                        Tests, in the same folders as lib/ (no server,
                             no Gemini); see Tests below
tool/app_icon/               The app icon, drawn in code, and its generator
```

## Navigation

Screens are opened by path with [`go_router`](https://pub.dev/packages/go_router)
(`lib/core/router/`):

| Path | Screen |
| --- | --- |
| `/` | `DashboardScreen` |
| `/flow/<name>` | `TrackingFlowScreen` for that flow, e.g. `/flow/pain` |
| `/summary` | `TrackingFlowScreen` with today's daily summary |
| `/catalog` | `CatalogScreen` |

Every path sits under the dashboard, so back always returns there, also after
opening a path directly (on the web, from the address bar). The Gemini key
check (`GeminiKeyGate`) wraps every route. Dialogs and bottom sheets aren't
routes; they still close with `Navigator.pop`.

## How a flow runs

1. `DashboardScreen` opens `/flow/<name>`, a `TrackingFlowScreen` for the flow
   you tap.
2. `TrackingFlowScreen` creates a `GenUiSession` with that flow's catalog and a
   `BackendTransport` to `<server>/<flow>`, and sends the flow's start message.
3. The server streams A2UI v1.0 messages back. `GenUiSession` passes them to
   a2ui_core's `MessageProcessor`, and the screen builds up as they arrive.
4. A button tap goes back to the server as a UI action, and the next screen
   streams in. `goToDashboard` and the report's `finish` are handled in the
   app and never sent (`finish` also clears the log, to start again), and so
   is `chooseCareCity`: the app asks for a city in a dialog, then sends
   `findNearbyCare` with it.
5. The flow's save action adds an entry to `HealthLog`, which the dashboard
   badges and the daily summary read.

## Extending

### Add a custom component

Create a folder for it in `lib/catalog/`, holding the `CatalogItem` (name,
JSON schema, widget builder, example data) and a `widgets/` folder with its
widgets; put any rules in `lib/models/`. Add it to the flow's catalog (`lib/flows/`), and use it from the flow's JSON
in `../server/flows/`. The in-app catalog (`CatalogScreen`) shows it in its
Custom tab on its own, from the flows' custom items; give it example data so
it has a preview. The Default tab shows the A2UI basic components, which
come from `a2ui_flutter`.

### Add a flow

1. Add the flow's folder on the server (see
   [server/README.md](../server/README.md)).
2. Add a `TrackingFlow` with the same `name` in `lib/flows/<name>_flow.dart`
   and list it on the dashboard (`lib/models/health_option.dart`). Its path,
   `/flow/<name>`, works right away.
3. Add a widget test in `test/flows/<name>_flow_test.dart` using
   `test/support/fake_backend.dart`.

### Change the app icon

The VitalLoop icon (a ring, the loop, closed by a heartbeat line, with an
amber bead on the ring) is drawn in `tool/app_icon/app_icon_painter.dart`. After changing it, rebuild every
Android, iOS and web icon file with:

```bash
GENERATE_ICONS=1 flutter test tool/app_icon/generate_icons_test.dart
```

Without `GENERATE_ICONS` the generator is skipped, so running all the tests
never rewrites the icons.

## Tests

```bash
flutter test                  # everything
flutter test test/models      # one folder
```

The tests don't need the server or a key: `test/support/fake_backend.dart`
reads the real screen templates from `../server/flows/` and plays the server's
part. Run them from this `client/` folder.

`test/` has the same folders as `lib/`, so the test for
`lib/models/health_log.dart` is `test/models/health_log_test.dart`:

```
test/
  app_test.dart       The app opens on the dashboard
  catalog/            Each component's card; that every example passes its
                      schema (catalog_examples_test.dart); the catalog itself,
                      with every example and the server's first screens held
                      to the strict v1.0 rules (vitalloop_catalog_test.dart);
                      and the expressions the screens use (shared/)
  core/               Routes, the surface theme, text formatting
  flows/              Each flow from start to summary, against the real
                      templates
  models/             Plain logic, no widgets: vitals ranges, severity, the
                      health log, the report, care places, the body map
  screens/            The dashboard, catalog, key check and flow screens
  services/           The session, the A2A client and transport, the key
                      setup calls, the PDF builder
  widgets/            The small shared widgets: buttons, dialogs, the bars
  a2ui/               How the app takes a streamed screen, and what it rejects
  support/            Shared helpers: the fake backend, test setup, fakes
  fixtures/           Data files the tests read
```

To add a test, put it next to its twin in `lib/` and call
`setUpTestEnvironment()` (from `test/support/test_utils.dart`) at the top of
`main` if it pumps widgets.

## Logging

Every class logs its part of a flow through `package:logging`, printed in color
by `package:logger` (see `lib/core/app_logging.dart`): requests sent, A2UI messages
received, surfaces built and actions tapped.

## Dependencies

- `google_fonts` stays on 8.x. Version 9 uses the separate `material_ui`
  package, whose `TextTheme` isn't Flutter's own, so this app doesn't
  compile with it.
- `a2ui_core` and `a2ui_flutter` (the versions in `pubspec.yaml`) process
  and render A2UI v1.0. They replace `genui`, which only speaks A2UI v0.9.
  The basic components (Text, Row, Button, …) and functions are theirs; the
  app styles them through the Flutter theme
  (`lib/core/theme/surface_theme.dart`).
- `flutter_markdown_plus` renders the Text component's Markdown, which is
  how a screen writes a heading (`## Title`).
- The app talks A2A to the server with its own small client
  (`lib/services/a2a_client.dart`) over `http`.
