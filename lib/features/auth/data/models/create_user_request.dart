class CreateUserRequest {
  final BasicInfo basicInfo;
  final List<int> brandIDs;

  const CreateUserRequest({required this.basicInfo, required this.brandIDs});

  Map<String, dynamic> toJson() => {
    'basicInfo': basicInfo.toJson(),
    'brandIDs': brandIDs,
  };
}

class BasicInfo {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String birthDate;

  const BasicInfo({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'password': password,
    'birth_date': birthDate,
  };
}
