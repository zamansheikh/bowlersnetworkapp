import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../../data/models/verify_email_request.dart';
import '../../data/models/verify_email_response.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyEmail extends UseCase<VerifyEmailResponse, VerifyEmailRequest> {
  final AuthRepository repository;
  VerifyEmail(this.repository);

  @override
  Future<Either<Failure, VerifyEmailResponse>> call(VerifyEmailRequest params) {
    return repository.verifyEmail(params);
  }
}
