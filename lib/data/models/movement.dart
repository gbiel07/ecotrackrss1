import 'json_utils.dart';

/// Movimentação (etapa de rastreabilidade) de um lote.
class Movement {
  const Movement({
    required this.id,
    required this.lotId,
    required this.action,
    required this.from,
    required this.to,
    required this.responsible,
    required this.date,
    this.notes = '',
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      id: JsonUtils.string(json, 'id'),
      lotId: JsonUtils.string(json, 'lotId'),
      action: JsonUtils.string(json, 'action'),
      from: JsonUtils.string(json, 'from'),
      to: JsonUtils.string(json, 'to'),
      responsible: JsonUtils.string(json, 'responsible'),
      date: JsonUtils.date(json, 'date'),
      notes: JsonUtils.string(json, 'notes'),
    );
  }

  final String id;
  final String lotId;
  final String action;
  final String from;
  final String to;
  final String responsible;

  /// Pode ser nula em registros antigos; a análise local aponta isso.
  final DateTime? date;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'lotId': lotId,
        'action': action,
        'from': from,
        'to': to,
        'responsible': responsible,
        'date': date == null ? null : JsonUtils.encodeDate(date!),
        'notes': notes,
      };
}
