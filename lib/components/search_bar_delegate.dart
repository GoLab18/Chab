import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/search_bloc/search_bloc.dart';
import 'tiles/user_with_invite_tile.dart';

class SearchBarDelegate extends SearchDelegate {
  final SearchTarget searchTarget;
  final SearchBloc searchBloc;
  final String currUserId;

  final ScrollController scrollController = ScrollController();
  VoidCallback? scrollListener;

  final cache = <String, dynamic>{}; // TODO implement caching for searching (adjust value type) and don't allow parallel requests

  SearchBarDelegate(this.searchTarget, this.searchBloc, this.currUserId);

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
    if (query.isEmpty) return Center(child: Text("Search :)"));

    searchBloc.add(SearchEvent(currUserId, searchTarget, query, null));

    scrollListener ??= () => _fetchMore();
    scrollController.addListener(scrollListener!); // TODO maybe scroll controller should be inside to rebuild on each rebuild (?)
    
    return BlocBuilder<SearchBloc, SearchState>(
      bloc: searchBloc,
      builder: (context, state) {
        if (state.status == SearchStatus.success) {
          return listViewForSearchTarget(state);
        } else if (state.status == SearchStatus.loading) {
          return Center(child: const CircularProgressIndicator());
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
    );
  }

  void _fetchMore() {
    if (
      scrollController.position.pixels == scrollController.position.maxScrollExtent
      && searchBloc.state.status == SearchStatus.success
    ) {
      searchBloc.add(SearchEvent(currUserId, searchTarget, query, searchBloc.state.results));
    }
  }

  ListView listViewForSearchTarget(SearchState state) {
    return switch (searchTarget) {
      SearchTarget.users => ListView.builder(                // TODO key magic for every tile for less rebuilds (?)
        cacheExtent: 500, // TODO 10 * item height (in pixels)
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: state.results.$1.length + (state.status == SearchStatus.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.results.$1.length) {
            return UserWithInviteTile(state.results.$1[index], state.results.$2[index]?.$1, state.results.$2[index]?.$2);
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        }
      ),
      SearchTarget.chatRooms => throw UnimplementedError(), // TODO: Handle this case.
      SearchTarget.messages => throw UnimplementedError(),   // TODO: Handle this case.
      SearchTarget.members => throw UnimplementedError(),   // TODO: Handle this case.
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