import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/recipe_utils.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Color seedColor;
  final Locale locale;
  final int decimalDigits;

  SettingsState({
    required this.themeMode,
    required this.seedColor,
    required this.locale,
    required this.decimalDigits,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    Locale? locale,
    int? decimalDigits,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      locale: locale ?? this.locale,
      decimalDigits: decimalDigits ?? this.decimalDigits,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    RecipeUtils.defaultDecimalDigits = 2;
    return SettingsState(
      themeMode: ThemeMode.system,
      seedColor: Colors.deepPurple,
      locale: const Locale('es'),
      decimalDigits: 2,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
  }

  void setLocale(Locale newLocale) {
    state = state.copyWith(locale: newLocale);
  }

  void setDecimalDigits(int digits) {
    RecipeUtils.defaultDecimalDigits = digits;
    state = state.copyWith(decimalDigits: digits);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
