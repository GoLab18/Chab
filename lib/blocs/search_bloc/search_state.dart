part of 'search_bloc.dart';

enum SearchStatus {
  success,
  loading,
  failure,
  noResultsFound,
  allResultsFound
}

class SearchState extends Equatable {
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

    const SearchState.noResultsFound() : this(status: SearchStatus.noResultsFound);

    const SearchState.allResultsFound(dynamic results) : this(status: SearchStatus.allResultsFound, results: results);
    
    @override
    List<Object?> get props => [status, results, pitId, searchAfterContent];
}
