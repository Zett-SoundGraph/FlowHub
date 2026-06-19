import 'package:flutter/material.dart';

class TextTheme {
  final TextStyle s10;
  final TextStyle s11;
  final TextStyle s12;
  final TextStyle s13;
  final TextStyle s14;
  final TextStyle s15;
  final TextStyle s16;
  final TextStyle s18;
  final TextStyle s20;
  final TextStyle s22;
  final TextStyle s24;
  final TextStyle s25;
  final TextStyle s28;
  final TextStyle s32;
  final TextStyle s30;
  final TextStyle s36;
  final TextStyle s42;
  final TextStyle s48;
  final TextStyle s54;

  TextTheme({
    required this.s10,
    required this.s11,
    required this.s12,
    required this.s13,
    required this.s14,
    required this.s15,
    required this.s16,
    required this.s18,
    required this.s20,
    required this.s22,
    required this.s24,
    required this.s25,
    required this.s28,
    required this.s30,
    required this.s32,
    required this.s36,
    required this.s42,
    required this.s48,
    required this.s54,
  });

  factory TextTheme.create({required Color color, String? fontFamily}) {
    return TextTheme(
      s10: TextStyle(fontSize: 10, fontFamily: fontFamily, color: color),
      s11: TextStyle(fontSize: 11, fontFamily: fontFamily, color: color),
      s12: TextStyle(fontSize: 12, fontFamily: fontFamily, color: color),
      s13: TextStyle(fontSize: 13, fontFamily: fontFamily, color: color),
      s14: TextStyle(fontSize: 14, fontFamily: fontFamily, color: color),
      s15: TextStyle(fontSize: 15, fontFamily: fontFamily, color: color),
      s16: TextStyle(fontSize: 16, fontFamily: fontFamily, color: color),
      s18: TextStyle(fontSize: 18, fontFamily: fontFamily, color: color),
      s20: TextStyle(fontSize: 20, fontFamily: fontFamily, color: color),
      s22: TextStyle(fontSize: 22, fontFamily: fontFamily, color: color),
      s24: TextStyle(fontSize: 24, fontFamily: fontFamily, color: color),
      s25: TextStyle(fontSize: 25, fontFamily: fontFamily, color: color),
      s28: TextStyle(fontSize: 28, fontFamily: fontFamily, color: color),
      s30: TextStyle(fontSize: 30, fontFamily: fontFamily, color: color),
      s32: TextStyle(fontSize: 32, fontFamily: fontFamily, color: color),
      s36: TextStyle(fontSize: 36, fontFamily: fontFamily, color: color),
      s42: TextStyle(fontSize: 42, fontFamily: fontFamily, color: color),
      s48: TextStyle(fontSize: 48, fontFamily: fontFamily, color: color),
      s54: TextStyle(fontSize: 54, fontFamily: fontFamily, color: color),
    );
  }
}
