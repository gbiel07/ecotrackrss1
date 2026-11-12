import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/models/app_user.dart';
import '../data/models/ecotrack_data.dart';
import '../data/models/movement.dart';
import '../data/models/occurrence.dart';
import '../data/models/waste_lot.dart';
import '../data/repositories/ecotrack_repository.dart';

enum LoadStatus { loading, ready, error }

/// Regras de negócio e estado dos registros (lotes, movimentações e ocorrências).
class EcoTrackController extends ChangeNotifier {
  EcoTrackController(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final EcoTrackRepository _repository;
  final DateTime Function() _clock;

  LoadStatus _status = LoadStatus.loading;
  String? _errorMessage;
  EcoTrackData _data = const EcoTrackData.empty();

  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  EcoTrackData get data => _data;

  List<WasteLot> get lots => List.unmodifiable(_data.lots);
  List<Movement> get movements => List.unmodifiable(_data.movements);
  List<Occurrence> get occurrences => List.unmodifiable(_data.occurrences);

  /// Movimentações da mais recente para a mais antiga.
  List<Movement> get sortedMovements {
    final items = [..._data.movements];
    items.sort((a, b) => _compareDesc(a.date, b.date));
    return items;
  }

  /// Lotes do mais recente para o mais antigo.
  List<WasteLot> get sortedLots {
    final items = [..._data.lots];
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<Occurrence> get openOccurrences =>
      _data.occurrences.where((occurrence) => occurrence.isOpen).toList();

  int countLotsWithStatus(Iterable<String> statuses) {
    final set = statuses.toSet();
    return _data.lots.where((lot) => set.contains(lot.status)).length;
  }

  int countOccurrencesWithStatus(String status) {
    return _data.occurrences.where((occurrence) => occurrence.status == status).length;
  }

  WasteLot? lotById(String id) {
    for (final lot in _data.lots) {
      if (lot.id == id) return lot;
    }
    return null;
  }

  /// Busca sem diferenciar maiúsculas de minúsculas (leitura de QR ou digitação).
  WasteLot? findLotByCode(String code) {
    final clean = code.trim().toLowerCase();
    if (clean.isEmpty) return null;
    for (final lot in _data.lots) {
      if (lot.id.toLowerCase() == clean) return lot;
    }
    return null;
  }

  Movement? movementById(String id) {
    for (final movement in _data.movements) {
      if (movement.id == id) return movement;
    }
    return null;
  }

  Occurrence? occurrenceById(String id) {
    for (final occurrence in _data.occurrences) {
      if (occurrence.id == id) return occurrence;
    }
    return null;
  }

  List<Movement> movementsOfLot(String lotId) {
    return sortedMovements.where((movement) => movement.lotId == lotId).toList();
  }

  Future<void> load() async {
    if (_status != LoadStatus.loading) {
      _status = LoadStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      _data = await _repository.load();
      _status = LoadStatus.ready;
    } catch (error) {
      _status = LoadStatus.error;
      _errorMessage = error is StorageException
          ? error.message
          : 'Não foi possível carregar os registros salvos neste dispositivo.';
    }
    notifyListeners();
  }

  Future<void> resetToDemoData() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _data = await _repository.resetToDemo();
      _status = LoadStatus.ready;
      _errorMessage = null;
    } catch (_) {
      _status = LoadStatus.error;
      _errorMessage = 'Não foi possível restaurar os dados de demonstração.';
    }
    notifyListeners();
  }

  Future<WasteLot> createLot({
    required String description,
    required String group,
    required String sector,
    required double quantity,
    required String unit,
    required String status,
    required String destination,
    required String notes,
    required AppUser user,
  }) async {
    final now = _clock();
    final lot = WasteLot(
      id: 'RSS-${now.year}-${_data.nextLot.toString().padLeft(3, '0')}',
      description: description.trim(),
      group: group,
      sector: sector.trim(),
      quantity: quantity,
      unit: unit,
      responsible: user.name,
      createdAt: now,
      status: status,
      destination: destination.trim().isEmpty ? 'A definir' : destination.trim(),
      notes: notes.trim(),
    );
    final movement = Movement(
      id: _movementId(_data.nextMovement),
      lotId: lot.id,
      action: 'Lote registrado',
      from: lot.sector,
      to: lot.destination,
      responsible: user.name,
      date: now,
      notes: 'Cadastro inicial do lote',
    );
    await _commit(_data.copyWith(
      lots: [lot, ..._data.lots],
      movements: [movement, ..._data.movements],
      nextLot: _data.nextLot + 1,
      nextMovement: _data.nextMovement + 1,
    ));
    return lot;
  }

  /// Registra uma etapa e atualiza o status do lote conforme a ação.
  Future<void> registerMovement({
    required WasteLot lot,
    required String action,
    required String from,
    required String to,
    required String notes,
    required AppUser user,
  }) async {
    final current = lotById(lot.id) ?? lot;
    final newStatus = MovementActions.resultingStatus(action, current.status);
    final movement = Movement(
      id: _movementId(_data.nextMovement),
      lotId: lot.id,
      action: action,
      from: from.trim(),
      to: to.trim(),
      responsible: user.name,
      date: _clock(),
      notes: notes.trim(),
    );
    await _commit(_data.copyWith(
      lots: _replaceLot(current.copyWith(status: newStatus)),
      movements: [movement, ..._data.movements],
      nextMovement: _data.nextMovement + 1,
    ));
  }

  Future<void> updateLotStatus({
    required WasteLot lot,
    required String newStatus,
    required String notes,
    required AppUser user,
  }) async {
    final current = lotById(lot.id) ?? lot;
    final movement = Movement(
      id: _movementId(_data.nextMovement),
      lotId: lot.id,
      action: 'Status atualizado: ${current.status} → $newStatus',
      from: current.status,
      to: newStatus,
      responsible: user.name,
      date: _clock(),
      notes: notes.trim(),
    );
    await _commit(_data.copyWith(
      lots: _replaceLot(current.copyWith(status: newStatus)),
      movements: [movement, ..._data.movements],
      nextMovement: _data.nextMovement + 1,
    ));
  }

  Future<Occurrence> createOccurrence({
    required String lotId,
    required String type,
    required String description,
    required String priority,
    required String status,
    required AppUser user,
  }) async {
    final occurrence = Occurrence(
      id: 'OCO-${_data.nextOccurrence.toString().padLeft(3, '0')}',
      lotId: lotId,
      type: type,
      description: description.trim(),
      priority: priority,
      status: status,
      responsible: user.name,
      date: _clock(),
    );
    await _commit(_data.copyWith(
      occurrences: [occurrence, ..._data.occurrences],
      nextOccurrence: _data.nextOccurrence + 1,
    ));
    return occurrence;
  }

  Future<void> updateOccurrenceStatus(String occurrenceId, String status) async {
    final updated = _data.occurrences
        .map((occurrence) =>
            occurrence.id == occurrenceId ? occurrence.copyWith(status: status) : occurrence)
        .toList();
    await _commit(_data.copyWith(occurrences: updated));
  }

  List<WasteLot> _replaceLot(WasteLot updated) {
    return _data.lots.map((lot) => lot.id == updated.id ? updated : lot).toList();
  }

  String _movementId(int number) => 'MOV-${number.toString().padLeft(4, '0')}';

  static int _compareDesc(DateTime? a, DateTime? b) {
    final first = a ?? DateTime.fromMillisecondsSinceEpoch(0);
    final second = b ?? DateTime.fromMillisecondsSinceEpoch(0);
    return second.compareTo(first);
  }

  /// Atualiza a tela imediatamente e desfaz a alteração se a gravação falhar.
  Future<void> _commit(EcoTrackData next) async {
    final previous = _data;
    _data = next;
    notifyListeners();
    try {
      await _repository.save(next);
    } catch (_) {
      _data = previous;
      notifyListeners();
      rethrow;
    }
  }
}
