import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/room_members_bloc/room_members_bloc.dart';
import '../../blocs/room_bloc/room_bloc.dart';
import '../../pages/group_chat_page.dart';
import '../../pages/private_chat_page.dart';
import '../../util/room_name_util.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatRoomAppBar({super.key});

  @override
  // PreferredSizeWidget interface implementation
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void navigateToChatPage<T>(BuildContext context, bool isPrivateChat, String roomId, T initialData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext pageContext) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<RoomMembersBloc>()
            ),
            BlocProvider.value(
              value: context.read<RoomBloc>()
            )
          ],
          child: isPrivateChat ? PrivateChatPage(initialData as Usr) : GroupChatPage(initialData as Map<String, Usr>)
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomMembersBloc, RoomMembersState>(
      builder: (context, roomMembersState) => BlocBuilder<RoomBloc, RoomState>(
        builder: (context, roomState) => Builder(
          builder: (context) {
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
              
              return switch (room.isPrivate) {
      
                // Private chat room info
                true => StreamBuilder<Usr>(
                  stream: roomMembersState.privateChatRoomFriend,
                  builder: (context, snapshot) => AppBar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 10,
                    automaticallyImplyLeading: true,
                    title: Builder(
                      builder: (context) {
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
                            
                        Usr friend = snapshot.data!;
                            
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              foregroundImage: friend.picture.isNotEmpty
                                ? NetworkImage(friend.picture)
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
                                        (roomState.status == ChatRoomStatus.success)
                                          ? Text(
                                            friend.name,
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
                    ),
                    centerTitle: false,
                    titleSpacing: 15,
                    leadingWidth: 30,
                    actions: [
                      IconButton(
                        onPressed: () {
                          if (roomState.status == ChatRoomStatus.success) {
                            navigateToChatPage(context, room.isPrivate, room.id, snapshot.data!);
                          }
                        },
                        icon: Icon(
                          Icons.info_outlined,
                          color: Theme.of(context).colorScheme.inversePrimary
                        )
                      )
                    ]
                  )
                ),
      
                // Group chat room info
                false => StreamBuilder<Map<String, Usr>>(
                  stream: roomMembersState.roomMembersStream,
                  builder: (context, snapshot) => AppBar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 10,
                    automaticallyImplyLeading: true,
                    title: Builder(
                      builder: (context) {
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
                                
                        List<Usr> usersList = snapshot.data!.values.toList();
                            
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              foregroundImage: room.picture!.isNotEmpty
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Chat room's name
                                        (roomState.status == ChatRoomStatus.success)
                                          ? Text(
                                            (room.name != null && room.name!.isNotEmpty)
                                              ? room.name!
                                              : RoomNameUtil.getUserNames(usersList), // max 33 chars can fit
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
                                    )
                                  )
                                )
                              )
                            )
                          ]
                        );
                      }
                    ),
                    centerTitle: false,
                    titleSpacing: 15,
                    leadingWidth: 30,
                    actions: [
                      IconButton(
                        onPressed: () {
                          if (roomState.status == ChatRoomStatus.success) {
                            navigateToChatPage(context, room.isPrivate, room.id, snapshot.data!);
                          }
                        },
                        icon: Icon(
                          Icons.info_outlined,
                          color: Theme.of(context).colorScheme.inversePrimary
                        )
                      )
                    ]
                  )
                )
              };
            }
      
            throw Exception("Non-existent room_bloc or room_members_bloc state");
          }
        )
      )
    );
  }
}
