import '../../domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  const AuthTokenModel({required super.accessToken});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      AuthTokenModel(accessToken: json['access_token'] as String? ?? '');

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
      };
}
