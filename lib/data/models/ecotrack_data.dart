import 'json_utils.dart';
import 'movement.dart';
import 'occurrence.dart';
import 'waste_lot.dart';

/// Conjunto completo de registros salvos no dispositivo.
///
/// O formato JSON é o mesmo da versão web (chave `ecotrack_rss_v1`).
class EcoTrackData {
  const EcoTrackData({
    required this.lots,
    required this.movements,
    required this.occurrences,
    required this.nextLot,
    required this.nextMovement,
    required this.nextOccurrence,
  });

  const EcoTrackData.empty()
      : lots = const [],
        movements = const [],
        occurrences = const [],
        nextLot = 1,
        nextMovement = 1,
        nextOccurrence = 1;

  factory EcoTrackData.fromJson(Map<String, dynamic> json) {
    final lots = JsonUtils.list(json, 'lots').map(WasteLot.fromJson).toList();
    final movements = JsonUtils.list(json, 'movements').map(Movement.fromJson).toList();
    final occurrences = JsonUtils.list(json, 'occurrences').map(Occurrence.fromJson).toList();
    return EcoTrackData(
      lots: lots,
      movements: movements,
      occurrences: occurrences,
      nextLot: JsonUtils.integer(json, 'nextLot', lots.length + 1),
      nextMovement: JsonUtils.integer(json, 'nextMovement', movements.length + 1),
      nextOccurrence: JsonUtils.integer(json, 'nextOccurrence', occurrences.length + 1),
    );
  }

  final List<WasteLot> lots;
  final List<Movement> movements;
  final List<Occurrence> occurrences;
  final int nextLot;
  final int nextMovement;
  final int nextOccurrence;

  EcoTrackData copyWith({
    List<WasteLot>? lots,
    List<Movement>? movements,
    List<Occurrence>? occurrences,
    int? nextLot,
    int? nextMovement,
    int? nextOccurrence,
  }) {
    return EcoTrackData(
      lots: lots ?? this.lots,
      movements: movements ?? this.movements,
      occurrences: occurrences ?? this.occurrences,
      nextLot: nextLot ?? this.nextLot,
      nextMovement: nextMovement ?? this.nextMovement,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
    );
  }

  Map<String, dynamic> toJson() => {
        'lots': lots.map((lot) => lot.toJson()).toList(),
        'movements': movements.map((movement) => movement.toJson()).toList(),
        'occurrences': occurrences.map((occurrence) => occurrence.toJson()).toList(),
        'nextLot': nextLot,
        'nextMovement': nextMovement,
        'nextOccurrence': nextOccurrence,
      };
}
