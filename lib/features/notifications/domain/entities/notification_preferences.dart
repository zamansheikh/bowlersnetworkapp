import 'package:equatable/equatable.dart';

/// One of the nine notification categories the user can opt into/out of.
/// `apiKey` matches the wire shape so the bloc can serialise patches
/// without an extra mapper.
enum NotificationKind {
  reactions('reactions', 'Reactions'),
  comments('comments', 'Comments'),
  follows('follows', 'New followers'),
  chatterVotes('chatter_votes', 'Chatter upvotes'),
  eventInvitations('event_invitations', 'Event invitations'),
  teamInvitations('team_invitations', 'Team invitations'),
  cardCollections('card_collections', 'Card collections'),
  messages('messages', 'Direct messages'),
  xpLevelUps('xp_level_ups', 'XP level-ups');

  const NotificationKind(this.apiKey, this.label);
  final String apiKey;
  final String label;
}

class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.reactions = true,
    this.comments = true,
    this.follows = true,
    this.chatterVotes = true,
    this.eventInvitations = true,
    this.teamInvitations = true,
    this.cardCollections = true,
    this.messages = true,
    this.xpLevelUps = true,
  });

  final bool reactions;
  final bool comments;
  final bool follows;
  final bool chatterVotes;
  final bool eventInvitations;
  final bool teamInvitations;
  final bool cardCollections;
  final bool messages;
  final bool xpLevelUps;

  bool valueOf(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.reactions:
        return reactions;
      case NotificationKind.comments:
        return comments;
      case NotificationKind.follows:
        return follows;
      case NotificationKind.chatterVotes:
        return chatterVotes;
      case NotificationKind.eventInvitations:
        return eventInvitations;
      case NotificationKind.teamInvitations:
        return teamInvitations;
      case NotificationKind.cardCollections:
        return cardCollections;
      case NotificationKind.messages:
        return messages;
      case NotificationKind.xpLevelUps:
        return xpLevelUps;
    }
  }

  NotificationPreferences withKind(NotificationKind kind, bool value) {
    switch (kind) {
      case NotificationKind.reactions:
        return copyWith(reactions: value);
      case NotificationKind.comments:
        return copyWith(comments: value);
      case NotificationKind.follows:
        return copyWith(follows: value);
      case NotificationKind.chatterVotes:
        return copyWith(chatterVotes: value);
      case NotificationKind.eventInvitations:
        return copyWith(eventInvitations: value);
      case NotificationKind.teamInvitations:
        return copyWith(teamInvitations: value);
      case NotificationKind.cardCollections:
        return copyWith(cardCollections: value);
      case NotificationKind.messages:
        return copyWith(messages: value);
      case NotificationKind.xpLevelUps:
        return copyWith(xpLevelUps: value);
    }
  }

  NotificationPreferences copyWith({
    bool? reactions,
    bool? comments,
    bool? follows,
    bool? chatterVotes,
    bool? eventInvitations,
    bool? teamInvitations,
    bool? cardCollections,
    bool? messages,
    bool? xpLevelUps,
  }) =>
      NotificationPreferences(
        reactions: reactions ?? this.reactions,
        comments: comments ?? this.comments,
        follows: follows ?? this.follows,
        chatterVotes: chatterVotes ?? this.chatterVotes,
        eventInvitations: eventInvitations ?? this.eventInvitations,
        teamInvitations: teamInvitations ?? this.teamInvitations,
        cardCollections: cardCollections ?? this.cardCollections,
        messages: messages ?? this.messages,
        xpLevelUps: xpLevelUps ?? this.xpLevelUps,
      );

  @override
  List<Object?> get props => [
        reactions,
        comments,
        follows,
        chatterVotes,
        eventInvitations,
        teamInvitations,
        cardCollections,
        messages,
        xpLevelUps,
      ];
}
