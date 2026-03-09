import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../main.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SPLASH SCREEN - Lightweight Loading Screen
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Shows a minimal, performant splash while essential data loads:
/// • SharedPreferences (theme + city)
/// • Any async initialization
///
/// Design: no BackdropFilter, no continuous animations, no heavy GPU ops.
/// Uses a single AnimationController for a smooth fade+scale entrance.
/// ═══════════════════════════════════════════════════════════════════════════

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  bool _dataReady = false;
  bool _animationDone = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _preloadData();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() => _animationDone = true);
            _tryNavigate();
          }
        });
      }
    });
  }

  Future<void> _preloadData() async {
    try {
      await SharedPreferences.getInstance();
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        setState(() => _dataReady = true);
        _tryNavigate();
      }
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _dataReady = true);
        _tryNavigate();
      }
    }
  }

  void _tryNavigate() {
    if (!_dataReady || !_animationDone || !mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => const MainLayout(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkGradientStart,
                    AppColors.darkGradientMiddle,
                    AppColors.darkGradientEnd,
                  ]
                : [
                    AppColors.lightGradientStart,
                    AppColors.lightGradientMiddle,
                    AppColors.lightGradientEnd,
                  ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App icon
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                AppColors.neonCyan.withValues(alpha: 0.3),
                                AppColors.neonMagenta.withValues(alpha: 0.3),
                              ]
                            : [
                                AppColors.lightAccent.withValues(alpha: 0.2),
                                AppColors.lightAccentSecondary.withValues(
                                  alpha: 0.2,
                                ),
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? AppColors.neonCyan.withValues(alpha: 0.5)
                            : AppColors.lightAccent.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: isDark
                          ? [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 30,
                                spreadRadius: 0,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 48.w,
                      color: isDark
                          ? AppColors.neonCyan
                          : AppColors.lightAccent,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    'TechVault',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'Discover the Future',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      letterSpacing: 1,
                    ),
                  ),

                  SizedBox(height: 48.h),

                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        isDark
                            ? AppColors.neonCyan.withValues(alpha: 0.7)
                            : AppColors.lightAccent.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
