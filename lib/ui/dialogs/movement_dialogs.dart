import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/waste_lot.dart';
import '../../logic/auth_controller.dart';
import '../../logic/ecotrack_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_toast.dart';
import '../widgets/detail_grid.dart';
import '../widgets/form_fields.dart';
import '../widgets/layout.dart';
import 'app_modal.dart';

/// Formulário "Confirmar movimentação" de um lote.
Future<void> openMovementForm(BuildContext context, WasteLot lot) async {
  final saved = await showAppModal<bool>(
    context: context,
    title: 'Confirmar movimentação',
    builder: (_) => _MovementForm(lot: lot),
  );
  if (saved == true && context.mounted) {
    AppToast.show(context, 'Movimentação confirmada e registrada.');
  }
}

/// Formulário "Atualizar status do lote" (perfil gestor).
Future<void> openLotStatusForm(BuildContext context, WasteLot lot) async {
  final saved = await showAppModal<bool>(
    context: context,
    title: 'Atualizar status do lote',
    builder: (_) => _LotStatusForm(lot: lot),
  );
  if (saved == true && context.mounted) {
    AppToast.show(context, 'Status do lote atualizado.');
  }
}

/// Detalhes somente leitura de uma movimentação.
Future<void> openMovementDetails(BuildContext context, String movementId) async {
  final movement = context.read<EcoTrackController>().movementById(movementId);
  if (movement == null) return;
  await showAppModal<void>(
    context: context,
    title: 'Movimentação ${movement.id}',
    builder: (_) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailGrid(entries: [
          DetailEntry('Código da movimentação', movement.id),
          DetailEntry('Lote relacionado', movement.lotId),
          DetailEntry('Etapa / ação', movement.action),
          DetailEntry('Origem', movement.from),
          DetailEntry('Destino', movement.to),
          DetailEntry('Responsável', movement.responsible),
          DetailEntry('Data e hora', Formatters.dateTime(movement.date)),
          DetailEntry('Observações', movement.notes.isEmpty ? 'Nenhuma' : movement.notes),
        ]),
        const FormActions(children: [CloseModalButton()]),
      ],
    ),
  );
}

class _MovementForm extends StatefulWidget {
  const _MovementForm({required this.lot});

  final WasteLot lot;

  @override
  State<_MovementForm> createState() => _MovementFormState();
}

class _MovementFormState extends State<_MovementForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _from = TextEditingController(text: widget.lot.sector);
  late final TextEditingController _to = TextEditingController(
    text: widget.lot.destination.isEmpty ? 'A definir' : widget.lot.destination,
  );
  final _notes = TextEditingController();
  String _action = MovementActions.all.first;
  bool _saving = false;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = context.read<AuthController>().user;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await context.read<EcoTrackController>().registerMovement(
            lot: widget.lot,
            action: _action,
            from: _from.text,
            to: _to.text,
            notes: _notes.text,
            user: user,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.show(context, 'Não foi possível salvar a movimentação. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = Breakpoints.isMobile(context) ? 1 : 2;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: 'Confirme a etapa atual do lote ',
              children: [
                TextSpan(
                  text: widget.lot.id,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '. A ação ficará registrada no histórico de rastreabilidade.'),
              ],
            ),
            style: AppTextStyles.small,
          ),
          const FieldLabel('Etapa / ação *'),
          AppSelect<String>(
            value: _action,
            items: stringItems(MovementActions.all),
            onChanged: (value) => setState(() => _action = value ?? _action),
          ),
          ResponsiveGrid(
            columns: columns,
            spacing: 16,
            runSpacing: 0,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Origem *'),
                  AppTextField(controller: _from, validator: _required('Informe a origem.')),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Destino *'),
                  AppTextField(controller: _to, validator: _required('Informe o destino.')),
                ],
              ),
            ],
          ),
          const FieldLabel('Observações'),
          AppTextField.multiline(controller: _notes, hint: 'Observações da movimentação...'),
          FormActions(children: [
            AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            ),
            AppButton(
              label: 'Confirmar movimentação',
              isLoading: _saving,
              loadingLabel: 'Salvando...',
              onPressed: _submit,
            ),
          ]),
        ],
      ),
    );
  }
}

class _LotStatusForm extends StatefulWidget {
  const _LotStatusForm({required this.lot});

  final WasteLot lot;

  @override
  State<_LotStatusForm> createState() => _LotStatusFormState();
}

class _LotStatusFormState extends State<_LotStatusForm> {
  late String _status =
      LotStatus.all.contains(widget.lot.status) ? widget.lot.status : LotStatus.all.first;
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<AuthController>().user;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await context.read<EcoTrackController>().updateLotStatus(
            lot: widget.lot,
            newStatus: _status,
            notes: _notes.text,
            user: user,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.show(context, 'Não foi possível atualizar o status. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            text: 'Atualize o status operacional de ',
            children: [
              TextSpan(text: widget.lot.id, style: const TextStyle(fontWeight: FontWeight.w700)),
              const TextSpan(text: '. A mudança será registrada no histórico.'),
            ],
          ),
          style: AppTextStyles.small,
        ),
        const FieldLabel('Novo status'),
        AppSelect<String>(
          value: _status,
          items: stringItems(LotStatus.all),
          onChanged: (value) => setState(() => _status = value ?? _status),
        ),
        const FieldLabel('Observação da atualização'),
        AppTextField.multiline(controller: _notes, hint: 'Motivo ou detalhe da atualização...'),
        FormActions(children: [
          AppButton(
            label: 'Cancelar',
            variant: AppButtonVariant.outline,
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: 'Atualizar status',
            isLoading: _saving,
            loadingLabel: 'Salvando...',
            onPressed: _submit,
          ),
        ]),
      ],
    );
  }
}

FormFieldValidator<String> _required(String message) {
  return (value) => (value == null || value.trim().isEmpty) ? message : null;
}
