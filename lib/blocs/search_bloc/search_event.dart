part of 'search_bloc.dart';

enum SearchTarget {
  users,
  chatRooms,
  messages,
  members
}

// Handles both initial full-text search and infinite scroll more data loading
final class SearchEvent extends Equatable {
  final String userId;
  final SearchTarget searchTarget;
  final String query;
  final dynamic previousResults; // Only for usage for fetching more on scroll

  const SearchEvent(this.userId, this.searchTarget, this.query, this.previousResults);

  @override
  List<Object> get props => [userId, searchTarget, query, previousResults];
}
