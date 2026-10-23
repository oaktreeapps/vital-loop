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

"""The LLM agent for one flow: answers each request with the next A2UI screen.

Where this fits in a request: agent_executor.py calls
FlowAgent.stream_screen() (step 3 of the flow in main.py). The agent:

  1. builds the instruction for Gemini: the flow's prompt.md, the current
     time, the template rules below and every screen template (screens.py);
  2. sends the user's request to Gemini through ADK and reads the reply while
     it streams in, turning it into partial screens (streaming.py);
  3. parses the complete reply, and asks Gemini once more if it was not valid
     A2UI JSON.

The LLM only fills each template with the user's answers (and writes a few
texts, e.g. a summary). Some flows also give it tools (FLOW_TOOLS), e.g. the
daily summary's search for care nearby (places.py). ADK keeps the
conversation history per session.
"""

from datetime import datetime
import json
import logging
import os
import re

from google.adk.agents import LlmAgent
from google.adk.agents.run_config import RunConfig
from google.adk.agents.run_config import StreamingMode
from google.adk.runners import InMemoryRunner
from google.genai import types

from places import resolve_places
from places import search_care_places
from screens import load_prompt
from screens import load_screens
from streaming import ScreenStreamer

logger = logging.getLogger(__name__)  # Logs invalid replies and retries.

# The Gemini model every flow uses. Set GEMINI_MODEL in server/.env to change
# it. main.py loads .env before importing this file, so the value is there.
MODEL = os.getenv("GEMINI_MODEL", "gemini-3-flash-preview")

# The tools each flow's agent may call, by flow name. A flow not listed here
# has none: Gemini only fills its templates.
FLOW_TOOLS = {
    "daily_summary": [search_care_places],
}

# ADK sessions belong to a user. The app has only one user, so one fixed id
# is enough.
USER_ID = "app_user"

# What we tell Gemini when its reply was not valid A2UI JSON. The error is
# added in front of it.
RETRY_REQUEST = (
    "Answer the previous request again with ONE ```json block holding the "
    "full A2UI message array."
)

# The rules for filling the screen templates, added to every flow's
# instruction. They tell Gemini to copy each template exactly and to change
# only the placeholders and the "$ai" parts.
TEMPLATE_RULES = """
SCREEN TEMPLATES
Every step of this flow is an A2UI JSON template below, keyed by the request
that shows it: "start" is the first request; every other key is the name of the
UI action the user just sent (a JSON object like
{"action": {"name": ..., "context": {...}}}).
Answer every request with the template for that request, as ONE ```json block
containing the full message array:
- Keep every message, component, id, layout property, text and surfaceId
  exactly as in the template. Never add, remove or reorder components.
- Replace each placeholder "{{name}}" with the value of `name` from the user's
  earlier actions. A placeholder that is the whole JSON value becomes that
  value as JSON (a list stays a list, a number stays a number); a placeholder
  inside a longer string becomes plain text.
- A placeholder "{{now}}" becomes the current local date and time given above,
  as "yyyy-MM-ddTHH:mm:00".
- A placeholder "{{a|text}}" becomes the value of a as readable plain text
  (lists joined with ", "); "{{a|lower}}" the same in lowercase, and
  "{{a|upper}}" in uppercase.
- Filters chain left to right: "{{a,b|list|text}}" merges a and b into one
  list, then turns it into readable text.
- A placeholder "{{a,b|list}}" becomes one list of strings with the values of
  a and b (lists merged, comma-separated text split).
- A placeholder "{{a,b|rows}}" becomes a list of rows
  {"item": <name>, "amount": "1 serving"}, one per value of a and b (lists, or
  comma-separated text).
- A value {"$ai": "<instruction>", "example": <example>} is a part YOU
  generate: replace the whole object with your own value that follows the
  instruction and has exactly the same JSON shape as the example (e.g. a list
  of {"label", "value"} options). Never copy the example itself, and never
  leave "$ai" in your answer.
- A value {"$places": ...} is a list of places a tool found: keep the
  "$places" key and write the list inside it. List only places the tool
  returned, each with its exact "id" and only the other keys the example
  shows. The server adds each place's facts from the tool's results and
  drops any other place.
- A value {"$place": "{{name}}"} is one place a tool found: keep the "$place"
  key and only fill its placeholder with the place's id (an empty string if
  there is none). The server puts the place's details there.
- You may tailor the lists of choices offered to the user (e.g. food
  suggestions) to this user, and you may write a summary's insight text
  yourself. Where the flow's instructions say you write a text yourself (e.g.
  a summary's title or overview), write it in place of the template's text.
  Change nothing else.
"""


def build_instruction(flow: str) -> str:
    """Builds the full instruction Gemini gets for [flow], as one text.

    It is the flow's prompt, the current time, the template rules and every
    screen template. It is built again on every request, so edits to the
    flow's files show up without a restart.
    """
    now = datetime.now().strftime("%Y-%m-%dT%H:%M:00")
    parts = [
        load_prompt(flow),
        f"Current local date and time: {now}",
        TEMPLATE_RULES,
    ]
    for route, screen in load_screens(flow).items():
        parts.append(f'Template for "{route}":\n```json\n{screen}\n```')
    return "\n\n".join(parts)


class FlowAgent:
    """Talks to Gemini (through ADK) for one flow, e.g. "nutrition".

    Each A2A conversation is one ADK session (the session id comes from the
    executor), so Gemini remembers the user's earlier answers in the flow.

    Attributes:
        flow: the flow's name, the same as its folder in flows/.
        runner: the ADK runner that runs the LLM agent and keeps the sessions
            in memory (they are lost when the server stops).
        surface_counts: per session, how often each surfaceId was created.
    """

    def __init__(self, flow: str):
        """Creates the ADK agent and runner for [flow]."""
        self.flow = flow
        self.reset()

    def reset(self) -> None:
        """Starts over with a new ADK agent and runner, and no sessions.

        Called after a new Gemini API key is saved: ADK keeps the Gemini
        client it made on the first call, with the key of that moment, so only
        a new agent uses the new key.
        """
        agent = LlmAgent(
            name=f"{self.flow}_agent",
            model=MODEL,
            # A function instead of a text, so ADK doesn't treat the
            # templates' {{placeholders}} as its own {state} variables.
            instruction=self._instruction,
            tools=list(FLOW_TOOLS.get(self.flow, [])),
        )
        self.runner = InMemoryRunner(agent=agent, app_name=self.flow)
        # Per session: how often each surfaceId was sent (see
        # _next_surface_id).
        self.surface_counts = {}

    def _instruction(self, context) -> str:
        """Returns the instruction ADK sends to Gemini on every request.

        ADK passes a [context] we don't need.
        """
        return build_instruction(self.flow)

    async def stream_screen(self, request: str, session_id: str):
        """Yields the next screen while Gemini writes it.

        This is what agent_executor.py calls for every request.

        Args:
            request: the user's request: text, or a UI action as JSON.
            session_id: the conversation's id, so Gemini sees its history.

        Yields:
            Lists of A2UI messages: each time more of the screen is ready
            (see streaming.py), and at the end the complete screen. If the
            streamed reply turns out to be invalid, Gemini is asked once more
            without streaming, and the last list is the screen of that retry.
        """
        counts = self.surface_counts.setdefault(session_id, {})
        streamer = ScreenStreamer(
            # A surface the app already has gets a new id, e.g. "<id>_2".
            rename=lambda surface_id: _next_surface_id(surface_id, counts),
            fill=fill_screen,
        )

        # Send each partial screen as soon as it is ready.
        reply = ""  # The reply so far; after the loop, the complete reply.
        async for reply in self._ask_stream(request, session_id):
            batch = streamer.feed(reply)
            if batch:
                yield batch

        # The complete screen.
        messages = await self._parse_or_ask_again(reply, session_id)
        logger.info(
            "[%s] Streamed %d partial update(s) before the full screen",
            self.flow,
            streamer.updates,
        )
        yield streamer.finish(fill_screen(messages))

    async def _parse_or_ask_again(
        self, reply: str, session_id: str
    ) -> list[dict]:
        """Parses Gemini's reply, asking once more if it is not valid.

        Raises:
            ValueError: the second reply is invalid too.
        """
        try:
            return parse_a2ui(reply)
        except ValueError as error:
            # One retry, like Verdure: tell the LLM what was wrong.
            logger.warning(
                "[%s] Invalid reply (%s), retrying", self.flow, error
            )
            retry_text = f"Your last answer was invalid: {error}. "
            retry_text += RETRY_REQUEST
            reply = await self._ask(retry_text, session_id)
            return parse_a2ui(reply)

    async def _ask(self, text: str, session_id: str) -> str:
        """Sends [text] to Gemini and returns its complete reply."""
        await self._ensure_session(session_id)
        message = types.Content(role="user", parts=[types.Part(text=text)])

        reply = ""
        events = self.runner.run_async(
            user_id=USER_ID, session_id=session_id, new_message=message
        )
        async for event in events:
            if event.is_final_response() and _has_text_parts(event):
                reply = _answer_text(event)
        return reply

    async def _ask_stream(self, text: str, session_id: str):
        """Sends [text] to Gemini and yields its reply while it grows.

        Yields:
            The whole reply so far, each time it grows. The last value is the
            complete reply.
        """
        await self._ensure_session(session_id)
        message = types.Content(role="user", parts=[types.Part(text=text)])

        so_far = ""  # All the text of the reply received until now.
        events = self.runner.run_async(
            user_id=USER_ID,
            session_id=session_id,
            new_message=message,
            run_config=RunConfig(streaming_mode=StreamingMode.SSE),
        )
        async for event in events:
            if not _has_text_parts(event):
                continue
            chunk = _answer_text(event)
            if event.partial:
                # A piece of the reply: add it to what we have.
                so_far += chunk
                yield so_far
            elif event.is_final_response() and chunk:
                # The whole reply at once: the source of truth for the end.
                so_far = chunk
                yield so_far

    async def _ensure_session(self, session_id: str) -> None:
        """Creates the ADK session [session_id] if it doesn't exist yet.

        The first request of a conversation creates it; later requests reuse
        it, so the LLM sees the earlier messages.
        """
        sessions = self.runner.session_service
        session = await sessions.get_session(
            app_name=self.flow, user_id=USER_ID, session_id=session_id
        )
        if session is None:
            await sessions.create_session(
                app_name=self.flow, user_id=USER_ID, session_id=session_id
            )


def _has_text_parts(event) -> bool:
    """Checks whether an ADK event has content with parts."""
    if event.content and event.content.parts:
        return True
    return False


def _answer_text(event) -> str:
    """Returns the text of an ADK event's parts.

    Gemini's "thought" parts are left out, so the text holds only the answer.
    """
    texts = []
    for part in event.content.parts:
        if part.text and not part.thought:
            texts.append(part.text)
    return "".join(texts)


def parse_a2ui(reply: str) -> list[dict]:
    """Reads the list of A2UI messages in Gemini's reply.

    The messages are in the reply's ```json block; if there is none, the
    whole reply is read as JSON. A single message object becomes a list of
    one.

    Raises:
        ValueError: the JSON is broken or holds no messages, so the caller
            can ask again.
    """
    code_block = re.search(r"```(?:json)?\s*(.*?)```", reply, re.DOTALL)
    if code_block:
        json_text = code_block.group(1)
    else:
        json_text = reply

    # Broken JSON raises json.JSONDecodeError, which is a ValueError.
    messages = json.loads(json_text)
    if isinstance(messages, dict):
        messages = [messages]
    if not isinstance(messages, list) or not messages:
        raise ValueError("expected a JSON array of A2UI messages")
    return messages


def fill_screen(node):
    """Finishes Gemini's screen [node] before the app gets it.

    Unfilled "$ai" parts become their examples (use_examples), then every
    "$places" list is checked against the places a tool really found
    (places.resolve_places). Returns a new value; [node] is not changed.
    """
    return resolve_places(use_examples(node))


def use_examples(node):
    """Replaces each {"$ai": ..., "example": ...} left unfilled by its example.

    So the screen still works when the LLM forgot to write a part. Goes
    through [node] (any parsed JSON value) recursively and returns a new
    value; [node] itself is not changed.
    """
    if isinstance(node, dict):
        if "$ai" in node:
            logger.warning("The LLM left a $ai part unfilled: %s", node["$ai"])
            return node.get("example")
        filled_dict = {}
        for key, value in node.items():
            filled_dict[key] = use_examples(value)
        return filled_dict

    if isinstance(node, list):
        filled_list = []
        for item in node:
            filled_list.append(use_examples(item))
        return filled_list

    return node


def _next_surface_id(surface_id: str, counts: dict[str, int]) -> str:
    """Returns the id to create [surface_id] under, and counts it.

    The first time that is [surface_id] itself, then "<id>_2", "<id>_3", ...
    (the app can't create a surface twice).
    """
    counts[surface_id] = counts.get(surface_id, 0) + 1
    if counts[surface_id] == 1:
        return surface_id
    return f"{surface_id}_{counts[surface_id]}"
