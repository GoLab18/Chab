import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/room_members_bloc/room_members_bloc.dart';
import '../../blocs/room_bloc/room_bloc.dart';
import '../../blocs/room_operations_bloc/room_operations_bloc.dart';
import '../../pages/group_chat_page.dart';
import '../../pages/private_chat_page.dart';
import '../../util/room_name_util.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatRoomAppBar({super.key});

  @override
  // PreferredSizeWidget interface implementation
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void navigateToChatPage(BuildContext context, bool isPrivateChat, String roomId) {
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
            ),
            BlocProvider(
              create: (BuildContext roomOpBlocContext) => RoomOperationsBloc(
                roomRepository: context.read<FirebaseRoomRepository>()
              )
            )
          ],
          child: isPrivateChat ? const PrivateChatPage() : const GroupChatPage()
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, roomState) => BlocBuilder<RoomMembersBloc, RoomMembersState>(
        builder: (context, roomMembersState) => AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          elevation: 10,
          automaticallyImplyLeading: true,
          title: Builder(
            builder: (context) {
              if (
                  roomState.status == RoomStatus.loading
                  || roomMembersState.status == RoomMembersStatus.loading
                  || roomState.room == null
                  || (roomMembersState.privateChatRoomFriend == null && roomMembersState.groupMembers == null)
              ) {
                return const SizedBox(
                  child: CircularProgressIndicator()
                );
              }
              
              if (
                roomState.status == RoomStatus.failure
                || roomMembersState.status == RoomMembersStatus.failure
              ) {
                return Text(
                  "Loading error",
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                );
              }

              Room room = roomState.room!;

              // Private chat room info
              if (room.isPrivate) {
                return Builder(
                  builder: (context) {
                    Usr friend = roomMembersState.privateChatRoomFriend!;

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
                                    Text(
                                      friend.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.inversePrimary
                                      )
                                    ),
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Text(
                                            "online", // TODO
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
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
                );
              }
              
              // Group chat room info
              else {
                return Builder(
                  builder: (context) {
                    List<Usr> usersList = roomMembersState.groupMembers!.values.toList();
                    
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
                            Icons.people_outlined,
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
                                    (roomState.status == RoomStatus.success)
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
                                          Text(
                                            "${usersList.length} members",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
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
                );
              }
            }
          ),
          centerTitle: false,
          titleSpacing: 15,
          leadingWidth: 30,
          actions: [
            IconButton(
              onPressed: () {
                if (roomState.status == RoomStatus.success && roomState.room != null) {
                  navigateToChatPage(context, roomState.room!.isPrivate, roomState.room!.id);
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
    );
  }
}
