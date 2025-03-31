import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/message_bloc/message_bloc.dart';
import '../../blocs/messages_bloc/messages_bloc.dart';
import '../../blocs/room_bloc/room_bloc.dart';
import '../../blocs/room_members_bloc/room_members_bloc.dart';
import '../../blocs/usr_bloc/usr_bloc.dart';
import '../../pages/chat_room_page.dart';

class RoomSearchTile extends StatelessWidget {
  final String roomId;
  final bool isPrivate;
  final String name;
  final String? picUrl;
  final UsrBloc usrBloc;

  const RoomSearchTile({
    super.key,
    required this.roomId,
    required this.isPrivate,
    required this.name,
    this.picUrl,
    required this.usrBloc
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext pageContext) => MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: usrBloc
              ),
              BlocProvider(
                create: (_) => RoomMembersBloc(
                  userRepository: context.read<FirebaseUserRepository>()
                )..add(
                  isPrivate
                    ? PrivateChatRoomMembersRequested(
                      roomId: roomId,
                      currentUserId: usrBloc.state.user!.id
                    )
                    : GroupChatRoomMembersRequested(roomId)
                )
              ),
              BlocProvider(
                create: (_) => RoomBloc(
                  roomRepository: context.read<FirebaseRoomRepository>()
                )..add(RoomRequested(roomId))
              ),
              BlocProvider(
                create: (BuildContext messageBlocContext) => MessageBloc(
                  roomRepository: context.read<FirebaseRoomRepository>()
                )
              ),
              BlocProvider(
                create: (BuildContext messagesBlocContext) => MessagesBloc(
                  roomRepository: context.read<FirebaseRoomRepository>()
                )..add(MessagesRequested(roomId))
              )
            ],
            child: const ChatRoomPage()
          )
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 30,
                  foregroundImage: (picUrl != null && picUrl!.isNotEmpty)
                    ? NetworkImage(picUrl!)
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
                      top: 8,
                      bottom: 8
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          )
                        ),

                        Text(
                          (isPrivate) ? "Private chat" : "Group chat",
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
                )
              ]
            )
          )
        )
      )
    );
  }
}