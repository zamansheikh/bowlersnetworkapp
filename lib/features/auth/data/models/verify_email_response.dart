class VerifyEmailResponse {
  final bool success;
  final String? message;

  const VerifyEmailResponse({required this.success, this.message});

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) =>
      VerifyEmailResponse(
        success:
            json['success'] as bool? ?? true, // Default to true if not provided
        message: json['message'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    if (message != null) 'message': message,
  };
}
