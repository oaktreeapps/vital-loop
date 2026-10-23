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

"""Fakes for OpenStreetMap and Gemini, so the places tests need no key or
network.
"""

from types import SimpleNamespace

import httpx

import places

# Sacramento, as OpenStreetMap returns it for a search for the city.
SACRAMENTO = {
    "name": "Sacramento",
    "display_name": "Sacramento, California, United States",
    "lat": "38.58",
    "lon": "-121.49",
    "boundingbox": ["38.43", "38.69", "-121.56", "-121.36"],
}


class FakeOpenStreetMap:
    """Answers city lookups: [found] for the given feature types.

    Keeps every request in [requests], for the tests to check.
    """

    def __init__(self, found=None, status: int = 200):
        self.found = {"settlement": [SACRAMENTO]} if found is None else found
        self.status = status
        self.requests = []

    def __call__(self, request: httpx.Request) -> httpx.Response:
        self.requests.append(request)
        if self.status != 200:
            return httpx.Response(self.status, json=[])
        feature = request.url.params.get("featureType", "")
        return httpx.Response(200, json=self.found.get(feature, []))


def maps_answer(*titles, text: str = "") -> SimpleNamespace:
    """A Gemini answer that used these Google Maps places.

    Each title is (place id, Google Maps title).
    """
    chunks = [
        SimpleNamespace(
            maps=SimpleNamespace(
                place_id=place_id,
                title=f"{title} - Google Maps",
                uri=f"https://maps.google.com/?cid={place_id}",
            )
        )
        for place_id, title in titles
    ]
    metadata = SimpleNamespace(grounding_chunks=chunks)
    return SimpleNamespace(
        text=text, candidates=[SimpleNamespace(grounding_metadata=metadata)]
    )


def place_line(name: str, lat="38.57", lng="-121.48", **cells) -> str:
    """One line of Gemini's place details, as the prompt asks for."""
    values = {
        "address": f"{name} Street, Sacramento",
        "rating": "4.5",
        "count": "1,204",
        "phone": "+1 916-555-0100",
        "website": "https://example.com",
        "kind": "Hospital",
        **cells,
    }
    return " | ".join(
        [
            name,
            values["address"],
            lat,
            lng,
            values["rating"],
            values["count"],
            values["phone"],
            values["website"],
            values["kind"],
        ]
    )


class FakeGemini:
    """Answers with [answers] in order, and keeps every prompt."""

    def __init__(self, *answers):
        self.answers = list(answers)
        self.prompts = []
        self.configs = []
        self.aio = SimpleNamespace(models=self)

    async def generate_content(self, *, model, contents, config):
        self.prompts.append(contents)
        self.configs.append(config)
        answer = self.answers.pop(0)
        if isinstance(answer, Exception):
            raise answer
        return answer


async def find_near_sacramento(
    gemini: FakeGemini, searches: list, osm=None
) -> dict:
    """Runs find_care for Sacramento against fakes."""
    osm = osm or FakeOpenStreetMap()
    transport = httpx.MockTransport(osm)
    async with httpx.AsyncClient(transport=transport) as client:
        return await places.find_care(
            "Sacramento", searches, client=client, gemini=gemini
        )


def two_places() -> FakeGemini:
    """Gemini finding places a and b, then giving their details."""
    return FakeGemini(
        maps_answer(("a", "Place a"), ("b", "Place b")),
        maps_answer(text=f"{place_line('Place a')}\n{place_line('Place b')}"),
    )
