import 'package:intl/intl.dart';

/// Formatação de datas e números em pt-BR, espelhando o toLocaleDateString da web.
abstract final class Formatters {
  static const String _locale = 'pt_BR';

  /// Ex.: "12 de nov. de 2026".
  static String date(DateTime? value) {
    if (value == null) return '—';
    return DateFormat("dd 'de' MMM 'de' y", _locale).format(value);
  }

  /// Ex.: "12 de nov. de 2026, 14:30".
  static String dateTime(DateTime? value) {
    if (value == null) return '—';
    return DateFormat("dd 'de' MMM 'de' y, HH:mm", _locale).format(value);
  }

  /// Ex.: "12/11/2026, 14:30:05" (equivalente a toLocaleString).
  static String dateTimeFull(DateTime? value) {
    if (value == null) return 'sem data';
    return DateFormat('dd/MM/yyyy, HH:mm:ss', _locale).format(value);
  }

  /// Ex.: "qui., 12 de nov." para o cabeçalho.
  static String today(DateTime value) {
    return DateFormat("EEE, dd 'de' MMM", _locale).format(value);
  }

  /// Ex.: "nov" (sem ponto) para os rótulos do gráfico.
  static String shortMonth(DateTime value) {
    return DateFormat('MMM', _locale).format(value).replaceAll('.', '');
  }

  /// Data no formato do nome de arquivo (2026-11-12).
  static String fileDate(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value);
  }

  /// Quantidade sem casas desnecessárias: 7 → "7", 2.5 → "2,5".
  static String quantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return NumberFormat('#,##0.##', _locale).format(value);
  }
}
