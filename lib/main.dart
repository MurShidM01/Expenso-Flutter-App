import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize providers
  final expenseProvider = ExpenseProvider();
  final settingsProvider = SettingsProvider();
  final authProvider = AuthProvider();
  
  // Load initial data
  await expenseProvider.loadData();
  await expenseProvider.loadExpenses();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: expenseProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Expenso',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
              brightness: Brightness.light,
              primary: const Color(0xFF6C63FF),
              secondary: const Color(0xFF03DAC6),
              tertiary: const Color(0xFFFF8A65),
              background: const Color(0xFFF8F9FE),
              surface: Colors.white,
            ),
            textTheme: GoogleFonts.poppinsTextTheme().copyWith(
              displayLarge: const TextStyle(fontWeight: FontWeight.bold),
              displayMedium: const TextStyle(fontWeight: FontWeight.bold),
              displaySmall: const TextStyle(fontWeight: FontWeight.bold),
              headlineMedium: const TextStyle(fontWeight: FontWeight.w600),
              titleLarge: const TextStyle(fontWeight: FontWeight.w600),
              bodyLarge: const TextStyle(fontSize: 16),
            ),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.1),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FE),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
              brightness: Brightness.dark,
              primary: const Color(0xFF6C63FF),
              secondary: const Color(0xFF03DAC6),
              tertiary: const Color(0xFFFF8A65),
              background: const Color(0xFF1A1A1A),
              surface: const Color(0xFF2D2D2D),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
              displayLarge: const TextStyle(fontWeight: FontWeight.bold),
              displayMedium: const TextStyle(fontWeight: FontWeight.bold),
              displaySmall: const TextStyle(fontWeight: FontWeight.bold),
              headlineMedium: const TextStyle(fontWeight: FontWeight.w600),
              titleLarge: const TextStyle(fontWeight: FontWeight.w600),
              bodyLarge: const TextStyle(fontSize: 16),
            ),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: const Color(0xFF2D2D2D),
              shadowColor: Colors.black.withOpacity(0.2),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
            ),
            scaffoldBackgroundColor: const Color(0xFF1A1A1A),
          ),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
