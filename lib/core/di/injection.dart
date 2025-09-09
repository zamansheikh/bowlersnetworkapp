import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import all the modules and classes that need to be registered
import '../network/network_module.dart';
import '../network/network_info.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/domain/usecases/get_users.dart';
import '../../features/home/data/repositories/user_repository_impl.dart';
import '../../features/home/data/datasources/user_remote_data_source.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

void resetDependencies() {
  getIt.reset();
}
