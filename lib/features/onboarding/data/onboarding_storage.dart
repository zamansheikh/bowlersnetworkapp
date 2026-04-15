import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';

@lazySingleton
class OnboardingStorage {
  OnboardingStorage(this._storage);

  final LocalStorageService _storage;

  Future<bool> hasSeenOnboarding() =>
      _storage.getBool(StorageKeys.onboardingSeen, defaultValue: false);

  Future<void> markSeen() =>
      _storage.setBool(StorageKeys.onboardingSeen, true);
}
