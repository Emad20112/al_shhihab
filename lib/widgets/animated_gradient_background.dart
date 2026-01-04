import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ANIMATED GRADIENT BACKGROUND - Dynamic Glass Canvas
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Creates a stunning animated background for glassmorphism effects.
/// Features floating gradient orbs that move slowly and blend together.
///
/// • Light Mode: Soft pastel orbs (ice blue, lavender, pink)
/// • Dark Mode: Deep cosmic orbs (purple, blue, void) with subtle glow
/// ═══════════════════════════════════════════════════════════════════════════

class AnimatedGradientBackground extends StatefulWidget {
  /// Child widget to display on top of the background
  final Widget? child;

  /// Number of floating orbs (default: 4)
  final int orbCount;

  /// Animation duration for orb movement (default: 15 seconds)
  final Duration animationDuration;

  /// Whether to show the mesh gradient overlay
  final bool showMeshOverlay;

  const AnimatedGradientBackground({
    super.key,
    this.child,
    this.orbCount = 4,
    this.animationDuration = const Duration(seconds: 15),
    this.showMeshOverlay = true,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<_FloatingOrb> _orbs;

  @override
  void initState() {
    super.initState();
    _initializeOrbs();
  }

  void _initializeOrbs() {
    final random = math.Random(42); // Fixed seed for consistent orb positions
    _controllers = [];
    _animations = [];
    _orbs = [];

    for (int i = 0; i < widget.orbCount; i++) {
      // Create controller with varying durations
      final controller = AnimationController(
        duration: Duration(
          seconds: widget.animationDuration.inSeconds + random.nextInt(10),
        ),
        vsync: this,
      );

      // Create looping animation
      final animation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      // Start at random phase
      controller.value = random.nextDouble();
      controller.repeat(reverse: true);

      _controllers.add(controller);
      _animations.add(animation);

      // Create orb with random properties
      _orbs.add(
        _FloatingOrb(
          startX: random.nextDouble(),
          startY: random.nextDouble(),
          endX: random.nextDouble(),
          endY: random.nextDouble(),
          size: 200 + random.nextDouble() * 300,
          colorIndex: i % 3,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkBackgroundGradient
            : AppColors.lightBackgroundGradient,
      ),
      child: Stack(
        children: [
          // Floating gradient orbs
          ..._buildFloatingOrbs(isDark, size),

          // Mesh gradient overlay for depth
          if (widget.showMeshOverlay) _buildMeshOverlay(isDark),

          // Noise texture overlay for realism
          _buildNoiseOverlay(isDark),

          // Child content
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  List<Widget> _buildFloatingOrbs(bool isDark, Size size) {
    final List<Color> lightColors = [
      const Color(0xFFB8E0FF).withValues(alpha: 0.6), // Soft blue
      const Color(0xFFE8D0FF).withValues(alpha: 0.5), // Lavender
      const Color(0xFFFFD0E8).withValues(alpha: 0.5), // Pink
    ];

    final List<Color> darkColors = [
      const Color(0xFF4A00E0).withValues(alpha: 0.4), // Deep purple
      const Color(0xFF0066FF).withValues(alpha: 0.3), // Electric blue
      const Color(0xFF00D9FF).withValues(alpha: 0.25), // Cyan
    ];

    final colors = isDark ? darkColors : lightColors;

    return List.generate(widget.orbCount, (index) {
      return AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          final orb = _orbs[index];
          final progress = _animations[index].value;

          // Calculate current position using smooth interpolation
          final x = _lerpDouble(orb.startX, orb.endX, progress) * size.width;
          final y = _lerpDouble(orb.startY, orb.endY, progress) * size.height;

          return Positioned(
            left: x - orb.size / 2,
            top: y - orb.size / 2,
            child: Container(
              width: orb.size,
              height: orb.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors[orb.colorIndex],
                    colors[orb.colorIndex].withValues(alpha: 0),
                  ],
                  stops: const [0.0, 1.0],
                ),
                // Add subtle glow in dark mode
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: colors[orb.colorIndex].withValues(alpha: 0.3),
                          blurRadius: 50,
                          spreadRadius: 20,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMeshOverlay(bool isDark) {
    return Positioned.fill(
      child: CustomPaint(painter: _MeshGradientPainter(isDark: isDark)),
    );
  }

  Widget _buildNoiseOverlay(bool isDark) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            // Subtle noise texture effect using gradient
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.transparent,
                (isDark ? Colors.black : Colors.white).withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

/// Data class for floating orb properties
class _FloatingOrb {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final int colorIndex;

  _FloatingOrb({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.colorIndex,
  });
}

/// Custom painter for mesh gradient effect
class _MeshGradientPainter extends CustomPainter {
  final bool isDark;

  _MeshGradientPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Create subtle mesh gradient overlay
    final paint = Paint()..style = PaintingStyle.fill;

    // Top-left subtle glow
    paint.shader = RadialGradient(
      center: Alignment.topLeft,
      radius: 1.0,
      colors: [
        (isDark ? AppColors.neonPurple : const Color(0xFFB8E0FF)).withValues(
          alpha: isDark ? 0.1 : 0.15,
        ),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Bottom-right subtle glow
    paint.shader = RadialGradient(
      center: Alignment.bottomRight,
      radius: 1.0,
      colors: [
        (isDark ? AppColors.neonCyan : const Color(0xFFFFD0E8)).withValues(
          alpha: isDark ? 0.08 : 0.12,
        ),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SIMPLE GRADIENT BACKGROUND (Static version for performance)
/// ═══════════════════════════════════════════════════════════════════════════

class SimpleGradientBackground extends StatelessWidget {
  final Widget? child;

  const SimpleGradientBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkBackgroundGradient
            : AppColors.lightBackgroundGradient,
      ),
      child: Stack(
        children: [
          // Static decorative orbs
          Positioned(
            top: -100.h,
            left: -100.w,
            child: _StaticOrb(
              size: 400.w,
              color: isDark
                  ? AppColors.neonPurple.withValues(alpha: 0.3)
                  : const Color(0xFFB8E0FF).withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            bottom: -150.h,
            right: -100.w,
            child: _StaticOrb(
              size: 500.w,
              color: isDark
                  ? AppColors.neonCyan.withValues(alpha: 0.2)
                  : const Color(0xFFFFD0E8).withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            top: 300.h,
            right: -50.w,
            child: _StaticOrb(
              size: 300.w,
              color: isDark
                  ? AppColors.neonBlue.withValues(alpha: 0.15)
                  : const Color(0xFFE8D0FF).withValues(alpha: 0.4),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _StaticOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _StaticOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
