part of 'search_bloc.dart';

enum SearchTarget {
  users,
  chatRooms,
  messages,
  newGroupMembers,
  groupMembers
}

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

// Handles both initial full-text search and infinite scroll more data loading
final class SearchQuery extends SearchEvent {
  final String userId;
  final SearchTarget searchTarget;
  final String query;
  final dynamic previousResults; // Only for usage for fetching more on scroll
  final List<String>? alreadyAddedUsers; // Holds added users IDs for exclusion in the next members search

  const SearchQuery(this.userId, this.searchTarget, this.query, this.previousResults, this.alreadyAddedUsers);

  @override
  List<Object> get props => [userId, searchTarget, query, previousResults];
}

final class SearchReset extends SearchEvent {}
