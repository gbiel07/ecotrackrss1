import 'package:flutter/material.dart';

import '../../../data/models/app_user.dart';
import '../../../logic/app_page.dart';

/// Item do menu lateral.
class MenuItem {
  const MenuItem(this.page, this.label, this.icon);

  final AppPage page;
  final String label;
  final IconData icon;
}

/// Menu de cada perfil (mesma ordem e rótulos da versão web).
abstract final class AppMenu {
  static String sectionOf(UserRole role) =>
      role == UserRole.manager ? 'GESTÃO' : 'OPERAÇÃO';

  static List<MenuItem> itemsFor(UserRole role) {
    switch (role) {
      case UserRole.employee:
        return const [
          MenuItem(AppPage.home, 'Tela inicial', Icons.home_outlined),
          MenuItem(AppPage.scan, 'Escanear QR Code', Icons.qr_code_scanner),
          MenuItem(AppPage.lots, 'Consultar lotes', Icons.inventory_2_outlined),
          MenuItem(AppPage.movements, 'Movimentações recentes', Icons.swap_horiz),
          MenuItem(AppPage.occurrences, 'Ocorrências', Icons.flag_outlined),
          MenuItem(AppPage.ai, 'Assistente de IA', Icons.auto_awesome_outlined),
        ];
      case UserRole.manager:
        return const [
          MenuItem(AppPage.dashboard, 'Dashboard', Icons.dashboard_outlined),
          MenuItem(AppPage.newLot, 'Cadastrar lote', Icons.add_box_outlined),
          MenuItem(AppPage.lots, 'Consultar lotes', Icons.inventory_2_outlined),
          MenuItem(AppPage.movements, 'Histórico de movimentações', Icons.swap_horiz),
          MenuItem(AppPage.occurrences, 'Ocorrências', Icons.flag_outlined),
          MenuItem(AppPage.ai, 'Central de IA', Icons.auto_awesome_outlined),
        ];
    }
  }
}
