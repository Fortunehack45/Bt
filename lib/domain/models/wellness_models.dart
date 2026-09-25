import 'package:flutter/material.dart';

class HabitItem {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final int streakDays;
  final bool isCompletedToday;

  const HabitItem({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.streakDays,
    this.isCompletedToday = false,
  });

  HabitItem copyWith({
    String? id,
    String? title,
    String? category,
    IconData? icon,
    Color? color,
    int? streakDays,
    bool? isCompletedToday,
  }) {
    return HabitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      streakDays: streakDays ?? this.streakDays,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }
}

class MealEntry {
  final String id;
  final String name;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final int calories;
  final String timeString;
  final String description;

  const MealEntry({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.timeString,
    required this.description,
  });
}

class WellnessRecommendation {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const WellnessRecommendation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}
