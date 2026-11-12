import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Coluna da tabela com largura mínima (usada também como proporção).
class AppTableColumn {
  const AppTableColumn(this.label, {this.width = 140});

  final String label;
  final double width;
}

/// Tabela com cabeçalho cinza e rolagem horizontal em telas estreitas
/// (.table-wrap / table do CSS).
class AppTable extends StatelessWidget {
  const AppTable({super.key, required this.columns, required this.rows});

  final List<AppTableColumn> columns;
  final List<List<Widget>> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = columns.fold<double>(0, (sum, column) => sum + column.width);
        final available = constraints.maxWidth.isFinite ? constraints.maxWidth : minWidth;
        final width = math.max(minWidth, available);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Table(
              columnWidths: {
                for (var i = 0; i < columns.length; i++) i: FlexColumnWidth(columns[i].width),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: AppColors.tableHead),
                  children: [
                    for (final column in columns)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(column.label.toUpperCase(), style: AppTextStyles.tableHeader),
                      ),
                  ],
                ),
                for (final row in rows)
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.lineSoft)),
                    ),
                    children: [
                      for (final cell in row)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Align(alignment: Alignment.centerLeft, child: cell),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Texto comum de célula.
class CellText extends StatelessWidget {
  const CellText(this.text, {super.key, this.style = AppTextStyles.tableCell});

  /// Texto em destaque (td strong).
  const CellText.strong(this.text, {super.key}) : style = AppTextStyles.tableStrong;

  /// Código do registro (.table-code).
  const CellText.code(this.text, {super.key}) : style = AppTextStyles.tableCode;

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Text(text, style: style);
}
