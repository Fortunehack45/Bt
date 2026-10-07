import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/native_platform_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/circular_theme_reveal.dart';
import '../domain/state/wellness_provider.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/security/screens/app_lock_screen.dart';
import 'app_shell.dart';

/// The root Wellnest application widget.
class WellnestApp extends StatefulWidget {
  const WellnestApp({super.key});

  @override
  State<WellnestApp> createState() => _WellnestAppState();
}

typedef BiothrixApp = WellnestApp;

class _WellnestAppState extends State<WellnestApp> with WidgetsBindingObserver {
  final WellnessProvider _wellnessProvider = WellnessProvider();
  bool _showSplash = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPersistentOnboarding();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _wellnessProvider.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _wellnessProvider.onAppResumed();
    }
  }

  Future<void> _checkPersistentOnboarding() async {
    final isDone = await NativePlatformService.instance.isOnboardingCompleted();
    if (mounted && isDone) {
      setState(() {
        _showOnboarding = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
          final isDark = _wellnessProvider.themeMode == ThemeMode.dark;
          final overlayStyle = SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          );

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: MaterialApp(
              title: 'Wellnest Wellness',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: _wellnessProvider.themeMode,
              builder: (ctx, child) {
                return ThemeReveal(child: child ?? const SizedBox.shrink());
              },
              home: _buildHomeView(),
            ),
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
          NativePlatformService.instance.setOnboardingCompleted(true);
        },
      );
    }

    // App Lock Gate: If 6-digit PIN / Biometric lock is active, show the lock screen
    if (_wellnessProvider.isAppLockEnabled && _wellnessProvider.isAppLocked) {
      return AppLockScreen(
        mode: AppLockMode.unlock,
        canCancel: false,
        onUnlocked: () {
          _wellnessProvider.unlockApp();
        },
      );
    }

    return const AppShell();
  }
}
