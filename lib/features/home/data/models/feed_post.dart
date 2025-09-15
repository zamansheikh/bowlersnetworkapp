class FeedPost {
  final PostMetadata metadata;
  final PostAuthor author;
  final PostLikes likes;
  final PostComments comments;
  final String caption;
  final List<String> media;
  final PostPoll? poll;
  final List<String> tags;
  final bool isLikedByMe;

  const FeedPost({
    required this.metadata,
    required this.author,
    required this.likes,
    required this.comments,
    required this.caption,
    required this.media,
    this.poll,
    required this.tags,
    required this.isLikedByMe,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      metadata: PostMetadata.fromJson(json['metadata']),
      author: PostAuthor.fromJson(json['author']),
      likes: PostLikes.fromJson(json['likes']),
      comments: PostComments.fromJson(json['comments']),
      caption: json['caption'] ?? '',
      media: List<String>.from(json['media'] ?? []),
      poll: json['poll'] != null ? PostPoll.fromJson(json['poll']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      isLikedByMe: json['is_liked_by_me'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'author': author.toJson(),
      'likes': likes.toJson(),
      'comments': comments.toJson(),
      'caption': caption,
      'media': media,
      'poll': poll?.toJson(),
      'tags': tags,
      'is_liked_by_me': isLikedByMe,
    };
  }

  FeedPost copyWith({
    PostMetadata? metadata,
    PostAuthor? author,
    PostLikes? likes,
    PostComments? comments,
    String? caption,
    List<String>? media,
    PostPoll? poll,
    List<String>? tags,
    bool? isLikedByMe,
  }) {
    return FeedPost(
      metadata: metadata ?? this.metadata,
      author: author ?? this.author,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      caption: caption ?? this.caption,
      media: media ?? this.media,
      poll: poll ?? this.poll,
      tags: tags ?? this.tags,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

class PostMetadata {
  final int id;
  final String uid;
  final String postPrivacy;
  final int totalLikes;
  final int totalComments;
  final String createdAt;
  final String updatedAt;
  final String created;
  final String lastUpdate;
  final bool hasText;
  final bool hasMedia;
  final bool hasPoll;
  final bool hasEvent;

  const PostMetadata({
    required this.id,
    required this.uid,
    required this.postPrivacy,
    required this.totalLikes,
    required this.totalComments,
    required this.createdAt,
    required this.updatedAt,
    required this.created,
    required this.lastUpdate,
    required this.hasText,
    required this.hasMedia,
    required this.hasPoll,
    required this.hasEvent,
  });

  factory PostMetadata.fromJson(Map<String, dynamic> json) {
    return PostMetadata(
      id: (json['id'] as num).toInt(),
      uid: json['uid'],
      postPrivacy: json['post_privacy'],
      totalLikes: (json['total_likes'] as num).toInt(),
      totalComments: (json['total_comments'] as num).toInt(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      created: json['created'],
      lastUpdate: json['last_update'],
      hasText: json['has_text'] ?? false,
      hasMedia: json['has_media'] ?? false,
      hasPoll: json['has_poll'] ?? false,
      hasEvent: json['has_event'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'post_privacy': postPrivacy,
      'total_likes': totalLikes,
      'total_comments': totalComments,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created': created,
      'last_update': lastUpdate,
      'has_text': hasText,
      'has_media': hasMedia,
      'has_poll': hasPoll,
      'has_event': hasEvent,
    };
  }

  PostMetadata copyWith({
    int? id,
    String? uid,
    String? postPrivacy,
    int? totalLikes,
    int? totalComments,
    String? createdAt,
    String? updatedAt,
    String? created,
    String? lastUpdate,
    bool? hasText,
    bool? hasMedia,
    bool? hasPoll,
    bool? hasEvent,
  }) {
    return PostMetadata(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      postPrivacy: postPrivacy ?? this.postPrivacy,
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      created: created ?? this.created,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      hasText: hasText ?? this.hasText,
      hasMedia: hasMedia ?? this.hasMedia,
      hasPoll: hasPoll ?? this.hasPoll,
      hasEvent: hasEvent ?? this.hasEvent,
    );
  }
}

class PostAuthor {
  final int userId;
  final String name;
  final String username;
  final String profilePictureUrl;
  final bool isFollowing;
  final bool viewerIsAuthor;

  const PostAuthor({
    required this.userId,
    required this.name,
    required this.username,
    required this.profilePictureUrl,
    required this.isFollowing,
    required this.viewerIsAuthor,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      userId: (json['user_id'] as num).toInt(),
      name: json['name'],
      username: json['username'],
      profilePictureUrl: json['profile_picture_url'] ?? '',
      isFollowing: json['is_following'] ?? false,
      viewerIsAuthor: json['viewer_is_author'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'username': username,
      'profile_picture_url': profilePictureUrl,
      'is_following': isFollowing,
      'viewer_is_author': viewerIsAuthor,
    };
  }

  PostAuthor copyWith({
    int? userId,
    String? name,
    String? username,
    String? profilePictureUrl,
    bool? isFollowing,
    bool? viewerIsAuthor,
  }) {
    return PostAuthor(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      username: username ?? this.username,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      viewerIsAuthor: viewerIsAuthor ?? this.viewerIsAuthor,
    );
  }
}

class PostLikes {
  final int total;
  final List<PostLiker> likers;

  const PostLikes({required this.total, required this.likers});

  factory PostLikes.fromJson(Map<String, dynamic> json) {
    return PostLikes(
      total: (json['total'] as num).toInt(),
      likers:
          (json['likers'] as List<dynamic>?)
              ?.map((liker) => PostLiker.fromJson(liker))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'likers': likers.map((liker) => liker.toJson()).toList(),
    };
  }
}

class PostLiker {
  final int userId;
  final String name;
  final String profilePicUrl;

  const PostLiker({
    required this.userId,
    required this.name,
    required this.profilePicUrl,
  });

  factory PostLiker.fromJson(Map<String, dynamic> json) {
    return PostLiker(
      userId: (json['user_id'] as num).toInt(),
      name: json['name'],
      profilePicUrl: json['profile_pic_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'name': name, 'profile_pic_url': profilePicUrl};
  }
}

class PostComments {
  final int total;
  final List<PostComment> commentList;

  const PostComments({required this.total, required this.commentList});

  factory PostComments.fromJson(Map<String, dynamic> json) {
    return PostComments(
      total: (json['total'] as num).toInt(),
      commentList:
          (json['comment_list'] as List<dynamic>?)
              ?.map((comment) => PostComment.fromJson(comment))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'comment_list': commentList.map((comment) => comment.toJson()).toList(),
    };
  }
}

class PostComment {
  final int commentId;
  final CommentUser user;
  final String text;
  final List<dynamic> pics;
  final List<dynamic> replies;

  const PostComment({
    required this.commentId,
    required this.user,
    required this.text,
    required this.pics,
    required this.replies,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      commentId: (json['comment_id'] as num).toInt(),
      user: CommentUser.fromJson(json['user']),
      text: json['text'],
      pics: json['pics'] ?? [],
      replies: json['replies'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'user': user.toJson(),
      'text': text,
      'pics': pics,
      'replies': replies,
    };
  }
}

class CommentUser {
  final int userId;
  final String name;
  final String profilePictureUrl;

  const CommentUser({
    required this.userId,
    required this.name,
    required this.profilePictureUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      userId: (json['user_id'] as num).toInt(),
      name: json['name'],
      profilePictureUrl: json['profile_picture_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

class PostPoll {
  final int id;
  final String uid;
  final String title;
  final String pollType;
  final List<PollOption> options;

  const PostPoll({
    required this.id,
    required this.uid,
    required this.title,
    required this.pollType,
    required this.options,
  });

  factory PostPoll.fromJson(Map<String, dynamic> json) {
    return PostPoll(
      id: (json['id'] as num).toInt(),
      uid: json['uid'],
      title: json['title'],
      pollType: json['poll_type'],
      options:
          (json['options'] as List<dynamic>?)
              ?.map((option) => PollOption.fromJson(option))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'poll_type': pollType,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }

  PostPoll copyWith({
    int? id,
    String? uid,
    String? title,
    String? pollType,
    List<PollOption>? options,
  }) {
    return PostPoll(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      pollType: pollType ?? this.pollType,
      options: options ?? this.options,
    );
  }
}

class PollOption {
  final int optionId;
  final String content;
  final int vote;
  final int perc;

  const PollOption({
    required this.optionId,
    required this.content,
    required this.vote,
    required this.perc,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      optionId: (json['option_id'] as num).toInt(),
      content: json['content'],
      vote: (json['vote'] as num).toInt(),
      perc: (json['perc'] as num).round(), // Convert double to int safely
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_id': optionId,
      'content': content,
      'vote': vote,
      'perc': perc,
    };
  }

  PollOption copyWith({int? optionId, String? content, int? vote, int? perc}) {
    return PollOption(
      optionId: optionId ?? this.optionId,
      content: content ?? this.content,
      vote: vote ?? this.vote,
      perc: perc ?? this.perc,
    );
  }
}
