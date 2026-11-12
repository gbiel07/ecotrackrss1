import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../data/models/ecotrack_data.dart';
import '../data/models/waste_lot.dart';

/// Gera os PDFs do sistema: relatório completo dos dados e etiqueta com QR Code.
class PdfExportService {
  const PdfExportService();

  static final PdfColor _green = PdfColor.fromHex('#14543e');
  static final PdfColor _ink = PdfColor.fromHex('#17211d');
  static final PdfColor _muted = PdfColor.fromHex('#52635b');
  static final PdfColor _border = PdfColor.fromHex('#d9e3dd');
  static final PdfColor _headBg = PdfColor.fromHex('#edf4ef');
  static final PdfColor _qr = PdfColor.fromHex('#123e32');

  Future<pw.ThemeData> _theme() async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/DMSans-400.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/DMSans-700.ttf'));
    return pw.ThemeData.withFont(base: regular, bold: bold);
  }

  /// Abre a janela de impressão / "Salvar como PDF" com todos os registros.
  Future<void> printDataReport(EcoTrackData data) async {
    await Printing.layoutPdf(
      name: 'Relatorio_EcoTrack_RSS_${Formatters.fileDate(DateTime.now())}',
      onLayout: (_) => buildDataReport(data),
    );
  }

  /// Abre a impressão da etiqueta do lote com QR Code.
  Future<void> printLotLabel(WasteLot lot) async {
    await Printing.layoutPdf(
      name: 'QR_${lot.id}',
      onLayout: (_) => buildLotLabel(lot),
    );
  }

  Future<Uint8List> buildDataReport(EcoTrackData data) async {
    final theme = await _theme();
    final document = pw.Document(theme: theme, title: 'Relatório EcoTrack RSS');
    final generated = Formatters.dateTime(DateTime.now());
    final openCount = data.occurrences.where((o) => o.isOpen).length;

    final lots = data.lots
        .map((l) => [
              l.id,
              l.description,
              WasteGroups.nameOf(l.group),
              l.sector,
              '${Formatters.quantity(l.quantity)} ${l.unit}',
              l.status,
              l.destination,
              l.responsible,
              Formatters.dateTime(l.createdAt),
              l.notes.isEmpty ? '—' : l.notes,
            ])
        .toList();

    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final movementsSorted = [...data.movements]
      ..sort((a, b) => (b.date ?? epoch).compareTo(a.date ?? epoch));
    final movements = movementsSorted
        .map((m) => [
              m.id,
              m.lotId,
              m.action,
              m.from,
              m.to,
              m.responsible,
              Formatters.dateTime(m.date),
              m.notes.isEmpty ? '—' : m.notes,
            ])
        .toList();

    final occurrencesSorted = [...data.occurrences]..sort((a, b) => b.date.compareTo(a.date));
    final occurrences = occurrencesSorted
        .map((o) => [
              o.id,
              o.lotId,
              o.type,
              o.priority,
              o.status,
              o.responsible,
              Formatters.dateTime(o.date),
              o.description.isEmpty ? '—' : o.description,
            ])
        .toList();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(12 * PdfPageFormat.mm),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ),
        build: (context) => [
          pw.Text(
            'EcoTrack RSS — Relatório de dados',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _ink),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Gerado em $generated · Dados armazenados neste dispositivo',
            style: pw.TextStyle(fontSize: 10, color: _muted),
          ),
          pw.SizedBox(height: 14),
          pw.Row(
            children: [
              _metric('${data.lots.length}', 'Lotes'),
              pw.SizedBox(width: 10),
              _metric('${data.movements.length}', 'Movimentações'),
              pw.SizedBox(width: 10),
              _metric('${data.occurrences.length}', 'Ocorrências'),
              pw.SizedBox(width: 10),
              _metric('$openCount', 'Ocorrências em aberto'),
            ],
          ),
          _sectionTitle('Lotes cadastrados'),
          _table(
            const [
              'ID',
              'Descrição',
              'Grupo',
              'Setor de origem',
              'Quantidade',
              'Status',
              'Destino',
              'Responsável',
              'Cadastro',
              'Observações',
            ],
            lots,
          ),
          _sectionTitle('Histórico de movimentações'),
          _table(
            const ['ID', 'Lote', 'Ação', 'Origem', 'Destino', 'Responsável', 'Data', 'Observações'],
            movements,
          ),
          _sectionTitle('Ocorrências registradas'),
          _table(
            const ['ID', 'Lote', 'Tipo', 'Prioridade', 'Status', 'Responsável', 'Data', 'Descrição'],
            occurrences,
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Relatório informativo gerado a partir dos dados locais do EcoTrack RSS. '
            'Confira os registros antes de usar como evidência oficial.',
            style: pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
    );
    return document.save();
  }

  Future<Uint8List> buildLotLabel(WasteLot lot) async {
    final theme = await _theme();
    final document = pw.Document(theme: theme, title: 'QR ${lot.id}');
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(10 * PdfPageFormat.mm),
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'EcoTrack RSS',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _qr),
              ),
              pw.SizedBox(height: 6),
              pw.Text(lot.description,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10, color: _muted)),
              pw.SizedBox(height: 16),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: lot.id,
                width: 150,
                height: 150,
                color: _qr,
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                lot.id,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _qr),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Grupo ${lot.group} · ${WasteGroups.nameOf(lot.group)}',
                style: pw.TextStyle(fontSize: 10, color: _muted),
              ),
            ],
          ),
        ),
      ),
    );
    return document.save();
  }

  pw.Widget _metric(String value, String label) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _border),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(label, style: pw.TextStyle(fontSize: 9, color: _muted)),
          ],
        ),
      ),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20, bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _green),
      ),
    );
  }

  pw.Widget _table(List<String> headers, List<List<String>> rows) {
    final data = rows.isEmpty
        ? [
            ['Nenhum registro encontrado.', ...List.filled(headers.length - 1, '')],
          ]
        : rows;
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: _border, width: 0.6),
      headerDecoration: pw.BoxDecoration(color: _headBg),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _ink),
      cellStyle: pw.TextStyle(fontSize: 7.5, color: _ink),
      cellAlignment: pw.Alignment.topLeft,
      headerAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(4),
    );
  }
}
