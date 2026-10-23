// Copyright 2026 Oaktreeapps
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../models/care_place.dart';
import 'care_map_pin.dart';

// The parts of the care map that don't need a map on screen: its pins and
// where its camera goes. Kept apart so tests can check them directly.

/// How close the camera comes to a single place.
const double placeZoom = 15;

/// How close the camera comes to a city with no places to show.
const double cityZoom = 11;

/// The camera's zoom when there is nothing to show: the whole world.
const double worldZoom = 1;

/// Space kept around the pins when the camera fits them all.
const EdgeInsets fitPadding = EdgeInsets.fromLTRB(40, 72, 40, 40);

/// One pin per place, green, or red for [selectedId]. Tapping a pin reports
/// its id to [onSelect]. The picked pin comes last, so it's drawn on top.
List<Marker> carePlaceMarkers(
  List<CarePlace> places, {
  required String? selectedId,
  required ValueChanged<String> onSelect,
}) {
  final List<CarePlace> inOrder = [
    for (final CarePlace place in places)
      if (place.id != selectedId) place,
    for (final CarePlace place in places)
      if (place.id == selectedId) place,
  ];
  return [
    for (final CarePlace place in inOrder)
      Marker(
        key: ValueKey(place.id),
        point: toLatLng(place.position),
        width: CareMapPin.size.width,
        height: CareMapPin.size.height,
        // The pin's tip, at its bottom center, sits on the place.
        alignment: Alignment.topCenter,
        child: CareMapPin(
          name: place.name,
          selected: place.id == selectedId,
          onTap: () => onSelect(place.id),
        ),
      ),
  ];
}

/// Where the camera looks, and how close.
typedef CameraView = ({LatLng center, double zoom});

/// Where the camera looks when there aren't two places to fit: the single
/// place up close, else [center] (the city), else the whole world.
CameraView cameraFor(List<CarePlace> places, GeoPoint? center) {
  if (places.isNotEmpty) {
    return (center: toLatLng(places.first.position), zoom: placeZoom);
  }
  if (center != null) return (center: toLatLng(center), zoom: cityZoom);
  return (center: const LatLng(20, 0), zoom: worldZoom);
}

/// The camera fit that shows every place, for two or more; `null` for fewer.
CameraFit? cameraFitFor(List<CarePlace> places) {
  if (places.length < 2) return null;
  return CameraFit.bounds(
    bounds: LatLngBounds.fromPoints([
      for (final CarePlace place in places) toLatLng(place.position),
    ]),
    padding: fitPadding,
    maxZoom: placeZoom,
  );
}

/// [point] as the map package's [LatLng].
LatLng toLatLng(GeoPoint point) => LatLng(point.lat, point.lng);
