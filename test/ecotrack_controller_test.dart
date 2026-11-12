import 'package:ecotrack_rss/core/constants/app_constants.dart';
import 'package:ecotrack_rss/data/models/app_user.dart';
import 'package:ecotrack_rss/data/models/ecotrack_data.dart';
import 'package:ecotrack_rss/data/repositories/ecotrack_repository.dart';
import 'package:ecotrack_rss/logic/ecotrack_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const manager = AppUser(username: 'gestor', name: 'Ana Martins', role: UserRole.manager);
  const employee = AppUser(username: 'funcionario', name: 'Marcos Oliveira', role: UserRole.employee);

  late EcoTrackController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    controller = EcoTrackController(
      EcoTrackRepository(),
      clock: () => DateTime(2026, 11, 12, 9, 30),
    );
    await controller.load();
  });

  test('primeiro acesso carrega os dados de demonstração', () {
    expect(controller.status, LoadStatus.ready);
    expect(controller.lots, hasLength(5));
    expect(controller.movements, hasLength(5));
    expect(controller.occurrences, hasLength(2));
  });

  test('cadastrar lote gera código sequencial e movimentação inicial', () async {
    final lot = await controller.createLot(
      description: 'Luvas descartáveis',
      group: 'A',
      sector: 'UTI',
      quantity: 3.5,
      unit: 'kg',
      status: LotStatus.stored,
      destination: '',
      notes: '',
      user: manager,
    );

    expect(lot.id, 'RSS-2026-006');
    expect(lot.destination, 'A definir');
    expect(controller.lots.first.id, 'RSS-2026-006');
    expect(controller.movementsOfLot(lot.id).single.action, 'Lote registrado');
    expect(controller.data.nextLot, 7);
  });

  test('confirmar coleta externa muda o status para Em transporte', () async {
    final lot = controller.lotById('RSS-2026-001')!;
    await controller.registerMovement(
      lot: lot,
      action: 'Coleta externa confirmada',
      from: 'Central de resíduos',
      to: 'Empresa licenciada',
      notes: '',
      user: employee,
    );

    expect(controller.lotById('RSS-2026-001')!.status, LotStatus.inTransport);
    expect(controller.movements.first.id, 'MOV-0006');
  });

  test('resolver ocorrência reduz as ocorrências abertas', () async {
    expect(controller.openOccurrences, hasLength(2));
    await controller.updateOccurrenceStatus('OCO-001', OccurrenceStatus.resolved);
    expect(controller.openOccurrences, hasLength(1));
  });

  test('dados persistem entre sessões', () async {
    await controller.createOccurrence(
      lotId: 'RSS-2026-003',
      type: 'Outro',
      description: 'Teste de persistência',
      priority: OccurrencePriority.low,
      status: OccurrenceStatus.pending,
      user: employee,
    );

    final reloaded = EcoTrackController(EcoTrackRepository());
    await reloaded.load();
    expect(reloaded.occurrenceById('OCO-003')?.description, 'Teste de persistência');
  });

  test('JSON salvo mantém o formato da versão web', () {
    final json = controller.data.toJson();
    final restored = EcoTrackData.fromJson(json);
    expect(restored.lots.first.id, controller.lots.first.id);
    expect(json['nextOccurrence'], 3);
  });
}
