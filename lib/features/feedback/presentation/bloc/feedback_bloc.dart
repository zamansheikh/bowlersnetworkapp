import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/feedback_draft.dart';
import '../../domain/repositories/feedback_repository.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

/// Drives the /feedback submit form. One screen, one POST. The screen
/// owns the controllers — bloc just tracks the pick-list values + the
/// in-flight submit.
@injectable
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  FeedbackBloc(this._repository) : super(const FeedbackState()) {
    on<FeedbackCategoryChanged>(_onCategoryChanged);
    on<FeedbackAreaChanged>(_onAreaChanged);
    on<FeedbackSubmitRequested>(_onSubmit);
    on<FeedbackResetRequested>((_, emit) => emit(const FeedbackState()));
  }

  final FeedbackRepository _repository;

  void _onCategoryChanged(
    FeedbackCategoryChanged event,
    Emitter<FeedbackState> emit,
  ) {
    emit(state.copyWith(category: event.category));
  }

  void _onAreaChanged(
    FeedbackAreaChanged event,
    Emitter<FeedbackState> emit,
  ) {
    emit(state.copyWith(area: event.area));
  }

  Future<void> _onSubmit(
    FeedbackSubmitRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    final title = event.title.trim();
    final body = event.body.trim();
    if (title.isEmpty) {
      emit(state.copyWith(errors: const ['Title is required.']));
      return;
    }
    if (body.isEmpty) {
      emit(state.copyWith(errors: const ['Body is required.']));
      return;
    }
    emit(state.copyWith(submitting: true, errors: const []));
    final res = await _repository.submit(
      category: state.category,
      title: title,
      body: body,
      area: state.area,
    );
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errors: f.messages)),
      (submitted) => emit(state.copyWith(
        submitting: false,
        submitted: submitted,
      )),
    );
  }
}
