import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';

class UserTile extends StatelessWidget {
  final Usr user;

  const UserTile(this.user, {super.key});

  void navigateToUserPage(BuildContext context) {

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => navigateToUserPage(context),
          splashColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
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
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
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

                            // TODO Nickname
                            // if (nickname is present)
                            Text(
                              "Lil Chigga",
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.tertiary
                              )
                            )
                          ]
                        ),

                        // TODO Chat room role
                        Text(
                          "Member", // if Admin then text green
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary
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
    );
  }
}