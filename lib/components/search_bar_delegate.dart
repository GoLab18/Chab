import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/invites_operations_bloc/invites_operations_bloc.dart';
import '../blocs/room_bloc/room_bloc.dart';
import '../blocs/search_bloc/search_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../cubits/staged_members_cubit.dart';
import 'prompts/message_divider.dart';
import 'prompts/search_results_not_found.dart';
import 'prompts/start_searching_prompt.dart';
import 'tiles/add_group_member_tile.dart';
import 'tiles/message_search_tile.dart';
import 'tiles/room_search_tile.dart';
import 'tiles/user_with_invite_tile.dart';

class SearchBarDelegate extends SearchDelegate {
  final SearchTarget searchTarget;
  final SearchBloc searchBloc;
  final UsrBloc usrBloc;
  final InvitesOperationsBloc? invOpsBloc; // Needed only for friends searching
  final RoomBloc? roomBloc; // For searching up messages and room members
  final StagedMembersCubit? stagedMembersCubit; // For managing staged members to add to new group

  bool isInitialSearch = true;

  final ScrollController scrollController = ScrollController();
  VoidCallback? scrollListener;

  SearchBarDelegate({
    required this.searchTarget,
    required this.searchBloc,
    required this.usrBloc,
    this.invOpsBloc,
    this.roomBloc,
    this.stagedMembersCubit
  }) {
    scrollController.addListener(_fetchMore);
  }

  @override
  String? get searchFieldLabel => "Search..";

  @override
  double? get leadingWidth => 50;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <IconButton>[
      IconButton(
        onPressed: () {
          if (query.isNotEmpty) query = "";
        },
        icon: Icon(
          Icons.clear,
          color: Theme.of(context).colorScheme.inversePrimary
        )
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.inversePrimary
        )
      )
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _provideResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _provideResults(context);
  }

  Widget _provideResults(BuildContext context) {
    if (query.isEmpty) {
      searchBloc.add(SearchReset());
      return StartSearchingPrompt(Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary);
    }
    
    searchBloc.add(
      SearchQuery(
        userId: usrBloc.state.user!.id,
        searchTarget: searchTarget,
        query: query,
        roomId: roomBloc?.state.room!.id,
        previousResults: null,
        alreadyAddedUsers: stagedMembersCubit?.state.map((usr) => usr.id).toList(),
        searchAfterContent: searchBloc.state.searchAfterContent
      )
    );
    
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) searchBloc.add(SearchReset());
      },
      child: BlocBuilder<SearchBloc, SearchState>(
        bloc: searchBloc,
        builder: (context, state) {
          if (isInitialSearch || state.status == SearchStatus.loading) {
            if (isInitialSearch) isInitialSearch = false;
            return Center(child: const CircularProgressIndicator());
          } else if (state.status == SearchStatus.noResultsFound) {
            return SearchResultsNotFound(Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary);
          } else if (state.status == SearchStatus.allResultsFound || state.status == SearchStatus.success) {
            return listViewForSearchTarget(state, context);
          } else if (state.status == SearchStatus.failure) {
            return Center(
              child: Text(
                "Loading error",
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.inversePrimary
                )
              )
            );
          }

          throw Exception("Non-existent search_bloc state");
        }
      )
    );
  }

  void _fetchMore() {
    if (
      scrollController.position.pixels == scrollController.position.maxScrollExtent
      && searchBloc.state.status == SearchStatus.success
    ) {
      searchBloc.add(
        SearchQuery(
          userId: usrBloc.state.user!.id,
          searchTarget: searchTarget,
          query: query,
          roomId: roomBloc!.state.room!.id,
          previousResults: searchBloc.state.results,
          alreadyAddedUsers: stagedMembersCubit?.state.map((usr) => usr.id).toList(),
          pitId: searchBloc.state.pitId,
          searchAfterContent: searchBloc.state.searchAfterContent
        )
      );
    }
  }

  ListView listViewForSearchTarget(SearchState state, BuildContext context) {
    return switch (searchTarget) {
      SearchTarget.users => renderProperListView(context, state.status, state.results.$1.length,
        (index) => UserWithInviteTile(
          key: ValueKey(state.results.$1[index].id),
          state.results.$1[index],
          state.results.$2[index]?.$1,
          state.results.$2[index]?.$2,
          invOpsBloc!,
          usrBloc
        )
      ),
      SearchTarget.newGroupMembers => renderProperListView(context, state.status, state.results.length,
        (index) => AddGroupMemberTile(
          key: ValueKey(state.results[index].id),
          user: state.results[index],
          callbackIcon: Icons.add,
          isMemberSubjectToAddition: true,
          onButtonInvoked: (user) {
            stagedMembersCubit!.stageMember(user);
          }
        )
      ),
      SearchTarget.chatRooms => renderProperListView(context, state.status, state.results.length,
        (index) => RoomSearchTile(
          key: ValueKey(state.results[index].$1),
          roomId: state.results[index].$1,
          isPrivate: state.results[index].$2,
          name: state.results[index].$3,
          picUrl: state.results[index].$4,
          usrBloc: usrBloc,
          searchBloc: searchBloc
        )
      ),
      SearchTarget.messages => renderProperListView(context, state.status, state.results.length,
        (index) => MessageSearchTile(
          key: ValueKey(state.results[index].$1.id),
          message: state.results[index].$1,
          name: state.results[index].$2,
          picUrl: state.results[index].$3,
          currUserId: usrBloc.state.user!.id
        )
      ),
      SearchTarget.groupMembers => throw UnimplementedError()   // TODO: Handle this case.
    };
  }

  ListView renderProperListView(BuildContext context, SearchStatus status, int itemCount, Widget Function(int) tileBuilder) {
    return ListView.builder(
      cacheExtent: MediaQuery.of(context).size.height * 1.5,
      controller: scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: itemCount + 1,
      itemBuilder: (context, index) {
        if (index < itemCount) {
          return tileBuilder(index);
        } else {
          return SizedBox(
            height: 70,
            child: status == SearchStatus.allResultsFound
              ? MessageDivider("No more results found")
              : Center(child: const CircularProgressIndicator())
          );
        }
      }
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 10,
        titleSpacing: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontSize: 18
        )
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Theme.of(context).hintColor),
        border: InputBorder.none
      )
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}