import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFB33636); // #B33636
  static const Color secondaryColor = Color(0xFF4F1315); // #4f1315
  static const Color accentColor = Color(0xFFEEC1A2); // #EEC1A2
  static const Color backgroundColor = Color(0xFFA0C8CD); //

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        fillColor: Colors.white,
      ),
      colorScheme: const ColorScheme(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(backgroundColor),
        foregroundColor: WidgetStatePropertyAll(Colors.black),
      )),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          iconSize: 30),
      //chnag ethe them of dropdown button
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(backgroundColor),
          surfaceTintColor: WidgetStatePropertyAll(Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      ),
      primaryTextTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      //inputDecorationTheme: InputDecorationTheme(),
    );
  }
}
