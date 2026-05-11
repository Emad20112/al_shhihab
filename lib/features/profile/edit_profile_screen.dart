import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/user_avatar.dart';
import '../auth/providers/auth_providers.dart';
import 'avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{};
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      if (name.isNotEmpty) data['name'] = name;
      if (email.isNotEmpty) data['email'] = email;
      if (phone.isNotEmpty) data['phone'] = phone;

      await ref.read(authControllerProvider.notifier).updateMe(data);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile_updated'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile_update_failed'.tr()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SimpleGradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, isDark)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.spacingMD,
                  AppDimensions.spacingSM,
                  AppDimensions.spacingMD,
                  AppDimensions.spacingXL,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildProfileCard(context, isDark, user),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMD,
        AppDimensions.spacingSM,
        AppDimensions.spacingMD,
        AppDimensions.spacingSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Directionality.of(context) == ui.TextDirection.rtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
              ),
              iconSize: 22.w,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              tooltip: 'back'.tr(),
            ),
          ),
          SizedBox(height: AppDimensions.spacingXS),
          Text(
            'edit_profile'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4.h),
          Text(
            'personal_info'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, bool isDark, dynamic user) {
    return GlassContainerFeatured(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(AppDimensions.spacingLG),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAvatarSection(isDark, user),
            SizedBox(height: AppDimensions.spacingMD),
            Text(
              'personal_info'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppDimensions.spacingSM),
            _ProfileTextField(
              controller: _nameController,
              label: 'name'.tr(),
              hint: 'name_hint'.tr(),
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'field_required'.tr();
                }
                if (value.trim().length < 2) {
                  return 'field_required'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: AppDimensions.spacingMD),
            _ProfileTextField(
              controller: _emailController,
              label: 'email'.tr(),
              hint: 'email_hint'.tr(),
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return null;
                final valid = RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(trimmed);
                return valid ? null : 'invalid_email'.tr();
              },
            ),
            SizedBox(height: AppDimensions.spacingMD),
            _ProfileTextField(
              controller: _phoneController,
              label: 'phone'.tr(),
              hint: 'phone_hint'.tr(),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              textDirection: ui.TextDirection.ltr,
              onSubmitted: (_) => _save(),
            ),
            SizedBox(height: AppDimensions.spacingLG),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text('save_changes'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(bool isDark, dynamic user) {
    return Column(
      children: [
        UserAvatar(
          avatarUrl: user?.avatarUrl,
          size: 96.w,
          showEditBadge: true,
          onTap: () => showAvatarPicker(context, ref),
        ),
        SizedBox(height: 6.h),
        TextButton(
          onPressed: () => showAvatarPicker(context, ref),
          child: Text(
            'change_avatar'.tr(),
            style: TextStyle(
              color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.textDirection,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ui.TextDirection? textDirection;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      textDirection: textDirection,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
