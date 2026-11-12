import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

/// Botão padrão (.btn, .btn-primary, .btn-outline...) com estado de carregamento.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
    this.loadingLabel,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool isLoading;
  final String? loadingLabel;
  final bool compact;

  ({Color background, Color foreground, Color? border, Color hover}) get _colors {
    switch (variant) {
      case AppButtonVariant.primary:
        return (
          background: AppColors.green,
          foreground: AppColors.white,
          border: null,
          hover: AppColors.greenDark,
        );
      case AppButtonVariant.secondary:
        return (
          background: const Color(0xFFEDF3F0),
          foreground: const Color(0xFF31534A),
          border: null,
          hover: const Color(0xFFE2ECE7),
        );
      case AppButtonVariant.outline:
        return (
          background: AppColors.white,
          foreground: AppColors.ink,
          border: AppColors.line,
          hover: const Color(0xFFF5F9F7),
        );
      case AppButtonVariant.danger:
        return (
          background: const Color(0xFFFFF0EF),
          foreground: const Color(0xFFB73F3F),
          border: null,
          hover: const Color(0xFFFFE4E2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(9);
    final textStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: compact ? 11 : 14,
      color: colors.foreground,
    );

    final text = Text(
      isLoading ? (loadingLabel ?? 'Processando...') : label,
      style: textStyle,
      overflow: fullWidth ? TextOverflow.ellipsis : null,
      textAlign: TextAlign.center,
    );

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: colors.foreground),
          )
        else if (icon != null)
          Icon(icon, size: compact ? 14 : 17, color: colors.foreground),
        if (isLoading || icon != null) SizedBox(width: compact ? 6 : 9),
        // Flexible só quando o botão ocupa a largura toda: em Row/Wrap sem
        // limite de largura um filho flexível geraria erro de layout.
        if (fullWidth) Flexible(child: text) else text,
      ],
    );

    return Opacity(
      opacity: enabled || isLoading ? 1 : 0.45,
      child: Material(
        color: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: colors.border == null ? BorderSide.none : BorderSide(color: colors.border!),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          hoverColor: colors.hover,
          splashColor: colors.foreground.withAlpha(30),
          highlightColor: colors.hover,
          child: Padding(
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                : const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Link de texto verde (.text-link), ex.: "Ver histórico →".
class AppTextLink extends StatelessWidget {
  const AppTextLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

/// Botão pequeno das tabelas (.table-action), ex.: "Visualizar".
class TableActionButton extends StatelessWidget {
  const TableActionButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F5F2),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        hoverColor: const Color(0xFFE3EDE8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF426456),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
