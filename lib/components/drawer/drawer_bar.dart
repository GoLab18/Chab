import 'package:chab/blocs/theme_bloc/theme_bloc.dart';
import 'package:chab/util/shared_preferences_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrawerBar extends StatefulWidget {
  const DrawerBar({super.key});

  @override
  State<DrawerBar> createState() => _DrawerBarState();
}

class _DrawerBarState extends State<DrawerBar> {
  // TODO
  // final String username = context.read<UsrBloc>().;

  void toggleThemes() {
    context.read<ThemeBloc>().add(
      ToggleThemes()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(height: 140),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  // Profile picture
                  CircleAvatar(
                    radius: 40,
                    // TODO
                    // backgroundImage: Image.asset(),
                    // foregroundImage: Image.asset(),
                    // onForegroundImageError: (exception, stackTrace) {
                      
                    // }
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    child: Icon(
                      Icons.person_outlined,
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  ),
              
                  // Dark mode toggle
                  IconButton(
                    onPressed: toggleThemes,
                    icon: Icon(
                      SharedPreferencesUtil.isDarkTheme
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  )
                ]
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // Username
                Text(
                  // TODO change it for the username
                  "",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                ),
                
                // Username
                Text(
                  // TODO change it for: online, offline, unseen accordingly etc.
                  // (either based on the database field or idk, shared_references?)
                  "",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary
                  )
                )
              ]
            )
          ],
        ),
      ),
    );
  }
}