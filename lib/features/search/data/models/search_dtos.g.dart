// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseDto _$SearchResponseDtoFromJson(Map<String, dynamic> json) =>
    SearchResponseDto(
      query: json['query'] as String? ?? '',
      results: json['results'] == null
          ? const SearchGroupsDto()
          : SearchGroupsDto.fromJson(json['results'] as Map<String, dynamic>),
    );

SearchGroupsDto _$SearchGroupsDtoFromJson(Map<String, dynamic> json) =>
    SearchGroupsDto(
      users:
          (json['users'] as List<dynamic>?)
              ?.map((e) => SearchUserDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => SearchPostDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      discussions:
          (json['discussions'] as List<dynamic>?)
              ?.map(
                (e) => SearchDiscussionDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      centers:
          (json['centers'] as List<dynamic>?)
              ?.map((e) => SearchCenterDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      brands:
          (json['brands'] as List<dynamic>?)
              ?.map((e) => SearchBrandDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => SearchEventDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      videos:
          (json['videos'] as List<dynamic>?)
              ?.map((e) => SearchVideoDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      splits:
          (json['splits'] as List<dynamic>?)
              ?.map((e) => SearchSplitDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cards:
          (json['cards'] as List<dynamic>?)
              ?.map((e) => SearchCardDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

SearchUserDto _$SearchUserDtoFromJson(Map<String, dynamic> json) =>
    SearchUserDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      isPro: json['is_pro'] as bool? ?? false,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );

SearchPostDto _$SearchPostDtoFromJson(Map<String, dynamic> json) =>
    SearchPostDto(
      uid: json['uid'] as String,
      caption: json['caption'] as String? ?? '',
      postType: json['post_type'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      authorUsername: json['author_username'] as String? ?? '',
      authorProfilePictureUrl: json['author_profile_picture_url'] as String?,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
    );

SearchDiscussionDto _$SearchDiscussionDtoFromJson(Map<String, dynamic> json) =>
    SearchDiscussionDto(
      uid: json['uid'] as String,
      title: json['title'] as String? ?? '',
      topicName: json['topic_name'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      upvoteCount: (json['upvote_count'] as num?)?.toInt() ?? 0,
      opinionCount: (json['opinion_count'] as num?)?.toInt() ?? 0,
      isResolved: json['is_resolved'] as bool? ?? false,
    );

SearchCenterDto _$SearchCenterDtoFromJson(Map<String, dynamic> json) =>
    SearchCenterDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      logo: json['logo'] as String?,
    );

SearchBrandDto _$SearchBrandDtoFromJson(Map<String, dynamic> json) =>
    SearchBrandDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      formalName: json['formal_name'] as String? ?? '',
      brandType: json['brand_type'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );

SearchEventDto _$SearchEventDtoFromJson(Map<String, dynamic> json) =>
    SearchEventDto(
      uid: json['uid'] as String,
      title: json['title'] as String? ?? '',
      eventTypeName: json['event_type_name'] as String? ?? '',
      eventDate: json['event_date'] as String?,
      address: json['address'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? false,
    );

SearchVideoDto _$SearchVideoDtoFromJson(Map<String, dynamic> json) =>
    SearchVideoDto(
      uid: json['uid'] as String,
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      authorName: json['author_name'] as String?,
      authorUsername: json['author_username'] as String?,
      authorProfilePictureUrl: json['author_profile_picture_url'] as String?,
      viewsCount: (json['views_count'] as num?)?.toInt(),
    );

SearchSplitDto _$SearchSplitDtoFromJson(Map<String, dynamic> json) =>
    SearchSplitDto(
      uid: json['uid'] as String,
      caption: json['caption'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      authorName: json['author_name'] as String?,
      authorUsername: json['author_username'] as String?,
      authorProfilePictureUrl: json['author_profile_picture_url'] as String?,
    );

SearchCardDto _$SearchCardDtoFromJson(Map<String, dynamic> json) =>
    SearchCardDto(
      uid: json['uid'] as String,
      displayName: json['display_name'] as String?,
      cardType: json['card_type'] as String?,
      displayImageUrl: json['display_image_url'] as String?,
      ownerUsername: json['owner_username'] as String?,
      ownerFullName: json['owner_full_name'] as String?,
    );
