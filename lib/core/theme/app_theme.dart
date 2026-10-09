import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Inter';

  static const Color _lightBackground = AppColors.lightBackground;
  static const Color _lightSurface = AppColors.lightBackground;
  static const Color _lightText = AppColors.lightText;
  static const Color _lightMuted = Color(0xFF6B6F55);

  static const Color _darkBackground = AppColors.darkBackground;
  static const Color _darkSurface = Color(0xFF22281B);
  static const Color _darkText = AppColors.darkText;
  static const Color _darkMuted = Color(0xFF9A9E84);

  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: _lightBackground,
    surface: _lightSurface,
    text: _lightText,
    muted: _lightMuted,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: _darkBackground,
    surface: _darkSurface,
    text: _darkText,
    muted: _darkMuted,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color text,
    required Color muted,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: text,
      onPrimary: background,
      secondary: text,
      onSecondary: background,
      error: const Color(0xFF8B2E1F),
      onError: background,
      surface: surface,
      onSurface: text,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: text.withValues(alpha: 0.08),
      splashFactory: InkSparkle.splashFactory,
      fontFamily: _fontFamily,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: text,
        displayColor: text,
        fontFamily: _fontFamily,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: text, size: 22),
        actionsIconTheme: IconThemeData(color: text, size: 22),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: text,
        unselectedItemColor: muted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: text,
        foregroundColor: background,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),
      iconTheme: IconThemeData(color: text, size: 22),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: muted, fontFamily: _fontFamily),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: text.withValues(alpha: 0.4),
            width: 1.4,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? background : muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? text
              : text.withValues(alpha: 0.18),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: DividerThemeData(
        color: text.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = switch (prefs.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
