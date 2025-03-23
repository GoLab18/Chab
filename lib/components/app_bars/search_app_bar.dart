import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/invites_operations_bloc/invites_operations_bloc.dart';
import '../../blocs/search_bloc/search_bloc.dart';
import '../../blocs/usr_bloc/usr_bloc.dart';
import '../search_bar_delegate.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final SearchTarget searchTarget;

  const SearchAppBar({super.key, required this.searchTarget});

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
  
  // PreferredSizeWidget interface implementation
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      elevation: 10,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Chab",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold
          )
        )
      ),
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 30,
      actions: <IconButton>[
        IconButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: SearchBarDelegate(
                widget.searchTarget,
                context.read<UsrBloc>().state.user!.id,
                context.read<SearchBloc>(),
                context.read<InvitesOperationsBloc>(),
                context.read<UsrBloc>()
              )
            );
          },
          icon: Icon(
            Icons.search_outlined,
            color: Theme.of(context).colorScheme.inversePrimary
          )
        )
      ]
    );
  }
}