import 'package:chab/blocs/theme_bloc/theme_bloc.dart';
import 'package:chab/util/shared_preferences_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/usr_bloc/usr_bloc.dart';

class DrawerBar extends StatelessWidget {
  const DrawerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8
      ),
      child: BlocBuilder<UsrBloc, UsrState>(
        builder: (context, state) {
          if (state.status == UsrStatus.failure) {
            return ConstrainedBox(
              constraints: const BoxConstraints.expand(height: 140),
              child: Center(
                child: Text(
                  "Loading error",
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                )
              )
            );
          }

          return ConstrainedBox(
            constraints: const BoxConstraints.expand(height: 140),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // Profile picture
                      CircleAvatar(
                        radius: 36,
                        foregroundImage: (state.status == UsrStatus.success && state.user!.picture.isNotEmpty)
                          ? NetworkImage(state.user!.picture)
                          : null,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        child: Icon(
                          Icons.person_outlined,
                          color: Theme.of(context).colorScheme.inversePrimary
                        )
                      ),
                  
                      // Dark mode toggle
                      IconButton(
                        onPressed: () => context.read<ThemeBloc>().add(ToggleThemes()),
                        icon: Icon(
                          SharedPreferencesUtil.isDarkTheme
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                          color: Theme.of(context).colorScheme.inversePrimary
                        )
                      )
                    ]
                  )
                ),
    
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  
                      // Username
                      (state.status == UsrStatus.success)
                        ? Text(
                          state.user!.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary
                          )
                        )
                        : SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          )
                        ),
                      
                      // Status
                      Text(
                        // TODO change it for: online, offline, unseen accordingly etc.
                        // (either based on the database field or idk, shared_references?)
                        // Status choice menu (?)
                        "online",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary
                        )
                      )
                    ]
                  )
                )
              ]
            )
          );
        }
      ),
    );
  }
}
