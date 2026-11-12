import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/occurrence.dart';
import '../../logic/auth_controller.dart';
import '../../logic/ecotrack_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_toast.dart';
import '../widgets/detail_grid.dart';
import '../widgets/form_fields.dart';
import '../widgets/layout.dart';
import 'app_modal.dart';

/// Formulário "Registrar ocorrência". [lotId] pré-seleciona o lote.
Future<void> openOccurrenceForm(BuildContext context, {String? lotId}) async {
  final saved = await showAppModal<bool>(
    context: context,
    title: 'Registrar ocorrência',
    builder: (_) => _OccurrenceForm(initialLotId: lotId),
  );
  if (saved == true && context.mounted) {
    AppToast.show(context, 'Ocorrência registrada com sucesso.');
  }
}

/// Detalhes da ocorrência; o gestor pode atualizar o status.
Future<void> openOccurrenceDetails(BuildContext context, String occurrenceId) async {
  final occurrence = context.read<EcoTrackController>().occurrenceById(occurrenceId);
  if (occurrence == null) return;
  final saved = await showAppModal<bool>(
    context: context,
    title: 'Ocorrência ${occurrence.id}',
    builder: (_) => _OccurrenceDetails(occurrence: occurrence),
  );
  if (saved == true && context.mounted) {
    AppToast.show(context, 'Status da ocorrência atualizado.');
  }
}

class _OccurrenceForm extends StatefulWidget {
  const _OccurrenceForm({this.initialLotId});

  final String? initialLotId;

  @override
  State<_OccurrenceForm> createState() => _OccurrenceFormState();
}

class _OccurrenceFormState extends State<_OccurrenceForm> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  String? _type;
  String? _lotId;
  String _priority = OccurrencePriority.medium;
  String _status = OccurrenceStatus.pending;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLotId;
    if (initial != null && context.read<EcoTrackController>().lotById(initial) != null) {
      _lotId = initial;
    }
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = context.read<AuthController>().user;
    final type = _type;
    final lotId = _lotId;
    if (user == null || type == null || lotId == null) return;
    setState(() => _saving = true);
    try {
      await context.read<EcoTrackController>().createOccurrence(
            lotId: lotId,
            type: type,
            description: _description.text,
            priority: _priority,
            status: _status,
            user: user,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.show(context, 'Não foi possível salvar a ocorrência. Tente novamente.');
    }
  }

  Widget _field(String label, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [FieldLabel(label), input],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lots = context.read<EcoTrackController>().lots;
    final columns = Breakpoints.isMobile(context) ? 1 : 2;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveGrid(
            columns: columns,
            spacing: 16,
            runSpacing: 0,
            children: [
              _field(
                'Tipo de ocorrência *',
                AppSelect<String>(
                  value: _type,
                  hint: 'Selecione',
                  items: stringItems(OccurrenceTypes.all),
                  validator: (value) => value == null ? 'Selecione o tipo.' : null,
                  onChanged: (value) => setState(() => _type = value),
                ),
              ),
              _field(
                'Lote relacionado *',
                AppSelect<String>(
                  value: _lotId,
                  hint: lots.isEmpty ? 'Nenhum lote cadastrado' : 'Selecione o lote',
                  items: [
                    for (final lot in lots) AppSelectItem(lot.id, '${lot.id} — ${lot.description}'),
                  ],
                  validator: (value) => value == null ? 'Selecione o lote.' : null,
                  onChanged: (value) => setState(() => _lotId = value),
                ),
              ),
              _field(
                'Prioridade',
                AppSelect<String>(
                  value: _priority,
                  items: stringItems(OccurrencePriority.all),
                  onChanged: (value) => setState(() => _priority = value ?? _priority),
                ),
              ),
              _field(
                'Status inicial',
                AppSelect<String>(
                  value: _status,
                  items: stringItems(OccurrenceStatus.initial),
                  onChanged: (value) => setState(() => _status = value ?? _status),
                ),
              ),
            ],
          ),
          const FieldLabel('Descrição da ocorrência *'),
          AppTextField.multiline(
            controller: _description,
            hint: 'Descreva o que aconteceu e as informações relevantes...',
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Descreva a ocorrência.' : null,
          ),
          FormActions(children: [
            AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            ),
            AppButton(
              label: 'Salvar ocorrência',
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

class _OccurrenceDetails extends StatefulWidget {
  const _OccurrenceDetails({required this.occurrence});

  final Occurrence occurrence;

  @override
  State<_OccurrenceDetails> createState() => _OccurrenceDetailsState();
}

class _OccurrenceDetailsState extends State<_OccurrenceDetails> {
  late String _status = widget.occurrence.status;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context
          .read<EcoTrackController>()
          .updateOccurrenceStatus(widget.occurrence.id, _status);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.show(context, 'Não foi possível atualizar a ocorrência. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final occurrence = widget.occurrence;
    final isManager = context.read<AuthController>().user?.isManager ?? false;
    final canEdit = isManager && occurrence.isOpen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailGrid(entries: [
          DetailEntry('Tipo', occurrence.type),
          DetailEntry('Lote', occurrence.lotId),
          DetailEntry('Prioridade', occurrence.priority),
          DetailEntry('Status', occurrence.status),
          DetailEntry('Responsável', occurrence.responsible),
          DetailEntry('Data', Formatters.dateTime(occurrence.date)),
        ]),
        const SizedBox(height: 13),
        DetailItem(label: 'Descrição', value: occurrence.description),
        if (canEdit) ...[
          const SizedBox(height: 2),
          const FieldLabel('Atualizar status'),
          AppSelect<String>(
            value: OccurrenceStatus.all.contains(_status) ? _status : null,
            items: stringItems(OccurrenceStatus.all),
            onChanged: (value) => setState(() => _status = value ?? _status),
          ),
          FormActions(children: [
            AppButton(
              label: 'Fechar',
              variant: AppButtonVariant.outline,
              onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            ),
            AppButton(
              label: 'Salvar status',
              isLoading: _saving,
              loadingLabel: 'Salvando...',
              onPressed: _save,
            ),
          ]),
        ] else
          const FormActions(children: [CloseModalButton()]),
      ],
    );
  }
}
