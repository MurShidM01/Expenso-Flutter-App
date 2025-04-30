import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  String _currency = 'USD';
  double _initialBalance = 0.0;

  List<Expense> get expenses => _expenses;
  String get currency => _currency;
  double get initialBalance => _initialBalance;

  double get totalBalance {
    double income = _expenses
        .where((expense) => expense.type == 'income')
        .fold(0.0, (sum, expense) => sum + expense.amount);
    
    double expenses = _expenses
        .where((expense) => expense.type == 'expense')
        .fold(0.0, (sum, expense) => sum + expense.amount);
    
    return _initialBalance + income - expenses;
  }

  double get totalIncome {
    return _expenses
        .where((expense) => expense.type == 'income')
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get totalExpenses {
    return _expenses
        .where((expense) => expense.type == 'expense')
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> removeExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setInitialBalance(double balance) async {
    _initialBalance = balance;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> loadData() async {
    final settings = await StorageService.loadSettings();
    _currency = settings['currency'] ?? 'USD';
    _initialBalance = settings['initialBalance'] ?? 0.0;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings({
      'currency': _currency,
      'initialBalance': _initialBalance,
    });
  }

  Future<void> loadExpenses() async {
    _expenses = await StorageService.loadExpenses();
      notifyListeners();
  }

  Future<void> clearAllData() async {
    _expenses = [];
    _initialBalance = 0;
    await StorageService.clearAllData();
    notifyListeners();
  }
} 