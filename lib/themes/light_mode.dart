import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    surface: Color.fromARGB(255, 182, 229, 199),
    primary: Color.fromARGB(255, 34, 85, 52),
    secondary: Color.fromARGB(255, 122, 195, 146),
    tertiary: Color.fromARGB(255, 99, 157, 122),
    inversePrimary: Color.fromARGB(255, 24, 58, 38),
    error: Color.fromARGB(255, 209, 53, 42)
  ),
  hintColor: const Color.fromARGB(255, 89, 115, 99),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Color.fromARGB(255, 239, 247, 242),
    backgroundColor: Color.fromARGB(255, 34, 85, 52)
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromARGB(255, 133, 193, 153)
  )
);
