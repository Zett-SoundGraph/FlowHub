import 'package:flutter/material.dart';

class ColorScheme {
  final MaterialColor primary;
  final MaterialColor secondary;
  final MaterialColor text;
  final MaterialColor background;
  final MaterialColor success;
  final MaterialColor warning;
  final MaterialColor error;
  final MaterialColor red;
  final MaterialColor blue;
  final MaterialColor purple;
  final MaterialColor orange;
  final MaterialColor green;
  final MaterialColor grey;
  final MaterialColor yellow;
  final MaterialColor dottedLine;

  ColorScheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.red,
    required this.blue,
    required this.purple,
    required this.orange,
    required this.green,
    required this.text,
    required this.grey,
    required this.yellow,
    required this.success,
    required this.warning,
    required this.error,
    required this.dottedLine,
  });

  factory ColorScheme.light() => ColorScheme(
        primary: const MaterialColor(
          0xFF276DDE,
          {
            100: Color(0xFFE7F0FF),
            200: Color(0xFFACCBFF),
            300: Color(0xFF7DADFA),
            400: Color(0xFF528EF0),
            800: Color(0xFF151529),
          },
        ),
        secondary: const MaterialColor(
          0xFF121A26,
          {
            100: Color(0xFFF1F1FF),
            200: Color(0xFFC4C4FF),
            300: Color(0xFF9F9FD5),
            400: Color(0xFF7676AF),
          },
        ),
        text: const MaterialColor(
          0xFF131314,
          {
            50: Color(0xFFF9F9F9),
            100: Color(0xFFF8F8F8),
            200: Color(0xFFF0F1F3),
            300: Color(0xFFE8EAEB),
            400: Color(0xFFE8EAEB),
            500: Color(0xFFA3A6B7),
            600: Color(0xFF677488),
            700: Color(0xFF313A48),
            800: Color(0xFF1F2937),
            900: Color(0xFF131314)
          },
        ),
        background: const MaterialColor(
          0xFFFFFFFF,
          {
            50: Color(0xFFF9F9F9),
            100: Color(0xFFF8F8F8),
            200: Color(0xFFF0F1F3),
          },
        ),
        success: const MaterialColor(
          0xFF46962A,
          {
            200: Color(0xFFE6F6E0),
            700: Color(0xFF3D8324),
          },
        ),
        warning: const MaterialColor(
          0xFFFFD023,
          {
            200: Color(0xFFFFF3CA),
            700: Color(0xFFC79F0E),
          },
        ),
        error: const MaterialColor(
          0xFFE03137,
          {
            200: Color(0xFFFFECEB),
            700: Color(0xFFC02337),
          },
        ),
        red: const MaterialColor(
          0xFFE03137,
          {
            200: Color(0xFFFFECEB),
            700: Color(0xFFC02337),
          },
        ),
        blue: const MaterialColor(
          0xFF276DDE,
          {
            100: Color(0xFFE7F0FF),
            200: Color(0xFFACCBFF),
            300: Color(0xFF7DADFA),
            400: Color(0xFF528EF0),
            800: Color(0xFF151529),
          },
        ),
        purple: const MaterialColor(
          0xFF8C62FF,
          {},
        ),
        orange: const MaterialColor(
          0xFFFE964A,
          {},
        ),
        green: const MaterialColor(
          0xFF46962A,
          {
            200: Color(0xFFE6F6E0),
            700: Color(0xFF3D8324),
          },
        ),
        yellow: const MaterialColor(
          0xFFFFD023,
          {
            200: Color(0xFFFFF3CA),
            700: Color(0xFFC79F0E),
          },
        ),
        grey: const MaterialColor(
          0xFFDBDFE4,
          {
            50: Color(0xFFF9F9F9),
            100: Color(0xFFF8F8F8),
            200: Color(0xFFF0F1F3),
            300: Color(0xFFE8EAEB),
            400: Color(0xFFE8EAEB),
            500: Color(0xFFA3A6B7),
            600: Color(0xFF677488),
            700: Color(0xFF313A48),
            800: Color(0xFF131314)
          },
        ),
        dottedLine: const MaterialColor(
          0xFFDDDDDD,
          {},
        ),
      );

  factory ColorScheme.dark() => ColorScheme(
        primary: const MaterialColor(
          0xFF276DDE,
          {
            100: Color(0xFFE7F0FF),
            200: Color(0xFFACCBFF),
            300: Color(0xFF7DADFA),
            400: Color(0xFF528EF0),
            800: Color(0xFF151529),
          },
        ),
        secondary: const MaterialColor(
          0xFF121A26,
          {
            100: Color(0xFFF1F1FF),
            200: Color(0xFFC4C4FF),
            300: Color(0xFF9F9FD5),
            400: Color(0xFF7676AF),
          },
        ),
        text: const MaterialColor(
          0xFFDBDFE4,
          {
            50: Color(0xFFF9F9F9),
            100: Color(0xFFF8F8F8),
            200: Color(0xFFF0F1F3),
            300: Color(0xFFE8EAEB),
            400: Color(0xFFE8EAEB),
            500: Color(0xFFA3A6B7),
            600: Color(0xFF677488),
            700: Color(0xFF313A48),
            800: Color(0xFF131314)
          },
        ),
        background: const MaterialColor(
          0xFFFFFFFF,
          {
            50: Color(0xFFF9F9F9),
            100: Color(0xFFF8F8F8),
            200: Color(0xFFF0F1F3),
          },
        ),
        success: const MaterialColor(
          0xFF46962A,
          {
            200: Color(0xFFE6F6E0),
            600: Color(0xFF3D8324),
          },
        ),
        warning: const MaterialColor(
          0xFFFFD023,
          {
            200: Color(0xFFFFF3CA),
            500: Color(0xFFC79F0E),
          },
        ),
        error: const MaterialColor(
          0xFFE03137,
          {
            200: Color(0xFFFFECEB),
            700: Color(0xFFC02337),
          },
        ),
        red: const MaterialColor(
          0xFFCE3B3B,
          {
            100: Color(0xFFFFEDEC),
            200: Color(0xFFFFECEB),
            500: Color(0xFFC02337),
            700: Color(0xFFE03137),
          },
        ),
        blue: const MaterialColor(
          0xFF276DDE,
          {
            100: Color(0xFFE7F0FF),
            200: Color(0xFFACCBFF),
            300: Color(0xFF7DADFA),
            400: Color(0xFF528EF0),
            800: Color(0xFF151529),
          },
        ),
        purple: const MaterialColor(
          0xFF8C62FF,
          {},
        ),
        orange: const MaterialColor(0xFFFE964A, {}),
        green: const MaterialColor(
          0xFF46962A,
          {
            200: Color(0xFFE6F6E0),
            600: Color(0xFF3D8324),
          },
        ),
        yellow: const MaterialColor(
          0xFFFFD023,
          {
            200: Color(0xFFFFF3CA),
            500: Color(0xFFC79F0E),
          },
        ),
        grey: const MaterialColor(
          0xFFDBDFE4,
          {
            50: Color(0xFFF9F9F9),
            100: Color(0xFFF8F8F8),
            200: Color(0xFFF0F1F3),
            300: Color(0xFFE8EAEB),
            400: Color(0xFFE8EAEB),
            500: Color(0xFFA3A6B7),
            600: Color(0xFF677488),
            700: Color(0xFF313A48),
            800: Color(0xFF131314)
          },
        ),
        dottedLine: const MaterialColor(
          0xFFDDDDDD,
          {},
        ),
      );
}
