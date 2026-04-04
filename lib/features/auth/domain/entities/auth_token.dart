import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String token;
  final bool requiresConsent;

  const AuthToken({
    required this.token,
    this.requiresConsent = false,
  });

  @override
  List<Object?> get props => [token, requiresConsent];
}
