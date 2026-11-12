import '../models/app_user.dart';

class _DemoAccount {
  const _DemoAccount({required this.password, required this.name, required this.role});

  final String password;
  final String name;
  final UserRole role;
}

/// Autenticação de demonstração (protótipo acadêmico, sem servidor).
class AuthService {
  const AuthService();

  static const Map<String, _DemoAccount> _accounts = {
    'funcionario': _DemoAccount(password: '1234', name: 'Marcos Oliveira', role: UserRole.employee),
    'gestor': _DemoAccount(password: '1234', name: 'Ana Martins', role: UserRole.manager),
  };

  /// Retorna o usuário quando usuário, senha e perfil conferem.
  AppUser? authenticate({
    required String username,
    required String password,
    required UserRole role,
  }) {
    final key = username.trim().toLowerCase();
    final account = _accounts[key];
    if (account == null || account.password != password || account.role != role) {
      return null;
    }
    return AppUser(username: key, name: account.name, role: account.role);
  }
}
