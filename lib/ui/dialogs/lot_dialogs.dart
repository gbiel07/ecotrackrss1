import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/waste_lot.dart';
import '../../logic/auth_controller.dart';
import '../../logic/ecotrack_controller.dart';
import '../../services/pdf_export_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_panel.dart';
import '../widgets/app_toast.dart';
import '../widgets/decorations.dart';
import '../widgets/detail_grid.dart';
import '../widgets/status_pill.dart';
import '../widgets/timeline.dart';
import 'app_modal.dart';
import 'movement_dialogs.dart';
import 'occurrence_dialogs.dart';

enum _LotAction { registerOccurrence, confirmMovement, updateStatus }

/// Abre os detalhes do lote e encadeia a ação escolhida (movimentação,
/// ocorrência ou atualização de status), como o modal da versão web.
Future<void> openLotDetails(BuildContext context, String lotId) async {
  final lot = context.read<EcoTrackController>().lotById(lotId);
  if (lot == null) {
    AppToast.show(context, 'Lote não encontrado.');
    return;
  }
  final action = await showAppModal<_LotAction>(
    context: context,
    title: 'Lote ${lot.id}',
    builder: (_) => _LotDetails(lotId: lot.id),
  );
  if (action == null || !context.mounted) return;

  final current = context.read<EcoTrackController>().lotById(lotId) ?? lot;
  switch (action) {
    case _LotAction.registerOccurrence:
      await openOccurrenceForm(context, lotId: current.id);
    case _LotAction.confirmMovement:
      await openMovementForm(context, current);
    case _LotAction.updateStatus:
      await openLotStatusForm(context, current);
  }
}

/// Imprime (ou salva em PDF) a etiqueta com o QR Code do lote.
Future<void> printLotQr(BuildContext context, WasteLot lot) async {
  try {
    await const PdfExportService().printLotLabel(lot);
  } catch (_) {
    if (context.mounted) AppToast.show(context, 'Não foi possível gerar a etiqueta do QR Code.');
  }
}

class _LotDetails extends StatelessWidget {
  const _LotDetails({required this.lotId});

  final String lotId;

  @override
  Widget build(BuildContext context) {
    final lot = context.watch<EcoTrackController>().lotById(lotId);
    final isManager = context.read<AuthController>().user?.isManager ?? false;
    if (lot == null) {
      return const Text('Lote não encontrado.');
    }
    final history = context.read<EcoTrackController>().movementsOfLot(lot.id);
    final isMobile = Breakpoints.isMobile(context);

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lot.id,
                style: const TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w800,
                  fontSize: 23,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusPill.status(lot.status),
                  StatusPill(label: 'Grupo ${lot.group}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppButton(
          label: 'Imprimir QR',
          icon: Icons.print_outlined,
          variant: AppButtonVariant.outline,
          onPressed: () => printLotQr(context, lot),
        ),
      ],
    );

    final historyView = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PanelHeader(
          title: 'Histórico do lote',
          subtitle: 'Movimentações associadas a este registro.',
        ),
        if (history.isEmpty)
          const Text('Nenhuma movimentação registrada.', style: AppTextStyles.small)
        else
          Timeline(entries: [
            for (final movement in history)
              TimelineEntry(
                title: movement.action,
                description: '${movement.from} → ${movement.to}',
                caption: '${Formatters.dateTime(movement.date)} · ${movement.responsible}',
              ),
          ]),
      ],
    );

    final qrBox = DashedBorderBox(
      child: Column(
        children: [
          const Text('QR Code do lote', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          QrImageView(
            data: lot.id,
            size: 112,
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.white,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.qr),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.qr,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${lot.id}\nIdentificador único do lote',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF7D8E86)),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 18),
        DetailGrid(entries: [
          DetailEntry('Descrição', lot.description),
          DetailEntry('Grupo do resíduo', WasteGroups.nameOf(lot.group)),
          DetailEntry('Quantidade', '${Formatters.quantity(lot.quantity)} ${lot.unit}'),
          DetailEntry('Setor de origem', lot.sector),
          DetailEntry('Responsável pelo cadastro', lot.responsible),
          DetailEntry('Data de cadastro', Formatters.dateTime(lot.createdAt)),
          DetailEntry('Destino previsto', lot.destination.isEmpty ? 'A definir' : lot.destination),
          DetailEntry('Observações', lot.notes.isEmpty ? 'Nenhuma' : lot.notes),
        ]),
        const SizedBox(height: 18),
        if (isMobile) ...[
          historyView,
          const SizedBox(height: 18),
          qrBox,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: historyView),
              const SizedBox(width: 18),
              SizedBox(width: 190, child: qrBox),
            ],
          ),
        FormActions(children: [
          AppButton(
            label: 'Registrar ocorrência',
            icon: Icons.flag_outlined,
            variant: AppButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(_LotAction.registerOccurrence),
          ),
          if (isManager)
            AppButton(
              label: 'Atualizar status',
              onPressed: () => Navigator.of(context).pop(_LotAction.updateStatus),
            )
          else
            AppButton(
              label: 'Confirmar movimentação →',
              onPressed: () => Navigator.of(context).pop(_LotAction.confirmMovement),
            ),
        ]),
      ],
    );
  }
}
