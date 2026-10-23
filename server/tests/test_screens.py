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

"""Tests for screens.py: finding the flows and loading their screen
templates, with includes and {{slots}} filled.

Run from server/:  .venv/bin/python -m unittest -v
"""

import json
from pathlib import Path
import re
import tempfile
import unittest

import screens
from screens import list_flows
from screens import load_screens


class ScreensTest(unittest.TestCase):
    """Tests for screens.py: finding flows and loading their templates."""

    def test_every_flow_is_found(self):
        """list_flows() finds every flow folder under flows/."""
        self.assertEqual(
            list_flows(),
            [
                "daily_summary",
                "medication",
                "nutrition",
                "pain",
                "symptoms",
                "vitals",
            ],
        )

    def test_every_route_in_flow_json_loads_a_screen(self):
        """Every route in flow.json gives a screen, in the file's order."""
        self.assertEqual(
            list(load_screens("nutrition")),
            [
                "start",
                "mealTypeSelected",
                "foodItemsEntered",
                "quantitiesEntered",
                "mealTimeSelected",
                "saveNutritionEntry",
            ],
        )
        self.assertEqual(
            list(load_screens("medication")),
            [
                "start",
                "medicineNameEntered",
                "doseScheduleEntered",
                "saveMedicationEntry",
            ],
        )

    def test_shared_screens_get_each_flows_values_for_their_slots(self):
        """Shared screens are valid JSON with every {{slot}} filled per flow."""
        unfilled_slot = r"\{\{(tag|row)\d|\{\{(surfaceId|stepLabel)"
        for flow in list_flows():
            for route, screen in load_screens(flow).items():
                json.loads(screen)  # Valid JSON.
                self.assertIsNone(
                    re.search(unfilled_slot, screen),
                    f"{flow} → {route} has an unfilled slot",
                )
        medication = load_screens("medication")
        self.assertIn(
            '"surfaceId": "medication_step_3_notes"',
            medication["doseScheduleEntered"],
        )
        self.assertIn("Go to dashboard", medication["saveMedicationEntry"])

    def test_keys_next_to_an_include_change_the_included_json(self):
        """{"$include": ..., "text": {...}} merges into the shared file."""
        with tempfile.TemporaryDirectory() as tmp:
            flows = Path(tmp)
            (flows / "a").mkdir()
            (flows / "a" / "flow.json").write_text('{"start": "one.json"}')
            (flows / "a" / "one.json").write_text(
                '[{"theme": {"$include": "t.json",'
                ' "text": {"body": {"size": 15}}, "extra": 1}}]'
            )
            (flows / "a" / "t.json").write_text(
                '{"font": "X", "text": {"body": {"size": 14, "weight": 400},'
                ' "h2": {"size": 24}}}'
            )

            original_flows_dir = screens.FLOWS_DIR
            screens.FLOWS_DIR = flows
            try:
                screen = load_screens("a")["start"]
            finally:
                screens.FLOWS_DIR = original_flows_dir

        self.assertEqual(
            json.loads(screen)[0]["theme"],
            {
                "font": "X",
                "text": {
                    "body": {"size": 15, "weight": 400},
                    "h2": {"size": 24},
                },
                "extra": 1,
            },
        )

    def test_includes_resolve_relative_to_the_including_file(self):
        """An $include path is relative to the file that has it."""
        with tempfile.TemporaryDirectory() as tmp:
            flows = Path(tmp)
            (flows / "a").mkdir()
            (flows / "shared").mkdir()
            (flows / "a" / "flow.json").write_text('{"start": "one.json"}')
            (flows / "a" / "one.json").write_text(
                '[{"theme": {"$include": "../shared/t.json"}}]'
            )
            (flows / "shared" / "t.json").write_text(
                '{"font": "X", "colors": {"$include": "c.json"}}'
            )
            (flows / "shared" / "c.json").write_text('{"primary": "#123456"}')

            original_flows_dir = screens.FLOWS_DIR
            screens.FLOWS_DIR = flows
            try:
                screen = load_screens("a")["start"]
            finally:
                screens.FLOWS_DIR = original_flows_dir

        self.assertEqual(
            json.loads(screen),
            [{"theme": {"font": "X", "colors": {"primary": "#123456"}}}],
        )

    def test_fill_slots_whole_values_as_json_text_inside_strings(self):
        """Whole-value slots become JSON, slots in text become escaped text."""
        filled = screens._fill_slots(
            '{"a": "{{x}}", "b": "Step {{y}}", "c": "{{answer}}"}',
            {"x": {"call": "f"}, "y": '3 "of" 3'},
        )
        self.assertEqual(
            json.loads(filled),
            {"a": {"call": "f"}, "b": 'Step 3 "of" 3', "c": "{{answer}}"},
        )


if __name__ == "__main__":
    unittest.main()
