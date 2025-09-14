class SendVerificationCodeResponse {
  final String message;

  const SendVerificationCodeResponse({required this.message});

  factory SendVerificationCodeResponse.fromJson(Map<String, dynamic> json) =>
      SendVerificationCodeResponse(message: json['message'] as String);

  Map<String, dynamic> toJson() => {'message': message};
}
