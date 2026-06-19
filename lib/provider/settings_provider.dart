import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/recipe_utils.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SettingsState {
  final ThemeMode themeMode;
  final Color seedColor;
  final Locale locale;
  final int decimalDigits;
  final double fontSizeScale;
  final bool hapticFeedbackEnabled;
  final bool useMaterial3;
  final String iconStyle;
  final bool numberColorsEnabled;
  final bool animationsEnabled;
  final String scrollBehavior;
  final bool leftHandedMode;
  final bool highContrastText;
  final String fontFamily;
  final bool showNavBarLabels;
  final String defaultMassUnit;
  final String defaultVolumeUnit;
  final String currencySymbol;

  SettingsState({
    required this.themeMode,
    required this.seedColor,
    required this.locale,
    required this.decimalDigits,
    required this.fontSizeScale,
    required this.hapticFeedbackEnabled,
    required this.useMaterial3,
    required this.iconStyle,
    required this.numberColorsEnabled,
    required this.animationsEnabled,
    required this.scrollBehavior,
    required this.leftHandedMode,
    required this.highContrastText,
    required this.fontFamily,
    required this.showNavBarLabels,
    required this.defaultMassUnit,
    required this.defaultVolumeUnit,
    required this.currencySymbol,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    Locale? locale,
    int? decimalDigits,
    double? fontSizeScale,
    bool? hapticFeedbackEnabled,
    bool? useMaterial3,
    String? iconStyle,
    bool? numberColorsEnabled,
    bool? animationsEnabled,
    String? scrollBehavior,
    bool? leftHandedMode,
    bool? highContrastText,
    String? fontFamily,
    bool? showNavBarLabels,
    String? defaultMassUnit,
    String? defaultVolumeUnit,
    String? currencySymbol,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      locale: locale ?? this.locale,
      decimalDigits: decimalDigits ?? this.decimalDigits,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      iconStyle: iconStyle ?? this.iconStyle,
      numberColorsEnabled: numberColorsEnabled ?? this.numberColorsEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      scrollBehavior: scrollBehavior ?? this.scrollBehavior,
      leftHandedMode: leftHandedMode ?? this.leftHandedMode,
      highContrastText: highContrastText ?? this.highContrastText,
      fontFamily: fontFamily ?? this.fontFamily,
      showNavBarLabels: showNavBarLabels ?? this.showNavBarLabels,
      defaultMassUnit: defaultMassUnit ?? this.defaultMassUnit,
      defaultVolumeUnit: defaultVolumeUnit ?? this.defaultVolumeUnit,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  SettingsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);

    final themeIndex = _prefs.getInt('themeMode') ?? 0;
    final themeMode = ThemeMode.values[themeIndex];

    final seedColorValue = _prefs.getInt('seedColor');
    final seedColor = seedColorValue != null ? Color(seedColorValue) : Colors.deepPurple;

    final lang = _prefs.getString('locale') ?? 'es';
    final locale = Locale(lang);

    final decimalDigits = _prefs.getInt('decimalDigits') ?? 2;
    RecipeUtils.defaultDecimalDigits = decimalDigits;

    final fontSizeScale = _prefs.getDouble('fontSizeScale') ?? 1.0;
    final hapticFeedbackEnabled = _prefs.getBool('hapticFeedbackEnabled') ?? true;
    final useMaterial3 = _prefs.getBool('useMaterial3') ?? true;
    final iconStyle = _prefs.getString('iconStyle') ?? 'outlined';
    final numberColorsEnabled = _prefs.getBool('numberColorsEnabled') ?? true;
    final animationsEnabled = _prefs.getBool('animationsEnabled') ?? true;
    final scrollBehavior = _prefs.getString('scrollBehavior') ?? 'default';
    final leftHandedMode = _prefs.getBool('leftHandedMode') ?? false;
    final highContrastText = _prefs.getBool('highContrastText') ?? false;
    final fontFamily = _prefs.getString('fontFamily') ?? 'system';
    final showNavBarLabels = _prefs.getBool('showNavBarLabels') ?? true;
    final defaultMassUnit = _prefs.getString('defaultMassUnit') ?? 'g';
    final defaultVolumeUnit = _prefs.getString('defaultVolumeUnit') ?? 'ml';
    final currencySymbol = _prefs.getString('currencySymbol') ?? r'$';

    return SettingsState(
      themeMode: themeMode,
      seedColor: seedColor,
      locale: locale,
      decimalDigits: decimalDigits,
      fontSizeScale: fontSizeScale,
      hapticFeedbackEnabled: hapticFeedbackEnabled,
      useMaterial3: useMaterial3,
      iconStyle: iconStyle,
      numberColorsEnabled: numberColorsEnabled,
      animationsEnabled: animationsEnabled,
      scrollBehavior: scrollBehavior,
      leftHandedMode: leftHandedMode,
      highContrastText: highContrastText,
      fontFamily: fontFamily,
      showNavBarLabels: showNavBarLabels,
      defaultMassUnit: defaultMassUnit,
      defaultVolumeUnit: defaultVolumeUnit,
      currencySymbol: currencySymbol,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setSeedColor(Color color) {
    _prefs.setInt('seedColor', color.toARGB32());
    state = state.copyWith(seedColor: color);
  }

  void setLocale(Locale newLocale) {
    _prefs.setString('locale', newLocale.languageCode);
    state = state.copyWith(locale: newLocale);
  }

  void setDecimalDigits(int digits) {
    RecipeUtils.defaultDecimalDigits = digits;
    _prefs.setInt('decimalDigits', digits);
    state = state.copyWith(decimalDigits: digits);
  }

  void setFontSizeScale(double scale) {
    _prefs.setDouble('fontSizeScale', scale);
    state = state.copyWith(fontSizeScale: scale);
  }

  void setHapticFeedbackEnabled(bool enabled) {
    _prefs.setBool('hapticFeedbackEnabled', enabled);
    state = state.copyWith(hapticFeedbackEnabled: enabled);
  }

  void setUseMaterial3(bool enabled) {
    _prefs.setBool('useMaterial3', enabled);
    state = state.copyWith(useMaterial3: enabled);
  }

  void setIconStyle(String style) {
    _prefs.setString('iconStyle', style);
    state = state.copyWith(iconStyle: style);
  }

  void setNumberColorsEnabled(bool enabled) {
    _prefs.setBool('numberColorsEnabled', enabled);
    state = state.copyWith(numberColorsEnabled: enabled);
  }

  void setAnimationsEnabled(bool enabled) {
    _prefs.setBool('animationsEnabled', enabled);
    state = state.copyWith(animationsEnabled: enabled);
  }

  void setScrollBehavior(String behavior) {
    _prefs.setString('scrollBehavior', behavior);
    state = state.copyWith(scrollBehavior: behavior);
  }

  void setLeftHandedMode(bool enabled) {
    _prefs.setBool('leftHandedMode', enabled);
    state = state.copyWith(leftHandedMode: enabled);
  }

  void setHighContrastText(bool enabled) {
    _prefs.setBool('highContrastText', enabled);
    state = state.copyWith(highContrastText: enabled);
  }

  void setFontFamily(String family) {
    _prefs.setString('fontFamily', family);
    state = state.copyWith(fontFamily: family);
  }

  void setShowNavBarLabels(bool enabled) {
    _prefs.setBool('showNavBarLabels', enabled);
    state = state.copyWith(showNavBarLabels: enabled);
  }

  void setDefaultMassUnit(String unit) {
    _prefs.setString('defaultMassUnit', unit);
    state = state.copyWith(defaultMassUnit: unit);
  }

  void setDefaultVolumeUnit(String unit) {
    _prefs.setString('defaultVolumeUnit', unit);
    state = state.copyWith(defaultVolumeUnit: unit);
  }

  void setCurrencySymbol(String symbol) {
    _prefs.setString('currencySymbol', symbol);
    state = state.copyWith(currencySymbol: symbol);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
