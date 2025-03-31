import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';

class AddGroupMemberTile extends StatefulWidget {
  final Usr user;
  final IconData callbackIcon;
  final bool isMemberSubjectToAddition;
  final void Function(Usr) onButtonInvoked;

  const AddGroupMemberTile({
    super.key,
    required this.user,
    required this.callbackIcon,
    required this.isMemberSubjectToAddition,
    required this.onButtonInvoked
  });

  @override
  State<AddGroupMemberTile> createState() => _AddGroupMemberTileState();
}

class _AddGroupMemberTileState extends State<AddGroupMemberTile> {
  bool isAdded = false;
  
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
                  foregroundImage: widget.user.picture.isNotEmpty
                    ? NetworkImage(widget.user.picture)
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
                      top: 16,
                      bottom: 16
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Username
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Text(
                              widget.user.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inversePrimary
                              )
                            )
                          )
                        ),
                    
                        if (!isAdded) IconButton.filled(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          onPressed: () {
                            widget.onButtonInvoked(widget.user);
                    
                            if (widget.isMemberSubjectToAddition) {
                              setState(() {
                                isAdded = true;
                              });
                            }
                          },
                          icon: Icon(
                            widget.callbackIcon,
                            size: 18,
                            color: Theme.of(context).colorScheme.inversePrimary
                          )
                        ),
                    
                        if (isAdded) Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Added",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary
                            )
                          )
                        )
                      ]
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