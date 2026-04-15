import 'package:equatable/equatable.dart';

/// A live authenticated session held by the app. Does not include profile
/// data — that's fetched lazily by ProfileBloc.
class AuthSession extends Equatable {
  const AuthSession({
    required this.token,
    this.userId,
    this.requiresConsent = false,
  });

  final String token;
  final int? userId;
  final bool requiresConsent;

  AuthSession copyWith({String? token, int? userId, bool? requiresConsent}) {
    return AuthSession(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      requiresConsent: requiresConsent ?? this.requiresConsent,
    );
  }

  @override
  List<Object?> get props => [token, userId, requiresConsent];
}
