import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../../data/models/create_user_request.dart';
import '../../data/models/create_user_response.dart';
import '../repositories/auth_repository.dart';

@injectable
class CreateUser extends UseCase<CreateUserResponse, CreateUserRequest> {
  final AuthRepository repository;
  CreateUser(this.repository);

  @override
  Future<Either<Failure, CreateUserResponse>> call(CreateUserRequest params) {
    return repository.createUser(params);
  }
}
