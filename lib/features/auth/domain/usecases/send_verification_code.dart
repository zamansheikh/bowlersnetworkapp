import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../../data/models/send_verification_code_request.dart';
import '../../data/models/send_verification_code_response.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendVerificationCode
    extends UseCase<SendVerificationCodeResponse, SendVerificationCodeRequest> {
  final AuthRepository repository;
  SendVerificationCode(this.repository);

  @override
  Future<Either<Failure, SendVerificationCodeResponse>> call(
    SendVerificationCodeRequest params,
  ) {
    return repository.sendVerificationCode(params);
  }
}
