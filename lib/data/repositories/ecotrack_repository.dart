import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/ecotrack_data.dart';
import '../seed/demo_data.dart';

/// Falha ao ler ou gravar os registros locais.
class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Camada de dados: persiste os registros no dispositivo com SharedPreferences
/// (equivalente ao localStorage da versão web).
class EcoTrackRepository {
  EcoTrackRepository({SharedPreferences? preferences}) : _preferences = preferences;

  SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  /// Carrega os registros. No primeiro acesso grava os dados de demonstração.
  Future<EcoTrackData> load() async {
    final prefs = await _prefs();
    final raw = prefs.getString(AppConstants.storageKey);
    if (raw == null || raw.isEmpty) {
      final seed = DemoData.build(DateTime.now());
      await save(seed);
      return seed;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Estrutura inesperada.');
      }
      return EcoTrackData.fromJson(decoded);
    } on FormatException {
      throw const StorageException('Os registros salvos estão em um formato inválido.');
    }
  }

  Future<void> save(EcoTrackData data) async {
    final prefs = await _prefs();
    final saved = await prefs.setString(AppConstants.storageKey, jsonEncode(data.toJson()));
    if (!saved) {
      throw const StorageException('Não foi possível gravar os registros no dispositivo.');
    }
  }

  /// Substitui os registros atuais pelos dados de demonstração.
  Future<EcoTrackData> resetToDemo() async {
    final seed = DemoData.build(DateTime.now());
    await save(seed);
    return seed;
  }
}
