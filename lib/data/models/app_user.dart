/// Perfis de acesso do sistema.
enum UserRole {
  employee('Funcionário', 'Funcionário operacional'),
  manager('Gestor responsável', 'Gestor responsável');

  const UserRole(this.label, this.description);

  /// Texto exibido no seletor de perfil do login.
  final String label;

  /// Texto exibido abaixo do nome no cabeçalho.
  final String description;
}

/// Usuário autenticado na sessão.
class AppUser {
  const AppUser({
    required this.username,
    required this.name,
    required this.role,
  });

  final String username;
  final String name;
  final UserRole role;

  bool get isManager => role == UserRole.manager;

  String get firstName => name.split(' ').first;

  /// Iniciais para o avatar (ex.: "Ana Martins" → "AM").
  String get initials {
    final parts = name.split(' ').where((part) => part.isNotEmpty).take(2);
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}
