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

"""Finds real hospitals, clinics and doctors near a place, with Gemini.

Where this fits: the daily summary's "Find care nearby" screen
(flows/daily_summary/02_nearby_care.json). Gemini calls search_care_places()
as an ADK tool, with the city the user typed and the kinds of care that fit
what they logged (e.g. "orthopedic clinic" for knee pain). Then it copies the
places it picks into the screen's {"$places": [...]} list, each with a reason.

How the search works, with no Google Maps key:
  1. The city's center comes from OpenStreetMap's free Nominatim service.
  2. Each kind of care is one Gemini request with Grounding with Google Maps
     (the same Gemini API key). Gemini answers with one line per place, and
     Google Maps tells which real places it used: their place ids and links.
  3. Only places Google Maps returned are kept, with Google's name, id and
     link. A place far from the city's center is left out.

Every place the tool returns is remembered here by its Google place id, and
resolve_places() replaces each place in a "$places" list with those facts,
dropping any place the search didn't return. So the screen never shows a
place the LLM made up.
"""

from collections import OrderedDict
import logging
import math
import os
import re

from google import genai
from google.genai import errors as genai_errors
from google.genai import types
import httpx

logger = logging.getLogger(__name__)  # Logs searches, never health data.

# OpenStreetMap's free geocoder, for the city's center. Its usage policy
# asks for a User-Agent that names the app, and at most one request a second.
NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"
USER_AGENT = "VitalLoop/1.0 (open-source genui demo app)"

# The Gemini model that searches Google Maps.
MAPS_MODEL = os.getenv("GEMINI_MODEL", "gemini-3-flash-preview")

# The most kinds of care one call looks for, and the most places it
# returns. All the kinds go into one search: two Gemini requests in all
# (find the places, then their details), to stay within Gemini's limits for
# Grounding with Google Maps.
MAX_SEARCHES = 3
MAX_PLACES = 10

# How long one request may take, in seconds.
TIMEOUT_SECONDS = 30

# Places further than this from the city's center are left out, in km. A
# city's own size counts too (see _max_distance_km), so a whole state works.
MIN_RADIUS_KM = 30

# How Gemini is asked to list the places it finds.
_ANSWER_FORMAT = (
    "List only places the Google Maps tool returned, each name written "
    "exactly as Google Maps shows it. Answer ONLY with one line per place, "
    "nothing else, in this format:\n"
    "name | address | latitude | longitude | rating | number of ratings | "
    "phone | website | kind of place\n"
    "Latitude and longitude are required: give each place's exact position "
    "from Google Maps, in decimal degrees. Write - only for other details "
    "you don't know."
)

# The places found so far, by id, newest last: what resolve_places() checks
# the LLM's lists against. Places are public facts, so one cache serves every
# session. Capped, so a long-running server doesn't grow without end.
_CACHE_SIZE = 500
_found_places: OrderedDict[str, dict] = OrderedDict()


class PlacesError(Exception):
    """A search failed. The message is shown to the user, through Gemini."""


async def search_care_places(city: str, searches: list[str]) -> dict:
    """Finds hospitals, clinics, doctors and other care in or near a city.

    Call it once, before filling the nearby care screen.

    Args:
        city: the city (or area) the user typed, e.g. "Austin" or
            "California".
        searches: one to three kinds of care to look for that fit what the
            user logged, most important first, e.g. ["orthopedic clinic",
            "orthopedic surgeon", "hospital"].

    Returns:
        {"city": {"name", "address", "center": {"lat", "lng"}},
         "places": [{"id", "name", "kind", "type", "address", "lat", "lng",
         "rating", "ratingCount", "phone", "website", "mapsUrl",
         "foundFor"}]}, or {"error": "<why, in plain words>"}.
    """
    try:
        try:
            gemini = genai.Client()  # Reads the Gemini API key from .env.
        except ValueError as error:
            raise PlacesError(
                "Nearby search needs the Gemini API key, which isn't set."
            ) from error
        async with httpx.AsyncClient(timeout=TIMEOUT_SECONDS) as client:
            return await find_care(city, searches, client=client, gemini=gemini)
    except PlacesError as error:
        logger.warning("Nearby search failed: %s", error)
        return {"error": str(error)}


async def find_care(city: str, searches: list[str], *, client, gemini) -> dict:
    """Does the work of search_care_places() with [client] and [gemini].

    Separate from the tool, so the tests can pass a fake HTTP client and a
    fake Gemini. (ADK shows every parameter of a tool to the LLM.)

    Raises:
        PlacesError: no city given or found, or the search failed.
    """
    city = (city or "").strip()
    if not city:
        raise PlacesError("No city was given.")
    queries = _clean_searches(searches)
    logger.info(
        "Nearby search: %d kind(s) of care near the given city", len(queries)
    )

    area = await _find_city(city, client=client)
    center = area["center"]
    max_km = area["radius_km"]
    kinds = " or ".join(queries)

    places: dict[str, dict] = {}
    for place in await _search(kinds, area["name"], gemini=gemini):
        if place["id"] in places:
            continue
        if _distance_km(center, place) > max_km:
            continue
        place["foundFor"] = kinds
        places[place["id"]] = place

    for place in places.values():
        _remember(place)
    return {
        "city": {
            "name": area["name"],
            "address": area["address"],
            "center": center,
        },
        "places": list(places.values()),
    }


def resolve_places(node):
    """Replaces each {"$places": [...]} under [node] with checked places.

    Each place in the list must have the "id" of a place search_care_places
    returned; it becomes the search's facts for that place plus the LLM's
    "reason". A place with an unknown id is dropped, so the screen never
    shows a place the LLM made up.

    A value {"$place": "<id>"} (e.g. the place the user picked, in the PDF
    report) becomes the search's facts for that one place. Without a known
    id (e.g. nothing was picked) the value is removed, key and all.

    Returns a new value; [node] is not changed.
    """
    if isinstance(node, dict):
        if list(node) == ["$places"]:
            return _checked_places(node["$places"])
        resolved = {}
        for key, value in node.items():
            if isinstance(value, dict) and list(value) == ["$place"]:
                place = _found_place(value["$place"])
                if place is not None:
                    resolved[key] = place
                continue
            resolved[key] = resolve_places(value)
        return resolved
    if isinstance(node, list):
        return [resolve_places(item) for item in node]
    return node


def _found_place(place_id) -> dict | None:
    """The facts a search returned for [place_id], or None if none did."""
    if not isinstance(place_id, str):
        return None
    found = _found_places.get(place_id)
    if found is None:
        if place_id:
            logger.warning("Dropped a place no search returned: %r", place_id)
        return None
    # Facts the search didn't find (None) are left out: the app checks this
    # place against its schema, where a missing phone is fine but null isn't.
    return {
        key: value
        for key, value in found.items()
        if key != "foundFor" and value is not None
    }


def _checked_places(listed) -> list[dict]:
    """The places in [listed] that a search returned, with its facts."""
    if not isinstance(listed, list):
        return []
    checked = []
    seen = set()
    for item in listed:
        if not isinstance(item, dict):
            continue
        place_id = item.get("id")
        found = (
            _found_places.get(place_id) if isinstance(place_id, str) else None
        )
        if found is None or place_id in seen:
            logger.warning("Dropped a place no search returned: %r", place_id)
            continue
        seen.add(place_id)
        place = dict(found)
        place.pop("foundFor", None)
        reason = item.get("reason")
        if isinstance(reason, str) and reason.strip():
            place["reason"] = reason.strip()[:300]
        checked.append(place)
    return checked


def _remember(place: dict) -> None:
    """Adds [place] to the cache that resolve_places() checks against."""
    _found_places[place["id"]] = place
    _found_places.move_to_end(place["id"])
    while len(_found_places) > _CACHE_SIZE:
        _found_places.popitem(last=False)


def _clean_searches(searches) -> list[str]:
    """Up to MAX_SEARCHES non-empty searches, or a general one if none."""
    cleaned = []
    if isinstance(searches, list):
        for search in searches:
            if isinstance(search, str) and search.strip():
                cleaned.append(search.strip()[:80])
    return cleaned[:MAX_SEARCHES] or ["doctor"]


async def _find_city(city: str, *, client) -> dict:
    """Looks up [city] on OpenStreetMap: its name, address and center.

    Also how far from the center a place may be ("radius_km"), from the
    city's size.

    Raises:
        PlacesError: the lookup failed or found nothing.
    """
    # Only areas: a city, town or village first, then a state or a country.
    # Never a shop or a building, so "Newyork" isn't a shop in Tokyo.
    found = []
    for feature in ("settlement", "state", "country"):
        found = await _nominatim(city, {"featureType": feature}, client)
        if found:
            break
    if not found:
        raise PlacesError(
            f'No place called "{city}" was found. Try a nearby larger city.'
        )
    first = found[0]
    center = {"lat": float(first["lat"]), "lng": float(first["lon"])}
    address = first.get("display_name", city)
    return {
        "name": first.get("name") or city,
        "address": address,
        "center": center,
        "radius_km": _max_distance_km(first.get("boundingbox"), center),
    }


async def _nominatim(query: str, extra: dict, client) -> list:
    """OpenStreetMap's best match for [query], as a list of 0 or 1 results.

    Raises:
        PlacesError: OpenStreetMap couldn't be reached or refused.
    """
    try:
        response = await client.get(
            NOMINATIM_URL,
            params={"q": query, "format": "jsonv2", "limit": 1, **extra},
            headers={"User-Agent": USER_AGENT},
        )
    except httpx.HTTPError as error:
        raise PlacesError(f"Couldn't look up the city ({error}).") from error
    if response.status_code != 200:
        raise PlacesError(
            f"Couldn't look up the city (HTTP {response.status_code})."
        )
    return response.json()


async def _search(query: str, city: str, *, gemini) -> list[dict]:
    """Finds places that are [query] in [city], with Gemini and Google Maps.

    Two requests: the first finds the places (Google Maps says which real
    places it used), the second asks for those places' details by their
    exact names. Returns only places Google Maps returned, with a position.

    Raises:
        PlacesError: Gemini couldn't be reached or refused the request.
    """
    found = await _ask_maps(
        f"Using Google Maps, find up to {MAX_PLACES} places that are "
        f"{query}, in or near {city}, open now or during the day. Put the "
        f"best fits first.",
        gemini,
    )
    maps_places = _maps_places(found)[:MAX_PLACES]
    if not maps_places:
        return []

    names = "\n".join(f"- {place['name']}" for place in maps_places)
    details = await _ask_maps(
        f"Using Google Maps, give the details of each of these places in or "
        f"near {city}, keeping each name exactly as written here:\n{names}\n"
        f"{_ANSWER_FORMAT}",
        gemini,
    )
    places = []
    for line in (details.text or "").splitlines():
        place = _place_from_line(line, maps_places)
        if place is not None:
            places.append(place)
    return places


async def _ask_maps(prompt: str, gemini):
    """Sends [prompt] to Gemini with Grounding with Google Maps.

    Raises:
        PlacesError: Gemini couldn't be reached or refused the request.
    """
    try:
        return await gemini.aio.models.generate_content(
            model=MAPS_MODEL,
            contents=prompt,
            config=types.GenerateContentConfig(
                tools=[types.Tool(google_maps=types.GoogleMaps())],
                # Finding and listing places needs little thinking; the
                # default (high) made each request take up to 30 seconds.
                thinking_config=types.ThinkingConfig(
                    thinking_level=types.ThinkingLevel.LOW
                ),
            ),
        )
    except genai_errors.APIError as error:
        if error.code == 429:
            raise PlacesError(
                "The nearby search reached Gemini's limit for Google Maps "
                "searches. Please try again later."
            ) from error
        raise PlacesError(
            "Couldn't search Google Maps through Gemini "
            f"({error.code} {error.status})."
        ) from error
    except Exception as error:  # Network errors and the like.
        raise PlacesError(
            f"Couldn't reach Gemini for the nearby search ({error})."
        ) from error


def _maps_places(response) -> list[dict]:
    """The real Google Maps places Gemini used in [response], each once.

    Each is {"id", "name", "title", "mapsUrl"}, in the order Gemini cited
    them.
    """
    places = []
    seen = set()
    candidate = (response.candidates or [None])[0]
    metadata = getattr(candidate, "grounding_metadata", None)
    for chunk in getattr(metadata, "grounding_chunks", None) or []:
        maps = getattr(chunk, "maps", None)
        if maps is None or not maps.place_id or not maps.title:
            continue
        if maps.place_id in seen:
            continue
        seen.add(maps.place_id)
        # A title is "Name - Google Maps", sometimes with a tagline:
        # "Name - Best Hospital, Cancer Center - Google Maps".
        title = _maps_title(maps.title)
        places.append(
            {
                "id": maps.place_id,
                "name": title.split(" - ")[0].strip(),
                "title": title,
                "mapsUrl": maps.uri,
            }
        )
    return places


def _place_from_line(line: str, maps_places: list) -> dict | None:
    """One "name | address | lat | lng | ..." line as a place, or None.

    None when the line isn't a place, has no position, or names a place
    Google Maps didn't return.
    """
    cells = [cell.strip(" *") for cell in line.split("|")]
    # "-" alone means "unknown"; a minus sign in "-73.98" must stay.
    cells = ["" if cell == "-" else cell for cell in cells]
    if len(cells) < 4 or not _key(cells[0]):
        return None
    found = _matching(cells[0], maps_places)
    lat, lng = _number(cells[2]), _number(cells[3])
    if found is None or lat is None or lng is None:
        return None
    # A shifted line (e.g. a "|" inside a name) gives numbers that aren't a
    # position.
    if not (-90 <= lat <= 90 and -180 <= lng <= 180):
        return None

    def cell(index: int) -> str | None:
        """The cell at [index], or None if it's missing or empty."""
        value = cells[index] if index < len(cells) else ""
        return value or None

    rating_count = _number(cell(5))
    website = cell(7)
    kind = cell(8) or "Health care"
    return {
        "id": found["id"],
        "name": found["name"],
        "kind": kind[:60],
        "type": _type_for(kind),
        "address": cell(1) or "",
        "lat": lat,
        "lng": lng,
        "rating": _number(cell(4)),
        "ratingCount": int(rating_count) if rating_count else None,
        "phone": cell(6),
        "website": website if website and website.startswith("http") else None,
        "mapsUrl": found["mapsUrl"],
    }


def _matching(name: str, maps_places: list) -> dict | None:
    """The Google Maps place that [name] is, or None.

    [name] matches a place's name, or the start of its full title.
    """
    key = _key(name)
    for place in maps_places:
        if key == _key(place["name"]) or _key(place["title"]).startswith(key):
            return place
    return None


def _maps_title(title: str) -> str:
    """A place's title from a Google Maps one like "X - Google Maps".

    A review's title, "Review of X - Google Maps", gives X.
    """
    title = re.sub(r"\s*-\s*Google Maps$", "", title).strip()
    return re.sub(r"^Review of\s+", "", title)


def _key(name: str) -> str:
    """[name] reduced to letters and digits, for matching names."""
    return re.sub(r"[^a-z0-9]", "", name.lower())


def _number(text) -> float | None:
    """The number in [text] (e.g. "4.6" or "1,204"), or None."""
    if not text:
        return None
    match = re.search(r"-?\d+(?:\.\d+)?", str(text).replace(",", ""))
    return float(match.group()) if match else None


def _type_for(kind: str) -> str:
    """A place type for the app's icons, from a kind of place.

    E.g. "hospital" for "Heart hospital", "medical_clinic" for "Orthopedic
    clinic".
    """
    kind = kind.lower()
    if "hospital" in kind:
        return "hospital"
    if "pharmacy" in kind or "chemist" in kind or "drug" in kind:
        return "pharmacy"
    if "dent" in kind:
        return "dentist"
    if "physio" in kind or "chiropract" in kind:
        return "physiotherapist"
    if "lab" in kind or "diagnostic" in kind:
        return "medical_lab"
    if "clinic" in kind or "centre" in kind or "center" in kind:
        return "medical_clinic"
    if "doctor" in kind or "physician" in kind or "dr" in kind.split():
        return "doctor"
    return "health"


def _max_distance_km(bounding_box, center: dict) -> float:
    """How far from [center] a place may be: the area's size, or more.

    [bounding_box] is OpenStreetMap's [south, north, west, east].
    """
    try:
        _, north, _, east = (float(value) for value in bounding_box)
    except (TypeError, ValueError):
        return MIN_RADIUS_KM
    half_diagonal = _distance_km(center, {"lat": north, "lng": east})
    return max(MIN_RADIUS_KM, half_diagonal * 1.5)


def _distance_km(a: dict, b: dict) -> float:
    """The great-circle distance between two {"lat", "lng"} points, in km."""
    lat1, lat2 = math.radians(a["lat"]), math.radians(b["lat"])
    d_lat = lat2 - lat1
    d_lng = math.radians(b["lng"] - a["lng"])
    h = (
        math.sin(d_lat / 2) ** 2
        + math.cos(lat1) * math.cos(lat2) * math.sin(d_lng / 2) ** 2
    )
    return 6371 * 2 * math.asin(math.sqrt(h))
