import 'package:flutter/material.dart';

/// Colours of the app: near-black surfaces with the Chatify blue as the accent.
class AppColors {
  static const Color primary = Color(0xFF0A5BD9);
  // Start of the gradient on the user's own message bubbles
  static const Color primaryBright = Color(0xFF1A7CF0);
  // Readable blue for links and icons on the dark background
  static const Color primaryLight = Color(0xFF3D9BFF);
  static const Color primarySoft = Color(0xFF14264B);
  static const Color primaryDisabled = Color(0xFF123A7D);

  static const Color background = Color(0xFF0E0E12);
  static const Color surface = Color(0xFF1E1D25);
  // Incoming message bubbles and anything that sits on a surface
  static const Color surfaceHigh = Color(0xFF2F2D3D);
  static const Color border = Color(0xFF2B2A35);

  static const Color text = Color(0xFFF4F4F7);
  static const Color muted = Color(0xFFA5A3B3);
  static const Color hint = Color(0xFF777585);
  static const Color onBubble = Color(0xCCFFFFFF);

  static const Color online = Color(0xFF34C768);
  static const Color offline = Color(0xFF5D5B6B);
  static const Color danger = Color(0xFFFF6B6B);
}

class AppTheme {
  static const String fontFamily = 'IBMPlexSansArabic';
  static const double radius = 16;
  static const double pagePadding = 20;

  // Dark Theme
  static final ThemeData darkTheme = _buildDarkTheme();

  static ThemeData _buildDarkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        onSurfaceVariant: AppColors.muted,
        outline: AppColors.border,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      primaryColor: AppColors.primary,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      iconTheme: const IconThemeData(color: AppColors.text),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryLight,
        selectionColor: AppColors.primaryDisabled,
        selectionHandleColor: AppColors.primaryLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 15),
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12.5),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primaryLight, width: 1.5),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryDisabled,
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size(54, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primarySoft,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.text
                : AppColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryLight
                : AppColors.muted,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius + 4),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.5,
          height: 1.6,
          color: AppColors.muted,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: AppColors.text,
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
