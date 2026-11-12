import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/ecotrack_controller.dart';
import '../../../logic/local_assistant.dart';
import '../../../services/pdf_export_service.dart';
import '../../../services/text_file_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_panel.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/decorations.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/layout.dart';
import 'chat_message.dart';

enum _AiTool { analyze, summary, report }

/// Central de IA local: assistente por palavras-chave, análises e relatórios.
class AiCenterScreen extends StatefulWidget {
  const AiCenterScreen({super.key});

  @override
  State<AiCenterScreen> createState() => _AiCenterScreenState();
}

class _AiCenterScreenState extends State<AiCenterScreen> {
  static const Duration _thinkingDelay = Duration(milliseconds: 350);

  final _input = TextEditingController();
  final _chatScroll = ScrollController();
  final List<ChatMessage> _messages = [
    const ChatMessage.assistant(
      'Olá! Sou o assistente local do EcoTrack. Posso consultar quantidades, lotes, '
      'movimentações, ocorrências e pendências dos registros deste dispositivo. '
      'O que deseja saber?',
    ),
  ];

  bool _sending = false;
  bool _exporting = false;
  _AiTool? _runningTool;
  String _result = '';
  String _resultMeta = 'As respostas e análises aparecerão aqui.';

  @override
  void dispose() {
    _input.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  LocalAssistant _assistant() => LocalAssistant(context.read<EcoTrackController>().data);

  void _scrollChatToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScroll.hasClients) return;
      _chatScroll.animateTo(
        _chatScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _ask([String? preset]) async {
    final question = (preset ?? _input.text).trim();
    if (question.isEmpty || _sending) return;
    _input.clear();
    setState(() {
      _sending = true;
      _messages
        ..add(ChatMessage.user(question))
        ..add(const ChatMessage.pending());
    });
    _scrollChatToEnd();

    await Future<void>.delayed(_thinkingDelay);
    if (!mounted) return;

    String answer;
    try {
      answer = _assistant().answer(question);
      _setResult(answer, 'Resposta do assistente local');
    } catch (_) {
      answer = 'Erro: não foi possível consultar os registros locais.';
    }
    setState(() {
      _messages[_messages.length - 1] = ChatMessage.assistant(answer);
      _sending = false;
    });
    _scrollChatToEnd();
  }

  Future<void> _runTool(_AiTool tool) async {
    if (_runningTool != null) return;
    setState(() => _runningTool = tool);
    await Future<void>.delayed(_thinkingDelay);
    if (!mounted) return;
    try {
      final assistant = _assistant();
      switch (tool) {
        case _AiTool.analyze:
          _setResult(assistant.analyze(), 'Análise de inconsistências nos registros');
        case _AiTool.summary:
          _setResult(assistant.dashboardSummary(), 'Resumo gerencial do EcoTrack RSS');
        case _AiTool.report:
          _setResult(assistant.report(), 'Relatório gerado pela IA');
      }
      AppToast.show(context, 'Análise local concluída.');
    } catch (_) {
      _setResult(
        'Não foi possível concluir a solicitação local.\n\n'
            'Tente novamente ou confira os registros salvos neste dispositivo.',
        'Falha na análise local',
      );
      AppToast.show(context, 'Não foi possível acessar a IA.');
    } finally {
      if (mounted) setState(() => _runningTool = null);
    }
  }

  void _setResult(String text, String meta) {
    setState(() {
      _result = text;
      _resultMeta = meta;
    });
  }

  Future<void> _copy() async {
    try {
      await const TextFileService().copy(_result);
      if (mounted) AppToast.show(context, 'Resultado copiado.');
    } catch (_) {
      if (mounted) AppToast.show(context, 'Não foi possível copiar automaticamente.');
    }
  }

  Future<void> _saveTxt() async {
    final fileName = 'ecotrack-relatorio-${Formatters.fileDate(DateTime.now())}.txt';
    try {
      await const TextFileService().saveTxt(_result, fileName);
    } catch (_) {
      if (mounted) AppToast.show(context, 'Não foi possível salvar o arquivo .txt.');
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      await const PdfExportService().printDataReport(context.read<EcoTrackController>().data);
    } catch (_) {
      if (mounted) AppToast.show(context, 'Não foi possível gerar o PDF.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stacked = Breakpoints.widthOf(context) < Breakpoints.aiStack;

    return PageContainer(
      children: [
        PageHeading(
          title: 'Central de inteligência artificial',
          subtitle:
              'Assistente local, análise de inconsistências, resumo gerencial e relatórios gratuitos.',
          actions: [_statusChip()],
        ),
        _notice(),
        if (stacked) ...[
          _chatPanel(),
          const SizedBox(height: 20),
          _toolsPanel(),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 11, child: _chatPanel()),
              const SizedBox(width: 20),
              Expanded(flex: 9, child: _toolsPanel()),
            ],
          ),
        const SizedBox(height: 20),
        _resultPanel(),
      ],
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F6EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Modo local gratuito',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.greenText),
      ),
    );
  }

  Widget _notice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F3),
        border: Border.all(color: const Color(0xFFDCEBE4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modo local gratuito', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text(
            'As respostas são geradas no próprio dispositivo usando regras programadas e os dados '
            'guardados localmente. Não utiliza a API da OpenAI, não exige chave e não envia seus '
            'registros para serviços externos. As análises são indicativas e devem ser conferidas '
            'pela equipe responsável.',
            style: TextStyle(fontSize: 12, height: 1.65, color: Color(0xFF567068)),
          ),
        ],
      ),
    );
  }

  Widget _chatPanel() {
    final isMobile = Breakpoints.isMobile(context);
    final sendButton = AppButton(
      label: 'Enviar pergunta →',
      isLoading: _sending,
      loadingLabel: 'Consultando...',
      fullWidth: isMobile,
      onPressed: _ask,
    );
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelHeader(
            title: 'Assistente EcoTrack',
            subtitle: 'Pergunte sobre os lotes, movimentações e ocorrências registrados localmente.',
            trailing: SquareIcon(
              icon: Icons.auto_awesome,
              size: 35,
              background: AppColors.greenPale,
              color: AppColors.green,
            ),
          ),
          Container(
            height: 310,
            decoration: BoxDecoration(
              color: AppColors.softer,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => ListView.separated(
                controller: _chatScroll,
                padding: const EdgeInsets.all(13),
                itemCount: _messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (_, index) => ChatBubble(
                  message: _messages[index],
                  maxWidth: constraints.maxWidth * 0.95 - 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final suggestion in assistantSuggestions)
                ActionChip(
                  label: Text(suggestion, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.line),
                  onPressed: _sending ? null : () => _ask(suggestion),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isMobile) ...[
            _chatInput(),
            const SizedBox(height: 10),
            sendButton,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _chatInput()),
                const SizedBox(width: 10),
                sendButton,
              ],
            ),
        ],
      ),
    );
  }

  Widget _chatInput() {
    return AppTextField(
      controller: _input,
      hint: 'Ex.: Quais ocorrências precisam de atenção?',
      minLines: 2,
      maxLines: 4,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _toolsPanel() {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelHeader(
            title: 'Análise e relatórios',
            subtitle: 'Analise os dados locais com verificações programadas, sem API externa.',
          ),
          _ToolCard(
            icon: Icons.manage_search,
            title: 'Analisar inconsistências',
            description:
                'Revisar campos ausentes, possíveis divergências e registros que merecem conferência.',
            buttonLabel: 'Analisar dados',
            isLoading: _runningTool == _AiTool.analyze,
            onPressed: _runningTool == null ? () => _runTool(_AiTool.analyze) : null,
          ),
          _ToolCard(
            icon: Icons.bar_chart,
            title: 'Resumo do dashboard',
            description: 'Calcular indicadores e destacar pendências a partir dos registros locais.',
            buttonLabel: 'Gerar resumo',
            isLoading: _runningTool == _AiTool.summary,
            onPressed: _runningTool == null ? () => _runTool(_AiTool.summary) : null,
          ),
          _ToolCard(
            icon: Icons.description_outlined,
            title: 'Relatório inteligente',
            description: 'Montar relatório dos registros locais para copiar ou salvar em arquivo.',
            buttonLabel: 'Gerar relatório',
            isLoading: _runningTool == _AiTool.report,
            onPressed: _runningTool == null ? () => _runTool(_AiTool.report) : null,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _resultPanel() {
    final hasResult = _result.isNotEmpty;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelHeader(
            title: 'Resultado da IA',
            subtitle: _resultMeta,
            stackOnCompact: true,
            trailing: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                AppButton(
                  label: 'Exportar dados em PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  isLoading: _exporting,
                  loadingLabel: 'Gerando PDF...',
                  onPressed: _exportPdf,
                ),
                AppButton(
                  label: 'Copiar',
                  variant: AppButtonVariant.outline,
                  onPressed: hasResult ? _copy : null,
                ),
                AppButton(
                  label: 'Salvar .txt',
                  variant: AppButtonVariant.outline,
                  onPressed: hasResult ? _saveTxt : null,
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 110, maxHeight: 550),
            decoration: BoxDecoration(
              color: AppColors.softer,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: hasResult
                  ? SelectableText(
                      _result,
                      style: const TextStyle(fontSize: 13, height: 1.8, color: AppColors.ink),
                    )
                  : const Text(
                      'Selecione uma análise ou envie uma pergunta ao assistente.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF83928C)),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.isLoading,
    required this.onPressed,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isNarrow = Breakpoints.widthOf(context) < 650;
    final button = AppButton(
      label: buttonLabel,
      variant: AppButtonVariant.outline,
      compact: true,
      isLoading: isLoading,
      onPressed: onPressed,
    );
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(fontSize: 11, height: 1.55, color: AppColors.muted),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: AppColors.line)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SquareIcon(
            icon: icon,
            size: 34,
            background: const Color(0xFFEDF5F1),
            color: AppColors.greenText,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [texts, const SizedBox(height: 10), button],
                  )
                : texts,
          ),
          if (!isNarrow) ...[const SizedBox(width: 11), button],
        ],
      ),
    );
  }
}
