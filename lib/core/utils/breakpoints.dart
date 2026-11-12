import 'package:flutter/widgets.dart';

/// Pontos de quebra iguais às media queries do style.css.
abstract final class Breakpoints {
  static const double mobile = 760;
  static const double compact = 1100;
  static const double medium = 920;
  static const double aiStack = 1050;

  static double widthOf(BuildContext context) => MediaQuery.sizeOf(context).width;

  /// Até 760 px: menu lateral vira gaveta e grids viram uma coluna.
  static bool isMobile(BuildContext context) => widthOf(context) < mobile;

  /// Até 1100 px: indicadores em duas colunas e painéis empilhados.
  static bool isCompact(BuildContext context) => widthOf(context) < compact;

  /// Até 920 px: oculta dados do usuário no cabeçalho.
  static bool isMedium(BuildContext context) => widthOf(context) < medium;

  /// Colunas da grade de detalhes (3 / 2 / 1).
  static int detailColumns(BuildContext context) {
    final width = widthOf(context);
    if (width < mobile) return 1;
    if (width < medium) return 2;
    return 3;
  }
}
