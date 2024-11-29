import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF3063FF);
const _onPrimaryColor = Colors.white;

const _secondaryColorLight = Color(0xFF83B9FC);
const _onSecondaryColorLight = Colors.black;
const _errorColorLight = Color(0xFFF44336);
const _onErrorColorLight = Colors.white;
const _surfaceColorLight = Colors.white;
const _onSurfaceColorLight = Colors.black;
const _outlineBorderColorLight = Color.fromARGB(20, 0, 0, 0);

const _displayFontFamily = 'Montserrat';
const _bodyFontFamily = 'Work Sans';

const _textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 32.0,
  ),
  displayMedium: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 28.0,
  ),
  displaySmall: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 24.0,
  ),
  bodyLarge: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 22.0,
    height: 1.3,
  ),
  bodyMedium: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 18.0,
    height: 1.3,
  ),
  bodySmall: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 16.0,
    height: 1.3,
  ),
);

final ThemeData lightTheme = ThemeData(
  textTheme: _textTheme,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: _primaryColor,
    onPrimary: _onPrimaryColor,
    secondary: _secondaryColorLight,
    onSecondary: _onSecondaryColorLight,
    error: _errorColorLight,
    onError: _onErrorColorLight,
    surface: _surfaceColorLight,
    onSurface: _onSurfaceColorLight,
    surfaceTint: Colors.transparent,
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStatePropertyAll(_textTheme.bodyMedium),
      backgroundColor: const WidgetStatePropertyAll(_surfaceColorLight),
      foregroundColor: const WidgetStatePropertyAll(_onSurfaceColorLight),
      side: const WidgetStatePropertyAll(
        BorderSide(
          color: _outlineBorderColorLight,
          width: 1.07,
        ),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.7)),
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(70.0)),
      alignment: Alignment.center,
    ),
  ),
);
