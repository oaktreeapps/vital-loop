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

"""Tests for agent.py's helpers: the instruction Gemini gets, reading its
reply, $ai parts and surface ids. No LLM calls.

Run from server/:  .venv/bin/python -m unittest -v
"""

import json
import unittest

from agent import _next_surface_id
from agent import build_instruction
from agent import parse_a2ui
from agent import use_examples
from screens import load_screens

# Helpers used by the tests below.


def _find_ai_parts(node, where, found: list) -> None:
    """Adds the name of every $ai part under [node] to [found].

    The name is the id of the component the part is in (for "options",
    "text" and "overview"), or else the key that holds the part. [where] is
    that name for [node] itself.
    """
    if isinstance(node, dict):
        if "$ai" in node:
            found.append(where)
            return
        for key, value in node.items():
            if key in ("options", "text", "overview"):
                child_where = node.get("id", key)
            else:
                child_where = key
            _find_ai_parts(value, child_where, found)
    elif isinstance(node, list):
        for item in node:
            _find_ai_parts(item, where, found)


def _ai_parts(flow: str, route: str) -> list:
    """Returns the names of the $ai parts in one screen."""
    found = []
    screen = json.loads(load_screens(flow)[route])
    _find_ai_parts(screen, None, found)
    return found


class AgentTest(unittest.TestCase):
    """Tests for agent.py's helpers: the instruction, parsing and ids."""

    def test_the_instruction_has_the_prompt_and_every_template(self):
        """The instruction holds the prompt, the rules and every template."""
        instruction = build_instruction("nutrition")
        self.assertIn("Food / Nutrition logging assistant", instruction)
        self.assertIn("SCREEN TEMPLATES", instruction)
        self.assertIn('Template for "start"', instruction)
        self.assertIn('Template for "saveNutritionEntry"', instruction)
        self.assertIn('"id": "tile_breakfast"', instruction)
        self.assertIn("{{mealType}}", instruction)
        self.assertIn("{{foodItems,otherFood|rows}}", instruction)

    def test_parse_a2ui_reads_the_json_block(self):
        """parse_a2ui reads the ```json block and rejects a reply without."""
        message = {"version": "v0.9", "deleteSurface": {"surfaceId": "a"}}
        reply = "Here you go.\n```json\n" + json.dumps([message]) + "\n```"
        self.assertEqual(parse_a2ui(reply), [message])
        with self.assertRaises(ValueError):
            parse_a2ui("Sorry, I can't do that.")

    def test_the_medicine_chips_are_generated_by_the_llm(self):
        """The medication flow asks the LLM to write the medicine chips."""
        instruction = build_instruction("medication")
        self.assertIn('"$ai": "6 common medicines', instruction)
        # The rules are wrapped over several lines, so compare the words.
        words = " ".join(instruction.split())
        self.assertIn("is a part YOU generate", words)

    def test_lists_and_the_summary_overview_are_generated_by_the_llm(self):
        """The choice lists and the daily summary texts are $ai parts."""
        self.assertIn("picked", _ai_parts("symptoms", "start"))
        self.assertIn("picked", _ai_parts("nutrition", "mealTypeSelected"))
        self.assertIn("picked", _ai_parts("medication", "start"))
        self.assertEqual(
            sorted(_ai_parts("daily_summary", "generateSummary")),
            ["overview", "overview_lead", "title"],
        )
        self.assertEqual(
            sorted(_ai_parts("daily_summary", "findNearbyCare")),
            ["$places", "center", "emptyText", "subtitle", "title"],
        )
        self.assertIn("report", _ai_parts("daily_summary", "generatePdf"))
        # The food suggestions follow the meal type the user picked.
        self.assertIn(
            "meal type the user just picked", build_instruction("nutrition")
        )
        self.assertIn(
            "written for the user's doctor", build_instruction("daily_summary")
        )

    def test_an_unfilled_ai_part_falls_back_to_its_example(self):
        """A $ai part the LLM left in its reply becomes its example."""
        options = [{"label": "A", "value": "A"}]
        reply = [
            {"options": {"$ai": "Some options", "example": options}, "id": "x"}
        ]
        self.assertEqual(use_examples(reply), [{"options": options, "id": "x"}])

    def test_a_surface_created_again_gets_a_new_id(self):
        """A second "step_1" in the same session becomes "step_1_2"."""
        counts = {}
        self.assertEqual(_next_surface_id("step_1", counts), "step_1")
        self.assertEqual(_next_surface_id("step_1", counts), "step_1_2")
        self.assertEqual(_next_surface_id("step_1", counts), "step_1_3")


if __name__ == "__main__":
    unittest.main()
