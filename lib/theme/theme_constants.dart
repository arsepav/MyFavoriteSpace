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
  brightness: Brightness.dark,
  primarySwatch: Colors.teal,
  hintColor: Colors.purple,
  // Add other theme properties here
);