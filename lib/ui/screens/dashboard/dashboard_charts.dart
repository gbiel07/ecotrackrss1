import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Valores de um mês no gráfico de barras.
class MonthlyBar {
  const MonthlyBar({required this.label, required this.lots, required this.movements});

  final String label;
  final int lots;
  final int movements;
}

/// Gráfico de barras duplas: lotes cadastrados × movimentações por mês.
class MonthlyVolumeChart extends StatelessWidget {
  const MonthlyVolumeChart({super.key, required this.bars});

  final List<MonthlyBar> bars;

  @override
  Widget build(BuildContext context) {
    final maxLots = bars.fold<int>(1, (max, bar) => bar.lots > max ? bar.lots : max);
    final maxMoves = bars.fold<int>(1, (max, bar) => bar.movements > max ? bar.movements : max);

    double factor(int value, int max) {
      final ratio = value / max;
      return ratio < 0.04 ? 0.04 : ratio;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 185,
          child: CustomPaint(
            painter: _GridPainter(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final bar in bars)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _Bar(
                                    heightFactor: factor(bar.lots, maxLots),
                                    color: AppColors.chartPrimary,
                                    tooltip: '${bar.lots} lote(s)',
                                  ),
                                  const SizedBox(width: 4),
                                  _Bar(
                                    heightFactor: factor(bar.movements, maxMoves),
                                    color: AppColors.chartAlt,
                                    tooltip: '${bar.movements} movimentação(ões)',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bar.label,
                              style: const TextStyle(fontSize: 10, color: AppColors.subtle),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 13),
        const Wrap(
          spacing: 15,
          runSpacing: 6,
          children: [
            _LegendItem(color: AppColors.chartPrimary, label: 'Lotes cadastrados'),
            _LegendItem(color: AppColors.chartAlt, label: 'Movimentações'),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.heightFactor, required this.color, required this.tooltip});

  final double heightFactor;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF7F8E88))),
      ],
    );
  }
}

/// Linhas horizontais de fundo (a cada 46 px) e linha de base.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 1;
    for (var y = 45.5; y < size.height - 24; y += 46) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final base = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 0.5), Offset(size.width, size.height - 0.5), base);
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

/// Barras horizontais de distribuição por grupo de resíduo.
class GroupDistribution extends StatelessWidget {
  const GroupDistribution({super.key, required this.counts});

  /// Quantidade de lotes por código de grupo (A–E).
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final max = counts.values.fold<int>(1, (m, v) => v > m ? v : m);
    return Column(
      children: [
        for (final code in WasteGroups.codes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(WasteGroups.nameOf(code), style: const TextStyle(fontSize: 11)),
                    ),
                    Text(
                      '${counts[code] ?? 0}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 6,
                    color: AppColors.chartGrid,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (counts[code] ?? 0) / max,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.groupColors[code] ?? AppColors.chartPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
