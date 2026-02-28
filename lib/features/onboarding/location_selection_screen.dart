import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/location_provider.dart';
import '../../widgets/animated_gradient_background.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LOCATION SELECTION SCREEN - Premium Onboarding
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A stunning full-screen onboarding experience shown on first launch.
/// Features floating orbs, glassmorphism cards with shimmer borders,
/// scale/glow selection animation, and staggered entrance effects.
/// ═══════════════════════════════════════════════════════════════════════════

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  ConsumerState<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen>
    with TickerProviderStateMixin {
  LocationRegion? _selectedRegion;

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // ── Floating decorative orbs ──────────────────────────────
            _buildFloatingOrbs(isDark),

            // ── Main content ─────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 32.h),

                    // ── Animated Hero Icon ───────────────────────────
                    _buildHeroIcon(isDark),

                    SizedBox(height: 24.h),

                    // ── Title & Subtitle ─────────────────────────────
                    _buildTitleSection(isDark),

                    SizedBox(height: 36.h),

                    // ── Region Cards ─────────────────────────────────
                    Expanded(child: _buildRegionCards(isDark)),

                    SizedBox(height: 20.h),

                    // ── Confirm Button ───────────────────────────────
                    _buildConfirmButton(isDark),

                    SizedBox(height: 14.h),

                    // ── Settings hint ────────────────────────────────
                    _buildSettingsHint(isDark),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FLOATING DECORATIVE ORBS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFloatingOrbs(bool isDark) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top-right orb
            Positioned(
              top: -40.h + (_floatController.value * 20),
              right: -30.w,
              child: _buildOrb(
                size: 180.w,
                colors: isDark
                    ? [
                        AppColors.neonCyan.withOpacity(0.08),
                        AppColors.neonBlue.withOpacity(0.04),
                      ]
                    : [
                        AppColors.lightAccent.withOpacity(0.08),
                        AppColors.lightAccentSecondary.withOpacity(0.04),
                      ],
              ),
            ),

            // Bottom-left orb
            Positioned(
              bottom: 60.h - (_floatController.value * 15),
              left: -50.w,
              child: _buildOrb(
                size: 200.w,
                colors: isDark
                    ? [
                        AppColors.neonMagenta.withOpacity(0.06),
                        AppColors.neonPurple.withOpacity(0.03),
                      ]
                    : [
                        AppColors.lightAccentSoft.withOpacity(0.1),
                        AppColors.lightAccentPastel.withOpacity(0.05),
                      ],
              ),
            ),

            // Center-right small orb
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: -20.w + (_floatController.value * 12),
              child: _buildOrb(
                size: 100.w,
                colors: isDark
                    ? [
                        AppColors.neonOrange.withOpacity(0.05),
                        AppColors.neonMagenta.withOpacity(0.03),
                      ]
                    : [
                        AppColors.lightCyanSoft.withOpacity(0.08),
                        AppColors.lightAccent.withOpacity(0.04),
                      ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrb({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO ICON with multi-ring glow + particle shimmer
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroIcon(bool isDark) {
    return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final pulse = _pulseController.value;
            return SizedBox(
              width: 120.w,
              height: 120.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            (isDark
                                    ? AppColors.neonCyan
                                    : AppColors.lightAccent)
                                .withOpacity(0.15 + pulse * 0.1),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // Middle ring
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            (isDark
                                    ? AppColors.neonMagenta
                                    : AppColors.lightAccentSoft)
                                .withOpacity(0.12 + pulse * 0.08),
                        width: 1,
                      ),
                    ),
                  ),

                  // Core icon circle
                  Container(
                    width: 76.w,
                    height: 76.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [AppColors.neonCyan, AppColors.neonMagenta]
                            : [
                                AppColors.lightAccent,
                                AppColors.lightAccentSecondary,
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isDark
                                      ? AppColors.neonCyan
                                      : AppColors.lightAccent)
                                  .withOpacity(0.25 + pulse * 0.2),
                          blurRadius: 30 + pulse * 15,
                          spreadRadius: 2 + pulse * 4,
                        ),
                        if (isDark)
                          BoxShadow(
                            color: AppColors.neonMagenta.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: -5,
                            offset: const Offset(10, 10),
                          ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 36.w,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.easeOutBack,
        );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TITLE SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTitleSection(bool isDark) {
    return Column(
          children: [
            // Main title with gradient text effect for dark mode
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: isDark
                      ? [AppColors.darkTextPrimary, AppColors.neonCyan]
                      : [
                          AppColors.lightTextPrimary,
                          AppColors.lightTextPrimary,
                        ],
                ).createShader(bounds);
              },
              child: Text(
                'select_location'.tr(),
                style: GoogleFonts.cairo(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 10.h),

            // Subtitle
            Text(
              'select_location_subtitle'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextMuted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.15, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REGION CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRegionCards(bool isDark) {
    return Column(
      children: [
        // ── Northern Region Card ─────────────────────────────────────
        Expanded(
          child: _buildPremiumRegionCard(
            isDark: isDark,
            region: LocationRegion.north,
            titleKey: 'northern_cities',
            citiesKey: 'northern_cities_list',
            icon: Icons.terrain_rounded,
            emoji: '🏔️',
            accentColors: isDark
                ? [AppColors.neonCyan, AppColors.neonBlue]
                : [const Color(0xFF6C63FF), const Color(0xFF00D9FF)],
            delay: 350.ms,
          ),
        ),

        SizedBox(height: 14.h),

        // ── Southern Region Card ─────────────────────────────────────
        Expanded(
          child: _buildPremiumRegionCard(
            isDark: isDark,
            region: LocationRegion.south,
            titleKey: 'southern_cities',
            citiesKey: 'southern_cities_list',
            icon: Icons.water_rounded,
            emoji: '🏖️',
            accentColors: isDark
                ? [AppColors.neonMagenta, AppColors.neonOrange]
                : [const Color(0xFFFF6B9D), const Color(0xFFFFA259)],
            delay: 500.ms,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumRegionCard({
    required bool isDark,
    required LocationRegion region,
    required String titleKey,
    required String citiesKey,
    required IconData icon,
    required String emoji,
    required List<Color> accentColors,
    required Duration delay,
  }) {
    final isSelected = _selectedRegion == region;
    final accent = accentColors.first;

    return GestureDetector(
          onTap: () => setState(() => _selectedRegion = region),
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return AnimatedContainer(
                duration: 400.ms,
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.98),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    // Primary glow when selected
                    if (isSelected)
                      BoxShadow(
                        color: accent.withOpacity(isDark ? 0.35 : 0.2),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    // Ambient shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: CustomPaint(
                      painter: isSelected
                          ? _ShimmerBorderPainter(
                              progress: _shimmerController.value,
                              borderRadius: 24.r,
                              colors: accentColors,
                              borderWidth: 2.0,
                              isDark: isDark,
                            )
                          : null,
                      child: AnimatedContainer(
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          color: isSelected
                              ? accent.withOpacity(isDark ? 0.12 : 0.06)
                              : AppColors.getGlassSurface(
                                  isDark,
                                ).withOpacity(isDark ? 0.28 : 0.55),
                          border: Border.all(
                            color: isSelected
                                ? accent.withOpacity(isDark ? 0.7 : 0.5)
                                : isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.white.withOpacity(0.5),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22.w,
                            vertical: 18.h,
                          ),
                          child: Row(
                            children: [
                              // ── Left: Icon + Emoji ─────────────────────
                              _buildCardIconSection(
                                isDark: isDark,
                                icon: icon,
                                emoji: emoji,
                                accentColors: accentColors,
                                isSelected: isSelected,
                              ),

                              SizedBox(width: 18.w),

                              // ── Center: Text Content ──────────────────
                              Expanded(
                                child: _buildCardTextSection(
                                  isDark: isDark,
                                  titleKey: titleKey,
                                  citiesKey: citiesKey,
                                  accent: accent,
                                  isSelected: isSelected,
                                ),
                              ),

                              SizedBox(width: 12.w),

                              // ── Right: Selection Indicator ─────────────
                              _buildSelectionIndicator(
                                isDark: isDark,
                                accent: accent,
                                isSelected: isSelected,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
        .animate(delay: delay)
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.15, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  // ── Card Icon Section ──────────────────────────────────────────────────────

  Widget _buildCardIconSection({
    required bool isDark,
    required IconData icon,
    required String emoji,
    required List<Color> accentColors,
    required bool isSelected,
  }) {
    final accent = accentColors.first;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: 400.ms,
          curve: Curves.easeOutCubic,
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? accentColors
                  : accentColors
                        .map((c) => c.withOpacity(isDark ? 0.3 : 0.25))
                        .toList(),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withOpacity(isDark ? 0.45 : 0.3),
                      blurRadius: 18,
                      spreadRadius: -2,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 28.w,
              color: Colors.white.withOpacity(isSelected ? 1.0 : 0.8),
            ),
          ),
        ),

        SizedBox(height: 8.h),

        // Emoji below icon
        Text(emoji, style: TextStyle(fontSize: 20.sp)),
      ],
    );
  }

  // ── Card Text Section ──────────────────────────────────────────────────────

  Widget _buildCardTextSection({
    required bool isDark,
    required String titleKey,
    required String citiesKey,
    required Color accent,
    required bool isSelected,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Region title
        AnimatedDefaultTextStyle(
          duration: 300.ms,
          style: GoogleFonts.cairo(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? accent
                : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
            height: 1.2,
          ),
          child: Text(titleKey.tr()),
        ),

        SizedBox(height: 8.h),

        // Decorative line
        AnimatedContainer(
          duration: 400.ms,
          width: isSelected ? 40.w : 24.w,
          height: 3.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.r),
            gradient: LinearGradient(
              colors: isSelected
                  ? [accent, accent.withOpacity(0.3)]
                  : [
                      (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted)
                          .withOpacity(0.3),
                      Colors.transparent,
                    ],
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // City names
        Text(
          citiesKey.tr(),
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary.withOpacity(0.8)
                : AppColors.lightTextSecondary,
            height: 1.6,
            letterSpacing: 0.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── Selection Indicator ────────────────────────────────────────────────────

  Widget _buildSelectionIndicator({
    required bool isDark,
    required Color accent,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: 350.ms,
      curve: Curves.easeOutBack,
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? accent : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? accent
              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                    .withOpacity(0.4),
          width: isSelected ? 0 : 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accent.withOpacity(isDark ? 0.5 : 0.35),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: AnimatedSwitcher(
        duration: 300.ms,
        switchInCurve: Curves.easeOutBack,
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                key: const ValueKey('check'),
                size: 18.w,
                color: Colors.white,
              )
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONFIRM BUTTON with gradient, glow, and ripple
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildConfirmButton(bool isDark) {
    final isEnabled = _selectedRegion != null;

    return AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.35,
          duration: 350.ms,
          child: AnimatedContainer(
            duration: 350.ms,
            transform: Matrix4.identity()..scale(isEnabled ? 1.0 : 0.96),
            transformAlignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                onTap: isEnabled ? _confirmSelection : null,
                borderRadius: BorderRadius.circular(16.r),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: isDark
                          ? [AppColors.neonCyan, AppColors.neonBlue]
                          : [
                              AppColors.lightAccent,
                              AppColors.lightAccentSecondary,
                            ],
                    ),
                    boxShadow: isEnabled
                        ? [
                            BoxShadow(
                              color:
                                  (isDark
                                          ? AppColors.neonCyan
                                          : AppColors.lightAccent)
                                      .withOpacity(isDark ? 0.4 : 0.3),
                              blurRadius: 24,
                              spreadRadius: -4,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 56.h,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'confirm_location'.tr(),
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkGradientStart
                                : Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: isDark
                              ? AppColors.darkGradientStart
                              : Colors.white,
                          size: 22.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .animate(delay: 650.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.25, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SETTINGS HINT
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSettingsHint(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.settings_rounded,
          size: 14.w,
          color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
              .withOpacity(0.7),
        ),
        SizedBox(width: 6.w),
        Text(
          'change_region_hint'.tr(),
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                .withOpacity(0.7),
          ),
        ),
      ],
    ).animate(delay: 800.ms).fadeIn(duration: 500.ms);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void _confirmSelection() {
    if (_selectedRegion == null) return;
    ref.read(locationProvider.notifier).selectRegion(_selectedRegion!);
    // If opened from settings (pushed route), pop back
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHIMMER BORDER PAINTER
// ═══════════════════════════════════════════════════════════════════════════
//
// Draws a gradient border with a travelling shimmer highlight that rotates
// around the card when selected, giving a premium "living border" effect.
// ═══════════════════════════════════════════════════════════════════════════

class _ShimmerBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final List<Color> colors;
  final double borderWidth;
  final bool isDark;

  _ShimmerBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.colors,
    required this.borderWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Rotating sweep gradient for shimmer effect
    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      transform: GradientRotation(progress * 2 * pi),
      colors: [
        colors[0].withOpacity(isDark ? 0.7 : 0.5),
        colors.length > 1
            ? colors[1].withOpacity(isDark ? 0.5 : 0.3)
            : colors[0].withOpacity(isDark ? 0.5 : 0.3),
        Colors.white.withOpacity(isDark ? 0.9 : 0.6),
        colors[0].withOpacity(isDark ? 0.7 : 0.5),
      ],
      stops: const [0.0, 0.3, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
