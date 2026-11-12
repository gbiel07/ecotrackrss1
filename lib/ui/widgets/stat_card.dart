import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/breakpoints.dart';
import 'app_panel.dart';
import 'layout.dart';

/// Indicador numérico (.stat-card).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    this.foot = '',
  });

  final String label;
  final int value;
  final IconData icon;
  final AppTone tone;
  final String foot;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return AppPanel(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF72847D),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: tone.background,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: tone.foreground),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.w800,
              fontSize: isMobile ? 23 : 27,
              letterSpacing: -1,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(foot, style: const TextStyle(fontSize: 11, color: AppColors.subtle)),
        ],
      ),
    );
  }
}

/// Linha de quatro indicadores (.stats-grid): 4 colunas, ou 2 em telas menores.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.cards});

  final List<StatCard> cards;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: ResponsiveGrid(
        columns: Breakpoints.isCompact(context) ? 2 : 4,
        spacing: isMobile ? 10 : 15,
        runSpacing: isMobile ? 10 : 15,
        equalHeight: true,
        children: cards,
      ),
    );
  }
}
