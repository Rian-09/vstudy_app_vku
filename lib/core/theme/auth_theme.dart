import 'package:flutter/material.dart';

abstract final class AuthColors {
  static const navy = Color(0xFF1F2A44);
  static const navySecondary = Color(0xFF3B4A6B);
  static const muted = Color(0xFF6B7280);
  static const grayBlue = Color(0xFF8A93A6);
  static const border = Color(0xFFE7E3D8);
  static const navyTint = Color(0xFFDDE2EE);
  static const white = Color(0xFFFFFFFF);
  static const text = Color(0xFF14181F);
  static const accent = Color(0xFFE1B70F);
  static const success = Color(0xFF1E6B45);
}

abstract final class AuthTextStyles {
  static const title = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    color: AuthColors.navy,
  );
  static const body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 20 / 14,
    color: AuthColors.navySecondary,
  );
  static const label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AuthColors.navy,
  );
  static const caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    height: 18 / 12,
    color: AuthColors.navySecondary,
  );
  static const button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w600,
  );
}
