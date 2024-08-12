import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    surface: Color.fromARGB(255, 182, 200, 226),
    primary: Color.fromARGB(255, 226, 233, 243),
    secondary: Color.fromARGB(255, 111, 147, 195),
    tertiary: Color.fromARGB(255, 30, 48, 72),
    inversePrimary: Color.fromARGB(255, 24, 38, 58)
  ),
  hintColor: const Color.fromARGB(255, 147, 164, 186),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Color.fromARGB(255, 226, 233, 243),
    backgroundColor: Color.fromARGB(255, 66, 106, 158)
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromARGB(255, 140, 169, 207)
  )
);