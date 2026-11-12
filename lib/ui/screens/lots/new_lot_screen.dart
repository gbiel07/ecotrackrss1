import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../logic/app_page.dart';
import '../../../logic/auth_controller.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../../logic/navigation_controller.dart';
import '../../dialogs/app_modal.dart';
import '../../dialogs/lot_dialogs.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/layout.dart';

/// Cadastro de lote (perfil gestor). Ao salvar, abre o lote com o QR Code.
class NewLotScreen extends StatefulWidget {
  const NewLotScreen({super.key});

  @override
  State<NewLotScreen> createState() => _NewLotScreenState();
}

class _NewLotScreenState extends State<NewLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _sector = TextEditingController();
  final _quantity = TextEditingController();
  final _destination = TextEditingController();
  final _notes = TextEditingController();
  String? _group;
  String _unit = LotUnits.all.first;
  String _status = LotStatus.initial.first;
  bool _saving = false;

  /// Recria os campos de seleção após limpar o formulário.
  int _formVersion = 0;

  @override
  void dispose() {
    _description.dispose();
    _sector.dispose();
    _quantity.dispose();
    _destination.dispose();
    _notes.dispose();
    super.dispose();
  }

  static double? _parseQuantity(String? text) {
    if (text == null) return null;
    return double.tryParse(text.trim().replaceAll(',', '.'));
  }

  void _resetForm() {
    _description.clear();
    _sector.clear();
    _quantity.clear();
    _destination.clear();
    _notes.clear();
    setState(() {
      _group = null;
      _unit = LotUnits.all.first;
      _status = LotStatus.initial.first;
      _formVersion++;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = context.read<AuthController>().user;
    final group = _group;
    final quantity = _parseQuantity(_quantity.text);
    if (user == null || group == null || quantity == null) return;

    setState(() => _saving = true);
    try {
      final lot = await context.read<EcoTrackController>().createLot(
            description: _description.text,
            group: group,
            sector: _sector.text,
            quantity: quantity,
            unit: _unit,
            status: _status,
            destination: _destination.text,
            notes: _notes.text,
            user: user,
          );
      if (!mounted) return;
      setState(() => _saving = false);
      _resetForm();
      AppToast.show(context, 'Lote cadastrado com sucesso.');
      await openLotDetails(context, lot.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.show(context, 'Não foi possível cadastrar o lote. Tente novamente.');
    }
  }

  Widget _field(String label, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [FieldLabel(label), input],
    );
  }

  String? _required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return PageContainer(
      children: [
        const PageHeading(
          title: 'Cadastrar lote',
          subtitle: 'Cadastre e identifique um novo lote de resíduos de serviços de saúde.',
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: AppPanel(
              padding: EdgeInsets.all(isMobile ? 17 : 25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 7, bottom: 13),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.line)),
                      ),
                      child: const Text(
                        'Informações do lote',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    ResponsiveGrid(
                      key: ValueKey(_formVersion),
                      columns: isMobile ? 1 : 2,
                      spacing: 16,
                      runSpacing: 0,
                      children: [
                        _field(
                          'Descrição do resíduo *',
                          AppTextField(
                            controller: _description,
                            hint: 'Ex.: materiais de curativo',
                            validator: (v) => _required(v, 'Informe a descrição.'),
                          ),
                        ),
                        _field(
                          'Grupo de resíduo *',
                          AppSelect<String>(
                            value: _group,
                            hint: 'Selecione o grupo',
                            items: [
                              for (final entry in WasteGroups.names.entries)
                                AppSelectItem(entry.key, entry.value),
                            ],
                            validator: (value) => value == null ? 'Selecione o grupo.' : null,
                            onChanged: (value) => setState(() => _group = value),
                          ),
                        ),
                        _field(
                          'Setor de origem *',
                          AppTextField(
                            controller: _sector,
                            hint: 'Ex.: laboratório',
                            validator: (v) => _required(v, 'Informe o setor de origem.'),
                          ),
                        ),
                        _field(
                          'Quantidade *',
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _quantity,
                                  hint: '0,00',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                                  ],
                                  validator: (value) {
                                    final number = _parseQuantity(value);
                                    if (number == null || number < 0.01) {
                                      return 'Informe uma quantidade maior que zero.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: AppSelect<String>(
                                  value: _unit,
                                  items: stringItems(LotUnits.all),
                                  onChanged: (value) => setState(() => _unit = value ?? _unit),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _field(
                          'Status inicial',
                          AppSelect<String>(
                            value: _status,
                            items: stringItems(LotStatus.initial),
                            onChanged: (value) => setState(() => _status = value ?? _status),
                          ),
                        ),
                        _field(
                          'Destino previsto',
                          AppTextField(
                            controller: _destination,
                            hint: 'Ex.: central de resíduos',
                          ),
                        ),
                      ],
                    ),
                    const FieldLabel('Observações'),
                    AppTextField.multiline(
                      controller: _notes,
                      hint: 'Informações adicionais sobre acondicionamento ou coleta...',
                    ),
                    FormActions(children: [
                      AppButton(
                        label: 'Cancelar',
                        variant: AppButtonVariant.outline,
                        onPressed: _saving
                            ? null
                            : () => context.read<NavigationController>().go(AppPage.lots),
                      ),
                      AppButton(
                        label: 'Cadastrar lote e gerar QR Code →',
                        isLoading: _saving,
                        loadingLabel: 'Salvando...',
                        onPressed: _submit,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
