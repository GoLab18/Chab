import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Color.fromARGB(255, 18, 29, 23),
    primary: Color.fromARGB(255, 38, 94, 58),
    secondary: Color.fromARGB(255, 72, 115, 85),
    tertiary: Color.fromARGB(255, 108, 158, 124),
    inversePrimary: Color.fromARGB(255, 210, 234, 221)
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Color.fromARGB(255, 210, 234, 221),
    backgroundColor: Color.fromARGB(255, 38, 94, 58)
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromARGB(255, 38, 94, 58)
  )
);
