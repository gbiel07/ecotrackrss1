import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Logotipo "✳ EcoTrack RSS".
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.textColor = AppColors.ink,
    this.fontSize = 21,
  });

  final Color textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.brandMark,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.emergency_outlined, size: 20, color: AppColors.brandMarkIcon),
        ),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            text: 'EcoTrack',
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: -0.8,
              color: textColor,
            ),
            children: const [
              TextSpan(
                text: ' RSS',
                style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.brandLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Caixa com borda tracejada (.scanner-placeholder, .qr-box).
class DashedBorderBox extends StatelessWidget {
  const DashedBorderBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = const Color(0xFFCBD9D2),
    this.background = AppColors.softer,
    this.radius = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color background;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(0.5);
    final path = Path()..addRRect(rect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Ícone quadrado arredondado usado em atalhos e ferramentas.
class SquareIcon extends StatelessWidget {
  const SquareIcon({
    super.key,
    required this.icon,
    this.size = 36,
    this.background = const Color(0xFFE7F5ED),
    this.color = const Color(0xFF267E5D),
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, size: size / 2, color: color),
    );
  }
}

/// Cartão de acesso rápido (.quick-action).
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.softer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SquareIcon(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.subtle)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item de atividade com ponto colorido (.activity-item).
class ActivityItem extends StatelessWidget {
  const ActivityItem({
    super.key,
    required this.title,
    required this.description,
    required this.caption,
    this.dotColor = const Color(0xFF5DBB94),
    this.showDivider = true,
  });

  final String title;
  final String description;
  final String caption;
  final Color dotColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.lineSoft))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF7F8E88)),
                ),
                const SizedBox(height: 5),
                Text(caption, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
