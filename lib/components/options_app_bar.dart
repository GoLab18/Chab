import 'package:flutter/material.dart';

import '../pages/change_account_page.dart';

class OptionsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OptionsAppBar({super.key});

  @override
  // PreferredSizeWidget interface implementation
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      elevation: 10,
      automaticallyImplyLeading: true,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 30,
      actions: <PopupMenuButton<String>>[
        PopupMenuButton<String>(
          color: Theme.of(context).colorScheme.secondary,
          icon: Icon(
            Icons.more_vert_outlined,
            color: Theme.of(context).colorScheme.inversePrimary
          ),
          onSelected: (String value) {
            if (value == "Accounts") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const ChangeAccountPage()
                )
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: "Accounts",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.manage_accounts_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  Text(
                    " Accounts",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  ),
                ],
              )
            )
          ]
        )
      ]
    );
  }
}
