import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/games/domain/services/pin_settings_service.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
  if (!getIt.isRegistered<PinSettingsService>()) {
    getIt.registerLazySingleton<PinSettingsService>(
      () => PinSettingsService(getIt<SharedPreferences>()),
    );
  }
  await getIt.allReady();
}

Future<void> resetDependencies() async {
  await getIt.reset();
  await configureDependencies();
}
