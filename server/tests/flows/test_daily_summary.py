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

"""Checks on the daily summary flow: the summary leads to care nearby, then
the PDF report, and the nearby care step as Gemini and the app see it.

Run from server/:  .venv/bin/python -m unittest -v
"""

import asyncio
import json
import unittest

from google.adk.tools import FunctionTool

from agent import _next_surface_id
from agent import build_instruction
from agent import fill_screen
from agent import FLOW_TOOLS
import places
from screens import load_screens
from streaming import ScreenStreamer
from tests.support.fakes import two_places


class DailySummaryTest(unittest.TestCase):
    """The daily summary's screens, in order."""

    def test_the_summary_leads_to_care_nearby_then_the_pdf(self):
        """Summary → city (asked by the app) → care nearby → PDF report."""
        screens_by_route = load_screens("daily_summary")
        summary = screens_by_route["generateSummary"]
        self.assertIn('"name": "chooseCareCity"', summary)
        self.assertIn("Find care nearby", summary)
        self.assertNotIn("generatePdf", summary)
        # The app asks for the city itself, so no route answers it.
        self.assertNotIn("chooseCareCity", screens_by_route)

        nearby = json.loads(screens_by_route["findNearbyCare"])
        components = {}
        for message in nearby:
            if "updateComponents" in message:
                for component in message["updateComponents"]["components"]:
                    components[component["id"]] = component
        # The map and the list show the same places.
        self.assertEqual(components["map"]["component"], "CareMap")
        self.assertEqual(components["list"]["component"], "CareList")
        for component_id in ("map", "list"):
            self.assertEqual(
                components[component_id]["places"], {"path": "/places"}
            )
            self.assertEqual(
                components[component_id]["selected"],
                {"path": "/selectedPlaceId"},
            )
        # Generate PDF is the last thing on the screen, and leads on to the
        # report as before.
        self.assertEqual(components["root"]["children"][-1], "pdf")
        self.assertEqual(
            components["pdf"]["action"]["event"]["name"], "generatePdf"
        )
        self.assertIn("PdfReport", screens_by_route["generatePdf"])


class NearbyCareFlowTest(unittest.TestCase):
    """The daily summary's nearby care step, as Gemini and the app see it."""

    def test_gemini_lists_only_ids_and_reasons(self):
        """Gemini writes each place's id and reason; the server adds the
        facts. Copying every fact made the screen slow to write."""
        screen = json.loads(load_screens("daily_summary")["findNearbyCare"])
        listed = screen[1]["updateDataModel"]["value"]["places"]["$places"]
        for place in listed["example"]:
            self.assertEqual(set(place), {"id", "reason"})

    def test_the_maps_calls_think_little(self):
        """The Google Maps calls ask for low thinking, to answer quickly."""
        gemini = two_places()
        asyncio.run(places._ask_maps("find", gemini))
        config = gemini.configs[0]
        self.assertEqual(config.thinking_config.thinking_level, "LOW")

    def test_only_the_daily_summary_has_the_search_tool(self):
        """Gemini can search for care in the daily summary flow only."""
        self.assertEqual(
            FLOW_TOOLS, {"daily_summary": [places.search_care_places]}
        )

    def test_the_tool_declaration_has_the_city_and_searches(self):
        """ADK turns the tool into a declaration with both parameters."""
        tool = FunctionTool(places.search_care_places)
        declaration = tool._get_declaration()
        self.assertEqual(declaration.name, "search_care_places")
        # ADK 2.x describes the parameters as a JSON schema.
        schema = declaration.parameters_json_schema
        self.assertEqual(schema["required"], ["city", "searches"])
        self.assertEqual(schema["properties"]["searches"]["type"], "array")

    def test_the_instruction_explains_the_tool_and_places(self):
        """Gemini is told when to search and how to list the places."""
        words = " ".join(build_instruction("daily_summary").split())
        self.assertIn("call the search_care_places tool ONCE", words)
        self.assertIn('keep the "$places" key', words)
        self.assertIn('Template for "findNearbyCare"', words)

    def test_the_streamed_data_model_never_holds_unchecked_places(self):
        """While streaming, the "$places" list is checked before it's sent."""
        places._found_places.clear()
        screen = load_screens("daily_summary")["findNearbyCare"]
        counts = {}
        streamer = ScreenStreamer(
            rename=lambda surface_id: _next_surface_id(surface_id, counts),
            fill=fill_screen,
        )
        reply = "```json\n" + screen + "\n```"
        sent = []
        for end in range(40, len(reply) + 40, 40):
            sent += streamer.feed(reply[:end])

        data_models = [m for m in sent if "updateDataModel" in m]
        self.assertEqual(len(data_models), 1)
        value = data_models[0]["updateDataModel"]["value"]
        # The template's example places aren't real, so they are dropped.
        self.assertEqual(value["places"], [])
        self.assertNotIn("$places", json.dumps(sent))


if __name__ == "__main__":
    unittest.main()
