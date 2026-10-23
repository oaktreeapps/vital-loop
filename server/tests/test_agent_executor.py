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

"""Tests for agent_executor.py's helpers: reading the app's request, and
wrapping the screens as an A2A message. No LLM calls.

Run from server/:  .venv/bin/python -m unittest -v
"""

from types import SimpleNamespace
import unittest

from a2a.types import DataPart
from a2a.types import Message
from a2a.types import Part
from a2a.types import Role
from a2a.types import TextPart

from agent_executor import _app_reported_error
from agent_executor import _read_request
from agent_executor import _to_a2a_message


def _message(*parts) -> Message:
    """A message from the app with [parts]: text (str) or data (dict)."""
    wrapped = []
    for part in parts:
        if isinstance(part, str):
            wrapped.append(Part(root=TextPart(text=part)))
        else:
            wrapped.append(Part(root=DataPart(data=part)))
    return Message(role=Role.user, parts=wrapped, message_id="m1")


class ReadRequestTest(unittest.TestCase):
    """Turning the app's request into text for Gemini."""

    def test_text_is_read_as_it_is(self):
        """The user's text is the request."""
        self.assertEqual(
            _read_request(_message("Log my lunch")), "Log my lunch"
        )

    def test_a_ui_action_is_read_as_json(self):
        """A button press (a data part) becomes its JSON, accents kept."""
        action = {"name": "savePainEntry", "context": {"area": "Épaule"}}
        self.assertEqual(
            _read_request(_message(action)),
            '{"name": "savePainEntry", "context": {"area": "Épaule"}}',
        )

    def test_several_parts_are_joined_line_by_line(self):
        """Every part is read, one per line."""
        self.assertEqual(
            _read_request(_message("Hello", {"a": 1})), 'Hello\n{"a": 1}'
        )

    def test_no_message_is_an_empty_request(self):
        """Nothing sent: an empty request."""
        self.assertEqual(_read_request(None), "")


class AppReportedErrorTest(unittest.TestCase):
    """Noticing when the app reports that it couldn't draw a screen."""

    def test_an_error_data_part_is_an_error_report(self):
        """A data part with an "error" key is a report."""
        cases = [
            (_message({"error": "Catalog not found"}), True),
            (_message("Hello", {"error": {"code": 1}}), True),
            (_message({"name": "savePainEntry"}), False),
            (_message("error"), False),
            (None, False),
        ]
        for message, reported in cases:
            with self.subTest(message=message):
                self.assertEqual(_app_reported_error(message), reported)


class ToA2aMessageTest(unittest.TestCase):
    """Sending a batch of screens to the app."""

    def test_each_a2ui_message_is_one_data_part(self):
        """One data part per A2UI message, in order, for the task."""
        batch = [
            {"version": "v0.9", "createSurface": {"surfaceId": "s"}},
            {"version": "v0.9", "deleteSurface": {"surfaceId": "old"}},
        ]
        task = SimpleNamespace(id="task-1", context_id="context-1")
        message = _to_a2a_message(batch, task)
        self.assertEqual([part.root.data for part in message.parts], batch)
        self.assertEqual(message.task_id, "task-1")
        self.assertEqual(message.context_id, "context-1")


if __name__ == "__main__":
    unittest.main()
