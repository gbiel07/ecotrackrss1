import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/services/auth_service.dart';

/// Estado da sessão do usuário.
class AuthController extends ChangeNotifier {
  AuthController(this._service);

  final AuthService _service;
  AppUser? _user;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;

  /// Retorna uma mensagem de erro ou `null` quando o login é válido.
  String? login({
    required String username,
    required String password,
    required UserRole role,
  }) {
    final user = _service.authenticate(username: username, password: password, role: role);
    if (user == null) return 'Usuário, senha ou perfil inválido.';
    _user = user;
    notifyListeners();
    return null;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
