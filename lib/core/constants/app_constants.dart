/// Constantes de domínio do EcoTrack RSS, equivalentes às da versão web.
abstract final class AppConstants {
  /// Mesma chave usada no localStorage da versão HTML/JS.
  static const String storageKey = 'ecotrack_rss_v1';
  static const String appName = 'EcoTrack RSS';
}

/// Grupos de resíduos de serviços de saúde (RDC ANVISA nº 222/2018).
abstract final class WasteGroups {
  static const Map<String, String> names = {
    'A': 'Grupo A · Infectante',
    'B': 'Grupo B · Químico',
    'C': 'Grupo C · Radioativo',
    'D': 'Grupo D · Comum',
    'E': 'Grupo E · Perfurocortante',
  };

  static List<String> get codes => names.keys.toList();

  static String nameOf(String code) => names[code] ?? code;
}

/// Status possíveis de um lote.
abstract final class LotStatus {
  static const String stored = 'Armazenado';
  static const String inTransport = 'Em transporte';
  static const String inTreatment = 'Em tratamento';
  static const String completed = 'Destinação concluída';

  static const List<String> all = [stored, inTransport, inTreatment, completed];
  static const List<String> initial = [stored, inTransport, inTreatment];
}

/// Status possíveis de uma ocorrência.
abstract final class OccurrenceStatus {
  static const String pending = 'Pendente';
  static const String inAnalysis = 'Em análise';
  static const String resolved = 'Resolvida';

  static const List<String> all = [pending, inAnalysis, resolved];
  static const List<String> initial = [pending, inAnalysis];
}

abstract final class OccurrencePriority {
  static const String low = 'Baixa';
  static const String medium = 'Média';
  static const String high = 'Alta';

  static const List<String> all = [low, medium, high];
}

abstract final class OccurrenceTypes {
  static const List<String> all = [
    'Atraso na coleta',
    'Acondicionamento inadequado',
    'Identificação incorreta',
    'Documento pendente',
    'Divergência de quantidade',
    'Outro',
  ];
}

abstract final class LotUnits {
  static const List<String> all = ['kg', 'L', 'un.', 'm³'];
}

/// Etapas de movimentação e o status resultante de cada uma.
abstract final class MovementActions {
  static const List<String> all = [
    'Coleta interna confirmada',
    'Transferência para armazenamento',
    'Coleta externa confirmada',
    'Encaminhado para tratamento',
    'Destinação concluída',
    'Conferência de lote',
  ];

  static String resultingStatus(String action, String currentStatus) {
    switch (action) {
      case 'Coleta externa confirmada':
        return LotStatus.inTransport;
      case 'Encaminhado para tratamento':
        return LotStatus.inTreatment;
      case 'Destinação concluída':
        return LotStatus.completed;
      case 'Transferência para armazenamento':
        return LotStatus.stored;
      default:
        return currentStatus;
    }
  }
}
