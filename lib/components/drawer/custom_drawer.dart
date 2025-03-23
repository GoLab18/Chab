import 'package:chab/blocs/auth_bloc/auth_bloc.dart';
import 'package:chab/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/change_usr_info_bloc/change_usr_info_bloc.dart';
import '../../blocs/invites_operations_bloc/invites_operations_bloc.dart';
import '../../blocs/invites_bloc/invites_bloc.dart';
import '../../blocs/room_operations_bloc/room_operations_bloc.dart';
import '../../blocs/search_bloc/search_bloc.dart';
import '../../blocs/usr_bloc/usr_bloc.dart';
import '../../pages/find_friends_page.dart';
import '../../pages/profile_page.dart';
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

  void openProfilePage() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext pageContext) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<UsrBloc>(),
            ),
            BlocProvider.value(
              value: context.read<ChangeUsrInfoBloc>(),
            )
          ],
          child: const ProfilePage()
        )
      )
    );
  }

  void openFindFriendsPage() {
    Navigator.pop(context);

    FirebaseUserRepository fuRepo = context.read<FirebaseUserRepository>();
    String userId = context.read<UsrBloc>().state.user!.id;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext pageContext) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<SearchBloc>()
            ),
            BlocProvider.value(
              value: context.read<UsrBloc>()
            ),
            BlocProvider(
              create: (context) => InvitesBloc(
                userRepository: fuRepo
              )..add(InvitesEvent(userId))
            ),
            BlocProvider(
              create: (context) => InvitesOperationsBloc(
                userRepository: fuRepo
              )
            ),
            BlocProvider(
              create: (context) => RoomOperationsBloc(
                roomRepository: context.read<FirebaseRoomRepository>()
              )
            )
          ],
          child: FindFriendsPage(userId)
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      shape: const BeveledRectangleBorder(),
      child: Center(
        child: ListView(
          children: [

            // Bar with user info, status and theme toggle
            const DrawerBar(),
            
            Divider(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),

            // Profile
            DrawerTile(
              tileIcon: Icons.person_outline,
              title: "Profile",
              onTap: openProfilePage
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
              title: "Find Friends",
              onTap: openFindFriendsPage
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