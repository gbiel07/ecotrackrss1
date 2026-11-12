import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/app_page.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../../logic/navigation_controller.dart';
import '../../dialogs/lot_dialogs.dart';
import '../../dialogs/occurrence_dialogs.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/decorations.dart';
import '../../widgets/layout.dart';
import '../../widgets/record_views.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';
import 'dashboard_charts.dart';

/// Dashboard do gestor: indicadores, gráficos, lotes recentes e ocorrências.
class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  List<MonthlyBar> _monthlyBars(EcoTrackController data) {
    final now = DateTime.now();
    final bars = <MonthlyBar>[];
    for (var offset = 5; offset >= 0; offset--) {
      final month = DateTime(now.year, now.month - offset, 1);
      bool sameMonth(DateTime? date) =>
          date != null && date.year == month.year && date.month == month.month;
      bars.add(MonthlyBar(
        label: Formatters.shortMonth(month),
        lots: data.lots.where((lot) => sameMonth(lot.createdAt)).length,
        movements: data.movements.where((movement) => sameMonth(movement.date)).length,
      ));
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<EcoTrackController>();
    final navigation = context.read<NavigationController>();
    final isCompact = Breakpoints.isCompact(context);
    final isMobile = Breakpoints.isMobile(context);
    final open = data.openOccurrences;
    final groupCounts = {
      for (final code in WasteGroups.codes)
        code: data.lots.where((lot) => lot.group == code).length,
    };
    final tablePadding =
        EdgeInsets.fromLTRB(isMobile ? 16 : 20, isMobile ? 17 : 20, isMobile ? 16 : 20, 0);

    final chartPanel = AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelHeader(
            title: 'Volume de lotes por mês',
            subtitle: 'Quantidade de cadastros nos últimos seis meses',
            trailing: StatusPill(label: 'Atualizado', tone: AppTone.green),
          ),
          MonthlyVolumeChart(bars: _monthlyBars(data)),
        ],
      ),
    );

    final groupsPanel = AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelHeader(
            title: 'Lotes por grupo',
            subtitle: 'Distribuição dos resíduos registrados',
          ),
          GroupDistribution(counts: groupCounts),
        ],
      ),
    );

    final recentLotsPanel = AppPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelHeader(
            title: 'Lotes recentes',
            subtitle: 'Acompanhe os registros mais novos.',
            padding: tablePadding,
            trailing: AppTextLink(
              label: 'Ver todos →',
              onPressed: () => navigation.go(AppPage.lots),
            ),
          ),
          LotsTable(
            lots: data.sortedLots.take(4).toList(),
            onView: (lot) => openLotDetails(context, lot.id),
          ),
        ],
      ),
    );

    final occurrencesPanel = AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelHeader(
            title: 'Ocorrências para acompanhar',
            subtitle: 'Registros que precisam de atenção.',
            trailing: AppTextLink(
              label: 'Ver todas →',
              onPressed: () => navigation.go(AppPage.occurrences),
            ),
          ),
          if (open.isEmpty)
            const EmptyState(message: 'Nenhuma ocorrência aberta.', icon: Icons.check_circle_outline)
          else
            for (var i = 0; i < open.length && i < 4; i++)
              InkWell(
                onTap: () => openOccurrenceDetails(context, open[i].id),
                child: ActivityItem(
                  title: '${open[i].type} · ${open[i].lotId}',
                  description: open[i].description,
                  caption: '${Formatters.dateTime(open[i].date)} · ${open[i].responsible}',
                  dotColor: open[i].priority == OccurrencePriority.high
                      ? const Color(0xFFD66C61)
                      : const Color(0xFFDCA04D),
                  showDivider: i < open.length - 1 && i < 3,
                ),
              ),
        ],
      ),
    );

    Widget twoColumns(Widget left, Widget right) {
      if (isCompact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, SizedBox(height: isMobile ? 12 : 18), right],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 14, child: left),
          const SizedBox(width: 18),
          Expanded(flex: 8, child: right),
        ],
      );
    }

    return PageContainer(
      children: [
        PageHeading(
          title: 'Dashboard',
          subtitle: 'Visão geral da rastreabilidade e do descarte de resíduos.',
          actions: [
            AppButton(
              label: 'Consultar lotes',
              variant: AppButtonVariant.outline,
              onPressed: () => navigation.go(AppPage.lots),
            ),
            AppButton(
              label: 'Cadastrar lote',
              icon: Icons.add,
              onPressed: () => navigation.go(AppPage.newLot),
            ),
          ],
        ),
        StatsGrid(cards: [
          StatCard(
            label: 'Total de lotes',
            value: data.lots.length,
            icon: Icons.inventory_2_outlined,
            tone: AppTone.green,
            foot: 'Lotes registrados',
          ),
          StatCard(
            label: 'Em andamento',
            value: data.countLotsWithStatus(const [LotStatus.inTransport, LotStatus.inTreatment]),
            icon: Icons.trending_up,
            tone: AppTone.blue,
            foot: 'Transporte ou tratamento',
          ),
          StatCard(
            label: 'Destinação concluída',
            value: data.countLotsWithStatus(const [LotStatus.completed]),
            icon: Icons.check,
            tone: AppTone.green,
            foot: 'Lotes finalizados',
          ),
          StatCard(
            label: 'Ocorrências abertas',
            value: open.length,
            icon: Icons.flag_outlined,
            tone: AppTone.red,
            foot: open.isEmpty ? 'Nenhuma pendência aberta' : 'Exigem acompanhamento',
          ),
        ]),
        twoColumns(chartPanel, groupsPanel),
        SizedBox(height: isMobile ? 12 : 20),
        twoColumns(recentLotsPanel, occurrencesPanel),
      ],
    );
  }
}
