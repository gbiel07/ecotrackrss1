import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../logic/app_page.dart';
import '../../../logic/auth_controller.dart';
import '../../../logic/navigation_controller.dart';
import '../ai/ai_center_screen.dart';
import '../dashboard/manager_dashboard_screen.dart';
import '../home/employee_home_screen.dart';
import '../lots/lots_screen.dart';
import '../lots/new_lot_screen.dart';
import '../movements/movements_screen.dart';
import '../occurrences/occurrences_screen.dart';
import '../scan/scan_screen.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// Estrutura autenticada: barra lateral fixa (ou gaveta no celular),
/// cabeçalho e conteúdo da página atual.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _pageFor(AppPage page) {
    switch (page) {
      case AppPage.home:
        return const EmployeeHomeScreen();
      case AppPage.dashboard:
        return const ManagerDashboardScreen();
      case AppPage.scan:
        return const ScanScreen();
      case AppPage.lots:
        return const LotsScreen();
      case AppPage.newLot:
        return const NewLotScreen();
      case AppPage.movements:
        return const MovementsScreen();
      case AppPage.occurrences:
        return const OccurrencesScreen();
      case AppPage.ai:
        return const AiCenterScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final navigation = context.watch<NavigationController>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final isMobile = Breakpoints.isMobile(context);
    final sidebarWidth = Breakpoints.isCompact(context) ? 220.0 : 252.0;

    final sidebar = AppSidebar(
      role: user.role,
      current: navigation.current,
      onSelect: (page) {
        _scaffoldKey.currentState?.closeDrawer();
        navigation.go(page);
      },
      onLogout: () {
        _scaffoldKey.currentState?.closeDrawer();
        auth.logout();
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              width: 260,
              backgroundColor: AppColors.sidebar,
              shape: const RoundedRectangleBorder(),
              child: sidebar,
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isMobile) SizedBox(width: sidebarWidth, child: sidebar),
          Expanded(
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  left: isMobile,
                  child: AppTopBar(
                    page: navigation.current,
                    user: user,
                    onMenuPressed: isMobile ? () => _scaffoldKey.currentState?.openDrawer() : null,
                  ),
                ),
                Expanded(
                  child: KeyedSubtree(
                    key: ValueKey(navigation.current),
                    child: _pageFor(navigation.current),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
