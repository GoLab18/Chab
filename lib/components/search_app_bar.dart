import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchAppBar({super.key});

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
  
  // PreferredSizeWidget interface implementation
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool isInSearchMode = false;

  // Replaces the app bar components with the search bar
  void toggleSearchMode() {
    setState(() {
      isInSearchMode = !isInSearchMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      elevation: 10,
      automaticallyImplyLeading: !isInSearchMode,
      title: isInSearchMode
        ? SearchBar(
          elevation: const WidgetStatePropertyAll(0),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(0)
              )
            )
          ),
          hintText: "Search..",
          hintStyle: WidgetStatePropertyAll(
            TextStyle(
              color: Theme.of(context).hintColor
            ),
          ),
          backgroundColor: const WidgetStatePropertyAll(
            Colors.transparent
          ),
          autoFocus: true
        )
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Chab",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold
            )
          ),
        ),
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 30,
      leading: isInSearchMode
        ? IconButton(
          onPressed: toggleSearchMode,
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.inversePrimary
          )
        )
        : null,
      actions: <IconButton>[
        IconButton(
          onPressed: isInSearchMode
            ? () {
              // TODO Searching
              toggleSearchMode();
            }
            : toggleSearchMode,
          icon: Icon(
            Icons.search_outlined,
            color: Theme.of(context).colorScheme.inversePrimary
          )
        )
      ]
    );
  }
}