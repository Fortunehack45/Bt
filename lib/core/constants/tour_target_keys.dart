import 'package:flutter/material.dart';

/// Global keys used by the Spotlight Tour overlay to measure and locate
/// active on-screen targets with 100% pixel precision across any device.
class TourTargetKeys {
  static final GlobalKey ringsHeroKey = GlobalKey(debugLabel: 'tour_rings_hero');
  static final GlobalKey heroCardKey = GlobalKey(debugLabel: 'tour_hero_card');
  static final GlobalKey metricGridKey = GlobalKey(debugLabel: 'tour_metric_grid');
  static final GlobalKey fabKey = GlobalKey(debugLabel: 'tour_fab');
  static final GlobalKey avatarKey = GlobalKey(debugLabel: 'tour_avatar');
}
