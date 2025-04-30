class Settings {
  final bool isDarkMode;
  final bool showNotifications;
  final String language;
  final String currency;
  final double initialBalance;

  Settings({
    this.isDarkMode = false,
    this.showNotifications = true,
    this.language = 'English',
    this.currency = 'USD',
    this.initialBalance = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'showNotifications': showNotifications,
      'language': language,
      'currency': currency,
      'initialBalance': initialBalance,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      isDarkMode: json['isDarkMode'] ?? false,
      showNotifications: json['showNotifications'] ?? true,
      language: json['language'] ?? 'English',
      currency: json['currency'] ?? 'USD',
      initialBalance: json['initialBalance']?.toDouble() ?? 0.0,
    );
  }

  Settings copyWith({
    bool? isDarkMode,
    bool? showNotifications,
    String? language,
    String? currency,
    double? initialBalance,
  }) {
    return Settings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      showNotifications: showNotifications ?? this.showNotifications,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }
} 