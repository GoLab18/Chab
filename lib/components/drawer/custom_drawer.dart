import 'package:chab/blocs/auth_bloc/auth_bloc.dart';
import 'package:chab/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawer_bar.dart';
import 'drawer_tile.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  void logout() {
    context.read<SignInBloc>().add(SignOutRequested());
    context.read<AuthBloc>().add(const AuthUserChanged());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      shape: const BeveledRectangleBorder(),
      child: Center(
        child: ListView(
          children: [

            // Bar with user info and theme toggle
            const DrawerBar(),
            
            Divider(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),

            // Profile
            DrawerTile(
              tileIcon: Icons.person_outline,
              title: "Profile",
              onTap: () {}
            ),

            Divider(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),

            // New Group
            DrawerTile(
              tileIcon: Icons.group_add_outlined,
              title: "New Group",
              onTap: () {}
            ),

            // Add Friends
            DrawerTile(
              tileIcon: Icons.person_add_alt_1_outlined,
              title: "Add Friends",
              onTap: () {}
            ),

            Divider(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),

            // Settings
            DrawerTile(
              tileIcon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {}
            ),

            // Logout
            DrawerTile(
              tileIcon: Icons.logout_outlined,
              title: "Logout",
              onTap: logout
            )
          ]
        )
      )
    );
  }
}