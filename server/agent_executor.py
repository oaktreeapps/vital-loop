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

"""Connects the A2A protocol to a FlowAgent.

Where this fits in a request: the A2A server (set up in main.py) calls
FlowAgentExecutor.execute() for every request to a flow (step 2 of the flow in
main.py). It:

  1. reads the request: plain text to start a flow, or a UI action (a button
     tap) as a data part;
  2. asks the flow's agent (agent.py) for the next screen;
  3. sends every partial screen to the app as a "working" status update, and
     the complete screen as "input-required" (the app now waits for the
     user's next tap).

Each A2UI message of a screen goes out as its own data part. The Flutter app
reads them with genui_a2a's A2uiAgentConnector.
"""

import json
import logging

from a2a.server.agent_execution import AgentExecutor
from a2a.server.agent_execution import RequestContext
from a2a.server.events import EventQueue
from a2a.server.tasks import TaskUpdater
from a2a.types import DataPart
from a2a.types import Message
from a2a.types import Part
from a2a.types import Task
from a2a.types import TaskState
from a2a.types import TextPart
from a2a.types import UnsupportedOperationError
from a2a.utils import new_agent_parts_message
from a2a.utils import new_agent_text_message
from a2a.utils import new_task
from a2a.utils.errors import ServerError

from agent import FlowAgent

logger = logging.getLogger(__name__)  # Logs each request and reply per flow.


class FlowAgentExecutor(AgentExecutor):
    """Runs one flow's FlowAgent for every A2A request to that flow.

    One conversation with the app is one A2A task: its context_id is also the
    ADK session id, so Gemini sees the user's earlier answers in the same
    flow.

    Attributes:
        agent: the FlowAgent that writes this flow's screens.
    """

    def __init__(self, agent: FlowAgent):
        """Keeps [agent], which answers every request this executor gets."""
        self.agent = agent

    async def execute(
        self, context: RequestContext, event_queue: EventQueue
    ) -> None:
        """Answers one request from the app with the next screen.

        If the app only reported an error, or Gemini fails, the task ends
        without a new screen.
        """
        # The first request of a conversation creates its A2A task.
        task = context.current_task
        if task is None:
            task = new_task(context.message)
            await event_queue.enqueue_event(task)
        updater = TaskUpdater(event_queue, task.id, task.context_id)

        flow = self.agent.flow
        request = _read_request(context.message)
        logger.info("[%s] ← %s", flow, request[:300])

        # The app reports problems with a screen (e.g. a schema error) as
        # {"error": ...}. Log them; there is no new screen to send.
        if _app_reported_error(context.message):
            logger.warning("[%s] The app reported an error: %s", flow, request)
            await updater.complete()
            return

        await self._send_next_screen(request, task, updater)

    async def _send_next_screen(
        self, request: str, task: Task, updater: TaskUpdater
    ) -> None:
        """Streams the next screen to the app while Gemini writes it.

        Every partial screen is a "working" update the app shows right away;
        the complete screen ends the turn as "input-required".
        """
        flow = self.agent.flow
        # We stay one batch behind: only when the next batch arrives do we
        # know the previous one was not the last (complete) screen.
        previous_batch = None
        try:
            batches = self.agent.stream_screen(
                request, session_id=task.context_id
            )
            async for batch in batches:
                if previous_batch is not None:
                    await updater.update_status(
                        TaskState.working,
                        message=_to_a2a_message(previous_batch, task),
                    )
                previous_batch = batch
        except Exception as error:
            logger.exception("[%s] Could not generate the next screen", flow)
            error_message = new_agent_text_message(
                f"Backend error: {error}", task.context_id, task.id
            )
            await updater.failed(error_message)
            return

        # The last batch is the complete screen.
        final_batch = previous_batch
        if final_batch is None:
            final_batch = []
        logger.info("[%s] → %d A2UI messages (final)", flow, len(final_batch))
        await updater.requires_input(
            _to_a2a_message(final_batch, task), final=True
        )

    async def cancel(
        self, context: RequestContext, event_queue: EventQueue
    ) -> None:
        """Cancelling is not supported.

        A screen is quick to generate, so the app simply sends its next
        request instead.
        """
        raise ServerError(error=UnsupportedOperationError())


def _to_a2a_message(batch: list[dict], task: Task) -> Message:
    """Wraps a batch of A2UI messages as one A2A message, one data part each."""
    parts = []
    for a2ui_message in batch:
        parts.append(Part(root=DataPart(data=a2ui_message)))
    return new_agent_parts_message(parts, task.context_id, task.id)


def _read_request(message: Message | None) -> str:
    """Returns the request as text: the user's text, or a UI action as JSON."""
    if message is None:
        return ""
    texts = []
    for part in message.parts:
        if isinstance(part.root, TextPart):
            texts.append(part.root.text)
        elif isinstance(part.root, DataPart):
            texts.append(json.dumps(part.root.data, ensure_ascii=False))
    return "\n".join(texts)


def _app_reported_error(message: Message | None) -> bool:
    """Checks whether the app sent a data part like {"error": ...}."""
    if message is None:
        return False
    for part in message.parts:
        if isinstance(part.root, DataPart) and "error" in part.root.data:
            return True
    return False
