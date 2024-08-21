import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    surface: Color.fromARGB(255, 239, 247, 242),
    primary: Color.fromARGB(255, 34, 85, 52),
    secondary: Color.fromARGB(255, 133, 193, 153),
    tertiary: Color.fromARGB(255, 210, 234, 221),
    inversePrimary: Color.fromARGB(255, 24, 58, 38)
  ),
  hintColor: const Color.fromARGB(255, 147, 164, 186),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Color.fromARGB(255, 239, 247, 242),
    backgroundColor: Color.fromARGB(255, 34, 85, 52)
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromARGB(255, 133, 193, 153)
  )
);
