import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import 'app_page.dart';

/// Página atual exibida dentro do shell autenticado.
class NavigationController extends ChangeNotifier {
  AppPage _current = AppPage.home;

  AppPage get current => _current;

  void go(AppPage page) {
    if (_current == page) return;
    _current = page;
    notifyListeners();
  }

  /// Página inicial de acordo com o perfil, como na versão web.
  void resetFor(UserRole role) {
    _current = role == UserRole.manager ? AppPage.dashboard : AppPage.home;
    notifyListeners();
  }
}
