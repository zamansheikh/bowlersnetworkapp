class ValidateSignupDataResponse {
  final bool isValid;
  final List<String>? errors;

  const ValidateSignupDataResponse({required this.isValid, this.errors});

  factory ValidateSignupDataResponse.fromJson(Map<String, dynamic> json) =>
      ValidateSignupDataResponse(
        isValid: json['isValid'] as bool,
        errors: json['errors'] != null
            ? (json['errors'] as List<dynamic>).cast<String>()
            : null,
      );

  Map<String, dynamic> toJson() => {
    'isValid': isValid,
    if (errors != null) 'errors': errors,
  };
}
