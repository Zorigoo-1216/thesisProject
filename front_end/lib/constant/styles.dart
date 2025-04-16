import 'package:flutter/material.dart';

/// 🎨 Өнгөний тохиргоо
class AppColors {
  static const Color primary = Color(0xFF636AE8);
  static const Color white = Colors.white;
  static const Color background = Colors.white;
  static const Color text = Colors.black;
  static const Color subtitle = Colors.black54;
  static const Color border = Color(0xFFBDBDBD);
  static const Color stateBackground = Color(0xFFF2F2FD);
  static const Color iconColor = Color(0xFF636AE8);
  static const Color tagColor = Color.fromARGB(255, 144, 148, 235);
}

/// 🅰 Фонтын тохиргоо
class AppFonts {
  static const String mainFont = 'Roboto';
  static const String logoFont = 'Archivo';
}

/// 🔠 Текстийн стилийн тохиргоо
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: AppFonts.mainFont,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.text,
    fontFamily: AppFonts.mainFont,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 12,
    color: AppColors.subtitle,
    fontFamily: AppFonts.mainFont,
  );

  static const TextStyle whiteButton = TextStyle(
    fontSize: 16,
    color: AppColors.white,
    fontFamily: AppFonts.mainFont,
  );

  static const TextStyle outlinedButton = TextStyle(
    fontSize: 16,
    color: AppColors.primary,
    fontFamily: AppFonts.mainFont,
  );
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: AppFonts.mainFont,
  );
}

/// 📐 Хэмжээс, зай, радиус
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const double radius = 10;
  static const double cardElevation = 2;
  static const double avatarSize = 40;
}

/// 🌈 App Theme (хүсвэл ашиглах боломжтой)
class AppTheme {
  static ThemeData get light => ThemeData(
    fontFamily: AppFonts.mainFont,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      bodyMedium: AppTextStyles.body,
      titleLarge: AppTextStyles.heading,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        textStyle: AppTextStyles.whiteButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        textStyle: AppTextStyles.outlinedButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
