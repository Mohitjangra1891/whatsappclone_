import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import 'AppColors.dart';
import 'CGColors.dart';

class AppThemeData {
  //
  AppThemeData._();

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: whiteColor,
    primaryColor: Colors.blue,
    primaryColorDark: Colors.white,
    // errorColor: Colors.red,
    hoverColor: Colors.white54,

    /// accentColor: Colors.blue, ---- changes to ( secondary: Colors.blue) in colorScheme
    dividerColor: viewLineColor,

    /// cursorColor: Colors.black  ,---  changes to textSelectionTheme: TextSelectionThemeData(
    ///       cursorColor:  Colors.black,
    ///     ),
    fontFamily: GoogleFonts.nunito().fontFamily,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        elevation: 1.0,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.black54,
      selectionHandleColor: kPrimaryColor,
      cursorColor: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      titleSpacing: 0.0,
      systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: appLayout_background,
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark),
      color: appLayout_background,
      iconTheme: IconThemeData(color: textPrimaryColor),
    ),
    colorScheme: const ColorScheme.light(
      secondary: Colors.blue,
      primary: kPrimaryColor,
      /*  primaryVariant: appColorPrimary,*/
    ),
    cardTheme: const CardTheme(color: Colors.white),
    iconTheme: const IconThemeData(color: textPrimaryColor),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: whiteColor),
    textTheme: TextTheme(
/*
      button: TextStyle(color: appColorPrimary),
*/
      headlineLarge: primaryTextStyle(color: whiteColor),
      headlineMedium: primaryTextStyle(color: whiteColor),
      headlineSmall: primaryTextStyle(color: whiteColor),
      labelLarge: TextStyle(color: Colors.white54),
      labelMedium: TextStyle(color: Colors.white54),
      labelSmall: TextStyle(color: Colors.white54),
      // headline6: TextStyle(color: textPrimaryColor),
      // subtitle2: TextStyle(color: textSecondaryColor),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ).copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
  }));

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: appBackgroundColorDark,
    highlightColor: appBackgroundColorDark,
    // errorColor: Color(0xFFCF6676),
    appBarTheme: const AppBarTheme(
        titleSpacing: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: appBackgroundColorDark,
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light),
        color: appBackgroundColorDark,
        iconTheme: IconThemeData(color: whiteColor)),
    primaryColor: color_primary_black,
    // accentColor: whiteColor,
    dividerColor: Color(0xFFDADADA).withOpacity(0.3),
    primaryColorDark: color_primary_black,
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.white70,
      selectionHandleColor: kPrimaryColor,
      cursorColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1.0,
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.black,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kDarkTextFieldBgColor,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    // set underline text field color same as kPrimaryColor
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
      ),
    ),

    /// cursorColor: Colors.white,
    hoverColor: Colors.black12,
    fontFamily: GoogleFonts.nunito().fontFamily,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: appBackgroundColorDark),
    primaryTextTheme: TextTheme(
      headlineLarge: primaryTextStyle(color: Colors.white),
      headlineMedium: primaryTextStyle(color: Colors.white),
      headlineSmall: primaryTextStyle(color: Colors.white),
      // headline6: primaryTextStyle(color: Colors.white),
      // overline: primaryTextStyle(color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      secondary: whiteColor,
      primary: appBackgroundColorDark,
      onPrimary: cardBackgroundBlackDark,
      onPrimaryFixedVariant: color_primary_black,
    ),
    cardTheme: CardTheme(color: cardBackgroundBlackDark),
    iconTheme: IconThemeData(color: whiteColor),
    textTheme: TextTheme(
      headlineLarge: primaryTextStyle(color: whiteColor),
      headlineMedium: primaryTextStyle(color: whiteColor),
      headlineSmall: primaryTextStyle(color: whiteColor),
      labelLarge: TextStyle(color: Colors.white54),
      labelMedium: TextStyle(color: Colors.white54),
      labelSmall: TextStyle(color: Colors.white54),
      // button: TextStyle(color: color_primary_black),
      // headline6: TextStyle(color: whiteColor),
      // subtitle2: TextStyle(color: Colors.white54),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ).copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
  }));
}
