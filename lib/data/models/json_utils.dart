/// Leitura tolerante de JSON, para aceitar dados antigos ou incompletos.
abstract final class JsonUtils {
  static String string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  static double number(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    return 0;
  }

  static int integer(Map<String, dynamic> json, String key, int fallback) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? date(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  static List<Map<String, dynamic>> list(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  /// Datas são gravadas em UTC (ISO 8601), como o toISOString do JavaScript.
  static String encodeDate(DateTime value) => value.toUtc().toIso8601String();
}
