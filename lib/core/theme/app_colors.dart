import 'package:flutter/material.dart';

/// Paleta herdada das variáveis CSS da versão web (style.css).
abstract final class AppColors {
  static const Color ink = Color(0xFF172B2A);
  static const Color muted = Color(0xFF71817E);
  static const Color line = Color(0xFFE4EBE8);
  static const Color lineSoft = Color(0xFFEDF1EF);
  static const Color background = Color(0xFFF5F8F7);
  static const Color white = Color(0xFFFFFFFF);

  static const Color green = Color(0xFF147D64);
  static const Color greenDark = Color(0xFF0D5D4B);
  static const Color greenPale = Color(0xFFE4F4EE);
  static const Color greenText = Color(0xFF176A53);
  static const Color orange = Color(0xFFC77823);
  static const Color red = Color(0xFFC74A4A);
  static const Color blue = Color(0xFF4169B2);

  static const Color inputBorder = Color(0xFFDCE5E1);
  static const Color inputFocus = Color(0xFF58A88B);
  static const Color hint = Color(0xFF9AA8A3);
  static const Color subtle = Color(0xFF8B9993);
  static const Color tableHead = Color(0xFFF8FAF9);
  static const Color soft = Color(0xFFF7FAF8);
  static const Color softer = Color(0xFFFBFDFC);

  // Barra lateral
  static const Color sidebar = Color(0xFF103A32);
  static const Color sidebarActive = Color(0xFF1B5949);
  static const Color sidebarText = Color(0xFFBDD3CA);
  static const Color sidebarLabel = Color(0xFF80A69A);
  static const Color sidebarCard = Color(0xFF19483E);

  // Login
  static const Color loginTop = Color(0xFF103F36);
  static const Color loginBottom = Color(0xFF0B2928);
  static const Color loginText = Color(0xFFC1D9D1);
  static const Color eyebrow = Color(0xFF67BD9C);

  // Marca
  static const Color brandMark = Color(0xFFB7EFD9);
  static const Color brandMarkIcon = Color(0xFF105342);
  static const Color brandLight = Color(0xFF8ED5BA);

  static const Color toast = Color(0xFF123E32);
  static const Color qr = Color(0xFF123E32);

  // Gráficos
  static const Color chartPrimary = Color(0xFF6DC4A1);
  static const Color chartAlt = Color(0xFFD5E9DF);
  static const Color chartGrid = Color(0xFFEDF2EF);

  static const Map<String, Color> groupColors = {
    'A': Color(0xFF58B58D),
    'B': Color(0xFFE2A34F),
    'C': Color(0xFFA4A0DC),
    'D': Color(0xFF75A6DA),
    'E': Color(0xFFDC8E8E),
  };
}

/// Tons usados em pílulas de status e ícones de indicadores.
enum AppTone {
  green(Color(0xFFE6F6EE), Color(0xFF21825E)),
  orange(Color(0xFFFFF3DF), Color(0xFFB67524)),
  red(Color(0xFFFFEBEA), Color(0xFFBD4C4C)),
  blue(Color(0xFFEAF0FF), Color(0xFF496CB1)),
  gray(Color(0xFFEDF1EF), Color(0xFF6D7E76));

  const AppTone(this.background, this.foreground);

  final Color background;
  final Color foreground;
}
