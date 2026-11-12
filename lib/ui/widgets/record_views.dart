import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/movement.dart';
import '../../data/models/occurrence.dart';
import '../../data/models/waste_lot.dart';
import 'app_button.dart';
import 'app_table.dart';
import 'layout.dart';
import 'status_pill.dart';

/// Tabela de lotes (código, descrição, grupo, setor, quantidade, status).
class LotsTable extends StatelessWidget {
  const LotsTable({super.key, required this.lots, this.onView});

  final List<WasteLot> lots;

  /// Quando informado, exibe a coluna "Ação" com o botão Visualizar.
  final ValueChanged<WasteLot>? onView;

  @override
  Widget build(BuildContext context) {
    if (lots.isEmpty) {
      return const EmptyState(message: 'Nenhum lote encontrado com esses filtros.');
    }
    final onView = this.onView;
    return AppTable(
      columns: [
        const AppTableColumn('Código do lote', width: 135),
        const AppTableColumn('Descrição', width: 250),
        const AppTableColumn('Grupo', width: 80),
        const AppTableColumn('Setor de origem', width: 170),
        const AppTableColumn('Quantidade', width: 110),
        const AppTableColumn('Status', width: 175),
        if (onView != null) const AppTableColumn('Ação', width: 115),
      ],
      rows: [
        for (final lot in lots)
          [
            CellText.code(lot.id),
            CellText.strong(lot.description),
            CellText(lot.group),
            CellText(lot.sector),
            CellText('${Formatters.quantity(lot.quantity)} ${lot.unit}'),
            StatusPill.status(lot.status),
            if (onView != null) TableActionButton(label: 'Visualizar', onPressed: () => onView(lot)),
          ],
      ],
    );
  }
}

/// Tabela de movimentações (código, lote, ação, responsável, data).
class MovementsTable extends StatelessWidget {
  const MovementsTable({super.key, required this.movements, this.onDetails});

  final List<Movement> movements;
  final ValueChanged<Movement>? onDetails;

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) {
      return const EmptyState(message: 'Nenhuma movimentação registrada.');
    }
    final onDetails = this.onDetails;
    return AppTable(
      columns: [
        const AppTableColumn('Movimentação', width: 130),
        const AppTableColumn('Lote', width: 130),
        const AppTableColumn('Etapa / ação', width: 260),
        const AppTableColumn('Responsável', width: 160),
        const AppTableColumn('Data', width: 175),
        if (onDetails != null) const AppTableColumn('Detalhes', width: 110),
      ],
      rows: [
        for (final movement in movements)
          [
            CellText.code(movement.id),
            CellText(movement.lotId),
            CellText.strong(movement.action),
            CellText(movement.responsible),
            CellText(Formatters.dateTime(movement.date)),
            if (onDetails != null)
              TableActionButton(label: 'Detalhes', onPressed: () => onDetails(movement)),
          ],
      ],
    );
  }
}

/// Cartão de ocorrência (.occurrence-card).
class OccurrenceCard extends StatelessWidget {
  const OccurrenceCard({super.key, required this.occurrence, required this.onDetails});

  final Occurrence occurrence;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${occurrence.id} · ${occurrence.type}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusPill.status(occurrence.status),
                        StatusPill.priority(occurrence.priority),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TableActionButton(label: 'Detalhes', onPressed: onDetails),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            occurrence.description,
            style: const TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF788981)),
          ),
          const SizedBox(height: 8),
          Text(
            'Lote: ${occurrence.lotId} · Registrada por ${occurrence.responsible} · '
            '${Formatters.dateTime(occurrence.date)}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF9AA8A2)),
          ),
        ],
      ),
    );
  }
}
