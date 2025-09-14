class CreateUserResponse {
  final bool success;
  final String? message;
  final int? userId;

  const CreateUserResponse({required this.success, this.message, this.userId});

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) =>
      CreateUserResponse(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String?,
        userId: json['user_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    if (message != null) 'message': message,
    if (userId != null) 'user_id': userId,
  };
}
