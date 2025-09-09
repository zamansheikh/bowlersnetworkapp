import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../../../home/domain/entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetProfile extends UseCase<User, NoParams> {
  final AuthRepository repository;
  GetProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getProfile();
  }
}
