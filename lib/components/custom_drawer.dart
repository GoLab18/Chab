import 'package:chab/authentication/auth_service.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});


  void logout() {
    final authService = AuthService();
    
    authService.signOut();
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