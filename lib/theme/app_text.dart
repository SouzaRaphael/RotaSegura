import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppText {
  const AppText._();

  static const bodyFamily = 'DM Sans';
  static const headingFamily = 'Manrope';

  static const h1 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 27,
    height: 1.2,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    color: AppColors.navy,
  );

  static const h2 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.navy,
  );

  static const h3 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static TextStyle stat({double size = 25, Color color = AppColors.blue}) => TextStyle(
    fontFamily: headingFamily,
    fontSize: size,
    height: 1.1,
    fontWeight: FontWeight.w800,
    color: color,
  );

  static const intro = TextStyle(fontSize: 14, height: 1.6, color: AppColors.muted);
  static const overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    color: AppColors.muted,
  );
  static const body = TextStyle(fontSize: 14, height: 1.5, color: AppColors.ink);
  static const strong = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const small = TextStyle(fontSize: 12, height: 1.5, color: AppColors.muted);
  static const footnote = TextStyle(fontSize: 11, height: 1.6, color: AppColors.muted);
  static const button = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
}
