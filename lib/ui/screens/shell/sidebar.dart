import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_user.dart';
import '../../../logic/app_page.dart';
import '../../widgets/decorations.dart';
import 'app_menu.dart';

/// Barra lateral verde-escura com marca, menu, ajuda e botão de sair.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.role,
    required this.current,
    required this.onSelect,
    required this.onLogout,
  });

  final UserRole role;
  final AppPage current;
  final ValueChanged<AppPage> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sidebar,
      child: SafeArea(
        right: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 25, 15, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 35),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BrandLogo(textColor: AppColors.white, fontSize: 19),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(13, 0, 13, 13),
                      child: Text(
                        'ESPAÇO DE TRABALHO',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sidebarLabel,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(13, 6, 13, 5),
                      child: Text(
                        AppMenu.sectionOf(role),
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: Color(0xFF7FA79A),
                        ),
                      ),
                    ),
                    for (final item in AppMenu.itemsFor(role))
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: _SidebarButton(
                          icon: item.icon,
                          label: item.label,
                          active: item.page == current,
                          onTap: () => onSelect(item.page),
                        ),
                      ),
                    const Spacer(),
                    const _SupportCard(),
                    _SidebarButton(
                      icon: Icons.logout,
                      label: 'Sair do sistema',
                      active: false,
                      onTap: onLogout,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.white : AppColors.sidebarText;
    return Material(
      color: active ? AppColors.sidebarActive : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.sidebarActive,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(3, 20, 3, 20),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.sidebarCard,
        border: Border.all(color: const Color(0x14FFFFFF)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFF2E6B58), shape: BoxShape.circle),
            child: const Text(
              '?',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precisa de ajuda?',
                  style: TextStyle(fontSize: 11, color: AppColors.white, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 5),
                Text(
                  'Consulte o administrador do sistema.',
                  style: TextStyle(fontSize: 10, height: 1.5, color: Color(0xFFA9C6BB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
