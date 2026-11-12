import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import 'layout.dart';

/// Par rótulo/valor exibido nas telas de detalhe.
class DetailEntry {
  const DetailEntry(this.label, this.value);

  final String label;
  final String value;
}

/// Bloco cinza com rótulo pequeno e valor em negrito (.detail-item).
class DetailItem extends StatelessWidget {
  const DetailItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF87968F))),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grade de detalhes (.detail-grid): 3 colunas, 2 em telas médias e 1 no celular.
class DetailGrid extends StatelessWidget {
  const DetailGrid({super.key, required this.entries, this.maxColumns = 3});

  final List<DetailEntry> entries;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    final columns = Breakpoints.detailColumns(context);
    return ResponsiveGrid(
      columns: columns > maxColumns ? maxColumns : columns,
      spacing: 13,
      runSpacing: 13,
      equalHeight: true,
      children: [
        for (final entry in entries) DetailItem(label: entry.label, value: entry.value),
      ],
    );
  }
}
