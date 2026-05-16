part of 'feedback_bloc.dart';

sealed class FeedbackEvent extends Equatable {
  const FeedbackEvent();
  @override
  List<Object?> get props => const [];
}

class FeedbackCategoryChanged extends FeedbackEvent {
  const FeedbackCategoryChanged(this.category);
  final FeedbackCategory category;
  @override
  List<Object?> get props => [category];
}

class FeedbackAreaChanged extends FeedbackEvent {
  const FeedbackAreaChanged(this.area);
  final FeedbackArea area;
  @override
  List<Object?> get props => [area];
}

/// User tapped Submit. Screen passes the current title + body since
/// it owns the controllers.
class FeedbackSubmitRequested extends FeedbackEvent {
  const FeedbackSubmitRequested({required this.title, required this.body});
  final String title;
  final String body;
  @override
  List<Object?> get props => [title, body];
}

class FeedbackResetRequested extends FeedbackEvent {
  const FeedbackResetRequested();
}
