class ValidateSignupDataRequest {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;

  const ValidateSignupDataRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
    'password': password,
  };
}
