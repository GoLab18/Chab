import 'package:chab/blocs/auth_bloc/auth_bloc.dart';
import 'package:chab/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:chab/components/drawer_bar.dart';
import 'package:chab/components/drawer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});


  void logout() {
    context.read<SignInBloc>().add(SignOutRequested());
    context.read<AuthBloc>().add(const AuthUserChanged());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            DrawerHeader(
              child: Icon(
                Icons.message_sharp,
                color: Theme.of(context).colorScheme.primary
              )
            ),
        
            // Logout
            ListTile(
              onTap: () => logout(),
              leading: const Icon(
                Icons.logout_outlined
              ),
              title: Center(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              titleAlignment: ListTileTitleAlignment.center,
              trailing: const Icon(
                Icons.arrow_back
              )
            )
          ]
        ),
      )
    );
  }
}