import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';

class AddGroupMemberTile extends StatelessWidget {
  final Usr user;
  final IconData callbackIcon;
  final void Function(Usr) onButtonInvoked;

  const AddGroupMemberTile({
    super.key,
    required this.user,
    required this.callbackIcon,
    required this.onButtonInvoked
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          splashColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 24,
                  foregroundImage: user.picture.isNotEmpty
                    ? NetworkImage(user.picture)
                    : null,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: Icon(
                    Icons.person_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                ),
                    
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 2,
                      bottom: 2
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Username
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Text(
                                user.name,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary
                                )
                              )
                            )
                          ),

                          IconButton(
                            onPressed: () {
                              onButtonInvoked(user);
                            },
                            icon: Icon(
                              callbackIcon,
                              color: Theme.of(context).colorScheme.inversePrimary,
                              size: 18
                            )
                          )
                        ]
                      )
                    )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}