import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../constants/app_constants.dart';
import '../storage/local_storage_service.dart';

/// Drives the active [ThemeMode] (system / light / dark) and persists choice.
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(ThemeMode.system);

  final LocalStorageService _storage;

  Future<void> load() async {
    final saved = await _storage.getString(StorageKeys.themeMode);
    emit(_fromString(saved));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state) return;
    await _storage.setString(StorageKeys.themeMode, _toString(mode));
    emit(mode);
  }

  static ThemeMode _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
