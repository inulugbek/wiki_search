import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class DefaultTheme {
  static const _primaryColor = Colors.white;
  static const _accentColor = Colors.grey;

  static final ThemeData themeData = ThemeData(
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: _appBarTheme,
    bottomAppBarTheme: _bottomAppBarTheme,
    textTheme: _textTheme,
    inputDecorationTheme: _inputDecorationTheme,
    buttonTheme: _buttonThemeData,
    primaryColor: _primaryColor,
    accentColor: _accentColor,
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    brightness: Brightness.light,
    centerTitle: true,
    elevation: 0,
    textTheme: TextTheme(),
  );

  static const BottomAppBarTheme _bottomAppBarTheme = BottomAppBarTheme();

  static const TextTheme _textTheme = TextTheme(
    headline4: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    headline5: TextStyle(),
    headline6: TextStyle(),
    subtitle1: TextStyle(),
    bodyText1: TextStyle(),
    bodyText2: TextStyle(),
  );

  static const InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: _primaryColor,
  );

  static const ButtonThemeData _buttonThemeData = ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    textTheme: ButtonTextTheme.accent,
  );
}
