import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../data/models/waste_lot.dart';
import '../../../logic/app_page.dart';
import '../../../logic/auth_controller.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../../logic/navigation_controller.dart';
import '../../dialogs/lot_dialogs.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/layout.dart';
import '../../widgets/record_views.dart';

/// Consulta de lotes com busca e filtros por status e grupo.
class LotsScreen extends StatefulWidget {
  const LotsScreen({super.key});

  @override
  State<LotsScreen> createState() => _LotsScreenState();
}

class _LotsScreenState extends State<LotsScreen> {
  /// Valor da opção "Todos" nos filtros.
  static const String _all = '';

  static String? _orNull(String? value) => (value == null || value == _all) ? null : value;

  String _query = '';
  String? _status;
  String? _group;

  List<WasteLot> _filter(List<WasteLot> lots) {
    final query = _query.trim().toLowerCase();
    return lots.where((lot) {
      final matchesQuery = query.isEmpty ||
          [lot.id, lot.description, lot.sector, lot.responsible]
              .any((value) => value.toLowerCase().contains(query));
      final matchesStatus = _status == null || lot.status == _status;
      final matchesGroup = _group == null || lot.group == _group;
      return matchesQuery && matchesStatus && matchesGroup;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<EcoTrackController>();
    final isManager = context.watch<AuthController>().user?.isManager ?? false;
    final isMobile = Breakpoints.isMobile(context);
    final lots = _filter(data.lots);
    final side = isMobile ? 16.0 : 20.0;

    return PageContainer(
      children: [
        PageHeading(
          title: 'Consultar lotes',
          subtitle: 'Localize um lote e consulte suas informações e rastreabilidade.',
          actions: [
            if (isManager)
              AppButton(
                label: 'Cadastrar lote',
                icon: Icons.add,
                onPressed: () => context.read<NavigationController>().go(AppPage.newLot),
              ),
          ],
        ),
        AppPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelHeader(
                title: 'Todos os lotes',
                subtitle: '${lots.length} registro(s) encontrado(s)',
                padding: EdgeInsets.fromLTRB(side, isMobile ? 17 : 20, side, 0),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 15),
                child: Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: isMobile ? double.infinity : 280,
                      child: AppTextField(
                        hint: 'Buscar por código, descrição ou setor...',
                        dense: true,
                        prefixIcon: const Icon(Icons.search, size: 18),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                    SizedBox(
                      width: isMobile ? double.infinity : 190,
                      child: AppSelect<String>(
                        value: _all,
                        dense: true,
                        items: [
                          const AppSelectItem(_all, 'Todos os status'),
                          ...stringItems(LotStatus.all),
                        ],
                        onChanged: (value) => setState(() => _status = _orNull(value)),
                      ),
                    ),
                    SizedBox(
                      width: isMobile ? double.infinity : 230,
                      child: AppSelect<String>(
                        value: _all,
                        dense: true,
                        items: [
                          const AppSelectItem(_all, 'Todos os grupos'),
                          for (final code in WasteGroups.codes)
                            AppSelectItem(code, WasteGroups.nameOf(code)),
                        ],
                        onChanged: (value) => setState(() => _group = _orNull(value)),
                      ),
                    ),
                  ],
                ),
              ),
              LotsTable(lots: lots, onView: (lot) => openLotDetails(context, lot.id)),
            ],
          ),
        ),
      ],
    );
  }
}
