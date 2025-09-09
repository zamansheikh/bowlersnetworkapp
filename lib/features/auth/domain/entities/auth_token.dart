import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;

  const AuthToken({required this.accessToken});

  @override
  List<Object?> get props => [accessToken];

  bool get isValid => accessToken.isNotEmpty;
}
