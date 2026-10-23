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

"""Builds a screen live while Gemini is still writing it.

Where this fits in a request: while Gemini streams its reply, agent.py hands
the reply so far to a ScreenStreamer (step 4 of the flow in main.py). The
streamer returns the A2UI messages that are ready to show, and
agent_executor.py sends them to the app as partial screens.

Gemini answers with one ```json block holding the screen's A2UI messages:
createSurface, updateDataModel and updateComponents with every component. We
read that JSON while it streams in and send the app what is ready so far:

- createSurface together with the first visible content (a surface without a
  root shows an error box in genui), then the data model as soon as it is
  complete;
- an updateComponents each time more of the screen is ready: every complete
  component reachable from "root", with each container's children cut at the
  first one that isn't complete yet. So the screen fills from top to bottom,
  and no component ever points at a child the app doesn't have.

The complete reply is still parsed and sent at the end, so the final screen is
exactly what Gemini wrote.

This file has three parts:
  1. partial_screen(): reads the complete messages and components from JSON
     that is not finished yet.
  2. visible_tree(): picks the components that can be shown.
  3. ScreenStreamer: decides which messages to send to the app, and when.
"""

import json
import re

# Keys whose value is the id of one child component. A component is only
# ready to show when every child it points at with these keys is ready too.
_SINGLE_CHILD_KEYS = ("child", "entryPointChild", "contentChild")

# The only catalog the app has. Every template uses it, but Gemini sometimes
# shortens it (e.g. to ".../v0_9/catalog.json"), and the app can't draw a
# surface whose catalog it doesn't know. So every createSurface is sent with
# this id.
CATALOG_ID = "https://a2ui.org/specification/v0_9/catalogs/basic/catalog.json"


# Part 1: reading JSON that is not finished yet.


def _scan_array(text: str, start: int) -> tuple[list[str], bool, int | None]:
    """Finds the complete elements of the JSON array that starts at [start].

    The text may stop in the middle of the array (the LLM is still writing).
    We walk through it one character at a time and count brackets; brackets
    inside JSON strings are ignored. Elements that are plain values (numbers,
    strings) are skipped: the arrays we read here only hold objects.

    Args:
        text: the reply so far.
        start: the position of the array's "[" in [text].

    Returns:
        A tuple of: the text of each complete object or array element,
        whether the array is closed, and where the unfinished element starts
        (None if there is none).
    """
    elements = []  # The text of each complete element.
    depth = 0  # How deep we are inside the current element's {} and [].
    in_string = False  # True between the quotes of a JSON string.
    escaped = False  # True right after a backslash inside a string.
    element_start = None  # Where the current element begins.

    for index in range(start + 1, len(text)):
        char = text[index]

        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue

        if char == '"':
            in_string = True
        elif char in "{[":
            if depth == 0:
                element_start = index
            depth += 1
        elif char in "}]":
            if depth == 0:
                # This bracket closes the array itself.
                return elements, True, None
            depth -= 1
            if depth == 0 and element_start is not None:
                elements.append(text[element_start : index + 1])
                element_start = None

    # The text ended before the array was closed.
    return elements, False, element_start


def _parse_objects(texts: list[str]) -> list[dict]:
    """Parses each JSON text and keeps the ones that are JSON objects.

    Texts that aren't valid JSON are skipped, so one bad element doesn't stop
    the live screen.
    """
    objects = []
    for text in texts:
        try:
            value = json.loads(text)
        except ValueError:
            continue
        if isinstance(value, dict):
            objects.append(value)
    return objects


def partial_screen(
    text: str,
) -> tuple[list[dict], tuple[str, list[dict]] | None]:
    """Reads the A2UI messages from a reply that is still being written.

    The reply is expected to look like ```json [message, message, ...] ```.

    Args:
        text: the reply so far.

    Returns:
        A tuple of: the complete messages so far, and the unfinished
        updateComponents message as (surfaceId, components completed so far),
        or None if no updateComponents message is being written.
    """
    # The message array is the first "[" after the ``` fence.
    fence = text.find("```")
    if fence >= 0:
        array_start = text.find("[", fence + 3)
    else:
        array_start = text.find("[")
    if array_start < 0:
        return [], None

    element_texts, closed, unfinished_start = _scan_array(text, array_start)
    messages = _parse_objects(element_texts)
    if closed or unfinished_start is None:
        return messages, None

    unfinished_update = _read_unfinished_update(text, unfinished_start)
    return messages, unfinished_update


def _read_unfinished_update(
    text: str, message_start: int
) -> tuple[str, list[dict]] | None:
    """Reads an updateComponents message that is not complete JSON yet.

    Its surfaceId and its finished components are read straight from the
    text, because json.loads can't read the unfinished message.

    Args:
        text: the reply so far.
        message_start: where the unfinished message starts in [text].

    Returns:
        (surfaceId, components completed so far), or None if the unfinished
        message is not an updateComponents or its components list hasn't
        started yet.
    """
    rest = text[message_start:]
    update_pos = rest.find('"updateComponents"')
    if update_pos < 0:
        return None

    after_update = rest[update_pos:]
    surface_match = re.search(r'"surfaceId"\s*:\s*"([^"]*)"', after_update)
    components_match = re.search(r'"components"\s*:\s*\[', after_update)
    if not surface_match or not components_match:
        return None

    # The position of the components list's "[" in the full text.
    components_start = message_start + update_pos + components_match.end() - 1
    component_texts, _, _ = _scan_array(text, components_start)
    return surface_match.group(1), _parse_objects(component_texts)


# Part 2: choosing the components that can be shown.


def _required_child_ids(component: dict) -> list[str]:
    """Returns the ids of the children a component needs all of.

    These are the _SINGLE_CHILD_KEYS and a list template's componentId. A
    plain list of "children" is not included, because that list may be cut
    short.
    """
    child_ids = []
    for key in _SINGLE_CHILD_KEYS:
        child_id = component.get(key)
        if isinstance(child_id, str):
            child_ids.append(child_id)

    children = component.get("children")
    # A list template looks like {"componentId": ..., "path": ...}.
    if isinstance(children, dict):
        template_id = children.get("componentId")
        if isinstance(template_id, str):
            child_ids.append(template_id)
    return child_ids


def _is_ready(
    component_id: str, components_by_id: dict, ids_on_path: set
) -> bool:
    """Checks that a component and every child it needs are complete.

    Args:
        component_id: the component to check.
        components_by_id: every complete component so far, by id.
        ids_on_path: the ids from "root" down to this component. A component
            that (by mistake) points back at itself is then "not ready",
            instead of making us loop forever.
    """
    component = components_by_id.get(component_id)
    if component is None or component_id in ids_on_path:
        return False

    ids_below = ids_on_path | {component_id}
    for child_id in _required_child_ids(component):
        if not _is_ready(child_id, components_by_id, ids_below):
            return False
    return True


def _add_shown_component(
    component_id: str, components_by_id: dict, ids_on_path: set, shown: dict
) -> None:
    """Adds a component, and then its children, to [shown].

    The component's list of children is cut at the first child that isn't
    ready, so the screen fills from the top. Then every child it keeps is
    added the same way.

    Args:
        component_id: the component to add; it must be ready.
        components_by_id: every complete component so far, by id.
        ids_on_path: the ids from "root" down to this component.
        shown: id -> component to show (children maybe cut), in visit order.
    """
    if component_id in shown:
        return

    component = dict(components_by_id[component_id])  # A copy we may change.
    ids_below = ids_on_path | {component_id}

    children = component.get("children")
    has_children_list = isinstance(children, list)
    if has_children_list:
        kept_children = []
        for child in children:
            if not isinstance(child, str):
                break
            if not _is_ready(child, components_by_id, ids_below):
                break  # Fill from the top: stop at the first missing one.
            kept_children.append(child)
        component["children"] = kept_children

    shown[component_id] = component

    next_ids = _required_child_ids(component)
    if has_children_list:
        next_ids = next_ids + component["children"]
    for child_id in next_ids:
        _add_shown_component(child_id, components_by_id, ids_below, shown)


def visible_tree(components: list[dict]) -> list[dict]:
    """Returns the part of a screen that can be shown right now.

    That is every component reachable from "root" whose children are all
    there, with each list of children cut at the first child that isn't
    ready. The list is empty until "root" is ready.
    """
    components_by_id = {}
    for component in components:
        if isinstance(component, dict):
            components_by_id[component.get("id")] = component

    if not _is_ready("root", components_by_id, set()):
        return []

    shown = {}
    _add_shown_component("root", components_by_id, set(), shown)
    return list(shown.values())


# Part 3: deciding what to send to the app.


class ScreenStreamer:
    """Turns a growing reply into the A2UI messages to send so far.

    Use one ScreenStreamer per reply: call feed() each time the reply grows,
    then finish() with the complete reply's messages. It remembers what it
    already sent, so feed() only returns what is new.

    Attributes:
        ids: the surfaceId in the reply -> the surfaceId sent to the app.
        created: the sent surfaceIds whose createSurface the app already got.
        updates: how many partial updateComponents were sent (for the logs).
    """

    def __init__(self, rename, fill):
        """Starts with nothing sent.

        Args:
            rename: a function that takes a surfaceId from the reply and
                returns the one to send (e.g. with "_2" for a surface the app
                already has). It is called once per surface.
            fill: a function applied to the components and the data model
                before they are sent (e.g. it replaces unfilled {"$ai": ...}
                parts).
        """
        self._rename = rename
        self._fill = fill
        self.ids = {}
        self.created = set()
        # Surfaces (ids in the reply) whose updateDataModel was already sent.
        self._data_sent = set()
        # The last components sent per surface (as JSON text), so an update
        # that changes nothing isn't sent again.
        self._last_sent = {}
        self.updates = 0

    def _sent_id(self, surface_id: str) -> str:
        """Returns the id to send for the reply's [surface_id].

        Asks [rename] only the first time, so the live updates and the end
        use the same id.
        """
        if surface_id not in self.ids:
            self.ids[surface_id] = self._rename(surface_id)
        return self.ids[surface_id]

    def feed(self, text: str) -> list[dict]:
        """Returns the messages to send now for the reply written so far.

        Args:
            text: the whole reply so far, not only the new part.

        Returns:
            The new messages to send; [] when nothing new can be shown yet.
        """
        messages, unfinished_update = partial_screen(text)

        # Sort the complete messages by kind, keyed by the reply's surfaceId.
        creates = {}
        data_models = {}
        components = {}
        for message in messages:
            for kind, body in message.items():
                if not isinstance(body, dict) or "surfaceId" not in body:
                    continue
                surface_id = body["surfaceId"]
                if kind == "createSurface":
                    creates[surface_id] = message
                elif kind == "updateDataModel":
                    data_models[surface_id] = message
                elif kind == "updateComponents":
                    components[surface_id] = body.get("components") or []

        # The components of the unfinished updateComponents, if any.
        if unfinished_update:
            surface_id, finished_components = unfinished_update
            components[surface_id] = finished_components

        to_send = []
        for surface_id, create in creates.items():
            to_send += self._new_messages_for_surface(
                surface_id,
                create,
                data_models.get(surface_id),
                components.get(surface_id, []),
            )
        return to_send

    def _new_messages_for_surface(
        self,
        surface_id: str,
        create: dict,
        data_model: dict | None,
        components: list[dict],
    ) -> list[dict]:
        """Returns what is new to send for one surface of the reply.

        Args:
            surface_id: the surfaceId in the reply.
            create: the surface's createSurface message.
            data_model: its updateDataModel message, if complete yet.
            components: its components completed so far.
        """
        visible = visible_tree(self._fill(components))
        sent_id = self._sent_id(surface_id)
        to_send = []

        # 1. createSurface, but only once there is something to show: an
        #    empty surface is an error box in the app.
        if sent_id not in self.created:
            if not visible:
                return []
            to_send.append(_with_surface_id(create, sent_id))
            self.created.add(sent_id)

        # 2. The data model, once, filled like the components (e.g. its
        #    "$places" lists are checked).
        if data_model is not None and surface_id not in self._data_sent:
            to_send.append(_with_surface_id(self._fill(data_model), sent_id))
            self._data_sent.add(surface_id)

        # 3. The visible components, if they changed since the last update.
        visible_as_text = json.dumps(visible, sort_keys=True)
        if visible and visible_as_text != self._last_sent.get(sent_id):
            self._last_sent[sent_id] = visible_as_text
            self.updates += 1
            to_send.append(
                {
                    "version": create.get("version", "v0.9"),
                    "updateComponents": {
                        "surfaceId": sent_id,
                        "components": visible,
                    },
                }
            )
        return to_send

    def finish(self, messages: list[dict]) -> list[dict]:
        """Returns the complete reply's messages to send at the end.

        A createSurface the app already got is left out, and every surface
        keeps the id the live updates used.

        A deleteSurface for a surface this reply already streamed is dropped:
        it was meant to clear an older screen before this one was created, and
        sent now it would remove the screen the app is showing.
        """
        to_send = []
        for message in messages:
            kind, body = _find_surface_body(message)
            if body is None:
                # Not about a surface: send it as it is.
                to_send.append(message)
                continue

            if kind == "deleteSurface":
                if body["surfaceId"] not in self.created:
                    to_send.append(message)
                continue

            sent_id = self._sent_id(body["surfaceId"])
            if kind == "createSurface":
                if sent_id in self.created:
                    continue  # The app already has this surface.
                self.created.add(sent_id)
            to_send.append(_with_surface_id(message, sent_id))
        return to_send


def _find_surface_body(message: dict) -> tuple[str | None, dict | None]:
    """Returns the first (kind, body) in [message] whose body has a surfaceId.

    For example ("createSurface", {"surfaceId": ...}), or (None, None) if the
    message has no such part.
    """
    for kind, body in message.items():
        if isinstance(body, dict) and "surfaceId" in body:
            return kind, body
    return None, None


def _with_surface_id(message: dict, surface_id: str) -> dict:
    """Returns a copy of [message] that uses [surface_id].

    A createSurface also gets the app's catalog id (see CATALOG_ID). The
    original message is not changed.
    """
    copy = {}
    for kind, body in message.items():
        if isinstance(body, dict):
            new_body = dict(body)
            new_body["surfaceId"] = surface_id
            if kind == "createSurface":
                new_body["catalogId"] = CATALOG_ID
            copy[kind] = new_body
        else:
            copy[kind] = body
    return copy
