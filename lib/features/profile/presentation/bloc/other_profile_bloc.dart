import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../follow/domain/repositories/follow_repository.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'other_profile_event.dart';
part 'other_profile_state.dart';

/// Drives the "view another user's profile" screen. NOT a singleton —
/// each screen instance owns its bloc so `username` is locked at
/// construction.
///
/// Distinct from [ProfileBloc] (which is for the logged-in user and
/// handles avatar/cover uploads + completion). This bloc only reads, plus
/// the one write the viewer is allowed to make: toggling follow.
class OtherProfileBloc extends Bloc<OtherProfileEvent, OtherProfileState> {
  OtherProfileBloc({
    required ProfileRepository profileRepository,
    required FollowRepository followRepository,
    required String username,
  })  : _profile = profileRepository,
        _follow = followRepository,
        _username = username,
        super(const OtherProfileState()) {
    on<OtherProfileLoadRequested>(_onLoad);
    on<OtherProfileFollowToggled>(_onToggleFollow);
  }

  final ProfileRepository _profile;
  final FollowRepository _follow;
  final String _username;

  Future<void> _onLoad(
    OtherProfileLoadRequested event,
    Emitter<OtherProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _profile.getProfileByUsername(_username);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (profile) => emit(state.copyWith(loading: false, profile: profile)),
    );
  }

  Future<void> _onToggleFollow(
    OtherProfileFollowToggled event,
    Emitter<OtherProfileState> emit,
  ) async {
    final p = state.profile;
    // Need a user id + canFollow to proceed; silently no-op otherwise.
    if (p == null || p.canFollow == false || state.followBusy) return;

    // Optimistic flip — flip the bool + nudge the count by ±1 so the UI
    // responds instantly. Backend's authoritative count overwrites on
    // success.
    final wasFollowing = p.isFollowing == true;
    final optimistic = _replaceFollow(
      p,
      isFollowing: !wasFollowing,
      followerCount: (p.followerCount + (wasFollowing ? -1 : 1))
          .clamp(0, 1 << 31),
    );
    emit(state.copyWith(profile: optimistic, followBusy: true));

    final res = await _follow.toggleFollow(p.user.id);
    res.fold(
      (f) {
        // Rollback to the prior state if the backend rejected it.
        emit(state.copyWith(
          profile: p,
          followBusy: false,
          errors: f.messages,
        ));
      },
      (result) => emit(state.copyWith(
        profile: _replaceFollow(
          p,
          isFollowing: result.isFollowing,
          followerCount: result.followerCount,
        ),
        followBusy: false,
      )),
    );
  }

  /// Returns a copy of [base] with only the follow-related fields swapped.
  /// Profile has no copyWith so we rebuild it field-by-field.
  Profile _replaceFollow(
    Profile base, {
    required bool isFollowing,
    required int followerCount,
  }) =>
      Profile(
        user: base.user,
        completionPercentage: base.completionPercentage,
        isComplete: base.isComplete,
        profilePictureUrl: base.profilePictureUrl,
        coverPictureUrl: base.coverPictureUrl,
        introVideoUrl: base.introVideoUrl,
        bio: base.bio,
        nickname: base.nickname,
        gender: base.gender,
        birthdate: base.birthdate,
        age: base.age,
        address: base.address,
        zipCode: base.zipCode,
        homeCenter: base.homeCenter,
        handedness: base.handedness,
        ballCarry: base.ballCarry,
        grip: base.grip,
        ballHandlingDescription: base.ballHandlingDescription,
        contactEmail: base.contactEmail,
        average: base.average,
        highGame: base.highGame,
        highSeries: base.highSeries,
        experience: base.experience,
        isCoach: base.isCoach,
        followerCount: followerCount,
        followingCount: base.followingCount,
        isFollowing: isFollowing,
        canFollow: base.canFollow,
      );
}
