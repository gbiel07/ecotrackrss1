import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../dialogs/app_modal.dart';
import '../../dialogs/lot_dialogs.dart';
import '../../dialogs/movement_dialogs.dart';
import '../../dialogs/occurrence_dialogs.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/decorations.dart';
import '../../widgets/detail_grid.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/layout.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/timeline.dart';

/// Extrai o código do lote de um texto lido (ex.: URL que contém "RSS-2026-001").
String extractLotCode(String raw) {
  final text = raw.trim();
  final index = text.indexOf('RSS-');
  if (index < 0) return text;
  return text.substring(index).split(RegExp(r'[\s?&#]')).first;
}

/// Leitura de QR Code pela câmera ou busca manual pelo código do lote.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _codeController = TextEditingController();
  bool _cameraActive = false;
  bool _handlingDetection = false;
  String? _foundLotId;

  /// A leitura por câmera está disponível em Android, iOS, macOS e navegador.
  bool get _cameraSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _startCamera() {
    if (!_cameraSupported) {
      AppToast.show(context, 'Câmera indisponível nesta plataforma. Use a busca manual.');
      return;
    }
    setState(() {
      _cameraActive = true;
      _handlingDetection = false;
    });
  }

  void _stopCamera({bool notify = false}) {
    if (_cameraActive) setState(() => _cameraActive = false);
    if (notify) AppToast.show(context, 'Leitor de câmera parado.');
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handlingDetection) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;
      _handlingDetection = true;
      final code = extractLotCode(raw);
      _codeController.text = code;
      _lookup(code);
      return;
    }
  }

  void _lookup(String code) {
    final lot = context.read<EcoTrackController>().findLotByCode(code);
    if (lot == null) {
      _handlingDetection = false;
      AppToast.show(context, 'Não encontramos um lote com esse código.');
      return;
    }
    setState(() {
      _cameraActive = false;
      _foundLotId = lot.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    final readerPanel = AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelHeader(
            title: 'Leitor de QR Code',
            subtitle: 'Permita o acesso à câmera ou digite o código do lote.',
          ),
          _cameraActive ? _buildCamera() : _buildPlaceholder(),
          const FieldLabel('Ou informe o código do lote', topSpacing: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  controller: _codeController,
                  hint: 'Ex.: RSS-2026-001',
                  textInputAction: TextInputAction.search,
                  onSubmitted: _lookup,
                ),
              ),
              const SizedBox(width: 8),
              AppButton(label: 'Buscar', onPressed: () => _lookup(_codeController.text)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'A câmera exige permissão do dispositivo. No navegador, use HTTPS ou localhost.',
            style: TextStyle(fontSize: 10, color: AppColors.subtle),
          ),
        ],
      ),
    );

    final howItWorksPanel = AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelHeader(title: 'Como funciona', subtitle: 'Fluxo rápido de identificação'),
          const Timeline(entries: [
            TimelineEntry(
              title: '1. Identifique o lote',
              description: 'Escaneie o QR Code ou digite o código impresso na etiqueta.',
            ),
            TimelineEntry(
              title: '2. Confira as informações',
              description: 'Verifique grupo, origem, quantidade e status atual.',
            ),
            TimelineEntry(
              title: '3. Registre a movimentação',
              description: 'Confirme a etapa e informe o destino ou observação necessária.',
            ),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF5FAF7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dica de segurança',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text(
                  'Confira o grupo do resíduo e os procedimentos internos antes de confirmar '
                  'qualquer movimentação.',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return PageContainer(
      children: [
        const PageHeading(
          title: 'Escanear QR Code',
          subtitle: 'Identifique o lote para visualizar informações ou registrar uma movimentação.',
        ),
        if (isMobile) ...[
          readerPanel,
          const SizedBox(height: 18),
          howItWorksPanel,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 12, child: readerPanel),
              const SizedBox(width: 18),
              Expanded(flex: 8, child: howItWorksPanel),
            ],
          ),
        if (_foundLotId != null) ...[
          const SizedBox(height: 18),
          _ScanResult(lotId: _foundLotId!),
        ],
      ],
    );
  }

  Widget _buildPlaceholder() {
    return DashedBorderBox(
      background: const Color(0xFFF8FBF9),
      radius: 10,
      padding: const EdgeInsets.all(25),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 180),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 44, color: Color(0xFF328A6C)),
            const SizedBox(height: 12),
            const Text('Pronto para escanear', style: AppTextStyles.panelTitle),
            const SizedBox(height: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 310),
              child: const Text(
                'Use a câmera do dispositivo para ler o QR Code impresso na etiqueta do lote.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF82928A)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                AppButton(label: 'Ativar câmera', icon: Icons.photo_camera_outlined, onPressed: _startCamera),
                AppButton(
                  label: 'Parar câmera',
                  variant: AppButtonVariant.outline,
                  onPressed: () => _stopCamera(notify: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCamera() {
    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(onDetect: _onDetect),
                    IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Parar câmera',
          variant: AppButtonVariant.outline,
          onPressed: () => _stopCamera(notify: true),
        ),
      ],
    );
  }
}

/// Painel "Lote identificado" exibido após a leitura.
class _ScanResult extends StatelessWidget {
  const _ScanResult({required this.lotId});

  final String lotId;

  @override
  Widget build(BuildContext context) {
    final lot = context.watch<EcoTrackController>().lotById(lotId);
    if (lot == null) return const SizedBox.shrink();
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelHeader(
            title: 'Lote identificado',
            subtitle: 'Confira os dados antes de continuar.',
            trailing: StatusPill.status(lot.status),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 15,
            runSpacing: 12,
            children: [
              Column(
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
                  const SizedBox(height: 4),
                  Text(lot.description, style: AppTextStyles.small),
                ],
              ),
              AppButton(
                label: 'Visualizar detalhes',
                variant: AppButtonVariant.outline,
                onPressed: () => openLotDetails(context, lot.id),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DetailGrid(entries: [
            DetailEntry('Grupo', WasteGroups.nameOf(lot.group)),
            DetailEntry('Origem', lot.sector),
            DetailEntry('Quantidade', '${Formatters.quantity(lot.quantity)} ${lot.unit}'),
          ]),
          FormActions(children: [
            AppButton(
              label: 'Registrar ocorrência',
              variant: AppButtonVariant.outline,
              onPressed: () => openOccurrenceForm(context, lotId: lot.id),
            ),
            AppButton(
              label: 'Confirmar movimentação →',
              onPressed: () => openMovementForm(context, lot),
            ),
          ]),
        ],
      ),
    );
  }
}
