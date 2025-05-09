import 'package:flutter/material.dart';

final ThemeData theme = ThemeData(
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0.0,
    surfaceTintColor: Colors.black,
  ),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    brightness: Brightness.dark,
    background: Colors.black,
    onBackground: Colors.white,
    surfaceTint: Colors.black12,
    primary: Colors.white,
    onPrimary: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      foregroundColor: WidgetStateProperty.all(Colors.black),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    indicatorColor: Colors.transparent,
    height: 60,
    backgroundColor: Colors.black,
    iconTheme: WidgetStateProperty.all<IconThemeData>(
      IconThemeData(
        color: Colors.white,
        size: 30,
      ),
    ),
  ),
);
