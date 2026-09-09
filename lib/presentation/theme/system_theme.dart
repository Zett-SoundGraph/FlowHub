// Inherited Widget for theme management
import 'package:flutter/material.dart';
import 'package:flowhub/presentation/theme/system_theme_data.dart';

class SystemTheme extends InheritedWidget {
  final ThemeMode themeMode;
  // final Function(ThemeMode) onThemeChanged;

  const SystemTheme({
    super.key,
    required this.themeMode,
    // required this.onThemeChanged,
    required super.child,
  });

  SystemThemeData get theme {
    return themeMode == ThemeMode.light
        ? SystemThemeData.light()
        : SystemThemeData.dark();
  }

  static SystemTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SystemTheme>();
  }

  @override
  bool updateShouldNotify(SystemTheme oldWidget) {
    return themeMode != oldWidget.themeMode;
  }

  // void toggleTheme() {
  //   switch (themeMode) {
  //     case ThemeMode.light:
  //       onThemeChanged(ThemeMode.dark);
  //       break;
  //     case ThemeMode.dark:
  //       onThemeChanged(ThemeMode.light);
  //       break;
  //     case ThemeMode.system:
  //       onThemeChanged(ThemeMode.light);
  //       break;
  //   }
  // }

  // void setTheme(ThemeMode mode) {
  //   onThemeChanged(mode);
  // }
}