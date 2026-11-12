import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/breakpoints.dart';

/// Área rolável de cada página (.page-content), limitada a 1600 px.
class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final horizontal = isMobile ? 16.0 : (Breakpoints.isCompact(context) ? 24.0 : 35.0);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontal, isMobile ? 22 : 30, horizontal, isMobile ? 35 : 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Título da página (.page-heading) com descrição e botões de ação.
class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.pageTitle.copyWith(fontSize: isMobile ? 22 : 25),
        ),
        const SizedBox(height: 7),
        Text(subtitle, style: AppTextStyles.muted),
      ],
    );
    final actionsWrap = Wrap(spacing: 9, runSpacing: 9, children: actions);

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                texts,
                if (actions.isNotEmpty) ...[const SizedBox(height: 18), actionsWrap],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: texts),
                if (actions.isNotEmpty) ...[const SizedBox(width: 18), actionsWrap],
              ],
            ),
    );
  }
}

/// Grade simples em linhas de N colunas (substitui o CSS grid).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.children,
    this.spacing = 15,
    this.runSpacing = 15,
    this.equalHeight = false,
    this.flexes,
  });

  final int columns;
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  /// Iguala a altura dos itens de cada linha. Não use com filhos que
  /// dependam de LayoutBuilder (tabelas), pois exige medidas intrínsecas.
  final bool equalHeight;

  /// Proporção opcional de cada coluna (ex.: [14, 8] para 1.4fr / .8fr).
  final List<int>? flexes;

  @override
  Widget build(BuildContext context) {
    final safeColumns = columns < 1 ? 1 : columns;
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += safeColumns) {
      final cells = <Widget>[];
      for (var column = 0; column < safeColumns; column++) {
        if (column > 0) cells.add(SizedBox(width: spacing));
        final index = start + column;
        final flex = (flexes != null && column < flexes!.length) ? flexes![column] : 1;
        cells.add(Expanded(
          flex: flex,
          child: index < children.length ? children[index] : const SizedBox.shrink(),
        ));
      }
      Widget row = Row(
        crossAxisAlignment:
            equalHeight ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: cells,
      );
      if (equalHeight) row = IntrinsicHeight(child: row);
      if (rows.isNotEmpty) rows.add(SizedBox(height: runSpacing));
      rows.add(row);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// Mensagem de lista vazia (.empty-state).
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: const Color(0xFFB4C2BC)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8B9993), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
