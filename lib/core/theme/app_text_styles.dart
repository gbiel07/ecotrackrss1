import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografia: DM Sans no corpo e Manrope nos títulos, como na versão web.
abstract final class AppFonts {
  static const String body = 'DMSans';
  static const String heading = 'Manrope';
}

abstract final class AppTextStyles {
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    color: AppColors.ink,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 25,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: AppColors.ink,
  );

  static const TextStyle panelTitle = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle panelSubtitle = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 11,
    color: Color(0xFF8A9993),
  );

  static const TextStyle muted = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    height: 1.5,
    color: AppColors.muted,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle input = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    color: AppColors.ink,
  );

  static const TextStyle hint = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    color: AppColors.hint,
  );

  static const TextStyle small = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 11,
    height: 1.5,
    color: Color(0xFF83928C),
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    color: Color(0xFFA0ACA7),
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.7,
    color: AppColors.eyebrow,
  );

  static const TextStyle tableHeader = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: Color(0xFF87968F),
  );

  static const TextStyle tableCell = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    color: Color(0xFF455B52),
  );

  static const TextStyle tableStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFF203B31),
  );

  static const TextStyle tableCode = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Color(0xFF23694F),
  );
}
