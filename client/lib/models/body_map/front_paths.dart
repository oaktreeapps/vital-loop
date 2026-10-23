// Copyright 2026 The Daily Health Tracker Authors.
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
//
// Modified by Oaktreeapps in 2026.

/// GEOMETRY ONLY — DO NOT HAND-EDIT.
///
/// One CustomClipper per region of the body, traced from an anatomical SVG
/// (fluttershapemaker.com). Coordinates are fractions of the available width;
/// height is always width * 1.7, so the figure keeps its proportions at any
/// size. `bodyMap` in body_map.dart is what names these and gives them ids;
/// nothing outside that file should reference these classes directly.
///
/// This is an asset, not content. A language model cannot produce anatomy
/// this way — see the class comment on BodyMapPicker.
///
/// This file holds the front view of the figure; `back_paths.dart` holds the
/// back. Each class below is one region. Only its `getClip` method is
/// used: the picker calls it to paint the region and to test whether a tap
/// landed inside it. None of these are used as real clippers on a widget.
library;

import 'package:flutter/material.dart';

// https://fluttershapemaker.com/ to generate paths from an SVG file
// To keep the aspect ratio the same on all shapes, every size.height has been
// replaced with size.width * 1.7.
/// Outline of the "Forehead" area (id `front.forehead`) on the front view.
class Forehead extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4248700, size.width * 1.7 * 0.04675833);
    path.lineTo(size.width * 0.5746050, size.width * 1.7 * 0.04601111);
    path.cubicTo(
      size.width * 0.5746050,
      size.width * 1.7 * 0.04601111,
      size.width * 0.5783250,
      size.width * 1.7 * 0.0009277778,
      size.width * 0.4989400,
      size.width * 1.7 * 0.001536111,
    );
    path.cubicTo(
      size.width * 0.4172150,
      size.width * 1.7 * 0.002147222,
      size.width * 0.4248700,
      size.width * 1.7 * 0.04675833,
      size.width * 0.4248700,
      size.width * 1.7 * 0.04675833,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Sinus" area (id `front.left_sinus`) on the front view.
class LeftFace extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5029950, size.width * 1.7 * 0.04993333);
    path.cubicTo(
      size.width * 0.5094950,
      size.width * 1.7 * 0.04990278,
      size.width * 0.5374950,
      size.width * 1.7 * 0.04975556,
      size.width * 0.5811100,
      size.width * 1.7 * 0.04993333,
    );
    path.lineTo(size.width * 0.5811100, size.width * 1.7 * 0.04993333);
    path.arcToPoint(
      Offset(size.width * 0.5860600, size.width * 1.7 * 0.05171389),
      radius: Radius.elliptical(
        size.width * 0.005500000,
        size.width * 1.7 * 0.003055556,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.lineTo(size.width * 0.5860600, size.width * 1.7 * 0.05171389);
    path.cubicTo(
      size.width * 0.5907450,
      size.width * 1.7 * 0.05729722,
      size.width * 0.5887650,
      size.width * 1.7 * 0.06311667,
      size.width * 0.5848100,
      size.width * 1.7 * 0.06813333,
    );
    path.cubicTo(
      size.width * 0.5794450,
      size.width * 1.7 * 0.07490278,
      size.width * 0.5703850,
      size.width * 1.7 * 0.08015833,
      size.width * 0.5683500,
      size.width * 1.7 * 0.08128611,
    );
    path.lineTo(size.width * 0.5029400, size.width * 1.7 * 0.08128611);
    path.lineTo(
      size.width * 0.5029400,
      size.width * 1.7 * 0.04993333,
    ); ////////////
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Sinus" area (id `front.right_sinus`) on the front
/// view.
class RightFace extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4972550, size.width * 1.7 * 0.04993333);
    path.lineTo(size.width * 0.4972550, size.width * 1.7 * 0.08128611);
    path.lineTo(size.width * 0.4318400, size.width * 1.7 * 0.08128611);
    path.cubicTo(
      size.width * 0.4298100,
      size.width * 1.7 * 0.08015833,
      size.width * 0.4207500,
      size.width * 1.7 * 0.07487222,
      size.width * 0.4153850,
      size.width * 1.7 * 0.06813333,
    );
    path.cubicTo(
      size.width * 0.4114250,
      size.width * 1.7 * 0.06313333,
      size.width * 0.4094500,
      size.width * 1.7 * 0.05730000,
      size.width * 0.4141350,
      size.width * 1.7 * 0.05171389,
    );
    path.lineTo(size.width * 0.4141350, size.width * 1.7 * 0.05171389);
    path.arcToPoint(
      Offset(size.width * 0.4190800, size.width * 1.7 * 0.04993333),
      radius: Radius.elliptical(
        size.width * 0.005575000,
        size.width * 1.7 * 0.003097222,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.lineTo(size.width * 0.4190800, size.width * 1.7 * 0.04993333);
    path.cubicTo(
      size.width * 0.4627250,
      size.width * 1.7 * 0.04972500,
      size.width * 0.4907450,
      size.width * 1.7 * 0.04987500,
      size.width * 0.4972550,
      size.width * 1.7 * 0.04993333,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Jaw" area (id `front.left_jaw`) on the front view.
class LeftMouth extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5660000, size.width * 1.7 * 0.08533333);
    path.cubicTo(
      size.width * 0.5660000,
      size.width * 1.7 * 0.08533333,
      size.width * 0.5588500,
      size.width * 1.7 * 0.1034722,
      size.width * 0.5483500,
      size.width * 1.7 * 0.1078056,
    );
    path.cubicTo(
      size.width * 0.5378500,
      size.width * 1.7 * 0.1121389,
      size.width * 0.5030500,
      size.width * 1.7 * 0.1108611,
      size.width * 0.5030500,
      size.width * 1.7 * 0.1108611,
    );
    path.lineTo(size.width * 0.5030500, size.width * 1.7 * 0.08533333);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Jaw" area (id `front.right_jaw`) on the front view.
class RightMouth extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4344500, size.width * 1.7 * 0.08533333);
    path.cubicTo(
      size.width * 0.4344500,
      size.width * 1.7 * 0.08533333,
      size.width * 0.4416000,
      size.width * 1.7 * 0.1034722,
      size.width * 0.4521000,
      size.width * 1.7 * 0.1078056,
    );
    path.cubicTo(
      size.width * 0.4626000,
      size.width * 1.7 * 0.1121389,
      size.width * 0.4974000,
      size.width * 1.7 * 0.1108611,
      size.width * 0.4974000,
      size.width * 1.7 * 0.1108611,
    );
    path.lineTo(size.width * 0.4974000, size.width * 1.7 * 0.08533333);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Throat" area (id `front.throat`) on the front view.
class Neck extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4713000, size.width * 1.7 * 0.1328611);
    path.cubicTo(
      size.width * 0.4762500,
      size.width * 1.7 * 0.1398889,
      size.width * 0.4906000,
      size.width * 1.7 * 0.1485000,
      size.width * 0.5007000,
      size.width * 1.7 * 0.1515278,
    );
    path.cubicTo(
      size.width * 0.5116000,
      size.width * 1.7 * 0.1496944,
      size.width * 0.5288000,
      size.width * 1.7 * 0.1407778,
      size.width * 0.5342500,
      size.width * 1.7 * 0.1325833,
    );
    path.lineTo(size.width * 0.5504000, size.width * 1.7 * 0.1296667);
    path.cubicTo(
      size.width * 0.5504000,
      size.width * 1.7 * 0.1296667,
      size.width * 0.5477500,
      size.width * 1.7 * 0.1260278,
      size.width * 0.5475000,
      size.width * 1.7 * 0.1237500,
    );
    path.cubicTo(
      size.width * 0.5472500,
      size.width * 1.7 * 0.1214722,
      size.width * 0.5485000,
      size.width * 1.7 * 0.1113056,
      size.width * 0.5485000,
      size.width * 1.7 * 0.1113056,
    );
    path.cubicTo(
      size.width * 0.5183500,
      size.width * 1.7 * 0.1147778,
      size.width * 0.4874000,
      size.width * 1.7 * 0.1150833,
      size.width * 0.4555000,
      size.width * 1.7 * 0.1114722,
    );
    path.cubicTo(
      size.width * 0.4555000,
      size.width * 1.7 * 0.1114722,
      size.width * 0.4566500,
      size.width * 1.7 * 0.1217222,
      size.width * 0.4557000,
      size.width * 1.7 * 0.1237500,
    );
    path.cubicTo(
      size.width * 0.4547500,
      size.width * 1.7 * 0.1257778,
      size.width * 0.4517500,
      size.width * 1.7 * 0.1300000,
      size.width * 0.4517500,
      size.width * 1.7 * 0.1300000,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Collar Bone" area (id `front.left_collar_bone`) on the
/// front view.
class LeftCollarBone extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5943150, size.width * 1.7 * 0.1489167);
    path.lineTo(size.width * 0.5999150, size.width * 1.7 * 0.1602222);
    path.cubicTo(
      size.width * 0.5999150,
      size.width * 1.7 * 0.1602222,
      size.width * 0.5642150,
      size.width * 1.7 * 0.1536111,
      size.width * 0.5511650,
      size.width * 1.7 * 0.1519722,
    );
    path.cubicTo(
      size.width * 0.5381150,
      size.width * 1.7 * 0.1503333,
      size.width * 0.5211650,
      size.width * 1.7 * 0.1505556,
      size.width * 0.5211650,
      size.width * 1.7 * 0.1505556,
    );
    path.cubicTo(
      size.width * 0.5211650,
      size.width * 1.7 * 0.1505556,
      size.width * 0.5280150,
      size.width * 1.7 * 0.1401389,
      size.width * 0.5398650,
      size.width * 1.7 * 0.1369167,
    );
    path.cubicTo(
      size.width * 0.5418150,
      size.width * 1.7 * 0.1363889,
      size.width * 0.5464150,
      size.width * 1.7 * 0.1345556,
      size.width * 0.5549650,
      size.width * 1.7 * 0.1349167,
    );
    path.cubicTo(
      size.width * 0.5643150,
      size.width * 1.7 * 0.1353333,
      size.width * 0.5933150,
      size.width * 1.7 * 0.1466944,
      size.width * 0.5943150,
      size.width * 1.7 * 0.1489167,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Collar Bone" area (id `front.right_collar_bone`) on
/// the front view.
class RightCollarBone extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4079500, size.width * 1.7 * 0.1489167);
    path.lineTo(size.width * 0.4023500, size.width * 1.7 * 0.1602222);
    path.cubicTo(
      size.width * 0.4023500,
      size.width * 1.7 * 0.1602222,
      size.width * 0.4380500,
      size.width * 1.7 * 0.1536111,
      size.width * 0.4511000,
      size.width * 1.7 * 0.1519722,
    );
    path.cubicTo(
      size.width * 0.4641500,
      size.width * 1.7 * 0.1503333,
      size.width * 0.4811000,
      size.width * 1.7 * 0.1505556,
      size.width * 0.4811000,
      size.width * 1.7 * 0.1505556,
    );
    path.cubicTo(
      size.width * 0.4811000,
      size.width * 1.7 * 0.1505556,
      size.width * 0.4742000,
      size.width * 1.7 * 0.1401389,
      size.width * 0.4623500,
      size.width * 1.7 * 0.1369167,
    );
    path.cubicTo(
      size.width * 0.4604000,
      size.width * 1.7 * 0.1363889,
      size.width * 0.4558000,
      size.width * 1.7 * 0.1345556,
      size.width * 0.4472500,
      size.width * 1.7 * 0.1349167,
    );
    path.cubicTo(
      size.width * 0.4379500,
      size.width * 1.7 * 0.1353333,
      size.width * 0.4089500,
      size.width * 1.7 * 0.1466944,
      size.width * 0.4079500,
      size.width * 1.7 * 0.1489167,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Shoulder" area (id `front.left_shoulder`) on the front
/// view.
class LeftDeltoid extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6023600, size.width * 1.7 * 0.1484750);
    path.cubicTo(
      size.width * 0.6023600,
      size.width * 1.7 * 0.1484750,
      size.width * 0.6024100,
      size.width * 1.7 * 0.1566972,
      size.width * 0.6160600,
      size.width * 1.7 * 0.1699750,
    );
    path.cubicTo(
      size.width * 0.6273600,
      size.width * 1.7 * 0.1809750,
      size.width * 0.6488100,
      size.width * 1.7 * 0.1982250,
      size.width * 0.6663600,
      size.width * 1.7 * 0.2053917,
    );
    path.cubicTo(
      size.width * 0.6909600,
      size.width * 1.7 * 0.2153917,
      size.width * 0.7066600,
      size.width * 1.7 * 0.2170861,
      size.width * 0.7111600,
      size.width * 1.7 * 0.2161694,
    );
    path.cubicTo(
      size.width * 0.7156600,
      size.width * 1.7 * 0.2152528,
      size.width * 0.6907100,
      size.width * 1.7 * 0.1754472,
      size.width * 0.6835100,
      size.width * 1.7 * 0.1671972,
    );
    path.cubicTo(
      size.width * 0.6763100,
      size.width * 1.7 * 0.1589472,
      size.width * 0.6721600,
      size.width * 1.7 * 0.1540306,
      size.width * 0.6622600,
      size.width * 1.7 * 0.1526139,
    );
    path.cubicTo(
      size.width * 0.6523600,
      size.width * 1.7 * 0.1511972,
      size.width * 0.6023600,
      size.width * 1.7 * 0.1484750,
      size.width * 0.6023600,
      size.width * 1.7 * 0.1484750,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Shoulder" area (id `front.right_shoulder`) on the
/// front view.
class RightDeltoid extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3997500, size.width * 1.7 * 0.1487083);
    path.cubicTo(
      size.width * 0.3997500,
      size.width * 1.7 * 0.1487083,
      size.width * 0.3997000,
      size.width * 1.7 * 0.1569306,
      size.width * 0.3860500,
      size.width * 1.7 * 0.1702083,
    );
    path.cubicTo(
      size.width * 0.3747500,
      size.width * 1.7 * 0.1812083,
      size.width * 0.3533000,
      size.width * 1.7 * 0.1984583,
      size.width * 0.3357500,
      size.width * 1.7 * 0.2056250,
    );
    path.cubicTo(
      size.width * 0.3112000,
      size.width * 1.7 * 0.2156528,
      size.width * 0.2954500,
      size.width * 1.7 * 0.2173472,
      size.width * 0.2909500,
      size.width * 1.7 * 0.2164306,
    );
    path.cubicTo(
      size.width * 0.2864500,
      size.width * 1.7 * 0.2155139,
      size.width * 0.3114000,
      size.width * 1.7 * 0.1757083,
      size.width * 0.3186000,
      size.width * 1.7 * 0.1674583,
    );
    path.cubicTo(
      size.width * 0.3258000,
      size.width * 1.7 * 0.1592083,
      size.width * 0.3299500,
      size.width * 1.7 * 0.1542917,
      size.width * 0.3398500,
      size.width * 1.7 * 0.1528750,
    );
    path.cubicTo(
      size.width * 0.3497500,
      size.width * 1.7 * 0.1514583,
      size.width * 0.3997500,
      size.width * 1.7 * 0.1487083,
      size.width * 0.3997500,
      size.width * 1.7 * 0.1487083,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Sternum" area (id `front.sternum`) on the front view.
class MidChest extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4808800, size.width * 1.7 * 0.1546889);
    path.lineTo(size.width * 0.4887300, size.width * 1.7 * 0.2407722);
    path.lineTo(size.width * 0.5160300, size.width * 1.7 * 0.2407722);
    path.lineTo(size.width * 0.5218800, size.width * 1.7 * 0.1545778);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Chest" area (id `front.left_chest`) on the front view.
class LeftPec extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6013450, size.width * 1.7 * 0.1627583);
    path.cubicTo(
      size.width * 0.6117450,
      size.width * 1.7 * 0.1739806,
      size.width * 0.6244450,
      size.width * 1.7 * 0.1843139,
      size.width * 0.6385950,
      size.width * 1.7 * 0.1940639,
    );
    path.lineTo(size.width * 0.6341450, size.width * 1.7 * 0.2360917);
    path.lineTo(size.width * 0.5250450, size.width * 1.7 * 0.2243694);
    path.lineTo(size.width * 0.5316450, size.width * 1.7 * 0.1535917);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Chest" area (id `front.right_chest`) on the front
/// view.
class RightPec extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4002500, size.width * 1.7 * 0.1634167);
    path.cubicTo(
      size.width * 0.3898500,
      size.width * 1.7 * 0.1746389,
      size.width * 0.3771500,
      size.width * 1.7 * 0.1849722,
      size.width * 0.3630000,
      size.width * 1.7 * 0.1947222,
    );
    path.lineTo(size.width * 0.3674500, size.width * 1.7 * 0.2367500);
    path.lineTo(size.width * 0.4773500, size.width * 1.7 * 0.2251389);
    path.lineTo(size.width * 0.4699500, size.width * 1.7 * 0.1542778);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Ribs" area (id `front.left_ribs`) on the front view.
class LeftLowerPec extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6325450, size.width * 1.7 * 0.2396472);
    path.lineTo(size.width * 0.6224450, size.width * 1.7 * 0.2741472);
    path.cubicTo(
      size.width * 0.6224450,
      size.width * 1.7 * 0.2741472,
      size.width * 0.5709950,
      size.width * 1.7 * 0.2679806,
      size.width * 0.5549450,
      size.width * 1.7 * 0.2635083,
    );
    path.cubicTo(
      size.width * 0.5426950,
      size.width * 1.7 * 0.2600917,
      size.width * 0.5260450,
      size.width * 1.7 * 0.2473139,
      size.width * 0.5260450,
      size.width * 1.7 * 0.2473139,
    );
    path.lineTo(size.width * 0.5246950, size.width * 1.7 * 0.2272028);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Ribs" area (id `front.right_ribs`) on the front view.
class RightLowerPec extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3690000, size.width * 1.7 * 0.2403056);
    path.lineTo(size.width * 0.3791000, size.width * 1.7 * 0.2748056);
    path.cubicTo(
      size.width * 0.3791000,
      size.width * 1.7 * 0.2748056,
      size.width * 0.4305500,
      size.width * 1.7 * 0.2686389,
      size.width * 0.4466000,
      size.width * 1.7 * 0.2641667,
    );
    path.cubicTo(
      size.width * 0.4588500,
      size.width * 1.7 * 0.2607500,
      size.width * 0.4755000,
      size.width * 1.7 * 0.2479722,
      size.width * 0.4755000,
      size.width * 1.7 * 0.2479722,
    );
    path.lineTo(size.width * 0.4776500, size.width * 1.7 * 0.2279722);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Stomach" area (id `front.stomach`) on the front view.
class MidAbdomin extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5017800, size.width * 1.7 * 0.2424667);
    path.lineTo(size.width * 0.4692800, size.width * 1.7 * 0.2611472);
    path.lineTo(size.width * 0.4682800, size.width * 1.7 * 0.3046389);
    path.lineTo(size.width * 0.5309700, size.width * 1.7 * 0.3048000);
    path.lineTo(size.width * 0.5346200, size.width * 1.7 * 0.2611472);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Abdomen" area (id `front.left_abdomen`) on the front
/// view.
class LeftAbdomin extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6201700, size.width * 1.7 * 0.2789444);
    path.arcToPoint(
      Offset(size.width * 0.6199200, size.width * 1.7 * 0.2787778),
      radius: Radius.elliptical(
        size.width * 0.0003150000,
        size.width * 1.7 * 0.0001750000,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.cubicTo(
      size.width * 0.5927700,
      size.width * 1.7 * 0.2759722,
      size.width * 0.5675700,
      size.width * 1.7 * 0.2720000,
      size.width * 0.5424700,
      size.width * 1.7 * 0.2663611,
    );
    path.arcToPoint(
      Offset(size.width * 0.5421700, size.width * 1.7 * 0.2663889),
      radius: Radius.elliptical(
        size.width * 0.0002350000,
        size.width * 1.7 * 0.0001305556,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.5420200, size.width * 1.7 * 0.2665278),
      radius: Radius.elliptical(
        size.width * 0.0002750000,
        size.width * 1.7 * 0.0001527778,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.cubicTo(
      size.width * 0.5420200,
      size.width * 1.7 * 0.2665278,
      size.width * 0.5421200,
      size.width * 1.7 * 0.2968889,
      size.width * 0.5421700,
      size.width * 1.7 * 0.3066944,
    );
    path.arcToPoint(
      Offset(size.width * 0.5406700, size.width * 1.7 * 0.3086667),
      radius: Radius.elliptical(
        size.width * 0.005000000,
        size.width * 1.7 * 0.002777778,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.5370700, size.width * 1.7 * 0.3094444),
      radius: Radius.elliptical(
        size.width * 0.004820000,
        size.width * 1.7 * 0.002677778,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.lineTo(size.width * 0.5063700, size.width * 1.7 * 0.3088611);
    path.cubicTo(
      size.width * 0.5062700,
      size.width * 1.7 * 0.3088611,
      size.width * 0.5062200,
      size.width * 1.7 * 0.3088889,
      size.width * 0.5061200,
      size.width * 1.7 * 0.3089167,
    );
    path.arcToPoint(
      Offset(size.width * 0.5060200, size.width * 1.7 * 0.3090556),
      radius: Radius.elliptical(
        size.width * 0.0003800000,
        size.width * 1.7 * 0.0002111111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.lineTo(size.width * 0.5055700, size.width * 1.7 * 0.3804167);
    path.arcToPoint(
      Offset(size.width * 0.5058700, size.width * 1.7 * 0.3806111),
      radius: Radius.elliptical(
        size.width * 0.0003750000,
        size.width * 1.7 * 0.0002083333,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.cubicTo(
      size.width * 0.5483200,
      size.width * 1.7 * 0.3817778,
      size.width * 0.5969200,
      size.width * 1.7 * 0.3805000,
      size.width * 0.6390200,
      size.width * 1.7 * 0.3746389,
    );
    path.arcToPoint(
      Offset(size.width * 0.6392700, size.width * 1.7 * 0.3744444),
      radius: Radius.elliptical(
        size.width * 0.0003750000,
        size.width * 1.7 * 0.0002083333,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Abdomen" area (id `front.right_abdomen`) on the front
/// view.
class RightAbdomin extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3803500, size.width * 1.7 * 0.2787778);
    path.arcToPoint(
      Offset(size.width * 0.3801000, size.width * 1.7 * 0.2789444),
      radius: Radius.elliptical(
        size.width * 0.0003150000,
        size.width * 1.7 * 0.0001750000,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.lineTo(size.width * 0.3610000, size.width * 1.7 * 0.3743889);
    path.arcToPoint(
      Offset(size.width * 0.3612500, size.width * 1.7 * 0.3745833),
      radius: Radius.elliptical(
        size.width * 0.0003750000,
        size.width * 1.7 * 0.0002083333,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.cubicTo(
      size.width * 0.4033000,
      size.width * 1.7 * 0.3804167,
      size.width * 0.4536000,
      size.width * 1.7 * 0.3821111,
      size.width * 0.4960500,
      size.width * 1.7 * 0.3809444,
    );
    path.arcToPoint(
      Offset(size.width * 0.4963500, size.width * 1.7 * 0.3807778),
      radius: Radius.elliptical(
        size.width * 0.0003250000,
        size.width * 1.7 * 0.0001805556,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.lineTo(size.width * 0.4973500, size.width * 1.7 * 0.3089444);
    path.arcToPoint(
      Offset(size.width * 0.4970000, size.width * 1.7 * 0.3087500),
      radius: Radius.elliptical(
        size.width * 0.0003400000,
        size.width * 1.7 * 0.0001888889,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.cubicTo(
      size.width * 0.4970000,
      size.width * 1.7 * 0.3087500,
      size.width * 0.4739500,
      size.width * 1.7 * 0.3091944,
      size.width * 0.4632000,
      size.width * 1.7 * 0.3094167,
    );
    path.arcToPoint(
      Offset(size.width * 0.4596000, size.width * 1.7 * 0.3086389),
      radius: Radius.elliptical(
        size.width * 0.004820000,
        size.width * 1.7 * 0.002677778,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.4581000, size.width * 1.7 * 0.3066667),
      radius: Radius.elliptical(
        size.width * 0.005000000,
        size.width * 1.7 * 0.002777778,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.4581500,
      size.width * 1.7 * 0.2968611,
      size.width * 0.4582500,
      size.width * 1.7 * 0.2665000,
      size.width * 0.4582500,
      size.width * 1.7 * 0.2665000,
    );
    path.arcToPoint(
      Offset(size.width * 0.4581000, size.width * 1.7 * 0.2663611),
      radius: Radius.elliptical(
        size.width * 0.0002750000,
        size.width * 1.7 * 0.0001527778,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.4578000, size.width * 1.7 * 0.2663333),
      radius: Radius.elliptical(
        size.width * 0.0006350000,
        size.width * 1.7 * 0.0003527778,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.cubicTo(
      size.width * 0.4327000,
      size.width * 1.7 * 0.2720000,
      size.width * 0.4075000,
      size.width * 1.7 * 0.2759722,
      size.width * 0.3803500,
      size.width * 1.7 * 0.2787778,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Pelvis" area (id `front.left_pelvis`) on the front
/// view.
class FrontLeftPelvic extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6405700, size.width * 1.7 * 0.3784167);
    path.lineTo(size.width * 0.6448200, size.width * 1.7 * 0.3865833);
    path.cubicTo(
      size.width * 0.5971200,
      size.width * 1.7 * 0.4019167,
      size.width * 0.5561200,
      size.width * 1.7 * 0.4218056,
      size.width * 0.5395700,
      size.width * 1.7 * 0.4479167,
    );
    path.lineTo(size.width * 0.5051200, size.width * 1.7 * 0.4480000);
    path.lineTo(size.width * 0.5059700, size.width * 1.7 * 0.3851389);
    path.cubicTo(
      size.width * 0.5455000,
      size.width * 1.7 * 0.3865278,
      size.width * 0.5997700,
      size.width * 1.7 * 0.3838056,
      size.width * 0.6405700,
      size.width * 1.7 * 0.3784167,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Pelvis" area (id `front.right_pelvis`) on the front
/// view.
class FrontRightPelvic extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3597000, size.width * 1.7 * 0.3784167);
    path.lineTo(size.width * 0.3554500, size.width * 1.7 * 0.3865833);
    path.cubicTo(
      size.width * 0.4031500,
      size.width * 1.7 * 0.4019167,
      size.width * 0.4441500,
      size.width * 1.7 * 0.4218056,
      size.width * 0.4607000,
      size.width * 1.7 * 0.4479167,
    );
    path.lineTo(size.width * 0.4952000, size.width * 1.7 * 0.4480278);
    path.lineTo(size.width * 0.4959000, size.width * 1.7 * 0.3849167);
    path.cubicTo(
      size.width * 0.4563500,
      size.width * 1.7 * 0.3863333,
      size.width * 0.4005000,
      size.width * 1.7 * 0.3838056,
      size.width * 0.3597000,
      size.width * 1.7 * 0.3784167,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Hip" area (id `front.left_hip`) on the front view.
class FrontLeftHip extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6637700, size.width * 1.7 * 0.5118611);
    path.cubicTo(
      size.width * 0.6637700,
      size.width * 1.7 * 0.5118611,
      size.width * 0.5863200,
      size.width * 1.7 * 0.4465556,
      size.width * 0.5836700,
      size.width * 1.7 * 0.4267500,
    );
    path.cubicTo(
      size.width * 0.5816200,
      size.width * 1.7 * 0.4115556,
      size.width * 0.6477200,
      size.width * 1.7 * 0.3931389,
      size.width * 0.6477200,
      size.width * 1.7 * 0.3931389,
    );
    path.cubicTo(
      size.width * 0.6477200,
      size.width * 1.7 * 0.3931389,
      size.width * 0.6648200,
      size.width * 1.7 * 0.4243333,
      size.width * 0.6667200,
      size.width * 1.7 * 0.4404722,
    );
    path.cubicTo(
      size.width * 0.6690000,
      size.width * 1.7 * 0.4601667,
      size.width * 0.6637700,
      size.width * 1.7 * 0.5118611,
      size.width * 0.6637700,
      size.width * 1.7 * 0.5118611,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Hip" area (id `front.right_hip`) on the front view.
class FrontRightHip extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3364500, size.width * 1.7 * 0.5118611);
    path.cubicTo(
      size.width * 0.3364500,
      size.width * 1.7 * 0.5118611,
      size.width * 0.4139000,
      size.width * 1.7 * 0.4465556,
      size.width * 0.4165500,
      size.width * 1.7 * 0.4267500,
    );
    path.cubicTo(
      size.width * 0.4186000,
      size.width * 1.7 * 0.4115556,
      size.width * 0.3525000,
      size.width * 1.7 * 0.3931389,
      size.width * 0.3525000,
      size.width * 1.7 * 0.3931389,
    );
    path.cubicTo(
      size.width * 0.3525000,
      size.width * 1.7 * 0.3931389,
      size.width * 0.3354000,
      size.width * 1.7 * 0.4243333,
      size.width * 0.3335000,
      size.width * 1.7 * 0.4404722,
    );
    path.cubicTo(
      size.width * 0.3312500,
      size.width * 1.7 * 0.4601667,
      size.width * 0.3364500,
      size.width * 1.7 * 0.5118611,
      size.width * 0.3364500,
      size.width * 1.7 * 0.5118611,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Groin" area (id `front.left_groin`) on the front view.
class LeftHipFlexer extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5886700, size.width * 1.7 * 0.4488333);
    path.cubicTo(
      size.width * 0.5839200,
      size.width * 1.7 * 0.4402500,
      size.width * 0.5752700,
      size.width * 1.7 * 0.4317222,
      size.width * 0.5746700,
      size.width * 1.7 * 0.4229722,
    );
    path.cubicTo(
      size.width * 0.5619200,
      size.width * 1.7 * 0.4304444,
      size.width * 0.5543200,
      size.width * 1.7 * 0.4388056,
      size.width * 0.5481200,
      size.width * 1.7 * 0.4479167,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Groin" area (id `front.right_groin`) on the front
/// view.
class RightHipFlexer extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4112000, size.width * 1.7 * 0.4488333);
    path.cubicTo(
      size.width * 0.4159500,
      size.width * 1.7 * 0.4402500,
      size.width * 0.4246000,
      size.width * 1.7 * 0.4317222,
      size.width * 0.4252000,
      size.width * 1.7 * 0.4229722,
    );
    path.cubicTo(
      size.width * 0.4379500,
      size.width * 1.7 * 0.4304444,
      size.width * 0.4455500,
      size.width * 1.7 * 0.4388056,
      size.width * 0.4517500,
      size.width * 1.7 * 0.4479167,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Thigh" area (id `front.left_thigh`) on the front view.
class LeftQuad extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6619700, size.width * 1.7 * 0.5173056);
    path.lineTo(size.width * 0.5899200, size.width * 1.7 * 0.4533889);
    path.lineTo(size.width * 0.5052200, size.width * 1.7 * 0.4526667);
    path.cubicTo(
      size.width * 0.5009700,
      size.width * 1.7 * 0.5122500,
      size.width * 0.5133200,
      size.width * 1.7 * 0.5756944,
      size.width * 0.5275700,
      size.width * 1.7 * 0.6336944,
    );
    path.cubicTo(
      size.width * 0.5697700,
      size.width * 1.7 * 0.6339722,
      size.width * 0.6064200,
      size.width * 1.7 * 0.6358333,
      size.width * 0.6208700,
      size.width * 1.7 * 0.6440556,
    );
    path.cubicTo(
      size.width * 0.6459200,
      size.width * 1.7 * 0.6066667,
      size.width * 0.6574200,
      size.width * 1.7 * 0.5644167,
      size.width * 0.6619700,
      size.width * 1.7 * 0.5173056,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Thigh" area (id `front.right_thigh`) on the front
/// view.
class RightQuad extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3383000, size.width * 1.7 * 0.5173056);
    path.lineTo(size.width * 0.4098000, size.width * 1.7 * 0.4533056);
    path.lineTo(size.width * 0.4949500, size.width * 1.7 * 0.4525833);
    path.cubicTo(
      size.width * 0.4992000,
      size.width * 1.7 * 0.5121667,
      size.width * 0.4869500,
      size.width * 1.7 * 0.5757222,
      size.width * 0.4727000,
      size.width * 1.7 * 0.6337222,
    );
    path.cubicTo(
      size.width * 0.4305000,
      size.width * 1.7 * 0.6340000,
      size.width * 0.3938500,
      size.width * 1.7 * 0.6358611,
      size.width * 0.3794000,
      size.width * 1.7 * 0.6440833,
    );
    path.cubicTo(
      size.width * 0.3543500,
      size.width * 1.7 * 0.6066667,
      size.width * 0.3428500,
      size.width * 1.7 * 0.5644167,
      size.width * 0.3383000,
      size.width * 1.7 * 0.5173056,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Knee" area (id `front.left_knee`) on the front view.
class LeftKnee extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5730800, size.width * 1.7 * 0.6630250);
    path.cubicTo(
      size.width * 0.5952700,
      size.width * 1.7 * 0.6653528,
      size.width * 0.6148350,
      size.width * 1.7 * 0.6626028,
      size.width * 0.6167800,
      size.width * 1.7 * 0.6568778,
    );
    path.cubicTo(
      size.width * 0.6187250,
      size.width * 1.7 * 0.6511528,
      size.width * 0.6023150,
      size.width * 1.7 * 0.6446278,
      size.width * 0.5801300,
      size.width * 1.7 * 0.6423000,
    );
    path.cubicTo(
      size.width * 0.5579450,
      size.width * 1.7 * 0.6399722,
      size.width * 0.5383750,
      size.width * 1.7 * 0.6427222,
      size.width * 0.5364300,
      size.width * 1.7 * 0.6484472,
    );
    path.cubicTo(
      size.width * 0.5344850,
      size.width * 1.7 * 0.6541722,
      size.width * 0.5508900,
      size.width * 1.7 * 0.6606944,
      size.width * 0.5730800,
      size.width * 1.7 * 0.6630250,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Knee" area (id `front.right_knee`) on the front view.
class RightKnee extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4271500, size.width * 1.7 * 0.6630250);
    path.cubicTo(
      size.width * 0.4049600,
      size.width * 1.7 * 0.6653528,
      size.width * 0.3853950,
      size.width * 1.7 * 0.6626028,
      size.width * 0.3834500,
      size.width * 1.7 * 0.6568778,
    );
    path.cubicTo(
      size.width * 0.3815050,
      size.width * 1.7 * 0.6511528,
      size.width * 0.3979150,
      size.width * 1.7 * 0.6446278,
      size.width * 0.4201050,
      size.width * 1.7 * 0.6423000,
    );
    path.cubicTo(
      size.width * 0.4422950,
      size.width * 1.7 * 0.6399722,
      size.width * 0.4618550,
      size.width * 1.7 * 0.6427222,
      size.width * 0.4638050,
      size.width * 1.7 * 0.6484472,
    );
    path.cubicTo(
      size.width * 0.4657550,
      size.width * 1.7 * 0.6541722,
      size.width * 0.4493400,
      size.width * 1.7 * 0.6606944,
      size.width * 0.4271500,
      size.width * 1.7 * 0.6630250,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Shin" area (id `front.left_shin`) on the front view.
class LeftShin extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6193700, size.width * 1.7 * 0.6656667);
    path.cubicTo(
      size.width * 0.6402200,
      size.width * 1.7 * 0.7189167,
      size.width * 0.6230200,
      size.width * 1.7 * 0.7674722,
      size.width * 0.6051700,
      size.width * 1.7 * 0.8140556,
    );
    path.lineTo(size.width * 0.5579200, size.width * 1.7 * 0.8101111);
    path.cubicTo(
      size.width * 0.5579200,
      size.width * 1.7 * 0.8101111,
      size.width * 0.5305200,
      size.width * 1.7 * 0.7217778,
      size.width * 0.5313700,
      size.width * 1.7 * 0.7004722,
    );
    path.cubicTo(
      size.width * 0.5315700,
      size.width * 1.7 * 0.6956944,
      size.width * 0.5343200,
      size.width * 1.7 * 0.6883056,
      size.width * 0.5350700,
      size.width * 1.7 * 0.6829444,
    );
    path.cubicTo(
      size.width * 0.5359200,
      size.width * 1.7 * 0.6769722,
      size.width * 0.5350200,
      size.width * 1.7 * 0.6629722,
      size.width * 0.5350200,
      size.width * 1.7 * 0.6629722,
    );
    path.cubicTo(
      size.width * 0.5653200,
      size.width * 1.7 * 0.6680556,
      size.width * 0.5938700,
      size.width * 1.7 * 0.6698056,
      size.width * 0.6193700,
      size.width * 1.7 * 0.6656667,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Shin" area (id `front.right_shin`) on the front view.
class RightShin extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3809000, size.width * 1.7 * 0.6656667);
    path.cubicTo(
      size.width * 0.3600500,
      size.width * 1.7 * 0.7189167,
      size.width * 0.3772500,
      size.width * 1.7 * 0.7674722,
      size.width * 0.3951000,
      size.width * 1.7 * 0.8140556,
    );
    path.lineTo(size.width * 0.4423500, size.width * 1.7 * 0.8101111);
    path.cubicTo(
      size.width * 0.4423500,
      size.width * 1.7 * 0.8101111,
      size.width * 0.4697500,
      size.width * 1.7 * 0.7217778,
      size.width * 0.4689000,
      size.width * 1.7 * 0.7004722,
    );
    path.cubicTo(
      size.width * 0.4687000,
      size.width * 1.7 * 0.6956944,
      size.width * 0.4659500,
      size.width * 1.7 * 0.6883056,
      size.width * 0.4652000,
      size.width * 1.7 * 0.6829444,
    );
    path.cubicTo(
      size.width * 0.4643500,
      size.width * 1.7 * 0.6769722,
      size.width * 0.4652500,
      size.width * 1.7 * 0.6629722,
      size.width * 0.4652500,
      size.width * 1.7 * 0.6629722,
    );
    path.cubicTo(
      size.width * 0.4349500,
      size.width * 1.7 * 0.6680556,
      size.width * 0.4064000,
      size.width * 1.7 * 0.6698056,
      size.width * 0.3809000,
      size.width * 1.7 * 0.6656667,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Ankle" area (id `front.left_ankle`) on the front view.
class LeftFrontAnkle extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5676200, size.width * 1.7 * 0.8306389);
    path.cubicTo(
      size.width * 0.5626700,
      size.width * 1.7 * 0.8280000,
      size.width * 0.5701700,
      size.width * 1.7 * 0.8163889,
      size.width * 0.5747700,
      size.width * 1.7 * 0.8160833,
    );
    path.cubicTo(
      size.width * 0.5797700,
      size.width * 1.7 * 0.8157500,
      size.width * 0.5926700,
      size.width * 1.7 * 0.8141667,
      size.width * 0.5987700,
      size.width * 1.7 * 0.8207222,
    );
    path.cubicTo(
      size.width * 0.6016700,
      size.width * 1.7 * 0.8238333,
      size.width * 0.6028200,
      size.width * 1.7 * 0.8316389,
      size.width * 0.5971700,
      size.width * 1.7 * 0.8326944,
    );
    path.cubicTo(
      size.width * 0.5915200,
      size.width * 1.7 * 0.8337500,
      size.width * 0.5719700,
      size.width * 1.7 * 0.8329444,
      size.width * 0.5676200,
      size.width * 1.7 * 0.8306389,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Ankle" area (id `front.right_ankle`) on the front
/// view.
class RightFrontAnkle extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.4326500, size.width * 1.7 * 0.8306389);
    path.cubicTo(
      size.width * 0.4376000,
      size.width * 1.7 * 0.8280000,
      size.width * 0.4301000,
      size.width * 1.7 * 0.8163889,
      size.width * 0.4255000,
      size.width * 1.7 * 0.8160833,
    );
    path.cubicTo(
      size.width * 0.4205000,
      size.width * 1.7 * 0.8157500,
      size.width * 0.4076000,
      size.width * 1.7 * 0.8141667,
      size.width * 0.4015000,
      size.width * 1.7 * 0.8207222,
    );
    path.cubicTo(
      size.width * 0.3986000,
      size.width * 1.7 * 0.8238333,
      size.width * 0.3974500,
      size.width * 1.7 * 0.8316389,
      size.width * 0.4031000,
      size.width * 1.7 * 0.8326944,
    );
    path.cubicTo(
      size.width * 0.4087500,
      size.width * 1.7 * 0.8337500,
      size.width * 0.4283000,
      size.width * 1.7 * 0.8329444,
      size.width * 0.4326500,
      size.width * 1.7 * 0.8306389,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Foot" area (id `front.left_foot`) on the front view.
class LeftFrontFoot extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6048700, size.width * 1.7 * 0.8396944);
    path.cubicTo(
      size.width * 0.6117200,
      size.width * 1.7 * 0.8430278,
      size.width * 0.6117700,
      size.width * 1.7 * 0.8575556,
      size.width * 0.6117700,
      size.width * 1.7 * 0.8575556,
    );
    path.cubicTo(
      size.width * 0.6117700,
      size.width * 1.7 * 0.8575556,
      size.width * 0.6390200,
      size.width * 1.7 * 0.8873333,
      size.width * 0.6436200,
      size.width * 1.7 * 0.8971389,
    );
    path.cubicTo(
      size.width * 0.6465700,
      size.width * 1.7 * 0.9033889,
      size.width * 0.6410700,
      size.width * 1.7 * 0.9132778,
      size.width * 0.6393200,
      size.width * 1.7 * 0.9163889,
    );
    path.cubicTo(
      size.width * 0.6386700,
      size.width * 1.7 * 0.9175000,
      size.width * 0.6340200,
      size.width * 1.7 * 0.9168056,
      size.width * 0.6330700,
      size.width * 1.7 * 0.9157778,
    );
    path.cubicTo(
      size.width * 0.6316700,
      size.width * 1.7 * 0.9142500,
      size.width * 0.6309200,
      size.width * 1.7 * 0.9072500,
      size.width * 0.6309200,
      size.width * 1.7 * 0.9072500,
    );
    path.cubicTo(
      size.width * 0.6309200,
      size.width * 1.7 * 0.9072500,
      size.width * 0.6303200,
      size.width * 1.7 * 0.9141667,
      size.width * 0.6289200,
      size.width * 1.7 * 0.9158056,
    );
    path.cubicTo(
      size.width * 0.6279200,
      size.width * 1.7 * 0.9170000,
      size.width * 0.6238200,
      size.width * 1.7 * 0.9177778,
      size.width * 0.6225700,
      size.width * 1.7 * 0.9166667,
    );
    path.cubicTo(
      size.width * 0.6209200,
      size.width * 1.7 * 0.9151944,
      size.width * 0.6190200,
      size.width * 1.7 * 0.9064444,
      size.width * 0.6190200,
      size.width * 1.7 * 0.9064444,
    );
    path.cubicTo(
      size.width * 0.6190200,
      size.width * 1.7 * 0.9064444,
      size.width * 0.6186200,
      size.width * 1.7 * 0.9158056,
      size.width * 0.6172200,
      size.width * 1.7 * 0.9176389,
    );
    path.cubicTo(
      size.width * 0.6163700,
      size.width * 1.7 * 0.9187500,
      size.width * 0.6116700,
      size.width * 1.7 * 0.9185556,
      size.width * 0.6106700,
      size.width * 1.7 * 0.9174722,
    );
    path.cubicTo(
      size.width * 0.6089200,
      size.width * 1.7 * 0.9155278,
      size.width * 0.6067200,
      size.width * 1.7 * 0.9060556,
      size.width * 0.6067200,
      size.width * 1.7 * 0.9060556,
    );
    path.cubicTo(
      size.width * 0.6067200,
      size.width * 1.7 * 0.9060556,
      size.width * 0.6082700,
      size.width * 1.7 * 0.9164444,
      size.width * 0.6068200,
      size.width * 1.7 * 0.9185000,
    );
    path.cubicTo(
      size.width * 0.6057700,
      size.width * 1.7 * 0.9200278,
      size.width * 0.5995700,
      size.width * 1.7 * 0.9197778,
      size.width * 0.5980200,
      size.width * 1.7 * 0.9183889,
    );
    path.cubicTo(
      size.width * 0.5957700,
      size.width * 1.7 * 0.9163056,
      size.width * 0.5932200,
      size.width * 1.7 * 0.9060556,
      size.width * 0.5932200,
      size.width * 1.7 * 0.9060556,
    );
    path.cubicTo(
      size.width * 0.5932200,
      size.width * 1.7 * 0.9060556,
      size.width * 0.5929200,
      size.width * 1.7 * 0.9166111,
      size.width * 0.5896200,
      size.width * 1.7 * 0.9186667,
    );
    path.cubicTo(
      size.width * 0.5863200,
      size.width * 1.7 * 0.9207222,
      size.width * 0.5770200,
      size.width * 1.7 * 0.9191111,
      size.width * 0.5733700,
      size.width * 1.7 * 0.9182500,
    );
    path.cubicTo(
      size.width * 0.5702700,
      size.width * 1.7 * 0.9175278,
      size.width * 0.5680200,
      size.width * 1.7 * 0.9154722,
      size.width * 0.5677200,
      size.width * 1.7 * 0.9135833,
    );
    path.cubicTo(
      size.width * 0.5669700,
      size.width * 1.7 * 0.9092222,
      size.width * 0.5688700,
      size.width * 1.7 * 0.8920000,
      size.width * 0.5688700,
      size.width * 1.7 * 0.8920000,
    );
    path.cubicTo(
      size.width * 0.5688700,
      size.width * 1.7 * 0.8920000,
      size.width * 0.5608200,
      size.width * 1.7 * 0.8794444,
      size.width * 0.5606700,
      size.width * 1.7 * 0.8758889,
    );
    path.cubicTo(
      size.width * 0.5605200,
      size.width * 1.7 * 0.8715833,
      size.width * 0.5647700,
      size.width * 1.7 * 0.8630278,
      size.width * 0.5649200,
      size.width * 1.7 * 0.8596944,
    );
    path.cubicTo(
      size.width * 0.5650700,
      size.width * 1.7 * 0.8562500,
      size.width * 0.5600700,
      size.width * 1.7 * 0.8500278,
      size.width * 0.5606700,
      size.width * 1.7 * 0.8463056,
    );
    path.cubicTo(
      size.width * 0.5613200,
      size.width * 1.7 * 0.8423056,
      size.width * 0.5677200,
      size.width * 1.7 * 0.8380278,
      size.width * 0.5684200,
      size.width * 1.7 * 0.8377778,
    );
    path.cubicTo(
      size.width * 0.5690700,
      size.width * 1.7 * 0.8374444,
      size.width * 0.5980700,
      size.width * 1.7 * 0.8363611,
      size.width * 0.6048700,
      size.width * 1.7 * 0.8396944,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Foot" area (id `front.right_foot`) on the front view.
class RightFrontFoot extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3954000, size.width * 1.7 * 0.8396944);
    path.cubicTo(
      size.width * 0.3885500,
      size.width * 1.7 * 0.8430278,
      size.width * 0.3885000,
      size.width * 1.7 * 0.8575556,
      size.width * 0.3885000,
      size.width * 1.7 * 0.8575556,
    );
    path.cubicTo(
      size.width * 0.3885000,
      size.width * 1.7 * 0.8575556,
      size.width * 0.3612500,
      size.width * 1.7 * 0.8873333,
      size.width * 0.3566500,
      size.width * 1.7 * 0.8971389,
    );
    path.cubicTo(
      size.width * 0.3537000,
      size.width * 1.7 * 0.9033889,
      size.width * 0.3592000,
      size.width * 1.7 * 0.9132778,
      size.width * 0.3609500,
      size.width * 1.7 * 0.9163889,
    );
    path.cubicTo(
      size.width * 0.3616000,
      size.width * 1.7 * 0.9175000,
      size.width * 0.3662500,
      size.width * 1.7 * 0.9168056,
      size.width * 0.3672000,
      size.width * 1.7 * 0.9157778,
    );
    path.cubicTo(
      size.width * 0.3686000,
      size.width * 1.7 * 0.9142500,
      size.width * 0.3693500,
      size.width * 1.7 * 0.9072500,
      size.width * 0.3693500,
      size.width * 1.7 * 0.9072500,
    );
    path.cubicTo(
      size.width * 0.3693500,
      size.width * 1.7 * 0.9072500,
      size.width * 0.3699500,
      size.width * 1.7 * 0.9141667,
      size.width * 0.3713500,
      size.width * 1.7 * 0.9158056,
    );
    path.cubicTo(
      size.width * 0.3723500,
      size.width * 1.7 * 0.9170000,
      size.width * 0.3764500,
      size.width * 1.7 * 0.9177778,
      size.width * 0.3777000,
      size.width * 1.7 * 0.9166667,
    );
    path.cubicTo(
      size.width * 0.3793500,
      size.width * 1.7 * 0.9151944,
      size.width * 0.3812500,
      size.width * 1.7 * 0.9064444,
      size.width * 0.3812500,
      size.width * 1.7 * 0.9064444,
    );
    path.cubicTo(
      size.width * 0.3812500,
      size.width * 1.7 * 0.9064444,
      size.width * 0.3816500,
      size.width * 1.7 * 0.9158056,
      size.width * 0.3830500,
      size.width * 1.7 * 0.9176389,
    );
    path.cubicTo(
      size.width * 0.3839000,
      size.width * 1.7 * 0.9187500,
      size.width * 0.3886000,
      size.width * 1.7 * 0.9185556,
      size.width * 0.3896000,
      size.width * 1.7 * 0.9174722,
    );
    path.cubicTo(
      size.width * 0.3913500,
      size.width * 1.7 * 0.9155278,
      size.width * 0.3935500,
      size.width * 1.7 * 0.9060556,
      size.width * 0.3935500,
      size.width * 1.7 * 0.9060556,
    );
    path.cubicTo(
      size.width * 0.3935500,
      size.width * 1.7 * 0.9060556,
      size.width * 0.3920000,
      size.width * 1.7 * 0.9164444,
      size.width * 0.3934500,
      size.width * 1.7 * 0.9185000,
    );
    path.cubicTo(
      size.width * 0.3945000,
      size.width * 1.7 * 0.9200278,
      size.width * 0.4007000,
      size.width * 1.7 * 0.9197778,
      size.width * 0.4022500,
      size.width * 1.7 * 0.9183889,
    );
    path.cubicTo(
      size.width * 0.4045000,
      size.width * 1.7 * 0.9163056,
      size.width * 0.4070500,
      size.width * 1.7 * 0.9060556,
      size.width * 0.4070500,
      size.width * 1.7 * 0.9060556,
    );
    path.cubicTo(
      size.width * 0.4070500,
      size.width * 1.7 * 0.9060556,
      size.width * 0.4073500,
      size.width * 1.7 * 0.9166111,
      size.width * 0.4106500,
      size.width * 1.7 * 0.9186667,
    );
    path.cubicTo(
      size.width * 0.4139500,
      size.width * 1.7 * 0.9207222,
      size.width * 0.4232500,
      size.width * 1.7 * 0.9191111,
      size.width * 0.4269000,
      size.width * 1.7 * 0.9182500,
    );
    path.cubicTo(
      size.width * 0.4300000,
      size.width * 1.7 * 0.9175278,
      size.width * 0.4322500,
      size.width * 1.7 * 0.9154722,
      size.width * 0.4325500,
      size.width * 1.7 * 0.9135833,
    );
    path.cubicTo(
      size.width * 0.4333000,
      size.width * 1.7 * 0.9092222,
      size.width * 0.4314000,
      size.width * 1.7 * 0.8920000,
      size.width * 0.4314000,
      size.width * 1.7 * 0.8920000,
    );
    path.cubicTo(
      size.width * 0.4314000,
      size.width * 1.7 * 0.8920000,
      size.width * 0.4394500,
      size.width * 1.7 * 0.8794444,
      size.width * 0.4396000,
      size.width * 1.7 * 0.8758889,
    );
    path.cubicTo(
      size.width * 0.4397500,
      size.width * 1.7 * 0.8715833,
      size.width * 0.4355000,
      size.width * 1.7 * 0.8630278,
      size.width * 0.4353500,
      size.width * 1.7 * 0.8596944,
    );
    path.cubicTo(
      size.width * 0.4352000,
      size.width * 1.7 * 0.8562500,
      size.width * 0.4402000,
      size.width * 1.7 * 0.8500278,
      size.width * 0.4396000,
      size.width * 1.7 * 0.8463056,
    );
    path.cubicTo(
      size.width * 0.4389500,
      size.width * 1.7 * 0.8423056,
      size.width * 0.4325500,
      size.width * 1.7 * 0.8380278,
      size.width * 0.4318500,
      size.width * 1.7 * 0.8377778,
    );
    path.cubicTo(
      size.width * 0.4312000,
      size.width * 1.7 * 0.8374444,
      size.width * 0.4022000,
      size.width * 1.7 * 0.8363611,
      size.width * 0.3954000,
      size.width * 1.7 * 0.8396944,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left Pinky Toe" (id `front.left_pinky_toe`) on the front
/// view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class LeftToe1 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.7940400, size.width * 1.7 * 0.9403611);
    path.arcToPoint(
      Offset(size.width * 0.8176400, size.width * 1.7 * 0.9534722),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.7940500, size.width * 1.7 * 0.9403528),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left #4 Toe" (id `front.left_no4_toe`) on the front view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class LeftToe2 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.7429850, size.width * 1.7 * 0.9620278);
    path.arcToPoint(
      Offset(size.width * 0.7665850, size.width * 1.7 * 0.9751389),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.7430000, size.width * 1.7 * 0.9620278),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left Middle Toe" (id `front.left_middle_toe`) on the
/// front view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class LeftToe3 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.6862700, size.width * 1.7 * 0.9722639);
    path.arcToPoint(
      Offset(size.width * 0.7098700, size.width * 1.7 * 0.9853750),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.6862700, size.width * 1.7 * 0.9722639),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left #2 Toe" (id `front.left_no2_toe`) on the front view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class LeftToe4 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.6256500, size.width * 1.7 * 0.9719861);
    path.arcToPoint(
      Offset(size.width * 0.6492500, size.width * 1.7 * 0.9850972),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.6256500, size.width * 1.7 * 0.9719750),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left Big Toe" (id `front.left_big_toe`) on the front
/// view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class LeftToe5 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5672750, size.width * 1.7 * 0.9645278);
    path.arcToPoint(
      Offset(size.width * 0.5908750, size.width * 1.7 * 0.9776389),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.5672750, size.width * 1.7 * 0.9645278),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right Pinky Toe" (id `front.right_pinky_toe`) on the
/// front view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class RightToe1 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.2081100, size.width * 1.7 * 0.9403611);
    path.arcToPoint(
      Offset(size.width * 0.1845100, size.width * 1.7 * 0.9534722),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.2081200, size.width * 1.7 * 0.9403528),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right #4 Toe" (id `front.right_no4_toe`) on the front
/// view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class RightToe2 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.2591650, size.width * 1.7 * 0.9620278);
    path.arcToPoint(
      Offset(size.width * 0.2355650, size.width * 1.7 * 0.9751389),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.2591750, size.width * 1.7 * 0.9620278),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right Middle Toe" (id `front.right_middle_toe`) on the
/// front view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class RightToe3 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3159500, size.width * 1.7 * 0.9722639);
    path.arcToPoint(
      Offset(size.width * 0.2923500, size.width * 1.7 * 0.9853750),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.3159500, size.width * 1.7 * 0.9722639),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right #2 Toe" (id `front.right_no2_toe`) on the front
/// view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class RightToe4 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3765150, size.width * 1.7 * 0.9719861);
    path.arcToPoint(
      Offset(size.width * 0.3529150, size.width * 1.7 * 0.9850972),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.3765000, size.width * 1.7 * 0.9719750),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right Big Toe" (id `front.right_big_toe`) on the front
/// view.
///
/// Drawn as a ring beside the foot, because the real toe is too small
/// to tap.
class RightToe5 extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4348900, size.width * 1.7 * 0.9645278);
    path.arcToPoint(
      Offset(size.width * 0.4112900, size.width * 1.7 * 0.9776389),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.4348900, size.width * 1.7 * 0.9645278),
      radius: Radius.elliptical(
        size.width * 0.02360000,
        size.width * 1.7 * 0.01311111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Brachial" area (id `front.left_brachial`) on the front
/// view.
class LeftBicep extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.7121450, size.width * 1.7 * 0.2195083);
    path.cubicTo(
      size.width * 0.6899450,
      size.width * 1.7 * 0.2198417,
      size.width * 0.6542450,
      size.width * 1.7 * 0.2075917,
      size.width * 0.6444950,
      size.width * 1.7 * 0.1984528,
    );
    path.lineTo(size.width * 0.6394950, size.width * 1.7 * 0.2386750);
    path.cubicTo(
      size.width * 0.6394950,
      size.width * 1.7 * 0.2386750,
      size.width * 0.6278450,
      size.width * 1.7 * 0.2587583,
      size.width * 0.6378450,
      size.width * 1.7 * 0.2745361,
    );
    path.cubicTo(
      size.width * 0.6478450,
      size.width * 1.7 * 0.2903139,
      size.width * 0.6572950,
      size.width * 1.7 * 0.3088972,
      size.width * 0.6572950,
      size.width * 1.7 * 0.3088972,
    );
    path.cubicTo(
      size.width * 0.6733450,
      size.width * 1.7 * 0.3020361,
      size.width * 0.7010950,
      size.width * 1.7 * 0.2978972,
      size.width * 0.7386450,
      size.width * 1.7 * 0.2960639,
    );
    path.cubicTo(
      size.width * 0.7386450,
      size.width * 1.7 * 0.2960639,
      size.width * 0.7130950,
      size.width * 1.7 * 0.2195083,
      size.width * 0.7121450,
      size.width * 1.7 * 0.2195083,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Brachial" area (id `front.right_brachial`) on the
/// front view.
class RightBicep extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.2894000, size.width * 1.7 * 0.2201944);
    path.cubicTo(
      size.width * 0.3116000,
      size.width * 1.7 * 0.2205278,
      size.width * 0.3473000,
      size.width * 1.7 * 0.2082778,
      size.width * 0.3570500,
      size.width * 1.7 * 0.1991389,
    );
    path.lineTo(size.width * 0.3620500, size.width * 1.7 * 0.2393611);
    path.cubicTo(
      size.width * 0.3620500,
      size.width * 1.7 * 0.2393611,
      size.width * 0.3737000,
      size.width * 1.7 * 0.2594444,
      size.width * 0.3637000,
      size.width * 1.7 * 0.2752222,
    );
    path.cubicTo(
      size.width * 0.3537000,
      size.width * 1.7 * 0.2910000,
      size.width * 0.3442500,
      size.width * 1.7 * 0.3095833,
      size.width * 0.3442500,
      size.width * 1.7 * 0.3095833,
    );
    path.cubicTo(
      size.width * 0.3282000,
      size.width * 1.7 * 0.3027222,
      size.width * 0.3004500,
      size.width * 1.7 * 0.2985833,
      size.width * 0.2629000,
      size.width * 1.7 * 0.2967500,
    );
    path.cubicTo(
      size.width * 0.2629000,
      size.width * 1.7 * 0.2967222,
      size.width * 0.2884500,
      size.width * 1.7 * 0.2201667,
      size.width * 0.2894000,
      size.width * 1.7 * 0.2201944,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Antecubital" area (id `front.left_antecubital`) on the
/// front view.
class LeftInnerElbow extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6716050, size.width * 1.7 * 0.3157444);
    path.cubicTo(
      size.width * 0.6739450,
      size.width * 1.7 * 0.3194667,
      size.width * 0.6900450,
      size.width * 1.7 * 0.3197278,
      size.width * 0.7075650,
      size.width * 1.7 * 0.3163250,
    );
    path.cubicTo(
      size.width * 0.7250850,
      size.width * 1.7 * 0.3129222,
      size.width * 0.7373800,
      size.width * 1.7 * 0.3071583,
      size.width * 0.7350350,
      size.width * 1.7 * 0.3034222,
    );
    path.cubicTo(
      size.width * 0.7326900,
      size.width * 1.7 * 0.2996861,
      size.width * 0.7165950,
      size.width * 1.7 * 0.2994389,
      size.width * 0.6990750,
      size.width * 1.7 * 0.3028417,
    );
    path.cubicTo(
      size.width * 0.6815550,
      size.width * 1.7 * 0.3062444,
      size.width * 0.6692750,
      size.width * 1.7 * 0.3120222,
      size.width * 0.6716200,
      size.width * 1.7 * 0.3157444,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Antecubital" area (id `front.right_antecubital`) on
/// the front view.
class RightInnerElbow extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3312450, size.width * 1.7 * 0.3165222);
    path.cubicTo(
      size.width * 0.3289000,
      size.width * 1.7 * 0.3202444,
      size.width * 0.3128000,
      size.width * 1.7 * 0.3205056,
      size.width * 0.2952850,
      size.width * 1.7 * 0.3171028,
    );
    path.cubicTo(
      size.width * 0.2777700,
      size.width * 1.7 * 0.3137000,
      size.width * 0.2654700,
      size.width * 1.7 * 0.3079361,
      size.width * 0.2677850,
      size.width * 1.7 * 0.3042000,
    );
    path.cubicTo(
      size.width * 0.2701000,
      size.width * 1.7 * 0.3004639,
      size.width * 0.2862300,
      size.width * 1.7 * 0.3002194,
      size.width * 0.3037450,
      size.width * 1.7 * 0.3036222,
    );
    path.cubicTo(
      size.width * 0.3212600,
      size.width * 1.7 * 0.3070250,
      size.width * 0.3335850,
      size.width * 1.7 * 0.3128111,
      size.width * 0.3312450,
      size.width * 1.7 * 0.3165333,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Anterior Forerarm" area (id
/// `front.left_anterior_forerarm`) on the front view.
class LeftInnerForearm extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.7471900, size.width * 1.7 * 0.3134667);
    path.cubicTo(
      size.width * 0.7471900,
      size.width * 1.7 * 0.3134667,
      size.width * 0.8117400,
      size.width * 1.7 * 0.3908833,
      size.width * 0.8255900,
      size.width * 1.7 * 0.4107167,
    );
    path.cubicTo(
      size.width * 0.8316900,
      size.width * 1.7 * 0.4194667,
      size.width * 0.8368900,
      size.width * 1.7 * 0.4289111,
      size.width * 0.8140400,
      size.width * 1.7 * 0.4356611,
    );
    path.cubicTo(
      size.width * 0.7974400,
      size.width * 1.7 * 0.4405778,
      size.width * 0.7778400,
      size.width * 1.7 * 0.4329667,
      size.width * 0.7678400,
      size.width * 1.7 * 0.4257444,
    );
    path.cubicTo(
      size.width * 0.7434400,
      size.width * 1.7 * 0.4081333,
      size.width * 0.6748400,
      size.width * 1.7 * 0.3310778,
      size.width * 0.6748400,
      size.width * 1.7 * 0.3310778,
    );
    path.cubicTo(
      size.width * 0.6943400,
      size.width * 1.7 * 0.3213000,
      size.width * 0.7188400,
      size.width * 1.7 * 0.3157444,
      size.width * 0.7471900,
      size.width * 1.7 * 0.3134667,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Anterior Forerarm" area (id
/// `front.right_anterior_forerarm`) on the front view.
class RightInnerForearm extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.2530850, size.width * 1.7 * 0.3134667);
    path.cubicTo(
      size.width * 0.2530850,
      size.width * 1.7 * 0.3134667,
      size.width * 0.1885350,
      size.width * 1.7 * 0.3908833,
      size.width * 0.1746850,
      size.width * 1.7 * 0.4107167,
    );
    path.cubicTo(
      size.width * 0.1685850,
      size.width * 1.7 * 0.4194667,
      size.width * 0.1633850,
      size.width * 1.7 * 0.4289111,
      size.width * 0.1862350,
      size.width * 1.7 * 0.4356611,
    );
    path.cubicTo(
      size.width * 0.2028350,
      size.width * 1.7 * 0.4405778,
      size.width * 0.2224350,
      size.width * 1.7 * 0.4329667,
      size.width * 0.2324350,
      size.width * 1.7 * 0.4257444,
    );
    path.cubicTo(
      size.width * 0.2568350,
      size.width * 1.7 * 0.4081333,
      size.width * 0.3254350,
      size.width * 1.7 * 0.3310778,
      size.width * 0.3254350,
      size.width * 1.7 * 0.3310778,
    );
    path.cubicTo(
      size.width * 0.3059350,
      size.width * 1.7 * 0.3213000,
      size.width * 0.2814350,
      size.width * 1.7 * 0.3157444,
      size.width * 0.2530850,
      size.width * 1.7 * 0.3134667,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Palm" area (id `front.left_palm`) on the front view.
class LeftInnerHand extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.8387700, size.width * 1.7 * 0.4339444);
    path.cubicTo(
      size.width * 0.8412700,
      size.width * 1.7 * 0.4331389,
      size.width * 0.8454200,
      size.width * 1.7 * 0.4346389,
      size.width * 0.8465700,
      size.width * 1.7 * 0.4361111,
    );
    path.cubicTo(
      size.width * 0.8481200,
      size.width * 1.7 * 0.4381389,
      size.width * 0.8459700,
      size.width * 1.7 * 0.4438611,
      size.width * 0.8490700,
      size.width * 1.7 * 0.4458056,
    );
    path.cubicTo(
      size.width * 0.8555200,
      size.width * 1.7 * 0.4498611,
      size.width * 0.8760200,
      size.width * 1.7 * 0.4555833,
      size.width * 0.8853700,
      size.width * 1.7 * 0.4604167,
    );
    path.cubicTo(
      size.width * 0.8913700,
      size.width * 1.7 * 0.4635278,
      size.width * 0.8924700,
      size.width * 1.7 * 0.4684444,
      size.width * 0.8924700,
      size.width * 1.7 * 0.4684444,
    );
    path.cubicTo(
      size.width * 0.8924700,
      size.width * 1.7 * 0.4684444,
      size.width * 0.8845200,
      size.width * 1.7 * 0.4769722,
      size.width * 0.8669700,
      size.width * 1.7 * 0.4823611,
    );
    path.cubicTo(
      size.width * 0.8495200,
      size.width * 1.7 * 0.4877222,
      size.width * 0.8267200,
      size.width * 1.7 * 0.4849722,
      size.width * 0.8267200,
      size.width * 1.7 * 0.4849722,
    );
    path.cubicTo(
      size.width * 0.8112700,
      size.width * 1.7 * 0.4779722,
      size.width * 0.8041200,
      size.width * 1.7 * 0.4661944,
      size.width * 0.8008700,
      size.width * 1.7 * 0.4593889,
    );
    path.cubicTo(
      size.width * 0.7983200,
      size.width * 1.7 * 0.4541111,
      size.width * 0.8045700,
      size.width * 1.7 * 0.4471111,
      size.width * 0.8045700,
      size.width * 1.7 * 0.4471111,
    );
    path.cubicTo(
      size.width * 0.8045700,
      size.width * 1.7 * 0.4471111,
      size.width * 0.8319700,
      size.width * 1.7 * 0.4361667,
      size.width * 0.8387700,
      size.width * 1.7 * 0.4339444,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Palm" area (id `front.right_palm`) on the front view.
class RightInnerHand extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.1618200, size.width * 1.7 * 0.4335389);
    path.cubicTo(
      size.width * 0.1593200,
      size.width * 1.7 * 0.4327333,
      size.width * 0.1551700,
      size.width * 1.7 * 0.4342333,
      size.width * 0.1540200,
      size.width * 1.7 * 0.4357056,
    );
    path.cubicTo(
      size.width * 0.1524700,
      size.width * 1.7 * 0.4377333,
      size.width * 0.1546200,
      size.width * 1.7 * 0.4434556,
      size.width * 0.1515200,
      size.width * 1.7 * 0.4454000,
    );
    path.cubicTo(
      size.width * 0.1450700,
      size.width * 1.7 * 0.4494556,
      size.width * 0.1245700,
      size.width * 1.7 * 0.4551778,
      size.width * 0.1152200,
      size.width * 1.7 * 0.4600111,
    );
    path.cubicTo(
      size.width * 0.1092200,
      size.width * 1.7 * 0.4631222,
      size.width * 0.1081200,
      size.width * 1.7 * 0.4680389,
      size.width * 0.1081200,
      size.width * 1.7 * 0.4680389,
    );
    path.cubicTo(
      size.width * 0.1081200,
      size.width * 1.7 * 0.4680389,
      size.width * 0.1160700,
      size.width * 1.7 * 0.4765667,
      size.width * 0.1336200,
      size.width * 1.7 * 0.4819556,
    );
    path.cubicTo(
      size.width * 0.1510700,
      size.width * 1.7 * 0.4873167,
      size.width * 0.1738700,
      size.width * 1.7 * 0.4845667,
      size.width * 0.1738700,
      size.width * 1.7 * 0.4845667,
    );
    path.cubicTo(
      size.width * 0.1893200,
      size.width * 1.7 * 0.4775667,
      size.width * 0.1964700,
      size.width * 1.7 * 0.4657889,
      size.width * 0.1997200,
      size.width * 1.7 * 0.4589833,
    );
    path.cubicTo(
      size.width * 0.2022700,
      size.width * 1.7 * 0.4537056,
      size.width * 0.1960200,
      size.width * 1.7 * 0.4467056,
      size.width * 0.1960200,
      size.width * 1.7 * 0.4467056,
    );
    path.cubicTo(
      size.width * 0.1960200,
      size.width * 1.7 * 0.4467056,
      size.width * 0.1686200,
      size.width * 1.7 * 0.4357611,
      size.width * 0.1618200,
      size.width * 1.7 * 0.4335389,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Thumb" area (id `front.left_thumb`) on the front view.
class LeftThumb extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.8599800, size.width * 1.7 * 0.4318889);
    path.cubicTo(
      size.width * 0.8565300,
      size.width * 1.7 * 0.4315833,
      size.width * 0.8520300,
      size.width * 1.7 * 0.4333333,
      size.width * 0.8513800,
      size.width * 1.7 * 0.4352500,
    );
    path.cubicTo(
      size.width * 0.8506300,
      size.width * 1.7 * 0.4373333,
      size.width * 0.8523300,
      size.width * 1.7 * 0.4418333,
      size.width * 0.8555800,
      size.width * 1.7 * 0.4444722,
    );
    path.cubicTo(
      size.width * 0.8588800,
      size.width * 1.7 * 0.4471667,
      size.width * 0.8666300,
      size.width * 1.7 * 0.4499722,
      size.width * 0.8711300,
      size.width * 1.7 * 0.4513611,
    );
    path.cubicTo(
      size.width * 0.8745800,
      size.width * 1.7 * 0.4524167,
      size.width * 0.8790300,
      size.width * 1.7 * 0.4519444,
      size.width * 0.8826300,
      size.width * 1.7 * 0.4528056,
    );
    path.cubicTo(
      size.width * 0.8870800,
      size.width * 1.7 * 0.4538611,
      size.width * 0.8921300,
      size.width * 1.7 * 0.4568333,
      size.width * 0.8977300,
      size.width * 1.7 * 0.4576944,
    );
    path.cubicTo(
      size.width * 0.9041800,
      size.width * 1.7 * 0.4586667,
      size.width * 0.9170800,
      size.width * 1.7 * 0.4595278,
      size.width * 0.9213800,
      size.width * 1.7 * 0.4586944,
    );
    path.cubicTo(
      size.width * 0.9247800,
      size.width * 1.7 * 0.4580556,
      size.width * 0.9258300,
      size.width * 1.7 * 0.4543333,
      size.width * 0.9235300,
      size.width * 1.7 * 0.4527778,
    );
    path.cubicTo(
      size.width * 0.9201800,
      size.width * 1.7 * 0.4505556,
      size.width * 0.9068300,
      size.width * 1.7 * 0.4477222,
      size.width * 0.9013800,
      size.width * 1.7 * 0.4453889,
    );
    path.cubicTo(
      size.width * 0.8971300,
      size.width * 1.7 * 0.4435556,
      size.width * 0.8953300,
      size.width * 1.7 * 0.4401944,
      size.width * 0.8906800,
      size.width * 1.7 * 0.4386944,
    );
    path.cubicTo(
      size.width * 0.8837800,
      size.width * 1.7 * 0.4364444,
      size.width * 0.8665300,
      size.width * 1.7 * 0.4324722,
      size.width * 0.8600000,
      size.width * 1.7 * 0.4318889,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Thumb" area (id `front.right_thumb`) on the front
/// view.
class RightThumb extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.1400500, size.width * 1.7 * 0.4318889);
    path.cubicTo(
      size.width * 0.1435000,
      size.width * 1.7 * 0.4315833,
      size.width * 0.1480000,
      size.width * 1.7 * 0.4333333,
      size.width * 0.1486500,
      size.width * 1.7 * 0.4352500,
    );
    path.cubicTo(
      size.width * 0.1494000,
      size.width * 1.7 * 0.4373333,
      size.width * 0.1477000,
      size.width * 1.7 * 0.4418333,
      size.width * 0.1444500,
      size.width * 1.7 * 0.4444722,
    );
    path.cubicTo(
      size.width * 0.1411500,
      size.width * 1.7 * 0.4471667,
      size.width * 0.1334000,
      size.width * 1.7 * 0.4499722,
      size.width * 0.1289000,
      size.width * 1.7 * 0.4513611,
    );
    path.cubicTo(
      size.width * 0.1254500,
      size.width * 1.7 * 0.4524167,
      size.width * 0.1210000,
      size.width * 1.7 * 0.4519444,
      size.width * 0.1174000,
      size.width * 1.7 * 0.4528056,
    );
    path.cubicTo(
      size.width * 0.1129500,
      size.width * 1.7 * 0.4538611,
      size.width * 0.1079000,
      size.width * 1.7 * 0.4568333,
      size.width * 0.1023000,
      size.width * 1.7 * 0.4576944,
    );
    path.cubicTo(
      size.width * 0.09585000,
      size.width * 1.7 * 0.4586667,
      size.width * 0.08295000,
      size.width * 1.7 * 0.4595278,
      size.width * 0.07865000,
      size.width * 1.7 * 0.4586944,
    );
    path.cubicTo(
      size.width * 0.07525000,
      size.width * 1.7 * 0.4580556,
      size.width * 0.07420000,
      size.width * 1.7 * 0.4543333,
      size.width * 0.07650000,
      size.width * 1.7 * 0.4527778,
    );
    path.cubicTo(
      size.width * 0.07985000,
      size.width * 1.7 * 0.4505556,
      size.width * 0.09320000,
      size.width * 1.7 * 0.4477222,
      size.width * 0.09865000,
      size.width * 1.7 * 0.4453889,
    );
    path.cubicTo(
      size.width * 0.1029000,
      size.width * 1.7 * 0.4435556,
      size.width * 0.1047000,
      size.width * 1.7 * 0.4401944,
      size.width * 0.1093500,
      size.width * 1.7 * 0.4386944,
    );
    path.cubicTo(
      size.width * 0.1162500,
      size.width * 1.7 * 0.4364444,
      size.width * 0.1335000,
      size.width * 1.7 * 0.4324722,
      size.width * 0.1400500,
      size.width * 1.7 * 0.4318889,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left Index Finger" (id `front.left_index_finger`) on the
/// front view.
///
/// Drawn as a ring beside the hand, because the real finger is too small
/// to tap.
class LeftPointerFinger extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.8992550, size.width * 1.7 * 0.6057194);
    path.arcToPoint(
      Offset(size.width * 0.9234500, size.width * 1.7 * 0.6191583),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.8992550, size.width * 1.7 * 0.6057028),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right Index Finger" (id `front.right_index_finger`) on
/// the front view.
///
/// Drawn as a ring beside the hand, because the real finger is too small
/// to tap.
class RightPointerFinger extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.1027550, size.width * 1.7 * 0.6057194);
    path.arcToPoint(
      Offset(size.width * 0.07856000, size.width * 1.7 * 0.6191583),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.1027750, size.width * 1.7 * 0.6057028),
      radius: Radius.elliptical(
        size.width * 0.02419000,
        size.width * 1.7 * 0.01343889,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left Middle Finger" (id `front.left_middle_finger`) on
/// the front view.
///
/// Drawn as a ring beside the hand, because the real finger is too small
/// to tap.
class LeftMiddleFinger extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.8586200, size.width * 1.7 * 0.5792194);
    path.arcToPoint(
      Offset(size.width * 0.8828150, size.width * 1.7 * 0.5926611),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.8586200, size.width * 1.7 * 0.5792028),
      radius: Radius.elliptical(
        size.width * 0.02419000,
        size.width * 1.7 * 0.01343889,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right Middle Finger" (id `front.right_middle_finger`) on
/// the front view.
///
/// Drawn as a ring beside the hand, because the real finger is too small
/// to tap.
class RightMiddleFinger extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.1434050, size.width * 1.7 * 0.5792194);
    path.arcToPoint(
      Offset(size.width * 0.1192150, size.width * 1.7 * 0.5926611),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.1434050, size.width * 1.7 * 0.5792028),
      radius: Radius.elliptical(
        size.width * 0.02419000,
        size.width * 1.7 * 0.01343889,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right Ring Finger" (id `front.right_ring_finger`) on the
/// front view.
///
/// Drawn as a ring beside the hand, because the real finger is too small
/// to tap.
class RightRingFinger extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.1854350, size.width * 1.7 * 0.5526639);
    path.arcToPoint(
      Offset(size.width * 0.1612400, size.width * 1.7 * 0.5661111),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.1854350, size.width * 1.7 * 0.5526639),
      radius: Radius.elliptical(
        size.width * 0.02420000,
        size.width * 1.7 * 0.01344444,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left Ring Finger" (id `front.left_ring_finger`) on the
/// front view.
///
/// Drawn as a ring beside the hand, because the real finger is too small
/// to tap.
class LeftRingFinger extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.8165900, size.width * 1.7 * 0.5526639);
    path.arcToPoint(
      Offset(size.width * 0.8407850, size.width * 1.7 * 0.5661056),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.8165900, size.width * 1.7 * 0.5526639),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Left Pinky" (id `front.left_pinky`) on the front view.
///
/// Drawn as a ring beside the hand, because the real finger is too small
/// to tap.
class LeftPinky extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.7771100, size.width * 1.7 * 0.5253611);
    path.arcToPoint(
      Offset(size.width * 0.8013050, size.width * 1.7 * 0.5388000),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.7771100, size.width * 1.7 * 0.5253611),
      radius: Radius.elliptical(
        size.width * 0.02419000,
        size.width * 1.7 * 0.01343889,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Right Pinky" (id `front.right_pinky`) on the front view.
///
/// Drawn as a ring beside the hand, because the real finger is too small
/// to tap.
class RightPinky extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.2249150, size.width * 1.7 * 0.5253611);
    path.arcToPoint(
      Offset(size.width * 0.2007200, size.width * 1.7 * 0.5388000),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width * 0.2249150, size.width * 1.7 * 0.5253611),
      radius: Radius.elliptical(
        size.width * 0.02419500,
        size.width * 1.7 * 0.01344167,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Seam lines on the front view, painted in the background colour so they
/// look like gaps: the lines between parts of the head and the stems that
/// reach out to the finger and toe selectors. Decorative, never tapped.
class Lines extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.08113500, size.width * 1.7 * 0.5750000);
    path.lineTo(size.width * 0.08303500, size.width * 1.7 * 0.5147472);
    path.lineTo(size.width * 0.08640000, size.width * 1.7 * 0.5147806);
    path.lineTo(size.width * 0.08450000, size.width * 1.7 * 0.5750417);
    path.moveTo(size.width * 0.09234000, size.width * 1.7 * 0.6042778);
    path.lineTo(size.width * 0.08113500, size.width * 1.7 * 0.5750000);
    path.lineTo(size.width * 0.08443000, size.width * 1.7 * 0.5746111);
    path.lineTo(size.width * 0.09563000, size.width * 1.7 * 0.6038889);
    path.moveTo(size.width * 0.09942500, size.width * 1.7 * 0.5623333);
    path.lineTo(size.width * 0.09687000, size.width * 1.7 * 0.5216667);
    path.lineTo(size.width * 0.1002400, size.width * 1.7 * 0.5216028);
    path.lineTo(size.width * 0.1027950, size.width * 1.7 * 0.5622722);
    path.moveTo(size.width * 0.1198100, size.width * 1.7 * 0.5773611);
    path.lineTo(size.width * 0.09942500, size.width * 1.7 * 0.5623306);
    path.lineTo(size.width * 0.1021150, size.width * 1.7 * 0.5612056);
    path.lineTo(size.width * 0.1225000, size.width * 1.7 * 0.5762361);
    path.moveTo(size.width * 0.1148100, size.width * 1.7 * 0.5439000);
    path.lineTo(size.width * 0.1132500, size.width * 1.7 * 0.5190750);
    path.lineTo(size.width * 0.1166150, size.width * 1.7 * 0.5190111);
    path.lineTo(size.width * 0.1181750, size.width * 1.7 * 0.5438333);
    path.moveTo(size.width * 0.1518650, size.width * 1.7 * 0.5572694);
    path.lineTo(size.width * 0.1148100, size.width * 1.7 * 0.5438889);
    path.lineTo(size.width * 0.1166450, size.width * 1.7 * 0.5423194);
    path.lineTo(size.width * 0.1537000, size.width * 1.7 * 0.5556889);
    path.moveTo(size.width * 0.1890750, size.width * 1.7 * 0.5379167);
    path.lineTo(size.width * 0.1362700, size.width * 1.7 * 0.5281167);
    path.lineTo(size.width * 0.1373200, size.width * 1.7 * 0.5262750);
    path.lineTo(size.width * 0.1901200, size.width * 1.7 * 0.5360750);
    path.moveTo(size.width * 0.1361600, size.width * 1.7 * 0.5281028);
    path.lineTo(size.width * 0.1351950, size.width * 1.7 * 0.5127389);
    path.lineTo(size.width * 0.1385600, size.width * 1.7 * 0.5126750);
    path.lineTo(size.width * 0.1395250, size.width * 1.7 * 0.5280389);
    path.moveTo(size.width * 0.8090000, size.width * 1.7 * 0.5359278);
    path.lineTo(size.width * 0.8618000, size.width * 1.7 * 0.5261250);
    path.lineTo(size.width * 0.8628450, size.width * 1.7 * 0.5279694);
    path.lineTo(size.width * 0.8100550, size.width * 1.7 * 0.5377778);
    path.moveTo(size.width * 0.8595950, size.width * 1.7 * 0.5278917);
    path.lineTo(size.width * 0.8605600, size.width * 1.7 * 0.5125278);
    path.lineTo(size.width * 0.8639250, size.width * 1.7 * 0.5125917);
    path.lineTo(size.width * 0.8629600, size.width * 1.7 * 0.5279556);
    path.moveTo(size.width * 0.8809600, size.width * 1.7 * 0.5436861);
    path.lineTo(size.width * 0.8825200, size.width * 1.7 * 0.5188639);
    path.lineTo(size.width * 0.8858850, size.width * 1.7 * 0.5189278);
    path.lineTo(size.width * 0.8843250, size.width * 1.7 * 0.5437528);
    path.moveTo(size.width * 0.8454300, size.width * 1.7 * 0.5555556);
    path.lineTo(size.width * 0.8824850, size.width * 1.7 * 0.5421861);
    path.lineTo(size.width * 0.8843200, size.width * 1.7 * 0.5437556);
    path.lineTo(size.width * 0.8472650, size.width * 1.7 * 0.5571250);
    path.moveTo(size.width * 0.8963400, size.width * 1.7 * 0.5621194);
    path.lineTo(size.width * 0.8988950, size.width * 1.7 * 0.5214500);
    path.lineTo(size.width * 0.9022600, size.width * 1.7 * 0.5215139);
    path.lineTo(size.width * 0.8997050, size.width * 1.7 * 0.5621833);
    path.moveTo(size.width * 0.8766350, size.width * 1.7 * 0.5760861);
    path.lineTo(size.width * 0.8970200, size.width * 1.7 * 0.5610583);
    path.lineTo(size.width * 0.8997050, size.width * 1.7 * 0.5621694);
    path.lineTo(size.width * 0.8793200, size.width * 1.7 * 0.5772222);
    path.moveTo(size.width * 0.9145950, size.width * 1.7 * 0.5748944);
    path.lineTo(size.width * 0.9127000, size.width * 1.7 * 0.5146417);
    path.lineTo(size.width * 0.9160650, size.width * 1.7 * 0.5146111);
    path.lineTo(size.width * 0.9179600, size.width * 1.7 * 0.5748611);
    path.moveTo(size.width * 0.9035000, size.width * 1.7 * 0.6037500);
    path.lineTo(size.width * 0.9147050, size.width * 1.7 * 0.5744722);
    path.lineTo(size.width * 0.9179950, size.width * 1.7 * 0.5748611);
    path.lineTo(size.width * 0.9067950, size.width * 1.7 * 0.6041389);
    path.moveTo(size.width * 0.7642050, size.width * 1.7 * 0.9453167);
    path.lineTo(size.width * 0.6408400, size.width * 1.7 * 0.9190139);
    path.lineTo(size.width * 0.6420500, size.width * 1.7 * 0.9172667);
    path.lineTo(size.width * 0.7654100, size.width * 1.7 * 0.9435694);
    path.moveTo(size.width * 0.7218600, size.width * 1.7 * 0.9629889);
    path.lineTo(size.width * 0.6270650, size.width * 1.7 * 0.9218472);
    path.lineTo(size.width * 0.6291400, size.width * 1.7 * 0.9203722);
    path.lineTo(size.width * 0.7239350, size.width * 1.7 * 0.9615139);
    path.moveTo(size.width * 0.6699050, size.width * 1.7 * 0.9699556);
    path.lineTo(size.width * 0.6136700, size.width * 1.7 * 0.9218556);
    path.lineTo(size.width * 0.6165000, size.width * 1.7 * 0.9208333);
    path.lineTo(size.width * 0.6727350, size.width * 1.7 * 0.9689333);
    path.moveTo(size.width * 0.6187800, size.width * 1.7 * 0.9676028);
    path.lineTo(size.width * 0.6002350, size.width * 1.7 * 0.9229833);
    path.lineTo(size.width * 0.6035150, size.width * 1.7 * 0.9225611);
    path.lineTo(size.width * 0.6220600, size.width * 1.7 * 0.9671806);
    path.moveTo(size.width * 0.5695600, size.width * 1.7 * 0.9603472);
    path.lineTo(size.width * 0.5774250, size.width * 1.7 * 0.9247528);
    path.lineTo(size.width * 0.5807650, size.width * 1.7 * 0.9249806);
    path.lineTo(size.width * 0.5729000, size.width * 1.7 * 0.9605750);
    path.moveTo(size.width * 0.2335400, size.width * 1.7 * 0.9423889);
    path.lineTo(size.width * 0.3569000, size.width * 1.7 * 0.9160861);
    path.lineTo(size.width * 0.3581050, size.width * 1.7 * 0.9178333);
    path.lineTo(size.width * 0.2347450, size.width * 1.7 * 0.9441361);
    path.moveTo(size.width * 0.2750000, size.width * 1.7 * 0.9603333);
    path.lineTo(size.width * 0.3697950, size.width * 1.7 * 0.9191917);
    path.lineTo(size.width * 0.3718700, size.width * 1.7 * 0.9206667);
    path.lineTo(size.width * 0.2770900, size.width * 1.7 * 0.9618083);
    path.moveTo(size.width * 0.3262050, size.width * 1.7 * 0.9677583);
    path.lineTo(size.width * 0.3824400, size.width * 1.7 * 0.9196556);
    path.lineTo(size.width * 0.3852650, size.width * 1.7 * 0.9206750);
    path.lineTo(size.width * 0.3290450, size.width * 1.7 * 0.9687750);
    path.moveTo(size.width * 0.3768750, size.width * 1.7 * 0.9660000);
    path.lineTo(size.width * 0.3954350, size.width * 1.7 * 0.9213889);
    path.lineTo(size.width * 0.3987150, size.width * 1.7 * 0.9218111);
    path.lineTo(size.width * 0.3801700, size.width * 1.7 * 0.9664306);
    path.moveTo(size.width * 0.4260350, size.width * 1.7 * 0.9593944);
    path.lineTo(size.width * 0.4181700, size.width * 1.7 * 0.9238000);
    path.lineTo(size.width * 0.4215100, size.width * 1.7 * 0.9235722);
    path.lineTo(size.width * 0.4293900, size.width * 1.7 * 0.9591667);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

// These shouldnt ever be highlighted
/// Finger shapes on the front view that are painted in skin colour but are
/// never tapped or highlighted. Fingers are picked through their ring
/// selectors instead (the regions with `ring: true` in `body_map.dart`).
class UntappableFingers extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.1051300, size.width * 1.7 * 0.4731472);
    path.cubicTo(
      size.width * 0.1051300,
      size.width * 1.7 * 0.4731472,
      size.width * 0.08602000,
      size.width * 1.7 * 0.4994667,
      size.width * 0.08313000,
      size.width * 1.7 * 0.5056472,
    );
    path.cubicTo(
      size.width * 0.08231500,
      size.width * 1.7 * 0.5073528,
      size.width * 0.08597500,
      size.width * 1.7 * 0.5117583,
      size.width * 0.08777500,
      size.width * 1.7 * 0.5103000,
    );
    path.cubicTo(
      size.width * 0.09327500,
      size.width * 1.7 * 0.5058833,
      size.width * 0.1161650,
      size.width * 1.7 * 0.4791389,
      size.width * 0.1161650,
      size.width * 1.7 * 0.4791389,
    );

    path.moveTo(size.width * 0.09863000, size.width * 1.7 * 0.5183083);
    path.cubicTo(
      size.width * 0.1051300,
      size.width * 1.7 * 0.5127972,
      size.width * 0.1312900,
      size.width * 1.7 * 0.4854000,
      size.width * 0.1312900,
      size.width * 1.7 * 0.4854000,
    );
    path.lineTo(size.width * 0.1192900, size.width * 1.7 * 0.4803444);
    path.cubicTo(
      size.width * 0.1192900,
      size.width * 1.7 * 0.4803444,
      size.width * 0.09558000,
      size.width * 1.7 * 0.5072889,
      size.width * 0.09110500,
      size.width * 1.7 * 0.5136500,
    );
    path.cubicTo(
      size.width * 0.09005500,
      size.width * 1.7 * 0.5151278,
      size.width * 0.09110500,
      size.width * 1.7 * 0.5176250,
      size.width * 0.09234000,
      size.width * 1.7 * 0.5184000,
    );
    path.cubicTo(
      size.width * 0.09357500,
      size.width * 1.7 * 0.5191750,
      size.width * 0.09746000,
      size.width * 1.7 * 0.5192694,
      size.width * 0.09862500,
      size.width * 1.7 * 0.5182944,
    );

    path.moveTo(size.width * 0.1471800, size.width * 1.7 * 0.4879083);
    path.lineTo(size.width * 0.1345000, size.width * 1.7 * 0.4863889);
    path.cubicTo(
      size.width * 0.1345000,
      size.width * 1.7 * 0.4863889,
      size.width * 0.1098800,
      size.width * 1.7 * 0.5097889,
      size.width * 0.1069100,
      size.width * 1.7 * 0.5145361,
    );
    path.cubicTo(
      size.width * 0.1058450,
      size.width * 1.7 * 0.5162389,
      size.width * 0.1136500,
      size.width * 1.7 * 0.5154806,
      size.width * 0.1166950,
      size.width * 1.7 * 0.5148472,
    );
    path.cubicTo(
      size.width * 0.1198400,
      size.width * 1.7 * 0.5142194,
      size.width * 0.1236050,
      size.width * 1.7 * 0.5125167,
      size.width * 0.1256950,
      size.width * 1.7 * 0.5106806,
    );
    path.cubicTo(
      size.width * 0.1307550,
      size.width * 1.7 * 0.5061667,
      size.width * 0.1471800,
      size.width * 1.7 * 0.4879083,
      size.width * 0.1471800,
      size.width * 1.7 * 0.4879083,
    );

    path.moveTo(size.width * 0.1679750, size.width * 1.7 * 0.4881861);
    path.lineTo(size.width * 0.1503400, size.width * 1.7 * 0.4877778);
    path.cubicTo(
      size.width * 0.1503400,
      size.width * 1.7 * 0.4877778,
      size.width * 0.1315400,
      size.width * 1.7 * 0.5056000,
      size.width * 0.1301450,
      size.width * 1.7 * 0.5092667,
    );
    path.cubicTo(
      size.width * 0.1293050,
      size.width * 1.7 * 0.5113917,
      size.width * 0.1390700,
      size.width * 1.7 * 0.5112861,
      size.width * 0.1418200,
      size.width * 1.7 * 0.5097583,
    );
    path.cubicTo(
      size.width * 0.1481650,
      size.width * 1.7 * 0.5061917,
      size.width * 0.1680000,
      size.width * 1.7 * 0.4881694,
      size.width * 0.1680000,
      size.width * 1.7 * 0.4881694,
    );

    path.moveTo(size.width * 0.8322550, size.width * 1.7 * 0.4881722);
    path.lineTo(size.width * 0.8498900, size.width * 1.7 * 0.4877833);

    path.cubicTo(
      size.width * 0.8498900,
      size.width * 1.7 * 0.4877833,
      size.width * 0.8686900,
      size.width * 1.7 * 0.5056028,
      size.width * 0.8700850,
      size.width * 1.7 * 0.5092722,
    );
    path.cubicTo(
      size.width * 0.8709250,
      size.width * 1.7 * 0.5113944,
      size.width * 0.8611650,
      size.width * 1.7 * 0.5112889,
      size.width * 0.8584100,
      size.width * 1.7 * 0.5097611,
    );
    path.cubicTo(
      size.width * 0.8521200,
      size.width * 1.7 * 0.5062056,
      size.width * 0.8322550,
      size.width * 1.7 * 0.4881556,
      size.width * 0.8322550,
      size.width * 1.7 * 0.4881556,
    );

    path.moveTo(size.width * 0.8531050, size.width * 1.7 * 0.4879083);
    path.lineTo(size.width * 0.8657600, size.width * 1.7 * 0.4863972);
    path.cubicTo(
      size.width * 0.8657600,
      size.width * 1.7 * 0.4863972,
      size.width * 0.8903850,
      size.width * 1.7 * 0.5097972,
      size.width * 0.8933500,
      size.width * 1.7 * 0.5145444,
    );
    path.cubicTo(
      size.width * 0.8944150,
      size.width * 1.7 * 0.5162472,
      size.width * 0.8866100,
      size.width * 1.7 * 0.5154889,
      size.width * 0.8835650,
      size.width * 1.7 * 0.5148556,
    );
    path.cubicTo(
      size.width * 0.8804200,
      size.width * 1.7 * 0.5142278,
      size.width * 0.8766550,
      size.width * 1.7 * 0.5125250,
      size.width * 0.8745650,
      size.width * 1.7 * 0.5106889,
    );
    path.cubicTo(
      size.width * 0.8695300,
      size.width * 1.7 * 0.5061806,
      size.width * 0.8531050,
      size.width * 1.7 * 0.4878944,
      size.width * 0.8531050,
      size.width * 1.7 * 0.4878944,
    );

    path.moveTo(size.width * 0.9016300, size.width * 1.7 * 0.5183222);
    path.cubicTo(
      size.width * 0.8951300,
      size.width * 1.7 * 0.5128139,
      size.width * 0.8689700,
      size.width * 1.7 * 0.4854139,
      size.width * 0.8689700,
      size.width * 1.7 * 0.4854139,
    );
    path.lineTo(size.width * 0.8809700, size.width * 1.7 * 0.4803583);
    path.cubicTo(
      size.width * 0.8809700,
      size.width * 1.7 * 0.4803583,
      size.width * 0.9046800,
      size.width * 1.7 * 0.5073028,
      size.width * 0.9091550,
      size.width * 1.7 * 0.5136639,
    );
    path.cubicTo(
      size.width * 0.9102050,
      size.width * 1.7 * 0.5151444,
      size.width * 0.9091550,
      size.width * 1.7 * 0.5176389,
      size.width * 0.9079200,
      size.width * 1.7 * 0.5184139,
    );
    path.cubicTo(
      size.width * 0.9066850,
      size.width * 1.7 * 0.5191889,
      size.width * 0.9027750,
      size.width * 1.7 * 0.5192861,
      size.width * 0.9016100,
      size.width * 1.7 * 0.5183083,
    );

    path.moveTo(size.width * 0.8951300, size.width * 1.7 * 0.4731472);
    path.cubicTo(
      size.width * 0.8951300,
      size.width * 1.7 * 0.4731472,
      size.width * 0.9142450,
      size.width * 1.7 * 0.4994667,
      size.width * 0.9171300,
      size.width * 1.7 * 0.5056472,
    );
    path.cubicTo(
      size.width * 0.9179450,
      size.width * 1.7 * 0.5073528,
      size.width * 0.9142850,
      size.width * 1.7 * 0.5117583,
      size.width * 0.9124850,
      size.width * 1.7 * 0.5103000,
    );
    path.cubicTo(
      size.width * 0.9069850,
      size.width * 1.7 * 0.5058833,
      size.width * 0.8840950,
      size.width * 1.7 * 0.4791389,
      size.width * 0.8840950,
      size.width * 1.7 * 0.4791389,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
