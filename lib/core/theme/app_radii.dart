import 'package:flutter/material.dart';

/// Centralized border radius standards for AuraPulse Wellness.
/// Smooth, modern, friendly curves inspired by Reference Image 1.
class AppRadii {
  AppRadii._();

  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double card = 24.0;
  static const double cardLarge = 28.0;
  static const double navigation = 32.0;
  static const double sheet = 32.0;
  static const double full = 999.0;

  // BorderRadius objects
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius roundedCardLarge = BorderRadius.all(Radius.circular(cardLarge));
  static const BorderRadius roundedNav = BorderRadius.all(Radius.circular(navigation));
  static const BorderRadius roundedSheet = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(full));
}
