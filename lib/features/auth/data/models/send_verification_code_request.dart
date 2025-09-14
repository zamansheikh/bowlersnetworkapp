class SendVerificationCodeRequest {
  final String email;

  const SendVerificationCodeRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}
