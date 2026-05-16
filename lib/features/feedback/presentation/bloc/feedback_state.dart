part of 'feedback_bloc.dart';

class FeedbackState extends Equatable {
  const FeedbackState({
    this.category = FeedbackCategory.bug,
    this.area = FeedbackArea.other,
    this.submitting = false,
    this.submitted,
    this.errors = const [],
  });

  final FeedbackCategory category;
  final FeedbackArea area;
  final bool submitting;

  /// Non-null after a successful submit. Screen listens for this to
  /// show a success toast + reset the form.
  final FeedbackSubmitted? submitted;
  final List<String> errors;

  FeedbackState copyWith({
    FeedbackCategory? category,
    FeedbackArea? area,
    bool? submitting,
    FeedbackSubmitted? submitted,
    List<String>? errors,
  }) {
    return FeedbackState(
      category: category ?? this.category,
      area: area ?? this.area,
      submitting: submitting ?? this.submitting,
      submitted: submitted ?? this.submitted,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [category, area, submitting, submitted, errors];
}
