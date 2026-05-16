part of 'search_bloc.dart';

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.loading = false,
    this.results = const SearchResults(),
    this.errors = const [],
  });

  final String query;
  final bool loading;
  final SearchResults results;
  final List<String> errors;

  /// True when the user has typed a "real" query (≥2 chars) — used by the
  /// screen to decide between the "start typing" splash and the results
  /// view (which may still be empty pending a response).
  bool get hasQuery => query.length >= 2;

  /// True after a search completes with no matches in any group.
  bool get isEmpty => hasQuery && !loading && results.isEmpty;

  SearchState copyWith({
    String? query,
    bool? loading,
    SearchResults? results,
    List<String>? errors,
    bool clearResults = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      loading: loading ?? this.loading,
      results: clearResults ? const SearchResults() : (results ?? this.results),
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [query, loading, results, errors];
}
