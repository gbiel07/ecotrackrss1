import '../../core/constants/app_constants.dart';
import 'json_utils.dart';

/// Ocorrência (desvio ou pendência) relacionada a um lote.
class Occurrence {
  const Occurrence({
    required this.id,
    required this.lotId,
    required this.type,
    required this.description,
    required this.priority,
    required this.status,
    required this.responsible,
    required this.date,
  });

  factory Occurrence.fromJson(Map<String, dynamic> json) {
    return Occurrence(
      id: JsonUtils.string(json, 'id'),
      lotId: JsonUtils.string(json, 'lotId'),
      type: JsonUtils.string(json, 'type'),
      description: JsonUtils.string(json, 'description'),
      priority: JsonUtils.string(json, 'priority'),
      status: JsonUtils.string(json, 'status'),
      responsible: JsonUtils.string(json, 'responsible'),
      date: JsonUtils.date(json, 'date') ?? DateTime.now(),
    );
  }

  final String id;
  final String lotId;
  final String type;
  final String description;
  final String priority;
  final String status;
  final String responsible;
  final DateTime date;

  bool get isOpen => status != OccurrenceStatus.resolved;

  Occurrence copyWith({String? status}) {
    return Occurrence(
      id: id,
      lotId: lotId,
      type: type,
      description: description,
      priority: priority,
      status: status ?? this.status,
      responsible: responsible,
      date: date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lotId': lotId,
        'type': type,
        'description': description,
        'priority': priority,
        'status': status,
        'responsible': responsible,
        'date': JsonUtils.encodeDate(date),
      };
}
