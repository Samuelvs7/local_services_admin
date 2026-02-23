import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeType {
  orange,
  dark,
}

class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier() : super(AppThemeType.orange);

  void toggleTheme() {
    state = state == AppThemeType.orange ? AppThemeType.dark : AppThemeType.orange;
  }

  void setTheme(AppThemeType type) {
    state = type;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});
