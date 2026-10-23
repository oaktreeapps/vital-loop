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

"""Starts the backend: one A2A agent per flow in flows/.

Each flow is served at its own URL, e.g. the nutrition flow at
  http://localhost:10002/nutrition                              (requests)
  http://localhost:10002/nutrition/.well-known/agent-card.json  (agent card)

How a request flows:
  1. main.py (this file): the web server receives the app's A2A request at
     /<flow> and hands it to that flow's A2A request handler.
  2. agent_executor.py: reads the request (text, or a button tap's UI action)
     and asks the flow's agent for the next screen.
  3. agent.py: builds Gemini's instruction from the flow's prompt.md and
     screen templates (loaded by screens.py), and sends the request to
     Gemini through ADK.
  4. streaming.py: while Gemini is still writing, turns its reply so far into
     partial A2UI screens.
  5. agent_executor.py: sends each partial screen to the app as a "working"
     update, and the complete screen as "input-required".

Separately, key_setup.py answers /setup/gemini-key, where the app checks the
Gemini API key (and sends one) before it starts any flow.

Run:  python main.py            (the app asks for a Gemini key if needed)
      python main.py --port 8080
"""

import argparse
import logging

from a2a.server.apps import A2AStarletteApplication
from a2a.server.request_handlers import DefaultRequestHandler
from a2a.server.tasks import InMemoryTaskStore
from a2a.types import AgentCapabilities
from a2a.types import AgentCard
from a2a.types import AgentSkill
from dotenv import load_dotenv
from starlette.applications import Starlette
from starlette.middleware.cors import CORSMiddleware
import uvicorn

# Load server/.env first: agent.py reads GEMINI_MODEL when it is imported.
load_dotenv()

from agent import FlowAgent  # noqa: E402
from agent import MODEL  # noqa: E402
from agent_executor import FlowAgentExecutor  # noqa: E402
from key_setup import current_key  # noqa: E402
from key_setup import KeySetup  # noqa: E402
from key_setup import SETUP_PATH  # noqa: E402
from screens import list_flows  # noqa: E402

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s %(name)s: %(message)s"
)
logger = logging.getLogger("backend")  # Logs which flows are served, and where.


def agent_card(flow: str, base_url: str) -> AgentCard:
    """Describes one flow's agent to A2A clients.

    The app (and any other A2A client) can read this card at
    <base_url>/<flow>/.well-known/agent-card.json to learn the agent's name,
    its request URL and that it supports streaming.
    """
    return AgentCard(
        name=f"VitalLoop: {flow}",
        description=(
            f"Guides the user through the {flow} flow with generated UI."
        ),
        url=f"{base_url}/{flow}",
        version="1.0.0",
        default_input_modes=["text"],
        default_output_modes=["text"],
        capabilities=AgentCapabilities(streaming=True),
        skills=[
            AgentSkill(
                id=flow,
                name=flow,
                description=f"Logs {flow} entries step by step.",
                tags=["health", flow],
            )
        ],
    )


def add_flow(app: Starlette, flow: str, base_url: str) -> FlowAgent:
    """Adds one flow's A2A routes to [app] and returns the flow's agent.

    Each flow gets its own agent, executor and task store, so flows never
    share conversation state.
    """
    agent = FlowAgent(flow)
    request_handler = DefaultRequestHandler(
        agent_executor=FlowAgentExecutor(agent),
        task_store=InMemoryTaskStore(),
    )
    a2a_app = A2AStarletteApplication(
        agent_card=agent_card(flow, base_url),
        http_handler=request_handler,
    )
    a2a_app.add_routes_to_app(
        app,
        agent_card_url=f"/{flow}/.well-known/agent-card.json",
        rpc_url=f"/{flow}",
    )
    logger.info("Flow %-14s → %s/%s", flow, base_url, flow)
    return agent


def add_key_setup(
    app: Starlette, agents: list[FlowAgent], base_url: str
) -> None:
    """Adds the /setup/gemini-key routes to [app] (see key_setup.py).

    The app checks the Gemini API key there first, and sends one if needed.
    After a new key, every flow's agent starts over so it uses the new key.
    """

    def reset_all_agents() -> None:
        """Makes every flow use the new key."""
        for agent in agents:
            agent.reset()

    key_setup = KeySetup(MODEL, on_new_key=reset_all_agents)
    app.router.routes.extend(key_setup.routes())
    logger.info("Key setup        → %s%s", base_url, SETUP_PATH)


def main():
    """Reads the command line, builds the web app and starts the server.

    All flows share one Starlette app and one port; each flow only gets its
    own URL path. Without a Gemini API key it still starts, so the app can
    ask for one and send it to /setup/gemini-key (see key_setup.py).
    """
    parser = argparse.ArgumentParser(description="VitalLoop backend")
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=10002)
    args = parser.parse_args()

    if current_key() is None:
        # Start anyway: the app asks for the key and sends it here.
        logger.warning(
            "No Gemini API key yet. Open the app to add one, or set "
            "GEMINI_API_KEY in server/.env (see .env.example)."
        )

    base_url = f"http://{args.host}:{args.port}"
    app = Starlette()  # The one web app that holds the routes of every flow.

    agents = []
    for flow in list_flows():
        agents.append(add_flow(app, flow, base_url))
    add_key_setup(app, agents, base_url)

    # Lets the app run in a browser too (flutter run -d chrome).
    app.add_middleware(
        CORSMiddleware,
        allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
        allow_methods=["*"],
        allow_headers=["*"],
    )

    uvicorn.run(app, host=args.host, port=args.port)


if __name__ == "__main__":
    main()
