import 'package:flutter/material.dart';

/// App-level text styles using JetBrainsMono font.
/// Use these constants in widgets directly (e.g. in screenshot capture contexts
/// where Theme.of(context) is not available).
class AppTextStyles {
  static const TextStyle labelTitle = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w700,
    fontSize: 50.0,
    height: 1.0,
    letterSpacing: -1.5,
    color: Colors.black,
  );

  static const TextStyle labelProduct = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w400,
    fontSize: 24.0,
    height: 1.1,
    letterSpacing: -0.5,
    color: Colors.black,
  );

  static const TextStyle labelFooter = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w400,
    fontSize: 20.0,
    height: 1.1,
    letterSpacing: -0.5,
    color: Colors.black,
  );
}

/// App-wide theme configuration.
class AppTheme {
  static ThemeData get dark => ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.labelTitle,
          bodyLarge: AppTextStyles.labelProduct,
          bodyMedium: AppTextStyles.labelFooter,
        ),
      );
}
