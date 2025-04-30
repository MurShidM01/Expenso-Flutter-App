import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  static const String _authKey = 'isAuthenticated';

  AuthProvider() {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool(_authKey) ?? false;
    notifyListeners();
  }

  Future<void> setAuthenticated(bool value) async {
    _isAuthenticated = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, value);
    notifyListeners();
  }

  Future<void> logout() async {
    await setAuthenticated(false);
  }

  // You can add more authentication-related methods here
  // such as login, logout, etc.
} 