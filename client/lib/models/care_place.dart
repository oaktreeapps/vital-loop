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

/// The city the "Find care nearby" dialog suggests before the user has
/// searched for one.
const String defaultCareCity = 'California';

/// A point on the map, in degrees.
class GeoPoint {
  /// Creates a point at [lat], [lng].
  const GeoPoint(this.lat, this.lng);

  /// Latitude, -90 to 90.
  final double lat;

  /// Longitude, -180 to 180.
  final double lng;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'GeoPoint($lat, $lng)';
}

/// A hospital, clinic, doctor or other place to get care, as the server's
/// nearby search found it on Google Maps.
///
/// The server checks every place against Google's results, so its name,
/// address, phone and position are Google's. Only [reason] is written by
/// the LLM.
class CarePlace {
  /// Creates a place; see the fields for what each value is.
  const CarePlace({
    required this.id,
    required this.name,
    required this.position,
    this.kind = '',
    this.type = '',
    this.address = '',
    this.rating,
    this.ratingCount,
    this.phone,
    this.website,
    this.mapsUrl,
    this.reason,
  });

  /// Reads a place from the screen's JSON, or returns `null` when it lacks
  /// an id, a name or a valid position. Other wrong values are left out.
  static CarePlace? fromJson(Object? json) {
    if (json is! Map) return null;
    final String? id = _text(json['id']);
    final String? name = _text(json['name']);
    final Object? lat = json['lat'];
    final Object? lng = json['lng'];
    if (id == null || name == null || lat is! num || lng is! num) {
      return null;
    }
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    final Object? rating = json['rating'];
    final Object? ratingCount = json['ratingCount'];
    return CarePlace(
      id: id,
      name: name,
      position: GeoPoint(lat.toDouble(), lng.toDouble()),
      kind: _text(json['kind']) ?? '',
      type: _text(json['type']) ?? '',
      address: _text(json['address']) ?? '',
      rating: rating is num ? rating.toDouble() : null,
      ratingCount: ratingCount is num ? ratingCount.toInt() : null,
      phone: _text(json['phone']),
      website: _link(json['website']),
      mapsUrl: _link(json['mapsUrl']),
      reason: _text(json['reason']),
    );
  }

  /// Google's id for the place; unique.
  final String id;

  /// The place's name, e.g. "Sutter Medical Center".
  final String name;

  /// Where the place is.
  final GeoPoint position;

  /// What the place is, in words, e.g. "Hospital" or "Orthopedic surgeon".
  final String kind;

  /// Google's place type, e.g. "hospital" or "doctor"; picks the icon.
  final String type;

  /// The street address.
  final String address;

  /// The average Google rating, 1 to 5, if there is one.
  final double? rating;

  /// How many people rated the place.
  final int? ratingCount;

  /// A phone number to call, if Google has one.
  final String? phone;

  /// The place's own website, if it has one.
  final Uri? website;

  /// The place's page on Google Maps.
  final Uri? mapsUrl;

  /// Why this place fits what the user logged, written by the LLM.
  final String? reason;

  /// A Google Maps link with directions to the place.
  Uri get directionsUrl => Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${position.lat},${position.lng}',
    'destination_place_id': id,
  });

  /// A link that calls [phone], or `null` without one.
  Uri? get phoneUrl {
    final String? digits = phone?.replaceAll(RegExp(r'[^\d+]'), '');
    return digits == null || digits.isEmpty
        ? null
        : Uri(scheme: 'tel', path: digits);
  }
}

/// The places in [json] (the screen's list), in order. Entries that aren't
/// valid places, and repeats of an id, are left out.
List<CarePlace> carePlacesFrom(Object? json) {
  if (json is! List) return const [];
  final seen = <String>{};
  return [
    for (final Object? item in json)
      if (CarePlace.fromJson(item) case final CarePlace place
          when seen.add(place.id))
        place,
  ];
}

/// The `{"lat", "lng"}` point in [json], or `null` if it isn't one.
GeoPoint? geoPointFrom(Object? json) {
  if (json is! Map) return null;
  final Object? lat = json['lat'];
  final Object? lng = json['lng'];
  if (lat is! num || lng is! num || lat.abs() > 90 || lng.abs() > 180) {
    return null;
  }
  return GeoPoint(lat.toDouble(), lng.toDouble());
}

/// [value] if it is a non-blank string, trimmed; else `null`.
String? _text(Object? value) {
  if (value is! String) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// [value] as an http(s) link, or `null` if it isn't one. Other schemes
/// (e.g. "javascript:") are never opened.
Uri? _link(Object? value) {
  final Uri? uri = Uri.tryParse(_text(value) ?? '');
  if (uri == null || !uri.hasAuthority) return null;
  return uri.isScheme('https') || uri.isScheme('http') ? uri : null;
}
