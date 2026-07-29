import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';

/// Persists and broadcasts [ThemeMode] for light / dark (Aetheric Depth).
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_readInitial(_prefs)) {
    AppColors.applyBrightness(_brightnessFor(state));
  }

  final SharedPreferences _prefs;

  static ThemeMode _readInitial(SharedPreferences prefs) {
    final raw = prefs.getString(AppConstants.keyThemeMode);
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static Brightness _brightnessFor(ThemeMode mode) {
    if (mode == ThemeMode.dark) return Brightness.dark;
    if (mode == ThemeMode.light) return Brightness.light;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  bool get isDarkMode {
    final brightness = _brightnessFor(state);
    return brightness == Brightness.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    AppColors.applyBrightness(_brightnessFor(mode));
    await _prefs.setString(AppConstants.keyThemeMode, mode.name);
    emit(mode);
  }

  Future<void> setDarkMode(bool enabled) =>
      setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);

  void syncSystemBrightness(Brightness platformBrightness) {
    if (state != ThemeMode.system) return;
    AppColors.applyBrightness(platformBrightness);
    // Re-emit so listeners rebuild with updated AppColors getters.
    emit(ThemeMode.system);
  }
}
