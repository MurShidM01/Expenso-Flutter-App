import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/expense.dart';
import 'permission_service.dart';
import '../models/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _expensesFileName = 'expenses.json';
  static const String _settingsFileName = 'settings.json';
  static Directory? _appDir;
  static const String _expensesKey = 'expenses';
  static const String _settingsKey = 'settings';
  static const String _exportDir = '/storage/emulated/0/Expenso';

  static Future<Directory> get _localPath async {
    if (_appDir != null) return _appDir!;

    // Request storage permission if not granted
    if (!await PermissionService.checkStoragePermission()) {
      final granted = await PermissionService.requestStoragePermission();
      if (!granted) {
        throw Exception('Storage permission not granted');
      }
    }

    // Always use app's private directory for storing app data
    final appDir = await getApplicationDocumentsDirectory();
    _appDir = appDir;
    return appDir;
  }

  static Future<Directory> get _externalPath async {
    if (Platform.isAndroid) {
      try {
        if (await Permission.manageExternalStorage.isGranted) {
          final externalDir = Directory('/storage/emulated/0/Expenso');
          if (!await externalDir.exists()) {
            await externalDir.create(recursive: true);
          }
          return externalDir;
        }
      } catch (e) {
        print('Error accessing external storage: $e');
      }
    }
    throw Exception('External storage not available');
  }

  static Future<File> get _expensesFile async {
    final path = await _localPath;
    final file = File('${path.path}/$_expensesFileName');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  static Future<File> get _settingsFile async {
    final path = await _localPath;
    final file = File('${path.path}/$_settingsFileName');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final file = await _expensesFile;
      final expensesList = expenses.map((e) => e.toMap()).toList();
      final expensesJson = jsonEncode(expensesList);
      await file.writeAsString(expensesJson);
      print('Expenses saved to: ${file.path}');
    } catch (e) {
      print('Error saving expenses: $e');
      rethrow;
    }
  }

  static Future<List<Expense>> loadExpenses() async {
    try {
      final file = await _expensesFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) return [];
      final List<dynamic> expensesList = jsonDecode(contents);
      return expensesList.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      print('Error loading expenses: $e');
      return [];
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final file = await _settingsFile;
      final settingsJson = jsonEncode(settings);
      await file.writeAsString(settingsJson);
      print('Settings saved to: ${file.path}');
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = await _settingsFile;
      if (!await file.exists()) {
        return {
          'currency': 'USD',
          'initialBalance': 0.0,
          'isDarkMode': false,
        };
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return {
          'currency': 'USD',
          'initialBalance': 0.0,
          'isDarkMode': false,
        };
      }
      return jsonDecode(contents);
    } catch (e) {
      print('Error loading settings: $e');
      return {
        'currency': 'USD',
        'initialBalance': 0.0,
        'isDarkMode': false,
      };
    }
  }

  static Future<void> clearAllData() async {
    try {
      final expensesFile = await _expensesFile;
      final settingsFile = await _settingsFile;
      if (await expensesFile.exists()) {
        await expensesFile.delete();
      }
      if (await settingsFile.exists()) {
        await settingsFile.delete();
      }
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  static Future<void> openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      if (Platform.isAndroid) {
        final packageInfo = await PackageInfo.fromPlatform();
        final uri = Uri.parse('content://${packageInfo.packageName}.fileprovider/external_files/${file.path.split('/').last}');
        
        // Try to open with system PDF viewer
        final intent = Uri.parse('intent://${file.path}#Intent;scheme=file;type=application/pdf;end');
        
        if (await canLaunchUrl(intent)) {
          await launchUrl(intent);
        } else {
          // Fallback to default file opener
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          } else {
            throw Exception('Could not open file');
          }
        }
      } else {
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Could not open file');
        }
      }
    } catch (e) {
      print('Error opening file: $e');
      rethrow;
    }
  }

  static Future<String> saveFileToExternalStorage(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      if (Platform.isAndroid) {
        // Request storage permission
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission not granted');
        }

        // Create Expenso directory in root storage
        final expensoDir = Directory(_exportDir);
        if (!await expensoDir.exists()) {
          await expensoDir.create(recursive: true);
        }

        // Create the file
        final file = File('${expensoDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        // Open the file after saving
        await openFile(file.path);

        return file.path;
      } else {
        // For non-Android platforms
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        // Open the file after saving
        await openFile(file.path);
        
        return file.path;
      }
    } catch (e) {
      print('Error saving file: $e');
      rethrow;
    }
  }

  static Future<String> savePdfToExternalStorage(List<int> bytes, String fileName) async {
    return saveFileToExternalStorage(bytes, fileName);
  }
} 