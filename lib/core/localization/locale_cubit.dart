import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../constants/app_constants.dart';
import '../storage/local_storage_service.dart';
import 'app_locale.dart';

/// Drives the active [AppLocale] and persists the user's choice.
///
/// Changing the locale here causes [MaterialApp.router] to rebuild with a new
/// `locale` argument, which flushes the [AppLocalizations] delegate.
@lazySingleton
class LocaleCubit extends Cubit<AppLocale> {
  LocaleCubit(this._storage) : super(AppLocale.en);

  final LocalStorageService _storage;

  /// Load the saved locale (if any) on app start.
  Future<void> load() async {
    final saved = await _storage.getString(StorageKeys.locale);
    emit(AppLocale.fromCode(saved));
  }

  Future<void> setLocale(AppLocale locale) async {
    if (locale == state) return;
    await _storage.setString(StorageKeys.locale, locale.code);
    emit(locale);
  }
}
