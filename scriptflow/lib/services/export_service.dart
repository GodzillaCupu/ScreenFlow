import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';

/// Exports scripts to local `.txt` files under <appDocs>/exports/ and
/// optionally hands them to the OS share sheet.
class ExportService {
  Future<File> exportTxt({
    required String title,
    required String content,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, AppConstants.exportsDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(p.join(dir.path, '${_safeFileName(title)}.txt'));
    return file.writeAsString(content, flush: true);
  }

  /// Writes then opens the native share sheet (save to Files, send, etc.).
  Future<void> exportAndShare({
    required String title,
    required String content,
  }) async {
    final file = await exportTxt(title: title, content: content);
    await Share.shareXFiles([XFile(file.path)], subject: title);
  }

  String _safeFileName(String title) {
    final cleaned = title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    return cleaned.isEmpty ? 'script' : cleaned;
  }
}
