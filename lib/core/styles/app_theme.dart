import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      displayLarge: AppStyle.heading1,
      displayMedium: AppStyle.heading2,
      bodyLarge: AppStyle.bodyText,
      bodyMedium:
          AppStyle.bodyText.copyWith(fontSize: 14, color: Colors.black54),
      labelSmall: AppStyle.caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: AppStyle.heading2.copyWith(
        color: Colors.black87,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
