import '../core/utils/formatters.dart';
import '../data/models/ecotrack_data.dart';
import '../data/models/movement.dart';
import '../data/models/occurrence.dart';
import '../data/models/waste_lot.dart';

/// Assistente local por palavras-chave e regras programadas.
///
/// Não usa modelo generativo nem API externa: os textos são montados a partir
/// dos registros salvos no dispositivo, exatamente como na versão web.
class LocalAssistant {
  LocalAssistant(this.data, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final EcoTrackData data;
  final DateTime Function() _clock;

  List<WasteLot> get _lots => data.lots;
  List<Movement> get _movements => data.movements;
  List<Occurrence> get _occurrences => data.occurrences;
  List<Occurrence> get _open => _occurrences.where((occurrence) => occurrence.isOpen).toList();

  // ---------------------------------------------------------------------------
  // Verificações programadas
  // ---------------------------------------------------------------------------

  /// Pontos para conferência: campos ausentes, referências inválidas e pendências.
  List<String> checks() {
    final result = <String>[];
    final lotIds = _lots.map((lot) => lot.id).toSet();

    for (final lot in _lots) {
      final missing = <String>[
        if (lot.id.isEmpty) 'identificador',
        if (lot.description.isEmpty) 'descrição',
        if (lot.group.isEmpty) 'grupo',
        if (lot.sector.isEmpty) 'setor de origem',
        if (!lot.quantity.isFinite || lot.quantity <= 0) 'quantidade positiva',
        if (lot.status.isEmpty) 'status',
        if (lot.destination.isEmpty) 'destino',
      ];
      if (missing.isNotEmpty) {
        result.add('Lote ${_or(lot.id, 'sem identificador')}: conferir ${missing.join(', ')}.');
      }
      if (!_movements.any((movement) => movement.lotId == lot.id)) {
        result.add('Lote ${lot.id}: não possui movimentação registrada.');
      }
    }

    for (final movement in _movements) {
      final missing = <String>[
        if (movement.id.isEmpty) 'identificador da movimentação',
        if (movement.lotId.isEmpty) 'lote relacionado',
        if (movement.action.isEmpty) 'ação',
        if (movement.responsible.isEmpty) 'responsável',
        if (movement.date == null) 'data',
        if (movement.from.isEmpty) 'origem',
        if (movement.to.isEmpty) 'destino',
      ];
      if (movement.lotId.isNotEmpty && !lotIds.contains(movement.lotId)) {
        result.add('Movimentação ${_or(movement.id, 'sem ID')}: '
            'referencia lote inexistente (${movement.lotId}).');
      }
      if (missing.isNotEmpty) {
        result.add('Movimentação ${_or(movement.id, 'sem identificador')}: '
            'conferir ${missing.join(', ')}.');
      }
    }

    for (final occurrence in _occurrences) {
      final id = _or(occurrence.id, 'sem ID');
      if (occurrence.lotId.isNotEmpty && !lotIds.contains(occurrence.lotId)) {
        result.add('Ocorrência $id: referencia lote inexistente (${occurrence.lotId}).');
      }
      if (occurrence.description.isEmpty) {
        result.add('Ocorrência $id: descrição ausente.');
      }
      if (occurrence.isOpen) {
        result.add('Ocorrência $id (${_or(occurrence.priority, 'prioridade não informada')}): '
            'está ${_or(occurrence.status, 'sem status')} — '
            '${_or(occurrence.type, 'tipo não informado')}.');
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Textos gerados
  // ---------------------------------------------------------------------------

  String summary() {
    final recent = _recentMovements(5)
        .map((m) => '• ${_or(m.id, 'MOV')} — lote ${_or(m.lotId, 'não informado')}: '
            '${_or(m.action, 'ação não informada')} (${Formatters.dateTimeFull(m.date)})')
        .join('\n');
    return [
      'RESUMO DO ECOTRACK RSS',
      'Gerado em: ${Formatters.dateTimeFull(_clock())}',
      'Total de lotes: ${_lots.length}',
      'Total de movimentações: ${_movements.length}',
      'Total de ocorrências: ${_occurrences.length}',
      'Ocorrências não resolvidas: ${_open.length}',
      '\nLotes por status:\n${_countText(_countBy(_lots, (WasteLot l) => l.status))}',
      '\nLotes por grupo:\n${_countText(_countBy(_lots, (WasteLot l) => l.group))}',
      '\nOcorrências por status:\n'
          '${_countText(_countBy(_occurrences, (Occurrence o) => o.status))}',
      '\nMovimentações mais recentes:\n'
          '${recent.isEmpty ? '• Nenhuma movimentação registrada' : recent}',
    ].join('\n');
  }

  String analyze() {
    final items = checks();
    final points = items.isEmpty
        ? '• Nenhuma inconsistência básica identificada pelas verificações programadas.'
        : items.map((item) => '• $item').join('\n');
    return 'ANÁLISE LOCAL DE CONSISTÊNCIA\n\n'
        'Resumo:\n'
        '• Lotes: ${_lots.length}\n'
        '• Movimentações: ${_movements.length}\n'
        '• Ocorrências abertas: ${_open.length}\n\n'
        'Pontos para conferência:\n$points\n\n'
        'Limitação: estas regras verificam apenas campos e referências simples. '
        'Não comprovam conformidade legal ou operacional; revise os registros com o '
        'responsável técnico.';
  }

  String dashboardSummary() {
    final attention = _open.isEmpty
        ? '• Nenhuma ocorrência em aberto nos dados atuais.'
        : _open
            .map((o) => '• ${o.id} — ${o.type}, prioridade ${o.priority}, '
                'status ${o.status}, lote ${o.lotId}')
            .join('\n');
    return '${summary()}\n\nPontos de atenção:\n$attention\n\n'
        'Este resumo foi calculado localmente a partir dos registros disponíveis.';
  }

  String report() {
    final pending = _open.isEmpty
        ? 'Nenhuma ocorrência pendente registrada.'
        : _open
            .map((o) => '• ${o.id} | Lote: ${o.lotId} | Tipo: ${o.type} | '
                'Prioridade: ${o.priority} | Status: ${o.status}\n'
                '  Descrição: ${_or(o.description, 'Não informada')}')
            .join('\n');
    final items = checks();
    final points = items.isEmpty
        ? 'Nenhum alerta básico identificado pelas regras programadas.'
        : items.map((item) => '• $item').join('\n');
    return 'RELATÓRIO OPERACIONAL — ECOTRACK RSS\n\n'
        '${summary()}\n\n'
        'OCORRÊNCIAS PENDENTES\n$pending\n\n'
        'PONTOS PARA CONFERÊNCIA\n$points\n\n'
        'Relatório gerado por regras locais. Conferência humana necessária; '
        'não constitui certificação de conformidade.';
  }

  /// Responde perguntas a partir de palavras-chave.
  String answer(String question) {
    final q = question.toLowerCase();

    if (RegExp('resumo|dashboard|indicador|visão geral|situação geral').hasMatch(q)) {
      return summary();
    }

    if (RegExp('inconsist|erro|problema|campo vazio|pendência|pendente|atenção|alerta')
        .hasMatch(q)) {
      final items = checks();
      final body = items.isEmpty
          ? '• Nenhuma inconsistência básica identificada pelas regras programadas.'
          : items.map((item) => '• $item').join('\n');
      return 'VERIFICAÇÕES E PENDÊNCIAS LOCAIS\n\n$body\n\n'
          'Ocorrências abertas: ${_open.length}.';
    }

    if (q.contains('ocorrên') || q.contains('ocorren')) {
      final open = _open.isEmpty
          ? '• Nenhuma ocorrência aberta.'
          : _open
              .map((o) => '• ${o.id} — ${o.type}; lote ${o.lotId}; prioridade ${o.priority}; '
                  'status ${o.status}. ${o.description}')
              .join('\n');
      return 'Ocorrências registradas: ${_occurrences.length}.\n\n'
          'Por status:\n${_countText(_countBy(_occurrences, (Occurrence o) => o.status))}\n\n'
          'Em aberto:\n$open';
    }

    if (RegExp('movimenta|histórico|historico|historia').hasMatch(q)) {
      final recent = _recentMovements(10)
          .map((m) => '• ${m.id} — lote ${m.lotId}: ${m.action}; '
              'responsável: ${_or(m.responsible, 'não informado')}; '
              'data: ${m.date == null ? 'não informada' : Formatters.dateTimeFull(m.date)}.')
          .join('\n');
      return 'Movimentações registradas: ${_movements.length}.\n\n'
          'Mais recentes:\n${recent.isEmpty ? '• Nenhuma movimentação registrada.' : recent}';
    }

    if (RegExp('lote|grupo|quantidade|status').hasMatch(q)) {
      WasteLot? match;
      for (final lot in _lots) {
        if (lot.id.isNotEmpty && q.contains(lot.id.toLowerCase())) {
          match = lot;
          break;
        }
      }
      if (match != null) {
        final lot = match;
        final movementCount = _movements.where((m) => m.lotId == lot.id).length;
        final occurrenceCount = _occurrences.where((o) => o.lotId == lot.id).length;
        return 'Dados do lote ${lot.id}:\n'
            '• Descrição: ${_or(lot.description, 'Não informada')}\n'
            '• Grupo: ${_or(lot.group, 'Não informado')}\n'
            '• Setor: ${_or(lot.sector, 'Não informado')}\n'
            '• Quantidade: ${Formatters.quantity(lot.quantity)} ${lot.unit}\n'
            '• Status: ${_or(lot.status, 'Não informado')}\n'
            '• Destino: ${_or(lot.destination, 'Não informado')}\n'
            '• Movimentações: $movementCount\n'
            '• Ocorrências: $occurrenceCount';
      }
      return 'Total de lotes: ${_lots.length}.\n\n'
          'Lotes por status:\n${_countText(_countBy(_lots, (WasteLot l) => l.status))}\n\n'
          'Lotes por grupo:\n${_countText(_countBy(_lots, (WasteLot l) => l.group))}\n\n'
          'Para consultar um lote específico, informe seu código completo, '
          'por exemplo RSS-2026-001.';
    }

    return 'Posso responder com base nos registros locais sobre lotes, grupos, status, '
        'quantidades, movimentações, ocorrências, pendências e indicadores. '
        'Experimente perguntar: ‘Quais ocorrências estão pendentes?’, ‘Resuma o dashboard’ '
        'ou ‘Consulte o lote RSS-2026-001’. Este assistente usa regras programadas, não um '
        'modelo generativo, portanto não interpreta perguntas tão livremente quanto uma IA '
        'conversacional online.';
  }

  // ---------------------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------------------

  List<Movement> _recentMovements(int limit) {
    final items = [..._movements];
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    items.sort((a, b) => (b.date ?? epoch).compareTo(a.date ?? epoch));
    return items.take(limit).toList();
  }

  static Map<String, int> _countBy<T>(Iterable<T> items, String Function(T item) key) {
    final result = <String, int>{};
    for (final item in items) {
      final value = _or(key(item), 'Não informado');
      result[value] = (result[value] ?? 0) + 1;
    }
    return result;
  }

  static String _countText(Map<String, int> counts) {
    if (counts.isEmpty) return '• Nenhum registro';
    return counts.entries.map((entry) => '• ${entry.key}: ${entry.value}').join('\n');
  }

  static String _or(String value, String fallback) => value.isEmpty ? fallback : value;
}

/// Sugestões de perguntas exibidas como atalhos no chat.
const List<String> assistantSuggestions = [
  'Quais ocorrências estão pendentes?',
  'Resuma o dashboard',
  'Consulte o lote RSS-2026-001',
  'Mostre as movimentações recentes',
];
