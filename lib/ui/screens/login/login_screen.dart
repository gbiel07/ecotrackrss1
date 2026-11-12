import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../data/models/app_user.dart';
import '../../../logic/auth_controller.dart';
import '../../../logic/navigation_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/decorations.dart';
import '../../widgets/form_fields.dart';

/// Tela de login dividida: painel da marca à esquerda e formulário à direita.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: isMobile
          ? const _LoginFormPanel(showBrand: true)
          : const Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 105, child: _LoginBrandPanel()),
                Expanded(flex: 95, child: _LoginFormPanel(showBrand: false)),
              ],
            ),
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = math.min(54.0, math.max(32.0, width * 0.04));
    final horizontal = width * (Breakpoints.isCompact(context) ? 0.06 : 0.07) * 0.55;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.loginTop, AppColors.loginBottom],
          stops: [0, 0.76],
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -0.6),
                  radius: 0.75,
                  colors: [Color(0x4059BD97), Color(0x0059BD97)],
                ),
              ),
            ),
          ),
          const Positioned(right: -290, bottom: -300, child: _Rings()),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 48),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: math.max(0.0, constraints.maxHeight - 96)),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandLogo(textColor: AppColors.white),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('RASTREAMENTO INTELIGENTE', style: AppTextStyles.eyebrow),
                              const SizedBox(height: 20),
                              Text(
                                'O cuidado com a saúde também passa pelo destino correto dos resíduos.',
                                style: TextStyle(
                                  fontFamily: AppFonts.heading,
                                  fontWeight: FontWeight.w800,
                                  fontSize: titleSize,
                                  height: 1.13,
                                  letterSpacing: -1.9,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 440),
                                child: const Text(
                                  'Controle, rastreabilidade e registro de cada etapa do descarte '
                                  'de resíduos de serviços de saúde.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.8,
                                    color: AppColors.loginText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF64D8A9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'Plataforma de gerenciamento de RSS',
                            style: TextStyle(fontSize: 12, color: AppColors.loginText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculos concêntricos decorativos do canto inferior direito.
class _Rings extends StatelessWidget {
  const _Rings();

  @override
  Widget build(BuildContext context) {
    Widget circle(double size, Color fill, {Color? border}) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: border == null ? null : Border.all(color: border),
          ),
        );
    return SizedBox(
      width: 700,
      height: 700,
      child: Stack(
        alignment: Alignment.center,
        children: [
          circle(700, const Color(0x05FFFFFF)),
          circle(600, const Color(0x06FFFFFF)),
          circle(500, Colors.transparent, border: const Color(0x17FFFFFF)),
        ],
      ),
    );
  }
}

class _LoginFormPanel extends StatefulWidget {
  const _LoginFormPanel({required this.showBrand});

  final bool showBrand;

  @override
  State<_LoginFormPanel> createState() => _LoginFormPanelState();
}

class _LoginFormPanelState extends State<_LoginFormPanel> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.employee;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final error = context.read<AuthController>().login(
          username: _username.text,
          password: _password.text,
          role: _role,
        );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    context.read<NavigationController>().resetFor(_role);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 22, vertical: 28)
              : const EdgeInsets.all(42),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.showBrand) ...[
                      const Align(alignment: Alignment.centerLeft, child: BrandLogo()),
                      const SizedBox(height: 45),
                    ],
                    const Text('BEM-VINDO AO SISTEMA', style: AppTextStyles.eyebrow),
                    const SizedBox(height: 12),
                    const Text(
                      'Acesse sua conta',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Entre com seu perfil para continuar.',
                        style: TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 10),
                    const FieldLabel('Usuário'),
                    AppTextField(
                      controller: _username,
                      hint: 'Digite seu usuário',
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Informe o usuário.' : null,
                    ),
                    const FieldLabel('Senha'),
                    AppTextField(
                      controller: _password,
                      hint: 'Digite sua senha',
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Informe a senha.' : null,
                    ),
                    const FieldLabel('Perfil de acesso'),
                    AppSelect<UserRole>(
                      value: _role,
                      items: [
                        for (final role in UserRole.values) AppSelectItem(role, role.label),
                      ],
                      onChanged: (value) => setState(() => _role = value ?? _role),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 22),
                    AppButton(label: 'Entrar  →', fullWidth: true, onPressed: _submit),
                    const SizedBox(height: 23),
                    const _DemoCredentials(),
                    const SizedBox(height: 23),
                    const Text(
                      'Protótipo acadêmico • Os dados ficam salvos neste dispositivo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.hint, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoCredentials extends StatelessWidget {
  const _DemoCredentials();

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String code) => Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF667772))),
              ),
              Text(
                code,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF176A53),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F6),
        border: Border.all(color: const Color(0xFFE8EEEB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credenciais para demonstração',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          row('Funcionário', 'funcionario / 1234'),
          row('Gestor', 'gestor / 1234'),
        ],
      ),
    );
  }
}
