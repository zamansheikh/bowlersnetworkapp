import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/profile_models.dart';

@lazySingleton
class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource(this._dio);

  Future<ProfileModel> getMyProfile() async {
    final response = await _dio.get(Endpoints.profile);
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProfileCompletionModel> getCompletion() async {
    final response = await _dio.get(Endpoints.profileCompletion);
    return ProfileCompletionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProfileModel> getProfileByUsername(String username) async {
    final response = await _dio.get(Endpoints.profileByUsername(username));
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateGender({required String value, bool isPublic = true}) async {
    await _dio.post(Endpoints.profileGender, data: {'value': value, 'is_public': isPublic});
  }

  Future<void> updateBirthdate({required String dateOfBirth, bool isPublic = true}) async {
    await _dio.post(Endpoints.profileBirthdate, data: {'date_of_birth': dateOfBirth, 'is_public': isPublic});
  }

  Future<void> updateAddress({
    required String address, required String zipCode,
    required double latitude, required double longitude,
    bool isPublic = true,
  }) async {
    await _dio.post(Endpoints.profileAddress, data: {
      'address': address, 'zip_code': zipCode,
      'latitude': latitude, 'longitude': longitude, 'is_public': isPublic,
    });
  }

  Future<void> updateHomeCenter({required int centerId, String centerName = '', bool isPublic = true}) async {
    await _dio.post(Endpoints.profileHomeCenter, data: {
      'center_id': centerId, 'center_name': centerName, 'is_public': isPublic,
    });
  }

  Future<void> updateBallHandlingStyle({String? handedness, String? ballCarry, String? grip, bool isPublic = true}) async {
    final data = <String, dynamic>{'is_public': isPublic};
    if (handedness != null) data['handedness'] = handedness;
    if (ballCarry != null) data['ball_carry'] = ballCarry;
    if (grip != null) data['grip'] = grip;
    await _dio.post(Endpoints.profileBallHandlingStyle, data: data);
  }

  Future<void> updateBio({required String content, bool isPublic = true}) async {
    await _dio.post(Endpoints.profileBio, data: {'content': content, 'is_public': isPublic});
  }

  Future<void> updateNickname({required String name, bool isPublic = true}) async {
    await _dio.post(Endpoints.profileNickname, data: {'name': name, 'is_public': isPublic});
  }

  Future<void> updateProfilePicture({required String url}) async {
    await _dio.post(Endpoints.profilePicture, data: {'url': url});
  }

  Future<void> updateCoverPicture({required String url}) async {
    await _dio.post(Endpoints.profileCoverPicture, data: {'url': url});
  }

  Future<List<CenterModel>> getCenters() async {
    final response = await _dio.get(Endpoints.centers);
    final list = response.data as List;
    return list.map((e) => CenterModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> toggleFollow(int userId) async {
    final response = await _dio.get(Endpoints.follow(userId));
    return response.data as Map<String, dynamic>;
  }
}
