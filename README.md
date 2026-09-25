# AuraPulse Wellness — Cross-Platform Flutter Mobile Application

A premium, cross-platform mobile wellness application built with Flutter & Dart for iOS and Android, inspired by the high-clarity wellness dashboard and the official iOS/Android 16px grid guidelines.

---

## Visual Design Hierarchy

```
                    MAIN APPLICATION CONTENT
                                │
                    Clean + Solid + Readable
                                │
                                ↓
                    ┌────────────────────────┐
                    │   Solid Wellness Cards │
                    │   Interactive Charts   │
                    │   Daily Metrics        │
                    │   Calendar Strip       │
                    └────────────────────────┘

                                ↓

                    FLOATING & SYSTEM INTERFACE
                                │
                         Glass Treatment
                                │
                                ↓
         ┌──────────────────────────────────────────────┐
         │                                              │
         │   • Android: Frosted Glass Material          │
         │     - Backdrop blur (sigma 16.0)             │
         │     - Soft translucent tint                  │
         │     - Subtle diffused borders & elevation    │
         │                                              │
         │   • iOS: Liquid-Glass-Inspired Material      │
         │     - Specular layered highlights            │
         │     - Background blur (sigma 24.0)           │
         │     - Squircle geometry & fluid depth        │
         │                                              │
         │   Elements using Glass:                      │
         │   - Floating Bottom Navigation Bar           │
         │   - Central Squircle [+] Action Button       │
         │   - Quick-Action Bottom Sheet                │
         │   - Floating Header Buttons (Back/More)      │
         └──────────────────────────────────────────────┘
```

---

## 16px Grid Guideline Implementation

Adhering strictly to Reference Image 2:
- **Margins**: 16px outer page margins on iOS and Android.
- **Gutters**: 16px spacing between dual-column metric cards.
- **Safe Area Insets**:
  - Dynamically calculates bottom safe area (iOS Home Indicator: 34px, Android gesture bar: 48px).
  - Ensures scrolling content floats behind the floating glass navigation bar with proper bottom padding (`AppSpacing.contentBottomPadding`).
  - Edge-to-edge transparent system bars for seamless immersion.

---

## Key Features & Screen Structure

1. **Splash & Onboarding**:
   - Animated pulse ring logo.
   - 3-step interactive onboarding highlighting wellness tracking, platform-adaptive glass UI, and daily habits.

2. **Home Dashboard (Reference Image 1 Screen 1)**:
   - Header with greeting, user profile avatar, date indicator, and floating glass utility icons.
   - **Weekly Progress Hero Card**: Lime green gradient (`#D6F57D`), "⚡ Daily intake" chip, "Your Weekly Progress" headline, and 6/7 days circular progress ring (72%).
   - **Dual Metric Summary**: "Step to walk" (5,500 steps, orange footprint badge) & "Drink Water" (12 glass, blue droplet badge).
   - **Interactive Weekly Calendar Strip**: August 2025 with week selector, Wednesday highlighted in soft lime pill.
   - **Meal Tracker**: Breakfast (456-512 kcal), Lunch (456-512 kcal), food avatars, and quick add buttons.
   - **Daily Recommendations**: Horizontally scrollable wellness advice cards.

3. **Statistics (Reference Image 1 Screen 2)**:
   - Header with floating glass back button, centered title, and more options button.
   - **Calories Hero**: "1250 Kcal" with "Target: 1920 Kcal".
   - **Weekly Bar Chart**: Mon-Sun with percentages (44%, 34%, 110%, 47%, 32%, 79%, 24%). Wednesday highlighted at 110% in solid wellness green (`#92DF2B`). Tapping any day updates the metric interactively.
   - **2x2 Metric Grid**:
     - **Exercise**: 2.0 hours + mini sparkline bar chart.
     - **BPM**: 86 bpm + live-feeling red ECG waveform line.
     - **Weight**: 68.4 kg + progress trend bar.
     - **Water**: 2.8 L + filled droplet indicators.

4. **Floating Glass Navigation Bar & Central Action Button**:
   - Elevated squircle central [+] button with soft wellness glow.
   - Triggers the **Platform-Adaptive Glass Quick-Action Panel** to log:
     - Water (+250ml)
     - Activity (Walking/Workouts)
     - Meals (Breakfast, Lunch, Dinner with kcal)
     - Sleep (Hours & recovery)
     - Habits (Custom daily routines)

5. **Dedicated Wellness Modules**:
   - **Progress**: Streaks, 30-day activity consistency matrix.
   - **Hydration**: Liquid intake visualizer and rapid logging.
   - **Activity**: Walking, running, distance in km, calories burned.
   - **Sleep**: Bedtime consistency, quality score (88%), and sleep stages (Deep, REM, Light).
   - **Habits**: Daily checklist with animated checkboxes, streak counters, and category filters.
   - **Nutrition**: Macronutrient balance (Carbs 45%, Protein 30%, Fats 25%) and food log.
   - **Profile & Settings**: Dark Mode toggle, units selector (Metric/Imperial), smart reminders, connected wearable sync.

6. **Dark Mode & Accessibility**:
   - Full dark theme with dark frosted/liquid glass and high-contrast dark slate content surfaces.
   - Semantic labels, accessible touch targets, and tactile haptic feedback.

---

## Project Structure

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp with Light & Dark themes
│   └── app_shell.dart             # Root shell with floating glass nav & page stack
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        # Wellness green, coral, water blue, neutrals
│   │   ├── app_typography.dart    # Typography scale
│   │   ├── app_spacing.dart       # 16px grid margin & gutter standards
│   │   ├── app_radii.dart         # Border radius standards
│   │   ├── app_shadows.dart       # Elevation shadows
│   │   ├── app_animations.dart    # Timing and easing curves
│   │   ├── glass_tokens.dart      # Platform glass blur and specular highlights
│   │   └── app_theme.dart         # Light & Dark ThemeData
│   ├── glass/
│   │   ├── platform_glass_surface.dart       # Core frosted vs liquid glass container
│   │   ├── platform_glass_navigation_bar.dart# Floating nav bar with central [+]
│   │   ├── platform_glass_button.dart        # Floating utility button
│   │   ├── platform_glass_bottom_sheet.dart  # Modal glass sheet
│   │   └── platform_glass_quick_action_panel.dart# Quick action launcher
│   ├── widgets/
│   │   ├── solid_wellness_card.dart          # Clean solid card base
│   │   ├── circular_progress_ring.dart       # Custom animated progress ring
│   │   ├── weekly_bar_chart.dart             # Custom weekly bar chart with highlight
│   │   ├── sparkline_chart.dart              # Exercise mini sparkline
│   │   ├── ecg_waveform.dart                 # BPM heartbeat waveform
│   │   ├── metric_badge.dart                 # Icon chip badge
│   │   ├── skeleton_loader.dart              # Shimmer loader
│   │   └── empty_state_view.dart             # Clean empty state view
│   └── utils/
│       ├── haptic_service.dart               # Haptic feedback utility
│       └── responsive_layout.dart            # Grid guideline helper
├── domain/
│   ├── models/
│   │   └── wellness_models.dart              # Habit, meal, recommendation models
│   └── state/
│       └── wellness_provider.dart            # Reactive state management
└── features/
    ├── onboarding/                           # Splash & Onboarding
    ├── home/                                 # Home Dashboard
    ├── statistics/                           # Statistics Screen
    ├── progress/                             # Streaks & Trends
    ├── hydration/                            # Water Tracker
    ├── activity/                             # Movement & Workouts
    ├── sleep/                                # Sleep Stages & Rest
    ├── habits/                               # Habits Checklist
    ├── nutrition/                            # Meal & Macro Log
    └── profile/                              # Profile & Settings
```

---

## Future App Icon Integration

As requested, the application has been prepared for the final icon/mascot:
- **Android**: Adaptive icon manifest configured at `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` with background color `#92DF2B`.
- **iOS**: Asset catalog placeholder ready at `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`.
- The final mascot icon can be dropped into the project when supplied without requiring UI refactoring.
