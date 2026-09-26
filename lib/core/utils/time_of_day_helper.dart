import 'package:flutter/material.dart';

/// Period of the day detected from device local time.
enum DayPeriod {
  morning,
  afternoon,
  evening,
  night,
}

/// Helper utility providing dynamic time-of-day awareness for greetings,
/// contextual icons, and circadian wellness prompts.
class TimeOfDayHelper {
  TimeOfDayHelper._();

  /// Returns the current day period based on device local hour.
  static DayPeriod getPeriod([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return DayPeriod.morning;
    } else if (hour >= 12 && hour < 17) {
      return DayPeriod.afternoon;
    } else if (hour >= 17 && hour < 21) {
      return DayPeriod.evening;
    } else {
      return DayPeriod.night;
    }
  }

  /// Returns the polite, humanized greeting for the current time of day.
  static String getGreeting([DateTime? time]) {
    switch (getPeriod(time)) {
      case DayPeriod.morning:
        return 'Good morning!';
      case DayPeriod.afternoon:
        return 'Good afternoon!';
      case DayPeriod.evening:
        return 'Good evening!';
      case DayPeriod.night:
        return 'Good night!';
    }
  }

  /// Returns a contextual Material icon representing the current time of day.
  static IconData getGreetingIcon([DateTime? time]) {
    switch (getPeriod(time)) {
      case DayPeriod.morning:
        return Icons.wb_sunny_rounded;
      case DayPeriod.afternoon:
        return Icons.light_mode_rounded;
      case DayPeriod.evening:
        return Icons.wb_twilight_rounded;
      case DayPeriod.night:
        return Icons.bedtime_rounded;
    }
  }

  /// Returns a circadian wellness cue matching the time of day.
  static String getCircadianCue([DateTime? time]) {
    switch (getPeriod(time)) {
      case DayPeriod.morning:
        return 'Hydrate early and absorb morning sunlight.';
      case DayPeriod.afternoon:
        return 'Sustained focus, movement, and hydration.';
      case DayPeriod.evening:
        return 'Winding down and preparing for cellular repair.';
      case DayPeriod.night:
        return 'Restorative rest and circadian recovery.';
    }
  }
}
