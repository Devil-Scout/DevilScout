import 'package:flutter/material.dart';

const _textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 32.0,
  ),
  displayMedium: TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 28.0,
  ),
  displaySmall: TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24.0,
  ),
  bodyLarge: TextStyle(
    fontFamily: 'Work Sans',
    fontSize: 22.0,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Work Sans',
    fontSize: 18.0,
  ),
  bodySmall: TextStyle(
    fontFamily: 'Work Sans',
    fontSize: 16.0,
  ),
);

final lightTheme = ThemeData(
  textTheme: _textTheme,
);
