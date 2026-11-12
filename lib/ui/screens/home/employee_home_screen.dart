import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../logic/app_page.dart';
import '../../../logic/auth_controller.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../../logic/navigation_controller.dart';
import '../../dialogs/movement_dialogs.dart';
import '../../dialogs/occurrence_dialogs.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/decorations.dart';
import '../../widgets/layout.dart';
import '../../widgets/record_views.dart';
import '../../widgets/stat_card.dart';

/// Tela inicial do funcionário: indicadores, atalhos e movimentações recentes.
class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<EcoTrackController>();
    final user = context.watch<AuthController>().user;
    final navigation = context.read<NavigationController>();
    if (user == null) return const SizedBox.shrink();

    final mine = data.sortedMovements.where((m) => m.responsible == user.name).take(4).toList();
    final recent = mine.isNotEmpty ? mine : data.sortedMovements.take(4).toList();
    final isMobile = Breakpoints.isMobile(context);

    return PageContainer(
      children: [
        PageHeading(
          title: 'Olá, ${user.firstName} 👋',
          subtitle: 'Veja o que está acontecendo com os resíduos hoje.',
          actions: [
            AppButton(
              label: 'Escanear lote',
              icon: Icons.qr_code_scanner,
              onPressed: () => navigation.go(AppPage.scan),
            ),
          ],
        ),
        StatsGrid(cards: [
          StatCard(
            label: 'Lotes cadastrados',
            value: data.lots.length,
            icon: Icons.inventory_2_outlined,
            tone: AppTone.green,
            foot: 'Registros no sistema',
          ),
          StatCard(
            label: 'Aguardando movimentação',
            value: data.countLotsWithStatus(const [LotStatus.stored]),
            icon: Icons.schedule,
            tone: AppTone.orange,
            foot: 'Precisam de acompanhamento',
          ),
          StatCard(
            label: 'Movimentações registradas',
            value: data.movements.length,
            icon: Icons.swap_horiz,
            tone: AppTone.blue,
            foot: 'Histórico atualizado',
          ),
          StatCard(
            label: 'Ocorrências abertas',
            value: data.openOccurrences.length,
            icon: Icons.flag_outlined,
            tone: AppTone.red,
            foot: 'Pendências para acompanhar',
          ),
        ]),
        AppPanel(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PanelHeader(
                title: 'Acesso rápido',
                subtitle: 'Escolha a atividade que deseja realizar.',
              ),
              ResponsiveGrid(
                columns: isMobile ? 1 : 3,
                spacing: 12,
                runSpacing: 12,
                equalHeight: true,
                children: [
                  QuickActionCard(
                    icon: Icons.qr_code_scanner,
                    title: 'Escanear QR Code',
                    subtitle: 'Identifique um lote rapidamente',
                    onTap: () => navigation.go(AppPage.scan),
                  ),
                  QuickActionCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Consultar lotes',
                    subtitle: 'Visualize dados e status',
                    onTap: () => navigation.go(AppPage.lots),
                  ),
                  QuickActionCard(
                    icon: Icons.flag_outlined,
                    title: 'Registrar ocorrência',
                    subtitle: 'Informe um problema identificado',
                    onTap: () => openOccurrenceForm(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelHeader(
                title: 'Movimentações recentes',
                subtitle: 'Últimas atividades registradas por você.',
                padding: EdgeInsets.fromLTRB(isMobile ? 16 : 20, isMobile ? 17 : 20, isMobile ? 16 : 20, 0),
                trailing: AppTextLink(
                  label: 'Ver histórico →',
                  onPressed: () => navigation.go(AppPage.movements),
                ),
              ),
              MovementsTable(
                movements: recent,
                onDetails: (movement) => openMovementDetails(context, movement.id),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
