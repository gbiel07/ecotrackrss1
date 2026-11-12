import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Etiqueta arredondada de status (.pill) com o ponto colorido à esquerda.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, this.tone = AppTone.gray});

  /// Escolhe a cor automaticamente a partir do status do lote ou da ocorrência.
  factory StatusPill.status(String status, {Key? key}) {
    return StatusPill(key: key, label: status, tone: toneForStatus(status));
  }

  /// Pílula de prioridade de ocorrência (ex.: "Alta prioridade").
  factory StatusPill.priority(String priority, {Key? key}) {
    final tone = switch (priority) {
      OccurrencePriority.high => AppTone.red,
      OccurrencePriority.medium => AppTone.orange,
      _ => AppTone.gray,
    };
    return StatusPill(key: key, label: '$priority prioridade', tone: tone);
  }

  final String label;
  final AppTone tone;

  static AppTone toneForStatus(String status) {
    switch (status) {
      case LotStatus.stored:
      case OccurrenceStatus.inAnalysis:
        return AppTone.blue;
      case LotStatus.inTransport:
      case LotStatus.inTreatment:
        return AppTone.orange;
      case LotStatus.completed:
      case OccurrenceStatus.resolved:
        return AppTone.green;
      case OccurrenceStatus.pending:
        return AppTone.red;
      default:
        return AppTone.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: tone.foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: tone.foreground),
          ),
        ],
      ),
    );
  }
}
