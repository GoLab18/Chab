import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/bloc/room_members_bloc.dart';
import '../../blocs/room_bloc/room_bloc.dart';
import '../../util/room_name_util.dart';

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
        child: BlocBuilder<RoomMembersBloc, RoomMembersState>(
          builder: (context, roomMembersState) => BlocBuilder<RoomBloc, RoomState>(
              builder: (context, roomState) {
                if (roomMembersState.status == ChatRoomMembersStatus.loading || roomState.status == ChatRoomStatus.loading) {
                  const SizedBox(
                    child: CircularProgressIndicator()
                  );
                }
                if (roomMembersState.status == ChatRoomMembersStatus.failure || roomState.status == ChatRoomStatus.failure) {
                  return Text(
                    "Loading error",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  );
                }

                if (roomMembersState.status == ChatRoomMembersStatus.success && roomState.status == ChatRoomStatus.success) {
                  final room = roomState.roomTuple!.room;
      
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Chat room photo
                      CircleAvatar(
                        radius: 24,
                        foregroundImage: room.isPrivate
                          ? roomMembersState.privateChatRoomFriend!.picture.isNotEmpty
                            ? NetworkImage(roomMembersState.privateChatRoomFriend!.picture)
                            : null
                          : room.picture!.isNotEmpty
                            ? NetworkImage(room.picture!)
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
                              child: !room.isPrivate
                                
                                // Group chat room data
                                ? StreamBuilder<Map<String, Usr>>(
                                  stream: context.read<RoomMembersBloc>().state.roomMembersStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: CircularProgressIndicator()
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Text(
                                        "Loading error",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context).colorScheme.inversePrimary
                                        )
                                      );
                                    }

                                    // Casting to a list for this widget specifically
                                    List<Usr> usersList = snapshot.data!.values.toList();
                                    
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Chat room's name
                                        (roomState.status == ChatRoomStatus.success)
                                          ? Text(
                                            (room.name != null && room.name!.isNotEmpty)
                                              ? room.name!
                                              : RoomNameUtil.getUserNames(usersList), // TODO check max amount
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
                                              (roomState.status == ChatRoomStatus.success)
                                                ? Text(
                                                  "${usersList.length} members",
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
                                    );
                                  }
                                )
                                
                                // Private chat room data
                                : Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Chat room's name
                                  (roomState.status == ChatRoomStatus.success)
                                    ? Text(
                                      roomMembersState.privateChatRoomFriend!.name,
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
                                        (roomState.status == ChatRoomStatus.success)
                                          ? Text(
                                            "online", // TODO
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
                              )
                            )
                          )
                        )
                      )
                    ]
                  );
                }

                throw Exception("Non-existent room_bloc or room_members_bloc state");
              }
            )
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
