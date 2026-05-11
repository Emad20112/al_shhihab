import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../widgets/user_avatar.dart';
import '../auth/providers/auth_providers.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AVATAR PICKER - Bottom Sheet for Changing User Avatar
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A premium glass-styled bottom sheet that allows the user to:
/// • Take a photo with the camera
/// • Pick an image from the gallery
/// • Remove the current avatar
/// ═══════════════════════════════════════════════════════════════════════════

Future<void> showAvatarPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AvatarPickerSheet(ref: ref),
  );
}

class _AvatarPickerSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AvatarPickerSheet({required this.ref});

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  bool _isLoading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isLoading = true);

      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final contentType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';

      await widget.ref.read(authControllerProvider.notifier).changeAvatarBytes(
            bytes: bytes,
            filename: picked.name,
            contentType: contentType,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('avatar_updated'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('avatar_update_failed'.tr()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    try {
      setState(() => _isLoading = true);
      await widget.ref.read(authControllerProvider.notifier).deleteAvatar();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('avatar_removed'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('avatar_update_failed'.tr()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = widget.ref.watch(currentUserProvider);
    final hasAvatar =
        user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXXL),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkGlassSurface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXXL),
            ),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacingLG),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),

                  SizedBox(height: AppDimensions.spacingLG),

                  // Title
                  Text(
                    'change_avatar'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  SizedBox(height: AppDimensions.spacingLG),

                  // Current avatar preview
                  UserAvatar(
                    avatarUrl: user?.avatarUrl,
                    size: 90.w,
                  ),

                  SizedBox(height: AppDimensions.spacingXL),

                  if (_isLoading) ...[
                    CircularProgressIndicator(
                      color:
                          isDark ? AppColors.neonCyan : AppColors.lightAccent,
                    ),
                    SizedBox(height: AppDimensions.spacingMD),
                    Text(
                      'uploading'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                    ),
                  ] else ...[
                    // Camera option
                    _PickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'take_photo'.tr(),
                      color:
                          isDark ? AppColors.neonCyan : AppColors.lightAccent,
                      onTap: () => _pickImage(ImageSource.camera),
                    )
                        .animate()
                        .fadeIn(
                          duration: Duration(
                              milliseconds: AppDimensions.animationNormal),
                        )
                        .slideY(begin: 0.1, end: 0),

                    SizedBox(height: AppDimensions.spacingSM),

                    // Gallery option
                    _PickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'choose_gallery'.tr(),
                      color: isDark
                          ? AppColors.neonMagenta
                          : AppColors.lightAccentSecondary,
                      onTap: () => _pickImage(ImageSource.gallery),
                    )
                        .animate(delay: const Duration(milliseconds: 50))
                        .fadeIn(
                          duration: Duration(
                              milliseconds: AppDimensions.animationNormal),
                        )
                        .slideY(begin: 0.1, end: 0),

                    // Remove option (only if avatar exists)
                    if (hasAvatar) ...[
                      SizedBox(height: AppDimensions.spacingSM),
                      _PickerOption(
                        icon: Icons.delete_outline_rounded,
                        label: 'remove_photo'.tr(),
                        color: AppColors.error,
                        onTap: _removeAvatar,
                      )
                          .animate(delay: const Duration(milliseconds: 100))
                          .fadeIn(
                            duration: Duration(
                                milliseconds: AppDimensions.animationNormal),
                          )
                          .slideY(begin: 0.1, end: 0),
                    ],
                  ],

                  SizedBox(height: AppDimensions.spacingMD),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        splashColor: color.withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLG,
            vertical: AppDimensions.spacingMD,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            color: color.withValues(alpha: isDark ? 0.1 : 0.06),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.25 : 0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(icon, color: color, size: 22.w),
              ),
              SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
                size: 24.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
