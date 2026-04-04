import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  final String credential;
  final String password;

  const LoginRequestModel({
    required this.credential,
    required this.password,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}
