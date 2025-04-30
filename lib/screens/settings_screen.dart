import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import '../providers/auth_provider.dart';
import '../services/version_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final _initialBalanceController = TextEditingController();
  final List<String> _currencies = ['USD', 'PKR', 'INR', 'EUR', 'GBP'];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _initialBalanceController.text =
        context.read<ExpenseProvider>().initialBalance.toString();
  }

  @override
  void dispose() {
    _initialBalanceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportStatement() async {
    try {
      final expenses = context.read<ExpenseProvider>().expenses;
      if (expenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No expenses to export')),
        );
        return;
      }

      // Show period selection dialog
      final period = await showDialog<StatementPeriod>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Statement Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
              _buildPeriodOption(context, StatementPeriod.daily, 'Daily'),
              _buildPeriodOption(context, StatementPeriod.weekly, 'Weekly'),
              _buildPeriodOption(context, StatementPeriod.monthly, 'Monthly'),
              _buildPeriodOption(context, StatementPeriod.yearly, 'Yearly'),
                    ],
                  ),
                ),
      );

      if (period == null) return; // User cancelled

      final pdf = await PdfService.generateStatement(
        expenses,
        context.read<ExpenseProvider>().currency,
        period,
      );

      final fileName = 'Expenso_Statement.pdf';
      final filePath = await StorageService.savePdfToExternalStorage(pdf, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statement exported to: $filePath'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting statement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPeriodOption(BuildContext context, StatementPeriod period, String label) {
    return ListTile(
      title: Text(label),
      onTap: () => Navigator.pop(context, period),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.file_download,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: const Text('Export Statement'),
      subtitle: const Text('Download your expense statement'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _exportStatement,
    );
  }

  Future<void> _clearData() async {
    try {
      final provider = context.read<ExpenseProvider>();
      await provider.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: $e')),
        );
      }
    }
  }

  Future<void> _launchHelpSupport() async {
    const url = 'https://github.com/MurShidM01/Expenso-Flutter-App/issues';
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch help & support')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching help & support: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
          padding: const EdgeInsets.all(16.0),
                child: Row(
          children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
            _buildSection(
              context,
                                'Preferences',
                                [
                                  _buildCurrencySelector(context),
                                  const Divider(),
                                  _buildThemeSelector(context),
                                ],
                              ),
                              const SizedBox(height: 24),
            _buildSection(
              context,
              'Data Management',
              [
                                  _buildExportButton(context),
                                  const Divider(),
                                  _buildClearDataButton(context),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                  context,
                                'About',
                                [
                                  _buildVersionInfo(context),
                                  const Divider(),
                                  _buildPrivacyPolicyButton(context),
                                  const Divider(),
                                  _buildTermsOfServiceButton(context),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildLogoutButton(context),
                            ],
                          ),
                        ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.currency_exchange,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: const Text('Currency'),
          subtitle: Text(provider.currency),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Select Currency'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCurrencyOption(context, provider, 'USD'),
                    _buildCurrencyOption(context, provider, 'EUR'),
                    _buildCurrencyOption(context, provider, 'GBP'),
                    _buildCurrencyOption(context, provider, 'PKR'),
                    _buildCurrencyOption(context, provider, 'JPY'),
                    _buildCurrencyOption(context, provider, 'INR'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCurrencyOption(BuildContext context, ExpenseProvider provider, String currency) {
    return ListTile(
      title: Text(currency),
      trailing: provider.currency == currency
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        provider.setCurrency(currency);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.palette,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: const Text('Theme'),
          subtitle: Text(settings.isDarkMode ? 'Dark' : 'Light'),
          trailing: Switch(
            value: settings.isDarkMode,
            onChanged: (value) => settings.toggleTheme(),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Future<void> _exportData() async {
    try {
      final provider = context.read<ExpenseProvider>();
      final expenses = provider.expenses;
      
      if (expenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export')),
        );
        return;
      }

      final data = {
        'currency': provider.currency,
        'expenses': expenses.map((e) => e.toJson()).toList(),
      };

      final jsonString = jsonEncode(data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expenso_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Expense Data Export',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Data exported successfully'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildClearDataButton(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.delete_forever,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      title: const Text('Clear All Data'),
      subtitle: const Text('Delete all your expense records'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'Are you sure you want to delete all your expense records? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<ExpenseProvider>(context, listen: false).clearAllData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text('All data cleared successfully'),
                        ],
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch the URL')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching URL: $e')),
        );
      }
    }
  }

  Widget _buildPrivacyPolicyButton(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.privacy_tip,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: const Text('Privacy Policy'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _launchUrl('https://github.com/MurShidM01/Expenso-Flutter-App/blob/main/PRIVACY_POLICY.md'),
    );
  }

  Widget _buildTermsOfServiceButton(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.description,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: const Text('Terms of Service'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _launchUrl('https://github.com/MurShidM01/Expenso-Flutter-App/blob/main/TERMS_OF_SERVICE.md'),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Column(
            children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: const Text('Developer'),
          subtitle: const Text('Ali Khan Jalbani'),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.update,
                      color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: const Text('Check for Updates'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final hasUpdate = await VersionService.checkForUpdate();
            if (mounted) {
              if (hasUpdate) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Update Available'),
                    content: const Text('A new version of Expenso is available. Would you like to update now?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Later'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _launchUrl(VersionService.getDownloadUrl());
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Update Now'),
                      ),
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('You are using the latest version'),
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).setAuthenticated(false);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 