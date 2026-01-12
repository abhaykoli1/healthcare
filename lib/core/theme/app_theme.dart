import 'package:flutter/material.dart';

class AppTheme {
  // 🔵 Core Brand Colors (Swap-style)
  static const primary = Color(0xffa0c149);
  static const primarySoft = Color(0xffEEF2FF);
  static const secondary = Color(0xff1d2356);

  static const bg = Color(0xffF3F5FB);
  static const surface = Colors.white;

  static const danger = Color(0xffE53935);
  static const success = Color(0xff2E7D32);
  static const textPrimary = Color(0xff111827);
  static const textSecondary = Color(0xff6B7280);

  // 🌞 LIGHT THEME (CRYPTO / SWAP STYLE)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    primaryColor: primary,

    /// 🧭 APP BAR (minimal, floating)
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),

    /// 🃏 CARD THEME (MOST IMPORTANT)
    // cardTheme: CardTheme(
    //   color: surface,
    //   elevation: 8,
    //   shadowColor: Colors.black.withOpacity(0.08),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    //   margin: const EdgeInsets.symmetric(vertical: 6),
    // ),

    /// ✍️ TEXT THEME
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
      bodySmall: TextStyle(fontSize: 12, color: textSecondary),
    ),

    /// 📝 INPUT FIELDS (swap-like soft fields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primarySoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textSecondary),
    ),

    /// 🔘 BUTTONS (Primary CTA like "Slide to Swap")
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: primary.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    ),

    /// 🟢 CHIP / STATUS TAGS
    chipTheme: ChipThemeData(
      backgroundColor: primarySoft,
      selectedColor: primary.withOpacity(0.15),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: primary),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    /// 🎯 ICON THEME
    iconTheme: const IconThemeData(color: primary, size: 22),

    /// 📊 DIVIDER
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 24,
    ),
  );
}
