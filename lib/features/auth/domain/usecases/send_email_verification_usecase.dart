import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SendEmailVerificationUseCase implements UseCase<Unit, String> {
  const SendEmailVerificationUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.sendEmailVerification(email);
}
