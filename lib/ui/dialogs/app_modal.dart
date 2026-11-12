import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';

/// Abre um modal no estilo da versão web (.modal): até 650 px, cabeçalho com
/// título e botão de fechar, corpo rolável. Fecha com Esc ou clicando fora.
Future<T?> showAppModal<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: const Color(0x7A0A231D),
    builder: (dialogContext) {
      final height = MediaQuery.sizeOf(dialogContext).height;
      return Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 650, maxHeight: height * 0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(23, 16, 16, 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppFonts.heading,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Fechar',
                      child: Material(
                        color: const Color(0xFFF0F5F2),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: const SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(Icons.close, size: 17, color: Color(0xFF536B60)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Builder(builder: builder),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Linha de botões alinhada à direita no rodapé de formulários (.form-actions).
class FormActions extends StatelessWidget {
  const FormActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 9,
        runSpacing: 9,
        children: children,
      ),
    );
  }
}

/// Botão "Fechar" padrão dos modais somente leitura.
class CloseModalButton extends StatelessWidget {
  const CloseModalButton({super.key, this.label = 'Fechar'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppButton(label: label, onPressed: () => Navigator.of(context).pop());
  }
}
