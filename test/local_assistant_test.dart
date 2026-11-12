import 'package:ecotrack_rss/data/models/waste_lot.dart';
import 'package:ecotrack_rss/data/seed/demo_data.dart';
import 'package:ecotrack_rss/logic/local_assistant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final now = DateTime(2026, 11, 12, 10);

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  LocalAssistant buildAssistant() => LocalAssistant(DemoData.build(now), clock: () => now);

  test('análise lista as ocorrências abertas dos dados de demonstração', () {
    final text = buildAssistant().analyze();
    expect(text, contains('ANÁLISE LOCAL DE CONSISTÊNCIA'));
    expect(text, contains('• Ocorrências abertas: 2'));
    expect(text, contains('OCO-002'));
  });

  test('aponta lote sem movimentação registrada', () {
    final data = DemoData.build(now);
    final orphan = WasteLot(
      id: 'RSS-2026-099',
      description: 'Lote de teste',
      group: 'D',
      sector: 'Recepção',
      quantity: 1,
      unit: 'kg',
      responsible: 'Teste',
      createdAt: now,
      status: 'Armazenado',
      destination: 'Central de resíduos',
    );
    final assistant = LocalAssistant(data.copyWith(lots: [...data.lots, orphan]), clock: () => now);
    expect(
      assistant.checks(),
      contains('Lote RSS-2026-099: não possui movimentação registrada.'),
    );
  });

  test('chat responde dados de um lote pelo código', () {
    final text = buildAssistant().answer('Consulte o lote RSS-2026-001');
    expect(text, contains('Dados do lote RSS-2026-001'));
    expect(text, contains('Materiais de curativo e gaze'));
    expect(text, contains('Quantidade: 18 kg'));
  });

  test('chat retorna resumo quando a pergunta cita o dashboard', () {
    final text = buildAssistant().answer('Resuma o dashboard');
    expect(text, startsWith('RESUMO DO ECOTRACK RSS'));
    expect(text, contains('Total de lotes: 5'));
  });

  test('chat explica o que sabe responder quando não reconhece a pergunta', () {
    final text = buildAssistant().answer('Bom dia!');
    expect(text, contains('Posso responder com base nos registros locais'));
  });

  test('relatório inclui seções de pendências e conferência', () {
    final text = buildAssistant().report();
    expect(text, contains('RELATÓRIO OPERACIONAL — ECOTRACK RSS'));
    expect(text, contains('OCORRÊNCIAS PENDENTES'));
    expect(text, contains('PONTOS PARA CONFERÊNCIA'));
  });
}
