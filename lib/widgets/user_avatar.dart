import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/network/api_config.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// USER AVATAR - Premium Avatar Widget with Network Image Support
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Displays user's avatar from network URL or a fallback gradient icon.
/// Features:
/// • Loads avatar from avatarUrl with CachedNetworkImage
/// • Gradient border ring (gold in dark, midnight in light)
/// • Loading shimmer placeholder
/// • Optional edit overlay badge
/// ═══════════════════════════════════════════════════════════════════════════

class UserAvatar extends StatelessWidget {
  /// Avatar URL from the user's profile (can be relative or absolute).
  final String? avatarUrl;

  /// Overall widget size (default: avatarSizeLG).
  final double? size;

  /// Whether to show the camera/edit overlay badge.
  final bool showEditBadge;

  /// Called when the avatar (or edit badge) is tapped.
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.size,
    this.showEditBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double effectiveSize = size ?? AppDimensions.avatarSizeLG;
    final double innerSize = effectiveSize - 6.w;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient ring
          Container(
            width: effectiveSize,
            height: effectiveSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.neonCyan, AppColors.neonMagenta]
                    : [AppColors.lightAccent, AppColors.lightAccentSecondary],
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.lightAccent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: Center(
              child: ClipOval(
                child: Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkGlassSurface : Colors.white,
                  ),
                  child: _buildImage(isDark, innerSize),
                ),
              ),
            ),
          ),

          // Edit badge
          if (showEditBadge)
            Positioned(
              right: -2.w,
              bottom: -2.w,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isDark
                      ? AppColors.goldButtonGradient
                      : LinearGradient(
                          colors: [
                            AppColors.lightAccent,
                            AppColors.lightAccentSecondary,
                          ],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.neonCyan : AppColors.lightAccent)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 14.w,
                  color: isDark ? AppColors.darkGradientStart : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(bool isDark, double innerSize) {
    final url = _resolveUrl();
    if (url == null || url.isEmpty) {
      return Center(
        child: Icon(
          Icons.person_rounded,
          size: innerSize * 0.5,
          color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: innerSize,
      height: innerSize,
      fit: BoxFit.cover,
      placeholder: (_, __) => _shimmerPlaceholder(isDark, innerSize),
      errorWidget: (_, __, ___) => Center(
        child: Icon(
          Icons.person_rounded,
          size: innerSize * 0.5,
          color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder(bool isDark, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isDark ? AppColors.neonCyan : AppColors.lightAccent)
            .withValues(alpha: 0.1),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.35,
          height: size * 0.35,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
          ),
        ),
      ),
    );
  }

  /// Resolve a relative path to a full URL.
  String? _resolveUrl() {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    if (avatarUrl!.startsWith('http')) return avatarUrl;
    // Build full URL from the base URL (strip /api/v1 suffix)
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
    return '$base${avatarUrl!.startsWith('/') ? '' : '/'}${avatarUrl!}';
  }
}
