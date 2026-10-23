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

"""Lets the app set up the Gemini API key the first time it runs.

Where this fits: before the app starts any flow, it asks this endpoint whether
the server has a working Gemini API key (main.py adds the route):

  GET  /setup/gemini-key   {"state": "ok" | "missing" | "invalid", ...}
  POST /setup/gemini-key   {"key": "..."}  checks the key with Google, saves it
                           to server/.env and starts using it right away.

A key is only accepted while there is no working one: once the server has a
key that Google accepts, nobody who can reach the server can replace it (change
it in server/.env instead). The key itself is never sent back or logged.
"""

import logging
import os
from pathlib import Path

import dotenv
from google import genai
from google.genai import errors as genai_errors
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette.routing import Route

logger = logging.getLogger(__name__)  # Logs key checks, never the key itself.

# The file the key is saved to: server/.env, next to this file.
ENV_PATH = Path(__file__).parent / ".env"
# The value .env.example ships with; a key equal to it counts as missing.
PLACEHOLDER_KEY = "your_key_here"
# Where developers create a key; the app shows this link.
KEY_URL = "https://aistudio.google.com/app/apikey"
# The URL path of the setup endpoint.
SETUP_PATH = "/setup/gemini-key"


class InvalidKeyError(Exception):
    """Google rejected the key. The message says why, in Google's words."""


async def check_key_with_google(key: str, model: str) -> None:
    """Asks Google whether [key] can use [model].

    Raises:
        InvalidKeyError: Google said no (a wrong or revoked key, or a model
            the key can't use). Network problems raise their own errors, so
            the caller can tell "wrong key" apart from "couldn't ask".
    """
    try:
        client = genai.Client(api_key=key)
        await client.aio.models.get(model=model)
    except genai_errors.ClientError as error:
        if error.code == 404:
            raise InvalidKeyError(
                f"The key works, but the model {model} was not found. "
                "Check GEMINI_MODEL in server/.env."
            ) from error
        raise InvalidKeyError(error.message or str(error)) from error


def current_key() -> str | None:
    """Returns the key the server would use now, or None if there is none.

    Google's library prefers GOOGLE_API_KEY over GEMINI_API_KEY, so this does
    too. Empty values and the .env.example placeholder count as no key.
    """
    key = os.getenv("GOOGLE_API_KEY") or os.getenv("GEMINI_API_KEY") or ""
    key = key.strip()
    if key == "" or key == PLACEHOLDER_KEY:
        return None
    return key


def _answer(state: str, message: str) -> dict:
    """Builds the JSON the app gets.

    Args:
        state: "ok", "missing" or "invalid".
        message: a text the app can show the user.
    """
    return {"state": state, "message": message, "keyUrl": KEY_URL}


class KeySetup:
    """Answers the app's key checks and saves the key it sends.

    Attributes:
        model: the Gemini model every check uses, the same as the flows.
    """

    def __init__(
        self,
        model: str,
        on_new_key,
        check=check_key_with_google,
        env_path: Path = ENV_PATH,
    ):
        """Creates the key setup.

        Args:
            model: the Gemini model to check the key with.
            on_new_key: a function with no arguments that runs after a new
                key is saved, so the flows can switch to it.
            check: the async function that checks a key with Google, called
                as check(key, model). Tests replace it with a fake.
            env_path: the .env file to save the key to. Tests replace it.
        """
        self.model = model
        self._on_new_key = on_new_key
        self._check = check
        self._env_path = env_path
        # The result of checking each key, as (state, Google's reason), so
        # the app's checks don't call Google every time.
        self._results = {}

    def routes(self) -> list[Route]:
        """Returns the Starlette route for SETUP_PATH (GET and POST)."""
        return [
            Route(SETUP_PATH, self._handle_request, methods=["GET", "POST"])
        ]

    async def _handle_request(self, request: Request) -> JSONResponse:
        """Answers GET with the key's status, and POST {"key": ...} by saving.

        This is the endpoint the app calls.
        """
        if request.method == "GET":
            return JSONResponse(await self.status())

        key = await _read_key_from_body(request)
        if key is None:
            return JSONResponse(
                _answer("missing", 'Send JSON like {"key": "..."}.'),
                status_code=400,
            )
        status_code, answer = await self.set_key(key)
        return JSONResponse(answer, status_code=status_code)

    async def status(self) -> dict:
        """Tells whether the server has a working key.

        A key is checked with Google once. If Google can't be reached, the key
        counts as ok for now (and is checked again next time), so being
        offline never locks the app.

        Returns:
            The answer for the app, with state "ok", "missing" or "invalid".
        """
        key = current_key()
        if key is None:
            return _answer("missing", "No Gemini API key is set yet.")

        if key not in self._results:
            try:
                await self._check(key, self.model)
                self._results[key] = ("ok", "")
            except InvalidKeyError as error:
                logger.warning(
                    "The Gemini API key in server/.env was rejected: %s", error
                )
                self._results[key] = ("invalid", str(error))
            except Exception:
                # Offline, a timeout, ...: don't block the app, and don't
                # remember this, so the key is checked again next time.
                logger.warning(
                    "Could not check the Gemini API key with Google",
                    exc_info=True,
                )
                return _answer("ok", "")

        state, reason = self._results[key]
        return _answer(state, reason)

    async def set_key(self, key: str) -> tuple[int, dict]:
        """Checks [key] with Google, saves it and starts using it.

        Returns:
            The HTTP status code and the JSON answer for the app: 200 when the
            key is saved, 400 for an empty or rejected key, 409 when a working
            key is already set, 502 when Google can't be reached.
        """
        key = key.strip()
        if not key:
            return 400, _answer("missing", "Enter a key.")

        # Never replace a working key from the app.
        current_status = await self.status()
        if current_status["state"] == "ok":
            return 409, _answer(
                "ok",
                "A working key is already set. To change it, edit server/.env.",
            )

        try:
            await self._check(key, self.model)
        except InvalidKeyError as error:
            return 400, _answer("invalid", str(error))
        except Exception as error:
            logger.warning(
                "Could not check the new Gemini API key with Google",
                exc_info=True,
            )
            return 502, _answer(
                "missing", f"Could not reach Google to check the key: {error}"
            )

        self._save_key(key)
        self._results[key] = ("ok", "")
        logger.info("Saved a new Gemini API key to %s", self._env_path)
        # Let every flow start over, so it uses the new key.
        self._on_new_key()
        return 200, _answer("ok", "")

    def _save_key(self, key: str) -> None:
        """Saves [key] to the .env file and uses it from now on."""
        # Create the file readable by its owner only (mode 0600) before the
        # key goes in.
        self._env_path.touch(mode=0o600, exist_ok=True)
        dotenv.set_key(self._env_path, "GEMINI_API_KEY", key)
        os.environ["GEMINI_API_KEY"] = key
        # GOOGLE_API_KEY would win over the new key (see current_key), so
        # drop it.
        os.environ.pop("GOOGLE_API_KEY", None)


async def _read_key_from_body(request: Request) -> str | None:
    """Returns the "key" text from the request's JSON body, or None."""
    try:
        body = await request.json()
    except Exception:
        return None  # Not JSON.
    if not isinstance(body, dict):
        return None
    key = body.get("key")
    if not isinstance(key, str):
        return None
    return key
