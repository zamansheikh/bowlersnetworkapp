class VerifyEmailRequest {
  final String email;
  final String code;

  const VerifyEmailRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}
