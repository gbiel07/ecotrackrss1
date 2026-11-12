import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/decorations.dart';

/// Estado de carregamento inicial dos registros locais.
class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandLogo(),
            SizedBox(height: 28),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 16),
            Text('Carregando registros do dispositivo...', style: AppTextStyles.muted),
          ],
        ),
      ),
    );
  }
}

/// Estado de erro ao ler os registros locais, com opções de recuperação.
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<EcoTrackController>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AppPanel(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SquareIcon(
                    icon: Icons.error_outline,
                    size: 44,
                    background: Color(0xFFFFE8E6),
                    color: AppColors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text('Não foi possível abrir os dados', style: AppTextStyles.panelTitle),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center, style: AppTextStyles.muted),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    alignment: WrapAlignment.center,
                    children: [
                      AppButton(
                        label: 'Tentar novamente',
                        icon: Icons.refresh,
                        onPressed: controller.load,
                      ),
                      AppButton(
                        label: 'Restaurar dados de demonstração',
                        variant: AppButtonVariant.outline,
                        onPressed: controller.resetToDemoData,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
