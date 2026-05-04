import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../data/dummy_data.dart';

class RFQBottomSheet extends StatefulWidget {
  final ProductModel product;

  const RFQBottomSheet({super.key, required this.product});

  @override
  State<RFQBottomSheet> createState() => _RFQBottomSheetState();
}

class _RFQBottomSheetState extends State<RFQBottomSheet> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    // Mock submission
    setState(() => _isSubmitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXXL),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXXL),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(AppDimensions.spacingLG),
            decoration: BoxDecoration(
              color: AppColors.getGlassSurface(isDark).withValues(alpha: 0.92),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusXXL),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: _isSubmitted
                  ? _buildSuccessState(isDark)
                  : _buildForm(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Column(
      key: const ValueKey('rfq_form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'bulk_order_quote'.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingLG),

        // Quantity Field
        _buildTextField(
          label:
              '${'quantity'.tr()} (${context.locale.languageCode == 'ar' ? widget.product.unitAr : widget.product.unit})',
          hint: 'enter_quantity'.tr(),
          controller: _quantityController,
          icon: Icons.numbers_rounded,
          isDark: isDark,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: AppDimensions.spacingMD),

        // Location Field
        _buildTextField(
          label: 'delivery_location'.tr(),
          hint: context.locale.languageCode == 'ar'
              ? 'الشارع، الحي، المدينة...'
              : 'Street, District, City...',
          controller: _locationController,
          icon: Icons.location_on_rounded,
          isDark: isDark,
        ),
        SizedBox(height: AppDimensions.spacingMD),

        // Date Picker
        _buildDatePicker(isDark),
        SizedBox(height: AppDimensions.spacingMD),

        // Notes Field
        _buildTextField(
          label: 'special_instructions'.tr(),
          hint: context.locale.languageCode == 'ar'
              ? 'المقاس، اللون، أو أي ملاحظات...'
              : 'Size, color, or any special requests...',
          controller: _notesController,
          icon: Icons.note_add_rounded,
          isDark: isDark,
          maxLines: 3,
        ),
        SizedBox(height: AppDimensions.spacingXL),

        // Submit Button
        _buildSubmitButton(isDark),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 20.w,
                color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13.sp,
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.3,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: maxLines > 1 ? 12.h : 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'delivery_date'.tr(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 20.w,
                  color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                ),
                SizedBox(width: 12.w),
                Text(
                  _selectedDate == null
                      ? context.locale.languageCode == 'ar'
                            ? 'اختر التاريخ'
                            : 'Select Date'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null
                        ? (isDark ? Colors.white : Colors.black).withValues(
                            alpha: 0.3,
                          )
                        : (isDark ? Colors.white : Colors.black),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return GestureDetector(
      onTap: _submitRequest,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.goldButtonGradient
              : AppColors.lightBackgroundGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.neonCyan : AppColors.lightAccent)
                  .withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'submit_quote'.tr().toUpperCase(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.black : Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Column(
      key: const ValueKey('rfq_success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 40.h),
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? AppColors.neonCyan.withValues(alpha: 0.1)
                : AppColors.neonGreen.withValues(alpha: 0.1),
            border: Border.all(
              color: isDark ? AppColors.neonCyan : AppColors.neonGreen,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 48.w,
            color: isDark ? AppColors.neonCyan : AppColors.neonGreen,
          ),
        ).animate().scale(
          delay: 200.ms,
          duration: 600.ms,
          curve: Curves.elasticOut,
        ),
        SizedBox(height: 24.h),
        Text(
          'quote_sent_success'.tr(),
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'quote_sent_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 40.h),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Center(
              child: Text(
                'continue_shopping'.tr().toUpperCase(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
