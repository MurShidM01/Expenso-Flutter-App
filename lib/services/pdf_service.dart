import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/expense.dart';

enum StatementPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

class PdfService {
  static Future<List<int>> generateStatement(
    List<Expense> expenses,
    String currency,
    StatementPeriod period,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    
    // Filter expenses based on period
    final filteredExpenses = _filterExpensesByPeriod(expenses, period);
    
    // Generate period-specific title
    final periodTitle = _getPeriodTitle(period, now);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Expenso Statement - $periodTitle',
                style: pw.TextStyle(font: pw.Font.helveticaBold()),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${DateFormat('MMM dd, yyyy').format(now)}',
              style: pw.TextStyle(font: pw.Font.helvetica()),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Date', style: pw.TextStyle(font: pw.Font.helveticaBold())),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Type', style: pw.TextStyle(font: pw.Font.helveticaBold())),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Category', style: pw.TextStyle(font: pw.Font.helveticaBold())),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Amount', style: pw.TextStyle(font: pw.Font.helveticaBold())),
                    ),
                  ],
                ),
                ...filteredExpenses.map(
                  (e) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          DateFormat('MMM dd, yyyy').format(e.date),
                          style: pw.TextStyle(font: pw.Font.helvetica()),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          e.type,
                          style: pw.TextStyle(font: pw.Font.helvetica()),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          e.category,
                          style: pw.TextStyle(font: pw.Font.helvetica()),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          '$currency ${e.amount.toStringAsFixed(2)}',
                          style: pw.TextStyle(font: pw.Font.helvetica()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Income: $currency ${_calculateTotalIncome(filteredExpenses).toStringAsFixed(2)}',
              style: pw.TextStyle(font: pw.Font.helveticaBold()),
            ),
            pw.Text(
              'Total Expenses: $currency ${_calculateTotalExpenses(filteredExpenses).toStringAsFixed(2)}',
              style: pw.TextStyle(font: pw.Font.helveticaBold()),
            ),
            pw.Text(
              'Net Balance: $currency ${_calculateNetBalance(filteredExpenses).toStringAsFixed(2)}',
              style: pw.TextStyle(font: pw.Font.helveticaBold()),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static List<Expense> _filterExpensesByPeriod(List<Expense> expenses, StatementPeriod period) {
    final now = DateTime.now();
    final startDate = _getStartDate(now, period);
    
    return expenses.where((expense) => expense.date.isAfter(startDate)).toList();
  }

  static DateTime _getStartDate(DateTime now, StatementPeriod period) {
    switch (period) {
      case StatementPeriod.daily:
        return DateTime(now.year, now.month, now.day);
      case StatementPeriod.weekly:
        return now.subtract(Duration(days: now.weekday - 1));
      case StatementPeriod.monthly:
        return DateTime(now.year, now.month, 1);
      case StatementPeriod.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  static String _getPeriodTitle(StatementPeriod period, DateTime now) {
    switch (period) {
      case StatementPeriod.daily:
        return 'Daily Statement - ${DateFormat('MMM dd, yyyy').format(now)}';
      case StatementPeriod.weekly:
        final startDate = now.subtract(Duration(days: now.weekday - 1));
        final endDate = startDate.add(const Duration(days: 6));
        return 'Weekly Statement - ${DateFormat('MMM dd').format(startDate)} to ${DateFormat('MMM dd, yyyy').format(endDate)}';
      case StatementPeriod.monthly:
        return 'Monthly Statement - ${DateFormat('MMMM yyyy').format(now)}';
      case StatementPeriod.yearly:
        return 'Yearly Statement - ${now.year}';
    }
  }

  static double _calculateTotalIncome(List<Expense> expenses) {
    return expenses
        .where((e) => e.type == 'Income')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  static double _calculateTotalExpenses(List<Expense> expenses) {
    return expenses
        .where((e) => e.type == 'Expense')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  static double _calculateNetBalance(List<Expense> expenses) {
    return _calculateTotalIncome(expenses) - _calculateTotalExpenses(expenses);
  }
} 