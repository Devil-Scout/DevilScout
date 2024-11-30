import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF3063FF);
const _onPrimaryColor = Colors.white;

const _secondaryColorLight = Color(0xFF83B9FC);
const _onSecondaryColorLight = Colors.black;
const _errorColorLight = Color(0xFFF44336);
const _onErrorColorLight = Colors.white;
const _surfaceColorLight = Colors.white;
const _onSurfaceColorLight = Colors.black;
const _outlineBorderColorLight = Color.fromARGB(25, 0, 0, 0);

const _displayFontFamily = 'Montserrat';
const _bodyFontFamily = 'Noto Sans';

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
    fontSize: 20.0,
  ),
  bodyLarge: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 16.0,
    height: 1.3,
  ),
  bodyMedium: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 14.0,
    height: 1.3,
  ),
  bodySmall: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 12.0,
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
        textStyle: WidgetStatePropertyAll(_textTheme.bodyLarge),
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
        minimumSize: const WidgetStatePropertyAll(Size.square(70.0)),
        alignment: Alignment.center,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(_textTheme.bodyLarge),
        backgroundColor: const WidgetStatePropertyAll(_primaryColor),
        foregroundColor: const WidgetStatePropertyAll(_onPrimaryColor),
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.7)),
          ),
        ),
        minimumSize: const WidgetStatePropertyAll(Size.square(70.0)),
        alignment: Alignment.center,
        elevation: const WidgetStatePropertyAll(0.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(_textTheme.bodyMedium!.copyWith(
          color: _primaryColor,
          decoration: TextDecoration.underline,
        )),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size(0.0, 0.0)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: _outlineBorderColorLight),
        borderRadius: BorderRadius.all(Radius.circular(10.7)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor),
        borderRadius: BorderRadius.all(Radius.circular(10.7)),
      ),
      labelStyle: _textTheme.bodyMedium,
    ),
    dividerTheme: const DividerThemeData(
      color: _outlineBorderColorLight,
      thickness: 1.5,
    ));
