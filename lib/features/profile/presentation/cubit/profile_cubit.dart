import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../../home/data/models/feed_post.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final Dio _dio;

  ProfileCubit(this._dio) : super(ProfileInitial());

  Future<void> loadUserPosts() async {
    emit(ProfileLoaded(isLoadingPosts: true));

    try {
      final response = await _dio.get('/api/user/posts');

      if (response.data is List) {
        final posts = (response.data as List<dynamic>)
            .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
            .toList();
        
        emit(ProfileLoaded(posts: posts, isLoadingPosts: false));
      } else {
        throw Exception('Invalid response format: expected List');
      }
    } catch (e) {
      emit(ProfileLoaded(
        posts: [],
        isLoadingPosts: false,
        postsError: 'Failed to load posts: $e',
      ));
    }
  }

  Future<void> refreshPosts() async {
    await loadUserPosts();
  }
}