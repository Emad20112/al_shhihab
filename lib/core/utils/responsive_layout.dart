import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveLayout {
  ResponsiveLayout._();

  static const double compactMaxWidth = 599;
  static const double mediumMaxWidth = 839;
  static const double contentMaxWidth = 1180;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= compactMaxWidth;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width > mediumMaxWidth;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= 360) return 14;
    if (width <= compactMaxWidth) return 18;
    if (width <= mediumMaxWidth) return 28;
    return 36;
  }

  static double bottomBarHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width <= 360 ? 60 : 64;
  }

  static double productHeroHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width > mediumMaxWidth) return math.min(size.height * 0.68, 620);
    if (size.width <= 360) return 330;
    return math.min(size.height * 0.50, 460);
  }

  static BoxConstraints pageConstraints(BuildContext context) {
    return const BoxConstraints(maxWidth: contentMaxWidth);
  }
}
