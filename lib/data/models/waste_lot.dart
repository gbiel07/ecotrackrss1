import 'json_utils.dart';

/// Lote de resíduos de serviços de saúde.
class WasteLot {
  const WasteLot({
    required this.id,
    required this.description,
    required this.group,
    required this.sector,
    required this.quantity,
    required this.unit,
    required this.responsible,
    required this.createdAt,
    required this.status,
    required this.destination,
    this.notes = '',
  });

  factory WasteLot.fromJson(Map<String, dynamic> json) {
    return WasteLot(
      id: JsonUtils.string(json, 'id'),
      description: JsonUtils.string(json, 'description'),
      group: JsonUtils.string(json, 'group'),
      sector: JsonUtils.string(json, 'sector'),
      quantity: JsonUtils.number(json, 'quantity'),
      unit: JsonUtils.string(json, 'unit'),
      responsible: JsonUtils.string(json, 'responsible'),
      createdAt: JsonUtils.date(json, 'createdAt') ?? DateTime.now(),
      status: JsonUtils.string(json, 'status'),
      destination: JsonUtils.string(json, 'destination'),
      notes: JsonUtils.string(json, 'notes'),
    );
  }

  final String id;
  final String description;
  final String group;
  final String sector;
  final double quantity;
  final String unit;
  final String responsible;
  final DateTime createdAt;
  final String status;
  final String destination;
  final String notes;

  WasteLot copyWith({String? status, String? destination, String? notes}) {
    return WasteLot(
      id: id,
      description: description,
      group: group,
      sector: sector,
      quantity: quantity,
      unit: unit,
      responsible: responsible,
      createdAt: createdAt,
      status: status ?? this.status,
      destination: destination ?? this.destination,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'group': group,
        'sector': sector,
        'quantity': quantity,
        'unit': unit,
        'responsible': responsible,
        'createdAt': JsonUtils.encodeDate(createdAt),
        'status': status,
        'destination': destination,
        'notes': notes,
      };
}
