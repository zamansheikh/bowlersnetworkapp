part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileCompletionRefreshed extends ProfileEvent {
  const ProfileCompletionRefreshed();
}

class ProfileCleared extends ProfileEvent {
  const ProfileCleared();
}

/// Fires the 2-step avatar upload pipeline:
///   1. push [bytes] to R2 via [CloudUploadService] under the `profiles` bucket
///   2. `POST /api/profile/profile-picture` with the returned public_url
///
/// On success we optimistically update the in-memory profile so the hero
/// reflects the new image without a full refetch.
class ProfileAvatarUploadRequested extends ProfileEvent {
  const ProfileAvatarUploadRequested({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;

  @override
  List<Object?> get props => [fileName, bytes.length];
}

/// Same flow, cover-picture variant.
class ProfileCoverUploadRequested extends ProfileEvent {
  const ProfileCoverUploadRequested({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;

  @override
  List<Object?> get props => [fileName, bytes.length];
}
