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

// Rebuilds the app icon for Android, iOS and web from
// app_icon_painter.dart.
//
// Run it from the client/ folder after changing the painter:
//
//   GENERATE_ICONS=1 flutter test tool/app_icon/generate_icons_test.dart
//
// It is a test only because `flutter test` gives Dart a real canvas to draw
// on. It writes the image files in place and needs no other tools. Without
// GENERATE_ICONS it is skipped, so running every test never rewrites them.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'app_icon_painter.dart';

/// Android's screen densities and their scale factor from 1dp.
const Map<String, double> _androidDensities = {
  'mdpi': 1,
  'hdpi': 1.5,
  'xhdpi': 2,
  'xxhdpi': 3,
  'xxxhdpi': 4,
};

void main() {
  test(
    'generate the app icon for Android, iOS and web',
    skip: Platform.environment['GENERATE_ICONS'] == null
        ? 'Set GENERATE_ICONS=1 to rewrite the icon files'
        : false,
    () async {
      // Android: the launcher icon for phones without adaptive icons (48dp),
      // and the adaptive icon's foreground and themed layers (108dp).
      for (final MapEntry(key: density, value: scale)
          in _androidDensities.entries) {
        final dir = 'android/app/src/main/res/mipmap-$density';
        await _write(
          '$dir/ic_launcher.png',
          (48 * scale).round(),
          IconVariant.rounded,
        );
        await _write(
          '$dir/ic_launcher_foreground.png',
          (108 * scale).round(),
          IconVariant.adaptiveForeground,
        );
        await _write(
          '$dir/ic_launcher_monochrome.png',
          (108 * scale).round(),
          IconVariant.monochrome,
        );
      }

      // iOS: every size listed in the asset catalog, square and opaque.
      await _writeAssetCatalog(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset',
        IconVariant.fullBleed,
        opaque: true,
      );

      // Web: the favicon, the install icons and the maskable ones.
      await _write('web/favicon.png', 32, IconVariant.rounded);
      await _write('web/icons/Icon-192.png', 192, IconVariant.rounded);
      await _write('web/icons/Icon-512.png', 512, IconVariant.rounded);
      await _write(
        'web/icons/Icon-maskable-192.png',
        192,
        IconVariant.maskable,
      );
      await _write(
        'web/icons/Icon-maskable-512.png',
        512,
        IconVariant.maskable,
      );
    },
  );
}

/// Draws [variant] for every image in the Xcode asset catalog [dir] (its
/// `Contents.json` lists each file's size in points and its scale).
Future<void> _writeAssetCatalog(
  String dir,
  IconVariant variant, {
  bool opaque = false,
}) async {
  final contents =
      jsonDecode(File('$dir/Contents.json').readAsStringSync())
          as Map<String, Object?>;
  for (final Map<String, Object?> image
      in (contents['images']! as List<Object?>).cast<Map<String, Object?>>()) {
    final double points = double.parse(
      (image['size']! as String).split('x').first,
    );
    final double scale = double.parse(
      (image['scale']! as String).replaceAll('x', ''),
    );
    await _write(
      '$dir/${image['filename']}',
      (points * scale).round(),
      variant,
      opaque: opaque,
    );
  }
}

/// Draws [variant] at [size] x [size] pixels and saves it as a PNG at [path].
///
/// With [opaque], the PNG has no alpha channel, which the App Store requires
/// for iOS icons.
Future<void> _write(
  String path,
  int size,
  IconVariant variant, {
  bool opaque = false,
}) async {
  final recorder = ui.PictureRecorder();
  paintAppIcon(ui.Canvas(recorder), size.toDouble(), variant);
  final ui.Image image = await recorder.endRecording().toImage(size, size);
  final ByteData? pixels = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  image.dispose();
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(
      _encodePng(pixels!.buffer.asUint8List(), size, opaque: opaque),
    );
}

/// Encodes [rgba] pixels (4 bytes each, row by row) as a [size] x [size]
/// PNG: RGB without alpha when [opaque], RGBA otherwise.
///
/// Dart's own PNG encoder always writes an alpha channel, so this small
/// encoder exists for the iOS icons.
Uint8List _encodePng(Uint8List rgba, int size, {required bool opaque}) {
  final channels = opaque ? 3 : 4;
  // Each row starts with a filter-type byte (0 = none), then its pixels.
  final raw = BytesBuilder(copy: false);
  for (var y = 0; y < size; y++) {
    raw.addByte(0);
    for (var x = 0; x < size; x++) {
      final int i = (y * size + x) * 4;
      raw.add(rgba.sublist(i, i + channels));
    }
  }

  final header = ByteData(13)
    ..setUint32(0, size)
    ..setUint32(4, size)
    ..setUint8(8, 8) // Bits per channel.
    ..setUint8(9, opaque ? 2 : 6); // Color type: RGB or RGBA.
  final png = BytesBuilder(copy: false)
    ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  _chunk(png, 'IHDR', header.buffer.asUint8List());
  _chunk(png, 'IDAT', ZLibCodec(level: 9).encode(raw.takeBytes()));
  _chunk(png, 'IEND', Uint8List(0));
  return png.takeBytes();
}

/// Appends one PNG chunk: its length, [type], [data] and CRC.
void _chunk(BytesBuilder png, String type, List<int> data) {
  final List<int> typeAndData = [...ascii.encode(type), ...data];
  png
    ..add(_uint32(data.length))
    ..add(typeAndData)
    ..add(_uint32(_crc32(typeAndData)));
}

/// [value] as 4 big-endian bytes.
Uint8List _uint32(int value) =>
    (ByteData(4)..setUint32(0, value)).buffer.asUint8List();

/// The CRC-32 checksum PNG puts after each chunk.
int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}
