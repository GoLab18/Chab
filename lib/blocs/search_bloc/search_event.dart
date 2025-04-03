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
  final String? roomId; // For searching messages and group members
  final dynamic previousResults; // Only for usage for fetching more on scroll
  final List<String>? alreadyAddedUsers; // Holds added users IDs for exclusion in the next members search
  final String? pitId;
  final List<dynamic>? searchAfterContent;

  const SearchQuery({
    required this.userId,
    required this.searchTarget,
    required this.query,
    this.roomId,
    this.previousResults,
    this.alreadyAddedUsers,
    this.pitId,
    this.searchAfterContent
  });

  @override
  List<Object> get props => [userId, searchTarget, query, previousResults];
}

final class SearchReset extends SearchEvent {}
