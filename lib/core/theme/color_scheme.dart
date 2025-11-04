import 'package:flutter/material.dart';

class AppTheme {
  // 🎉 Brand / Primary
  static const primary = Color(0xFF0f2027);
  static const secondary = Color(0xFFFFC107); // Amber/Gold (reward feel)

  // 🌟 Accents
  static const accentGreen = Color(0xFF4CAF50); // Success / Win
  static const accentRed = Color(0xFFF44336);   // Lose / Error
  static const accentBlue = Color(0xFF2196F3);  // Info / Hints
  static const accentOrange = Color(0xFFFF5722);// Excitement / Offers

  // 🎨 Backgrounds
  static const background = Color(0xFFFDFDFD);
  static const cardBackground = Color(0xFFFFFFFF);
  static const rewardBackground = Color(0xFFFFF8E1); // light gold shade

  // 📝 Text Colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);

  //admin panel color
  static const adminGreen = Color(0xFFA1E861); // Success / Win
  static const adminTileGreen = Color(0xFF0F3442);   // Lose / Error
  static const adminBackGroundGreen = Color(0xFF082834);  // Info / Hints
  static const adminDrawer = Color(0xFF051D2A);// Excitement / Offers

  // ✨ Special Gradients
  static const rewardGradient = [
    Color(0xFFFFD54F), // Gold yellow
    Color(0xFFFFB300), // Deep amber
  ];

  static const List<Color> gradientPurpleBlue = [
    Color(0xFF6A11CB), Color(0xFF2575FC)
  ];

  static const List<Color> gradientOrangeGold = [
    Color(0xFFFF8C3B), Color(0xFFFFC107)
  ];

  static const List<Color> gradientOrangePurple = [
    Color(0xFFFFC107),Color(0xFF6A11CB)
  ];
  static const winGradient = [

    // Color(0xFF23A168), // green
    // Color(0xFFFFC107), // amber/gold

    // Color(0xFF23A168), // green
    // Color(0xFF2196F3),

    Color(0xFF0f2027), Color(0xFF2c5364)
  ];

  static const loseGradient = [
    Color(0xFFF44336),
    Color(0xFFB71C1C),
  ];
}
