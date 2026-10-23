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
/// This file holds the back view of the figure; `front_paths.dart` holds the
/// front. Each class below is one region. Only its `getClip` method is
/// used: the picker calls it to paint the region and to test whether a tap
/// landed inside it. None of these are used as real clippers on a widget.
library;

import 'package:flutter/material.dart';

// https://fluttershapemaker.com/ to generate paths from an SVG file
// To keep the aspect ratio the same on all shapes, every size.height has been
// replaced with size.width * 1.7.
/// Outline of the "Left Shoulder Blade" area (id `back.left_shoulder_blade`) on
/// the back view.
class LeftShoulder extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3062650, size.width * 1.7 * 0.1943278);
    path.cubicTo(
      size.width * 0.3094050,
      size.width * 1.7 * 0.2092278,
      size.width * 0.3169450,
      size.width * 1.7 * 0.2315500,
      size.width * 0.3308850,
      size.width * 1.7 * 0.2394722,
    );
    path.cubicTo(
      size.width * 0.3532750,
      size.width * 1.7 * 0.2521889,
      size.width * 0.4620200,
      size.width * 1.7 * 0.2479694,
      size.width * 0.4620200,
      size.width * 1.7 * 0.2479694,
    );
    path.arcToPoint(
      Offset(size.width * 0.4748900, size.width * 1.7 * 0.2352778),
      radius: Radius.elliptical(
        size.width * 0.02613000,
        size.width * 1.7 * 0.01451667,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.cubicTo(
      size.width * 0.4744200,
      size.width * 1.7 * 0.2111917,
      size.width * 0.4753900,
      size.width * 1.7 * 0.1746833,
      size.width * 0.4746900,
      size.width * 1.7 * 0.1677167,
    );
    path.cubicTo(
      size.width * 0.4163750,
      size.width * 1.7 * 0.1676194,
      size.width * 0.3578100,
      size.width * 1.7 * 0.1800472,
      size.width * 0.3062700,
      size.width * 1.7 * 0.1943278,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Hamstring" area (id `back.right_hamstring`) on the
/// back view.
class RightHamstring extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.6784150, size.width * 1.7 * 0.5870583);
    path.cubicTo(
      size.width * 0.6806600,
      size.width * 1.7 * 0.5724917,
      size.width * 0.6794700,
      size.width * 1.7 * 0.5348361,
      size.width * 0.6794700,
      size.width * 1.7 * 0.5348361,
    );
    path.cubicTo(
      size.width * 0.6404700,
      size.width * 1.7 * 0.5483111,
      size.width * 0.5988450,
      size.width * 1.7 * 0.5578583,
      size.width * 0.5491500,
      size.width * 1.7 * 0.5574472,
    );
    path.cubicTo(
      size.width * 0.5390000,
      size.width * 1.7 * 0.5573667,
      size.width * 0.5162500,
      size.width * 1.7 * 0.5511167,
      size.width * 0.5065950,
      size.width * 1.7 * 0.5504250,
    );
    path.cubicTo(
      size.width * 0.5006900,
      size.width * 1.7 * 0.6144500,
      size.width * 0.5398700,
      size.width * 1.7 * 0.7325861,
      size.width * 0.5429350,
      size.width * 1.7 * 0.7350278,
    );
    path.cubicTo(
      size.width * 0.5707650,
      size.width * 1.7 * 0.7406194,
      size.width * 0.6253650,
      size.width * 1.7 * 0.7390972,
      size.width * 0.6500050,
      size.width * 1.7 * 0.7332667,
    );
    path.cubicTo(
      size.width * 0.6602050,
      size.width * 1.7 * 0.6870333,
      size.width * 0.6732350,
      size.width * 1.7 * 0.6205556,
      size.width * 0.6783950,
      size.width * 1.7 * 0.5870583,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Shoulder Blade" area (id `back.right_shoulder_blade`)
/// on the back view.
class RightShoulder extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.6937650, size.width * 1.7 * 0.1943278);
    path.cubicTo(
      size.width * 0.6906250,
      size.width * 1.7 * 0.2092278,
      size.width * 0.6830850,
      size.width * 1.7 * 0.2315500,
      size.width * 0.6691450,
      size.width * 1.7 * 0.2394722,
    );
    path.cubicTo(
      size.width * 0.6467550,
      size.width * 1.7 * 0.2521889,
      size.width * 0.5380000,
      size.width * 1.7 * 0.2479694,
      size.width * 0.5380000,
      size.width * 1.7 * 0.2479694,
    );
    path.arcToPoint(
      Offset(size.width * 0.5251400, size.width * 1.7 * 0.2352778),
      radius: Radius.elliptical(
        size.width * 0.02614500,
        size.width * 1.7 * 0.01452500,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.5256400,
      size.width * 1.7 * 0.2111917,
      size.width * 0.5246400,
      size.width * 1.7 * 0.1746833,
      size.width * 0.5253450,
      size.width * 1.7 * 0.1677167,
    );
    path.cubicTo(
      size.width * 0.5836600,
      size.width * 1.7 * 0.1676194,
      size.width * 0.6422250,
      size.width * 1.7 * 0.1800472,
      size.width * 0.6937650,
      size.width * 1.7 * 0.1943278,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Buttock" area (id `back.left_buttock`) on the back
/// view.
class LeftGlute extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.3489600, size.width * 1.7 * 0.4244444);
    path.cubicTo(
      size.width * 0.3320200,
      size.width * 1.7 * 0.4544444,
      size.width * 0.3252950,
      size.width * 1.7 * 0.4867806,
      size.width * 0.3257300,
      size.width * 1.7 * 0.5216250,
    );
    path.cubicTo(
      size.width * 0.3257300,
      size.width * 1.7 * 0.5216250,
      size.width * 0.3365600,
      size.width * 1.7 * 0.5299083,
      size.width * 0.3647300,
      size.width * 1.7 * 0.5375056,
    );
    path.cubicTo(
      size.width * 0.3902300,
      size.width * 1.7 * 0.5443889,
      size.width * 0.4176350,
      size.width * 1.7 * 0.5506444,
      size.width * 0.4412700,
      size.width * 1.7 * 0.5512000,
    );
    path.cubicTo(
      size.width * 0.4600950,
      size.width * 1.7 * 0.5516472,
      size.width * 0.4731550,
      size.width * 1.7 * 0.5492278,
      size.width * 0.4818650,
      size.width * 1.7 * 0.5469278,
    );
    path.cubicTo(
      size.width * 0.4878050,
      size.width * 1.7 * 0.5453583,
      size.width * 0.4960000,
      size.width * 1.7 * 0.5390944,
      size.width * 0.4966100,
      size.width * 1.7 * 0.5355000,
    );
    path.cubicTo(
      size.width * 0.4987850,
      size.width * 1.7 * 0.5227222,
      size.width * 0.4972600,
      size.width * 1.7 * 0.4687028,
      size.width * 0.4972600,
      size.width * 1.7 * 0.4687028,
    );
    path.lineTo(size.width * 0.4606250, size.width * 1.7 * 0.4673139);
    path.arcToPoint(
      Offset(size.width * 0.4237750, size.width * 1.7 * 0.4503972),
      radius: Radius.elliptical(
        size.width * 0.04097000,
        size.width * 1.7 * 0.02276111,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.4178450,
      size.width * 1.7 * 0.4378583,
      size.width * 0.4105450,
      size.width * 1.7 * 0.4224306,
      size.width * 0.4105450,
      size.width * 1.7 * 0.4224306,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Buttock" area (id `back.right_buttock`) on the back
/// view.
class RightGlute extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5958250, size.width * 1.7 * 0.4224417);
    path.cubicTo(
      size.width * 0.5958250,
      size.width * 1.7 * 0.4224417,
      size.width * 0.5885300,
      size.width * 1.7 * 0.4378694,
      size.width * 0.5825950,
      size.width * 1.7 * 0.4504083,
    );
    path.arcToPoint(
      Offset(size.width * 0.5457500, size.width * 1.7 * 0.4673250),
      radius: Radius.elliptical(
        size.width * 0.04096000,
        size.width * 1.7 * 0.02275556,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.lineTo(size.width * 0.5091150, size.width * 1.7 * 0.4687139);
    path.cubicTo(
      size.width * 0.5091150,
      size.width * 1.7 * 0.4687139,
      size.width * 0.5075850,
      size.width * 1.7 * 0.5227389,
      size.width * 0.5097600,
      size.width * 1.7 * 0.5355111,
    );
    path.cubicTo(
      size.width * 0.5103750,
      size.width * 1.7 * 0.5391056,
      size.width * 0.5185700,
      size.width * 1.7 * 0.5453694,
      size.width * 0.5245050,
      size.width * 1.7 * 0.5469389,
    );
    path.cubicTo(
      size.width * 0.5332150,
      size.width * 1.7 * 0.5492389,
      size.width * 0.5462750,
      size.width * 1.7 * 0.5516611,
      size.width * 0.5651000,
      size.width * 1.7 * 0.5512111,
    );
    path.cubicTo(
      size.width * 0.5887350,
      size.width * 1.7 * 0.5506556,
      size.width * 0.6161350,
      size.width * 1.7 * 0.5444000,
      size.width * 0.6416400,
      size.width * 1.7 * 0.5375167,
    );
    path.cubicTo(
      size.width * 0.6697950,
      size.width * 1.7 * 0.5299194,
      size.width * 0.6806400,
      size.width * 1.7 * 0.5216361,
      size.width * 0.6806400,
      size.width * 1.7 * 0.5216361,
    );
    path.cubicTo(
      size.width * 0.6810750,
      size.width * 1.7 * 0.4867917,
      size.width * 0.6743550,
      size.width * 1.7 * 0.4544639,
      size.width * 0.6574150,
      size.width * 1.7 * 0.4244556,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Popliteal" area (id `back.left_popliteal`) on the back
/// view.
class LeftBackKnee extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3548650, size.width * 1.7 * 0.7433333);
    path.arcToPoint(
      Offset(size.width * 0.3522900, size.width * 1.7 * 0.7639861),
      radius: Radius.elliptical(
        size.width * 0.1086050,
        size.width * 1.7 * 0.06033611,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.3859300,
      size.width * 1.7 * 0.7642917,
      size.width * 0.4203550,
      size.width * 1.7 * 0.7644139,
      size.width * 0.4563950,
      size.width * 1.7 * 0.7641639,
    );
    path.cubicTo(
      size.width * 0.4539900,
      size.width * 1.7 * 0.7585139,
      size.width * 0.4542100,
      size.width * 1.7 * 0.7520917,
      size.width * 0.4580850,
      size.width * 1.7 * 0.7445806,
    );
    path.cubicTo(
      size.width * 0.4252100,
      size.width * 1.7 * 0.7442750,
      size.width * 0.3900000,
      size.width * 1.7 * 0.7438056,
      size.width * 0.3548650,
      size.width * 1.7 * 0.7433333,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Popliteal" area (id `back.right_popliteal`) on the
/// back view.
class RightBackKnee extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5419150, size.width * 1.7 * 0.7445806);
    path.cubicTo(
      size.width * 0.5457900,
      size.width * 1.7 * 0.7520806,
      size.width * 0.5460100,
      size.width * 1.7 * 0.7585139,
      size.width * 0.5436050,
      size.width * 1.7 * 0.7641639,
    );
    path.cubicTo(
      size.width * 0.5796450,
      size.width * 1.7 * 0.7644139,
      size.width * 0.6140700,
      size.width * 1.7 * 0.7642917,
      size.width * 0.6477100,
      size.width * 1.7 * 0.7639861,
    );
    path.arcToPoint(
      Offset(size.width * 0.6451350, size.width * 1.7 * 0.7433333),
      radius: Radius.elliptical(
        size.width * 0.1086050,
        size.width * 1.7 * 0.06033611,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.6100000,
      size.width * 1.7 * 0.7438056,
      size.width * 0.5747900,
      size.width * 1.7 * 0.7442750,
      size.width * 0.5419150,
      size.width * 1.7 * 0.7445833,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Calf" area (id `back.left_calf`) on the back view.
class LeftCalf extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3530550, size.width * 1.7 * 0.7722333);
    path.cubicTo(
      size.width * 0.3468850,
      size.width * 1.7 * 0.8326389,
      size.width * 0.3675850,
      size.width * 1.7 * 0.8843056,
      size.width * 0.3914250,
      size.width * 1.7 * 0.9349556,
    );
    path.cubicTo(
      size.width * 0.4080000,
      size.width * 1.7 * 0.9385861,
      size.width * 0.4228700,
      size.width * 1.7 * 0.9387139,
      size.width * 0.4361700,
      size.width * 1.7 * 0.9356111,
    );
    path.cubicTo(
      size.width * 0.4484200,
      size.width * 1.7 * 0.8839444,
      size.width * 0.4590000,
      size.width * 1.7 * 0.8315694,
      size.width * 0.4540050,
      size.width * 1.7 * 0.7722778,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Calf" area (id `back.right_calf`) on the back view.
class RightCalf extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5459950, size.width * 1.7 * 0.7722778);
    path.cubicTo(
      size.width * 0.5409950,
      size.width * 1.7 * 0.8315694,
      size.width * 0.5515800,
      size.width * 1.7 * 0.8839444,
      size.width * 0.5638300,
      size.width * 1.7 * 0.9356111,
    );
    path.cubicTo(
      size.width * 0.5771300,
      size.width * 1.7 * 0.9387139,
      size.width * 0.5920000,
      size.width * 1.7 * 0.9385861,
      size.width * 0.6085750,
      size.width * 1.7 * 0.9349556,
    );
    path.cubicTo(
      size.width * 0.6324150,
      size.width * 1.7 * 0.8843056,
      size.width * 0.6531150,
      size.width * 1.7 * 0.8326389,
      size.width * 0.6469450,
      size.width * 1.7 * 0.7722333,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left S. I. Joint" area (id `back.left_s_i_joint`) on the
/// back view.
class LeftBackPelvic extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4225650, size.width * 1.7 * 0.4245500);
    path.cubicTo(
      size.width * 0.4213900,
      size.width * 1.7 * 0.4278833,
      size.width * 0.4231550,
      size.width * 1.7 * 0.4382361,
      size.width * 0.4276200,
      size.width * 1.7 * 0.4445139,
    );
    path.cubicTo(
      size.width * 0.4322250,
      size.width * 1.7 * 0.4509889,
      size.width * 0.4424300,
      size.width * 1.7 * 0.4605611,
      size.width * 0.4501900,
      size.width * 1.7 * 0.4634028,
    );
    path.cubicTo(
      size.width * 0.4568650,
      size.width * 1.7 * 0.4658444,
      size.width * 0.4700400,
      size.width * 1.7 * 0.4628139,
      size.width * 0.4741900,
      size.width * 1.7 * 0.4615583,
    );
    path.cubicTo(
      size.width * 0.4772950,
      size.width * 1.7 * 0.4606194,
      size.width * 0.4769200,
      size.width * 1.7 * 0.4575167,
      size.width * 0.4751400,
      size.width * 1.7 * 0.4558639,
    );
    path.cubicTo(
      size.width * 0.4721400,
      size.width * 1.7 * 0.4530861,
      size.width * 0.4614600,
      size.width * 1.7 * 0.4489194,
      size.width * 0.4561400,
      size.width * 1.7 * 0.4448056,
    );
    path.cubicTo(
      size.width * 0.4493900,
      size.width * 1.7 * 0.4395806,
      size.width * 0.4402450,
      size.width * 1.7 * 0.4278861,
      size.width * 0.4346400,
      size.width * 1.7 * 0.4245111,
    );
    path.cubicTo(
      size.width * 0.4320000,
      size.width * 1.7 * 0.4228944,
      size.width * 0.4233050,
      size.width * 1.7 * 0.4224333,
      size.width * 0.4225650,
      size.width * 1.7 * 0.4245500,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right S. I. Joint" area (id `back.right_s_i_joint`) on the
/// back view.
class RightBackPelvic extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5653450, size.width * 1.7 * 0.4245083);
    path.cubicTo(
      size.width * 0.5597450,
      size.width * 1.7 * 0.4278833,
      size.width * 0.5505950,
      size.width * 1.7 * 0.4395778,
      size.width * 0.5438450,
      size.width * 1.7 * 0.4448028,
    );
    path.cubicTo(
      size.width * 0.5385300,
      size.width * 1.7 * 0.4489222,
      size.width * 0.5278450,
      size.width * 1.7 * 0.4530694,
      size.width * 0.5248450,
      size.width * 1.7 * 0.4558611,
    );
    path.cubicTo(
      size.width * 0.5230650,
      size.width * 1.7 * 0.4575278,
      size.width * 0.5226900,
      size.width * 1.7 * 0.4606167,
      size.width * 0.5257900,
      size.width * 1.7 * 0.4615556,
    );
    path.cubicTo(
      size.width * 0.5299500,
      size.width * 1.7 * 0.4628111,
      size.width * 0.5431300,
      size.width * 1.7 * 0.4658417,
      size.width * 0.5497900,
      size.width * 1.7 * 0.4634000,
    );
    path.cubicTo(
      size.width * 0.5575550,
      size.width * 1.7 * 0.4605611,
      size.width * 0.5677550,
      size.width * 1.7 * 0.4509889,
      size.width * 0.5723600,
      size.width * 1.7 * 0.4445111,
    );
    path.cubicTo(
      size.width * 0.5768250,
      size.width * 1.7 * 0.4382333,
      size.width * 0.5785950,
      size.width * 1.7 * 0.4278806,
      size.width * 0.5774200,
      size.width * 1.7 * 0.4245472,
    );
    path.cubicTo(
      size.width * 0.5766900,
      size.width * 1.7 * 0.4224333,
      size.width * 0.5680000,
      size.width * 1.7 * 0.4228944,
      size.width * 0.5653450,
      size.width * 1.7 * 0.4245083,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Achilles" area (id `back.left_achilles`) on the back
/// view.
class LeftAchilles extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3770000, size.width * 1.7 * 0.9625000);
    path.lineTo(size.width * 0.3923400, size.width * 1.7 * 0.9760694);
    path.cubicTo(
      size.width * 0.4011700,
      size.width * 1.7 * 0.9800639,
      size.width * 0.4121700,
      size.width * 1.7 * 0.9804417,
      size.width * 0.4263750,
      size.width * 1.7 * 0.9801278,
    );
    path.cubicTo(
      size.width * 0.4263750,
      size.width * 1.7 * 0.9801278,
      size.width * 0.4285100,
      size.width * 1.7 * 0.9730250,
      size.width * 0.4282700,
      size.width * 1.7 * 0.9706611,
    );
    path.cubicTo(
      size.width * 0.4280300,
      size.width * 1.7 * 0.9682972,
      size.width * 0.4324150,
      size.width * 1.7 * 0.9424694,
      size.width * 0.4324150,
      size.width * 1.7 * 0.9424694,
    );
    path.lineTo(size.width * 0.3946450, size.width * 1.7 * 0.9427083);
    path.cubicTo(
      size.width * 0.3946450,
      size.width * 1.7 * 0.9427083,
      size.width * 0.3950350,
      size.width * 1.7 * 0.9557000,
      size.width * 0.3880800,
      size.width * 1.7 * 0.9588611,
    );
    path.cubicTo(
      size.width * 0.3811250,
      size.width * 1.7 * 0.9620222,
      size.width * 0.3770000,
      size.width * 1.7 * 0.9625000,
      size.width * 0.3770000,
      size.width * 1.7 * 0.9625000,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Achilles" area (id `back.right_achilles`) on the back
/// view.
class RightAchilles extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.6111700, size.width * 1.7 * 0.9588611);
    path.cubicTo(
      size.width * 0.6042100,
      size.width * 1.7 * 0.9557000,
      size.width * 0.6046000,
      size.width * 1.7 * 0.9427083,
      size.width * 0.6046000,
      size.width * 1.7 * 0.9427083,
    );
    path.lineTo(size.width * 0.5668300, size.width * 1.7 * 0.9424694);
    path.cubicTo(
      size.width * 0.5668300,
      size.width * 1.7 * 0.9424694,
      size.width * 0.5712250,
      size.width * 1.7 * 0.9683028,
      size.width * 0.5709800,
      size.width * 1.7 * 0.9706611,
    );
    path.cubicTo(
      size.width * 0.5707350,
      size.width * 1.7 * 0.9730194,
      size.width * 0.5728700,
      size.width * 1.7 * 0.9801278,
      size.width * 0.5728700,
      size.width * 1.7 * 0.9801278,
    );
    path.cubicTo(
      size.width * 0.5870800,
      size.width * 1.7 * 0.9804417,
      size.width * 0.5980800,
      size.width * 1.7 * 0.9800639,
      size.width * 0.6069100,
      size.width * 1.7 * 0.9760694,
    );
    path.lineTo(size.width * 0.6222500, size.width * 1.7 * 0.9625000);
    path.cubicTo(
      size.width * 0.6222500,
      size.width * 1.7 * 0.9625000,
      size.width * 0.6181200,
      size.width * 1.7 * 0.9620222,
      size.width * 0.6111650,
      size.width * 1.7 * 0.9588639,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Heel" area (id `back.left_heel`) on the back view.
class LeftHeel extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3872850, size.width * 1.7 * 0.9933333);
    path.cubicTo(
      size.width * 0.3897100,
      size.width * 1.7 * 0.9950000,
      size.width * 0.4033650,
      size.width * 1.7 * 0.9995861,
      size.width * 0.4084550,
      size.width * 1.7 * 0.9996111,
    );
    path.cubicTo(
      size.width * 0.4135450,
      size.width * 1.7 * 0.9996361,
      size.width * 0.4239550,
      size.width * 1.7 * 0.9943917,
      size.width * 0.4252500,
      size.width * 1.7 * 0.9927167,
    );
    path.cubicTo(
      size.width * 0.4265450,
      size.width * 1.7 * 0.9910417,
      size.width * 0.4259500,
      size.width * 1.7 * 0.9833556,
      size.width * 0.4259500,
      size.width * 1.7 * 0.9833556,
    );
    path.cubicTo(
      size.width * 0.4259500,
      size.width * 1.7 * 0.9833556,
      size.width * 0.4130600,
      size.width * 1.7 * 0.9843306,
      size.width * 0.4057900,
      size.width * 1.7 * 0.9831278,
    );
    path.cubicTo(
      size.width * 0.3985200,
      size.width * 1.7 * 0.9819250,
      size.width * 0.3889650,
      size.width * 1.7 * 0.9773694,
      size.width * 0.3889650,
      size.width * 1.7 * 0.9773694,
    );
    path.cubicTo(
      size.width * 0.3889650,
      size.width * 1.7 * 0.9773694,
      size.width * 0.3848600,
      size.width * 1.7 * 0.9916667,
      size.width * 0.3872850,
      size.width * 1.7 * 0.9933333,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Heel" area (id `back.right_heel`) on the back view.
class RightHeel extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.6102850, size.width * 1.7 * 0.9773694);
    path.cubicTo(
      size.width * 0.6102850,
      size.width * 1.7 * 0.9773694,
      size.width * 0.6007300,
      size.width * 1.7 * 0.9819222,
      size.width * 0.5934600,
      size.width * 1.7 * 0.9831278,
    );
    path.cubicTo(
      size.width * 0.5861900,
      size.width * 1.7 * 0.9843333,
      size.width * 0.5733050,
      size.width * 1.7 * 0.9833556,
      size.width * 0.5733050,
      size.width * 1.7 * 0.9833556,
    );
    path.cubicTo(
      size.width * 0.5733050,
      size.width * 1.7 * 0.9833556,
      size.width * 0.5726950,
      size.width * 1.7 * 0.9910361,
      size.width * 0.5740050,
      size.width * 1.7 * 0.9927167,
    );
    path.cubicTo(
      size.width * 0.5753150,
      size.width * 1.7 * 0.9943972,
      size.width * 0.5857000,
      size.width * 1.7 * 0.9996306,
      size.width * 0.5907950,
      size.width * 1.7 * 0.9996111,
    );
    path.cubicTo(
      size.width * 0.5958900,
      size.width * 1.7 * 0.9995917,
      size.width * 0.6095400,
      size.width * 1.7 * 0.9950028,
      size.width * 0.6119650,
      size.width * 1.7 * 0.9933333,
    );
    path.cubicTo(
      size.width * 0.6143900,
      size.width * 1.7 * 0.9916639,
      size.width * 0.6102700,
      size.width * 1.7 * 0.9773667,
      size.width * 0.6102700,
      size.width * 1.7 * 0.9773667,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Cervical Spine" area (id `back.cervical_spine`) on the back
/// view.
class UpperSpine extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4857450, size.width * 1.7 * 0.1353972);
    path.lineTo(size.width * 0.4853350, size.width * 1.7 * 0.1769778);
    path.lineTo(size.width * 0.5123100, size.width * 1.7 * 0.1770000);
    path.lineTo(size.width * 0.5124600, size.width * 1.7 * 0.1353083);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Elbow" area (id `back.right_elbow`) on the back view.
class RightElbow extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.6987150, size.width * 1.7 * 0.3620417);
    path.cubicTo(
      size.width * 0.6987150,
      size.width * 1.7 * 0.3620417,
      size.width * 0.6978150,
      size.width * 1.7 * 0.3652778,
      size.width * 0.7019250,
      size.width * 1.7 * 0.3686500,
    );
    path.cubicTo(
      size.width * 0.7057500,
      size.width * 1.7 * 0.3717917,
      size.width * 0.7454250,
      size.width * 1.7 * 0.3791000,
      size.width * 0.7567100,
      size.width * 1.7 * 0.3754750,
    );
    path.cubicTo(
      size.width * 0.7765000,
      size.width * 1.7 * 0.3691306,
      size.width * 0.7680200,
      size.width * 1.7 * 0.3493972,
      size.width * 0.7680200,
      size.width * 1.7 * 0.3493972,
    );
    path.cubicTo(
      size.width * 0.7512500,
      size.width * 1.7 * 0.3432972,
      size.width * 0.7023500,
      size.width * 1.7 * 0.3565611,
      size.width * 0.6987150,
      size.width * 1.7 * 0.3620444,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Elbow" area (id `back.left_elbow`) on the back view.
class LeftElbow extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.2350000, size.width * 1.7 * 0.3494000);
    path.cubicTo(
      size.width * 0.2350000,
      size.width * 1.7 * 0.3494000,
      size.width * 0.2265000,
      size.width * 1.7 * 0.3691222,
      size.width * 0.2463100,
      size.width * 1.7 * 0.3754778,
    );
    path.cubicTo(
      size.width * 0.2576100,
      size.width * 1.7 * 0.3790889,
      size.width * 0.2972700,
      size.width * 1.7 * 0.3717944,
      size.width * 0.3010950,
      size.width * 1.7 * 0.3686528,
    );
    path.cubicTo(
      size.width * 0.3052000,
      size.width * 1.7 * 0.3652806,
      size.width * 0.3043000,
      size.width * 1.7 * 0.3620444,
      size.width * 0.3043000,
      size.width * 1.7 * 0.3620444,
    );
    path.cubicTo(
      size.width * 0.3006650,
      size.width * 1.7 * 0.3565611,
      size.width * 0.2517650,
      size.width * 1.7 * 0.3432972,
      size.width * 0.2350000,
      size.width * 1.7 * 0.3494000,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Back of Left Hand" area (id `back.back_of_left_hand`) on the
/// back view.
class LeftHand extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.1170800, size.width * 1.7 * 0.4859833);
    path.cubicTo(
      size.width * 0.1170800,
      size.width * 1.7 * 0.4859833,
      size.width * 0.1077050,
      size.width * 1.7 * 0.4866889,
      size.width * 0.1020800,
      size.width * 1.7 * 0.4874917,
    );
    path.cubicTo(
      size.width * 0.09645500,
      size.width * 1.7 * 0.4882944,
      size.width * 0.08665000,
      size.width * 1.7 * 0.4879361,
      size.width * 0.07044000,
      size.width * 1.7 * 0.4946306,
    );
    path.cubicTo(
      size.width * 0.05423000,
      size.width * 1.7 * 0.5013250,
      size.width * 0.04470500,
      size.width * 1.7 * 0.5060389,
      size.width * 0.04470500,
      size.width * 1.7 * 0.5060389,
    );
    path.lineTo(size.width * 0.03161500, size.width * 1.7 * 0.5073278);
    path.cubicTo(
      size.width * 0.03161500,
      size.width * 1.7 * 0.5073278,
      size.width * 0.02508500,
      size.width * 1.7 * 0.5084250,
      size.width * 0.02734500,
      size.width * 1.7 * 0.5129639,
    );
    path.cubicTo(
      size.width * 0.02960500,
      size.width * 1.7 * 0.5175028,
      size.width * 0.05648000,
      size.width * 1.7 * 0.5143972,
      size.width * 0.05648000,
      size.width * 1.7 * 0.5143972,
    );
    path.lineTo(size.width * 0.07976000, size.width * 1.7 * 0.5116833);
    path.cubicTo(
      size.width * 0.07976000,
      size.width * 1.7 * 0.5116833,
      size.width * 0.07151500,
      size.width * 1.7 * 0.5258722,
      size.width * 0.06957500,
      size.width * 1.7 * 0.5285111,
    );
    path.cubicTo(
      size.width * 0.06763500,
      size.width * 1.7 * 0.5311500,
      size.width * 0.04873500,
      size.width * 1.7 * 0.5563333,
      size.width * 0.04842500,
      size.width * 1.7 * 0.5580694,
    );
    path.cubicTo(
      size.width * 0.04811500,
      size.width * 1.7 * 0.5598056,
      size.width * 0.05249000,
      size.width * 1.7 * 0.5642556,
      size.width * 0.05439500,
      size.width * 1.7 * 0.5657528,
    );
    path.cubicTo(
      size.width * 0.05630000,
      size.width * 1.7 * 0.5672500,
      size.width * 0.06386000,
      size.width * 1.7 * 0.5705861,
      size.width * 0.06893500,
      size.width * 1.7 * 0.5728333,
    );
    path.cubicTo(
      size.width * 0.07401000,
      size.width * 1.7 * 0.5750806,
      size.width * 0.07889500,
      size.width * 1.7 * 0.5738028,
      size.width * 0.08565500,
      size.width * 1.7 * 0.5730722,
    );
    path.cubicTo(
      size.width * 0.09241500,
      size.width * 1.7 * 0.5723417,
      size.width * 0.09803000,
      size.width * 1.7 * 0.5645861,
      size.width * 0.09901500,
      size.width * 1.7 * 0.5660028,
    );
    path.cubicTo(
      size.width * 0.1000000,
      size.width * 1.7 * 0.5674194,
      size.width * 0.1079500,
      size.width * 1.7 * 0.5672750,
      size.width * 0.1100850,
      size.width * 1.7 * 0.5655972,
    );
    path.cubicTo(
      size.width * 0.1142250,
      size.width * 1.7 * 0.5623389,
      size.width * 0.1238550,
      size.width * 1.7 * 0.5464722,
      size.width * 0.1238550,
      size.width * 1.7 * 0.5464722,
    );
    path.lineTo(size.width * 0.1479000, size.width * 1.7 * 0.5268444);
    path.cubicTo(
      size.width * 0.1596600,
      size.width * 1.7 * 0.5159972,
      size.width * 0.1684750,
      size.width * 1.7 * 0.5046972,
      size.width * 0.1719000,
      size.width * 1.7 * 0.4925694,
    );
    path.arcToPoint(
      Offset(size.width * 0.1281850, size.width * 1.7 * 0.4808694),
      radius: Radius.elliptical(
        size.width * 0.1110850,
        size.width * 1.7 * 0.06171389,
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

/// Outline of the "Back of Right Hand" area (id `back.back_of_right_hand`) on
/// the back view.
class RightHand extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.8718050, size.width * 1.7 * 0.4808694);
    path.arcToPoint(
      Offset(size.width * 0.8280900, size.width * 1.7 * 0.4925694),
      radius: Radius.elliptical(
        size.width * 0.1110850,
        size.width * 1.7 * 0.06171389,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.8315100,
      size.width * 1.7 * 0.5046972,
      size.width * 0.8403250,
      size.width * 1.7 * 0.5159972,
      size.width * 0.8520900,
      size.width * 1.7 * 0.5268444,
    );
    path.lineTo(size.width * 0.8761350, size.width * 1.7 * 0.5464722);
    path.cubicTo(
      size.width * 0.8761350,
      size.width * 1.7 * 0.5464722,
      size.width * 0.8857650,
      size.width * 1.7 * 0.5623389,
      size.width * 0.8899050,
      size.width * 1.7 * 0.5655972,
    );
    path.cubicTo(
      size.width * 0.8920400,
      size.width * 1.7 * 0.5672639,
      size.width * 0.8999900,
      size.width * 1.7 * 0.5674194,
      size.width * 0.9009750,
      size.width * 1.7 * 0.5660028,
    );
    path.cubicTo(
      size.width * 0.9019600,
      size.width * 1.7 * 0.5645861,
      size.width * 0.9075800,
      size.width * 1.7 * 0.5723389,
      size.width * 0.9143350,
      size.width * 1.7 * 0.5730722,
    );
    path.cubicTo(
      size.width * 0.9210900,
      size.width * 1.7 * 0.5738056,
      size.width * 0.9259800,
      size.width * 1.7 * 0.5750806,
      size.width * 0.9310550,
      size.width * 1.7 * 0.5728333,
    );
    path.cubicTo(
      size.width * 0.9361300,
      size.width * 1.7 * 0.5705861,
      size.width * 0.9436950,
      size.width * 1.7 * 0.5672528,
      size.width * 0.9455950,
      size.width * 1.7 * 0.5657528,
    );
    path.cubicTo(
      size.width * 0.9474950,
      size.width * 1.7 * 0.5642528,
      size.width * 0.9518750,
      size.width * 1.7 * 0.5598111,
      size.width * 0.9515650,
      size.width * 1.7 * 0.5580694,
    );
    path.cubicTo(
      size.width * 0.9512550,
      size.width * 1.7 * 0.5563278,
      size.width * 0.9323600,
      size.width * 1.7 * 0.5311472,
      size.width * 0.9304150,
      size.width * 1.7 * 0.5285111,
    );
    path.cubicTo(
      size.width * 0.9284700,
      size.width * 1.7 * 0.5258750,
      size.width * 0.9202300,
      size.width * 1.7 * 0.5116833,
      size.width * 0.9202300,
      size.width * 1.7 * 0.5116833,
    );
    path.lineTo(size.width * 0.9435100, size.width * 1.7 * 0.5143972);
    path.cubicTo(
      size.width * 0.9435100,
      size.width * 1.7 * 0.5143972,
      size.width * 0.9703900,
      size.width * 1.7 * 0.5175028,
      size.width * 0.9726450,
      size.width * 1.7 * 0.5129639,
    );
    path.cubicTo(
      size.width * 0.9749000,
      size.width * 1.7 * 0.5084250,
      size.width * 0.9683750,
      size.width * 1.7 * 0.5073278,
      size.width * 0.9683750,
      size.width * 1.7 * 0.5073278,
    );
    path.lineTo(size.width * 0.9552850, size.width * 1.7 * 0.5060389);
    path.cubicTo(
      size.width * 0.9552850,
      size.width * 1.7 * 0.5060389,
      size.width * 0.9457850,
      size.width * 1.7 * 0.5013167,
      size.width * 0.9295500,
      size.width * 1.7 * 0.4946306,
    );
    path.cubicTo(
      size.width * 0.9133150,
      size.width * 1.7 * 0.4879444,
      size.width * 0.9035150,
      size.width * 1.7 * 0.4882944,
      size.width * 0.8979100,
      size.width * 1.7 * 0.4874917,
    );
    path.cubicTo(
      size.width * 0.8923050,
      size.width * 1.7 * 0.4866889,
      size.width * 0.8829100,
      size.width * 1.7 * 0.4859833,
      size.width * 0.8829100,
      size.width * 1.7 * 0.4859833,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Tricep" area (id `back.right_tricep`) on the back
/// view.
class RightUpperArm extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.7671900, size.width * 1.7 * 0.3452778);
    path.cubicTo(
      size.width * 0.7671900,
      size.width * 1.7 * 0.3452778,
      size.width * 0.7257450,
      size.width * 1.7 * 0.2095750,
      size.width * 0.7050000,
      size.width * 1.7 * 0.1991417,
    );
    path.cubicTo(
      size.width * 0.7035000,
      size.width * 1.7 * 0.2145500,
      size.width * 0.6947850,
      size.width * 1.7 * 0.2295194,
      size.width * 0.6811900,
      size.width * 1.7 * 0.2435639,
    );
    path.cubicTo(
      size.width * 0.6782650,
      size.width * 1.7 * 0.2601028,
      size.width * 0.6715050,
      size.width * 1.7 * 0.2803417,
      size.width * 0.6629950,
      size.width * 1.7 * 0.2970222,
    );
    path.cubicTo(
      size.width * 0.6629950,
      size.width * 1.7 * 0.2970222,
      size.width * 0.6674950,
      size.width * 1.7 * 0.3096139,
      size.width * 0.6714500,
      size.width * 1.7 * 0.3158417,
    );
    path.cubicTo(
      size.width * 0.6823900,
      size.width * 1.7 * 0.3330417,
      size.width * 0.6948000,
      size.width * 1.7 * 0.3595111,
      size.width * 0.6948000,
      size.width * 1.7 * 0.3595111,
    );
    path.cubicTo(
      size.width * 0.7100500,
      size.width * 1.7 * 0.3485000,
      size.width * 0.7399550,
      size.width * 1.7 * 0.3429250,
      size.width * 0.7671900,
      size.width * 1.7 * 0.3452778,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Tricep" area (id `back.left_tricep`) on the back view.
class LeftUpperArm extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3081900, size.width * 1.7 * 0.3595056);
    path.cubicTo(
      size.width * 0.3081900,
      size.width * 1.7 * 0.3595056,
      size.width * 0.3206250,
      size.width * 1.7 * 0.3330556,
      size.width * 0.3315600,
      size.width * 1.7 * 0.3158333,
    );
    path.cubicTo(
      size.width * 0.3355250,
      size.width * 1.7 * 0.3096056,
      size.width * 0.3400200,
      size.width * 1.7 * 0.2970139,
      size.width * 0.3400200,
      size.width * 1.7 * 0.2970139,
    );
    path.cubicTo(
      size.width * 0.3315200,
      size.width * 1.7 * 0.2803472,
      size.width * 0.3247450,
      size.width * 1.7 * 0.2600944,
      size.width * 0.3218200,
      size.width * 1.7 * 0.2435556,
    );
    path.cubicTo(
      size.width * 0.3082250,
      size.width * 1.7 * 0.2295194,
      size.width * 0.2995000,
      size.width * 1.7 * 0.2145500,
      size.width * 0.2980000,
      size.width * 1.7 * 0.1991417,
    );
    path.cubicTo(
      size.width * 0.2772750,
      size.width * 1.7 * 0.2095750,
      size.width * 0.2358350,
      size.width * 1.7 * 0.3452778,
      size.width * 0.2358350,
      size.width * 1.7 * 0.3452778,
    );
    path.cubicTo(
      size.width * 0.2630650,
      size.width * 1.7 * 0.3429250,
      size.width * 0.2929700,
      size.width * 1.7 * 0.3485000,
      size.width * 0.3082100,
      size.width * 1.7 * 0.3595111,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Thoracic Spine" area (id `back.thoracic_spine`) on the back
/// view.
class MidSpine extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4846350, size.width * 1.7 * 0.1811472);
    path.lineTo(size.width * 0.4824650, size.width * 1.7 * 0.3603278);
    path.lineTo(size.width * 0.5134250, size.width * 1.7 * 0.3595694);
    path.lineTo(size.width * 0.5132700, size.width * 1.7 * 0.1811472);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Hamstring" area (id `back.left_hamstring`) on the back
/// view.
class LeftHamstring extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3546350, size.width * 1.7 * 0.7332528);
    path.cubicTo(
      size.width * 0.3792750,
      size.width * 1.7 * 0.7390861,
      size.width * 0.4338750,
      size.width * 1.7 * 0.7406056,
      size.width * 0.4617050,
      size.width * 1.7 * 0.7350139,
    );
    path.cubicTo(
      size.width * 0.4647700,
      size.width * 1.7 * 0.7325722,
      size.width * 0.5039500,
      size.width * 1.7 * 0.6144361,
      size.width * 0.4980450,
      size.width * 1.7 * 0.5504111,
    );
    path.cubicTo(
      size.width * 0.4883900,
      size.width * 1.7 * 0.5511028,
      size.width * 0.4656400,
      size.width * 1.7 * 0.5573556,
      size.width * 0.4554900,
      size.width * 1.7 * 0.5574333,
    );
    path.cubicTo(
      size.width * 0.4057950,
      size.width * 1.7 * 0.5578444,
      size.width * 0.3641450,
      size.width * 1.7 * 0.5482972,
      size.width * 0.3251700,
      size.width * 1.7 * 0.5348222,
    );
    path.cubicTo(
      size.width * 0.3251700,
      size.width * 1.7 * 0.5348222,
      size.width * 0.3239800,
      size.width * 1.7 * 0.5724917,
      size.width * 0.3262250,
      size.width * 1.7 * 0.5870444,
    );
    path.cubicTo(
      size.width * 0.3313650,
      size.width * 1.7 * 0.6205556,
      size.width * 0.3443950,
      size.width * 1.7 * 0.6870333,
      size.width * 0.3546150,
      size.width * 1.7 * 0.7332528,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Top of Head" area (id `back.right_top_of_head`) on the
/// back view.
class RightSkull extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5028500, size.width * 1.7 * 0.002175000);
    path.lineTo(size.width * 0.5027050, size.width * 1.7 * 0.07311944);
    path.lineTo(size.width * 0.5487350, size.width * 1.7 * 0.07319444);
    path.lineTo(size.width * 0.5489000, size.width * 1.7 * 0.007616667);
    path.cubicTo(
      size.width * 0.5360700,
      size.width * 1.7 * 0.003822222,
      size.width * 0.5191550,
      size.width * 1.7 * 0.002238889,
      size.width * 0.5028500,
      size.width * 1.7 * 0.002175000,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Base of Head" area (id `back.base_of_head`) on the back
/// view.
class LowerHead extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5501950, size.width * 1.7 * 0.1315222);
    path.cubicTo(
      size.width * 0.5493450,
      size.width * 1.7 * 0.1205556,
      size.width * 0.5617300,
      size.width * 1.7 * 0.1133944,
      size.width * 0.5726950,
      size.width * 1.7 * 0.1030111,
    );
    path.lineTo(size.width * 0.5489450, size.width * 1.7 * 0.09265278);
    path.lineTo(size.width * 0.5487950, size.width * 1.7 * 0.07600833);
    path.lineTo(size.width * 0.4510850, size.width * 1.7 * 0.07600833);
    path.lineTo(size.width * 0.4516750, size.width * 1.7 * 0.09168333);
    path.lineTo(size.width * 0.4274700, size.width * 1.7 * 0.1017083);
    path.cubicTo(
      size.width * 0.4403550,
      size.width * 1.7 * 0.1155972,
      size.width * 0.4445000,
      size.width * 1.7 * 0.1235694,
      size.width * 0.4482250,
      size.width * 1.7 * 0.1324667,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Temple" area (id `back.left_temple`) on the back view.
class LeftEar extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4168450, size.width * 1.7 * 0.03032500);
    path.cubicTo(
      size.width * 0.4144150,
      size.width * 1.7 * 0.04028611,
      size.width * 0.4107400,
      size.width * 1.7 * 0.06076111,
      size.width * 0.4107400,
      size.width * 1.7 * 0.06076111,
    );
    path.cubicTo(
      size.width * 0.4005200,
      size.width * 1.7 * 0.06176944,
      size.width * 0.3969600,
      size.width * 1.7 * 0.06791389,
      size.width * 0.4001300,
      size.width * 1.7 * 0.07800833,
    );
    path.cubicTo(
      size.width * 0.4037900,
      size.width * 1.7 * 0.09065556,
      size.width * 0.4121300,
      size.width * 1.7 * 0.1001222,
      size.width * 0.4228600,
      size.width * 1.7 * 0.1016528,
    );
    path.lineTo(size.width * 0.4458350, size.width * 1.7 * 0.09091389);
    path.lineTo(size.width * 0.4449300, size.width * 1.7 * 0.01136389);
    path.cubicTo(
      size.width * 0.4333400,
      size.width * 1.7 * 0.01427222,
      size.width * 0.4189450,
      size.width * 1.7 * 0.02170556,
      size.width * 0.4168450,
      size.width * 1.7 * 0.03032500,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Temple" area (id `back.right_temple`) on the back
/// view.
class RightEar extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5550700, size.width * 1.7 * 0.01136389);
    path.lineTo(size.width * 0.5541650, size.width * 1.7 * 0.09091389);
    path.lineTo(size.width * 0.5771650, size.width * 1.7 * 0.1016528);
    path.cubicTo(
      size.width * 0.5878900,
      size.width * 1.7 * 0.1001222,
      size.width * 0.5962350,
      size.width * 1.7 * 0.09065556,
      size.width * 0.5998950,
      size.width * 1.7 * 0.07800833,
    );
    path.cubicTo(
      size.width * 0.6030650,
      size.width * 1.7 * 0.06791389,
      size.width * 0.5995050,
      size.width * 1.7 * 0.06176944,
      size.width * 0.5892850,
      size.width * 1.7 * 0.06076111,
    );
    path.cubicTo(
      size.width * 0.5892850,
      size.width * 1.7 * 0.06076111,
      size.width * 0.5856100,
      size.width * 1.7 * 0.04028611,
      size.width * 0.5831800,
      size.width * 1.7 * 0.03032500,
    );
    path.cubicTo(
      size.width * 0.5810550,
      size.width * 1.7 * 0.02170556,
      size.width * 0.5666600,
      size.width * 1.7 * 0.01427222,
      size.width * 0.5550700,
      size.width * 1.7 * 0.01136389,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Neck" area (id `back.left_neck`) on the back view.
class LeftNeck extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4483550, size.width * 1.7 * 0.1351361);
    path.cubicTo(
      size.width * 0.4495300,
      size.width * 1.7 * 0.1482222,
      size.width * 0.4325650,
      size.width * 1.7 * 0.1644444,
      size.width * 0.4325650,
      size.width * 1.7 * 0.1644444,
    );
    path.lineTo(size.width * 0.4738000, size.width * 1.7 * 0.1620833);
    path.lineTo(size.width * 0.4775650, size.width * 1.7 * 0.1350778);
    path.cubicTo(
      size.width * 0.4775650,
      size.width * 1.7 * 0.1350778,
      size.width * 0.4652550,
      size.width * 1.7 * 0.1351194,
      size.width * 0.4483550,
      size.width * 1.7 * 0.1351361,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Neck" area (id `back.right_neck`) on the back view.
class RightNeck extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5224350, size.width * 1.7 * 0.1350667);
    path.lineTo(size.width * 0.5252300, size.width * 1.7 * 0.1620500);
    path.lineTo(size.width * 0.5674350, size.width * 1.7 * 0.1644333);
    path.cubicTo(
      size.width * 0.5674350,
      size.width * 1.7 * 0.1644333,
      size.width * 0.5504700,
      size.width * 1.7 * 0.1482222,
      size.width * 0.5516450,
      size.width * 1.7 * 0.1351361,
    );
    path.cubicTo(
      size.width * 0.5347450,
      size.width * 1.7 * 0.1351194,
      size.width * 0.5224350,
      size.width * 1.7 * 0.1350667,
      size.width * 0.5224350,
      size.width * 1.7 * 0.1350667,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Posterior Forearm" area (id
/// `back.left_posterior_forearm`) on the back view.
class LeftForearm extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.2194600, size.width * 1.7 * 0.3649361);
    path.lineTo(size.width * 0.1411350, size.width * 1.7 * 0.4668806);
    path.cubicTo(
      size.width * 0.1587300,
      size.width * 1.7 * 0.4673472,
      size.width * 0.1733150,
      size.width * 1.7 * 0.4706694,
      size.width * 0.1840300,
      size.width * 1.7 * 0.4776611,
    );
    path.lineTo(size.width * 0.2905000, size.width * 1.7 * 0.3799111);
    path.cubicTo(
      size.width * 0.2638600,
      size.width * 1.7 * 0.3830722,
      size.width * 0.2410000,
      size.width * 1.7 * 0.3811111,
      size.width * 0.2194600,
      size.width * 1.7 * 0.3649361,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Posterior Forearm" area (id
/// `back.right_posterior_forearm`) on the back view.
class RightForearm extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.7095000, size.width * 1.7 * 0.3799111);
    path.lineTo(size.width * 0.8159550, size.width * 1.7 * 0.4776694);
    path.cubicTo(
      size.width * 0.8266700,
      size.width * 1.7 * 0.4706778,
      size.width * 0.8412550,
      size.width * 1.7 * 0.4673556,
      size.width * 0.8588500,
      size.width * 1.7 * 0.4668889,
    );
    path.lineTo(size.width * 0.7805250, size.width * 1.7 * 0.3649444);
    path.cubicTo(
      size.width * 0.7590000,
      size.width * 1.7 * 0.3811111,
      size.width * 0.7361400,
      size.width * 1.7 * 0.3830722,
      size.width * 0.7095000,
      size.width * 1.7 * 0.3799111,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Lumbar Spine" area (id `back.lumbar_spine`) on the back
/// view.
class LowerSpine extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4833400, size.width * 1.7 * 0.3641361);
    path.lineTo(size.width * 0.4753400, size.width * 1.7 * 0.4141667);
    path.lineTo(size.width * 0.5205150, size.width * 1.7 * 0.4136694);
    path.lineTo(size.width * 0.5123500, size.width * 1.7 * 0.3641889);
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Sacrum" area (id `back.sacrum`) on the back view.
class Tailbone extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4584450, size.width * 1.7 * 0.4356417);
    path.cubicTo(
      size.width * 0.4605350,
      size.width * 1.7 * 0.4406556,
      size.width * 0.4846050,
      size.width * 1.7 * 0.4565250,
      size.width * 0.4908650,
      size.width * 1.7 * 0.4575056,
    );
    path.cubicTo(
      size.width * 0.4971250,
      size.width * 1.7 * 0.4584861,
      size.width * 0.5126800,
      size.width * 1.7 * 0.4572944,
      size.width * 0.5159950,
      size.width * 1.7 * 0.4562694,
    );
    path.cubicTo(
      size.width * 0.5193100,
      size.width * 1.7 * 0.4552444,
      size.width * 0.5369400,
      size.width * 1.7 * 0.4394833,
      size.width * 0.5376950,
      size.width * 1.7 * 0.4325917,
    );
    path.cubicTo(
      size.width * 0.5384500,
      size.width * 1.7 * 0.4257000,
      size.width * 0.5249600,
      size.width * 1.7 * 0.4213972,
      size.width * 0.5249600,
      size.width * 1.7 * 0.4213972,
    );
    path.lineTo(size.width * 0.4662700, size.width * 1.7 * 0.4222889);
    path.cubicTo(
      size.width * 0.4662700,
      size.width * 1.7 * 0.4222889,
      size.width * 0.4563600,
      size.width * 1.7 * 0.4306361,
      size.width * 0.4584450,
      size.width * 1.7 * 0.4356528,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Lower Back" area (id `back.left_lower_back`) on the
/// back view.
class LeftLowerBack extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4147800, size.width * 1.7 * 0.3258333);
    path.cubicTo(
      size.width * 0.4144550,
      size.width * 1.7 * 0.3567361,
      size.width * 0.4100350,
      size.width * 1.7 * 0.3868056,
      size.width * 0.4032100,
      size.width * 1.7 * 0.4163889,
    );
    path.lineTo(size.width * 0.4605350, size.width * 1.7 * 0.4156000);
    path.quadraticBezierTo(
      size.width * 0.4668700,
      size.width * 1.7 * 0.3708333,
      size.width * 0.4695650,
      size.width * 1.7 * 0.3258333,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Middle Back" area (id `back.left_middle_back`) on the
/// back view.
class LeftMidBack extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4699400, size.width * 1.7 * 0.3192500);
    path.quadraticBezierTo(
      size.width * 0.4716750,
      size.width * 1.7 * 0.2875500,
      size.width * 0.4716650,
      size.width * 1.7 * 0.2557250,
    );
    path.cubicTo(
      size.width * 0.4511650,
      size.width * 1.7 * 0.2567833,
      size.width * 0.4297800,
      size.width * 1.7 * 0.2563333,
      size.width * 0.4079650,
      size.width * 1.7 * 0.2552083,
    );
    path.arcToPoint(
      Offset(size.width * 0.4147850, size.width * 1.7 * 0.3192500),
      radius: Radius.elliptical(
        size.width * 1.042140,
        size.width * 1.7 * 0.5789667,
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

/// Outline of the "Right Lower Back" area (id `back.right_lower_back`) on the
/// back view.
class RightLowerBack extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5826050, size.width * 1.7 * 0.3258333);
    path.cubicTo(
      size.width * 0.5829300,
      size.width * 1.7 * 0.3567361,
      size.width * 0.5873550,
      size.width * 1.7 * 0.3868056,
      size.width * 0.5941750,
      size.width * 1.7 * 0.4163889,
    );
    path.lineTo(size.width * 0.5368550, size.width * 1.7 * 0.4156000);
    path.quadraticBezierTo(
      size.width * 0.5305000,
      size.width * 1.7 * 0.3708333,
      size.width * 0.5278200,
      size.width * 1.7 * 0.3258333,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Middle Back" area (id `back.right_middle_back`) on the
/// back view.
class RightMidBack extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.5274450, size.width * 1.7 * 0.3192500);
    path.quadraticBezierTo(
      size.width * 0.5257100,
      size.width * 1.7 * 0.2875500,
      size.width * 0.5257200,
      size.width * 1.7 * 0.2557250,
    );
    path.cubicTo(
      size.width * 0.5462200,
      size.width * 1.7 * 0.2567833,
      size.width * 0.5676100,
      size.width * 1.7 * 0.2563333,
      size.width * 0.5894200,
      size.width * 1.7 * 0.2552083,
    );
    path.arcToPoint(
      Offset(size.width * 0.5826000, size.width * 1.7 * 0.3192500),
      radius: Radius.elliptical(
        size.width * 1.043355,
        size.width * 1.7 * 0.5796417,
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

/// Outline of the "Left Side" area (id `back.left_side`) on the back view.
class FarLeftBack extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.3494450, size.width * 1.7 * 0.2975139);
    path.cubicTo(
      size.width * 0.3342100,
      size.width * 1.7 * 0.2738028,
      size.width * 0.3317200,
      size.width * 1.7 * 0.2454250,
      size.width * 0.3317200,
      size.width * 1.7 * 0.2454250,
    );
    path.arcToPoint(
      Offset(size.width * 0.3927500, size.width * 1.7 * 0.2552194),
      radius: Radius.elliptical(
        size.width * 0.2566600,
        size.width * 1.7 * 0.1425889,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.3999500, size.width * 1.7 * 0.3213306),
      radius: Radius.elliptical(
        size.width * 1.107340,
        size.width * 1.7 * 0.6151889,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.lineTo(size.width * 0.3999500, size.width * 1.7 * 0.3220917);
    path.cubicTo(
      size.width * 0.3994800,
      size.width * 1.7 * 0.3543333,
      size.width * 0.3938950,
      size.width * 1.7 * 0.3878750,
      size.width * 0.3861650,
      size.width * 1.7 * 0.4156000,
    );
    path.cubicTo(
      size.width * 0.3861650,
      size.width * 1.7 * 0.4156000,
      size.width * 0.3550050,
      size.width * 1.7 * 0.4215778,
      size.width * 0.3512850,
      size.width * 1.7 * 0.4198778,
    );
    path.cubicTo(
      size.width * 0.3443700,
      size.width * 1.7 * 0.4167139,
      size.width * 0.3584000,
      size.width * 1.7 * 0.3817111,
      size.width * 0.3588750,
      size.width * 1.7 * 0.3790667,
    );
    path.cubicTo(
      size.width * 0.3593500,
      size.width * 1.7 * 0.3764222,
      size.width * 0.3619400,
      size.width * 1.7 * 0.3566250,
      size.width * 0.3605050,
      size.width * 1.7 * 0.3421222,
    );
    path.cubicTo(
      size.width * 0.3600750,
      size.width * 1.7 * 0.3377833,
      size.width * 0.3595050,
      size.width * 1.7 * 0.3303778,
      size.width * 0.3585750,
      size.width * 1.7 * 0.3241917,
    );
    path.lineTo(size.width * 0.3585000, size.width * 1.7 * 0.3238278);
    path.cubicTo(
      size.width * 0.3568650,
      size.width * 1.7 * 0.3160917,
      size.width * 0.3533550,
      size.width * 1.7 * 0.3036111,
      size.width * 0.3494300,
      size.width * 1.7 * 0.2975000,
    );

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Side" area (id `back.right_side`) on the back view.
class FarRightBack extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.6393000, size.width * 1.7 * 0.3227917);
    path.cubicTo(
      size.width * 0.6409050,
      size.width * 1.7 * 0.3150833,
      size.width * 0.6440400,
      size.width * 1.7 * 0.3036250,
      size.width * 0.6479700,
      size.width * 1.7 * 0.2975139,
    );
    path.cubicTo(
      size.width * 0.6632050,
      size.width * 1.7 * 0.2738028,
      size.width * 0.6656950,
      size.width * 1.7 * 0.2454250,
      size.width * 0.6656950,
      size.width * 1.7 * 0.2454250,
    );
    path.arcToPoint(
      Offset(size.width * 0.6046450, size.width * 1.7 * 0.2552222),
      radius: Radius.elliptical(
        size.width * 0.2566300,
        size.width * 1.7 * 0.1425722,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.5998700,
      size.width * 1.7 * 0.2780417,
      size.width * 0.5978600,
      size.width * 1.7 * 0.3046833,
      size.width * 0.5976450,
      size.width * 1.7 * 0.3246972,
    );
    path.cubicTo(
      size.width * 0.5980350,
      size.width * 1.7 * 0.3571722,
      size.width * 0.6034300,
      size.width * 1.7 * 0.3876583,
      size.width * 0.6112200,
      size.width * 1.7 * 0.4156000,
    );
    path.cubicTo(
      size.width * 0.6112200,
      size.width * 1.7 * 0.4156000,
      size.width * 0.6423850,
      size.width * 1.7 * 0.4215778,
      size.width * 0.6461000,
      size.width * 1.7 * 0.4198778,
    );
    path.cubicTo(
      size.width * 0.6530200,
      size.width * 1.7 * 0.4167139,
      size.width * 0.6389900,
      size.width * 1.7 * 0.3817111,
      size.width * 0.6385150,
      size.width * 1.7 * 0.3790667,
    );
    path.cubicTo(
      size.width * 0.6380400,
      size.width * 1.7 * 0.3764222,
      size.width * 0.6354500,
      size.width * 1.7 * 0.3566250,
      size.width * 0.6368800,
      size.width * 1.7 * 0.3421222,
    );
    path.cubicTo(
      size.width * 0.6373100,
      size.width * 1.7 * 0.3377833,
      size.width * 0.6382500,
      size.width * 1.7 * 0.3293222,
      size.width * 0.6391950,
      size.width * 1.7 * 0.3231361,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Wrist" area (id `back.left_wrist`) on the back view.
class LeftWrist extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.1358150, size.width * 1.7 * 0.4731528);
    path.cubicTo(
      size.width * 0.1335950,
      size.width * 1.7 * 0.4759306,
      size.width * 0.1409850,
      size.width * 1.7 * 0.4804417,
      size.width * 0.1523150,
      size.width * 1.7 * 0.4832417,
    );
    path.cubicTo(
      size.width * 0.1636450,
      size.width * 1.7 * 0.4860417,
      size.width * 0.1746350,
      size.width * 1.7 * 0.4860639,
      size.width * 0.1768550,
      size.width * 1.7 * 0.4832917,
    );
    path.cubicTo(
      size.width * 0.1790750,
      size.width * 1.7 * 0.4805194,
      size.width * 0.1716800,
      size.width * 1.7 * 0.4760056,
      size.width * 0.1603550,
      size.width * 1.7 * 0.4732056,
    );
    path.cubicTo(
      size.width * 0.1490300,
      size.width * 1.7 * 0.4704056,
      size.width * 0.1380300,
      size.width * 1.7 * 0.4703833,
      size.width * 0.1358150,
      size.width * 1.7 * 0.4731528,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Right Wrist" area (id `back.right_wrist`) on the back view.
class RightWrist extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.8396450, size.width * 1.7 * 0.4732056);
    path.cubicTo(
      size.width * 0.8283050,
      size.width * 1.7 * 0.4760056,
      size.width * 0.8209150,
      size.width * 1.7 * 0.4805194,
      size.width * 0.8231450,
      size.width * 1.7 * 0.4832917,
    );
    path.cubicTo(
      size.width * 0.8253750,
      size.width * 1.7 * 0.4860639,
      size.width * 0.8363500,
      size.width * 1.7 * 0.4860417,
      size.width * 0.8476900,
      size.width * 1.7 * 0.4832417,
    );
    path.cubicTo(
      size.width * 0.8590300,
      size.width * 1.7 * 0.4804417,
      size.width * 0.8664150,
      size.width * 1.7 * 0.4759250,
      size.width * 0.8641900,
      size.width * 1.7 * 0.4731528,
    );
    path.cubicTo(
      size.width * 0.8619650,
      size.width * 1.7 * 0.4703806,
      size.width * 0.8510000,
      size.width * 1.7 * 0.4704056,
      size.width * 0.8396450,
      size.width * 1.7 * 0.4732056,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Outline of the "Left Top of Head" area (id `back.left_top_of_head`) on the
/// back view.
class LeftSkull extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.4511050, size.width * 1.7 * 0.007616667);
    path.lineTo(size.width * 0.4512600, size.width * 1.7 * 0.07319444);
    path.lineTo(size.width * 0.4957600, size.width * 1.7 * 0.07311944);
    path.lineTo(size.width * 0.4956250, size.width * 1.7 * 0.002175000);
    path.cubicTo(
      size.width * 0.4798500,
      size.width * 1.7 * 0.002238889,
      size.width * 0.4635000,
      size.width * 1.7 * 0.003822222,
      size.width * 0.4511050,
      size.width * 1.7 * 0.007616667,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Ring selector for "Sole of Left Foot" (id `back.sole_of_left_foot`) on the
/// back view.
///
/// Drawn as a ring beside the foot, because the real sole is too small
/// to tap.
class LeftFoot extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.1686850, size.width * 1.7 * 0.9766361);
    path.arcToPoint(
      Offset(size.width * 0.2023300, size.width * 1.7 * 0.9688583),
      radius: Radius.elliptical(
        size.width * 0.02576500,
        size.width * 1.7 * 0.01431389,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.1686850, size.width * 1.7 * 0.9766361),
      radius: Radius.elliptical(
        size.width * 0.02576000,
        size.width * 1.7 * 0.01431111,
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

/// Ring selector for "Sole of Right Foot" (id `back.sole_of_right_foot`) on the
/// back view.
///
/// Drawn as a ring beside the foot, because the real sole is too small
/// to tap.
class RightFoot extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.7962750, size.width * 1.7 * 0.9688583);
    path.arcToPoint(
      Offset(size.width * 0.8299250, size.width * 1.7 * 0.9766361),
      radius: Radius.elliptical(
        size.width * 0.02576500,
        size.width * 1.7 * 0.01431389,
      ),
      rotation: 0,
      largeArc: true,
      clockwise: false,
    );
    path.arcToPoint(
      Offset(size.width * 0.7962750, size.width * 1.7 * 0.9688639),
      radius: Radius.elliptical(
        size.width * 0.02576000,
        size.width * 1.7 * 0.01431111,
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

/// Foot shapes on the back view that are painted in skin colour but are
/// never tapped or highlighted. The soles are picked through their ring
/// selectors instead (the regions with `ring: true` in `body_map.dart`).
class UntappableFeet extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.6548550, size.width * 1.7 * 0.9671250);
    path.cubicTo(
      size.width * 0.6569550,
      size.width * 1.7 * 0.9656778,
      size.width * 0.6574650,
      size.width * 1.7 * 0.9621694,
      size.width * 0.6574650,
      size.width * 1.7 * 0.9621694,
    );
    path.arcToPoint(
      Offset(size.width * 0.6429100, size.width * 1.7 * 0.9628278),
      radius: Radius.elliptical(
        size.width * 0.1436000,
        size.width * 1.7 * 0.07977778,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.6347500,
      size.width * 1.7 * 0.9629611,
      size.width * 0.6292150,
      size.width * 1.7 * 0.9628278,
      size.width * 0.6292150,
      size.width * 1.7 * 0.9628278,
    );
    path.lineTo(size.width * 0.6154350, size.width * 1.7 * 0.9738444);
    path.lineTo(size.width * 0.6191600, size.width * 1.7 * 0.9877722);
    path.cubicTo(
      size.width * 0.6191600,
      size.width * 1.7 * 0.9877722,
      size.width * 0.6527600,
      size.width * 1.7 * 0.9685722,
      size.width * 0.6548550,
      size.width * 1.7 * 0.9671278,
    );

    path.moveTo(size.width * 0.3800750, size.width * 1.7 * 0.9877778);
    path.lineTo(size.width * 0.3838000, size.width * 1.7 * 0.9738500);
    path.lineTo(size.width * 0.3700000, size.width * 1.7 * 0.9628361);
    path.cubicTo(
      size.width * 0.3700000,
      size.width * 1.7 * 0.9628361,
      size.width * 0.3644650,
      size.width * 1.7 * 0.9629639,
      size.width * 0.3563050,
      size.width * 1.7 * 0.9628361,
    );
    path.arcToPoint(
      Offset(size.width * 0.3417550, size.width * 1.7 * 0.9621778),
      radius: Radius.elliptical(
        size.width * 0.1435850,
        size.width * 1.7 * 0.07976944,
      ),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.cubicTo(
      size.width * 0.3417550,
      size.width * 1.7 * 0.9621778,
      size.width * 0.3422550,
      size.width * 1.7 * 0.9656861,
      size.width * 0.3443600,
      size.width * 1.7 * 0.9671333,
    );
    path.cubicTo(
      size.width * 0.3464650,
      size.width * 1.7 * 0.9685806,
      size.width * 0.3800750,
      size.width * 1.7 * 0.9877778,
      size.width * 0.3800750,
      size.width * 1.7 * 0.9877778,
    );
    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Seam lines on the back view, painted in the background colour so they
/// look like gaps between parts. Decorative, never tapped.
class BackLines extends CustomClipper<Path> {
  /// Builds the outline for a figure `size.width` wide and
  /// `size.width * 1.7` tall.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width * 0.7725450, size.width * 1.7 * 0.9809889);
    path.lineTo(size.width * 0.6480450, size.width * 1.7 * 0.9809889);
    path.lineTo(size.width * 0.6480450, size.width * 1.7 * 0.9821000);
    path.lineTo(size.width * 0.7725450, size.width * 1.7 * 0.9821000);

    path.moveTo(size.width * 0.3519500, size.width * 1.7 * 0.9815444);
    path.lineTo(size.width * 0.2274500, size.width * 1.7 * 0.9815444);
    path.lineTo(size.width * 0.2274500, size.width * 1.7 * 0.9826556);
    path.lineTo(size.width * 0.3519500, size.width * 1.7 * 0.9826556);

    return path;
  }

  /// Always true. These clippers are only used through [getClip], so this
  /// value does not matter in practice.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
