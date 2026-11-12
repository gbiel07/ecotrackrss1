import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/app_user.dart';
import '../../../logic/app_page.dart';

/// Cabeçalho com trilha de navegação, data e usuário (.topbar).
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.page,
    required this.user,
    this.onMenuPressed,
  });

  final AppPage page;
  final AppUser user;

  /// Exibido apenas no celular, abre a gaveta com o menu.
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final hideMeta = Breakpoints.isMedium(context);
    final horizontal = isMobile ? 17.0 : (Breakpoints.isCompact(context) ? 24.0 : 35.0);

    return Container(
      height: isMobile ? 74 : 84,
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      decoration: const BoxDecoration(
        color: Color(0xEBFFFFFF),
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          if (onMenuPressed != null) ...[
            IconButton(
              onPressed: onMenuPressed,
              tooltip: 'Abrir menu',
              icon: const Icon(Icons.menu, color: AppColors.ink),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'EcoTrack RSS',
                    children: [
                      const TextSpan(
                        text: '  /  ',
                        style: TextStyle(color: Color(0xFFC1CBC7)),
                      ),
                      TextSpan(
                        text: page.title,
                        style: const TextStyle(
                          color: Color(0xFF344B44),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8B9A95)),
                ),
                const SizedBox(height: 5),
                Text(
                  page.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF87958F)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          if (!hideMeta) ...[
            Text(
              Formatters.today(DateTime.now()),
              style: const TextStyle(fontSize: 11, color: Color(0xFF7A8A84)),
            ),
            const SizedBox(width: 20),
          ],
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFD8EEE4), shape: BoxShape.circle),
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Color(0xFF17634D),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          if (!hideMeta) ...[
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  user.role.description,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF84948E)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
