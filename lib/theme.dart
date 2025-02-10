import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF3063FF);
const _onPrimaryColor = Colors.white;

const _secondaryColorLight = Color(0xFF83B9FC);
const _onSecondaryColorLight = Colors.black;
const _errorColorLight = Color(0xFFF44336);
const _onErrorColorLight = Colors.white;
const _surfaceColorLight = Colors.white;
const _onSurfaceColorLight = Colors.black;
var _onSurfaceColorLightVariant = Colors.grey[500];
const _outlineBorderColorLight = Color.fromARGB(25, 0, 0, 0);

const _displayFontFamily = 'Montserrat';
const _bodyFontFamily = 'Noto Sans';

const _textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 32,
  ),
  displayMedium: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 28,
  ),
  displaySmall: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 24,
  ),
  titleLarge: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 22,
  ),
  titleMedium: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 20,
  ),
  titleSmall: TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 16,
  ),
  labelLarge: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 18,
  ),
  labelMedium: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 14,
  ),
  labelSmall: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 12,
  ),
  bodyLarge: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 16,
    height: 1.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 14,
    height: 1.5,
  ),
  bodySmall: TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 12,
    height: 1.5,
  ),
);

final ThemeData lightTheme = ThemeData(
  textTheme: _textTheme,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: _primaryColor,
    onPrimary: _onPrimaryColor,
    secondary: _secondaryColorLight,
    onSecondary: _onSecondaryColorLight,
    error: _errorColorLight,
    onError: _onErrorColorLight,
    surface: _surfaceColorLight,
    onSurface: _onSurfaceColorLight,
    onSurfaceVariant: _onSurfaceColorLightVariant,
    surfaceContainer: Colors.grey[200],
    surfaceTint: Colors.transparent,
  ),
  appBarTheme: AppBarTheme(
    color: _surfaceColorLight,
    elevation: 0,
    iconTheme: const IconThemeData(color: _onSurfaceColorLight),
    titleTextStyle: _textTheme.displaySmall!.copyWith(
      color: _onSurfaceColorLight,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 70,
    elevation: 4,
    backgroundColor: _surfaceColorLight,
    shadowColor: _onSurfaceColorLight.withValues(alpha: 0.1),
    indicatorColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? _textTheme.bodyMedium?.copyWith(
              color: _primaryColor,
              fontWeight: FontWeight.bold,
            )
          : _textTheme.bodyMedium,
    ),
    iconTheme: const WidgetStateProperty.fromMap({
      WidgetState.selected: IconThemeData(color: _primaryColor),
    }),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      textStyle: _textTheme.bodyLarge,
      backgroundColor: _surfaceColorLight,
      foregroundColor: _onSurfaceColorLight,
      iconColor: _onSurfaceColorLight,
      iconSize: 22,
      side: const BorderSide(
        color: _outlineBorderColorLight,
        width: 1.07,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.7)),
      ),
      minimumSize: const Size.square(70),
      alignment: Alignment.center,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: _textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: _primaryColor,
      foregroundColor: _onPrimaryColor,
      overlayColor: _secondaryColorLight.withValues(alpha: 0.1),
      iconColor: _onPrimaryColor,
      iconSize: 28,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.7)),
      ),
      minimumSize: const Size.square(70),
      alignment: Alignment.center,
      elevation: 0,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: _textTheme.bodyMedium!.copyWith(
        color: _primaryColor,
        decoration: TextDecoration.underline,
      ),
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      overlayColor: Colors.transparent,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
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
  ),
);
