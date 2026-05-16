import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

/// Central Predictive Search. Widget debounces the input and fires
/// [SearchQueryChanged]; the bloc tags every request with a monotonically
/// increasing token so out-of-order responses from earlier queries are
/// discarded (the user's last keystroke always wins).
@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository) : super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
  }

  final SearchRepository _repository;

  /// Bumped per dispatched query; responses with a stale token are ignored.
  int _requestToken = 0;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final q = event.query.trim();
    // Min length matches backend's 400 floor — fail fast without round-trip.
    if (q.length < 2) {
      _requestToken++;
      emit(state.copyWith(
        query: q,
        loading: false,
        results: const SearchResults(),
        errors: const [],
        clearResults: true,
      ));
      return;
    }
    final token = ++_requestToken;
    emit(state.copyWith(query: q, loading: true, errors: const []));
    final res = await _repository.search(query: q);
    // Discard if a newer query has been fired in the meantime.
    if (token != _requestToken) return;
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (results) => emit(state.copyWith(loading: false, results: results)),
    );
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    _requestToken++;
    emit(const SearchState());
  }
}
