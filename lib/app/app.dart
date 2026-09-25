import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../domain/state/wellness_provider.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import 'app_shell.dart';

/// The root Biothrix application widget.
class BiothrixApp extends StatefulWidget {
  const BiothrixApp({super.key});

  @override
  State<BiothrixApp> createState() => _BiothrixAppState();
}

class _BiothrixAppState extends State<BiothrixApp> {
  final WellnessProvider _wellnessProvider = WellnessProvider();
  bool _showSplash = true;
  bool _showOnboarding = true;

  @override
  void dispose() {
    _wellnessProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WellnessStateScope(
      provider: _wellnessProvider,
      child: AnimatedBuilder(
        animation: _wellnessProvider,
        builder: (context, _) {
          return MaterialApp(
            title: 'Biothrix Wellness',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _wellnessProvider.themeMode,
            home: _buildHomeView(),
          );
        },
      ),
    );
  }

  Widget _buildHomeView() {
    if (_showSplash) {
      return SplashScreen(
        onFinish: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(
        onGetStarted: () {
          setState(() {
            _showOnboarding = false;
          });
        },
      );
    }

    return const AppShell();
  }
}
