import 'package:flutter/material.dart';
import 'package:some_space/theme/theme_manager.dart';

ThemeManager themeManager = ThemeManager();

// Light Theme
ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  hintColor: Colors.green,
  // Add other theme properties here
);

// Dark Theme
ThemeData darkTheme = ThemeData(
  useMaterial3: true,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.green,
    onPrimary: Colors.orange,
    secondary: Colors.pink,
    onSecondary: Colors.cyan,
    error: Colors.red,
    onError: Colors.redAccent,
    background: Colors.black,
    onBackground: Colors.black38,
    surface: Colors.lime,
    onSurface: Colors.purple,
  ),
  // buttonTheme: ButtonThemeData(
  //   buttonColor: Colors.indigo,
  //   hoverColor: Colors.indigoAccent,
  // )
  //primarySwatch: Colors.teal,
  //hintColor: Colors.purple,
  // Add other theme properties here
);
