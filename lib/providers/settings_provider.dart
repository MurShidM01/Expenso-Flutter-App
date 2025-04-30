import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _showNotifications = true;
  String _language = 'English';
  final List<String> _supportedLanguages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

  bool get isDarkMode => _isDarkMode;
  bool get showNotifications => _showNotifications;
  String get language => _language;
  List<String> get supportedLanguages => _supportedLanguages;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await StorageService.loadSettings();
    _isDarkMode = settings['isDarkMode'] ?? false;
    _showNotifications = settings['showNotifications'] ?? false;
    _language = settings['language'] ?? 'English';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _showNotifications = !_showNotifications;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_supportedLanguages.contains(language)) {
      _language = language;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings({
      'isDarkMode': _isDarkMode,
      'showNotifications': _showNotifications,
      'language': _language,
    });
  }
} 