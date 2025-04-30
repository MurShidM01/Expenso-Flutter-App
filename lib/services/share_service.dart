import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Expense Statement',
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }
} 