import 'package:flutter/material.dart';
import '../data/models.dart';

class AppTheme {
  static const Color coffeeBrown = Color(0xFF6F4E37);
  static const Color coffeeGreen = Color(0xFF4CAF50);
  static const Color alertRed = Color(0xFFE53E3E);
  static const Color alertYellow = Color(0xFFECC94B);

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: coffeeBrown,
        secondary: coffeeGreen,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: coffeeBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Color getAlertColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.critical:
        return alertRed;
      case AlertPriority.warning:
        return alertYellow;
      case AlertPriority.info:
        return coffeeGreen;
    }
  }
}
