import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../../data/models/validate_signup_data_request.dart';
import '../../data/models/validate_signup_data_response.dart';
import '../repositories/auth_repository.dart';

@injectable
class ValidateSignupData
    extends UseCase<ValidateSignupDataResponse, ValidateSignupDataRequest> {
  final AuthRepository repository;
  ValidateSignupData(this.repository);

  @override
  Future<Either<Failure, ValidateSignupDataResponse>> call(
    ValidateSignupDataRequest params,
  ) {
    return repository.validateSignupData(params);
  }
}
