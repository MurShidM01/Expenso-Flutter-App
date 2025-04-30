import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class VersionService {
  static const String _githubRepo = 'MurShidM01/Expenso-Flutter-App';
  static const String _githubApiUrl = 'https://api.github.com/repos/$_githubRepo/releases/latest';

  static Future<bool> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Get latest version from GitHub
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');

        // Compare versions
        return _isNewerVersion(latestVersion, currentVersion);
      }
      return false;
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }

  static bool _isNewerVersion(String latestVersion, String currentVersion) {
    final latestParts = latestVersion.split('.');
    final currentParts = currentVersion.split('.');

    for (var i = 0; i < 3; i++) {
      final latest = int.tryParse(latestParts[i]) ?? 0;
      final current = int.tryParse(currentParts[i]) ?? 0;

      if (latest > current) return true;
      if (latest < current) return false;
    }
    return false;
  }

  static String getDownloadUrl() {
    return 'https://github.com/$_githubRepo/releases/latest';
  }
} 