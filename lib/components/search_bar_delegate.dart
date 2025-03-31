import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/invites_operations_bloc/invites_operations_bloc.dart';
import '../blocs/search_bloc/search_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../cubits/staged_members_cubit.dart';
import 'tiles/add_group_member_tile.dart';
import 'tiles/room_search_tile.dart';
import 'tiles/user_with_invite_tile.dart';

class SearchBarDelegate extends SearchDelegate {
  final SearchTarget searchTarget;
  final SearchBloc searchBloc;
  final UsrBloc usrBloc;
  final InvitesOperationsBloc? invOpsBloc; // Needed only for friends searching
  final StagedMembersCubit? stagedMembersCubit; // For managing staged members to add to new group

  bool isInitialSearch = true;

  final ScrollController scrollController = ScrollController();
  VoidCallback? scrollListener;

  SearchBarDelegate({
    required this.searchTarget,
    required this.searchBloc,
    required this.usrBloc,
    this.invOpsBloc,
    this.stagedMembersCubit
  });

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
      return Center(child: Text("Search :)", style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)));
    }
    
    searchBloc.add(SearchQuery(usrBloc.state.user!.id, searchTarget, query, null, stagedMembersCubit?.state.map((usr) => usr.id).toList()));

    scrollListener ??= () => _fetchMore();
    scrollController.addListener(scrollListener!); // TODO maybe scroll controller should be inside to rebuild on each rebuild (?)
    
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
          } else if (state.status == SearchStatus.success) {
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
        SearchQuery(usrBloc.state.user!.id, searchTarget, query, searchBloc.state.results, stagedMembersCubit?.state.map((usr) => usr.id).toList())
      );
    }
  }

  ListView listViewForSearchTarget(SearchState state, BuildContext context) {
    double cacheExtent = MediaQuery.of(context).size.height * 1.5;

    return switch (searchTarget) {
      SearchTarget.users => ListView.builder(
        cacheExtent: cacheExtent,
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: state.results.$1.length + (state.status == SearchStatus.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.results.$1.length) {
            return UserWithInviteTile(
              key: ValueKey(state.results.$1[index].id),
              state.results.$1[index],
              state.results.$2[index]?.$1,
              state.results.$2[index]?.$2,
              invOpsBloc!,
              usrBloc
            );
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        }
      ),
      SearchTarget.newGroupMembers => ListView.builder(
        cacheExtent: cacheExtent,
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: state.results.length + (state.status == SearchStatus.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.results.length) {
            return AddGroupMemberTile(
              key: ValueKey(state.results[index].id),
              user: state.results[index],
              callbackIcon: Icons.add,
              isMemberSubjectToAddition: true,
              onButtonInvoked: (user) {
                stagedMembersCubit!.stageMember(user);
              }
            );
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        }
      ),
      SearchTarget.chatRooms => ListView.builder(
        cacheExtent: cacheExtent,
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: state.results.length + (state.status == SearchStatus.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.results.length) {
            return RoomSearchTile(
              key: ValueKey(state.results[index].$1.id),
              room: state.results[index].$1,
              username: state.results[index].$2,
              userPicUrl: state.results[index].$3,
              usrBloc: usrBloc
            );
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        }
      ),
      SearchTarget.messages => throw UnimplementedError(),   // TODO: Handle this case.
      SearchTarget.groupMembers => throw UnimplementedError()   // TODO: Handle this case.
    };

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
    if (scrollListener != null) scrollController.removeListener(scrollListener!);
    scrollController.dispose();

    super.dispose();
  }
}