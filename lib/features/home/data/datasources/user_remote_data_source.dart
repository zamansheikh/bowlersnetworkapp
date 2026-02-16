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
    return [];
  }

  @override
  Future<UserModel> getUser(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return  UserModel(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      username: 'johndoe',
      firstName: 'John',
      lastName: 'Doe',
      profilePictureUrl: 'https://example.com/profile.jpg',
      introVideoUrl: 'https://example.com/intro.mp4',
      coverPhotoUrl: 'https://example.com/cover.jpg',
      xp: 1000,
      level: 5,
      cardTheme: 'default',
      isPro: false,
      sponsors: [],
      followerCount: 100,
      stats: StatsModel(
        id: 1,
        userId: 1,
        averageScore: 200,
        highGame: 300,
        highSeries: 800,
        experience: 5,
      ), // Replace with appropriate default values if needed
      favoriteBrands: [],
      isComplete: true, followingCount: 0,
    );
  }
}
