import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color lightBackground = Color(0xFFFEFAE0);
  static const Color lightText = Color(0xFF283618);

  static const Color darkBackground = Color(0xFF1A1F10);
  static const Color darkText = Color(0xFFE8E4D0);

  static const List<Color> noteAccents = [
    Color(0xFFA69F4D),
    Color(0xFF44442A),
    Color(0xFF663920),
    Color(0xFF2C100D),
  ];

  static Color? accentFromHex(String? hex) {
    if (hex == null) return null;
    final v = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    if (v == null) return null;
    return Color(0xFF000000 | v);
  }
}
