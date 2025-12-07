import 'package:flutter/material.dart';

class AppTheme{

  ///Basic app colors
  static final Color softLavender= Color(0xFFF3EDFF);
  static final Color lightLavender= Color(0xFFE6DBFF);
  static final Color classicLavender= Color(0xFFCDB7F6);
  static final Color mutedLavender= Color(0xFFB39DDB);
  static final Color deepLavender= Color(0xFF9179C7);
  static final Color midnightBlue= Color(0xFF0F172A);
  static final Color charcoalBlack= Color(0xFF1C1B22);
  static final Color offWhite = Color(0xFFFAF9FF);


  static final ThemeData lightTheme= ThemeData(
    useMaterial3: true,
    colorSchemeSeed: deepLavender,
    brightness: Brightness.light,
    scaffoldBackgroundColor: offWhite,
  );

  static final ThemeData darkTheme= ThemeData(
    useMaterial3: true,
    colorSchemeSeed: deepLavender,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: charcoalBlack,
  );
}