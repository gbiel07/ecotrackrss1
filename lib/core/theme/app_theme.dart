import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      surface: AppColors.white,
      error: AppColors.red,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.white,
      dividerColor: AppColors.line,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.green,
        selectionColor: Color(0x33147D64),
        selectionHandleColor: AppColors.green,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.green,
      ),
    );
  }
}

/// Decoração padrão dos campos, equivalente a input/select/textarea do CSS.
abstract final class AppInputDecoration {
  static const double _radius = 9;

  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputDecoration build({
    String? hint,
    String? errorText,
    bool dense = false,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.hint.copyWith(fontSize: dense ? 12 : 14),
      errorText: errorText,
      errorStyle: const TextStyle(fontSize: 11, color: AppColors.red),
      errorMaxLines: 2,
      isDense: true,
      filled: true,
      fillColor: AppColors.white,
      prefixIcon: prefixIcon,
      contentPadding: dense
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 11)
          : const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      border: _border(AppColors.inputBorder),
      enabledBorder: _border(AppColors.inputBorder),
      focusedBorder: _border(AppColors.inputFocus, 1.4),
      errorBorder: _border(AppColors.red),
      focusedErrorBorder: _border(AppColors.red, 1.4),
    );
  }
}
