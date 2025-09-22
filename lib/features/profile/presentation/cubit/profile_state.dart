part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final List<FeedPost>? posts;
  final bool isLoadingPosts;
  final String? postsError;

  ProfileLoaded({this.posts, this.isLoadingPosts = false, this.postsError});

  ProfileLoaded copyWith({
    List<FeedPost>? posts,
    bool? isLoadingPosts,
    String? postsError,
  }) {
    return ProfileLoaded(
      posts: posts ?? this.posts,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      postsError: postsError ?? this.postsError,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
