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

"""Tests for streaming.py: building each screen live while Gemini writes
it, as valid partial screens.

Run from server/:  .venv/bin/python -m unittest -v
"""

import json
import unittest

from agent import _next_surface_id
from agent import parse_a2ui
from agent import use_examples
from screens import list_flows
from screens import load_screens
from streaming import CATALOG_ID
from streaming import partial_screen
from streaming import ScreenStreamer
from streaming import visible_tree

# Helpers used by the tests below.


def _child_ids(component: dict) -> list:
    """Returns every child id a component points at.

    Like streaming.py's _required_child_ids, but also with the plain
    "children" list, so a test can check that no component points at a
    missing child.
    """
    child_ids = []
    for key in ("child", "entryPointChild", "contentChild"):
        child_ids.append(component.get(key))
    children = component.get("children")
    if isinstance(children, list):
        child_ids += children
    elif isinstance(children, dict):
        child_ids.append(children.get("componentId"))

    only_ids = []
    for child_id in child_ids:
        if isinstance(child_id, str):
            only_ids.append(child_id)
    return only_ids


def _stream(screen: str, chunk: int = 37, counts: dict | None = None):
    """Feeds [screen] to a ScreenStreamer as if the LLM wrote it.

    Args:
        screen: the screen's JSON text.
        chunk: how many characters the LLM writes at a time.
        counts: the surface counts of the session; a new one if None.

    Returns:
        (every message sent, final ones included; the ScreenStreamer).
    """
    if counts is None:
        counts = {}
    streamer = ScreenStreamer(
        rename=lambda surface_id: _next_surface_id(surface_id, counts),
        fill=use_examples,
    )
    reply = "```json\n" + screen + "\n```"

    sent = []
    for end in range(chunk, len(reply) + chunk, chunk):
        sent += streamer.feed(reply[:end])
    sent += streamer.finish(use_examples(parse_a2ui(reply)))
    return sent, streamer


def _message_kind(message: dict) -> str:
    """Returns a message's kind, e.g. "createSurface"."""
    for key in message:
        if key != "version":
            return key
    return ""


class StreamingTest(unittest.TestCase):
    """Tests for streaming.py: building every screen live from a reply."""

    def test_every_screen_streams_as_valid_partial_screens(self):
        """Every template streams as valid partial screens, then in full."""
        for flow in list_flows():
            for route, screen in load_screens(flow).items():
                self._check_screen_streams(f"{flow} → {route}", screen)

    def _check_screen_streams(self, where: str, screen: str) -> None:
        """Streams one screen and checks every message sent."""
        sent, streamer = _stream(screen)
        kinds = []
        for message in sent:
            kinds.append(_message_kind(message))

        # createSurface once, first, then the data model (if any).
        self.assertEqual(kinds.count("createSurface"), 1, where)
        self.assertEqual(kinds[0], "createSurface", where)
        if "updateDataModel" in kinds:
            self.assertEqual(kinds[1], "updateDataModel", where)

        # Every partial screen is complete in itself.
        updates = []
        for message in sent:
            if "updateComponents" in message:
                updates.append(message["updateComponents"]["components"])
        for components in updates:
            ids = set()
            for component in components:
                ids.add(component["id"])
            self.assertIn("root", ids, where)
            for component in components:
                for child_id in _child_ids(component):
                    error = f"{where}: {component['id']} → {child_id}"
                    self.assertIn(child_id, ids, error)

        # It builds up in steps, and ends as the whole screen.
        self.assertGreater(streamer.updates, 2, where)
        full_components = None
        for message in use_examples(json.loads(screen)):
            if "updateComponents" in message:
                full_components = message["updateComponents"]["components"]
                break
        self.assertEqual(updates[-1], full_components, where)

    def test_partial_screen_reads_unfinished_json(self):
        """partial_screen reads what is complete, even with brackets in text."""
        # The reply stops in the middle of component "b".
        reply = (
            "```json\n"
            '[{"version": "v0.9", "createSurface": {"surfaceId": "s"}},\n'
            '{"version": "v0.9", "updateComponents": {"surfaceId": "s", '
            '"components": ['
            '{"id": "root", "component": "Column", "children": ["a", "b"]},'
            '{"id": "a", "component": "Text", '
            '"text": "It\\"s [not] {a} brace"},'
            '{"id": "b", "component": "Text", "te'
        )
        messages, (surface_id, components) = partial_screen(reply)
        self.assertEqual(len(messages), 1)
        self.assertEqual(surface_id, "s")
        self.assertEqual([c["id"] for c in components], ["root", "a"])

        # "b" isn't complete, so root shows only "a".
        root = visible_tree(components)[0]
        self.assertEqual(root["id"], "root")
        self.assertEqual(root["children"], ["a"])

    def test_clearing_deletes_never_remove_the_streamed_screen(self):
        """A deleteSurface for the streamed surface is not sent at the end."""
        # The nutrition start screen first deletes every surface of the flow,
        # its own included, to clear a previous meal.
        screen = load_screens("nutrition")["start"]
        surface_id = None
        for message in json.loads(screen):
            if "createSurface" in message:
                surface_id = message["createSurface"]["surfaceId"]
                break
        counts = {}
        sent, _ = _stream(screen, counts=counts)

        deleted = []
        for message in sent:
            if "deleteSurface" in message:
                deleted.append(message["deleteSurface"]["surfaceId"])
        self.assertIn("nutrition_summary", deleted)
        self.assertNotIn(surface_id, deleted)
        self.assertIn("updateComponents", sent[-1])
        self.assertEqual(sent[-1]["updateComponents"]["surfaceId"], surface_id)
        # A delete doesn't use up a surface id: the summary is created as
        # itself.
        self.assertNotIn("nutrition_summary", counts)

    def test_a_repeated_surface_is_renamed_live_and_at_the_end(self):
        """A surface sent twice gets the new id live and at the end."""
        screen = load_screens("vitals")["start"]
        counts = {}
        _stream(screen, counts=counts)
        sent, _ = _stream(screen, counts=counts)

        surface_ids = set()
        for message in sent:
            for body in message.values():
                if isinstance(body, dict) and "surfaceId" in body:
                    surface_ids.add(body["surfaceId"])
        self.assertEqual(surface_ids, {"vitals_step_1_readings_2"})

    def test_a_wrong_catalog_id_is_sent_as_the_apps_catalog(self):
        """A createSurface with a catalog the app lacks gets the app's one."""
        # Gemini once shortened the id, and the app couldn't draw the screen.
        screen = load_screens("daily_summary")["findNearbyCare"]
        screen = screen.replace(
            CATALOG_ID, "https://a2ui.org/specification/v0_9/catalog.json"
        )
        self.assertNotIn(CATALOG_ID, screen)
        sent, _ = _stream(screen)

        catalog_ids = []
        for message in sent:
            if "createSurface" in message:
                catalog_ids.append(message["createSurface"]["catalogId"])
        self.assertEqual(catalog_ids, [CATALOG_ID])


if __name__ == "__main__":
    unittest.main()
