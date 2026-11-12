import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/breakpoints.dart';

/// Cartão branco com borda e sombra suave (.panel / .stat-card).
class AppPanel extends StatelessWidget {
  const AppPanel({super.key, required this.child, this.padding, this.margin});

  final Widget child;

  /// `null` usa o padrão (20, ou 16 no celular). Use `EdgeInsets.zero` para tabelas.
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  static const BoxDecoration decoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(BorderSide(color: AppColors.line)),
    boxShadow: [
      BoxShadow(color: Color(0x0F16362D), blurRadius: 32, offset: Offset(0, 12)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final defaultPadding = Breakpoints.isMobile(context) ? 16.0 : 20.0;
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(defaultPadding),
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Cabeçalho de painel (.panel-head) com título, subtítulo e ação opcional.
class PanelHeader extends StatelessWidget {
  const PanelHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = EdgeInsets.zero,
    this.stackOnMobile = false,
    this.stackOnCompact = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool stackOnMobile;

  /// Empilha a ação abaixo do título também em telas médias (até 1100 px).
  final bool stackOnCompact;

  @override
  Widget build(BuildContext context) {
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.panelTitle),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(subtitle!, style: AppTextStyles.panelSubtitle),
        ],
      ],
    );

    final Widget content;
    final stack = (stackOnMobile && Breakpoints.isMobile(context)) ||
        (stackOnCompact && Breakpoints.isCompact(context));
    if (trailing != null && stack) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [texts, const SizedBox(height: 12), trailing!],
      );
    } else {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: texts),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      );
    }

    return Padding(
      padding: padding,
      child: Padding(padding: const EdgeInsets.only(bottom: 18), child: content),
    );
  }
}
