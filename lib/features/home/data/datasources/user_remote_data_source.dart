import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUser(String id);
}

@LazySingleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<List<UserModel>> getUsers() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    return [
      const UserModel(id: '1', name: 'John Doe', email: 'john@example.com'),
      const UserModel(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
    ];
  }

  @override
  Future<UserModel> getUser(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return const UserModel(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
    );
  }
}
