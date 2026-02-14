/// FeedV3 data models matching /api/newsfeed/v1/ API structure

// ─── Author ──────────────────────────────────────────────────────────────────

class FeedV3AuthorRoles {
  final bool isPro;
  final bool isCenterAdmin;
  final bool isTournamentDirector;

  const FeedV3AuthorRoles({
    this.isPro = false,
    this.isCenterAdmin = false,
    this.isTournamentDirector = false,
  });

  factory FeedV3AuthorRoles.fromJson(Map<String, dynamic> json) {
    return FeedV3AuthorRoles(
      isPro: json['is_pro'] ?? false,
      isCenterAdmin: json['is_center_admin'] ?? false,
      isTournamentDirector: json['is_tournament_director'] ?? false,
    );
  }
}

class FeedV3Author {
  final int userId;
  final String name;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final FeedV3AuthorRoles roles;
  final String profilePictureUrl;
  final String coverPictureUrl;
  final bool isFollowable;
  final bool isFollowing;
  final int followerCount;

  const FeedV3Author({
    required this.userId,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.email = '',
    this.roles = const FeedV3AuthorRoles(),
    this.profilePictureUrl = '',
    this.coverPictureUrl = '',
    this.isFollowable = false,
    this.isFollowing = false,
    this.followerCount = 0,
  });

  factory FeedV3Author.fromJson(Map<String, dynamic> json) {
    return FeedV3Author(
      userId: (json['user_id'] as num).toInt(),
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      roles: json['roles'] != null
          ? FeedV3AuthorRoles.fromJson(json['roles'])
          : const FeedV3AuthorRoles(),
      profilePictureUrl: json['profile_picture_url'] ?? '',
      coverPictureUrl: json['cover_picture_url'] ?? '',
      isFollowable: json['is_followable'] ?? false,
      isFollowing: json['is_following'] ?? false,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
    );
  }
}

// ─── Content Types ───────────────────────────────────────────────────────────

/// Default text/media post content
class DefaultContent {
  final String text;
  final List<String> mediaUrls;
  final String? title;
  final String? description;

  const DefaultContent({
    this.text = '',
    this.mediaUrls = const [],
    this.title,
    this.description,
  });

  factory DefaultContent.fromJson(Map<String, dynamic> json) {
    return DefaultContent(
      text: json['text'] ?? '',
      mediaUrls:
          (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      title: json['title'],
      description: json['description'],
    );
  }
}

/// Poll option
class FeedV3PollOption {
  final int id;
  final String text;
  final int voteCount;
  final double voteShare;
  final bool hasVoted;

  const FeedV3PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.voteShare = 0.0,
    this.hasVoted = false,
  });

  factory FeedV3PollOption.fromJson(Map<String, dynamic> json) {
    return FeedV3PollOption(
      id: (json['id'] as num).toInt(),
      text: json['text'] ?? '',
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      voteShare: (json['vote_share'] as num?)?.toDouble() ?? 0.0,
      hasVoted: json['has_voted'] ?? false,
    );
  }

  FeedV3PollOption copyWith({
    int? id,
    String? text,
    int? voteCount,
    double? voteShare,
    bool? hasVoted,
  }) {
    return FeedV3PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
      voteShare: voteShare ?? this.voteShare,
      hasVoted: hasVoted ?? this.hasVoted,
    );
  }
}

/// Poll content
class PollContent {
  final String title;
  final String description;
  final String pollType; // 'single' or 'multiple'
  final int expiryHours;
  final bool hasExpired;
  final double timeLeftSeconds;
  final int totalVotes;
  final List<FeedV3PollOption> options;

  const PollContent({
    required this.title,
    this.description = '',
    this.pollType = 'single',
    this.expiryHours = 24,
    this.hasExpired = false,
    this.timeLeftSeconds = 0,
    this.totalVotes = 0,
    this.options = const [],
  });

  factory PollContent.fromJson(Map<String, dynamic> json) {
    return PollContent(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pollType: json['poll_type'] ?? 'single',
      expiryHours: (json['expiry_hours'] as num?)?.toInt() ?? 24,
      hasExpired: json['has_expired'] ?? false,
      timeLeftSeconds: (json['time_left_seconds'] as num?)?.toDouble() ?? 0,
      totalVotes: (json['total_votes'] as num?)?.toInt() ?? 0,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => FeedV3PollOption.fromJson(e))
              .toList() ??
          [],
    );
  }

  PollContent copyWith({
    String? title,
    String? description,
    String? pollType,
    int? expiryHours,
    bool? hasExpired,
    double? timeLeftSeconds,
    int? totalVotes,
    List<FeedV3PollOption>? options,
  }) {
    return PollContent(
      title: title ?? this.title,
      description: description ?? this.description,
      pollType: pollType ?? this.pollType,
      expiryHours: expiryHours ?? this.expiryHours,
      hasExpired: hasExpired ?? this.hasExpired,
      timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
      totalVotes: totalVotes ?? this.totalVotes,
      options: options ?? this.options,
    );
  }
}

/// Shared post content (reshare)
class SharedContent {
  final String description;
  final FeedV3Post? original;

  const SharedContent({this.description = '', this.original});

  factory SharedContent.fromJson(Map<String, dynamic> json) {
    return SharedContent(
      description: json['description'] ?? '',
      original: json['original'] != null
          ? FeedV3Post.fromJson(json['original'])
          : null,
    );
  }
}

// ─── Comment ─────────────────────────────────────────────────────────────────

class FeedV3Comment {
  final int id;
  final int? parentId;
  final String text;
  final String? mediaUrl;
  final String createdAt;
  final String created;
  final int likesCount;
  final bool hasLiked;
  final bool isMine;
  final bool isPostAuthor;
  final FeedV3Author author;
  final List<FeedV3Comment> replies;

  const FeedV3Comment({
    required this.id,
    this.parentId,
    required this.text,
    this.mediaUrl,
    this.createdAt = '',
    this.created = '',
    this.likesCount = 0,
    this.hasLiked = false,
    this.isMine = false,
    this.isPostAuthor = false,
    required this.author,
    this.replies = const [],
  });

  factory FeedV3Comment.fromJson(Map<String, dynamic> json) {
    return FeedV3Comment(
      id: (json['id'] as num).toInt(),
      parentId: (json['parent_id'] as num?)?.toInt(),
      text: json['text'] ?? '',
      mediaUrl: json['media_url'],
      createdAt: json['created_at'] ?? '',
      created: json['created'] ?? '',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      hasLiked: json['has_liked'] ?? false,
      isMine: json['is_mine'] ?? false,
      isPostAuthor: json['is_post_author'] ?? false,
      author: FeedV3Author.fromJson(json['author']),
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => FeedV3Comment.fromJson(e))
              .toList() ??
          [],
    );
  }

  FeedV3Comment copyWith({
    int? id,
    int? parentId,
    String? text,
    String? mediaUrl,
    String? createdAt,
    String? created,
    int? likesCount,
    bool? hasLiked,
    bool? isMine,
    bool? isPostAuthor,
    FeedV3Author? author,
    List<FeedV3Comment>? replies,
  }) {
    return FeedV3Comment(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      created: created ?? this.created,
      likesCount: likesCount ?? this.likesCount,
      hasLiked: hasLiked ?? this.hasLiked,
      isMine: isMine ?? this.isMine,
      isPostAuthor: isPostAuthor ?? this.isPostAuthor,
      author: author ?? this.author,
      replies: replies ?? this.replies,
    );
  }
}

// ─── Post ────────────────────────────────────────────────────────────────────

enum FeedV3PostType { defaultPost, poll, shared }

class FeedV3Post {
  final int id;
  final String uid;
  final FeedV3PostType postType;
  final String createdAt;
  final String created;
  final bool isPublic;
  final bool isMine;
  final FeedV3Author author;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool hasLiked;
  final List<FeedV3Comment> latestComments;

  // Content — one of these will be populated based on postType
  final DefaultContent? defaultContent;
  final PollContent? pollContent;
  final SharedContent? sharedContent;

  const FeedV3Post({
    required this.id,
    this.uid = '',
    required this.postType,
    this.createdAt = '',
    this.created = '',
    this.isPublic = true,
    this.isMine = false,
    required this.author,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.hasLiked = false,
    this.latestComments = const [],
    this.defaultContent,
    this.pollContent,
    this.sharedContent,
  });

  factory FeedV3Post.fromJson(Map<String, dynamic> json) {
    final postTypeStr = json['post_type'] ?? 'default';
    final FeedV3PostType postType;
    DefaultContent? defaultContent;
    PollContent? pollContent;
    SharedContent? sharedContent;

    switch (postTypeStr) {
      case 'poll':
        postType = FeedV3PostType.poll;
        if (json['content'] != null) {
          pollContent = PollContent.fromJson(json['content']);
        }
        break;
      case 'shared':
        postType = FeedV3PostType.shared;
        if (json['content'] != null) {
          sharedContent = SharedContent.fromJson(json['content']);
        }
        break;
      default:
        postType = FeedV3PostType.defaultPost;
        if (json['content'] != null) {
          defaultContent = DefaultContent.fromJson(json['content']);
        }
        break;
    }

    return FeedV3Post(
      id: (json['id'] as num).toInt(),
      uid: json['uid'] ?? '',
      postType: postType,
      createdAt: json['created_at'] ?? '',
      created: json['created'] ?? '',
      isPublic: json['is_public'] ?? true,
      isMine: json['is_mine'] ?? false,
      author: FeedV3Author.fromJson(json['author']),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      sharesCount: (json['shares_count'] as num?)?.toInt() ?? 0,
      hasLiked: json['has_liked'] ?? false,
      latestComments:
          (json['latest_comments'] as List<dynamic>?)
              ?.map((e) => FeedV3Comment.fromJson(e))
              .toList() ??
          [],
      defaultContent: defaultContent,
      pollContent: pollContent,
      sharedContent: sharedContent,
    );
  }

  FeedV3Post copyWith({
    int? id,
    String? uid,
    FeedV3PostType? postType,
    String? createdAt,
    String? created,
    bool? isPublic,
    bool? isMine,
    FeedV3Author? author,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? hasLiked,
    List<FeedV3Comment>? latestComments,
    DefaultContent? defaultContent,
    PollContent? pollContent,
    SharedContent? sharedContent,
  }) {
    return FeedV3Post(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      postType: postType ?? this.postType,
      createdAt: createdAt ?? this.createdAt,
      created: created ?? this.created,
      isPublic: isPublic ?? this.isPublic,
      isMine: isMine ?? this.isMine,
      author: author ?? this.author,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      hasLiked: hasLiked ?? this.hasLiked,
      latestComments: latestComments ?? this.latestComments,
      defaultContent: defaultContent ?? this.defaultContent,
      pollContent: pollContent ?? this.pollContent,
      sharedContent: sharedContent ?? this.sharedContent,
    );
  }
}

// ─── Paginated Response ──────────────────────────────────────────────────────

class PaginatedFeedResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<FeedV3Post> results;

  const PaginatedFeedResponse({
    this.count = 0,
    this.next,
    this.previous,
    this.results = const [],
  });

  factory PaginatedFeedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedFeedResponse(
      count: (json['count'] as num?)?.toInt() ?? 0,
      next: json['next'],
      previous: json['previous'],
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => FeedV3Post.fromJson(e))
              .toList() ??
          [],
    );
  }

  bool get hasMore => next != null;
}

class PaginatedCommentsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<FeedV3Comment> results;

  const PaginatedCommentsResponse({
    this.count = 0,
    this.next,
    this.previous,
    this.results = const [],
  });

  factory PaginatedCommentsResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedCommentsResponse(
      count: (json['count'] as num?)?.toInt() ?? 0,
      next: json['next'],
      previous: json['previous'],
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => FeedV3Comment.fromJson(e))
              .toList() ??
          [],
    );
  }

  bool get hasMore => next != null;
}
