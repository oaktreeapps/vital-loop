# Copyright 2026 Oaktreeapps
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Loads a flow's prompt and A2UI screen templates from flows/<flow>/.

Where this fits in a request: agent.py calls load_prompt() and load_screens()
every time it builds the instruction for Gemini, so edits to the files show up
without a restart. main.py calls list_flows() once, at start-up.

Each flow folder has:
  flow.json   which screen answers which request (the "routes")
  prompt.md   the flow's instructions for the LLM
  *.json      one A2UI screen per step

A route is "start" (the first request) or the name of the UI action the user
just sent, e.g. "mealTypeSelected". Its value is a screen file, or a shared
screen with the values for its {{slots}}:
  {"screen": "../shared/notes.json", "with": {"stepLabel": "Step 5 of 5"}}

A screen can pull in another file with {"$include": "../shared/theme.json"}.
Keys next to "$include" change the included JSON for that screen only, e.g.
{"$include": "../shared/theme.json", "text": {"body": {"size": 15}}}.
"""

import json
from pathlib import Path

# The folder with one sub-folder per flow (plus "shared" for common parts).
# Tests may point it at a temporary folder.
FLOWS_DIR = Path(__file__).parent / "flows"


def list_flows() -> list[str]:
    """Returns every folder in flows/ that has a flow.json, sorted by name."""
    flows = []
    for folder in FLOWS_DIR.iterdir():
        if (folder / "flow.json").exists():
            flows.append(folder.name)
    return sorted(flows)


def load_prompt(flow: str) -> str:
    """Returns the flow's prompt.md: its instructions for the LLM."""
    prompt_path = FLOWS_DIR / flow / "prompt.md"
    return prompt_path.read_text()


def load_screens(flow: str) -> dict[str, str]:
    """Loads the screen of every route in the flow's flow.json.

    Args:
        flow: the flow's folder name, e.g. "nutrition".

    Returns:
        {route: screen}, in the order of flow.json. Each screen is indented
        JSON text with every $include expanded and the route's slots filled.
    """
    flow_folder = FLOWS_DIR / flow
    routes = _read_json_file(flow_folder / "flow.json")

    screens = {}
    for route, target in routes.items():
        # Keys like "_comment" are notes for people, not routes.
        if route.startswith("_"):
            continue
        screens[route] = _load_route_screen(flow_folder, target)
    return screens


def _load_route_screen(flow_folder: Path, target) -> str:
    """Loads the screen one route points at, as JSON text.

    Args:
        flow_folder: the flow's folder; file names are relative to it.
        target: a screen file name, or {"screen": <file>, "with": <slots>}.
    """
    if isinstance(target, str):
        file_name = target
        slots = {}
    else:
        file_name = target["screen"]
        slots = target.get("with", {})

    screen_path = (flow_folder / file_name).resolve()
    screen = _read_json_file(screen_path)
    screen = _expand_includes(screen, screen_path.parent)
    return _fill_slots(_to_json(screen), slots)


def _expand_includes(node, base_dir: Path):
    """Replaces every {"$include": "path"} in [node] with that file's JSON.

    [node] is any parsed JSON value; this goes through it recursively and
    returns a new value. A path is relative to the folder of the file that
    has the $include ([base_dir]), and an included file may include other
    files in turn. Other keys next to "$include" are merged into the included
    JSON (see _merge), so a screen can change a few values of a shared file.
    """
    if isinstance(node, dict):
        # A dict with "$include" is replaced by the included file, with the
        # dict's other keys on top.
        if "$include" in node:
            included_path = (base_dir / node["$include"]).resolve()
            included = _read_json_file(included_path)
            # Paths in the included file are relative to its own folder.
            expanded = _expand_includes(included, included_path.parent)
            overrides = {k: v for k, v in node.items() if k != "$include"}
            return _merge(expanded, _expand_includes(overrides, base_dir))

        expanded_dict = {}
        for key, value in node.items():
            expanded_dict[key] = _expand_includes(value, base_dir)
        return expanded_dict

    if isinstance(node, list):
        expanded_list = []
        for item in node:
            expanded_list.append(_expand_includes(item, base_dir))
        return expanded_list

    return node


def _merge(base, overrides):
    """Returns [base] with [overrides] on top.

    Objects are merged key by key, recursively; any other value in
    [overrides] replaces the one in [base].
    """
    if not isinstance(base, dict) or not isinstance(overrides, dict):
        return overrides
    merged = dict(base)
    for key, value in overrides.items():
        merged[key] = _merge(base[key], value) if key in base else value
    return merged


def _fill_slots(screen: str, slots: dict) -> str:
    """Fills a shared screen's {{slots}} with one flow's values.

    "{{slot}}" as a whole JSON value becomes the slot's value as JSON; a text
    slot inside a longer string becomes plain text. Placeholders that are not
    slots (e.g. "{{mealType}}") stay for the LLM to fill from the user's
    answers.
    """
    for name, value in slots.items():
        placeholder = "{{" + name + "}}"
        value_as_json = _to_json(value)

        # The whole JSON value, quotes included: "{{slot}}" -> the value.
        screen = screen.replace('"' + placeholder + '"', value_as_json)

        # Inside a longer string: "Step {{slot}}" -> the text, still escaped
        # for JSON ([1:-1] drops the quotes around the JSON string).
        if isinstance(value, str):
            screen = screen.replace(placeholder, value_as_json[1:-1])
    return screen


def _read_json_file(path: Path):
    """Reads and parses the JSON file at [path]."""
    return json.loads(path.read_text())


def _to_json(value) -> str:
    """Returns [value] as indented JSON text, with non-ASCII text readable."""
    return json.dumps(value, indent=2, ensure_ascii=False)
