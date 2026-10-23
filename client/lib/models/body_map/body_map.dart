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

/// The body map: every region the figure can draw, and what it is called.
///
/// Generated alongside `front_paths.dart` and `back_paths.dart` from the same
/// traced SVG — the three files change together or not at all.
///
/// This is the client's half of the contract with the agent. The agent picks
/// *which* of these regions a step offers, by [BodyRegion.id]; the geometry
/// and the canonical name stay here, because neither is something a language
/// model can invent reliably:
///
/// - **Geometry** is five thousand lines of traced bezier coordinates. A
///   model asked to produce them returns a scribble, and a different scribble
///   every time it is asked.
/// - **The canonical name** is what ends up in the stored entry and in the
///   PDF the doctor reads. Reworded per session, two days of lower-back pain
///   would no longer compare. The agent may still reword the *displayed*
///   label; only what is stored comes from here.
///
/// [regionIds] is exported in the catalog JSON as a schema enum, so an id the
/// model invents is rejected by the server's validator before it reaches the
/// wire.
library;

import 'package:flutter/material.dart';

import 'back_paths.dart';
import 'front_paths.dart';

/// Height of the figure as a multiple of its width.
///
/// Baked into every coordinate in `front_paths.dart` and `back_paths.dart`
/// (`size.width * 1.7`), so a painter that uses any other ratio draws a body
/// that does not line up with its own hit-testing.
const double kBodyAspect = 1.7;

/// Which side of the figure a region is on.
///
/// The picker shows one side at a time, and the user flips between them.
enum BodyView {
  /// The body seen from the front: face, chest, stomach, palms, toes.
  front('front', 'Front'),

  /// The body seen from behind: back of the head, spine, buttocks, heels.
  back('back', 'Back');

  /// Creates a side with its JSON [id] and its on-screen [label].
  const BodyView(this.id, this.label);

  /// The value used in JSON and as the start of every region id on this
  /// side, e.g. `front` in `front.left_knee`.
  final String id;

  /// The word shown on the Front / Back switch.
  final String label;

  /// The opposite side.
  BodyView get other => this == front ? back : front;

  /// The side whose [id] is [id], or null if it matches none (for example
  /// when the agent did not send a `view`).
  static BodyView? byId(String? id) {
    for (final BodyView v in values) {
      if (v.id == id) return v;
    }
    return null;
  }
}

/// One region of the figure.
@immutable
class BodyRegion {
  /// Creates a region. Only [bodyMap] below should call this.
  const BodyRegion({
    required this.id,
    required this.label,
    required this.view,
    required this.clipper,
    this.decorative = false,
    this.tracery = false,
    this.ring = false,
  });

  /// Stable and view-qualified: `front.left_knee`. What the agent sends.
  final String id;

  /// The canonical name. This is what is stored in the entry.
  final String label;

  /// The side of the figure this region is drawn on.
  final BodyView view;

  /// The outline, in fractions of the painter's width.
  final CustomClipper<Path> clipper;

  /// Part of the drawing rather than a place that can hurt: painted, never
  /// offered, never hit-tested.
  final bool decorative;

  /// A decorative region drawn in the separating colour rather than in skin —
  /// the seams on the head, the stems reaching out to the digit selectors.
  final bool tracery;

  /// Drawn as a ring set slightly apart from the body. Fingers, toes and
  /// soles are far too small to tap where they actually are, so the traced
  /// artwork puts a selector beside the hand or foot instead.
  final bool ring;
}

/// Every region, front then back, in paint order. Later shapes draw over
/// earlier ones, so hit-testing walks the list backwards.
final List<BodyRegion> bodyMap = <BodyRegion>[
  BodyRegion(
    id: 'front.forehead',
    label: 'Forehead',
    view: BodyView.front,
    clipper: Forehead(),
  ),
  BodyRegion(
    id: 'front.left_sinus',
    label: 'Left Sinus',
    view: BodyView.front,
    clipper: LeftFace(),
  ),
  BodyRegion(
    id: 'front.right_sinus',
    label: 'Right Sinus',
    view: BodyView.front,
    clipper: RightFace(),
  ),
  BodyRegion(
    id: 'front.left_jaw',
    label: 'Left Jaw',
    view: BodyView.front,
    clipper: LeftMouth(),
  ),
  BodyRegion(
    id: 'front.right_jaw',
    label: 'Right Jaw',
    view: BodyView.front,
    clipper: RightMouth(),
  ),
  BodyRegion(
    id: 'front.throat',
    label: 'Throat',
    view: BodyView.front,
    clipper: Neck(),
  ),
  BodyRegion(
    id: 'front.left_collar_bone',
    label: 'Left Collar Bone',
    view: BodyView.front,
    clipper: LeftCollarBone(),
  ),
  BodyRegion(
    id: 'front.right_collar_bone',
    label: 'Right Collar Bone',
    view: BodyView.front,
    clipper: RightCollarBone(),
  ),
  BodyRegion(
    id: 'front.left_shoulder',
    label: 'Left Shoulder',
    view: BodyView.front,
    clipper: LeftDeltoid(),
  ),
  BodyRegion(
    id: 'front.right_shoulder',
    label: 'Right Shoulder',
    view: BodyView.front,
    clipper: RightDeltoid(),
  ),
  BodyRegion(
    id: 'front.sternum',
    label: 'Sternum',
    view: BodyView.front,
    clipper: MidChest(),
  ),
  BodyRegion(
    id: 'front.left_chest',
    label: 'Left Chest',
    view: BodyView.front,
    clipper: LeftPec(),
  ),
  BodyRegion(
    id: 'front.right_chest',
    label: 'Right Chest',
    view: BodyView.front,
    clipper: RightPec(),
  ),
  BodyRegion(
    id: 'front.left_ribs',
    label: 'Left Ribs',
    view: BodyView.front,
    clipper: LeftLowerPec(),
  ),
  BodyRegion(
    id: 'front.right_ribs',
    label: 'Right Ribs',
    view: BodyView.front,
    clipper: RightLowerPec(),
  ),
  BodyRegion(
    id: 'front.stomach',
    label: 'Stomach',
    view: BodyView.front,
    clipper: MidAbdomin(),
  ),
  BodyRegion(
    id: 'front.left_abdomen',
    label: 'Left Abdomen',
    view: BodyView.front,
    clipper: LeftAbdomin(),
  ),
  BodyRegion(
    id: 'front.right_abdomen',
    label: 'Right Abdomen',
    view: BodyView.front,
    clipper: RightAbdomin(),
  ),
  BodyRegion(
    id: 'front.left_pelvis',
    label: 'Left Pelvis',
    view: BodyView.front,
    clipper: FrontLeftPelvic(),
  ),
  BodyRegion(
    id: 'front.right_pelvis',
    label: 'Right Pelvis',
    view: BodyView.front,
    clipper: FrontRightPelvic(),
  ),
  BodyRegion(
    id: 'front.left_hip',
    label: 'Left Hip',
    view: BodyView.front,
    clipper: FrontLeftHip(),
  ),
  BodyRegion(
    id: 'front.right_hip',
    label: 'Right Hip',
    view: BodyView.front,
    clipper: FrontRightHip(),
  ),
  BodyRegion(
    id: 'front.left_groin',
    label: 'Left Groin',
    view: BodyView.front,
    clipper: LeftHipFlexer(),
  ),
  BodyRegion(
    id: 'front.right_groin',
    label: 'Right Groin',
    view: BodyView.front,
    clipper: RightHipFlexer(),
  ),
  BodyRegion(
    id: 'front.left_thigh',
    label: 'Left Thigh',
    view: BodyView.front,
    clipper: LeftQuad(),
  ),
  BodyRegion(
    id: 'front.right_thigh',
    label: 'Right Thigh',
    view: BodyView.front,
    clipper: RightQuad(),
  ),
  BodyRegion(
    id: 'front.left_knee',
    label: 'Left Knee',
    view: BodyView.front,
    clipper: LeftKnee(),
  ),
  BodyRegion(
    id: 'front.right_knee',
    label: 'Right Knee',
    view: BodyView.front,
    clipper: RightKnee(),
  ),
  BodyRegion(
    id: 'front.left_shin',
    label: 'Left Shin',
    view: BodyView.front,
    clipper: LeftShin(),
  ),
  BodyRegion(
    id: 'front.right_shin',
    label: 'Right Shin',
    view: BodyView.front,
    clipper: RightShin(),
  ),
  BodyRegion(
    id: 'front.left_ankle',
    label: 'Left Ankle',
    view: BodyView.front,
    clipper: LeftFrontAnkle(),
  ),
  BodyRegion(
    id: 'front.right_ankle',
    label: 'Right Ankle',
    view: BodyView.front,
    clipper: RightFrontAnkle(),
  ),
  BodyRegion(
    id: 'front.left_foot',
    label: 'Left Foot',
    view: BodyView.front,
    clipper: LeftFrontFoot(),
  ),
  BodyRegion(
    id: 'front.right_foot',
    label: 'Right Foot',
    view: BodyView.front,
    clipper: RightFrontFoot(),
  ),
  BodyRegion(
    id: 'front.left_brachial',
    label: 'Left Brachial',
    view: BodyView.front,
    clipper: LeftBicep(),
  ),
  BodyRegion(
    id: 'front.right_brachial',
    label: 'Right Brachial',
    view: BodyView.front,
    clipper: RightBicep(),
  ),
  BodyRegion(
    id: 'front.left_antecubital',
    label: 'Left Antecubital',
    view: BodyView.front,
    clipper: LeftInnerElbow(),
  ),
  BodyRegion(
    id: 'front.right_antecubital',
    label: 'Right Antecubital',
    view: BodyView.front,
    clipper: RightInnerElbow(),
  ),
  BodyRegion(
    id: 'front.left_anterior_forerarm',
    label: 'Left Anterior Forerarm',
    view: BodyView.front,
    clipper: LeftInnerForearm(),
  ),
  BodyRegion(
    id: 'front.right_anterior_forerarm',
    label: 'Right Anterior Forerarm',
    view: BodyView.front,
    clipper: RightInnerForearm(),
  ),
  BodyRegion(
    id: 'front.left_palm',
    label: 'Left Palm',
    view: BodyView.front,
    clipper: LeftInnerHand(),
  ),
  BodyRegion(
    id: 'front.right_palm',
    label: 'Right Palm',
    view: BodyView.front,
    clipper: RightInnerHand(),
  ),
  BodyRegion(
    id: 'front.left_thumb',
    label: 'Left Thumb',
    view: BodyView.front,
    clipper: LeftThumb(),
  ),
  BodyRegion(
    id: 'front.right_thumb',
    label: 'Right Thumb',
    view: BodyView.front,
    clipper: RightThumb(),
  ),
  BodyRegion(
    id: 'front.left_index_finger',
    label: 'Left Index Finger',
    view: BodyView.front,
    clipper: LeftPointerFinger(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_index_finger',
    label: 'Right Index Finger',
    view: BodyView.front,
    clipper: RightPointerFinger(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.left_middle_finger',
    label: 'Left Middle Finger',
    view: BodyView.front,
    clipper: LeftMiddleFinger(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_middle_finger',
    label: 'Right Middle Finger',
    view: BodyView.front,
    clipper: RightMiddleFinger(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_ring_finger',
    label: 'Right Ring Finger',
    view: BodyView.front,
    clipper: RightRingFinger(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.left_ring_finger',
    label: 'Left Ring Finger',
    view: BodyView.front,
    clipper: LeftRingFinger(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.left_pinky',
    label: 'Left Pinky',
    view: BodyView.front,
    clipper: LeftPinky(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_pinky',
    label: 'Right Pinky',
    view: BodyView.front,
    clipper: RightPinky(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.left_pinky_toe',
    label: 'Left Pinky Toe',
    view: BodyView.front,
    clipper: LeftToe1(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.left_no4_toe',
    label: 'Left #4 Toe',
    view: BodyView.front,
    clipper: LeftToe2(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.left_middle_toe',
    label: 'Left Middle Toe',
    view: BodyView.front,
    clipper: LeftToe3(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.left_no2_toe',
    label: 'Left #2 Toe',
    view: BodyView.front,
    clipper: LeftToe4(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.left_big_toe',
    label: 'Left Big Toe',
    view: BodyView.front,
    clipper: LeftToe5(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_pinky_toe',
    label: 'Right Pinky Toe',
    view: BodyView.front,
    clipper: RightToe1(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_no4_toe',
    label: 'Right #4 Toe',
    view: BodyView.front,
    clipper: RightToe2(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_middle_toe',
    label: 'Right Middle Toe',
    view: BodyView.front,
    clipper: RightToe3(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_no2_toe',
    label: 'Right #2 Toe',
    view: BodyView.front,
    clipper: RightToe4(),
    ring: true,
  ),
  BodyRegion(
    id: 'front.right_big_toe',
    label: 'Right Big Toe',
    view: BodyView.front,
    clipper: RightToe5(),
    ring: true,
  ),
  BodyRegion(
    id: 'front._untappablefingers',
    label: 'Untappable Fingers',
    view: BodyView.front,
    clipper: UntappableFingers(),
    decorative: true,
  ),
  BodyRegion(
    id: 'front._lines',
    label: 'Lines',
    view: BodyView.front,
    clipper: Lines(),
    decorative: true,
    tracery: true,
  ),
  BodyRegion(
    id: 'back.left_top_of_head',
    label: 'Left Top of Head',
    view: BodyView.back,
    clipper: LeftSkull(),
  ),
  BodyRegion(
    id: 'back.right_top_of_head',
    label: 'Right Top of Head',
    view: BodyView.back,
    clipper: RightSkull(),
  ),
  BodyRegion(
    id: 'back.left_temple',
    label: 'Left Temple',
    view: BodyView.back,
    clipper: LeftEar(),
  ),
  BodyRegion(
    id: 'back.right_temple',
    label: 'Right Temple',
    view: BodyView.back,
    clipper: RightEar(),
  ),
  BodyRegion(
    id: 'back.base_of_head',
    label: 'Base of Head',
    view: BodyView.back,
    clipper: LowerHead(),
  ),
  BodyRegion(
    id: 'back.left_neck',
    label: 'Left Neck',
    view: BodyView.back,
    clipper: LeftNeck(),
  ),
  BodyRegion(
    id: 'back.right_neck',
    label: 'Right Neck',
    view: BodyView.back,
    clipper: RightNeck(),
  ),
  BodyRegion(
    id: 'back.left_shoulder_blade',
    label: 'Left Shoulder Blade',
    view: BodyView.back,
    clipper: LeftShoulder(),
  ),
  BodyRegion(
    id: 'back.right_shoulder_blade',
    label: 'Right Shoulder Blade',
    view: BodyView.back,
    clipper: RightShoulder(),
  ),
  BodyRegion(
    id: 'back.left_hamstring',
    label: 'Left Hamstring',
    view: BodyView.back,
    clipper: LeftHamstring(),
  ),
  BodyRegion(
    id: 'back.right_hamstring',
    label: 'Right Hamstring',
    view: BodyView.back,
    clipper: RightHamstring(),
  ),
  BodyRegion(
    id: 'back.left_buttock',
    label: 'Left Buttock',
    view: BodyView.back,
    clipper: LeftGlute(),
  ),
  BodyRegion(
    id: 'back.right_buttock',
    label: 'Right Buttock',
    view: BodyView.back,
    clipper: RightGlute(),
  ),
  BodyRegion(
    id: 'back.left_popliteal',
    label: 'Left Popliteal',
    view: BodyView.back,
    clipper: LeftBackKnee(),
  ),
  BodyRegion(
    id: 'back.right_popliteal',
    label: 'Right Popliteal',
    view: BodyView.back,
    clipper: RightBackKnee(),
  ),
  BodyRegion(
    id: 'back.right_calf',
    label: 'Right Calf',
    view: BodyView.back,
    clipper: RightCalf(),
  ),
  BodyRegion(
    id: 'back.left_calf',
    label: 'Left Calf',
    view: BodyView.back,
    clipper: LeftCalf(),
  ),
  BodyRegion(
    id: 'back.left_s_i_joint',
    label: 'Left S. I. Joint',
    view: BodyView.back,
    clipper: LeftBackPelvic(),
  ),
  BodyRegion(
    id: 'back.right_s_i_joint',
    label: 'Right S. I. Joint',
    view: BodyView.back,
    clipper: RightBackPelvic(),
  ),
  BodyRegion(
    id: 'back.left_achilles',
    label: 'Left Achilles',
    view: BodyView.back,
    clipper: LeftAchilles(),
  ),
  BodyRegion(
    id: 'back.right_achilles',
    label: 'Right Achilles',
    view: BodyView.back,
    clipper: RightAchilles(),
  ),
  BodyRegion(
    id: 'back.left_heel',
    label: 'Left Heel',
    view: BodyView.back,
    clipper: LeftHeel(),
  ),
  BodyRegion(
    id: 'back.right_heel',
    label: 'Right Heel',
    view: BodyView.back,
    clipper: RightHeel(),
  ),
  BodyRegion(
    id: 'back.cervical_spine',
    label: 'Cervical Spine',
    view: BodyView.back,
    clipper: UpperSpine(),
  ),
  BodyRegion(
    id: 'back.thoracic_spine',
    label: 'Thoracic Spine',
    view: BodyView.back,
    clipper: MidSpine(),
  ),
  BodyRegion(
    id: 'back.lumbar_spine',
    label: 'Lumbar Spine',
    view: BodyView.back,
    clipper: LowerSpine(),
  ),
  BodyRegion(
    id: 'back.sacrum',
    label: 'Sacrum',
    view: BodyView.back,
    clipper: Tailbone(),
  ),
  BodyRegion(
    id: 'back.left_lower_back',
    label: 'Left Lower Back',
    view: BodyView.back,
    clipper: LeftLowerBack(),
  ),
  BodyRegion(
    id: 'back.left_middle_back',
    label: 'Left Middle Back',
    view: BodyView.back,
    clipper: LeftMidBack(),
  ),
  BodyRegion(
    id: 'back.right_lower_back',
    label: 'Right Lower Back',
    view: BodyView.back,
    clipper: RightLowerBack(),
  ),
  BodyRegion(
    id: 'back.right_middle_back',
    label: 'Right Middle Back',
    view: BodyView.back,
    clipper: RightMidBack(),
  ),
  BodyRegion(
    id: 'back.left_side',
    label: 'Left Side',
    view: BodyView.back,
    clipper: FarLeftBack(),
  ),
  BodyRegion(
    id: 'back.right_side',
    label: 'Right Side',
    view: BodyView.back,
    clipper: FarRightBack(),
  ),
  BodyRegion(
    id: 'back.right_elbow',
    label: 'Right Elbow',
    view: BodyView.back,
    clipper: RightElbow(),
  ),
  BodyRegion(
    id: 'back.left_elbow',
    label: 'Left Elbow',
    view: BodyView.back,
    clipper: LeftElbow(),
  ),
  BodyRegion(
    id: 'back.left_wrist',
    label: 'Left Wrist',
    view: BodyView.back,
    clipper: LeftWrist(),
  ),
  BodyRegion(
    id: 'back.right_wrist',
    label: 'Right Wrist',
    view: BodyView.back,
    clipper: RightWrist(),
  ),
  BodyRegion(
    id: 'back.back_of_left_hand',
    label: 'Back of Left Hand',
    view: BodyView.back,
    clipper: LeftHand(),
  ),
  BodyRegion(
    id: 'back.back_of_right_hand',
    label: 'Back of Right Hand',
    view: BodyView.back,
    clipper: RightHand(),
  ),
  BodyRegion(
    id: 'back.right_tricep',
    label: 'Right Tricep',
    view: BodyView.back,
    clipper: RightUpperArm(),
  ),
  BodyRegion(
    id: 'back.left_tricep',
    label: 'Left Tricep',
    view: BodyView.back,
    clipper: LeftUpperArm(),
  ),
  BodyRegion(
    id: 'back.left_posterior_forearm',
    label: 'Left Posterior Forearm',
    view: BodyView.back,
    clipper: LeftForearm(),
  ),
  BodyRegion(
    id: 'back.right_posterior_forearm',
    label: 'Right Posterior Forearm',
    view: BodyView.back,
    clipper: RightForearm(),
  ),
  BodyRegion(
    id: 'back.sole_of_left_foot',
    label: 'Sole of Left Foot',
    view: BodyView.back,
    clipper: LeftFoot(),
    ring: true,
  ),
  BodyRegion(
    id: 'back.sole_of_right_foot',
    label: 'Sole of Right Foot',
    view: BodyView.back,
    clipper: RightFoot(),
    ring: true,
  ),
  BodyRegion(
    id: 'back._untappablefeet',
    label: 'Left Line',
    view: BodyView.back,
    clipper: UntappableFeet(),
    decorative: true,
  ),
  BodyRegion(
    id: 'back._backlines',
    label: 'Right Line',
    view: BodyView.back,
    clipper: BackLines(),
    decorative: true,
    tracery: true,
  ),
];

/// Regions on one side, in paint order.
///
/// Builds a new list on every call; the lists are short, so this is cheap.
List<BodyRegion> regionsFor(BodyView view) =>
    bodyMap.where((BodyRegion r) => r.view == view).toList(growable: false);

/// Every region a patient can actually tap, by id.
///
/// Decorative shapes are left out. Used to check ids sent by the agent.
final Map<String, BodyRegion> selectableRegions = <String, BodyRegion>{
  for (final BodyRegion r in bodyMap)
    if (!r.decorative) r.id: r,
};

/// The ids the agent may send, sorted. Exported into the catalog schema.
final List<String> regionIds = selectableRegions.keys.toList()..sort();
