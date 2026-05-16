import 'package:json_annotation/json_annotation.dart';

part 'search_dtos.g.dart';

/// Wire-level shape of `GET /api/search?q=...&types=...`. Only the groups
/// the backend matched on are present in `results` — missing groups
/// default to empty.
@JsonSerializable(createToJson: false)
class SearchResponseDto {
  const SearchResponseDto({this.query = '', this.results = const SearchGroupsDto()});

  @JsonKey(defaultValue: '')
  final String query;

  final SearchGroupsDto results;

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchGroupsDto {
  const SearchGroupsDto({
    this.users = const [],
    this.posts = const [],
    this.discussions = const [],
    this.centers = const [],
    this.brands = const [],
    this.events = const [],
    this.videos = const [],
    this.splits = const [],
    this.cards = const [],
  });

  final List<SearchUserDto> users;
  final List<SearchPostDto> posts;
  final List<SearchDiscussionDto> discussions;
  final List<SearchCenterDto> centers;
  final List<SearchBrandDto> brands;
  final List<SearchEventDto> events;
  final List<SearchVideoDto> videos;
  final List<SearchSplitDto> splits;
  final List<SearchCardDto> cards;

  factory SearchGroupsDto.fromJson(Map<String, dynamic> json) =>
      _$SearchGroupsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchUserDto {
  const SearchUserDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.fullName = '',
    this.isPro = false,
    this.profilePictureUrl,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'full_name', defaultValue: '')
  final String fullName;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;

  factory SearchUserDto.fromJson(Map<String, dynamic> json) =>
      _$SearchUserDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchPostDto {
  const SearchPostDto({
    required this.uid,
    this.caption = '',
    this.postType = '',
    this.authorName = '',
    this.authorUsername = '',
    this.authorProfilePictureUrl,
    this.likesCount = 0,
    this.createdAt,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String caption;
  @JsonKey(name: 'post_type', defaultValue: '')
  final String postType;
  @JsonKey(name: 'author_name', defaultValue: '')
  final String authorName;
  @JsonKey(name: 'author_username', defaultValue: '')
  final String authorUsername;
  @JsonKey(name: 'author_profile_picture_url')
  final String? authorProfilePictureUrl;
  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int likesCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory SearchPostDto.fromJson(Map<String, dynamic> json) =>
      _$SearchPostDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchDiscussionDto {
  const SearchDiscussionDto({
    required this.uid,
    this.title = '',
    this.topicName = '',
    this.authorName = '',
    this.upvoteCount = 0,
    this.opinionCount = 0,
    this.isResolved = false,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'topic_name', defaultValue: '')
  final String topicName;
  @JsonKey(name: 'author_name', defaultValue: '')
  final String authorName;
  @JsonKey(name: 'upvote_count', defaultValue: 0)
  final int upvoteCount;
  @JsonKey(name: 'opinion_count', defaultValue: 0)
  final int opinionCount;
  @JsonKey(name: 'is_resolved', defaultValue: false)
  final bool isResolved;

  factory SearchDiscussionDto.fromJson(Map<String, dynamic> json) =>
      _$SearchDiscussionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchCenterDto {
  const SearchCenterDto({
    this.id = 0,
    this.name = '',
    this.address = '',
    this.logo,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String address;
  final String? logo;

  factory SearchCenterDto.fromJson(Map<String, dynamic> json) =>
      _$SearchCenterDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchBrandDto {
  const SearchBrandDto({
    this.id = 0,
    this.name = '',
    this.formalName = '',
    this.brandType = '',
    this.logoUrl,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'formal_name', defaultValue: '')
  final String formalName;
  @JsonKey(name: 'brand_type', defaultValue: '')
  final String brandType;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  factory SearchBrandDto.fromJson(Map<String, dynamic> json) =>
      _$SearchBrandDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchEventDto {
  const SearchEventDto({
    required this.uid,
    this.title = '',
    this.eventTypeName = '',
    this.eventDate,
    this.address = '',
    this.isOnline = false,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'event_type_name', defaultValue: '')
  final String eventTypeName;
  @JsonKey(name: 'event_date')
  final String? eventDate;
  @JsonKey(defaultValue: '')
  final String address;
  @JsonKey(name: 'is_online', defaultValue: false)
  final bool isOnline;

  factory SearchEventDto.fromJson(Map<String, dynamic> json) =>
      _$SearchEventDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchVideoDto {
  const SearchVideoDto({
    required this.uid,
    this.title = '',
    this.thumbnailUrl,
    this.durationSeconds,
    this.authorName,
    this.authorUsername,
    this.authorProfilePictureUrl,
    this.viewsCount,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'author_name')
  final String? authorName;
  @JsonKey(name: 'author_username')
  final String? authorUsername;
  @JsonKey(name: 'author_profile_picture_url')
  final String? authorProfilePictureUrl;
  @JsonKey(name: 'views_count')
  final int? viewsCount;

  factory SearchVideoDto.fromJson(Map<String, dynamic> json) =>
      _$SearchVideoDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchSplitDto {
  const SearchSplitDto({
    required this.uid,
    this.caption = '',
    this.thumbnailUrl,
    this.authorName,
    this.authorUsername,
    this.authorProfilePictureUrl,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String caption;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'author_name')
  final String? authorName;
  @JsonKey(name: 'author_username')
  final String? authorUsername;
  @JsonKey(name: 'author_profile_picture_url')
  final String? authorProfilePictureUrl;

  factory SearchSplitDto.fromJson(Map<String, dynamic> json) =>
      _$SearchSplitDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SearchCardDto {
  const SearchCardDto({
    required this.uid,
    this.displayName,
    this.cardType,
    this.displayImageUrl,
    this.ownerUsername,
    this.ownerFullName,
  });

  final String uid;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'card_type')
  final String? cardType;
  @JsonKey(name: 'display_image_url')
  final String? displayImageUrl;
  @JsonKey(name: 'owner_username')
  final String? ownerUsername;
  @JsonKey(name: 'owner_full_name')
  final String? ownerFullName;

  factory SearchCardDto.fromJson(Map<String, dynamic> json) =>
      _$SearchCardDtoFromJson(json);
}
