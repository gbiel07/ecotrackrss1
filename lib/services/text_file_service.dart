import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Copiar e salvar relatórios em texto (.txt).
class TextFileService {
  const TextFileService();

  Future<void> copy(String text) => Clipboard.setData(ClipboardData(text: text));

  /// No celular abre o menu de compartilhamento (salvar em Arquivos, Drive,
  /// WhatsApp...). No navegador o arquivo é baixado.
  Future<void> saveTxt(String text, String fileName) async {
    final bytes = Uint8List.fromList(utf8.encode(text));
    final file = XFile.fromData(bytes, mimeType: 'text/plain', name: fileName);
    await Share.shareXFiles(
      [file],
      subject: 'Relatório EcoTrack RSS',
      fileNameOverrides: [fileName],
    );
  }
}
