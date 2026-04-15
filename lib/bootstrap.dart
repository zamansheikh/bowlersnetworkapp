import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection.dart';
import 'core/localization/locale_cubit.dart';
import 'core/theme/theme_cubit.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  configureDependencies();

  // Hydrate persisted user preferences before first build so the splash
  // screen never flashes the wrong theme or locale.
  await Future.wait([
    getIt<LocaleCubit>().load(),
    getIt<ThemeCubit>().load(),
  ]);

  // Firebase is initialized later in Phase 1 once google-services.json is set.
}
