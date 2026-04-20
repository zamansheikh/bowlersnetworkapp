part of 'conversations_bloc.dart';

class ConversationsState extends Equatable {
  const ConversationsState({
    this.items = const [],
    this.loading = false,
    this.refreshing = false,
    this.errors = const [],
  });

  final List<ConversationListItem> items;
  final bool loading;
  final bool refreshing;
  final List<String> errors;

  ConversationsState copyWith({
    List<ConversationListItem>? items,
    bool? loading,
    bool? refreshing,
    List<String>? errors,
  }) {
    return ConversationsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [items, loading, refreshing, errors];
}
