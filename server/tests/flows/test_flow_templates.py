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

"""Checks on what every flow's screens say and do: summaries go back to the
dashboard, and every screen has the shared theme.

Run from server/:  .venv/bin/python -m unittest -v
"""

import json
import unittest

from screens import FLOWS_DIR
from screens import list_flows
from screens import load_screens
from streaming import A2UI_VERSION
from streaming import CATALOG_ID


class FlowTemplatesTest(unittest.TestCase):
    """Checks that hold for the screens of every flow."""

    def test_every_summary_goes_back_to_the_dashboard(self):
        """Each last screen offers "Go to dashboard", not "Log another"."""
        summaries = {
            "nutrition": "saveNutritionEntry",
            "medication": "saveMedicationEntry",
            "pain": "savePainEntry",
            "symptoms": "symptomDetailsEntered",
            "vitals": "vitalsEntered",
        }
        for flow, route in summaries.items():
            screen = load_screens(flow)[route]
            self.assertIn('"name": "goToDashboard"', screen, flow)
            self.assertIn("Go to dashboard", screen, flow)
            self.assertNotIn("Log another", screen, flow)
            # The app handles goToDashboard itself, so no flow routes it.
            self.assertNotIn("goToDashboard", load_screens(flow))

    def test_every_screen_gets_the_shared_theme_in_full(self):
        """Every createSurface has the shared theme, no $include left.

        A screen may restyle text variants for itself, but it keeps the
        shared font, colors and corners, and every shared variant.
        """
        theme_path = FLOWS_DIR / "shared" / "theme.json"
        theme = json.loads(theme_path.read_text())
        for flow in list_flows():
            for route, screen in load_screens(flow).items():
                self.assertNotIn("$include", screen)
                for message in json.loads(screen):
                    if "createSurface" not in message:
                        continue
                    create = message["createSurface"]
                    # A2UI v1.0 has no "theme": it travels as an extension.
                    self.assertNotIn("theme", create)
                    extensions = create["metadata"]["extensions"]
                    screen_theme = extensions["vitalloopTheme"]
                    where = f"{flow} → {route}"
                    for key in ("fontFamily", "cornerRadius", "colors"):
                        self.assertEqual(screen_theme[key], theme[key], where)
                    self.assertLessEqual(
                        set(theme["text"]), set(screen_theme["text"]), where
                    )


class A2uiVersionTest(unittest.TestCase):
    """Every screen is written in A2UI v1.0."""

    def test_every_message_is_a_v1_0_message(self):
        """Each message says version 1.0 and names the app's catalog."""
        for flow in list_flows():
            for route, screen in load_screens(flow).items():
                for message in json.loads(screen):
                    where = f"{flow} → {route}"
                    self.assertEqual(message["version"], A2UI_VERSION, where)
                    if "createSurface" in message:
                        catalog_id = message["createSurface"]["catalogId"]
                        self.assertEqual(catalog_id, CATALOG_ID, where)

    def test_bindings_and_calls_use_the_v1_0_keys(self):
        """Bindings are {"@path"}, calls {"@call"} without a returnType.

        "path" stays in the two places v1.0 keeps it: a list template
        ({"componentId", "path"}) and the updateDataModel message itself.
        """
        for flow in list_flows():
            for route, screen in load_screens(flow).items():
                for message in json.loads(screen):
                    for kind, body in message.items():
                        if kind == "version":
                            continue
                        if kind == "updateDataModel":
                            # Its "path" is a message parameter.
                            body = body.get("value")
                        for problem in _v0_9_leftovers(body):
                            self.fail(f"{flow} → {route}: {problem}")


def _v0_9_leftovers(node):
    """Yields what in [node] is still written the A2UI v0.9 way."""
    if isinstance(node, list):
        for item in node:
            yield from _v0_9_leftovers(item)
        return
    if not isinstance(node, dict):
        return
    if "path" in node and "componentId" not in node:
        yield f'a v0.9 binding {{"path": {node["path"]!r}}}'
    if "call" in node and "args" in node:
        yield f'a v0.9 call {{"call": {node["call"]!r}}}'
    if "@call" in node and "returnType" in node:
        yield f'a returnType on the call to {node["@call"]!r}'
    for value in node.values():
        yield from _v0_9_leftovers(value)


if __name__ == "__main__":
    unittest.main()
