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

"""Tests for key_setup.py: the app's first-run Gemini API key check.

Google is never called: a fake check stands in for it, and every test uses its
own temporary .env and a clean environment, so the real key is never touched.

Run from server/:  .venv/bin/python -m unittest -v
"""

import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from starlette.applications import Starlette
from starlette.testclient import TestClient

from key_setup import InvalidKeyError
from key_setup import KeySetup
from key_setup import PLACEHOLDER_KEY
from key_setup import SETUP_PATH

# A key the fake Google check accepts.
GOOD_KEY = "good-key-123"
# A key the fake Google check rejects.
BAD_KEY = "bad-key-456"


class FakeGoogle:
    """Stands in for check_key_with_google.

    Accepts GOOD_KEY, rejects BAD_KEY, and acts as if offline while [offline]
    is set. [calls] counts the checks, to test the cache.
    """

    def __init__(self):
        """Starts online, with no checks made."""
        self.offline = False
        self.calls = 0

    async def __call__(self, key: str, model: str) -> None:
        """Checks [key] the way Google would, without the network."""
        self.calls += 1
        if self.offline:
            raise ConnectionError("no network")
        if key != GOOD_KEY:
            raise InvalidKeyError(
                "API key not valid. Please pass a valid API key."
            )


class KeySetupTest(unittest.TestCase):
    """The GET and POST /setup/gemini-key endpoint, through a test client."""

    def setUp(self):
        """A clean environment, a temporary .env and a test client."""
        # An empty os.environ, so the real key is never seen or changed.
        clean_environment = mock.patch.dict(os.environ, {}, clear=True)
        clean_environment.start()
        self.addCleanup(clean_environment.stop)

        # A temporary folder for the .env file.
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.env_path = Path(folder.name) / ".env"

        self.google = FakeGoogle()
        self.new_keys = 0  # How often on_new_key ran.

        def on_new_key():
            """Counts the agent resets main.py would do."""
            self.new_keys += 1

        setup = KeySetup(
            "test-model",
            on_new_key,
            check=self.google,
            env_path=self.env_path,
        )
        self.client = TestClient(Starlette(routes=setup.routes()))

    def state(self) -> str:
        """The key state the app would see now."""
        return self.client.get(SETUP_PATH).json()["state"]

    def post(self, body) -> tuple[int, dict]:
        """Sends [body] as JSON, like the app.

        Returns:
            The HTTP status code and the JSON answer.
        """
        response = self.client.post(SETUP_PATH, json=body)
        return response.status_code, response.json()

    def test_no_key_or_the_example_placeholder_is_missing(self):
        """No key, or .env.example's placeholder, makes the app ask for one."""
        self.assertEqual(self.state(), "missing")
        os.environ["GEMINI_API_KEY"] = PLACEHOLDER_KEY
        self.assertEqual(self.state(), "missing")
        self.assertEqual(self.google.calls, 0)

    def test_a_working_key_is_ok_and_checked_only_once(self):
        """A key Google accepts is ok, and the answer is cached."""
        os.environ["GEMINI_API_KEY"] = GOOD_KEY
        self.assertEqual(self.state(), "ok")
        self.assertEqual(self.state(), "ok")
        self.assertEqual(self.google.calls, 1)

    def test_a_rejected_key_is_invalid_with_googles_reason(self):
        """A key Google rejects makes the app ask again, saying why."""
        os.environ["GEMINI_API_KEY"] = BAD_KEY
        answer = self.client.get(SETUP_PATH).json()
        self.assertEqual(answer["state"], "invalid")
        self.assertIn("API key not valid", answer["message"])
        self.assertIn("aistudio.google.com", answer["keyUrl"])

    def test_offline_never_locks_the_app_and_checks_again_later(self):
        """If Google can't be reached, the key counts as ok (not cached)."""
        os.environ["GEMINI_API_KEY"] = GOOD_KEY
        self.google.offline = True
        self.assertEqual(self.state(), "ok")
        self.google.offline = False
        self.assertEqual(self.state(), "ok")
        self.assertEqual(self.google.calls, 2)

    def test_saving_a_working_key(self):
        """A good key is saved to .env, used at once, and flows start over."""
        status, answer = self.post({"key": f"  {GOOD_KEY}  "})
        self.assertEqual((status, answer["state"]), (200, "ok"))
        self.assertIn(GOOD_KEY, self.env_path.read_text())
        self.assertEqual(os.environ["GEMINI_API_KEY"], GOOD_KEY)
        self.assertEqual(self.new_keys, 1)
        self.assertEqual(self.state(), "ok")

    def test_saving_drops_google_api_key_which_would_win(self):
        """GOOGLE_API_KEY would override the new key, so it is removed."""
        os.environ["GOOGLE_API_KEY"] = BAD_KEY
        self.assertEqual(self.post({"key": GOOD_KEY})[0], 200)
        self.assertNotIn("GOOGLE_API_KEY", os.environ)

    def test_a_rejected_key_is_not_saved(self):
        """A key Google rejects is reported, and nothing changes."""
        status, answer = self.post({"key": BAD_KEY})
        self.assertEqual((status, answer["state"]), (400, "invalid"))
        self.assertIn("API key not valid", answer["message"])
        self.assertFalse(self.env_path.exists())
        self.assertEqual(self.new_keys, 0)

    def test_a_working_key_cannot_be_replaced_from_the_app(self):
        """Once the server has a working key, the app can't swap it."""
        os.environ["GEMINI_API_KEY"] = GOOD_KEY
        status, answer = self.post({"key": "someone-elses-key"})
        self.assertEqual(status, 409)
        self.assertIn("server/.env", answer["message"])
        self.assertEqual(os.environ["GEMINI_API_KEY"], GOOD_KEY)
        self.assertEqual(self.new_keys, 0)

    def test_an_invalid_key_can_be_replaced(self):
        """A key Google rejects (e.g. revoked) can be replaced from the app."""
        os.environ["GEMINI_API_KEY"] = BAD_KEY
        self.assertEqual(self.post({"key": GOOD_KEY})[0], 200)
        self.assertEqual(self.state(), "ok")

    def test_google_unreachable_while_saving(self):
        """If Google can't be reached, the key is not saved; the app is told."""
        self.google.offline = True
        status, answer = self.post({"key": GOOD_KEY})
        self.assertEqual(status, 502)
        self.assertIn("Could not reach Google", answer["message"])
        self.assertFalse(self.env_path.exists())

    def test_bad_requests(self):
        """An empty key or a body without a key is rejected."""
        self.assertEqual(self.post({"key": "   "})[0], 400)
        self.assertEqual(self.post({"nope": GOOD_KEY})[0], 400)
        response = self.client.post(SETUP_PATH, content=b"not json")
        self.assertEqual(response.status_code, 400)

    def test_the_key_is_never_sent_back(self):
        """No answer ever contains the key."""
        os.environ["GEMINI_API_KEY"] = GOOD_KEY
        get_response = self.client.get(SETUP_PATH)
        self.assertNotIn(GOOD_KEY, get_response.text)
        post_response = self.client.post(SETUP_PATH, json={"key": GOOD_KEY})
        self.assertNotIn(GOOD_KEY, post_response.text)


if __name__ == "__main__":
    unittest.main()
