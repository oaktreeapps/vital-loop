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

import '../../../core/theme/app_colors.dart';
import '../../../models/care_place.dart';
import 'care_map_fallback.dart';
import 'care_map_markers.dart';

/// OpenStreetMap's standard map tiles. They need no key; the map credits
/// OpenStreetMap, as its tile usage policy asks.
const String openStreetMapTiles =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// The app's id, sent to OpenStreetMap with each tile request, as its tile
/// usage policy asks.
const String mapUserAgentPackage = 'com.oaktreeapps.vitalloop';

/// An OpenStreetMap map with a pin for each of [places].
///
/// The camera fits every pin, and moves to [selectedId] when it changes.
/// Tapping a pin reports its id to [onSelect]. With no places, a link to
/// the area on Google Maps shows instead.
class CareMapView extends StatefulWidget {
  /// Creates the map for [places].
  const CareMapView({
    super.key,
    required this.places,
    required this.onSelect,
    this.selectedId,
    this.center,
    this.city,
    this.height = 280,
  });

  /// The places to pin.
  final List<CarePlace> places;

  /// The picked place's id, or `null` (or empty) when none is picked.
  final String? selectedId;

  /// Called with a place's id when its pin is tapped.
  final ValueChanged<String> onSelect;

  /// The city's center, where the camera starts when there are no places.
  final GeoPoint? center;

  /// The city searched; the Google Maps link searches it.
  final String? city;

  /// The map's height.
  final double height;

  @override
  State<CareMapView> createState() => _CareMapViewState();
}

/// Holds the map's controller, to move the camera.
class _CareMapViewState extends State<CareMapView> {
  /// Moves the camera.
  final MapController _controller = MapController();

  /// Whether the map is on screen and can be moved.
  bool _ready = false;

  /// Fits the camera when the places change, and moves to a newly picked
  /// place.
  @override
  void didUpdateWidget(CareMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_ready) return;
    if (!_sameIds(oldWidget.places, widget.places)) {
      _fitCamera();
    } else if (widget.selectedId != oldWidget.selectedId) {
      _showSelected();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Moves the camera so every place is in view.
  void _fitCamera() {
    final CameraFit? fit = cameraFitFor(widget.places);
    if (fit != null) {
      _controller.fitCamera(fit);
    } else {
      final CameraView view = cameraFor(widget.places, widget.center);
      _controller.move(view.center, view.zoom);
    }
  }

  /// Moves the camera to the picked place.
  void _showSelected() {
    final CarePlace? place = widget.places
        .where((place) => place.id == widget.selectedId)
        .firstOrNull;
    if (place != null) {
      _controller.move(toLatLng(place.position), placeZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nothing to pin (no places found, or the search couldn't run): a link
    // to the area on Google Maps instead of an empty map.
    if (widget.places.isEmpty) {
      return CareMapFallback(
        searchUrl: _searchUrl(),
        message: 'No places to show on the map.',
      );
    }
    final CameraView view = cameraFor(widget.places, widget.center);
    return Semantics(
      label:
          'Map of ${widget.places.length} places to get care'
          '${widget.city == null ? '' : ' near ${widget.city}'}',
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: view.center,
            initialZoom: view.zoom,
            initialCameraFit: cameraFitFor(widget.places),
            backgroundColor: AppColors.field,
            // No turning the map: north stays up.
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapReady: () => _ready = true,
          ),
          children: [
            TileLayer(
              urlTemplate: openStreetMapTiles,
              userAgentPackageName: mapUserAgentPackage,
            ),
            MarkerLayer(
              markers: carePlaceMarkers(
                widget.places,
                selectedId: widget.selectedId,
                onSelect: widget.onSelect,
              ),
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
      ),
    );
  }

  /// A Google Maps search for the city, or for the first place.
  Uri _searchUrl() {
    final String query =
        widget.city ?? widget.places.firstOrNull?.name ?? 'hospitals near me';
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
  }
}

/// Whether [a] and [b] hold the same places, in the same order.
bool _sameIds(List<CarePlace> a, List<CarePlace> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].id != b[i].id) return false;
  }
  return true;
}
