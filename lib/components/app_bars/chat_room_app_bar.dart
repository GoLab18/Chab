import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/room_bloc/room_bloc.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatRoomAppBar({super.key});

  @override
  // PreferredSizeWidget interface implementation
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      elevation: 10,
      automaticallyImplyLeading: true,
      title: GestureDetector(
        onTap: () {},
        child: BlocBuilder<RoomBloc, RoomState>(
          builder: (context, state) {
            if (state.status == ChatRoomStatus.failure) {
              return Text(
                  "Loading error",
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Chat room photo
                CircleAvatar(
                  radius: 24,
                  foregroundImage: (state.status == ChatRoomStatus.success && state.roomTuple!.room.picture.isNotEmpty)
                    ? NetworkImage(state.roomTuple!.room.picture)
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
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.expand(height: kBottomNavigationBarHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chat room name
                            (state.status == ChatRoomStatus.success)
                              ? Text(
                                state.roomTuple!.room.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.inversePrimary
                                )
                              )
                              : CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.inversePrimary
                              ),
                            Flexible(
                              child: Row(
                                children: [
                                  (state.status == ChatRoomStatus.success)
                                    ? Text(
                                      state.roomTuple!.room.isPrivate
                                       ? "online"
                                       : "${state.roomTuple!.room.members.length} members",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.tertiary
                                      )
                                    )
                                    : SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context).colorScheme.tertiary
                                      )
                                    )
                                ]
                              )
                            )
                          ]
                        ),
                      ),
                    )
                  )
                )
              ]
            );
          }
        )
      ),
      centerTitle: false,
      titleSpacing: 15,
      leadingWidth: 30,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.info_outlined,
            color: Theme.of(context).colorScheme.inversePrimary
          )
        )
      ]
    );
  }
}