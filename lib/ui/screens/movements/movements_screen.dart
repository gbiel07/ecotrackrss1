import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/breakpoints.dart';
import '../../../logic/app_page.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../../logic/navigation_controller.dart';
import '../../dialogs/movement_dialogs.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/layout.dart';
import '../../widgets/record_views.dart';

/// Histórico de movimentações com busca.
class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<EcoTrackController>();
    final isMobile = Breakpoints.isMobile(context);
    final side = isMobile ? 16.0 : 20.0;
    final query = _query.trim().toLowerCase();
    final movements = data.sortedMovements
        .where((m) =>
            query.isEmpty ||
            [m.id, m.lotId, m.action, m.responsible]
                .any((value) => value.toLowerCase().contains(query)))
        .toList();

    return PageContainer(
      children: [
        PageHeading(
          title: 'Histórico de movimentações',
          subtitle: 'Rastreabilidade de cada etapa registrada no sistema.',
          actions: [
            AppButton(
              label: 'Identificar lote',
              icon: Icons.qr_code_scanner,
              variant: AppButtonVariant.outline,
              onPressed: () => context.read<NavigationController>().go(AppPage.scan),
            ),
          ],
        ),
        AppPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelHeader(
                title: 'Movimentações registradas',
                subtitle: '${data.movements.length} movimentação(ões) no histórico',
                padding: EdgeInsets.fromLTRB(side, isMobile ? 17 : 20, side, 0),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: isMobile ? double.infinity : 280,
                    child: AppTextField(
                      hint: 'Buscar por lote, responsável ou ação...',
                      dense: true,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                ),
              ),
              MovementsTable(
                movements: movements,
                onDetails: (movement) => openMovementDetails(context, movement.id),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
