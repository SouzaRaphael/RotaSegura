import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: AppText.bodyFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      surface: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.white,
  );

  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color, width: width),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: AppColors.navy, displayColor: AppColors.navy),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.placeholder),
      labelStyle: const TextStyle(color: AppColors.label),
      border: border(AppColors.inputBorder),
      enabledBorder: border(AppColors.inputBorder),
      focusedBorder: border(AppColors.blue, 2),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 2),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.blue : null,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.white,
      selectedColor: AppColors.blue,
      side: const BorderSide(color: AppColors.secondaryBorder),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navy,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.white),
    popupMenuTheme: const PopupMenuThemeData(color: AppColors.white),
  );
}
