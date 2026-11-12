import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../dialogs/occurrence_dialogs.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/layout.dart';
import '../../widgets/record_views.dart';
import '../../widgets/stat_card.dart';

/// Registro e acompanhamento de ocorrências.
class OccurrencesScreen extends StatefulWidget {
  const OccurrencesScreen({super.key});

  @override
  State<OccurrencesScreen> createState() => _OccurrencesScreenState();
}

class _OccurrencesScreenState extends State<OccurrencesScreen> {
  static const String _all = '';
  String _status = _all;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<EcoTrackController>();
    final items = data.occurrences
        .where((occurrence) => _status == _all || occurrence.status == _status)
        .toList();

    return PageContainer(
      children: [
        PageHeading(
          title: 'Ocorrências',
          subtitle: 'Registre desvios, pendências ou situações que precisam de acompanhamento.',
          actions: [
            AppButton(
              label: 'Registrar ocorrência',
              icon: Icons.add,
              onPressed: () => openOccurrenceForm(context),
            ),
          ],
        ),
        StatsGrid(cards: [
          StatCard(
            label: 'Total de ocorrências',
            value: data.occurrences.length,
            icon: Icons.flag_outlined,
            tone: AppTone.blue,
            foot: 'Registros no sistema',
          ),
          StatCard(
            label: 'Pendentes',
            value: data.countOccurrencesWithStatus(OccurrenceStatus.pending),
            icon: Icons.schedule,
            tone: AppTone.orange,
            foot: 'Aguardando análise',
          ),
          StatCard(
            label: 'Em análise',
            value: data.countOccurrencesWithStatus(OccurrenceStatus.inAnalysis),
            icon: Icons.manage_search,
            tone: AppTone.blue,
            foot: 'Em acompanhamento',
          ),
          StatCard(
            label: 'Resolvidas',
            value: data.countOccurrencesWithStatus(OccurrenceStatus.resolved),
            icon: Icons.check,
            tone: AppTone.green,
            foot: 'Tratadas pela equipe',
          ),
        ]),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelHeader(
                title: 'Registros de ocorrências',
                subtitle: 'Detalhes e status de cada registro.',
                stackOnMobile: true,
                trailing: SizedBox(
                  width: 180,
                  child: AppSelect<String>(
                    value: _all,
                    dense: true,
                    items: [
                      const AppSelectItem(_all, 'Todos os status'),
                      ...stringItems(OccurrenceStatus.all),
                    ],
                    onChanged: (value) => setState(() => _status = value ?? _all),
                  ),
                ),
              ),
              if (items.isEmpty)
                const EmptyState(message: 'Nenhuma ocorrência encontrada.')
              else
                for (final occurrence in items)
                  OccurrenceCard(
                    occurrence: occurrence,
                    onDetails: () => openOccurrenceDetails(context, occurrence.id),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
