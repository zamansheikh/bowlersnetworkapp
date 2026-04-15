import 'package:json_annotation/json_annotation.dart';

part 'auth_dtos.g.dart';

/// POST /api/auth/verify-email
@JsonSerializable(createFactory: false)
class VerifyEmailRequest {
  const VerifyEmailRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class MessageResponse {
  const MessageResponse({required this.message});

  final String message;

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);
}

/// POST /api/auth/signup — payload is wrapped as `{signup_data, verification_code, referrer_username}`
@JsonSerializable(createFactory: false)
class SignupData {
  const SignupData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
    required this.dateOfBirth,
    this.isCoach,
    this.parentEmail,
  });

  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String username;
  final String password;
  @JsonKey(name: 'date_of_birth')
  final String dateOfBirth;
  @JsonKey(name: 'is_coach', includeIfNull: false)
  final bool? isCoach;
  @JsonKey(name: 'parent_email', includeIfNull: false)
  final String? parentEmail;

  Map<String, dynamic> toJson() => _$SignupDataToJson(this);
}

@JsonSerializable(createFactory: false)
class SignupRequest {
  const SignupRequest({
    required this.signupData,
    required this.verificationCode,
    this.referrerUsername,
  });

  @JsonKey(name: 'signup_data')
  final SignupData signupData;
  @JsonKey(name: 'verification_code')
  final String verificationCode;
  @JsonKey(name: 'referrer_username', includeIfNull: false)
  final String? referrerUsername;

  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}

/// POST /api/auth/signup/validate/registration — same shape as [SignupData]
/// minus the coach flag; backend returns 200 on success or
/// `{"errors": [...]}` on failure.
@JsonSerializable(createFactory: false)
class ValidateRegistrationRequest {
  const ValidateRegistrationRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
    required this.dateOfBirth,
    this.parentEmail,
  });

  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String username;
  final String password;
  @JsonKey(name: 'date_of_birth')
  final String dateOfBirth;
  @JsonKey(name: 'parent_email', includeIfNull: false)
  final String? parentEmail;

  Map<String, dynamic> toJson() => _$ValidateRegistrationRequestToJson(this);
}

/// POST /api/auth/login
@JsonSerializable(createFactory: false)
class LoginRequest {
  const LoginRequest({required this.credential, required this.password});

  final String credential;
  final String password;

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// Shared response shape for login + signup: `{token, requires_consent?}`.
@JsonSerializable(createToJson: false)
class AuthTokenResponse {
  const AuthTokenResponse({required this.token, this.requiresConsent = false});

  final String token;
  @JsonKey(name: 'requires_consent', defaultValue: false)
  final bool requiresConsent;

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenResponseFromJson(json);
}

/// POST /api/access/recovery/initiate/otp  &  initiate/magic-link
@JsonSerializable(createFactory: false)
class EmailRequest {
  const EmailRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => _$EmailRequestToJson(this);
}

/// POST /api/access/recovery/validate/otp
@JsonSerializable(createFactory: false)
class ValidateOtpRequest {
  const ValidateOtpRequest({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toJson() => _$ValidateOtpRequestToJson(this);
}

/// POST /api/access/recovery/validate/magic-key
@JsonSerializable(createFactory: false)
class ValidateMagicKeyRequest {
  const ValidateMagicKeyRequest({required this.magicKey});

  @JsonKey(name: 'magic_key')
  final String magicKey;

  Map<String, dynamic> toJson() => _$ValidateMagicKeyRequestToJson(this);
}

/// POST /api/access/recovery/reset-password
@JsonSerializable(createFactory: false)
class ResetPasswordRequest {
  const ResetPasswordRequest({required this.newPassword});

  @JsonKey(name: 'new_password')
  final String newPassword;

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}
