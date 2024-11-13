import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mbosswater/core/styles/app_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      displayLarge: AppStyle.heading1,
      // Thay thế cho headline1
      displayMedium: AppStyle.heading2,
      // Thay thế cho headline2
      bodyLarge: AppStyle.bodyText,
      // Thay thế cho bodyText1
      bodyMedium:
          AppStyle.bodyText.copyWith(fontSize: 14, color: Colors.black54),
      // Thay thế cho bodyText2
      labelSmall: AppStyle.caption, // Thay thế cho caption
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
