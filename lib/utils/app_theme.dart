import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(

    primaryColor: AppColors.primaryGreen,

    scaffoldBackgroundColor: AppColors.backgroundWhite,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textLight,
        fontSize: 14,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.borderColor,
        ),
      ),
    ),
  );
}