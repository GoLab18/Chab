part of 'search_bloc.dart';

enum SearchStatus {
  success,
  loading,
  failure
}

class SearchState {
  final SearchStatus status;
  final dynamic results;
  final String? pitId;
  final List<dynamic>? searchAfterContent;
  
  const SearchState({
    this.status = SearchStatus.loading,
    this.results = const [],
    this.pitId,
    this.searchAfterContent
  });

    const SearchState.loading() : this();
    
    const SearchState.success(dynamic r, String pi, List<dynamic>? sac)
      : this(status: SearchStatus.success, results: r, pitId: pi, searchAfterContent: sac);

    const SearchState.failure() : this(status: SearchStatus.failure);
}
