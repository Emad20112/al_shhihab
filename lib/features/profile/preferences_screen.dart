import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../widgets/glass_setting_tile.dart';
import '../auth/providers/auth_providers.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PREFERENCES SCREEN - User Preferences Management
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Full-screen preferences editor featuring:
/// • Fetches prefs from GET /api/v1/me/preferences
/// • Saves prefs via PUT /api/v1/me/preferences
/// • Notification toggles (orders, offers)
/// • Order type selector (delivery / pickup)
/// • Language preference synced to server
/// ═══════════════════════════════════════════════════════════════════════════

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Preference values
  bool _notifyOrders = true;
  bool _notifyOffers = true;
  String _orderType = 'delivery'; // delivery | pickup

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await ref
          .read(authControllerProvider.notifier)
          .fetchPreferences();

      if (mounted) {
        setState(() {
          _notifyOrders = prefs['notify_orders'] ?? true;
          _notifyOffers = prefs['notify_offers'] ?? true;
          _orderType = prefs['order_type']?.toString() ?? 'delivery';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePreferences({key: value});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('preferences_updated'.tr()),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
          ),
        );
      }
    } catch (_) {
      // Revert will happen on next load
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'preferences'.tr(),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color:
                        isDark ? AppColors.neonCyan : AppColors.lightAccent,
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                        child:
                            SizedBox(height: AppDimensions.spacingLG)),

                    // Notifications Section
                    SliverToBoxAdapter(
                      child: GlassSettingSection(
                        title: 'push_notifications'.tr(),
                        animationDelay:
                            const Duration(milliseconds: 100),
                        children: [
                          GlassSettingTile(
                            icon: Icons.shopping_bag_outlined,
                            iconColor: isDark
                                ? AppColors.neonCyan
                                : AppColors.lightAccent,
                            title: 'notification_orders'.tr(),
                            animationDelay:
                                const Duration(milliseconds: 150),
                            trailing: GlassToggleSwitch(
                              value: _notifyOrders,
                              onChanged: (value) {
                                setState(
                                    () => _notifyOrders = value);
                                _savePreference(
                                    'notify_orders', value);
                              },
                            ),
                          ),
                          GlassSettingTile(
                            icon: Icons.local_offer_outlined,
                            iconColor: isDark
                                ? AppColors.neonOrange
                                : Colors.orange,
                            title: 'notification_offers'.tr(),
                            animationDelay:
                                const Duration(milliseconds: 200),
                            trailing: GlassToggleSwitch(
                              value: _notifyOffers,
                              onChanged: (value) {
                                setState(
                                    () => _notifyOffers = value);
                                _savePreference(
                                    'notify_offers', value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SliverToBoxAdapter(
                        child:
                            SizedBox(height: AppDimensions.spacingLG)),

                    // Order Type Section
                    SliverToBoxAdapter(
                      child: GlassSettingSection(
                        title: 'order_type'.tr(),
                        animationDelay:
                            const Duration(milliseconds: 250),
                        children: [
                          GlassSettingTile(
                            icon: Icons.delivery_dining_rounded,
                            iconColor: _orderType == 'delivery'
                                ? (isDark
                                    ? AppColors.neonGreen
                                    : Colors.green)
                                : (isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted),
                            title: 'delivery'.tr(),
                            animationDelay:
                                const Duration(milliseconds: 300),
                            trailing: Radio<String>(
                              value: 'delivery',
                              groupValue: _orderType,
                              activeColor: isDark
                                  ? AppColors.neonCyan
                                  : AppColors.lightAccent,
                              onChanged: (value) {
                                setState(
                                    () => _orderType = value!);
                                _savePreference(
                                    'order_type', value);
                              },
                            ),
                            onTap: () {
                              setState(
                                  () => _orderType = 'delivery');
                              _savePreference(
                                  'order_type', 'delivery');
                            },
                          ),
                          GlassSettingTile(
                            icon: Icons.store_rounded,
                            iconColor: _orderType == 'pickup'
                                ? (isDark
                                    ? AppColors.neonGreen
                                    : Colors.green)
                                : (isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted),
                            title: 'pickup'.tr(),
                            animationDelay:
                                const Duration(milliseconds: 350),
                            trailing: Radio<String>(
                              value: 'pickup',
                              groupValue: _orderType,
                              activeColor: isDark
                                  ? AppColors.neonCyan
                                  : AppColors.lightAccent,
                              onChanged: (value) {
                                setState(
                                    () => _orderType = value!);
                                _savePreference(
                                    'order_type', value);
                              },
                            ),
                            onTap: () {
                              setState(
                                  () => _orderType = 'pickup');
                              _savePreference(
                                  'order_type', 'pickup');
                            },
                          ),
                        ],
                      ),
                    ),

                    // Saving indicator
                    if (_isSaving)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.spacingLG),
                          child: Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark
                                    ? AppColors.neonCyan
                                    : AppColors.lightAccent,
                              ),
                            ),
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(
                        child:
                            SizedBox(height: AppDimensions.spacingHuge)),
                  ],
                ),
        ),
      ),
    );
  }
}
