import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Clipper creating an expanding circular mask originating from a specific anchor point (e.g. top-right corner).
class CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;

  const CircularRevealClipper({
    required this.fraction,
    required this.center,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    if (fraction <= 0.0) {
      return path; // Empty path
    }
    if (fraction >= 1.0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    final maxRadius = _calcMaxRadius(size, center);
    final radius = maxRadius * fraction;

    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  double _calcMaxRadius(Size size, Offset center) {
    final d1 = math.sqrt(center.dx * center.dx + center.dy * center.dy);
    final d2 = math.sqrt((size.width - center.dx) * (size.width - center.dx) + center.dy * center.dy);
    final d3 = math.sqrt(center.dx * center.dx + (size.height - center.dy) * (size.height - center.dy));
    final d4 = math.sqrt((size.width - center.dx) * (size.width - center.dx) + (size.height - center.dy) * (size.height - center.dy));
    return math.max(math.max(d1, d2), math.max(d3, d4));
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) {
    return oldClipper.fraction != fraction || oldClipper.center != center;
  }
}

/// Provides access to the circular reveal theme animator from anywhere in the widget hierarchy.
class ThemeReveal extends StatefulWidget {
  final Widget child;

  const ThemeReveal({super.key, required this.child});

  static ThemeRevealState? of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeRevealState>();
  }

  @override
  State<ThemeReveal> createState() => ThemeRevealState();
}

class ThemeRevealState extends State<ThemeReveal>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();

  late AnimationController _animController;
  late Animation<double> _curvedAnimation;

  ui.Image? _snapshotImage;
  bool _isAnimating = false;
  Offset _origin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _snapshotImage?.dispose();
          _snapshotImage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _snapshotImage?.dispose();
    super.dispose();
  }

  /// Initiates a circular reveal theme transition originating from [origin] (defaults to top-right corner).
  Future<void> changeTheme({
    Offset? origin,
    required VoidCallback onApplyTheme,
  }) async {
    if (_isAnimating) {
      onApplyTheme();
      return;
    }

    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.attached) {
        onApplyTheme();
        return;
      }

      final media = MediaQuery.maybeOf(context);
      final pixelRatio = media?.devicePixelRatio ?? 2.0;
      final screenSize = media?.size ?? const Size(400, 800);

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      if (!mounted) return;

      // Default to top-right corner as indicated in reference red mark
      _origin = origin ?? Offset(screenSize.width, 0);

      setState(() {
        _snapshotImage = image;
        _isAnimating = true;
      });

      // Switch theme in state
      onApplyTheme();

      // Run forward from 0.0 to 1.0
      _animController.forward(from: 0.0);
    } catch (_) {
      // Fallback for tests or unsupported environments
      onApplyTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnimating && _snapshotImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // 1. Frozen snapshot of previous theme
          Positioned.fill(
            child: RawImage(
              image: _snapshotImage,
              fit: BoxFit.cover,
            ),
          ),

          // 2. Live app with new theme, revealed by expanding circular mask
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _curvedAnimation,
              builder: (ctx, child) {
                return ClipPath(
                  clipper: CircularRevealClipper(
                    fraction: _curvedAnimation.value,
                    center: _origin,
                  ),
                  child: child,
                );
              },
              child: RepaintBoundary(
                key: _boundaryKey,
                child: widget.child,
              ),
            ),
          ),
        ],
      );
    }

    return RepaintBoundary(
      key: _boundaryKey,
      child: widget.child,
    );
  }
}
