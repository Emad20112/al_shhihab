import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS APP BAR - Premium Transparent App Bar
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A glassmorphism app bar that pins to the top while letting
/// the animated background shine through.
///
/// Features:
/// • User greeting with glass avatar
/// • Notification bell with neon dot indicator
/// • Search button
/// • Fully theme-aware
/// ═══════════════════════════════════════════════════════════════════════════

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// User's name for greeting
  final String userName;

  /// Avatar image URL (optional)
  final String? avatarUrl;

  /// Notification count (shows dot if > 0)
  final int notificationCount;

  /// Search button callback
  final VoidCallback? onSearchTap;

  /// Notification button callback
  final VoidCallback? onNotificationTap;

  /// Avatar/Profile button callback
  final VoidCallback? onAvatarTap;

  /// Custom height
  final double? height;

  /// Enable entry animation
  final bool animate;

  const GlassAppBar({
    super.key,
    this.userName = 'Guest',
    this.avatarUrl,
    this.notificationCount = 0,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.height,
    this.animate = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height ?? 80.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget appBar = Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 20.w,
        right: 20.w,
        bottom: 8.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppColors.getBlurSigma(isDark) * 0.8,
            sigmaY: AppColors.getBlurSigma(isDark) * 0.8,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.getGlassSurface(
                isDark,
              ).withValues(alpha: AppColors.getGlassOpacity(isDark)),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar + Greeting
                Expanded(child: _buildUserSection(context, isDark)),

                // Action buttons
                Row(
                  children: [
                    _buildSearchButton(context, isDark),
                    SizedBox(width: 8.w),
                    _buildNotificationButton(context, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (animate) {
      return appBar
          .animate()
          .fadeIn(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          )
          .slideY(
            begin: -0.5,
            end: 0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
    }

    return appBar;
  }

  Widget _buildUserSection(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Row(
        children: [
          // Glass Avatar
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.neonCyan.withValues(alpha: 0.3),
                        AppColors.neonMagenta.withValues(alpha: 0.3),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.lightAccent.withValues(alpha: 0.3),
                        AppColors.lightAccentSecondary.withValues(alpha: 0.3),
                      ],
                    ),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildAvatarFallback(isDark),
                    ),
                  )
                : _buildAvatarFallback(isDark),
          ),

          SizedBox(width: 12.w),

          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'welcome'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(bool isDark) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: 24.w,
        color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context, bool isDark) {
    return _GlassIconButton(
      icon: Icons.search_rounded,
      isDark: isDark,
      onTap: onSearchTap,
    );
  }

  Widget _buildNotificationButton(BuildContext context, bool isDark) {
    return Stack(
      children: [
        _GlassIconButton(
          icon: Icons.notifications_rounded,
          isDark: isDark,
          onTap: onNotificationTap,
        ),
        // Notification dot
        if (notificationCount > 0)
          Positioned(
            right: 8.w,
            top: 8.w,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.neonMagenta : AppColors.error,
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: AppColors.neonMagenta.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

/// Glass icon button used in the app bar
class _GlassIconButton extends StatefulWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;

  const _GlassIconButton({
    required this.icon,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36.w,
        height: 36.w,
        transform: Matrix4.identity()..scale(_isPressed ? 0.92 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isDark
              ? AppColors.darkGlassSurface.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.4),
          border: Border.all(
            color: widget.isDark
                ? AppColors.neonCyan.withValues(alpha: _isPressed ? 0.5 : 0.2)
                : Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: widget.isDark && _isPressed
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          widget.icon,
          size: 18.w,
          color: widget.isDark
              ? (_isPressed ? AppColors.neonCyan : AppColors.darkTextPrimary)
              : AppColors.lightTextPrimary,
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SLIVER GLASS APP BAR (For use with CustomScrollView)
/// ═══════════════════════════════════════════════════════════════════════════

class SliverGlassAppBar extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final int notificationCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const SliverGlassAppBar({
    super.key,
    this.userName = 'Guest',
    this.avatarUrl,
    this.notificationCount = 0,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: _GlassAppBarDelegate(
        userName: userName,
        avatarUrl: avatarUrl,
        notificationCount: notificationCount,
        onSearchTap: onSearchTap,
        onNotificationTap: onNotificationTap,
        onAvatarTap: onAvatarTap,
      ),
    );
  }
}

class _GlassAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String userName;
  final String? avatarUrl;
  final int notificationCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  _GlassAppBarDelegate({
    required this.userName,
    this.avatarUrl,
    required this.notificationCount,
    this.onSearchTap,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  double get minExtent => 100.h;

  @override
  double get maxExtent => 100.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return GlassAppBar(
      userName: userName,
      avatarUrl: avatarUrl,
      notificationCount: notificationCount,
      onSearchTap: onSearchTap,
      onNotificationTap: onNotificationTap,
      onAvatarTap: onAvatarTap,
      animate: false,
    );
  }

  @override
  bool shouldRebuild(covariant _GlassAppBarDelegate oldDelegate) {
    return oldDelegate.userName != userName ||
        oldDelegate.avatarUrl != avatarUrl ||
        oldDelegate.notificationCount != notificationCount;
  }
}
