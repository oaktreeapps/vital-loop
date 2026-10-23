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
                    screen_theme = message["createSurface"]["theme"]
                    where = f"{flow} → {route}"
                    for key in ("fontFamily", "cornerRadius", "colors"):
                        self.assertEqual(screen_theme[key], theme[key], where)
                    self.assertLessEqual(
                        set(theme["text"]), set(screen_theme["text"]), where
                    )


if __name__ == "__main__":
    unittest.main()
