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

"""Tests for places.py: the nearby care search and the place check.

OpenStreetMap is replaced by a fake HTTP transport, and Gemini by a fake
client, so no key or network is needed.

Run from server/:  .venv/bin/python -m unittest -v
"""

import unittest
from unittest import mock

from google.genai import errors as genai_errors
import httpx

from agent import fill_screen
import places
from tests.support.fakes import FakeGemini
from tests.support.fakes import FakeOpenStreetMap
from tests.support.fakes import find_near_sacramento
from tests.support.fakes import maps_answer
from tests.support.fakes import place_line
from tests.support.fakes import SACRAMENTO
from tests.support.fakes import two_places


class FindCareTest(unittest.IsolatedAsyncioTestCase):
    """Searching for care near a city with OpenStreetMap and Gemini."""

    def setUp(self):
        places._found_places.clear()

    async def test_finds_care_near_the_city(self):
        """The city is looked up, then Gemini finds the places and details."""
        osm = FakeOpenStreetMap()
        gemini = two_places()
        found = await find_near_sacramento(gemini, ["orthopedic clinic"], osm)

        self.assertEqual(found["city"]["name"], "Sacramento")
        self.assertEqual(
            found["city"]["center"], {"lat": 38.58, "lng": -121.49}
        )
        self.assertEqual([p["id"] for p in found["places"]], ["a", "b"])
        first = found["places"][0]
        self.assertEqual(first["name"], "Place a")
        self.assertEqual(first["kind"], "Hospital")
        self.assertEqual(first["type"], "hospital")
        # A negative longitude keeps its minus sign.
        self.assertEqual((first["lat"], first["lng"]), (38.57, -121.48))
        self.assertEqual(first["rating"], 4.5)
        self.assertEqual(first["ratingCount"], 1204)
        self.assertEqual(first["phone"], "+1 916-555-0100")
        self.assertEqual(first["mapsUrl"], "https://maps.google.com/?cid=a")
        self.assertEqual(first["foundFor"], "orthopedic clinic")

        # OpenStreetMap: a city first, with a User-Agent naming the app.
        request = osm.requests[0]
        self.assertEqual(request.url.params["featureType"], "settlement")
        self.assertEqual(request.headers["user-agent"], places.USER_AGENT)
        # Gemini: find the places, then ask for exactly those by name.
        self.assertIn("orthopedic clinic", gemini.prompts[0])
        self.assertIn("Sacramento", gemini.prompts[0])
        self.assertIn("- Place a\n- Place b", gemini.prompts[1])

    async def test_only_real_places_with_a_position(self):
        """A place Google Maps didn't return, or without a valid position or
        near the city, is left out. Google's names win."""
        gemini = FakeGemini(
            maps_answer(
                ("a", "Place a"),
                ("c", "Place c - Best Hospital, Cancer Center"),
                ("c", "Review of Place c"),
                ("far", "Far Place"),
                ("x", "Shifted Place"),
                ("y", "No Position"),
            ),
            maps_answer(
                text="\n".join(
                    [
                        "Here are the places:",
                        place_line("Place a"),
                        place_line("Place c"),
                        place_line("Invented Clinic"),
                        place_line("Far Place", lat="34.05", lng="-118.24"),
                        place_line("Shifted Place", lat="2825", lng="38.5"),
                        place_line("No Position", lat="-", lng="-"),
                    ]
                )
            ),
        )
        found = await find_near_sacramento(gemini, ["hospital"])
        self.assertEqual([p["id"] for p in found["places"]], ["a", "c"])
        self.assertEqual(found["places"][1]["name"], "Place c")
        # Place c's review is the same place: asked for once.
        self.assertEqual(gemini.prompts[1].count("Place c"), 1)

    async def test_all_kinds_of_care_in_one_search(self):
        """Up to three kinds in one search: two Gemini requests in all.
        None at all means "doctor"."""
        gemini = FakeGemini(maps_answer(("a", "Place a")), maps_answer())
        await find_near_sacramento(gemini, ["a", " ", "b", "c", "d"])
        self.assertEqual(len(gemini.prompts), 2)
        self.assertIn("a or b or c,", gemini.prompts[0])
        self.assertNotIn("c or d", gemini.prompts[0])

        gemini = FakeGemini(maps_answer())
        found = await find_near_sacramento(gemini, [])
        self.assertIn("are doctor,", gemini.prompts[0])
        # Nothing found: no second request.
        self.assertEqual(len(gemini.prompts), 1)
        self.assertEqual(found["places"], [])

    async def test_a_city_is_an_area_never_a_shop(self):
        """Without a city, a state or a country is tried; nothing else."""
        osm = FakeOpenStreetMap({"state": [dict(SACRAMENTO, name="CA")]})
        found = await find_near_sacramento(two_places(), ["hospital"], osm)
        self.assertEqual(found["city"]["name"], "CA")
        features = [r.url.params["featureType"] for r in osm.requests]
        self.assertEqual(features, ["settlement", "state"])

    async def test_an_unknown_city_is_an_error(self):
        """A city OpenStreetMap can't find gives a message for the user."""
        osm = FakeOpenStreetMap({})
        with self.assertRaisesRegex(places.PlacesError, "No place called"):
            await find_near_sacramento(two_places(), ["hospital"], osm)
        features = [r.url.params["featureType"] for r in osm.requests]
        self.assertEqual(features, ["settlement", "state", "country"])

    async def test_the_city_lookup_failing_is_an_error(self):
        """OpenStreetMap refusing or unreachable: a PlacesError."""
        with self.assertRaisesRegex(places.PlacesError, "HTTP 503"):
            await find_near_sacramento(
                two_places(), ["hospital"], FakeOpenStreetMap({}, 503)
            )

        def offline(request):
            raise httpx.ConnectError("no network")

        transport = httpx.MockTransport(offline)
        async with httpx.AsyncClient(transport=transport) as client:
            with self.assertRaisesRegex(places.PlacesError, "look up the city"):
                await places.find_care(
                    "Sacramento", ["hospital"], client=client, gemini=None
                )

    async def test_gemini_limits_give_a_plain_message(self):
        """Gemini's quota error becomes a short message, not its JSON."""
        quota = genai_errors.ClientError(
            429,
            {
                "error": {
                    "code": 429,
                    "message": "You exceeded your current quota",
                    "status": "RESOURCE_EXHAUSTED",
                }
            },
        )
        with self.assertRaisesRegex(places.PlacesError, "try again later"):
            await find_near_sacramento(FakeGemini(quota), ["hospital"])

        refused = genai_errors.ClientError(
            400, {"error": {"code": 400, "status": "INVALID_ARGUMENT"}}
        )
        with self.assertRaisesRegex(places.PlacesError, "400 INVALID_ARGUMENT"):
            await find_near_sacramento(FakeGemini(refused), ["hospital"])

    async def test_the_tool_answers_failures_with_an_error_for_gemini(self):
        """search_care_places never raises: Gemini explains the error."""
        failing = mock.AsyncMock(side_effect=places.PlacesError("Nope."))
        with (
            mock.patch.object(places, "find_care", failing),
            mock.patch.object(places.genai, "Client"),
        ):
            answer = await places.search_care_places("Sacramento", ["x"])
        self.assertEqual(answer, {"error": "Nope."})

    async def test_without_a_gemini_key_the_tool_says_so(self):
        """No Gemini API key: an error for Gemini, nothing searched."""
        no_key = mock.Mock(side_effect=ValueError("No API key was provided."))
        with mock.patch.object(places.genai, "Client", no_key):
            answer = await places.search_care_places("Sacramento", ["x"])
        self.assertIn("Gemini API key", answer["error"])


class ResolvePlacesTest(unittest.IsolatedAsyncioTestCase):
    """Checking the LLM's "$places" lists against what the search found."""

    async def asyncSetUp(self):
        places._found_places.clear()
        await find_near_sacramento(two_places(), ["hospital"])

    def test_known_places_get_the_searchs_facts_and_keep_the_reason(self):
        """The LLM's copy is replaced by the search's facts, plus its reason."""
        listed = [
            {
                "id": "b",
                "name": "Made-up name",
                "phone": "123",
                "reason": " Hi ",
            },
            {"id": "a"},
        ]
        checked = places.resolve_places({"$places": listed})
        self.assertEqual([p["id"] for p in checked], ["b", "a"])
        self.assertEqual(checked[0]["name"], "Place b")
        self.assertEqual(checked[0]["phone"], "+1 916-555-0100")
        self.assertEqual(checked[0]["reason"], "Hi")
        self.assertNotIn("reason", checked[1])
        self.assertNotIn("foundFor", checked[0])

    def test_made_up_and_repeated_places_are_dropped(self):
        """Only places a search returned, each once."""
        listed = [{"id": "invented"}, {"id": "a"}, {"id": "a"}, "a", None]
        checked = places.resolve_places({"$places": listed})
        self.assertEqual([p["id"] for p in checked], ["a"])
        self.assertEqual(places.resolve_places({"$places": "a"}), [])

    def test_lists_are_found_anywhere_and_nothing_else_changes(self):
        """A "$places" list deep in a message is resolved; the rest stays."""
        message = {"value": {"places": {"$places": [{"id": "a"}]}, "x": 1}}
        resolved = places.resolve_places([message])
        self.assertEqual(resolved[0]["value"]["x"], 1)
        self.assertEqual(resolved[0]["value"]["places"][0]["id"], "a")
        self.assertIn("$places", message["value"]["places"])  # Not changed.

    def test_an_unfilled_list_falls_back_to_no_places(self):
        """A "$ai" list left unfilled becomes its example, which is dropped:
        example places never reach the user."""
        node = {"$places": {"$ai": "places", "example": [{"id": "example"}]}}
        self.assertEqual(fill_screen(node), [])

    def test_the_picked_place_gets_the_searchs_facts(self):
        """A "$place" with a found id becomes that place's facts."""
        report = {"title": "Report", "carePlace": {"$place": "b"}}
        resolved = places.resolve_places(report)
        self.assertEqual(resolved["title"], "Report")
        self.assertEqual(resolved["carePlace"]["name"], "Place b")
        self.assertEqual(resolved["carePlace"]["phone"], "+1 916-555-0100")
        self.assertNotIn("foundFor", resolved["carePlace"])
        for key, value in resolved["carePlace"].items():
            self.assertIsNotNone(value, key)

    def test_no_picked_place_removes_the_key(self):
        """Nothing picked, an unknown id or no id at all: no carePlace."""
        for value in ["", "invented", None, "{{selectedPlaceId}}"]:
            report = {"title": "Report", "carePlace": {"$place": value}}
            self.assertEqual(
                places.resolve_places(report), {"title": "Report"}, value
            )


class PlaceHelpersTest(unittest.TestCase):
    """The small helpers that read Gemini's and OpenStreetMap's answers."""

    def test_a_kind_of_place_gets_an_icon_type(self):
        """Words in the kind pick the app's icon; anything else is "health"."""
        cases = [
            ("Heart hospital", "hospital"),
            ("24h Pharmacy", "pharmacy"),
            ("Chemist", "pharmacy"),
            ("Dental clinic", "dentist"),
            ("Physiotherapy centre", "physiotherapist"),
            ("Diagnostic lab", "medical_lab"),
            ("Orthopedic clinic", "medical_clinic"),
            ("Family doctor", "doctor"),
            ("Dr Patel", "doctor"),
            ("Yoga studio", "health"),
        ]
        for kind, expected in cases:
            with self.subTest(kind=kind):
                self.assertEqual(places._type_for(kind), expected)

    def test_google_maps_titles_become_place_names(self):
        """ " - Google Maps" and "Review of" are taken off."""
        cases = [
            ("City Hospital - Google Maps", "City Hospital"),
            ("Review of City Hospital - Google Maps", "City Hospital"),
            ("City Hospital", "City Hospital"),
        ]
        for title, expected in cases:
            with self.subTest(title=title):
                self.assertEqual(places._maps_title(title), expected)

    def test_numbers_are_read_from_text(self):
        """Ratings, counts and coordinates; anything else is None."""
        cases = [
            ("4.6", 4.6),
            ("1,204", 1204.0),
            ("-121.48", -121.48),
            ("4.5 stars", 4.5),
            ("-", None),
            ("", None),
            (None, None),
        ]
        for text, expected in cases:
            with self.subTest(text=text):
                self.assertEqual(places._number(text), expected)

    def test_searches_are_cleaned_and_limited(self):
        """Blank and non-text searches go, at most three stay; none: doctor."""
        self.assertEqual(
            places._clean_searches([" dentist ", "", 5, "a", "b", "c"]),
            ["dentist", "a", "b"],
        )
        self.assertEqual(places._clean_searches([]), ["doctor"])
        self.assertEqual(places._clean_searches("dentist"), ["doctor"])
        self.assertEqual(len(places._clean_searches(["x" * 200])[0]), 80)

    def test_distances_between_points(self):
        """Sacramento to Los Angeles is about 580 km; a point to itself is 0."""
        sacramento = {"lat": 38.58, "lng": -121.49}
        los_angeles = {"lat": 34.05, "lng": -118.24}
        self.assertAlmostEqual(
            places._distance_km(sacramento, los_angeles), 580, delta=10
        )
        self.assertEqual(places._distance_km(sacramento, sacramento), 0)

    def test_places_may_be_at_least_30_km_away(self):
        """A small or unknown area still allows the minimum radius."""
        center = {"lat": 38.58, "lng": -121.49}
        self.assertEqual(
            places._max_distance_km(
                ["38.57", "38.59", "-121.5", "-121.48"], center
            ),
            places.MIN_RADIUS_KM,
        )
        self.assertEqual(
            places._max_distance_km(None, center), places.MIN_RADIUS_KM
        )
        self.assertGreater(
            places._max_distance_km(SACRAMENTO["boundingbox"], center), 0
        )


if __name__ == "__main__":
    unittest.main()
