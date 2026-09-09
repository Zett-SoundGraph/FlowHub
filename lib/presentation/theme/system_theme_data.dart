// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flowhub/presentation/theme/color_theme.dart';
import 'package:flowhub/presentation/theme/text_theme.dart';


class SystemThemeData {
  final Brightness brightness;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  
  /// Base spacing unit for responsive design
  final double baseSpacing;
  
  /// Base border radius for responsive design
  final double baseBorderRadius;
  
  /// Base elevation for responsive design
  final double baseElevation;

  SystemThemeData({
    required this.brightness,
    required this.colorScheme,
    required this.textTheme,
    this.baseSpacing = 8.0,
    this.baseBorderRadius = 8.0,
    this.baseElevation = 2.0,
  });

  factory SystemThemeData.light() => SystemThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(),
    textTheme: TextTheme.create(
      color: ColorScheme.light().text, // Default text color for light theme
    ),
    baseSpacing: 8.0,
    baseBorderRadius: 8.0,
    baseElevation: 2.0,
  );

  factory SystemThemeData.dark() => SystemThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(),
    textTheme: TextTheme.create(
      color: ColorScheme.dark().text, // Default text color for dark theme
    ),
    baseSpacing: 8.0,
    baseBorderRadius: 8.0,
    baseElevation: 2.0,
  );
}
